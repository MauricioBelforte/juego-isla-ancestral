# Modelo: GLM-5.3-Flash
# Plataforma: Kilo Code
# Fecha: 2026-11-25
#
# M85: Modelos 3D Legal — ModelCredit (Resource)
# Crédito de una PERSONA sobre assets 3D. Un artista puede tener VARIOS roles
# sobre el mismo asset (ej: "modelado" y "texturizado") — edge case del
# checklist (artista con múltiples roles): por eso roles es Array[String].
# Espejo de scripts/legal/audio_credit.gd (M84).

class_name ModelCredit
extends Resource

## Roles en el pipeline de assets 3D (M108)
const ROLES: Array[String] = [
	"modelado",       ## Mesh/geo
	"retopologia",    ## Retopología
	"rig",            ## Esqueleto/deformación
	"animacion",      ## Clips de animación
	"texturizado",    ## Materiales/texturas
	"supervision",    ## Dirección de arte/QA del asset
	"otro",
]

@export var persona_nombre: String = ""
@export var roles: Array[String] = []
## Assets sobre los que esta persona trabajó (un artista puede creditar varios)
@export var asset_ids: Array[String] = []
@export var notas: String = ""
@export var pago_acordado: bool = false
@export var pago_realizado: bool = false


func es_pagado() -> bool:
	return not pago_acordado or pago_realizado


## Edge case: artista con múltiples roles — la lista es válida solo si cada
## rol es conocido (evita typos silenciosos en los créditos).
func roles_validos() -> bool:
	for r in roles:
		if not (r in ROLES):
			return false
	return true


func to_dict() -> Dictionary:
	return {
		"persona_nombre": persona_nombre,
		"roles": roles.duplicate(),
		"asset_ids": asset_ids.duplicate(),
		"notas": notas,
		"pago_acordado": pago_acordado,
		"pago_realizado": pago_realizado,
	}


static func from_dict(dict: Dictionary) -> ModelCredit:
	var cred := ModelCredit.new()
	cred.persona_nombre = String(dict.get("persona_nombre", ""))
	var rs: Variant = dict.get("roles", [])
	if typeof(rs) == TYPE_ARRAY:
		for r in (rs as Array):
			cred.roles.append(String(r))
	var ids: Variant = dict.get("asset_ids", [])
	if typeof(ids) == TYPE_ARRAY:
		for a in (ids as Array):
			cred.asset_ids.append(String(a))
	cred.notas = String(dict.get("notas", ""))
	cred.pago_acordado = bool(dict.get("pago_acordado", false))
	cred.pago_realizado = bool(dict.get("pago_realizado", false))
	return cred
