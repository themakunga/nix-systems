# Variables - Asegúrate de que coincidan exactamente
NIXCONF = nix rebuild switch .\#nixosConfigurations
NIXBUILD = nix build .\#nixosConfigurations
DARWINCONF = sudo darwin-rebuild switch .\#darwinConfigurations
TAIL = -L --accept-flake-config
NXRUN = nix run nixpkgs\#

.PHONY: all clean test help darwin-kanagawa darwin-outer-heaven nix-wheatley nix-glados nix-mediaserver nix-motherbase nix-steamdeck install-darwin install-nixos help formatting statix deadnix check

## darwin-kanagawa: Rebuild darwin in Kanagawa host
darwin-kanagawa:
	@echo "Rebuild Nix-Darwin host Kanagawa"
	@${DARWINCONF}.kanagawa ${TAIL}

## darwin-outer-heaven: Rebuild darwin in Outer-Heaven host
darwin-outer-heaven:
	@echo "Rebuilg Nix-Darwin host outer-heaven"
	@${DARWINCONF}.outer-heaven ${TAIL}

## ---
## sd-image: Build SD image with a generich host
sd-image:
	@echo "Build SD image RPI"
	@${NIXBUILD}.sd-image.config.system.build.images.rpi5-installer ${TAIL}

## ---
## nix-wheatley: Rebuild Nix Wheatley host
nix-wheatley:
	@echo "Rebuild Nix host Cornholio"
	@${NIXCONF}.wheatley ${TAIL}

## nix-glados: Rebuild Nix GlaDOS host
nix-glados:
	@echo "Rebuild Nix host GlaDOS"
	@${NIXCONF}.glaDOS ${TAIL}

## nix-mediaserver: Rebuild Nix MediaCenter host
nix-mediaserver:
	@echo "Rebuild Nix host MediaCenter"
	@${NIXCONF}.mediaserver ${TAIL}

## nix-motherbase: Rebuild Nix MotherBase host
nix-motherbase:
	@echo "Rebuild Nix host MotherBase"
	@${NIXCONF}.motherbase ${TAIL}

## nix-steamdeck: Rebuild Nix Steamdeck
nix-steamdeck:
	@echo "Rebuild Nix host Steamdeck"
	@${NIXCONF}.steamdeck ${TAIL}

## ---
## install-darwin: Install nix-darwin
install-darwin:
	@echo "Install nix Darwin"
	sudo nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch

## install-nixos: Install NixOS package Manager
install-nixos:
	@echo "Install NixOS"
	sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)

## ---
## formatting: Format code using alejandra
formatting:
	@echo "Formmating Flakes using Alejandra"
	@${NXRUN}alejandra -- --check .

## statix: Perform static analysis
statix:
	@echo "Perform Static analysis"
	@${NXRUN}statix -- check .

## deadnix: Dectect unused code
deadnix:
	@echo "Detect unused code"
	@${NXRUN}deadnix -- .

## check: Run nix flake Checker
check:
	@echo "Run Nix Flake check"
	@nix flake check ${TAIL}

## ---
## all: (Default) Muestra la ayuda
all: help

## clean: Limpiar basura de builds de Nix (opcional)
clean:
	sudo nix-collect-garbage -d

## test: Validar los archivos Nix sin aplicar cambios
test:
	nix run nixpkgs#statix -- check
	nix run nixpkgs#deadnix -- --fail

## ---
## help: This Information
help:
	@echo "Use: make [target]"
	@echo ""
	@sed -n 's/^##//p' $(MAKEFILE_LIST) | column -t -s ':' | sed -e 's/^/ /'
