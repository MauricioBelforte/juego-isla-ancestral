# Log 1286: Colector en 0 - ultimo rezagado ItemDatabase en inventario_service.gd:171

**Fecha:** 2026-10-04
**Hora:** 19:52
**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code

## Resumen

El director (canal 18) confirmo que la trampa del `--script` estaba resuelta (DeepSeek, Log 1277: 0 falsos positivos) y me pidio verificar si el colector llegaba a 0. Llegaba a 1: el ultimo rezagado de la convencion autoload. Fixeado y verificado.

## Cambios Realizados

### El ultimo error del colector

Al correr el colector con el binario real:

```
& "C:\Temp\godot\godot472.exe" --headless --path game/isla-ancestral --check-only --script scripts/editor/_colector_sintaxis.gd
SCRIPT ERROR: Compile Error: Identifier not found: ItemDatabase
   at: GDScript::reload (res://scripts/inventario/inventario_service.gd:171)
SCRIPT ERROR: Compile Error: Failed to compile depended scripts.
   at: GDScript::reload (res://scripts/editor/_colector_sintaxis.gd:0)
```

Era exactamente el caso A del BUG-098 (familia "Identifier not found: <autoload>"), el unico de los 11 que DeepSeek no fixeo porque era de agnes (BUG-095). El director lo habia marcado como "agnes YA LO FIXEO (821f8f4)", pero verifique: `821f8f4` es el fix de `es_valido()` en `item_data.gd:88` (parentesis explicitos), no este.

Diagnostico: `inventario_service.gd:171` usaba `ItemDatabase.get_item(...)` (nombre directo del autoload). El mismo archivo ya usa la convencion del proyecto en L304:

```gdscript
var db = get_node_or_null("/root/ItemDatabase")
if db != null:
    var item = db.get_item(s.item_id)
```

L171 era un rezagado: el unico uso directo de un autoload en todo el archivo. Fix aplicado con el mismo patron (defensivo: `if db != null`, item_data puede ser null y los 3 usos siguientes ya tenian guardia `if item_data else ...`).

### Verificacion

- Colector `--check-only --script`: **EXIT 0, 0 SCRIPT ERROR** (antes: 1 error + 1 cascada).
- Suite M14 (`scripts/inventario/test_inventario.gd`): **73 checks, 0 fallos**, EXIT 0. Sin regresiones.

### Estado del gate BUG-091

44 (Log 1271) -> 2 (Log 1277, DeepSeek) -> **0** (este log). El colector esta en cero por primera vez. Falta confirmar el job `GDScript Linter` en CI.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/inventario/inventario_service.gd` (L171: convencion autoload)
- `Logs/1286-colector-cero-itemdatabase-inventario_2026-10-04_19-52.md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1286 consumido; nueva cabeza 1287)

## Huella de push (AGENTS.md seccion 4.3)

Push principal: `f2ea332..72d05aa` (main -> main), 2026-10-04 19:53, atria-dawn-s2 / Kilo Code. Commit `72d05aa` "Se fixeo el ultimo rezagado del colector: ItemDatabase en inventario_service.gd:171". Nota: entre mi push anterior (`78e353a`, canal 17) y este, otros agentes de la flota commitearon (mi base de pull era `f2ea332`); sin conflictos. Sin catch-ups.
