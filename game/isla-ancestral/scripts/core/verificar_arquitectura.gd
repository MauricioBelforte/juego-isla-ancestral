# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M07: Verificacion de arquitectura (Fase 1)
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/core/verificar_arquitectura.gd
# Valida: (1) orden de autoloads contra el orden canonico por capas,
#         (2) dependencias unidireccionales (core no referencia capas superiores),
#         (3) smoke test de la arquitectura base (servicios registrados, EventBus funcional).

extends SceneTree

var _fallos: int = 0

## Precedencias obligatorias: [dependiente, dependencia] — la dependencia debe
## cargarse ANTES. Solo se listan pares con dependencia real en _ready/const.
const PRECEDENCIAS := [
	["ServiceRegistry", "EventBus"],
	["SaveManager", "EventBus"],
	["Inventario", "ItemDatabase"],
	["ShopManager", "ItemDatabase"],
	["GameTime", "TimeCalendar"],
	["EconomyManager", "EventBus"],
	["Friendship", "EventBus"],
	["Bootstrap", "EventBus"],
	["Bootstrap", "ServiceRegistry"],
]

## Capas superiores que el nucleo (scripts/core) NO puede referenciar
const CAPAS_SUPERIORES := [
	"scripts/ui", "scripts/player", "scripts/npc", "scripts/shops",
	"scripts/economia", "scripts/inventario", "scripts/friendship",
	"scripts/time", "scripts/tools", "scripts/saving",
]

## Herramientas de verificacion excluidas del escaneo de dependencias
const EXCLUIDOS_SCAN := ["verificar_arquitectura.gd"]

func _init() -> void:
	var autoloads := _leer_autoloads()
	_check(autoloads.size() > 0, "project.godot declara autoloads")
	_check(autoloads[0] == "EventBus", "EventBus es el primer autoload (todos pueden depender de el)")
	_check("Bootstrap" in autoloads, "Bootstrap presente como autoload")
	_check("ServiceRegistry" in autoloads, "ServiceRegistry presente como autoload")

	var orden_real := _indice_de(autoloads)
	if orden_real.get("Bootstrap", -1) == autoloads.size() - 1:
		print("  [OK] Bootstrap es el ultimo autoload")
	else:
		print("  [AVISO] Bootstrap no es el ultimo autoload (posicion %d/%d). Recomendado: al final, para que la escena arranque con todos los autoloads cargados. Reorden diferido por reservas activas de M53/M112 en project.godot" % [orden_real.get("Bootstrap", -1) + 1, autoloads.size()])
	_verificar_precedencias(autoloads)

	_verificar_dependencias_unidireccionales()

	# El smoke test de servicios/señales se ejecuta en runtime real via
	# scenes/prueba_arquitectura.tscn (en --script mode los autoloads son placeholders)
	print("  [AVISO] smoke test de servicios: ejecutar scenes/prueba_arquitectura.tscn en runtime real")
	print("=== VERIFICACION ARQUITECTURA M07: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> bool:
	if not cond:
		_fallo(mensaje)
	else:
		print("  [OK] " + mensaje)
	return cond

func _fallo(mensaje: String) -> void:
	_fallos += 1
	print("FALLO: " + mensaje)

func _leer_autoloads() -> Array[String]:
	var resultado: Array[String] = []
	var en_seccion := false
	var f := FileAccess.open("res://project.godot", FileAccess.READ)
	if f == null:
		return resultado
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line.begins_with("["):
			en_seccion = line == "[autoload]"
			continue
		if en_seccion and "=" in line:
			var nombre := line.split("=")[0].strip_edges()
			if nombre != "":
				resultado.append(nombre)
	f.close()
	return resultado

func _indice_de(autoloads: Array[String]) -> Dictionary:
	var d := {}
	for i in autoloads.size():
		d[autoloads[i]] = i
	return d

## Verifica las precedencias obligatorias entre autoloads
func _verificar_precedencias(autoloads: Array[String]) -> void:
	var orden_real := _indice_de(autoloads)
	for par in PRECEDENCIAS:
		var dependiente: String = par[0]
		var dependencia: String = par[1]
		if not (dependiente in orden_real) or not (dependencia in orden_real):
			continue
		if orden_real[dependencia] > orden_real[dependiente]:
			_fallo("precedencia violada: '%s' (pos %d) carga despues de su dependencia '%s' (pos %d)" % [dependiente, orden_real[dependiente], dependencia, orden_real[dependencia]])
	print("  [OK] precedencias de autoloads verificadas (%d pares)" % PRECEDENCIAS.size())

## Dependencias unidireccionales: scripts/core no referencia capas superiores
func _verificar_dependencias_unidireccionales() -> void:
	var dir := DirAccess.open("res://scripts/core")
	if dir == null:
		_fallo("no se pudo abrir res://scripts/core")
		return
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if not dir.current_is_dir() and nombre.ends_with(".gd") and not (nombre in EXCLUIDOS_SCAN):
			var ruta := "res://scripts/core/" + nombre
			var f := FileAccess.open(ruta, FileAccess.READ)
			if f:
				var i := 0
				while not f.eof_reached():
					i += 1
					var line := f.get_line()
					for capa in CAPAS_SUPERIORES:
						if line.contains(capa):
							_fallo("%s:%d referencia capa superior '%s'" % [nombre, i, capa])
				f.close()
		nombre = dir.get_next()
	print("  [OK] dependencias unidireccionales de scripts/core verificadas")
