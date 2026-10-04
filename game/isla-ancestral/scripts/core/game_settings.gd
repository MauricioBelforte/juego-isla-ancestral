extends Node

## GameSettings — Módulo de configuraciones del juego (M46)
## Singleton: guarda/carga ajustes en user://settings.cfg
## Incluye: sensibilidad mouse, invertir Y, volumen, etc.

signal settings_changed

## Sensibilidad del mouse (0.001 a 0.1, default 0.032)
var mouse_sensitivity: float = 0.032
## Invertir eje Y de la cámara
var invert_y: bool = false
## Volumen general (0.0 a 1.0)
## ⚠️ DEPRECATED (2026-10-04, frente M53 Opción A): usar
## AudioConfig.set_volumen() — fuente de verdad de audio (BUG-092, Log 1260).
## Esta variable NO controla ningún bus (cero lectores externos); se conserva
## solo por compatibilidad de lectura de settings.cfg. Módulo dueño: M07
## Arquitectura-General (no M46: la fila 46 es Arte-2D). Doc: M07 plan-actual.
var master_volume: float = 1.0
## Volumen de música — ⚠️ DEPRECATED: AudioConfig.set_volumen("Music", ...) (ver arriba)
var music_volume: float = 0.8
## Volumen de efectos — ⚠️ DEPRECATED: AudioConfig.set_volumen("SFX", ...) (ver arriba)
var sfx_volume: float = 1.0
## Pantalla completa
var fullscreen: bool = false
## Resolución (0= ventana, 1= 1280x720, 2= 1920x1080)
var resolution_index: int = 0

const CONFIG_PATH := "user://settings.cfg"

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("controls", "invert_y", invert_y)
	
	# DEPRECATED (usar AudioConfig.set_volumen() — fuente de verdad de audio
	# (BUG-092, Log 1260)): persistencia de compatibilidad, no controla buses.
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	
	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("video", "resolution_index", resolution_index)
	
	config.save(CONFIG_PATH)
	settings_changed.emit()

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	
	mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", mouse_sensitivity)
	invert_y = config.get_value("controls", "invert_y", invert_y)
	
	# DEPRECATED (AudioConfig.set_volumen()): lectura de compatibilidad, no
	# refleja ni controla los buses de audio reales.
	master_volume = config.get_value("audio", "master_volume", master_volume)
	music_volume = config.get_value("audio", "music_volume", music_volume)
	sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume)
	
	fullscreen = config.get_value("video", "fullscreen", fullscreen)
	resolution_index = config.get_value("video", "resolution_index", resolution_index)
	
	settings_changed.emit()

func reset_defaults() -> void:
	mouse_sensitivity = 0.032
	invert_y = false
	# DEPRECATED (AudioConfig.set_volumen()): reset de compatibilidad; los
	# volúmenes reales se restablecen con AudioConfig.restore_save_data().
	master_volume = 1.0
	music_volume = 0.8
	sfx_volume = 1.0
	fullscreen = false
	resolution_index = 0
	save_settings()
