#!/usr/bin/env bash
# CI · Comprobaciones de calidad y seguridad.
# Son las mismas en local y en GitHub Actions: el workflow solo llama a este script.
# Necesita Terraform y, para TFLint y Trivy, tenerlos instalados o Docker.
set -euo pipefail
cd "$(dirname "$0")/.."

TF="${TF:-terraform}"           # TF=tofu para usar OpenTofu
TFLINT_VERSION="0.66.0"
TRIVY_VERSION="0.76.2"
RAIZ="$(pwd)"

paso() { echo; echo "==> $1"; }

paso "1/4 Formato (terraform fmt)"
"$TF" fmt -check -recursive -diff

paso "2/4 Validación de cada configuración (terraform validate)"
for dir in bootstrap envs/*/; do
  echo "--- ${dir%/}"
  "$TF" -chdir="$dir" init -backend=false -input=false >/dev/null
  "$TF" -chdir="$dir" validate -no-color
done

paso "3/4 Buenas prácticas (TFLint)"
# --config con ruta absoluta: si no, cada carpeta buscaría su propio .tflint.hcl
if command -v tflint >/dev/null 2>&1; then
  tflint --init --config "$RAIZ/.tflint.hcl"
  tflint --recursive --config "$RAIZ/.tflint.hcl"
else
  docker run --rm -v "$RAIZ:/data" -w /data -e GITHUB_TOKEN="${GITHUB_TOKEN:-}" \
    --entrypoint sh "ghcr.io/terraform-linters/tflint:v${TFLINT_VERSION}" \
    -c "tflint --init --config /data/.tflint.hcl && tflint --recursive --config /data/.tflint.hcl"
fi

paso "4/4 Seguridad (Trivy): falla si hay hallazgos HIGH o CRITICAL"
if command -v trivy >/dev/null 2>&1; then
  trivy config --exit-code 1 --severity HIGH,CRITICAL .
else
  docker run --rm -v "$RAIZ:/data" "aquasec/trivy:${TRIVY_VERSION}" \
    config --exit-code 1 --severity HIGH,CRITICAL /data
fi

echo
echo "CI completada: todo correcto"
