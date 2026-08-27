# Log 173: Implementación del Núcleo de Amistad (M20)

**Fecha:** 2026-08-26
**Modelo:** ox-alpha (Cline)

## Resumen
Se implementó el núcleo de datos del M20 (Sistema de Amistad), el bloqueador que desbloquea el descuento por amistad del M38 (ya placeholdeado) y los trueques del M39. Emite eventos sobre el EventBus del M07 y se registra como ISaveProvider del M59.

## Cambios Realizados

### Código creado (game/isla-ancestral/scripts/friendship/)
- **`gift_evaluator.gd`** — `class_name GiftEvaluator`: lógica pura determinista de clasificación de regalos (Amado=20 / Gusta=10 / Neutral=5 / Duplicado=2; nunca 0 por regla cozy). Consume gustos/disgustos de VecinoData (M19) y metadatos de ItemData (M14) por duck-typing.
- **`vecino_amistad.gd`** — `class_name VecinoAmistad`: estado por vecino (puntos, nivel, memoria de regalos, límites diarios por tipo, recompensas pendientes), subida de nivel conservando excedente, y serialización.
- **`friendship_service.gd`** — autoload `Friendship`: única autoridad, API (get_nivel/get_puntos/get_progreso/get_limite_dia/regalar/charlar/enviar_carta/reclamar_recompensa), emite sobre EventBus M07 (`npc.gift_given`, `npc.friendship_level_up`) y ISaveProvider (sección `friendship`).
- **`test_amistad.gd`** — suite de validación (14 checks).

### Registro
- Autoload `Friendship` agregado en `project.godot`.
- `CHECKLIST-GLOBAL.md` fila 20 → 🟡 30/147 (núcleo hecho).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/friendship/gift_evaluator.gd` (nuevo)
- `game/isla-ancestral/scripts/friendship/vecino_amistad.gd` (nuevo)
- `game/isla-ancestral/scripts/friendship/friendship_service.gd` (nuevo)
- `game/isla-ancestral/scripts/friendship/test_amistad.gd` (nuevo)
- `game/isla-ancestral/project.godot`
- `CHECKLIST-GLOBAL.md`

## Verificación
`--headless --script test_amistad.gd` → **14/14 checks OK, exit 0** + boot del proyecto limpio sin errores de scripts.

## Pendientes honestos (`[?]`)
- VecinoData real de M19 (hoy por duck-typing → evaluador neutral).
- Reacción/expresión del vecino al regalo (M21).
- Regalos de cumpleaños sin consumir límite diario (M73).
- Cartas con respuesta diferida y límite por M29.
- Recursos `.tres` de niveles/eventos/cartas.
- Log DOM-AMISTAD centralizado.