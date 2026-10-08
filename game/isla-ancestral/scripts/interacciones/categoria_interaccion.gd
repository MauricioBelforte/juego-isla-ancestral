# Modelo: atria-dawn-preview
# Plataforma: Kilo Code
# Fecha: 2026-10-02
#
# M70: Interacciones - CategoriaInteraccion (Resource).
# Configura una categoria semantica de interaccion: prioridad base, etiqueta
# localizable, icono, sonido y si requiere linea de vision.
# Parte del catalogo data/interacciones/categorias_interaccion.tres.

class_name CategoriaInteraccion
extends Resource

@export var id: StringName = &""
# Clave de localizacion para la linea de contexto del HUD (pasa por tr()).
@export var etiqueta: String = ""
# Ruta del icono (M45 provee los assets). Vacio = icono por defecto.
@export var icono: String = ""
# Clave/sonido del chirrido de la categoria (M43/M44 reproducen).
@export var sonido: String = ""
# Prioridad base de la categoria (RF5: mayor gana en empate). Se suma a la
# prioridad declarada por el interactuable.
@export var prioridad_base: int = 0
# Si la categoria requiere linea de vision despejada (RF4: npc, cofre,
# puerta, evento). Las demas se seleccionan aunque haya geometria entre medio.
@export var requiere_vision: bool = false
