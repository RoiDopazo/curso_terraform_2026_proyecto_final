# Mejora opcional · Despliegue en AWS con OIDC

Solo si tienes cuenta de AWS. No forma parte de lo obligatorio.

1. Crea el rol (con tus credenciales de AWS):

   ```bash
   cd extras/oidc
   terraform init
   terraform apply -var="repositorio=tu-usuario/tu-repositorio"
   ```

2. En GitHub, en **Settings › Secrets and variables › Actions › Variables**, crea:
   - `AWS_ROLE_ARN`: el output `rol_arn`.
   - `BUCKET_ESTADO`: el bucket del estado creado con `bootstrap/` en AWS.
   - `PREFIJO`: tu prefijo.
3. En **Settings › Environments**, crea los entornos `dev` y `pro`. En `pro`, añade una regla de aprobación (*Required reviewers*).
4. Ejecuta el workflow **Despliegue en AWS (opcional)** desde la pestaña **Actions**, eligiendo entorno y acción.

Al terminar: `terraform destroy` en cada entorno y, después, en `extras/oidc`.
