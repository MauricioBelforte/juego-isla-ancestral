# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-15
#
# M84: Música y Audio Legal — AudioCredit (Resource)
# Representa un crédito de audio: quién contribuyó, en qué rol, y estado
# de pago. Usado por AudioLegalManager y AudioCreditsGenerator.

class_name AudioCredit
extends Resource

## Roles de audio
enum AudioRole {
	COMPOSITOR,
	MUSICISTA,
	DISENADOR_SONORO,
	ACTOR_VOCAL,
	INGENIERO_MEZCLA,
	LICENSOR,
	OTRO
}

## Datos de la persona
@export var persona_nombre: String
@export var rol: AudioRole
@export var contribucion: String
@export var pistas: Array[String] = []

## Referencia al contrato
@export var referencia_contrato: String = ""

## Estado de pago
@export var estado_pago: String = "pendiente"  ## pendiente, parcial, pagado
@export var monto_pago: float = 0.0
@export var moneda: String = "USD"

## Atribución en créditos del juego
@export var incluir_en_creditos: bool = true
@export var texto_atribucion: String = ""

## Notas internas
@export var notas: String = ""


func es_pagado() -> bool:
	return estado_pago == "pagado"


func generar_texto_credito() -> String:
	var rol_texto := AudioRole.keys()[rol].capitalize()
	if not texto_atribucion.is_empty():
		return texto_atribucion
	return "%s — %s (%s)" % [persona_nombre, contribucion, rol_texto]


func to_dict() -> Dictionary:
	return {
		"persona_nombre": persona_nombre,
		"rol": AudioRole.keys()[rol],
		"contribucion": contribucion,
		"pistas": pistas,
		"referencia_contrato": referencia_contrato,
		"estado_pago": estado_pago,
		"monto_pago": monto_pago,
		"moneda": moneda,
		"incluir_en_creditos": incluir_en_creditos,
		"texto_atribucion": texto_atribucion,
		"notas": notas,
	}


static func from_dict(dict: Dictionary) -> AudioCredit:
	var cred := AudioCredit.new()
	cred.persona_nombre = String(dict.get("persona_nombre", ""))
	cred.rol = AudioRole.get(String(dict.get("rol", "OTRO")), AudioRole.OTRO)
	cred.contribucion = String(dict.get("contribucion", ""))
	cred.pistas = Array(dict.get("pistas", []))
	cred.referencia_contrato = String(dict.get("referencia_contrato", ""))
	cred.estado_pago = String(dict.get("estado_pago", "pendiente"))
	cred.monto_pago = float(dict.get("monto_pago", 0.0))
	cred.moneda = String(dict.get("moneda", "USD"))
	cred.incluir_en_creditos = bool(dict.get("incluir_en_creditos", true))
	cred.texto_atribucion = String(dict.get("texto_atribucion", ""))
	cred.notas = String(dict.get("notas", ""))
	return cred
