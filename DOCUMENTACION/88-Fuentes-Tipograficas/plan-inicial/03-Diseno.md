**Modelo:** SWE-1.6
**Plataforma:** Devin

# 03-Diseno.md — Módulo 88: Fuentes Tipográficas

## 1. Arquitectura del módulo

```
Fuentes Tipográficas (assets y configuración de tipografía)
├── Fuentes
│   ├── Nunito (fuente principal)
│   │   ├── Nunito-Regular.ttf
│   │   ├── Nunito-Bold.ttf
│   │   ├── Nunito-Medium.ttf
│   │   └── Nunito-Light.ttf
│   └── Fredoka One (fuente secundaria)
│       └── FredokaOne-Regular.ttf
├── Configuración
│   ├── Theme (Godot Theme)
│   ├── StyleBox (estilos de UI)
│   ├── Tamaños (jerarquía visual)
│   ├── Pesos (Light, Regular, Medium, Bold)
│   ├── Tracking (normal, tight, loose)
│   └── Line Height (1.0, 1.2, 1.4)
└── Optimización
    ├── Subsetting (latín extendido)
    ├── Compresión (WOFF2)
    └── Caching (pre-carga)
```

## 2. Fuentes

**Fuente principal: Nunito**
- Sans-serif, legible, amigable
- Soporta latín extendido, cirílico
- Pesos: Light (300), Regular (400), Medium (500), Bold (700)
- Licencia: SIL Open Font License 1.1
- Fuente: Google Fonts

**Fuente secundaria: Fredoka One**
- Rounded, amigable, perfecta para estilo cozy
- Solo un peso: Bold (700)
- Soporta latín extendido
- Licencia: SIL Open Font License 1.1
- Fuente: Google Fonts

**Ruta de archivos:**
```
assets/fonts/
├── nunito/
│   ├── Nunito-Regular.ttf
│   ├── Nunito-Bold.ttf
│   ├── Nunito-Medium.ttf
│   └── Nunito-Light.ttf
└── fredoka_one/
    └── FredokaOne-Regular.ttf
```

## 3. Configuración en Godot

**Theme (res://ui/theme.tres):**
```gdscript
[resource]
resource_name = "Theme"

default_font = ExtResource("res://assets/fonts/nunito/Nunito-Regular.ttf")
default_font_size = 16

Label/colors/font_color = Color(1, 1, 1, 1)
Label/colors/font_outline_color = Color(0, 0, 0, 1)
Label/constants/outline_size = 1

Button/colors/font_color = Color(1, 1, 1, 1)
Button/colors/font_hover_color = Color(1, 1, 0, 1)
Button/colors/font_pressed_color = Color(0.5, 0.5, 0.5, 1)
```

**StyleBox (res://ui/style_box_bg.tres):**
```gdscript
[resource]
resource_name = "StyleBoxFlat"

bg_color = Color(0.172, 0.172, 0.172, 1)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(1, 1, 1, 1)
corner_radius_top_left = 4
corner_radius_top_right = 4
corner_radius_bottom_left = 4
corner_radius_bottom_right = 4
```

## 4. Tamaños de fuente

**Jerarquía visual:**
```gdscript
# res://ui/font_sizes.gd
class_name FontSizes
extends Resource

const H1 = 32
const H2 = 24
const H3 = 20
const BODY = 16
const SMALL = 12
const MICRO = 10

static func get_size(element: String) -> int:
    match element:
        "H1": return H1
        "H2": return H2
        "H3": return H3
        "BODY": return BODY
        "SMALL": return SMALL
        "MICRO": return MICRO
        _: return BODY
```

## 5. Pesos de fuente

**Pesos:**
```gdscript
# res://ui/font_weights.gd
class_name FontWeights
extends Resource

const LIGHT = 300
const REGULAR = 400
const MEDIUM = 500
const BOLD = 700

static func get_weight(weight: String) -> int:
    match weight:
        "LIGHT": return LIGHT
        "REGULAR": return REGULAR
        "MEDIUM": return MEDIUM
        "BOLD": return BOLD
        _: return REGULAR
```

## 6. Tracking (espaciado entre letras)

**Tracking:**
```gdscript
# res://ui/font_tracking.gd
class_name FontTracking
extends Resource

const NORMAL = 0
const TIGHT = -1
const LOOSE = 1

static func get_tracking(tracking: String) -> int:
    match tracking:
        "NORMAL": return NORMAL
        "TIGHT": return TIGHT
        "LOOSE": return LOOSE
        _: return NORMAL
```

## 7. Line height (altura de línea)

**Line height:**
```gdscript
# res://ui/line_height.gd
class_name LineHeight
extends Resource

const TITLE = 1.0
const BODY = 1.2
const PARAGRAPH = 1.4

static func get_line_height(element: String) -> float:
    match element:
        "TITLE": return TITLE
        "BODY": return BODY
        "PARAGRAPH": return PARAGRAPH
        _: return BODY
```

## 8. Componentes de UI

**Label (res://ui/components/label.gd):**
```gdscript
class_name GameLabel
extends Label

@export var size: String = "BODY"
@export var weight: String = "REGULAR"
@export var tracking: String = "NORMAL"

func _ready():
    add_theme_font_override("font", load("res://assets/fonts/nunito/Nunito-Regular.ttf"))
    add_theme_font_size_override("font_size", FontSizes.get_size(size))
    add_theme_constant_override("outline_size", 1)
    add_theme_color_override("font_outline_color", Color.BLACK)
```

**RichTextLabel (res://ui/components/rich_text_label.gd):**
```gdscript
class_name GameRichTextLabel
extends RichTextLabel

@export var size: String = "BODY"
@export var weight: String = "REGULAR"

func _ready():
    add_theme_font_override("normal_font", load("res://assets/fonts/nunito/Nunito-Regular.ttf"))
    add_theme_font_size_override("normal_font_size", FontSizes.get_size(size))
    add_theme_constant_override("outline_size", 1)
    add_theme_color_override("font_outline_color", Color.BLACK)
```

**Button (res://ui/components/button.gd):**
```gdscript
class_name GameButton
extends Button

@export var size: String = "BODY"
@export var weight: String = "REGULAR"

func _ready():
    add_theme_font_override("font", load("res://assets/fonts/nunito/Nunito-Regular.ttf"))
    add_theme_font_size_override("font_size", FontSizes.get_size(size))
    add_theme_color_override("font_hover_color", Color.YELLOW)
    add_theme_color_override("font_pressed_color", Color.GRAY)
```

## 9. Optimización de fuentes

**Subsetting:**
```gdscript
# tools/font_subsetter.gd
class_name FontSubsetter
extends RefCounted

static func subset_font(input_path: String, output_path: String, characters: String):
    # Usar pyftsubset (herramienta externa) para subsetting
    # pyftsubset input.ttf --text-file=characters.txt --output-file=output.ttf
    pass
```

**Compresión:**
```gdscript
# tools/font_compressor.gd
class_name FontCompressor
extends RefCounted

static func compress_font(input_path: String, output_path: String):
    # Usar woff2_compress (herramienta externa) para compresión
    # woff2_compress input.ttf output.woff2
    pass
```

**Caching:**
```gdscript
# res://ui/font_cache.gd
class_name FontCache
extends Node

var fonts: Dictionary = {}

func _ready():
    preload_fonts()

func preload_fonts():
    fonts["nunito_regular"] = load("res://assets/fonts/nunito/Nunito-Regular.ttf")
    fonts["nunito_bold"] = load("res://assets/fonts/nunito/Nunito-Bold.ttf")
    fonts["nunito_medium"] = load("res://assets/fonts/nunito/Nunito-Medium.ttf")
    fonts["nunito_light"] = load("res://assets/fonts/nunito/Nunito-Light.ttf")
    fonts["fredoka_one"] = load("res://assets/fonts/fredoka_one/FredokaOne-Regular.ttf")

func get_font(name: String) -> Font:
    return fonts.get(name)
```

## 10. Integración con M58 (Accesibilidad)

**Accesibilidad:**
```gdscript
# res://ui/accessibility/font_settings.gd
class_name FontSettings
extends Resource

var font_scale: float = 1.0
var high_contrast: bool = false

func apply_settings(label: Label):
    var base_size = FontSizes.get_size("BODY")
    label.add_theme_font_size_override("font_size", int(base_size * font_scale))
    
    if high_contrast:
        label.add_theme_color_override("font_color", Color.WHITE)
        label.add_theme_color_override("font_outline_color", Color.BLACK)
    else:
        label.add_theme_color_override("font_color", Color.WHITE)
        label.add_theme_color_override("font_outline_color", Color.BLACK)
```

## 11. Integración con M87 (Internacionalización)

**Localización:**
```gdscript
# res://ui/localization/font_loader.gd
class_name FontLoader
extends RefCounted

static func load_font_for_language(language: String) -> Font:
    match language:
        "es", "pt", "fr", "de", "it":
            return load("res://assets/fonts/nunito/Nunito-Regular.ttf")
        "ru", "uk":
            return load("res://assets/fonts/nunito/Nunito-Regular.ttf")  # Nunito soporta cirílico
        "zh", "ja", "ko":
            return load("res://assets/fonts/noto_sans_cjk/NotoSansCJK-Regular.ttf")  # Futuro
        _:
            return load("res://assets/fonts/nunito/Nunito-Regular.ttf")
```

## 12. Integración con M90 (Configuración Gráfica)

**Settings:**
```gdscript
# res://ui/settings/font_settings_menu.gd
class_name FontSettingsMenu
extends Control

@onready var font_scale_slider = $FontScaleSlider
@onready var high_contrast_toggle = $HighContrastToggle

func _ready():
    font_scale_slider.value = FontSettings.font_scale
    high_contrast_toggle.button_pressed = FontSettings.high_contrast

func _on_font_scale_slider_value_changed(value: float):
    FontSettings.font_scale = value
    # Aplicar a todos los labels
    apply_font_scale()

func _on_high_contrast_toggle_toggled(pressed: bool):
    FontSettings.high_contrast = pressed
    # Aplicar a todos los labels
    apply_high_contrast()
```

## 13. Diagrama de flujo

```
[Inicio del juego]
    ↓
[FontCache.preload_fonts()]
    ↓
[Configurar Theme con fuentes]
    ↓
[Configurar StyleBox]
    ↓
[Cargar configuración de accesibilidad (M58)]
    ↓
[Cargar configuración de localización (M87)]
    ↓
[Aplicar ajustes de fuentes]
    ↓
[UI lista con fuentes configuradas]
```

## 14. Pruebas de calidad

**Pruebas manuales:**
- Probar legibilidad en 720p, 1080p, 4K
- Probar soporte de caracteres especiales (tildes, ñ, símbolos)
- Probar localización (español, portugués, francés, alemán, italiano, ruso)
- Probar ajustes de accesibilidad (tamaño, contraste)
- Probar rendimiento (tiempo de carga de fuentes)

**Pruebas automáticas:**
- Tests de carga de fuentes
- Tests de renderizado de caracteres especiales
- Tests de performance (tiempo de carga)
