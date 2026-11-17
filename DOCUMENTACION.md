# Documentación del proyecto

**Autor/a:** ___
**Opción:** AWS / Floci (deja la que uses)

## 1. Arquitectura

Describe en pocas líneas qué despliega cada entorno y en qué se diferencian. Puedes incluir un diagrama (imagen o texto).

| | dev | pro |
| --- | --- | --- |
| Zonas | ___ | ___ |
| Servidores | ___ | ___ |
| Bucket de logs | ___ | ___ |
| Estado | ___ | ___ |

## 2. Cómo se ha organizado el código

Explica los módulos, los directorios de entorno y los bucles que usas.

## 3. Decisiones de seguridad

| Medida | Dónde | Por qué |
| --- | --- | --- |
| ___ | ___ | ___ |

### Hallazgos de Trivy aceptados

Cada excepción (`#trivy:ignore:...`) debe estar justificada aquí y en un comentario junto al recurso.

| Regla | Severidad | Justificación |
| --- | --- | --- |
| ___ | ___ | ___ |

## 4. CI/CD

Explica qué hace cada workflow y cuándo se ejecuta. Si no has usado GitHub, indica que has ejecutado los scripts en local.

## 5. Cómo desplegar

Pasos para desplegar y destruir tu proyecto.

## 6. Mejoras posibles

¿Qué cambiarías con más tiempo?
