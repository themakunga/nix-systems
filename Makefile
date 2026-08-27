# =========================================================
# TheMakunga Infrastructure - Centro de Operaciones
# =========================================================

# --- VARIABLES DE ENTORNO ---
TARGET_IP ?= 192.168.1.100
HOST ?= aperture-science

.PHONY: all test help install-nix bootstrap-darwin switch-outer-heaven switch-kanagawa switch-motherbase switch-msf switch-steamdeck deploy-aperture switch-aperture deploy-black-mesa switch-black-mesa deploy-valve switch-valve deploy-motherbase build-host build-vm build-sd build-bootstrap check fmt sops-common sops-host update clean shell

all: ## Objetivo por defecto requerido por checkmake
	@echo "No default 'all' target configured. Please specify a target like 'switch-outer-heaven'."

test: ## Objetivo de pruebas requerido por checkmake
	@echo "No tests configured for this infrastructure repository yet."

help: ## Muestra este menú de ayuda
	@echo "========================================================="
	@echo " TheMakunga Infrastructure - Comandos Disponibles"
	@echo "========================================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

# =========================================================
# 🚀 INSTALACIÓN INICIAL (BOOTSTRAP)
# =========================================================

install-nix: ## Instala Nix oficial (Determinate Systems) habilitando Flakes automáticamente
	@echo "=> Instalando Nix..."
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

bootstrap-darwin: ## Primera instalación de Nix-Darwin en un Mac virgen. Uso: make bootstrap-darwin HOST=kanagawa
	@echo "=> Bootstrap inicial de Nix-Darwin para $(HOST)..."
	nix run nix-darwin -- switch --flake .#$(HOST)

# =========================================================
# 🍎 DESPLIEGUES MACOS (NIX-DARWIN)
# =========================================================

switch-outer-heaven: ## Aplica la configuración en outer-heaven (Mac Principal)
	@echo "=> Aplicando Nix-Darwin en outer-heaven..."
	git add -A
	sudo darwin-rebuild switch --flake .#outer-heaven

switch-kanagawa: ## Aplica la configuración en kanagawa
	@echo "=> Aplicando Nix-Darwin en kanagawa..."
	git add -A
	sudo darwin-rebuild switch --flake .#kanagawa

# =========================================================
# 🐧 DESPLIEGUES NIXOS LOCALES (X86_64)
# =========================================================

switch-motherbase: ## Aplica la configuración en motherbase (KVM/Server)
	@echo "=> Aplicando NixOS en motherbase..."
	git add -A
	sudo nixos-rebuild switch --flake .#motherbase

switch-msf: ## Aplica la configuración en msf (Media Server)
	@echo "=> Aplicando NixOS en msf..."
	git add -A
	sudo nixos-rebuild switch --flake .#msf

switch-steamdeck: ## Aplica la configuración en steamdeck
	@echo "=> Aplicando NixOS en steamdeck..."
	git add -A
	sudo nixos-rebuild switch --flake .#steamdeck

# =========================================================
# 🍓 DESPLIEGUES REMOTOS (RASPBERRY PI - AARCH64)
# =========================================================
# deploy-*  → Instalación inicial desde imagen bootstrap (nixos-anywhere + disko)
#             Requiere que el Pi esté corriendo el bootstrap SD, NO el sistema final.
# switch-*  → Actualización de un sistema ya instalado (nixos-rebuild, sin reparticionar)
#             Usa el propio Pi como builder (--build-host) para evitar cross-compile.

deploy-aperture: ## [INICIAL] Instala aperture-science vía nixos-anywhere (desde bootstrap SD). Uso: make deploy-aperture TARGET_IP=192.168.x.x
	@echo "=> Instalación inicial de aperture-science en $(TARGET_IP) (bootstrap → NVMe)..."
	git add -A
	./scripts/deploy.sh $(TARGET_IP) .#aperture-science

switch-aperture: ## [UPDATE] Actualiza aperture-science en ejecución vía nixos-rebuild. Uso: make switch-aperture TARGET_IP=192.168.x.x
	@echo "=> Actualizando aperture-science en $(TARGET_IP)..."
	git add -A
	nix run nixpkgs#nixos-rebuild -- switch \
	  --flake .#aperture-science \
	  --target-host root@$(TARGET_IP) \
	  --build-host root@$(TARGET_IP)

build-bootstrap: ## Genera la imagen SD de instalación inicial (aperture-bootstrap)
	@echo "=> Generando imagen de Bootstrap para Raspberry Pi 5..."
	git add -A
	make build-sd HOST=aperture-bootstrap

deploy-black-mesa: ## [INICIAL] Instala black-mesa (Pi Zero/3) vía nixos-anywhere. Uso: make deploy-black-mesa TARGET_IP=192.168.x.x
	@echo "=> Instalación inicial de black-mesa en $(TARGET_IP)..."
	git add -A
	./scripts/deploy.sh $(TARGET_IP) .#black-mesa

switch-black-mesa: ## [UPDATE] Actualiza black-mesa en ejecución vía nixos-rebuild. Uso: make switch-black-mesa TARGET_IP=192.168.x.x
	@echo "=> Actualizando black-mesa en $(TARGET_IP)..."
	git add -A
	nix run nixpkgs#nixos-rebuild -- switch \
	  --flake .#black-mesa \
	  --target-host root@$(TARGET_IP) \
	  --build-host root@$(TARGET_IP)

deploy-valve: ## [INICIAL] Instala valve (Pi 5) vía nixos-anywhere. Uso: make deploy-valve TARGET_IP=192.168.x.x
	@echo "=> Instalación inicial de valve en $(TARGET_IP)..."
	git add -A
	./scripts/deploy.sh $(TARGET_IP) .#valve

switch-valve: ## [UPDATE] Actualiza valve en ejecución vía nixos-rebuild. Uso: make switch-valve TARGET_IP=192.168.x.x
	@echo "=> Actualizando valve en $(TARGET_IP)..."
	git add -A
	nix run nixpkgs#nixos-rebuild -- switch \
	  --flake .#valve \
	  --target-host root@$(TARGET_IP) \
	  --build-host root@$(TARGET_IP)

# ==========================================
# 🌍 DESPLIEGUE REMOTO X86_64
# ==========================================

deploy-motherbase: ## Despliega motherbase remoto usando linux-builder local
	@echo "=> Desplegando configuración en motherbase.local..."
	git add -A
	nix run nixpkgs#nixos-rebuild -- switch --flake .#motherbase --target-host root@192.168.5.153 --build-host ssh-ng://builder@linux-builder --fast

# =========================================================
# 🧪 PRUEBAS Y CONSTRUCCIÓN (TESTING)
# =========================================================

build-host: ## Compila la configuración de un host SIN aplicarla. Uso: make build-host HOST=motherbase
	@echo "=> Compilando la configuración para $(HOST)..."
	git add -A
	nix build .#nixosConfigurations.$(HOST).config.system.build.toplevel

build-vm: ## Levanta una VM efímera de un host NixOS para pruebas. Uso: make build-vm HOST=motherbase
	@echo "=> Construyendo y ejecutando VM para $(HOST)..."
	git add -A
	nix build .#nixosConfigurations.$(HOST).config.system.build.vm
	./result/bin/run-$(HOST)-vm

build-sd: ## Genera la imagen .img genérica (SD/USB) para un host Pi. Uso: make build-sd HOST=aperture-science
	@echo "=> Generando imagen SD para $(HOST)..."
	git add -A
	nix build .#nixosConfigurations.$(HOST).config.system.build.sdImage
	@echo "=> Imagen construida en ./result/sd-image/"

# =========================================================
# 🔐 GESTIÓN DE SECRETOS (SOPS)
# =========================================================

sops-common: ## Edita los secretos comunes (ej. WiFi, Tokens compartidos)
	@echo "=> Abriendo media/secrets/common.yaml..."
	sops media/secrets/common.yaml

sops-host: ## Edita los secretos de un host específico. Uso: make sops-host HOST=motherbase
	@echo "=> Abriendo secretos de $(HOST)..."
	sops media/secrets/hosts/$(HOST).yaml

sops-update: ## Actualiza las llaves criptográficas de todos los archivos SOPS (tras agregar un nuevo host/usuario)
	@echo "=> Actualizando llaves en todos los secretos..."
	find media/secrets -type f -name "*.yaml" -exec sops updatekeys -y {} \;

# =========================================================
# 🧹 MANTENIMIENTO Y QA
# =========================================================

check: ## Ejecuta los pre-commits y evalúa la sintaxis del Flake
	@echo "=> Validando sintaxis y pre-commits..."
	pre-commit run --all-files
	nix flake check

fmt: ## Fuerza el formateo de todo el código Nix usando Alejandra
	@echo "=> Formateando archivos Nix..."
	nix fmt

update: ## Actualiza las dependencias en flake.lock (nixpkgs, home-manager, etc.)
	@echo "=> Actualizando Flake Inputs..."
	nix flake update

clean: ## Recolecta basura y optimiza el Nix Store
	@echo "=> Vaciando papelera de Nix..."
	sudo nix-collect-garbage -d
	nix-collect-garbage -d
	nix store optimise

shell: ## Entra al entorno de desarrollo definido en devShell.nix
	nix develop
