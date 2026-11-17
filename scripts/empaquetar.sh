#!/usr/bin/env bash
# Genera entrega.zip con los ficheros versionados en Git.
# git archive solo incluye lo que está en el repositorio: deja fuera .terraform/,
# los .tfstate y los terraform.tfvars (si el .gitignore es correcto).
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -n "$(git status --porcelain)" ]; then
  echo "Aviso: hay cambios sin confirmar; no entrarán en el ZIP (haz commit antes)."
fi

git archive --format=zip -o entrega.zip HEAD

if unzip -l entrega.zip | grep -E '\.tfstate|terraform\.tfvars$|\.terraform/'; then
  echo "ERROR: el ZIP contiene estado o variables privadas. Revisa el .gitignore."; exit 1
fi
echo "entrega.zip creado: $(unzip -l entrega.zip | tail -1)"
