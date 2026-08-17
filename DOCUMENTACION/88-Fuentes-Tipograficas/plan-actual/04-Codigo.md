**Modelo:** SWE-1.6
**Plataforma:** Devin

# 04-Codigo.md — Módulo 88: Fuentes Tipográficas

## 1. Carácter del Componente

Módulo de **fuentes tipográficas** que define assets de fuentes, configuración de tipografía en Godot y optimización de archivos de fuente. Implementable inmediatamente (depende de M58 para accesibilidad, M87 para internacionalización, M90 para configuración gráfica). Es un módulo de assets y configuración.

**06-Plan-Testings.md:** APLICA (sistema de UI con localización y accesibilidad, requiere testing de legibilidad, soporte de caracteres, localización, ajustes de accesibilidad).

## 2. Archivos involucrados (implementación)

```
assets/fonts/
├── nunito/
│   ├── Nunito-Regular.ttf
│   ├── Nunito-Bold.ttf
│   ├── Nunito-Medium.ttf
│   └── Nunito-Light.ttf
└── fredoka_one/
    └── FredokaOne-Regular.ttf

res://ui/
├── theme.tres                              → Theme de Godot
├── style_box_bg.tres                        → StyleBox de fondo
├── font_sizes.gd                            → Tamaños de fuente
├── font_weights.gd                          → Pesos de fuente
├── font_tracking.gd                         → Tracking de fuente
├── line_height.gd                           → Line height
├── components/
│   ├── label.gd                              → GameLabel
│   ├── rich_text_label.gd                    → GameRichTextLabel
│   └── button.gd                            → GameButton
├── font_cache.gd                            → FontCache
├── accessibility/
│   └── font_settings.gd                     → FontSettings
├── localization/
│   └── font_loader.gd                       → FontLoader
└── settings/
    └── font_settings_menu.gd                → FontSettingsMenu

tools/
├── font_subsetter.gd                        → FontSubsetter (subsetting)
└── font_compressor.gd                       → FontCompressor (compresión)

06-Plan-Testings.md                           → Plan de testings (APLICA)
07-Resultados-Testings.md                      → Resultados de testings (APLICA)
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M57 (UI):** Estilos de UI basados en fuentes (Theme, StyleBox, Label, RichTextLabel, Button)
- **M13 (Herramientas):** Nombres de herramientas y descripciones con fuentes
- **M16 (Crafting):** Nombres de items y recetas con fuentes
- **M19 (NPC):** Nombres de NPCs y diálogos con fuentes
- **M22 (Misiones):** Títulos y descripciones de misiones con fuentes

### Entrada (desde otros módulos)
- **M58 (Accesibilidad):** Ajustes de tamaño de fuente y contraste
- **M87 (Internacionalización):** Carga de fuente según idioma
- **M90 (Configuración Gráfica):** Settings de fuentes (tamaño, contraste)

### Configuración
- `res://ui/theme.tres` define Theme de Godot con fuentes
- `res://ui/font_sizes.gd` define tamaños de fuente
- `res://ui/font_weights.gd` define pesos de fuente
- `res://ui/font_tracking.gd` define tracking
- `res://ui/line_height.gd` define line height

## 4. Implementación de theme.tres (esqueleto)

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

RichTextLabel/colors/default_color = Color(1, 1, 1, 1)
RichTextLabel/colors/font_outline_color = Color(0, 0, 0, 1)
RichTextLabel/constants/outline_size = 1
```

## 5. Implementación de font_sizes.gd (esqueleto)

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

## 6. Implementación de font_weights.gd (esqueleto)

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

## 7. Implementación de font_tracking.gd (esqueleto)

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

## 8. Implementación de line_height.gd (esqueleto)

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

## 9. Implementación de GameLabel (esqueleto)

```gdscript
# res://ui/components/label.gd
class_name GameLabel
extends Label

@export var size: String = "BODY"
@export var weight: String = "REGULAR"
@export var tracking: String = "NORMAL"

func _ready():
    var font_path = "res://assets/fonts/nunito/Nunito-%s.ttf" % weight.capitalize()
    add_theme_font_override("font", load(font_path))
    add_theme_font_size_override("font_size", FontSizes.get_size(size))
    add_theme_constant_override("outline_size", 1)
    add_theme_color_override("font_outline_color", Color.BLACK)
```

## 10. Implementación de GameRichTextLabel (esqueleto)

```gdscript
# res://ui/components/rich_text_label.gd
class_name GameRichTextLabel
extends RichTextLabel

@export var size: String = "BODY"
@export var weight: String = "REGULAR"

func _ready():
    var font_path = "res://assets/fonts/nunito/Nunito-%s.ttf" % weight.capitalize()
    add_theme_font_override("normal_font", load(font_path))
    add_theme_font_size_override("normal_font_size", FontSizes.get_size(size))
    add_theme_constant_override("outline_size", 1)
    add_theme_color_override("font_outline_color", Color.BLACK)
```

## 11. Implementación de GameButton (esqueleto)

```gdscript
# res://ui/components/button.gd
class_name GameButton
extends Button

@export var size: String = "BODY"
@export var weight: String = "REGULAR"

func _ready():
    var font_path = "res://assets/fonts/nunito/Nunito-%s.ttf" % weight.capitalize()
    add_theme_font_override("font", load(font_path))
    add_theme_font_size_override("font_size", FontSizes.get_size(size))
    add_theme_color_override("font_hover_color", Color.YELLOW)
    add_theme_color_override("font_pressed_color", Color.GRAY)
```

## 12. Implementación de FontCache (esqueleto)

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

## 13. Implementación de FontSettings (esqueleto)

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

## 14. Implementación de FontLoader (esqueleto)

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

## 15. Implementación de FontSettingsMenu (esqueleto)

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
    apply_font_scale()

func _on_high_contrast_toggle_toggled(pressed: bool):
    FontSettings.high_contrast = pressed
    apply_high_contrast()

func apply_font_scale():
    # Aplicar a todos los labels
    var labels = get_tree().get_nodes_in_group("ui_labels")
    for label in labels:
        FontSettings.apply_settings(label)

func apply_high_contrast():
    # Aplicar a todos los labels
    var labels = get_tree().get_nodes_in_group("ui_labels")
    for label in labels:
        FontSettings.apply_settings(label)
```

## 16. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Descargar Nunito de Google Fonts | **IMPLEMENTACIÓN INMEDIATA** |
| Descargar Fredoka One de Google Fonts | **IMPLEMENTACIÓN INMEDIATA** |
| Crear assets/fonts/nunito/ con archivos .ttf | **IMPLEMENTACIÓN INMEDIATA** |
| Crear assets/fonts/fredoka_one/ con archivo .ttf | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/theme.tres | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/style_box_bg.tres | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/font_sizes.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/font_weights.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/font_tracking.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/line_height.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/components/label.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/components/rich_text_label.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/components/button.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/font_cache.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/accessibility/font_settings.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/localization/font_loader.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/settings/font_settings_menu.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Implementar subsetting de fuentes (pyftsubset) | **IMPLEMENTACIÓN INMEDIATA** |
| Implementar compresión de fuentes (woff2_compress) | **IMPLEMENTACIÓN INMEDIATA** |
| Crear 06-Plan-Testings.md | **IMPLEMENTACIÓN INMEDIATA** |
| Ejecutar 07-Resultados-Testings.md | **M58 (Accesibilidad) / M87 (Internacionalización)** |

## 17. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** Devin
**Fecha:** 2026-08-16 23:30:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Resolví los 17 puntos de la sección 87 del plan maestro.
- Seleccioné Nunito como fuente principal (sans-serif, legible, amigable, soporta cirílico, SIL Open Font License 1.1).
- Seleccioné Fredoka One como fuente secundaria (rounded, amigable, perfecta para estilo cozy, SIL Open Font License 1.1).
- Revisé licencias (SIL Open Font License 1.1: uso comercial, modificación, distribución, sublicencia, con atribución).
- Revisé caracteres especiales (tildes, ñ, símbolos, cirílico).
- Definí tamaños de fuente (H1 32px, H2 24px, H3 20px, BODY 16px, SMALL 12px, MICRO 10px).
- Definí pesos de fuente (Light 300, Regular 400, Medium 500, Bold 700).
- Definí tracking (normal 0, tight -1, loose 1).
- Definí line height (título 1.0, cuerpo 1.2, párrafo 1.4).
- Creé jerarquía visual (H1 > H2 > H3 > cuerpo > pequeño > micro).
- Diseñé estilos de UI en Godot (Theme, StyleBox, Label, RichTextLabel, Button).
- Diseñé optimización de archivos de fuente (subsetting, compresión WOFF2, caching).
- Diseñé integración con M58 (Accesibilidad) para ajustes de tamaño y contraste.
- Diseñé integración con M87 (Internacionalización) para carga de fuente según idioma.
- Diseñé integración con M90 (Configuración Gráfica) para settings de fuentes.
- Diseñé componentes de UI (GameLabel, GameRichTextLabel, GameButton).
- Diseñé FontCache para pre-carga de fuentes.
- Diseñó FontSettings para accesibilidad.
- Diseñé FontLoader para localización.
- Diseñé FontSettingsMenu para settings de fuentes.

### Lo que NO pude hacer (honestidad obligatoria)
- Descargar fuentes de Google Fonts — requiere implementación real.
- Crear archivos .ttf en assets/fonts/ — requiere implementación real.
- Crear archivos .tres de Godot — requiere implementación real.
- Implementar subsetting de fuentes (pyftsubset) — requiere herramientas externas.
- Implementar compresión de fuentes (woff2_compress) — requiere herramientas externas.
- Ejecutar tests de legibilidad y localización — requiere código real para testear.

### Recomendaciones para el próximo agente (implementador)
- Descargar Nunito y Fredoka One de Google Fonts inmediatamente.
- Crear carpeta assets/fonts/nunito/ y assets/fonts/fredoka_one/.
- Crear theme.tres en Godot Editor con fuentes configuradas.
- Crear style_box_bg.tres para estilos de UI.
- Implementar font_sizes.gd, font_weights.gd, font_tracking.gd, line_height.gd.
- Implementar GameLabel, GameRichTextLabel, GameButton.
- Implementar FontCache para pre-carga de fuentes.
- Implementar FontSettings para accesibilidad (tamaño, contraste).
- Implementar FontLoader para localización (carga de fuente según idioma).
- Implementar FontSettingsMenu en settings (M90).
- Implementar subsetting de fuentes con pyftsubset para reducir tamaño.
- Implementar compresión de fuentes con woff2_compress para optimizar carga.
- Probar legibilidad en diferentes resoluciones (720p, 1080p, 4K).
- Probar soporte de caracteres especiales (tildes, ñ, símbolos).
- Probar localización (español, portugués, francés, alemán, italiano, ruso).
- Atribuir fuentes en créditos (M131).
