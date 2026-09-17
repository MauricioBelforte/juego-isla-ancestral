# Modelo: DeepSeek-V4.1-Flash / WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-09-14
#
# M26 — Templo Subterráneo (iteración 2).
# TemploFlow: orquestador de gating del Templo de la Brisa. Mantiene el estado
# del templo (7 anillos de la Columna, sellos de cristal, restauración del
# Sello y apertura de la salida). Lógica pura: `RefCounted`, sin nodos, sin
# autoloads y sin VoxelTerrain, para poder verificarse headless.
#
# Reglas de gating (03-Diseno.md, "Reglas de gating (anti-exploit)"):
#   - La salida se abre SOLO con el sello restaurado (estado de mundo guardado).
#   - Los sellos son objetos ÚNICOS: un sello colocado en un anillo no puede
#     reutilizarse en otro (no duplicación).
#   - Activar un anillo exige el sello correspondiente + el glifo correcto.
#   - Los 7 anillos juntos son la única vía al puzzle final.

class_name TemploFlow
extends RefCounted

## Cantidad de anillos de la Columna (03-Diseno: "7 anillos de viento").
const ANILLOS_TOTAL := 7

# Motivos de rechazo como constantes nombradas: los tests los comparan sin
# depender de strings mágicos.
const MOTIVO_OK := ""
const MOTIVO_ANILLO_FUERA_DE_RANGO := "anillo_fuera_de_rango"
const MOTIVO_ANILLO_YA_ACTIVO := "anillo_ya_activo"
const MOTIVO_SELLO_INEXISTENTE := "sello_inexistente"
const MOTIVO_SELLO_YA_COLOCADO := "sello_ya_colocado"
const MOTIVO_SELLO_DUPLICADO := "sello_duplicado"
const MOTIVO_GLIFO_INCORRECTO := "glifo_incorrecto"
const MOTIVO_FALTAN_ANILLOS := "faltan_anillos"
const MOTIVO_SELLO_NO_RESTAURADO := "sello_no_restaurado"

## Emitida al activar un anillo correctamente (hook de VFX/SFX, M52/M43).
signal anillo_activado(indice: int)
## Emitida al restaurar el Sello (hook de cutscene, M33).
signal sello_restaurado_ok()

## Estado de los 7 anillos (false = inactivo).
var anillos: Array[bool] = []
## Glifo esperado por anillo (M24 familia símbolos).
var glifos: Array[String] = []
## Sellos conseguidos y aún no colocados: sello_id -> true.
var sellos_disponibles: Dictionary = {}
## Sellos colocados: indice del anillo (int) -> sello_id.
var sellos_colocados: Dictionary = {}
## El Sello fue restaurado en la Cámara del Sello.
var sello_restaurado: bool = false
## Motivo del último rechazo (MOTIVO_OK si la última operación tuvo éxito).
var ultimo_motivo: String = MOTIVO_OK


func _init(glifos_esperados: Array = []) -> void:
	anillos.clear()
	glifos.clear()
	for i in ANILLOS_TOTAL:
		anillos.append(false)
		if i < glifos_esperados.size():
			glifos.append(str(glifos_esperados[i]))
		else:
			glifos.append("glifo_%d" % i)


## Registra un sello de cristal conseguido por el jugador.
## Rechaza ids vacíos y repetidos (el sello es un objeto único: M66, cofre 1 copia).
func registrar_sello(sello_id: String) -> bool:
	if sello_id.is_empty():
		ultimo_motivo = MOTIVO_SELLO_INEXISTENTE
		return false
	if sellos_disponibles.has(sello_id):
		ultimo_motivo = MOTIVO_SELLO_DUPLICADO
		return false
	sellos_disponibles[sello_id] = true
	ultimo_motivo = MOTIVO_OK
	return true


## Índice del anillo donde está colocado el sello, o -1 si está libre.
func sello_colocado_en(sello_id: String) -> int:
	for indice in sellos_colocados:
		if str(sellos_colocados[indice]) == sello_id:
			return int(indice)
	return -1


## Activa un anillo: exige sello disponible, sello no reutilizado y glifo correcto.
func activar_anillo(indice: int, sello_id: String, glifo: String) -> bool:
	ultimo_motivo = MOTIVO_OK
	if indice < 0 or indice >= ANILLOS_TOTAL:
		ultimo_motivo = MOTIVO_ANILLO_FUERA_DE_RANGO
		return false
	if anillos[indice]:
		ultimo_motivo = MOTIVO_ANILLO_YA_ACTIVO
		return false
	if not sellos_disponibles.has(sello_id):
		ultimo_motivo = MOTIVO_SELLO_INEXISTENTE
		return false
	if sello_colocado_en(sello_id) != -1:
		ultimo_motivo = MOTIVO_SELLO_YA_COLOCADO
		return false
	if glifo != glifos[indice]:
		ultimo_motivo = MOTIVO_GLIFO_INCORRECTO
		return false
	anillos[indice] = true
	sellos_colocados[indice] = sello_id
	anillo_activado.emit(indice)
	return true


func anillos_activos() -> int:
	var n := 0
	for a in anillos:
		if a:
			n += 1
	return n


func progreso() -> float:
	return float(anillos_activos()) / float(ANILLOS_TOTAL)


func anillos_completos() -> bool:
	return anillos_activos() == ANILLOS_TOTAL


## Restaura el Sello en la Cámara: único gating de la salida.
func restaurar_sello() -> bool:
	ultimo_motivo = MOTIVO_OK
	if not anillos_completos():
		ultimo_motivo = MOTIVO_FALTAN_ANILLOS
		return false
	sello_restaurado = true
	sello_restaurado_ok.emit()
	return true


func salida_abierta() -> bool:
	return sello_restaurado


## Intento explícito de abrir la salida: falla (sin cambiar estado) si el sello
## no fue restaurado. Es el punto donde un exploit "entrar por la salida sellada"
## queda rechazado y auditado.
func intentar_abrir_salida() -> bool:
	if not sello_restaurado:
		ultimo_motivo = MOTIVO_SELLO_NO_RESTAURADO
		return false
	ultimo_motivo = MOTIVO_OK
	return true


## Estado serializable (para el checkpoint atómico y la telemetría).
func estado() -> Dictionary:
	var ids: Array = sellos_disponibles.keys()
	ids.sort()
	var colocados: Dictionary = {}
	for indice in sellos_colocados:
		colocados[str(indice)] = str(sellos_colocados[indice])
	return {
		"anillos": anillos.duplicate(),
		"glifos": glifos.duplicate(),
		"sellos_disponibles": ids,
		"sellos_colocados": colocados,
		"sello_restaurado": sello_restaurado,
	}


## Restaura el estado desde un Dictionary (checkpoint). Tolera tipos de JSON
## (números como float, claves de Dictionary como String).
func cargar_estado(datos: Dictionary) -> void:
	var arr: Variant = datos.get("anillos", [])
	if typeof(arr) == TYPE_ARRAY:
		for i in mini((arr as Array).size(), ANILLOS_TOTAL):
			anillos[i] = bool((arr as Array)[i])
	var gl: Variant = datos.get("glifos", [])
	if typeof(gl) == TYPE_ARRAY:
		for i in mini((gl as Array).size(), ANILLOS_TOTAL):
			glifos[i] = str((gl as Array)[i])
	sellos_disponibles.clear()
	var disp: Variant = datos.get("sellos_disponibles", [])
	if typeof(disp) == TYPE_ARRAY:
		for s in (disp as Array):
			sellos_disponibles[str(s)] = true
	sellos_colocados.clear()
	var col: Variant = datos.get("sellos_colocados", {})
	if typeof(col) == TYPE_DICTIONARY:
		var cd: Dictionary = col as Dictionary
		for k in cd:
			sellos_colocados[int(k)] = str(cd[k])
	sello_restaurado = bool(datos.get("sello_restaurado", false))
	ultimo_motivo = MOTIVO_OK


func descripcion() -> String:
	return "TemploFlow: %d/%d anillos | sellos %d | sello_restaurado=%s | salida=%s" % [
		anillos_activos(), ANILLOS_TOTAL, sellos_disponibles.size(),
		str(sello_restaurado), str(salida_abierta()),
	]
