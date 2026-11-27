#!/usr/bin/env sh
# Levanta el stack completo (Linux/macOS) desde cualquier carpeta.
cd "$(dirname "$0")" && exec python3 scripts/levantar.py "$@"
