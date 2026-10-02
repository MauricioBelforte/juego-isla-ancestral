# Log 1184: Sello de M131-Creditos - pantalla de credito implementada y KnownIssue de audio

**Fecha:** 2026-10-02
**Hora:** 04:39
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Se sello **M131-Creditos** a OK siguiendo la decision del coordinador (implementar la pantalla
y luego sellar). La pantalla de credito **no existia**: `ui_root.gd` solo imprimia el placeholder
`[M89] Credito -> pendiente de implementar` y `git ls-files` no devolvia ninguna escena de creditos.
Se implemento, se testeo, se reclasificaron los 9 `[?]` de audio a `[ ]` KnownIssue con la causa
VERDADERA, y se cerro la fila 131 de `CHECKLIST-GLOBAL.md`.

**Estado final del checklist:** 95 items · 85 [x] · 10 [ ] · **0 [?]**.

## Decisiones y contexto

- **Decision del coordinador (question tool):** (1) implementar la pantalla y luego sellar ->
  HECHO; (2) esperar a que `CHECKLIST-GLOBAL.md` se liberara -> se espero y se edito; (3) usar el
  pool **1182**.
- **Desviacion del numero de log:** el 1182 ya estaba consumido
  (`Logs/1182-M105-reverificacion-guardianes-6-sondas-piso-iter7_2026-10-02_04-12-00.md` y el
  commit `6146612`). Por el protocolo 6.1.a se tomo la **primera linea del pool = 1184**.
- **Texto de la fila 131:** la columna `Notas` fue **dictada por el coordinador** y se aplico
  verbatim, mas la firma propia (`Sello ejecutado por mimo-v2.6-flash-free (opencode) 2026-10-02,
  Log 1184`), porque 29 prohíbe firmar con identidad ajena.
- El borrado de `Logs/NUMEROS_DISPONIBLES.txt` en este commit incluye ademas el **1182 y 1183**
  que otros agentes habian consumido en el arbol de trabajo sin commitear todavia.

## Cambios Realizados

1. **NUEVO `scripts/ui/layers/credits_layer.gd`** (`class_name CreditsLayer extends UILayer`,
   `MODAL_FULL`): los 10 items de la Seccion D del checklist.
   - D1 scroll suave de creditos con rodillo continuo (`RichTextLabel` + auto-scroll px/s) y
     salto suave a secciones (PageUp/PageDown) cacheando offsets con `get_line_offset`.
   - D2 boton pausa/continuar (`_alternar_anim`) · D3 tamanos S/M/L [12,16,20] ·
     D4 alto contraste via `credits_manager.color_contraste_accesible(fondo)` ·
     D5 velocidades [42,16,95] px/s · D6 cambio de idioma en caliente con reconstruccion ·
     D7 copyright con anio auto · D8 paleta arena/ocre de `ThemeUx` ·
     D9 limite de 300 s con despedida · D10 foco en 6 botones + ESC/PageUp/PageDown.
   - `on_layer_opened()` guarda y restaura el foco previo.
2. **NUEVO `scripts/legal/test_credits_layer_m131.gd`**: 42 checks / 0 fallos. Cubre montaje,
   open/close, controles D2-D6, idioma en caliente, contraste, contador, salto de seccion y fin
   a los 5 minutos. Incluye asercion de regresion por `get_v_scroll_bar`.
3. **`scripts/ui/ui_root.gd`**: `var credits_layer`, montaje tras `LoadingLayer`, y
   `menus_layer.creditos_pedido -> credits_layer.open()`. **No** `push_layer()`: es no-op para
   capas ya registradas (`ui_manager.gd` L457-459).
4. **`DOCUMENTACION/131-Creditos/plan-actual/05-Checklist.md`**: los 9 `[?]` -> `[ ]` KnownIssue
   con causa verdadera; C38 contador `[ ]` -> `[x]`; cabecera y `Totales` actualizados; nota
   corrigiendo la afirmacion falsa sobre los modulos de audio.
5. **`DOCUMENTACION/131-Creditos/plan-actual/04-Codigo.md`**: tabla de archivos con el estado
   REAL, API publica real vs API prevista, pendientes actualizados y Notas del Agente.
6. **`CHECKLIST-GLOBAL.md`** fila 131: `Con dudas` -> `Completado`, `84/95` -> `85/95`,
   actividad -> 2026-10-02, `Notas` con el sello. Edicion binaria, 10 celdas preservadas.

## Hallazgos tecnicos (pendientes de llevar a GUIA-GODOT)

1. **`get_vscroll_bar()` NO existe**: compila con `--check-only` (EXIT=0) pero revienta en runtime
   con `Nonexistent function`. El nombre real es **`get_v_scroll_bar()`**. Corregido en 3 sitios.
   **Leccion: `--check-only` NO valida nombres de metodos; hay que ejecutar el codigo.**
2. **La causa de los 9 `[?]` de audio era FALSA.** El checklist afirmaba "modulos de audio que
   aun no existen", pero M41/M42/M43/M91 existen, tienen autoloads en `project.godot` y pasan
   tests (M41 14/0, M43 15/0). La causa real: **0 archivos de audio en el repo**
   (`.ogg`/`.wav`/`.mp3`/`.opus`), `UIFeedback` crea 4 `AudioStreamPlayer` sin asignar streams, y
   `sfx_surfaces.json` solo define superficies de terreno. `music_context_matrix.json` **si** ya
   define el tema `flow_creditos`.
3. **Bug propio durante la edicion de GLOBAL:** use la variable `i` de un `for i, l in ...`
   DESPUES del bucle, donde conservaba la ultima iteracion (indice 231 = el `""` final), y
   AGREGUE la fila 131 al final del archivo en vez de REEMPLAZAR la de la linea 74. Lo detectaron
   las aserciones (numstat `1 0` en vez de `1 1` + conteo de ocurrencias = 2). Se revirtio con
   `git restore --source=HEAD --staged --worktree` y se rehizo capturando el indice DENTRO del
   `if`. **Leccion: no leer la variable de un bucle despues de cerrarlo.**
4. **BOM en el asunto del commit `ce8312b`:** `Out-File -Encoding UTF8` de PowerShell 5.1 escribe
   UTF-8 **con BOM**, que viajo al mensaje de commit (`U+FEFF` visible en `git log`). No se hizo
   amend (regla de git). Los commits siguientes escriben el mensaje directo con Python.
5. **`push_layer()` es no-op** para capas montadas por `UIRoot` (ya registradas en `_enter_tree`),
   y `ui_root.gd:152` usa `push_layer(pause_layer)` = bug preexistente NO tocado en este turno.

## Verificacion

| Prueba | Resultado |
|---|---|
| `run_tests.py --module m131` | **4 OK, 0 FAIL** (incluye `test-credits_layer_m131`) |
| `run_tests.py --module m84` | **1 OK, 0 FAIL** (sin regresion) |
| Arranque headless `--quit-after 90` | **0 SCRIPT ERROR**; `CreditsLayer (pila=11)`, `creditos=true` |
| `CHECKLIST-GLOBAL.md` numstat | **1/1**, CRLF 231 -> 231, fila 131 unica en la linea 74 |
| Encoding | UTF-8 sin BOM, 0 caracteres C1, 0 U+FFFD |

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/ui/layers/credits_layer.gd` (NUEVO)
- `game/isla-ancestral/scripts/legal/test_credits_layer_m131.gd` (NUEVO)
- `game/isla-ancestral/scripts/ui/ui_root.gd`
- `DOCUMENTACION/131-Creditos/plan-actual/04-Codigo.md`
- `DOCUMENTACION/131-Creditos/plan-actual/05-Checklist.md`
- `CHECKLIST-GLOBAL.md` (solo fila 131)
- `Logs/NUMEROS_DISPONIBLES.txt` (1184 consumido)
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md`

## Commits

- `ce8312b` - implementacion y documentacion (5 archivos, 787+/41-)
- `5bfca88` - fila 131 de CHECKLIST-GLOBAL (1/1)
- este commit - log 1184 + baja de pool + backlog

**Push:** NO realizado (push negativo).
