# Log 270: Fix carga de fuentes TTF — FontFile.load_dynamic_font()

**Fecha:** 2026-08-30
**Hora:** 19:32
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
Corregido error `FreeType: Error loading font: '' (face_index=0)` que impedía cargar fuentes Nunito y Fredoka One en el tema UI. Solución: usar `FontFile.load_dynamic_font()` en vez de `load()`.

## Problema
`load("res://X.ttf")` retorna un `FontFile` importado cacheado pero con campo interno de datos vacío (`''`). FreeType no puede parsear datos vacíos → 6 errores en runtime (3 fuentes × 2 errores cada una).

## Solución
Reemplazar `load()` por `FontFile.new()` + `load_dynamic_font(path)` en `theme_ux.gd`:

```gdscript
func _try_load_font(path: String, fallback_font: Font) -> Font:
    var font_file := FontFile.new()
    var err := font_file.load_dynamic_font(path)
    if err == OK:
        return font_file as Font
    push_warning("ThemeUx: no se pudo cargar fuente desde " + path)
    return fallback_font
```

## Intentos fallidos documentados
1. `load("res://X.ttf")` — datos vacíos
2. `load("uid://...")` — idéntico
3. Wrappers `.tres` con `ext_resource` → FontFile sigue vacío
4. `preload()` — mismo problema

## Cambios realizados
- `scripts/ui/theme/theme_ux.gd`: `_try_load_font()` usa `FontFile.new()` + `load_dynamic_font()`
- `scripts/ui/theme/theme_ux.gd`: constantes PATH_FONT_* apuntan directamente a `.ttf`
- `DOCUMENTACION/07-GUIA-GODOT.md`: agregada §9.48 (carga de fuentes en runtime)
- Eliminados `.tres` wrappers innecesarios y `tools/generate_font_tres.py`

## Archivos modificados
- `game/isla-ancestral/scripts/ui/theme/theme_ux.gd`
- `DOCUMENTACION/07-GUIA-GODOT.md` (+§9.48)

## Archivos eliminados
- `game/isla-ancestral/assets/fonts/*.tres` (wrappers que no funcionaban)
- `game/isla-ancestral/tools/generate_font_tres.py`

## Verificación
- Ejecución del proyecto: 0 errores FreeType
- `[M53] Tema cozy global aplicado (escala 1.00)` — carga exitosa
