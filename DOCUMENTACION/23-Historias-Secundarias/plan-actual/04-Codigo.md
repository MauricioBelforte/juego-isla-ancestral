# 04 — Código — M23: Historias Secundarias

**Modelo:** Deepseek V4 Flash (documentación base)
**Plataforma:** OpenCode (documentación base)
**Fecha:** 2026-08-17 (documentación base)
**Actualizado:** Step 3.7 Flash / Kilo Code — 2026-09-02 05:09 (iter. 1 núcleo)

## Archivos creados (iter. 1 núcleo)

| Archivo | Tipo | Descripción |
|---------|------|-------------|
| `scripts/historias/quest_chain.gd` | Resource | Estructura de cadena: id, título, contexto, pasos, recompensa, consecuencia, diálogo posterior, oculta, postgame |
| `scripts/historias/quest_chain_service.gd` | Autoload (`Historias`) | Servicio: carga JSON desde `data/historias/`, validación anti-repetición, consultas por tipo/estado, señales de progreso, persistencia M59 |
| `scripts/historias/validate_quest_chains.gd` | EditorScript | Validador batch para Editor/CI: contexto >= 10 chars, 3+ pasos, recompensa única, sin referencias rotas |
| `data/historias/cadenas_ejemplo.json` | Datos | 3 cadenas de ejemplo: faro (vecinos), biblioteca (lugares), plaza (postgame) |

## API clave (implementación GDScript)

```gdscript
# QuestChain (Resource)
class_name QuestChain extends Resource
@export var id: String
@export var titulo: String
@export var contexto: String
@export var pasos: Array[Dictionary]
@export var recompensa: Dictionary
@export var consecuencia: Dictionary
@export var dialogo_posterior: String
@export var oculta: bool
@export var postgame: bool
func validar() -> Array  # errores vacío = OK

# QuestChainService (Autoload "Historias")
signal cadena_descubierta(chain: QuestChain)
signal cadena_completada(chain: QuestChain)
signal paso_completado(chain_id: String, paso_id: String)
func get_cadena(chain_id: String) -> QuestChain
func get_cadenas_por_tipo(tipo: String) -> Array
func get_cadenas_disponibles() -> Array
func get_cadenas_ocultas() -> Array
func get_cadenas_postgame() -> Array
func marcar_paso_completado(chain_id: String, paso_id: String) -> void
func get_consecuencias_pendientes() -> Array
func validar_todas() -> Array  # para Editor/CI
```

## Reglas de implementación (resumen)

1. Las cadenas viven en JSON bajo `data/historias/`; el validador corre en Editor y CI.
2. El campo `contexto` es obligatorio (anti-repetición dura); mínimo 10 caracteres.
3. Las consecuencias se aplican vía hook a M22/M68 y se persisten atómicamente (M59).
4. Las recompensas narrativas/cosméticas son únicas, nunca otorgan stats (visión cozy).
5. Los diálogos posteriores se guardan por NPC + estado global.
6. No tocar M22 (trama) ni M68 (ejecución) — solo contratos y datos.

## Notas del Agente

**Modelo:** Step 3.7 Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 05:09
**Estado:** Parcial — núcleo data-driven implementado (QuestChain Resource + QuestChainService autoload + validador + JSON ejemplo). Liberado a 🟡.

### Lo que hice
- Creé `quest_chain.gd` como Resource con campos: id, título, contexto, pasos, recompensa, consecuencia, diálogo_posterior, oculta, postgame.
- Creé `quest_chain_service.gd` como autoload `Historias`: carga JSON desde `data/historias/`, validación anti-repetición en `_registrar_cadena`, consultas por tipo/estado, señales `cadena_descubierta`, `cadena_completada`, `paso_completado`, persistencia M59 (`build_save_data`/`restore_save_data`).
- Creé `validate_quest_chains.gd` como EditorScript para validación batch en Editor/CI.
- Creé `data/historias/cadenas_ejemplo.json` con 3 cadenas de ejemplo (faro, biblioteca, plaza postgame).
- Actualicé 04-Codigo.md con la API implementada y reglas de implementación.

### Lo que NO pude hacer (honestidad obligatoria)
- No ejecuté el validador headless (no hay godot en PATH en este entorno).
- No implementé las 40+ cadenas del catálogo completo (solo 3 de ejemplo).
- No integré con M22/M68 (hooks de consecuencia y ejecución de misiones).
- No implementé las 12 consecuencias persistentes completas (solo el schema en datos).
- No implementé las recompensas narrativas/cosméticas completas (20 capítulos de diario, 10+ cosméticos).

### Recomendaciones para el próximo agente
- Ejecutar `validate_quest_chains.gd` desde el Editor para verificar las cadenas de ejemplo.
- Ampliar `cadenas_ejemplo.json` a 40+ cadenas con contexto verificable.
- Integrar con M22 (hooks de consecuencia) y M68 (ejecución de objetivos).
- Implementar las 12 consecuencias persistentes en el estado de mundo.
- Agregar las recompensas narrativas/cosméticas completas.

---

## Notas del Agente — Iteración 1 núcleo (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 16:45:00
**Estado:** Parcial (motor + validador + cadenas ejemplo implementados y verificados; módulo liberado 🟡)

### Lo que hice
- SecondaryStoriesService autoload (scripts/historias/secondary_stories_service.gd): motor de cadenas del esquema del diseño — iniciar_cadena (ocultas/postgame gating), reportar_paso con validación de tipo y evidencia (hablar/explorar/puzzle/entregar), reportar_entrega que consume el objeto del inventario M14, _completar_cadena con consecuencia → WorldState M21 (flags tipo faro_encendido), recompensa.diario → M55 (registrada en la categoría misiones) y recompensa.cosmetico → quest_updated (M71 escucha), señales quest_started/quest_completed M07 (M55/M71 ya consumían).
- Validador anti-repetición (§regla dura): contexto no vacío (>=10 chars), pasos >= 3, tipos conocidos (hablar/explorar/puzzle/entregar), ids de paso únicos, recompensa/consecuencia presentes, títulos únicos. El catálogo base pasa limpio.
- Ocultas (§misiones ocultas): no figuran en cadenas_disponibles() hasta iniciarse; postgame (§postgame) requiere final_elegido de M22.
- Persistencia ISaveProvider M59 sección "secondary_stories" (activas + completadas; huérfanas purgadas).
- Catálogo data/historias/secundarias.json con 4 cadenas ejemplo (faro, invernadero, epílogo plaza postgame, luciérnagas secreta).
- Validador como script ejecutable: validar_cadenas() (para CI/editor — checklist QA).
- Test test_historias.gd: carga, validador, cadena completa (4 pasos con tipos mixtos + rechazo de tipo incorrecto + consecuencia aplicada + registro en M55), entrega con/sin objeto, ocultas, postgame (bloqueada sin final de M22, abre tras final), persistencia con huérfana → **0 fallos**.
- Regresiones: test_diario M55 0 fallos, test_progresion M71 0 fallos, test_historia M22 0 fallos.
- Checklist: 10 ítems [x] del núcleo relevados.

### Lo que NO pude hacer (honestidad obligatoria)
- Contenido narrativo de las 60 cadenas del catálogo (escritura con contexto real): 4 cadenas ejemplo entregadas; la escritura es iteración con dueño (recomiendo DeepSeek/narrativa).
- Diálogo posterior de NPCs (diálogo_posterior del esquema): requiere hooks M21 — con dueño.
- Recompensas cosméticas visibles (ropa/sombreros): requiere M53/M45 — la señal quest_updated ya emite.
- Consecuencias visuales del mundo (faro encendido visible): M17/M18/M27 — los flags de WorldState ya están aplicados.
- M68 (misiones: cada cadena como objetivos): M68 no existe; las señales quest_started/updated/completed ya siguen el contrato.
- Ejecución de pasos "puzzle" real: la ejecución del puzzle la hace M25/M26 (el motor valida evidencia); con dueño.

### Recomendaciones para el próximo agente
- Escritura de cadenas: seguir el esquema del 03-Diseno (contexto narrativo >= 10 chars — el validador rechaza "recoge N" genéricos); validar con validar_cadenas() antes de commit.
- M55: agregar la entrada "mision_{cadena_id}" al diario_catalog.json por cada cadena nueva (o extender M55 para auto-purgar categorías de cadenas).
- M25/M26: al implementar puzzles, reportar reportar_paso(cadena_id, "puzzle", ref) cuando el jugador resuelva el puzzle asociado.
- La evidencia de pasos se compara con _slug (minúsculas/sin tildes) — mantener ids ascii-plana.
