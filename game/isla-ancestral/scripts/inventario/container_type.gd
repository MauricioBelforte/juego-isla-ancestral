# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M14: Inventario — tipos de contenedor (03-Diseno §5)
# Bolsillo 24 | Mochila +16 | Casa 60 | Cofres 16/28/40 | Almacen 240 | Correo 24

class_name ContainerType
extends RefCounted

enum Id {
	BOLSILLO = 0,
	MOCHILA = 1,
	CASA = 2,
	COFRE = 3,
	ALMACEN = 4,
	CORREO = 5,
}

## Tamanos por defecto (slots). El cofre usa 16 base; expansiones M17/M18 ajustan.
const TAMANOS := {
	Id.BOLSILLO: 24,
	Id.MOCHILA: 16,
	Id.CASA: 60,
	Id.COFRE: 16,
	Id.ALMACEN: 240,
	Id.CORREO: 24,
}

## Orden de fallback anti-perdida (regla de oro del diseno):
## bolsillo lleno -> casa llena -> queda en el mundo (pickup)
static func cadena_fallback() -> Array:
	return [Id.BOLSILLO, Id.CASA]

static func nombre(id: int) -> String:
	match id:
		Id.BOLSILLO: return "Bolsillo"
		Id.MOCHILA: return "Mochila"
		Id.CASA: return "Casa"
		Id.COFRE: return "Cofre"
		Id.ALMACEN: return "Almacen"
		Id.CORREO: return "Correo"
	return "?"
