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
var master_volume: float = 1.0
## Volumen de música
var music_volume: float = 0.8
## Volumen de efectos
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
	
	master_volume = config.get_value("audio", "master_volume", master_volume)
	music_volume = config.get_value("audio", "music_volume", music_volume)
	sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume)
	
	fullscreen = config.get_value("video", "fullscreen", fullscreen)
	resolution_index = config.get_value("video", "resolution_index", resolution_index)
	
	settings_changed.emit()

func reset_defaults() -> void:
	mouse_sensitivity = 0.032
	invert_y = false
	master_volume = 1.0
	music_volume = 0.8
	sfx_volume = 1.0
	fullscreen = false
	resolution_index = 0
	save_settings()
