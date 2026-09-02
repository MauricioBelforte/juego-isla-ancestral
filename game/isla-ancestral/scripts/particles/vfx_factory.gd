# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M52 iter 3: VfxFactory — parámetros y creación de GPUParticles3D desde el
# catálogo. `parametros(vfx)` es puro/testeable (headless safe); `crear()`
# instancia el nodo (solo en runtime de render, no en headless).

class_name VfxFactory
extends RefCounted

const RUTA_CATALOGO := "res://data/vfx/vfx_catalog.json"

## Devuelve el catálogo (Array de VFX) o [] si no existe.
static func cargar_catalogo() -> Array:
	if not FileAccess.file_exists(RUTA_CATALOGO):
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CATALOGO))
	if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("vfx")) == TYPE_ARRAY:
		return parsed.get("vfx")
	return []

## Parámetros normalizados de un VFX del catálogo (para configurar partículas).
static func parametros(vfx: Dictionary) -> Dictionary:
	return {
		"color": _color_desde_hex(String(vfx.get("color", "#FFFFFF"))),
		"cantidad": int(vfx.get("cantidad", 20)),
		"emision": float(vfx.get("emision", 0.5)),
		"tipo": String(vfx.get("tipo", "flotante")),
		"id": String(vfx.get("id", "")),
	}

static func crear(container: Node, vfx: Dictionary, position: Vector3 = Vector3.ZERO) -> Node:
	var pm := _parametros_particula(vfx)
	var gp := GPUParticles3D.new()
	gp.amount = int(pm["cantidad"])
	gp.one_shot = true
	gp.explosiveness = 1.0
	gp.position = position
	gp.mesh = _quad()
	gp.process_material = pm["material"]
	container.add_child(gp)
	gp.emitting = true
	return gp

static func _parametros_particula(vfx: Dictionary) -> Dictionary:
	var p := parametros(vfx)
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 45.0
	mat.initial_velocity_min = 0.5
	mat.initial_velocity_max = float(p["emision"]) * 2.0
	mat.gravity = Vector3(0, -0.5, 0)
	mat.color = p["color"]
	return {"cantidad": p["cantidad"], "material": mat}

static func _quad() -> QuadMesh:
	var quad := QuadMesh.new()
	quad.size = Vector2(0.08, 0.08)
	return quad

static func _color_desde_hex(hex: String) -> Color:
	if hex.begins_with("#") and hex.length() == 7:
		var h := hex.substr(1)
		return Color(
			float(_hex_byte(h.substr(0, 2))) / 255.0,
			float(_hex_byte(h.substr(2, 2))) / 255.0,
			float(_hex_byte(h.substr(4, 2))) / 255.0)
	return Color.WHITE

static func _hex_byte(cad: String) -> int:
	var hex_digits := "0123456789abcdef"
	var alto := hex_digits.find(String(cad[0]).to_lower())
	var bajo := hex_digits.find(String(cad[1]).to_lower())
	return (alto * 16 + bajo) if (alto >= 0 and bajo >= 0) else 0
