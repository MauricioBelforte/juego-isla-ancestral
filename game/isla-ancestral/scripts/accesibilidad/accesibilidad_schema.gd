# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M58: AccesibilidadSchema — validación de la configuración de accesibilidad
# (tamaño de texto, contraste, daltonismo, efectos, subtítulos...).
class_name AccesibilidadSchema
extends RefCounted

const TAMANOS := ["pequeno", "medio", "grande"]
const CONTRASTES := ["alto", "medio", "bajo"]
const DALTONISMOS := ["ninguno", "protanopia", "deuteranopia", "tritanopia"]

## Devuelve Array[String] con los problemas (vacío si es válido).
static func validar(config: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	if not TAMANOS.has(String(config.get("tamano_texto", ""))):
		errores.append("tamano_texto inválido: %s" % config.get("tamano_texto", ""))
	if not CONTRASTES.has(String(config.get("contraste", ""))):
		errores.append("contraste inválido: %s" % config.get("contraste", ""))
	if not DALTONISMOS.has(String(config.get("modo_daltonismo", ""))):
		errores.append("modo_daltonismo inválido: %s" % config.get("modo_daltonismo", ""))
	for flag in ["reducir_efectos", "reducir_parpadeo", "alta_visibilidad_interactivos",
			"sonido_visual", "subtitulos", "sensor_respeto", "persistencia_auto"]:
		if typeof(config.get(flag, null)) != TYPE_BOOL:
			errores.append("flag no booleano: %s" % flag)
	return errores

## Contraste relativo WCAG (luminancia) para pares de colores usados en la UI.
static func contraste_relativo(color1: Color, color2: Color) -> float:
	var l1 := _luminancia(color1)
	var l2 := _luminancia(color2)
	var max_l := maxf(l1, l2)
	var min_l := minf(l1, l2)
	return (max_l + 0.05) / (min_l + 0.05)

static func _luminancia(c: Color) -> float:
	var r := c.r if c.r <= 0.03928 else pow((c.r + 0.055) / 1.055, 2.4)
	var g := c.g if c.g <= 0.03928 else pow((c.g + 0.055) / 1.055, 2.4)
	var b := c.b if c.b <= 0.03928 else pow((c.b + 0.055) / 1.055, 2.4)
	return 0.2126 * r + 0.7152 * g + 0.0722 * b
