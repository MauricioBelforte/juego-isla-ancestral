# Modelo: kimi-k3 (Moonshot AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-20
#
# M106 T-009: Seguridad — Bases de datos separadas por entorno (RF4).
# Resuelve la config de BD del entorno activo y VALIDA la separación:
# dev/staging NUNCA deben apuntar a prod (error clásico de seguridad).
# Headless-safe, lógica pura, RefCounted vía preload (sin class_name, pitfall §9.41).

extends RefCounted

const _ENV := preload("res://scripts/security/security_environment_resolver.gd")

var _resolver: RefCounted = null

## app_env: entorno forzado (para tests). "" = leer APP_ENV / default dev.
func _init(app_env: String = "") -> void:
	_resolver = _ENV.new(app_env)

## Configuración de BD del entorno activo:
## {"nombre", "host", "credencial_origen", "entorno"}
func config_bd() -> Dictionary:
	var cfg: Dictionary = _resolver.config_entorno()
	return {
		"entorno": _resolver.entorno(),
		"nombre": str(cfg.get("base_datos", "")),
		"host": str(cfg.get("bd_host", "")),
		"credencial_origen": str(cfg.get("bd_credencial_origen", "")),
	}

## Valida la separación de BD entre entornos. Devuelve Array de violaciones ([] = OK).
## Reglas: dev/staging no pueden usar la BD ni el host de prod; cada entorno tiene BD distinta;
## prod exige credencial de secret_manager (nunca env_local).
func validar_separacion() -> Array:
	var violaciones: Array = []
	var entornos: Array = _resolver.entornos_disponibles()
	var prod_nombre := _bd_campo("prod", "base_datos")
	var prod_host := _bd_campo("prod", "bd_host")
	var nombres_vistos: Dictionary = {}
	for env in entornos:
		var nombre := _bd_campo(env, "base_datos")
		var host := _bd_campo(env, "bd_host")
		var cred := _bd_campo(env, "bd_credencial_origen")
		# dev/staging no pueden apuntar a la BD de prod
		if env != "prod":
			if nombre != "" and nombre == prod_nombre:
				violaciones.append("%s usa la base_datos de prod (%s)" % [env, nombre])
			if host != "" and host == prod_host:
				violaciones.append("%s usa el bd_host de prod (%s)" % [env, host])
		# nombres de BD distintos entre entornos
		if nombre != "":
			if nombres_vistos.has(nombre):
				violaciones.append("base_datos '%s' repetida entre '%s' y '%s'" % [nombre, nombres_vistos[nombre], env])
			else:
				nombres_vistos[nombre] = env
		# prod exige secret_manager
		if env == "prod" and cred == "env_local":
			violaciones.append("prod usa credencial env_local (debe ser secret_manager)")
	return violaciones

## ¿La configuración actual es segura (sin violaciones)?
func es_separacion_valida() -> bool:
	return validar_separacion().is_empty()

func _bd_campo(entorno: String, campo: String) -> String:
	var res = _ENV.new(entorno)
	return str(res.valor(campo, ""))
