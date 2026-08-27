#!/usr/bin/env bash
# =========================================================
# deploy-linux.sh — Deploy inteligente para hosts x86_64
#
# Detecta automáticamente el SO del target:
#   - NixOS ya instalado → nixos-rebuild switch (actualización)
#   - Linux genérico     → nixos-anywhere con kexec (instalación)
#
# Uso: ./scripts/deploy-linux.sh <HOST> <TARGET_IP>
# Ej:  ./scripts/deploy-linux.sh motherbase 192.168.5.100
#
# REQUISITOS:
#   - La llave SSH local debe estar en authorized_keys del target
#   - x86_64 únicamente (para ARM/RPi usar deploy.sh)
#   - Si el target es Linux genérico, el usuario root debe tener acceso SSH
# =========================================================
set -euo pipefail

HOST="${1:-}"
TARGET_IP="${2:-}"

# ── Validación de argumentos ─────────────────────────────────────────────────
if [[ -z "$HOST" || -z "$TARGET_IP" ]]; then
  echo "Uso: $0 <HOST> <TARGET_IP>"
  echo ""
  echo "Ejemplos:"
  echo "  $0 motherbase    192.168.5.100   # Instala/actualiza motherbase"
  echo "  $0 msf          192.168.5.110   # Instala/actualiza msf"
  echo ""
  echo "El script detecta el SO automáticamente:"
  echo "  NixOS   → nixos-rebuild switch (actualiza el sistema existente)"
  echo "  Linux   → nixos-anywhere + kexec (instala NixOS desde cero)"
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
FLAKE_ATTR=".#${HOST}"

# ── Verificar conectividad ───────────────────────────────────────────────────
echo "==> [1/4] Verificando conectividad con root@${TARGET_IP}..."
if ! ssh -o ConnectTimeout=10 \
        -o StrictHostKeyChecking=no \
        -o BatchMode=yes \
        root@"${TARGET_IP}" 'exit' 2>/dev/null; then
  echo ""
  echo "❌  No se pudo conectar a root@${TARGET_IP}"
  echo ""
  echo "Posibles causas:"
  echo "  - El equipo no está encendido o accesible en red"
  echo "  - La llave SSH local no está en authorized_keys del target"
  echo "  - El servicio SSH no está corriendo en el target"
  echo ""
  echo "Para un equipo sin SO: flashea el ISO de instalación primero:"
  echo "  make build-installer-x86"
  exit 1
fi

# ── Detectar SO y arquitectura ───────────────────────────────────────────────
echo "==> [2/4] Detectando sistema operativo en ${TARGET_IP}..."
OS_INFO=$(ssh -o StrictHostKeyChecking=no \
              -o BatchMode=yes \
              root@"${TARGET_IP}" '
  OS_ID=$(grep "^ID=" /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d "\"" || echo "unknown")
  OS_NAME=$(grep "^PRETTY_NAME=" /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d "\"" || echo "Unknown")
  ARCH=$(uname -m)
  IS_NIXOS=$(test -f /etc/NIXOS && echo "yes" || echo "no")
  printf "%s\t%s\t%s\t%s" "$OS_ID" "$ARCH" "$IS_NIXOS" "$OS_NAME"
')

OS_ID=$(printf '%s' "$OS_INFO"   | cut -f1)
ARCH=$(printf '%s' "$OS_INFO"    | cut -f2)
IS_NIXOS=$(printf '%s' "$OS_INFO" | cut -f3)
OS_NAME=$(printf '%s' "$OS_INFO"  | cut -f4)

echo "   Sistema : ${OS_NAME}"
echo "   Distro  : ${OS_ID}"
echo "   Arch    : ${ARCH}"
echo "   NixOS   : ${IS_NIXOS}"

# ── Validación de arquitectura ───────────────────────────────────────────────
if [[ "$ARCH" != "x86_64" ]]; then
  echo ""
  echo "❌  Arquitectura no soportada: ${ARCH}"
  echo ""
  echo "Este script es exclusivamente para x86_64."
  echo "Para despliegues ARM/Raspberry Pi usa:"
  echo "  make deploy-aperture TARGET_IP=${TARGET_IP}"
  echo "  make deploy-black-mesa TARGET_IP=${TARGET_IP}"
  exit 1
fi

echo ""

# ── Deploy según SO detectado ────────────────────────────────────────────────
if [[ "$IS_NIXOS" == "yes" ]] || [[ "$OS_ID" == "nixos" ]]; then
  # ── Rama NixOS: actualizar sistema existente ─────────────────────────────
  echo "==> [3/4] Sistema NixOS detectado → nixos-rebuild switch"
  echo "   Actualizando ${HOST} sin reparticionar..."
  echo ""

  git add -A

  nix run nixpkgs#nixos-rebuild -- switch \
    --flake "${FLAKE_ATTR}" \
    --target-host "root@${TARGET_IP}" \
    --build-host "root@${TARGET_IP}"

else
  # ── Rama Linux genérico: instalación desde cero ───────────────────────────
  echo "==> [3/4] Linux genérico (${OS_ID}) → nixos-anywhere + kexec"
  echo "   Se cargará un entorno NixOS temporal vía kexec y luego"
  echo "   se instalará ${HOST} desde el flake..."
  echo ""
  echo "   ⚠️  ADVERTENCIA: nixos-anywhere REPARTICIONARÁ el disco."
  echo "   Todos los datos del target serán eliminados."
  echo ""
  read -rp "   ¿Continuar con la instalación en ${TARGET_IP}? [s/N] " CONFIRM
  if [[ "${CONFIRM,,}" != "s" && "${CONFIRM,,}" != "si" && "${CONFIRM,,}" != "yes" && "${CONFIRM,,}" != "y" ]]; then
    echo "Instalación cancelada."
    exit 0
  fi
  echo ""

  git add -A

  nix run github:nix-community/nixos-anywhere -- \
    --flake "${FLAKE_ATTR}" \
    "root@${TARGET_IP}"
fi

# ── Resumen ──────────────────────────────────────────────────────────────────
echo ""
echo "==> [4/4] ✅  Deploy completado"
echo "   Host   : ${HOST}"
echo "   Target : root@${TARGET_IP}"
echo ""
if [[ "$IS_NIXOS" == "yes" ]] || [[ "$OS_ID" == "nixos" ]]; then
  echo "El sistema ya está activo con la nueva configuración."
else
  echo "El sistema se está reiniciando con NixOS instalado."
  echo "Conéctate en ~60s con: ssh root@${TARGET_IP}"
fi
