#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# deploy.sh — Instala NixOS en un host remoto vía nixos-anywhere
#
# PREREQUISITO RPi5: El target debe correr NixOS (imagen bootstrap),
# NO Debian/Ubuntu. kexec no funciona en RPi5.
# Ver: make build-bootstrap → flashear SD → bootear → luego correr este script.
# =========================================================

TARGET_IP="${1:-}"
FLAKE_ATTR="${2:-}"

if [ -z "$TARGET_IP" ] || [ -z "$FLAKE_ATTR" ]; then
  echo "Uso: ./scripts/deploy.sh <IP_DESTINO> <FLAKE_ATTR>"
  echo "Ej. Raspberry Pi 5 : ./scripts/deploy.sh 192.168.1.100 .#aperture-science"
  echo "Ej. Pi Zero 2 W    : ./scripts/deploy.sh 192.168.1.101 .#black-mesa"
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
TEMPLATE_DIR="$REPO_ROOT/template"

echo "==> 1. Creando directorio de plantillas en $TEMPLATE_DIR..."
mkdir -p "$TEMPLATE_DIR"

echo "==> 2. Generando hardware-configuration.nix desde el host remoto ($TARGET_IP)..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@$TARGET_IP" \
  "nixos-generate-config --no-filesystems --root /tmp/target && cat /tmp/target/etc/nixos/hardware-configuration.nix" \
  > "$TEMPLATE_DIR/hardware-configuration.nix"

echo "==> 3. Registrando template/hardware-configuration.nix en el índice de Git..."
git add "$TEMPLATE_DIR/hardware-configuration.nix"

echo "==> 4. Ejecutando nixos-anywhere hacia $TARGET_IP..."
# --phases disko,install,reboot: salta la fase kexec.
# kexec no funciona en RPi5; el bootstrap ya corre NixOS así que no es necesario.
nix run github:nix-community/nixos-anywhere -- \
  --phases disko,install,reboot \
  --flake "$FLAKE_ATTR" \
  "root@$TARGET_IP"

echo "==> Deploy completado!"
