# asset_memory_reporter_logic.gd — M108 Pipeline de Assets (núcleo V0, headless-compatible)
# Lógica pura de memory reporter: estima VRAM/RAM por asset según import settings y totaliza.
#
# **Modelo:** stepfun/step-3.7-flash:free
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02

extends RefCounted

class ReporteAsset extends RefCounted:
    var archivo: String
    var vram_estimado_mb: float = 0.0
    var ram_estimado_mb: float = 0.0
    var errores: Array[String] = []

    func _init(p_archivo: String) -> void:
        archivo = p_archivo

    func agregar_error(mensaje: String) -> void:
        errores.append(mensaje)

class ReporteTotal extends RefCounted:
    var total_vram_mb: float = 0.0
    var total_ram_mb: float = 0.0
    var detalles: Array[ReporteAsset] = []

    func agregar(ra: ReporteAsset) -> void:
        detalles.append(ra)
        total_vram_mb += ra.vram_estimado_mb
        total_ram_mb += ra.ram_estimado_mb

func generar_reporte(raiz: String = "res://assets/final/") -> ReporteTotal:
    var reporte := ReporteTotal.new()
    var raiz_abs := ProjectSettings.globalize_path(raiz)
    if not DirAccess.dir_exists_absolute(raiz_abs):
        DirAccess.make_dir_recursive_absolute(raiz_abs)
        print("[M108] memory_reporter: final/ no existe; se crea vacío.")
        return reporte

    var archivos := _recorrer_assets(raiz)
    for ruta in archivos:
        var ra := _estimar_asset(ruta)
        reporte.agregar(ra)

    _escribir_reporte(reporte, raiz)
    return reporte

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
        elif not dir.current_is_dir():
            resultado.append(raiz + entrada)
        entrada = dir.get_next()
    dir.list_dir_end()
    return resultado

func _estimar_asset(ruta: String) -> ReporteAsset:
    var ra := ReporteAsset.new(ruta.get_file())
    var tam := FileAccess.get_size(ruta)
    if tam == 0:
        ra.agregar_error("TAMAÑO: archivo vacío '%s'" % ra.archivo)
        return ra

    var extension := ra.archivo.get_extension().to_lower()
    if extension in ["png", "webp"]:
        ra.ram_estimado_mb = tam / (1024.0 * 1024.0)
        ra.vram_estimado_mb = ra.ram_estimado_mb * 0.8
    elif extension in ["glb", "gltf"]:
        ra.ram_estimado_mb = tam / (1024.0 * 1024.0)
        ra.vram_estimado_mb = ra.ram_estimado_mb * 1.5
    elif extension in ["ogg", "wav"]:
        ra.ram_estimado_mb = tam / (1024.0 * 1024.0)
        ra.vram_estimado_mb = 0.0
    else:
        ra.ram_estimado_mb = tam / (1024.0 * 1024.0)
        ra.vram_estimado_mb = 0.0

    return ra

func _escribir_reporte(reporte: ReporteTotal, raiz: String) -> void:
    var lineas: Array[String] = []
    lineas.append("# Memory Report — M108")
    lineas.append("Fecha: %s" % Time.get_date_string_from_system())
    lineas.append("")
    lineas.append("## Totales")
    lineas.append("- VRAM estimada: %.2f MB" % reporte.total_vram_mb)
    lineas.append("- RAM estimada: %.2f MB" % reporte.total_ram_mb)
    lineas.append("")
    lineas.append("## Detalle")
    for detalle in reporte.detalles:
        lineas.append("- %s: VRAM=%.2f MB, RAM=%.2f MB" % [detalle.archivo, detalle.vram_estimado_mb, detalle.ram_estimado_mb])
        for e in detalle.errores:
            lineas.append("  - ERROR: %s" % e)

    var ruta := "res://assets/final/_memory_report.md"
    var f := FileAccess.open(ruta, FileAccess.WRITE)
    if f:
        f.store_string("\n".join(lineas) + "\n")
        f.close()
        print("[M108] memory_reporter: reporte escrito en %s" % ruta)
