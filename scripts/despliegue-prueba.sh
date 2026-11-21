#!/usr/bin/env bash
# CD · Despliegue de prueba en un entorno efímero de Floci.
# Crea el bucket del estado, despliega el entorno dev, comprueba los recursos
# y lo destruye todo al terminar (también si algo falla).
# Necesita Terraform, la AWS CLI y Floci escuchando en http://localhost:4566
# (esa dirección está fija en providers.tf y en backend-floci.hcl).
set -euo pipefail
cd "$(dirname "$0")/.."

TF="${TF:-terraform}"
ENTORNO="${ENTORNO:-dev}"
ENDPOINT="http://localhost:4566"   # fija: la usan también providers.tf y backend-floci.hcl

export TF_VAR_usar_floci=true
export TF_VAR_prefijo="${PREFIJO:-ci}"
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=eu-west-1
unset AWS_PROFILE AWS_SESSION_TOKEN
aws_floci() { aws --endpoint-url "$ENDPOINT" "$@"; }
paso() { echo; echo "==> $1"; }

# Se trabaja sobre una copia limpia del proyecto para no tocar lo local:
# - terraform.tfvars tiene prioridad sobre TF_VAR_* (pondría usar_floci = false)
# - el estado local de bootstrap/ y los .terraform/ pueden apuntar a AWS real
# (tar en lugar de rsync: Git Bash en Windows no trae rsync)
TRABAJO="$(mktemp -d)"
tar -cf - --exclude .git --exclude .terraform --exclude 'terraform.tfvars' \
  --exclude '*.auto.tfvars' --exclude '*.tfstate' --exclude '*.tfstate.*' . \
  | tar -xf - -C "$TRABAJO"
trap 'rm -rf "$TRABAJO"' EXIT
cd "$TRABAJO"

paso "1/6 Comprobar que Floci responde en $ENDPOINT"
if ! curl -sf "$ENDPOINT/_floci/health" >/dev/null; then
  echo "Floci no responde en $ENDPOINT."
  echo "Este script solo despliega en Floci: arráncalo en local o usa el workflow"
  echo "'Despliegue de prueba' de GitHub Actions, que levanta su propio Floci."
  exit 1
fi

paso "2/6 Elegir una AMI de Floci"
if [ -z "${TF_VAR_ami_id:-}" ]; then
  TF_VAR_ami_id="$(aws_floci ec2 describe-images --query 'Images[0].ImageId' --output text)"
  if [ -z "$TF_VAR_ami_id" ] || [ "$TF_VAR_ami_id" = "None" ]; then
    echo "Floci no devuelve ninguna AMI: indícala con TF_VAR_ami_id"; exit 1
  fi
  export TF_VAR_ami_id
fi
echo "AMI: $TF_VAR_ami_id"

limpiar() {
  paso "6/6 Limpieza: destruir el entorno y el bucket del estado"
  "$TF" -chdir="envs/$ENTORNO" destroy -auto-approve -input=false || true
  "$TF" -chdir=bootstrap destroy -auto-approve -input=false || true
  rm -rf "$TRABAJO"
}
trap limpiar EXIT

paso "3/6 Crear el bucket del estado (bootstrap)"
"$TF" -chdir=bootstrap init -input=false
"$TF" -chdir=bootstrap apply -auto-approve -input=false
BUCKET="$("$TF" -chdir=bootstrap output -raw bucket_estado)"

paso "4/6 Desplegar el entorno $ENTORNO con el estado en S3"
"$TF" -chdir="envs/$ENTORNO" init -input=false -reconfigure \
  -backend-config=../../backend-floci.hcl -backend-config="bucket=$BUCKET"
"$TF" -chdir="envs/$ENTORNO" apply -auto-approve -input=false

paso "5/6 Comprobar los recursos creados"
"$TF" -chdir="envs/$ENTORNO" output
echo "--- Instancias del entorno"
# shellcheck disable=SC2016 # las comillas invertidas son de JMESPath, no del shell
aws_floci ec2 describe-instances \
  --filters "Name=tag:Entorno,Values=$(echo "$ENTORNO" | tr '[:lower:]' '[:upper:]')" \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,Tags[?Key==`Name`]|[0].Value]' \
  --output table
echo "--- Estado guardado en el bucket"
aws_floci s3 ls "s3://$BUCKET" --recursive
