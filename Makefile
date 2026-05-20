NIXOSRUN = nix run
NIXRUN = nix run nixpkgs\#
NIXBUILD = nix build .\#nixosConfigurations
NIXINSTALL = sudo nixos-install --flake .\#nixosConfigurations
NIXREBUILD = sudo nixos-rebuild switch --flake .\#nixosConfigurations
DARWINREBUILD = sudo darwin-rebuild switch .\#darwinConfigurations
ARGS = -L --accept-flake-config
EXTRA = --extra-experimental-features "nix-command flakes"

.PHONY: default rebuild-glados rebuild-wheatley build-glados build-wheatley rebuild-kanagawa rebuild-outer-heaven install-mediacenter install-motherbase install-steamdeck rebuild-mediacenter rebuild-motherbase rebuild-steamdeck setup-nixos setup-darwin formatting statix deadnix all clean test


default: help

all: help

build-glados:
	@echo "Build GlaDOS SD Image"
	@${NIXBUILD}.glaDOS-build.config.system.build.sdImage ${ARGS}

build-wheatley:
	@echo "Build Wheatley SD Image"
	@${NIXBUILD}.wheatley-build.config.system.build.sdImage ${ARGS}

rebuild-glados:
	@echo "Install packages and configuration in GlaDOS host (arm64)"
	@${NIXREBUILD}.glaDOS ${ARGS}

rebuild-wheatlety:
	@echo "Install packages and configuration in Wheatley host (arm64)"
	@${NIXREBUILD}.wheatley ${ARGS}

rebuild-kanagawa:
	@echo "Rebuild and configure Kanagawa Darwin host"
	@${DARINREBUILD}.kanagawa ${ARGS}

rebuild-outer-heaven:
	@echo "Rebuild and configure Outer-Heaven Darwin host"
	@${DARWINREBUILD}.outer-heaven ${ARGS}

install-mediacenter:
	@echo "Install nixos system for Mediacenter host (x86_64)"
	@${NIXINTALL}.mediacenter ${EXTRAS}

install-motherbase:
	@echo "Install nixos system for Motherbase host (x86_64)"
	@${NIXINSTALL}.motherbase ${EXTRA}

install-steamdeck:
	@echo "Install nixos system for SteamDeck host (x86_64)"
	@${NIXINSTALL}.steamdeck ${EXTRA}

rebuild-mediacenter:
	@echo "Update packages and configurations for Mediacenter host"
	@${NIXREBUILD}.mediacenter ${ARGS}

rebuild-motherbase:
	@echo "Update packages and configurations for Motherbase host"
	@${NIXREBUILD}.motherbase ${ARGS}

rebuild-steamdeck:
	@echo "Update packages and configurations for SteamDeck host"
	@${NIXREBUILD}.steamdeck ${ARGS}

setup-nixos:
	@echo "Install nixOS package manager"
	@sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)

setup-darwin:
	@echo "Install nix-darwin modules and package manager"
	@${NIXOSRUN} nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch

formatting:
	@echo "Style format flake using Alejandra"
	@${NIXRUN}alejandra -- --check .

statix:
	@echo "Perform Static analysis"
	@${NIXRUN}statix -- check .

deadnix:
	@echo "Detect unused code"
	@${NIXRUN}deadnix -- .

check:
	@echo "Check modules and configurations"
	@nix flake check ${TAIL}

clean:
	@echo "Clean installation"
	@sudo nix-collect-garbage -d

test: check

help:
	@echo "Use make [target]"
	@echo ""
	@sed -n '/^[a-zA-Z0-9_-]*:/ { N; s/^\([^:]*\):.*\n.*@echo "\(.*\)".*/\1:\2/p; }' $(MAKEFILE_LIST) | column -t -s ':' | sed -e 's/^/ /'
