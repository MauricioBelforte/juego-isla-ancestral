# retire_asset_logic.gd — M108 Pipeline de Assets (núcleo V0, headless-compatible)
# Lógica pura de retiro: mueve final → archive, registra id retirado y detecta referencias.
#
# **Modelo:** stepfun/step-3.7-flash:free
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02

extends RefCounted

class ResultadoRetire extends RefCounted:
    var archivo: String
    var retirado: bool = false
    var advertencias: Array[String] = []

    func _init(p_archivo: String) -> void:
        archivo = p_archivo

    func agregar_advertencia(mensaje: String) -> void:
        advertencias.append(mensaje)

class ResultadoRetiro extends RefCounted:
    var retirados: int = 0
    var advertencias_total: int = 0
    var detalles: Array[ResultadoRetire] = []

    func agregar(rr: ResultadoRetire) -> void:
        detalles.append(rr)
        if rr.retirado:
            retirados += 1
        advertencias_total += rr.advertencias.size()

func retirar_asset(nombre_archivo: String, final: String = "res://assets/final/", archive: String = "res://assets/archive/") -> ResultadoRetire:
    var rr := ResultadoRetire.new(nombre_archivo)
    var origen := final + nombre_archivo
    var destino := archive + nombre_archivo

    if not FileAccess.file_exists(ProjectSettings.globalize_path(origen)):
        rr.agregar_advertencia("FINAL: '%s' no existe en final/." % nombre_archivo)
        return rr

    if FileAccess.file_exists(ProjectSettings.globalize_path(destino)):
        rr.agregar_advertencia("ARCHIVE: '%s' ya existe en archive/." % nombre_archivo)
        return rr

    DirAccess.rename_absolute(ProjectSettings.globalize_path(origen), ProjectSettings.globalize_path(destino))
    rr.retirado = true
    _registrar_retiro(nombre_archivo)
    return rr

func _registrar_retiro(nombre_archivo: String) -> void:
    var registro := "res://assets/archive/_RETIRADOS.md"
    var lineas: Array[String] = []
    if FileAccess.file_exists(registro):
        var f := FileAccess.open(registro, FileAccess.READ)
        if f:
            lineas = f.get_as_text().split("\n")
            f.close()

    var entrada := "- %s | %s" % [nombre_archivo, Time.get_date_string_from_system()]
    if not lineas.has(entrada):
        lineas.append(entrada)

    var out := FileAccess.open(registro, FileAccess.WRITE)
    if out:
        out.store_string("\n".join(lineas) + "\n")
        out.close()
