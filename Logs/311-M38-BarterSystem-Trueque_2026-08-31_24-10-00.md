# Log 311: M38 Economía iter. BarterSystem (trueque) — glm-5.3-flash

**Fecha:** 2026-08-31
**Hora:** 24:10
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen

Iteración del M38 Economía (F5, V0) retomada del 🟡 (núcleo logs 171-235): el trueque (BarterSystem) ya no figura como pendiente. Intercambio objeto-por-objeto sin moneda, con amistad/temporada/límites diarios y salvavidas cozy. Módulo liberado 🟡 26/160.

## Cambios Realizados

### barter_offer.gd (nuevo, Resource)
- oferta_id, npc_id, pedido/entregado {item_id: cantidad}, amistad_minima (RF8), estaciones (RF7), es_salvavidas (RF12), limite_diario por oferta. Una instancia por archivo .tres.

### barter_system.gd (nuevo, autoload "Barter")
- `propuestas_disponibles(npc_id)`: gating amistad mínima (M20) + temporada (M29) + usos del día; el salvavidas SIEMPRE aparece y no consume límite.
- `ejecutar_trueque(npc_id, oferta_id)`: validación dura con motivos → remover pedido todo-o-nada (M14) → agregar lo recibido; si no entra, **rollback cozy del pedido** (el jugador jamás pierde por un bug de espacio).
- Límites diarios por npc_id reseteados por `dia_absoluto()` (M29/M30, contrato del proyecto).
- Señales `trueque_exitoso`/`trueque_rechazado(motivo)` + log `[DOM-ECO-TRUEQUE]`.
- Persistencia ISaveProvider M59: sección "barter" {dia, usos}.
- RF7 verificado: el saldo del jugador jamás se toca en un trueque.

### data/economia/barter/ (3 ofertas)
- trueque_salvavidas (RF12: piedra→madera, siempre disponible), trueque_finneas_herramienta (amistad 2), trueque_catalina_fibra (amistad 1, verano, límite 2).

### test_barter.gd (nuevo)
- Carga de ofertas, salvavidas RF12, atomicidad (inventario intacto tras rechazo), límite diario con motivo claro, RF8 amistad, RF7 temporada, saldo intacto → **0 fallos**.

### Registro
- Autoload `Barter` en project.godot; caché de clases regenerada.
- Checklist: 7 ítems [x] (RF7/RF8/RF12 + H×4). Progreso 19→26/160.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/economia/barter_offer.gd` (nuevo)
- `game/isla-ancestral/scripts/economia/barter_system.gd` (nuevo)
- `game/isla-ancestral/data/economia/barter/trueque_salvavidas.tres` (nuevo)
- `game/isla-ancestral/data/economia/barter/trueque_finneas_herramienta.tres` (nuevo)
- `game/isla-ancestral/data/economia/barter/trueque_catalina_fibra.tres` (nuevo)
- `game/isla-ancestral/scripts/economia/test_barter.gd` (nuevo)
- `game/isla-ancestral/project.godot` (autoload Barter)
- `DOCUMENTACION/38-Economia/plan-actual/04-Codigo.md` (Notas del Agente iter.)
- `DOCUMENTACION/38-Economia/plan-actual/05-Checklist.md` (26/160 + reserva liberada)
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`

## Verificación

- test_barter.gd: 0 fallos · test_minorista_mayorista: 14 checks/0 fallos · test_topos_banda: 11/0 · test_tiendas (M39): 0 fallos · test_calendario (M29): OK (Godot 4.5 headless).
