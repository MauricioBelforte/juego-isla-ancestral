# atlas_builder_logic.gd — M108 Pipeline de Assets (núcleo V0, headless-compatible)
# Lógica pura de atlas builder: empaca texturas del mismo set en atlas ≤ 4096² con margen anti-bleeding.
#
# **Modelo:** stepfun/step-3.7-flash:free
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02

extends RefCounted

const ATLAS_MAX_SIZE := 4096
const MARGEN := 4

class ResultadoAtlas extends RefCounted:
    var atlas: String
    var textos_empacadas: int = 0
    var errores: Array[String] = []

    func _init(p_atlas: String) -> void:
        atlas = p_atlas

    func agregar_error(mensaje: String) -> void:
        errores.append(mensaje)

class ResultadoAtlasBuilder extends RefCounted:
    var atlas_generados: int = 0
    var errores_total: int = 0
    var detalles: Array[ResultadoAtlas] = []

    func agregar(ra: ResultadoAtlas) -> void:
        detalles.append(ra)
        if ra.errores.is_empty():
            atlas_generados += 1
        errores_total += ra.errores.size()

func construir_atlas(categoria: String, raiz: String = "res://assets/staging/") -> ResultadoAtlasBuilder:
    var resultado := ResultadoAtlasBuilder.new()
    var categoria_abs := ProjectSettings.globalize_path(raiz + categoria)
    if not DirAccess.dir_exists_absolute(categoria_abs):
        DirAccess.make_dir_recursive_absolute(categoria_abs)
        print("[M108] atlas_builder: categoría '%s' no existe; se crea vacía." % categoria)
        return resultado

    var archivos := _recorrer_texturas(categoria_abs)
    if archivos.is_empty():
        return resultado

    var atlas := _generar_atlas(archivos, categoria)
    if atlas != null:
        resultado.agregar(atlas)

    return resultado

func _recorrer_texturas(categoria_abs: String) -> Array[String]:
    var resultado: Array[String] = []
    var dir := DirAccess.open(categoria_abs)
    if dir == null:
        return resultado

    dir.list_dir_begin()
    var entrada := dir.get_next()
    while entrada != "":
        if entrada == "." or entrada == "..":
            pass
        elif not dir.current_is_dir():
            var ext := entrada.get_extension().to_lower()
            if ext in ["png", "webp"]:
                resultado.append(categoria_abs + "/" + entrada)
        entrada = dir.get_next()
    dir.list_dir_end()
    return resultado

func _generar_atlas(archivos: Array[String], categoria: String) -> ResultadoAtlas:
    var ra := ResultadoAtlas.new(categoria)
    if archivos.size() == 0:
        return ra

    var atlas_path := "res://assets/final/atlas_%s.png" % categoria
    var atlas_abs := ProjectSettings.globalize_path(atlas_path)
    var imagenes: Array[Image] = []

    for ruta in archivos:
        var img := Image.new()
        var err := img.load(ruta)
        if err != OK:
            ra.agregar_error("IMAGEN: no se pudo cargar '%s'" % ruta)
            continue
        imagenes.append(img)

    if imagenes.is_empty():
        ra.agregar_error("ATLAS: ninguna textura válida en '%s'" % categoria)
        return ra

    var atlas_img := Image.create(ATLAS_MAX_SIZE, ATLAS_MAX_SIZE, false, Image.FORMAT_RGBA8)
    atlas_img.fill(Color(0, 0, 0, 0))

    var x := MARGEN
    var y := MARGEN
    var fila_altura := 0

    for img in imagenes:
        if x + img.get_width() + MARGEN > ATLAS_MAX_SIZE:
            x = MARGEN
            y += fila_altura + MARGEN
            fila_altura = 0

        if y + img.get_height() + MARGEN > ATLAS_MAX_SIZE:
            ra.agregar_error("ATLAS: excede %dx%d en '%s'" % [ATLAS_MAX_SIZE, ATLAS_MAX_SIZE, categoria])
            return ra

        atlas_img.blit_rect(img, Rect2(Vector2(0, 0), Vector2(img.get_width(), img.get_height())), Vector2(x, y))
        x += img.get_width() + MARGEN
        fila_altura = max(fila_altura, img.get_height())

    atlas_img.save_png(atlas_abs)
    ra.textos_empacadas = imagenes.size()
    return ra
