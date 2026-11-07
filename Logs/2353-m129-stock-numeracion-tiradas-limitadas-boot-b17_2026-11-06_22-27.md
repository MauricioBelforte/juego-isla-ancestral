# Log 2353: M129 — stock y numeracion de tiradas limitadas + boot B-17/B-12-06

**Fecha:** 2026-11-06
**Hora:** 22:27
**Modelo:** DeepSeek V4.1 Flash
**Plataforma:** OpenCode
**Canal:** `Mensajes entre modelos/DS-V4.1-Flash-Opencode/` (mensaje 252)
**Rol:** gate-1 (auditor) + codificacion. **No sella.**
**Continua:** Log 2351 (46 degradaciones + agrupador v2.1).

---

## Resumen

Reasignacion de agnes-3-flash (msg 249): M129 (codigo/logica) + boot B-17/B-12-06. Implementado el
item L101 que estaba `[?]` por Familia A: control de stock y numeracion de tiradas limitadas fisicas,
con persistencia M59 y tests headless.

## Cambios

- `game/isla-ancestral/data/legal/merchandising.json` **v3**: seccion `tiradas_limitadas` (3 SKUs:
  artbook 500, vinilo 300, figura de resina 200).
- `game/isla-ancestral/scripts/legal/merch_manager.gd`: estado por SKU + 14 funciones de stock/
  numeracion, `get_section_name/get_save_data/restore_save_data` y registro como proveedor de
  `SaveManager`.
- `game/isla-ancestral/scripts/legal/merch_validator.gd`: valida `tiradas_limitadas`.
- `game/isla-ancestral/scripts/legal/test_merch_m129.gd`: v3, **58 checks / 0 fallos**.
- `game/isla-ancestral/scripts/legal/test_merch_boot_m129.gd`: NUEVO, boot pre-check B-17/B-12-06,
  **11 checks / 0 fallos**.
- `DOCUMENTACION/129-Merchandising/plan-actual/05-Checklist.md`: L101 `[?]`→`[x]` con evidencia;
  Totales reales 107/0/1 = 108; L134 marcado como dueño Hy4.
- `DOCUMENTACION/129-Merchandising/plan-actual/04-Codigo.md`: seccion 7 con la iteracion v3.

## Verificacion

- `godot --headless --path game/isla-ancestral -s res://scripts/legal/test_merch_m129.gd` → EXIT 0,
  `Resumen M129: 58 checks, 0 fallos`.
- `godot --headless --path game/isla-ancestral -s res://scripts/legal/test_merch_boot_m129.gd` →
  EXIT 0, `Resumen boot M129: 11 checks, 0 fallos`.
- Boot (`--quit-after 600`) → EXIT 0, sin `SCRIPT ERROR`/`Parse Error`.
- JSON reparseado con Python: version 3, 10 productos, 3 tiradas.

## Respaldos

`game/isla-ancestral/scripts/legal/Obsoletos/2026-11-06_22-18-40_{merch_manager.gd,merch_validator.gd,test_merch_m129.gd,merchandising.json}`.

## Pendiente

- L134 (pipeline de mockups 3D) → Hy4.
- `quality.yml` sin tocar (requiere autorizacion del fundador).
- Sin commits; cambios en working tree.
