# Log 297 — M21 consume gift_given de M20 por clase exacta

**Fecha:** 2026-08-30
**Hora:** 21:13
**Modelo:** Hy3 (Kilo)
**Módulos:** M20 (Amistad) → M21 (Diálogos)
**Tipo:** Integración (cableado consumidor de evento) + test + documentación

## Contexto

M20 (Friendship) emite `EventBus.npc.gift_given(npc_id, item_id, clase)` con la clase exacta
de `GiftEvaluator.Clase` (0=AMADO, 1=GUSTA, 2=NEUTRAL, 3=DUPLICADO). En el turno anterior
(Log 296) se cerraron B (reacción M21) y D (DOM-AMISTAD) de M20, confirmando que la señal
lleva la clase exacta. Pero **ningún sistema consumía** `gift_given` ni `friendship_level_up`:
M21 no reaccionaba al regalo. Usuario aprobó ("si hace eso") cablear M21 para que consuma
`gift_given.clase` en sus expresiones/textos.

## Qué se hizo

### 1. Cableado en `scripts/dialogos/dialogue_manager.gd` (autoload `DialogueManager`)
- `signal gift_reaction(npc_id: String, reaccion_id: String, clase: int, item_id: String)`
- `signal level_up_reaction(npc_id: String, new_level: int)`
- `const REACCION_REGALO`: mapa `GiftEvaluator.Clase -> {id, expresion, texto}`:
  - 0 → R_AMADO (feliz_intenso), 1 → R_GUSTA (feliz), 2 → R_NEUTRAL (neutral),
    3 → R_DUPLICADO (neutral). Los `texto` son claves `REACCION_REGALO_*` (localización M87).
  - Los `id` coinciden con `GiftEvaluator._reaccion()` para trazabilidad.
- `var _ultima_reaccion_regalo: Dictionary` (contexto por NPC para diálogos subsiguientes).
- `func _ready()`: suscripción a `EventBus.npc.gift_given` (`_on_gift_given`) y a
  `EventBus.npc.friendship_level_up` (`_on_level_up`), con guardas `has_signal` +
  `is_connected` para evitar doble suscripción.
- `func _on_gift_given(npc_id, item_id, clase)`: si `REACCION_REGALO` tiene la clase, guarda
  `_ultima_reaccion_regalo[npc_id]` y emite `gift_reaction`. Clases fuera de rango se ignoran.
- `func _on_level_up(npc_id, new_level)`: reenvía `level_up_reaction`.
- `func get_ultima_reaccion_regalo(npc_id) -> Dictionary`: consulta (o `{}`).

### 2. Test headless `scripts/dialogos/test_reaccion_m21_dialogo.gd`
- Usa el autoload real `/root/DialogueManager` (su `_ready()` ya corrió al iniciar el árbol).
- **Lección clave:** en `--script` los autoloads se añaden al árbol **después** de `_init()`,
  por eso la ejecución se difiere con `call_deferred("_ejecutar")` (igual patrón que
  `test_amistad_eventos.gd`). Correr en `_init()` da `root` vacío → autoloads `null`.
- Verifica: 4 clases → `reaccion_id` correcta (R_AMADO/R_GUSTA/R_NEUTRAL/R_DUPLICADO),
  `item_id` propagado, `clase` propagada exacta; almacenamiento por NPC; `level_up_reaction`.
- **Resultado: 0 fallos.**

### 3. Regresión
- `test_dialogos.gd`: **0 fallos** (el manager sigue funcionando tras agregar `_ready()`/handlers).

## Resultado final

- M21 reacciona al regalo por clase exacta de M20 (no solo un bool "le gustó/no").
- Contrato de señal listo para que la UI (M53/M87) consuma `gift_reaction`/`level_up_reaction`.
- Ambas suites verdes: test_reaccion_m21_dialogo 0/0, test_dialogos 0/0.

## Pendiente honesto

- La UI (M53) aún no consume `gift_reaction`/`level_up_reaction` (no hay UI de reacción a regalo).
- Claves `REACCION_REGALO_*` no están dadas de alta en el diccionario M87 todavía.
- M20 `L82` (escenas breves de evento con diálogo) sigue abierto — contenido para M21, opcional.

## Archivos
- `game/isla-ancestral/scripts/dialogos/dialogue_manager.gd` (editado: señales, const, _ready, handlers)
- `game/isla-ancestral/scripts/dialogos/test_reaccion_m21_dialogo.gd` (nuevo)
- `DOCUMENTACION/21-Dialogos/plan-actual/05-Checklist.md` (+2 [x])
- `DOCUMENTACION/21-Dialogos/plan-actual/04-Codigo.md` (iteración 3)
- `CHECKLIST-GLOBAL.md` (fila 21: 62/135 + 15 [?])
- `Logs/297-M21-Consumo-gift-given-M20_2026-08-30.md`
