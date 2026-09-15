# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M60 iter. 3 — Política de rotación/limpieza de `.bak` (checklist T-109,
# coordinada con M107 Recuperación).
#
# Problema que resuelve: antes, WriterAtomico BORRABA el `.bak` existente en
# cada guardado (`DirAccess.remove_absolute`) → una sola copia y sin historial:
# un save corrupto dos veces seguidas era irrecuperable.
#
# Política (ventana deslizante de 3 copias por slot):
#   índice 0 = `.bak`          (más reciente)
#   índice 1 = `.bak.1`
#   índice 2 = `.bak.2`        (más vieja)
# En cada guardado exitoso la cadena ROTA: se descarta la más vieja, las demás
# corren un lugar y `.bak` queda libre para que el writer copie el archivo
# actual. `limpiar_antiguos()` barre copias fuera de la ventana (huérfanas de
# políticas anteriores o de versiones con otro MAX_BACKUPS).
#
# ⚠️ No referencia WriterAtomico a propósito: evita la dependencia cíclica
# (WriterAtomico sí usa este helper). El sufijo es el mismo literal.

class_name GestorBackups
extends RefCounted

## Sufijo del backup (debe coincidir con WriterAtomico.BAK_SUFFIX).
const SUFIJO_BAK: String = ".bak"

## Copias conservadas por archivo (`.bak` + `.bak.1` + `.bak.2`).
const MAX_BACKUPS: int = 3

## Ruta de la copia `i` (0 = la más reciente).
static func ruta_copia(ruta_base: String, i: int) -> String:
	if i <= 0:
		return ruta_base + SUFIJO_BAK
	return "%s%s.%d" % [ruta_base, SUFIJO_BAK, i]

## Rota la cadena de backups ANTES de sobreescribir `ruta_base`.
## Devuelve cuántas copias quedaron tras la rotación.
static func rotar(ruta_base: String) -> int:
	# 1) descartar la más vieja de la ventana
	var ultima := ruta_copia(ruta_base, MAX_BACKUPS - 1)
	if FileAccess.file_exists(ultima):
		DirAccess.remove_absolute(ultima)
	# 2) correr las intermedias hacia atrás (de vieja a nueva)
	for i in range(MAX_BACKUPS - 2, 0, -1):
		var origen := ruta_copia(ruta_base, i)
		if FileAccess.file_exists(origen):
			DirAccess.rename_absolute(origen, ruta_copia(ruta_base, i + 1))
	# 3) `.bak` -> `.bak.1` (deja `.bak` libre para el writer)
	var bak := ruta_copia(ruta_base, 0)
	if FileAccess.file_exists(bak):
		DirAccess.rename_absolute(bak, ruta_copia(ruta_base, 1))
	return contar(ruta_base)

## Copias existentes, de la más reciente a la más vieja.
static func listar(ruta_base: String) -> Array[String]:
	var out: Array[String] = []
	for i in range(0, MAX_BACKUPS):
		var p := ruta_copia(ruta_base, i)
		if FileAccess.file_exists(p):
			out.append(p)
	return out

## Cantidad de copias dentro de la ventana.
static func contar(ruta_base: String) -> int:
	return listar(ruta_base).size()

## Restaura la copia `i` sobre el archivo principal (M107: recuperación).
## Devuelve Error (ERR_FILE_NOT_FOUND si esa copia no existe).
static func restaurar(ruta_base: String, i: int = 0) -> Error:
	var p := ruta_copia(ruta_base, i)
	if not FileAccess.file_exists(p):
		return ERR_FILE_NOT_FOUND
	var err := DirAccess.copy_absolute(p, ruta_base)
	if err == OK:
		print("[M60] Backup %d restaurado en %s" % [i, ruta_base])
	return err

## Borra copias fuera de la ventana (huérfanas). Devuelve cuántas borró.
static func limpiar_antiguos(ruta_base: String) -> int:
	var borrados := 0
	for i in range(MAX_BACKUPS, MAX_BACKUPS + 64):
		var p := ruta_copia(ruta_base, i)
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)
			borrados += 1
	return borrados

## Bytes ocupados por todas las copias de un archivo (diagnóstico M107).
static func espacio_usado(ruta_base: String) -> int:
	var total := 0
	for p in listar(ruta_base):
		total += FileAccess.get_file_as_bytes(p).size()
	return total

## Rotación + limpieza de todos los archivos de un slot. Devuelve
## {copias, borrados} para el log de la operación.
static func mantener_slot(slot: int) -> Dictionary:
	var r := GestorSlot.rutas_slot(slot)
	var borrados := 0
	for clave in ["save", "voxel", "meta"]:
		borrados += limpiar_antiguos(String(r[clave]))
	return {"copias": contar(String(r["save"])), "borrados": borrados}
