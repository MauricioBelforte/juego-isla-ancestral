# Checklist y Referencias Rápidas

> **Modelo:** MiMo V2.5
> **Plataforma:** OpenCode
> **Fecha:** 2026-09-09
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §6 + §7
> **Validado en:** Isla Ancestral — Godot 4.7.2

---

## Checklist al Escribir Código GDScript

- [ ] ¿La función tiene `static func` si no accede a variables de instancia?
- [ ] ¿Las variables/parámetros no usados tienen prefijo `_`?
- [ ] ¿Las señales usan `snake_case`?
- [ ] ¿`:=` solo se usa con tipos explícitos (NO con null/Variant)?
- [ ] ¿`add_child()` no se llama durante `_ready()` (usar `.call_deferred()`)?
- [ ] ¿No se está sobrescribiendo `show()`, `hide()` o `get_visible()` en CanvasLayer?
- [ ] ¿El script extiende el mismo tipo que el nodo en .tscn?
- [ ] ¿No hay `class_name` que colisione con autoloads o clases nativas?
- [ ] ¿No se usa `type` como nombre de variable/parámetro?
- [ ] ¿No se usa `print()` con formato incorrecto (`% [args]`)?
- [ ] ¿`Input` se usa correctamente (no `get_current_input_device_state()`)?
- [ ] ¿No se usan comandos markdown en `.gd` (`** **`)?
- [ ] ¿`@export` no usa inner classes como tipo de Array?
- [ ] ¿No se capturan lambdas con += (usar Array como contenedor mutable)?

---

## Referencias Rápidas

### Godot 4.7
- [Docs](https://docs.godotengine.org/)
- [Dev snapshot](https://godotengine.org/development/)

### Voxel Tools
- [Docs](https://voxel-tools.readthedocs.io/)
- [GitHub](https://github.com/Zylann/godot_voxel)
- [Demo project](https://github.com/Zylann/godot_voxel/tree/master/demo)

### Jolt Physics
- [GitHub](https://github.com/godotengine/godot-jolt)
- [Comparison (2023)](https://github.com/godotengine/godot/issues/61854)

### Herramientas internas
- `scripts/check_tscn_errors.py` — Análisis estático de .tscn
- `scripts/validador_isla_raiz.gd` — Validación del terreno de la Isla Raíz

### Errores conocidos
- Ver `06-registro-errores.md` — Registro de errores (E-11 a E-19)
- Ver `docs/ERRORS.md` — Errores conocidos de Godot
- Ver `09-godot4-migracion.md` — Errores de migración Godot 4.x
