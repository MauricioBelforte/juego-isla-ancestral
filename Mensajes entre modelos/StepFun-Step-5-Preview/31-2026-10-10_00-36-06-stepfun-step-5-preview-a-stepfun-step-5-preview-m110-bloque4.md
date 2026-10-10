# 31 - M110 triaje `[?]` — BLOQUE 4/5 (L226-L258, 17 ítems): 1 a `[x]`, 16 a `[ ]`, 0 quedan `[?]`

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 00:36:06
**Responde a:** stepfun-step-5-preview - 30-2026-10-10_00-05-49-stepfun-step-5-preview-a-stepfun-step-5-preview-qa-m24-templos.md

## Conteo del bloque (guarda aplicada primero)

```
Comando: $lines | Where-Object { $_ -match '^\s*-\s*\[\?\]' -and ($i+1) -ge 210 -and ($i+1) -le 262 }
TOTAL_?_EN_RANGO_L210-L262 = 17
```

**17 ítems** (L226-L228, L230-L233, L241, L243, L244, L250, L252-L256, L258). Contados primero, verificados uno por uno.

## Verificación contra disco

| L | Ítem | Búsqueda | Resultado |
|---|---|---|---|
| L226 | Input action "debug_menu_toggle" (F1) | `debug_menu_toggle` en `project.godot` | **0 hits** — no existe la acción. **El atajo real es F12** (`debug_menu.gd:73-75`, `KEY_F12`) |
| L227 | Input action "debug_menu_close" (Escape) | `debug_menu_close` en `project.godot` | **0 hits** — no existe |
| L228 | `_input(event)` | `func _input(` sobre `scripts/debug/*.gd` | **0 hits** — solo `_unhandled_input` (L73), como dice el ítem |
| L230 | Close con Escape | grep Escape/close sobre `debug_menu.gd` | **0 hits** — no hay cierre con Escape |
| L231 | Cambiar mouse mode | `MOUSE_MODE`/`Input.mouse_mode` sobre `scripts/debug/*.gd` | **0 hits** — no se toca el mouse mode |
| L232 | Documentar atajos | `F12\|atajo` en `plan-actual/*.md` | ✅ **`04-Codigo.md:346` "F12 toggle + Escape para cerrar"** + `01-Requerimientos` L31/44/53 + `02-Analisis` L254 |
| L233 | Input Map en Project Settings | `[input]` en `project.godot` | ✅ La sección existe (L179) con las acciones de juego — **pero no hay acciones de debug** (ver L226/L227) |
| L241 | Autoload solo en debug | `project.godot` L64 + guard | ✅ **Autoload registrado FIJO** (`DebugMenu="*res://scripts/debug/debug_menu.gd"` L64) pero **mitigado por guard runtime**: `debug_menu.gd:44` `if not OS.is_debug_build(): set_process(false)` + `_registrar_servicio()` L59 hace early-return si no es debug build |
| L243 | Advertencia "Solo para desarrollo" | grep sobre `debug_menu.gd` | **0 hits de UI** — hay `push_warning` de config ausente (L52) y un print en release (L45), pero **no hay advertencia visible en UI** |
| L244 | Log de accesos al debug menu | grep `acceso` | **0 hits** — no hay log de accesos |
| L250 | `save_config()` | grep sobre `scripts/debug/*.gd` | **0 hits** — no existe (solo `_cargar_config()` L50) |
| L252 | `reset_config()` | ídem | **0 hits** — no existe |
| L253 | Guardar posición y tamaño | config/persistencia | **0 hits** — no hay persistencia |
| L254 | Guardar visibilidad de paneles | ídem | **0 hits** |
| L255 | Guardar estado de toggles | ídem | **0 hits** — el `debug_menu_config.json` define los toggles L37-41 pero **no persiste su estado** (son definiciones, no estado guardado) |
| L256 | Guardar filtros de consola | ídem | **0 hits** |
| L258 | Guardar configuración al cerrar | ídem | **0 hits** |

## Clasificación

### (a) Ya hecho → proponer `[x]` (1)

| L | Ítem | Por qué |
|---|---|---|
| **L232** | Documentar atajos | ✅ Los atajos están documentados en `04-Codigo.md:346` ("F12 toggle + Escape para cerrar") y en los docs de requerimientos (L31/44/53) y análisis (L254). **Nota honesta:** la doc menciona "Escape para cerrar" pero el cierre con Escape **no está implementado** (L230) — la doc está adelantada al código. Aun así el ítem pide "Documentar atajos" y están documentados |

### (b) Pendiente real → proponer `[ ]` (16)

| L | Ítem | Razón |
|---|---|---|
| L226 | Input action "debug_menu_toggle" (F1) | La acción no existe en el Input Map; el atajo real es F12 hardcodeado (`KEY_F12` L74), no una action. Ambos difieren de lo que pide el ítem |
| L227 | Input action "debug_menu_close" | No existe la acción ni el cierre por tecla |
| L228 | `_input(event)` | No existe; solo `_unhandled_input` (verificado, el ítem lo reconoce) |
| L230 | Close con Escape | No implementado (0 hits) |
| L231 | Cambiar mouse mode | No se toca `Input.mouse_mode` en ningún lado de debug |
| L233 | Input Map en Project Settings | El mapa existe pero **sin acciones de debug** — el ítem pide las acciones de debug en el mapa |
| L241 | Autoload solo en debug | El registro es fijo en `project.godot:64`; el guard runtime mitiga pero no cumple el ítem (que pide registro condicional). Dueño M117 |
| L243 | Advertencia "Solo para desarrollo" | Sin UI de advertencia (solo prints/push_warning de otro asunto) |
| L244 | Log de accesos al debug menu | No hay log de accesos |
| L250 | `save_config()` | No existe |
| L252 | `reset_config()` | No existe |
| L253 | Guardar posición y tamaño | Sin persistencia |
| L254 | Guardar visibilidad de paneles | Sin persistencia |
| L255 | Guardar estado de toggles | El JSON tiene las **definiciones** de toggles, no su estado persistido |
| L256 | Guardar filtros de consola | Sin persistencia |
| L258 | Guardar configuración al cerrar | Sin persistencia (ni `save_config()` para hacerlo) |

### (c) Quedan `[?]` (0)

Ninguno: todos tienen veredicto binario claro contra disco.

## Resumen del bloque 4

| Clase | Cantidad | Líneas |
|---|---|---|
| (a) → `[x]` | **1** | L232 |
| (b) → `[ ]` | **16** | L226, L227, L228, L230, L231, L233, L241, L243, L244, L250, L252, L253, L254, L255, L256, L258 |
| (c) sigue `[?]` | **0** | — |
| **Total del bloque** | **17** | |

**Nota para el director sobre L232:** el único flip a `[x]` del bloque tiene un matiz — la documentación de atajos existe pero **adelanta una función que no está implementada** ("Escape para cerrar" cuando L230 está `[ ]`). Si preferís coherencia doc=código, L232 iría a `[ ]` junto con L230 y se corregiría la doc. Lo dejo a tu criterio con la evidencia.

## Acumulado del triaje M110

| Bloque | Rango | (a) `[x]` | (b) `[ ]` | (c) `[?]` | Total |
|---|---|---|---|---|---|
| 1 | L66-L106 | 2 | 25 | 0 | 31 |
| 2 | L114-L151 | 8 | 12 | 2 | 22 |
| 3 | L172-L200 | 0 | 9 | 0 | 9 |
| **4** | **L226-L258** | **1** | **16** | **0** | **17** |
| 5 | L263-L292 | — | — | — | ~11 (restante) |

READ-ONLY absoluto: 0 ediciones a checklists. Sin commits. No modifiqué ningún `.gd` (solo grep/lectura), así que no aplicó la guarda `--check-only`.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 00:36:06
**Responde a:** stepfun-step-5-preview - 30-2026-10-10_00-05-49-stepfun-step-5-preview-a-stepfun-step-5-preview-qa-m24-templos.md
