# Step-5-WorkBuddy — Sección B: estado histórico + encargo + tandas
**Fuente:** BACKLOG-MASTER.md Step-5-WorkBuddy (sección dividida 5nov por fundador)
**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Rol:** EJECUTOR PRINCIPAL del director
**Estado:** Histórico

# (B) ESTADO HISTÓRICO Y ENCAJE — registro del BACKLOG-MASTER anterior (preservado íntegro)

# BACKLOG-MASTER.md — step 5 workbuddy

Canal: `Mensajes entre modelos/Step-5-WorkBuddy/`. Numeracion propia (pool de esa
carpeta). Identidad de firma: **step 5 workbuddy**.

## Reservas de log (protocolo v3, AGENTS.md 6.1)

- [x] Log reservado: **1796** — M04-Game-Engine iteracion 1: 10 flips seccion B
      (Costos y licencias) con cita real. Archivo:
      `Logs/1796-M04-iter1-costos-licencias_2026-10-12_23-50-00.md`.
- [x] Log **1797** consumido por error (doble ejecucion de `reservar_log.py
      --reservar`); sin archivo asociado. Deuda declarada en Log 1796 y en el
      informe al director (msg 04). No reasignar.
- [x] Log reservado: **1801** — M04-Game-Engine iteracion 2: 12 flips seccion A
      (Evaluacion de candidatos) con cita real. Archivo:
      `Logs/1801-M04-iter2-evaluacion-candidatos_2026-10-13_02-18-42.md`.
      Pool medido antes: head 1801 -> 1802. ASCII puro verificado por bytes.
- [x] Log reservado: **1806** — M04-Game-Engine iteracion 3: 14 flips seccion C
      (Soporte voxel y rendimiento) con cita real. Archivo:
      `Logs/1806-M04-iter3-soporte-voxel_2026-10-13_03-45-00.md`.
      Pool medido antes: head 1806 (1802-1805 los consumieron otros agentes) ->
      1807. ASCII puro verificado por bytes (0 no-ASCII).
- [x] Log reservado: **1810** — M04-Game-Engine iteracion 4: 10 flips seccion D
      (Ecosistema del motor) con cita real. Archivo:
      `Logs/1810-M04-iter4-ecosistema-motor_2026-10-13_04-40-00.md`.
      Pool medido antes: head 1810 (1807-1809 los consumieron otros agentes) ->
      1811. ASCII puro verificado por bytes (0 no-ASCII; 1er intento con §/★
      corregido antes de cerrar).

- [x] Log reservado: **1822** — M04-Game-Engine iteracion 6: 12 flips seccion F
      (Configuracion del proyecto base) con cita real. Archivo:
      `Logs/1822-M04-iter6-config-proyecto-base_2026-10-13_17-34-18.md`.
      Pool medido antes: head 1822 (1813-1821 los consumieron otros agentes) ->
      1823. ASCII puro verificado por bytes (0 no-ASCII).
      Ademas: 02-Analisis.md L36 -> Jolt Physics (unica edicion autorizada por la
      directora) y 04-Codigo.md sec.2 registra la version exacta 4.7.2 (E3 resuelto).
      Conteo: 70 -> 82 [x] / 46 [ ] / 0 [?] = 128 (medido por prefijo de linea).
- [x] Log reservado: **2015** — M93-Balance, REPOBLACION V3 items 16-19: 4 flips
      de definicion (O.1 / O.2 / O.5 / balance_report.gd) con diseno verificado HOY.
      Archivo: `Logs/2015-m93-flips-definicion-o1-o2-o5-balance-report_2026-10-19_01-52-59.md`.
      Pool medido antes: head 2015 -> 2016. ASCII puro verificado por bytes (3.949 B, CRLF 68, sin BOM).
- [x] Log reservado: **2018** — M36-Fauna / M65, REPOBLACION V3 item 20
      (anti-stuck de manada/banco): flip L212 con cita real + diseno en M65.
      Archivo: `Logs/2018-item20-anti-stuck-manada-banco_2026-10-19_03-20-47.md`.
      Pool medido antes: head 2018 -> 2019. ASCII puro verificado por bytes (4.215 B, CRLF 77, sin BOM).
- [x] Log reservado: **2037** — M90-Configuracion-Grafica, REPOBLACION V3 items 97-174:
      44 flips [ ]->[x] con diseno (03-Diseno.md sec.15 nueva + 06-Plan-Testings.md nuevo).
      Archivo: `Logs/2037-m90-tanda-documental-44-flips-diseno-sec15_2026-10-20_02-25-00.md`.
      Pool medido antes: head 2037 -> 2038. ASCII puro verificado por bytes (3.434 B, CRLF 49, sin BOM).
- [x] Log reservado: **2040** — M90 / item 58 (barrido de [?] con dependencia
      resuelta, flip-back): 4 flips M90 L90-93 + 3 flips M11 L45/L71/L98 (autorizados
      por el director msg 116) + acuses 112/114/116/118 y corrección de la fila 90
      (201 vs 245/249). Archivo:
      `Logs/2040-Item58-Barrido-Flipback-M90-4-Flips_2026-10-20_03-28-18.md`.
      Pool medido antes: head 2040 (max log en disco 2039, creado 03:18 por otro
      agente) -> 2041. ASCII puro verificado por bytes (6.477 B, CRLF 91, 0 LF
      sueltos, sin BOM; 1er intento con 6 bytes no-ASCII + LF corregido antes de cerrar).
- [x] Log reservado: **2023** — M119-Actualizaciones, REPOBLACION V3 items 31-39:
      diseno de UpdateDownloader (T-022) y RollbackManager (T-049..T-056) + veredicto
      honesto de los 7 [ ] de implementacion. Archivo:
      `Logs/2023-m119-diseno-updatedownloader-rollbackmanager_2026-10-19_22-05-40.md`.
      Pool medido antes: head 2023 -> 2024. ASCII puro verificado por bytes
      (5.213 B, CRLF 89, sin BOM).


## Commits (delegados a atria-dawn; yo no commiteo ni pusheo)

- [x] M04 iter 1: pedido msg 65 a atria-dawn -> commit **e38ad5a**
      (9 archivos, +376/-12) + push a origin/main, 2026-10-13 00:04.
      Verificado por mi: `git show --stat e38ad5a` y
      `git branch -r --contains e38ad5a`. Pool de canal excluido del commit
      (correcto). Acuse enviado (msg 69 en carpeta atria-dawn).
- [x] M04 iter 2: pedido msg 72 a atria-dawn -> commit verificado en HEAD
      (05-Checklist con 36 [x] + Log 1801 en el arbol) y en origin/main
      (origin == HEAD == 764cc70). Fila GLOBAL aplicada por el director
      (24 -> 36/128, confirmado en su msg 9 y en HEAD:CHECKLIST-GLOBAL).
- [x] M04 iter 3: pedido msg 76 a atria-dawn -> commit **e237d07** (push
      764cc70..e237d07, Log 1809/9d9bc5f) verificado por mi en HEAD y en
      origin/main. Acuse enviado (msg 78).
- [x] M04 iter 4: pedido msg 79 a atria-dawn (2026-10-13 04:50) -> commit
      **0526aa5** (iter 4+5 juntas) verificado en origin/main (`git show --stat` +
      `git branch -r --contains`), 2026-10-13 16:49. Archivos: 02-Analisis.md, 05-Checklist.md, Log 1810,
      BACKLOG-MASTER, tracker, msgs 12/78/79. Pool de canal excluido (stale).

## Lote WB (encargo del director, msg 01; orden aprobado msg 03)

Orden de trabajo: M04 -> M109 -> M67 -> M75 -> M56 -> M73 -> M20 -> M158;
M90 y M17 diferidos al final (solo si el director los libera; gemelo
step-5-kilocode activo hoy).

| Modulo | Carpeta | Estado iteracion |
|---|---|---|
| M04-Game-Engine | DOCUMENTACION/04-Game-Engine/ | iter 1: 14->24 [x] (Log 1796, commit e38ad5a + push); iter 2: 24->36 [x] seccion A (Log 1801, origin/main); iter 3: 36->50 [x] seccion C (Log 1806, commit e237d07 + push); iter 4: 50->60 [x] seccion D (Log 1810, ped. commit msg 79, SIN COMMITEAR verificado 05:05); iter 5: 60->70 [x] seccion E (Log 1812, ped. commit msg 81); iter 6: 70->82 [x] seccion F (Log 1822, commit 31e6d94 + push origin/main, verificado); iter 7: 82->94 [x] seccion G (Log 1831, commit 7db22f8 + push origin/main, verificado); iter 8: 94->105 [x] seccion H + F16 presets Linux/SteamOS (Log 1833, ped. commit msg 96 a atria) |
| M109-Herramientas-Internas | DOCUMENTACION/109-Herramientas-Internas/ | pendiente |
| M67-Vehiculos | DOCUMENTACION/67-Vehiculos/ | pendiente |
| M75-Postgame | DOCUMENTACION/75-Postgame/ | pendiente |
| M56-Fotografia | DOCUMENTACION/56-Fotografia/ | pendiente |
| M73-Coleccionables | DOCUMENTACION/73-Coleccionables/ | pendiente |
| M20-Sistema-De-Amistad | DOCUMENTACION/20-Sistema-De-Amistad/ | pendiente |
| M158-Herramientas-Y-Desbloqueo-De-Zonas | DOCUMENTACION/158-Herramientas-Y-Desbloqueo-De-Zonas/ | pendiente |
| M90-Configuracion-Grafica | DIFERIDO (gemelo activo) | no tocar |
| M17-Construccion | DIFERIDO (gemelo activo) | no tocar |

Prohibidos absolutos (del otro frente): M40, M70, M140, M63, M112, M94, M92, M91,
M104, M88, M160.

## Pendientes de esta iteracion

- [x] Iteracion 2 de M04: seccion A (Evaluacion de candidatos, 12 items) con cita — HECHA (Log 1801; 24->36 [x] / 92 [ ] / 0 [?] = 128). ACEPTADA por el director (msg 9); fila GLOBAL aplicada por el.
- [x] Iteracion 3 de M04: seccion C (Soporte voxel y rendimiento, 14 items) — HECHA (Log 1806; 36->50 [x] / 78 [ ] / 0 [?] = 128; informe msg 10). ACEPTADA por el director (msg 11); GLOBAL aplicada por el; commit e237d07 + push verificado.
- [x] Iteracion 4 de M04: seccion D (Ecosistema del motor, 10 items) — HECHA (Log 1810; 50->60 [x] / 68 [ ] / 0 [?] = 128; informe msg 12). Pend: que el director aplique la fila GLOBAL 50 -> 60/128.
- [x] Acuse del commit de iter 3: verificado e237d07 en HEAD + origin/main (msg 78 a atria).
- [x] VERIFICADO 2026-10-22: iter 4+5 commiteados en 0526aa5 (verificado 2026-10-13 en origin/main; ver linea sucesora de este registro). Acuse del commit de iter 4 cuando atria-dawn confirme (verificar sha + origin/main antes de acusar).
- [x] Iteracion 5 de M04: seccion E (Version y gestion del motor, 10 items) — HECHA (Log 1812; 60->70 [x] / 58 [ ] / 0 [?] = 128; informe msg 14). Pend: que el director aplique la fila GLOBAL 60 -> 70/128.
- [x] Reportado al director (msg 12): la fila GLOBAL de M04 quedo en "Completado" con 68 [ ] pendientes (DoD 21.6). RESUELTO: el director bajo la fila a "Con dudas" 60/128 (msg 13). Fila GLOBAL 60/128 verificada en disco.

- [x] Acuse del commit de iter 4+5: VERIFICADO 2026-10-13 (corrida 17:36) - commit 0526aa5 (iter 4+5) verificado en origin/main; pedido renovado msg 81 atendido.
- [x] Iteracion 6 de M04: seccion F (Configuracion del proyecto base, 12 flips de 18) - HECHA (Log 1822; 70->82 [x] / 46 [ ] / 0 [?] = 128; informe msg 16). ACEPTADA por el director (msg 18); GLOBAL aplicada por el; commit 31e6d94 + push verificado (msg 94 a atria).
- [x] Iteracion 7 de M04: seccion G (Rendimiento y calidad grafica, 12 items) - HECHA (Log 1831; 82->94 [x] / 34 [ ] / 0 [?] = 128; informe msg 19). Pend: que el director aplique la fila GLOBAL 82 -> 94/128.
- [x] Acuse del commit de iter 7: VERIFICADO 2026-10-13 23:45 - commit 7db22f8 en origin/main (git show --stat + git branch -r --contains).
- [x] Iteracion 8 de M04: F16 (export presets Linux/SteamOS creados + export real EXIT 0, ELF x86_64 91,6 MB) + seccion H (10 flips de 11; H9 pipeline de audio sin evidencia -> [ ]) - HECHA (Log 1833; 94->105 [x] / 23 [ ] / 0 [?] = 128; informe msg 20). Pend: fila GLOBAL 94 -> 105/128.
- [x] VERIFICADO 2026-10-22: commit 7337d50 en origin/main (git show --stat 7 archivos, verificado 2026-10-14; ver linea sucesora). Acuse del commit de iter 8: pedido a atria en msg 96 (iter 7 + iter 8 en un lote); — git log --all -- Logs/1810-* = VACIO; origin/main = edc12ca NO lo contiene; HEAD local = a7a3b39 (2 commits ajenos de pool). Iter 4 + log 1810 + msg 12 + msg 79 siguen sin commitear; pedido renovado a atria en msg 81 (junto con iter 5).
- [x] Iteracion 9 de M04: H9 (asset pipeline de audio M41-M44, re-medido con vocabulario amplio: 19 matches en 04-Codigo/03-Diseno de 41/42/43/44 vs 0 en el barrido de iter 8) + seccion I (10 flips de riesgos y edge cases con cita real) - HECHA (Log 1836; 105->116 [x] / 12 [ ] / 0 [?] = 128; informe msg 24; seccion 11 nueva en 02-Analisis). Pend: fila GLOBAL 105 -> 116/128 (aplica el director).
- [x] Log reservado: **1836** - M04 iter 9 (H9 audio + seccion I).
- [x] Acuse del commit de iter 8: VERIFICADO 2026-10-14 - commit 7337d50 en origin/main (git show --stat 7 archivos + git branch -r --contains). Nota de honestidad de atria sobre el binario ELF atendida: se exporto a temporal fuera del arbol y se borro; el flip F16 se apoya en los presets, no en el binario.
- [x] VERIFICADO 2026-10-22: paths sustantivos en HEAD (Log 1836 + M04 05-Checklist/02-Analisis; msg 24 en HEAD). Acuse del commit de iter 9: pedido a atria en msg 102 (6 paths; pool de mi canal excluido por stale).
- [x] Reportado al director (msg 24): suites de audio M41/M42 con SCRIPT ERROR bajo un "0 fallos" (test_musica_m41 5 errores, test_ambient_m42 2 errores - metodos inexistentes en los directores) = falso verde potencial; M43 (127 checks) y M44 (9 checks) limpios. Deuda de M41/M42, no tocada. Ademas: 0 archivos de audio entregados por el compositor (43/04-Codigo L69).
- [x] Correccion de registro: la linea vieja "iter 4 SIN COMMITEAR (msg 12/79)" quedo superada - iter 4+5 commiteados en 0526aa5 (verificado 2026-10-13).
- [x] Iteracion 10 de M04: seccion J (validacion del hito M1 y cierre, 10 flips de 12) - HECHA (Log 1839 = primera pasada, 9 flips; Log 1844 = segunda pasada + reparacion del hueco; 116->126 [x] / 0 [?] / 2 [ ] = 128; informe msg 27 al director). J2/J3 quedan [ ] honestos por indicacion del director (msg 25: exigen medicion en dispositivo/runtime). J11 flipeado con cita del msg 25 + nota honesta medida (el worktree del GLOBAL muestra 105/128 y la fila arranca con 3 celdas vacias -> verificar_checklist.py NO cruza el Progreso de M04).
- [x] Hueco de numeracion REPARADO: la corrida de las 05:5x-06:00 consumio el 1844 del pool y escribio las citas 'ver Log 1844 Jx', pero su archivo no llego a disco (corrida cortada antes de informar al director). Log 1844 re-escrito en la corrida 17:20 con la re-verificacion completa de la seccion J (las 10 citas re-mediadas con sed/grep/ls). No se inventaron numeros: el 1844 ya estaba consumido (cabeza del pool = 1845).
- [x] Procesados los msgs 25 (iter 9 aceptada 116/128 + iter 10 = seccion J autorizada) y 26 (check de estado: la corrida anterior se corto antes de enviar el informe) del director. Informe 27 enviado. Tracker .ultima-revision-step-5.txt 23 -> 26.
- [x] VERIFICADO 2026-10-22: 5/6 paths en HEAD (M04 05-Checklist, 02-Analisis, Logs/1839+1844, tracker, BACKLOG); msg 27 no verificable por nombre (numero reciclado en el canal). Acuse del commit de iter 10: pedido a atria-dawn por su canal (msg 108; paths: 05-Checklist.md, 02-Analisis.md, Logs/1839 + Logs/1844, msg 27, tracker, BACKLOG-MASTER; pools de numeracion excluidos).

- [x] Procesados los msgs 28 (iter 10 M04 ACEPTADA 126/128 + M109 autorizado) y 29 (nueva metodologia de flota: atria salio; los commits se piden a mimo por MI canal; cola M109 -> M67 -> M75 -> M56 -> M73 -> M20 -> M158). Tracker 26 -> 29.
- [x] Log reservado: **1845** - M109 lote 1.
- [x] M109-Herramientas-Internas lote 1: 25 flips `[ ]` -> `[x]` (iter 3: 12 = sec.18 debug 6 + sec.21 validacion 6; iter 4: 13 = framework 4 + debug 3 + generacion 5 + cierre 1) - 27 -> **52 [x] / 83 [ ] / 3 [?] = 138** (Log 1845). Evidencia: 03-Diseno L40-42/L48-83, 02-Analisis L14/L18, 01-Requerimientos L54. Nota honesta: 'desbloquear herramienta' no es textual (marcado por respaldo DoD). Drift corregido: header (110 items) -> 138; 'Total de items: 127' -> 138. Fila GLOBAL 27/138 -> 52/138 para que aplique el director (msg 30).
- [x] Log 1845 commiteado por el director (109e987, 18:52) junto a logs pendientes de la flota - verificado byte-exact con git cat-file -e; msg 30 ajustado.
- [x] VERIFICADO 2026-10-22: lote 1 commiteado en ef27daa el 2026-10-14 (ver linea sucesora). Acuse del commit: pedido al director mimo por MI canal msg 30 (quedan: M109 05-Checklist, M04 05-Checklist+02-Analisis de iter 10 - sin commitear desde la salida de atria -, BACKLOG-MASTER, tracker, msgs 27/30). Pools de numeracion excluidos.
- [x] Acuse del commit del lote 1: VERIFICADO 2026-10-14 - commit ef27daa aplicado por el director (msg 31) con los 9 archivos pedidos en msg 30 (M109 checklist, M04 checklist+analisis, BACKLOG, tracker, msgs 27-30).
- [x] Procesado el msg 31 del director (mimo): M109 lote 1 ACEPTADO (52/138); iter 2 AUTORIZADA (secciones 2-13, 14 editores de dominio). Tracker 29 -> 31.
- [x] Log reservado: **1847** - M109 iteracion 5 (secciones 2-14).
- [x] M109 iteracion 5: 55 flips de las secciones 2-14 (los 14 editores de dominio de RF1) -> **107 [x] / 28 [ ] / 3 [?] = 138** (Log 1847). Evidencia medida: 03-Diseno §3 L50-62 (tabla de los 14 editores) + 01-Requerimientos §3 L13-25 + RF4 L41 (previsualizacion) + RF6 L43 (exports). 12 salvedades honestas documentadas (acotadores no textuales: preview 3D, casa NPC, horario semanal, etc.). 6 items quedan [ ] honestos sin respaldo (L62/L70/L71/L78/L86/L100). Drift corregido: Totales heredado 127/0 -> 107/28. Fila GLOBAL 52/138 -> 107/138 para que aplique el director (msg 32).
- [x] VERIFICADO 2026-10-22: M109 05-Checklist + BACKLOG-MASTER + tracker + Log 1847 en HEAD. Acuse del commit de iter 5: pedido al director mimo por MI canal msg 32 (queda: M109 05-Checklist + BACKLOG-MASTER + tracker + msg 32; Log 1847 a commitear por el director junto a los logs de la flota).

- [x] Procesado el msg 33 del director (mimo): iter 2 de M109 ACEPTADA (107/138; GLOBAL aplicado - verificado fila L43); lote 3 AUTORIZADO (secc 15 mapas + 16-17 teleport/spawn + 19-20 inspeccion/profiling + L203 log del modulo); commit pedido de 3 paths. Tracker .ultima-revision-step-5.txt 31 -> 33.
- [x] Log reservado: **1854** - M109 lote 3.
- [x] M109 lote 3: 13 flips `[ ]` -> `[x]` con cita real -> **120 [x] / 15 [ ] / 3 [?] = 138** (Log 1854). Sec. 15 mapas (5) -> 03-Diseno sec.3 L63 + RF4 L41 + RF6 L43; sec. 16 teleport (2) -> 03-Diseno sec.4 L68 + 01-Req sec.3.15 L27; sec. 17 spawn (2) -> sec.4 L69 + 01-Req sec.3.16 L28; sec. 19 inspeccion (2) -> sec.4 L70 + RF8 L45; sec. 20 profiling (1) -> 01-Req sec.3.19 L31; L203 -> Log 1854. 5 items quedan [ ] honestos sin respaldo textual (L137/L144/L145/L165/L171). Verificador: 1 inconsistencia esperada de M109 (GLOBAL 107/138 vs 120/138, aplica el director) + 22 ajenas. Informe msg 34 al director. Commit propio con pathspec explicito (politica msg 241, autorizado en msg 33). 0 push.

- [x] Procesados los msgs 35 (step-5-kilocode, informativa: mis mensajes siguen en la raiz de la carpeta, sin subcarpetas de rango) y 36 (mimo): M109 lote 3 ACEPTADO (GLOBAL 120/138 verificado, fila 109, actividad 2026-10-15 01:30) + NUEVA TAREA: elegir modulo amarillo con [ ] y sin [?] cerca de completar y PROPONER flips con cita real (Patron D). Tracker .ultima-revision-step-5.txt 33 -> 36.
- [x] Log reservado: **1857** - M06 auditoria (head medido 1857 justo antes de reservar; 1856 lo tomo otro agente).
- [x] M06-Control-De-Versiones auditoria (msg 36 del director): barrido del GLOBAL = 108 amarillos con [ ], 28 con [ ] y CERO [?]. Elegido M06 (99/100, 1 pendiente, 0 [?], sin dueno activo - verificado agnes en M08/M133). Estado medido por prefijo de linea: 99 [x] / 0 [?] / 1 [ ] = 100. Evidencia de cierre previo verificada en disco (docs/version-control-policy.md 4322 B; scripts/proyecto/test_version_control_m06.gd). El unico [ ] (L25 "Evaluar proteccion de rama main") = EVALUACION EJECUTADA hoy por API: `gh api .../branches/main/protection` -> 404 "Branch not protected" (main SIN proteccion); 131 commits/24 h + GHA corre en cada push (12 runs) + politica de commits directos (05 L19/L22, 02-Analisis L21) -> Proteccion PR-only romperia el flujo; con el CI en rojo (medido) "require checks" bloquearia todo; opcion liviana = bloquear force-push/borrado. Propuesta de 1 flip (99 -> 100/100) con caveat ("requiere UI de GitHub" segun nota de cierre) - NO aplicado, decision del director (informe msg 37, Log 1857). HALLAZGO reportado: CI en rojo en cada push (Testing Suite failure 3/3, quality.yml "workflow file issue" 0s 3/3, dev-build cancelled 3/3) -> relevante para M118. 0 commits / 0 push / 0 marcas aplicadas.

- [x] Procesado el msg 38 del director (mimo, 2026-10-15 04:50): flip M06 L25 ACEPTADO (M06 OK 100/100 en GLOBAL, verificado fila 06 + commit 64f4502); hallazgo CI rojo registrado (no tocar quality.yml); COMMIT AUTORIZADO de mis paths (sin push); siguiente modulo a eleccion entre M118/M36/M93. Tracker .ultima-revision-step-5.txt 36 -> 38.
- [x] Log reservado: **1859** - M93 auditoria + verificacion M06 + commit autorizado (head medido 1859 justo antes; 1858 lo tomo M01 iter 7).
- [x] DRIFT M06 verificado y REPORTADO (no tocado): el commit 64f4502 del director aplico el flip SOLO en el GLOBAL; el checklist del modulo (06-Control-De-Versiones/plan-actual/05-Checklist.md) sigue con L25 [ ] y Totales 99/100 -> pedido de aplicacion al director (informe 39).
- [x] M93-Balance auditoria (Patron D, elegido entre M118/M36/M93): 131 [x] / 0 [?] / 3 [ ] = 134 (coincide GLOBAL). Evidencia: autoload Balance project.godot L60; 18 tablas data/balance/*.json; validate_balance.gd headless x2 = 0 fallos EXIT 0, 0 SCRIPT ERROR; reglas meta.json verificadas 1 a 1 (0.05 rareza, 600 AO tope diario, 115% techo bucle, 20 items/categoria). Los 3 [ ] HONESTOS (simulate_economy.gd no existe en disco; solo diseno 03-Diseno sec.2.3) -> propuesta: se quedan (precedente M50/M65). 0 flips disponibles. Drift menor reportado: header "(130 items)" vs 134 marcadores reales. Hallazgo reportado: validador NO cableado en CI (grep -rl balance .github/ = 0).
- [x] Commit propio ejecutado (autorizado msg 38, sin push): Log 1857 (untracked hasta ahora), Log 1859, tracker 36 -> 38, BACKLOG-MASTER, informe msg 39. msg 37 ya estaba commiteado por el director en 64f4502. Pools excluidos. Informe 39 al director.

- [x] Procesado el msg 40 del director (mimo, 2026-10-15 07:35): M06 drift CERRADO (verificado: checklist del modulo L25 [x] + Totales 100/100, en HEAD; fila 06 GLOBAL OK Completado); M93 confirmado (3 [ ] se quedan; fila 93 GLOBAL = 131/134 con nota de mi auditoria); **M36-Fauna AUTORIZADO** con auditoria Patron D completa. Tracker .ultima-revision-step-5.txt 38 -> 40.
- [x] Log reservado: **1863** - M36-Fauna auditoria Patron D (head medido 1863 justo antes de reservar).
- [x] M36-Fauna auditoria (Patron D): 226 [x] / 0 [?] / 2 [ ] = 228 (coincide Totales L271 y fila 36 GLOBAL). Suites headless binario real: test_fauna.gd = **58 checks nombrados, 0 fallos, EXIT 0, 0 SCRIPT ERROR** (suite VIVA; reconcilia Log 1144 '62' vs Log 1145 '58 OK x2' = metodo de conteo) y fauna_auditor.gd = **7 especies, 0 fallos, EXIT 0**. L225 'plan-inicial/ como reversa historica': **PROPUESTO FLIP [ ]->[x] (227/228)** - plan-inicial/ EXISTE con 5 docs, versionado desde 41ff104 (2026-08-24), su 05-Checklist = 142 [ ] historico real. L212 'anti-stuck manada/banco coordinado' (dueno M65): **SIGUE [ ]** - M65 tiene anti-stuck POR AGENTE (m65_animal_ai.gd L159-168) pero NO coordinado de grupo; la nota del item ('logica en behavior.gd') es inexacta. 0 flips aplicados (marcas del director). Informe msg 41 + pedido de commit (Log 1863, msg 41, tracker, BACKLOG-MASTER; msg 40 no autorizo commit nuevo).

- [x] Procesado el msg 42 del director (mimo, 2026-10-15 13:20): M36 L225 flip APLICADO por el (verificado en disco: L225 [x] con nota FLIP + Totales 227/228, en HEAD commit 0232ac6); L212 confirmado [ ]; **COMMIT AUTORIZADO de mis paths de M36**; siguiente modulo = **M50-Vegetacion** (127/142, 15 abiertos) con auditoria Patron D.
- [x] Commit propio ejecutado (autorizado msg 42, sin push): **5193499** = Logs/1863-M36-Fauna-Auditoria-Patron-D, tracker 38 -> 40, BACKLOG-MASTER. Informe msg 41 YA estaba en HEAD (commiteado por el director) -> excluido. git status por path + diffs revisados 1 por 1 (100% propios) antes del add. Pools excluidos, sin push.
- [x] Log reservado: **1864** - M50-Vegetacion auditoria Patron D (head medido 1864 justo antes de reservar).
- [x] M50-Vegetacion auditoria (Patron D): 127 [x] / 3 [?] / 12 [ ] = 142 (coincide fila 50 GLOBAL). 4 suites headless hoy: test_vegetation_headless 7 checks, test_vegetation_plan_headless 5, test_vegetation_spawner_headless 4 (todas VIVAS, 0 fallos, EXIT 0, 0 SCRIPT ERROR) + test_distribucion (debug). Distribucion real = 109 instancias (playa 12 / montana 10 / pradera 25 / bosque 22 / ribera 15 / cercanias_spawn 25), coincide 1:1 con vegetacion_config.json v2. Log 644: 45 instancias, 0 omitidas, BUG-022 clamp de agua.
- [x] M50 flips PROPUESTOS (no aplicados, marcas del director): **L115** densidad real vs tabla -> [x] (128/142) y **L119** naming -> [x] (45 GLB existen con nombre canonico 50-Vegetacion_*.glb; 129/142). Los otros 10 [ ] honestos: L118 presupuesto (render M61), L174 5 de 7 biomas (falta humedal), L175 frame pivote, L176 viento (grep 0, dueno M48), L178 estaciones (grep 0, dueno M29), L179 clamps (solo agua, falta pendiente/altura), L180 MultiMesh (implementacion usa Node3D directo), L181 regeneracion (grep 0), L256 escalas.json NO a 1.0 (del usuario), L257 revision visual (del usuario). Los 3 [?] con dueno externo continuan (L117 LOD sin validate_vegetation.gd/especies.tres; L197 manager sin estaciones/pooling; L203 cubierto hoy por el spawner). Deriva diseno-implementacion documentada (Log 1864 sec. 6).
- [x] Informe msg 43 al director (cierre M36 + commit 5193499 + auditoria M50 + 2 flips propuestos + pedido autorizacion commit paths M50 + pedido decision siguiente modulo). Tracker -> 43.

- [x] Procesado el msg 44 del director (mimo, 2026-10-15 04:17): M50 flips L115/L119 APLICADOS por el (verificado en disco: [x] con notas FLIP, Totales 129/142, fila GLOBAL 50 = 129/142); **COMMIT AUTORIZADO** de Log 1864 + informe 43 + tracker + BACKLOG-MASTER (sin push, pools excluidos); siguiente modulo = **M119-Actualizaciones** (109/118, 9 abiertos) con auditoria Patron D. Tracker .ultima-revision-step-5.txt 43 -> 44.
- [x] Commit propio ejecutado (autorizado msg 44, sin push): **a3eb072** = Logs/1864-M50-Vegetacion-Auditoria-Patron-D, informe msg 43 (untracked, NO estaba en HEAD), tracker 43 -> 43, BACKLOG-MASTER. Indice compartido limpio antes del add (git diff --cached vacio); add+commit encadenados en 1 invocacion, pathspec explicito, 4 paths exactos (git show --stat = 4 files, 187+/1-). Warnings autocrlf = ruido normal (trampa 48).
- [x] Log reservado: **1866** - M119-Actualizaciones auditoria Patron D (head medido 1866 justo antes; 1865 lo tomo otro agente).
- [x] M119-Actualizaciones auditoria (Patron D): 109 [x] / 0 [?] / 9 [ ] = 118 (coincide fila GLOBAL L55). Arquitectura real medida: scripts/updates/ = SOLO update_manager.gd (92 lineas, 3187 B, 10 funciones - _ready, _cargar_versions, _registrar_servicio, comparar_versiones, _parsear, hay_actualizacion, version_remota, set_canal, politica, _guardar_version; CERO download/rollback/migrate) + test_updates_m119.gd; versions.json = 3 canales (estable 1.0.0/beta 1.1.0-beta.1/dev 1.1.0-dev.3) + politica (min_versiones_atras 2, aviso_previa, requiere_reinicio); persistencia user://version.tres. Las 5 clases disenadas (GameVersion, UpdateChecker, UpdateDownloader, SaveMigrator, RollbackManager) = 0 hits class_name y 0 archivos que las mencionen en game/**/*.gd. Suite headless binario real = **15 checks nombrados, 0 fallos, EXIT 0, 0 SCRIPT ERROR** (VIVA).
- [x] M119: **0 flips disponibles** - los 9 [ ] son deuda de implementacion REAL con dueno externo (L24/L25/L27 M59; L35/L48/L146 M96/M118; L61 M59; L87/L150 M107/M59) y la funcionalidad esta AUSENTE en disco (no plegada, no sustituida): download y rollback NO existen en ningun lado; 03-Diseno.md sin secciones UpdateDownloader ni RollbackManager. ANTES = 109/118 -> DESPUES = 109/118 (0 cambios). Propuesta: se quedan (precedente M93/M50). DRIFT menor reportado: la correccion 2026-10-15 de step-5-kilocode dice "79 lineas" de update_manager.gd; real medido = 92 lineas (resto de la correccion confirmado 1:1).
- [x] Informe msg 45 al director (cierre M50 + commit a3eb072 + auditoria M119 0 flips + drift 79->92 + pedido autorizacion commit 2a tanda: Log 1866, msg 45, tracker 44, BACKLOG-MASTER). Pools de canal y logs excluidos de todo commit. 0 push / 0 marcas aplicadas / 0 ediciones a CHECKLIST-GLOBAL.md / quality.yml. 8 colisiones de pool de logs ajenas conocidas sin tocar.
- [x] Procesado el msg 46 del director (mimo, 2026-10-15 18:15): M119 aceptada (0 flips, 109/118, los 9 [ ] deuda externa con dueno); commit a3eb072 verificado OK; **COMMIT 2a TANDA AUTORIZADO** (Log 1866, informe 45, tracker 43->44, BACKLOG-MASTER, sin push, pools excluidos); drift 79 vs 92 lineas de update_manager.gd lo corrige el director; siguiente = **M94-Retencion-Sin-FOMO** (87/138, 48 duplicados a mapear) con auditoria Patron D + muestreo 21.8 + flips propuestos no aplicados. Tracker 44 -> 46.
- [x] Commit propio **da9d9f5** (autorizado msg 46, sin push): 4 paths exactos = 4 files, 211+/1- (Log 1866, informe 45, tracker 44, BACKLOG-MASTER). Diffs 1 por 1; add+commit encadenados; verificado git show --stat + git cat-file -e HEAD.
- [x] Log reservado: **1869** - M94 auditoria Patron D (head medido 1869 justo antes).
- [x] M94-Retencion-Sin-FOMO auditoria (Patron D): **87 [x] / 51 [?] / 0 [ ] = 138** (coincide fila 94 GLOBAL y Totales L225; LF puro sin BOM). Modulo design-heavy (todos items "Definir").
- [x] M94 mapeo de los 48 duplicados: script propio (NFKD, corte de notas en ->/--/em dash) = **48/48 REALES en 37 familias** (11 de 3 ocurrencias: L25/L26/L41/L45/L48/L49/L53/L65/L66/L67/L68; 26 de 2). **0 falsos, 0 inflacion [x]-[x]**: el [x] NO quedo inflado por los duplicados (la degradacion del director del 2026-10-10 los cubrio todos). 2 notas inexactas reportadas (L139/L149 dicen "1a ocurrencia [x]" pero L55/L60 son [?]).
- [x] M94 citas fantasmas (trampa 95, medido): 03-Diseno.md real = 9 secciones, 0 subsecciones; 77 citas §X.Y en notas, **58 a secciones inexistentes** (§10/14/15/16/18/20); contenido si existe en secciones reales (§2/§4/§5/§6/§7/§8) = drift de cita, no de contenido.
- [x] M94 evidencia en disco: scripts/motivacion/ = 7 .gd + 2 test; objetivos.json = 7 objetivos esquema canonico post-BUG-061 (expiracion=false x7). Suites binario real: test_motivacion_m94.gd = **38 checks/0 fallos/EXIT 0/0 SCRIPT ERROR** (VIVA, 8 bloques); test_antifomo_headless.gd = 6 checks/0 fallos/EXIT 0. quality.yml = 0 menciones motivacion/antifomo (auditor NO cableado en CI).
- [x] M94 muestreo 21.8: **4 fallas de 8 -> SELLO DENEGADO (21.8.2.b)**. FAIL: L172 ("30 ciclos" = 1 ciclo en suite, 30 ausente en codigo y diseño), L191 (suite MigracionMotivacion inexistente, 0 hits; diseño sec.8 = 1 linea), L165 ("notificacion suave" 0 hits en todo plan-actual y codigo), L99 ("4 y 3 variantes en 2 festividades" sin data: 0 registrar() de produccion, 1 festividad de test). PASS: L185/L189/L82/L40. Sello previo Log 1146 (hy3/WB) stale (anterior a la correccion del director 2026-10-10).
- [x] M94 4 flips PROPUESTOS (no aplicados, los aplica el director): L172/L191/L165/L99 [x] -> [?] (DESPUES propuesto 83 [x] / 55 [?] / 0 [ ] = 138; fila GLOBAL 87/138 -> 83/138). Drift reportado: Totales L198-200 stale (113 vs 138), numeracion de secciones salta 2/3/4/7.
- [x] Informe msg 47 al director (acuse msg 46 + commit da9d9f5 + auditoria M94 completa + muestreo 4/8 fallas sello denegado + 4 flips propuestos + pedido autorizacion commit 2a tanda M94: Log 1869, msg 47, tracker 46, BACKLOG-MASTER). Pools excluidos. 0 push / 0 marcas aplicadas / 0 ediciones a CHECKLIST-GLOBAL.md / quality.yml.

- [x] Procesado el msg 49 del director (De-Director V4.1, 2026-10-15 23:00): M94 aceptada (sello DENEGADO confirmado, los 4 flips L172/L191/L165/L99 los aplica el director; NO toco el checklist de M94); **COMMIT 2a TANDA AUTORIZADO** (Log 1869 + informe 47 + tracker + BACKLOG-MASTER, sin push, pools excluidos); siguiente = **M31-Ciclo-Dia-Noche lote 1** (skybox/luces programadas, 49 pendientes de 120/169) con verificacion previa de que M31 no este en rojo/azul. Tracker 48 -> 50 (via msg 50).
- [x] Commit propio **122074b** (autorizado msg 49, sin push): 3 paths exactos = 3 files, 261+ (Log 1869, informe 47, BACKLOG-MASTER). El tracker ya estaba en HEAD (= 48). add+commit encadenados, pathspec explicito; verificado git log -1 --stat. Pools excluidos.
- [x] Log reservado: **1878** - M31 lote 1 cielo/estrellas/90 s (head medido 1878 justo antes; BOM del pool no bloqueo la reserva).
- [x] M31 lote 1 IMPLEMENTADO (msg 49 sec. 4, flujo implementar->verificar->documentar->reporte): day_night_cycle.gd (209 -> 404 lineas) = (1) cielo procedural por hora (ProceduralSkyMaterial: sky_energy_multiplier = sky_curve.tres §P5, sky_top_color/sky_horizon_color = sky_color_ramp.tres M49, ground_* por lerp; material duplicado en runtime); (2) domo de estrellas (MeshInstance3D SphereMesh r=900 flip_faces + ImageTexture procedural 600 estrellas semilla 31031; alpha_estrellas(hora): subida 0->100% 20:00-22:00 fase_umbral.json §estrellas §P6, noche sostenida, bajada espejo 5->7); (3) transiciones 90 s (_duracion_transicion consume time_config.tres duracion_gradiente_* en ALBA/ATARDECER; resto crossfade 1 s §transicion). Compatibilidad: _aplicar_iluminacion(hora, tween, duracion=-1.0) con 2 args = anterior.
- [x] Trampa MEDIDA: en Godot 4.7.2 la propiedad es `sky_energy_multiplier` (NO `sky_energy` de Godot 3) - 4 SCRIPT ERROR en la 1a corrida del test existente; corregido tras sonda del property_list real.
- [x] Test nuevo test_cielo_estrellas_m31.gd: **39 checks / 0 fallos / EXIT 0 x3, 0 SCRIPT ERROR** (binario real). Guardas: bloques A-D con _fin(), piso CHECKS_MINIMOS = 39 MEDIDO en verde, _summary por call_deferred. Guardian probado EN ROJO por inyeccion (aborto bloque C -> EXIT 1, nombra ["C","D"], 19 checks). Regresion test_curvas_luz.gd = 0 fallos.
- [x] M31 flips APLICADOS (4, con cita): L44 (B-P6 estrellas), L87 (D canvas estrellas), L218 (K 90 s), L219 (K Sky procedural) [?] -> [x]. ANTES = 120 [x] / 49 [?] -> DESPUES = **124 [x] / 45 [?] / 0 [ ] = 169** (prefijo de linea, invariante OK). Header + Totales actualizados. 04-Codigo.md seccion nueva (append LF, 147 CRLF preservados).
- [x] Informe msg 50 al director (fila GLOBAL a aplicar: 120/169 -> 124/169 + pedido autorizacion commit tanda M31 lote 1 + NO auto-sello 21.8). Drift reportado: diseño §P3 "0.18-1.0" vs curva 0.15; "24 puntos" vs ramp de 9; rutas diseño world/light/ vs real scripts/world/.
- [x] Procesado el msg 51 del director (De-Director V4.1, 2026-10-15 23:58): GLOBAL 31 aplicada por el (124/169,NO tocar); M94 reconfirmada (4 flips aplicados por el, sello DENEGADO, commit 122074b correcto); **COMMIT TANDA M31 LOTE 1 AUTORIZADO y EJECUTADO = 80b0576** (8 paths exactos, 577+/12-, SIN push, pools excluidos; indice compartido limpio antes, add+commit encadenados); siguiente = **M31 lote 2** (gaps propios ~2: niebla + season_mod + tests de secciones propias) + drift sec. P3 como deuda documentada (manda el dato, NO reescribir diseno) + informe 52 + tracker + Log del pool.
- [x] Log reservado: **1884** - M31 lote 2 niebla/estacional (head medido 1884 justo antes; 1879-1883 los consumieron otros agentes).
- [x] M31 lote 2 IMPLEMENTADO (msg 51 sec. 4): (1) NIEBLA - day_night_cycle.gd carga fog_curve.tres y aplica niebla_densidad(hora) al Environment (tween incluido); FOG_BASE = 0.00018 (niebla marina autoreada main_island.gd L204) x curva relativa 0.5-1.3; cierra el gap "fog_curve no se carga en codigo" (los items de niebla siguen [?] por el nodo FogVolume externo M45 - nota PARCIAL en L222); (2) SEASON_MOD - data nueva data/light/season_mod.tres (Curve dominio 0-3: Primavera 1.0, Verano 1.1, Otono 0.95, Invierno 0.85 - DECISION DE IMPLEMENTACION, el diseno sec. 4 no fija cifras) generada con gen_season_mod.gd (validador, EXIT 0) y consumida por mod_estacional() sobre day_curve (sol) + sky_curve (ambiente/cielo), luna NO modulada; estacion de M29 (get_estacion + estacion_cambio, _hora_actual trackeada); (3) PISO anti-oscuridad 0.15 (regla de oro sec. 7): maxf(valor*mod, 0.15) - en Invierno 0.15x0.85 clampeado a 0.15.
- [x] Test nuevo test_niebla_estacion_m31.gd: **47 checks / 0 fallos / EXIT 0 x3, 0 SCRIPT ERROR** (bloques A-C, piso CHECKS_MINIMOS = 47 MEDIDO en verde, _summary por call_deferred). **Guardian probado EN ROJO por inyeccion** (aborto runtime bloque C -> EXIT 1, "[FAIL] solo 28 checks ejecutados (minimo 47)"; el marcador de bloque NO dispara en aborto dentro del bloque - el piso es la capa que caza). Regresiones x2 verdes: test_curvas_luz.gd (0 fallos), test_ciclo_dia_noche.gd (16/0), test_cielo_estrellas_m31.gd (39/0).
- [x] TRAMPA MEDIDA (2): (a) Curve.sample() usa la curva HORNEADA (bake), no la interpolacion lineal exacta - mi test esperaba 1.02 a las 03:00 y el medido fue 1.0296 (corregido al valor medido); (b) una sonda de inyeccion via /tmp de Git Bash + python de Windows NO se aplico (rutas distintas) y la corrida "verde" fue de la suite SIN mutar - redetectada al revisar; rehecha con python administrado + assert de mutacion (familia trampa 75: medir la medicion).
- [x] M31 flip APLICADO (1, con cita): L99 (E season_mod.tres) [?] -> [x]. ANTES = 124 [x] / 45 [?] -> DESPUES = **125 [x] / 44 [?] / 0 [ ] = 169** (prefijo de linea, invariante OK). Header + Totales + nota PARCIAL L222 actualizados. 04-Codigo.md seccion nueva iter 4 lote 2 (append LF, 147 CRLF preservados). 03-Diseno.md nota de deriva sec. P3 al final (append LF).
- [x] Informe msg 52 al director (commit 80b0576 de la tanda lote 1 + lote 2 completo + fila GLOBAL a aplicar 124/169 -> 125/169 + drift sec. P3 registrado + pedido autorizacion commit tanda lote 2 (11 paths)). Tracker 50 -> 52 (2 B sin BOM sin newline; helper reservar_mensaje.py salta stale 49/51 -> 52 real; archivo renombrado al formato del canal -a-de-director-v4.1-).
- [x] VERIFICADO 2026-10-22: fila 31 del GLOBAL = 125/169 en el worktree (celda Progreso, prefijo de linea del checklist M31 = 125 [x]/44 [?]/0 [ ] = 169). Pendiente del director: aplicar fila GLOBAL 31 = 125/169 + autorizar commit de la tanda M31 lote 2 (sin push, pools excluidos).

- [x] **2026-10-16 02:09-02:30 - revision de canal (tracker 53): 2 mensajes nuevos (54 + 55, GLM-5.3 Flash-Director).** Msg 54: COMMIT LOTE 2 M31 AUTORIZADO (11 paths, sin push) + GLOBAL 31 aplicada por el (125/169) + **M76-Multijugador AUTORIZADO** (limites con M77: lo tecnico de red es de M77; reclamo del bloqueo en 4 registros). Msg 55 (02:20, correccion): M76 parcialmente bloqueado - los 11 items del manifiesto NO cerrables sin mp_contract.json; propuesta de crear el contrato.
- [x] **Commit 1201e55** (sin push, autorizado msg 54): 11 paths = 11 files, 579+/8- (M31 lote 2: day_night_cycle.gd, gen_season_mod.gd, test_niebla_estacion_m31.gd, season_mod.tres, 03-Diseno/04-Codigo/05-Checklist M31, Log 1884, msg 52, BACKLOG-MASTER, tracker). Hash confirmado al director en msg 56.
- [x] Log reservado: **1887** (head medido 1887 justo antes; pool NO commiteado).
- [x] **M76 auditado y cerrado en su alcance de contrato: 81 [x] / 3 [?] / 46 [ ] -> 126 [x] / 0 [?] / 4 [ ] = 130** (49 flips con cita: 42 [ ]->[x], 3 [?]->[x], 4 notas honestas).
- [x] **mp_contract.json ENTREGADO** (game/isla-ancestral/data/multijugador/, 1555 B, ASCII, LF; spec literal de 03-Diseno sec. 3.1; la ruta vieja Assets/_Project/Data/Postgame/ era fantasma Unity - hallazgo T-D7 confirmado). Cierra los 11 items de manifiesto.
- [x] **validate_mp_contract.gd ENTREGADO** (scripts/multijugador/, headless real extends SceneTree): 36 checks / 0 fallos / EXIT 0 x3 / 0 SCRIPT ERROR; **guardian probado EN ROJO** (aborto runtime bloque B -> EXIT 1, nombra [B], 32 checks < piso 36).
- [x] 03-Diseno.md sec. 7 NUEVA (19 definiciones de contrato con limite M77 explicito); 04-Codigo.md sec. 7 NUEVA (entregables, mediciones, trampas, honestidad).
- [x] TRAMPAS MEDIDAS: (1) el validador SE DETECTABA A SI MISMO (contiene los strings que prohibe) -> exclusion DECLARADA de validate_* con conteo; (2) substring mp_local matchea en dump_locales_m68.gd -> word boundary; (3) Git Bash paso \n/\t LITERALES al heredoc -> chr(10)/chr(9) (trampa 35 re-confirmada); (4) := sobre Variant de Array sin tipar -> Parse Error (trampa 26); (5) split por b"\n" de CRLF deja el \r al final -> notas como lineas nuevas (46 LF sueltos) -> revertido a HEAD y rehecho separando EOL por linea.
- [x] Reclamo del bloqueo M76 aplicado en 4 registros: header 05-Checklist (Estado En curso Step-5-WorkBuddy, sec. 21.4.7), ESTADO-PARALELO (fila nueva), BACKLOG-MASTER, fila GLOBAL entregada al director (msg 56 sec. 4).
- [x] Informe msg 56 al director (GLM-5.3 Flash-Director): hash 1201e55 + M76 126/130 + fila GLOBAL para aplicar + pedido autorizacion commit tanda M76 (10 paths). Tracker 54 -> 56 (2 B sin BOM sin newline).
- [x] Pendiente del director (msg 57, RESUELTO EN PARTE): el commit de la tanda M76 lo hizo el propio director en **982c159** (barrio todo: 3 docs M76, mp_contract.json, validate_mp_contract.gd, export_presets.cfg, sin push pendiente). Queda pendiente SOLO aplicar la fila GLOBAL 76 = 126/130.
- [x] Pendiente del director (msg 57, RESUELTO): los 11 flips de manifiesto quedan confirmados - con el contrato en el repo dejan de estar bloqueados (su 55 superado en ese punto) y se procesan normales.
- [x] **M55 tomado y auditado (iter. 4, Log 1897, reclamo 🔵 §21.4.7 autorizado msg 59):** 55-Diario-Del-Jugador, 37/3/91 → **58 [x] / 15 [?] / 58 [ ] = 131**.


- [x] **2026-10-16 03:28-03:40 - revision de canal (tracker 56 -> 57): 1 mensaje nuevo (57, GLM-5.3 Flash-Director).** Msg 57: acuse de que mp_contract.json + validate_mp_contract.gd viajaron al remoto en su catch-up **commit 982c159** (push d2efb96..04e111d + ce1986c, Log 1888); M31 lote 2 commiteado + GLOBAL 125/169 aplicada por el; los 11 items del manifiesto dejan de estar bloqueados (su 55 superado) -> procesalos normales; DeepSeek (267) midio M76 81/130 -> pedir mi medicion para reconciliar; recordatorio git pull --rebase antes de mi proximo commit.
- [x] **Commit 982c159 VERIFICADO** (git show --stat = 9 files, 490+/60-): incluye los 2 entregables M76 Y barrio mi documentacion M76 (03-Diseno sec.7 +87, 04-Codigo sec.7 +51, 05-Checklist 101 lineas con los 49 flips) + export_presets.cfg + bump CI. En origin/main (git branch -r --contains). 982c159 ancestro de HEAD (rc=0); HEAD == origin/main == a75feac (0/0 divergencia) -> el pull --rebase no hace falta, sin divergencia que rebasear.
- [x] Log reservado: **1894** (head medido 1894 justo antes; 1888 colision ajeno director-vs-M117; 1889-1893 de otros agentes).
- [x] **M76 reconciliacion de medicion (lo que pidio el director):** mi conteo sobre HEAD = **126 [x] / 0 [?] / 4 [ ] = 130** (prefijo de linea sobre git show HEAD:...05-Checklist.md; coincide Totales L214). DeepSeek 267 = 81/3/46 = el estado ANTES de mis flips (Log 1887 sec.2 midio ese mismo inicial). Diferencia = mis 49 flips exactos (42 [ ]->[x] + 3 [?]->[x]): 81+42+3=126, 46-42=4, 3-3=0. Cierra sin residuo. Las 11 colisiones de pool de logs (8 historicas + 1876/1878 + 1888) NO afectan el conteo del checklist.
- [x] Los 11 items del manifiesto confirmados [x] en HEAD con cita (L44/L52/L68/L84/L108/L116/L132/L140/L156/L180/L196 -> 03-Diseno sec.7.1/7.4/7.13/7.17, 02-Analisis 2.4A2/3.2/3.6, 01-Req 5 RF12, moderacion.reporte_jugadores, limite M15). Los 4 [ ] honestos: L61/L93 (requieren FASE MP implementada) + L211/L212 (cierre, pendientes de fila GLOBAL).
- [x] Evidencia fresca: validador headless sobre HEAD = 36 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR (4a corrida verde, binario real Godot 4.7.2). verificar_checklist.py exit 1 con UNA sola alerta de M76 (la esperada: GLOBAL 81/130 vs disco 126/130) + 4 ajenas no tocadas.
- [x] Informe msg 58 al director (UTF-8 sin BOM, LF, 5507 B): acuse 982c159 + reconciliacion con tabla de los 11 + fila GLOBAL 76 reiterada + pedido commit tanda verificacion (4 paths: msg 58, Log 1894, tracker, BACKLOG-MASTER). Tracker 56 -> 57 (2 B sin BOM sin newline).
- [x] VERIFICADO 2026-10-22: fila 76 = 126/130 aplicada + QA 21.8 VERIFICADO por Hy3 (sello visible en la fila del GLOBAL). Pendiente del director: **aplicar fila GLOBAL 76 = 126/130** (unica alerta de M76 en verificar_checklist.py) + ruteo del QA 21.8 de M76 a verificador externo (no auto-sellado; soy el creador del contrato).


- [x] **2026-10-17 16:24 — vuelta V2 (tracker 59 -> 66): 3 mensajes del director procesados (61, 63, 66) + M55 iter. 5 CERRADA.**
      Msg 61: fila GLOBAL 55 aplicada por el (58/131, verificado 8d4e41f + 3f60b14) + lote de rendimiento AUTORIZADO.
      Msg 63: sus 2 .gd borrados por su `git add -A` (7788533) RECUPERADOS desde c718068 (byte-identicos).
      Msg 66: metodologia V2 adoptada (ciclo: responder director -> BACKLOG -> reporte cada vuelta + marcas [x] en ESTE archivo).
      M55 iter. 5 (Log 1934): 1a corrida del test gate = 2 fallos de scroll -> bug de produccion REAL (paso de fila medido en cada llamada: 32 asumido vs 43 real, offset->indice descentrado) -> fix = paso congelado (`_paso_medido`) -> 26 checks / 0 fallos / EXIT 0 x3 + guardian EN ROJO (M55_SONDA=1) + 4/4 suites verdes.
      Mediciones: apertura 500+ entradas = 12.179 us · 12 filas de 500 en arbol · LazyLoad <= 2 llamadas · pooling 12 -> 12.
      4 flips W (L193-196) con cita: 58/15/58 -> **62 [x] / 15 [?] / 54 [ ] = 131**. Fila GLOBAL 62/131 para que aplique el director (alerta esperada del verificador).
      Cita fantasma reportada: diary_layer.gd citaba "Log 1898" (real = de otro agente, m30-fix-c56); el log de esta iter es 1934.
      Artefactos: Log 1934 (ASCII puro, CRLF), informe msg 67 (UTF-8 sin BOM, LF, 5654 B), tracker 59 -> 66, pool 67 consumido (head 62 stale reportado).
      Pendiente del director: aplicar fila GLOBAL 55 = 62/131 + autorizar commit de 9 paths (sin push, pools excluidos).

- [x] **2026-10-16 04:05-04:40 - revision de canal (tracker 57 -> 59): 1 mensaje nuevo (59, GLM-5.3 Flash-Director).** Msg 59: fila GLOBAL 76 APLICADA por el (126/130, con mi texto + celda Recom vacia para 11 canonicas; su conteo por script = 126/0/4, coincide con el mio); mi tanda commiteada por el en **1b6afea** (4 paths: msg 58, Log 1894, tracker, BACKLOG-MASTER) y YA PUSHEADA (origin/main; HEAD == origin/main == ebb3005, 0/0 -> el pull --rebase no hacia falta); **M55 AUTORIZADO** (toma como tarea: reclamo en 4 registros, DoD, headless, reporte de cierre). Nota: QA final de M76 a verificador externo cuando cierre (ruteo: agnes si Hy3 sigue con cola).
- [x] **Commit 1b6afea VERIFICADO** (git show --stat = 4 files, 162+/3-; git branch -r --contains = origin/main; los 4 paths estan en HEAD via git cat-file -e).
- [x] Log reservado: **1897** (head medido 1897 justo antes; 1895/1896 los consumieron otros agentes entre corridas).
- [x] **M55-Diario-Del-Jugador auditado contra disco (Patron D) + 4/4 suites headless VERDES** (binario real Godot 4.7.2, 0 SCRIPT ERROR en las 4): test_diario 0 fallos (37 checks: anti-spoiler L90/L97 + 6 integraciones por senal real) · test_diario_ui 89 checks/0 fallos (anti-spoiler L116/L192) · validate_diary 0 fallos/1 aviso (fotografias vacia = M56) · test_diario_persist 0 fallos (2 procesos Godot + SaveManager M59 real, slot 3).
- [x] **M55 flips: 37/3/91 -> 58 [x] / 15 [?] / 58 [ ] = 131** (invariante OK; CRLF preservado byte a byte, sin BOM, FFFD=0; conteo verificado por prefijo de linea Y contra verificar_checklist.py).
- [x] 21 flips [x] con cita: estados (enum + promocion), EventBus canal unico (6 puentes + emision diary.*), LUGAR_VISITADO (travel.island_loaded), anti-spoiler general §3.2 x11 ("No revelar X"), nombres propios EN, persistencia x5 (ISaveProvider + schema_version + sin duplicados + nivel/cierre + corrupta con defaults), migracion (carga tolerante, v1 unica).
- [x] 12 [?] con diagnostico MEDIDO y dueno: ESPECIE_AVISTADA (emisor fauna_registry EXISTE, ids 7 tierra/aire != 4 peces del catalogo -> M36/M34), PLANTA_IDENTIFICADA (sin emisor -> M50), MINERAL_DESCUBIERTO (extraccion != descubrimiento -> M35), RECETA_DESBLOQUEADA (emisor + ids coinciden pero CraftingService no es autoload ni nodo persistente -> M16), PISTA_LEIDA (sin emisor -> M24/M26), RUIDA_PROGRESADA (sin emisor -> M25), DESCUBRIMIENTO (M71 emite hito_* != descubrimiento_* -> M71), galeria Q x5 (frente sin contenido M56).
- [x] 04-Codigo.md sec. Notas iter. 4 (auditoria, flips, honestidades, recomendaciones); 05-Checklist header + Totales + reclamo actualizados; ESTADO-PARALELO (reclamo M55).
- [x] VERIFICADO 2026-10-22: informe msg 60 enviado en su momento (reclamo M55 + medicion + pedidos); fila 55 aplicada 67/131. Informe msg 60 al director (reclamo M55 + medicion 58/131 + fila GLOBAL para aplicar + pedido commit tanda: 05-Checklist, 04-Codigo, Log 1897, msg 60, tracker, BACKLOG-MASTER, ESTADO-PARALELO). Tracker 57 -> 59 (helper reserva saltando stale).
- [x] VERIFICADO 2026-10-22: fila 55 = 67/131 aplicada (commit 73da1c3, 2026-10-21; iter 5 incluida); QA 21.8 por Hy3. Pendiente del director: aplicar fila GLOBAL 55 = 58/131 (unica alerta M55 del verificador) + ruteo QA 21.8 de M55 a verificador externo + decision de commit de la tanda.
- [x] **2026-10-17 18:38 - vuelta V2 (tracker 67 -> 68): 1 mensaje nuevo del director procesado (068) + cierre de las 2 acciones que pedia (msg 069 enviado).**
      Msg 068 (GLM-5.3 Flash-Director, acuse de mi 67): (1) aplicar el [x] del item de rendimiento con evidencia + dups con politica de DS; (2) actualizar la fila 55 de CHECKLIST-GLOBAL.md con el conteo post-iter5. Acuses suyos verificados: los 2 .gd recuperados commiteados en c34db68 (en disco) y el lote de rendimiento dado por CERRADO VERDE.
      Verificado ANTES de escribir: gate re-corrido con el binario real (Godot 4.7.2 console headless) = 26 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR (840 lineas), corrida 18:29 de hoy. Las 4 marcas W (L193-196) YA estaban [x] y commiteadas en 258dbbf (git diff vacio) -> no habia nada que re-flippear; el pedido quedo en los dups.
      Dup encontrado y flippeado: L25 "Disenar lista virtualizada por categoria con scroll suave [C]" = dup de #194 (unico [ ] que comparte la evidencia del lote, por grep virtualiz|100 ms|pooling|lazy|perezosa). Aplicado con la politica de DS: misma evidencia + "dup de #194".
      Medido despues de escribir (prefijo de linea): **M55 = 63 [x] / 15 [?] / 53 [ ] = 131** (Totales L226 + cabecera L13 actualizados; CRLF 230/0 y sin BOM preservados byte a byte).
      CHECKLIST-GLOBAL.md fila 55 actualizada POR ORDEN EXPLICITA del msg 068: 62/131 -> **63/131**, Ultima actividad -> 2026-10-17, nota con evidencia + origen del flip + "sin auto-sello 21.8". EOL verificado: 219 LF / 0 CRLF / sin BOM; git diff = 1 linea.
      Artefactos: Log **1941** (ASCII puro por bytes, 55 CRLF, sin BOM, 5455 B; head medido 1941 justo antes -> pool head 1942), informe **msg 69** (UTF-8 sin BOM, LF, 4756 B), tracker 67 -> **68**, pool del canal: 69 consumido (head seguia stale en 62, sin archivo -> use ultimo+1 = 69 y lo reporte).
      Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a quality.yml, AGENTS.md, project.godot ni checklists ajenos.
      Pedido al director: autorizar commit de los 6 paths (05-Checklist.md M55, CHECKLIST-GLOBAL.md, Log 1941, msg 69, tracker, BACKLOG-MASTER) + ruteo del QA 21.8 de la iter. 5 + decision de cablear las 5 suites M55 en quality.yml + reparacion de CHECKLIST-GLOBAL.md (~23 lineas degradadas).

---

## Registro de la vuelta 2026-10-17 19:47 (tracker 69 -> 70, RAMA 1 + RAMA 2 / Bloque W + item 70)

- **1 mensaje nuevo del director procesado (070):** acuse puro de mi 69 (iter 5 de M55 cerrada), sin trabajo nuevo pedido. Verificado por el: 2 .gd en c34db68, lote rendimiento CERRADO VERDE, fila 55 GLOBAL 63/131 vigente. Respondido con msg 71 (misma vuelta).
- **DEFECTO PROPIO encontrado y reparado (estrella de la vuelta):** mi flip de L25 en la iter 5 (Log 1941, run 18:38) dejo mojibake doble-codificado (6 marcadores, round-trip latin-1 -> UTF-8) en `DOCUMENTACION/55-Diario-Del-Jugador/plan-actual/05-Checklist.md`. Detectado con el barrido de mojibake (item 70 de la cola, `scripts/diagnosticar_mojibake.py`, lectura pura). Reparado byte a byte sobre L25 unicamente: solo L25 cambio (231 lineas, diff = [24]), 230 CRLF preservados, 0 LF sueltos, sin BOM, 0 marcadores restantes, [x] + evidencia intactos. El mojibake NO estaba en 258dbbf: el defecto era de mi edicion sin commitear. Confesion Patron D.
- **Medido:** scan global 14 -> **13 SUCIO** (mi archivo sale de la lista) + 1 IRREVERSIBLE (scripts/validar_i18n_integridad.py, U+FFFD) + 263 EXCLUIDO. Los 13 SUCIO y el IRREVERSIBLE son AJENOS (canales historicos step-5-kilocode/atria-dawn/agnes/Hy3/Ling/DeepSeek + validador i18n): decision del director/fundador. El gate 'Mojibake scan' del CI sigue rojo por esos, no por mi.
- **Bloque W M76 item 7 CERRADO:** lote 2 de M76 = commit `1b6afea` (verificado: git cat-file -t = commit, git show --stat = 4 paths). Contrato mp en `982c159`; M76 sellado 21.8 por Hy3 en `b465697`. Items 4/10 (capturas inventario dark) = STALE: M76 cerrado y sellado, 0 items de captura en su 05-Checklist y sin carpeta capturas/ -> NO flippeados, propuestos retirar/reasignar (msg 71).
- **Conteos M55 sin cambio:** 63 [x] / 15 [?] / 53 [ ] = 131.
- **Artefactos:** Log **1946** (ASCII puro por bytes, 66 CRLF, sin BOM, 3845 B; head medido 1946 justo antes -> pool head 1947), informe **msg 71** (UTF-8 sin BOM, LF, ~3.9 KB; typo 'UTF-1' corregido a 'UTF-8' antes de cerrar), tracker 69 -> **70**, pool del canal: 71 consumido (el 62 stale sigue primero en el pool, sin tocar).
- **Limites:** 0 commits / 0 push / 0 flips ajenos / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot / 0 auto-sellos 21.8.
- **Pedidos al director:** commit de los paths M55 pendientes (incluida la L25 reparada); decision sobre los 13 SUCIO + 1 IRREVERSIBLE ajenos (el gate del CI); retiro/reasignacion de los items 4/10 del Bloque W.

---

## Registro de la vuelta 2026-10-17 21:00 (tracker 70 -> 70, RAMA 2 / ítem 65)

- **Sin mensajes nuevos del director** (último = 070, tracker 70). RAMA 2: trabajé el ítem 65 de la sección A (Escaneo de `ESTADO-PARALELO.md` vs GLOBAL).
- **TRAMPA MEDIDA (la estrella de la vuelta):** el EP **no es cronológicamente descendente**. Las liberaciones de M112 (L45) y M32 (L61) están ARRIBA de sus reclamos (L53/L69) pese a ser posteriores, y la liberación de M87 está DENTRO del cuerpo de su entrada AZUL (L25) sin cambiar la cabecera. Mi primer parser ("primera aparición gana") dio un diff FALSO: leía M112/M32/M87 como reclamados cuando están liberados. El diff final ordena por fecha real. Además la entrada más reciente (M53, L4951) trae hora UTC (23:52 UTC = 20:52 GMT-3 = hoy).
- **8 reclamos AZUL vigentes cruzados con el GLOBAL:** M45/M159 OK (nota en celda Agente); **M13 y M26 = DIFF-ESTADO** (reclamados en EP, fila del GLOBAL en AMARILLO); **M41/M49 = DIFF-CELDA** (fecha en "Agente actual"), **M46 = celda Agente vacía**; M53 OK (agente nuevo G-5.3-Flash-Agente, canal abierto hoy por directiva del fundador).
- **11 reservas AZUL colgadas >24 h con el trabajo ya reflejado en el GLOBAL:** M17 (10-03), M37 (10-03), M66/M116 (10-10), M155 (10-11), M83 (09-17), M96 (09-16), M128/M166 (09-18), M113/M115 (09-15). Son notas de liberación que faltan, no trabajo en vuelo. Ninguno reclamado (§21.4.7: los activos tienen <= 45 h).
- **Defectos de formato del GLOBAL medidos hoy:** 7 filas rompen el mapa por posición — M48 (L145, 23 celdas), M139 (L79, 26), M104 (L40, 17), M115 (L52, 17), M148 (L90, 16), M127 (L65, 15) con celdas vacías iniciales + M41 (L138, 10 celdas, corta). El defecto de Log 1940 (16 filas + L22 pegada + NUL) **bajó a 7** (L22 ya separado, NUL desaparecido, GLOBAL ahora LF puro 219 / 193.139 B / sin BOM) pero **sigue pendiente**. 12 filas con "Agente actual" que no es agente (fechas M30/M32/M41/M49/M61, "?" M146, notas M02/M35/M45/M94/M123).
- **Registro de agentes:** G-5.3-Flash-Agente (nuevo, M53) — pedir confirmar alta; `step-5-kilocode` sigue en 7 filas del GLOBAL pese a estar dado de baja; `minimax-3` (M144) y `s2` (M154) sin entrada propia en el EP; M94 atribuida a `deepseek-v4-flash-vision-exp` (modelo distinto de DeepSeek-V4.1-Flash, trampa 109) cuando la última actividad fue Step-5-WorkBuddy.
- **Casa propia verificada:** mis 6 módulos cuadran disco vs GLOBAL — M109 120/138 · M31 125/169 · M55 63/131 · M76 126/130 · M94 83/138 · M140 100/124.
- **Artefactos:** Log **1951** (ASCII puro por bytes, 7.740 B, 97 CRLF, sin BOM; head medido 1951 justo antes -> pool 1952), informe **msg 72** (UTF-8 sin BOM, LF, 7.131 B), pool del canal: **72 consumido** (el 62 stale sigue primero, sin tocar), anotación del ítem 65 + este registro en el BACKLOG.
- **Pool de Logs al cierre:** `reservar_log.py --estado` = 11 colisiones, **TODAS ajenas** (1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726, 1876, 1878, 1888). Ninguna mía: se reportan, no se tocan.
- **Límites:** 0 commits / 0 push / 0 marcas en módulos / 0 ediciones a CHECKLIST-GLOBAL.md, ESTADO-PARALELO.md, quality.yml, AGENTS.md, project.godot.
- **Pedidos al director:** subir a AZUL + agente las filas M13 y M26; reparar celdas Agente de M41/M49/M46 y las 7 filas malformadas (o autorizarme por bytes); confirmar alta de G-5.3-Flash-Agente y limpiar la atribución stale de step-5-kilocode (7 filas) y de M94; pedir a los dueños las notas de liberación de las 11 reservas colgadas (o autorizarme a redactarlas en el EP).
- **Próxima:** NN > 70; sin mensaje -> ítem 66 (normalización de `capturas/`) u otro de la cola.

---

## Registro de la vuelta 2026-10-17 22:20 (tracker 70 -> 70, RAMA 2 / ítem 66)

- **Sin mensajes nuevos del director** (último = 070, tracker 70). RAMA 2: trabajé el ítem 66 de la sección A (Normalización de `capturas/`, mínimo 2 por módulo).
- **El universo no era el que sugería el ítem:** en `DOCUMENTACION/` hay UNA sola carpeta `capturas/` (`04-Game-Engine/capturas`, 2 archivos, previa a la convención). La convención vigente (AGENTS.md §1231-1240) es `tools/mcp/godot-mcp/capturas/{ID-Modulo}-Nombre/` y está **gitignored** (`.gitignore:104`) -> la normalización no toca el repo commiteado: 0 commits necesarios.
- **HALLAZGO (bug de estructura, 5 casos):** capturas que quedaron como DIRECTORIO con el archivo adentro (`12-Camara/cap_12_camera_follow.webp/` y `09-Terreno-Y-Geografia/cap_09_Aurora{,_biomas,_playa,_playa2}.webp/`). `12-Camara` tenía 0 capturas por esto. Restauradas como archivos (1 archivo interno verificado en cada una); `find . -mindepth 2 -type d` = 0 después.
- **Merges/renombres ejecutados** (solo mover/renombrar, 0 borrados): `9/`(67)+`09/`(1)→09-Terreno-Y-Geografia (73) · `50/`(12)→50-Vegetacion (16) · `49/`(17)→49-Iluminacion (24) · `51/`(21)→51-Agua (nueva) · `155-Vestimenta/`(1)→155-Vestimenta-Y-Accesorios (11) · `19/`→19-NPC-Y-Vecinos · `45/`→45-Arte-3D · `47/`→47-Texturas-Y-Materiales (3 nuevas carpetas) · RENAME 10-Mundo-Voxel→10-Generacion-Del-Mundo · 37-Museo→37-Museos-Y-Colecciones · 163-Encantamientos→163-Sistema-De-Encantamientos · 105-Agua-Blanca→105-Telemetria-De-Gameplay ("Agua Blanca" no existe en DOCUMENTACION: grep=0) · 01-Jugador→01-Fundamentos-Del-Proyecto · 22 sueltos de raíz → carpeta por prefijo (15/16/33/34/40/53/110).
- **Cobertura final (mínimo 2):** 169 módulos canónicos; 37 con carpeta; **29 OK**; **8 con 1 sola** (108, 12-Camara, 154, 19, 34, 40, 88 + 52-QA-WEB); 132 sin carpeta (la mayoría no visual: legal/marketing/gestión; pero visuales en 0: 11, 57, 58, 89, 146, 147, 151, 156, 158, 160, 164, 168). Verificación por snapshots: 407 antes = 407 después, 0 perdidos, 0 nuevos.
- **Artefactos:** Log **1957** (ASCII puro por bytes verificado: 0 no-ASCII, 59 CRLF, 0 LF sueltos, sin BOM, 6.069 B; head medido 1957 justo antes -> pool 1958), informe **msg 73** (UTF-8 sin BOM, LF puro 45, 0 FFFD, 0 NUL, 4.897 B), pool del canal: **73 consumido** (ultimo+1 = 73; el 62 stale sigue primero en el pool, sin tocar), tracker sigue en 70.
- **Límites:** 0 archivos borrados · 0 commits / 0 push · 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot ni módulos ajenos · 0 flips / 0 auto-sellos 21.8.
- **Pedidos al director (msg 73):** decidir sobre las 4 carpetas ambiguas (`19-Muelle/`, `52-QA-WEB/`, `QA-M51-M31-M19/`, `gameplay/`), los 15 sueltos (`cap_diag/cap_fix/cap_tienda`: 21-Dialogos vs 162-Dialogos-Contextuales-De-NPCs; + 2 `prueba-*`) y el futuro de `DOCUMENTACION/04-Game-Engine/capturas/` (migrar o archivar). Sigue pendiente el retiro/reasignación de los ítems 4/10 del Bloque W.
- **Próxima:** NN > 70; sin mensaje -> ítem 67 (inventario de assets sin atribución, BUG-052) u otro de la cola.


## Registro de la vuelta 2026-10-17 23:34 (tracker 70 -> 70, RAMA 2 / item 67)

- **Sin mensajes nuevos del director** (ultimo = 070, tracker 70). RAMA 2: trabaje el item 67 de la seccion A (Inventario de assets sin atribucion, BUG-052, 694 glb).
- **Universo medido en 3 perimetros (no confundir):** gate (`game/isla-ancestral/assets`, scope de `asset_metadata_scope.json`) = **722 archivos en alcance**; versionados = **694 .glb** = 418 `assets/3d` (los unicos bajo res://) + 250 `tools/mcp` + 16 respaldos `Obsoletos/2026-10-10_01-49-00_glb-respaldos-assets-3d/` + 10 `game/Obsoletos` (cuadra con la auditoria de Log 1035: CON 0 / SIN 694 / AMBIGUO 0); disco total = **1388** (694 + la copia `.kilo/worktrees/phase-judge/`, excluida por el scope).
- **HALLAZGO GRAVE (medido):** `python tools/legal/validate_asset_metadata.py --check` = **EXIT 1**. Informe `--json`: 722 en alcance = 418 .glb + 300 .png + 4 .ttf; magic invalido **0** (BUG-042 resuelto: las 4 .ttf de assets/fonts son fuentes reales de 39-277 KB); CON atribucion embebida **0**; SIN atribucion **718**; inventarios 54/54 completos. Techo .glb: **418 de max 418, clavado, 0 holgura**.
- **Los 300 HALLAZGOS NUEVOS** son todos `.png` de `game/isla-ancestral/assets/2d/items_m159/` (ico_*.png, 48x48 RGBA, 226 B, placeholders de la tanda de iconos de M159): commits 94c1c7f / cd7d85c / 13825c6, todos del **2026-10-17** - POSTERIORES al cierre de BUG-052 del 2026-10-10 (418/418 EXIT 0, trinquete intacto). Misma deuda de raiz (exportador sin copyright embebido) trasladada de .glb a .png por una puerta que el trinquete no cubria. El paso CI `Verify legal gates (M127 iter. 3)` (`quality.yml:659`) corre ese `--check` sin `|| true` y Actions evalua los `run: |` con `-e` -> el job no puede pasar en HEAD. Rojo DISTINTO del ajeno ya conocido (`scripts/legal/test_licenses_m83.gd:111`, job de tests Godot).
- **Derivas documentales (no tocadas):** `11-BUGS.md` fila L135 dice BUG-052 RESUELTO pero el detalle L4486 dice "[ ] Abierto" (falta registrar ademas la re-apertura parcial por los 300 PNG); la nota MAGIC_INVALIDO del scope quedo obsoleta (holgura muerta de 3).
- **Opciones presentadas al director (msg 74), ninguna ejecutada:** (a) fix de raiz en el pipeline M166/M09; (b) backfill de los 300 PNG (ofrecido, requiere autorizacion con paths exactos); (c) baseline nuevo `**/assets/2d/**/*.png` max 300 - desaconsejado (consagra la deuda). Recomendacion: (a)+(b).
- **Artefactos:** Log **1961** (ASCII puro verificado por bytes: 0 no-ASCII, 58 CRLF, 0 LF sueltos, sin BOM, 5.965 B; head medido 1961 justo antes -> pool 1962), informe **msg 74** (UTF-8 sin BOM, LF puro, sin BOM, ~4,5 KB), pool del canal: **74 consumido** (ultimo+1 = 73+1; el 62 stale sigue primero, sin tocar), tracker sigue en 70. Evidencia cruda en `.workbuddy-ai/tmp/inv_assets.json` (gitignored).
- **Limites:** 0 commits / 0 push / 0 assets modificados / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot, 11-BUGS.md ni modulos ajenos.
- **Proxima:** NN > 70; sin mensaje -> item 68 (specs para modulos verde->amarillo por [?]) u otro de la cola.
---

## Vuelta 2026-10-18 01:5x — RAMA 2 (sin mensajes nuevos; tracker 70) + item 68

- **Sin mensajes nuevos del director** (ultimo = 070, tracker 70). RAMA 2: item 68 de la
  seccion A = "Preparacion de specs para modulos verde->amarillo por [?]". Respondido con
  msg 75 + Log 1968.
- **Universo medido (regex por prefijo de linea):** 168 modulos con checklist; 101 con
  al menos un [?] (1.152 items); 53 sin ningun [ ] (blanco de la tarea, 783 [?]) y 48 con
  [ ] ademas (369 [?]).
- **AUTOCORRECCION (Patron D):** mi primer contador de [ ] usaba `(m)^- \[ \]` en lugar
  de `(?m)` -> media 0 en TODOS los modulos. Lo detecte al cruzar con el bloque Totales
  de M68 (18 [ ] reales). Los contadores de [x] y [?] usaban (?m) y son correctos. Contar
  con el regex corregido antes de publicar cualquier particion.
- **Artefacto creado:** `legal/marketing_legal_review.md` (7.073 B, 134 LF, UTF-8 sin BOM,
  0 FFFD) -> cierra el unico [?] de M126 (L90; artefacto inexistente medido 2026-10-12).
  Flip propuesto al director (M126 quedaria 101/101). Hallazgo: la plantilla declaraba
  Blender/GIMP GPL pero THIRD-PARTY-NOTICES.md tiene 0 menciones (medido).
- **Uplift de DOCUMENTACION/README.md redactado y propuesto** (no aplicado): cierra M3
  L67/L68/L69; raiz real = 16 carpetas; carpetas Unity no aplican (proyecto Godot).
- **M73 L215 verificado:** plan-inicial = 130 items exactos, todos [ ], con cabecera que
  miente "130/130 completados" (familia M79-L7); plan-actual = 135 -> la igualdad
  plan-inicial == plan-actual es inalcanzable por diseno (plan-inicial NO MODIFICAR).
- **M52:** 2 decisiones de spec medidas - `git grep VfxManager` = 0 hits,
  `git ls-files "*validate_vfx*"` = 0, sin autoload VFX en project.godot; los archivos
  reales son vfx_director/factory/pool/schema/trigger/loops + 5 suites (QA Log 1030).
- **M29:** el [?] "Flecha indicadora en el HUD" esta DUPLICADO (L75 y L207).
- **Muestreo clasificado (65 items, 33 modulos):** A spec/documentacion (M126, M3, M123,
  M52 x2, M73, M2) · B dependencia externa con dueno (16 modulos) · C contenido/codigo
  (M148, M52 x1, M109 x3, M60, M24) · D revertidos BUG-070/Familia A (M80/M81/M85/M82, 11).
- **Artefactos:** Log 1968 (reservado del pool, head medido 1968 justo antes -> 1969),
  informe `specs-dudas-2026-10-18.md` (10.079 B, LF, sin BOM), msg 75 (UTF-8 sin BOM, LF),
  tracker 70 (sin cambios), diario y memoria de automatizacion.
- **Limites:** 0 commits / 0 push / 0 flips / 0 ediciones a CHECKLIST-GLOBAL.md,
  quality.yml, AGENTS.md, project.godot ni 05-Checklist ajenos. Unico archivo creado
  fuera de mi carpeta: legal/marketing_legal_review.md (ruta nombrada por el propio item;
  `git check-ignore` rc=1 = no ignorada; hermanos legal/* versionados en LF).
- **Proxima:** NN > 70; sin mensaje -> item 69 (pre-copia de Obsoletos/ antes de refactors
  grandes) u otro de la cola.
## Registro de la vuelta 2026-10-18 03:36 (tracker 70 sin cambios, RAMA 2 / item 69)

- **Sin mensajes nuevos del director** (ultimo = 070). Item 69 = "Pre-copia de `Obsoletos/` antes de
  refactors grandes (parr. 5)". Respondido con msg 76 + Log 1980.
- **Hallazgo principal:** `Obsoletos/` = 732 archivos / 22.631.175 B, de los cuales **481 (65,7 %)
  estan FUERA de git** (384 ignorados + 97 sin seguimiento). Un `git clean -fdx` o un clone nuevo
  se lleva 2 de cada 3 archivos de la carpeta que parr. 5 define como red de seguridad. Los 97 sin
  seguimiento son los respaldos mas frescos (hoy 00:52, `encoding-backup-20261018_005227`, 87
  archivos con `data/items/*.tres`).
- Convencion parr. 5: cumplida en 137/732 (18,7 %) - 32 con sello en el nombre + 105 en la carpeta;
  595 sin sello. 6 respaldos de 0 bytes. 104 archivos tocados en 24 h (la parr. 5 SI se usa).
- **Entregado `scripts/precopia_obsoletos.py`** (sin commitear). Probado con el binario real:
  dry-run 0 escrituras; corrida real 2/2 verificados + manifiesto SHA-256; **ancla faltante ->
  EXIT 1 sin copiar nada**; destino existente -> EXIT 1 sin sobrescribir. Pruebas contra
  `.workbuddy-ai/tmp/`, nunca contra `Obsoletos/`.
- **DEFECTO PROPIO confesado:** al consumir el 76 del pool de canal trunque el archivo un instante
  (lo abri en modo escritura binaria, que trunca al abrir, y la escritura fallo despues). Reparado
  desde la copia byte a byte de `.workbuddy-ai/tmp/`; diff contra el respaldo = solo falta la linea
  `76`. Pool final: 143 numeros, LF puro, sin BOM. Leccion: escribir el contenido completo en
  memoria y abrir el archivo una sola vez (o tmp + rename).
- **Artefactos:** Log 1980 (ASCII puro por bytes, 100 CRLF, sin BOM, 5.836 B; head medido 1979 y
  consumido por otro agente en el medio -> reserve 1980), msg 76 (UTF-8 sin BOM, LF, 5.284 B),
  informe `item-69-precopia-obsoletos-2026-10-18.md`, tracker 70, diario y memoria.
- **Limites:** 0 commits / 0 push / 0 archivos de proyecto modificados / 0 borrados / 0 flips /
  0 autosellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot.
- **Proxima:** NN > 70; sin mensaje -> item 70 (barrido de tildes/mojibake en archivos nuevos del
  dia) u otro de la cola.


## Registro de la vuelta 2026-10-18 19:22 (tracker 70 -> 94, RAMA 1 + RAMA 2 / acuse 094 + item 54)

- **Mensaje nuevo del director: 094** ("veredicto barrido 70", 2026-10-18 06:15). Acuse puro + su
  veredicto sobre mis 4 hallazgos del barrido del dia (todos confirmados: mojibake real 0; los 4
  Hallazgos eran falsos positivos o ajenos deliberados). Respondido con msg 78 + Log 1992.
- **Verificacion en disco de las 3 afirmaciones del 094:** (1) flip M126 [?]->[x] del director =
  CONFIRMADO (commit eca50bc; L90 = [x]; git status limpio en esas rutas); (2) artefacto
  legal/marketing_legal_review.md = EXISTE (7.073 B, LF, sin BOM, mtime 02:07 de hoy); (3) fila 126
  del GLOBAL sincronizada solo a MEDIAS: Notas con la linea nueva, pero celda Estado sigue 'Con
  dudas' con 101 [x] / 0 [?] / 0 [ ].
- **Hallazgo 1 (ajeno, NO tocado):** L90 de M126 y el banner L9-10 siguen afirmando 'ARTEFACTO
  INEXISTENTE ... legal/ y docs/legal/ no existen' cuando el artefacto existe. [x] con justificacion
  falsa (familia M79-L7 / M73 L215). Fix de texto, dueno: director o dueno del modulo.
- **Hallazgo 2 (ajeno, NO tocado):** 'Con dudas' sin [?] es incoherente con la leyenda. No propongo
  Completado automatico: el artefacto lo hice yo -> sello 21.8 no auto; el sello del 2026-10-12 fue
  denegado y no se hereda. Corresponde re-verify independiente (Hy3/agnes).
- **RAMA 2 (item 54, Bloque C):** scripts/verificar_checklist.py -> EXIT 1 con 16 alertas,
  clasificadas por grupo con la celda exacta a aplicar (A: 7 filas 'Disponible' con [x] - solo celda
  Estado; B: 125 104/105 vs 105 medidos; C: 157 con plan-actual/ vacio; D: 7 avisos 21.4.7). Casa
  propia OK: las 16 no se cruzan con mis 6 modulos ni con la deuda de los 16 'Totales'.
- **Housekeeping:** el tracker llegaba ya en 94 con mtime 19:09 y SIN respuesta ni artefactos de una
  corrida previa (mi ultimo artefacto seguia siendo el 77 de las 05:06) -> corrida anterior toco el
  tracker y no llego a responder; este msg 78 es la respuesta que faltaba. Pool de canal: 78
  consumido (ultimo+1; cabeza seguia stale en 62, reportado). Pool de Logs: cabeza 1992 medida justo
  antes -> consumida (cabeza 1993).
- **Artefactos:** msg 78 (UTF-8 sin BOM, LF puro 5.917 B), informe-078 (LF, 7.371 B), Log 1992
  (ASCII puro por bytes: 5.138 B, 88 CRLF, 0 LF sueltos, sin BOM), este registro. Tracker 94.
- **Limites:** 0 commits / 0 push / 0 archivos ajenos modificados / 0 ediciones a
  CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot / 0 flips / 0 autosellos 21.8.
- **Proxima:** NN > 94; sin mensaje -> item 55 (corrida verificar_backlogs.py + reporte) u otro de la
  cola.

## Registro de la vuelta 2026-10-18 21:2x (RAMA 1: msg 077 del director + RAMA 2: item 55)

- **RAMA 1 - mensaje nuevo del director: 077** (`077-2026-10-18_23-59-00-glm-53-flash-director-a-Step-5-WorkBuddy-instructivo-global-utf8-sin-bom.md`, mtime 20:51) = INSTRUCTIVO GLOBAL: UTF-8 SIN BOM + LF en todo archivo escrito al repo (nunca Set-Content de PS 5.1; usar Python), procedimiento `verificar_bom.py --fix`, y la regla del pool (100 numeros consecutivos SIN usados, PASO 4 del metodo de renumeracion). Respondido con msg 78 + Log 1995.
- **Casa propia verificada por bytes (19 archivos: 10 mensajes 065-076, 5 logs del dia, BACKLOG, pool, tracker): 0 BOM, 0 UTF-16, 0 FFFD.** Mensajes/BACKLOG LF puro; logs CRLF puro + ASCII puro (convencion de Logs/ preservada - declarada al director).
- **Colision de timing de pool (reportada, no tocada):** yo habia consumido el 077 del pool minutos antes de que el director escribiera su instructivo con el mismo 077. Acciones: removi 078 para esta respuesta (regla 1) y reeexpandi el pool a **100 consecutivos sin usados = 079-178**, LF puro, sin BOM (regla 4). Tracker en 077 (mensaje del director procesado).
- **Nota menor:** el 077 cita "Ling 8bbb43" (commit real f8bbb43) y pierde caracteres en el cuerpo (corrupcion reparada); documentado al director sin accion pedida.
- **RAMA 2 - item 55 HECHO:** corrida de `scripts/verificar_backlogs.py` (EXIT 1, 27/29 modelos con backlog, 304 cierres-delta, 5 drift-inverso, 0 modulos inexistentes). Los 5 drift-inverso MATERIALES verificados en disco (backlog DeepSeek L811/812/814/862/866 `[ ]` vs M62 05-Checklist L110/111/113/214/218 `[x]` desde iter. 7 / Tanda 6 2026-10-17). Los 304 = ruido del parser (familia "colisiones AJENAS 1290", conteos de modulos vecinos; mis 5 "RETROCESO" falsos con la linea fuente leida). BUG del `--json` (UnboundLocalError -> exit 1 siempre) con patch propuesto NO aplicado (herramental compartido). Evidencia completa en Log 1995.
- **Artefactos:** msg 78 (UTF-8 sin BOM, LF puro 5.356 B, verificado por bytes), Log 1995 (ASCII puro, 8.885 B, 151 CRLF, 0 LF sueltos, sin BOM; cabeza del pool de Logs medida justo antes = 1995), item 55 -> `[x]`, este registro.
- **Limites:** 0 commits / 0 push / 0 archivos ajenos modificados / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot / 0 flips / 0 autosellos 21.8.
- **Proxima:** NN > 77; sin mensaje -> item 56 (corrida verificar_pool_numeros.py + saneo, respaldo director) u otro de la cola.

## Registro de la vuelta 2026-10-18 21:45 (RAMA 2 / item 56: pools de numeracion)

- **Barrido de canal:** tracker 77; listado RECURSIVO de mi carpeta -> 78 mensajes + pool + LEEME. Ultimo del director = 077 (instructivo UTF-8 sin BOM + regla del pool). 078 es propio. **Sin mensajes nuevos** -> RAMA 2.
- **Item 56 HECHO:** `scripts/verificar_pool_numeros.py` -> **EXIT 0** (lectura completa previa; READ-ONLY; exit code por proceso, no por pipe). Pool global: 1002 libres 1999..3000, 1914 logs, ultimo 1998, correlativo. 17 canales auditados. Mi canal: 100 libres, 78 mensajes, sin huecos.
- **Casa propia por bytes:** pool del canal 379 B, sin BOM, CRLF=0, LF=100, 079..178 consecutivos; consumido 079 para el msg 79 (ultimo+1, cabeza coincidente) y reeexpandido a 100 consecutivos = 080..179 (regla 4 del 077). El pool del canal esta gitignore; el global de Logs NO (medido con git check-ignore).
- **Control de ceguera:** fixture en `.workbuddy-ai/tmp/poolfix/` (borrado) -> EXIT 1 con 4 detecciones correctas -> el verificador discrimina y el verde de hoy es real.
- **Artefactos:** Log 1999 (ASCII puro, 4.439 B, 74 CRLF, 0 LF sueltos, sin BOM; cabeza del pool de Logs medida justo antes = 1999 -> pool 2000), msg 079 (UTF-8 sin BOM, LF puro, 2.971 B), este registro, item 56 -> [x].
- **Limites:** 0 commits / 0 push / 0 archivos de proyecto modificados / 0 pools ajenos tocados / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot / 0 flips / 0 autosellos 21.8.
- **Proxima:** NN > 77; sin mensaje -> item 57 (barrido de `**Totales:**` inconsistentes, drift > 5, en CHECKLIST-GLOBAL) u otro de la cola.


## Registro de la vuelta 2026-10-18 23:03 (tracker 79 sin cambios, RAMA 2 / item 57: barrido de Totales inconsistentes)

- Sin mensajes nuevos del director (ultimo = 077, ya procesado y acusado en mi 078; 079 propio). Tracker 79.
- Item 57 (Bloque C) HECHO con Log 2003 + msg 080. Detalle completo en la linea 57 de la cola y en el log.
- Universo: 167 plan-actual; plan-inicial medido aparte (36 drift) y excluido por diseno. 3 drift > 5 en plan-actual: M71 (96), M32 (23), M30 (12); todos ajenos; total-declarado 0 drift; NO-PARSE 2 (M116, M151).
- Pedido al director: criterio/lista origen de sus '16 Totales incoherentes' para verificarlos uno por uno.
- Trampa propia: fraccionario X/N suelto dentro de la linea de Totales (cita de test) inventaba 'completados'; corregido en v3 del medidor (fraccionario solo en los primeros 80 chars y solo si no hay desglose backtick). Segundo `·` (U+00B7) colado en el log recien escrito: normalizado a ASCII antes de publicar (trampa 125).
- Artefactos: Log 2003 (ASCII puro por bytes, 80 CRLF, 0 LF sueltos, sin BOM, 4.180 B), msg 080 (UTF-8 sin BOM, LF puro, 3.465 B, verificado por bytes), BACKLOG item 57 [x] + este registro (LF preservado), pool canal 80 consumido y reexpandido a 81..180 (100 consecutivos sin usados), pool Logs 2003 consumido (2004 en adelante), tracker 79 sin cambios, diario y memorias.
- Limites: 0 commits / 0 push / 0 archivos de modulo modificados / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot.
- Proxima: NN > 79; sin mensaje -> item 58 (barrido de [?] en modulos amarillos con dependencia ya resuelta) u otro de la cola.


## REPOBLACION V3 (2026-10-19T00:01:51) — items REALES de 05-Checklist (fuente en comentario)
1. - [ ] [67] Navegar por agua leyendo la superficie (M51, sin fluidos) [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
2. - [ ] [67] Velocidad de crucero/rápida, timón suave y reversa [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
3. - [ ] [67] Colisiones con islas, rocas y vegetación (M50) sin atravesar [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
4. - [ ] [67] No atascarse en aguas poco profundas (aviso) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
5. - [ ] [67] Vela desplegable (M48) y estela por evento (M52) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
6. - [ ] [67] Vuelo con altitud/descenso y aterrizaje suave en plataformas [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
7. - [ ] [67] Altitud máxima 60 m (mejorable a 90 m) [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
8. - [ ] [67] No romper el streaming a gran altura (chunk_target + LOD, M10/M61) [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
9. - [ ] [67] No colisionar con vegetación alta (paso por encima) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
10. - [ ] [67] Viento lateral (M32) y farol nocturno (M49) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
11. - [ ] [67] Buceo/emersión con límite −40 m y flotabilidad mínima [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
12. - [ ] [67] Visibilidad y luces bajo el agua (M49) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
13. - [ ] [67] Explorar cuevas subacuáticas (M25) [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
14. - [ ] [67] Burbujas por evento (M52) y audio amortiguado (M43) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
15. - [ ] [67] Cámara estable bajo el agua (sin mareo) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
16. - [ ] [67] Velocidad sobre riel fija (20 m/s) y sin giro libre [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
17. - [ ] [67] Vagón de carga (16 slots, M14) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
18. - [ ] [67] Documentar el estado condicional en 01-Requerimientos.md [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
19. - [ ] [67] Controles con WASD y gamepad (palanca/gatillos) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
20. - [ ] [67] Testear física en 30/60 FPS (delta correcto) [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
21. - [ ] [67] Volver chunk_target = jugador al salir [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
22. - [ ] [67] LOD de chunks por altitud del dirigible [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
23. - [ ] [67] Cargar islas cercanas (M27) antes que el terreno lejano [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
24. - [ ] [67] Testear barco/dirigible/submarino sin popping de terreno [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
25. - [ ] [67] Colisiones suaves con islas, rocas y vegetación (M50) [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
26. - [ ] [67] Barco no puede ir a tierra; submarino no emerge en tierra [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
27. - [ ] [67] Dirigible con techo de altitud [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
28. - [ ] [67] Vehículos no atraviesan puentes (M11) ni ruinas (M25) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
29. - [ ] [67] No atropellar animales (M36) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
30. - [ ] [67] Interacción para entrar/salir del vehículo [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
31. - [ ] [67] Entrada solo si está docked o en superficie [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
32. - [ ] [67] Al salir: restaurar cámara, HUD y sonidos (sin fugas) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
33. - [ ] [67] No quedar atascado cerca de muros al entrar/salir [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
34. - [ ] [67] Testear entrada/salida con gamepad y durante eventos (M74) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
35. - [ ] [67] Atraque con magnetismo suave en muelles [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
36. - [ ] [67] Ajustar posición y rotación; ángulo inválido → reintento [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
37. - [ ] [67] Docking de barco y dirigible en plataformas [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
38. - [ ] [67] Indicador visual de zona de atraque (M53) y sonido (M43) [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
39. - [ ] [67] Testear docking en muelles angostos y con olas (M51) [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
40. - [ ] [67] Baúl integrado con slots por tipo (barco 12, dirigible 8, submarino 10) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
41. - [ ] [67] Abrir el baúl desde el HUD y mover ítems [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
42. - [ ] [67] Límite de slots respetado y apilables [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
43. - [ ] [67] Mejora de baúl persistente (M59) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
44. - [ ] [67] Testear baúl con inventario lleno [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
45. - [ ] [67] Definir mejoras por vehículo (velocidad, giro, faroles, baúl) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
46. - [ ] [67] Mejoras de velocidad/giro (niveles) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
47. - [ ] [67] Mejoras de faroles (M49) y baúl [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
48. - [ ] [67] Comprar en tienda (M39) o artesanales (M16) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
49. - [ ] [67] Persistencia y visualización de nivel en el HUD [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
50. - [ ] [67] Pintura del vehículo (paleta cozy, M46) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
51. - [ ] [67] Banderas personalizables con viento (M50/M48) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
52. - [ ] [67] Nombre del vehículo editable y localizable (M87) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
53. - [ ] [67] Materiales de pintura del pool (M45/M49) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
54. - [ ] [67] Persistencia de personalización (M59) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
55. - [ ] [67] Sonidos de motor/agua/viento por vehículo [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
56. - [ ] [67] LOD de audio: atenuar > 40 m, silenciar > 80 m [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
57. - [ ] [67] Sin fugas de audio al salir [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
58. - [ ] [67] Sonidos de docking/salida y balance con M91 [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
59. - [ ] [67] Testear audio 3D y bajo el agua (amortiguado) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
60. - [ ] [67] Timón al girar, olas/estela y hélices del dirigible [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
61. - [ ] [67] Pasajeros a bordo y banderas con viento [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
62. - [ ] [67] Detener animaciones al salir (sin fuga) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
63. - [ ] [67] LOD de animaciones en distancia [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
64. - [ ] [67] Testear animaciones con Reduce Motion (M58) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
65. - [ ] [67] Cámara 3ª persona con zoom de cámara [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
66. - [ ] [67] Seguimiento suave sin mareo (M57) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
67. - [ ] [67] Reducir movimiento con Reduce Motion (M58) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
68. - [ ] [67] Cámara del submarino estable y sin clipping del dirigible [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
69. - [ ] [67] Testear cámara en 16:9 y 4:3 (M08) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
70. - [ ] [67] Presupuesto por vehículo ≤ 30 draw calls (pooling M62) [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
71. - [ ] [67] Luces de faroles en pool (M49, máx 2 por vehículo) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
72. - [ ] [67] VFX solo por eventos (M52) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
73. - [ ] [67] Sin GC pesado durante la conducción [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
74. - [ ] [67] Probar con profiler (M116) y baja calidad (M90) [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
75. - [ ] [67] Entrar con inventario abierto (M14) o durante diálogo (M21, bloqueado) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
76. - [ ] [67] Salir con el vehículo en movimiento rápido [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
77. - [ ] [67] Vehículo atascado en roca (desatascado manual) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
78. - [ ] [67] Barco en agua congelada (hielo M51) y dirigible con viento fuerte (M32) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
79. - [ ] [67] Carga de guardado con vehículo en el agua o a 60 m (M59) [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
80. - [ ] [67] Localizar HUD del vehículo (velocidad, dirección) [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
81. - [ ] [67] Localizar menús de personalización y avisos de docking [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
82. - [ ] [67] Localizar nombres de vehículos [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
83. - [ ] [67] Testear HUD en 3 idiomas sin desbordes [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
84. - [ ] [67] Localizar mensajes de límites (profundidad, altitud) [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
85. - [ ] [67] HUD legible con alto contraste opcional [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
86. - [ ] [67] Reduce Motion: cámara y animaciones reducidas [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
87. - [ ] [67] Subtítulos en avisos del vehículo [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
88. - [ ] [67] Controles completos con gamepad (sin mouse) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
89. - [ ] [67] Crear validate_vehicles.gd (física, streaming, colisiones, presupuestos) [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
90. - [ ] [67] Probar ciclo barco: dock → entrar → navegar → atracar → salir [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
91. - [ ] [67] Probar ciclo dirigible: despegar → volar → aterrizar [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
92. - [ ] [67] Probar ciclo submarino: sumergir → explorar → emerger [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
93. - [ ] [67] Revisar logs VEH-* en consola sin errores [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
94. - [ ] [67] Documentar los presets en 04-Codigo.md [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
95. - [ ] [67] Documentar el flujo de streaming (chunk_target) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
96. - [ ] [67] Documentar la condición de la locomotora [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
97. - [ ] [67] Agregar notas del agente al 04-Codigo.md (honestidad) [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
98. - [ ] [67] Alimentar logros de exploración (M72) por viajes [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
99. - [ ] [67] Registrar fotos del vehículo (M56, PHOTO_POSE_REQUEST) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
100. - [ ] [67] Guardar estado del vehículo en el mundo (M59) [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
101. - [ ] [67] Coordinar con M68 la navegación asistida [M] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
102. - [ ] [67] Testear integración con M28 (viajes entre islas) [C] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
103. - [ ] [67] Firmar los documentos del módulo (modelo y plataforma) [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
104. - [ ] [67] Actualizar CHECKLIST-GLOBAL con el progreso real [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
105. - [ ] [67] Actualizar DOCUMENTACION/README.md con el módulo 67 [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
106. - [ ] [67] Actualizar ESTADO-PARALELO.md [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
107. - [ ] [67] Generar el log 63 en Logs/ [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
108. - [ ] [67] Verificar con verificar_checklist.py (sin alertas nuevas) [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
109. - [ ] [67] Push del módulo y reporte al usuario [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
110. - [ ] [67] Marcar ítems solo al cumplir la DoD (sección 21.6) [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
111. - [ ] [67] Revisar que plan-inicial == plan-actual (SHA-256) [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
112. - [ ] [67] Confirmar 130 ítems exactos [S] <!-- fuente: 67-Vehiculos/05-Checklist.md -->
113. - [ ] [23] Crear la historia de la panadera (2-4 pasos) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
114. - [x] [23] Crear la historia del farero [M] — cadena-faro en data/historias/secundarias.json (4 pasos, consecuencia faro_encendido; test bloque C, Log 2082) <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
115. - [ ] [23] Crear la historia de la doctora [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
116. - [ ] [23] Crear la historia del carpintero [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
117. - [ ] [23] Crear la historia de la tejedora [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
118. - [ ] [23] Crear la historia del pescador [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
119. - [ ] [23] Crear la historia del guarda [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
120. - [ ] [23] Crear la historia de la alquimista [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
121. - [ ] [23] Documentar las historias de vecinos en el plan-actual [S] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
122. - [ ] [23] Crear la historia del faro (lugar) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
123. - [x] [23] Crear la historia de la biblioteca [M] — cadena-biblioteca mergeada desde data/historias/cadenas_ejemplo.json vía RUTA_CATALOGO_EJEMPLOS (merge por id, fuente "ejemplos"); corrida end-to-end en test_historias.gd bloque H (Log 2083) <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
124. - [ ] [23] Crear la historia de los jardines [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
125. - [ ] [23] Crear la historia de la plaza [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
126. - [ ] [23] Crear la historia del molino [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
127. - [ ] [23] Crear la historia de la cofradía [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
128. - [ ] [23] Crear historias de 4 ruinas (biblioteca quemada, observatorio, estación, puente) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
129. - [ ] [23] Crear las historias de 6 objetos legendarios (relicto, gema, carta, llave, farol, brújula) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
130. - [ ] [23] Documentar historias de lugares, ruinas y objetos [S] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
131. - [ ] [23] Crear la historia de la familia molinera [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
132. - [ ] [23] Crear la historia de la familia pescadores [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
133. - [ ] [23] Crear la historia de la familia guardas [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
134. - [ ] [23] Crear las historias de 3 comerciantes (rutas y secretos) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
135. - [ ] [23] Documentar historias de familias y comerciantes [S] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
136. - [ ] [23] Crear el evento de siembra (M32) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
137. - [ ] [23] Crear el evento de vendimia [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
138. - [ ] [23] Crear el evento de marea [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
139. - [ ] [23] Crear el evento de eclipse [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
140. - [ ] [23] Crear 5 cadenas secretas ocultas [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
141. - [x] [23] Definir el descubrimiento de las ocultas por el mundo [M] — 03-Diseno L58 + ocultas invisibles hasta iniciarse (servicio L71; test bloque E) <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
142. - [ ] [23] Documentar historias estacionales y secretas [S] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
143. - [x] [23] Definir 40+ cadenas de 3-5 pasos con contexto [M] — 03-Diseno catalogo (60 cadenas / 89 slots) + schema contexto>=10 y pasos>=3 <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
144. - [x] [23] Definir el schema de cadena (pasos, recompensa, consecuencia, oculta, postgame) [M] — 03-Diseno esquema + quest_chain.gd + validador <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
145. - [x] [23] Crear 8 misiones de exploración (brújula, fauna, cronitado) [M] — Step-5-WorkBuddy 2026-10-24 (iter. 15, Log 2166): 8 cadenas en data/historias/secundarias.json (51 -> 59) con NPC REALES de data/villagers/ (finneas_zorro, teo_conejo, sofia_buho, aria_ciervo, catalina_oso, olivia_nutria, nico_gato, ramon_tejon) y objetos REALES de data/items/ por campo id (OBJ-HER-016, OBJ-NAT-027, OBJ-REL-004, OBJ-LUZ-015, OBJ-LUZ-013, OBJ-ITE-009, OBJ-HER-004, OBJ-ITE-013); 03-Diseno L39 nombra 3 temas (brújula, fauna M65, cronitar ruinas) y los 5 restantes son extensión declarada (mirador del acantilado, grutas del manantial, playas del sur, sendero del bosque, muelle viejo); integración con M65 FUERA por orden del director (msg 200). Suite bloque T: 543 checks/0 fallos/EXIT 0 x3 + guardián EN ROJO por inyección de runtime (478/2/EXIT 1, medido en el cierre del 2026-10-24). <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
146. - [x] [23] Documentar cadenas y misiones de exploración [S] — Step-5-WorkBuddy 2026-10-24 (iter. 15, Log 2166): documentado en 04-Codigo.md §Iter. 15 (las 8 misiones con NPC/objetos REALES, flags de consecuencia, cobertura de suite y la interpretación declarada de «cronitar ruinas» = fechar las ruinas, 02-Analisis L20). <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
147. - [x] [23] Crear 6 misiones de construcción (puentes, cofradía, plaza, senderos, kiosko, jardín) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md --> **[x] HECHO 2026-10-24 (Step-5-WorkBuddy, iter. 16, Log 2169, msg 204):** los 6 temas con cadena en data/historias/secundarias.json — cofradía/jardines (iter. 6), puente (iter. 7, tema de reparación, consecuencia puente_cruzable) y plaza/senderos/kiosko (3 cadenas que habían aparecido a las 04:04 por corrida cortada, RE-VERIFICADAS: NPC REALES bruno_sapo/nico_gato/pablo_pato de data/villagers/ y objetos REALES OBJ-ITE-002 "Piedra"/gravel "Grava"/OBJ-ITE-001 "Madera" de data/items/ por campo id). Suite test_historias.gd: 6 asserts de conteo reparados (la suite estaba ROJA 6 fallos/543/EXIT 1 con el dato nuevo) + bloque U nuevo = 580 checks / 0 fallos / EXIT 0 x3 + guardián EN ROJO por inyección de runtime (EXIT 1, 544 checks, 2 fallos). L70 (puente, M28) y L73 (compuesta con agricultura) siguen [ ]. M23 = 74/29/2 = 105.
148. - [ ] [23] Definir la reconstrucción del puente (M28) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
149. - [x] [23] Crear 5 misiones de agricultura (invernadero, cruces, variantes) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md --> (Step-5 2026-10-24, iter. 17, Log 2172: 5 cadenas en disco, 62 -> 67; suite bloque V 624/0 x3)
150. - [ ] [23] Definir variantes estacionales de agricultura (M32) [S] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
151. - [x] [23] Documentar misiones de construcción y agricultura [S] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md --> (Step-5 2026-10-24, iter. 17, Log 2172: 04-Codigo sec. Iter. 16 + Iter. 17)
152. - [x] [23] Crear 4 misiones de pesca (peces-trofeo, documentación y suelta) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md --> **[x] HECHO 2026-10-24 (Step-5-WorkBuddy, iter. 18, Log 2173, msg 213):** 4 cadenas en data/historias/secundarias.json — cadena-pesca-trofeos (finneas_zorro «pescador» + OBJ-HER-011 «Caña de oro»), cadena-pesca-documentacion (sofia_buho «bibliotecaria» + OBJ-ART-002 «Pergamino místico»), cadena-pesca-suelta (teo_conejo «herbolario» + OBJ-HER-010 «Caña mejorada»), cadena-pesca-nocturna (extensión declarada; finneas_zorro + OBJ-LUZ-012 «Linterna»). NPC REALES de data/villagers/ (profesiones medidas en los .tres) y objetos REALES de data/items/ por campo id. 03-Diseno L42 nombra 3 temas -> 3 nombrados + 1 de extensión declarada. Suite test_historias.gd bloque W: 691 checks / 0 fallos / EXIT 0 x3 (re-verificada hoy) + guardián EN ROJO por inyección de runtime.
153. - [x] [23] Crear 6 misiones de colección (murales, glifos, sellos, minerales, peces, plantas) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md --> **[x] HECHO 2026-10-24 (Step-5-WorkBuddy, iter. 18, Log 2173, msg 213):** las 6 cadenas del cluster (misma tanda que pesca, 67 -> 77): cadena-coleccion-murales (luna_zorra «artesana» + OBJ-CUA-010 «Obra maestra»), cadena-coleccion-glifos (sofia_buho + OBJ-ART-001 «Estatuilla antigua»), cadena-coleccion-sellos (olivia_nutria «sastra» + OBJ-ART-005 «Joya de la isla»), cadena-coleccion-minerales (ramon_tejon «herrero» + mineral_cobre «Mineral de Cobre»), cadena-coleccion-peces (finneas_zorro + OBJ-ITE-023 «Pescado»), cadena-coleccion-plantas (teo_conejo + OBJ-PLA-004 «Orquídea»). Los 6 temas de 03-Diseno L43, 6/6 con cadena. Título de cadena-coleccion-sellos renombrado a «Los Sellos de los Oficios» por colisión medida con cadena-cofradia (iter. 6). Integración con M36 (museo) = ítem 154, implementación dueño M36.
154. - [x] [23] Definir la integración con M36 (museo) [M] — 03-Diseno L71 <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
155. - [x] [23] Documentar misiones de pesca y colección [S] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md --> **[x] HECHO 2026-10-24 (Step-5-WorkBuddy, iter. 18, Log 2173, msg 213):** pesca y colección documentadas en 04-Codigo.md §Iter. 18 (tabla de las 10 cadenas con NPC/objeto REALES, lugares, consecuencias) y 07-Resultados-Testings.md §Iter. 18.
156. - [x] [23] Crear 6 misiones de amistad (regalo, pesca, paseos, ficción) [M] — 05-Checklist [x] desde iter. 10 (Log 2131); desync del espejo reparada en iter. 13 (Log 2137): las 6 cadenas están en disco <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
157. - [x] [23] Crear 5 misiones de investigación (faro, biblioteca, geodesia, mapas) [M] — Step-5 2026-10-22 (iter. 13, Log 2137): 5 cadenas en data/historias/secundarias.json (40 -> 51) + 04-Codigo.md §Iter. 13 <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
158. - [x] [23] Definir la integración con M36 (mapas) [S] — 02-Analisis L26 + 03-Diseno L45 <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
159. - [x] [23] Documentar misiones de amistad e investigación [S] — Step-5 2026-10-22 (iter. 13, Log 2137): documentado en 04-Codigo.md §Iter. 10 + §Iter. 13 <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
160. - [x] [23] Crear 6 misiones de puzzles (templos 24/25/26, ruinas ocultas) [M] — Step-5 2026-10-22 (iter. 13, Log 2137): 6 cadenas en data/historias/secundarias.json (40 -> 51) + 04-Codigo.md §Iter. 13 <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
161. - [ ] [23] Definir la integración con el framework M24 [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
162. - [x] [23] Documentar misiones de puzzles [S] — Step-5 2026-10-22 (iter. 13, Log 2137): documentado en 04-Codigo.md §Iter. 13 <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
163. - [ ] [23] Crear 20 capítulos de diario (recompensa narrativa) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
164. - [ ] [23] Crear recetas de conversación desbloqueables [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
165. - [ ] [23] Crear 10+ cosméticos (disfraces, sombreros, paletas de casa) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
166. - [x] [23] Definir cero stats en recompensas (cozy) [S] — 03-Diseno L52; schema sin campo stats <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
167. - [x] [23] Definir recompensas únicas no duplicables (M66 cofre) [M] — 03-Diseno L25/L72; validador recompensa presente + titulo unico <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
168. - [ ] [23] Documentar recompensas en el plan-actual [S] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
169. - [x] [23] Definir las 12 consecuencias persistentes [M] — 03-Diseno L53 (las 12 listadas) <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
170. - [ ] [23] Crear la consecuencia "jardín florecido" [S] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
171. - [ ] [23] Crear la consecuencia "taller abierto" [S] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
172. - [ ] [23] Crear la consecuencia "cofradía activa" [S] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
173. - [x] [23] Definir el cambio visual del mundo por consecuencia [M] — 03-Diseno L54 <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
174. - [x] [23] Definir diálogos posteriores por estado de mundo [M] — 03-Diseno L54 + campo dialogo_posterior del schema <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
175. - [ ] [23] Documentar consecuencias y diálogos posteriores [S] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
176. - [x] [23] Definir la activación por pistas del mundo (M22) [S] — 03-Diseno L58 <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
177. - [x] [23] Crear 4 cadenas de postgame [M] — iter. 19 (2026-10-24, Log 2176): las 4 del 03-Diseno L47 en secundarias.json (cadena-epilogo-plaza previa + memorial del Sello + epílogo de la aldea + epílogo del guardián oculta); suite bloque X 742/0/EXIT 0 x3 + guardián EN ROJO sobre el bloque X <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
178. - [x] [23] Definir la variación del postgame según el final de M22 [M] — 03-Diseno L59; gate final_elegido!="" (servicio L103-106) <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
179. - [x] [23] Crear el memorial del Sello post-final [S] — iter. 19 (Log 2176): cadena-memorial-sello (ramon_tejon + piedra_caliza REAL, aria_ciervo; consecuencia memorial_del_sello_erguido) <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
180. - [x] [23] Crear el epílogo de la aldea [S] — iter. 19 (Log 2176): cadena-epilogo-aldea (pablo_pato + clay REAL, catalina_oso; consecuencia epilogo_de_la_aldea_contado) <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
181. - [x] [23] Crear el epílogo del guardián (final secreto) [S] — iter. 19 (Log 2176): cadena-epilogo-guardian, oculta:true (final secreto, patrón ocultas L38; nico_gato + fragmento_ancestral REAL; consecuencia epilogo_del_guardian_cantado) <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
182. - [ ] [23] Integrar con M68 (objetivos y evaluación) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
183. - [ ] [23] Integrar con M32 (estacionales) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
184. - [ ] [23] Integrar con M36 (museo y colección) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
185. - [ ] [23] Integrar con M37 (comerciantes) [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
186. - [x] [23] Documentar la integración en el plan-actual [M] — 03-Diseno integracion + 04-Codigo reglas 3/6 + Notas <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
187. - [ ] [23] Diseñar test E2E de 10 cadenas completas [M] <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
188. - [x] [23] Diseñar test de postgame tras cada final (4 variaciones) [M] — test_historias.gd bloque F, 4 finales M22; 40 checks/0 fallos x3 <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
189. - [x] [23] Diseñar 06-Plan-Testings.md (unitarias + integración) [M] — creado iter. 2 (2026-10-21) <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
190. - [x] [23] Crear 07-Resultados-Testings.md [S] — creado iter. 2 (2026-10-21) <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
191. - [x] [23] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M] — 02-Analisis 49 lin + 03-Diseno 76 lin <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->
192. - [x] [23] Actualizar plan-actual como espejo del estado real [M] — iter. 2: checklist + 04-Codigo + 06/07 <!-- fuente: 23-Historias-Secundarias/05-Checklist.md -->

1. - [x] [109] Definir reutilización de lista vista/detalle en todos [M] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
2. - [x] [109] Definir red/amarillo por campo con error específico [S] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
3. - [x] [109] Definir vistas de misión principal vs secundarias [S] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
4. - [x] [109] Definir detección de recetas inalcanzables [M] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
5. - [x] [109] Definir vista por categoría de crafting [S] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
6. - [x] [109] Definir simulador de mercado rápido [M] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
7. - [x] [109] Definir vista por NPC/vendedor [S] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
8. - [x] [109] Definir vista de calendario anual [S] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
9. - [x] [109] Definir teleport con guardado del punto anterior [S] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
10. - [x] [109] Definir spawn con cantidad y densidad editable [S] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
11. - [x] [109] Definir validación de no duplicar entidades únicas [S] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
12. - [x] [109] Definir copia de estado al portapapeles [S] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
13. - [x] [109] Definir export de muestras a CSV [S] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
14. - [x] [109] Definir soporte de herramientas para QA (M102) [S] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
15. - [x] [109] Definir documentación plan-actual actualizada y firmada [S] <!-- fuente: 109-Herramientas-Internas/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2009, msg 082):** definido en `109-Herramientas-Internas/03-Diseno.md` §8 (nuevo, líneas 91-130) y flippeado en su `05-Checklist.md` (120 -> 135/138, conteo por prefijo verificado).
16. - [x] [93] Definir `simulate_economy.gd` con escenarios (rutinario, diligente, minimalista) → KnownIssue no bloqueante DoD: NO implementado; es la brecha princip <!-- fuente: 93-Balance/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2015, msg 084):** diseno verificado HOY en `93-Balance/plan-actual/03-Diseno.md` §2.3 (L74-78): escenarios rutinario (30 min/dia), diligente (2 h/dia), minimalista (1 sesion/semana). Implementacion diferida documentada en el item.
17. - [x] [93] Definir simulación de 60/180/365 días [C] — KnownIssue no bloqueante DoD: ídem O.1; requiere simulate_economy.gd. Design documentado. <!-- fuente: 93-Balance/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Log 2015, msg 084):** §2.3 dice "Simula 60/180/365 dias usando curvas de tiempo real de sesion". Implementacion diferida (idem item 16).
18. - [x] [93] Definir que la simulación corra en CI (M118) [M] — KnownIssue no bloqueante DoD: M118 (CI/CD) tiene cicd_manager; agregar el job cuando simulate_econo <!-- fuente: 93-Balance/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Log 2015, msg 084):** §5 (L140-146) define el gate CI: `validate_balance.gd --check` + `simulate_economy.gd --days 180 --scenario rutinario` en cada PR que toque `data/balance/`, PR bloqueado si falla. Job concreto cuando exista el .gd (deuda conocida).
19. - [x] [93] Definir `balance_report.gd` que genera reporte markdown legible [M] — **degradado 2026-10-16 (barrido agnes 622 + flip GLM-5.3 Flash-Director): archiv <!-- fuente: 93-Balance/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Log 2015, msg 084):** cierra la degradacion del 2026-10-16; verificado HOY que `validate_balance.gd` NO genera markdown (grep = 0) ni existe `docs/balance/` -> sin reformulacion posible; definicion vigente §2.4 (L80-81): `docs/balance/reporte.md` con tablas markdown. Implementacion (el .gd) pendiente = deuda conocida.
20. - [x] [36] [M65] Anti-stuck de manada/banco coordinado [M] — KnownIssue no bloqueante DoD: dueño M65; logica basica implementada en behavior.gd. Avanzar con navm <!-- fuente: 36-Fauna/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2018, msg 088):** la cita "behavior.gd" era falsa (0 archivos en disco, medido hoy); la lógica básica vive en el autoload `m65_animal_ai.gd` L159-168 (aborta si `distancia_acumulada > 30 m` y `dist > 0.5`) y los miembros de manada/banco la heredan vía `solicitar_movimiento`. Anti-stuck de grupo coordinado NO existía (lectura completa de pack_logic.gd / school_logic.gd) → **diseñado** en `65-Animales-IA/plan-actual/03-Diseno.md` (sección "Anti-stuck"), implementación diferida a navmesh M65 (KnownIssue no bloqueante). Flip L212: 36-Fauna 227 → 228 [x] / 0 [?] / 0 [ ]. Suites medidas hoy con binario real: `scripts/animales_ia/test_m65.gd` 24 OK y `tests/test_m65.gd` 35 OK, ambas 0 fallos / EXIT 0 / 0 SCRIPT ERROR.
21. - [ ] [50] Verificar presupuesto (instancias/draw calls/VRAM) [M] <!-- fuente: 50-Vegetacion/05-Checklist.md --> — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2022, msg 096):** el spawner usa instanciacion directa de GLB, no MultiMesh (L140). Run medido: 65 instancias vs presupuesto 8.000 del preset medio -> dentro por conteo; draw calls y VRAM por instancia no medibles sin MultiMesh.
22. - [ ] [50] Cada bioma muestra su vegetación característica verificada [M] <!-- fuente: 50-Vegetacion/05-Checklist.md --> — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2022, msg 096):** run real con plan 109 items / 65 instanciadas / 44 omitidas por clamp de agua / 0 sin archivo; inventario por bioma individual no levantado del run (solo totales).
23. - [x] [50] Escena pivote sin caída de frame (M61) [M] <!-- fuente: 50-Vegetacion/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2022, msg 096):** run real del juego (ventana) con el spawner activo: FPS 60 estables, sin caida de frame. Capturas cap_50_2026-10-19_05-07-30_poblado-runtime-verificacion.png y cap_50_2026-10-19_05-12-10_fps-60-pivote.png en tools/mcp/godot-mcp/capturas/50-Vegetacion/. Suites headless medidas: 7/5/4 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR.
24. - [ ] [50] Viento determinista con amplitud por bioma/clima [M] <!-- fuente: 50-Vegetacion/05-Checklist.md --> — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2022, msg 096):** no existe viento_shader.gdshader ni shader de viento en disco (find = 0 archivos).
25. - [ ] [50] Estaciones cambian color visualmente en ≤ X s [M] <!-- fuente: 50-Vegetacion/05-Checklist.md --> — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2022, msg 096):** no hay implementacion de estaciones (grep estacion|season en scripts/vegetacion = 0).
26. - [ ] [50] Densidad respeta clamps de terreno [M] <!-- fuente: 50-Vegetacion/05-Checklist.md --> — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2022, msg 096):** clamp de agua verificado en run (44 omitidas por agua, 0 sin archivo); clamps de pendiente/altura no medidos por bioma en el run.
27. - [ ] [50] Costo MultiMesh dentro del presupuesto [M] <!-- fuente: 50-Vegetacion/05-Checklist.md --> — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2022, msg 096):** no hay MultiMesh en el pipeline (instanciacion directa de GLB, ver L140); costo no medible.
28. - [ ] [50] Regeneración por eventos sin romper determinismo [M] <!-- fuente: 50-Vegetacion/05-Checklist.md --> — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2022, msg 096):** no hay regeneracion ni replantado (grep regener|replant|repoblar en scripts/vegetacion = 0).
29. - [x] [50] escalas.json a 1.0 definitivo para los 10 tipos horneados (dejar 1.0 evita doble escala; pendiente edición fina por usuario) [S] <!-- fuente: 50-Vegetacion/05-Checklist.md --> — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2022, msg 096):** editados los 3 multiplicadores fuera de 1.0 en game/isla-ancestral/data/escalas/escalas.json (palmera 4.0->1.0, arbol_frutal 3.0->1.0, hierba_alta 0.8->1.0). Verificado simulando el autoload EscalasGlobales: los 10 tipos horneados renderizan a su altura objetivo exacta (el horneado reescalar_v5.py deja los GLB a su altura final; el multiplicador era doble escala).
30. - [ ] [50] Revisión visual final del usuario (propongo capturas verif3_*) [S] <!-- fuente: 50-Vegetacion/05-Checklist.md --> — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2022, msg 096):** capturas de evidencia entregadas al director (msg 096): cap_50_2026-10-19_05-07-30_poblado-runtime-verificacion.png y cap_50_2026-10-19_05-12-10_fps-60-pivote.png; pendiente de revision del fundador.
31. - [ ] [119] Crear Resource GameVersion con campos major, minor, patch, build, date [M] — **KnownIssue no bloqueante DoD: dueño M59** (deuda de implementación: `Ga — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2023):** verbo de implementacion ("Crear Resource") con funcionalidad AUSENTE en disco (medido hoy: `find game -name game_version.gd` = 0 archivos, 0 `class_name`; `update_manager.gd` = 92 lineas / 10 funciones, sin descarga ni rollback); revertido por Familia A de BUG-070 (P-41, Log 1157); dueno externo M59. NO se re-flippea sin codigo (precedente M50: feature inexistente en disco = [ ]). <!-- fuente: 119-Actualizaciones/05-Checklist.md -->
32. - [ ] [119] Implementar to_string() para mostrar versión [S] — **KnownIssue no bloqueante DoD: dueño M59** (deuda de implementación: método de `GameVersion` no cr — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2023):** verbo de implementacion ("Implementar metodo") con funcionalidad AUSENTE en disco (medido hoy: `find game -name game_version.gd` = 0 archivos, 0 `class_name`; `update_manager.gd` = 92 lineas / 10 funciones, sin descarga ni rollback); revertido por Familia A de BUG-070 (P-41, Log 1157); dueno externo M59. NO se re-flippea sin codigo (precedente M50: feature inexistente en disco = [ ]). <!-- fuente: 119-Actualizaciones/05-Checklist.md -->
33. - [ ] [119] Implementar is_same_major_minor() para compatibilidad [S] — **KnownIssue no bloqueante DoD: dueño M59** (deuda de implementación: método de `GameVersi — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2023):** verbo de implementacion ("Implementar metodo") con funcionalidad AUSENTE en disco (medido hoy: `find game -name game_version.gd` = 0 archivos, 0 `class_name`; `update_manager.gd` = 92 lineas / 10 funciones, sin descarga ni rollback); revertido por Familia A de BUG-070 (P-41, Log 1157); dueno externo M59. NO se re-flippea sin codigo (precedente M50: feature inexistente en disco = [ ]). <!-- fuente: 119-Actualizaciones/05-Checklist.md -->
34. - [ ] [119] Crear UpdateChecker con check_latest() — **KnownIssue no bloqueante DoD: dueño M96/M118** (deuda de implementación: `UpdateChecker` diseñado en `03-Di — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2023):** verbo de implementacion ("Crear clase") con funcionalidad AUSENTE en disco (medido hoy: `find game -name update_checker.gd` = 0 archivos, 0 `class_name`; `update_manager.gd` = 92 lineas / 10 funciones, sin descarga ni rollback); revertido por Familia A de BUG-070 (P-41, Log 1157); dueno externo M96/M118. NO se re-flippea sin codigo (precedente M50: feature inexistente en disco = [ ]). <!-- fuente: 119-Actualizaciones/05-Checklist.md -->
35. - [ ] [119] Crear UpdateDownloader con download() — **KnownIssue no bloqueante DoD: dueño M96/M118** (deuda de implementación: no existe como clase en disco ni co — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2023):** verbo de implementacion ("Crear clase") con funcionalidad AUSENTE en disco (medido hoy: `find game -name update_downloader.gd` = 0 archivos, 0 `class_name`; `update_manager.gd` = 92 lineas / 10 funciones, sin descarga ni rollback); revertido por Familia A de BUG-070 (P-41, Log 1157); dueno externo M96/M118. NO se re-flippea sin codigo (precedente M50: feature inexistente en disco = [ ]). <!-- fuente: 119-Actualizaciones/05-Checklist.md -->
36. - [ ] [119] Crear SaveMigrator con migrate_save() — **KnownIssue no bloqueante DoD: dueño M59** (deuda de implementación: `SaveMigrator` diseñado en `03-Diseno.md — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2023):** verbo de implementacion ("Crear clase") con funcionalidad AUSENTE en disco (medido hoy: `find game -name save_migrator.gd` = 0 archivos, 0 `class_name`; `update_manager.gd` = 92 lineas / 10 funciones, sin descarga ni rollback); revertido por Familia A de BUG-070 (P-41, Log 1157); dueno externo M59. NO se re-flippea sin codigo (precedente M50: feature inexistente en disco = [ ]). <!-- fuente: 119-Actualizaciones/05-Checklist.md -->
37. - [ ] [119] Crear RollbackManager con restore_previous_version() — **KnownIssue no bloqueante DoD: dueño M107/M59** (deuda de implementación: no existe como clase — **[ ] honesto 2026-10-19 (Step-5-WorkBuddy, Log 2023):** verbo de implementacion ("Crear clase") con funcionalidad AUSENTE en disco (medido hoy: `find game -name rollback_manager.gd` = 0 archivos, 0 `class_name`; `update_manager.gd` = 92 lineas / 10 funciones, sin descarga ni rollback); revertido por Familia A de BUG-070 (P-41, Log 1157); dueno externo M107/M59. NO se re-flippea sin codigo (precedente M50: feature inexistente en disco = [ ]). <!-- fuente: 119-Actualizaciones/05-Checklist.md -->
38. - [x] [119] T-022: diseño de UpdateDownloader — **no documentado** en `04-Codigo.md` ni en `03-Diseno.md` (solo quedaba una llamada `UpdateDownloader.new()` dentr — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2023):** seccion de diseno `### UpdateDownloader (Node)` documentada en `119-Actualizaciones/plan-actual/03-Diseno.md` sec. 3 (L183-225): `download()` / `cancelar()` / `verificar_integridad()`, `DIR_TMP user://updates/tmp/`, resume por `Range`, SHA-256 contra `UpdateInfo.sha256`, 3 reintentos backoff 1/5/15 s, espacio con `DirAccess.get_space_left()`, cancelacion y un download a la vez. Flip L146 del 05-Checklist aplicado con cita real; implementacion de la clase diferida = KnownIssue no bloqueante (dueno M96/M118). Cerraba lo que pedia el QA de atria-dawn-s2 (msg 193): "diseno antes que codigo". <!-- fuente: 119-Actualizaciones/05-Checklist.md -->
39. - [x] [119] T-049 a T-056: diseño de RollbackManager + políticas + UI — **no documentado** en `04-Codigo.md` ni en `03-Diseno.md` (solo quedaba una llamada `Rollb — **[x] HECHO 2026-10-19 (Step-5-WorkBuddy, Log 2023):** seccion de diseno `### RollbackManager (Node)` documentada en `119-Actualizaciones/plan-actual/03-Diseno.md` sec. 3 (L227-268) con las 8 reglas T-049 a T-056 (backup por version, retencion `min_versiones_atras`, disparo automatico/manual, fail-closed por hash, restauracion del save, UI popup+settings, notificacion/registro, re-verificacion post-rollback). Flip L150 del 05-Checklist aplicado con cita real; implementacion de la clase diferida = KnownIssue no bloqueante (dueno M107/M59). <!-- fuente: 119-Actualizaciones/05-Checklist.md -->
40. - [ ] [76] Verificar determinismo local (split no red) [M] — **[ ] honesto: requiere FASE MP implementada (split no existe)** <!-- fuente: 76-Multijugador/05-Checklist.md -->
41. - [ ] [76] Verificar que la invitación nunca expone datos [S] — **[ ] honesto: requiere implementación de invitación (FASE MP)** <!-- fuente: 76-Multijugador/05-Checklist.md -->
42. - [ ] [76] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S] — **ESTADO-PARALELO + Log actualizados; fila GLOBAL entregada al director (msg 55) — él <!-- fuente: 76-Multijugador/05-Checklist.md -->
43. - [ ] [76] Verificar con verificar_checklist.py (sin alertas nuevas) [S] — **Pendiente: fila GLOBAL a aplicar por el director** <!-- fuente: 76-Multijugador/05-Checklist.md -->
44. - [ ] [55] Mantener la estética cozy del proyecto en el diario [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** UI implementada sigue 03-Diseno sec. 5.2/5.3 (diary_layer.gd, 834 lineas); verificacion visual fina = fundador.
45. - [ ] [55] Guardar retrato, relación (M20) y últimos diálogos del personaje [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** save guarda {categoria, estado, favorito, dia} (diary_service.gd L339-348): sin retrato/relacion/dialogos.
46. - [ ] [55] Marcar personaje completado cuando su arco termina (M22) [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** marcar_completado existe (L155) pero ningun puente completa personajes; quest_completed registra en misiones (L102-103).
47. - [ ] [55] Vincular misiones relacionadas del personaje (M23) [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** mecanismo generico refs+navegacion existe (diary_layer.gd L633-661; 3 entradas con refs); falta poblar refs mision<->personaje.
48. - [ ] [55] Vincular POI del mapa (M54) con la entrada [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** island_loaded registra lugar (L105-106) sin POI: no hay vinculo con M54.
49. - [ ] [55] Guardar estado de exploración del lugar [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin campo de exploracion en el save (L339-348).
50. - [ ] [55] Marcar completado al 100% de exploración del lugar [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** idem 681: sin estado de exploracion que completar.
51. - [ ] [55] Mostrar fauna/flora del lugar por avistamientos [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin vinculo lugar->criatura; ESPECIE_AVISTADA sin puente (L90-112).
52. - [ ] [55] Guardar hábitat, dieta y fotografías de la criatura (M56) [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** categoria fotografias = 0 entradas (aviso del validador HOY, M56); save sin habitat/dieta.
53. - [ ] [55] Marcar completado al identificar al 100% la criatura [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin contador de identificacion por criatura.
54. - [ ] [55] Mostrar rareza de la criatura y momento de avistamiento [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** save guarda dia (L346); NO existe campo rareza en el modelo.
55. - [ ] [55] Validar siluetas/iconos contra el bestiario (M46) [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** validate_diary.gd cubre catálogo/i18n/persistencia/rendimiento/encoding, no iconos M46.
56. - [ ] [55] Guardar estación y hábitat de la planta (M29/M33) [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin campos estacion/habitat en entradas de plantas.
57. - [ ] [55] Guardar usos en recetas conocidas (M16) [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin puente M16->planta.
58. - [ ] [55] Mostrar escasez/abundancia estacional [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** no existe escasez/abundancia estacional.
59. - [ ] [55] Validar iconos de hojas contra el catálogo [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** idem 687: sin validacion de iconos de hojas.
60. - [ ] [55] Guardar ubicación, usos y rareza del mineral [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin campos ubicacion/usos/rareza en minerales.
61. - [ ] [55] Vincular mineral con su región [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin vinculo mineral<->region.
62. - [ ] [55] Guardar cantidad conocida en el inventario (M14) [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin integracion con inventario M14.
63. - [ ] [55] Validar iconos de gemas contra el catálogo [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** idem 687: sin validacion de iconos de gemas.
64. - [ ] [55] Desbloquear entrada al aprender la receta [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin puente RECETA_DESBLOQUEADA (L90-112); registro manual/API funciona (test_diario.gd L50).
65. - [ ] [55] Mostrar ingredientes con cantidades y resultado [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** modelo de entrada = {id, titulo, descripcion, refs} (sec. 9): sin ingredientes.
66. - [ ] [55] Marcar completado al fabricar el ítem [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin disparador de fabricacion.
67. - [ ] [55] Vincular receta con su nivel de habilidad (M17) [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin integracion con habilidades M17.
68. - [ ] [55] Guardar pista al leerse (releíble) [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin puente PISTA_LEIDA (M24) en _conectar_eventos (L90-112).
69. - [ ] [55] Marcar pista como resuelta al resolver el puzzle [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin disparador de puzzle resuelto.
70. - [ ] [55] No mostrar la solución en la pista [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** catálogo sin campo solucion: se define cuando M24 lo pida.
71. - [ ] [55] Validar referencias de pistas a puzzles [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** validador exige refs existentes; no valida vinculo pista->puzzle.
72. - [x] [55] Desbloquear entrada al obtener el Sello [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, Log 2032):** puente real prereq_met -> registrar sello (diary_service.gd L96-97); test_diario.gd L64-65; suites HOY: test_diario 38/0, persist 18/0, ui 89/0, perf 26/0, validate 0 fallos; todos EXIT 0.
73. - [ ] [55] Mostrar la secuencia de Sellos en orden [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** catálogo trae 7 sellos en orden narrativo y la UI los lista en ese orden; sin numeral/secuencia explicita.
74. - [ ] [55] Mostrar lore de cada Sello al completarse [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sellos sin descripcion (0 de 7, medido hoy); contenido pendiente de M22/M26.
75. - [ ] [55] Validar iconografía de Sellos (M46) [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** idem 687: sin iconografia de Sellos validada.
76. - [ ] [55] Actualizar estado de la ruina (4 estados) al progresar [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin puente RUIDA_PROGRESADA; estados VISTO/COMPLETADO, no 4 estados.
77. - [ ] [55] Mostrar recompensas obtenidas en la entrada [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin datos de recompensas.
78. - [ ] [55] Marcar completado al restaurar la ruina [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin disparador de restauracion.
79. - [ ] [55] Validar estados contra el catálogo de M25 [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin integracion con catálogo M25.
80. - [ ] [55] Guardar cartas del festival y del correo con fecha [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** puente carta_recibida existe (L111-112) + dia en save (L346); contenido depende de M74.
81. - [ ] [55] Permitir releer cartas y marcarlas como leídas [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** releible via persistencia (test persist 18/18 HOY); leidas = VISTO al registrar.
82. - [ ] [55] Vincular cartas con eventos del calendario (M29) [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin vinculo carta<->evento de calendario.
83. - [ ] [55] Validar remitentes contra NPC (M19) [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** npc_moved_in registra personajes; no valida remitentes contra M19.
84. - [ ] [55] Desbloquear descubrimientos al completar hitos (M71) [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin puente DESCUBRIMIENTO (M71); progreso se emite por registro (L289-295).
85. - [ ] [55] Mostrar misiones activas/completadas con progreso en vivo [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** solo quest_completed (no activas); progreso en vivo via diary.progreso_cambiado (L293).
86. - [ ] [55] Alimentar logros de colección (M72) con el total real [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sec. 3.2 documenta la regla (total real fuera de UI); no hay emision a M72.
87. - [x] [55] Definir filtro por bioma para criaturas/lugares [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, Log 2032):** definido en 03-Diseno.md sec. 10 (nuevo, 2026-10-20): campo bioma + filtro persistido en "ui"; implementacion diferida = KnownIssue.
88. - [x] [55] Diseñar contenido secreto desbloqueable por acción concreta [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, Log 2032):** definido en 03-Diseno.md sec. 11 (nuevo, 2026-10-20): secreta solo en lore + accion reveladora por EventBus + validacion.
89. - [ ] [55] Mostrar "???" SOLO en secciones lore (nunca en colecciones) [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** UI muestra "???" donde la entrada este marcada secreta (L437-440); hoy 0 secreta: sin efecto visible.
90. - [x] [55] Permitir releer pistas, recetas y cartas desde el diario [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, Log 2032):** persistencia M59 round-trip (diary_service.gd L339-376, purga de huerfanas) + test_diario_persist.gd 2 procesos HOY 18/0 EXIT 0.
91. - [ ] [55] Navegar al lugar en el mapa (M54) desde la entrada [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** navegacion interna por refs existe (L646-661); salto al mapa M54 no.
92. - [ ] [55] Dar soporte a plurales [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** DIARY.* sin msgid_plural en es.po/en.po (los 4 son de ITEMS/M68); UI usa _t() sin plural.
93. - [ ] [55] Testear el diario en 3 idiomas sin desbordes de UI [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** suites miden i18n es/en; sin prueba de 3 idiomas ni desbordes.
94. - [ ] [55] Manejar icono faltante con fallback genérico [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin manejo de icono faltante medido en diary_layer.gd (filas = estrella/titulo/estado).
95. - [ ] [55] Probar el diario con Reduce Motion activo (M58) [M] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** sin prueba con Reduce Motion (M58).
96. - [ ] [55] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S] <!-- fuente: 55-Diario-Del-Jugador/05-Checklist.md --> -- **[ ] honesto 2026-10-20 (Step-5-WorkBuddy, Log 2032):** ESTADO-PARALELO + Log 2032 actualizados esta vuelta; sin README en 55-*; fila GLOBAL (67/131) la aplica el director.
97. - [x] [90] Definir culling de objetos fuera de distancia <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
98. - [x] [90] Definir LODs para objetos lejanos (M50) — **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** hay LOD del **terreno**, no de objetos. `scripts/main_ <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
99. - [x] [90] Definir iluminación volumétrica (baja/media: off, alta: on, ultra: alta calidad) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
100. - [x] [90] Definir animación por wind shader <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
101. - [x] [90] Definir interacción con jugador <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
102. - [x] [90] Definir normal map para olas <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
103. - [x] [90] Definir parallax para profundidad <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
104. - [x] [90] Definir caustics para ultra <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
105. - [x] [90] Definir colisión de partículas con world <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
106. - [x] [90] Definir toggle de bloom — **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** el bloom está **activo** en la escena principal (`main_island.tscn` L4 <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
107. - [x] [90] Definir bloom shader para glow <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
108. - [x] [90] Definir threshold para fuentes de luz brillantes <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
109. - [x] [90] Definir motion blur basado en velocidad de cámara <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
110. - [x] [90] Definir más blur cuando la cámara se mueve más rápido <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
111. - [x] [90] Definir desactivado por defecto (causa mareo) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
112. - [x] [90] Definir depth of field basado en distancia de la cámara <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
113. - [x] [90] Definir blur para objetos fuera de foco <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
114. - [x] [90] Definir aperture controla cuánto blur <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
115. - [x] [90] Definir FSR 1.0 (AMD) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
116. - [x] [90] Definir FSR 2.0 (AMD mejorado) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
117. - [x] [90] Definir DLSS (NVIDIA) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
118. - [x] [90] Definir XeSS (Intel) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
119. - [x] [90] Definir detección de GPU y habilitación correspondiente <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
120. - [x] [90] Definir detección de RAM (OS.get_static_memory_usage()) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
121. - [x] [90] Definir detección de CPU (OS.get_processor_name()) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
122. - [x] [90] Diseñar tamaño de fuente (slider 0.5x a 2x) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
123. - [x] [90] Diseñar alto contraste (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
124. - [x] [90] Diseñar reducción de motion blur (opción para reducir mareo) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
125. - [x] [90] Diseñar reducción de bloom (opción para reducir distracción visual) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
126. - [x] [90] Diseñar aplicación en tiempo real <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
127. - [x] [90] Diseñar FPS counter (opcional, en debug) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
128. - [x] [90] Diseñar profiling de GPU (opcional, en debug) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
129. - [x] [90] Diseñar monitoreo de uso de GPU y RAM (opcional, en debug) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
130. - [x] [90] Diseñar FPS counter visible en debug (M110) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
131. - [x] [90] Diseñar profiling visible en debug (M110) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
132. - [x] [90] Diseñar monitoreo visible en debug (M110) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
133. - [x] [90] Diseñar controles para resolución (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
134. - [x] [90] Diseñar controles para pantalla completa (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
135. - [x] [90] Diseñar controles para ventana (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
136. - [x] [90] Diseñar controles para borderless (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
137. - [x] [90] Diseñar controles para VSync (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
138. - [x] [90] Diseñar controles para FPS cap (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
139. - [x] [90] Diseñar controles para escala de resolución (slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
140. - [x] [90] Diseñar controles para upscaling (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
141. - [x] [90] Diseñar controles para calidad de sombras (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
142. - [x] [90] Diseñar controles para calidad de texturas (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
143. - [x] [90] Diseñar controles para distancia de dibujado (slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
144. - [x] [90] Diseñar controles para calidad de efectos (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
145. - [x] [90] Diseñar controles para calidad de vegetación (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
146. - [x] [90] Diseñar controles para calidad de agua (x] Diseñar controles para calidad de partículas (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
147. - [x] [90] Diseñar controles para anti-aliasing (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
148. - [x] [90] Diseñar controles para anisotropic filtering (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
149. - [x] [90] Diseñar controles para post-processing (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
150. - [x] [90] Diseñar controles para bloom (toggle + slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
151. - [x] [90] Diseñar controles para motion blur (toggle + slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
152. - [x] [90] Diseñar controles para depth of field (toggle + slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
153. - [x] [90] Diseñar botón de detección automática <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
154. - [x] [90] Diseñar HardwareDetector <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
155. - [x] [90] Diseñar método detect_hardware() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
156. - [x] [90] Diseñar lógica de recomendación según GPU, RAM, CPU <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
157. - [x] [90] Diseñar método apply_resolution() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
158. - [x] [90] Diseñar método apply_vsync() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
159. - [x] [90] Diseñar método apply_fps_cap() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
160. - [x] [90] Diseñar método apply_anti_aliasing() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
161. - [x] [90] Incluir resolución como objeto {x, y} <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
162. - [x] [90] Diseñar pruebas de legibilidad en 720p <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
163. - [x] [90] Diseñar pruebas de legibilidad en 1080p <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
164. - [x] [90] Diseñar pruebas de legibilidad en 4K <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
165. - [x] [90] Diseñar pruebas de soporte de tildes <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
166. - [x] [90] Diseñar pruebas de soporte de ñ <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
167. - [x] [90] Diseñar pruebas de soporte de símbolos <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
168. - [x] [90] Diseñar pruebas de localización (español, portugués, francés, alemán, italiano, ruso) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
169. - [x] [90] Diseñar pruebas de ajustes de accesibilidad <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
170. - [x] [90] Diseñar pruebas de rendimiento (tiempo de carga) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
171. - [x] [90] Diseñar 06-Plan-Testings.md (APLICA) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
172. - [x] [90] Diseñar tests de ajustes individuales <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).
173. - [x] [90] Diseñar tests de aplicación en tiempo real <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] VERIFICADO 2026-10-20 (Step-5-WorkBuddy, tanda M90):** ya estaba [x] en disco antes de mi tanda (cerrado por agnes-3-flash t6-t13 / step-5-kilocode); verificado por conteo, no re-flippeado.
174. - [x] [90] Diseñar tests de detección automática de hardware <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md --> **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, tanda M90, diseno 03-Diseno.md sec.15 + 06-Plan-Testings.md, Log 2037, msg 108):** verbo "Definir/Disenar" cerrado por diseno documentado; implementacion ausente en disco -> nota honesta en el 05-Checklist (UI = M53; apply_* = contrato sec.15.4; colision particulas/parallax diferidos).


## Registro de la vuelta 2026-10-19 00:40 (tracker 81 sin cambios numericos; RAMA 1: msg 081 procesado + RAMA 2: REPOBLACION V3 items 1-15)

- RAMA 1: el 081 del director (acuse del 079 / item 56 pools en verde) quedo sin respuesta por la renumeracion de las 23:28 (tracker en 81, sin 082 escrito, pool intacto). Procesado y acusado con msg 082. Item 57 (Totales) ya estaba reportado (Log 2003); sigue pendiente el criterio de los '16 Totales' del director.
- RAMA 2: items 1-15 de la REPOBLACION V3 = los 15 `[ ]` reales de 109-Herramientas-Internas/05-Checklist.md (modulo propio). Cerrados con definiciones en 03-Diseno.md seccion 8 (lineas 91-130) + 15 flips con cita real. Conteo medido por prefijo: 135 [x] / 3 [?] / 0 [ ] = 138. Verificado por bytes: 05-Checklist 21.994 B / 289 CRLF / 0 LF sueltos / sin BOM; 03-Diseno 11.625 B / LF puro / sin BOM.
- Trampa de la vuelta: reconteo en modo texto dio 0/0/0 (la lectura con encoding='utf-8' normaliza CRLF); conteo valido por bytes.
- Artefactos: Log 2009 (ASCII puro por bytes, CRLF, sin BOM), msg 082 (UTF-8 sin BOM, LF), pool canal 082 consumido y reexpandido a 083..182 (100 consecutivos), tracker 81, diario y memorias.
- Limites: 0 commits / 0 push / 0 archivos ajenos modificados / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot / 0 auto-sellos 21.8.
- Pendientes del director: fila 46 GLOBAL 120/138 -> 135/138 + ruteo QA 21.8 de M109 (soy autor, no auto-sello).
- Proxima: NN > 81; sin mensaje -> items 16-19 de la REPOBLACION V3 (M93-Balance) u otro de la cola.


## Registro de la vuelta 2026-10-19 01:52 (tracker 82 -> 83; RAMA 1: msg 083 + RAMA 2: items 16-19 M93)

- RAMA 1: msg 083 del director = acuse puro de mi 082 (M109 cerrado iter. 7 = 135/138; los 3 [?] quedan en mi 05) + correccion de su puntero (metodo V3). Acusado con msg 084.
- RAMA 2: items 16-19 REPOBLACION V3 = los 4 `[ ]` de 93-Balance/plan-actual/05-Checklist.md (O.1, O.2, O.5 de simulacion economica + balance_report.gd degradado). Flips [ ] -> [x] con diseno verificado HOY en 03-Diseno.md §2.3 (L74-78), §5 (L140-146) y §2.4 (L80-81). Modulo: 130 -> 134 [x] / 0 [?] / 0 [ ] = 134.
- Deuda NO borrada: implementacion de simulate_economy.gd y balance_report.gd diferida a iter futura M93 + M105, documentada en cada item. Ofrezco revertir los 4 flips; QA 21.8 a rutear por el director (no auto-sello).
- Medido por bytes: 05-Checklist 29.133 -> 30.656 B, CRLF 247 preservados, 3 LF sueltos preexistentes preservados, sin BOM, diff = 5 lineas. Nota historica: QA Hy3 L247 y notas agnes L250 citan 131/3 (foto vieja) - no tocados; Totales L235 actualizado 134/0/0 con re-medida.
- Trampa de la vuelta: el patch aborto 3 veces por sus propias guardas (LF sueltos preexistentes mal exigidos; delta sin restar el prefijo; espacio separador comido que SI se escribio una vez y se reparo verificado por bytes). El assert de delta cuadro por la razon equivocada (4 bytes = 4 espacios): mando el diff.
- Artefactos: Log 2015 (ASCII puro, CRLF, sin BOM, 3.949 B; head medido 2015 -> pool 2016), msg 084 (UTF-8 sin BOM, LF puro, 3.891 B), pool canal 084 consumido y reexpandido a 085..184 (100 consecutivos), tracker 83, diario y memorias.
- Limites: 0 commits / 0 push / 0 archivos ajenos modificados / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot / 0 auto-sellos 21.8.
- Pendientes del director: commit de los 5 paths (05-Checklist M93, Log 2015, BACKLOG, msg 084, tracker); ruteo QA 21.8 M93; fila 46 GLOBAL 120 -> 135/138 + QA M109; "16 Totales"; commit M55; gate ASCII Logs/; gate legal 300 PNG M159.
- Proxima: NN > 83; sin mensaje -> item 20 ([36] anti-stuck de manada) u otro de la cola.
## Registro de la vuelta 2026-10-19 02:05 (tracker 84 -> 85; RAMA 1: msg 085 del director + universo item 57)

- RAMA 1: msg 085 del director (05:05, llego mientras cerraba la vuelta anterior) = acuse de mi 084 con los 4 flips de M93 ACEPTADOS (134/0/0 por bytes, diseno verificado HOY, CRLF preservados - "el estandar que quiero para todas las tandas") + entrega del criterio del item 57: su lista de inconsistentes la genera MEDIDA con verificar_checklist.py (05 reales vs fila del GLOBAL) y la manda en el proximo acuse; mi universo de 3 sigue valido hasta entonces.
- Respondido con msg 086 entregando mi universo del item 57 RE-MEDIDO hoy 02:05: M32-Clima drift [x] 23 / [?] 23 (declara 96/0/25 del 2026-09-12 vs real 119/2/0=121); M30-Reloj drift [x] 12 (declara 107/13 del 2026-09-18 vs real 119/1/0=120); M71-Progresion drift [x] 96 (historico 72 del 2026-09-18 vs real 168/45/0=213).
- Matiz medido: M71 (bloque secundario 168/0/45) y M30 (L252, conteo director msg 184 del 2026-10-13, 119/0/1) tienen ADEMAS un Totales reciente que CUADRA; el drift es solo de la linea historica. Si el criterio es "ninguna linea cuadra", el universo se reduce a M32. Cruzar con la lista medida del director.
- Trampa del item 57 documentada al director: citas de tests dentro de la linea de Totales (M31 "39/0/EXIT 0 x3") fabrican drift fantasma de 86 con un parser de fraccionario suelto; fix: fraccionario solo sin desglose backtick y en los primeros 80 caracteres.
- Housekeeping: el 085 del director entro con el tracker en 84 y consumio el 085 del pool (queda 99 -> reexpandido a 087..186 = 100 consecutivos). Sin colision con mi 084.
- Artefactos: msg 086 (UTF-8 sin BOM, LF puro, 3.255 B), tracker 85, pool 087..186. Limites: 0 commits / 0 push / 0 archivos de modulo modificados / 0 flips / 0 auto-sellos 21.8.
- Proxima: NN > 85; sin mensaje -> item 20 ([36] anti-stuck de manada/banco coordinado) u otro de la cola.

## Registro de la vuelta 2026-10-19 03:20 (tracker 86 -> 87; RAMA 1: msg 087 del director + RAMA 2: item 20)

- RAMA 1: unico mensaje nuevo = **087** (04:55, cruce del item 57). El director declara el item 57 CERRADO con las dos listas como evidencia (la mia: drift de deudores viejos >24 h; la de el: flips del dia post-acuse). Verificado en disco antes de acusar: las 5 filas que sincronizo cuadran hoy (M109 135/138, M125 105/105, M62 127/150, M90 181/249, M93 134/134). Acuse con msg 088.
- RAMA 2: item 20 REPOBLACION V3 = `[36-Fauna] [M65] Anti-stuck de manada/banco coordinado`. HALLAZGO: la cita del item ("logica basica implementada en behavior.gd") era FALSA — no existe `behavior.gd` en el repo (find = 0 archivos). El anti-stuck individual SI existe en el autoload `m65_animal_ai.gd` L159-168 (>30 m acumulados con dist > 0.5 -> aborta + resetea), heredado por los miembros de pack/school via `solicitar_movimiento`. El anti-stuck de grupo coordinado NO existia (pack_logic.gd / school_logic.gd: 0 referencias) -> disenado en `65-Animales-IA/plan-actual/03-Diseno.md` (seccion "Anti-stuck": recalculo de cohesion si el lider aborta, rotacion forzada del grupo sin desplazamiento, migracion anticipada del banco), implementacion diferida a navmesh M65 (KnownIssue no bloqueante).
- Suites medidas HOY con el binario real (no heredadas): `scripts/animales_ia/test_m65.gd` 24 OK / 0 fallos / EXIT 0 / 0 SCRIPT ERROR; `tests/test_m65.gd` (pack/school) 35 OK / 0 fallos / EXIT 0 / 0 SCRIPT ERROR.
- Artefactos: Log 2018 (ASCII puro por bytes, 4.215 B, 77 CRLF, sin BOM; pool head medido 2018 -> 2019), msg 088 (UTF-8 sin BOM, LF puro 79, 4.193 B), 36-Fauna 05-Checklist (227 -> 228 [x] / 0 [?] / 0 [ ]; 18.182 -> 19.065 B, LF puro preservado, sin BOM, diff 3 lineas), M65 03-Diseno.md (1.110 -> 2.805 B, +30 lineas, LF preservado), tracker 87, pool canal 088 consumido y reexpandido a 089..188 (100 consecutivos verificados).
- Limites: 0 commits / 0 push / 0 archivos ajenos modificados / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot / 0 flips ajenos / 0 auto-sellos 21.8. Flip ofrecido a revertir al director.
- Pendientes del director: commit de paths (36-Fauna 05-Checklist, M65 03-Diseno, Log 2018, msg 088, tracker, BACKLOG) + los arrastrados (M55/M93/M109, QA 21.8 M109/M93, "16 Totales", gate ASCII Logs/, gate legal 300 PNG M159).
- Proxima: NN > 87; sin mensaje -> item 21 ([50] verificacion de presupuesto) u otro de la cola.

## Registro de la vuelta 2026-10-19 22:06 (tracker 99 -> 100; RAMA 1: msg 099 + RAMA 2: REPOBLACION V3 items 31-39 M119)

- RAMA 1: el 099 del director llego con el tracker YA en 99 (actualizado por el a las
  21:02) y sin respuesta mia — patron del caso 081 (tracker adelantado). Procesado y
  acusado con msg 100. Contenido: correccion de su tercer incidente de padding
  (renumerrado a 097-PADDED, mi 098 intacto, gate de padding en cada Cron C); tanda M50
  ABIERTA con los 8 [ ] honestos como deuda conocida con dueno/definicion; orden item 31
  (M119) o COLA ACTIVA — GO; commits en la ronda proxima Cron C.
- RAMA 2: items 31-39 REPOBLACION V3 = los 9 [ ] de
  119-Actualizaciones/plan-actual/05-Checklist.md (medido hoy: 109 [x] / 0 [?] / 9 [ ] =
  118, cuadra con la auditoria del 2026-10-15 y con la fila GLOBAL 109/118).
- 2 flips con cita real (L146 T-022 y L150 T-049..T-056): diseno de UpdateDownloader y
  RollbackManager documentado HOY en 03-Diseno.md sec. 3 (secciones nuevas
  `### UpdateDownloader (Node)` L183-225 y `### RollbackManager (Node)` L227-268).
  M119: 109 -> **111 [x] / 0 [?] / 7 [ ] = 118** (Totales L163 actualizados).
- Los 7 [ ] de implementacion (L24/L25/L27/L35/L48/L61/L87) quedan [ ] honestos:
  verbos "Crear/Implementar" con clases AUSENTES en disco (hoy: find = 0 archivos,
  0 class_name, update_manager.gd 92 lineas / 10 funciones sin descarga ni rollback) y
  revertidos por Familia A de BUG-070 (P-41, Log 1157) — no se re-flippean. Duenos
  externos M59/M96/M118/M107.
- Suite test_updates_m119.gd corrida HOY con binario real: 15 checks / 0 fallos /
  EXIT 0, 15 [OK] nominales en la salida. Hallazgo ajeno reportado al director: 3
  SCRIPT ERROR de pause_layer.gd / ui_root.gd al construir la UI al arrancar la escena.
- Medido por bytes: 03-Diseno.md 5.664 -> 9.621 B (LF puro preservado); 04-Codigo.md
  12.245 -> 12.717 B (4 referencias "sin diseno" actualizadas, 0 restantes);
  05-Checklist.md 15.559 -> 18.263 B (CRLF 171 -> 173, 21 LF sueltos preservados, sin BOM).
- Artefactos: Log 2023 (ASCII puro, CRLF, sin BOM), msg 100 (UTF-8 sin BOM, LF puro,
  4.981 B), pool canal 100 consumido y reexpandido a 101..200 (100 consecutivos, 400 B,
  sin BOM), BACKLOG actualizado, tracker 100, diario y memorias.
- Limites: 0 commits / 0 push / 0 archivos ajenos modificados / 0 ediciones a
  CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot / 0 auto-sellos 21.8. Los 2
  flips son de MI modulo (M119) y se ofrecen a revertir.
- Pedidos al director (msg 100): commit de la tanda M119 (3 paths de 119-Actualizaciones
  + Log 2023 + msg 100 + BACKLOG-MASTER + tracker); ruteo QA 21.8 M119; los 3 SCRIPT
  ERROR de pause_layer.gd/ui_root.gd para la tabla de deuda ajena.
- Proxima: NN > 100; sin mensaje -> item 40 ([76] determinismo local) u otro de la COLA ACTIVA.


## Registro de la vuelta 2026-10-20 01:24 (tracker 101 sin cambios numericos; RAMA 1: msg 101 del director + RAMA 2: REPOBLACION V3 items 44-96 M55)

- RAMA 1: unico mensaje nuevo = **101** (2026-10-20 00:15, acuse de mi 100 = tanda M119 items 31-39, GO al riel Actualizaciones). Acuse puro, sin trabajo nuevo. Respondido con msg 102 (UTF-8 sin BOM + LF, 1.191 B). Numeracion: ultimo 101 + 1 = 102, cabeza del pool coincidente; consumido y reexpandido a 103..202 (100 consecutivos verificados). Tracker -> 101.
- RAMA 2: tanda M55-Diario-Del-Jugador items 44-96 = los 53 [ ] reales de 55-Diario-Del-Jugador/plan-actual/05-Checklist.md (medido HOY: 63 [x] / 15 [?] / 53 [ ] = 131). Universo real medido: diary_service.gd (390 lineas, 6 puentes vivos, sin PISTA_LEIDA/RUIDA/DESCUBRIMIENTO/RECETA_DESBLOQUEADA), diary_layer.gd (834 lineas, secreta->"???" L437-440, refs navegables L633-661), diario_catalog.json (14 categorias / 44 entradas / 3 con refs / 0 secreta), es.po+en.po (4 plurales ITEMS+M68, 0 DIARY).
- 4 FLIPS con cita real + suites medidas HOY con binario real (todas 0 fallos / EXIT 0 / 0 SCRIPT ERROR): test_diario.gd 38 checks (36 + 2 sanidad; alcanzabilidad verificada por lectura del flujo L27-33, estas suites NO tienen la guardia de 3 capas), test_diario_persist.gd 18 checks (7 padre + 11 hijo, 2 procesos con SaveManager real), test_diario_ui.gd 89 checks, test_diario_perf_m55.gd 26 checks, validate_diary.gd 0 fallos / 1 aviso (fotografias depende de M56).
- Diseno documentado: 03-Diseno.md +secc. 10 (filtro por bioma: campo bioma + filtro en "ui") y +secc. 11 (contenido secreto desbloqueable: marca secreta solo en lore + accion reveladora por EventBus + validacion), 9.599 -> 11.867 B (LF puro preservado).
- 49 items [ ] honestos con nota medida (verbos de implementacion con funcionalidad ausente o dueno externo M14/M16/M17/M19/M20/M22-M25/M29/M33/M46/M54/M56/M58/M71/M72/M74). 05-Checklist: 54 lineas cambiadas (4 flips + 49 notas + Totales), 25.202 -> 33.426 B, CRLF 230 preservados, sin BOM; conteo final 67 [x] / 15 [?] / 49 [ ] = 131.
- Artefactos: Log 2032 (ASCII puro por bytes, 4.285 B, 82 CRLF, 0 LF sueltos, sin BOM; cabeza del pool medida justo antes = 2032 -> pool 2033), msg 102 + msg 103 (informe de tanda al director), 05-Checklist y 03-Diseno de 55-Diario-Del-Jugador, BACKLOG items 44-96 anotados + este registro.
- Limites: 0 commits / 0 push / 0 archivos ajenos modificados / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot / 0 auto-sellos 21.8. Flips ofrecidos a revertir; QA 21.8 a rutear por el director.
- Pedidos al director (msg 103): commit de los 2 paths de 55-Diario-Del-Jugador + Log 2032; fila GLOBAL 55 (67/131); ruteo QA 21.8. Arrastrados: commits M119/M109/M93/M36/M50/M55 de tandas previas; gate ASCII Logs/; gate legal 300 PNG M159.

## Registro de la vuelta 2026-10-20 02:20 (tracker 104 -> 106; RAMA 1: msgs 105/106 + RAMA 2: tanda M90 97-174)
- **RAMA 1:** dos mensajes nuevos del director. 105 = acuse de mi 102 (fila GLOBAL 119 = 111/118 VERIFICADA en disco, fila 58; GO en mi riel). 106 = acuse de mi 104 (colision 103 corregida: su acuse renombrado a 105, mis 103/104 intactos; mi sugerencia de gate adoptada como invariante; tanda M55 aceptada). Ambos acuses puros -> respondidos con msg 107.
- **Numeracion:** head del pool = 106 pero el msg 106 del director ya existia como archivo -> use 107 = max(archivos)+1 (invariante que el director adopto en 106) y reporte. Pool realineado a 108..207 (100 consecutivos); 106 removido por corresponder a archivo existente. Tracker -> 106. Padding: mi tracker y mi pool estaban sin pad de 3 cifras (el gate no corrio sobre mi carpeta).
- **Discrepancia medida:** scripts/verificar_padding_pools.py (2.103 B, commit a82ef67, worktree limpio) NO contiene la invariante max+1 que el msg 106 dice haber agregado: solo normaliza padding. Reportado al director (msg 107 sec.4).
- **RAMA 2 = tanda M90 (items 97-174):** medido antes 201 [x]/4 [?]/44 [ ] = 249 lineas. 44 flips [ ]->[x] con diseno sec.15 (nueva) + 06-Plan-Testings.md (nuevo). Modulo: 245 [x] / 4 [?] / 0 [ ] = 249 lineas. Los otros 34 items de mi cola ya estaban cerrados por agnes/kilocode -> verificados, no re-flippeados.
- **Evidencia HOY (binario real Godot 4.7.2 console, todas 0 fallos/EXIT 0/0 SCRIPT ERROR):** test_graphics_config.gd 85 checks/6 bloques (guarda 3 capas, CHECKS_MINIMOS 80); test_graphics_config_post_m90.gd 57 checks (sin guardia, no modificada). Nucleo graphics_config.gd 575 lineas; shaders agua_olas/caustics/oceano/wind_vegetacion en disco; UI de ajustes y apply_resolution/vsync/anti_aliasing AUSENTES (grep=0) -> contrato de diseno.
- **HALLAZGOS:** (1) 05-Checklist M90 con 332 secuencias de mojibake por doble codificacion + BOM UTF-8 (preexistente, NO reparado); (2) linea 246 fusiona 2 items por salto de linea perdido ("calidad de agua (x] calidad de particulas"); (3) Totales stale (decia 192/53/4 y otro bloque 248/248/0).
- **Artefactos:** 03-Diseno.md 17.911 -> 28.383 B (LF preservado, sin BOM); 06-Plan-Testings.md 5.642 B (LF); 05-Checklist 45.292 -> 53.520 B (BOM y CRLF preservados: 348 -> 355); ESTADO-PARALELO +entrada (CRLF); msg 107.
- **Limites:** 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot. Flips ofrecidos a revertir.
- **Pedidos al director (msg 108):** fila GLOBAL 90 sync a 245/249 (por linea) o 246/250 (por item, con la fusion de L246); decision sobre el mojibake/BOM del 05-Checklist; commit de los 3 paths de M90.
- **Proxima:** NN > 106; sin mensaje -> siguiente [ ] de la COLA ACTIVA (la seccion M90 quedo en 0 [ ]; proximo modulo de la cola).

## Registro de la vuelta 2026-10-20 03:15-03:43 (tracker 111 -> 118; RAMA 1: msgs 112/114/116/118 + RAMA 2: item 58)
- **RAMA 1:** cuatro mensajes nuevos del director. 112 = acuse de mi 111 (su sync de la fila 90 "aterrizo" en 201/249 y reparo mojibake con fix_encoding.py). 114 = acuse de mi 113 (toma mi correccion: fila resincronizada a 245/249). 116 = acuse de mi 115 (item 58 tomado, 4 flips M90 tomados, **GO para aplicar los 3 flips M11 con medicion de disco**). 118 = acuse de mi 117 (flips M11 tomados). Respondidos con msgs 113, 115 (informe), 117 y 119.
- **Correccion de la fila 90 (medida antes de acusar):** la fila decia 201/249 NO incluia mi tanda M90 (05-Checklist = 245 [x]/4 [?]/0 [ ]). Causa medida: los commits 1abb839/93820f7 ("Se sincronizo M90 a 245/249") NO contenian CHECKLIST-GLOBAL.md (2 paths cada uno). El director tomo la correccion y la fila quedo en 245/249 (verificado por mi en disco, L193). Con los 4 flips de esta vuelta el modulo pasa a 249/249 -> sync final pedido (msg 119). Celdas 7/9 de la fila: SIGUEN con 36 bytes de mojibake multipasada (hex c383c692...c382c29d, 2 bytes de control); gate diagnosticar_mojibake.py HOY: EXIT 1, SUCIO 5, GLOBAL = 156 marcadores (resto ajeno). NO toco el GLOBAL.
- **COLISION DE NUMERACION (5ta familia 092/097/103/106):** mi informe de tanda iba a ser 114 y el director tomo el 114 del pool para su acuse-113 mientras yo lo consumia; reescrito como 115 = max(archivos)+1. En la hora siguiente el director consumio 115/116/117/118 del pool (6 consumos totales). Regla reforzada: verificar max(archivos) Y el head REAL del pool justo antes de escribir; el head almacenado puede tener minutos de retraso.
- **RAMA 2 = item 58 (barrido [?] con dependencia resuelta):** universo 96 modulos con [?], 78 "Con dudas" (892 items), 158 con bloqueante declarado. TRAMPA: el filtro "archivo citado existe" da 143 FALSOS positivos; el criterio valido (artefacto declarado AUSENTE que ahora existe Y cumple la funcion) bajo el universo a 7. **4 flips M90 L90-93** (presets: EFECTOS L68 + presets L131-153 vs texto del item + suites HOY 85/57 checks) -> M90 249 [x]/0 [?]/0 [ ]. **3 flips M11** (GO del director): L45 rango 4 m (autoload interacciones + DEFAULT_RANGO 2.5 + radio 1.5), L98 sprint (player_core_m11.gd L19-30), L71 prompt HUD (mecanismo; M57 pendiente con nota honesta) -> M11 75 -> 78 [x] / 45 [?]. NO resueltos con cita: M10 L18, M156 L192-196 (escenas huerfanas), M131 (0 audios), M27/M31/M124/M94/M55/M109 (duenos externos). El director adopto la trampa como regla de la flota (msg 116).
- **Artefactos:** Log 2040 (ASCII puro por bytes, 6.477 B, CRLF 91, 0 LF sueltos, sin BOM; 1er intento con 6 bytes no-ASCII + LF corregido antes de cerrar), msgs 113/115/117/119, 05-Checklist M90 (52.231 -> 55.915 B, CRLF 355 preservado, diff 4/4) y M11 (33.213 -> 34.324 B, LF puro preservado, diff 3/3), BACKLOG item 58 [x] + reserva 2040 + este registro (LF puro preservado).
- **Limites:** 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot. Flips ofrecidos a revertir. Tracker -> 118; pool del canal 120..219 (100 consecutivos verificados).
- **Pedidos al director (msg 119):** sync final fila 90 a 249/249 + limpieza celdas 7/9; commit de 8 paths (2 checklists, Log 2040, 4 msgs, BACKLOG, tracker); fila 11 del GLOBAL (75 -> 78 [x]); reposicion de cola (REPOBLACION V3 y Bloque C/D agotados).
- **Proxima:** NN > 118; sin mensaje -> item 59 (barrido de citas dead-links en Notas) o lo que ordenes.


## Registro de la vuelta 2026-10-20 06:05 (tracker 121 -> 122; RAMA 1: msg 122 + RAMA 2: standby M119 7 items + barrido Totales)

- **RAMA 1:** unico mensaje nuevo = **122** (2026-10-20 07:00, acuse de mi 121 + direccion de standby: los 7 [ ] de M119 y el barrido estilo agnes por conteo). Acusado con msg 123. Numeracion: max(archivos) 122 + 1 = 123 = cabeza del pool (coincidentes); consumido y reexpandido a 124..223 (100 consecutivos verificados). Tracker -> 122.
- **RAMA 2a - afinado de los 7 [ ] de M119 (Log 2049):** evidencia fresca en disco (0 referencias a `class_name GameVersion/UpdateChecker/UpdateDownloader/SaveMigrator/RollbackManager` en `game/`; `update_manager.gd` 93 lineas / 10 funciones, sin download ni rollback). Corregidas 2 notas OBSOLETAS del checklist (L48/L87 decian "no existe seccion propia en 03-Diseno.md" cuando la tanda Log 2023 SI la agrego: ahora citan L195-237 y L239-280). Alineadas 2 divergencias diseno<->checklist en `03-Diseno.md` (9621 -> 10180 B, LF puro): `is_same_major_minor()` agregada (L70-73) y fachada `check_latest()` (L164-169). **0 flips**: conteo final 111 [x] / 0 [?] / 7 [ ] = 118 (18263 -> 18906 B, 173 CRLF + 21 LF sueltos preservados por linea).
- **RAMA 2b - barrido de Totales por conteo (Log 2049):** universo 167 checklists, 24014 items medidos por prefijo (19511 [x] / 1131 [?] / 3372 [ ]). Tras verificacion linea por linea de los candidatos: **7 drifts reales** (M11 6, M49 10, M50 4, M86 1, M125 1, M126 1, M90 8) + **1 sin Totales vigente** (M151, unica linea tachada con ~~; medido 94/6/67). Sincronizados los 2 que causaron mis tandas: M90 L341 (byte-index; por str-es la 352) 245/0/4 -> 249/0/0 (55915 -> 56115 B, CRLF 355) y M11 L173 75/0/48 -> 78/0/45 (34324 -> 34505 B, LF 335). Los 5 ajenos (M49/M50/M86/M125/M126) + M151 reportados al director SIN tocar. Punto ciego medido: 2992 [ ] sin nota de deuda/dueno en 62 modulos (spec sin auditar, no corrupcion).
- **Trampas nuevas (Log 2049):** (1) el parser de Totales por "primera/ultima linea que matchea" fabrica falsos en los dos sentidos - matchea notas historicas incrustadas dentro de la linea vigente (M109, M59, M32, M113, M83, M31 falsos); la verificacion honesta exigio leer cada candidato; (2) `str.splitlines()` parte tambien en \x0b \x0c U+2028: en M90 la linea de Totales es 352 por str pero 341 por bytes -> buscar por CONTENIDO al splicear por bytes; (3) EOL mixto preservado por linea.
- **Numeracion del director:** cito "items 40-46" para los 7 [ ] de M119; en el BACKLOG son los items 31-37 de la REPOBLACION V3 (discrepancia reportada en msg 123, sustancia trabajada = las lineas 24/25/27/35/48/61/87 del checklist).
- **Artefactos:** Log 2049 (7067 B, ASCII puro por bytes, CRLF 129, sin BOM), msgs 123/125, 03-Diseno M119, 05-Checklist M119/M90/M11, scripts-prueba-temp/sweep_totales_step5.py + sync_totales_step5.py (solo lectura/backup de barrido), este registro (LF puro preservado).
- **Limites:** 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot / 0 marcas aplicadas.
- **Pedidos al director (msg 125):** ruteo de los 5 drifts ajenos + linea nueva de Totales de M151; autorizacion de commit de los paths de esta tanda (03-Diseno + 05-Checklist M119/M90/M11 + Log 2049 + msgs 123/124 + BACKLOG + tracker).
- **Proxima:** NN > 122; sin mensaje -> siguiente de la cola o lo que ordenes.

## Registro de la vuelta 2026-10-21 01:20-01:44 (tracker 125 -> 127; RAMA 1: msg 126 + RAMA 2: item 59)

- **RAMA 1:** unico mensaje nuevo = **126** (2026-10-20 07:25, acuse puro de 125 + toma de la tanda M119 TOMEN: 7 flips + 7 drifts registrados, el director purga/rutea en su proximo Ciclo C; sin trabajo nuevo ordenado). Acuse + informe respondidos con msg **127** (un solo mensaje, por convencion). Numeracion: max(archivos) 126 + 1 = 127 = cabeza del pool (coincidentes); consumido y reexpandido a 128..226 (99 consecutivos verificados por bytes). Tracker -> 127.
- **RAMA 2 = item 59 (barrido de citas dead-links):** cifras medidas y detalle en Log 2060 y en el item 59 de este backlog. Auditor del repo: 1985 logs indexados / 118 rotas / 79 ambiguas / 91 menciones. Barrido estricto GLOBAL: 29 OK-ruta / 251 OK-basename / 22 solo-archivados / 33 AUSENTES. **1 dead-link real: `CONVENCIONES-CODIGO.md` (fila M111, GLOBAL L49)** -> reportado al director para decision; GLOBAL NO tocado. 5 falsos positivos de mi barrido descartados uno por uno contra disco (07-Resultados-Testings.md, fixture_terrain.tscn/.gd, test_datos_m60.gd, patron .tres/.json, //settings/controls.cfg runtime user://).
- **Trampas de la vuelta (documentadas en Log 2060):** (1) auditor Caso B con slug entrecomillado -> tokenizer da 0 tokens -> `all([])` = True -> 1982 candidatos FALSOS de ambigua (familia trampa 92); (2) mi tokenizer NAIVE contaba "21.8"/"V2.5"/"agnes-2.5" como rutas -> fabricaba 960 rotas falsas (descartado, reescrito con extensiones/regex estrictos + exclusiones); (3) discrepancia 97 vs 91 de menciones entre DOS corridas del MISMO auditor: resuelta sin inventar — hy3 escribio los logs 2054-2059 (01:11-01:39 de hoy) en el worktree COMPARTIDO entre ambas corridas y esos logs resolvieron 6 menciones a numeros antes inexistentes (1981 -> 1985 indexados). Mismo script, misma logica: se movio el arbol, no el detector.
- **Artefactos:** Log 2060 (4370 B, ASCII puro por bytes, CRLF 41, sin BOM), msg 127 (UTF-8, LF, sin BOM), item 59 [x] + este registro (LF puro preservado; 945 LF verificado antes y despues).
- **Limites:** 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot. Sigue pendiente la autorizacion de commit de tandas anteriores (8 paths del 2026-10-20) + los de esta tanda.
- **Pedidos al director (msg 127):** decision sobre `CONVENCIONES-CODIGO.md` (fila M111, GLOBAL L49): recrear el doc o corregir la fila; + autorizacion de commit de las tandas acumuladas.
- **Proxima:** NN > 126; si hay mensaje nuevo se procesa en orden ascendente; si no, siguiente [ ] de la COLA ACTIVA (item 60: barrido de modulos sin actividad >24h -> reclamo 21.3 documentado) o lo que ordenes.

## Registro de la vuelta 2026-10-21 02:26 (tracker 127 -> 128; RAMA 1: msg 128 + RAMA 2: items 4/10 del Bloque W)

- **RAMA 1:** unico mensaje nuevo = **128** (acuse puro de mi 127: item 59 preservado y visible en el commit de la ronda del Cron C; "segui RAMA 2"). Acusado con mi msg **129**. Tracker 127 -> 128. Pool del canal: 129 consumido (coincidia con ultimo+1), reeexpandido a 130..229 (100 numeros consecutivos, head 130, sin huecos; max archivo 129).
- **RAMA 2 = items 4 y 10 del Bloque W EJECUTADOS** (era el unico pendiente de la seccion A): captura del inventario con el tema dark. El STALE del 2026-10-17 quedo desactualizado: el tema dark existe en codigo desde 2026-10-18 (`theme_ux.gd` L13, D102). Evidencia en Log 2062: headless 32 items / bolsillo 24/24 / capa visible / EXIT 0 / 0 SCRIPT ERROR; run con ventana 2 capturas 1152x648 err=0; verificacion visual propia (panel navy + borde oro, texto cream, "Slots: 24/24", filtro Mobiliario "Slots: 3/24"). Capturas en `tools/mcp/godot-mcp/capturas/76-Multijugador/` (hash verificado contra el user:// de origen). Preview temporal `scripts/ui/preview_inventario_s5.{gd,tscn}` (patron M53 D102b).
- **Trampa propia:** la 1ra version del preview poblaba el bolsillo empezando por Mobiliario -> la 2da captura (filtro Mobiliario) salia byte identica a la 1ra (mismo sha256). Un filtro que "no cambia nada" puede ser bug del script de prueba: medir el hash, no mirar. Corregido repartiendo 2 items por categoria.
- **Items 5 y 8 verificados:** item 5 = los 4 [ ] honestos de M76 estan documentados (L61/L93 FASE MP + L211/L212 fila GLOBAL); item 8 = 0 marcadores `#esperando` en el checklist de M76 (universo vacio).
- **Artefactos:** Log 2062 (5.607 B, ASCII puro por bytes, CRLF 84, sin BOM), msg 129 (5.154 B, UTF-8 sin BOM, LF 50), 2 capturas + 2 archivos de preview, 4 lineas del Bloque W actualizadas (LF puro preservado).
- **Limites:** 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot ni 05-Checklist ajenos. Los 2 archivos .gd/.tscn son NUEVOS (preview temporal), no tocan logica de produccion.
- **Pedidos al director (msg 129):** visto bueno de los flips 4/10 (ofrecidos a revertir); autorizacion de commit de 6 paths de esta tanda + los 8 del 2026-10-20; **REPOSICION DE COLA (la seccion A quedo sin pendientes salvo el item 9, que depende de tu commit)**.
- **Proxima:** NN > 128; sin mensaje nuevo la cola activa queda vacia -> hace falta reponerla o asignar modulo.

## Registro de la vuelta 2026-10-21 03:50 (tracker 132 -> 132; RAMA 1 acuse 132 + verificacion de casa propia)

- Unico mensaje nuevo = **132** del director (acuse puro de 131: drift M55 "corregido", cola se repone en el ciclo D con GO cuando llegue, trampa del prefijo de linea documentada como metodo estandar). Sin orden de trabajo nueva -> RAMA 2 = verificacion de casa propia con la cola vacia (0 `[ ]` en la seccion de tareas, re-medido).
- HALLAZGO DE LA VUELTA: **el sync de la fila 55 NO aterrizo**. El director anuncia en su 132 "Sincronizado a 67/131"; medido: fila 55 = **63/131** en worktree Y en HEAD; el ultimo commit que toco CHECKLIST-GLOBAL.md es `11e77f3` del 2026-10-20 06:45 (sincronia de la fila 90), ninguno posterior. M55 en disco (conteo por prefijo de linea): 67 [x] / 15 [?] / 49 [ ] = 131. Segunda ocurrencia de la familia "el commit que anuncia el sync no contiene el archivo" (fila 90, 2026-10-20). Reportado al director con el comando de verificacion (`git show HEAD:CHECKLIST-GLOBAL.md | grep -a "^| 55 |"`, el `-a` obligatorio por el byte NUL del archivo).
- Casa propia (6 modulos, disco vs GLOBAL): OK M109 135/138, M31 125/169, M76 126/130, M94 83/138, M140 100/124; DRIFT M55 67/131 vs 63/131 (el de arriba).
- Pendientes re-verificados: CONVENCIONES-CODIGO.md (fila M111) sigue ausente en el arbol y en HEAD (decision del director); las 2 capturas de M76 existen en disco con hash verificado pero `tools/mcp/godot-mcp/` esta cubierto por `.gitignore:109` -> no committeables sin negacion o `add -f`.
- Artefactos: msg **133** (2.985 B, UTF-8 sin BOM, LF puro 43, sin FFFD). Numeracion: 133 = max(archivos)+1 = cabeza del pool; consumido y re-expandido a 134..233 (100 consecutivos verificados, sin huecos; sin BOM).
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot. Tracker -> 132.

## Registro de la vuelta 2026-10-21 05:07 (tracker 133 -> 134; RAMA 1 acuse 134 + casa propia + hallazgo GLOBAL doble-encoding)

- Unico mensaje nuevo = **134** del director (acuse de mi 133: sync de la fila 55 "ATERRIZADO AHORA (verificado en disco)"; standby aceptado hasta el bloque del ciclo D). Acusado con mi msg **135**. Tracker -> 134. Numeracion: 135 = max(archivos)+1 = cabeza del pool; consumido (quedan 136..233, 98 numeros, sin huecos).
- **VERIFICADO EN DISCO (yo mido, el director escribe):** el sync SI aterrizo. Commit aplicador `73da1c3` (2026-10-21 03:56:09): fila 55 = **67/131** en HEAD (blob limpio, LF puro, sin BOM, 199.083 B) y en el worktree. M55 en disco por prefijo de linea: 67 [x] / 15 [?] / 49 [ ] = 131 -> cuadra. La familia "sync anunciado que no aterriza" (fila 90 x2, fila 55 x2) queda **cerrada para la fila 55**.
- HALLAZGO NUEVO DE LA VUELTA: **el `CHECKLIST-GLOBAL.md` del worktree quedo con DOBLE ENCODING y BOM** (sin commitear, mtime 04:41:18, posterior al commit 73da1c3 de las 03:56). Por bytes: worktree 211.316 B / BOM SI / CRLF 225 / emojis 0 (HEAD: 367) / doble-UTF-8 (`C3 83`) 1.591 (HEAD: 148); `git status` = ` M`, `git diff --numstat` = 207/207. **Diff con todo lo no-ASCII eliminado de ambos lados: exactamente 1 linea distinta** = la fila 73 (73-Coleccionables, de agnes, sin commitear). Es decir: 206 de las 207 lineas son SOLO dano de encoding; las cifras ASCII (IDs, marcas, Progreso) sobrevivieron. Viola la secc. 28 y pondria en rojo `verificar_bom.py` sobre el worktree. Reportado al director (msg 135); NO tocado (archivo suyo). Entregadas 2 opciones que preservan lo de agnes: restaurar desde HEAD + re-aplicar la fila 73, o commitear la fila 73 sobre el HEAD limpio.
- Casa propia (6 modulos, disco vs GLOBAL, por prefijo de linea y celda Progreso): **0 drift** - M55 67/15/49=131 vs 67/131; M31 125/44/0=169 vs 125/169; M76 126/0/4=130 vs 126/130; M94 83/55/0=138 vs 83/138; M109 135/3/0=138 vs 135/138; M140 100/0/24=124 vs 100/124.
- TRAMPA PROPIA (descartada antes de reportar): mi 1er barrido leyo la celda 4 del `split('|')` = **Prioridad**, no Progreso (indice 3 sobre `[1:-1]`) -> publico 6 DRIFT falsos (M55 "Baja", M31 "Media"...). Familia trampa 31: un contador con la columna corrida fabrica drift donde no lo hay. Metodo corregido y re-medido.
- Pendientes re-verificados: CONVENCIONES-CODIGO.md (dead-link fila M111) AUSENTE en todo el arbol vivo (find insensible = 0) y en HEAD; fila 111 = 209/209 Completado con QA 21.8 de agnes-3-flash. Las 2 capturas M76 existen con hash verificado pero `tools/mcp/godot-mcp/capturas/` sigue IGNORADA por .gitignore.
- Cola activa: **VACIA** - 11/12 items del Bloque W en `[x]`; el unico sin marca es el item 9 (commit/push de la proxima tanda, requiere autorizacion expresa del director). REPOBLACION V3: 174 items con marca, 0 sin marca. Pedida reposicion / bloque del ciclo D.
- Artefactos: Log **2067** (reservado con head del pool medido JUSTO antes: 2067 = max 2066 + 1; ASCII puro por bytes, CRLF 75, sin BOM, 4.701 B), msg **135** (3.880 B, UTF-8 sin BOM, LF puro 46, sin FFFD), tracker -> 134, pool del canal 135 consumido (quedan 136..233).
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot ni 05-Checklist ajenos. El log 2067 queda untracked hasta que el director lo preserve (trampa 64).

## Registro de la vuelta 2026-10-21 05:20 (tracker 134 -> 136; RAMA 1 acuse 136 + barrido de Totales)
- [x] Mensaje 136 del director contestado con el **137** (canal): confirmado el estándar "yo escribo, vos medís"; el director aplicará fix_encoding al GLOBAL; "Seguí riel".
- [x] Barrido de Totales (pendiente del director "16 incoherentes"): **1 deriva real** = M73-Coleccionables (declara 26/107/2 vs disco 32/2/101). 42 checklists no parseables por la heurística estricta, explicitamente NO contados como limpios.
- [x] Trampa propia documentada: la inversión de etiquetas (Pendientes = `[ ]` vs No-resueltos = `[?]`) estuvo a punto de fabricar 144 derivas falsas; corregido el mapeo antes de publicar.
- [x] Cautelas medidas sobre `fix_encoding.py` entregadas al director: no quita el BOM (usar `verificar_bom.py --fix`); aplicar sobre el worktree para no destruir la fila 73 de agnes.
- [x] Log 2067 extendido con §6 (7.060 B, 0 no-ASCII, CRLF, sin BOM). Consumido el número de canal 137 (head del pool verificado antes).
- Nota de cierre: la inscripción de este registro falló a nivel de shell (heredoc, exit 2) sin daño en los archivos; se re-emite aquí, junto con el registro de las 05:31.

## Registro de la vuelta 2026-10-21 05:31 (tracker 137 -> 138; RAMA 1 acuse 138 + corrección de target)
- [x] Mensaje 138 del director contestado con el **139** (canal).
- [x] Log reservado: **2069** — acuse 138, verificación en disco del GLOBAL y corrección del target post-fix.
- [x] Log reservado: **2070** — cierre de libro: re-emisión de este registro y regularización del consumo 2070.
- [x] Verificado en disco (05:31): worktree GLOBAL 211.433 B / BOM / CRLF 225 / C3 83 = 1.591 / emoji 0 → el doble encoding sigue ÍNTEGRO, nada limpiado aún. HEAD: 199.083 B / sin BOM / LF / C3 83 = 148 / emoji 367. Diff real = 2 filas: **61** (minimax-m3-1-flash, M61 tanda 1, Log 2068) y **73** (agnes-3-flash #889). Fila 55: 67/131.
- [x] **TRAMPA PROPIA corregida**: el target "C3 83 = 0" que di en el mensaje 137 era FALSO. HEAD tiene 148 marcadores preexistentes de mojibake multinivel (45-Arte-3D: 81, 159: 33, 161: 22, 90: 8, 86: 3, 83: 1). Target correcto: C3 83 = 148, emoji F0 9F = 367, sin BOM, LF. Prueba de aceptación: post-fix, diferir de HEAD SOLO en las filas 61 y 73.
- [x] Herramientas inexistentes reportadas al director: "thyroidal" (0 apariciones en el repo salvo su propio mensaje 138) y "verificar_padding.py" (el real es `verificar_padding_pools.py`, que verifica el padding de 3 cifras de los pools de números de todos los canales, NO encoding). El que quita el BOM reescribiendo es `verificar_bom.py --fix`; `fix_encoding_dirigido.py` tiene lista blanca fija de 2 archivos y el GLOBAL no está.
- [x] Numeración: 2068 estaba reclamado por minimax-m3-1-flash en las docs de M61 (reserva 05:20, sin archivo en disco); al reservar ya lo había consumido él por la vía canónica → SIN colisión. Error de procedimiento propio: ejecuté la reserva dos veces esperando que el pool ofreciera 2068 como fugado; consumí 2069 y 2070, ambos con archivo real, nada se quema.
- [x] Tracker dejado en **138** (el commit 3abf415 del director lo había dejado en 137, número de mi propio mensaje; 138 = último mensaje del director procesado). Consumido el 139 del pool de canal (head 140).
- [x] Pendientes: (1) fix del GLOBAL con el target corregido; (2) CONVENCIONES-CODIGO.md (fila M111) ausente del árbol y de HEAD; (3) cola activa vacía, el ítem 9 del Bloque W espera orden de commit del director.
- Límites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot ni 05-Checklist ajenos.

## Registro de la vuelta 2026-10-21 14:49 (tracker 139 -> 140; RAMA 1: msg 140 = GO a fila 90)
- [x] Mensaje 140 del director contestado con el **141** (canal): acuse del target C3 83 = 148 + GO a fila 90 (245/249) tomado como reposición de cola.
- [x] Fila 90 medida: GLOBAL = 245/249 en worktree Y HEAD (path limpio; el cron commiteó el worktree en ce23231). El "201/249" del director es histórico (f5ea88f); el vigente llegó con 11e77f3.
- [x] M90 medido por prefijo de línea: 250 líneas-ítem, **249 [x] / 0 [?] / 0 [ ]** (L359 = nota con marca `[→]`; línea 246 fusionada = 246 [x] / 250 ítems). Totales L352 en sync; `git diff` vs HEAD vacío.
- [x] DRIFT = 4 = mis flips [?] -> [x] de L90-93 (Log 2040, ítem 58), reconocidos por el director en la nota de Totales y ausentes de la fila. Reverificados: `graphics_config.gd` L68 EFECTOS {0.25/0.5/0.85/1.0} + presets L131-153.
- [x] Suites frescas HOY (binario real Godot 4.7.2 console, headless): `test_graphics_config.gd` 85 checks / 0 fallos / 6 bloques / EXIT 0; `test_graphics_config_post_m90.gd` 57 checks / 0 fallos / EXIT 0. 0 SCRIPT ERROR.
- [x] Muestreo 21.8.2.b: mínimo 13 (5% de 249); muestra de 18 = **0 fallas** (17 por resolución automática de artefactos + L158 a mano). NO es sello: M90 lo implementó un frente Step 5 y 21.8.4/21.23 me inhabilitan como verificador propio.
- [x] TRAMPA PROPIA: el 1er muestreador publicaba 17 FALLAS falsas (no resolvía archivos citados sin ruta ni accesos a diccionario tipo `SOMBRAS["alta"]`); corregido el resolver antes de reportar.
- [x] Log **2077** (head del pool medido justo antes = 2077; ASCII puro por bytes, CRLF 94, 0 LF sueltos, sin BOM, 5.853 B). Tracker -> 140. Pool del canal: consumido 141 (head verificado antes = 141 = último+1); quedan 142..240.
- Pedidos al director (msg 141): sync fila 90 a 249/249 + ruteo QA 21.8 externo; autorización de commit de 4 paths; decisión CONVENCIONES-CODIGO.md (fila M111); tanda nueva de cola (el ítem 9 del Bloque W sigue esperando orden de commit).
- Límites: 0 commits / 0 push / 0 flips / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot ni 05-Checklist ajenos.

## Registro de la vuelta 2026-10-21 15:22 (tracker 140 -> 142; RAMA 1: msg 142 + RAMA 2: CONVENCIONES-CODIGO.md + tanda M67)
- [x] Mensaje 142 del director contestado con el **143** (canal). Contenido verificado en disco: (1) fila 90 = 249/249 Completado con sync citando Log 2077 + suites 85/0 y 57/0 (CONFIRMADO, GLOBAL L193); QA 21.8 de M90 ruteado a MiniMax-M3.1-Flash (coincido: §21.23 me inhabilita); (2) commit de mis paths autorizado por CRON C; (3) CONVENCIONES-CODIGO.md: DECISION CREARLA, encargada a mi frente; (4) cola nueva repoblada: 67-Vehiculos (112 [ ]) + 23-Historias-Secundarias (80 [ ]).
- [x] **CONVENCIONES-CODIGO.md CREADO** en `DOCUMENTACION/111-Codigo-De-Calidad/plan-actual/` (ruta canonica; AGENTS §3 prohibe doc nueva en `docs/`). 13.172 B, UTF-8 sin BOM, LF puro 234. Consolidacion de lo existente con fuente por seccion: AGENTS §28 (encoding, 4 lecciones duras, herramientas), GUIA-GODOT/01 (GDScript), GUIA-GODOT/19 (C-01..C-11), convenciones duras del protocolo multiagente y scripts temporales/capturas. Nota honesta: AGENTS §24 documenta stack Unity/C# no vigente (real: Godot 4.7.2/GDScript, verificado en project.godot).
- [x] Numeracion: 7ma colision de la familia 092/097/103/106/124 — el director tomo el 142 de mi pool; mi 143 = max(archivos)+1 = cabeza. Consumido 143; pool re-expandido a 144..243 (100 consecutivos verificados). Tracker -> 142.
- [x] Log reservado: **2079** (head medido justo antes = 2079 = max 2078 + 1) — tanda M67 + doc de convenciones.
- [x] Tanda M67-Vehiculos (reclamo de cola nueva; Notas del Agente iter. 1 / Log 528 leidas antes de tocar). Universo por prefijo de linea: 19 [x] / 112 [ ] / 0 [?] = 131 (cuadra GLOBAL fila 67 = 19/131 y Totales L281).
- [x] Suite con binario real (Godot 4.7.2 console, headless): `test_vehiculos.gd` = 40 checks / 0 fallos / EXIT 0; guardia de 3 capas verificada por lectura (CHECKS_MINIMOS 40, 8 bloques, `_summary` en `call_deferred` aparte).
- [x] HALLAZGO PROPIO corregido: L146 del test tenia un `%` literal dentro del string de formato ("40% vel max: %.2f") -> `ERROR: String formatting error`. El check corria igual (error no fatal) pero el mensaje de fallo salia roto. Fix: `40%%`. Pos-fix: 0 errores de formateo, 40/0, EXIT 0. LF puro del archivo preservado. Propuesta de alta en GUIA-GODOT/01 §19 pendiente de visto bueno del director.
- [x] AJENO reportado, NO tocado: `achievement_service.gd` (M72) editado en el worktree compartido a las 15:13 de hoy (+31/-14 sin commitear) con Python-ismos `False`/`True` (L109/L282/L286) -> 3 SCRIPT ERROR de parse al boot + autoload que no instancia. Los 2 SCRIPT ERROR clasicos (`pause_layer.gd:79` -> `ui_root.gd:50`) siguen ajenos (reportados en M119).
- [x] 6 FLIPS con cita real (ofrecidos a revertir): F.4 L69 (condicional locomotora ya en 01-Requerimientos §3.1 L26 + RF4 L69); M.1 L122 (mejoras definidas en 03-Diseno §3.1 columna Mejoras; implementacion L123-125 sigue [ ]: `vehicle_preset.gd` sin campo de mejoras, medido); W L203 (presets reales en 04-Codigo §6.1, valores medidos de `vehicles.json`); W L204 (flujo streaming: diseño §3.2 + estadio real §6.3); W L205 (condicion locomotora: mecanismo real §6.4, `presets_count()==3` testeado); W L206 (notas del agente §7).
- [x] 04-Codigo.md: +seccion 6 (estadio real: rutas reales, presets reales, API real de VehicleManager, contrato `desplazamiento()`, chunk_target pendiente iter. 2 con M10/M61; `vehicle_streaming.gd` no existe, find = 0) + seccion 7 (Notas del Agente). 5.884 -> 11.125 B, LF puro preservado, diff 70/1.
- [x] 05-Checklist M67: 8 lineas (6 flips + Totales + cabecera). Cabecera original "130/130 completados" FALSA (familia M79-L7) -> corregida a 25/131 medido. Totales 19/112 -> 25/106. 15.933 -> 17.133 B, CRLF puro preservado, diff 8/8. **M67 queda 25 [x] / 106 [ ] / 0 [?] = 131.**
- Pedidos al director (msg 143): linkear CONVENCIONES-CODIGO.md desde la fila 111 del GLOBAL; commit por CRON C de los 7 paths de la tanda; decision sobre `achievement_service.gd` en vuelo; visto bueno para proponer el alta de la variante "% literal" en GUIA-GODOT/01 §19.
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot ni 05-Checklist ajenos.

## Registro de la vuelta 2026-10-21 15:35 (tracker 142 -> 144; RAMA 1: msg 144 = visto bueno GUIA-GODOT + ratificacion M67)
- [x] Mensaje 144 del director contestado con el **145** (canal). Verificado en disco: (1) fila 111 con dead-link CERRADO (nota citando mi doc); (2) mi tanda commiteada por CRON C en `2063233` (15:26:31, 7 paths mios, sin push); (3) `achievement_service.gd` derivado a agnes (msg 905 + commit `51b3a0b`); (4) VISTO BUENO para editar directo GUIA-GODOT/01.
- [x] **M67 tanda 1 RATIFICADA** por el director: los 6 flips con cita quedan; la correccion de la cabecera falsa 130/130 -> 25/131 (familia M79-L7) ratificada como estandar. Proxima tanda declarada: 23-Historias-Secundarias (80 [ ], medir universo + Notas del Agente primero).
- [x] **GUIA-GODOT/01 §19.1 agregado** (edicion directa aditiva autorizada): variante "% literal dentro del string de formato" con mi firma, el par incorrecto/correcto (`40%` -> `40%%`), la diferencia con §19 (NO aborta la funcion: check corre, mensaje de fallo roto) y el caso real (test_vehiculos.gd:146, Log 2079). Medido: 38.690 -> 39.806 B, diff 25/0 insercion pura, LF puro preservado, sin BOM, sin EOL final preservado.
- [x] Numeracion: 8va colision de la familia 092/097/103/106/124 (el director tomo el 144 de mi pool); mi 145 = max(archivos)+1 = cabeza. Consumido 145; pool re-expandido a 146..245 (100 verificados). Tracker -> 144.
- Nota: el registro de la vuelta 143 en este BACKLOG quedo escrito un minuto despues del snapshot del CRON C (15:26:31) -> lo toma el proximo CRON C (paths pendientes de commit: este BACKLOG, GUIA-GODOT/01, msg 145).
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot.

## Registro de la vuelta 2026-10-21 15:40 (tracker 144 -> 146; RAMA 1: msg 146 = GO M23 + primera medicion)
- [x] Mensaje 146 del director contestado con el **147** (canal): §19.1 VALIDADA por el director (insercion pura 25/0, formato de guia correcto); GO confirmado para 23-Historias-Secundarias con mi metodo.
- [x] Medicion M23 (solo lectura): 24 [x] / 80 [ ] / 0 [?] = 104 (cuadra GLOBAL fila 23 = 24/104 y Totales L199; 11.564 B, CRLF puro 203, sin BOM). Regla 21.5: SIN seccion "Notas del Agente"; el registro vigente es la QA cruzado de Hy3 (2026-09-02, L176-199), leida completa. Veredicto heredado 🟡: nucleo data-driven cumplido (servicio + validador + 4 cadenas + test 0 fallos); los 80 [ ] son de producto/contenido (60 cadenas, dialogos M21, cosmeticos, integraciones, E2E). OK NO heredado: la proxima tanda re-corre la suite con binario real.
- [x] Numeracion: 9na colision familia 092/097/103/106/124 (director tomo el 146); mi 147 = max+1 = head. Pool consumido 147, re-expandido a 148..247 (100 verificados). Tracker -> 146.
- Limites: 0 commits / 0 push / 0 auto-sellos / 0 protegidos. Proxima: tanda M23 (re-run de test_historias.gd + clasificacion de los 80 [ ]).

## Registro de la vuelta 2026-10-21 16:35 (tracker 147 -> 148; RAMA 1: msg 148 = plan M23 ratificado -> tanda M23 ejecutada, Log 2082)
- [x] Mensaje 148 del director (acuse de mi 147): plan M23 RATIFICADO tal cual — (1) re-correr test_historias.gd con binario real ANTES de cualquier flip, (2) clasificar los 80 [ ] por verbo y dueno con cita en disco, (3) [ ] honestos donde el dueno sea externo. Contestado con el mensaje 149 (acuse + informe).
- [x] **Re-corrida con binario real (Godot 4.7.2 console, headless):** 3 corridas -> 40 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR. La suite original imprimia "0 fallos" SIN contador: la endureci con la guarda de 3 capas (_check contador, _fin(bloque) + BLOQUES, CHECKS_MINIMOS=40 MEDIDO en verde, _summary en call_deferred SEPARADO). Guardian probado EN ROJO por inyeccion de runtime: EXIT 1 nombrando C/D/E/F/G + "solo 11 checks (minimo 40)", proceso TERMINA (no cuelga); sonda borrada en la misma operacion (0 sondas en el repo).
- [x] **Bloque postgame extendido a los 4 finales de M22** (principal/regresar/guardian/secreto, data/historia/historia_principal.json): bloqueada sin final + abierta tras cada uno, con estado limpio por iteracion.
- [x] **19 flips con cita en disco** (24 -> 43 [x]; 61 [ ] / 0 [?] = 104): 1 "Crear" (cadena-faro) + 18 "Definir/Disenar/Documentar" con cita en 02-Analisis/03-Diseno/implementacion. Criterio aplicado y documentado en 04-Codigo.md (Notas iter. 2). Los 61 [ ] restantes: ~46 de contenido narrativo ausente (secundarias.json = 4 de ~89 cadenas; 0 capitulo-* en M55; 0 cosmeticos) + 11 con dueno externo (M32 x5, M28, M68, M36, M37, M24).
- [x] **Creados** 06-Plan-Testings.md y 07-Resultados-Testings.md (no existian; LF puro, sin BOM, convencion de hermanos).
- [x] **Regresiones de integracion (binario real):** M22 test_historia 41/0, M55 test_diario 0 fallos, M71 test_progresion 83/0, M59 validate_save 16/0 "VALIDACION OK" — todos EXIT 0, 0 SCRIPT ERROR.
- [x] **Hallazgos reportados al director (no tocados):** (1) cadenas_ejemplo.json huerfano (el servicio solo carga secundarias.json); (2) [x] "molino funcionando" SIN apoyo en disco (grep = 0 archivos) — marca no tocada, decision del director; (3) recompensas diario de las cadenas apuntan a capitulo-* inexistentes en el catalogo M55; (4) M24 no se menciona en 02/03 -> su item queda [ ] honesto.
- [x] **Rojo propio corregido:** la 1a version del bloque F resetea el estado de M23 y el bloque G afirmaba un id fijo ya no completada ("round-trip restaura completadas") -> G reescrito para verificar TODAS las completadas del snapshot.
- [x] Numeracion: 149 = max(archivos)+1 = cabeza del pool (148 lo consumio el director); consumido 149, pool re-expandido a 150..249 (100 verificados). Tracker -> 148.
- [x] Artefactos: Log 2082 (ASCII puro por bytes, CRLF, sin BOM), msg 149 (UTF-8 sin BOM, LF), 05-Checklist M23 (43/61/0 = 104, CRLF puro preservado, diff 33/32), 04-Codigo +Notas iter. 2 (8.706 -> 12.630 B), 06/07 nuevos, test_historias.gd endurecido (LF puro), 19 flips espejo en esta cola.
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot. Pedidos al director: sync fila 23 del GLOBAL a 43/104, decision sobre el [x] "molino funcionando", commit de los paths por CRON C, reposicion de cola.
## Registro de la vuelta 2026-10-21 17:14 (tracker 149 -> 151; RAMA 1: msg 151 = acuse 149 + decisiones + GO integrar ejemplos -> tanda M23 iter. 3, Log 2083)
- [x] Mensaje 151 del director: tanda iter. 2 RATIFICADA. Decisiones: (a) fila 23 del GLOBAL sincronizada a 42/104 (verificado en worktree Y HEAD, commit f2d114c, 16:58:47); (b) [x] molino -> [?] APLICADO por el director en 05 L111 con cita de mi Log 2082; (c) CRON C commiteo la tanda (f2d114c, 14 paths, sin push); (d) cola 203 pendientes sin repoblacion, M67 listo para alternar. Contestado con el mensaje 152.
- [x] **Tanda M23 iter. 3 — merge de cadenas_ejemplo.json** (hallazgo 1 con GO a INTEGRAR): RUTA_CATALOGO_EJEMPLOS cableada con merge por id (el principal gana los conflictos; las invalidas se rechazan con sus errores; las validas se anaden con fuente "ejemplos"). MEDIDO en carga: 5 cadenas — +cadena-biblioteca; conflicto cadena-faro (gana la variante del principal); cadena-postgame-plaza RECHAZADA por tipo de paso "construir" desconocido (03-Diseno y TIPOS_PASO solo conocen hablar/explorar/puzzle/entregar; 0 usos del token en scripts/).
- [x] **Suite iter. 3:** bloque A actualizado (5 cadenas + conflicto resuelto + mergeada + rechazada no cargada) + bloque H nuevo (reporte del merge {anadidas, conflictos, rechazadas} + corrida end-to-end de cadena-biblioteca). 3 x verde con binario real: 59 checks / 0 fallos / EXIT 0. CHECKS_MINIMOS 40 -> 59 MEDIDO. Guardian probado EN ROJO con abort de runtime a mitad del bloque H: EXIT 1, "el bloque H NO se ejecuto", "solo 47 checks (minimo 59)"; sonda borrada en la misma operacion (0 sondas).
- [x] **Regresiones medidas (binario real):** M55 test_diario 0 fallos, M55 test_diario_persist 0 fallos, M59 qa_m59_payload_sections RESULTADO=OK.
- [x] **1 flip con cita:** 05 L32 "Crear la historia de la biblioteca" -> [x]. L34 (plaza) sigue [ ] con nota del rechazo. Refresco de mis anotaciones: conteo del bloque de clasificacion y nota del Total -> 43 [x] / 60 [ ] / 1 [?] = 104.
- [x] **2 hallazgos nuevos reportados (no tocados):** (1) el puente M23->M55 degrada en silencio — diary_service.registrar() exige la entrada en el catalogo de M55 y solo existen mision_cadena-faro / mision_cadena-invernadero (NO mision_cadena-biblioteca); (2) el archivo de ejemplos usa claves de consecuencia estado_mundo.* vs flags pelados del principal (la mergeada aplica flag_estado_mundo.biblioteca_iluminada) — no normalizado sin orden.
- [x] **3 anomalias de cierre reportadas (no tocadas):** tracker encontrado en 149 (lo escribio otro proceso al aterrizar el 151) -> dejado en 151; el 05 quedo con EOL LF (el editor del director convirtio el CRLF al aplicar el [?] del molino); mi 150 nunca existio como archivo (el director lo dio "en vuelo") -> salto permanente.
- [x] Numeracion: 11na colision de la familia 092/097/103/106/124 (el director tomo el 151 del pool); mi 152 = el que me indico el director. Pool reeexpandido a 153..252 (100 verificados). Tracker -> 151.
- [x] Artefactos: Log 2083 (ASCII puro por bytes, CRLF, sin BOM), msg 152 (UTF-8 sin BOM, LF), 05-Checklist M23 (43/60/1 = 104, LF preservado), 04-Codigo +Notas iter. 3 (12.630 -> 15.376 B), 06/07 actualizados, test_historias.gd iter. 3 + secondary_stories_service.gd (merge).
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot. Pedidos: commit de los paths de la iter. 3 por CRON C; decision sobre el tipo "construir"; entrada mision_cadena-biblioteca en M55; normalizacion de claves estado_mundo.*.

## 2026-10-21 18:25 (GMT-3) - RAMA 1 msg 153 (decisiones 1 y 4) -> normalizacion estado_mundo.* + plaza rechazo persistente (Log 2085, canal 154)

- Tracker 152 -> 153. Msg 153 del director: iter. 3 RATIFICADA + 4 decisiones. (1) Tipo "construir" NO se agrega hoy: cadena-postgame-plaza queda RECHAZADA PERSISTENTE con nota en el 05 + item [?] nuevo (contenido con tipo no soportado, duenos M22/M17); el flip del item de plaza solo cuando el tipo exista o el dato se migre; NO migro datos sin orden. (2) commit iter. 3 por CRON C. (3) mision_cadena-biblioteca en M55 = derivacion vigente. (4) GO a mi: normalizar claves estado_mundo.* (data-only en el fichero de ejemplos + test que afirme ambas cargas consistentes).
- Normalizacion EJECUTADA (data-only): 5 claves peladas en cadenas_ejemplo.json (condicion faro/biblioteca + consecuencia faro/biblioteca/plaza). Direccion MEDIDA, no elegida: el motor aplica la clave de consecuencia LITERAL a WorldState y el principal ya usaba flags pelados. quest_chain.gd L19 (comentario de esquema desactualizado) corregido al esquema canonico.
- Suite: bloque H afirma clave pelada + que la prefija NO se aplica; bloque I nuevo (_test_esquema_consistente, 10 checks) afirma ambas cargas en el mismo esquema (crudo ejemplos/principal + runtime mergeado + flags compartidos con el mismo deletreo). 3x verde 70/0/EXIT 0; piso 59 -> 70 MEDIDO.
- Guardian EN ROJO x2 (ambas terminan): (a) aborto de runtime en bloque I (copia-sonda) -> EXIT 1 nombrando "el bloque I NO se ejecuto" + "solo 61 checks (minimo 70)"; (b) prefijo re-inyectado en el dato -> EXIT 1 con 4 fallos nombrando la clave. Dato restaurado y verificado por sha256.
- TRAMPA PROPIA 1: la 1a inyeccion uso --path relativo equivocado (game/ en vez de game/isla-ancestral/) y dio EXIT 1 por "script not found" = ROJO FALSO que parecia el guardian. Rehecha con el path correcto. TRAMPA PROPIA 2: el bloque I concatenaba ejemplos+principal y contaba cadena-faro (esta en los dos) dos veces -> falso rojo "6 cargadas"; corregido a ids unicos.
- Regresiones: M22 41/0, M55 diario 0, M55 persist 0, M59 16/0, M71 83/0 (todos EXIT 0, 0 SCRIPT ERROR).
- 05-Checklist M23: L34 con la decision del director; +1 [?] "Definir el tipo de paso construir" (duenos M22/M17); Totales L200 estaba DESACTUALIZADA desde iter. 2 (decia 24/80/0) -> sincronizada. M23 = 43 [x] / 60 [ ] / 2 [?] = 105 (medido por prefijo de linea).
- Residual reportado NO tocado: secundarias.json (principal) mantiene 1 condicion con prefijo (cadena-faro p1) - declarativa, 0 consumidores, fuera del GO (era data-only en ejemplos).
- Artefactos: Log 2085, msg 154, cadenas_ejemplo.json, quest_chain.gd (comentario), test_historias.gd, 04-Codigo +iter.4, 05-Checklist, 07-Resultados, este registro. Tracker 153. 0 commits / 0 push / 0 auto-sellos / 0 protegidos tocados.
- Pedidos al director: extender o no el GO a la condicion del principal; entrada mision_cadena-biblioteca en M55 (derivada); commit de los paths por CRON C; reposicion de cola (seccion A sigue con 0 [ ]).

## Registro de vuelta — 2026-10-21 20:01 (GMT-3) — Step-5-WorkBuddy (tanda M67-Vehiculos #2, Log 2089, msg 156)

- **RAMA 1:** tracker 154 -> 155. Unico entrante = **155** del director (acuse puro de mi 154: iter 4 y normalizacion de claves RATIFICADAS, commit `ae07eaa` verificado en disco con mis 8 paths; fila 23 del GLOBAL sincronizada a 43/105 con la nota de calibracion cruzada Beam+director — verificado en worktree; "M67 sigue listo para alternar"). Acusado + informe en msg **156**. Numeracion: 12da colision de la familia 092/097/103/106/124 (el director consumio mi 155); 156 = max(archivos)+1 = cabeza del pool; consumido y re-expandido a 157..256 (100 verificados).
- **RAMA 2 — M67 tanda 2** (GO del msg 142, alternancia ratificada): endureci la suite y cree el validador.
  - `test_vehiculos.gd`: 40 -> **53 checks / 0 fallos / EXIT 0 x3** (binario real). Bloques nuevos `_test_delta_frameindependiente` (6 checks, G4) y `_test_salida_velocidad` (5 checks, S2) + camino real de `atracar()` en `_test_dock_zarpar` (+2): el log `[VEH-DOCK]` NO se ejercitaba (early return "ya docked"). Piso 40 -> 53 MEDIDO.
  - **Guardián EN ROJO** por inyeccion de aborto de runtime (copia-sonda borrada en la misma operacion): EXIT 1, "solo 47 checks (minimo 53)". **Hallazgo:** en Godot 4.7.2 el `SCRIPT ERROR` mata SOLO la funcion del bloque; `_run()` sigue y llama `_fin()`, asi que la capa de bloques NO nombra el aborto intra-funcion — lo detecta el **piso medido**. La capa `_fin` cubre abortos de `_run()`.
  - **Validador nuevo** `scripts/vehiculos/validate_vehicles.gd`: **40 checks / 0 fallos / EXIT 0 x3**; probado en rojo por tamper del catalogo (12.0 -> 13.0 -> EXIT 1 `[FAIL] barco vel max 12 (§3.1)`), restaurado y verificado por sha256. Reporta sus PENDIENTES (streaming/colisiones/HUD/camara/audio/mejoras/personalizacion/baul) en vez de validarlos.
  - Sonda de valores exactos (v30 = v60 = 6.000000; desplazamiento 6.100000 vs 6.050001 m sobre el integral 6 m): borrada en la misma operacion, 0 probes en el arbol.
  - **3 flips con cita:** G4 (L78), S2 (L171), V4 logs VEH-* (L198: [VEH-ENTER] x14 / [VEH-EXIT] x14 / [VEH-DOCK] x1, 0 errores propios; el unico ERROR del boot es ajeno — singleton AnimationService). M67 = **28 [x] / 103 [ ] / 0 [?] = 131** (prefijo de linea; Totales y cabecera sincronizados).
  - **4 notas honestas** en `[ ]` que siguen: D2/I3 (techo de altitud: sin fisica vertical en el controller), J2 (entrada "en superficie" sin nodos 3D), T5 (avisos sin claves M87). **V1 (`validate_vehicles.gd`) queda `[ ]` a proposito**: entregable parcial (fisica + catalogo + presupuestos; streaming/colisiones hasta la iter. 2).
  - TRAMPA propia: el 1er intento de rojo del validador uso `sed` con sintaxis GNU no soportada -> no tampeo nada y el "ROJO" salio EXIT 0; detectado por el exit code antes de publicar (el sha256 antes/despues coincidia). Rehecho con sustitucion simple.
- **Pendientes director:** sync fila 67 del GLOBAL a 28/131; commit de los paths de la tanda por CRON C; flip visto bueno de los 3 flips (ofrecidos a revertir); veredicto sobre V1 parcial; tanda siguiente (M67 tanda 3 o alternar).
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot ni 05-Checklist ajenos. EOL preservado por archivo (05 M67 CRLF; 04 M67 y este backlog LF).

---

## Vuelta 2026-10-21 21:2x (tracker 159) - RAMA 1 msgs 157/159 + RAMA 2 M67 tanda 3 (Log 2098, canal 160)

- **RAMA 1:** dos entrantes del director. **157** (23:12): M67 t2 RATIFICADA (3 flips visto bueno; fila 67 sync 28/131 verificada en disco; CRON C commiteo la tanda; GO tanda M67 #3 areas V1 o alternar M23). **159** (00:15 del 22, llego durante mi tanda): confirma el GO "con tu plan tal cual" — pero CONTRADICE al 157 sobre L194 (alla "V1 queda [ ]", aca "flip L194"). Mi 158 anuncio el flip L194 cuando el 157 ya lo habia dejado [ ] (inconsistencia mia confesada); mi ejecucion siguio el 157 (no inflar) y pedi decision explicita en el informe. Acuse+informe en msg **160**.
- Numeracion: el director tomo el 159 de mi pool (13ra colision familia 092/097/103/106/124); mi 160 = max(archivos)+1 = cabeza. Pool consumido 160, re-expandido a 161..252 (92 numeros).
- **RAMA 2 — M67 tanda 3** (areas V1, GO 157/159):
  - `test_vehiculos.gd` 53 -> **63 checks / 0 fallos / EXIT 0 x3**: bloque NUEVO `_test_ciclo_barco` (10 checks) end-to-end a pie/docked -> enter -> zarpar -> 2 s a crucero 6 m/s con desplazamiento medido (Vector3) -> atracar camino real [VEH-DOCK] -> salir -> controller liberado. Va al FINAL de `_run()` (trampa M23: no alterar la premisa de otros bloques). Piso 53 -> **63 MEDIDO**.
  - **Guardián EN ROJO por inyeccion de RUNTIME** (`Variant = null`, no parse error): "solo 53 checks (minimo 63)", EXIT 1. Reconfirma: el aborto intra-funcion no lo nombra `_fin`, lo detecta el piso. La 1ra inyeccion (`null.get_name()` directo) fue PARSE ERROR estatico = no probaba el guardian (trampa 27), rehecha. Sonda borrada en la misma operacion (0 probes).
  - Trampa propia nueva: `float(Vector3)` no existe en GDScript -> "Nonexistent 'float' constructor" abortaba mi bloque (58<61, el piso la detecto); corregido acumulando Vector3 como el bloque de delta.
  - `validate_vehicles.gd` 40 -> **46 checks / 0 fallos / EXIT 0 x3** (+bloque ciclo 6 checks).
  - Regresiones HOY (no heredadas): M28 test_viajes.gd EXIT 0 / 0 SCRIPT ERROR; M71 test_progresion.gd 83/0/EXIT 0.
  - **1 FLIP con cita real: L195 (V2 ciclo barco) -> [x].** M67 = **29 [x] / 0 [?] / 102 [ ] = 131** (prefijo; 05 verificado por bytes: 285 CRLF preservados, sin BOM, 0 FFFD, diff 8/8).
  - Notas medidas sin flip: L52 streaming (chunk_target = 0 archivos fuera del validador; M10/M61 no exponen API; vehicle_streaming.gd ausente), L53 colisiones (grep colision: camera/construccion/animales_ia, ninguno de terreno), L194 (decision 157 citada), L196/L197 (eje vertical ausente, iter. 2 visual).
  - 04-Codigo §8 notas tanda 3 + medicion de dependencias. Log **2098** (ASCII puro/CRLF 72/sin BOM, 3.896 B; cabeza del pool medida justo antes = 2098 -> pool 2099).
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos. Flip ofrecido a revertir. Pendientes director: decision L194 (157 vs 159), sync fila 67 a 29/131, commit CRON C de 5 paths, visto bueno V2, tanda siguiente (M23 residual o mas M67).

---

## Vuelta 2026-10-22 00:4x (tracker 161) - M23 iter 5: 6 historias de vecinos (Log 2107, canal 162)

- **Contexto:** msg 161 del director acusa mi 160 y RATIFICA la alternancia M67/M23 con L194 confirmado. Sin entrantes nuevos al abrir: sigo la cola (BACKLOG seccion A / modulo M23). Tanda = 03-Diseno L31, vecinos: de los 8, el farero ya estaba cubierto (cadena-faro, iter 3).
- **Dato:** `secundarias.json` 4 -> **10 cadenas** (6 nuevas): `cadena-panadera` (catalina_oso, cocinera), `cadena-carpintero` (bruno_sapo, carpintero), `cadena-tejedora` (olivia_nutria, sastra), `cadena-pescador` (finneas_zorro, pescador), `cadena-guarda` (nico_gato, guardabosques), `cadena-alquimista` (teo_conejo, herbolario). **Mapeo honesto:** los roles del diseno (panadera/doctora/tejedora/guarda/alquimista) NO existen en disco; 14 villagers medidos, se uso el de rol mas cercano. Entregas: `madera_roble` y `fibra_algodon` son items REALES de data/items/ (300 medidos); `pan_fiesta`/`carrete_nuevo`/`jarabe_lunar` narrativos (patron farol_cargado/semilla_antigua). Consecuencias peladas y unicas.
- **Doctora = [?] con evidencia:** 0 NPC medicos en data/villagers/ (14 medidos). NO se inventa el personaje (asset de otro dueno).
- **Suite:** bloque J nuevo (28 checks): carga, fuente del principal, unicidad de consecuencias y end-to-end de DOS (carpintero con madera_roble real + alquimista con objeto narrativo sembrado). Asserts existentes actualizados por el contenido nuevo (A: 5->11 cadenas; I: principal 4->10, cargadas 5->11). Piso 70 -> **98 MEDIDO en verde** (98/0/EXIT 0, binario real).
- **Guardián EN ROJO por inyeccion de RUNTIME** (`root.call("probe_...")`): EXIT 1 nombrando «el bloque J NO se ejecuto» + «solo 71 checks (minimo 98)». La 1ra inyeccion (`null.metodo()`) fue PARSE ERROR estatico = no probaba el guardian (trampa 27 familia), rehecha. Sonda borrada en la misma operacion (0 probes en el arbol).
- **Regresiones medidas HOY:** M22 41/0 · M55 diario 0 fallos · M55 persist 0 fallos · M59 validate_save 16/0 · M71 progresion 83/0 — todos EXIT 0, 0 SCRIPT ERROR.
- **8 flips con cita en 05-Checklist M23:** L19 panadera, L22 carpintero, L23 tejedora, L24 pescador, L25 guarda, L26 alquimista, L27 documentar -> [x]; L21 doctora -> [?] con evidencia. M23 = **50 [x] / 3 [?] / 52 [ ] = 105** (prefijo; LF preservado, sin BOM). Linea «Totales» (L201) sincronizada (mentia 43/60/2). 04-Codigo.md §Iter. 5 documenta la tanda.
- **TRAMPA Nueva:** el Edit tool NORMALIZA los EOL de un archivo mixto (04-Codigo.md: 141 CRLF / 99 LF -> 0/279). Restaurado desde HEAD por bytes + bloque re-aplicado con LF: `git diff` quita puramente aditivo (1 insercion, 0 borrados). Leccion: en archivos de EOL mixto, escribir por bytes, no con el editor.
- **Nota:** el CRON commiteo mi `secundarias.json` en vuelo (ae96f66, 00:57) — contenido verificado en HEAD (10 cadenas, las 6 nuevas presentes).
- Limites: 0 commits mios / 0 push / 0 auto-sellos 21.8 / 0 protegidos. Flips ofrecidos a revertir. Pendientes director: commit CRON C de los paths de la tanda; decision sobre la doctora (NPC medico ausente); tanda siguiente (resto de M23: lugares L31+, eventos M32, exploracion, etc.).


## Vuelta 2026-10-22 02:2x (tracker 161 -> 163) - RAMA 1 acuse 163 (fila 23 sync VERIFICADA) + RAMA 2 casa propia y cierre de items B (cola activa VACIA)

- **RAMA 1:** unico entrante = 163 del director (acuse de mi 162: M23 iter. 5 RATIFICADA 50/105; fila 23 sincronizada por el; consumio el 163 de MI pool). Acusado con mi **164** (3.003 B, UTF-8 sin BOM + LF puro, verificado por bytes). Numeracion: 12.a colision de la familia 092/097/103/106/124; 164 = max(archivos)+1 con head del pool stale (163). Pool: 163 (director) y 164 (yo) consumidos; reeexpandido a 165..264 (100 consecutivos, 400 B, LF puro, sin BOM).
- **Verificado en disco antes de escribir:** fila 23 del GLOBAL = 50/105 (celda Progreso); M23 = 50 [x]/3 [?]/52 [ ] = 105 por prefijo de linea (05-Checklist M23, 20.738 B, LF puro, sin BOM); secundarias.json = 10 cadenas por id.
- **RAMA 2 (cola activa VACIA: 0 items `[ ]` en la seccion A, 2.a corrida consecutiva):** casa propia de mis 6 modulos, 0 DRIFT — M55 67/15/49=131 vs GLOBAL 67/131; M31 125/44/0=169 vs 125/169; M76 126/0/4=130 vs 126/130; M94 83/55/0=138 vs 83/138; M109 135/3/0=138 vs 135/138; M140 100/0/24=124 vs 100/124.
- **Cierre de 10 items B obsoletos con cita de disco** (seccion B = mi registro historico): acuses de commits de iters viejos (iter 4/8/9/10, lote 1 M109, iter 5 M109) verificados contra HEAD con `git cat-file -e HEAD:<path>`; pendientes de filas del director (31=125/169, 76=126/130 + QA 21.8, 55=67/131 + QA 21.8, informe msg 60) verificados HOY en el worktree.
- **Trampa de alcance:** los msgs del canal citados por numero (msg 27 de iter 10) NO son verificables por nombre: el numero fue reciclado por otro mensaje. Se cerro con nota honesta de 5/6 paths verificados.
- **Pedidos al director (msg 164):** REPOSICION DE COLA ACTIVA (bloqueante de RAMA 2); autorizacion de commit de los paths de M23 iter. 5 (secundarias.json ya commiteado por CRON ae96f66); visto bueno de los flips de iter. 5 (ofrecidos a revertir).
- Limites: 0 commits mios / 0 push / 0 auto-sellos 21.8 / 0 protegidos (CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot intactos).


## Vuelta 2026-10-22 03:0x (tracker 163 -> 165) - RAMA 1 msg 165 (ruteo) + RAMA 2 M67 tanda 4: mejoras por nivel (Log 2114, canal 166)

- **RAMA 1:** entro **165** del director DURANTE la corrida (ratifica mi 164: fila 23 con LF puro y sin BOM correcta, re-expansion del pool correcta; ruteo tras cola vacia con 3 opciones: M67 #4 areas V1 / M23 clusters / nicho propio). Eleccion declarada: **opcion 1 = M67 #4** (default de automatizacion sin atencion; encadena con mi validador 46/0). Consumio el 165 de MI pool; mi 166 = max(archivos)+1. Pool: 165 (director) + 166 (yo) consumidos; reeexpandido a 167..266. Tracker -> 165.
- **Tanda M67 #4 (areas V1 con datos de configuracion, Log 2114):**
  - `vehicle_preset.gd`: +`mejoras` (Dictionary: nivel_max/por_nivel/topes) + `nivel` + API efectiva (velocidad/giro/baul/altitud) + subir_nivel/bajar_nivel. Nivel 0 = base.
  - `vehicle_controller.gd`: `aplicar()` consume valores EFECTIVOS; +flag `rapida` (default TRUE = historico hasta vel_max; false = techo crucero).
  - `vehicles.json`: +bloque mejoras por vehiculo; topes = columna Mejoras de 03-Diseno sec. 3.1 (dirigible altitud 90, submarino baul 16). Nivel 3 medido: barco 15/2.2/18, dirigible 18/90, submarino 10/16, locomotora 26 con giro 0.
  - Suite: +`_test_mejoras` (36 checks) al final de `_run()`. **63 -> 99 checks / 0 fallos / EXIT 0 x3** (binario real). Piso 99 MEDIDO. Guardian EN ROJO por inyeccion de RUNTIME (`Variant = null`): "solo 63 checks (minimo 99)" EXIT 1; sonda borrada, sha256 restaurado (7477acd546dc).
  - Validador: +`_validar_mejoras` (44 checks). **46 -> 90 / 0 fallos / EXIT 0**.
  - Regresiones medidas HOY: M28 test_viajes 0 fallos; M71 test_progresion 83/0.
  - **2 flips con cita:** L43 (crucero/rapida/timon/reversa) y L123 (mejoras velocidad/giro). L124 NO flippeada (compuesta: baul si, faroles M49 externo). M67 = **32 [x] / 0 [?] / 99 [ ] = 131** (prefijo; cabecera y Totales sincronizados; LF puro preservado).
  - 04-Codigo sec. Tanda 4 documentado.
- **TRAMPA NUEVA:** mi 1ra version ponia `rapida=false` por default = cambiaba el techo historico de vel_max a crucero y rompia los checks de clamp existentes. Semantica invertida antes de correr nada. Regla: un flag nuevo que altere un limite existente debe nacer con el default del comportamiento viejo.
- **TRAMPA reconfirmada:** el `encode('ascii')` de un log con `sec.` escrito como U+00A7 falla ANTES de escribir (fallo seguro, 0 bytes a medias); sanitizar a ASCII puro de entrada.
- Pedidos al director (msg 166): sync fila 67 del GLOBAL a 32/131 + visto bueno de los 2 flips; autorizacion de commit (8 paths de la tanda, pools excluidos).
- Limites: 0 commits mios / 0 push / 0 auto-sellos 21.8 / 0 protegidos.

## Vuelta 2026-10-22 04:1x (tracker 166 -> 167) - RAMA 1 acuse 167 (M67 #4 RATIFICADA) + RAMA 2 M23 iter 6: 3 historias de lugares (Log 2117, canal 168)

- **RAMA 1:** entro **167** del director (acuse de mi 166: M67 #4 RATIFICADA — 99 checks / validador 90 / guardian en rojo por inyeccion de runtime; ruteo tras fila 67 con 3 opciones: M67 #5 areas V1 / M23 clusters con duenos claros / nicho propio). Eleccion declarada: **opcion 2 = M23, cluster Lugares** (03-Diseno L31) — la cola activa (seccion A) sigue VACIA y los clusters restantes de M23 tienen dueno claro (= yo). Consumio el 167 de MI pool; mi 168 = cabeza del pool (max(archivos)+1 coincide). Pool: 167 (director) + 168 (yo) consumidos; reeexpandido a 169..268 (100 numeros, LF puro, sin BOM). Tracker -> 167.
- **Tanda M23 iter. 6 (cluster Lugares, Log 2117):**
  - `secundarias.json` 10 -> **13 cadenas** (3 nuevas): `cadena-jardines` (mateo_mapache granjero, entrega `baya_roja` REAL, puzzle `semillas-perdidas`), `cadena-cofradia` (mercedes_lince mercader, `fragmento_ancestral` REAL, `sellos-antiguos`), `cadena-molino` (aria_ciervo trovadora, `fibra_algodon` REAL, `melodia-del-molino`). NPCs e items REALES verificados en disco (`data/villagers/`, `data/items/`); refs de puzzle narrativos = patron `faro-linterna`. Consecuencias peladas y unicas: `jardin_florecido`, `cofradia_activa`, `molino_funcionando` (13 unicas sobre 13 cadenas). De los lugares del diseno, faro (iter. 3), biblioteca (iter. 4), plaza e invernadero ya estaban cubiertos: cluster Lugares COMPLETO.
  - Suite: bloque K nuevo (`_test_lugares`, 31 checks ejecutados) al FINAL de `_run()` con carga, fuente del principal, unicidad de las 3 consecuencias vs las 11 preexistentes, 3 capitulos unicos y end-to-end de las 3. Piso 98 -> **129 checks / 0 fallos / EXIT 0 x4** (binario real).
  - Guardian EN ROJO por inyeccion de runtime en el bloque K (`Variant` -> `Dictionary` tipado): EXIT 1, «el bloque K NO se ejecuto» + «solo 99 checks (minimo 129)». La 1ra version (Dictionary -> Dictionary) NO abortaba: rehecha. Sonda borrada, sha256 del original verificado, 0 sondas.
  - Regresiones medidas HOY: M22 41/0 · M71 progresion 83/0 · M71 flujo-XP 37/0 · M59 rotacion 43/0 (9 bloques, `test_rotate_m59.gd`) · M59 backup-rotations 7/0 · M55 diario 0 fallos.
  - **5 flips con cita:** L31 faro (lugar), L33 jardines, L36 molino, L37 cofradia -> [x]; L112 consecuencia `molino_funcionando` -> [x] (tu msg 151 la habia degradado a [?] por grep=0; ahora `cadena-molino` la aplica end-to-end y el bloque K mide `ws_has`). M23 = **55 [x] / 2 [?] / 48 [ ] = 105** (prefijo). Las DOS lineas de totales estaban desincronizadas (L170 mentia 43/105 desde iter. 2/3; L201 al dia): ambas a 55/48/2.
  - **Hallazgo (dueno M55, no tocado):** el puente M23->M55 degrada en silencio tambien para las 3 nuevas (`not diary.esta_registrada("mision_cadena-jardines")`; `capitulo-*` ausentes del catalogo M55). Mismo residual que `cadena-biblioteca` iter. 3.
  - Documentacion: 04-Codigo §Iter. 6 (+3.656 B), 06-Plan-Testings (bloques 8 -> 11, piso 129, 6 inyecciones en rojo), 07-Resultados (iters 4/5/6 + regresiones + estado del catalogo). Los 4 archivos eran LF puro sin BOM: escritos por bytes, invariante preservada.
- **Autocorreccion:** escribi «siete inyecciones» en 06/07 y el conteo real es SEIS (iter. 2: 1, iter. 3: 1, iter. 4: 2, iter. 5: 1, iter. 6: 1). Corregido en el mismo run antes de cerrar (regla: medir antes de escribir la cifra, aplicada a mis propios documentos).
- Pedidos al director (msg 168): sync fila 23 del GLOBAL a 55/105; visto bueno de los 5 flips (L112 ofrecido a revertir); autorizacion de commit de los paths de la tanda (pools excluidos); REPOSICION DE COLA ACTIVA (seccion A vacia, 2 vueltas seguidas de M23).
- Limites: 0 commits mios / 0 push / 0 auto-sellos 21.8 / 0 protegidos.

## Vuelta 2026-10-22 05:3x (tracker 168 -> 169) - RAMA 1 acuse 169 (M23 iter.6 RATIFICADA) + RAMA 2 M23 iter 7: 4 historias de ruinas (Log 2125, canal 170)

- **RAMA 1:** unico entrante 169 del director (07:40): M23 iter. 6 RATIFICADA — verificado en disco por el (55 [x], fila sync 55/105); mi oferta de revertir flips reconocida como el standard, sin necesidad de revertir; ruteo: seguir con el cluster restante de M23 o el siguiente del diseno (03-Diseno L31). Eleccion declarada: opcion 1 = cluster Ruinas (03-Diseno L33), el siguiente del catalogo tras Lugares. Mi 170 = cabeza del pool (max+1 coincide); 169 (director) + 170 (yo) consumidos; pool reexpandido. Tracker -> 169.
- [x] Log reservado: **2125** — M23 iter. 7, cluster Ruinas. Head medido JUSTO antes: 2125 -> consumido, head nuevo 2126.
- **Tanda M23 iter. 7 — cluster Ruinas del 03-Diseno L33** (biblioteca quemada, observatorio, estacion, puente): `secundarias.json` 13 -> 17 cadenas. NPC REALES de data/villagers/ (sofia_buho bibliotecaria, vera_ardilla farera, ramon_tejon herrero, luna_zorra artesana — los 4 villanos que quedaban sin cadena propia) y objetos REALES de data/items/ (ancient_crystal, iron_ore, piedra_caliza); `tomo_carbonizado` narrativo (0 items de libro en data/items/, medido). Consecuencias peladas unicas: biblioteca_quemada_rescatada, observatorio_alineado, estacion_reparada (del listado L53), puente_cruzable (del listado L53).
- Suite `test_historias.gd`: bloque L nuevo `_test_ruinas` al FINAL de `_run()` (40 checks: 8 carga/fuente + 2 unicidad + 1 diarios + 7x4 end-to-end + 1 puente diario). Piso 129 -> **169 checks / 0 fallos / EXIT 0 x3** (binario real, 0 SCRIPT ERROR). Guardian EN ROJO por inyeccion de runtime sobre el bloque L (Variant -> Dictionary): EXIT 1, «el bloque L NO se ejecuto» + «solo 130 checks (minimo 169)»; sonda borrada, sha256 del original verificado.
- **Correccion propia:** la lista `existentes` del bloque K decia `sendero_bosque_senalizado` (con z); el flag real en datos es `sendero_bosque_senalado` — corregido en la suite y en 07 (la lista no habria detectado una colision con el flag real).
- Regresiones medidas tras la tanda: M22 `test_historia.gd` 41/0 · M71 `test_progresion.gd` 83/0 · M59 `test_rotate_m59.gd` 43/0 (9 bloques) + `test_backup_rotate_return.gd` 4/0 · M55 `test_diario.gd` 0 fallos. Todas EXIT 0, 0 SCRIPT ERROR.
- **1 flip con cita en 05-Checklist M23:** item «Crear historias de 4 ruinas» [ ] -> [x] (Log 2125). M23 = **56 [x] / 47 [ ] / 2 [?] = 105** (prefijo de linea; Totales L201 y la nota de clasificacion sincronizadas — la de Totales mentia desde iter. 2/3 y quedo coherente).
- Documentacion: 04-Codigo §Iter. 7 (+3.691 B), 06-Plan-Testings (bloques 11 -> 12, piso 169, 7 inyecciones en rojo), 07-Resultados (iters + veredicto SIETE, catalogo 18, regresiones actualizadas). Los 5 archivos eran LF puro sin BOM: escritos por bytes, invariante preservada.
- **Hallazgo (dueno M55, no tocado):** el puente M23->M55 degrada en silencio tambien para las 4 nuevas (`not diary.esta_registrada("mision_cadena-puente")`; `capitulo-*` ausentes del catalogo M55). Mismo residual de iters. 3 y 6.
- Pedidos al director (msg 170): sync fila 23 del GLOBAL a 56/105; visto bueno del flip (ofrecido a revertir); autorizacion de commit de los paths de la tanda (pools excluidos); REPOSICION DE COLA ACTIVA (seccion A vacia por 3.ra vuelta — siguiente cluster seria Objetos L34, 6 cadenas).
- Limites: 0 commits mios / 0 push / 0 auto-sellos 21.8 / 0 protegidos.

## Vuelta 2026-10-22 06:3x (tracker 170 -> 171) — RAMA 1 acuse 171 (M23 iter. 7 RATIFICADA) + RAMA 2 M23 iter. 8: cluster Objetos (Log 2127, canal 172)

- RAMA 1: entro 171 del director (M23 iter. 7 RATIFICADA, 56 [x] medidos; fila 23 del GLOBAL sincronizada a 56/105 en el worktree por el director, commit pendiente del CRON; ruteo multiopcion: siguiente cluster de M23 si queda O M67 #-siguiente + re-verificacion de tandas ajenas). Eleccion declarada: opcion 1 = cluster Objetos (03-Diseno L34, checklist L39). Mi 172 = cabeza del pool (max+1 coincide); 171 (director) + 172 (yo) consumidos; head nuevo 173 (173..268). Tracker -> 171.
- Anomalia de protocolo reportada: el tracker quedo en `170\n` escrito por proceso ajeno (yo lo habia dejado en 169 sin newline); lo restauro a 171 con mi convencion (bare number, sin newline/BOM).
- Tanda M23 iter. 8: secundarias.json 17 -> 23 cadenas (relicto, gema, carta, llave, farol, brujula). NPC REALES teo_conejo (herbolario), pablo_pato (ceramista, unico villager sin cadena), catalina_oso (cocinera), bruno_sapo (carpintero), nico_gato (guardabosques), finneas_zorro (pescador); objetos REALES gemstone, OBJ-SEC-004 «Reliquia oculta», OBJ-SEC-001 «Llave oculta», OBJ-LUZ-005 «Farol» (verificados por campo id dentro del .tres); carta_sellada y brujula_desorientada narrativos (0 items de carta/brujula en data/items/, barrido medido). Consecuencias peladas unicas: relicto_devuelto, gema_devuelta, receta_heredada, llave_encontrada, patrulla_nocturna, brujula_calibrada (23/23 unicas).
- Suite: bloque M `_test_objetos` (58 checks) al FINAL de _run(); conteos de A e I actualizados 17/18 -> 23/24 (medidos); piso 169 -> **227 checks / 0 fallos / EXIT 0 x3** (binario real). Guardian EN ROJO por inyeccion runtime (Variant con int -> Dictionary tipado): EXIT 1 «bloque M NO se ejecuto» + «solo 170 checks (minimo 227)»; sonda borrada, sha256 OK.
- Regresiones medidas HOY (no heredadas): M22 41/0 - M71 83/0 - M59 rotate 43/0 (9 bloques) - M59 backup_rotate_return 4/0 - M59 backup_rotations 7/0 - M55 diario 0 fallos. Todas EXIT 0. (Trampa de rutas: los .gd de M59 viven en scripts/saving/; las rutas scripts/rotate/ y scripts/backup/ de logs anteriores NO existen.)
- 2 flips con cita: L39 (6 objetos legendarios) y L40 (documentar lugares/ruinas/objetos, compuesta — con iter. 8 los tres clusters tienen contenido). M23 = 58 [x] / 45 [ ] / 2 [?] = 105 (prefijo verificado).
- Hallazgo (dueno M55, no tocado): el puente M23->M55 degrada en silencio tambien para las 6 nuevas (`not diary.esta_registrada("mision_cadena-brujula")`). Mismo residual de iters. 3, 6 y 7.
- Documentacion: 04-Codigo §Iter. 8 (+3.739 B), 05-Checklist (2 flips + totales), 06-Plan-Testings (bloques 12 -> 13, piso 227, 8 inyecciones en rojo, catalogo vivo 24), 07-Resultados (seccion Iter. 8 + veredicto OCHO, catalogo 23/vivo 24, regresiones). Los 5 archivos eran LF puro sin BOM: escritos por bytes, invariante preservada.
- Log reservado: **2127** (head medido 2127 justo antes -> consumido; head nuevo 2128; otro agente habia consumido 2126).
- Pedidos al director (msg 172): visto bueno de los 2 flips (ofrecidos a revertir); autorizacion de commit de los paths de la tanda (pools excluidos); REPOSICION DE COLA ACTIVA (seccion A vacia por 4.ta vuelta — siguientes clusters: Familias L35, 3 cadenas). Limites: 0 commits mios / 0 push / 0 auto-sellos 21.8 / 0 protegidos.

## Vuelta 2026-10-22 12:4x (tracker 172 -> 173) - RAMA 1 acuse 173 (M23 iter. 8 RATIFICADA) + RAMA 2 M23 iter. 9: cluster Familias + muestra del riel de Beam (Log 2129, canal 174)

- RAMA 1: entro 173 del director (acuse de mi 172: M23 iter. 8 RATIFICADA 58 [x]/45 [ ]; ruteo multi 2+ asincrono: siguiente cluster de M23 + 1 re-verificacion de muestras del riel de Beam; "Tu 173 consumido; proximo 174"). Eleccion declarada: opcion 1 = cluster Familias (03-Diseno L35). Mi 174 = cabeza del pool (max+1 coincide); 173 (director) + 174 (yo) consumidos; head nuevo 175. Tracker -> 173.
- Tanda M23 iter. 9 (cluster Familias del 03-Diseno L35): `secundarias.json` 23 -> 26 cadenas. `cadena-molinera` (mateo_mapache, entrega OBJ-REL-003 REAL, puzzle piedras-de-molienda), `cadena-pescadores` (finneas_zorro, OBJ-HER-014 "Red de captura" REAL, nudo-del-abuelo), `cadena-guardas` (nico_gato, OBJ-LUZ-011 "Candil" REAL, ronda-de-los-guardas). Consecuencias peladas unicas: molienda_familiar_restaurada, red_del_abuelo_reparada, vigilia_de_los_guardas (26/26 unicas). Con esto los clusters del diseno (Vecinos, Lugares, Ruinas, Objetos, Familias) quedan COMPLETOS.
- Suite: bloque N `_test_familias` (31 checks) al FINAL de _run(); conteos de A, I y cargadas 24/23/24 -> 27/26/27 (1a corrida: 3 fallos de conteo, corregidos antes de medir); piso 227 -> **258 checks / 0 fallos / EXIT 0 x3** (binario real). Guardian EN ROJO por inyeccion de runtime (Variant -> Dictionary): EXIT 1 "el bloque N NO se ejecuto" + "solo 228 checks (minimo 258)"; sonda borrada, sha256 del original verificado.
- Regresiones medidas HOY: M22 41/0 - M71 83/0 - M59 rotate 43/0 (9 bloques) - M59 backup_rotate_return 4/0 - M59 backup_rotations 7/0 - M55 diario 0 fallos. Todas EXIT 0.
- 3 flips con cita: L44, L45 y L46 [ ] -> [x] (Log 2129; NPC y objeto REALES verificados en disco). M23 = **61 [x] / 42 [ ] / 2 [?] = 105** (prefijo). TRAMPA de totales reparada: L170 mentia 55/48/2 (iters 7 y 8 nunca se volcaron ahi); las DOS lineas sincronizadas a 61/42/2 contra el prefijo medido.
- Hallazgo (dueno M55, no tocado): el puente M23->M55 degrada en silencio para las 3 nuevas (capitulo-molinera, capitulo-pescadores y capitulo-guardas ausentes del catalogo M55). Mismo residual de iters 3, 6, 7 y 8.
- Muestra del riel de Beam (2.a rama del ruteo, independiente): 17/17 items [x] con secciones 03-Diseno citadas existentes; cobertura de evidencia de los flips de hoy 86/86 (M143) y 68/68 (M147); conteos en 05-Checklist M143 104/111 y M147 133/134. DRIFT de filas GLOBAL (143: 96/111 vs 104/111; 147: 65/134 vs 133/134) reportado para sync del director.
- CRON commiteo la tanda EN VUELO (HEAD 8595186 -> 7c582cb; secundarias.json entro en 31c8288): contenido verificado en HEAD por grep (_test_familias x2, "Iter. 9 - Historias de familias", 61/105 x2, 258 x3, "NUEVE veces"); git diff vs HEAD de mis paths trackeados vacio. HEAD actual 9a4cacb (barridos siguientes ajenos).
- Pendiente de la raiz compartida: los 3 `scripts-prueba_tmp_familias_*.py` de esta corrida quedaron TRACKEADOS en HEAD por barrido del CRON (patron recurrente: tambien siguen versionados d14, t15beam, ternas*, acuse* de vueltas previas). El move a `Obsoletos/raiz-temporales-2026-10-22-step5/` (gitignored, .gitignore:246) borraria 3 paths versionados: NO ejecutado sin visto bueno del director.
- Nota de protocolo: al reservar el log, `reservar_log.py` fallo con OSError [Errno 22] Invalid argument al escribir el pool (lock transitorio de Windows; el archivo quedo intacto, verificado por bytes: empezaba en 2128); reintentado con backoff -> reservo 2129 OK. Ademas otro proceso consumio 2128 entre dos mediciones mias (carrera del pool compartido): reportado al director, no tocado.
- Pedidos al director (msg 174): sync fila 23 del GLOBAL a 61/105 + visto bueno de los 3 flips; sync filas 143/147 del GLOBAL; confirmacion de si Comerciantes L47/L48 es contenido de M23 o tiene dueno M37; nota de protocolo del 2128 y del Errno 22; visto bueno para el move de los 3 temporales trackeados.
- Limites: 0 commits mios / 0 push / 0 auto-sellos 21.8 / 0 protegidos.

## Vuelta 2026-10-22 13:0x (tracker 173 -> 175) - RAMA 1 acuse 175 (M23 iter.9 RATIFICADA + muestra del riel VALIDADA) + ruteo declarado: cluster Amistad (msg 176)

- RAMA 1: entro 175 del director durante el cierre de la vuelta anterior (ratifica M23 iter. 9: 61 [x] medidos; mi muestra independiente del riel de Beam VALIDADA como tercera verificacion de la matriz, coincide con agnes y el director; ruteo multi: siguiente cluster de M23 + otra muestra del riel; "Tu 175 consumido; proximo 176"). Consumio el 175 de MI pool. Mi 176 = max(existentes)+1 (coincide con su "proximo 176"); 176 consumido del pool; head nuevo 177 (177..268). Tracker -> 175.
- Verificacion en disco HOY (no heredada): M23 05-Checklist por prefijo = **61 [x] / 42 [ ] / 2 [?] = 105**, coincide con la ratificacion. **DRIFT:** la fila 23 del GLOBAL sigue en **58/105** (1 ocurrencia de 58/105, 0 de 61/105 en la fila, medido hoy): sync pedido de nuevo al director (msg 176 sec. 2).
- Mapa de los 42 [ ] medido contra el 03-Diseno: los 5 clusters de cadenas (Vecinos/Lugares/Ruinas/Objetos/Familias) estan COMPLETOS (26 cadenas en disco). Sin dueno externo: Amistad (6, L44), Secretas (5, L38), Investigacion (5, L45), Puzzles (6, L46), Comerciantes (3, L36, integracion M37). Con dueno externo (no tocar sin orden): Estacionales (M32), Exploracion fauna (M65), Construccion (M28), Agricultura (M32), Pesca/Coleccion (M36), Postgame (M22), integraciones M24/M68/M36/M37.
- Eleccion declarada (msg 176): **cluster Amistad (6 cadenas)** del 03-Diseno L44 ("regalo favorito, sentadilla de pesca, paseos, ficcion"), sin duenos externos, NPCs reales de data/villagers/. La proxima muestra del riel se entrega junto con esa tanda.
- Artefactos: msg 176 (UTF-8 sin BOM + LF puro, 41 LF, 2.912 B; nombre 176-2026-10-22_12-59-29-Step-5-WorkBuddy-a-glm-5.3-flash-director-acuse-175-ratificadas-ruteo-amistad.md), tracker 175, pool del canal head 177. Log 2129 y msg 174 siguen untracked al cierre (barrido del CRON pendiente).
- Limites: 0 commits mios / 0 push / 0 auto-sellos 21.8 / 0 protegidos.


## Vuelta 2026-10-22 15:36 (tracker 176 -> 177) - RAMA 1 msg 177 (GO cluster Amistad) + RAMA 2 M23 iter. 10: verificacion de cierre + reparacion documental (Log 2131, canal 178)

- RAMA 1: entro 177 del director (GO para el cluster Amistad de M23 como tanda asincrona; fila 23 del GLOBAL sincronizada por el a 61/105, "no la toques vos"; muestra del riel sigue siendo tercera verificacion valida; "Tu 177 consumido; proximo 178"). Mi 178 = cabeza del pool (max+1 coincide); 178 consumido; head nuevo 179. Tracker -> 177.
- HALLAZGO DE ESTADO: la tanda del cluster Amistad ya estaba EJECUTADA en disco por una corrida previa de este automatismo (secundarias.json 26 -> 32, bloque O + piso 316 en la suite, flip L84 [x] -> M23 62 [x] / 41 [ ] / 2 [?] = 105; todo committeado por el CRON), pero esa corrida se corto antes de cerrar: faltaban el Log 2131 (numero consumido del pool, citado por checklist y suite), la seccion Iter. 10 de 04-Codigo (cita fantasma: el checklist la citaba y no existia), los registros de 06/07, el msg al director y la memoria. Decision declarada: NO rehacer la tanda; RE-VERIFICARLA integra y REPARAR lo faltante.
- Verificacion MEDIDA en esta corrida (no heredada): 6 NPC REALES (olivia_nutria, finneas_zorro, sofia_buho, aria_ciervo, mercedes_lince, luna_zorra en data/villagers/, 14 medidos) y 6 objetos REALES por campo id dentro del .tres (OBJ-ROP-005, OBJ-ITE-036, OBJ-NAT-022, OBJ-NAT-023, OBJ-ITE-035, OBJ-NAT-004); 32/32 consecuencias y 31/31 capitulos de diario unicos.
- Suite test_historias.gd con binario real: 316 checks / 0 fallos / EXIT 0 x3, 0 SCRIPT ERROR. Piso 258 -> 316 MEDIDO en verde.
- Guardian EN ROJO re-ejecutado en esta corrida (la nota del checklist afirmaba la inyeccion pero la corrida previa no dejo registro en mi memoria -> no se hereda): inyeccion runtime `Variant` con `Array` -> `Dictionary` al inicio de _test_amistad -> EXIT 1, "el bloque O NO se ejecuto" + "solo 259 checks (minimo 316)"; sonda borrada en la misma operacion, sha256 del original verificado.
- Regresiones medidas HOY (binario real): M22 41/0, M71 83/0, M59 rotate 43/0 (9 bloques) + backup_rotate_return 4/0 + backup_rotations 7/0, M55 0 fallos. Todas EXIT 0.
- Reparacion documental (LF puro, sin BOM, verificado por bytes): 04-Codigo +seccion Iter. 10 (+39/-0, aditivo; repara la cita fantasma); 06 (header iter. 10, bloques 14 -> 15 con fila O, CHECKS_MINIMOS 316 con la cadena, guardian "diez veces" con bullet iter. 10, catalogo vivo 32); 07 (inyeccion iter. 10 en sec. 2, regresiones iter. 10 en sec. 4, catalogo 23 -> 32 con puente M55 de iters 9/10, veredicto NUEVE -> DIEZ y 258 -> 316, seccion 7 nueva); 05 (Total 61/42/2 -> 62/41/2 con nota iter. 10, cabecera Estado iter. 10, nota de clasificacion con el conteo medido). Log 2131 escrito (ASCII puro por bytes, CRLF 123, sin BOM, 7.280 B) ocupando el numero consumido por la corrida previa (head del pool 2133; hueco inocuo reparado).
- DRIFT: fila 23 del GLOBAL en 58/105 en el worktree (1 ocurrencia de 58/105, 0 de 61/105). El director la sincronizo a 61/105 y con el flip de iter. 10 deberia quedar 62/105. Reportado, NO tocada (msg 177: "no la toques vos").
- Hallazgo (dueno M55): el puente M23->M55 degrada en silencio para las 6 nuevas (mision_cadena-regalo-favorito y capitulo-* ausentes del catalogo M55). Mismo patron desde cadena-biblioteca (H). No se inventa contenido de M55.
- Limites: 0 commits propios / 0 push / 0 auto-sellos 21.8 / 0 protegidos. Pedidos (msg 178): sync fila 23 GLOBAL a 62/105; visto bueno del flip L84 (ofrezco revertir); autorizacion de commit de los 4 docs + Log 2131 (datos y suite ya en HEAD por el CRON); visto bueno del move de los 3 scripts-prueba temporales trackeados; REPOSICION DE COLA ACTIVA (seccion A vacia).

### SECCION A - COLA ACTIVA (repoblada por CRON D 2026-10-22 19:00 por orden fundador; fuentes en parentesis = literal del 05 del modulo)
Orden de ejecucion: 1) tandas de M23 ya autorizadas por el director en su 179 (Secretas L38 -> Comerciantes-cadenas L36 (solo cadenas, integracion M37 afuera) -> Puzzles L46 -> Investigacion L45; multi con lo en vuelo) 2) resto de M23 3) M59 4) M21 5) M69. Excluido a proposito: M56 y M93 (dueños activos/agotado). Produce-first, flip al pie, reporte minimo.
- [ ] (23-Historias-Secundarias) - [ ] Crear la historia de la plaza [M] — la variante cadena-postgame-plaza de cadenas_ejemplo.json fue RECHAZADA por el validador en el merge (tipo de paso "construir" desconocido: 03-Diseno y TIPOS_PASO solo conocen hablar/explorar/puzzle/entregar; 0 usos del token en scripts/); cadena-epilogo-plaza del principal ya cubre la plaza post-final (L130). DECISION DEL DIRECTOR (msg 153, 2026-10-21): el rechazo es PERSISTENTE — no se agrega el tipo "construir" hoy (sin respaldo de diseño, mismo patrón que el rechazo de prereq_quest en M105) y el dato NO se migra sin orden. El flip de este ítem se otorga solo cuando el tipo exista o el dato se migre (ver ítem [?] siguiente). Log 2083 + Log 2085.
- [x] (23-Historias-Secundarias) - [x] Crear las historias de 3 comerciantes (rutas y secretos) [M] — Step-5-WorkBuddy 2026-10-23 (iter. 14, Log 2163): ya estaba [x] en el modulo desde la iter. 12 (Log 2135) y la cola quedo stale. En disco: cadena-ruta-del-mercader (mercedes_lince, mercader REAL), cadena-cargamento-de-telas (olivia_nutria) y cadena-secreto-del-yunque (ramon_tejon) en data/historias/secundarias.json, objetos REALES por campo id (OBJ-ITE-052, OBJ-ITE-010, OBJ-TAL-002). Se sincroniza la cola, no el modulo.
- [x] (23-Historias-Secundarias) - [x] Documentar historias de familias y comerciantes [S] — Step-5-WorkBuddy 2026-10-23 (iter. 14, Log 2163): ya estaba [x] en el modulo desde la iter. 12 (Log 2135) — item COMPUESTO (familias + comerciantes), las dos mitades documentadas: 04-Codigo.md §Iter. 9 (familias) y §Iter. 12 (comerciantes). Cola sincronizada.
- [ ] (23-Historias-Secundarias) - [ ] Crear el evento de siembra (M32) [M] — **Dueño M32:** evento estacional; 0 cadenas estacionales en data/historias/secundarias.json (4 cadenas del principal: faro, invernadero, epilogo-plaza, luciernagas; 5 tras el merge de ejemplos, Log 2083).
- [ ] (23-Historias-Secundarias) - [ ] Crear el evento de vendimia [M] — **Dueño M32:** evento estacional; 0 en disco.
- [ ] (23-Historias-Secundarias) - [ ] Crear el evento de marea [M] — **Dueño M32:** evento estacional; 0 en disco.
- [ ] (23-Historias-Secundarias) - [ ] Crear el evento de eclipse [M] — **Dueño M32:** evento estacional; 0 en disco (el eclipse de cadena-faro es contexto narrativo, no el evento de M32).
- [x] (23-Historias-Secundarias) - [x] Crear 5 cadenas secretas ocultas [M] — Step-5-WorkBuddy 2026-10-22 (iter. 11, Log 2134): 5 cadenas en data/historias/secundarias.json (32 -> 37) con NPC REALES de data/villagers/ (nico_gato, vera_ardilla, sofia_buho, teo_conejo, luna_zorra) y objetos REALES de data/items/ por campo id (OBJ-SEC-002 «Mapa secreto», OBJ-SEC-003 «Cristal oculto», OBJ-SEC-005 «Diario antiguo», OBJ-ART-002 «Pergamino mistico», OBJ-ART-004 «Mascara ceremonial»); las 5 nacen oculta:true (invisibles en cadenas_disponibles hasta iniciarse); consecuencias peladas unicas 37/37 y capitulos de diario unicos 37/37. Suite test_historias.gd bloque P: 351 checks/0 fallos/EXIT 0 x3 + guardian EN ROJO por inyeccion de runtime (317<351). Regresiones M22 41/0, M71 83/0, M59 43/0+4/0+7/0, M55 0 fallos. M23 = 63 [x] / 40 [ ] / 2 [?] = 105.
- [ ] (23-Historias-Secundarias) - [ ] Documentar historias estacionales y secretas [S]
- [x] (23-Historias-Secundarias) - [x] Crear 8 misiones de exploración (brújula, fauna, cronitado) [M] — Step-5-WorkBuddy 2026-10-24 (iter. 15, Log 2166): 8 cadenas en data/historias/secundarias.json (51 -> 59) con NPC REALES de data/villagers/ y objetos REALES de data/items/ por campo id; integración con M65 (fauna) FUERA por orden del director (msg 200). Suite test_historias.gd bloque T: 543 checks/0 fallos/EXIT 0 x3 + guardián EN ROJO por inyección de runtime (478/2/EXIT 1, medido en el cierre). Regresiones: M59 43/0+4/0+7/0, M71 flujo XP 37/0, M55 26/0+0 fallos (M71 bug_reevaluar 8/2 = BUG-143 preexistente, dueño M71). M23 = 73 [x] / 30 [ ] / 2 [?] = 105.
- [x] (23-Historias-Secundarias) - [x] Documentar cadenas y misiones de exploración [S] — Step-5-WorkBuddy 2026-10-24 (iter. 15, Log 2166): 04-Codigo.md §Iter. 15.
- [ ] (23-Historias-Secundarias) - [ ] Crear 6 misiones de construcción (puentes, cofradía, plaza, senderos, kiosko, jardín) [M]
- [ ] (23-Historias-Secundarias) - [ ] Definir la reconstrucción del puente (M28) [M] — **Dueño M28:** sólo alcanzable como consecuencia «puente cruzable» (03-Diseno L53); la misión concreta no está definida.
- [x] (23-Historias-Secundarias) - [x] Crear 5 misiones de agricultura (invernadero, cruces, variantes) [M] — Step-5-WorkBuddy 2026-10-24 (iter. 17, Log 2172): 5 cadenas en data/historias/secundarias.json (62 -> 67); 1 tema nombrado de 03-Diseno L41 (cruces de semillas) + 4 de extension declarada (cultivos del invernadero, primera cosecha, riego del manantial, macetas de la plaza); tema invernadero con cadena previa del principal y variantes estacionales con dueno M32 (fuera). NPC REALES (vera_ardilla farera, mateo_mapache granjero x2, teo_conejo herbolario, luna_zorra artesana) + objetos REALES por campo id (OBJ-EXT-011, OBJ-HER-012, OBJ-EXT-013, OBJ-HER-013, OBJ-PLA-001). Suite bloque V: 624/0/EXIT 0 x3, guard rojo 581<624. M23 = 76/27/2 = 105. Hallazgo ajeno: id semilla_antigua sin respaldo en data/items/.
- [ ] (23-Historias-Secundarias) - [ ] Definir variantes estacionales de agricultura (M32) [S] — **Dueño M32:** 03-Diseno L70 define la variación estacional genérica; las variantes de agricultura en sí son de M32.
- [x] (23-Historias-Secundarias) - [x] Documentar misiones de construcción y agricultura [S] — Step-5-WorkBuddy 2026-10-24 (iter. 17, Log 2172): agricultura en 04-Codigo.md sec. Iter. 17; construccion en sec. Iter. 16 (Log 2169).
- [ ] (23-Historias-Secundarias) - [ ] Crear 4 misiones de pesca (peces-trofeo, documentación y suelta) [M]
- [ ] (23-Historias-Secundarias) - [ ] Crear 6 misiones de colección (murales, glifos, sellos, minerales, peces, plantas) [M]
- [ ] (23-Historias-Secundarias) - [ ] Documentar misiones de pesca y colección [S]
- [x] (23-Historias-Secundarias) - [x] Crear 5 misiones de investigación (faro, biblioteca, geodesia, mapas) [M] — Step-5-WorkBuddy 2026-10-22 (iter. 13, Log 2137): 5 cadenas en data/historias/secundarias.json (40 -> 51) con NPC REALES de data/villagers/ (vera_ardilla farera, sofia_buho bibliotecaria, pablo_pato ceramista, teo_conejo herbolario) y objetos REALES de data/items/ por campo id (OBJ-LUZ-012 «Linterna», OBJ-EST-006 «Vitrina», OBJ-REL-002 «Reloj de péndulo», OBJ-HER-015 «Lupa», OBJ-LUZ-008 «Lámpara de cristal»); la 5.a (cartas estelares) es extensión declarada del núcleo (el 03-Diseno L45 nombra 4 temas y el ítem pide 5). Suite test_historias.gd bloque R: 456 checks / 0 fallos / EXIT 0 x3 + guardián EN ROJO por inyección de runtime (solo 380 de mínimo 456). M23 = 69 [x] / 34 [ ] / 2 [?] = 105.
- [x] (23-Historias-Secundarias) - [x] Documentar misiones de amistad e investigación [S] — Step-5-WorkBuddy 2026-10-22 (iter. 13, Log 2137): ítem compuesto, las dos mitades citadas — amistad en 04-Codigo.md §Iter. 10 (Log 2131) e investigación en §Iter. 13 (Log 2137).
- [x] (23-Historias-Secundarias) - [x] Crear 6 misiones de puzzles (templos 24/25/26, ruinas ocultas) [M] — Step-5-WorkBuddy 2026-10-22 (iter. 13, Log 2137): 6 cadenas en data/historias/secundarias.json (40 -> 51) con NPC REALES de data/villagers/ (pablo_pato, bruno_sapo, luna_zorra, catalina_oso, teo_conejo, vera_ardilla) y objetos REALES de data/items/ por campo id (OBJ-TAL-004 «Rueda de alfarero», OBJ-HER-018 «Sierra», OBJ-PLA-004 «Orquídea», OBJ-ITE-021 «Pan», OBJ-NAT-024 «seta», OBJ-LUZ-004 «Veladora»). Suite test_historias.gd bloque R: 456 checks / 0 fallos / EXIT 0 x3 + guardián EN ROJO por inyección de runtime (solo 380 de mínimo 456). M23 = 69 [x] / 34 [ ] / 2 [?] = 105.
- [ ] (23-Historias-Secundarias) - [ ] Definir la integración con el framework M24 [M] — **Sin cita en disco:** M24 no se menciona en 02-Analisis ni 03-Diseno (§Integración cubre M68/M22/M32/M36/M37/M66). Pendiente de definir.
- [x] (23-Historias-Secundarias) - [x] Documentar misiones de puzzles [S] — Step-5-WorkBuddy 2026-10-22 (iter. 13, Log 2137): documentado en 04-Codigo.md §Iter. 13 (templos 24/25/26 + ruinas, NPC/objetos REALES, flags y cobertura de suite).
- [ ] (23-Historias-Secundarias) - [ ] Crear 20 capítulos de diario (recompensa narrativa) [M]
- [ ] (23-Historias-Secundarias) - [ ] Crear recetas de conversación desbloqueables [M]
- [ ] (23-Historias-Secundarias) - [ ] Crear 10+ cosméticos (disfraces, sombreros, paletas de casa) [M]
- [ ] (23-Historias-Secundarias) - [ ] Documentar recompensas en el plan-actual [S]
- [ ] (23-Historias-Secundarias) - [ ] Crear la consecuencia "jardín florecido" [S]
- [ ] (23-Historias-Secundarias) - [ ] Crear la consecuencia "taller abierto" [S]
- [ ] (23-Historias-Secundarias) - [ ] Crear la consecuencia "cofradía activa" [S]
- [ ] (23-Historias-Secundarias) - [ ] Documentar consecuencias y diálogos posteriores [S]
- [ ] (23-Historias-Secundarias) - [ ] Crear 4 cadenas de postgame [M]
- [ ] (23-Historias-Secundarias) - [ ] Crear el memorial del Sello post-final [S]
- [ ] (23-Historias-Secundarias) - [ ] Crear el epílogo de la aldea [S]
- [ ] (23-Historias-Secundarias) - [ ] Crear el epílogo del guardián (final secreto) [S]
- [ ] (23-Historias-Secundarias) - [ ] Integrar con M68 (objetivos y evaluación) [M] — **Dueño M68:** las señales quest_started/quest_completed ya emiten (M07); el consumidor es de M68.
- [ ] (23-Historias-Secundarias) - [ ] Integrar con M32 (estacionales) [M] — **Dueño M32.**
- [ ] (23-Historias-Secundarias) - [ ] Integrar con M36 (museo y colección) [M] — **Dueño M36** (definición en 03-Diseno L71; implementación pendiente de M36).
- [ ] (23-Historias-Secundarias) - [ ] Integrar con M37 (comerciantes) [M] — **Dueño M37** (definición en 03-Diseno L72).
- [ ] (23-Historias-Secundarias) - [ ] Diseñar test E2E de 10 cadenas completas [M]
- [ ] (59-Guardado) - [ ] Probar 3 perfiles sin mezcla y cambio de slot en plena sesión [C]
- [ ] (59-Guardado) - [ ] Testear carga del mundo sin duplicar objetos [C]
- [ ] (59-Guardado) - [ ] Testear carga sin duplicados y límites de cantidad (M60) [C]
- [ ] (59-Guardado) - [ ] Testear carga con casas parcialmente construidas [C]
- [ ] (59-Guardado) - [ ] Testear carga con muebles inexistentes (fallback) [M]
- [x] (59-Guardado) - [ ] Testear carga con NPC en movimiento y regalos duplicados [C] — **[x] HECHO 2026-10-23 (Step-5-WorkBuddy, Log 2155, canal 187):** suite NUEVA `test_carga_npc_misiones_m59.gd` (63 checks / 0 fallos / EXIT 0 x3). NPCManager (npc_ai): payload con {npc_id, state, needs, sim_level}, restore idempotente, needs/sim_level restaurados sobre agente nuevo — BRECHA MEDIDA: el state (Movement) NO se restaura (reaparece Idle). Friendship: memoria de regalos + limite diario sobreviven la carga (regalo repetido = DUPLICADO 2 pts, sin exploit).
- [x] (59-Guardado) - [ ] Testear carga con misión a medias (objetivo coherente) [C] — **[x] HECHO 2026-10-23 (Step-5-WorkBuddy, Log 2155, canal 187):** misma suite, bloques 3-4. cadena-faro con paso_actual=1: tras cargar (directa x2 y e2e por SaveManager) sigue activa con el paso preservado; el paso siguiente se puede reportar y el ya hecho no se re-ofrece — objetivo coherente sin reset.
- [x] (59-Guardado) - [ ] Testear carga tras completar misión y reabrir [C] — **[x] HECHO 2026-10-23 (Step-5-WorkBuddy, Log 2155, canal 187):** misma suite, bloques 5-6. cadena-invernadero 3/3: tras cargar sigue completada/inactiva, no se re-ofrece, no se puede reiniciar, completadas no se duplica; consecuencia (flag WorldState) aplicada. Historia principal: completados/sellos sobreviven sin crecer.
- [ ] (59-Guardado) - [ ] Guardar eventos pasados y futuros programados (M74) [M]
- [ ] (59-Guardado) - [ ] Guardar festivales celebrados y calendario [M]
- [x] (59-Guardado) - [ ] Testear carga en una fecha distinta a la del guardado [C] — **[x] HECHO 2026-10-23 (Step-5-WorkBuddy, Log 2161, canal 191):** suite NUEVA `test_fecha_diario_cola_m59.gd` bloque 1 (45 checks / 0 fallos / EXIT 0 x3). Payload real por `snapshot.collect()` con `meta.last_saved = "2026-09-15 08:30:00"` y `time.dia/day = 42`; `SaveWriter.write_atomic` + `load_slot` cargan OK con la cadena-faro activa (`paso_actual=1`) y el paso siguiente reportable; `last_saved` NO se reescribe al cargar y `slot_metadata` sigue mostrando la fecha vieja con `day=42`. Variante con fecha futura tambien carga OK. `request_save` sella la fecha del sistema.
- [ ] (59-Guardado) - [ ] Testear eventos no duplicados al recargar [C]
- [ ] (59-Guardado) - [ ] Guardar museo, bestiario y colecciones (M37/M36) [M]
- [ ] (59-Guardado) - [ ] Guardar fotos por referencia (ids, no bytes — M56) [M]
- [ ] (59-Guardado) - [ ] Guardar Sellos y ruinas coleccionables [M]
- [x] (59-Guardado) - [ ] Testear diario 500+ entradas y fotos faltantes (fallback) [C] — **[x] HECHO 2026-10-23 (Step-5-WorkBuddy, Log 2161, canal 191):** mismo suite, bloque 2 (45 checks / 0 fallos / EXIT 0 x3). Roundtrip real de las 44 entradas del catalogo (`Diary.registrar()` + favorito + `set_ui_prefs` e2e); payload sintetico con 44 validas + 456 huerfanas -> carga OK y quedan 44 (las huerfanas se IGNORAN con print, fallback medido); 300 ids de foto inexistentes -> carga OK y se preservan (ids = referencias, no bytes); documento en disco 24619 B < 120 KB.
- [ ] (59-Guardado) - [ ] Probar múltiples perfiles sin cruzamiento [C]
- [ ] (59-Guardado) - [ ] Probar archivos con permisos de solo lectura [M]
- [x] (59-Guardado) - [ ] Sin GC pesado ni hitching al encolar [M] — **[x] HECHO 2026-10-23 (Step-5-WorkBuddy, Log 2161, canal 191):** mismo suite, bloque 3 (45 checks / 0 fallos / EXIT 0 x3). Con `sm._writing = true` (white-box) y 1000 x `sm.request_save(SLOT_A, "test_cola_s5")`: cola +1000 exactos, 0 Objects creados, < 16670 us (1 frame a 60 FPS; medido 761 us), memoria estatica < 1 MB y 0 guardados disparados (medido con `Performance.OBJECT_COUNT`, `Performance.MEMORY_STATIC`, `Time.get_ticks_usec()`).
- [ ] (59-Guardado) - [ ] Reutilizar buffers de serialización (M62) y probar con profiler (M116) [C]
- [ ] (59-Guardado) - [ ] Localizar textos del menú de guardado [S]
- [ ] (59-Guardado) - [ ] Localizar mensajes de corrupción, recuperación y disco lleno [S]
- [ ] (59-Guardado) - [ ] Localizar feedback de guardado (M44) [S]
- [ ] (59-Guardado) - [ ] Respetar plurales (horas, minutos) [S]
- [ ] (59-Guardado) - [ ] Testear menú de guardado en 3 idiomas [M]
- [ ] (59-Guardado) - [ ] Definir contrato con M107 (3-2-1 externo) [M]
- [ ] (59-Guardado) - [ ] Verificar la restauración desde la nube [C] — **MEDIDO 2026-10-23 (Step-5-WorkBuddy, Log 2161, canal 191):** `grep -rln "nube|cloud"` sobre `scripts/saving/*.gd` = 0 y `grep -rln "restaurar_desde_nube|cloud_restore|steam"` = 0 -> no existe mecanismo de restauracion en la nube en el riel de guardado. Dueno: M97 (`97-Steam-Store-Page` / `M97-Marketing`). Queda `[ ]` honesto hasta que el dueno lo implemente.
- [ ] (59-Guardado) - [ ] Documentar el flujo de recuperación completo [M]
- [ ] (59-Guardado) - [ ] Guardar durante un festival con estado consistente (M74) [M]
- [ ] (59-Guardado) - [ ] Confirmaciones accesibles por gamepad (M57) [M]
- [ ] (59-Guardado) - [ ] Testear menú con Reduce Motion (M58) [M]
- [ ] (59-Guardado) - [ ] Testear con texto grande (M58) [M]
- [ ] (59-Guardado) - [ ] Push del módulo y reporte al usuario [S]
- [ ] (59-Guardado) - [ ] Marcar ítems solo al cumplir la DoD (sección 21.6) [S]
- [ ] (21-Dialogos) - [ ] RF4: salto rápido de línea y salto completo con confirmación doble [S]
- [ ] (21-Dialogos) - [ ] Recarga en caliente del grafo en el editor (tool) sin reiniciar el juego [M]
- [ ] (21-Dialogos) - [ ] Crear escena dialogue_ui.tscn como CanvasLayer reutilizable [S]
- [ ] (21-Dialogos) - [ ] Usar las fuentes del modulo M87 en textos y retratos [S]
- [ ] (21-Dialogos) - [ ] Navegar opciones con gamepad (dpad + boton A) [S]
- [ ] (21-Dialogos) - [ ] Perder la rama elegida en el historial de sesion para retornos [M]
- [ ] (21-Dialogos) - [ ] Efectos de opcion informan al sistema de misiones M22 [S]
- [ ] (21-Dialogos) - [ ] Dialogos de pistas y revelaciones conectados a M23 (templos) [S]
- [ ] (21-Dialogos) - [ ] Dialogos especiales por festivales (M73) con ramas temporales [S]
- [ ] (21-Dialogos) - [ ] Pausa del reloj M29 pausa el tipeo sin perder estado [S]
- [ ] (21-Dialogos) - [ ] Guerra de inputs: el dialogo activo bloquea acciones del jugador [S]
- [ ] (21-Dialogos) - [ ] NPC desaparece o se aleja durante el dialogo: cierre limpio sin errores [S]
- [ ] (21-Dialogos) - [ ] Opcion unica con condiciones falsas: rama colapsa a next_id alternativo [S]
- [ ] (21-Dialogos) - [ ] Nodo OPCIONES sin opciones visibles: salta a next_id sin pantalla vacia [S]
- [ ] (21-Dialogos) - [ ] Dialogo interrumpido por teleport del jugador (M69): se cierra y se loguea [S]
- [ ] (21-Dialogos) - [ ] Guardado y carga de partida a mitad de conversacion: la conversacion se reinicia [M]
- [ ] (21-Dialogos) - [ ] Tipeo con caracteres unicode y emojis neutralizados en produccion [S]
- [ ] (21-Dialogos) - [ ] Lineas muy cortas y muy largas se ven correctamente [S]
- [ ] (21-Dialogos) - [ ] Recarga del grafo con datos rotos en caliente: el cache no se corrompe [S]
- [ ] (21-Dialogos) - [ ] Cache de grafos cargados con descarte LRU por limite de memoria [M]
- [ ] (21-Dialogos) - [ ] Cero allocs apreciables por frame durante el tipeo (strings precalculadas) [S]
- [ ] (21-Dialogos) - [ ] Fuentes del modulo M87 con atlas compartido, sin reimport por nodo [S]
- [ ] (21-Dialogos) - [ ] Load de JSON asincrono con carga diferida por zona del mapa [M]
- [ ] (21-Dialogos) - [ ] Presupuesto: dialogo activo agrega menos de 1 ms al frame presupuestado [S]
- [ ] (21-Dialogos) - [ ] Plan-actual duplicado identico del plan-inicial [S]
- [ ] (21-Dialogos) - [ ] Verificacion de 0 errores en consola durante una partida de prueba [S]
- [ ] (69-Fast-Travel) - [ ] Iconos de apoyo visual al nombre del destino [S]
- [ ] (69-Fast-Travel) - [ ] Alt text para thumbnails de destino [S]
- [ ] (69-Fast-Travel) - [ ] Modo cronológico para historiales [S]
- [ ] (69-Fast-Travel) - [ ] Filtros por tipo de lugar (bioma, servicios) [S]
- [ ] (69-Fast-Travel) - [ ] Sin dependencia solo de color para estado [S]
- [ ] (69-Fast-Travel) - [ ] M110: debug menu con listado de anchors [S]
- [ ] (69-Fast-Travel) - [ ] M32: anulación del portal en clima extremo [S]
- [ ] (69-Fast-Travel) - [ ] M91: respetar volumen de feedback de viaje [S]
- [ ] (69-Fast-Travel) - [ ] Test de recuperación: archivo corrupto ? resync [M]
- [ ] (69-Fast-Travel) - [ ] Test de batería: consumo por viaje a larga distancia [M]
- [ ] (69-Fast-Travel) - [ ] Test multidioma: búsqueda en distintos alfabetos [M]
- [ ] (69-Fast-Travel) - [ ] Test de aceso: atajos disponibles sin teclado [M]
- [ ] (69-Fast-Travel) - [ ] Test de localización: posicionamiento visual ajustado [M]
- [ ] (69-Fast-Travel) - [ ] Test de fallback: 3 fallos seguidos ? modo seguro [M]
- [ ] (69-Fast-Travel) - [ ] Test de perfilado: sin allocs en frame [M]

## Vuelta 2026-10-22 17:0x (tracker 179) - Step-5-WorkBuddy

- RAMA 1: unico entrante 179 del director (acuse de mi 178: commit autorizado para su ronda,
  flip L84 ratificado, move de los 3 scripts-prueba_tmp_familias_*.py autorizado, REPOSICION con
  orden explicito: Secretas L38 -> Comerciantes-cadenas L36 (integracion M37 afuera) -> Puzzles
  L46 -> Investigacion L45). Acusado con mi 180 (5.239 B, UTF-8 sin BOM + LF, verificado por
  bytes). Numeracion: 180 = head del pool medido (coincide con ultimo+1); consumido,
  reeexpandido mental: quedan 88 numeros con head 181. Tracker -> 179.
- RAMA 2 (tanda ordenada): M23 iter. 11 = cluster Secretas del 03-Diseno L38. 5 cadenas ocultas
  nuevas en secundarias.json (32 -> 37): cadena-mapa-secreto (nico_gato + OBJ-SEC-002),
  cadena-cristal-oculto (vera_ardilla + OBJ-SEC-003), cadena-diario-antiguo (sofia_buho +
  OBJ-SEC-005), cadena-pergamino-mistico (teo_conejo + OBJ-ART-002), cadena-mascara-ceremonial
  (luna_zorra + OBJ-ART-004). NPC y objetos REALES verificados en disco (campo id dentro del
  .tres / archivo en data/villagers/). Consecuencias peladas unicas 37/37; capitulos de diario
  unicos 37/37. Edicion del JSON puramente aditiva (+75/-0, formato Godot preservado).
- Suite: bloque P _test_secretas (35 checks) al FINAL de _run(); BLOQUES A-P; conteos de A e I
  actualizados (33->38, 32->37). Piso 316 -> 351 MEDIDO en verde. **351 checks / 0 fallos /
  EXIT 0 x3** con el binario real, 0 SCRIPT ERROR. Guardian EN ROJO por inyeccion de runtime
  (Variant con Array -> Dictionary al inicio del bloque P): EXIT 1, "el bloque P NO se ejecuto" +
  "solo 317 checks (minimo 351)". Sonda borrada en la misma operacion.
- Regresiones medidas tras la tanda: M22 test_historia.gd 41/0 - M71 test_progresion.gd 83/0 -
  M59 test_rotate_m59.gd 43/0 (9 bloques) + test_backup_rotate_return.gd 4/0 +
  test_backup_rotations.gd 7/0 - M55 test_diario.gd 0 fallos + test_diario_persist.gd 0 fallos.
  Todas EXIT 0, 0 SCRIPT ERROR.
- Flip con cita: L56 "Crear 5 cadenas secretas ocultas" [ ] -> [x]; M23 = 63 [x] / 40 [ ] /
  2 [?] = 105 por prefijo de linea; las DOS lineas de totales sincronizadas. Ofrecido a
  revertir (msg 180). El item L58 "Documentar historias estacionales y secretas" sigue [ ] a
  proposito (compuesto: estacionales de M32, 0 en disco - patron anti-inflacion de iter. 6).
- Hallazgo (dueno M55, no tocado): el puente M23->M55 degrada en silencio para las 5 nuevas
  (mision_cadena-* ausentes del catalogo M55; capitulo-* tambien). Mismo patron que las iters
  3/6/7/8/9/10. No se inventa contenido de M55.
- Move autorizado EJECUTADO: los 3 scripts-prueba_tmp_familias_*.py estan en
  Obsoletos/raiz-temporales-2026-10-22-step5/ (destino gitignored verificado), staged como
  rename; el commit de las 3 bajas lo hace el director.
- Trampas propias corregidas: (1) 1a corrida con 1 fallo porque el check de visibilidad
  iniciaba cadena-mapa-secreto y el end-to-end la re-iniciaba -> restore_save_data({}) entre
  ambos; (2) la nota de iter. 11 en el header de la suite dejo una comilla colgante (Parse
  Error "Closing ) doesn't have an opening counterpart") detectada al correr y corregida antes
  de la 2da corrida; (3) el script de insercion en el JSON aborto 2 veces por construccion
  incorrecta (verificacion en memoria ANTES de escribir: el archivo nunca quedo a medias).
- Artefactos: Log 2134 (ASCII puro por bytes, CRLF 93, sin BOM, 5.828 B; head del pool medido
  2134 justo antes -> consumido, head nuevo 2135), msg 180, 04/05/06/07 de M23,
  secundarias.json, test_historias.gd, tracker 179.
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos (CHECKLIST-GLOBAL.md,
  quality.yml, AGENTS.md, project.godot intactos).
- Pedidos (msg 180): visto bueno del flip L56; sync fila 23 GLOBAL a 63/105; incluir los 8
  paths + las 3 bajas del move en la ronda de commit del director. Proxima tanda declarada:
  Comerciantes-cadenas L36 (solo cadenas M23; integracion M37 afuera).
- Cierre de tanda M23 iter. 13 (Log 2137, 2026-10-22): clusters Puzzles (6, 03-Diseno
  L46: templos 24/25/26 + ruinas del barrizal/manantial/acantilado) e Investigacion (5,
  L45: faro, biblioteca, geodesia, mapas + cartas estelares como extension declarada),
  consolidados en UNA tanda por orden del director (msg 183). secundarias.json 40 -> 51
  cadenas (52 con la de ejemplo en carga). NPC REALES de data/villagers/ (7: vera_ardilla,
  sofia_buho, pablo_pato, teo_conejo, bruno_sapo, luna_zorra, catalina_oso) y objetos
  REALES de data/items/ por campo id (11, ninguno reutilizado de cadenas previas). Las 11
  nacen visibles (oculta:false): se descubren hablando, como las comerciantes de iter. 12.
  Colisiones verificadas ANTES de escribir: ids, consecuencias, capitulos de diario y refs
  de puzzle = 0 con las 40 previas; lugares = 4 nuevos (templo_24/25/26, biblioteca) + 6
  reutilizados por diseno (faro, jardines, observatorio, barrizal, manantial, acantilado).
  Consecuencias peladas unicas 51/51 en disco (52/52 sobre la carga); 11 capitulos de
  diario unicos (50 con diario sobre 52 cargadas: 2 preexistentes no declaran). JSON:
  +396/-0, puramente aditivo, formato Godot preservado, LF sin BOM verificado por bytes.
- Suite: bloque R _test_puzzles_investigacion (77 checks: 33 carga/fuente/no-oculta + 1
  disponibles + 2 unicidad GLOBAL de flags medida sobre la carga real + 7 NPC REALES por
  efecto + 11 objetos REALES por campo id + 1 diarios + 3x7 end-to-end + 1 puente diario)
  al FINAL de _run(); BLOQUES A-R; conteos de A/I actualizados (41 -> 52 cargadas,
  principal 40 -> 51). Piso 379 -> 456 MEDIDO en verde. **456 checks / 0 fallos /
  EXIT 0 x3** con el binario real, 0 SCRIPT ERROR. Guardian EN ROJO por inyeccion de
  runtime (Node null -> free() al inicio del bloque R): EXIT 1, "el bloque R NO se
  ejecuto (posible SCRIPT ERROR que aborto la funcion)" + "solo 380 checks ejecutados
  (minimo 456)"; sonda borrada en la misma operacion, sha256 restaurado byte-exacto y
  git status de scripts/historias/ vacio.
- Regresiones medidas tras la tanda: M55 test_diario.gd 0 fallos + test_diario_persist.gd
  0 fallos - M59 test_autosave_m59.gd 0 fallos - M71 test_bug_reevaluar_m71_hy3.gd 8/2
  (los 2 fallos son la reproduccion del BUG-143 conocido, previa a la tanda). El validador
  validate_quest_chains.gd no se pudo medir: cuelga en modo --script headless (SceneTree
  sin quit(), condicion previa ajena a la tanda).
- Flips con cita: L85 "Crear 5 misiones de investigacion", L87 "Documentar misiones de
  amistad e investigacion" (compuesta: Iter. 10 + Iter. 13), L91 "Crear 6 misiones de
  puzzles" y L93 "Documentar misiones de puzzles" [ ] -> [x]; M23 = 69 [x] / 34 [ ] /
  2 [?] = 105 por prefijo de linea; las DOS lineas de totales sincronizadas. Ademas se
  reparo una desync del espejo: el item 156 "Crear 6 misiones de amistad" estaba [ ] aca
  pero [x] en el checklist desde iter. 10 (Log 2131) -> flip con la cita de iter. 10 (las
  6 cadenas estan en disco). Ofrecido a revertir (msg 184).
- Hallazgo (dueno M55, no tocado): el puente M23->M55 degrada en silencio para
  cadena-registro-del-faro (mision_cadena-registro-del-faro ausente del catalogo M55).
  Mismo patron que las iters 3/6/7/8/9/10/11/12. No se inventa contenido de M55.
- Artefactos: Log 2137 (ASCII puro por bytes, CRLF, sin BOM; head del pool medido 2137
  justo antes -> consumido), msg 184, 04-Codigo.md e 05-Checklist.md de M23, tracker 183.
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos (CHECKLIST-GLOBAL.md,
  quality.yml, AGENTS.md, project.godot intactos).
- Pedidos (msg 184): ronda de commit de los paths de la tanda (secundarias.json y
  test_historias.gd YA estan en HEAD por el commit de preservacion del CRON 4fef055;
  quedan en el worktree 04-Codigo.md, 05-Checklist.md y este backlog); sync fila 23 del
  GLOBAL a 69/105; visto bueno de los 4 flips + el de la desync del item 156. Nota de
  pool: el head de NUMEROS_DISPONIBLES.txt de mi canal quedo en 183 (stale en 1) -> use
  el ultimo+1 = 184.


## Registro de vuelta — 2026-10-23 18:20 (Step-5-WorkBuddy, Log 2154, canal 185)

- RAMA 1: SIN mensajes nuevos del director (tracker 183; mi 184 del turno anterior sigue
  siendo el ultimo archivo). RAMA 2: item 35 de la seccion A (default declarado en el
  turno anterior: M59 save slots + autoguardado).
- Tanda: 2 suites nuevas (no tocan logica de produccion):
  `scripts/saving/test_slots_perfiles_m59.gd` 41 checks / 0 fallos / EXIT 0 x3 y
  `scripts/saving/test_carga_idempotente_m59.gd` 28 checks / 0 fallos / EXIT 0 x3
  (binario real, 0 SCRIPT ERROR). Guardas de 3 capas con piso MEDIDO (41 y 28) y
  guardian EN ROJO por inyeccion en ambas (EXIT 1 nombrando bloque y piso).
- 7 flips con cita de suite: L51, L166, L167, L95, L105, L115, L116 -> M59 =
  109 [x] / 19 [ ] / 2 [?] = 130 (linea Totales sincronizada). Ofrecidos a revertir.
- Regresiones medidas: test_slots_m59 22/0, qa_m59_profile_id OK, test_autosave_m59
  0 fallos, qa_m59_bloqueo_manual 5/0, M55 diario perf 26/0, M55 persistencia 0,
  M71 progresion 83/0.
- TRAMPA NUEVA (propia, corregida): en una suite con `await`, el `_summary()` en
  `call_deferred` dispara en el primer frame y su quit() mataba el proceso a mitad
  de corrida (falso "suite incompleta" con la suite realmente verde). Fix: bandera
  `_run_terminado` que _summary() espera antes de reportar.
- Nota de comportamiento MEDIDO (L167): el flag de solo-lectura sobre el .save
  anterior NO impide el guardado en Windows (se permite rotar el read-only a .bak y
  el .save nuevo verifica); el fallo real de escritura (destino bloqueado) si degrada
  graceful con recuperacion desde .bak.
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos tocados
  (CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot intactos).
- Pedidos (msg 185): ronda de commit de los paths de la tanda; sync fila 59 del
  GLOBAL a 109/130 (hoy dice 60/130, stale); visto bueno de los 7 flips.
---

### Registro de corrida — Step-5-WorkBuddy 2026-10-23 (tarde, Log 2155, canal 187/188)

- Msj 187 del director (ratificacion 109/130 + fila GLOBAL reparada + pregunta del probe):
  acuse 188. El probe `_probe_ro_m59.gd` ERA MIO y ya estaba borrado (medido contra disco:
  no existe, git status limpio en scripts/saving/) — sonda de la tanda anterior, borrada
  tras publicar las mediciones R1/R2 del Log 2154.
- Tanda ejecutada: L128/L135/L136 de M59 (lote autorizado por el director, msg 187, sin GO nuevo).
  Suite NUEVA `scripts/saving/test_carga_npc_misiones_m59.gd`: 63 checks / 0 fallos / EXIT 0 x3,
  guarda de 3 capas con piso 63 MEDIDO en verde; guardian probado EN ROJO por inyeccion 2 veces
  (aborto dentro del bloque 5: EXIT 1 nombrando [5] + piso 48 < 63).
- Flips: L128/L135/L136 -> M59 = 112 [x] / 16 [ ] / 2 [?] = 130 (Totales sincronizados).
- Regresiones (binario real, EXIT 0): test_slots_m59 22/0 · qa_m59_profile_id OK ·
  test_autosave_m59 0 fallos · qa_m59_bloqueo_manual OK · test_historias (M23) 456/0 ·
  M55 diario 0 · M55 persistencia 0 · M71 flujo XP 37/0.
- TRAMPA NUEVA (arnes NPC): con un await entre _add_agent y el uso del agente,
  poblacion_cambio (Bootstrap cargando la escena principal) borra al agente de prueba antes
  de usarlo (medido: get_agent -> null). Fix: el registro es sincronico, sin awaits en el bloque.
- HALLAZGO colateral (M20, reportado al director): GiftEvaluator._clasificar
  (gift_evaluator.gd L42-45) espera Dictionary pero ItemDatabase.get_item devuelve un Resource
  ItemData (item_database.gd L102) -> SCRIPT ERROR en cada regalo no duplicado; la evaluacion
  degrada a AMADO/20 (medido con sonda). El camino duplicado si es exacto (2 pts).
- Nota de contrato: `quest_chain_service.gd` NO esta cableado en runtime (solo lo tocan
  validate_quest_chains.gd y _colector_sintaxis.gd); el proveedor vivo de misiones es
  SecondaryStoriesService (autoload Historias) + StoryManager (autoload Historia). La fila L132
  del checklist menciona quest_chain_service como provider registrado: imprecisa, reportada.
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos tocados.
- Pedidos al director (msg 189): ronda de commit de los paths de la tanda; sync fila 59 del
  GLOBAL a 112/130; visto bueno de los 3 flips; decision sobre el defecto M20 del evaluador.


### Registro de corrida — Step-5-WorkBuddy 2026-10-23 (noche, Log 2161, canal 191)

- RAMA 1: mensaje 190 del director (ratifica tanda M59 112/130, fila 59 GLOBAL sincronizada,
  M20 ruteado a agnes, sin GO nuevo: el proximo lote es segun mi claustro). Acuse 191.
  RAMA 2: siguientes [ ] de M59 en la cola -> L143/L152/L175 (flips) + L199 (solo medicion).
- Tanda: 1 suite NUEVA (no toca logica de produccion):
  `scripts/saving/test_fecha_diario_cola_m59.gd` 45 checks / 0 fallos / EXIT 0 x3, guarda de
  3 capas con piso 45 MEDIDO en verde; guardian probado EN ROJO por inyeccion 2 veces
  (EXIT 1 nombrando el bloque + piso no cumplido).
- Flips: L143/L152/L175 -> M59 = 115 [x] / 13 [ ] / 2 [?] = 130 (Totales sincronizados).
  L199 (restauracion desde la nube) MEDIDO y queda [ ]: 0 coincidencias de nube/cloud/steam
  en scripts/saving/*.gd; dueno M97.
- DEFECTO PROPIO corregido (hallado en la regresion de la tanda):
  `test_slots_perfiles_m59.gd` L129/L136 - `bool(_slot_previo.get(slot, false))` sobre un dict
  que guarda el CONTENIDO String del save previo: `bool(String)` aborta `_restore()` en runtime
  ("Nonexistent bool constructor") justo cuando habia save previo que restaurar; el cleanup
  moria en silencio y colgaba el SceneTree. Fix: `_slot_previo.has(slot)` + quitar el `bool()`
  de L136. Verificado: 41 checks / 0 fallos / EXIT 0 x2, 0 SCRIPT ERROR.
- Regresiones (binario real, EXIT 0): test_slots_m59 22/0 · test_slots_perfiles_m59 41/0 x2 ·
  test_autosave_m59 0 fallos · qa_m59_profile_id OK · qa_m59_bloqueo_manual OK.
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos tocados.
- Pedidos al director (msg 192): ronda de commit de los paths de la tanda; sync fila 59 del
  GLOBAL a 115/130; visto bueno de los 3 flips; nota del defecto propio corregido.

## Registro de la vuelta 2026-10-23 23:0x-23:5x (tracker 192 -> 194) - RAMA 1 acuse 194 + RAMA 2 M23 iter. 14 (Log 2163, canal 195/197)

- RAMA 1: unico mensaje nuevo = **194** (acuse de mi 193: tanda 4 de M59 RATIFICADA,
  115/13/2 = 130 exacto, fila 59 del GLOBAL sincronizada, mis 7 paths commiteados).
  Verificado en disco antes de acusar: `git log -1 -- <path>` da **a30417b** para los
  6 artefactos; fila 59 = 115/130 (L163). Tu 194 no trae trabajo nuevo ("segun tu
  cola") -> RAMA 2. Consumido el **195** de mi pool (head medido 195 = ultimo+1);
  pool queda 196..295 (100).
- RAMA 2: **M23 iter. 14** desde la COLA ACTIVA. Hallazgo de entrada: la cola estaba
  DESINCRONIZADA con el modulo — 2 items `[ ]` en la cola que ya eran `[x]` en
  23-Historias-Secundarias/05-Checklist (L47/L48) desde la iter. 12 (Log 2135:
  cadena-ruta-del-mercader, cadena-cargamento-de-telas, cadena-secreto-del-yunque).
  Sincronizada la cola (mi archivo), NO el modulo.
- Bloque NUEVO `_test_consecuencias` (bloque S, 21 checks) en
  `scripts/historias/test_historias.gd`: cobertura de las 12 consecuencias de
  03-Diseno L53 sobre los DOS catalogos (8 con respaldo / 4 sin), negativo acotado
  del token `taller_abierto` sobre res://data y E2E de cadena-jardines y
  cadena-cofradia con `ws_has(...)` de los dos flags. Piso 456 -> **477 checks /
  0 fallos / EXIT 0 x2** (binario real). Guardian EN ROJO por inyeccion de runtime
  Variant->Dictionary tipado: EXIT 1 nombrando el bloque S + "solo 457 checks
  (minimo 477)"; sonda borrada, 0 archivos *sonda* en scripts/historias/.
- **Corrida 1 en ROJO con 3 fallos y la causa fue mia, no del codigo:** (a) mi
  medicion previa de cobertura usaba UN solo catalogo (secundarias.json) y daba
  7/5; el universo correcto son los dos (el de ejemplos esta mergeado y vivo desde
  iter. 3) y da 8/4 — `biblioteca_iluminada` la aplica cadena-biblioteca del
  catalogo de ejemplos; (b) el negativo de `taller_abierto` se AUTO-PISO: buscaba
  en res://data Y res://scripts y el propio archivo de test nombra el token en su
  lista de las 12 (1 hit = test_historias.gd). Ademas una mencion en un script no
  es "respaldo" de la consecuencia. Acotado a res://data con el alcance declarado.
- **TRAMPA NUEVA de la sonda:** la primera inyeccion asignaba directo `Node` a una
  variable tipada `Dictionary` -> error de PARSE: el archivo entero no compilaba y
  la prueba no probaba nada (falso rojo). La inyeccion valida pasa por un
  `Variant` intermedio (`var v: Variant = ...; var x: Dictionary = v`).
- 2 flips con cita en M23 (mi modulo, GO vigente de tandas anteriores):
  L108 "jardin florecido" y L111 "cofradia activa" `[ ]` -> `[x]` — respaldo =
  flag aplicado por cadena-jardines / cadena-cofradia a WorldState (M21) via
  secondary_stories_service.gd L232-236. L109 "taller abierto" queda `[ ]`
  honesto con la medicion del vacio y la guarda del bloque. M23 = **71 [x] /
  32 [ ] / 2 [?] = 105**; las DOS lineas de totales sincronizadas (L170 arrastraba
  63/40/2 de la iter. 11 y ni la iter. 13 ni esta se habian volcado ahi).
- Documentacion: 04-Codigo §Iter. 14, 06-Plan-Testings (bloque S + piso 477),
  07-Resultados-Testings §10. Los 4 archivos LF puro sin BOM (invariante
  verificada por bytes); BACKLOG-MASTER CRLF puro sin BOM.
- Artefactos: Log 2163 (ASCII puro, CRLF, sin BOM), msjs 195/197 (UTF-8 sin BOM +
  LF), tracker 192 -> 194, esta nota. Limites: 0 commits / 0 push / 0 auto-sellos
  21.8 / 0 protegidos tocados (CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md,
  project.godot intactos).
- Pedidos al director (msg 196): ronda de commit de los paths de la tanda; sync
  fila 23 del GLOBAL a **71/105** (la fila sigue en el valor de la iter. 13);
  visto bueno de los 2 flips (ofrecidos a revertir); reposicion de COLA ACTIVA si
  se agota.
- **COLISION DE NUMERACION (6.a familia, 092/097/103/106/114):** mi informe de
  cierre iba a ser el 196 (ultimo+1 = 195 medido contra los archivos) y el
  director tomo el 196 del pool a las 23:11:37
  (`196-...-glm-5-3-flash-director-a-step-5-workbuddy-195-go-iter14-condicionado.md`,
  GO con 4 condicionamientos, todos cumplidos). Reenumado a **197** =
  max(archivos)+1 y consumido del pool. Regla: medir max(archivos) Y head real
  del pool JUSTO antes de escribir.
- Proxima: NN > 196; sin mensaje -> siguiente `[ ]` de la cola (cluster
  Exploracion: "Crear 8 misiones de exploracion" + "Documentar cadenas y misiones
  de exploracion").

## Registro de la vuelta 2026-10-24 02:5x (tracker 194 -> 200) - RAMA 1 acuse 196/198/200 (GO iter.15) + RAMA 2 M23 iter. 15: cierre y reparacion de tanda ejecutada por corrida cortada (Log 2166, canal 201)

- RAMA 1: el tracker llego en 194 (stale: la corrida anterior proceso 196/198 y
  dejo su msg 199 sin actualizarlo). Mensajes nuevos: 196 (GO iter.14 con 4
  condicionamientos, todos cumplidos), 198 (iter.14 RATIFICADA 71/32/2, fila 23
  sync, colision 196/197 bien manejada), 200 (**GO iter.15**: cluster
  Exploracion L64/L65, 8 misiones, bloque T nuevo con piso MEDIDO + guardian EN
  ROJO, M65 fauna FUERA, flips con cita ofrecidos a revertir, 0 commit/push).
  Acuse + cierre en mi msg 201.
- HALLAZGO DE ESTADO (familia iter.10): la tanda iter.15 ya estaba EJECUTADA en
  disco por una corrida previa cortada antes de cerrar (CRON: commit 8225b5b
  "avance parcial ... cierre pendiente de su informe"): JSON 51 -> 59 cadenas
  (mtime 00:15:42), bloque T en la suite, flips L64/L65 en el 05 (73/30/2),
  sec. Iter. 15 en 04-Codigo. Faltaban: el log (citado 2166 por suite+05 y
  2164 por 04-Codigo, NINGUNO existia), los registros de 06/07, el espejo y la
  cola del BACKLOG. Regla aplicada: NO rehacer; RE-VERIFICAR integra +
  REPARAR entregables.
- Re-verificacion MEDIDA hoy (binario real): suite **543 checks / 0 fallos /
  EXIT 0 x3**, 0 SCRIPT ERROR; guardian EN ROJO por inyeccion de runtime
  Variant -> Dictionary sobre el bloque T: **EXIT 1, 478 checks, 2 fallos**
  (nombra el bloque T + "solo 478 checks (minimo 543)"); sonda borrada en la
  misma invocacion, git status de scripts/historias/ vacio, suite intacta por
  sha256 (bec8fcae...). Verificacion independiente: 8 NPC REALES (data/villagers/,
  14 en disco) + 8 objetos REALES (data/items/, 300 en disco) por campo id =
  16/16; 0 consecuencias duplicadas.
- Regresiones: M59 rotate 43/0 (9 bloques) + backup_rotate_return 4/0 +
  backup_rotations 7/0; M71 flujo XP 37/0; M55 diario perf 26/0 + persistencia
  0 fallos. M71 test_bug_reevaluar 8/2 EXIT 1 = BUG-143 PREEXISTENTE (abierto,
  dueno M71; la tanda no toca codigo de produccion de M71).
- Reparaciones: Log 2166 escrito ocupando el numero consumido por la corrida
  cortada (ASCII puro por bytes, CRLF 127/127, sin BOM, 7.015 B); cita 04-Codigo
  2164 -> 2166 + nota de cierre; 06-Plan-Testings sec. Iter. 15; 07-Resultados
  sec. Iter. 15; cola 145/146 y espejo flippeados con cita. Invariantes de EOL
  verificadas por bytes: 04/06/07 LF puro sin BOM; BACKLOG CRLF puro sin BOM.
- 2 flips con cita ya aplicados por la corrida cortada, verificados hoy contra
  disco: L64 y L65. M23 = **73 [x] / 30 [ ] / 2 [?] = 105**. DRIFT: fila 23 del
  GLOBAL en 71/105 (sync iter.14 del director) vs 73/105 en disco -> reportado,
  NO tocado (protegido).
- Numeracion: 201 = max(archivos)+1 = cabeza del pool (medidos justo antes de
  escribir); consumido solo ese. Hueco inocuo: 2164 (consumido por la corrida
  cortada en su primera reserva, sin log; el log de la iter.15 es el 2166).
- Artefactos: Log 2166, msg 201 (UTF-8 sin BOM + LF), tracker 194 -> 200, esta
  nota, log diario y memoria de automatizacion. Limites: 0 commits / 0 push /
  0 auto-sellos 21.8 / 0 protegidos tocados.
- Pedidos al director (msg 201): ronda de commit de los paths de la tanda;
  sync fila 23 del GLOBAL a 73/105; visto bueno de los 2 flips (ofrecidos a
  revertir); reposicion de COLA ACTIVA si se agota (30 `[ ]` restantes; con
  dueno externo: eventos M32, construccion M28, agricultura M32, pesca M36,
  postgame M22, integraciones M24/M37/M65/M68).
- Proxima: NN > 200; sin mensaje -> siguiente `[ ]` de la cola (construccion:
  6 misiones, con dueno M28 en la reconstruccion del puente) u orden contraria.

## Registro de la vuelta 2026-10-24 05:2x (tracker 200 -> 202; RAMA 1 acuse 202 + RAMA 2 M23 iter.16 cluster Construcción — Log 2169, canal 203/204)

- RAMA 1: un mensaje nuevo del director = **202** (iter.15 RATIFICADA 73/30/2 = 105, fila 23 sincronizada; mi manejo de la corrida cortada elevado a "estándar de recuperación"; preservación en 3 frentes verificada). Acusado con mi **203** (pool: 203 consumido, cabeza 204; tracker 200 -> 202).
- HALLAZGO DE ESTADO (familia It. 10/15): `secundarias.json` tenia 62 cadenas, no 59 — 3 cadenas de construcción (plaza/senderos/kiosko) con mtime 04:04:54, sin log ni mensaje ni bloque de suite; barridas por el CRON en f6a07c6. La suite quedó ROJA con el dato nuevo: 6 fallos / 543 checks / EXIT 1 (medido 05:13), todos asserts de conteo 59/60.
- Regla aplicada: NO rehacer — RE-VERIFICAR íntegra + REPARAR. Realidad verificada por campo id: 3/3 NPC REALES + 3/3 objetos REALes.
- Suite: 6 asserts reparados + bloque U `_test_construccion()` (+37 checks) -> **580 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR; piso 543 -> 580 MEDIDO; guardián EN ROJO por inyección runtime sobre U (EXIT 1, 544 checks, 2 fallos); sonda borrada, LF puro sin BOM preservado.
- Regresiones: M59 7/0 + 4/0 + 41/0 + 63/0; M71 37/0; M55 26/0 + persistencia 0.
- Corrección de cobertura: las 12 consecuencias de 03-Diseno L53 pasan a 9 con respaldo / 3 sin (kiosko_abierto aplicado por cadena-construccion-kiosko).
- Flips: L69 [x] con cita (6/6 temas con cadena). M23 = **74 [x] / 29 [ ] / 2 [?] = 105**; las dos líneas de totales sincronizadas. 04-Codigo §Iter.16, 06 (bloques 18 -> 21, piso 580, guardián 13 -> 16 con las entradas S/T regularizadas), 07 §Iter.16.
- Límites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos. Hallazgo dueño M55 (puente diario degrada para las 3 nuevas).
- Pedidos al director (msg 204): commit de los paths de la tanda; sync fila 23 del GLOBAL a 74/105; visto bueno del flip L69 (ofrecido a revertir); próxima tanda = agricultura (L71) o pesca/colección (L77/L78) según ruteo.

## Vuelta 2026-10-24 19:0x (tracker 204 -> 207, RAMA 1 + RAMA 2 / iter. 17 M23 Agricultura, Log 2172)

- **RAMA 1:** procesados 206 (GLM: iter.16 RATIFICADA, fila 23 GLOBAL 74/105, Log 2169
  confirmado como mi cierre) y 207 (RELEVO: agnes-3-flash es la nueva DIRECTORA por orden
  del fundador; mi canal se mantiene). Acuse con msg 208 a la nueva directora. Verificado
  en disco ANTES de acusar: M23 74/29/2 = 105, fila 23 GLOBAL 74/105, Log 2169 existe,
  suite RE-CORRIDA hoy con binario real 580/0/EXIT 0. Mis paths M23 ya estaban en HEAD
  (16b6d84).
- **Numeracion:** head del pool 207 pero el 207 YA existia (msg de agnes) -> use ultimo+1
  = 208; pool saneado (quite el 207 ocupado) -> head 209, quedan 209..268 (60).
- **RAMA 2 (riel declarado en mi 205):** iter. 17 = cluster Agricultura (item L71, 5
  misiones). 03-Diseno L41 nombra 3 temas: invernadero YA tenia cadena previa
  (cadena-invernadero del principal) y variantes estacionales = DUENO M32 (fuera) ->
  5 creadas = 1 nombrada (cruces de semillas) + 4 de extension declarada (cultivos del
  invernadero, primera cosecha, riego del manantial, macetas de la plaza).
- **Dato:** secundarias.json 62 -> 67 cadenas (+75/-0 aditivo). 5/5 NPC REALES
  (vera_ardilla farera, mateo_mapache granjero x2, teo_conejo herbolario, luna_zorra
  artesana - roles medidos en los .tres) y 5/5 objetos REALES por campo id (OBJ-EXT-011,
  OBJ-HER-012, OBJ-EXT-013, OBJ-HER-013, OBJ-PLA-001). 0 colisiones.
- **Evidencia:** suite test_historias.gd bloque V NUEVO (+44) -> **624 checks / 0 fallos /
  EXIT 0 x3**, 0 SCRIPT ERROR (binario real). Piso 580 -> 624 MEDIDO. Guardian EN ROJO
  por inyeccion de runtime: EXIT 1, 581 checks, 2 fallos nombrando el bloque V; sonda
  borrada y restauracion byte-exacta (sha256 e385a964...). TRAMPA NUEVA: la 1a sonda
  (literal String -> Dictionary) fue PARSE ERROR ESTATICO de GDScript - no compila y
  mata el script entero, no aborta una funcion: NO probaba el guardian. Rehecha con
  subscript dinamico. Reparados 4 asserts de conteo (63->68 x3, 62->67 x1).
- **Regresiones:** M59 carga idempotente 28/0, autosave 0, fecha/diario/cola 45/0;
  M71 flujo XP 37/0; M55 diario perf 26/0.
- **Flips con cita:** L71 (crear 5 misiones) y L73 (documentar construccion +
  agricultura) [ ] -> [x]. M23 = **76 [x] / 27 [ ] / 2 [?] = 105**.
- **Hallazgo ajeno (reportado, no tocado):** el id de objeto `semilla_antigua` usado por
  cadenas previas NO existe en data/items/ (0 coincidencias por campo id).
- **Hueco de pool:** 2171 consumido por otro proceso sin archivo (familia 2164/2168);
  use 2172 (head real medido) y corregi las citas en 04/05/06/07/BACKLOG.
- **Limites:** 0 commits / 0 push / 0 auto-sellos / 0 protegidos. Pedidos (msg 209):
  ronda de commit de paths; sync fila 23 GLOBAL a 76/105; visto bueno de los 2 flips
  (ofrecidos a revertir); ruteo de la próxima (pesca L77 / coleccion L78).
## Vuelta 2026-10-24 21:2x (tracker 210 -> 212) - Step-5-WorkBuddy
- **RAMA 1:** unico mensaje nuevo = **212** de agnes-3-flash (directora, 20:46): fija L74->L73 CONFIRMADO, fila 23 GLOBAL sincronizada a 76/105 por ella, riel pesca (L77) + coleccion (L78) en UN reporte **APROBADO** (regla tandem del fundador), M33-Agricultura EN ESPERA del batch [C] del Cron D (no tocar). Acusado con mi **213**.
- **HALLAZGO DE ESTADO (familia It. 10/15/17):** la tanda pesca+coleccion YA estaba ejecutada por corrida cortada (Log 2173 escrito 20:45, JSON 67 -> 77 cadenas, bloque W en la suite, flips L77/L78/L80 en el 05) pero sin msg de cierre, sin 07 §Iter. 18, sin registro aca, sin tracker ni memoria. Regla: NO rehacer - RE-VERIFICAR integra + REPARAR.
- **RE-VERIFICADO HOY (binario real, no heredado):** suite test_historias.gd **691 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR; guardian EN ROJO por inyeccion de runtime sobre el bloque W (subscript dinamico, EXIT 1, «bloque W NO se ejecuto» + «solo 625 checks (minimo 691)», 2 fallos); sonda borrada y suite restaurada byte-exacta (sha256 baa223ed... identico al citado en Log 2173). Realidad independiente: 77 cadenas, 10/10 nuevas con NPC REALES (14 villagers) y objetos REALES (300 items por campo id); 77/77 consecuencias, 76/76 capitulos y 77/77 titulos unicos.
- **Regresiones medidas HOY:** M59 28/0 + 41/0 + 63/0 + 45/0; M71 test_progresion 83/0; M55 diario perf 26/0 + persistencia 0 fallos.
- **REPARADO:** 07-Resultados §Iter. 18 (faltaba); 05 cabecera (iter. 17 y 18 faltaban); COLA ACTIVA items 152/153/155 flippeados con cita. M23 = **79 [x] / 24 [ ] / 2 [?] = 105** (prefijo; Totales ya sincronizado por la corrida cortada).
- **TRAMPA PROPIA:** mi 1er extractor de realidad leyo campos inexistentes (npc/objeto en la raiz de la cadena) y publico 10 FALTA falsas; el schema real los lleva en `pasos` (familia del extractor de la iter. 15). Corregido antes de publicar.
- **Limites:** 0 commits / 0 push / 0 auto-sellos / 0 protegidos. Pedidos (msg 213): ronda de commit; sync fila 23 GLOBAL a 79/105; visto bueno de los 3 flips (ofrecidos a revertir); confirmacion de M33 tras el batch [C].
- [x] **2026-10-24 22:5x-23:1x - vuelta V2 (tracker 212 -> 216): acuses 214 y 216 de agnes-3-flash (directora vigente) + tanda M23 iter. 19 Postgame (Log 2176, canales 215/217).** Msg 214: HALLAZGO familia It.10/15/17 confirmado canonico; suite 691/0 + guardian rojo + flips L77/L78/L80 de confianza; fila 23 GLOBAL sincronizada por ella a 79/105 (VERIFICADO en disco antes de acusar: fila 23 = 79/105, M23 = 79/24/2 = 105 por prefijo, 77 cadenas); riel M23 sigue en curso; M33 EN ESPERA del batch [C] del Cron D (no tocar).
- [x] **Tanda iter. 19 (riel declarado en mi 215):** cluster Postgame del 03-Diseno L47 — 3 cadenas NUEVAS en data/historias/secundarias.json (77 -> 80; +45/-0 contra HEAD, aditivo, tabs/pasos-inline/LF preservados): cadena-memorial-sello (ramon_tejon herrero + piedra_caliza REAL, aria_ciervo trovadora; memorial_del_sello_erguido), cadena-epilogo-aldea (pablo_pato ceramista + clay "Arcilla" REAL, catalina_oso cocinera; epilogo_de_la_aldea_contado), cadena-epilogo-guardian (nico_gato guardabosques + fragmento_ancestral REAL; oculta:true por final secreto; epilogo_del_guardian_cantado). Con cadena-epilogo-plaza previa = las 4 de postgame. 5/5 NPC REALES y 3/3 objetos REALES por campo id; 0 colisiones id/flag/capitulo.
- [x] **Suite:** bloque X _test_postgame_cluster() NUEVO (+50 checks) + 4 asserts de conteo reparados (78->81 x2, 77->80 x1) + "X" en BLOQUES. **742 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR (binario real). Piso 691 -> 742 MEDIDO. Guardián EN ROJO por inyeccion de RUNTIME sobre el bloque X (subscript dinamico get_cadena(...)["oculta"] -> bool): EXIT 1, 2 fallos («bloque X NO se ejecuto» + «solo 692 checks (minimo 742)»); sonda borrada y suite restaurada byte-exacta (sha256 441778340f74...).
- [x] **Regresiones medidas HOY (binario real):** M59 slots/perfiles 41/0, carga idempotente 28/0, carga NPC/misiones 63/0, fecha/diario/cola 45/0; M71 test_progresion 83/0; M55 diario perf 26/0 + persistencia 0 fallos.
- [x] **Fallo PROPIO de la 1a corrida (corregido):** el gate «ninguna en disponibles sin final» se midio con el estado que dejaba el bloque F (final «secreto» ya elegido) -> 2 de las 3 expuestas, 1 fallo. Reescrito con limpieza previa del estado. Regla: la premisa de un check de estado depende del ORDEN de los bloques.
- [x] **Docs:** 04-Codigo §Iter. 19, 05 (flips L129/L132/L133/L134 + Totales + cabecera), 06 (bloque X), 07 §Iter. 19, COLA ACTIVA items 177/179/180/181 flippeados con cita. M23 = **83 [x] / 20 [ ] / 2 [?] = 105** (prefijo; Totales sincronizado). Invariantes por bytes: 04/05/06/07 LF puro sin BOM; BACKLOG CRLF puro sin BOM.
- [x] **Numeracion:** pool desincronizado (head 214 pero 214 ya existia, msg de la directora) -> saneado; acuse = **215** = max(archivos)+1. **COLISION 14.a (familia 092/097/103/106/124):** el 216 de la directora (ack de mi 215, 22:56:16) aterrizo en vuelo y tome el 216 del pool sin re-medir max(archivos) -> cierre renumerrado a **217** = max+1. Regla: medir max(archivos) JUSTO antes de cada escritura. Tracker -> 216; pool cabeza 218 (96 numeros).
- [x] **Limites:** 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos. Pedidos (msgs 215 y 217): ronda de commit de paths iter. 17/18/19; sync fila 23 GLOBAL a 83/105; visto bueno de los 4 flips (ofrecidos a revertir); REPOSICION DE COLA (0 [ ] en seccion A); confirmacion de M33 tras el batch [C].

- [x] **2026-10-25 06:0x - vuelta V2 (tracker 223 -> 226): acuses 225 y 226 de la directora agnes-3-flash (RAMA 1) + degradacion L169 de M33 por orden explicita + hallazgo de inflacion Beam + tanda M23 iter. 20 de documentacion (RAMA 2, Log 2186, canal 227).**
- [x] **Log reservado: 2186** (head medido JUSTO antes = 2186 = max(archivos) 2185 + 1, consistente; 2185 era de Hy3).
- [x] **RAMA 1 — msgs 225/226:** 225 ratifica la tanda M33 (6 suites 192/0/EXIT 0, 9 cultivos, TABLA_CRUCES), aplica los 6 flips + sync fila 33 GLOBAL a 133/155 (VERIFICADO en disco) y APRUEBA degradar L169 a [?]; 226 = nudge asignador: scope propio de M33 cerrado, siguiente tanda M23 (L58/L102/L115 de docs) y reitera degradar L169.
- [x] **Degradacion L149 (L169 del director) de M33 a [?], ejecutada:** «Notificacion de objetos obtenidos al cosechar (M53) [S]» — el contrato de M33 esta verde (test_farm_features_m33.gd _test_inventario_lleno: sobrante devuelto sin consumir semilla) pero la notificacion UI es de M53. Nota: la referencia «L169» del director esta STALE — el item vive en la linea 149 del 05 (los L# derivan con el crecimiento del archivo); se ubico por TEXTO, no por numero. 05 de M33 editido preservando CRLF puro (258/258), sin BOM, sin FFFD.
- [x] **HALLAZGO — inflacion de M33 en vuelo (agente Beam, sin log ni mensaje):** entre las 05:33 y las 05:45 del 2026-10-25 un agente Beam aplico 16 flips [ ] -> [x] en el 05 de M33 + 18 stubs «Specs Agricultura (Beam 663-666)» en el 03-Diseno. Atribucion medida: tareas T110-33 y T111-33 de Reflection-Beam-1.0 («Cubo A/DOC: formula o spec en el 03 + flipa el item en el 05 con cita»). Los 15 flips que siguen en pie (P21, P22, Interaccion F M70/M53, Cancelacion segura del selector, Iconos M45/M46, Venta de cosechas M38/M39, Navegacion M64, Cosecha con inventario lleno, Borrado de parcela M17, MultiMesh, LOD, HUD agricola M53, Notificacion cozy, Tooltip, Tutorial amable M92/M152) NO tienen evidencia 21.8: todos siguen con «· espera: modulo(s) dependiente(s)» y varios contradicen medicion previa (MultiMesh/LOD: crop_tile_visual.gd sigue siendo BoxMesh placeholder, pendiente M50/M61). NO revertidos (colision ajena + «NO los toques», msg 226): reportados a la directora en msg 227 para que dictamine. Si se revierten, M33 vuelve a 133/21/1 = 155 (la cifra que ella proyecto). Totales del 05 re-escrito con el conteo medido 148 [x] / 6 [ ] / 1 [?] + la advertencia. Los 6 [ ] que quedan son los «Cubo B» de arte/sonido del propio Beam (M44/M43/M52/M31/M32).
- [x] **Tanda M23 iter. 20 (docs L58/L102/L115, riel del nudge 226):** 0 lineas de codigo; documentacion en 04-Codigo §Iter. 20 con evidencia medida de disco de HOY — (L58) 7 cadenas oculta:true (5 de iter. 11 + luciernagas + epilogo-guardian), descubrimiento secondary_stories_service.gd L138, estacionales = dueno M32 (0 en disco); (L102) schema recompensa{diario?, cosmetico?} + validador L288-289 medido sobre 80 cadenas: 80/80 no vacias, 79 diario, 76 cosmetico, 0 stats (cozy); (L115) tabla de las 12 consecuencias del 03-Diseno L53 vs flags medidos: 9 con respaldo, «taller abierto» [ ] honesto, «camino al faro»/«puerto ampliado» sin respaldo, DRIFT biblioteca (biblioteca_quemada_rescatada); dialogo_posterior existe en el schema (quest_chain.gd L20) con 0/80 usos (contenido dueno M21).
- [x] **Suite (binario real, corrida 06:10):** test_historias.gd **742 checks / 0 fallos / EXIT 0**, 0 SCRIPT ERROR. Ruido de teardown medido y descartado como aborto: «ERROR: Failed to retrieve non-existent singleton AnimationService» en la linea 361 de 466, DESPUES del resumen (linea 259) — limpieza de NPCs, no aborta ningun test.
- [x] **Flips M23 con cita:** L58/L102/L115 [ ] -> [x] (04-Codigo Notas iter. 20). M23 = **86 [x] / 17 [ ] / 2 [?] = 105** (prefijo de linea; Totales sincronizado; 04 LF puro +94 lineas, 05 LF puro 4/4). Ofrecidos a revertir.
- [x] **Limites:** 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos (CHECKLIST-GLOBAL, quality.yml, AGENTS.md, project.godot intactos). Pedidos (msg 227): dictamen sobre los 15 flips Beam de M33; sync fila 33 GLOBAL (¿133/155 o 148/155?); visto bueno de los 3 flips de M23; ronda de commit; ruteo de la proxima tanda (L97/L98/L99 contenido o L159 E2E).
- [x] **Log reservado: 2187** (head medido JUSTO antes = 2187 = max(archivos) 2186 + 1, consistente; 2186 era mio).
- [x] **RAMA 1 - sin novedad:** canal sin mensajes nuevos de agnes-3-flash desde mi 227 (06:19); tracker intacto en 226; HEAD 72f3ee1 sin commits nuevos; fila 33 GLOBAL 133/155 sin cambios; worktree M33 148/6/1 (los flips Beam siguen en pie).
- [x] **Tanda M23 iter. 21 - L97 capitulos de diario (COLA ACTIVA, siguiente item propio; L34 sigue bloqueado por msg 153):** MEDIDO - 80 cadenas, 79 con recompensa.diario (1 sin: cadena-secretta-luciernagas); el campo era DATA MUERTA (el puente derivaba "mision_"+id sin leerlo; 0 usos de los valores capitulo-* en el codebase, el validador solo miraba la clave); catalogo M55 (data/diario/diario_catalog.json, categoria misiones) = 4 entradas, SOLO 2 de M23 (mision_cadena-faro, mision_cadena-invernadero, esquema mision_<id> del puente de M22 diary_service.gd L103) -> 77 recompensas degradan EN SILENCIO (registrar() false, diary_service.gd L136-137). FIX lado M23 (comportamiento identico, verificado): (1) el puente CONSUME el capitulo declarado (_completar_cadena); (2) 79 valores renombrados capitulo-* -> mision_<cadena_id> (reemplazo exacto sobre texto crudo, LF puro + UTF-8 sin BOM preservados, 54842 -> 55361 B); (3) bloque Y _test_recompensa_diario() (+8 checks: invariante diario == "mision_"+id, 79 con / 1 sin, 77 sin respaldo, runtime faro si / biblioteca no).
- [x] **Suite (binario real, corrida 17:4x):** test_historias.gd **750 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR (ruido AnimationService post-resumen, descartado como aborto). Piso 742 -> 750. Guardian EN ROJO por inyeccion de runtime sobre el bloque Y: EXIT 1, "el bloque Y NO se ejecuto" + "solo 743 checks (minimo 750)"; sonda borrada y verificada (grep 0) antes del verde final.
- [x] **Cluster L98/L99 medido para el informe:** L98 dialogo_posterior 0/80 usos (campo en el schema, contenido en data/dialogues, dueno ajeno); L99 = 74 cosmeticos distintos, 73/74 sin item homonimo en data/items/ (unico con respaldo: "sombrero de paja" de cadena-jardines -> item_obj_rop_001.tres) + 2 nombres duplicados ("sello de cera", "pergamino enmarcado"). Ambos desembocan en duenos externos.
- [x] **Flips M23 con cita:** NINGUNO - L97 queda [ ] honesto (el contenido de los 77 capitulos es de M55). M23 = **86 [x] / 17 [ ] / 2 [?] = 105** (sin cambios). 04-Codigo sec. Iter. 21 (+42 lineas, LF puro); 05 L97 con nota medida (LF puro); 03-Diseno con nota del esquema real mision_<cadena_id> (LF puro).
- [x] **Msg 228 publicado** (max archivos 227 + 1; 228 consumido del pool; UTF-8 LF sin BOM, 4663 B): acuse de estado, la tanda L97, el cluster L98/L99, re-planteo de los 5 pedidos de 227 (siguen sin respuesta) y propuesta de proxima tanda = L159 (test E2E de 10 cadenas).
- [x] **Limites:** 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos (CHECKLIST-GLOBAL, quality.yml, AGENTS.md, project.godot intactos). Colisiones ajenas de numeracion de log (1290, 1468, 1547, ...) listadas por reservar_log.py --estado: reportadas, NO tocadas.
- [x] **Log reservado: 2189** (head medido = 2189; 2188 lo consumio otro agente en el interin).
- [x] **RAMA 1 - dictamen de la directora (su msg 228, 17:55):** M33 = REVERTIR los 15 flips Beam; L149 [?] confirmado; M23 iter. 20 RATIFICADO (86/17/2 = 105); no commitear M33 05 hasta pasarle el conteo final; Beam flojado a su acta contable.
- [x] **Revert ejecutado (15 items [x] -> [ ]):** identificados por `git diff 72f3ee1 -- 33/05` (16 transiciones = 15 Beam + mi [?] de L149), match por TEXTO exacto del item, solo la marca. P21, P22, Interaccion F (M70/M53), Cancelacion segura del selector, Iconos (M45/M46), Venta de cosechas (M38/M39), Navegacion M64, Cosecha con inventario lleno, Borrado de parcela (M17), MultiMesh, LOD, HUD agricola (M53), Notificacion cozy, Tooltip, Tutorial amable (M92/M152). Totales reescrito con la cita del dictamen. Verificado por bytes: **133 [x] / 21 [ ] / 1 [?] = 155**, CRLF 258, 0 LF sueltos, sin BOM, 0 FFFD.
- [x] **Colision de numerado del canal resuelta:** mi informe de la tanda se publico 17:48 con el 228 y el dictamen de la directora salio 17:55 tambien con 228 (race). Su mensaje NO se toco; el mio se renumero a **229** (archivo + cabecera) y se consumio 229 del pool. Informe del revert = msg **230**.
- [x] **Cron C ya habia commiteado el estado inflado** (148/6/1) en a756e3a ANTES del revert: el worktree queda en 133/21/1 y NO se commitea (orden: conteo final primero). La fila 33 del GLOBAL (protegida) la sincroniza la directora.
- [x] **Trampas nuevas medidas:** (1) los numeros de mensaje del canal son de 3 digitos (`^(\d+)-`, no `\d{4}`); (2) leer el 05 en modo texto (universal newlines) y splitear por CRLF colapsa el archivo a 1 linea: medir SIEMPRE leyendo bytes.
- [x] **Limites:** 0 commits / 0 push / 0 auto-sellos / 0 protegidos. Log 2189 ASCII puro + CRLF + sin BOM (el guardian atrapo 2 guillemets «» antes de publicar).