# Documentación del proyecto

**Autor/a:** Rodrigo Dopazo Igleisas
**Opción:** Floci

## 1. Arquitectura

El proyecto despliega la misma infraestructura en dos entornos, "dev" y "pro", usando los mismos módulos. "dev" es un entorno pequeño para pruebas, con un solo servidor, y "pro" tiene dos servidores repartidos en dos zonas para tener más disponibilidad, además de un bucket para los logs.


| | dev | pro |
| --- | --- | --- |
| Zonas | 1 (eu-west-1a) | 2 (eu-west-1a y eu-west-1b) |
| Servidores | 1  | 2 (uno en cada zona) |
| Bucket de logs | No | Sí (`rodrigo-dopazo-pro-logs`) |
| Estado | S3: `dev/terraform.tfstate`, con bloqueo | S3: `pro/terraform.tfstate`, con bloqueo |

## 2. Cómo se ha organizado el código

- **`bootstrap/`**: crea el bucket del estado.
- **`modules/`**: tres módulos reutilizables que usan los dos entornos:
  - `red`: la VPC, las subredes públicas, el Internet Gateway y la tabla de rutas.
  - `servidor_web`: el grupo de seguridad con sus reglas y la instancia EC2 con nginx.
  - `logs`: un bucket S3 privado y cifrado, con versionado y caducidad de los objetos a los 30 días.
- **`envs/dev` y `envs/pro`**: un directorio por entorno, cada uno con su backend y su estado.

Bucles:
- `for_each` sobre el mapa `local.servidores` en `envs/pro/main.tf`, para crear un servidor por cada elemento (`module.web["a"]` y `module.web["b"]`). Cada servidor toma su nombre de la clave (`each.key`) y su mensaje de `each.value.mensaje`.

## 3. Decisiones de seguridad

| Medida | Dónde | Por qué |
| --- | --- | --- |
| IMDSv2 obligatorio (`http_tokens = "required"`) · Trivy AWS-0028 | `modules/servidor_web` | Evita que alguien pueda sacar las credenciales de la instancia desde el servicio de metadatos con un ataque tipo SSRF |
| Disco raíz cifrado · Trivy AWS-0131 | `modules/servidor_web` | Los datos del disco y de sus copias quedan protegidos |
| Bucket de logs cifrado (AES256) | `modules/logs` | Los logs pueden tener información sensible |
| Bloqueo del acceso público al bucket de logs · Trivy AWS-0086, 0087, 0091 y 0093 | `modules/logs` | Los logs nunca deben poder leerse desde fuera, aunque alguien se equivoque con una política o una ACL |
| Bucket del estado cifrado, versionado y privado | `bootstrap` | El estado guarda datos sensibles de la infraestructura; con el versionado se puede recuperar una versión anterior si se estropea |
| Bloqueo del estado (`use_lockfile = true`) | `backend-floci.hcl` | Impide que dos `apply` modifiquen el mismo estado a la vez |
| Caducidad de los logs a los 30 días | `modules/logs` | No se guardan datos más tiempo del necesario |
| Sin credenciales en el código | `.gitignore` | `terraform.tfvars`, el estado y `.terraform/` no se suben al repositorio |

### Hallazgos de Trivy aceptados

Cada excepción (`#trivy:ignore:...`) debe estar justificada aquí y en un comentario junto al recurso.

| Regla | Severidad | Justificación |
| --- | --- | --- |
| AWS-0104 | CRITICAL | `modules/servidor_web`: la regla de salida permite ir a cualquier IP porque el servidor necesita salir a Internet para instalar nginx y las actualizaciones |
| AWS-0164 | HIGH | `modules/red`: no hay balanceador, así que los servidores web son públicos y sus subredes tienen que dar IP pública |
| AWS-0132 | HIGH | `bootstrap`: el bucket del estado se cifra con AES256 (claves de AWS) en vez de con una clave KMS propia, porque para este proyecto no compensa su coste y gestión |
| AWS-0132 | HIGH | `modules/logs`: el bucket de logs se cifra con AES256 (claves de AWS) en vez de con una clave KMS propia, por el mismo motivo |

## 4. CI/CD

He hecho un fork de la plantilla en GitHub, así que los workflows se ejecutan en GitHub Actions:

- **`ci.yml`**: se ejecuta en cada push y en cada pull request. Lanza `scripts/ci.sh`, que comprueba el formato (`terraform fmt`), valida cada configuración (`terraform validate`), pasa TFLint y Trivy. Si Trivy encuentra algún hallazgo HIGH o CRITICAL, el CI falla. No necesita credenciales porque no se conecta a AWS.
- **`despliegue-prueba.yml`**: se ejecuta con cada push a `main` o a mano desde la pestaña Actions. Arranca un Floci dentro del propio pipeline y ejecuta `scripts/despliegue-prueba.sh`: crea el bucket del estado, despliega dev con el estado en S3, comprueba las instancias y el estado, y al final lo destruye todo, aunque algo falle.
- **`despliegue-aws.yml`**: es opcional y no lo he usado, porque trabajo con Floci.

Antes de hacer push, también he ejecutado `./scripts/ci.sh` en local para comprobar que todo pasaba.

## 5. Cómo desplegar

**1. Crear el bucket del estado** (con estado local):

```bash
cd bootstrap
cp ../envs/dev/terraform.tfvars.example terraform.tfvars   # indicar usar_floci = true
terraform init
terraform apply
terraform output bucket_estado
```

**2. Desplegar dev**:

```bash
cd envs/dev
cp terraform.tfvars.example terraform.tfvars   # indicar usar_floci = true
terraform init -backend-config=../../backend-floci.hcl -backend-config="bucket=<bucket_estado>"
terraform apply
```

`<bucket_estado>` es el nombre del bucket que devuelve `terraform output bucket_estado` en `bootstrap/`.

**3. Desplegar pro**: los mismos pasos que para dev pero realizandolos en la carpeta `envs/pro`.

**Destruir**, en orden inverso: primero `envs/pro`, después `envs/dev` y por último `bootstrap`, con `terraform destroy` en cada carpeta. Bootstrap va el último porque su bucket guarda el estado de los otros dos.

## 6. Mejoras posibles

- Poner un balanceador en las subredes públicas y llevar los servidores a subredes privadas. Así los servidores no tendrían IP pública y se resolvería AWS-0164.
- Usar una clave KMS propia para cifrar los buckets, con rotación y control de acceso (AWS-0132).
- Activar VPC Flow Logs y enviarlos al bucket de logs (AWS-0178), y activar también los logs de acceso a S3 (AWS-0089).
- Servir la web por HTTPS y limitar desde qué IPs se puede entrar.
- Fijar una versión concreta de la imagen de Floci en el pipeline, en lugar de `latest-compat`.
