**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 58: Accesibilidad

> Todos los archivos listados están **Pendiente de implementación** (documentación en estado inicial; el módulo queda delegable para su implementación).

## 1. Archivos previstos

| Ruta prevista | Propósito | Estado |
|---|---|---|
| `res://accesibilidad/autoload/settings_manager.gd` | Autoload global: carga/guarda/valida el perfil, emite señales | Pendiente de implementación |
| `res://accesibilidad/profiles/accessibility_profile.gd` | Resource serializable con todos los campos de accesibilidad y presets | Pendiente de implementación |
| `res://accesibilidad/profiles/accessibility_defaults.gd` | Valores por defecto versionados (migraciones futuras) | Pendiente de implementación |
| `res://accesibilidad/services/accessibility_applier.gd` | Aplica el perfil a UI, cámara, audio, input y gráficos | Pendiente de implementación |
| `res://accesibilidad/visual/color_filter.gdshader` | Shader passthrough: filtros de daltonismo, contraste, brillo, saturación | Pendiente de implementación |
| `res://accesibilidad/visual/color_filter.gd` | Gestiona el CanvasLayer del filtro y el fallback `modulate` | Pendiente de implementación |
| `res://accesibilidad/visual/interactable_outlines.gd` | Realza contornos de interactuables en el mundo (lee M08/M10) | Pendiente de implementación |
| `res://accesibilidad/motion/motion_reducer.gd` | Factor anti-mareo: consume amplitudes de shake/parallax de M12 | Pendiente de implementación |
| `res://accesibilidad/input/action_mode_helper.gd` | Convierte acciones hold↔toggle consultando el perfil | Pendiente de implementación |
| `res://accesibilidad/input/aim_assist.gd` | Magnetismo suave de puntería (0–100 %), integra M34/M35/combate | Pendiente de implementación |
| `res://accesibilidad/input/input_presets.gd` | Presets `single_hand` / `low_mobility` aplicados sobre M57 | Pendiente de implementación |
| `res://accesibilidad/cognitive/difficulty_provider.gd` | Expone `serene_combat`, `extended_timers`, `guidance_level` a los sistemas | Pendiente de implementación |
| `res://accesibilidad/audio/audio_indicator.gd` | Rizos/anillos visuales ante eventos de sonido no visibles (integra M91/M43) | Pendiente de implementación |
| `res://accesibilidad/audio/visual_alert_card.gd` | Carteles visuales de estado (baja vida, tormenta) | Pendiente de implementación |
| `res://accesibilidad/text/reading_settings.gd` | Aplica espaciado/line-height/tamaño sobre el theme de M88 | Pendiente de implementación |
| `res://accesibilidad/ui/accessibility_menu.gd` | Vista del menú en M53 (sin lógica de gameplay) | Pendiente de implementación |
| `res://accesibilidad/ui/accessibility_preview.gd` | Escena de preview en vivo de cada opción | Pendiente de implementación |
| `res://accesibilidad/data/profile_io.gd` | E/S JSON atómica con backup y validación | Pendiente de implementación |
| `res://accesibilidad/data/profile_migrations.gd` | Migraciones `version` 1 → futuras | Pendiente de implementación |
| `res://accesibilidad/tts/access_text_reader.gd` | Interfaz/evento de lectura de texto para TTS futuro (no implementado) | Pendiente de implementación |

> Nota: `accessibility_menu.gd` y `accessibility_preview.gd` se referencian desde la escena del menú de Opciones de M53 (`res://ui/menus/options/`), pero residen en `res://accesibilidad/` para mantener el dominio desacoplado.

## 2. Firmas de funciones clave (GDScript)

```gdscript
# res://accesibilidad/profiles/accessibility_profile.gd
class_name AccessibilityProfile
extends Resource

signal changed(profile: AccessibilityProfile)

@export var version: int = 1
# --- Visual ---
@export var color_filter: StringName = &"none"          # none/protanopia/deuteranopia/tritanopia
@export var color_filter_intensity: float = 1.0         # 0.0 - 1.0
@export var high_contrast: bool = false
@export var contrast: float = 1.0
@export var brightness: float = 1.0
@export var saturation: float = 1.0
@export var ui_scale: float = 1.0                       # 0.8 - 2.0
@export var text_scale: StringName = &"normal"          # normal/large/extra_large
@export var interactable_outlines: bool = false
@export var ui_background_opacity: float = 0.6          # 0.0 - 1.0
# --- Auditiva ---
@export var subtitles_enabled: bool = true
@export var subtitle_size_scale: float = 1.0            # 0.8 - 2.0
@export var subtitle_bg_opacity: float = 0.8            # 0.0 - 1.0
@export var subtitle_speed: float = 1.0                 # 0.5 - 2.0
@export var audio_indicators: bool = true
@export var visual_alert_cards: bool = true
# --- Motora ---
@export var action_mode: Dictionary = {}                # action_name -> "hold"/"toggle"
@export var aim_assist: float = 0.0                     # 0.0 - 1.0
@export var vibration_enabled: bool = true
@export var input_preset: StringName = &"default"       # default/single_hand/low_mobility
# --- Cognitiva ---
@export var difficulty: StringName = &"standard"        # serene/standard/custom
@export var serene_combat: bool = false
@export var extended_timers: bool = false
@export var motion_reduction: float = 1.0               # 1.0 = sin reducción, 0.0 = mínimo movimiento
@export var guidance_level: StringName = &"standard"    # minimal/standard/reinforced
@export var dialogue_pace: StringName = &"player_controlled"
# --- Lectoescritura ---
@export var reading_spacing: float = 1.0                # 0.8 - 1.5
@export var reading_line_height: float = 1.0            # 0.9 - 1.6
@export var global_large_text: bool = false
# --- Sistema ---
@export var autosave_interval_minutes: int = 5          # 1 - 30
@export var accessibility_shortcut: StringName = &"f10"

static func default_profile() -> AccessibilityProfile: ...
static func preset(name: StringName) -> AccessibilityProfile: ...
```

```gdscript
# res://accesibilidad/autoload/settings_manager.gd
extends Node
## Autoload "SettingsManager" (primer autoload del proyecto).

signal profile_loaded(profile: AccessibilityProfile)
signal profile_changed(profile: AccessibilityProfile)
signal profile_reset()

const SAVE_PATH := "user://accesibilidad/profile.json"
const BACKUP_PATH := "user://accesibilidad/profile.backup.json"
const SAVE_DEBOUNCE_SECONDS := 2.0

var _profile: AccessibilityProfile
var _save_timer: float = 0.0
var _dirty := false

func _ready() -> void:
    _profile = ProfileIO.load_or_default()
    AccessibilityApplier.apply_profile(_profile)
    profile_loaded.emit(_profile)

func get_profile() -> AccessibilityProfile: ...
func get_setting(key: StringName) -> Variant: ...
func set_setting(key: StringName, value: Variant) -> void: ...
func save() -> bool: ...
func reset() -> void: ...
func _process(delta: float) -> void:
    # debounce de guardado para no escribir en cada tick de slider
    ...
```

```gdscript
# res://accesibilidad/data/profile_io.gd
class_name ProfileIO

static func load_or_default() -> AccessibilityProfile: ...
static func save(profile: AccessibilityProfile) -> bool: ...
static func write_atomic(tmp_path: String, final_path: String) -> bool: ...
static func validate(profile: AccessibilityProfile) -> void: ...
```

```gdscript
# res://accesibilidad/services/accessibility_applier.gd
class_name AccessibilityApplier

static func apply_profile(profile: AccessibilityProfile) -> void:
    _apply_ui_scale(profile.ui_scale)                    # via M53 root node
    _apply_text(profile)                                 # via M88 theme
    _apply_color_filter(profile)                         # CanvasLayer shader / fallback modulate
    _apply_motion(profile.motion_reduction)              # via M12 camera
    _apply_subtitles(profile)                            # via M91 SubtitleManager
    _apply_input(profile)                                # via M57 InputManager
    _apply_difficulty(profile)                           # flags para sistemas de juego
    _apply_audio_indicators(profile)
```

```gdscript
# res://accesibilidad/visual/color_filter.gd
class_name ColorFilter

func set_filter(filter_type: StringName, intensity: float) -> void: ...
func set_high_contrast(enabled: bool, contrast: float, brightness: float, saturation: float) -> void: ...
func use_shader_mode() -> bool: ...          # según preset gráfico de M90
func use_fallback_modulate() -> void: ...    # calidad baja
```

```gdscript
# res://accesibilidad/input/aim_assist.gd
class_name AimAssist

@export var strength: float = 0.0  # 0.0 - 1.0 (leída del perfil)

func find_target(direction: Vector2, candidates: Array[Node]) -> Node2D: ...
func assist_direction(raw: Vector2, target: Node2D) -> Vector2: ...
```

```gdscript
# res://accesibilidad/motion/motion_reducer.gd
class_name MotionReducer

var factor: float = 1.0  # 1.0 = sin reducción; consume amplitudes de M12

func scale_shake(amplitude: float) -> float: ...
func scale_parallax(offset: Vector2) -> Vector2: ...
func scale_transition(duration: float) -> float: ...
```

```gdscript
# res://accesibilidad/cognitive/difficulty_provider.gd
class_name DifficultyProvider

func is_serene() -> bool: ...
func timers_extended() -> bool: ...
func combat_calm() -> bool: ...
```

```gdscript
# res://accesibilidad/ui/accessibility_menu.gd
class_name AccessibilityMenuUI
extends Control
## Vista pura: reenvía valores a SettingsManager. Sin lógica de gameplay.

func _on_slider_changed(key: StringName, value: float) -> void:
    SettingsManager.set_setting(key, value)
```

```gdscript
# res://accesibilidad/audio/audio_indicator.gd
class_name AudioIndicator
extends Sprite2D

func show_ripple(position_2d: Vector2, intensity: float) -> void: ...
```

## 3. Convenciones

- Prefijo `_` en privados; `snake_case` en funciones; `PascalCase` en clases (convención del proyecto).
- Todos los "gateways" hacia otros módulos se hacen por llamadas a sus managers (InputManager, SubtitleManager, UIRoot de M53) — nunca accesos directos a nodos de escena.
- Solo `SettingsManager` toca disco; `AccessibilityApplier` solo aplica; los scripts de vista solo reenvían.
- Cero dependencias de plugins externos; GDScript puro + shader Godot.

---

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice

- Generé la documentación completa del módulo transversal 58-Accesibilidad en `DOCUMENTACION/58-Accesibilidad/` (plan-inicial y plan-actual idénticos): 01-Requerimientos (33 RF organizados por áreas: visual, auditiva, motora, cognitiva, lectoescritura y sistema, más RN y criterios de aceptación), 02-Analisis (5 áreas del dominio, 8 alternativas A1–A8, 8 decisiones clave D1–D8, riesgos y mitigaciones), 03-Diseno (arquitectura SettingsManager/Profile/Applier/Menu, flujos de boot, cambio en vivo, persistencia atómica y recuperación ante corrupción, tabla de integración con M53/M57/M88/M90/M91/M12/M87), 04-Codigo (20 archivos previstos en `res://accesibilidad/` marcados "Pendiente de implementación", firmas GDScript completas del perfil, manager, I/O, applier, filtro de color, aim assist, motion reducer, difficulty provider, indicador de audio y menú) y 05-Checklist con 173 ítems verificables.
- Respeté el ecosistema Godot 4.x + GDScript (sin referencias a Unity/C#) y las convenciones del proyecto (firma de documentación, español, marcadores [S]/[M]/[C], plan-actual byte a byte idéntico a plan-inicial).
- NO toqué ningún archivo fuera de `DOCUMENTACION/58-Accesibilidad/`.

### Lo que NO pude hacer (honestidad obligatoria)

- No implementé código: el módulo es 100 % documentación y queda delegable para su implementación (archivos marcados "Pendiente de implementación").
- No ejecuté el juego ni testings reales: no hay código ejecutable todavía en este módulo.
- No actualicé `CHECKLIST-GLOBAL.md` (queda fuera del alcance de la tarea otorgada); el módulo figuraba como `58 | Accesibilidad | ⬜ Sin iniciar | 0/100`.

### Recomendaciones para el próximo agente

- **Primero:** verificar que `SettingsManager` sea el PRIMER autoload del proyecto (por encima de input y UI) para que el filtro de color y el escalado existan antes del logo de título.
- Al implementar `AccessibilityApplier`, probar cada área contra su módulo destino (M53 raíz UI, M57 InputManager, M88 theme, M90 preset gráfico, M91 SubtitleManager, M12 cámara) y documentar los puntos de contacto reales.
- Implementar `ProfileIO` con escritura atómica y backup ANTES que la UI para poder persistir desde el día uno.
- Verificar los presets `single_hand`/`low_mobility` contra el remapeo real de M57 (que no existan conflictos con la capa de acciones).
- Ejecutar el plan de testings del 05-Checklist (sección M) y dejar `07-Resultados-Testings.md` en plan-actual cuando el plan de testings amerite.
- Confirmar el comportamiento del shader de daltonismo en calidad Baja (fallback modulate) antes de cerrar el módulo.
- Al completar la implementación, actualizar `CHECKLIST-GLOBAL.md` (estado ✅/🟡, progreso real) y `ESTADO-PARALELO.md` si aplica, con la firma correspondiente.