# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-19
#
# M52: preview de calibración visual post-iteración 6 (Log 882: "no verificada").
# Dispara 6 eventos representativos del catálogo VFX a través de VfxDirector
# (pool iter. 5/6) y los deja en vuelo para captura V4. No modifica nada del
# flujo real: solo instancia el director + emisores en una escena aislada.

extends Node3D

const DIRECTOR_GD := preload("res://scripts/particles/vfx_director.gd")
## Eventos representativos para verificación visual. CLAVE = campo "evento" del
## catálogo (trigger name), NO el "id" vfx_* (VfxDirector keya por "evento").
const EVENTOS := [
	["primavera_inicio", "polen (flotante 150)"],
	["fuego_encendido", "humo (40)"],
	["herramienta_golpe", "chispas (18)"],
	["viento_hojas", "hojas (40)"],
	["magia_tecnologica", "magia (50)"],
	["evento_iniciado", "confeti (120)"],
]

var _director
var _contenedor: Node3D
var _t := 0.0

func _ready() -> void:
	_luz_y_suelo()
	_contenedor = Node3D.new()
	add_child(_contenedor)
	_director = DIRECTOR_GD.new()
	_director.set_container(_contenedor)
	add_child(_director)
	_director.precalentar(1)
	_camara()
	print("[M52-PREVIEW] director listo: %d eventos de catálogo; disparando %d en vuelo" % [
		_director.eventos_registrados(), EVENTOS.size()])
	for par in EVENTOS:
		var i := int(EVENTOS.find(par))
		var pos := Vector3(-4.0 + 1.6 * i, 0.5, -2.0)
		var ok: bool = _director.disparar(par[0], pos)
		_marca(pos, "%s: %s" % [par[0], par[1]], ok)
		if not ok:
			print("[M52-PREVIEW] fallo disparo %s (no existe o pool descartado)" % par[0])

func _process(delta: float) -> void:
	_t += delta
	_director.actualizar(delta)

func _luz_y_suelo() -> void:
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-50, 40, 0)
	luz.light_energy = 1.4
	luz.shadow_enabled = true
	add_child(luz)
	var amb := OmniLight3D.new()
	amb.light_energy = 0.5
	amb.position = Vector3(0, 5, 5)
	add_child(amb)
	var suelo := MeshInstance3D.new()
	var plano := PlaneMesh.new()
	plano.size = Vector2(16, 8)
	suelo.mesh = plano
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.14, 0.12)  # fondo oscuro: partículas claras se leen
	suelo.material_override = mat
	suelo.rotation_degrees = Vector3(-90, 0, 0)
	suelo.position.y = -0.4
	add_child(suelo)

func _camara() -> void:
	var cam := Camera3D.new()
	cam.position = Vector3(0, 2.2, 5.4)
	cam.fov = 55.0
	cam.look_at(Vector3(0, 0.8, -2.0))
	add_child(cam)

func _marca(pos: Vector3, texto: String, disparo_ok: bool) -> void:
	var lbl := Label3D.new()
	lbl.text = ("OK " if disparo_ok else "FALLO ") + texto
	lbl.position = Vector3(pos.x, 2.2, pos.z)
	lbl.modulate = Color(0.3, 0.9, 0.4) if disparo_ok else Color(0.95, 0.25, 0.25)
	lbl.scale = Vector3(0.32, 0.32, 0.32)
	lbl.outline_size = 4
	add_child(lbl)
