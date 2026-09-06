# Log 584: M65 Animales-IA — cierre de reorganización (pack/school a animales_ia)

**Fecha:** 2026-09-03
**Hora:** 07:00
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Último ítem accionable de M65 (84/89): movidos `pack_logic.gd` y `school_logic.gd` de `scripts/fauna/` a `scripts/animales_ia/` (reorganización del checklist). Los 5 pendientes restantes tienen dueño ajeno.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/fauna/pack_logic.gd` → `scripts/animales_ia/pack_logic.gd` | Movido con .uid (lógica de manadas — dominio animales IA) |
| `scripts/fauna/school_logic.gd` → `scripts/animales_ia/school_logic.gd` | Movido con .uid (lógica de bancos/peces) |
| `DOCUMENTACION/65-Animales-IA/plan-actual/05-Checklist.md` | Ítem [x] con evidencia |

## Verificación
- Scan del repo: **0 referencias cruzadas** a pack_logic/school_logic fuera de los archivos movidos (movimiento seguro sin romper imports).
- `test_m65.gd`: **0 fallos** tras el movimiento.
- Regresión `test_fauna.gd` (M36): **0 fallos** (fauna quedó limpia sin los archivos).

## Pendientes M65 restantes (todos con dueño ajeno)
- [M08] Movimiento real con NavigationServer3D evitando voxels
- [M09] Spawner con burbuja 72m y filtros
- [M45] Modelos/meshes de animales
- [M43] Sonidos contextuales de fauna
- [M61] Pool de nodos para evitar alloc/free

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/animales_ia/pack_logic.gd` *(movido)*
- `game/isla-ancestral/scripts/animales_ia/school_logic.gd` *(movido)*
- `DOCUMENTACION/65-Animales-IA/plan-actual/05-Checklist.md` *(modificado)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 584)*
- `Logs/reservas/584-...txt` *(creado y borrado)*
