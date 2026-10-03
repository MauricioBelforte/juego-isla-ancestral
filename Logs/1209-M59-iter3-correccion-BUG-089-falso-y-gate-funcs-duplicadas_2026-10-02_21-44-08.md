# Log 1209 - M59: correccion de un falso positivo (BUG-089) y guarda contra funcs duplicadas

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Modulo:** M59-Guardado (dueno) + M83 (CI) tangencial
**Fecha:** 2026-10-02 21:44
**Estado:** Entregado y medido. NO sella 21.8 (autor != verificador).
**Tipo:** correccion de un reporte propio + herramienta de gate nueva

---

## 1. Contexto

Al retomar M59 iter. 3 (Log 1205) para cerrar el push, verifique el "HALLAZGO AJENO P0"
que yo mismo habia reportado: `minimap_widget.gd` con DOS `func _ready()` como regresion
publicada (commit `46c1f79`). **La verificacion mostro que el reporte era FALSO.**

## 2. La correccion: BUG-089 NO era un bug real

**Evidencia dura (medida, no leida):**

| Medicion | Resultado |
|---|---|
| `git log --all` que tocan `minimap_widget.gd` | 18 commits |
| `git show <c>:<ruta> \| grep -c '^func _ready'` en CADA uno | **1** en todos |
| `--check-only --script minimap_widget.gd` en HEAD | compila (sin Parse Error) |
| 3 suites de M59 en HEAD | **0 SCRIPT ERROR**, EXIT 0 |

**Conclusion:** ningun commit, en ninguna rama, tuvo dos `_ready()`. El Parse Error que vi
durante iter. 3 correspondia a un **estado TRANSITORIO del worktree** mientras M54 (agnes)
editaba el archivo (guardaba estados intermedios y los corregia). No era codigo publicado.

**Causa del error de atribucion:** medi el WORKTREE, no el CONTENIDO DEL COMMIT. El worktree
de un repo con 4 agentes puede estar en un estado intermedio ajeno en cualquier momento.

**Que se corrigio (todos los lugares donde el reporte se propago):**

- `DOCUMENTACION/11-BUGS.md`: la fila de la tabla y la entrada detallada de BUG-089, marcadas
  **INVALIDO / CORREGIDO**; la seccion 8 (delegacion a agnes) reescrita como **DELEGACION
  ANULADA**. De paso se reparo una blockquote partida (`> **` + `Regla de delegacion:**` en dos
  lineas separadas por el bloque insertado) y un heading roto (`---## 8.` en una sola linea).
- `Logs/1205`: seccion 8 reescrita; titulo y campo Tipo corregidos.
- `Mensajes entre modelos/ESTADO-PARALELO.md`: bloque del hallazgo reescrito.
- `.workbuddy-ai/memory/MEMORY.md` y `2026-10-02.md`: clausula y trampa (AF) corregidas.
- Skill `isla-ancestral-ciclo-modulo`: trampas AF y AG reescritas; se agregan AI (corregir un
  falso positivo es trabajo) y AJ (el validador nuevo).

## 3. Guarda nueva: `scripts/verificar_funcs_duplicadas.py`

**Por que:** un script GDScript con dos `func` del MISMO nombre **a nivel de clase** NO COMPILA
(`Function "X" has the same name as a previously declared function`), el archivo entero queda
roto y contamina el "0 SCRIPT ERROR" de cualquier suite. Nada lo detectaba.

**Alcance (clave para no dar falsos positivos):** solo cuenta `func NAME(` a **columna 0**
(miembro de la clase del archivo). Las funciones de las **inner classes** van indentadas y
viven en OTRO alcance: pueden repetir nombre legitimamente (los `addons/gdUnit4/*` y varios
`test_*.gd` lo hacen a proposito). Por eso NO se cuentan.

**Mediciones:**

| Prueba | Resultado |
|---|---|
| `--selftest` (5 casos: dup nivel 0, unico, inner class, `static func` dup, comentario) | **5/5 OK**, exit 0 |
| Escaneo del repo completo | **0 duplicados**, exit 0 |
| Sonda en ROJO (duplicado inyectado en un .gd real) | exit 1, "func a x2 en lineas [3, 6]" |
| Limpieza del fixture de la sonda | borrado OK |

**Gate:** nuevo step "Verify no duplicate top-level funcs (GDScript)" en el job
`encoding-guard` (que esta en el `needs:` del gate duro `summary`). `quality.yml` editado
byte-exacto preservando el invariante CRLF (**834 -> 843**, crlf==lf==cr).
`validar_workflows.py` EXIT 0 (solo los 2 avisos preexistentes BUG-078 de M117/M116).

## 4. Lo que NO hice

- **No** toque `minimap_widget.gd` (M54/agnes): no hay nada roto. Su trabajo (edge arrows,
  MapCanvas) sigue su curso.
- **No** selle 21.8 (autor != verificador).
- **No** toque `CHECKLIST-GLOBAL.md` ni el pool (tarea del coordinador); solo reserve 1209.

## 5. Archivos tocados

- `DOCUMENTACION/11-BUGS.md` (BUG-089: fila + entrada + delegacion anulada; glitches de formato)
- `Logs/1205-M59-iter3-...md` (seccion 8, titulo, Tipo)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (bloque del hallazgo)
- `scripts/verificar_funcs_duplicadas.py` (**nuevo**)
- `.github/workflows/quality.yml` (step nuevo en `encoding-guard`)
- Skill `isla-ancestral-ciclo-modulo` (AF/AG corregidas; AI/AJ nuevas)
- Memoria: `MEMORY.md` + `2026-10-02.md`

## 6. Huella de push (AGENTS.md 4.3)

- Rango publicado: (se completa al pushear)
- Hora: 2026-10-02 21:44
- Ejecutante: DeepSeek-V4.1-Flash (WorkBuddy)
- Tipo: fast-forward, sin `--force`, `GIT_TERMINAL_PROMPT=0`
- Commits propios: (se completa)
- Commits ajenos en el rango: (se completa)
