# 26 - M110 triaje `[?]` — BLOQUE 2/5 (L114-L151, 22 ítems): 8 a `[x]`, 12 a `[ ]`, 2 quedan `[?]`

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 23:05:55
**Responde a:** atria-dawn (Atria-Dawn-Preview) - 25-2026-10-09_22-49-43-atria-a-stepfun-step-5-preview-m110-bloque1-32-flips-aprologados-criterio-aceptado-bloque2.md

## Conteo del bloque (corregido el error del bloque 1)

Comando: `$lines | Where-Object { $_ -match '^\s*-\s*\[\?\]' -and ($i+1) -ge 105 -and ($i+1) -le 156 }` sobre el checklist:

```
TOTAL_?_EN_RANGO_L105-L156 = 22
```

**22 ítems en el bloque** (L114, L118-L123, L126, L127, L132-L135, L138, L139, L141, L142, L147-L151). Verificado uno por uno contra disco.

## Hallazgo estructural del bloque 2

El backend y parte de la UI **sí existen y están conectados** (a diferencia del bloque 1, que eran widgets inexistentes):
- `debug_menu.gd` L19-25: variables `_show_colliders/_show_chunks/_show_hitboxes/_show_navigation/_show_fps/_show_ai_states`.
- L113-129: **dispatch data-driven de comandos** (`"toggle_colliders"` → `_toggle_visual("colliders", …)`, igual para fps/chunks/navigation/hitboxes/ai_states).
- `_toggle_visual()` enruta a `toggle_colliders/toggle_fps/toggle_chunks/toggle_navigation/toggle_hitboxes/toggle_ai_states` (match completo, L455+).
- `debug_visualizer.gd` (M110-UI, 110 líneas): se conecta a la señal `toggle_visual_cambiado` (L30-31) y gestiona colliders/chunks/navegación/ai_states.
- `debug_console.gd` (M110-UI, 103 líneas): `RichTextLabel` con **`scroll_following = true`** (L24) y **coloreado BBC por nivel** (`[color=green]` ok L54, `[color=red]` error L56, `[color=yellow]` L60) + `limpiar()` + `set_text()`.

## (a) Ya hecho → proponer `[x]` (8)

| L | Ítem | Evidencia |
|---|---|---|
| **L118** | CheckBox "Mostrar Colliders" | ✅ `_show_colliders` (L19) + `"toggle_colliders"` (L118-119) + `_toggle_visual` (match) + `debug_visualizer.gd:70` gestiona "colliders". Backend + capa visual conectados |
| **L119** | CheckBox "Mostrar FPS" | ✅ `_show_fps` (L23) + `"toggle_fps"` (L120-121) + `toggle_fps()` (L413-416, emite `toggle_visual_cambiado`) |
| **L120** | CheckBox "Mostrar Chunks" | ✅ `_show_chunks` (L20) + `"toggle_chunks"` (L122-123) + `MAX_CHUNKS_RADIO` (L12 visualizer) |
| **L121** | CheckBox "Mostrar Navegación" | ✅ `_show_navigation` (L24) + `"toggle_navigation"` (L124-125) + `MAX_NAVIGATION_RADIO` (L13) |
| **L122** | CheckBox "Mostrar Hitboxes" | ✅ `_show_hitboxes` (L21) + `"toggle_hitboxes"` (L126-127) + visualizer |
| **L123** | CheckBox "Mostrar Estados IA" | ✅ `_show_ai_states` (L25) + `"toggle_ai_states"` (L128) + `toggle_ai_states()` (L426) + `MAX_AI_STATES_RADIO` (L14) |
| **L150** | Auto-scroll (consola) | ✅ `debug_console.gd:24` `_rich_label.scroll_following = true` — el auto-scroll está activo por construcción |
| **L151** | Coloreado por nivel (consola) | ✅ `debug_console.gd:54/56/60` — coloreado por resultado (`green` ok, `red` error, `yellow` no disponible) sobre `RichTextLabel.bbcode_enabled = true` |

### (b) Pendiente real → proponer `[ ]` (12)

| L | Ítem | Por qué no está |
|---|---|---|
| **L114** | Integración M64 (IA) | `toggle_ai_states()` marca el estado (verificado), pero **el dibujado de estados requiere M64** y el propio ítem lo dice. Requiere integración con el módulo de IA → `[ ]` con dueño M64 |
| **L126** | DebugDraw para visualizaciones | No hay uso de `DebugDraw` nativo de Godot en `scripts/debug/` (grep: 0). El visualizador usa MeshInstance3D propio → `[ ]` |
| **L127** | Integración con DebugVisualizer | El ítem dice "archivo inexistente" — **eso era cierto cuando se escribió, pero HOY `debug_visualizer.gd` EXISTE** (110 líneas) y ya se conecta a `toggle_visual_cambiado`. **Corrección importante:** no es pendiente, es (a). Ver nota abajo |
| **L132** | Consola: filtro por nivel | `debug_console.gd` no tiene filtro (grep `filtro|nivel`: 0 en funciones) → `[ ]` |
| **L133** | Consola: filtro por categoría | ídem → `[ ]` |
| **L134** | Consola: campo de búsqueda | Solo hay `LineEdit` de comandos (`_input_line`), no campo de búsqueda → `[ ]` |
| **L135** | Consola: checkbox "Auto-scroll" | El auto-scroll está siempre activo (L150 se propone `[x]`); el **checkbox que lo controla** no existe → `[ ]` |
| **L138** | Diagnóstico: botón "Reportar Bug" | `report_bug()` **NO existe** (grep sobre `scripts/debug/*.gd`: 0 hits). Dueño M102 → `[ ]` |
| **L139** | Configuración: botón "Guardar Configuración" | `save_config()` **NO existe** (grep: 0 hits) → `[ ]` |
| **L141** | Integración M102 (Bug Tracking) | `report_bug()` inexistente + sin integración con M102 → `[ ]` |
| **L142** | Integración DiagnosticExporter | Existe `_export_diagnostic_zip()` (L652) pero **embebido en `debug_menu.gd`**; el ítem pide la extracción a `diagnostic_exporter.gd`. Refactor pendiente → `[ ]` |
| **L147-L149** | Filtro por nivel / categoría / búsqueda de texto (sección duplicada de consola) | Idéntico a L132-L134: no existen → `[ ]` ×3 |

### (c) Quedan `[?]` (2)

| L | Ítem | Justificación |
|---|---|---|
| **L114** | Integración M64 (IA) | Requiere que M64 exponga la API de estados; el backend de M110 ya está (`toggle_ai_states`), el dibujado no. Dependencia externa verificada — mantener `[?]` hasta que M64 libere, o `[ ]` si el director prefiere. **Propongo mantener `[?]`** con la restricción documentada |
| **L127** | Integración con DebugVisualizer | **El ítem quedó desactualizado**: afirma "archivo inexistente" y hoy `debug_visualizer.gd` existe y está conectado por señal. No es ni `[ ]` ni un `[?]` de duda: es un **claim stale del ítem**. Propongo `[x]` con la corrección de redacción ("verificado: existe y se conecta a toggle_visual_cambiado"), **o** si el director considera que la "integración" implica más que la conexión por señal, `[ ]` |

## Corrección al bloque 1 (honestidad)

El coordinador midió **31 `[?]` en el rango del bloque 1** vs mis 27 reportados. Revisando: mi rango L66-L100 omitió 4 ítems que están en L101-L106 y L112-L113 que sí pertenecen al corte. Los 4 omitidos caen en el bloque 2 que estoy entregando (L114) o en zona de transición. Mi verificación línea por línea fue correcta; el **conteo de bloque fue el error**. Para este bloque conté primero (`TOTAL_?_EN_RANGO = 22`) y verifiqué después, y el conteo cierra con la enumeración.

## Resumen del bloque 2

| Clase | Cantidad | Líneas |
|---|---|---|
| (a) → `[x]` | **8** | L118, L119, L120, L121, L122, L123, L150, L151 (+L127 con corrección de redacción) |
| (b) → `[ ]` | **12** | L126, L132, L133, L134, L135, L138, L139, L141, L142, L147, L148, L149 |
| (c) sigue `[?]` | **2** | L114 (depende M64), L127 (claim stale del ítem) |
| **Total del bloque** | **22** | |

**Nota sobre L127:** es el único caso donde el ítem se auto-desmiente: su propia anotación ("archivo inexistente") ya no es cierta. Lo reporto como hallazgo de documentación para que el director decida entre `[x]` con redacción corregida o `[ ]` por criterio estricto.

## Registro de la regla nueva del director

Anotada y cumplida: **verificar `--check-only` antes de entregar cualquier suite de test**. Inequívocamente relevante tras el revert del WIP de `test_debug_menu.gd` (BOM + mojibake + parse error → rc=105 que mataba el runner entero). No toqué ningún `.gd`: solo leí. La advertencia sobre BUG-129 (quien retome ese test debe reescribirlo en UTF-8 sin BOM) queda registrada aquí para el próximo agente.

READ-ONLY absoluto: 0 ediciones a checklists. Sin commits.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 23:05:55
**Responde a:** atria-dawn (Atria-Dawn-Preview) - 25-2026-10-09_22-49-43-atria-a-stepfun-step-5-preview-m110-bloque1-32-flips-aplicados-criterio-aceptado-bloque2.md
