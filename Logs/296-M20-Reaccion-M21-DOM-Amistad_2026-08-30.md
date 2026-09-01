# Log 296 — M20 (Amistad): Reacción M21 + DOM-AMISTAD

**Fecha:** 2026-08-30
**Hora:** 20:52
**Autor:** WorkBuddy (continuación de M20, tareas no visuales)
**Módulo:** 20-Sistema-De-Amistad
**Alcance:** tareas B (reacción M21) y D (DOM-AMISTAD) del remanente no visual.

## Contexto

M20 ya tenía: núcleo (ox-alpha), cumpleaños + cartas con M29 (WorkBuddy), y las tareas
A (gustos reales M19) + C (niveles en `.tres`) cerradas en el Log 295. Quedaban B y D,
que no requieren visión, confirmadas por el usuario ("si segui con ese").

## B — Reacción M21 (clase exacta de regalo)

**Problema previo:** `EventBus.npc.gift_given` emitía solo `liked: bool`. M21 no podía
reaccionar por clase de regalo (AMADO / GUSTA / NEUTRAL / DUPLICADO), solo "le gustó o no".

**Cambio (`scripts/core/event_bus.gd`):**
- `signal gift_given(npc_id: String, item_id: String, clase: int)` (era `liked: bool`).
- Comentario explica que `clase` = `GiftEvaluator.Clase` para que M21 reaccione por
  expresión/texto exactos.

**Cambio (`scripts/friendship/friendship_service.gd`):**
- `_emitir_npc_events(...)` ahora emite `bus.npc.gift_given.emit(vecino_id, item_id, clase)`.
- No había suscriptores previos de `gift_given` → cambio de firma seguro.

**Puente M21 → M20 (ya existía, verificado en vivo):** `WorldStateService` (M21) resuelve
`amistad_<npc_id>` delegando en `Friendship.get_nivel(npc_id)` (`_get_amistad`). Las
variantes de diálogo por nivel de amistad (05-Checklist L58) ya funcionan por delegación.

**Verificación (test_amistad_eventos.gd → `_test_reaccion_m21`):**
- `gift_given` tiene 3 argumentos (npc, item, clase) — contrato correcto.
- `_emitir_npc_events` EMITE la clase GUSTA y la clase NEUTRAL exactas (no colapsadas a bool).
- `WorldStateService.amistad_R_M21_WS` == nivel vivo de M20 (autoload real Friendship).

> Nota de implementación del test: en modo `--script` los autoloads SÍ están en `/root`
> (EventBus, Friendship, Inventario). Por eso el test inyecta `_fs` en el árbol para que
> la emisión llegue al EventBus real, y usa `_emitir_npc_events` directo (aislar el contrato
> de emisión del Inventario, que rechaza regalos sin item). El cálculo de la clase en sí ya
> está cubierto por `_test_gustos_reales_m19` vía `GiftEvaluator.evaluar`.

## D — DOM-AMISTAD (log centralizado con rotación)

**Cambio (`scripts/friendship/friendship_service.gd`):**
- `const LOG_CAP := 100`, `var _eventos: Array = []`.
- `registrar_evento(tipo, npc_id, detalle, clase=-1)` → append + `pop_front` mientras
  `size() > LOG_CAP` (rotación, se descartan los más antiguos).
- `get_eventos()` (copia), `get_eventos_npc(npc_id)` (filtrado por vecino).
- 6 sitios de llamada: `regalar` (regalo + nivel), `regalar_en_cumpleanos` (regalo_cumpleanos
  + nivel), `celebrar_cumpleanos` (cumpleanos), `charlar` (nivel), `_madurar_cartas`
  (carta_recibida + nivel), `_recibir_carta_npc` (carta_npc).
- Persistencia: `get_save_data()` incluye `"eventos"`; `restore_save_data()` repuebla
  `_eventos` con guarda de cap.

**Verificación (test_amistad_eventos.gd → `_test_dom_amistad`):**
- Al menos 1 evento registrado; filtrado por NPC devuelve eventos de D_A.
- D_A registra regalo / nivel / cumpleanos / carta_npc.
- Rotación respeta cap 100 tras inyectar 150 eventos.
- Eventos persistidos tras `get_save_data` → `restore_save_data`.

## Resultado de tests

- `test_amistad.gd`: **14/14 OK** (sin regresión).
- `test_amistad_eventos.gd`: **53/53 OK** (era 44/44; +9 checks de B y D).

## Archivos modificados

- `game/isla-ancestral/scripts/core/event_bus.gd` — firma `gift_given(npc, item, clase)`.
- `game/isla-ancestral/scripts/friendship/friendship_service.gd` — emisión `clase`, DOM-AMISTAD.
- `game/isla-ancestral/scripts/friendship/test_amistad_eventos.gd` — `_test_reaccion_m21`,
  `_test_dom_amistad` (preload `BUS`).

## Checklist (05-Checklist.md)

- `[x]` L49 Reacción del vecino por clase de regalo (M21).
- `[x]` L58 Variantes de diálogo por nivel de amistad (M21).
- `[x]` L107 Log DOM-AMISTAD centralizado con rotación.
- Total M20: **46/148** (era 43/148).
- Pendiente honesto: **L82** escenas breves de evento con diálogo (contenido M21, requiere
  work de escenas/diálogos, fuera del alcance de este cierre).

## Riesgos / notas

- `regalar` depende de `ItemDatabase` para el meta del item; FLOR_SILVESTRE no es un item
  real del juego (solo aparece en perfiles/tests), por eso el test de emisión usa
  `_emitir_npc_events` directo con clase conocida en vez de `regalar` con item inexistente.
- M21 (consumidor) debe cablear `gift_given.clase` a su lógica de expresión/texto; el hook
  de M20 está listo. Eso es alcance de M21, no de M20.
- `ULTIMO_NUMERO.txt` estaba en 272 (reset de otro proceso); se fijó en 296.
