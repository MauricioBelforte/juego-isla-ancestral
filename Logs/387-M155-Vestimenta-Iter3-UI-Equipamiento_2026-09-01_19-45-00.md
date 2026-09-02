# Log 387: M155 Vestimenta — Iteración 3: UI de equipamiento completa (capas M53) + tests

**Fecha:** 2026-09-01
**Hora:** 19:45
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Iteración 3 del módulo M155 (Vestimenta y Accesorios): UI de equipamiento completa como capa del framework M53 — reemplaza el esqueleto roto de iter 1 (`equipment_ui.gd` esperaba nodos `$Panel/VBox/...` inexistentes), montada en UIRoot, con toggle global (E), desbloqueo progresivo visual y tests de capa en la suite (0 fallos).

## Cambios Realizados

### UI de equipamiento (capas M53)

- **`scripts/ui/layers/equipment_layer.gd`** — `EquipmentLayer extends UILayer` (MODAL_SIMPLE), construida por código siguiendo el patrón de InventoryLayer:
  - Panel cozy (StyleBoxFlat crema/borde dorado) con dimensión y centro.
  - 4 botones de slot (head/body/feet/accessory) con prenda equipada + rareza; click en slot ocupado = desequipar.
  - Grid con las 16 prendas del catálogo: nombre + rareza + id; `disabled` con 🔒 si `UnlockCondition` no se cumple (capítulo/flag); click = equipar (manager.valida slot).
  - Label del bono de terreno del equipo (`player_equipment.get_total_terrain_bonus`) y refresh por señales `equipment_changed`/`terrain_bonus_updated`.
  - `toggle()` compatible con UIManager; cierra con `equipamiento`/`pausa`.
- **`scripts/ui/ui_root.gd`** — monta `EquipmentLayer` como capa 8 del UIRoot (print de montaje).
- **`scripts/ui/core/ui_manager.gd`** — toggle global con la acción `equipamiento` (E) en `_unhandled_input` (inventario usa B, equipamiento E).
- **`project.godot`** — nueva acción `equipamiento` (KEY_E física 69) en [input].

### Tests (suite completa ÉXITO 0 fallos)

- **`tests/unit/ui/test_equipment_layer.gd`** — 3 tests: build+toggle (oculto→visible→oculto), grid con 16 items del catálogo, 20+ botones (4 slots + 16 prendas).
- Suite completa vía `res://tests/run_tests.gd` → **ÉXITO, exit 0**.
- Smoke de parse: 198/198 OK (asset validator).

### Verificación V4 (log del runtime)

- `[DOM-UI] capa registrada: EquipmentLayer (tipo=MODAL_FULL, pila=8)` + `UIRoot: capas montadas (... equipamiento=true)` + 0 parse errors (boot completo: spawn Y=17, Catalina snap, hotbar, NPC agent).
- **[?] Verificación visual del panel abierto:** el runtime quedó embebido en el panel del Depurador/Remoto del editor de otro agente y la presentación D3D12 no se captura con la ventana oculta (PrintWindow devuelve vacío). La validación visual con tecla E en ventana propia queda como dueño: deepseek-v4-flash-vision-exp (próxima sesión).

## Archivos Modificados/Creados

- Creados: `game/isla-ancestral/scripts/ui/layers/equipment_layer.gd`, `game/isla-ancestral/tests/unit/ui/test_equipment_layer.gd`, capturas intento (no versionadas)
- Modificados: `game/isla-ancestral/scripts/ui/ui_root.gd` (montaje capa 8), `game/isla-ancestral/scripts/ui/core/ui_manager.gd` (toggle E), `game/isla-ancestral/project.godot` (acción equipamiento), `DOCUMENTACION/155-Vestimenta-Y-Accesorios/plan-actual/05-Checklist.md` (bloque iter 3, 62/123), `CHECKLIST-GLOBAL.md` (fila 155), `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fila M155), `Mensajes entre modelos/ESTADO-PARALELO.md` (fila M155), `Logs/ULTIMO_NUMERO.txt` (→387)

## Verificación

- Suite completa ÉXITO (0 fallos) · parse 198/198 · capa registrada y montada (log) · 4 slots y 16 prendas en la UI (test grid=16) · 2 [?] honestos (visual del panel en ventana propia; integración M14/M156 ajenas).
