# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M05: Utilidades basicas de logging y validacion (Fase 1)
# Clase estatica sin autoload: cero acoplamiento, usable desde cualquier capa.
# Los modulos imprimen con su prefijo; los contadores permiten a los tests
# verificar que no hubo errores/avisos durante una ejecucion.

## Registro centralizado de mensajes y verificaciones basicas.
class_name Registro
extends Object

## Cantidad de errores registrados desde el ultimo reinicio de contadores
static var errores: int = 0

## Cantidad de avisos registrados desde el ultimo reinicio de contadores
static var avisos: int = 0

## Mensaje informativo con prefijo de modulo
static func info(modulo: String, mensaje: String) -> void:
	print("[%s] %s" % [modulo, mensaje])

## Aviso no fatal (no corta la ejecucion)
static func aviso(modulo: String, mensaje: String) -> void:
	avisos += 1
	push_warning("[%s] %s" % [modulo, mensaje])

## Error registrado (no corta la ejecucion; los tests lo detectan por contador)
static func error(modulo: String, mensaje: String) -> void:
	errores += 1
	push_error("[%s] %s" % [modulo, mensaje])

## Verificacion basica: registra un error si la condicion es falsa y la devuelve
static func verificar(cond: bool, modulo: String, mensaje: String) -> bool:
	if not cond:
		error(modulo, "Verificacion fallida: " + mensaje)
	return cond

## Verificacion de referencia no nula
static func verificar_no_nulo(obj: Object, modulo: String, mensaje: String) -> bool:
	return verificar(obj != null, modulo, mensaje)

## Reinicia los contadores (inicio de una bateria de pruebas)
static func reiniciar_contadores() -> void:
	errores = 0
	avisos = 0
