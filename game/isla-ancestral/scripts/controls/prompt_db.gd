# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M57: Interfaz de Control — PromptDB (tabla accion x dispositivo -> textura).
# Item [S] "PromptDB: tabla accion x dispositivo -> textura" del 05-Checklist.
# Item [S] "Prompts de UI nunca muestran icono de otro dispositivo".
#
# Contrato con arte (M46): cada nombre DEVUELTO es el nombre de textura que el
# arte coloca en res://assets/ui/prompts/<modo>/<nombre>.png. Esta clase NO
# carga imagenes (headless-safe) — solo resuelve el nombre exacto. Mientras
# el PNG no exista, el widget consume el nombre y cae a su placeholder.
#
# Prioridad de resolucion por modo mando:
#   1. InputMap real (si la accion tiene JoypadButton/Motion, se usa su indice
#      estandar — respeta el remapeo del usuario en caliente).
#   2. Catalogo estatico de diseno (PREFABS) para las acciones canonicas cozy.
#   3. Fallback genérico del modo (sin icono de OTRO dispositivo jamas).
#
# Sin dependencia de ControlInput (evita orden de autoload en tests headless):
# las constantes de modo replican las de control_input.gd y estan comentadas
# para mantenerse en sintonia.

class_name PromptDB
extends RefCounted

const MODO_TECLADO := "teclado"
const MODO_RATON := "raton"
const MODO_XBOX := "xbox"
const MODO_PLAYSTATION := "playstation"
const MODO_GENERICO := "generico"

## Nombre de textura por indice de boton estandar (Godot JoyButton) por modo.
## JoyButton: 0 A/CRUZ, 1 B/CIRCULO, 2 X/CUADRADO, 3 Y/TRIANGULO,
##            4 BACK/SHARE, 5 START/OPTIONS, 10 DPAD_IZQ, 11 DPAD_DER.
const NOMBRE_BOTON := {
	MODO_XBOX: {0: "xbox_a", 1: "xbox_b", 2: "xbox_x", 3: "xbox_y", 4: "xbox_back", 5: "xbox_start", 10: "xbox_dpad_l", 11: "xbox_dpad_r"},
	MODO_PLAYSTATION: {0: "ps_cross", 1: "ps_circle", 2: "ps_square", 3: "ps_triangle", 4: "ps_share", 5: "ps_options", 10: "ps_dpad_l", 11: "ps_dpad_r"},
	MODO_GENERICO: {0: "gen_a", 1: "gen_b", 2: "gen_x", 3: "gen_y", 4: "gen_back", 5: "gen_start", 10: "gen_dpad_l", 11: "gen_dpad_r"},
}

## Catalogo estatico de diseno (fallback cuando el InputMap no tiene evento
## de mando para la accion). Solo acciones canonicas cozy con convencion
## conocida; las que no esten aca devuelven "" (el widget decide placeholder).
const PREFABS_MANDO := {
	MODO_XBOX: {"interactuar": "xbox_a", "favorito": "xbox_x", "inventario": "xbox_y", "colocar": "xbox_b", "pausa": "xbox_start"},
	MODO_PLAYSTATION: {"interactuar": "ps_cross", "favorito": "ps_square", "inventario": "ps_triangle", "colocar": "ps_circle", "pausa": "ps_options"},
	MODO_GENERICO: {"interactuar": "gen_a", "favorito": "gen_x", "inventario": "gen_y", "colocar": "gen_b", "pausa": "gen_start"},
}

## Textura de una accion para un modo.
## Teclado: "key_<ETIQUETA>" derivada del InputMap real (p. ej. key_E).
## Raton: "mouse_<n>". Mando:Nombre por boton estandar o prefab de diseno.
## Nunca mezcla dispositivos: cada modo resuelve SOLO sus propios nombres.
## Accion desconocida o sin evento -> "" (sin icono).
static func prompt_para(accion: String, modo: String) -> String:
	match modo:
		MODO_TECLADO:
			return _texto_de_evento(IS_INPUT, accion, true)
		MODO_RATON:
			return _texto_de_evento(IS_MOUSE, accion, true)
		MODO_XBOX, MODO_PLAYSTATION, MODO_GENERICO:
			var por_mapa := _prompt_de_inputmap(accion, modo)
			if por_mapa != "":
				return por_mapa
			var prefabs: Dictionary = PREFABS_MANDO.get(modo, {})
			return str(prefabs.get(accion, ""))
		_:
			return ""

## Igual que prompt_para pero consultando el modo ACTIVO de ControlInput si
## esta disponible (headless / autoload ausente -> teclado, modo seguro).
static func prompt_para_activo(accion: String) -> String:
	var modo := MODO_TECLADO
	var ci = Engine.get_main_loop().root.get_node_or_null("/root/ControlInput")
	if ci != null:
		modo = str(ci.dispositivo_activo())
	return prompt_para(accion, modo)

# ── integerno ─────────────────────────────────────────────

const IS_INPUT = 0  # marcador de tipo de scan (teclado)
const IS_MOUSE = 1  # marcador de tipo de scan (mouse)

static func _texto_de_evento(tipo: int, accion: String, _teclado: bool) -> String:
	if not InputMap.has_action(accion):
		return ""
	for ev in InputMap.action_get_events(accion):
		if tipo == IS_INPUT and ev is InputEventKey and ev.physical_keycode != 0:
			return "key_" + OS.get_keycode_string(ev.physical_keycode).to_lower()
		if tipo == IS_MOUSE and ev is InputEventMouseButton:
			return "mouse_" + str(ev.button_index)
	return ""

static func _prompt_de_inputmap(accion: String, modo: String) -> String:
	if not InputMap.has_action(accion):
		return ""
	for ev in InputMap.action_get_events(accion):
		if ev is InputEventJoypadButton:
			var tabla: Dictionary = NOMBRE_BOTON[modo]
			return str(tabla.get(ev.button_index, ""))
	return ""
