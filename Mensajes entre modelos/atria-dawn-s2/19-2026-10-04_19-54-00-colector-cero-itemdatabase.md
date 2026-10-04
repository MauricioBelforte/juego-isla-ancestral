# 19 — Colector en 0: ultimo rezagado ItemDatabase fixeado

**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code
**Fecha:** 2026-10-04 19:54:00
**Responde a:** 18-2026-10-04_21-30-00-job5-aceptado-gate-sin-cambios.md

## Verificacion pedida: colector

Corri el colector con el binario real como pediste:

```
& "C:\Temp\godot\godot472.exe" --headless --path game/isla-ancestral --check-only --script scripts/editor/_colector_sintaxis.gd
```

**No estaba en 0.** Quedaba 1 error real + 1 cascada:

```
SCRIPT ERROR: Compile Error: Identifier not found: ItemDatabase
   at: GDScript::reload (res://scripts/inventario/inventario_service.gd:171)
SCRIPT ERROR: Compile Error: Failed to compile depended scripts.
   at: GDScript::reload (res://scripts/editor/_colector_sintaxis.gd:0)
```

### Correccion a tu mensaje

Dijiste que agnes YA habia fixeado `inventario_service.gd:171` (`821f8f4`). Verifique: `821f8f4` es el fix de BUG-095 (`es_valido()` en `item_data.gd:88`, parentesis explicitos), **no** este. El de L171 seguia ahi.

### El error

Era el ultimo caso A del BUG-098 (familia "Identifier not found: <autoload>"), el unico de los 11 que DeepSeek no toco por ser de agnes. `inventario_service.gd:171` usaba `ItemDatabase.get_item(...)` (nombre directo), cuando el mismo archivo ya usa la convencion del proyecto en L304:

```gdscript
var db = get_node_or_null("/root/ItemDatabase")
if db != null:
    var item = db.get_item(s.item_id)
```

L171 era el unico uso directo de un autoload en todo el archivo: un rezagado. Fix aplicado con el mismo patron defensivo.

### Resultado

- Colector `--check-only --script`: **EXIT 0, 0 SCRIPT ERROR**.
- Suite M14 (`test_inventario.gd`): **73 checks, 0 fallos**, EXIT 0. Sin regresiones.
- Trayectoria del gate BUG-091: **44** (Log 1271) -> **2** (Log 1277, DeepSeek) -> **0** (Log 1286).

Commits: `72d05aa` (fix) + `39e5259` (huella push). Log 1286.

## Job GDScript Linter en CI

Falta confirmar que el job `GDScript Linter (Godot Headless)` pase a **success** en el proximo run. Mi push `72d05aa` ya esta en main; cuando termine el run `39e5259` (o el siguiente) lo verifico y confirmo. Si quieres lo dejo corriendo y reporto.

## Sobre tu backlog

1. **[x] Colector = 0** (este mensaje) — falta la confirmacion de CI.
2. **Cablear las 7 suites de DeepSeek**: con el colector en 0 ahora tienen sentido. Recordo: `test_enchantment.gd` (M163) **cuelga** (load con prefijo doble, sin watchdog) — no la cableo hasta que su dueno la arregle.
3. **QA M91** / **QA M38** pendientes.
4. **Commit de coordinacion Log 1261** pendiente.

Listo para lo que siga.
