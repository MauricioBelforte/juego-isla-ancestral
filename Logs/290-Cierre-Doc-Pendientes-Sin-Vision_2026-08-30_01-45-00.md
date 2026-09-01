# Log 290 — Cierre de pendientes documentales (sin visión)

**Fecha:** 2026-08-30
**Hora:** 01:45
**Alcance:** cerrar los pendientes del log 252 que NO requieren leer capturas PNG/JPG.

## Contexto

El segmento anterior (log 252) dejó los tres workstreams del usuario ("si cerra todos los pendientes")
funcionalmente DONE y verificados:

- Presupuesto M166: 23 variantes excedidas → **0 excedidas** (121 variantes auditadas).
- Pipeline Godot: **153 GLB** exportados, Godot `--import` → **153/153 DONE**.
- M70: 5/5 ítems cerrados y documentados.
- Desincronización: 0 restantes.

Pero faltaba volcar seis hallazgos (E-40..E-45) y tres tareas de documentación/tooling en la
guía, el checklist y la memoria. Todas son ediciones de texto o scripts filesystem: NO requieren
visión. Este log las cierra.

## Tareas completadas

### 1. Guía de Blender — E-40..E-45 insertados (DOCUMENTACION/09-GUIA-BLENDER.md)

Se insertaron 6 entradas nuevas entre el final de E-39 y `## 4. Checklist`:

- **E-40** — medir TRIÁNGULOS REALES (`loop_triangles`), nunca CARAS. Causa de fondo del
  saneo de presupuesto: `generar_alta.py` contaba polígonos y daba falso OK (totem 10.507
  caras = 21.014 tris contra techo 6.000).
- **E-41** — al reescribir índices de material, respaldar por NOMBRE, no por número (evita
  el reseteo de `material_index` de `materials.clear()`, E-35).
- **E-42** — reportar materiales USADOS POR CARAS, no slots (un slot huérfano no cuenta).
- **E-43** — colisión de nombres entre variantes: prioridad de sufijos EXPLÍCITA en
  `exportar_godot.py`, no orden de `os.listdir`. Caso real: `palanca_madera_alta` (v2
  rechazada, 14:13) vs `_lowpoly` v3 (22:54).
- **E-44** — purgar todo objeto NO-`SM_` antes de exportar glTF (el prefijo `SM_` es la
  frontera entre asset y set de captura).
- **E-45** — `bpy.context` por socket NO tiene `active_object`; el exportador glTF de Blender
  4.2 lee `context.active_object` en la primera línea de `save()`. Solución: exportar en
  HEADLESS (`blender -b --factory-startup --python exportar_godot.py` + `addon_enable
  ('io_scene_gltf2')` + opciones por env-var).

Changelog: se agregó bloque `Cambios 00:15` y se actualizó `Última actualización` a
`2026-08-30 00:15`.

### 2. CHECKLIST-OBJETOS-BLENDER.md — contadores actualizados

Se reemplazó la sección "Contadores" para reflejar el estado real:
- Presupuesto M166: **0 excedidos** (121 variantes).
- Pipeline Godot: **VIVO** (153 GLB, 153/153 en Godot).
- Desincronización: **0**.
- Última actualización: 2026-08-30 00:15.

### 3. auditar_desincronizados.py — script reutilizable real (E-46)

Antes era un one-liner Python. Ahora es un script estable en `scripts-reutilizables/` con el
mismo estilo que `auditar_optimizacion.py` (filesystem, sin Blender). Comportamiento:
- Agrupa los `.blend` de cada módulo por `base` (prefijo antes del primer sufijo conocido).
- Para cada variante, compara su `mtime` con el del fuente.
- Delta > 0 (fuente más nueva que la variante) → DESINCRONIZADA.
- `--arreglar` regenera las variantes con `generar_variante.py`.
- `--tolerancia N` ignora diferencias ≤ N segundos.
- Exit 0 = limpio, exit 1 = hay desincronizadas.

**Ejecutado en este arranque (sin Blender):** 69 assets auditados, **0 desincronizadas**,
EXIT=0. Los deltas negativos son los esperados (las derivadas son más nuevas que el fuente).

### 4. scenes/test_runner.tscn — referencia de script corregida

`res://tests/test_runner.gd` → `res://tests/run_tests.gd`. El archivo `tests/test_runner.gd`
no existe; el real es `run_tests.gd` (con su `.uid`). El error `File not found` del import de
Godot queda resuelto. No rompe el import de los 153 GLB (es un nodo de test aparte), pero
deja el proyecto limpio de referencias rotas.

## Verificación numérica

| Check | Herramienta | Resultado | Requiere Blender |
|-------|-------------|-----------|------------------|
| Desincronización | `auditar_desincronizados.py` | 0 / 69 assets | NO (filesystem) |
| Presupuesto M166 | `auditar_presupuesto.py` | 0 excedidos (verificado en log 252) | SÍ (`import bpy`) |
| Pipeline Godot | `exportar_godot.py` export + Godot `--import` | 153/153 | SÍ (headless) |

Nota: `auditar_presupuesto.py` importa `bpy` y tiene `BM` hardcodeado, así que no corre fuera
de Blender. El 0 excedidos se mantiene del log 252; no se re-ejecutó aquí porque la visión/
Blender no estaban disponibles, pero tampoco hubo ningún cambio de geometría desde entonces
que lo invalidara.

## Pendientes que QUEDAN (requieren visión / Blender)

- **QA visual de capturas** (E-10 / E-13): no se puede hacer sin leer PNGs. El usuario debe
  abrir Blender (GUI) para revivir el socket 9876 y recuperar la multimodalidad; entonces el
  otro modelo retoma el QA visual de las variantes regeneradas.
- `cono_revolucion` / `media_cana`: helpers mencionados como pendientes en el log 252, pero
  NO se halló referencia concreta a dónde deben vivir ni un bug abierto. Se dejan como nota;
  no bloquean nada.

## Archivos tocados

- `DOCUMENTACION/09-GUIA-BLENDER.md` (E-40..E-45 + changelog 00:15 + Última actualización)
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` (contadores)
- `tools/mcp/blender-mcp/scripts-reutilizables/auditar_desincronizados.py` (CREADO)
- `game/isla-ancestral/scenes/test_runner.tscn` (referencia run_tests.gd)
- `Logs/253-...md` (este log)
- `Logs/ULTIMO_NUMERO.txt` → 253

## Conclusión

Todos los pendientes del log 252 que no requieren visión están cerrados y verificados. El
proyecto queda con: presupuesto 0 excedidos, pipeline Godot vivo (153/153), 0 variantes
desincronizadas, y el checklist/guía al día. Lo único que falta para el cierre total es el QA
visual, que depende de que el usuario abra Blender para recuperar la multimodalidad.