# Variables - Asegúrate de que coincidan exactamente
NIXCONF = sudo nix rebuild switch .\#nixosConfigurations
DARWINCONF = sudo darwin-rebuild switch .\#darwinConfigurations
TAIL = -L --accept-flake-config

.PHONY: all clean test help darwin-kanagawa darwin-outer-heaven sd-cornholio sd-glados nix-cornholio nix-glados nix-mediaserver nix-motherbase nix-steamdeck install-darwin install-nixos help

## darwin-kanagawa: Rebuild darwin in Kanagawa host
darwin-kanagawa:
	@echo "Rebuild Nix-Darwin host Kanagawa"
	@${DARWINCONF}.kanagawa ${TAIL}

## darwin-outer-heaven: Rebuild darwin in Outer-Heaven host
darwin-outer-heaven:
	@echo "Rebuilg Nix-Darwin host outer-heaven"
	@${DARWINCONF}.outer-heaven ${TAIL}

## ---
## sd-cornholio: Build SD image Cornholio host
sd-cornholio:
	@echo "Build SD image host Cornholio"
	@${NIXCONF}.cornholio-builder.config.system.build.sdImage ${TAIL}

## sd-glados: Build SD image GlaDOS host
sd-glados:
	@echo "Build SD image host GlaDOS"
	@${NIXCONF}.glados-builder.config.system.build.sdImage ${TAIL}

## ---
## nix-cornholio: Rebuild Nix Cornholio host
nix-cornholio:
	@echo "Rebuild Nix host Cornholio"
	@${NIXCONF}.cornholio ${TAIL}

## nix-glados: Rebuild Nix GlaDOS host
nix-glados:
	@echo "Rebuild Nix host GlaDOS"
	@${NIXCONF}.glados ${TAIL}

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
