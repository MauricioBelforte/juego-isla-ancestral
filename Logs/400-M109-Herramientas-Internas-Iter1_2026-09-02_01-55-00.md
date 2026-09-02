# Log 400: M109 Herramientas Internas — Iteración 1: framework de editores + Editor de Recetas operativo

**Fecha:** 2026-09-02
**Hora:** 01:55
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Iteración 1 del módulo M109 (Herramientas Internas, V0/Media): arquitectura de editores data-driven con el primer editor operativo (Recetas, RF6) + núcleo de validación testable + plugin del editor registrado.

## Cambios Realizados

### Framework y herramientas (scripts/editor/)
- `tools/editor_base.gd` — EditorBase (@tool PanelContainer): patrón común de los 14 editores — lista de entradas, selector, formulario dinámico por campo, guardado con backup `.bak`, mensajes de estado.
- `tools/recipe_tool.gd` — **Editor de Recetas (RF6) operativo**: lista las recetas reales de `data/balance/crafting.json`, formulario de 10 campos (nombre/categoría/nivel/estación/origen/coste_recursos "id:cant, id:cant"/coste_ao/resultado/cantidad), guardado validado con backup `.bak`.
- `support/recipe_schema.gd` — RecipeSchema: reglas de crafting.json (categorías válidas, estaciones, nivel ≥1, coste_recursos bien formado, cantidad ≥1) + conversores de costes.
- `plugin_herramientas.gd` — EditorPlugin que registra el dock "Herramientas internas" (DOCK_SLOT_BOTTOM_LEFT) con el catálogo de editores (Recetas activo; los demás se suman por el mismo patrón). Registrado en `project.godot` → `[editor_plugins] enabled`.

### Tests
- `tests/unit/editor/test_recipe_schema.gd` — 6 casos: receta válida (pico de cobre real), sin costes, id vacío/receta vacía, estación inválida + nivel 0, roundtrip de costes, texto de costes inválido → **suite completa ÉXITO (0 fallos, exit 0)**.

### Verificación
- Suite completa en verde con los scripts de editor en el proyecto (los @tool no se cargan fuera del editor; el núcleo puro sí quedó testeado).
- **¿Verificación visual del dock?** — pendiente: el Editor de Godot está abierto por otro agente (no se reinicia para no pisar su sesión); la captura del layout del dock se hace en la próxima sesión con editor propio → [?] documentado.

## Pendientes con dueño (documentados)

- Verificación visual del dock del editor (dueño: deepseek-v4-flash-vision-exp, próxima sesión con editor propio).
- 13 editores + teleport + profiling restantes: el patrón está listo (EditorBase + schema por dominio) — iteración 2 (dueño: deepseek-v4-flash-vision-exp).

## Archivos Modificados/Creados

- Creados: `scripts/editor/tools/editor_base.gd`, `scripts/editor/tools/recipe_tool.gd`, `scripts/editor/support/recipe_schema.gd`, `scripts/editor/plugin_herramientas.gd`, `tests/unit/editor/test_recipe_schema.gd`
- Modificados: `game/isla-ancestral/project.godot` ([editor_plugins] con el plugin), `DOCUMENTACION/109-Herramientas-Internas/plan-actual/05-Checklist.md` (bloque iter 1), `CHECKLIST-GLOBAL.md` (fila 109 → 🟡 7/127), `Logs/ULTIMO_NUMERO.txt` (→400)
