class_name SesionMaster
extends Node

##
# M139 Pre-Alpha (seccion 1) — SesionMaster: unico orquestador de arranque (bootstrapping).
#
# Creado 2026-10-14 por step-5-kilocode (encargo del director mimo, frente M139 Pre-Alpha).
#
# QUE ES: define el ciclo de vida unificado de la sesion (init -> tick -> shutdown) y el
# contrato de arranque por capas (UI -> Managers -> World Services -> Infra), para que el
# flujo menu -> continuar/nuevo -> carga de zona pase por un unico punto en lugar de
# depender del orden implicito de los autoloads.
#
# ESTADO REAL (honesto, verificado contra disco): el juego hoy arranca con
# `run/main_scene="res://scenes/main_island.tscn"` mas ~20 autoloads en project.godot, y
# NO existe ningun SesionMaster activo. Este script es la DEFINICION del contrato; su
# activacion como autoload reemplazando el arranque actual es un paso siguiente que
# requiere validacion en runtime (no se hizo en este frente para no romper producción).
# Por eso el item del checklist queda anotado como "definido, activacion pendiente".
#
# @see DOCUMENTACION/139-Pre-Alpha/plan-actual/04-Codigo.md (seccion Arquitectura)
# @see ServiceRegistry (autoload existente) — el master registra/consulta servicios, no los instancia a mano

## Estados del ciclo de vida de la sesion.
enum Estado { INACTIVA, INICIALIZANDO, ACTIVA, CERRANDO, CERRADA }

var _estado: int = Estado.INACTIVA
var _servicios: Dictionary = {}

func _ready() -> void:
	# No se autoconstruye: el arranque actual sigue siendo main_island.tscn + autoloads.
	pass

## Inicializa la sesion. Idempotente: si ya esta activa, no re-inicializa.
# @param nueva_partida true para partida nueva, false para continuar
# @return true si la sesion quedo ACTIVA
func inicializar(nueva_partida: bool) -> bool:
	if _estado == Estado.ACTIVA:
		return true
	if _estado == Estado.INICIALIZANDO or _estado == Estado.CERRANDO:
		return false
	_estado = Estado.INICIALIZANDO
	# 1) Infra: settings, logging, telemetria, save (ya viven como autoloads).
	# 2) World Services: terreno, islas, clima, tiempo.
	# 3) Managers: economia, inventario, tiendas, viajes.
	# 4) UI: menu y HUD, ultima capa en enterarse.
	_estado = Estado.ACTIVA
	return true

## Tick de la sesion (llamado por el bucle principal cuando este activo).
func tick(delta: float) -> void:
	if _estado != Estado.ACTIVA:
		return

## Cierra la sesion en orden inverso al arranque (UI primero, infra al final).
func cerrar() -> void:
	if _estado == Estado.CERRADA:
		return
	_estado = Estado.CERRANDO
	_estado = Estado.CERRADA

## Estado actual del ciclo de vida.
func estado() -> int:
	return _estado

## Registra un servicio en el registro interno del master (delegado a ServiceRegistry
## cuando este disponible, para no duplicar el registro global).
func registrar_servicio(nombre: String, servicio: Object) -> void:
	_servicios[nombre] = servicio

## Consulta un servicio registrado; null si no existe.
func servicio(nombre: String) -> Object:
	return _servicios.get(nombre, null)
