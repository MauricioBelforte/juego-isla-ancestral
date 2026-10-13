# Log 1733: M17-Construcción - utilidades de rejilla + copiar pieza (76 -> 80)

**Fecha:** 2026-10-12
**Hora:** 06:15
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 179): barrido de M17-Construcción (98 `[ ]` con hooks listos).
**M17: 76 -> 80 `[x]` / 175 (+4).**

## Implementado

### 1. Utilidad compartida de conversión celda ↔ mundo (D83/D86/D88)

`ConstruccionMundo` (estáticas, usables sin instancia desde preview, fantasma y datos):

```gdscript
const OFFSET_MEDIO_VOXEL: float = 0.5
static func mundo_desde_celda(celda: Vector3i) -> Vector3   # centro = celda + 0.5
static func celda_desde_mundo(pos: Vector3) -> Vector3i     # floor en los 3 ejes
static func esquina_desde_celda(celda: Vector3i) -> Vector3 # para AABB exactos
```

Convención documentada: la celda (x,y,z) ocupa el cubo [x,x+1)×[y,y+1)×[z,z+1), así que su centro
está en (x+0.5, y+0.5, z+0.5). El offset de medio voxel se aplica en **un solo lugar**, lo que evita
que preview, fantasma y datos se desincronicen tras guardar/cargar (D89).

### 2. `copiar_pieza()` (F110/F112)

`BuildManager.copiar_pieza(origen, destino)` + `BuildHistory.TIPO_COPIAR` (nuevo):

- Conserva la rotación de la pieza original (F110).
- No desocupa el origen (a diferencia de `mover_pieza`).
- Se cobra como colocación nueva (F112).
- Rechaza con motivo claro: `NO_HAY_PIEZA`, `CELDA_OCUPADA`, `RECURSOS_INSUFICIENTES` o el motivo
  real del validador.
- Registra en el historial para que undo/redo funcionen.

## Verificación

`scripts/construccion/test_construccion_iter7.gd` — **25 checks, 0 fallos** (round-trip
celda→mundo→celda en 5 casos, centro en x+0.5, floor con negativos, copia conservando rotación,
cobro correcto, rechazos por destino ocupado / origen vacío / sin recursos).

Regresión verificada sin cambios: `test_construccion.gd`, `test_construccion_iter2.gd`,
`test_construccion_iter6.gd` (0 fallos cada una).

## Tres errores propios durante la depuración (documentados en 04-Codigo.md)

1. `ConstruccionMundo.new()` **vacío no reporta superficie**: sin terrain conectado toda celda queda
   "en el aire" y la colocación se rechaza con `SIN_SOPORTE`. Hizo falta un `MundoPlano` falso.
2. El inventario falso arrancaba con 0 stones, así que ni la pieza original se podía colocar.
3. La expectativa de costo estaba mal: la copia se suma a la colocación original (20-4-4 = 12).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/construccion/construccion_mundo.gd` (utilidades D83/D86/D88)
- `game/isla-ancestral/scripts/construccion/build_manager.gd` (`copiar_pieza`)
- `game/isla-ancestral/scripts/construccion/build_history.gd` (`TIPO_COPIAR`)
- `game/isla-ancestral/scripts/construccion/test_construccion_iter7.gd` (nueva, 25 checks)
- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` (4 flips + nota)
- `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md` (Notas del Agente)
