# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-19
#
# M62: Memoria — TextureMemory
# Detectores de los edge cases de texturas y del "crecimiento por frame"
# (diseño §5 y checklist §K). No carga ni descarga nada por su cuenta: es
# lógica pura y medible, para que M09/M63 decidan y el panel M110 muestre.
#
# Casos cubiertos (checklist §K):
#   · textura gigante (4K simple sin mips): el detector la identifica y la
#     degrada automáticamente — con la cuenta de MB ahorrados;
#   · atlas lleno: política de evicción por orden de uso (LRU) que devuelve
#     QUÉ evictó, para poder registrarlo en el log (M103);
#   · nieve/niebla (M32) que crea nodos por frame: detector de nodos por
#     frame con alerta.
#
# Regla de diseño que respeta: el 62 vigila y decide, no renderiza. Por eso
# `degradar()` devuelve una textura NUEVA y no muta la original.

class_name TextureMemory
extends RefCounted

## A partir de este lado (px) una textura se considera "gigante".
## Configurable para que los tests no tengan que reservar 64 MB de verdad.
var umbral_lado: int = 4096

## Bytes por píxel asumidos para estimar peso (RGBA8).
var bytes_por_pixel: int = 4

## ── Texturas ─────────────────────────────────────────────────────────────

## Peso estimado en MB (ancho × alto × bpp). No incluye mips.
func peso_mb(tex: Texture2D) -> float:
	if tex == null:
		return 0.0
	var px := tex.get_width() * tex.get_height()
	return snappedf(float(px * bytes_por_pixel) / (1024.0 * 1024.0), 0.01)

func es_gigante(tex: Texture2D) -> bool:
	if tex == null:
		return false
	return tex.get_width() >= umbral_lado or tex.get_height() >= umbral_lado

## ¿Tiene mips? Se mira la Image: `Texture2D` no expone `has_mipmaps()`.
func sin_mips(tex: Texture2D) -> bool:
	if tex == null:
		return true
	var img := tex.get_image()
	if img == null:
		return true
	return not img.has_mipmaps()

## El caso del checklist §K: gigante Y sin mips → hay que degradar.
func requiere_degradacion(tex: Texture2D) -> bool:
	return es_gigante(tex) and sin_mips(tex)

## Degrada una textura gigante: reduce por `factor` y genera mips.
## Devuelve una textura NUEVA (no muta la original) o null si no se pudo.
func degradar(tex: Texture2D, factor: int = 2) -> Texture2D:
	if tex == null or factor < 2:
		return null
	var img := tex.get_image()
	if img == null:
		return null
	var ancho := maxi(1, img.get_width() / factor)
	var alto := maxi(1, img.get_height() / factor)
	img.resize(ancho, alto, Image.INTERPOLATE_LANCZOS)
	if not img.has_mipmaps():
		img.generate_mipmaps()
	return ImageTexture.create_from_image(img)

## Aplica la degradación sólo si hace falta. Devuelve {aplicada, textura, mb_antes, mb_despues}.
func aplicar_politica(tex: Texture2D, factor: int = 2) -> Dictionary:
	var antes := peso_mb(tex)
	if not requiere_degradacion(tex):
		return {"aplicada": false, "textura": tex, "mb_antes": antes, "mb_despues": antes}
	var nueva := degradar(tex, factor)
	if nueva == null:
		return {"aplicada": false, "textura": tex, "mb_antes": antes, "mb_despues": antes}
	return {"aplicada": true, "textura": nueva, "mb_antes": antes, "mb_despues": peso_mb(nueva)}

## ── Atlas: evicción por orden de uso (LRU) ───────────────────────────────

## `entradas` = [{nombre: String, mb: int, ultimo_uso: int}].
## Evicta las de `ultimo_uso` MÁS ANTIGUO hasta liberar `hasta_mb` o alcanzar
## `max_entradas`. Devuelve las entradas evictadas (copias), para el log.
func evictar_atlas(entradas: Array, hasta_mb: int, max_entradas: int) -> Array:
	var ordenadas: Array = []
	for e in entradas:
		if typeof(e) == TYPE_DICTIONARY:
			ordenadas.append((e as Dictionary).duplicate())
	ordenadas.sort_custom(func(a, b):
		var ua := int(a.get("ultimo_uso", 0))
		var ub := int(b.get("ultimo_uso", 0))
		if ua != ub:
			return ua < ub
		return String(a.get("nombre", "")) < String(b.get("nombre", ""))
	)
	var evictadas: Array = []
	var liberados := 0
	for e in ordenadas:
		if liberados >= hasta_mb or evictadas.size() >= max_entradas:
			break
		liberados += int(e.get("mb", 0))
		evictadas.append(e)
	return evictadas

## Cuántas entradas de atlas están en uso "reciente" (para el panel M110).
func entradas_recientes(entradas: Array, desde_ms: int, ahora_ms: int) -> int:
	var n := 0
	for e in entradas:
		if typeof(e) == TYPE_DICTIONARY and int((e as Dictionary).get("ultimo_uso", 0)) >= desde_ms:
			n += 1
	return n


## ── Detector de nodos por frame (nieve/niebla M32) ───────────────────────
## Un sistema que crea nodos cada frame no "leakea" en el sentido clásico:
## crece de forma sostenida y sólo se ve mirando la DERIVADA. Este detector
## mide nodos por frame desde el primer muestreo y avisa si supera el umbral.
class DetectorNodosPorFrame extends RefCounted:
	var umbral_por_frame: float = 2.0
	var _inicial: int = -1
	var _frames: int = 0
	var _ultimo_total: int = -1

	func reiniciar() -> void:
		_inicial = -1
		_frames = 0
		_ultimo_total = -1

	## Llamar una vez por frame con el total de nodos vivos.
	func muestrear(total_nodos: int) -> void:
		if _inicial < 0:
			_inicial = total_nodos
		_ultimo_total = total_nodos
		_frames += 1

	func frames_muestreados() -> int:
		return _frames

	## Nodos netos creados por frame desde el inicio del muestreo.
	func nodos_por_frame() -> float:
		if _inicial < 0 or _frames <= 1:
			return 0.0
		return snappedf(float(_ultimo_total - _inicial) / float(_frames - 1), 0.001)

	func excede_umbral() -> bool:
		return nodos_por_frame() > umbral_por_frame

	## Mensaje de alerta listo para el log (M103). "" si no hay nada que avisar.
	func alerta() -> String:
		if not excede_umbral():
			return ""
		return "crecimiento de nodos por frame: %.2f (umbral %.2f) en %d frames" % [
			nodos_por_frame(), umbral_por_frame, _frames]
