# Log 1514: Fix BUG-125 — InventoryPanel con doble add_child (ERROR de engine en primera apertura)

**Fecha:** 2026-10-09
**Hora:** 04:46
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

> ⚠️ **Log RETROACTIVO** (creado por pedido del director en msg 86, 2026-10-09 04:34): el cierre
> real de este bug ocurrió el **2026-10-09 ~02:15** (encargo msg 80). La evidencia estaba ya
> documentada en `11-BUGS.md` y en el informe msg 81; este archivo la archiva con formalidad.

## Resumen

Se corrigió el **doble `add_child`** del `InventoryPanel` en `player.gd`: el panel se agregaba dos
veces (a `bg` en L554 y a `canvas` en L700), lo que producía un **ERROR de engine en cada primera
apertura del inventario** (`Node already has a parent`) y dejaba el árbol de nodos en estado
distinto al diseñado.

## Cambios Realizados

- Eliminado el `add_child` duplicado en `player.gd` (~L700): el panel queda como hijo único de
  `Backdrop` (la ruta diseñada), sin el segundo enganche a `InventoryCanvas`.
- **Verificación rojo→verde:** suite `tests/test_bug125_bug126_fix.gd` (creada en el mismo
  encargo, cubre BUG-125 + BUG-126):
  - **ROJO** (antes del fix): el ERROR `already has a parent` se reproduce.
  - **VERDE** (después): **23 checks / 0 fallos**.
- Regresión: runner completo del momento **22 suites OK**.
- `--check-only` EXIT 0 sobre `player.gd`.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/player/player.gd` (fix, -1 línea)
- `game/isla-ancestral/tests/test_bug125_bug126_fix.gd` (suite nueva, permanente)
- `DOCUMENTACION/11-BUGS.md` (BUG-125 → [x] Resuelto con detalle en §5/§6)
- Informe de cierre: **msg 81** del canal `mimo-v2.6-flash-free/`

**Nota de estado:** cambios **sin stagear/commit** (el director centraliza los pushes). Identidad
del cierre certificada en el informe msg 81 y aceptada por el director (msg 82).
