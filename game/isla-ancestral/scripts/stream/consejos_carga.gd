# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-02
#
# M63 §6 (L98): consejos de mundo de la pantalla de carga.
# Base de datos `tips.txt` (una frase por linea; '#' = comentario; lineas en
# blanco ignoradas) + rotacion DETERMINISTA por semilla de partida (M29):
# la misma partida muestra el mismo orden de consejos, que rota con el tiempo.
# LOGICA PURA (metodos `static`): testeable headless sin arbol de escena.
# ⚠️ class_name: helper de logica (NO autoload — GUIA-GODOT §9.17).

class_name ConsejosCarga
extends RefCounted

## Cada cuantos segundos rota el consejo visible (§6: "consejos rotando").
const INTERVALO_ROTACION: float = 6.0
## Ruta por defecto de la base de datos de consejos (junto a weights.json).
const RUTA_DEFAULT: String = "res://data/stream/tips.txt"


## Parsea el texto de `tips.txt`: una frase por linea; '#' = comentario;
## lineas en blanco ignoradas; se recortan los espacios de cada frase.
## El ORDEN se preserva (el indice depende de el).
static func parsear(texto: String) -> PackedStringArray:
	var out := PackedStringArray()
	for linea in texto.split("\n"):
		var limpia := linea.strip_edges()
		if limpia == "" or limpia.begins_with("#"):
			continue
		out.append(limpia)
	return out


## Carga y parsea `tips.txt`. Devuelve VACIO si el archivo no existe, esta
## vacio o no se puede leer: la pantalla de carga debe seguir funcionando sin
## consejos (degradacion silenciosa, no error fatal).
static func cargar(ruta: String = RUTA_DEFAULT) -> PackedStringArray:
	if ruta == "" or not FileAccess.file_exists(ruta):
		return PackedStringArray()
	var texto := FileAccess.get_file_as_string(ruta)
	if texto == "":
		return PackedStringArray()
	return parsear(texto)


## Indice inicial determinista para una semilla de partida (M29), en [0, n-1].
## NO es `semilla % n`: semillas contiguas (partidas creadas seguidas) darian
## el mismo consejo. Se mezcla la semilla para decorrelacionarlas.
## n <= 0 -> 0 (sin consejos).
static func indice_inicial(semilla: int, n: int) -> int:
	if n <= 0:
		return 0
	var h: int = (semilla * 2654435761) ^ (semilla >> 7)
	h = h ^ (h >> 13)
	return int(abs(h)) % n


## Consejo a mostrar para (semilla, tick). `tick` avanza con el tiempo
## (rotacion); el indice da la vuelta con `posmod`. Vacio si no hay consejos.
static func consejo(tips: PackedStringArray, semilla: int, tick: int) -> String:
	var n := tips.size()
	if n == 0:
		return ""
	var i := indice_inicial(semilla, n)
	return tips[posmod(i + tick, n)]
