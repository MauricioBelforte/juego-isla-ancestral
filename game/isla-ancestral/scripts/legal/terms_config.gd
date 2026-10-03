# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-03
#
# M125: Términos de Servicio — TermsConfig (Resource)
# Configuración data-driven de los términos: versión, fecha, archivo.

class_name TermsConfig
extends Resource

@export var terms_version: int = 1
@export var terms_date: String = "2026-01-01"
@export var terms_file: String = "res://data/legal/terminos.json"
@export var accept_required: bool = true
@export var show_on_launch: bool = true
