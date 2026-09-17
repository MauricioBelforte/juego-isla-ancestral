# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M124: Contenido Generado por Usuarios — Test headless iter. 2
# Cubre la parte verificable del módulo: límites de almacenamiento (RF13),
# sanitización del UGC (4K->2K y sin coords del save), telemetría sin PII y la
# regresión de la iter. 1 (catálogo + UgcValidator + autoload UgcManager).
#
# DOS redes de seguridad contra el falso verde / el cuelgue:
#   1. Marcador `_fin("X")` al final de cada bloque: si un error de script aborta
#      la función en silencio, el bloque queda sin marcar y el suite FALLA.
#   2. Watchdog en `_process`: si `_run()` no terminó en FRAMES_MAX frames, el
#      proceso cierra con código 1. Un aborto silencioso NO llega a `quit()` y el
#      SceneTree quedaría colgado para siempre (y el stdout se pierde por
#      buffering al matar el proceso).
#
# ⚠️ El proyecto trata los WARNINGS de GDScript como errores: nada de `:=` sobre
# valores Variant, nada de acceso a método sin tipo (usar `call()`).

extends SceneTree

const RUTA_CATALOGO := "res://data/ugc/ugc_catalog.json"

const _SC_LIMITS := preload("res://scripts/ugc/ugc_limits.gd")
const _SC_SANITIZER := preload("res://scripts/ugc/ugc_sanitizer.gd")
const _SC_TELEMETRY := preload("res://scripts/ugc/ugc_telemetry.gd")
const _SC_VALIDATOR := preload("res://scripts/ugc/ugc_validator.gd")

const BLOQUES := ["A", "B", "C", "D", "E", "F"]
const FRAMES_MAX := 300

var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}
var _frames: int = 0
var _terminado: bool = false
var _config: Dictionary = {}

func _init() -> void:
	call_deferred("_run")

func _process(_delta: float) -> bool:
	_frames += 1
	if not _terminado and _frames > FRAMES_MAX:
		_checks += 1
		_fallos += 1
		_terminado = true
		print("!! WATCHDOG: _run() no terminó en %d frames (posible SCRIPT ERROR que abortó la función)" % FRAMES_MAX)
		print("=== Resumen M124: %d checks, %d fallos ===" % [_checks, _fallos])
		quit(1)
	return false

func _run() -> void:
	print("=== [M124] Test de UGC (iter. 2) ===")
	_cargar_config()
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()
	_verificar_marcadores()
	_terminado = true
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

# --- accesores tipados: evitan pasar Variant a parámetros tipados (warning=error)
func _ok_de(r: Dictionary) -> bool:
	return bool(r.get("ok", false))

func _motivo_de(r: Dictionary) -> String:
	return str(r.get("motivo", ""))

func _mensaje_de(r: Dictionary) -> String:
	return str(r.get("mensaje", ""))

func _cargar_config() -> void:
	if not FileAccess.file_exists(RUTA_CATALOGO):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CATALOGO))
	if typeof(parsed) == TYPE_DICTIONARY:
		_config = parsed as Dictionary

# ============================================================ A: catálogo y límites
func _bloque_a() -> void:
	print("--- A: catálogo y límites data-driven ---")
	_check("A1 catálogo cargado", not _config.is_empty(), "keys=%s" % str(_config.keys()))
	var lim := _SC_LIMITS.desde_catalogo(_config)
	_check("A2 items activos = 200", lim.items_activos_max() == 200, "v=%d" % lim.items_activos_max())
	_check("A3 fotos/día = 50", lim.fotos_por_dia_max() == 50, "v=%d" % lim.fotos_por_dia_max())
	_check("A4 blueprints/día = 20", lim.blueprints_por_dia_max() == 20, "v=%d" % lim.blueprints_por_dia_max())
	_check("A5 bytes/día = 10 MB", lim.bytes_por_dia_max() == 10485760, "v=%d" % lim.bytes_por_dia_max())
	_check("A6 peso foto = 3 MB", lim.peso_max("foto") == 3145728, "v=%d" % lim.peso_max("foto"))
	_check("A7 peso blueprint = 256 KB", lim.peso_max("blueprint") == 262144, "v=%d" % lim.peso_max("blueprint"))
	_check("A8 peso construcción = 512 KB", lim.peso_max("construccion") == 524288, "v=%d" % lim.peso_max("construccion"))
	_check("A9 lado máx foto = 2048 px", lim.lado_max_foto_px() == 2048, "v=%d" % lim.lado_max_foto_px())
	_check("A10 formatos de foto = jpg,webp", lim.formatos_foto() == ["jpg", "webp"], "v=%s" % str(lim.formatos_foto()))
	_check("A11 SLA nsfw 24 h / spam 72 h",
		lim.sla_reporte_horas("nsfw") == 24 and lim.sla_reporte_horas("spam") == 72,
		"nsfw=%d spam=%d" % [lim.sla_reporte_horas("nsfw"), lim.sla_reporte_horas("spam")])
	var vacio := _SC_LIMITS.new({})
	_check("A12 defaults si el catálogo no trae `limites`",
		vacio.items_activos_max() == 200 and vacio.fotos_por_dia_max() == 50 and vacio.peso_max("foto") == 3145728)
	_fin("A")

# ============================================================ B: límites por ítem
func _bloque_b() -> void:
	print("--- B: UgcLimits por ítem ---")
	var lim := _SC_LIMITS.desde_catalogo(_config)
	var r1: Dictionary = lim.validar_item("foto", 3145728, "jpg")
	_check("B1 foto de 3 MB exactos -> ok", _ok_de(r1), str(r1))
	var r2: Dictionary = lim.validar_item("foto", 3145729, "jpg")
	_check("B2 foto de 3 MB+1 -> peso_excedido", _motivo_de(r2) == "peso_excedido", _motivo_de(r2))
	var r3: Dictionary = lim.validar_item("blueprint", 262144, "")
	_check("B3 blueprint de 256 KB -> ok", _ok_de(r3))
	var r4: Dictionary = lim.validar_item("blueprint", 262145, "")
	_check("B4 blueprint de 256 KB+1 -> peso_excedido", _motivo_de(r4) == "peso_excedido", _motivo_de(r4))
	var r5: Dictionary = lim.validar_item("construccion", 524288, "")
	_check("B5 construcción de 512 KB -> ok", _ok_de(r5))
	var r6: Dictionary = lim.validar_item("construccion", 524289, "")
	_check("B6 construcción de 512 KB+1 -> peso_excedido", _motivo_de(r6) == "peso_excedido", _motivo_de(r6))
	var r7: Dictionary = lim.validar_item("foto", 1000, "png")
	_check("B7 formato png -> formato_no_soportado", _motivo_de(r7) == "formato_no_soportado", _motivo_de(r7))
	var r8: Dictionary = lim.validar_item("foto", 1000, ".JPG")
	_check("B8 formato '.JPG' -> ok (normaliza extensión y mayúsculas)", _ok_de(r8), str(r8))
	var r9: Dictionary = lim.validar_item("musica", 1000, "")
	_check("B9 tipo 'musica' (contenido sin archivo) -> tipo_desconocido", _motivo_de(r9) == "tipo_desconocido", _motivo_de(r9))
	var r10: Dictionary = lim.validar_item("foto", 0, "jpg")
	_check("B10 0 bytes -> bytes_invalidos", _motivo_de(r10) == "bytes_invalidos", _motivo_de(r10))
	_check("B11 mensaje en bytes crudos cuando el redondeo humano empata (3.0 MB vs 3.0 MB)",
		_mensaje_de(r2).contains("3145729 B"), _mensaje_de(r2))
	_check("B12 motivo es constante del script y el mensaje no está vacío",
		_motivo_de(r2) == _SC_LIMITS.MOTIVO_PESO_EXCEDIDO and not _mensaje_de(r2).is_empty())
	_fin("B")

# ============================================================ C: límites por cuota
func _bloque_c() -> void:
	print("--- C: UgcLimits por cuota ---")
	var lim := _SC_LIMITS.desde_catalogo(_config)
	var uso: Dictionary = lim.uso_vacio()
	_check("C1 uso_vacio() tiene las 4 claves", uso.size() == 4, "v=%d" % uso.size())
	_check("C2 uso vacío + foto -> ok", _ok_de(lim.validar_cuota(uso, "foto", 1000)))
	uso["items_activos"] = 199
	_check("C3 199 ítems activos -> ok (el tope 200 es inclusivo)", _ok_de(lim.validar_cuota(uso, "foto", 1000)))
	uso["items_activos"] = 200
	var rc: Dictionary = lim.validar_cuota(uso, "foto", 1000)
	_check("C4 200 ítems activos -> cuota_items", _motivo_de(rc) == "cuota_items", _motivo_de(rc))
	_check("C5 el mensaje de cuota_items dice el número y qué hacer", _mensaje_de(rc).contains("200"), _mensaje_de(rc))
	uso["items_activos"] = 0
	uso["fotos_hoy"] = 49
	_check("C6 49 fotos hoy -> ok", _ok_de(lim.validar_cuota(uso, "foto", 1000)))
	uso["fotos_hoy"] = 50
	var rf: Dictionary = lim.validar_cuota(uso, "foto", 1000)
	_check("C7 50 fotos hoy -> cuota_diaria", _motivo_de(rf) == "cuota_diaria", _motivo_de(rf))
	uso["fotos_hoy"] = 0
	uso["blueprints_hoy"] = 19
	_check("C8 19 blueprints hoy -> ok", _ok_de(lim.validar_cuota(uso, "blueprint", 1000)))
	uso["blueprints_hoy"] = 20
	var rb: Dictionary = lim.validar_cuota(uso, "blueprint", 1000)
	_check("C9 20 blueprints hoy -> cuota_diaria", _motivo_de(rb) == "cuota_diaria", _motivo_de(rb))
	uso["blueprints_hoy"] = 0
	uso["bytes_hoy"] = 10485760 - 1024
	_check("C10 bytes justo al tope diario -> ok", _ok_de(lim.validar_cuota(uso, "foto", 1024)))
	uso["bytes_hoy"] = 10485760
	var rby: Dictionary = lim.validar_cuota(uso, "foto", 1024)
	_check("C11 bytes al tope -> cuota_bytes", _motivo_de(rby) == "cuota_bytes", _motivo_de(rby))
	var u2: Dictionary = lim.uso_vacio()
	var c1: Dictionary = lim.consumir(u2, "foto", 1000, "jpg")
	var descontado := int(u2.get("items_activos", -1)) == 1 and int(u2.get("fotos_hoy", -1)) == 1 and int(u2.get("bytes_hoy", -1)) == 1000
	var c2: Dictionary = lim.consumir(u2, "foto", 3145729, "jpg")
	var intacto := int(u2.get("items_activos", -1)) == 1 and int(u2.get("bytes_hoy", -1)) == 1000
	_check("C12 consumir() descuenta y NO muta si la validación falla",
		_ok_de(c1) and descontado and not _ok_de(c2) and intacto)
	_fin("C")

# ============================================================ D: sanitizador
func _bloque_d() -> void:
	print("--- D: UgcSanitizer (4K->2K + sin coords del save) ---")
	_check("D1 4096x2160 necesita redimensión", _SC_SANITIZER.necesita_redimension(Vector2i(4096, 2160), 2048))
	_check("D2 mantiene aspecto: 4096x2160 -> 2048x1080",
		_SC_SANITIZER.tamano_escalado(Vector2i(4096, 2160), 2048) == Vector2i(2048, 1080))
	_check("D3 retrato: 2160x4096 -> 1080x2048",
		_SC_SANITIZER.tamano_escalado(Vector2i(2160, 4096), 2048) == Vector2i(1080, 2048))
	_check("D4 1024x768 no necesita redimensión", not _SC_SANITIZER.necesita_redimension(Vector2i(1024, 768), 2048))
	_check("D5 factor de escala 4096 -> 0.5", is_equal_approx(_SC_SANITIZER.factor_escala(Vector2i(4096, 2160), 2048), 0.5))
	var img: Image = Image.create_empty(4096, 2160, false, Image.FORMAT_RGB8)
	var prep: Dictionary = _SC_SANITIZER.preparar_foto(img, 2048)
	var final: Variant = prep.get("tamano_final", Vector2i.ZERO)
	_check("D6 imagen real 4096x2160 -> 2048x1080", final == Vector2i(2048, 1080), "v=%s" % str(final))
	_check("D7 redimensionada = true", bool(prep.get("redimensionada", false)))
	_check("D8 la imagen ORIGINAL no se muta", img.get_size() == Vector2i(4096, 2160), "v=%s" % str(img.get_size()))
	var chica: Image = Image.create_empty(1024, 768, false, Image.FORMAT_RGB8)
	var prep2: Dictionary = _SC_SANITIZER.preparar_foto(chica, 2048)
	_check("D9 imagen chica: no se redimensiona y conserva tamaño",
		not bool(prep2.get("redimensionada", true)) and prep2.get("tamano_final", Vector2i.ZERO) == Vector2i(1024, 768))
	_check("D10 formato_de_ruta('foto.JPG') = 'jpg'", _SC_SANITIZER.formato_de_ruta("foto.JPG") == "jpg")
	var bp := {
		"nombre": "Casa del muelle",
		"coords": [12, 3, 44],
		"save_id": "slot_3",
		"slot": 3,
		"steam_id": "76561198000000000",
		"piezas": [
			{"tipo": "madera", "posicion": [1, 0, 1]},
			{"tipo": "piedra", "posicion": [2, 0, 0]},
		],
	}
	var saneado: Dictionary = _SC_SANITIZER.sanitizar_blueprint(bp)
	var eliminadas: Variant = saneado.get("eliminadas", [])
	var datos: Dictionary = saneado.get("datos", {}) as Dictionary
	_check("D11 quita coords/save_id/slot/steam_id del sobre",
		eliminadas == ["coords", "save_id", "slot", "steam_id"], "v=%s" % str(eliminadas))
	_check("D12 limpio = false (el sobre traía PII)", not bool(saneado.get("limpio", true)))
	_check("D13 el nombre sobrevive", str(datos.get("nombre", "")) == "Casa del muelle")
	var piezas: Array = datos.get("piezas", []) as Array
	_check("D14 las piezas se copian INTACTAS (la posición relativa ES el contenido)",
		piezas.size() == 2 and str(piezas[0]).contains("posicion"), "v=%s" % str(piezas))
	_check("D15 el blueprint ORIGINAL no se muta",
		bp.has("coords") and (bp.get("piezas", []) as Array).size() == 2)
	var bp2 := {"nombre": "x", "meta": {"world_coords_2": [0, 0, 0]}}
	var s2: Dictionary = _SC_SANITIZER.sanitizar_blueprint(bp2)
	_check("D16 variante 'world_coords_2' detectada por subcadena",
		(s2.get("eliminadas", []) as Array) == ["meta.world_coords_2"], "v=%s" % str(s2.get("eliminadas", [])))
	var bp3 := {"nombre": "limpio", "piezas": [{"tipo": "arena", "posicion": [0, 0, 0]}]}
	var s3: Dictionary = _SC_SANITIZER.sanitizar_blueprint(bp3)
	_check("D17 sobre ya limpio -> limpio = true y sin eliminadas",
		bool(s3.get("limpio", false)) and (s3.get("eliminadas", []) as Array).is_empty())
	var crudo := {"a": 1, "b": "ñandú", "c": [1, 2, 3], "d": {"e": true}}
	var ruta_tmp := "user://ugc_test_tmp.zst"
	var comprimido: bool = _SC_SANITIZER.comprimir_a_archivo(crudo, ruta_tmp)
	var vuelta: Dictionary = _SC_SANITIZER.leer_de_archivo(ruta_tmp)
	_check("D18 roundtrip de compresión ZSTD (FileAccess.open_compressed)",
		comprimido and int(vuelta.get("a", 0)) == 1 and str(vuelta.get("b", "")) == "ñandú"
		and (vuelta.get("c", []) as Array).size() == 3 and bool((vuelta.get("d", {}) as Dictionary).get("e", false)),
		str(vuelta))
	var repetitivo := {"x": "a".repeat(4000)}
	var peso_zstd: int = _SC_SANITIZER.peso_archivo_comprimido(repetitivo, ruta_tmp)
	var peso_crudo: int = _SC_SANITIZER.bytes_de_json(repetitivo)
	_check("D19 el archivo ZSTD pesa menos que el JSON crudo",
		peso_zstd > 0 and peso_zstd < peso_crudo, "zstd=%d crudo=%d" % [peso_zstd, peso_crudo])
	_check("D20 bytes_de_json coincide con el buffer UTF-8",
		_SC_SANITIZER.bytes_de_json(crudo) == _SC_SANITIZER.json_compacto(crudo).to_utf8_buffer().size())
	_check("D21 el temporal de test quedó limpio",
		not FileAccess.file_exists(ruta_tmp), ruta_tmp)
	_fin("D")

# ============================================================ E: telemetría
func _bloque_e() -> void:
	print("--- E: UgcTelemetry sin PII ---")
	var h1: String = _SC_TELEMETRY.hash_alias("tester_01")
	var h2: String = _SC_TELEMETRY.hash_alias("tester_01")
	var h3: String = _SC_TELEMETRY.hash_alias("tester_02")
	_check("E1 hash estable y de 8 hex", h1 == h2 and h1.length() == 8 and h1.is_valid_hex_number(false), "v=%s" % h1)
	_check("E2 hash distinto para alias distinto", h1 != h3, "%s vs %s" % [h1, h3])
	_check("E3 el hash no permite recuperar el alias", h1 != "tester_01" and not h1.contains("tester"))
	var tel := _SC_TELEMETRY.new()
	tel.avanzar(2.5)
	var ok1: bool = tel.registrar("publicar", "creacion_1", "tester_01", {"tipo": "decoracion"})
	tel.avanzar(1.0)
	var ok2: bool = tel.registrar("ver", "creacion_1", "tester_02")
	var ok3: bool = tel.registrar("descargar", "creacion_1", "tester_02")
	_check("E4 registra publicar/ver/descargar", ok1 and ok2 and ok3)
	_check("E5 contadores correctos",
		tel.cantidad("publicar") == 1 and tel.cantidad("ver") == 1 and tel.cantidad("descargar") == 1,
		str(tel.contadores()))
	_check("E6 evento inválido rechazado", not tel.registrar("borrar_todo", "creacion_1"))
	_check("E7 extra con 'email' rechazado", not tel.registrar("ver", "creacion_1", "x", {"email": "a@b.c"}))
	_check("E8 PII anidada rechazada", not tel.registrar("ver", "creacion_1", "x", {"meta": {"steam_id": "123"}}))
	_check("E9 los rechazos NO suman contadores", tel.cantidad("ver") == 1, "ver=%d" % tel.cantidad("ver"))
	var ev: Array = tel.eventos()
	var primero: Dictionary = ev[0] as Dictionary
	_check("E10 el evento guarda el hash, nunca el alias",
		str(primero.get("autor", "")) == h1 and not str(primero.get("autor", "")).contains("tester"))
	_check("E11 timestamp del reloj inyectable (2.5 s)",
		is_equal_approx(float(primero.get("t", -1.0)), 2.5), "v=%s" % str(primero.get("t", -1.0)))
	var res: Dictionary = tel.resumen()
	_check("E12 resumen: 1 ítem único, 2 autores únicos",
		int(res.get("items_unicos", 0)) == 1 and int(res.get("autores_unicos", 0)) == 2, str(res))
	var json: String = tel.exportar_json()
	var tel2 := _SC_TELEMETRY.new()
	_check("E13 import JSON roundtrip",
		tel2.cargar_json(json) and tel2.cantidad("ver") == 1 and tel2.eventos().size() == 3)
	_check("E14 cargar_json rechaza otra versión", not tel2.cargar_json('{"version": 99, "eventos": []}'))
	_check("E15 cargar_json rechaza texto inválido", not tel2.cargar_json("no soy json"))
	var m104: Array = tel.exportar_a_m104()
	var e0: Dictionary = m104[0] as Dictionary
	_check("E16 export a M104 con el shape esperado",
		m104.size() == 3 and e0.has("categoria") and e0.has("autor_hash") and str(e0.get("categoria", "")) == "ugc")
	_check("E17 export a M104 no filtra el alias", not JSON.stringify(m104).contains("tester"))
	_check("E18 claves_pii() detecta sin mutar",
		_SC_TELEMETRY.claves_pii({"email": "x"}) == ["email"] and _SC_TELEMETRY.tiene_pii({"ip": "1.2.3.4"}))
	_fin("E")

# ============================================================ F: regresión iter. 1
func _bloque_f() -> void:
	print("--- F: regresión iter. 1 ---")
	var contenido: Array = _config.get("contenido", []) as Array
	var tipos: Array = _config.get("tipos_validos", []) as Array
	var estados: Array = _config.get("estados_validos", []) as Array
	_check("F1 catálogo: 3 piezas / 5 tipos / 4 estados",
		contenido.size() == 3 and tipos.size() == 5 and estados.size() == 4,
		"%d/%d/%d" % [contenido.size(), tipos.size(), estados.size()])
	var errores: Array = _SC_VALIDATOR.validar(_config)
	_check("F2 UgcValidator: catálogo real sin errores", errores.is_empty(), "v=%s" % str(errores))
	var um: Node = root.get_node_or_null("UgcManager")
	_check("F3 autoload UgcManager presente", um != null)
	if um != null and um.has_method("por_estado"):
		var pub: Array = um.call("por_estado", "publicado")
		_check("F4 UgcManager.por_estado('publicado') = 2", pub.size() == 2, "v=%d" % pub.size())
	else:
		_check("F4 UgcManager.por_estado('publicado') = 2", false, "autoload ausente o sin el método")
	_fin("F")

# ============================================================ marcadores
func _verificar_marcadores() -> void:
	print("--- marcadores de bloque (anti-falso-verde) ---")
	for n in BLOQUES:
		_check("bloque %s ejecutado hasta el final" % n, _vistos.has(n))

func _summary() -> void:
	print("=== Resumen M124: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M124 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M124 OK — todos los checks pasaron")
		quit(0)
