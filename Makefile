NIX_USER ?= dvcorreia

# The name of the nixosConfiguration in the flake
# you can find darwin host name with: scutil --get LocalHostName
NIXNAME ?= macbook-pro-intel

# We need to do some OS switching below.
UNAME := $(shell uname)

NIX_OPTS += --extra-experimental-features nix-command
NIX_OPTS += --extra-experimental-features flakes

switch:
ifeq ($(UNAME), Darwin)
	nix build $(NIX_OPTS) ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"
endif

format:
	nix-shell -p nixfmt-rfc-style --command "nixfmt **/*.nix"