# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-03
#
# M17 Construccion iter. 1 — Tipos y motivos compartidos.
#
# NUCLEO PURO: este archivo no depende de nodos, escenas, VoxelTools ni autoloads.
# Se puede cargar en headless sin que el mundo exista (base de las suites).
#
# Renombrado respecto al diseno (03-Diseno.md / 04-Codigo.md): el diseno propone
# `BuildValidator`, pero ese `class_name` global YA lo usa M117 Build System
# (scripts/build/build_validator.gd:10). Declararlo de nuevo rompe M117. Aqui el
# validador de M17 se llama `ConstruccionValidator`.

class_name ConstruccionTipos
extends RefCounted

## Modo de la sesion de construccion (RF1 / RF2).
enum Modo {
	CONSTRUCCION,   ## piezas estructurales (paredes, pisos, techos, puertas...)
	DECORACION,     ## mismo sistema, catalogo filtrado a muebles y decoracion
}

## Permiso de una zona (RF6). Una celda pertenece a lo sumo a una zona efectiva:
## la de AABB mas pequena que la contiene (la mas especifica).
enum Permiso {
	EDIFICABLE,   ## por defecto; se puede construir
	PROTEGIDA,    ## parcelas de NPC, ruinas M25: nunca se construye
	NARRATIVA,    ## zonas de guion: bloqueadas hasta que el guion las libere
	AGUA,         ## solo puentes (receta.sobre_agua)
}

## Motivos de rechazo. `OK` no es un motivo: es la ausencia de motivos.
enum Motivo {
	OK,
	RECETA_INVALIDA,
	FUERA_DE_ZONA,
	ZONA_PROTEGIDA,
	ZONA_NARRATIVA,
	AGUA_NO_PERMITIDA,
	CELDA_OCUPADA,
	SIN_SOPORTE,
	REQUIERE_PARED,
	NPC_EN_CELDA,
	RECURSOS_INSUFICIENTES,
	LIMITE_DE_ZONA,
	NO_HAY_PIEZA,
	NO_DECONSTRUIBLE,
}

## Texto legible por motivo (para HUD y logs de diagnostico).
const TEXTO: Dictionary = {
	Motivo.OK: "valido",
	Motivo.RECETA_INVALIDA: "receta invalida",
	Motivo.FUERA_DE_ZONA: "fuera de zona edificable",
	Motivo.ZONA_PROTEGIDA: "zona protegida (no se puede construir)",
	Motivo.ZONA_NARRATIVA: "zona narrativa bloqueada",
	Motivo.AGUA_NO_PERMITIDA: "solo puentes pueden ir sobre el agua",
	Motivo.CELDA_OCUPADA: "celda ocupada por otra pieza",
	Motivo.SIN_SOPORTE: "sin soporte debajo",
	Motivo.REQUIERE_PARED: "requiere una pared contigua",
	Motivo.NPC_EN_CELDA: "hay un vecino en el lugar",
	Motivo.RECURSOS_INSUFICIENTES: "recursos insuficientes",
	Motivo.LIMITE_DE_ZONA: "limite de piezas de la zona alcanzado",
	Motivo.NO_HAY_PIEZA: "no hay ninguna pieza en esa celda",
	Motivo.NO_DECONSTRUIBLE: "esa pieza no se puede demoler (ruina o evento)",
}

## Texto de un motivo. Tolerante a valores desconocidos.
static func texto(motivo: int) -> String:
	return String(TEXTO.get(motivo, "motivo desconocido (%d)" % motivo))

## Resultado de validacion. Estructura estable que consumen manager, HUD y tests:
##   { "ok": bool, "motivos": Array[int], "detalle": Array[String], "celdas": Array[Vector3i] }
static func resultado_ok(celdas: Array = []) -> Dictionary:
	return {"ok": true, "motivos": [], "detalle": [], "celdas": celdas, "texto": ""}

## Construye un resultado de fallo a partir de motivos (acepta uno o varios).
static func resultado_fallo(motivos: Array, detalle: Array = [], celdas: Array = []) -> Dictionary:
	var textos: Array = []
	for m in motivos:
		textos.append(texto(int(m)))
	return {
		"ok": false,
		"motivos": motivos.duplicate(),
		"detalle": detalle.duplicate(),
		"celdas": celdas,
		"texto": " | ".join(textos),
	}

## Clave canonica de una celda para mapas/diccionarios en memoria.
## Formato estable y ordenable (determinismo de checksum): "x,y,z".
static func clave(celda: Vector3i) -> String:
	return "%d,%d,%d" % [celda.x, celda.y, celda.z]

## Inversa de `clave()`. Devuelve Vector3i(0,0,0) si el texto no es una clave.
static func celda_de_clave(texto: String) -> Vector3i:
	var partes := texto.split(",")
	if partes.size() != 3:
		return Vector3i.ZERO
	return Vector3i(int(partes[0]), int(partes[1]), int(partes[2]))
