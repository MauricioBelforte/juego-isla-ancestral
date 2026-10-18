# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M83: Licencias de Software — AssetAttributionGenerator
# Genera la atribución de assets/dependencias de terceros para el output de build
# (créditos del juego + archivo detallado). Reutiliza LicenseProfile.

class_name AssetAttributionGenerator
extends RefCounted

const ATRIBUTION_FILENAME := "ASSET_ATRIBUCIONES.txt"


func generar_compacto(licencias: Array[LicenseProfile]) -> String:
	var text := "ATRIBUCIÓN DE ASSETS Y DEPENDENCIAS\n"
	text += "=".repeat(40) + "\n\n"

	var requiere_atrib: Array[LicenseProfile] = []
	for lp in licencias:
		if lp.attribution_required:
			requiere_atrib.append(lp)

	if requiere_atrib.is_empty():
		text += "No hay assets de terceros con atribución requerida.\n"
		return text

	for lp in requiere_atrib:
		text += "- %s" % lp.dependency_name
		if not lp.version.is_empty():
			text += " %s" % lp.version
		text += " — %s\n" % lp.license_type
		if not lp.notes.is_empty():
			text += "  %s\n" % lp.notes

	return text


func generar_detallado(licencias: Array[LicenseProfile]) -> String:
	var text := "# Atribución de Assets y Dependencias — Isla Ancestral\n\n"
	text += "Fecha de generación: %s\n\n" % Time.get_datetime_string_from_system()
	text += "Total de dependencias: %d\n\n" % licencias.size()

	for lp in licencias:
		text += "---\n"
		text += "## %s\n" % lp.dependency_name
		if not lp.version.is_empty():
			text += "- **Versión:** %s\n" % lp.version
		text += "- **Licencia:** %s\n" % lp.license_type
		text += "- **Uso comercial:** %s\n" % ("Sí" if lp.commercial_use else "No")
		text += "- **Atribución requerida:** %s\n" % ("Sí" if lp.attribution_required else "No")
		if lp.source_offer_required:
			text += "- **Ofrecer fuente:** Sí\n"
		if not lp.license_url.is_empty():
			text += "- **URL:** %s\n" % lp.license_url
		if not lp.notes.is_empty():
			text += "- **Notas:** %s\n" % lp.notes
		text += "\n"

	return text


func guardar_compacto(licencias: Array[LicenseProfile], ruta: String) -> bool:
	var dir := DirAccess.open(ruta.get_base_dir())
	if not dir:
		DirAccess.make_dir_recursive_absolute(ruta.get_base_dir())
	var file := FileAccess.open(ruta, FileAccess.WRITE)
	if not file:
		push_error("[M83] No se pudo escribir %s" % ruta)
		return false
	file.store_string(generar_compacto(licencias))
	file.close()
	return true


func guardar_detallado(licencias: Array[LicenseProfile], ruta: String) -> bool:
	var dir := DirAccess.open(ruta.get_base_dir())
	if not dir:
		DirAccess.make_dir_recursive_absolute(ruta.get_base_dir())
	var file := FileAccess.open(ruta, FileAccess.WRITE)
	if not file:
		push_error("[M83] No se pudo escribir %s" % ruta)
		return false
	file.store_string(generar_detallado(licencias))
	file.close()
	return true


## Cuenta las dependencias que requieren atribución o offer de fuente.
func contar_requieren_atribucion(licencias: Array[LicenseProfile]) -> int:
	var n := 0
	for lp in licencias:
		if lp.attribution_required or lp.source_offer_required:
			n += 1
	return n
