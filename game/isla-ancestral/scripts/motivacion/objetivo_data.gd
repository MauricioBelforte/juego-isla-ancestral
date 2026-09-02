# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M94: Retención sin FOMO — ObjetivoData
# Definición de un objetivo (diario/semanal/mensual) como Resource.
# El catálogo se carga desde JSON (data-driven).
# Diseño original (04-Codigo.md §1.1, ObjetivoDiario.cs).

class_name ObjetivoData
extends Resource

enum Plazo { DIARIO, SEMANAL, MENSUAL }

@export var id: String = ""
@export var nombre: String = ""
@export var descripcion: String = ""
@export var plazo: Plazo = Plazo.DIARIO
@export var condicion: String = ""        # ej: "recolectar_madera", "hablar_npc"
@export var cantidad_requerida: int = 1
@export var recompensa_id: String = ""    # id de item o moneda
@export var recompensa_cantidad: int = 1
@export var visible: bool = true