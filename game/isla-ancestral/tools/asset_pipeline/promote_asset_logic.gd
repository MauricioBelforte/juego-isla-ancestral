# promote_asset_logic.gd — M108 Pipeline de Assets (núcleo V0, headless-compatible)
# Lógica pura de aprobación: mueve staging → final y actualiza _APROBADAS.md.
#
# **Modelo:** stepfun/step-3.7-flash:free
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02

extends RefCounted

class ResultadoPromote extends RefCounted:
    var archivo: String
    var promovido: bool = false
    var errores: Array[String] = []

    func _init(p_archivo: String) -> void:
        archivo = p_archivo

    func agregar_error(mensaje: String) -> void:
        errores.append(mensaje)

class ResultadoPromocion extends RefCounted:
    var promovidos: int = 0
    var errores_total: int = 0
    var detalles: Array[ResultadoPromote] = []

    func agregar(rp: ResultadoPromote) -> void:
        detalles.append(rp)
        if rp.promovido:
            promovidos += 1
        errores_total += rp.errores.size()

func promover_asset(nombre_archivo: String, staging: String = "res://assets/staging/", final: String = "res://assets/final/") -> ResultadoPromote:
    var rp := ResultadoPromote.new(nombre_archivo)
    var origen := staging + nombre_archivo
    var destino := final + nombre_archivo

    if not FileAccess.file_exists(ProjectSettings.globalize_path(origen)):
        rp.agregar_error("STAGING: '%s' no existe." % nombre_archivo)
        return rp

    if FileAccess.file_exists(ProjectSettings.globalize_path(destino)):
        rp.agregar_error("FINAL: '%s' ya existe en final/." % nombre_archivo)
        return rp

    DirAccess.rename_absolute(ProjectSettings.globalize_path(origen), ProjectSettings.globalize_path(destino))
    rp.promovido = true
    _actualizar_indice(nombre_archivo, destino)
    return rp

func _actualizar_indice(nombre_archivo: String, destino: String) -> void:
    var indice := "res://assets/final/_APROBADAS.md"
    var lineas: Array[String] = []
    if FileAccess.file_exists(indice):
        var f := FileAccess.open(indice, FileAccess.READ)
        if f:
            lineas = f.get_as_text().split("\n")
            f.close()

    var entrada := "- %s | %s | %s" % [nombre_archivo, Time.get_date_string_from_system(), destino]
    if not lineas.has(entrada):
        lineas.append(entrada)

    var out := FileAccess.open(indice, FileAccess.WRITE)
    if out:
        out.store_string("\n".join(lineas) + "\n")
        out.close()
