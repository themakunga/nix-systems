#!/usr/bin/env bash

find . -type f -name "*.nix" | while read -r file; do
  if ! grep -q "# === DOCUMENTATION ===" "$file"; then
    echo "Añadiendo cabecera a $file"

    filename=$(basename "$file")
    cat <<EOF >temp_file
# === DOCUMENTATION ===
# File: $filename
# Path: $file
# Description: Módulo de configuración para la infraestructura.
# =====================

EOF

    cat "$file" >>temp_file
    mv temp_file "$file"
  fi
done
