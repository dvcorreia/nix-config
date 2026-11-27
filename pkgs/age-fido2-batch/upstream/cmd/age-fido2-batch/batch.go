package main

import (
	"fmt"
	"io"
	"os"
	"path/filepath"

	"filippo.io/age"
)

// decryptFiles decrypts each (name, file) pair of files into directory/name.
// The first stanza unwrap loads the identity secret from the token (PIN and
// touch); every file after that reuses the secret cached in the identity.
//
// Outputs are created exclusively and unlinked again when any decryption
// fails: a failed batch must never leave partial secrets behind or overwrite
// existing files. Callers such as devshell hooks re-run frequently and rely
// on an existing output meaning the whole batch succeeded.
func decryptFiles(identities []age.Identity, directory string, files []string) (err error) {
	var outputs []string
	defer func() {
		if err != nil {
			for _, output := range outputs {
				_ = os.Remove(output)
			}
		}
	}()

	for i := 0; i < len(files); i += 2 {
		output := filepath.Join(directory, files[i])
		if err = decryptFile(identities, files[i+1], output); err != nil {
			return fmt.Errorf("decrypting %s: %w", files[i], err)
		}
		outputs = append(outputs, output)
	}
	return nil
}

// decryptFile decrypts a single age file. The output is opened with O_EXCL so
// an existing file is never overwritten, and is removed when writing fails to
// avoid leaving truncated secrets behind.
func decryptFile(identities []age.Identity, input, output string) error {
	f, err := os.Open(input)
	if err != nil {
		return err
	}
	defer func() { _ = f.Close() }()

	r, err := age.Decrypt(f, identities...)
	if err != nil {
		return err
	}

	w, err := os.OpenFile(output, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o600)
	if err != nil {
		return err
	}

	_, copyErr := io.Copy(w, r)
	closeErr := w.Close()
	if copyErr != nil || closeErr != nil {
		_ = os.Remove(output)
		if copyErr != nil {
			return copyErr
		}
		return closeErr
	}
	return nil
}
