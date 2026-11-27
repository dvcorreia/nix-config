package main

import (
	"bytes"
	"os"
	"path/filepath"
	"testing"

	"filippo.io/age"
	page "filippo.io/age/plugin"
	"github.com/olastor/age-plugin-fido2-hmac/pkg/plugin"
)

// countingDevice wraps plugin.MockFido2Device with a GetHmacSecret call
// counter. Upstream PR olastor/age-plugin-fido2-hmac#53 added the equivalent
// GetHmacSecretCalls field to the mock; once that lands this wrapper can go.
type countingDevice struct {
	plugin.MockFido2Device
	touches int
}

func (d *countingDevice) GetHmacSecret(credential, salt []byte, pin string) ([]byte, error) {
	d.touches++
	return bytes.Clone(d.HmacSecret), nil
}

// batchFixture provides a version-2 FIDO2 identity with its secret unloaded,
// plus one file encrypted to its native recipient per given name.
type batchFixture struct {
	directory string
	identity  *plugin.Fido2HmacIdentity
	device    *countingDevice
	pins      *int
	files     []string // name, path, name, path, ...
}

func newBatchFixture(t *testing.T, names ...string) *batchFixture {
	t.Helper()

	// A FIDO2 version-2 identity derives its native X25519 key from these bytes.
	secret := bytes.Repeat([]byte{42}, 32)
	device := &countingDevice{MockFido2Device: plugin.MockFido2Device{HmacSecret: secret}}
	pins := new(int)
	identity := &plugin.Fido2HmacIdentity{
		Version:    2,
		RequirePin: true,
		CredId:     []byte("test-credential"),
		Salt:       bytes.Repeat([]byte{1}, 32),
		Device:     device,
		UI: &page.ClientUI{
			RequestValue: func(name, prompt string, secret bool) (string, error) {
				*pins++
				return "123456", nil
			},
			DisplayMessage: func(name, message string) error { return nil },
		},
	}
	t.Cleanup(identity.ClearSecret)
	if err := identity.LoadSecret("123456"); err != nil {
		t.Fatal(err)
	}
	native, err := identity.X25519Identity()
	if err != nil {
		t.Fatal(err)
	}

	// Drop the derived secret so tests observe their own unlocks only.
	identity.ClearSecret()
	device.touches = 0
	*pins = 0

	fixture := &batchFixture{
		directory: t.TempDir(),
		identity:  identity,
		device:    device,
		pins:      pins,
	}
	for _, name := range names {
		input := filepath.Join(t.TempDir(), name+".age")
		var ciphertext bytes.Buffer
		w, err := age.Encrypt(&ciphertext, native.Recipient())
		if err != nil {
			t.Fatal(err)
		}
		if _, err := w.Write([]byte(name)); err != nil {
			t.Fatal(err)
		}
		if err := w.Close(); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(input, ciphertext.Bytes(), 0o600); err != nil {
			t.Fatal(err)
		}
		fixture.files = append(fixture.files, name, input)
	}
	return fixture
}

func (f *batchFixture) decrypt(t *testing.T, files []string) error {
	t.Helper()
	return decryptFiles([]age.Identity{f.identity}, f.directory, files)
}

func TestDecryptFilesUnlocksOnce(t *testing.T) {
	fixture := newBatchFixture(t, "first", "second", "third")
	if err := fixture.decrypt(t, fixture.files); err != nil {
		t.Fatal(err)
	}
	if *fixture.pins != 1 || fixture.device.touches != 1 {
		t.Fatalf("got %d PIN requests and %d touches; want one each", *fixture.pins, fixture.device.touches)
	}
	for i := 0; i < len(fixture.files); i += 2 {
		output := filepath.Join(fixture.directory, fixture.files[i])
		data, err := os.ReadFile(output)
		if err != nil || string(data) != fixture.files[i] {
			t.Fatalf("unexpected plaintext for %s: %v", fixture.files[i], err)
		}
		info, err := os.Stat(output)
		if err != nil || info.Mode().Perm() != 0o600 {
			t.Fatalf("unexpected permissions for %s: %v", fixture.files[i], err)
		}
	}
}

func TestDecryptFilesKeepsExistingOutputs(t *testing.T) {
	fixture := newBatchFixture(t, "new", "existing")
	existing := filepath.Join(fixture.directory, "existing")
	if err := os.WriteFile(existing, []byte("keep"), 0o600); err != nil {
		t.Fatal(err)
	}
	if err := fixture.decrypt(t, fixture.files); err == nil {
		t.Fatal("expected failure for an existing output")
	}
	if _, err := os.Stat(filepath.Join(fixture.directory, "new")); !os.IsNotExist(err) {
		t.Fatal("failed batch left a decrypted file behind")
	}
	data, _ := os.ReadFile(existing)
	if string(data) != "keep" {
		t.Fatal("existing output was overwritten")
	}
}

func TestDecryptFilesRollsBackOnCorruption(t *testing.T) {
	fixture := newBatchFixture(t, "valid", "corrupted")
	ciphertext, err := os.ReadFile(fixture.files[1])
	if err != nil {
		t.Fatal(err)
	}
	ciphertext[len(ciphertext)-1] ^= 1
	corrupted := filepath.Join(t.TempDir(), "corrupted.age")
	if err := os.WriteFile(corrupted, ciphertext, 0o600); err != nil {
		t.Fatal(err)
	}
	if err := fixture.decrypt(t, []string{"valid", fixture.files[1], "corrupted", corrupted}); err == nil {
		t.Fatal("expected failure for a corrupted ciphertext")
	}
	for _, name := range []string{"valid", "corrupted"} {
		if _, err := os.Stat(filepath.Join(fixture.directory, name)); !os.IsNotExist(err) {
			t.Fatalf("failed batch left %s behind", name)
		}
	}
}
