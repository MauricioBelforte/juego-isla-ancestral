# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-23
#
# M56/M55: interfaz IDiaryPhotoProvider — desacople del diario M55 respecto
# del PhotoService M56. Sigue el patron de interfaces/i_saveable.gd.
#
# Contrato: quien IMPLEMENTE esta interfaz (el diario M55) podra pedir
# catalogo de fotos y subscribirse a foto_tomada sin importar PhotoService
# (duck-typing, regla seccion 15: se conectan por senal/metodos, no por
# referencia directa).
#
# QA: scripts/foto/qa_m56_diary_provider.gd (verifica que una estructura
# dummy que implementa el contrato pasa el duck-typing del verificador).

extends RefCounted
class_name IDiaryPhotoProvider

## Devuelve el catalogo de fotos para el diario.
## @return Array[Dictionary]: cada entrada con {ruta: String, resultado: Dictionary}
##          (los mismos campos que emite PhotoService.foto_tomada).
func obtener_fotos_diario() -> Array:
	return []

## Devuelve las fotos visibles segun el capitulo/anio de la historia (M29).
## @return Array[Dictionary] (mismo esquema que obtener_fotos_diario)
func obtener_fotos_visibles(dia_actual: int) -> Array:
	return []

## Se subscribe a la senal PhotoService.foto_tomada y agrega las nuevas fotos
## al diario. Debe ser tolerante a que PhotoService no exista (sin crash).
## @return bool: true si la subscripcion quedo activa.
func conectar_foto_tomada() -> bool:
	return false
