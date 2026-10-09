# Log 1492: BUG-104 resuelto — autoload duplicado LocalizationManager eliminado

**Fecha:** 2026-10-08
**Hora:** 21:22
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Cierre del **BUG-104** (encargo del director, msg 76 del canal): los dos autoloads
`Localization` y `LocalizationManager` NO eran dos capas legítimas — eran dos
implementaciones distintas del mismo sistema M87, consecuencia de un merge descuidado.
El autoload duplicado `LocalizationManager` fue **eliminado de `project.godot`** (solo
queda `Localization`, el correcto); las 2 únicas referencias runtime al duplicado
— ambas rotas desde su origen — fueron corregidas al correcto. Verificado con runtime
headless, suites M87/i18n, runner de regresión y gate de templos. Sin regresiones.

## Cambios Realizados

1. **`game/isla-ancestral/project.godot`** — eliminada la línea
   `LocalizationManager="*res://scripts/localizacion/localization_manager.gd"` de la
   sección `[autoload]`. Solo queda `Localization="*res://scripts/localization/localization_manager.gd"` (L59).

2. **`scripts/inventario/inventario_iter4.gd`** (`nombre_localizado`) — referencia
   corregida de `/root/LocalizationManager` a `/root/Localization`; el método
   `get_string` (que **ninguno** de los dos scripts expone, por lo que SIEMPRE cayó
   al fallback) fue reemplazado por `traducir_clave` del correcto, con detección de
   clave-devuelta-literal para el fallback.

3. **`scripts/legal/credits_manager.gd`** (`_ready`) — nodo `"LocalizationManager"` →
   `"Localization"`; señal `idioma_cambiado` (que el duplicado **ni siquiera tiene** —
   la conexión era un no-op silencioso) → `locale_changed`; método `get_idioma_actual` →
   `get_locale()`. El handler `_on_m87_idioma(nuevo: String)` se mantuvo compatible.

4. **`scripts/localizacion/test_localizacion_m87.gd`** — movido a
   `scripts/localizacion/Obsoletos/2026-10-08_00-00-00_test_localizacion_m87_autoload_eliminado_bug104.gd`
   con cabecera que explica el porqué (el test vigente de M87 es
   `scripts/localization/test_localizacion_iter6.gd`). Carpeta movida, NO borrada
   (el colector de sintaxis aún hace preloads de esa ruta).

5. **`scripts/validadores/validador_autoloads.gd`** — comentario sobre el par
   Localization/LocalizationManager pasado a histórico (el par ya no existe como
   autoload; el validador detecta rutas idénticas y nuestro par tenía rutas distintas).

6. **INTOCADOS (restricción del director):** `scripts/localization/localization_manager.gd`
   (correcto) y `scripts/localizacion/localization_manager.gd` (duplicado huérfano —
   ya no es autoload, quedó como archivo inofensivo).

### Hallazgo documentado en 11-BUGS

Las 2 referencias al duplicado estaban **muertas desde su origen**: `inventario_iter4`
llamaba `get_string` (método inexistente en ambos scripts → siempre fallback) y
`credits_manager` conectaba la señal `idioma_cambiado` (inexistente en el duplicado →
conexión silenciosamente no-op). Es decir: **nadie usaba el duplicado en runtime**;
solo su print de carga (`[M87] LocalizationManager listo (3 idiomas)`) lo hacía visible.

## Verificación

| Check | Resultado |
|---|---|
| Autoloads en `project.godot` | solo `Localization`; `LocalizationManager` eliminado |
| Runtime juego (`--quit-after 90`) | mensaje viejo `[M87] LocalizationManager listo`: **0** apariciones; **0 SCRIPT ERROR** |
| Presencia positiva (`test_ui_i18n_m53.gd`) | `OK: Localization autoload presente (M87)` + claves es resueltas; **36 OK / 3 fallos = idéntico al baseline** (3 fallos preexistentes de tooltips/InteractPrompt, probados con project.godot viejo vía `git stash`) |
| Suite M87 vigente (`test_localizacion_iter6.gd`) | **82 checks / 1 fallo** — fallo I9 preexistente, probado idéntico contra baseline con `git stash push -- project.godot` |
| Runner regresión (`res://tests/run_tests.gd`) | **21/25 suites OK / 1188 tests / 1 fallo** (quirk GdUnit4 rc=101 con 0 failures internos — preexistente; baseline evolucionó de 780→1188 tests por los sweeps de otros agentes) |
| Gate templos (`test_regresion_templos.gd`) | **76 checks / 0 fallos** |
| Nota runtime | El error headless `Parameter "fd" is null` (text server sin fuentes) también aparece en el baseline — preexistente, no relacionado |

## Archivos Modificados/Creados

- `game/isla-ancestral/project.godot` (edit)
- `game/isla-ancestral/scripts/inventario/inventario_iter4.gd` (edit)
- `game/isla-ancestral/scripts/legal/credits_manager.gd` (edit)
- `game/isla-ancestral/scripts/localizacion/Obsoletos/2026-10-08_00-00-00_test_localizacion_m87_autoload_eliminado_bug104.gd` (move + header)
- `game/isla-ancestral/scripts/validadores/validador_autoloads.gd` (edit, comentario)
- `DOCUMENTACION/11-BUGS.md` (edit — tabla L176, cuerpo BUG-104 + CIERRE, historial §9) — SIN stagear (protocolo)
- `Mensajes entre modelos/mimo-v2.6-flash-free/77-...-bug104-autoload-duplicado-eliminado-informe-cierre.md` (msg 77 al director)

## Nota de commit

No se ejecutó commit: el director barre el working tree con sus sweeps periódicos
(como ya hizo con el fix del chamán → `5a7ec48` y el shader BUG-105 → `033aeac`).
Todos los cambios quedan en working tree a la espera del próximo sweep.
