# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-02
#
# M91 — Dispositivo de salida de audio.
#
# Dos conceptos distintos que el 04-Codigo §11 de este módulo mezcla:
#
#  1. DISPOSITIVOS REALES del sistema (lo que devuelve `dispositivos()`):
#     es lo que el dropdown de settings debe listar y lo que acepta
#     `seleccionar()`. En headless solo existe "Default".
#  2. CATEGORÍAS de uso (auriculares, altavoces, HDMI, Bluetooth): son
#     ETIQUETAS de agrupación del menú, definidas en `CATEGORIAS()`.
#     Mapear categoría -> dispositivo real es trabajo de la UI (M53),
#     porque el motor no expone esa semántica.
#
# API real Godot 4.7.2 — SONDEADA por reflexión, no adivinada (T-107):
#   AudioServer -> get_output_device_list() / get_output_device() /
#                  set_output_device()
#   ⚠ El 04-Codigo §11 usa `get_device_list()` / `set_device()` /
#     `get_device()`, que NO existen en Godot 4.7 (ver GUIA-GODOT/06 T-107).
class_name OutputDeviceManager
extends RefCounted

## Categorías de salida definidas por el diseño (etiquetas de UI).
const CATEGORIAS_LISTA: Array[String] = ["predeterminado", "auriculares", "altavoces", "HDMI", "Bluetooth"]


## Dispositivos de salida reales del sistema (PackedStringArray, no vacío:
## siempre incluye "Default").
static func dispositivos() -> PackedStringArray:
	return AudioServer.get_output_device_list()


## Dispositivo de salida activo.
static func actual() -> String:
	return AudioServer.get_output_device()


## Selecciona un dispositivo por su nombre REAL.
## Devuelve false si no existe (el motor ignora nombres desconocidos, pero
## preferimos rechazarlos explícitamente para que la UI pueda mostrar error).
static func seleccionar(nombre: String) -> bool:
	if not AudioServer.get_output_device_list().has(nombre):
		return false
	AudioServer.set_output_device(nombre)
	return true


## Categorías de uso definidas por el diseño (etiquetas para el menú).
static func categorias() -> Array[String]:
	return CATEGORIAS_LISTA


## ¿El nombre corresponde a una categoría conocida?
static func es_categoria(nombre: String) -> bool:
	return CATEGORIAS_LISTA.has(nombre)
