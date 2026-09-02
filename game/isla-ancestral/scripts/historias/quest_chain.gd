# Modelo: Step 3.7 Flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M23: Historias Secundarias — Tipos y estructuras de datos para cadenas de misiones.
# Data-driven: las cadenas se definen en JSON bajo data/historias/ y se validan
# contra reglas de anti-repetición (contexto obligatorio, referencias alcanzables).

extends Resource
class_name QuestChain

## ── Datos de cadena ──────────────────────────────────────

@export var id: String = ""
@export var titulo: String = ""
@export var contexto: String = ""          # Anti-repetición: por qué existe esta cadena
@export var pasos: Array[Dictionary] = []  # Cada paso: {id, tipo, npc/lugar/objeto, condicion, requisito}
@export var recompensa: Dictionary = {}    # {diario, cosmetico, ...}
@export var consecuencia: Dictionary = {}  # {estado_mundo.xxx = true/false}
@export var dialogo_posterior: String = "" # ID de diálogo posterior
@export var oculta: bool = false
@export var postgame: bool = false

## ── Validación básica ────────────────────────────────────

## Valida que la cadena cumpla las reglas mínimas (anti-repetición, estructura).
## Retorna Array de String con los errores encontrados (vacío = OK).
func validar() -> Array:
    var errores: Array = []
    if id.is_empty():
        errores.append("id vacío")
    if titulo.is_empty():
        errores.append("titulo vacío")
    if contexto.is_empty() or contexto.length() < 10:
        errores.append("contexto vacío o demasiado corto (>=10 chars)")
    if pasos.size() < 3:
        errores.append("cadena con menos de 3 pasos")
    for paso in pasos:
        if not paso.has("id"):
            errores.append("paso sin id en cadena '%s'" % id)
        if not paso.has("tipo"):
            errores.append("paso sin tipo en cadena '%s'" % id)
    if not recompensa.has("diario") and not recompensa.has("cosmetico"):
        errores.append("recompensa sin diario ni cosmetico en cadena '%s'" % id)
    return errores

## ── Consultas ────────────────────────────────────────────

func get_paso_por_id(paso_id: String) -> Dictionary:
    for paso in pasos:
        if paso.get("id") == paso_id:
            return paso
    return {}

func es_postgame() -> bool:
    return postgame

func es_oculta() -> bool:
    return oculta
