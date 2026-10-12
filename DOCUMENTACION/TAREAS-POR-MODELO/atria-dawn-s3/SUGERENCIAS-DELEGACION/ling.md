# Ling-3.1-Flash — Sugerencias de delegación

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
**Última actualización:** 2026-10-12 06:35

---

## Estado del agente

- **M83-Licencias CERRADO** por Ling (53/100, 19 flips, 6 funciones nuevas, test 37/0 + regresiones, Log 1730).
- **M87-Localizacion QA ✅** aceptado por el director (msg 87): 5 [?] = deuda legítima, producto correcto.
- **M99-Marketing sello ✅** aplicado (Ling, msg 84).
- **LIBRE AHORA** — su lote M87/M89 anterior está consumido. Necesita tarea NUEVA y LARGA.

## ⭐ NUEVO LOTE PRE-ARMADO: M21-Dialogos, secciones B + C + E (37 items)

**M21-Dialogos** (13/143 = 13 [x] / 123 [ ] / 7 [?]). Fase F4 habilitada. Sin agente.
**Es un módulo HOOK puro** — el núcleo existe y está vivo; los [ ] piden aserciones, no código desde cero. Es exactamente el nicho de Ling (mismo patrón que M83).

### Núcleo verificado en disco (medido este ciclo)

| Archivo | Líneas | API real |
|---|---|---|
| `scripts/dialogos/dialogue_manager.gd` | 304 | `start_dialogue(id, ctx)` `stop_dialogue()` `advance()` `choose_option(i)` `skip_all()` `set_tipeando()` `is_dialogue_active()` `resolve_text()` `get_session_vars()` `get_current_speaker_key()` — **es autoload** (project.godot:24) |
| `scripts/dialogos/dialogue_node.gd` | 98 | `class_name DialogueNode` + `@export` id/tipo/speaker_key/text_key/placeholders/conditions/effects/next_id/goto_id/options + `TIPO_LINEA/OPCIONES/EVENTO/FIN` + `evaluate_conditions()` `apply_effects()` |
| `scripts/dialogos/dialogue_graph.gd` | 87 | `load_from_json(path)` `get_start_node()` `get_node_by_id(id)` `validate()` |
| `scripts/dialogos/dialogue_option.gd` | 74 | `class_name DialogueOption` + `evaluate_conditions()` `apply_effects()` |
| `scripts/dialogos/dialog_graph_validator.gd` | 180 | validación estática (nodos huérfanos + operadores + claves mundo) |
| `scripts/dialogos/contextual_dialogue_manager.gd` | 163 | `seleccionar(npc_id, tipo, ctx)` |
| `scripts/ui/layers/dialog_layer.gd` | 351 | UI completa: typing timer, opciones, traducción, fondo dim |
| `scripts/dialogos/world_state_service.gd` | — | **WorldState es autoload** (project.godot:23) |
| 6 suites vivas | — | `test_dialogos.gd` (152l), `test_clima_dialogo_m21`, `test_eventos_dialogo_m21`, `test_reaccion_m21_dialogo`, `test_localizacion_dialogos`, `test_contextual_dialogue_m162` |

### Sección B — Motor nodo a nodo (13 [ ])

DialogueNode YA tiene id/tipo/speaker_key/text_key/placeholders/next_id/goto_id/options y las 4 constantes TIPO_. DialogueManager YA es autoload con start/stop/advance/choose_option/skip_all. **La mayoría son aserciones sobre API existente:**

- B: tipos de nodo LINEA/OPCIONES/EVENTO/FIN (constantes existen → asertar comportamiento de cada una)
- B: transición lineal via `next_id` y salto directo via `goto_id` (campos existen en DialogueNode)
- B: nodo FIN con cierre limpio (`stop_dialogue` + signal `dialogue_ended`)
- B: nodo EVENTO sin texto visible con efectos (`avance_evento()` existe en el manager)
- B: `start_dialogue` con cache de grafos (`_cargar_grafo` existe)
- B: reentrada segura: dos diálogos nunca activos a la vez (`is_dialogue_active()` existe)
- B: contexto por sesión (`get_session_vars()`, `_combinar_estado()`)
- B: resolución de texto con claves y placeholders (`resolve_text()`, `_es_clave_localizacion()`)
- B: speaker por clave con nombre y retrato (`get_current_speaker_key()` + NpcPortraitUI)

### Sección C — Grafo JSON y validación (12 [ ] + 2 [?])

`DialogueGraph.load_from_json` + `validate()` + `DialogGraphValidator` existen. El gate CI `validate_all_dialogues.gd` ya corre en runtime.

- C: esquema JSON con dialogue_id y start_node_id
- C: `load_from_json` con parsing tolerante
- C: detectar next_id/goto_id apuntando a nodo inexistente
- C: detectar nodo huérfano y grafo sin nodo de inicio
- C: detectar ciclos sin salida (loop de LINEA sin FIN) [M]
- C: validar condiciones con operador fuera de OPERADORES_VALIDOS
- C: validar referencias a variables inexistentes del WorldState (allowlist)
- C: emitir log [VAL-DGT] con conteo de errores y advertencias
- C: fallback amigable al usar un grafo inválido
- C: recarga en caliente del grafo en el editor (tool) [M]
- 2 [?] ya diagnosticados por el autor: JSON.parse_string no expone línea/columna; IDs duplicados colapsan en Dictionary — **no forzar [x], mantener [?] con justificación**

### Sección E — Opciones y ramificación (8 [ ] + 2 [?])

`DialogueOption` (class_name + evaluate_conditions + apply_effects) y `choose_option()` existen.

- E: DialogueOption con text_key, next_id, conditions y effects (la clase existe → asertar)
- E: ocultar opciones bloqueadas cuando `hide_blocked` es true
- E: mostrar opciones bloqueadas con texto alternativo y visual gris
- E: navegar opciones con gamepad (dpad + botón A)
- E: seleccionar opciones con mouse (hover y click) — DialogLayer tiene `_on_opt_pressed(idx)`
- E: aplicar los effects de la opción elegida una sola vez
- E: soportar ramas de más de un nivel de profundidad
- E: perder la rama elegida en el historial de sesión para retornos [M]
- 2 [?] (filtrado por condiciones, navegación teclado) — Ling que decida si son HOOK o deuda real

### Fuera del lote (dependencias externas)

- D (UI): DialogLayer ya tiene typing — son polish visual, mejor tras F6
- F: WorldState existe como autoload; las condiciones M22/M23/M73/M19 dependen de esos módulos
- G: integración M19/M64/M25 — dueños externos
- H/I/J/K/L: robustez, optimización, docs, polish, QA — seguimiento natural post-lote

## Encargo listo para reenviar

> **Encargo: M21-Dialogos, lote secciones B + C + E (37 items: 33 [ ] + 4 [?]).** Lee
> `DOCUMENTACION/21-Dialogos/plan-actual/05-Checklist.md` secciones B, C y E. **El núcleo YA
> existe y es autoload**: `scripts/dialogos/dialogue_manager.gd` (304 l., start/stop/advance/
> choose_option/skip_all/resolve_text), `dialogue_node.gd` (DialogueNode con id/tipo/speaker_key/
> text_key/placeholders/conditions/effects/next_id/goto_id/options + TIPO_LINEA/OPCIONES/EVENTO/
> FIN), `dialogue_graph.gd` (load_from_json/get_start_node/get_node_by_id/validate),
> `dialogue_option.gd`, `dialog_graph_validator.gd`, `dialog_layer.gd` (351 l.), y
> `world_state_service.gd` (autoload WorldState). **Amplía con aserciones, no recrees.** Hay 6
> suites vivas en `scripts/dialogos/` — tu suite nueva no debe romperlas (regresión). Test
> headless con `C:\Temp\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path
> game/isla-ancestral -s res://tests/<suite>.gd`. Los 2 [?] de C (JSON sin línea/columna, IDs
> duplicados colapsan en Dictionary) y los 2 [?] de E: tú decides si son HOOK cerrables o deuda
> legítima — justifica en `## Notas del Agente`. No toques CHECKLIST-GLOBAL, no commit, UTF-8.
> Reporta en tu canal.

## Addendum opcional (barato, diagnóstico propio de Ling)

Ling encontró en su QA de M87 (msg 86) que **2 suites están en rojo** por estado persistido:
`test_localizacion_iter6.gd` (I9) y `test_ui_i18n_m53.gd` (D/E). Root cause:
`user://isla-ancestral/config.cfg` tiene `idioma="en"` persistido; los tests asumen locale
inicial "es". **El producto es correcto** — es deuda de tests. Fix: forzar `set_locale("es")`
antes de capturar `original`/`ini_locale`, o no persistir locale en contexto de test. Si el
director quiere, Ling puede cerrarlo en la misma sesión (son 2 tests, 30 min) y registrar en
`DOCUMENTACION/11-BUGS.md`. **No es bloqueante para el lote M21.**

---

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code


## Cola de 12 tareas entregada al director (msg 223) — estado

| # | Módulo | Items | Estado (2026-10-12 08:10) |
|---|---|---|---|
| L1 | M21-Dialogos B+C+E | 96+7 | 🔵 asignado por director (msg 94) — iba 40/143 |
| L2 | M92-Tutorial | 87 [ ] | 🔵 asignado por director (msg 224/102) — EN CURSO |
| ~~L3~~ | ~~M58-Accesibilidad~~ | ~~33 [ ]~~ | ❌ **CANCELADO 2026-10-12** (colisión: trabajo sin commitear de Step 5, s2 reasignado a M49 por director msg 311). Reemplazo sugerido: **M145-Diseno-De-Experiencia (87/105)** |
| L4 | M112-Testing-Automatico | 8 [ ]+12 [?] | pendiente |
| L5 | M94-Retencion-Sin-FOMO | 51 [?] | pendiente (Patrón D, director sella) |
| L6 | M87 2 tests rojos | 2 | pendiente (mecánico → Step 5) |
| L7 | M124-UGC | 25 [?] | pendiente |
| L8 | M88-Fuentes | 11 [?] | pendiente |
| L9 | M107-Backups | 9 [?] | pendiente |
| L10 | M123-Modding | 2 [?] | pendiente |
| L11 | M66-Anti-Softlock | 7 [?] | pendiente |
| L12 | M100 re-QA | — | opcional post-agnes (Ling cerró M100: 12/13 artefactos, msg 100) |

**Lección de coordinación (M58):** incluí M58 en la lista de Ling SIN verificar git status del
módulo. Step 5 tenía 269 insertiones sin commitear. **Protocolo nuevo:** antes de poner un módulo en
una lista, verificar que no tenga trabajo sin commitear (git status game/isla-ancestral/scripts/<...>
+ mtime reciente de plan-actual/).