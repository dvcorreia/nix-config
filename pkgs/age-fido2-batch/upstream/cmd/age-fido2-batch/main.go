// Command age-fido2-batch decrypts multiple age files with a FIDO2 identity
// using a single unlock: one PIN prompt and one touch for the whole batch.
//
// Stock `age -d` spawns a fresh plugin process per file and the age plugin
// protocol has no bulk mode (olastor/age-plugin-fido2-hmac#15), so decrypting
// N files costs N PIN prompts and touches. Decrypting every file in one
// process lets the identity cache its secret after the first stanza unwrap
// and reuse it for all remaining files.
//
// Only version-2 identities are supported. Their HMAC salt is fixed in the
// identity, so one secret unwraps every file. Version-1 identities carry the
// salt in each encrypted stanza and would still need one touch per file.
package main

import (
	"fmt"
	"os"
	"time"

	"filippo.io/age"
	page "filippo.io/age/plugin"
	"github.com/olastor/age-plugin-fido2-hmac/pkg/plugin"
)

// deviceFindTimeout matches the polling window used by the upstream CLI.
const deviceFindTimeout = 50 * time.Second

func main() {
	os.Exit(run(os.Args[1:]))
}

func run(args []string) int {
	if len(args) < 4 || len(args)%2 != 0 {
		fmt.Fprintln(os.Stderr, "usage: age-fido2-batch IDENTITY OUTPUT_DIR NAME FILE [NAME FILE ...]")
		return 2
	}

	identities, err := loadIdentities(args[0])
	if err != nil {
		return reportError(err)
	}
	for _, identity := range identities {
		defer identity.ClearSecret()
	}

	printf := func(format string, args ...any) {
		fmt.Fprintf(os.Stderr, format, args...)
	}
	ui := page.NewTerminalUI(printf, printf)

	device, err := plugin.FindDevice(deviceFindTimeout, func(message string) error {
		printf("%s\n", message)
		return nil
	})
	if err != nil {
		return reportError(err)
	}

	ageIdentities := make([]age.Identity, 0, len(identities))
	for _, identity := range identities {
		identity.UI = ui
		identity.Device = device
		ageIdentities = append(ageIdentities, identity)
	}

	if err := decryptFiles(ageIdentities, args[1], args[2:]); err != nil {
		return reportError(err)
	}
	return 0
}

// loadIdentities parses the identity file and rejects identities that cannot
// benefit from a single unlock (see the package comment).
func loadIdentities(path string) ([]*plugin.Fido2HmacIdentity, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer func() { _ = f.Close() }()

	identities, err := plugin.ParseIdentities(f)
	if err != nil {
		return nil, err
	}
	for _, identity := range identities {
		if identity.Version != 2 || len(identity.CredId) == 0 {
			return nil, fmt.Errorf("a version 2 split FIDO2 identity is required")
		}
	}
	return identities, nil
}

func reportError(err error) int {
	fmt.Fprintln(os.Stderr, "age-fido2-batch:", err)
	return 1
}
