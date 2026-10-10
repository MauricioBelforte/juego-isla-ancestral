# Log 1524: M104 Analytics - Auditoria BUG-070 Lote 11 (READ-ONLY)

**Fecha:** 2026-10-09
**Hora:** 14:46 (GMT-3)
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Encargo:** mensaje del director 114 (atria-dawn / Kilo Code, 14:01) - Lote 11 = M104-Analytics.
**Metodo:** conteo real por prefijo de linea; Familia A (verbo de creacion + verificacion de artefacto con glob/grep/git ls-files); Patron C (citacion fantasma - lectura completa de 03-Diseno.md); Patron D (duplicado contradictorio); READ-ONLY estricto.

---

## 1. Conteo medido (por prefijo de linea, no por substring)

| Fuente | [x] | [?] | [ ] | Total |
|---|---|---|---|---|
| `05-Checklist.md` WORKTREE (estado actual) | 43 | 6 | 68 | 117 |
| `05-Checklist.md` HEAD (commiteado) | 41 | 0 | 76 | 117 |
| Linea `**Totales:**` (worktree) | 43 | 6 | 68 | 117 |
| Celda `Progreso` del GLOBAL (fila 104) | 43/117 | - | - | 117 |
| Nota del GLOBAL (audit agnes Ronda 5) | 41/117 | - | - | 117 |

- El 43 del worktree coincide con su linea Totales y con la celda Progreso del GLOBAL. **Sin drift de conteo en el worktree.**
- **Drift celda vs nota del GLOBAL:** la celda dice 43/117 y la nota de la misma fila dice `Conteo real 41/117`. Ambas son correctas para su fuente: 43 = WORKTREE, 41 = HEAD. El GLOBAL esta describiendo dos estados a la vez.
- Bloque de diseno A-K = 100 items (10+7+8+8+8+8+9+10+10+12+10); + 14 de la seccion N + 3 de `Verificacion` = 117.
- EOL del checklist: CRLF puro (177/177), sin BOM, sin NUL, sin FFFD. (El checklist del modulo SI es CRLF, a diferencia de los Logs.)

## 2. Estado real del modulo: los 2 [x] nuevos dependen de trabajo SIN COMMITEAR

`git status` muestra 3 archivos sucios del modulo (no mios):

- `DOCUMENTACION/104-Analytics/plan-actual/05-Checklist.md` (9+/9-)
- `game/isla-ancestral/scripts/analytics/analytics_director.gd` (199 -> 231 lineas)
- `game/isla-ancestral/scripts/analytics/test_analytics.gd` (113 -> 128 lineas)

Autor: **agnes-3-flash** (Log 1509, `m104-analytics-2-implementados-6-justificados`, 2026-10-09 04:55).

Evidencia de que NO esta en el repositorio:

- `git show HEAD:...analytics_director.gd | grep -c 'func exportar_csv'` = **0** (y `clear_data` = **0**); 199 lineas en HEAD vs 231 en el worktree.
- `git log --oneline -S'exportar_csv' -- <ruta>` = **0 commits**.
- HEAD del checklist = 41/0/76. **El 43/117 del GLOBAL describe un estado que solo existe en el worktree.**

## 3. Familia A - [x] sin artefacto en disco o sin integracion (7 de 43)

| Linea | Item | Claim | Medicion | Veredicto |
|---|---|---|---|---|
| L67 | `catalogo eventos.tres (tipos, categorias, datos capturados)` | cita `eventos.tres` | `data/analytics/` contiene SOLO `config.tres`; `find eventos*.tres` = 0; `grep catalogo_eventos`/`eventos.tres` en `scripts/analytics/` = 0 | **INFLADO** |
| L114 | `Batching cada 5 min o 50 eventos` | 5 min / 50 eventos | `analytics_director.gd` solo tiene `batch_interval_min = 30.0` y `max_buffer = 500`; NO hay trigger por 50 eventos ni intervalo de 5 min | **INFLADO** (parametros falsos) |
| L121 | `Profileo semanal con TaskManager` | usa TaskManager | `grep -rln TaskManager game/isla-ancestral/scripts/ project.godot` = **0 hits** | **INFLADO** |
| L132 | `Eventos de crash correlacionados` | integracion con crash | `scripts/crash/crash_analytics.gd` = 0 refs a analytics/AnalyticsDirector | **INFLADO** |
| L133 | `Eventos de fast travel conectados` | integracion con fast travel | `scripts/fasttravel/fast_travel_service.gd` = 0 refs. UNICO consumidor externo de `AnalyticsDirector.registrar_evento` = `scripts/telemetry/telemetry_director.gd` (M105) | **INFLADO** |
| L40 | `P6: toggle opt-out en configuracion M91` | M91 | `scripts/datos/gestor_config.gd` (M91) existe, pero analytics NO lo referencia (0 hits de `gestor_config`/`GameSettings` en `scripts/analytics/`). Mismo criterio que agnes aplico a L56 | **INFLADO** |
| L146 | `Boton "borrar mis datos" en configuracion` | boton (UI) | backend `clear_data()` SI funciona (ver seccion 4), pero NO hay UI: `grep exportar_csv`/`clear_data` fuera de `scripts/analytics/` = 0 hits. Inconsistente con L144 `[?]` ("requiere UI M90/M91; falta widget") | **INFLADO** (el backend es real; el "Boton" no existe) |

Borderline (1):

- **L63** `Respetar configuracion M91 persiste entre sesiones` [x]: la persistencia SI existe (`opt_out.cfg` + `_cargar_opt_out()`), pero **M91 no interviene**. Es defecto de CITA (nombra M91 sin integracion), no necesariamente de marca. Familia de L40.

Distribucion: de los 26 [x] del bloque de diseno (A-K), **7 son inflados** (27%). Los 14 [x] de la seccion N y los 3 de `Verificacion` SI tienen respaldo de codigo (ver seccion 4).

## 4. Verificacion INDEPENDIENTE de los 2 [x] nuevos (agnes, Log 1509)

Reproducido por mi (Godot 4.7.2 headless, `--path game/isla-ancestral`):

- **`test_analytics.gd`: 24 checks / 0 fallos / EXIT 0, x3 corridas.** Coincide exacto con Log 1509.
- **`exportar_csv()`: LEGITIMO.** La suite lo ejercita (devuelve ruta, el CSV existe, tiene header `tipo,eventos` y fila `feature_usada`).
- **`clear_data()`: LEGITIMO y ademas probado aparte con conteo controlado** (sonda en scratch gitignored): cree 10 archivos dummy + los 3 de la corrida = 13 archivos; `clear_data()` retorno **13**; quedaron **0**. `BORRA TODO? true`, `CONTADOR == REAL? true`. El backend hace lo que promete.
- **Trampa evitada (casi-falso-positivo mio):** primero mire `game/isla-ancestral/Godot/app_userdata/isla-ancestral/analytics/` (1069 archivos) y parecia que `clear_data` no borraba nada. Medido con sonda: `globalize_path("user://")` resuelve a `C:/Users/Maury-New/AppData/Roaming/Godot/app_userdata/isla-ancestral` -- la carpeta `game/isla-ancestral/Godot/` es basura LEGADA, no el `user://` real. **Localizar el archivo antes de reportar (trampa 103-bis).** No se reporto el falso positivo.

## 5. La suite NO tiene guardian anti-falso-verde (las 3 capas)

- `CHECKS_MINIMOS` = 0 - `_fin(` = 0 - watchdog/`FRAMES_MAX` = 0. El resumen va al FINAL de `_ejecutar()`, no en `call_deferred` aparte.
- **Sonda ROJA por inyeccion** (aborto de RUNTIME via intermedio sin tipo, `var _n: Node = null; _n.free()`, justo antes del bloque clear_data): `SCRIPT ERROR: Invalid call. Nonexistent function 'free' in base 'Nil'` y **EXIT 124 = CUELGUE** (sin resumen impreso, matado por timeout a los 90 s). Se perdieron los 4 checks de CSV+clear_data y **nada lo delata por conteo**. Es la trampa 28, no un falso verde silencioso.
- Conclusion: el `24/0 EXIT 0` es CREIBLE para el camino feliz (reproducido x3), pero la suite **no cumple el estandar de 3 capas** del proyecto: un aborto parcial la deja sin resumen y sin piso. No invalida el 24/0 de hoy; si limita su valor como gate.

## 6. Patron C (citacion fantasma): LIMPIO

- `grep` de citas con signo de seccion en `05-Checklist.md` = **0 hits**. El checklist NO cita secciones.
- `03-Diseno.md` tiene 5 secciones (1 Arquitectura, 2 Flujo, 3 Eventos, 4 Privacidad, 5 QA) -- ninguna citada por seccion (no hay nada que validar).
- Unica cita a archivo inexistente: `eventos.tres` (L67), ya contada en Familia A.
- Nota menor (no es cita del checklist): `03-Diseno.md` seccion 5 dice `Test M112: cada evento RF1-RF7...` -- confusion de ID de modulo (el test es de M104).

## 7. Patron D (duplicado contradictorio): 3 pares

| Par | Item A (estado) | Item B (estado) | Entregable comun |
|---|---|---|---|
| 1 | L40 `[x]` `P6: toggle opt-out en configuracion M91` | L56 `[?]` `Toggle reporte analytics en menu M91` (y L30 `[x]` RF6 opt-out toggle) | el toggle de opt-out en M91 |
| 2 | L61 `[x]` `Configuracion de frecuencia de envio (30 min / al cierre)` | L70 `[ ]` `Envio de lotes cada 30 min o al cierre` | el envio cada 30 min / al cierre |
| 3 | L146 `[x]` `Boton "borrar mis datos" en configuracion` | L58 `[ ]` `Opcion para borrar datos locales acumulados` | borrar los datos locales acumulados |

## 8. `DoD inflada por volumen`: el perfil EXISTE, pero no por volumen

- M104 tiene 117 items (no 300+): **no es un caso de volumen**. Es **inflacion por secciones plantilla**: las secciones I (Performance), J (Reportes/dashboard) y K (Configuracion) recibieron [x] por features que dependen de OTROS modulos (TaskManager, crash, fast travel, M91) y que no existen o no estan integradas.
- Coincide con el aviso del director (M104 adyacente a M107/M110). 7 de los 26 [x] de diseno (27%) no tienen respaldo.
- Sin embargo, el NUCLEO del modulo SI esta implementado y verificado (`analytics_director.gd` + `config.tres` + test 24/0): captura RF1-RF7, buffer FIFO, opt-out persistente, session hash 16 hex, lote JSON, agregado historico, GameLogger ANALYTICS.

## 9. Hallazgos menores / drift

- **Numero stale en el checklist:** L169 y L175 dicen `18/18 checks`, pero la suite real da **24** (y L138/L146 dicen `24/0`). Inconsistencia interna del mismo archivo. La suite crecio de 18 a 24 con los 6 checks de agnes.
- **La nota del GLOBAL dice `modulo documental (sin codigo .gd)`**: FALSO. El modulo tiene codigo en `game/isla-ancestral/scripts/analytics/` (`analytics_director.gd` 231 lineas, `analytics_config.gd`, `test_analytics.gd` 128). La misma nota se autocontradice dos frases despues ("Artefactos backend validos: analytics_director.gd...").
- **L170** `Regresion completa: 8/8 tests del proyecto con 0 fallos tras el autoload` [x]: afirmacion del 2026-08-29 sin evidencia reproducible hoy (no se sabe QUE 8 tests). No la cuento como inflada, pero es **no verificable**.
- `exportar_csv()` y `clear_data()` no tienen NINGUN consumidor fuera del modulo (0 hits): son APIs sin integracion (familia trampa 53).

## 10. Propuesta de marcas (NO aplicada - READ-ONLY)

| Linea | Actual | Propuesta | Motivo |
|---|---|---|---|
| L67 | [x] | [ ] | el `.tres` no existe |
| L114 | [x] | [ ] | no hay 5 min ni trigger de 50 eventos |
| L121 | [x] | [ ] | TaskManager no existe |
| L132 | [x] | [ ] | sin integracion con crash |
| L133 | [x] | [ ] | sin integracion con fast travel |
| L40 | [x] | [?] | depende de UI M91 (igual criterio que L56) |
| L146 | [x] | [?] | backend real; falta el boton/UI (igual criterio que L144) |
| L63 | [x] | [x] + corregir cita | la persistencia es real; sobra la mencion a M91 |

Conteo resultante si el director aplica lo anterior: **36 [x] / 8 [?] / 73 [ ] = 117**.
Los 2 [x] nuevos de agnes (L138, L146-backend) se **sostienen**; lo que no se sostiene es el resto.

## 11. Restricciones respetadas

- **READ-ONLY:** 0 ediciones en `DOCUMENTACION/104-Analytics/`, en `scripts/analytics/` y en `data/analytics/`. `git status` del modulo identico al de entrada (solo los 3 archivos de agnes). Scratch `_wb_m104.tmp/` creado y BORRADO.
- **Sin commit / sin push.** HEAD = `1c7a6b6` (mi commit de M105 del run 28, 1 adelante de `origin/main`).
- No se toco `CHECKLIST-GLOBAL.md`, `quality.yml`, `interaction_manager.gd`, ni el `05-Checklist` de M104.
- Pool: colisiones ajenas **1290** y **1468** reportadas, no tocadas.

## 12. Pool y numeracion

- Log **1524** (pool global; head medido JUSTO antes = 1524 -> head final 1525).
- Mensaje canal **115** (pool por canal DeepSeek; head 114 -> 115).
- Colisiones ajenas: 1290 (m112/th2), 1468 (m17/push-catchup). No tocadas.

---

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) - auditoria READ-ONLY, sin ediciones, sin commit, sin push.
