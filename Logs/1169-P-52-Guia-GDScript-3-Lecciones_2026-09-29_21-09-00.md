# Log 1169: P-52 se documentaron las 3 lecciones GDScript en GUIA-GODOT/01 (§26-§28)

**Fecha:** 2026-09-29
**Hora:** 21:09
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen

P-52 (deuda pendiente de P-49): se documentaron en `DOCUMENTACION/GUIA-GODOT/01-gdscript-errores-comunes.md`
las 3 trampas de GDScript que cazé en código de producción durante P-38/P-49 (Godot 4.7.2),
con el formato de la guía (síntomo/exacta causa/solución + fecha). Son lecciones §26 obligatorias
antes de codificar (AGENTS.md §26).

## Cambios Realizados

1. **`GUIA-GODOT/01-gdscript-errores-comunes.md`** — 3 secciones nuevas + 3 filas en la tabla
   "Errores rápidos de referencia" + firma de cabecera:
   - **§26. Autoload no resuelto en `_ready()` de un nodo de escena.** Síntoma:
     `get_node_or_null("/root/fauna")` devuelve null en `_ready()` **aunque el autoload existe
     y su log de boot ya se vio** (falla en silencio, no es error de parse). Causa: orden de
     ready del árbol (timing). Solución: lookup **lazy + reintento** vía el patrón canónico del
     repo `Engine.get_main_loop().root.get_node_or_null(...)` (como `fauna_manager`), con tope de
     reintento y degradación honesta.
   - **§27. `Vector3.xz` es property read-only y NO pasa por dispatch de Variant.** Síntoma
     exacto: `SCRIPT ERROR: Invalid access to property or key 'xz' on a base object of type
     'Vector3'.` (cuando el Vector3 llega por referencia no tipada). Causa: `.xz/.yx/.zy` son
     getters read-only de componentes; el dispatch genérico de `Variant` no los resuelve, en
     cambio las componentes base settable (`.x/.y/.z`) sí. Solución:
     `Vector2(v.x, v.z)` / `Vector3(v.x, 0.0, v.z)`.
   - **§28. `:=` sobre un helper que devuelve Variant no infiere tipo.** Síntoma exacto:
     `SCRIPT ERROR: Parse Error: Cannot infer the type of "locator" variable because the
     expression does not have a set type.` (al escribir `var x := helper()` donde `helper()`
     no declara `-> Tipo`). Causa: `:=` exige tipo estático concreto en el RHS; una función
     sin anotación devuelve `Variant`. Solución: `var x = ...` (sin inferencia) o anotar el
     tipo explícito.
2. **Fila 26** en `TAREAS-POR-MODELO/agnes-3-flash/BACKLOG-MASTER.md`.

## Contexto (de dónde salen las lecciones)

Las 3 trampas se dispararon al integrar el spawner de fauna M36 en `main_island` (P-49) y al
corregir la integración de M65 (P-38): el autoload `fauna` no estaba listo en el `_ready` del
nodo spawner (§26), `MundoRaiz.SPAWN_CONTENIDO.xz` fallaba por Variant read-only (§27) y
`var locator := _get_locator()` no infería tipo (§28). Tres errores distintos, todos reales,
todos en código que terminó en producción.

## Archivos Modificados/Creados

- `DOCUMENTACION/GUIA-GODOT/01-gdscript-errores-comunes.md` (secciones 26-28 + tabla + firma)
- `Logs/1169-P-52-Guia-GDScript-3-Lecciones_2026-09-29_21-09-00.md` (este archivo)
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/BACKLOG-MASTER.md` (fila 26)
