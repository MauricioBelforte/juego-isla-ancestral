# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-27
#
# M55 (Diario del Jugador) - resolutor de ICONOS de entrada.
# Cubre los items de la familia iconos del 05-Checklist:
#   L93  (validar iconos de gemas/minerales contra el catalogo),
#   L117 (validar iconografia de Sellos, M46),
#   L203 (manejar icono faltante con fallback generico),
#   L77/L85 (siluetas de bestiario y hojas contra el catalogo M46).
#
# Contrato (sin campo nuevo en el JSON del diario, para no duplicar la
# fuente de verdad): el id del icono se DERIVA del id de la entrada con las
# convenciones de prefijos que M46 ya declara en
# `data/arte2d/inventario_2d.json > convenciones.prefijos`:
#     icono_objeto -> ico_   simbolo -> sym_   retrato -> pt_
#     ilustracion  -> illus_ insignia -> badge_ ui -> ui_art_
#
# Tres niveles de resolucion (L203), en orden:
#   1. `icono` declarado en la entrada (campo opcional del catalogo).
#   2. id derivado presente en el inventario M46 -> ruta convencional.
#   3. fallback GENERICO procedural (textura 16x16 generada en codigo).
# Nunca devuelve null: la fila del diario no puede quedar sin icono.
#
# La DEUDA se MIDE, no se silencia (patron M72): `inventario_iconos()` cuenta
# entradas con id en el inventario, sin id y con asset en disco. Hoy el
# inventario M46 declara 48 ids y NINGUNO tiene archivo: la deuda es arte,
# no codigo. Este modulo no inventa arte.
#
# Uso: preload("res://scripts/diario/iconos_diario.gd")

extends RefCounted

const RUTA_INVENTARIO_M46 := "res://data/arte2d/inventario_2d.json"

## Prefijo de familia por categoria (convenciones M46). "" = no derivable.
const FAMILIA_POR_CATEGORIA := {
	"personajes": "pt_",
	"lugares": "illus_",
	"criaturas": "ico_",
	"sellos": "sym_",
	"misiones": "",
	"eventos": "",
	"cartas": "",
	"recetas": "ico_",
	"plantas": "ico_",
	"minerales": "ico_",
	"ruinas": "illus_",
	"descubrimientos": "ico_",
	"pistas": "",
	"fotografias": "illus_",
}

## Prefijo que YA lleva el id de la entrada y hay que quitar antes de derivar.
## Se quita UNA sola vez: `mineral_mineral_cobre` -> `mineral_cobre` (el doble
## prefijo es deuda de datos del catalogo, ver 04-Codigo.md iter. 6).
const PREFIJO_ID_POR_CATEGORIA := {
	"personajes": "vecino_",
	"lugares": "lugar_",
	"criaturas": "pez_",
	"sellos": "sello_",
	"misiones": "mision_",
	"eventos": "evento_",
	"cartas": "carta_",
	"recetas": "receta_",
	"plantas": "planta_",
	"minerales": "mineral_",
	"ruinas": "ruina_",
	"descubrimientos": "descubrimiento_",
	"pistas": "pista_",
	"fotografias": "foto_",
}

## Carpeta donde vivira cada familia de asset (hoy todas vacias: deuda M46).
const CARPETA_POR_FAMILIA := {
	"ico_": "res://assets/2d/iconos/",
	"sym_": "res://assets/2d/simbolos/",
	"pt_": "res://assets/2d/retratos/",
	"illus_": "res://assets/2d/ilustraciones/",
	"badge_": "res://assets/2d/insignias/",
	"ui_art_": "res://assets/2d/ui/",
	"logo_": "res://assets/2d/logo/",
}

## Extensiones que se prueban al buscar el archivo del asset.
const EXTENSIONES: Array[String] = [".png", ".webp", ".svg"]

## Tamano del icono de fallback (px). Cuadrado y potencia de 2 (filtro nearest).
const TAM_FALLBACK := 16

## Color del fallback generico: gris calido neutro, sin depender del tema.
const COLOR_FALLBACK := Color(0.55, 0.51, 0.44, 1.0)
const COLOR_FALLBACK_BORDE := Color(0.30, 0.27, 0.23, 1.0)

## Cache del inventario M46 y de la textura de fallback (una sola instancia:
## el fallback se comparte entre filas y no se filtra en VRAM por entrada).
static var _inv: Dictionary = {}
static var _inv_cargado: bool = false
static var _fallback: Texture2D = null
static var _fallback_usos: int = 0


## ── Inventario M46 ────────────────────────────────────────────────

## Lee `data/arte2d/inventario_2d.json` una sola vez. Devuelve {id: asset}.
## Diccionario VACIO si el archivo falta o no parsea: el llamador distingue
## "inventario vacio" de "sin iconos" con `inventario_disponible()`.
static func inventario_m46() -> Dictionary:
	if _inv_cargado:
		return _inv
	_inv_cargado = true
	_inv = {}
	var txt := FileAccess.get_file_as_string(RUTA_INVENTARIO_M46)
	if txt.is_empty():
		return _inv
	var parseado: Variant = JSON.parse_string(txt)
	if typeof(parseado) != TYPE_DICTIONARY:
		return _inv
	var d: Dictionary = parseado
	for a in (d.get("assets", []) as Array):
		if typeof(a) == TYPE_DICTIONARY:
			var id := String((a as Dictionary).get("id", ""))
			if not id.is_empty():
				_inv[id] = a
	return _inv


static func inventario_disponible() -> bool:
	return inventario_m46().size() > 0


## Solo para tests: fuerza la relectura del inventario.
static func _recargar_inventario() -> void:
	_inv_cargado = false
	_inv = {}
	inventario_m46()


## ── Derivacion del id ─────────────────────────────────────────────

## Id de icono derivado del id de entrada. "" si la categoria no tiene familia
## de arte declarada en M46 (misiones/eventos/cartas/pistas) o si el id no
## aporta resto util. NO consulta el disco ni el inventario: es puro.
static func id_derivado(categoria: String, entrada_id: String) -> String:
	var familia := String(FAMILIA_POR_CATEGORIA.get(categoria, ""))
	if familia.is_empty():
		return ""
	var resto := entrada_id
	var prefijo := String(PREFIJO_ID_POR_CATEGORIA.get(categoria, ""))
	if not prefijo.is_empty() and resto.begins_with(prefijo):
		resto = resto.substr(prefijo.length())
	resto = resto.strip_edges()
	if resto.is_empty():
		return ""
	return familia + resto


## Carpeta convencional de un id de icono segun su familia ("" si no hay).
static func carpeta_de(id_icono: String) -> String:
	for familia in CARPETA_POR_FAMILIA:
		if id_icono.begins_with(String(familia)):
			return String(CARPETA_POR_FAMILIA[familia])
	return ""


## Ruta del asset en disco para un id de icono ("" si no hay carpeta).
## Prueba las extensiones de EXTENSIONES; devuelve la PRIMERA que existe.
## `existe` se informa aparte (resolver) para no confundir "sin ruta
## convencional" con "archivo ausente".
static func ruta_asset(id_icono: String) -> String:
	var carpeta := carpeta_de(id_icono)
	if carpeta.is_empty():
		return ""
	for ext in EXTENSIONES:
		var ruta := carpeta + id_icono + String(ext)
		if ResourceLoader.exists(ruta):
			return ruta
	return ""


## ── Resolucion en 3 niveles (L203) ────────────────────────────────

## Resuelve el icono de una entrada. SIEMPRE devuelve una textura no nula.
## Devuelve {id, fuente, ruta, textura, en_inventario, asset_en_disco}:
##   fuente: "declarado" | "derivado" | "fallback"
##   en_inventario: el id figura en el inventario M46 (aunque no haya archivo)
##   asset_en_disco: existe el archivo del asset
static func resolver(categoria: String, entrada_id: String, declarado: String = "") -> Dictionary:
	var id := declarado.strip_edges()
	var fuente := "declarado"
	if id.is_empty():
		id = id_derivado(categoria, entrada_id)
		fuente = "derivado"
	if not id.is_empty():
		var ruta := ruta_asset(id)
		if not ruta.is_empty():
			var tex: Variant = load(ruta)
			if tex is Texture2D:
				return {
					"id": id,
					"fuente": fuente,
					"ruta": ruta,
					"textura": tex,
					"en_inventario": inventario_m46().has(id),
					"asset_en_disco": true,
				}
		# El id existe pero el arte no: cae al fallback CONSERVANDO el id
		# (asi el inventario puede reportar la deuda por id, no "sin icono").
		_fallback_usos += 1
		return {
			"id": id,
			"fuente": "fallback",
			"ruta": "",
			"textura": textura_fallback(),
			"en_inventario": inventario_m46().has(id),
			"asset_en_disco": false,
		}
	_fallback_usos += 1
	return {
		"id": "",
		"fuente": "fallback",
		"ruta": "",
		"textura": textura_fallback(),
		"en_inventario": false,
		"asset_en_disco": false,
	}


## Textura generica de respaldo: 16x16, relleno + borde de 1 px. Se genera en
## codigo (no hay arte en el repo) y se CACHEA: una sola instancia.
static func textura_fallback() -> Texture2D:
	if _fallback != null:
		return _fallback
	var img := Image.create(TAM_FALLBACK, TAM_FALLBACK, false, Image.FORMAT_RGBA8)
	img.fill(COLOR_FALLBACK)
	for i in TAM_FALLBACK:
		img.set_pixel(i, 0, COLOR_FALLBACK_BORDE)
		img.set_pixel(i, TAM_FALLBACK - 1, COLOR_FALLBACK_BORDE)
		img.set_pixel(0, i, COLOR_FALLBACK_BORDE)
		img.set_pixel(TAM_FALLBACK - 1, i, COLOR_FALLBACK_BORDE)
	_fallback = ImageTexture.create_from_image(img)
	return _fallback


## Cuantas veces se pidio el fallback (observabilidad del guardian de test).
static func usos_fallback() -> int:
	return _fallback_usos


static func _reset_usos_fallback() -> void:
	_fallback_usos = 0


## ── Inventario MEDIDO de la iconografia del diario ────────────────

## Recorre el catalogo parseado y mide la iconografia real.
## `catalogo` = Dictionary con la clave "categorias" (formato del JSON).
## Devuelve conteos y las listas de deuda:
##   entradas, con_id_derivado, en_inventario, con_asset,
##   sin_familia, sin_id_en_inventario (Array[String]),
##   familia_disponible (Array[String]: id NO exacto pero si su familia M46)
static func inventario_iconos(catalogo: Dictionary) -> Dictionary:
	var inv := inventario_m46()
	var ids_inv: Array = inv.keys()
	var r := {
		"entradas": 0,
		"con_id_derivado": 0,
		"en_inventario": 0,
		"con_asset": 0,
		"sin_familia": 0,
		"sin_id_en_inventario": [],
		"familia_disponible": [],
		"declarados": 0,
	}
	var sin_id: Array = r["sin_id_en_inventario"]
	var fam: Array = r["familia_disponible"]
	for c in (catalogo.get("categorias", []) as Array):
		if typeof(c) != TYPE_DICTIONARY:
			continue
		var cat := String((c as Dictionary).get("id", ""))
		for e in ((c as Dictionary).get("entradas", []) as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ent: Dictionary = e
			r["entradas"] = int(r["entradas"]) + 1
			var declarado := String(ent.get("icono", ""))
			if not declarado.is_empty():
				r["declarados"] = int(r["declarados"]) + 1
			var id := declarado if not declarado.is_empty() else id_derivado(cat, String(ent.get("id", "")))
			if id.is_empty():
				r["sin_familia"] = int(r["sin_familia"]) + 1
				continue
			r["con_id_derivado"] = int(r["con_id_derivado"]) + 1
			if inv.has(id):
				r["en_inventario"] = int(r["en_inventario"]) + 1
			else:
				sin_id.append(id)
				# ¿existe al menos el simbolo de la FAMILIA (prefijo mas corto)?
				for cand in ids_inv:
					var cid := String(cand)
					if id.begins_with(cid + "_") or id == cid:
						fam.append("%s <- %s" % [id, cid])
						break
			if not ruta_asset(id).is_empty():
				r["con_asset"] = int(r["con_asset"]) + 1
	return r


## Ids con icono declarado o derivado que NO figuran en el inventario M46.
## Es la deuda medible: no dice "falta el dibujo", dice "el id no esta en el
## catalogo de arte" (puede ser deuda de M46 o id mal formado en M55).
static func iconos_ausentes(catalogo: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for x in (inventario_iconos(catalogo).get("sin_id_en_inventario", []) as Array):
		out.append(String(x))
	return out
