# 07-Resultados-Testings — M110-Debug-Menu

**Modelo:** atria-dawn-s3 (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 04:45:00

> QA §21.8 ejecutada por **atria-dawn-s3** sobre el triaje E-12d de **step-5-kilocode**
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

- **Autor del triaje:** step-5-kilocode (msgs 24, 26, 28, 31, 33).
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

---

## 9. Persistencia de estado — iter. 2026-10-27 (DeepSeek-V4.1-Flash, Log 2214)

**Suite:** `scripts/debug/test_debug_menu_config_m110.gd` (NUEVA, 7 bloques A–G).
**Resultado: 75 checks / 0 fallos / EXIT 0 ×3.** Piso `CHECKS_MINIMOS = 75` **MEDIDO** en
verde (A 14 + B 9 + C 18 + D 9 + E 11 + F 7 + G 7), no estimado.

### Qué se mide (contrato, no cifras de contenido)

| Bloque | Qué verifica |
|--------|--------------|
| A | `estado_actual()` tiene las 6 claves, versión declarada, 6 toggles, filtros por defecto en -1, instancia nueva limpia |
| B | `save_config()` escribe JSON parseable, sin `.tmp` residual, **idempotente byte a byte**, deja el estado limpio |
| C | **round-trip**: set → save → instancia nueva → `_cargar_estado()` restaura geometría, paneles, los 6 toggles y los 4 filtros; panel/toggle desconocido → `false` |
| D | `reset_config()` borra el archivo, vuelve a defaults y deja el estado limpio; el guardado posterior regenera con defaults |
| E | filtros de consola por nivel, categoría y búsqueda **case-insensitive**, combinación que da 0, autoscroll no filtra, y el tope de 100 líneas se aplica también a las entradas con nivel |
| F | guardado al cerrar: **sin cambios NO escribe**, con cambios escribe en `EXIT_TREE` **y** en `WM_CLOSE_REQUEST`, y lo escrito se recupera |
| G | fail-closed: JSON inválido → defaults y **el archivo corrupto no se pisa**; versión distinta → defaults; cableado estático de `_ready`→`_cargar_estado()` y `_notification`→`save_config()` |

### Guardián probado EN ROJO (×3, restauración con reintentos + sha256 verificado)

| Inyección | Resultado medido |
|-----------|------------------|
| aborto de RUNTIME en el bloque C (acceso a clave inexistente de un `Dictionary`) | **EXIT 1 en 1 corrida**; nombra `el bloque C NO se ejecutó`, dispara el piso (58 < 75) y **termina** (no cuelga) |
| quitar `_marcar_sucio()` de `toggle_chunks` | `[FALLO] F7 WM_CLOSE_REQUEST tambien guarda` → EXIT 1 |
| `CHECKS_MINIMOS = 99` | `solo 75 checks ejecutados (mínimo medido 99)` → EXIT 1 |

Control final tras las 3 sondas: **75/0/EXIT 0** y **sha256 de los 2 archivos idéntico al
original** (nada quedó inyectado).

### Regresión M110 (6 suites, 115 checks, todas EXIT 0)

`test_debug_m110` 18/0 · `test_debug_menu_headless` 22/0 · `test_m110_iter_atria` 27/0 ·
`test_m110_ui` 17/0 · `test_m110_ui2` 14/0 · `test_m110_ui3` 17/0. `--check-only` EXIT 0 en
los 2 archivos tocados. EOL: `debug_menu.gd` 1008 CRLF / 0 LF suelto / sin BOM; suite nueva
LF puro sin BOM.

**Límite declarado:** el bloque G verifica el cableado de `_ready`/`_notification` de forma
**estática** (texto del script), porque la suite no agrega el menú al árbol para no disparar
`_ready` sobre la escena completa. Un refactor que mueva esas llamadas a otra función
haría fallar G6/G7 — es intencional: si la persistencia deja de estar cableada, es código
muerto y el ítem no está cerrado.

## 10. Capa visual REAL — iter. 2026-11-01 (DeepSeek-V4.1-Flash, Log 2299)

### Qué se mide

Que el visualizador dibuje **artefactos del mundo** y no cajas decorativas, y que respete
el gate de visibilidad. La medición es el `ImmediateMesh` resultante: número de segmentos,
vértices y superficies, más el conteo de nodos enumerados por capa.

Invariantes verificados (bloque A): 1 línea = 1 segmento / 2 vértices / 1 superficie;
1 caja = 12 aristas / 24 vértices; 1 esfera (3 aros × 12) = 36 segmentos / 72 vértices;
un camino de 3 puntos = 2 segmentos; mesh vacío = 0 superficies; `NaN`/`INF` rechazados.

### Guardián probado EN ROJO (×3, restauración con sha256 verificado)

| sonda | inyección | resultado |
|---|---|---|
| S1 | aborto de RUNTIME dentro del bloque C | EXIT 1, nombra `["C"]`, piso dispara (62 < 66), D/E/F/G/H retoman sin colgarse |
| S2 | `CHECKS_MINIMOS` 66 → 99 | EXIT 1, "solo 66 checks ejecutados (mínimo medido 99)" |
| S3 | gate L268 eliminado de `_debe_dibujar()` | EXIT 1, 5 fallos nombrados: B1, B3, B4, B7, H9 |

sha256 de los 3 archivos restaurado byte-exacto en las 3 sondas
(`78e78983…` suite, `9b17f54e…` visualizer, `255a87e1…` depurador).

### Defectos propios corregidos en la misma vuelta

1. `free()` sobre `Depurador3D` (`RefCounted`) → SCRIPT ERROR que abortaba el bloque **antes**
   de `_fin(bloque)`, reportándolo como "no ejecutado".
2. `NavigationAgent3D` **extiende `Node`, no `Node3D`**: no tiene `global_position`.
3. Doble compuerta (`_activo` local **y** toggle del menú) que podía discrepar.
4. El cache de clases globales no resuelve `Depurador3D` bajo `--headless --script`
   (`Parse Error: Could not find type`) → se usa `preload()` por ruta.

### Regresión M110 (9 suites, 326 checks, todas EXIT 0)

`test_m110_ui` 17/0 · `test_m110_ui2` 14/0 · `test_m110_ui3` 17/0 · `test_debug_m110` 18/0 ·
`test_m110_iter_atria` 27/0 · `test_debug_menu_headless` 22/0 · `test_debug_menu_config_m110`
75/0 · `test_debug_menu_control_m110` 75/0 · `test_debug_menu_entorno_m110` 61/0.

**Suite nueva:** `scripts/debug/test_debug_visualizer_real_m110.gd` — **66 checks / 0 fallos
/ EXIT 0 ×3**, piso `CHECKS_MINIMOS = 66` **MEDIDO**, LF puro sin BOM.
