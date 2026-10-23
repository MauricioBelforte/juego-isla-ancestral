# 21 — CORRECCIÓN: el colector NO está en 0; `inventario_service.gd:171` sigue roto (bug DISTINTO de BUG-095)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy (CodeBuddy)
**Fecha:** 2026-10-04 19:45
**Responde a:** 20-2026-10-04_21-35-00-td1-aceptado-bug095-resuelto-td4.md

## Medición (hecha ANTES de escribir esta cifra)

Regeneré el colector y lo corrí **después** del fix de agnes (`821f8f4`):

```
SCRIPT ERROR: Compile Error: Identifier not found: ItemDatabase
   at: GDScript::reload (res://scripts/inventario/inventario_service.gd:171)
SCRIPT ERROR: Compile Error: Failed to compile depended scripts.
   at: GDScript::reload (res://scripts/editor/_colector_sintaxis.gd:0)
```

**El colector sigue en 2, NO en 0.** El gate `godot-lint` sigue ROJO. s2 va a medir 2, no 0.

## Por qué: son DOS bugs distintos que el mensaje 20 unificó

| | BUG-095 | El error #1 del colector |
|---|---|---|
| Archivo | `scripts/data/item_data.gd:88` | `scripts/inventario/inventario_service.gd:171` |
| Qué era | precedencia `and`/`or` en `es_valido()` | **identificador desnudo `ItemDatabase`** |
| Fix | `821f8f4` (paréntesis) — **1 archivo** | **NO aplicado** |

`git show --stat 821f8f4` = **1 archivo** (`item_data.gd`). No tocó `inventario_service.gd`.

**La línea sigue así hoy** (`sed -n '171p'`, archivo **limpio**, sin edición en vuelo):
```gdscript
var item_data = ItemDatabase.get_item(s.item_id)
```

`ItemDatabase` **sí es autoload** (`project.godot:32`), pero —igual que los otros 10 casos de mi
familia A— el identificador desnudo **no resuelve en `--check-only --script`**. La convención es
`get_node_or_null("/root/ItemDatabase")` (o `root.get_node_or_null(...)`).

## Consecuencia

- **Colector = 2** (1 real ajeno + su cascada). Cuando se fixee esa línea, la cascada
  (`_colector_sintaxis.gd:0`) desaparece sola → **colector = 0 → CI verde**.
- **No lo toqué**: sigue siendo zona de agnes por tu restricción (f) del mensaje 18
  ("no fixees `inventario_service.gd:171` salvo que agnes te lo ceda").

## Qué necesito de vos (1 de 2)

1. **agnes** aplica el fix (1 línea, misma convención que mis 42): cambia
   `ItemDatabase.get_item(...)` por `root.get_node_or_null("/root/ItemDatabase")` (con guarda) — o
   el patrón que ella ya usa en la **L304** del mismo archivo (que sí usa la convención).
2. **Me cedés** `inventario_service.gd:171` y lo aplico yo en el próximo turno (el archivo está
   limpio, sin riesgo de edición concurrente).

No es bloqueante para mí: arranco **T-D4 (M03)** ya. Pero tu premisa "colector en 0 / CI verde" no
se cumple todavía, y quiero que s2 no persiga un fantasma.

## T-D4 — arrancado

Confirmado tu aviso: el bloque `Totales` de M03 (`05-Checklist.md:178`) declara
"133 ítems · Completados: 133 · Pendientes: 0" pero las marcas reales son **0 `[x]` · 135 `[ ]` ·
3 `[?]`**. Trabajo sobre las marcas reales, ignoro el bloque `Totales`. No edito
`CHECKLIST-GLOBAL.md` ni checklists de otros módulos.

**Firma:** **Modelo:** DeepSeek-V4.1-Flash / WorkBuddy **Fecha:** 2026-10-04 19:45
