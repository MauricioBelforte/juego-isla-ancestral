# UI, HUD y CanvasLayer — Errores Comunes

> **Modelo:** GPT-5.6 Luna
> **Plataforma:** Copilot SDK en VS Code
> **Última actualización:** 2026-10-31
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §9.26/9.27/9.33/9.39/9.46/9.47/9.49/9.51 + §26.29
> **Validado en:** Isla Ancestral — Godot 4.7.2

---

## 1. Función no encontrada en CanvasLayer

**Error:**
```
SCRIPT ERROR: Could not find function "X" in base 'CanvasLayer'.
```

**Causa:** CanvasLayer no tiene `show()`, `hide()`, `get_visible()`, etc.

```gdscript
# ❌ CanvasLayer no tiene show()
canvas_layer.show()

# ✅ Usar los métodos correctos de CanvasLayer
canvas_layer.visible = true
```

---

## 2. No redefinir show() en CanvasLayer (§9.39)

**Error:** `The function signature doesn't match the parent.`

```gdscript
# ❌ Incorrecto — CanvasLayer ya tiene show()
func show(text: String, at: Control) -> void:
    pass

# ✅ Correcto — nombre específico
func show_tooltip(text: String, at: Control) -> void:
    pass
```

---

## 3. Verificar widget ANTES de agregar (§9.47)

**REGLA OBLIGATORIA:** Antes de agregar CUALQUIER widget de UI, verificar que no exista en otro script.

```gdscript
# ANTES de crear el widget, buscar en el proyecto:
# 1. Buscar scripts que creen el mismo widget
grep -r "class_name.*Widget" scripts/ui/
# 2. Buscar instancias en escenas
grep -r "Widget" scenes/ui/

# DESPUÉS de verificar, crear el widget
var widget = MyWidget.new()
add_child(widget)
```

**Error común:** Dos scripts crean el mismo widget, causando duplicados en runtime.

---

## 4. Object.has() no existe en Godot 4 (§9.49)

```gdscript
# ❌ Incorrecto
if op.has_method("get") and op.has("text_key"): ...

# ✅ Correcto — operador `in`
if "text_key" in op:
    var clave: String = str(op.text_key)
```

---

## 5. Autoload en _unhandled_input() (§9.51)

```gdscript
# ❌ Identificador global — falla en --script
func _ready() -> void:
    GameTime.hora_cambio.connect(_on_hora_cambio)

# ✅ Correcto — path canónico
var _gt = null
func _ready() -> void:
    _gt = get_node_or_null("/root/GameTime")
    if _gt != null and _gt.has_signal("hora_cambio"):
        _gt.hora_cambio.connect(_on_hora_cambio)
```

---

## 6. Carga de fuentes en runtime (§9.48)

**REGLA OBLIGATORIA:** SIEMPRE usar `FontFile.new()` + `load_dynamic_font(path)` para fuentes en runtime.

```gdscript
# ❌ Incorrecto — no funciona en Godot 4
var font = load("res://fonts/MainFont.ttf")  # FontData, no Font

# ✅ Correcto
var font_file := FontFile.new()
font_file.load_dynamic_font("res://fonts/MainFont.ttf")
label.add_theme_font_override("font", font_file)
```

---

## 7. show() vs visible = true (§9.33)

```gdscript
# ❌ show() no existe en CanvasLayer
canvas_layer.show()

# ✅ Usar visible
canvas_layer.visible = true
```

---

## 8. Tooltip duplicado (§9.46)

**Problema:** Múltiples instancias del mismo tooltip aparecen en pantalla.

**Solución:** Verificar que no se esté creando múltiples veces:
```gdscript
# Antes de crear, verificar si ya existe
if tooltip != null and is_instance_valid(tooltip):
    tooltip.queue_free()

tooltip = Tooltip.new()
add_child(tooltip)
```

---

## 9. CanvasLayer oculta elementos de gameplay (§9.33)

**Problema:** Los elementos de UI ocultan objetos de gameplay porque están en el mismo CanvasLayer.

**Solución:** Usar layers diferentes:
- Layer 1: Gameplay (HUD)
- Layer 2: Menús
- Layer 3: Tooltips
- Layer 4: Overlays

```gdscript
# En el CanvasLayer
canvas_layer.layer = 2  # Menús sobre gameplay
```

---

## 10. El widget HUD solo lee de autoloads, no muta gameplay (§26.29)

**REGLA DE ORO:** Los widgets del HUD solo LEEN datos de los autoloads. NUNCA modifican el estado de gameplay.

```gdscript
# ❌ Incorrecto — widget modifica gameplay
func _on_button_pressed():
    PlayerStats.health -= 10  # NO permitido

# ✅ Correcto — widget solo lee
func _process(delta):
    var health = PlayerStats.health  # Solo lectura
    _health_bar.value = health
```

---

## 11. Error de parse en UI frena boot completo (§9.60)

**Error:** `SCRIPT ERROR: Parse Error: Used space character for indentation.`

**Impacto:** Un solo error de parse en un script de UI frena el boot completo del juego.

**Solución:** Verificar indentación (tabs, no espacios) en TODOS los scripts de UI.

---

## 12. CanvasLayer.visible no existe (§9.39)

```gdscript
# ❌ Error
canvas_layer.visible  # No existe

# ✅ Correcto
canvas_layer.get_visible()  # Método heredado de Node
```

---

## Referencia rápida de CanvasLayer

| Propiedad/Método | Descripción |
|---|---|
| `.layer` | Capa de renderizado (1-128) |
| `.visible` | Mostrar/ocultar (heredado de Node) |
| `.offset` | Offset de posición |
| `.transform` | Transformación del canvas |
| `.get_visible()` | Obtener estado de visibilidad |
| `.show()` | Mostrar (heredado de Node, NO redefinir) |
| `.hide()` | Ocultar (heredado de Node, NO redefinir) |

---

## 13. Navegación con foco y botones deshabilitados — M53/M89 (2026-10-31)

**Observación reproducida:** en la pausa, `Guardar` aparece deshabilitado cuando la partida
no tiene cambios (`game/isla-ancestral/scripts/ui/layers/pause_layer.gd:L80-L84`). La navegación
se trababa al contar ese botón en el conjunto de candidatos. El filtro vigente centraliza el
criterio en `MenuNavigator._can_receive_focus()` y rechaza `BaseButton.disabled`
(`game/isla-ancestral/scripts/ui/core/menu_navigator.gd:L134-L138`), y M89 comprueba que el botón
deshabilitado no entra en los candidatos y el siguiente habilitado sí
(`game/isla-ancestral/scripts/ui/test_m89_menus.gd:L205-L209`).

**Resultado medido en este proyecto:** `test_m89_menus.gd` terminó con 58 comprobaciones y 0
fallos; `test_m53_pausa_prompts.gd`, con 39 y 0 (`DOCUMENTACION/53-UI-UX/plan-actual/07-Resultados-Testings.md:L17-L18`).
La señal `continuar_pedido` de PauseLayer llega a UIManager y `_on_pausa_continuar()` cierra la capa
y reanuda el mundo (`game/isla-ancestral/scripts/ui/core/ui_manager.gd:L203-L209,L551-L559`).
M53 también activa `pressed` en el botón Continuar y verifica que PauseLayer se oculta, el árbol
reanuda y la capa sale de la pila (`game/isla-ancestral/scripts/ui/test_m53_pausa_prompts.gd:L148-L158`).

**Límite observado:** esto verifica «Continuar» desde la pausa. El «Continuar» del menú principal
sin PauseLayer solo cambia el estado a `CARGANDO`; en esa rama no se encontró llamada a
`SceneManager` ni `SaveManager` (`game/isla-ancestral/scripts/ui/ui_root.gd:L206-L223`;
`DOCUMENTACION/53-UI-UX/plan-actual/07-Resultados-Testings.md:L26`). No usar el test de pausa
como evidencia de que se carga una partida guardada desde el menú principal.

**Evidencia visual:** la captura de la pausa registra Guardar atenuado y el foco en «Borrar slot 1»;
la captura posterior registra el mundo reanudado
(`tools/mcp/godot-mcp/capturas/53-UI-UX/cap_53_2026-10-31_20-39-08_gpt-luna_pausa-salta-guardar.png`;
`tools/mcp/godot-mcp/capturas/167-Isla-Raiz/cap_167_2026-10-31_20-39-56_gpt-luna_continuar-reanuda.png`).
La observación de que el texto de controles del mundo trasluce por la pausa también quedó registrada;
no se cambió ese diseño (`DOCUMENTACION/TAREAS-POR-MODELO/GPT-Luna/RIEL-S2-VISION-RUNTIME.md:L43-L47`).

Este caso no valida todos los menús, entradas o dispositivos: la evidencia se limita a estas dos
suites y a las capturas indicadas.
