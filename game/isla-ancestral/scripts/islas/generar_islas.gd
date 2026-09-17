# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M27: Islas del Mundo — GENERADOR del dataset (13 islas + índice).
# Construye los 13 `IslandDefinition` (aurora + 12 satélites) y el
# `Archipielago`, VALIDA cada definición y sólo entonces guarda los `.tres`.
# Igual que el generador de M68: el dataset no se edita a mano, se regenera.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/islas/generar_islas.gd
#
# Layout de anclas: NO se serializa (las pone M10 en runtime). El test
# `test_islas_m27.gd` reproduce una disposición de referencia con la geometría
# de anillos del diseño §5 para validar solapamientos:
#   NUCLEO  aurora      centro (0,0)
#   CERCANO 3 islas     radio 1100 m  (máx anillo 1600)
#   MEDIO   3 islas     radio 2400 m  (máx anillo 3200)
#   LEJANO  6 islas     radio 4400 m  (máx anillo 6400)
# Verificado: distancia mínima entre islas >= radio_a + radio_b + 64.

extends SceneTree

const RUTA_DEFINICIONES := "res://data/islas/definiciones"
const RUTA_ARCHIPIELAGO := "res://data/islas/archipielago.tres"

var _creadas: Array[String] = []
var _errores: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== [M27] Generador del archipiélago (13 islas) ===")
	DirAccess.make_dir_recursive_absolute(RUTA_DEFINICIONES)

	var datos: Array = _catalogo()
	var definiciones: Array[IslandDefinition] = []
	var esperadas := PackedStringArray()

	for d in datos:
		var def: IslandDefinition = _construir(d)
		var errores: Array[String] = def.validar()
		if not errores.is_empty():
			for e in errores:
				_errores.append("definición %s inválida: %s" % [def.id, e])
			continue
		definiciones.append(def)
		esperadas.append(String(def.id))

	if not _errores.is_empty():
		print("  [ABORT] %d definiciones inválidas; no se guarda nada:" % _errores.size())
		for e in _errores:
			print("    - %s" % e)
		quit(1)
		return

	# Guardar cada definición.
	for def in definiciones:
		var ruta: String = "%s/%s.tres" % [RUTA_DEFINICIONES, def.id]
		var err: int = ResourceSaver.save(def, ruta)
		if err != OK:
			_errores.append("no se pudo guardar %s (err=%d)" % [ruta, err])
			continue
		_creadas.append(String(def.id))
		print("  [OK] %-12s %-22s anillo=%s radio=%d bioma=%s"
			% [def.id, def.nombre_display, def.anillo_nombre(), def.radio, def.bioma_base_nombre()])

	# Índice del archipiélago (orden estable; Aurora primera).
	esperadas.sort()
	# Aurora debe ir primera en la lista de esperadas.
	var ordenadas := PackedStringArray()
	ordenadas.append("aurora")
	for e in esperadas:
		if e != "aurora":
			ordenadas.append(e)

	var arch := Archipielago.new()
	arch.version = 1
	arch.id_principal = &"aurora"
	arch.islas_esperadas = ordenadas
	var err_arch: int = ResourceSaver.save(arch, RUTA_ARCHIPIELAGO)
	if err_arch != OK:
		_errores.append("no se pudo guardar el índice del archipiélago (err=%d)" % err_arch)
	else:
		print("  [OK] archipielago.tres con %d islas esperadas" % ordenadas.size())

	print("=== Resumen: %d islas guardadas, %d errores ===" % [_creadas.size(), _errores.size()])
	quit(1 if not _errores.is_empty() else 0)


## ── Helpers de tipado (los @export tipados no aceptan Array sin convertir) ──

func _ints(v: Array) -> Array[int]:
	var out: Array[int] = []
	for x in v:
		out.append(int(x))
	return out


func _floats(v: Array) -> Array[float]:
	var out: Array[float] = []
	for x in v:
		out.append(float(x))
	return out


func _construir(d: Dictionary) -> IslandDefinition:
	var def := IslandDefinition.new()
	def.id = StringName(d["id"])
	def.nombre_display = String(d["nombre"])
	def.nombre_clave = "M27.ISLA.%s.NOMBRE" % String(d["id"]).to_upper()
	def.descripcion = String(d.get("lore", ""))
	def.radio = int(d["radio"])
	def.altura_min = int(d.get("altura_min", 0))
	def.altura_max = int(d["altura_max"])
	def.playa_ancho = int(d.get("playa_ancho", 8))
	def.bioma_base = int(d["bioma"])
	def.biomas_mezcla = _ints(d.get("mezcla", []))
	def.proporciones_mezcla = _floats(d.get("proporciones", []))
	def.clima_tendencia = int(d.get("clima", 0))
	def.musica_clave = StringName(d.get("musica", ""))
	def.recursos_exclusivos = PackedStringArray(d.get("recursos", []))
	def.flora_endemica = PackedStringArray(d.get("flora", []))
	def.fauna_endemica = PackedStringArray(d.get("fauna", []))
	def.puzzles = PackedStringArray(d.get("puzzles", []))
	def.npc_residentes = PackedStringArray(d.get("npc", []))
	def.anillo = int(d["anillo"])
	def.es_secreta = bool(d.get("secreta", false))
	def.es_flotante = bool(d.get("flotante", false))
	def.desbloqueo_flag = StringName(d.get("flag", ""))
	def.orden_anillo = int(d.get("orden", 0))

	# Puntos de llegada/partida: sobre el disco interior del muelle.
	var margen: int = def.radio - def.playa_ancho - 24
	var y_puerto: int = (def.altura_max + 6) if def.es_flotante else (def.altura_min + 3)
	def.punto_llegada = Vector3i(margen, y_puerto, 0)
	def.punto_partida = Vector3i(margen, y_puerto, 12)
	return def


## ── Catálogo (diseño §5, sección 26 del plan maestro) ─────────────────────
## `bioma` = índice del catálogo de biomas de M09 (IslandDefinition.BIOMAS).
## Anclas de referencia: ver cabecera (no se serializan).
func _catalogo() -> Array:
	return [
		{
			"id": "aurora", "nombre": "Isla Aurora", "anillo": IslandRing.NUCLEO,
			"radio": 256, "altura_min": 0, "altura_max": 140, "playa_ancho": 10,
			"bioma": 2, "mezcla": [0, 1, 4, 3], "proporciones": [0.2, 0.3, 0.3, 0.2],
			"clima": 0, "musica": "mus_aurora", "orden": 0,
			"lore": "El hogar. Puerto central del archipiélago y única isla siempre cargada.",
			"recursos": ["madera", "piedra", "fibra"],
			"flora": ["flor_aurora", "pino_comun"],
			"fauna": ["conejo", "gaviota"],
			"puzzles": ["tutorial_puerto"],
			"npc": ["alcalde", "ferrera"],
		},
		{
			"id": "coral", "nombre": "Isla de Coral", "anillo": IslandRing.CERCANO,
			"radio": 200, "altura_min": 0, "altura_max": 40, "playa_ancho": 12,
			"bioma": 10, "mezcla": [0, 3], "proporciones": [0.6, 0.4],
			"clima": 1, "musica": "mus_coral", "orden": 1,
			"lore": "Arrecifes someros y lagunas tibias; el mar es el camino.",
			"recursos": ["coral_rojo", "concha_nacar", "perla"],
			"flora": ["alga_coral", "palma_coral"],
			"fauna": ["pez_loro", "tortuga_marina", "medusa_lunar"],
			"puzzles": ["buceo_arrecife"],
			"npc": ["buzo_viejo"],
		},
		{
			"id": "verde", "nombre": "Isla Verde", "anillo": IslandRing.CERCANO,
			"radio": 190, "altura_min": 0, "altura_max": 70, "playa_ancho": 10,
			"bioma": 10, "mezcla": [2, 1], "proporciones": [0.6, 0.4],
			"clima": 1, "musica": "mus_verde", "orden": 2,
			"lore": "Selva densa y rumor de hojas; la flora más rara del archipiélago.",
			"recursos": ["bambu", "fruta_tropical", "resina"],
			"flora": ["arbol_copal", "helecho_gigante", "orquidea"],
			"fauna": ["mono_titi", "rana_dardo"],
			"puzzles": ["sendero_canopia"],
			"npc": ["botanica"],
		},
		{
			"id": "pequena", "nombre": "Isla Pequeña", "anillo": IslandRing.CERCANO,
			"radio": 96, "altura_min": 0, "altura_max": 30, "playa_ancho": 10,
			"bioma": 0, "mezcla": [1], "proporciones": [1.0],
			"clima": 0, "musica": "mus_pequena", "orden": 3,
			"lore": "Una cala mínima para una tarde tranquila.",
			"recursos": ["coco", "arena_fina"],
			"flora": ["palma_enana"],
			"fauna": ["cangrejo_ermitano"],
			"puzzles": ["tesoro_mini"],
			"npc": ["pescador_retirado"],
		},
		{
			"id": "cenizas", "nombre": "Isla de las Cenizas", "anillo": IslandRing.MEDIO,
			"radio": 200, "altura_min": 0, "altura_max": 120, "playa_ancho": 8,
			"bioma": 9, "mezcla": [5, 6], "proporciones": [0.7, 0.3],
			"clima": 4, "musica": "mus_cenizas", "orden": 4, "flag": "progreso_medio",
			"lore": "La caldera duerme; el suelo aún recuerda el fuego.",
			"recursos": ["obsidiana", "azufre", "hierro_volcanico"],
			"flora": ["planta_fuego", "helecho_ceniza"],
			"fauna": ["salamandra_brasa"],
			"puzzles": ["forja_antigua"],
			"npc": ["herrero_exiliado"],
		},
		{
			"id": "desierto", "nombre": "Isla del Desierto", "anillo": IslandRing.MEDIO,
			"radio": 180, "altura_min": 0, "altura_max": 50, "playa_ancho": 14,
			"bioma": 7, "mezcla": [0], "proporciones": [1.0],
			"clima": 2, "musica": "mus_desierto", "orden": 5, "flag": "progreso_medio",
			"lore": "Dunas interminables y un oasis que sólo aparece al mediodía.",
			"recursos": ["arena_vidrio", "cobre", "sal"],
			"flora": ["cactus_barril", "flor_desierto"],
			"fauna": ["lagarto_cola", "escarabajo"],
			"puzzles": ["oasis_perdido"],
			"npc": ["nomada"],
		},
		{
			"id": "flotante", "nombre": "Isla Flotante", "anillo": IslandRing.MEDIO,
			"radio": 140, "altura_min": 40, "altura_max": 90, "playa_ancho": 6,
			"bioma": 1, "mezcla": [2], "proporciones": [1.0],
			"clima": 5, "musica": "mus_flotante", "orden": 6, "flotante": true,
			"flag": "progreso_medio",
			"lore": "Una isla que flota sobre el mar; saltar de nube en nube es el juego.",
			"recursos": ["cristal_cielo", "pluma_eter"],
			"flora": ["lotus_aereo"],
			"fauna": ["ave_flotante"],
			"puzzles": ["plataformas_nubes"],
			"npc": ["guardian_nubes"],
		},
		{
			"id": "cielo", "nombre": "Islas del Cielo", "anillo": IslandRing.LEJANO,
			"radio": 160, "altura_min": 60, "altura_max": 130, "playa_ancho": 6,
			"bioma": 6, "mezcla": [5], "proporciones": [1.0],
			"clima": 5, "musica": "mus_cielo", "orden": 7, "flotante": true,
			"flag": "progreso_lejano",
			"lore": "Cumbres suspendidas; desde aquí se ve todo el archipiélago.",
			"recursos": ["esencia_nube", "cristal_viento"],
			"flora": ["pino_alpino"],
			"fauna": ["aguila_real"],
			"puzzles": ["ascenso_cielo"],
			"npc": ["astronoma"],
		},
		{
			"id": "nieve", "nombre": "Isla de Nieve", "anillo": IslandRing.LEJANO,
			"radio": 190, "altura_min": 0, "altura_max": 130, "playa_ancho": 10,
			"bioma": 8, "mezcla": [5, 6], "proporciones": [0.5, 0.5],
			"clima": 3, "musica": "mus_nieve", "orden": 8, "flag": "progreso_lejano",
			"lore": "Silencio blanco y huellas que el viento borra.",
			"recursos": ["hielo_perpetuo", "plata_fria"],
			"flora": ["pino_nival", "musgo_glacial"],
			"fauna": ["zorro_artico", "reno"],
			"puzzles": ["cueva_hielo"],
			"npc": ["explorador"],
		},
		{
			"id": "volcanica", "nombre": "Isla Volcánica", "anillo": IslandRing.LEJANO,
			"radio": 210, "altura_min": 0, "altura_max": 150, "playa_ancho": 8,
			"bioma": 9, "mezcla": [5], "proporciones": [1.0],
			"clima": 4, "musica": "mus_volcanica", "orden": 9, "flag": "progreso_lejano",
			"lore": "El cráter activo: la recompensa de la expedición más larga.",
			"recursos": ["nucleo_magma", "basalto_duro", "rubi"],
			"flora": ["flor_lava"],
			"fauna": ["fenix_joven"],
			"puzzles": ["ascenso_crater"],
			"npc": ["cartografa"],
		},
		{
			"id": "submarina", "nombre": "Isla Submarina", "anillo": IslandRing.LEJANO,
			"radio": 170, "altura_min": 0, "altura_max": 20, "playa_ancho": 16,
			"bioma": 0, "mezcla": [12], "proporciones": [1.0],
			"clima": 6, "musica": "mus_submarina", "orden": 10, "flag": "progreso_lejano",
			"lore": "Un atolón que apenas asoma; el resto vive bajo el agua.",
			"recursos": ["perla_negra", "cristal_abismo"],
			"flora": ["coral_luminoso"],
			"fauna": ["raya_abismo", "caballito_abisal"],
			"puzzles": ["ruinas_sumergidas"],
			"npc": ["sirena_guardiana"],
		},
		{
			"id": "misteriosa", "nombre": "Isla Misteriosa", "anillo": IslandRing.LEJANO,
			"radio": 200, "altura_min": 0, "altura_max": 110, "playa_ancho": 8,
			"bioma": 11, "mezcla": [2, 5], "proporciones": [0.5, 0.5],
			"clima": 6, "musica": "mus_misteriosa", "orden": 11, "flag": "progreso_lejano",
			"lore": "Ruinas que no recuerdan su nombre; un enigma narrativo por resolver.",
			"recursos": ["reliquia_antigua", "moneda_olvidada"],
			"flora": ["hongo_luminoso"],
			"fauna": ["espiritu_bosque"],
			"puzzles": ["enigma_tres_piedras"],
			"npc": ["ermitano"],
		},
		{
			"id": "secreta", "nombre": "Isla Secreta", "anillo": IslandRing.LEJANO,
			"radio": 150, "altura_min": 0, "altura_max": 80, "playa_ancho": 8,
			"bioma": 12, "mezcla": [11], "proporciones": [1.0],
			"clima": 6, "musica": "mus_secreta", "orden": 12, "secreta": true,
			"flag": "pista_secreta",
			"lore": "No aparece en el mapa. Se descubre siguiendo pistas, nunca por accidente.",
			"recursos": ["fragmento_resonancia", "cristal_puro"],
			"flora": ["flor_resonante"],
			"fauna": ["ciervo_blanco"],
			"puzzles": ["camara_resonancia"],
			"npc": ["voz_resonancia"],
		},
	]
