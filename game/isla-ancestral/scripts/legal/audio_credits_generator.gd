# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-15
#
# M84: Música y Audio Legal — AudioCreditsGenerator
# Genera archivos de créditos de audio para builds y visualización.
# Formato compacto (menú del juego) y detallado (archivo web).

class_name AudioCreditsGenerator
extends RefCounted

const CREDITS_FILENAME := "AUDIO_CREDITS.txt"

const AUDIO_ROLE_NAMES := {
	"COMPOSITOR": "Banda Sonora",
	"MUSICISTA": "Músicos",
	"DISENADOR_SONORO": "Diseño de Sonido",
	"ACTOR_VOCAL": "Voces",
	"INGENIERO_MEZCLA": "Ingeniería de Mezcla",
	"LICENSOR": "Licencias",
	"OTRO": "Otros",
}


func generar_compacto(creditos: Array[AudioCredit]) -> String:
	var text := "MÚSICA Y AUDIO\n"
	text += "=".repeat(30) + "\n\n"

	var por_rol: Dictionary = {}
	for cred in creditos:
		if not cred.incluir_en_creditos:
			continue
		var rol_key := AudioCredit.AudioRole.keys()[cred.rol]
		if not por_rol.has(rol_key):
			por_rol[rol_key] = []
		por_rol[rol_key].append(cred.persona_nombre)

	for rol_key in por_rol.keys():
		var nombre_rol: String = AUDIO_ROLE_NAMES.get(rol_key, rol_key)
		text += "%s: %s\n" % [nombre_rol, ", ".join(por_rol[rol_key])]

	return text


func generar_detallado(creditos: Array[AudioCredit]) -> String:
	var text := "# Créditos de Audio — Isla Ancestral\n\n"
	text += "Fecha de generación: %s\n\n" % Time.get_datetime_string_from_system()

	for cred in creditos:
		if not cred.incluir_en_creditos:
			continue
		text += "---\n"
		text += "## %s\n" % cred.persona_nombre
		text += "- **Rol:** %s\n" % AudioCredit.AudioRole.keys()[cred.rol]
		text += "- **Contribución:** %s\n" % cred.contribucion
		if cred.pistas.size() > 0:
			text += "- **Pistas:** %s\n" % ", ".join(cred.pistas)
		if not cred.referencia_contrato.is_empty():
			text += "- **Contrato:** %s\n" % cred.referencia_contrato
		text += "- **Estado de pago:** %s\n\n" % cred.estado_pago

	return text


func guardar_compacto(creditos: Array[AudioCredit], ruta: String) -> bool:
	var dir := DirAccess.open(ruta.get_base_dir())
	if not dir:
		DirAccess.make_dir_recursive_absolute(ruta.get_base_dir())
	var file := FileAccess.open(ruta, FileAccess.WRITE)
	if not file:
		push_error("[M84] No se pudo escribir %s" % ruta)
		return false
	file.store_string(generar_compacto(creditos))
	file.close()
	return true


func guardar_detallado(creditos: Array[AudioCredit], ruta: String) -> bool:
	var dir := DirAccess.open(ruta.get_base_dir())
	if not dir:
		DirAccess.make_dir_recursive_absolute(ruta.get_base_dir())
	var file := FileAccess.open(ruta, FileAccess.WRITE)
	if not file:
		push_error("[M84] No se pudo escribir %s" % ruta)
		return false
	file.store_string(generar_detallado(creditos))
	file.close()
	return true


func generar_reporte_licencias(licencias: Array[AudioLicense]) -> String:
	var text := "# Reporte de Licencias de Audio\n\n"
	text += "Fecha: %s\n" % Time.get_datetime_string_from_system()
	text += "Total de tracks: %d\n\n" % licencias.size()

	var por_tipo: Dictionary = {}
	for lic in licencias:
		var tipo_key := AudioLicense.AudioType.keys()[lic.audio_type]
		if not por_tipo.has(tipo_key):
			por_tipo[tipo_key] = []
		por_tipo[tipo_key].append(lic)

	for tipo_key in por_tipo.keys():
		text += "## %s (%d tracks)\n\n" % [tipo_key, por_tipo[tipo_key].size()]
		for lic in por_tipo[tipo_key]:
			text += "- **%s** — %s\n" % [lic.titulo, lic.autor]
			text += "  Licencia: %s | Uso comercial: %s | Atribución: %s\n" % [
				AudioLicense.LicenseType.keys()[lic.license_type],
				"Sí" if lic.uso_comercial else "No",
				"Sí" if lic.attribution_requerida else "No",
			]
			if lic.attribution_requerida:
				text += "  Atribución: \"%s\"\n" % lic.attribution_texto
		text += "\n"

	return text
