# apply_import_presets_logic.gd — M108 Pipeline de Assets (núcleo V0, headless-compatible)
# Lógica pura de aplicación de presets de importación: compara .import contra reglas y corrige desviaciones.
#
# **Modelo:** stepfun/step-3.7-flash:free
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02

extends RefCounted

const PRESETS := {
    "tex_3d": {
        "extensions": ["png", "webp"],
        "settings": {
            "compress/mode": 2,  # VRAM Compressed
            "mipmaps/generate": true,
            "texture/quality": 1,  # high_quality
            "texture/filter": 1,  # filter on
            "texture/repeat": 0,  # repeat off
            "process/fix_alpha_border": true,
        }
    },
    "tex_ui": {
        "extensions": ["png", "webp"],
        "settings": {
            "compress/mode": 2,
            "mipmaps/generate": false,
            "texture/quality": 1,
            "texture/filter": 0,
            "texture/repeat": 0,
            "process/fix_alpha_border": true,
        }
    },
    "voxel_palette": {
        "extensions": ["png", "webp"],
        "settings": {
            "compress/mode": 2,
            "mipmaps/generate": false,
            "texture/quality": 1,
            "texture/filter": 0,
            "texture/repeat": 0,
            "process/fix_alpha_border": true,
        }
    },
    "mesh_glb": {
        "extensions": ["glb", "gltf"],
        "settings": {
            "import/merge_meshes": false,
            "import/optimize_meshes": true,
            "import/shadow_mesh": true,
            "import/vertex_compression": true,
        }
    },
    "audio_ogg": {
        "extensions": ["ogg"],
        "settings": {
            "audio/compress": 1,  # Vorbis
            "audio/loop": false,
        }
    },
    "audio_wav": {
        "extensions": ["wav"],
        "settings": {
            "audio/compress": 0,  # PCM
            "audio/loop": true,
        }
    },
    "font_ttf": {
        "extensions": ["ttf", "otf"],
        "settings": {
            "font/msdf": true,
            "font/antialiasing": true,
            "font/subset": true,
        }
    },
}

class ResultadoPreset extends RefCounted:
    var archivo: String
    var corregido: bool = false
    var errores: Array[String] = []

    func _init(p_archivo: String) -> void:
        archivo = p_archivo

    func agregar_error(mensaje: String) -> void:
        errores.append(mensaje)

class ResultadoAplicacion extends RefCounted:
    var errores_total: int = 0
    var corregidos: int = 0
    var detalles: Array[ResultadoPreset] = []

    func agregar(rp: ResultadoPreset) -> void:
        detalles.append(rp)
        if rp.corregido:
            corregidos += 1
        errores_total += rp.errores.size()

func aplicar_presets(raiz: String = "res://assets/staging/") -> ResultadoAplicacion:
    var resultado := ResultadoAplicacion.new()
    var raiz_abs := ProjectSettings.globalize_path(raiz)
    if not DirAccess.dir_exists_absolute(raiz_abs):
        DirAccess.make_dir_recursive_absolute(raiz_abs)
        print("[M108] apply_import_presets: staging/ no existe; se crea vacío.")
        return resultado

    var archivos := _recorrer_assets(raiz)
    for ruta in archivos:
        var rp := _procesar_asset(ruta, raiz)
        resultado.agregar(rp)

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

func _procesar_asset(ruta: String, raiz: String) -> ResultadoPreset:
    var rp := ResultadoPreset.new(ruta.replace(raiz, ""))
    var nombre := rp.archivo.get_file()
    var extension := nombre.get_extension().to_lower()

    var preset := _detectar_preset(extension)
    if preset == null:
        rp.agregar_error("FORMATO: extensión '%s' sin preset definido." % extension)
        return rp

    var import_path := ruta + ".import"
    if not FileAccess.file_exists(import_path):
        rp.agregar_error("IMPORT: falta archivo .import para '%s'" % rp.archivo)
        return rp

    var cambios := _aplicar_preset_import(import_path, preset)
    if not cambios.is_empty():
        rp.corregido = true
        rp.agregar_error("AJUSTADO: %s" % ", ".join(cambios))

    return rp

func _detectar_preset(extension: String) -> Dictionary:
    for clave in PRESETS:
        if extension in PRESETS[clave]["extensions"]:
            return PRESETS[clave]
    return {}

func _aplicar_preset_import(import_path: String, preset: Dictionary) -> Array[String]:
    var cambios: Array[String] = []
    var import_abs := ProjectSettings.globalize_path(import_path)
    var f := FileAccess.open(import_abs, FileAccess.READ)
    if f == null:
        return cambios

    var contenido := f.get_as_text()
    f.close()

    var json := JSON.new()
    if json.parse(contenido) != OK:
        return cambios

    var data: Dictionary = json.get_data()
    var params := data.get("params", {})
    var settings := preset.get("settings", {})
    var modificado := false

    for clave in settings:
        var esperado := settings[clave]
        if params.has(clave):
            var actual := params[clave]
            if _valores_distintos(actual, esperado):
                params[clave] = esperado
                modificado = true
                cambios.append(clave)
        else:
            params[clave] = esperado
            modificado = true
            cambios.append(clave)

    if modificado:
        data["params"] = params
        var out := FileAccess.open(import_abs, FileAccess.WRITE)
        if out:
            out.store_string(JSON.stringify(data, "\t"))
            out.close()

    return cambios

func _valores_distintos(a, b) -> bool:
    if typeof(a) != typeof(b):
        return true
    if a is Dictionary and b is Dictionary:
        return a.hash() != b.hash()
    return a != b
