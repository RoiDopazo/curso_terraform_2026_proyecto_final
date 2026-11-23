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
TODO: 

| Medida | Dónde | Por qué |
| --- | --- | --- |
| ___ | ___ | ___ |

### Hallazgos de Trivy aceptados

Cada excepción (`#trivy:ignore:...`) debe estar justificada aquí y en un comentario junto al recurso.

| Regla | Severidad | Justificación |
| --- | --- | --- |
| AWS-0104 | CRITICAL | `modules/servidor_web`: la regla de salida permite ir a cualquier IP porque el servidor necesita salir a Internet para instalar nginx y las actualizaciones |
| AWS-0164 | HIGH | `modules/red`: no hay balanceador, así que los servidores web son públicos y sus subredes tienen que dar IP pública |
| AWS-0132 | HIGH | `bootstrap`: el bucket del estado se cifra con AES256 (claves de AWS) en vez de con una clave KMS propia, porque para este proyecto no compensa su coste y gestión |
| AWS-0132 | HIGH | `modules/logs`: el bucket de logs se cifra con AES256 (claves de AWS) en vez de con una clave KMS propia, por el mismo motivo |

## 4. CI/CD
TODO:

Explica qué hace cada workflow y cuándo se ejecuta. Si no has usado GitHub, indica que has ejecutado los scripts en local.

## 5. Cómo desplegar
TODO: 

Pasos para desplegar y destruir tu proyecto.

## 6. Mejoras posibles
TODO: 

¿Qué cambiarías con más tiempo?
