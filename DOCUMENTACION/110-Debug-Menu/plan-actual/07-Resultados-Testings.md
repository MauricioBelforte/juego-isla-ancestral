# 07-Resultados-Testings — M110-Debug-Menu

**Modelo:** atria-dawn-s3 (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 04:45:00

> QA §21.8 ejecutada por **atria-dawn-s3** sobre el triaje E-12d de **stepfun-step-5-preview**
> (verificador ≠ autor del triaje — regla de independencia §21.8). Esta es la cuarta QA §21.8
> coordinada y la segunda ejecutada por este agente.

## 1. Veredicto

**🟡 LIBERADO CON TRIAJE COMPLETO** (no ✅).

El módulo no es sellable como ✅ porque quedan **75 `[ ]`** (todos widgets de la capa UI, con
dueño asignado M110-UI). El valor entregado por este ciclo es la **auditoría E-12d**: el módulo
pasó de **90 ítems inflados** (declarados `[?]` sin verificación) a **0 `[?]`** con veredicto
binario contra disco en 5 bloques, y queda como **API backend completa, verificada y auditable**.

El criterio de sellado lo definió el director (msg 154): el veredicto correcto es liberar con
triaje completo, no exigir completitud.

## 2. Estado del checklist

| Marca | Conteo | Verificado por mí |
|---|---|---|
| `[x]` | 150 | ✓ |
| `[ ]` | 75 | ✓ |
| `[?]` | **0** | ✓ |
| **Total** | **225** | ✓ |

**Drift de Totales corregido:** la línea Totales de `05-Checklist.md` decía
`146 [x] · 27 [?] · 52 [ ]` (stale — previo a los flips de los bloques 4-5). Corregida a
`150 [x] · 0 [?] · 75 [ ]`, coincide con el conteo real y con la fila de CHECKLIST-GLOBAL.md.
La nota inferior también mencionaba "los 104 `[?]`" (stale) — reescrita reflejando el cierre del
triaje.

## 3. Muestreo anti-inflación §21.8.2.b

10 ítems `[x]` elegidos por **verbos de creación / afirmaciones de existencia**
(regla: mínimo 5 o el 5% de los `[x]` — 5% de 150 = 8; muestreé 10). Verificación contra disco:

| # | Ítem (línea) | Artefacto citado | Resultado |
|---|---|---|---|
| 1 | L75 — Lista de POI | `data/debug/poi_list.tres` + `scripts/debug/poi_list.gd` (3 POIs) | ✓ Ambos existen y versionados; **en vivo:** "poi_list: 3 POIs", "poi_list.tres existe en disco" |
| 2 | L161/L285 — DebugVisualizer | `scripts/debug/debug_visualizer.gd` (Node3D, 5 toggles) | ✓ Existe, 110 líneas; **en vivo:** "5 toggles definidos" |
| 3 | L188 — Crear ZIP | export de diagnóstico (ZIP+txt) | ✓ `user://diagnostics/` con **74 zips + 73 txt reales** (la claim "9 zips" queda corta) |
| 4 | L284 — debug_menu.gd | 730 líneas, 47 funciones | ✓ Existe, **736 líneas, 49 funciones** (≥ claim) |
| 5 | L289 — debug_console.gd | 103 líneas (`limpiar()`, `obtener_lineas()`) | ✓ Existe, 103 líneas exactas; **en vivo:** "limpiar", "obtener_lineas", "max 100 lineas" |
| 6 | L290 — escena + UI | `scenes/debug/debug_menu.tscn` + `debug_menu_ui.gd` | ✓ Ambos existen y versionados |
| 7 | L291/L248 — config | `data/debug/debug_menu_config.json` | ✓ Existe, 185 líneas |
| 8 | L292 — poi_list.tres | `data/debug/poi_list.tres` | ✓ Existe y versionado |
| 9 | L293 — diagnostics | `user://diagnostics/` generados | ✓ Carpeta existe en `%APPDATA%\Godot\app_userdata\isla-ancestral\diagnostics\` |
| 10 | L131 — Consola | RichTextLabel + `scroll_following` | ✓ 3 matches en `debug_console.gd`; **en vivo:** 14/0 |

**Resultado del muestreo: 10/10 verificados, 0 fallas.** Por la regla §21.8.2.b (0-1 fallas de 5
→ sello válido; 2+ → denegación), el muestreo **valida** los `[x]` muestreados.

### Métricas declaradas vs reales

Detecté discrepancias aparentes en el conteo de líneas y las investigué con dos métodos:

| Archivo | Claim | Mi primer método (`Measure-Object -Line`) | Método correcto (`Get-Content.Count`) | Veredicto |
|---|---|---|---|---|
| `debug_menu.gd` | 730 líneas | 618 | **736** | ✓ claim conservadora (Step 5 midió 736 en msg 33) |
| `debug_visualizer.gd` | 110 líneas | 97 | **110** | ✓ coincide |
| `debug_console.gd` | 103 líneas | 90 | **103** | ✓ coincide |

**Lección methodológica:** `Measure-Object -Line` no cuenta la última línea de archivos sin
newline final y subreporta. **Verificar conteos de líneas con `(Get-Content).Count`, no con
`Measure-Object -Line`.** Mi primer método fue el erróneo; las claims eran correctas. Sin
inflación de métricas en M110.

## 4. Sonda roja con binario real (Godot 4.7.2)

Ejecuté las **6 suites SceneTree** del módulo con
`C:\Temp\godot\Godot_v4.7.2-stable_win64_console.exe --headless`:

| Suite | Checks | Fallos | EXITCODE | Claims del checklist que valida |
|---|---|---|---|---|
| `scripts/debug/test_m110_ui.gd` | 17 | 0 | 0 | L161 (17/0), L168-170 (radios), L292 |
| `scripts/debug/test_m110_ui2.gd` | 14 | 0 | 0 | L131 (14/0), L136/L264 (100 líneas) |
| `scripts/debug/test_m110_ui3.gd` | 17 | 0 | 0 | slice 3 (DebugMenuUI + consola + visualizer) |
| `scripts/debug/test_debug_m110.gd` | 18 | 0 | 0 | L57 (5 pestañas), L242 (comando inexistente), API RF1-20 |
| `scripts/debug/test_m110_iter_atria.gd` | 27 | 0 | 0 | gaps cerrados iter. log 928 |
| `scripts/debug/test_debug_menu_headless.gd` | 22 | 0 | 0 | RF1-20, RF20 export |
| **TOTAL** | **115** | **0** | **6× 0** | |

**115 checks, 0 fallos, 6× EXITCODE=0.** La claim L303 ("67 checks, 0 fallos, 0 script errors")
queda **conservadora** frente a los 115 reales — no hay inflación.

La suite formal `tests/unit/debug/test_debug_menu.gd` es gdUnit4 (`extends GdUnitTestSuite`) y no
es ejecutable con `--script` (Godot lo rechaza: "doesn't inherit from SceneTree or MainLoop").
Tampoco aceptó `--check-only` (abortó). No es bloqueante: las 6 suites SceneTree cubren las claims
y son ejecutables directamente.

### Observaciones menores (no bloqueantes)

1. **`ERROR: Parameter "t" is null`** aparece durante `test_debug_m110.gd` (un comando invocado
   con parámetro null). Los checks pasaron igual y EXITCODE=0. Deuda menor de robustez del
   manejador de comandos: conviene responder con un mensaje de error en vez de loguear un ERROR.
2. **3 ObjectDB leaked + 1 resource leaked at exit** en `test_m110_ui.gd`. Deuda menor sin dueño
   asignado (mismo patrón observado en M24).
3. **L268 quedó `[x]` con matiz**: el propio Step 5 ofreció bajarlo a `[ ]` si el director quería
   chequeo estricto (falta verificar que `debug_visualizer._process()` consuma `visible` antes de
   dibujar). El director lo dejó `[x]` con la deuda registrada para M110-UI. Lo confirmo: el
   mecanismo de condición existe (`visible` L16, `esta_visible()` L80-81) y la nota honesta quedó
   en el checklist.
4. **L232 / doc adelantada:** `04-Codigo.md:346` documenta "Escape para cerrar" pero el cierre con
   Escape no está implementado. Ya registrado por el director como deuda de coherencia para
   M110-UI (no es bug de este módulo).

## 5. Independencia del verificador

- **Autor del triaje:** stepfun-step-5-preview (msgs 24, 26, 28, 31, 33).
- **Verificador (esta QA):** atria-dawn-s3 — **no tocó ninguna marca de M110** en ningún momento
  de los 5 bloques; solo conté y verifiqué artefactos para mis re-verificaciones de cada entrega.
- **Flips:** aplicados por el director (msg 32 + bloque 5), no por el triador ni por mí.
- Las dos ediciones que hice en este QA son: corregir el drift de la línea **Totales** (un
  meta-dato, no una marca de ítem) y añadir **esta sección de resultados** + la nota de QA en
  `05-Checklist.md`. Ninguna marca de ítem fue modificada.

## 6. Conclusión

**M110-Debug-Menu queda 🟡 Liberado con triaje completo.** El sistema E-12d quedó demostrado de
punta a punta sobre este módulo: de 90 ítems inflados a un módulo auditable con 0 `[?]`, backend
verificado por 115 checks reales y 10/10 ítems de muestra contra disco. Los 75 `[ ]` restantes
son la capa UI (M110-UI), que puede construirse sobre esta API sin tocar el backend.

**Próximo paso para el agente de M110-UI:** partir de la API pública verificada
(`alternar()`, `esta_visible()`, `pestanas()`, `ejecutar_comando()` + 24 comandos data-driven +
export de diagnóstico RF20). Implementar el cierre con Escape o corregir `04-Codigo.md:346`.

> **Corrección sobre BUG-129 y `test_debug_menu.gd` (2026-10-10, msg 34 del director):** una
> versión preliminar de este reporte advertía que BUG-129 seguía abierto y que había que
> reescribir `test_debug_menu.gd` en UTF-8 sin BOM. **Estaba desactualizada.** mimo-v2.6-flash-free
> aplicó el patch autorizado (`inst.free()` en `vegetation_spawner.gd:88`), 257 → 0 strays medidos
> con boot completo, `test_debug_menu.gd` ya está reescrito en UTF-8 sin BOM (verifiqué los primeros
> bytes: `101 120 116` = `ext`, 0 mojibake), el runner está verde (29/29 suites, 1267 tests,
> EXIT=0) y `11-BUGS.md` se flipeó a `[x] RESUELTO 2026-10-10`. **Nadie debe tocar
> `test_debug_menu.gd` de nuevo.** El gate de CI de M112 está desbloqueado.

---
**Modelo:** atria-dawn-s3 (Atria-Dawn-Preview) / **Plataforma:** Kilo Code / **Fecha:** 2026-10-10 04:45:00
