# asset_validator_logic.gd — M108 Pipeline de Assets (núcleo V0, headless-compatible)
# Lógica pura de validación: puede ejecutarse en editor o headless.
#
# **Modelo:** step-3.7-flash
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02

extends RefCounted

# ---------------------------------------------------------------------------
# Reglas de validación
# ---------------------------------------------------------------------------
const REGLAS_NOMBRE := {
    "regex": r"^(mdl|tex|mat|aud|anim|fnt|ui|vox)_[a-z0-9_]{1,59}$",
    "mensaje": "NOMBRE inválido: debe ser {prefijo}_{entidad}_{variante}. Ej: mdl_casa_madera_01"
}

const REGLAS_EXTENSION := {
    "glb": ["mdl"],
    "gltf": ["mdl"],
    "obj": ["mdl"],
    "png": ["tex", "ui", "vox"],
    "webp": ["tex", "ui"],
    "ogg": ["aud"],
    "wav": ["aud"],
    "ttf": ["fnt"],
    "otf": ["fnt"],
}

# ---------------------------------------------------------------------------
# Data classes (RefCounted)
# ---------------------------------------------------------------------------
class ValidacionArchivo extends RefCounted:
    var archivo: String
    var errores: Array[String] = []
    var aprobado: bool = false

    func _init(p_archivo: String) -> void:
        archivo = p_archivo

    func agregar_error(mensaje: String) -> void:
        errores.append(mensaje)

    func finalizar() -> void:
        aprobado = errores.is_empty()

class ResultadoPipeline extends RefCounted:
    var errores_total: int = 0
    var aprobados: int = 0
    var detalles: Array[ValidacionArchivo] = []

    func agregar(rv: ValidacionArchivo) -> void:
        detalles.append(rv)
        if rv.aprobado:
            aprobados += 1
        else:
            errores_total += rv.errores.size()

# ---------------------------------------------------------------------------
# API principal
# ---------------------------------------------------------------------------
func validar_pipeline(raiz: String = "res://assets/staging/") -> ResultadoPipeline:
    var resultado := ResultadoPipeline.new()

    # Si staging no existe, crearlo vacío
    var raiz_abs := ProjectSettings.globalize_path(raiz)
    if not DirAccess.dir_exists_absolute(raiz_abs):
        DirAccess.make_dir_recursive_absolute(raiz_abs)
        print("[M108] assets/staging/ no existe; se crea vacío.")
        return resultado

    var archivos := _recorrer_assets(raiz)
    for ruta in archivos:
        var rv := _validar_archivo(ruta, raiz)
        rv.finalizar()
        resultado.agregar(rv)

    return resultado

func _recorrer_assets(raiz: String) -> Array[String]:
    var resultado: Array[String] = []
    var raiz_abs := ProjectSettings.globalize_path(raiz)
    var dir := DirAccess.open(raiz_abs)
    if dir == null:
        return resultado

    dir.list_dir_begin()
    var entrada := dir.get_next()
    while entrada != "":
        if entrada == "." or entrada == "..":
            pass
        elif dir.current_is_dir():
            var sub := _recorrer_assets(raiz + entrada + "/")
            for s in sub:
                resultado.append(s)
        else:
            resultado.append(raiz + entrada)
        entrada = dir.get_next()
    dir.list_dir_end()
    return resultado

func _validar_archivo(ruta_completa: String, raiz: String) -> ValidacionArchivo:
    var rv := ValidacionArchivo.new(ruta_completa.replace(raiz, ""))
    var nombre_archivo := rv.archivo.get_file()
    var extension := nombre_archivo.get_extension().to_lower()

    _validar_nombre(nombre_archivo, rv)
    _validar_extension(extension, rv)
    _validar_ficha(nombre_archivo, rv)
    if extension in ["png", "webp"]:
        _validar_textura_vram(ruta_completa, rv)
    if extension == "wav":
        _validar_wav_corto(ruta_completa, rv)

    return rv

# ---------------------------------------------------------------------------
# Reglas individuales
# ---------------------------------------------------------------------------
func _validar_nombre(nombre: String, rv: ValidacionArchivo) -> void:
    var base := nombre.get_basename()
    var regex := RegEx.new()
    regex.compile(REGLAS_NOMBRE["regex"])
    if not regex.search(base):
        rv.agregar_error("NOMBRE inválido: '%s' (debe ser {prefijo}_{entidad}_{variante})" % base)

func _validar_extension(extension: String, rv: ValidacionArchivo) -> void:
    if extension not in REGLAS_EXTENSION:
        rv.agregar_error("FORMATO: extensión '%s' no permitida en staging." % extension)

func _validar_ficha(nombre_archivo: String, rv: ValidacionArchivo) -> void:
    var base := nombre_archivo.get_basename()
    var ruta_ficha := "res://assets/fichas/%s.md" % base
    if not FileAccess.file_exists(ruta_ficha):
        rv.agregar_error("FICHA: falta ficha en assets/fichas/%s.md" % base)

func _validar_textura_vram(ruta: String, rv: ValidacionArchivo) -> void:
    var import_path := ruta + ".import"
    if not FileAccess.file_exists(import_path):
        rv.agregar_error("TEXTURA: falta archivo .import para '%s'" % rv.archivo)

func _validar_wav_corto(ruta: String, rv: ValidacionArchivo) -> void:
    var tam := FileAccess.get_size(ruta)
    if tam > 1024 * 1024:  # > 1 MB ≈ > 5 s en WAV 44.1kHz 16-bit
        rv.agregar_error("AUDIO: WAV supera 5 s (%.1f MB); usar OGG para música." % (tam / (1024.0 * 1024.0)))

# ---------------------------------------------------------------------------
# Reporte
# ---------------------------------------------------------------------------
func escribir_reporte(resultado: ResultadoPipeline) -> int:
    # Devuelve 0 si todo OK, número de errores si falla (para CI)
    var lineas: Array[String] = []
    lineas.append("# Reporte de Validación de Assets — M108")
    lineas.append("Fecha: %s" % Time.get_date_string_from_system())
    lineas.append("")
    lineas.append("## Resumen")
    lineas.append("- Aprobados: %d" % resultado.aprobados)
    lineas.append("- Errores: %d" % resultado.errores_total)
    lineas.append("")

    if resultado.errores_total > 0:
        lineas.append("## Errores")
        for detalle in resultado.detalles:
            if not detalle.aprobado:
                lineas.append("### %s" % detalle.archivo)
                for e in detalle.errores:
                    lineas.append("- %s" % e)
                lineas.append("")

    var reporte := "\n".join(lineas)
    var ruta := "res://assets/staging/_reporte_validacion.md"
    var archivo := FileAccess.open(ruta, FileAccess.WRITE)
    if archivo:
        archivo.store_string(reporte)
        archivo.close()
        print("[M108] Reporte escrito en: %s" % ruta)
    else:
        push_error("[M108] No se pudo escribir el reporte en %s" % ruta)

    return resultado.errores_total
