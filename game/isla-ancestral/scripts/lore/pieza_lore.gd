# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M148: Lore Ambiental — PiezaDeLore
# Modelo de datos de una pieza de lore ambiental: id, canonRef, tipo,
# texto, isla, consumidorId (a qué sistema apunta la pista).
# Diseño original (04-Codigo.md §1.1, PiezaDeLore.cs).

class_name PiezaDeLore
extends Resource

enum Tipo { RUIDA, OBJETO, ARQUITECTURA, VEGETACION, DANO, MURAL, ESTATUA, MAPA, CANCION, NPC_RUMOR, PEZ, PLANTA, MINERAL, TERRENO }

@export var id: String = ""
@export var canon_ref: String = ""           # referencia a M147
@export var tipo: Tipo = Tipo.RUIDA
@export var isla: String = "raiz"
@export var titulo: String = ""
@export var texto: String = ""
@export var consumidor_id: String = ""        # puzzle_id, sello, coleccion, etc.
@export var coords: Vector3 = Vector3.ZERO   # opcional: dónde está en el mundo
@export var temporada: String = ""           # "primavera"/"verano"/"otono"/"invierno" (si es secreto de temporada)