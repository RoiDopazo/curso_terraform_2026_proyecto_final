# Backend para AWS: terraform init -backend-config=../../backend-aws.hcl
# Cambia el bucket por el que crea bootstrap/ (output bucket_estado)
bucket       = "nombre-apellido-tfstate-proyecto"
region       = "eu-west-1"
encrypt      = true
use_lockfile = true
