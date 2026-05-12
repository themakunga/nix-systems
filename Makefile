.PHONY: darwin-kanagawa darwin-outer-heaven sd-cornholio sd-glados nix-cornholio nix-glados nix-mediaserver nix-motherbase nix-steamdeck install-darwin install-nixos

darwin-kanagawa:
	sudo darwin-rebuild switch .#darwinConfigurations.kanagawa  -L --accept-flake-config

darwin-outer-heaven:
	sudo darwin-rebuild switch .#darwinConfigurations.outer-heaven	 -L --accept-flake-config

sd-cornholio:
	nix build .#nixosConfigurations.cornholio-builder.config.system.build.sdImage -L --accept-flake-config

sd-glados:
	nix build .#nixosConfigurations.glados-builder.config.system.build.sdImage -L --accept-flake-config

nix-cornholio:
	nix build .#nixosConfigurations.cornholio  -L --accept-flake-config

nix-glados:
	nix build .#nixosConfigurations.glados -L --accept-flake-config

nix-mediaserver:
	nix build .#nixosConfigurations.mediaserver -L --accept-flake-config

nix-motherbase:
	nix build .#nixosConfigurations.motherbase -L --accept-flake-config

nix-steamdeck:
	nix build .#nixosConfigurations.steamdeck -L --accept-flake-config

install-darwin:
	sudo nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch

install-nixos:
	sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)


