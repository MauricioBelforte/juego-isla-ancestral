**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

# 03-Diseno.md — Módulo 91: Configuración de Audio

## 1. Arquitectura del módulo

```
Configuración de Audio (menú de settings de audio)
├── Volúmenes
│   ├── Volumen maestro (slider 0-100%)
│   ├── Música (slider 0-100%)
│   ├── Efectos (slider 0-100%)
│   ├── Ambiente (slider 0-100%)
│   ├── Voces (slider 0-100%)
│   ├── UI (slider 0-100%)
│   └── Cinemáticas (slider 0-100%)
├── Audio 3D
│   ├── Toggle de audio 3D
│   ├── Espacialización (HRTF)
│   └── Oclusión
├── Subtítulos
│   ├── Toggle de subtítulos
│   ├── Tamaño (slider 0.5x a 2x)
│   ├── Opacidad (slider 0.2 a 1.0)
│   ├── Fondo (toggle + color)
│   └── Color de texto (selector)
├── Sonidos de interfaz
│   ├── Toggle de sonidos de interfaz
│   ├── Hover
│   ├── Click
│   ├── Notificaciones
│   └── Errores
├── Rango dinámico
│   ├── Quiet (compresión alta)
│   ├── Medio (compresión media)
│   └── Dinámico (sin compresión)
├── Compresión
│   ├── Toggle de compresión
│   ├── Threshold
│   └── Ratio
└── Dispositivo de salida
    ├── Predeterminado
    ├── Auriculares
    ├── Altavoces
    ├── HDMI
    └── Bluetooth
```

## 2. Menú de configuración de audio

> ⚠️ **Nota de alcance (2026-10-03, mimo-v2.6-flash-free / opencode, iter. 10):**
> `res://ui/settings/audio_settings_menu.gd` **no existe todavía** (0 refs en
> `scripts/`). Este §2 es la **especificación de controles que M91 entrega a
> M53** (dueño del menú, ver §10): los ítems de controles del checklist
> (L147, L198-L211) son de **M53** (Trampa 119). El estado real vive en el
> autoload `AudioConfig` (§16-18), no en una clase `AudioSettings`.

**Archivo: res://ui/settings/audio_settings_menu.gd** (futuro — M53)

**Estructura:**
```gdscript
class_name AudioSettingsMenu
extends Control

@onready var master_volume_slider = $MasterVolumeSlider
@onready var music_volume_slider = $MusicVolumeSlider
@onready var sfx_volume_slider = $SFXVolumeSlider
@onready var ambient_volume_slider = $AmbientVolumeSlider
@onready var voice_volume_slider = $VoiceVolumeSlider
@onready var ui_volume_slider = $UIVolumeSlider
@onready var cinematic_volume_slider = $CinematicVolumeSlider
@onready var audio_3d_toggle = $Audio3DToggle
@onready var subtitles_toggle = $SubtitlesToggle
@onready var subtitle_size_slider = $SubtitleSizeSlider
@onready var subtitle_opacity_slider = $SubtitleOpacitySlider
@onready var subtitle_background_toggle = $SubtitleBackgroundToggle
@onready var subtitle_color_picker = $SubtitleColorPicker
@onready var ui_sounds_toggle = $UISoundsToggle
@onready var dynamic_range_option_button = $DynamicRangeOptionButton
@onready var compression_toggle = $CompressionToggle
@onready var output_device_option_button = $OutputDeviceOptionButton
@onready var test_headphones_button = $TestHeadphonesButton
@onready var test_speakers_button = $TestSpeakersButton
```

## 3. Configuración de settings

> ⚠️ **Corregido 2026-10-03 (mimo-v2.6-flash-free / opencode, iter. 10):**
> `res://settings/audio_settings.gd` **no existe** — la implementación real es
> el autoload `AudioConfig` (`scripts/audio/audio_config_service.gd`, sin
> `class_name`, ver §16-18). Los **valores por defecto de abajo SÍ son los
> reales** (`AudioConfig.DEFAULTS`, documentado allí como "diseño §3") y
> `apply_settings()` equivale a `_aplicar_todo()`. El esqueleto de abajo queda
> como diseño original de referencia.

**Archivo (diseño original): res://settings/audio_settings.gd** → real: autoload `AudioConfig`

**Estructura:**
```gdscript
class_name AudioSettings
extends Resource

var master_volume: float = 0.8
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var ambient_volume: float = 0.6
var voice_volume: float = 0.9
var ui_volume: float = 0.5
var cinematic_volume: float = 0.8
var audio_3d: bool = true
var subtitles: bool = true
var subtitle_size: float = 1.0
var subtitle_opacity: float = 0.8
var subtitle_background: bool = true
var subtitle_color: Color = Color.WHITE
var ui_sounds: bool = true
var dynamic_range: String = "medio"
var compression: bool = true
var output_device: String = "predeterminado"

func apply_settings():
    # Aplicar configuración a AudioServer
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(master_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(music_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient"), linear2db(ambient_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"), linear2db(voice_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear2db(ui_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Cinematic"), linear2db(cinematic_volume))
    # ... más configuraciones
```

## 4. Buses de audio

**Buses de audio en AudioServer:**
```
Master (bus índice 0)
├── Music (bus índice 1)
├── SFX (bus índice 2)
├── Ambient (bus índice 3)
├── Voice (bus índice 4)
├── UI (bus índice 5)
└── Cinematic (bus índice 6)
```

**Implementación:**
```gdscript
# res://audio/audio_bus_setup.gd
class_name AudioBusSetup
extends Node

func _ready():
    setup_audio_buses()

func setup_audio_buses():
    # Crear buses de audio
    var master_bus = AudioServer.get_bus_index("Master")
    var music_bus = AudioServer.add_bus()
    AudioServer.set_bus_name(music_bus, "Music")
    AudioServer.set_bus_send(music_bus, master_bus)
    
    var sfx_bus = AudioServer.add_bus()
    AudioServer.set_bus_name(sfx_bus, "SFX")
    AudioServer.set_bus_send(sfx_bus, master_bus)
    
    var ambient_bus = AudioServer.add_bus()
    AudioServer.set_bus_name(ambient_bus, "Ambient")
    AudioServer.set_bus_send(ambient_bus, master_bus)
    
    var voice_bus = AudioServer.add_bus()
    AudioServer.set_bus_name(voice_bus, "Voice")
    AudioServer.set_bus_send(voice_bus, master_bus)
    
    var ui_bus = AudioServer.add_bus()
    AudioServer.set_bus_name(ui_bus, "UI")
    AudioServer.set_bus_send(ui_bus, master_bus)
    
    var cinematic_bus = AudioServer.add_bus()
    AudioServer.set_bus_name(cinematic_bus, "Cinematic")
    AudioServer.set_bus_send(cinematic_bus, master_bus)
```

**✅ Implementación real (2026-10-02):** el `audio_bus_setup.gd` de arriba
nunca se creó — los 7 buses los crea `AudioConfig._crear_buses()`
(`scripts/audio/audio_config_service.gd:48`) dentro de `_ready()`, con
`add_bus` + `set_bus_name` + `set_bus_send("Master")` solo si el nombre aún no
existe (idempotente). Verificado por `test_audio_config.gd`.

### Tabla de enrutamiento — "control de X" (5 ítems del checklist)

Regla de diseño: **cada familia de sonido del juego tiene su bus propio y su
control independiente.** Bajar una familia jamás mueve a las demás — verificado
en `_test_aplicacion_y_control_por_bus()`: mover `Music` deja intactos los
otros 5 buses.

| Familia de sonido (texto del checklist) | Bus | Control | Default |
|---|---|---|---|
| Música de fondo | `Music` | `set_volumen_porcentaje("Music", p)` | 70% |
| Audio de cinemáticas | `Cinematic` | `set_volumen_porcentaje("Cinematic", p)` | 80% |
| Efectos de juego: herramientas, craft, interacción | `SFX` | `set_volumen_porcentaje("SFX", p)` | 80% |
| Ambiente: viento, agua, pájaros | `Ambient` | `set_volumen_porcentaje("Ambient", p)` | 60% |
| Voces de NPCs y de cinemáticas | `Voice` | `set_volumen_porcentaje("Voice", p)` | 90% |
| Interfaz: hover, click, notificaciones | `UI` | `set_volumen_porcentaje("UI", p)` | 50% |
| Mezcla general | `Master` | `set_volumen_porcentaje("Master", p)` | 80% |

**Cómo enruta un emisor** (una línea por familia):

```gdscript
$AudioStreamPlayer3D.bus = "SFX"      # herramienta / craft / interacción
$AudioStreamPlayer3D.bus = "Ambient"   # viento / agua / pájaros
$AudioStreamPlayer2D.bus = "UI"        # hover / click / notificación
$AudioStreamPlayer.bus = "Voice"       # NPC hablando, voz de cutscene
```

**Dos controles separados para música y cinemáticas:** `Music` gobierna la
música de fondo y `Cinematic` el audio de cutscene. Si una cutscene necesita
que la voz baje pero la música no, se usan `Voice` y `Music` por separado —
por eso el ítem "control de música de fondo y cinemáticas" son dos canales,
no uno.

**Verificación automática:** `_test_aplicacion_y_control_por_bus()` en
`scripts/audio/test_audio_config.gd` comprueba, para cada bus hijo, que
`set_volumen_porcentaje()` llega al `volume_db` **de ese bus**, que el estado
interno lineal lo sigue, que el mute no contamina a los vecinos y que ningún
otro bus se mueve.

## 5. Audio 3D

> **Reescrito 2026-10-02 · mimo-v2.6-flash-free (opencode).**
> El esqueleto anterior (`AudioEffectEQ` como "espacialización") era
> **incorrecto**: `AudioEffectEQ` ecualiza, no espacializa.
> Todo lo siguiente está verificado contra la **API real de Godot 4.7.2**
> mediante sondeo (`ClassDB.class_get_integer_constant_list` +
> `get_property_list()`), siguiendo la lección **T-107**.
>
> **Estado de implementación: todavía no existe.** El proyecto no usa
> `AudioStreamPlayer3D` en ningún script. Este apartado es el **diseño**
> (los ítems dicen "Definir"); la implementación llegará cuando haya
> fuentes de audio 3D que colocar.

### 5.1 Espacialización — L88: HRTF **no disponible** → `[?]`

Sondeo del 2026-10-02 sobre `AudioStreamPlayer3D` (Godot 4.7.2):

| Pregunta | Resultado |
|---|---|
| ¿Existe `panning_mode`? | **No** — 67 propiedades, ninguna con modo de pan |
| ¿Existe algo con "pan"? | solo `panning_strength` (rango 0–3) |
| ¿`AudioServer` expone HRTF/room? | **No** — 0 propiedades coincidentes |
| ¿Algún `AudioEffect*` espacial? | **No** — 29 clases registradas, ninguna spatializer; `AudioEffectPanner` es solo pan estéreo |

**Conclusión: HRTF no se puede pedir al motor stock.** Opciones reales:

1. **GDExtension de terceros** (Resonance Audio, Steam Audio).
2. **DSP propio** — un `AudioEffect` con convolución HRTF (costo alto).
3. **Pan equilibrado + atenuación + oclusión**, que es lo que sí da el motor.

Mientras no se decida, **L88 queda `[?]`** (no resuelto, honesto): no se
diseña a medias ni se marca como hecho. Lo implementable está en §5.2–§5.6.

### 5.2 Atenuación / rolloff — L91

| Parámetro | API real (4.7.2) | Rango / valores |
|---|---|---|
| Modelo | `attenuation_model` | `ATTENUATION_INVERSE_DISTANCE(0)` · `ATTENUATION_INVERSE_SQUARE_DISTANCE(1)` · `Logarithmic(2)` · `ATTENUATION_DISABLED(3)` |
| Radio de referencia | `unit_size` | 0.1 – 100 |
| Volumen máximo | `max_db` | −24 – +6 dB |
| Distancia de corte | `max_distance` | 0 – 4096 m |
| Filtro de lejanía | `attenuation_filter_cutoff_hz` / `attenuation_filter_db` | apaga agudos con la distancia |

**Decisión de diseño:** `ATTENUATION_INVERSE_SQUARE_DISTANCE` (decae con el
cuadrado de la distancia, como el sonido real), `unit_size = 10`,
`max_distance` a ojo del tamaño de la isla, y `attenuation_filter_cutoff_hz`
bajo para que lo lejano suene apagado en lugar de solo bajo.

### 5.3 Doppler — L90

`doppler_tracking` — enum real **`Disabled, Idle, Physics`**:

| Constante | Valor |
|---|---|
| `DOPPLER_TRACKING_DISABLED` | 0 |
| `DOPPLER_TRACKING_IDLE_STEP` | 1 |
| `DOPPLER_TRACKING_PHYSICS_STEP` | 2 |

**Decisión:** `DOPPLER_TRACKING_PHYSICS_STEP` para fuentes en movimiento
(animales, proyectiles): muestrea la velocidad en cada paso de física, que
es donde este juego mueve los cuerpos. `IDLE_STEP` sería para algo que se
mueva solo por proceso visual.

### 5.4 Oclusión (bloqueo por objetos) — L89

Godot **no** oculta sonido por sí solo. Diseño: **raycast desde el oído +
filtro pasa-bajos por reproductor**.

1. El oído (cámara/jugador) lanza un ray hacia la fuente (§5.5).
2. Si algo lo bloquea → `AudioEffectLowPassFilter.cutoff_hz` baja (p. ej. 800 Hz)
   → suena "tapado".
3. Si no hay bloqueo → `cutoff_hz` vuelve a 20500 Hz (abierto).

> ⚠️ El filtro va en un **bus propio de cada reproductor**, **no** en el bus
> `SFX` compartido: si se pusiera en `SFX`, *todo* el juego sonaría tapado.
> Ese era precisamente el error del esqueleto anterior.

### 5.5 Raycast para oclusión — L94

```gdscript
var q := PhysicsRayQueryParameters3D.create(desde, hasta, mascara_oclusion)
q.collide_with_bodies = true    # propiedades reales verificadas por sondeo
q.collide_with_areas  = false
var golpe := get_world_3d().direct_space_state.intersect_ray(q)
var oculto := not golpe.is_empty()
```

`PhysicsRayQueryParameters3D` expone `from`, `to`, `collision_mask`,
`collide_with_bodies`, `collide_with_areas`, `hit_from_inside`, `exclude`.

### 5.6 PhysicsBody3D para bloqueo de sonido — L95

Las paredes que deben tapar son **`StaticBody3D` en una capa de colisión
dedicada** (p. ej. capa 12, `Occlusion`), y la `collision_mask` del raycast
apunta **solo** a esa capa:

- paredes, rocas y cuevas → tapan el sonido;
- jugadores, NPCs, animales y proyectiles → **no** tapan (el ray los ignora).

Sin capa dedicada el ray chocaría con cualquier cuerpo y **todo** sonaría
constantemente tapado.

### 5.7 Cómo queda montado (implementación futura)

```
AudioStreamPlayer3D                    ← una instancia por fuente
├── bus propio "3D_<id>"
│     └── AudioEffectLowPassFilter     ← oclusión (§5.4)
├── attenuation_model / unit_size / max_distance   (§5.2)
├── doppler_tracking = DOPPLER_TRACKING_PHYSICS_STEP (§5.3)
└── stream = el audio
```

Un único script aparte (módulo nuevo, §15 de AGENTS.md) recorre por frame
los reproductores activos, hace el raycast al oído (§5.5) y actualiza el
`cutoff_hz` de su bus.


## 6. Subtítulos

> **Corregido 2026-10-02 (mimo-v2.6-flash-free / opencode).** El esqueleto
> original tenía tres defectos que se documentan aquí para no repetirlos:
> 1. Ruta `res://ui/subtitles/subtitle_manager.gd` no existe — la convención
>    real del proyecto es `game/isla-ancestral/scripts/…`.
> 2. Referenciaba una clase `AudioSettings` inexistente: la config real de
>    audio es el autoload `AudioConfig` (`audio_config_service.gd`), y la
>    persistencia vive en `DataStore` (M60).
> 3. `class_name SubtitleManager` junto a `@onready $SubtitleLabel` exigía un
>    `.tscn`, pero este proyecto **no** monta capas UI en escenas (§9.47): la
>    UI se construye por código, igual que `credits_layer`.
> 4. El `await` original tenía race condition: dos `show_subtitle` seguidos
>    hacían que el reloj del primero ocultara al segundo.
>
> **Ruta real:** `game/isla-ancestral/scripts/ui/subtitle_manager.gd`
> **Autoload:** `SubtitleManager` (sin `class_name` — pitfall §9.17/§9.41)

**SubtitleManager (implementado):**
```gdscript
extends Node   # autoload "SubtitleManager", sin class_name

# ── Límites del diseño (clamados en cada setter) ──
const TAMANO_MIN := 0.5      # slider 0.5x a 2x
const TAMANO_MAX := 2.0
const OPACIDAD_MIN := 0.2    # slider 0.2 a 1.0
const OPACIDAD_MAX := 1.0
const TAMANO_BASE := 16.0    # font_size = round(16 * tamano)

# ── Estado (persistido en M60 sección "subtitles") ──
var habilitados: bool = true          # toggle on/off
var tamano: float = 1.0
var opacidad: float = 0.9
var fondo_visible: bool = true        # toggle + color del fondo
var color_fondo: Color = Color(0, 0, 0, 0.6)
var color_texto: Color = Color(1, 1, 1, 1)

# ── Señales (para que M53 refleje el estado en sus sliders) ──
signal subtitulo_mostrado(texto: String, duracion: float)
signal subtitulo_oculto()
signal config_subtitulos_cambiada()
signal habilitados_cambiado(habilitados: bool)
```

**API pública (ítems de método):**
```gdscript
func show_subtitle(text: String, duration: float) -> void
func hide_subtitle() -> void
func hay_subtitulo_visible() -> bool
func texto_actual() -> String

func set_habilitados(v: bool)     # get_habilitados()
func set_subtitle_size(v: float)  # get_subtitle_size()  — clamado a [0.5, 2.0]
func set_subtitle_opacity(v: float) # get_subtitle_opacity() — clamado a [0.2, 1.0]
func set_background_visible(v: bool) / get_background_visible()
func set_background_color(c: Color) / get_background_color()
func set_text_color(c: Color) / get_text_color()
func restaurar_defaults() -> void
func get_save_data() -> Dictionary
func restore_save_data(data: Dictionary) -> void
```

**Estructura de UI (montada en `_ready()`, sin `.tscn`):**
```
SubtitleManager (autoload)
└── CanvasLayer "SubtitulosCapa" (layer 90)
    └── PanelContainer "SubtituloFondo"   ← fondo toggle+color (StyleBoxFlat)
        └── RichTextLabel "SubtitleLabel" ← horizontal_alignment CENTER
```
Anclaje: centrado horizontalmente, pegado al borde inferior
(`anchor_*` + `offset_*`, `grow_horizontal = BOTH`), así sigue a la ventana.

**Anti-race-condition:** `show_subtitle` incrementa un contador `_generacion`
y captura su valor local (`mi_generacion`). Al vencer el `SceneTreeTimer`,
solo oculta si `mi_generacion == _generacion`. Si mientras tanto entró otro
subtítulo, el reloj viejo queda obsoleto y no lo toca. `duration <= 0.0`
significa "sin reloj": queda hasta `hide_subtitle()`.

**Persistencia (M60, sección `subtitles`):** las claves son ASCII a propósito
— el borrador usaba `subtítulo_size` con tilde, y las claves con tildes
generan mojibake cuando un agente escribe en cp1252 (§28). Misma intención,
distinto nombre:

| Clave | Tipo | Equivalente al borrador |
|-------|------|-------------------------|
| `enabled` | bool | toggle de subtítulos |
| `size` | **float** | `subtítulo_size` |
| `opacity` | **float** | `subtítulo_opacity` |
| `color` | `{"r","g","b","a"}` | `subtítulo_color` |
| `background` | bool | fondo on/off |
| `text_color` | `{"r","g","b","a"}` | color de texto |

**Multiidioma (ítem de M87):** `show_subtitle` recibe **texto ya traducido**;
el llamador resuelve la cadena con el autoload `Localization`. El gestor no
hace `tr()` propio — así un mismo subtitle se sirve en cualquier idioma sin
duplicar lógica, y el UTF-8 llega intacto (§28).

**Tests:** `scripts/ui/test_subtitles_m91.gd` — 80 checks, 0 fallos.
Cubre defaults, toggle, clamados de tamaño/opacidad, fondo, formato de
guardado y la condición de carrera con relojes reales.

## 7. Sonidos de interfaz

> ⚠️ **BLOQUEADO (2026-10-02, mimo-v2.6-flash-free / opencode).** El diseño
> de abajo **no está implementado** y no debe marcarse como hecho:
>
> 1. `UISoundManager` no existe en `scripts/`.
> 2. El esqueleto tiene los mismos defectos del §6: ruta `res://audio/…`
>    fuera de la convención real, clase `AudioSettings` inexistente (la real
>    es `AudioConfig`), y `$HoverSound`/`$ClickSound`/… que exigirían un
>    `.tscn` cuando este proyecto monta la UI por código (§9.47).
> 3. **Cero assets de sonido en todo el proyecto** (0 `.wav` / `.ogg` /
>    `.mp3`): sin streams no hay nada que `play()`. Esto hay que resolverlo
>    antes de implementar — ya sea importando samples, o generándolos con
>    `AudioStreamWAV` procedural / `AudioStreamGenerator`.
>
> Mientras tanto, los ítems de esta sección se dejan `[ ]` a propósito
> (Trampa 119: no marcar por marcar).

**UISoundManager (diseño original, pendiente de implementación):**
```gdscript
# res://audio/ui_sound_manager.gd   ← RUTA INCORRECTA, ver nota arriba
class_name UISoundManager
extends Node

@onready var hover_sound = $HoverSound
@onready var click_sound = $ClickSound
@onready var notification_sound = $NotificationSound
@onready var error_sound = $ErrorSound

func play_hover_sound():
    if AudioSettings.ui_sounds:
        hover_sound.play()

func play_click_sound():
    if AudioSettings.ui_sounds:
        click_sound.play()

func play_notification_sound():
    if AudioSettings.ui_sounds:
        notification_sound.play()

func play_error_sound():
    if AudioSettings.ui_sounds:
        error_sound.play()
```

## 8. Rango dinámico

**DynamicRangeManager:**
```gdscript
# res://audio/dynamic_range_manager.gd
class_name DynamicRangeManager
extends Node

func apply_dynamic_range(range: String):
    var master_bus = AudioServer.get_bus_index("Master")
    
    match range:
        "quiet":
            apply_compression(master_bus, threshold=-20, ratio=10, attack=0.01, release=0.1)
        "medio":
            apply_compression(master_bus, threshold=-10, ratio=5, attack=0.01, release=0.1)
        "dinamico":
            remove_compression(master_bus)

func apply_compression(bus_index: int, threshold: float, ratio: float, attack: float, release: float):
    var compressor = AudioEffectCompressor.new()
    compressor.threshold = threshold
    compressor.ratio = ratio
    compressor.attack_us = attack * 1000000
    compressor.release_us = release * 1000000
    AudioServer.add_bus_effect(bus_index, compressor, 0)

func remove_compression(bus_index: int):
    var effect_count = AudioServer.get_bus_effect_count(bus_index)
    for i in range(effect_count):
        if AudioServer.get_bus_effect(bus_index, i) is AudioEffectCompressor:
            AudioServer.remove_bus_effect(bus_index, i)
            break
```

## 9. Compresión

**CompressionManager:**
```gdscript
# res://audio/compression_manager.gd
class_name CompressionManager
extends Node

func apply_compression(enabled: bool):
    var master_bus = AudioServer.get_bus_index("Master")
    
    if enabled:
        var limiter = AudioEffectLimiter.new()
        limiter.threshold_db = -3
        limiter.ceil_db = 0
        limiter.soft_clip = true
        AudioServer.add_bus_effect(master_bus, limiter, 0)
    else:
        remove_limiter(master_bus)

func remove_limiter(bus_index: int):
    var effect_count = AudioServer.get_bus_effect_count(bus_index)
    for i in range(effect_count):
        if AudioServer.get_bus_effect(bus_index, i) is AudioEffectLimiter:
            AudioServer.remove_bus_effect(bus_index, i)
            break
```

## 10. Dispositivo de salida

**OutputDeviceManager** (implementado en `scripts/audio/output_device_manager.gd`
como `RefCounted` con funciones `static`; probado con los 82 checks de
`test_audio_effects_m91.gd`):

```gdscript
# res://scripts/audio/output_device_manager.gd   <- convencion real, NO res://audio/
class_name OutputDeviceManager
extends RefCounted

# API real Godot 4.7.2 - sondeada por reflexion (T-107).
static func dispositivos() -> PackedStringArray:
    return AudioServer.get_output_device_list()

static func actual() -> String:
    return AudioServer.get_output_device()

static func seleccionar(nombre: String) -> bool:
    if not AudioServer.get_output_device_list().has(nombre):
        return false
    AudioServer.set_output_device(nombre)
    return true
```

> ⚠️ **API corregida 2026-10-02 (mimo-v2.6-flash-free / opencode).** El diseño
> original de esta sección usaba `AudioServer.get_device_list()` /
> `set_device()` / `get_device()` — **API de Godot 3, no existe en 4.7.2**.
> El sondeo por reflexión confirma los nombres reales
> `get_output_device_list()` / `set_output_device()` / `get_output_device()`.
> El archivo **implementado** ya usaba los correctos desde el Lote 1; lo que
> estaba mal era este diseño (y `02-Analisis` §14). Ver `GUIA-GODOT/06` T-107.

**Dropdown en settings:** lo diseña y monta **M53** (menú). M91 solo expone
`dispositivos()` / `actual()` / `seleccionar()`. Por eso **L147 queda `[ ]`** a
propósito: el diseño de UI es de otro módulo (Trampa 119).

## 11. Pruebas de audio

> **Reescrito 2026-10-02 · mimo-v2.6-flash-free 2026-10-02 (opencode).** El esqueleto anterior era un
> archivo con funciones **vacías** (`# Test estéreo` sin nada más). Todo lo
> de abajo está verificado contra la **API real de Godot 4.7.2** por sondeo
> (lección T-107) y cubre **L271, L272 y L273**.
>
> **Estado: diseño, sin implementar.** El manager se crea cuando los botones
> de prueba existan en el menú de settings (M53).

### 11.1 APIs reales con las que se hace (sondeadas)

| Para qué | API real (4.7.2) |
|---|---|
| Enviar un canal a la izquierda / derecha | `AudioEffectPanner.pan` → float **-1 .. 1**, paso 0.01 |
| Modo de altavoces del driver | `AudioServer.get_speaker_mode()` |
| Constantes de modo | `SPEAKER_MODE_STEREO=0` · `SPEAKER_SURROUND_31=1` · `SPEAKER_SURROUND_51=2` · `SPEAKER_SURROUND_71=3` |
| **Medir** si un canal está sonando | `AudioServer.get_bus_peak_volume_left_db(bus)` / `..._right_db(bus)` |
| Canales de un bus | `AudioServer.get_bus_channels(bus)` |
| Lista / cambio de dispositivo | `AudioServer.get_output_device_list()` / `get_output_device()` |
| Latencia real (para cortar el test) | `AudioServer.get_output_latency()` |

> 💡 **El test de balance se puede automatizar:** `get_bus_peak_volume_*_db`
> devuelve el pico real de cada canal, así que el test puede **comprobar**
> que la izquierda suena y la derecha no (y viceversa) sin depender del oído.
> Lo que sigue necesitando al usuario es *oír* si sale por el altavoz
> correcto.

### 11.2 Estructura del manager

```gdscript
# res://scripts/audio/audio_test_manager.gd
extends Node          # sin class_name (§9.17 / §9.41)

signal test_iniciado(id: StringName)
signal paso_cambiado(id: StringName, paso: int, texto: String)
signal test_terminado(id: StringName, resultado: bool)

enum Test { ESTEREO, ESPACIAL_3D, BALANCE, CINCO_UNO, SIETE_UNO, DISPOSITIVO }
```

### 11.3 Test estéreo — L271 · L150 · L160

**Objetivo:** confirmar que el canal izquierdo y el derecho suenan por
separado.

| Paso | Qué pasa | Qué debe notar el usuario |
|---|---|---|
| 1 | Tono de 200 Hz con `AudioEffectPanner.pan = -1`, 1,5 s | **Solo** el oído / altavoz **izquierdo** |
| 2 | Silencio 0,5 s | — |
| 3 | Mismo tono con `pan = +1`, 1,5 s | **Solo** el **derecho** |
| 4 | «¿Funcionó?» → Sí / No | — |

**Comprobación automática (sin oído):** durante el paso 1,
`get_bus_peak_volume_left_db` debe estar por encima de -60 dB y el derecho
prácticamente en -infinito.

### 11.4 Test espacial 3D — L272 (HRTF depende de L88)

**Objetivo:** confirmar que el sonido se desplaza alrededor de la cabeza.

- Fuente `AudioStreamPlayer3D` describiendo un círculo de 3 m alrededor del
  oído, una vuelta en 8 s, con `attenuation_model` y `unit_size` según
  **§5.2**.
- Esperado: recorrido audible **izquierda → atrás → derecha → frente**.
- ❌ **La variante HRTF queda pendiente de L88** (`[?]`): Godot 4.7.2 no la
  expone (ver §5.1.1). Este test cubre el espacializado que sí existe
  (pan + atenuación + Doppler).

### 11.5 Test de balance de canales — L273 · L152 · L163

**Objetivo:** que ningún canal quede mudo ni mucho más bajo que los demás.

1. Recorrer los canales que declara `get_bus_channels()` del bus destino.
2. En cada canal mandar un tono de 1 s.
3. **Automático:** leer `get_bus_peak_volume_*_db` y **fallar** si algún
   canal queda por debajo de -60 dB.
4. **Manual:** el usuario confirma que el canal anunciado es el que suena.

### 11.6 Test 5.1 y 7.1 — L161 · L162

Primero se le pregunta al driver:

```gdscript
match AudioServer.get_speaker_mode():
    AudioServer.SPEAKER_MODE_STEREO:
        pass   # no hay 5.1/7.1: informar y NO ofrecer el test
    AudioServer.SPEAKER_SURROUND_51:
        pass   # recorrer I, D, Centro, LFE, IT, DT
    AudioServer.SPEAKER_SURROUND_71:
        pass   # idem + IL, DR
```

Si el modo es `SPEAKER_MODE_STEREO` el test **no se ofrece**: no tiene
sentido pedirle 5.1 a un driver estéreo, y ahí se le explica al usuario
por qué.

### 11.7 Botones de prueba en settings — L157 · L167

- Dos botones en la sección de pruebas del menú: **«Probar auriculares»** y
  **«Probar altavoces»**.
- Muestran el paso actual (`paso_cambiado` → un Label) y los botones
  «Sí funciona» / «No funciona».
- **Deshabilitados** mientras corre un test (regla de §8: impedir doble
  click durante la carga).
- El menú es de **M53**: M91 solo expone el manager y sus señales.


## 12. Integración con M58 (Accesibilidad)

**Accesibilidad:**
- Tamaño de subtítulos (slider 0.5x a 2x)
- Alto contraste (toggle)
- Reducción de audio complejo (opción para simplificar audio)
- Audio descriptivo (opción para descripción visual en audio)

**Implementación:**
- Ajustes de accesibilidad en menú de configuración de audio
- Ajustes guardados en settings (M91)
- Ajustes aplicados en tiempo real

## 13. Integración con M87 (Internacionalización)

**Internacionalización:**
- Subtítulos en diferentes idiomas (español, portugués, francés, alemán, italiano, ruso)
- Audio de voces en diferentes idiomas (si disponible)
- Localización de nombres de dispositivos de salida

**Implementación:**
- SubtitleManager con soporte multiidioma
- AudioPlayer con soporte multiidioma
- LocalizationManager para traducción

## 14. Integración con M61 (Rendimiento)

**Rendimiento:**
- Audio en streaming (para archivos grandes)
- Audio en memoria (para archivos pequeños)
- Pool de AudioPlayers para evitar GC
- Audio comprimido (OGG, MP3) para reducir tamaño

**Implementación:**
- AudioStreamPlayer para streaming
- AudioStreamPlayer2D/3D para memoria
- ObjectPool para AudioPlayers
- Compresión de audio en import settings

## 15. Diagrama de flujo

```
[Usuario abre settings]
    ↓
[Menú de configuración de audio]
    ↓
[Usuario ajusta volúmenes y opciones]
    ↓
[AudioSettings se actualiza]
    ↓
[AudioBusSetup aplica configuración a AudioServer]
    ↓
[Configuración guardada en settings (M91)]
    ↓
[Usuario cierra settings]
    ↓
[Configuración aplicada al audio del juego]
```

## 16. Guardado de configuración

> ✅ **CORREGIDO 2026-10-03 (mimo-v2.6-flash-free / opencode, M91 iter. 10).**
> El diseño original de los §16-18 describía `user://settings/audio_settings.json`
> con clases `AudioSettingsLoader` / `AudioSettingsSaver` que **no existen** en el
> código (0 referencias en `scripts/`). La implementación real usa la persistencia
> de M60. Debajo queda el diseño **real**, verificado contra el código.
> Los huecos de persistencia encontrados quedaron como **BUG-092**.

**Almacenamiento real:** `user://config.cfg` (escritura atómica) vía
`DataStore.guardar_config()` / `DataStore.cargar_config()` → `GestorConfig` (M60).

**Sección `"audio"` del config** — la escribe `AudioConfig._guardar_config()`
(`audio_config_service.gd` L168-177), claves = nombre del bus → volumen lineal:

```gdscript
# user://config.cfg → sección "audio"
{ "Master": 0.8, "Music": 0.7, "SFX": 0.8, "Ambient": 0.6,
  "Voice": 0.9, "UI": 0.5, "Cinematic": 0.8 }
```

**Cuándo se escribe — patrón del proyecto: auto-guardado en cada setter**
(dispara `DataStore.guardar_config()` en el acto, no al cerrar el menú):

- `AudioConfig.set_volumen()` → llama `_guardar_config()` en **cada** cambio (L102).
- `SubtitleManager` → `_guardar_config()` en cada setter de subtítulos.
- Consecuencia: **volúmenes y subtítulos NO necesitan trigger de cierre** (ya
  están en disco antes de que el menú se cierre). El trigger de cierre solo
  aplica a las secciones sin auto-save → §18.

**Vía doble (NO confundir — son almacenes distintos):**

| Vía | Almacén | Contenido | Cuándo se escribe |
|-----|---------|-----------|-------------------|
| Config (settings) | `user://config.cfg` sección `"audio"` | bus → lineal 0-1 | cada `set_volumen()` |
| Savegame (slots) | slot `.save` sección `"audio_config"` | `{volumenes, mutes}` | `request_save()` / `load_slot()` — proveedor registrado en `_ready` (`get_section_name()` = `"audio_config"`) |

**Huecos conocidos (→ BUG-092, 2026-10-03):**
1. `set_mute()` NO llama `_guardar_config()` y `_guardar_config()` NO serializa
   `_mutes` → los mutes viven solo en el savegame, **no** en `config.cfg`
   (se pierden entre sesiones).
2. `DynamicRangeManager` / `CompressionManager` / `OutputDeviceManager` no
   persisten su selección (verificado: 0 referencias a `DataStore` en ellos).

## 17. Carga de configuración al inicio

**Real:** el autoload `AudioConfig._ready()` (`audio_config_service.gd` L41-44):

```gdscript
func _ready() -> void:
    _crear_buses()                   # §4: crea buses hijo si faltan → Master
    _cargar_config()                 # defaults → overlay config["audio"] → aplicar
    _registrar_proveedor_guardado()  # SaveManager.register_provider(self)
```

`_cargar_config()` (L63-73), en orden:

1. `_volumenes = DEFAULTS.duplicate()` — defaults del diseño §3.
2. Overlay: `DataStore.cargar_config()["audio"]` → `clampf(0.0, 1.0)` por bus
   (solo claves que existen en `_volumenes`).
3. `_aplicar_todo()` → `_aplicar_volumen()` por bus: lineal → dB, con mute
   respetado (`set_bus_mute`).

**Fallback:** sin `DataStore`, sin `cargar_config()` o sin sección `"audio"`
quedan los defaults — no hay crash (null-check con `has_method`).
`SubtitleManager` carga su propia sección con el mismo patrón.

> **No existe** `AudioSettingsLoader`, ni `user://settings/audio_settings.json`,
> ni la clase `AudioSettings` (el diseño viejo de esta sección quedó reemplazado
> el 2026-10-03, iter. 10).

## 18. Guardado de configuración al cerrar — L288

**Hallazgo de diseño (iter. 10, 2026-10-03):** con auto-guardado por setter
(§16), un trigger de cierre **no es necesario** para volúmenes ni subtítulos:
ya persisten en `config.cfg` antes de que el menú se cierre. El trigger hacía
falta para las secciones **sin** auto-save (rango dinámico, compresión,
dispositivo de salida — BUG-092).

> **Cerrado en iter. 11 (2026-10-04, BUG-092, Log 1260):** `set_opcion()`
> quedó implementada **con auto-guardado por setter** (mismo camino que
> `set_volumen()`), así que las 3 secciones ya persisten en cada cambio:
> hoy **ninguna** sección necesita `al_cerrar_settings()`. El contrato se
> conserva por si M53 prefiere escribir solo al cerrar — llamarlo sería inocuo.

**Contrato de cierre (diseñado en M91; lo ejecuta M53 al cerrar su menú):**

```gdscript
# Contrato: el menú de settings (M53) llama esto al cerrarse.
func al_cerrar_settings() -> void:
    # 1. Volúmenes + subtítulos: NO-OP — ya persistidos en cada setter (§16).
    # 2. Opciones (rango dinámico/compresión/dispositivo): auto-guardan en cada
    #    set_opcion() desde la iter. 11 (BUG-092 cerrado) — patrón de set_volumen().
    AudioConfig.set_opcion("rango_dinamico", rango)
    AudioConfig.set_opcion("compresion", activo)
    AudioConfig.set_opcion("dispositivo_salida", nombre)
    # 3. SaveManager NO participa: config ≠ savegame. El trigger de slot es
    #    SaveManager.request_save(slot, reason) — dueño M59, no de settings.
```

**API `set_opcion(clave: String, valor: Variant) -> bool` — IMPLEMENTADA
(iter. 11, BUG-092, Log 1260):** valida la clave en `OPCIONES_VALIDAS`
(`rango_dinamico` / `compresion` / `dispositivo_salida`) y el valor por tipo →
aplica al motor y confirma el estado final → si todo OK: `_opciones[clave] = valor`,
señal `opcion_cambiada` y `_guardar_config()` (mismo camino y misma sección que
`set_volumen()`). Si validación o aplicación fallan → `false` y **no** persiste.
Claves en español, coherentes con `config.cfg` (`volumen_maestro`, …). Detalle
completo en `04-Codigo.md` (Notas del Agente — Iteración 11).

> **Diseño viejo eliminado (2026-10-03):** la clase `AudioSettingsSaver` con su
> `save_settings()` manual hacia `user://settings/audio_settings.json` no existe
> en el código (0 referencias); el disparador real de escritura es el setter.

## 19. Pruebas de calidad

> **Reescrito 2026-10-02 · mimo-v2.6-flash-free 2026-10-02 (opencode).** Antes era una lista de una línea
> por prueba. Ahora cada una dice **qué se hace, qué se espera y quién la
> puede ejecutar**. Cubre **L303, L305 y L307**.

### 19.1 Pruebas automáticas (corren sin usuario)

| # | Prueba | Cómo se comprueba | Resultado medido |
|---|---|---|---|
| A1 | Carga de configuración | `test_audio_config.gd` | 136 checks, 0 fallos (incluye bloque BUG-092) |
| A2 | Aplicación y control por bus | misma suite, `_test_aplicacion_y_control_por_bus()` | (incluido en A1) |
| A3 | Rango dinámico y compresión | `test_audio_effects_m91.gd` | 82 checks, 0 fallos |
| A4 | Subtítulos | `test_subtitles_m91.gd` | 80 checks, 0 fallos |

**298 checks, 0 fallos** (136 + 82 + 80; medido 2026-10-04). Ejecutar:

```
python tools/ci/run_tests.py --module audio --timeout 180      # A1-A3
python tools/ci/run_tests.py --module subtitle --timeout 180   # A4
```

### 19.2 Pruebas de balance de canales — L303

- **Automática:** tono por canal + `get_bus_peak_volume_*_db` → falla si
  algún canal queda por debajo de -60 dB (procedimiento en **§11.5**).
- **Manual (hardware):** el usuario confirma que el canal anunciado suena.

### 19.3 Pruebas de espacialización 3D — L305

- Fuente girando alrededor del oído durante 8 s (procedimiento en
  **§11.4**).
- Esperado: recorrido audible **izquierda → atrás → derecha → frente**.
- ⚠️ La variante **HRTF depende de L88** y queda pendiente (`[?]`).

### 19.4 Pruebas de cambio de dispositivo de salida — L307

1. `AudioServer.get_output_device_list()` → poblar el dropdown.
2. Elegir un segundo dispositivo.
3. Esperado: `AudioServer.get_output_device()` devuelve el nombre nuevo y
   un tono de prueba se oye por él.
4. Volver al original y repetir la comprobación.

> Requiere **dos dispositivos reales** en la máquina → su ejecución es
> **hardware del usuario**; el diseño queda cerrado aquí.

### 19.5 Pruebas manuales de escenario

| Prueba | Cuándo |
|---|---|
| Volúmenes en escenario mixto (música + SFX + voz a la vez) | antes de cada release |
| Subtítulos en es / en / pt | con M87 |
| Rango dinámico (quiet / medio / dinámico) | al cambiar de preset |
| Compresión on/off | al cambiar el toggle |
| Sonidos de interfaz | **cuando existan los assets** (bloqueado) |
