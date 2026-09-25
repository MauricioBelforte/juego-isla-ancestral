# Modelo: kimi-k3 (Moonshot AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-19
#
# M106 T-005: Seguridad — Middleware de rate limiting (diseño reutilizable, headless-safe).
# Orquesta las 3 capas (IP + usuario + endpoint) sobre SecurityManager.verificar_limite_tasa().
# ⚠️ Sin class_name (pitfall §9.41): vía preload, igual que security_input_validator.gd.
# Inyecta el SecurityManager por constructor → testeable headless sin reloj ni red reales.
# La integración al servidor HTTP real (online) es de M77 — este es el componente de decisión.

extends RefCounted

var _sm: Object = null  # SecurityManager (autoload) inyectado

func _init(security_manager: Object) -> void:
	_sm = security_manager

## Procesa una solicitud y decide si se permite según las 3 capas de rate limiting.
## ip / usuario / endpoint: identificadores de la solicitud (vacío = capa no aplica).
## ahora_s: instante actual en segundos (lo inyecta el caller; en runtime real = Time.get_unix...).
## Devuelve: {"permitida": bool, "motivo": String, "capa": String, "reintentar_en_s": int}
## - permitida=true si TODAS las capas configuradas tienen capacidad (consume 1 unidad por capa).
## - permitida=false si alguna capa excede su límite (motivo = capa que rechazó).
func procesar(ip: String, usuario: String, endpoint: String, ahora_s: int) -> Dictionary:
	if _sm == null:
		return {"permitida": true, "motivo": "sin_security_manager", "capa": "", "reintentar_en_s": 0}
	# capa endpoint (la más específica primero: rechazo temprano barato)
	if endpoint != "":
		if not _sm.verificar_limite_tasa("endpoint:" + endpoint, ahora_s):
			return _rechazo("endpoint", "endpoint:" + endpoint, ahora_s)
	# capa IP
	if ip != "":
		if not _sm.verificar_limite_tasa("ip:" + ip, ahora_s):
			return _rechazo("ip", "ip:" + ip, ahora_s)
	# capa usuario
	if usuario != "":
		if not _sm.verificar_limite_tasa("usuario:" + usuario, ahora_s):
			return _rechazo("usuario", "usuario:" + usuario, ahora_s)
	return {"permitida": true, "motivo": "", "capa": "", "reintentar_en_s": 0}

func _rechazo(capa: String, clave: String, ahora_s: int) -> Dictionary:
	return {
		"permitida": false,
		"motivo": "limite_excedido",
		"capa": capa,
		"reintentar_en_s": _sm.tasa_reintento_s(clave, ahora_s),
	}
