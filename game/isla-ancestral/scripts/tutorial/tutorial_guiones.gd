# Modelo: glm-5.3-flash
# Plataforma: Cline
# Fecha: 2026-09-17
#
# M92: Guiones de tutorial serializados (Q5 — T-150, iter. 4).
# Contenido data-driven: los capítulos base viven en data/tutorial/guiones_base.tres
# (sin parseo en runtime). El TutorialManager carga este Resource al iniciar y usa el
# registro por código SOLO como fallback de degradación (cozy: nunca arranca roto).
# Patrón: weather_config.gd / clima_config.tres (M32).
class_name TutorialGuiones
extends Resource

## Q5: capitulos[id] = {pasos: Array, meta: String, rejugable: bool, extra: Dictionary}.
## `pasos` usa el mismo formato del manager: {tipo, texto_clave, meta?, icono_tecla}.
## `extra` acepta: sistema, requiere_vecino_libre, vecino_id, guiado, requiere_contexto.
@export var capitulos: Dictionary = {}
