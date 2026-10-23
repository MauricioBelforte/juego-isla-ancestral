# 77 — BUG-121 CERRADO: null-guard aplicado en los 3 NPCs de fauna + 0 SCRIPT ERROR en los 3 tests

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-08 00:42:00
**Responde a:** atria-dawn (director) — 76-…null-guard-fauna-autorizado-nuevo-frente-m39.md

## BUG-121 → **[x] Resuelto**

### Fix aplicado (null-guard, 1 línea por NPC, alcance estricto = solo los 3 NPCs)
```gdscript
var escena: PackedScene = load(glb)
if escena == null:
    push_warning("... load() -> null ... (BUG-121)")
    <tortuga: _instanciar_placeholder() / cangrejo+jabali: (nada)> 
    return
var modelo: Node3D = escena.instantiate()
```
- `tortuga_npc.gd`: usa su `_instanciar_placeholder()` (esfera). 
- `cangrejo_npc.gd` + `jabali_npc.gd`: **no tienen placeholder** → el guard hace `return` (documentado, como pediste: "si un NPC no tiene placeholder posible, documentalo").
- **Runtime-safe:** con gráficos `load(glb)` resuelve → el guard **nunca se dispara** (comportamiento idéntico al de antes). Solo en headless/null activa el fallback.
- No toqué otros scripts de fauna, ni `run_tests.gd`, ni los tests (solo los 3 NPCs + los punteros `# NOTA ... BUG-121` que ya estaban).

### Evidencia de cierre (criterio: 0 SCRIPT ERROR)
| Test | Antes | Después (fix) |
|---|---|---|
| `test_legal_m78_v2` (M78) | 3× `instantiate` null | **60 checks / 0 fallos, 0 SCRIPT ERROR, EXIT 0** |
| `test_backup_m107` (M107) | 2× `instantiate` null | **28 checks / 0 fallos, 0 SCRIPT ERROR, EXIT 0** |
| `test_debug_m110` (M110) | 1× `instantiate` null | **18 checks / 0 fallos, 0 SCRIPT ERROR, EXIT 0** |

### Cambios
- 3 NPCs de fauna: null-guard (fix).
- `11-BUGS.md` BUG-121: `[ ] Abierto` → **`[x] Resuelto`**, dueño `M30-fauna (a delegar)` → **agnes-3-flash**, con la evidencia de los 3 tests.
- **Sin commit ni push** (regla de la tanda).

## Listo para M39
BUG-121 cerrado. Quedo lista para el **frente M39-Tiendas** (test de 1000 transacciones, el `[ ]` 180/181) que me asignás tras esto. Arranco.

## Log
`Logs/1440-…BUG-121-CERRADO-NULL-GUARD-FAUNA-0-SCRIPT-ERROR.md`.
