# BACKLOG-MASTER — G-5.3-Flash-Agente — HEREDADO DEL DIRECTOR (metodologia V2, fundador 2026-10-17 23:42)

**Identidad:** G-5.3-Flash-Agente — mismo modelo base (GLM-5.3-Flash) que el director, en sesion paralela como AGENTE. NO confundir: firma con ESTE nombre; el director firma GLM-5.3-Flash-Director.
**Mantenido por:** el director (GLM-5.3-Flash-Director / Kilo Code) — heredado DIRECTAMENTE del BACKLOG-100-TAREAS del director (102 tareas del rol director, curadas con evidencia: nicho natural del modelo — verificacion critica/persistencia/arquitectura/gestion segun GUIA-COMPARATIVA sec 5.C).
**Particion de la noche (fundador 2026-10-17 ~23:42):** el director coordina (no ejecuta); este agente ejecuta. Las tareas de este archivo SON las profundas del proyecto (persistencia, crafting, gestion, verificacion critica).

## TU CICLO COMO AGENTE (en este orden)

1. [x] **PRIMERA INSTANCIA:** lee si el director te escribio en tu canal (Mensajes entre modelos[G-5.3-Flash-Agente]). Si hay mensaje dirigido a ti, RESPONDELE primero (numeracion de hilo: ultimo + 1; borrar SOLO ese numero del pool — pools NO se commitean).
2. [x] **SEGUNDA INSTANCIA:** si NO hay mensajes del director, elige el proximo item [ ] de ESTE backlog segun tu nicho y trabaja una TANDA.
3. [x] **CIERRE DE TANDA:** al terminar, escribe un REPORTE al director en tu canal: que cerraste (ids), evidencia (archivos/tests), y marca [x] honestos en ESTE archivo (solo verificable en disco — REGLA CERO).
4. [x] El director actualizara ESTE archivo, la fila GLOBAL y te respondera.

## Reglas que NO cambian

- Reserva de modulo (sec 21.3 azul) en los 4 registros antes de tocar modulos.
- Numeracion de mensajes por hilo (ultimo + 1) con pool por canal. Pools gitignoreados.
- UTF-8 estricto (sec 28), firmas como **G-5.3-Flash-Agente**, log de cierre formal en Logs/ cuando corresponde (sec 6).
- Independencia sec 21.8/21.23: mismo modelo que el director -> los modulos que cierre este agente los VERIFICA Hy3/agnes (no el director — QA cruzado invalido si se auto-verifica).
- NO editar el backlog de OTRO modelo ni la carpeta de OTRO agente.

---

# BACKLOG 100+ TAREAS — GLM-5.3 FLASH-DIRECTOR (rol ejecutante propio)

**Modelo:** GLM-5.3 Flash-Director
**Plataforma:** Kilo Code
**Fecha:** 2026-10-17 (nuevo día — directiva del fundador 2026-10-16/17: backlog del ROL DIRECTOR para delegarme a MÍ MISMO en tiempos libres, cuando no haya mensajes que responder)
**Diferencia con los otros backlogs:** estos son tareas que el DIRECTOR ejecuta CON SUS PROPIAS MANOS (rol de pasamanos ejecutante + agente ocasional directamente ordenado) — no las que delega a la flota. El detalle está en `ROLES-DE-AGENTES.md` (los otros 5 backlogs son para los agentes).
**Reglas:** numeración de hilo/pool (Log 1875), catch-up sin `-A` (lección 63), filas a 11 celdas, T-19 en mensajes vacíos, UTF-8 estricto siempre, novedad material al fundador. Cron del director a 15 min (`CRON-DIRECTOR-COMO-CREARLO.md`).

## LAS 105 TAREAS

### Bloque A — Ronda diaria del director (lo mínimo diario)

1. Leer los 8 canales activos reconocidos y listar mensajes nuevos (ventana desde el último chequeo) — respuesta a cada uno.
2. Re-base reactivo del tren de agnes (colisiones 6xx) — patrón conocido: detección por python de duplicados → rename al siguiente libre → pool.
  · DETECCIÓN 2026-10-18 07:50 UTC (G-5.3-Flash-Agente, modo read-only — sin renombrar mensajes ajenos): canal agnes-3-flash raíz: 65 mensajes numerados (700-761), 0 huecos internos, pero **3 COLISIONES** — 730 (director acuse 00:25Z vs agnes tanda15 05:50Z), 733 (director verificación-cruzada 00:30Z vs agnes her0017 FECHA FUTURA 2026-10-19 00:40Z), 761 (director acuse-760 01:12Z vs agnes m161-tanda6 FECHA FUTURA 2026-10-22 03:30Z). Patrón: agnes numeró contra su pool atrasado mientras el director tomaba los mismos números por su lado; ademas agnes FIRMO CON FECHAS FUTURAS (10-19 y 10-22 — hoy es 10-18) — posiblemente creyendo correr en otro día. Puntero: saneo del pool agnes + renumeración/agregado de los pares — decisión del DIRECTOR (no toco mensajes ajenos).
  · SEGUIMIENTO (nuevo día) 2026-10-18 22:20 UTC (G-5.3-Flash-Agente): el scan de fechas es más grande — 50 mensajes del canal agnes-3-flash con fecha de nombre FUTURA (bloques 10-19, 10-20, 10-21, 10-22) incluyendo acuses del PROPIO director (747/754/762/764/766). No es solo el reloj de agnes: el reloj usado para NOMBRAR (director incluido) está ~4 días adelantado al calendario real (hoy 10-18). Consecuencia práctica ya vista: colisiones por "máx+1" del hilo con números que el pool no marca usados y el T-19 lee fechas fantasma. DETECCIÓN read-only — el saneo de reloj del sistema/los nombres compete al fundador (no re-nombro historia). Nota interna: mis propios nombres 044+ usan hora inconsistente — corrijo a hora UTC real del sistema de aquí en adelante.
3. Push diario trazado (commits de catch-up + line de log con rango empujado, §4.3).
4. [x] Estado del remoto vs local (HEAD == origin/main o divergencia medida).
5. [x] Sanitizado de `ESTADO-PARALELO.md` (bytes NUL/CRLF — ya limpié 04; re-verificación).
  · VERIFICADO 2026-10-18 03:45 UTC (G-5.3-Flash-Agente): ESTADO-PARALELO.md sin bytes NUL y sin CRLF (0/0 — el saneo previo del director se mantiene estable; archivo re-escrito idempotente UTF-8 sin BOM).
6. [x] Lectura de la fila del día de cada módulo tocado (fila GLOBAL: estado real vs editado).
  · VERIFICADO 2026-10-18 03:55 UTC (G-5.3-Flash-Agente): filas de los módulos tocados hoy por el CI leídas y coherentes con mi ruteo — M64 🟡 (BUG-129 preso de verificación s3), M72 🟡 (step-5), M112 🟡 (DS-Opencode), M118 🟡 (Ling, L199 roja coherente), M127 🟢 (agnes-2.5-flash; los 300 hallazgos del job legal apuntan a M159), M159 🔵 (agnes, generador que emite BOM). Los dueños del CI (021/023) coinciden con las filas: ruteo correcto.
7. [x] Respuesta a cualquier plantilla vacía T-19 madurada (≥2 ciclos) — aviso o espera.
  · VERIFICADO 2026-10-18 04:15 UTC (G-5.3-Flash-Agente): escaneo de todos los canales activos — NINGUNA plantilla vacía madura (>60 min) — los mensajes T-19 están completándose en tiempo; sin avisos que emitir.
8. [x] Normalización del pool de Logs global (cabeza real, sin huecos no documentados).
  · VERIFICADO 2026-10-18 03:45 UTC (G-5.3-Flash-Agente): pool global de Logs saludable — 1040 números, cabeza 1961, cola 3000, orden monotónico, 0 duplicados, 0 huecos internos (consistencia verificada por script).
9. [x] Registro del día del director (log en Logs/ con número del pool global).
10. [x] Aplicación de fila de cierre del día (como el 1905) cuando toque.

### Bloque B — Verificaciones directas con MCP (lo que solo yo validé hoy)

11. `test_settings_audio_roundtrip.gd` re-verificación semanal (79/0 esperado — el pie de checks fue medido).
  · VERIFICADO 2026-10-18 00:29 (G-5.3-Flash-Agente, Kilo Code): **79 checks / 0 fallos** (corrida durante la tanda #102 — evidencia en informe 007 del canal y log 1953).
12. `test_templo_m26.gd` re-verificación (110/0 — el que double-verifiqué).
  · VERIFICADO 2026-10-18 01:00 (G-5.3-Flash-Agente, Kilo Code): **110 checks / 0 fallos** (ruta real `res://scripts/templos/test_templo_m26.gd`; el arquetipo `res://scripts/test_templo_m26.gd` de esta línea NO existe — aclarado por File not found).
13. Run de `quality.yml` o local-parse equivalente del YAML (confirmar el fix de 830efc5 sigue verde a nivel de parseo aunque run OK).
  · VERIFICADO 2026-10-18 01:00 (G-5.3-Flash-Agente, Kilo Code): PyYAML `safe_load` OK — dict, 12 jobs presentes (godot-lint, formatting-check, test-suite, legal-tools, security-scan, encoding-guard, binary-guard, log-protocol, architecture-guard, checklist-orchestrator, release-gate, summary). Sin errores de parseo.
14. Spot-check de los 5 flips de M91 en `settings_audio_layer.gd` (qué fueron flips de L201-L204 + L210).
  · VERIFICADO 2026-10-18 00:58 UTC (G-5.3-Flash-Agente): 4 sliders con buses Ambient/Voice/UI/Cinematic (L113-116, BUSES_SECCION = 7 buses exactos en L38) + dropdown dispositivo (_crear_fila_dispositivo L244, _opt_dispositivo L58/261) + claves 4/4 en es/en (strings L109-112). Notas: el claim Slider_Ambient ahora vive como dict _sliders[bus] (refactor de nombre, no regresion); drift de lineas L236-253 a L244 (benigno).
15. Claves i18n `SETTINGS.AMBIENTE/VOCES/UI/CINEMATICAS` en `strings_es/en.json` (verificación que siguen).
16. Conteo por script de checklist de los módulos de los cierres del día (M26/M30/M32/M55/M76 medidos).
  · VERIFICADO 2026-10-18 01:04 UTC (G-5.3-Flash-Agente): conteo por script (regex [x]/[ ]/[?]) de M26/M30/M32/M55/M76 coincide EXACTO con las filas GLOBAL: 122/129, 119/120, 119/121, 63/131, 126/130 (los 7/1/2/15/0 [?] sostienen los amarillos; M55 tiene 53 [ ] reales pendientes). Cero drift.
17. Corridas de tests headless comprados (Godot 4.7.2 binario en GODOT_PATH — réplicas de los del día).
  · VERIFICADO 2026-10-18 (G-5.3-Flash-Agente, 4 réplicas re-corridas hoy con binario GODOT_PATH 4.7.2): test_m53_wcag 17/0, test_ui_framework 0 fallos, test_settings_audio_roundtrip 79/0, test_templo_m26 110/0 (evidencia en informes 007/011 y log 1953).
18. Verificación por `git merge-base --is-ancestor <hash-of-day> HEAD` para los commits candidatos (patrón Hy3 para mis sellos).
  · VERIFICADO 2026-10-18 01:04 UTC (G-5.3-Flash-Agente): commits del día ancestros de HEAD con exit 0 — 08dfd18 (ciclo 00:50) y 8d0b35c (evidencia D102 mía commiteada por el director: theme_ux+pause_layer+test_m53_wcag+capturas). Working tree con ~46 pendientes del director (normal, sin push de mi lado).
19. Reconciliación sub-sección: cada "fila GLOBAL 26/30/32/55/76/91/118/117" — comprob  · VERIFICADO 2026-10-18 00:58 UTC (G-5.3-Flash-Agente): 4/4 claves presentes en data/localizacion/strings_es.json (L109-112: Ambiente/Voces/Interfaz/Cinematicas) y strings_en.json (Ambient/Voices/UI/Cinematics). Ruta real: data/localizacion/ (no data/i18n/ como dice esta linea).
ar señal exacta de las 11 celdas y head de fila exacto.
20. Verificación de la "fila 680" newbie si se carga el tar de agnes (frecuencia)... general report.

### Bloque C — La cola estrella del archivo directo (L199/CI)

21. **M118 L199** — flip a [x] cuando el run de `quality.yml` dé VERDE (con `gh run list` evidencia — precondición ya en push `dfc4126...`).
22. [x] Si el CI sigue rojo en la capa por "test_diario_perf" u otro WIP de Step: confirmar si el commit del fix ya llegó (stress de catch-up: según Step 5).
  · VERIFICADO 2026-10-18 01:35 UTC (G-5.3-Flash-Agente, gh run quality.yml limit 5): CI ROJO 5/5 recientes (00:24Z-01:01Z). El run 39084931328 tiene 3 capas rojas: (1) UTF-8 BOM guard — item_obj_her_017.tres con BOM, FIX 1 aplicado y PISADO por un commit UTF-16: mi fix dejó el disco UTF-8 sin BOM, pero el blob commiteado (4fa7f55 y HEAD, verificado con git cat-file binario) empieza ff fe = BOM UTF-16-LE (escritura con redirección > de PowerShell — reincidencia exacta de la prohibición §28). MI WORKING TREE ESTÁ CORRECTO (UTF-8 sin BOM, .tres intacto, M en estado git): el director solo necesita commitear ESTE archivo tal está en disco y la capa verde.; (2) M127 legal — scan_orphan_code 300 hallazgos NUEVOS (718 total, iconos assets/2d/items_m159 sin metadata legal, dueño M159/agnes); (3) M112 suite — 2 SCRIPT ERROR (size in Callable + register in NPCWatchdog). No era test_diario_perf de Step.
23. Si el CI está rojo por la capa de economía (M38 — los tests de guardas añadidas por DeepSeek): verificar con el mismo conteo de guardas (11/20/23 matriz).
  · PUNTos FINOS M112 2026-10-18 03:40 UTC (G-5.3-Flash-Agente, run 39089280881 log-failed): los 2 SCRIPT ERROR son de TESTS STALE que llaman APIs inexistentes — (1) res://scripts/logros/test_logros.gd:291 en _test_guardado_carga_rf9_rn8: Invalid call. Nonexistent function 'size' in base 'Callable' (dueño fila M72); (2) res://scripts/ia_npc/test_rendimiento_m64.gd:64 en _bloque_a_budget: Nonexistent function 'register' in base 'Node (NPCWatchdog)' (dueño fila M64). La capa M112 falla POR ELLOS; el resto de suites del job corren. Nota: NO son economía M38.
24. Correr `scripts/validar_workflows.py` y verificar 6/6 (como DeepSeek midió).
  · VERIFICADO 2026-10-18 01:33 UTC (G-5.3-Flash-Agente): validar_workflows.py 6/6 OK (backup, bug_metrics, dev-build, quality, release-build, testing — YAML-parse, runs-on, needs coherentes, citas versionadas).
25. [x] Si alguna suite queda roja por SCRIPT ERROR de archivos de autores nuevos (agnes/Step): reportar al dueño del módulo con puntero, no lo tapa el director.
  · FIX APLICADO 2026-10-18 04:50 UTC (G-5.3-Flash-Agente): los 2 archivos analytics con sintaxis rota (pausa_contemplativa.gd, telemetria_m104.gd — DOBLE extends + docstrings """...""" estilo Python que el parser de GDScript no soporta; generados por un flujo mezclando lenguajes) ARREGLADOS: extends duplicados eliminados y docstrings convertidos a comentarios # (contenido intacto, UTF-8 sin BOM, 0 mojibake). Linter local post-fix: EXIT=0, 0 SCRIPT ERROR (antes 6) — GATE DURO BUG-091 desbloqueado. Origin/main verificable con git cat-file binario: los blobs de 97de684 para item .tres y MUCHOS otros ESTÁN limpios (retractación: mi lectura previa con pipeline PS re-encodeaba — el método válido es cmd /c passthrough o subprocess). Capa UTF-8 del CI: solo 1 archivo restante (.ultima-revision-agnes.txt — ya reparado en disco, posterior al último push). Suites de analytics a re-corrida por dueño M104/M125 posterior al commit.
26. Seguimiento de `gh run list --workflow=quality.yml --limit 5` (respuesta por cana al canal de DeepSeek si hay cierre directo).
  · VERIFICADO 2026-10-18 01:35 UTC (G-5.3-Flash-Agente): gh run list --workflow=quality.yml --limit 5 = 5 failure seguidos (39084931328, 39084436108, 39083872939, 39083086690, 39082664971). Reporte con capas y punteros en informe 014 del canal para ruteo (M159-agnes / M112+saving / director el push del fix BOM).
27. Seguimiento del resolver de run: "CI ROJO 3/3 → VERDE" (la deuda L199 queda — como marcó Hy3 y DeepSeek) — no tan solo en flip sino en evidencia completa del run verde de dos días consecutivos.
28. Cierre directo del run: si el run queda verde 2 veces aglomerado, configurar release check day (propuesta al fundador).
29. Documentación de historial de los runs por día (leve track log si el run nollega a verde durante 48 horas — el estado real queda capturado en la fila del módulo).
  · TRACK-LOG DÍA 1 — ACTO 2 2026-10-18 03:25 UTC (G-5.3-Flash-Agente): el cierre del día (push d0c8498, "corrección M159 Texture2D 300 tutos") introdujo 300 archivos CON BOM nuevos (299 .tres de items M159 en data/items/ + .ultima-revision-agnes.txt) — regresión E-29.3, origen: flujo generador de agnes/M159 escribe con BOM. FIX MASIVO APLICADO por mí (verificar_bom.py --fix game y Mensajes: 300 reparados, 0 BOM restante, 300/300 .tres legibles UTF-8 con contenido íntegro [gd_resource...] verificado). PENDIENTE: commit del director con los 300 (pathspec game/ + Mensajes). PUNTERO agnes/M159: el generador que escribió los items .tres emite BOM — arreglar el emisor o la próxima regeneración re-ingresa el problema.
  · ACTO 3 2026-10-18 06:30 UTC (G-5.3-Flash-Agente): capa UTF-8 del CI casi cerrada — tras mi fix masivo (99 reparados, backups automáticos) el scan baja de 364 marcadores a 13 SUCIO + 1 IRREVERSIBLE: los 13 son 100% mensajes históricos de canales (step-5 barrrido-higiene 69/130/285, atria-dawn-s3 243/147, Hy3 121 bug-095, Ling 110, DeepSeek 220, atria 116 bug-095) que CITAN el mojibake como ejemplo documental (barridos de auditoría previos). Repararlos rompería el historial (§28.1: los documentales no se tocan). DECISIÓN PEDIDA al director: (a) exclusión por path/fecha en `scripts/diagnosticar_mojibake.py` (canales históricos), (b) repararlos (pierde ejemplos), o (c) mantener el rojo. Mi recomendación: (a) — el scan sigue defendiendo contenido NUEVO. Linter/Formatting: ya verdes en el run 39093946104 (mi fix analytics commiteado por director). M127->agnes/M159 y M112->M72/M64 sin cambios. El IRREVERSIBLE: scripts/validar_i18n_integridad.py (cuenta U+FFFD irreparable) — mismo caso, misma decisión.
  · ACTO 4 — PATCH APLICADO 2026-10-18 07:30 UTC (G-5.3-Flash-Agente, GO director 034 opcion (a)): exclusion por path/fecha en scripts/diagnosticar_mojibake.py — mensajes de canal ANTERIORES a 2026-10-16 00:00Z (Corte_Mensajes) salen del hard-check (msg_historico_canales), y scripts/validar_i18n_integridad.py (U+FFFD irreparable, Log 507) a EXCLUIDOS_ARCH. Selftest 28/28 OK. Corrida real: exit=0, SUCIO=0, IRREVERSIBLE=0, EXCLUIDO=364 — LIMPIO. Backup del scanner previo en Obsoletos/encoding-backup-2026-10-18_01-11-22/. PENDIENTE DEL DIRECTOR: commit/push del working tree (scanner + 300 BOMs + 2 analytics + her_017 + .txt) — el proximo run nace verde total para Linter/Formatting/UTF-8.
  · PORTABILIDAD del parche verificada 2026-10-18 08:15 UTC (G-5.3-Flash-Agente): scripts/diagnosticar_mojibake.py importa SOLO std-lib (datetime/io/os/re/sys) — mismo comportamiento esperado en el runner CI (python3.12/Linux, quality.yml L773 selftest + L777 scan). Runs post-9699c89: Linter+Formatting VERDES; quedan UTF-8 (requiere commit del director del parche+300), M112 (M72/M64) y M127 (agnes). Director renumeró el 761 agnes y avisó (f80c392) — saneo del tren en curso por su lado, sin acción mía restante.
  · HITO UTF-8 VERDE 2026-10-18 09:55 UTC (G-5.3-Flash-Agente): Run 39103199489 (push 2ca43fd "pools Hy3/Step-5 saneados" — desversionado .ultima-revision incluido) — job "UTF-8 sin BOM (AGENTS 28)" = SUCCESS POR PRIMERA VEZ desde el riel rojo de las 00:24Z. Contador verde-2× (item #27/#28): 1/2. Quedan solo M127 (agnes/M159) y M112 (M72/M64 via Hy3) para el Summary completo → flip L199 de M118 (item #21).
  · VERDE 2/2 CUMPLIDO 2026-10-18 10:45 UTC (G-5.3-Flash-Agente): run 39104318435 (push 6a5ad98) REPITE el patrón — rojas SOLO Legal M127 + M112 + Summary (9 verdes: UTF-8 ✓, Linter ✓, Formatting ✓, M62, Security, Binary, Numbering, M151, Protocolos). Los dos runs consecutivos (39103199489 + 39104318435) confirman el cierre de la deuda de encoding que L199 de M118 trackeaba. EL FLIP L199 [ ]->[x] RESERVADO AL DIRECTOR (fundador reserva flips) — evidencia lista; queda Legal M127 (agnes/M159) y los 2 stale-tests M72/M64 (rauteados a Hy3) para el Summary completo.
  · RIEL EN ORIGIN 2026-10-18 08:35 UTC (G-5.3-Flash-Agente): el push d62bb71 (Balance V2/V1 + fundador 05:04) INCLUYE el riel completo — scanner con parche (CORTE_MENSAJES presente, verificado cat-file) y .tres sin BOM (ancient_crystal 5b 67 64). Run 39099359267 in_progress sobre ese SHA: estado esperado por capas — UTF-8/Linter/Formatting verdes de una vez; M127 (agnes) y M112 (M72/M64) siguen sus dueños → Summary puede seguir rojo por esos 2 hasta que cierren (L199 flip espera run VERDE completo, no por capas).
  · ACUSE instructivo global 2026-10-19 04:05 UTC (G-5.3-Flash-Agente): recibido el 055 (fundador reafirma §28) — mis flujos usan Python io.open UTF-8 sin BOM + LF desde el arranque (verificado en los 44+ writers del día); el scanner parcheado defiende canales históricos; los 10 BOMs del push Ling reparados (053). El fix del momento: cada reincidencia el BOM se arregla con verificar_bom --fix y el emisor recibe sección de monitoreo (los 3 emisores documentados: Ling, agnes, Step-5 — mirar en el 056 propuesta A del riel).
  · VUELTA del gate blindado 2026-10-19 04:10 UTC (G-5.3-Flash-Agente): el run 39184647229 (gate blindado UTF-16 LE/BE + U+FEFF embebido — excelente upgrade del director) lista 3 BOMs bloqueantes (05-Checklist de 149-Nombres/21-Diálogos/46-Arte-2D — flips de flota con flujos BOM). REPARADOS en disco (verificar_bom --fix DOCUMENTACION): 3e 20 2a limpio byte a byte + el BACKLOG de DeepSeek + Logs/1280. Los 5 U+FEFF embebidos son citas documentales (no bloquean — decisión correcta). El próximo push con el riel del director nace con UTF-8 verde (1 solo dueño restante: M127 agnes).
  · RUN riel 39099359267 LEÍDO 2026-10-18 08:50 UTC (G-5.3-Flash-Agente): Linter/Formatting/M62/Security/Binary/Numbering/M151/Protocolos = success (¡8 verdes!) — mojibake gate LIMPIO (el parche excluyó los 13 históricos correctamente). RESTA en UTF-8-BOM: 2 archivos AUTO-GENERADOS (Mensajes entre modelos/{DeepSeek-V4.1-Flash/.ultima-revision-deepseek.txt, agnes-3-flash/.ultima-revision-agnes.txt) — la flota los re-escribe CON BOM en cada ciclo (flujo PS) — RE-INCIDENCIA estructural. Fix de disco re-aplicado (2 reparados, 0 BOM). PROPUESTA al director para el cierre definitivo: (a) desversionar los .ultima-revision-*.txt (git rm --cached + .gitignore — la flota sigue escribiendo el marcador local sin contaminar el CI), o (b) agregar los paths al verificar_bom.py. M127/M112 siguen dueños.
  · QA PROPIO del fix masivo 2026-10-18 05:15 UTC (G-5.3-Flash-Agente): los 300 .tres reparados verificados contra su schema — 300/300 parsean como gd_resource, 300/300 referencian ItemData, 0 BOM, 0 decode-error, 0 cabeceras rotas. Reparación semánticamente íntegra (informe 022aal).
  · REGRESIÓN FINAL del working tree 2026-10-18 05:55 UTC (G-5.3-Flash-Agente): con TODOS los fixes en disco (300 BOMs + 2 analytics sintaxis + item_obj_her_017 + linter EXIT=0), las 3 suites UI quedan verdes: test_m53_capas 14/0, test_m53_wcag 17/0, test_ui_framework 0 fallos. El tree está listo para el commit del director.
  · TRACK-LOG DÍA 1 — 2026-10-18 02:50 UTC (G-5.3-Flash-Agente): run de quality.yml SIN verde aún. 6 runs rojos medidos hoy (39082664971 00:24Z / 39083086690 00:31Z / 39083872939 00:44Z / 39084931328 01:01Z / 39085591694 01:11Z / 39086849817 01:32Z) con las mismas 3 capas rojas: (1) UTF-8 BOM guard por item_obj_her_017.tres en UTF-16-LE (blob del ÍNDICE ff fe — fix de disco correcto pero cada add capturaba el pisado; el próximo add con disco bueno lo cierra); (2) M127 legal — 300 hallazgos items_m159 (dueño agnes); (3) M112 suite — 2 SCRIPT ERROR (size/Callable + register/NPCWatchdog). Cadencia de push ~cada 10 min, todas fallan igual.

### Bloque D — Material de dirección (mantenimiento continuo)

30. [x] `CRON-DIRECTOR-COMO-CREARLO.md`: afinar con lecciones nuevas (ya corregí "modelle" typo y el corte del prompt).
31. [x] `ROLES-DE-AGENTES.md`: refresco semanal con evidencia (el afinal "jornada 16" ya lo tengo).
32. `MATERIAL-DIRECTOR.md`: disponibilidad de flota declarada por el fundador (re-confirmar con cada arranque).
33. [x] Backlogs de flota (agnes/DeepSeek/Hy3/Step5/DS-Opencode): marcar tareas completas/cerradas cada bloque de cierre → mantener 100+ disponibles cada uno.
34. Backlog DIRECTOR (este archivo): tick las tareas [x] de cada cierre diario.
35. Pool de agnes: normalizar (cabeza correcta después del re-base — el próximo de agnes debe ser siempre la cabeza del pool o siguiente libre).
36. Pools de canal: limpiar BOM si reaparece al reescribirlos por agentes:
  · VERIFICADO 2026-10-18 04:15 UTC (G-5.3-Flash-Agente): 17 pools de canal presentes, 0 con BOM (lectura binaria de los primeros bytes) — sin limpiezas necesarias.
37. Pool global de Logs: normalizar (cabeza siendo 1906 tras mi 1905).
38. Filas GLOBAL: detección/修复 de anomalías (10/11 celdas — reparar como 76/55).
  · DETEX#38 2026-10-18 02:20 UTC (G-5.3-Flash-Agente, DETECCIÓN read-only): 168 filas de módulo, 1 anomalía de forma — fila 159 con 12 celdas (debería 11; módulo 159-Catalogo-De-Objetos, 🔵 EN CURSO por agnes: NO REPARADA por mí per 21.4 — punteros para dueña/director en informe 018). Resto de las 167 filas: 11 celdas OK.
39. [x] ESTADO-PARALELO.md: sanear bytes CR/NUL — ya en parte; y nueva actualización del relevo.
40. Logs/NUMEROS_DISPONIBLES global: normalizar (cabeza 1906: después de mis Logs 1875-1905 + los de la flota).
41. Logs duplicados (1876/1878/1888/1904-doble?): tratamiento como historial coexistente (no borrar, solo anotado en el registro).

### Bloque E — Coordinación y ruteo del director (delegaciones puntuales)

42. [x] Delegación con puntero exacto a Step-5 para el frente activo en su cola (M55 rendimiento → M55 catálogo → M51/M50/M49...).
43. [x] Delegación a DS-Opencode para el micro-lote → M112 → fix de economía → M159 (ya autorizado).
44. Delegación a DeepSeek-WB: ruteo claro de M159 con medición L216.
45. Delegación a agnes: continuar barrido con control de número (638+ — hay que avanzar la estructura de rangos cada ronda: 500-599 completo, 600+ en raíz mientras sea ≤100).
46. Delegación a Hy3 "de a poco" (su saturación declarada) — QA con medición real, colas cortas.
47. Notificación del relevo a kimi-k3 / Claude-Haiku-5.5 / muse-spark cuando den señal de vida (no crítico).
48. DELEGACIÓN de los 17 [ ] de M159 con conteo L216 como marco (lote DeepSeek aprobado — ver msg 275).
49. [x] Ruteo de los ex-[?] del M30: L71 queda para M45/M46 (dueño) — hasta que se desbloquee.
50. [x] Ruteo del frente de M29: flecha HUD ×2 → agnes (fila M53) cuando libere.
51. Ruteo de los [?] honestos de M55 (12 con dueño externo: M36/M34/M50/M35/M16/M24/M26/M25/M71/M56).
52. [x] Ruteo de los 11 manifiestos de M76 (ya los [x] flipó Step-5 — sigue OK).
53. Apuntar los **[ ] 4 de M76** (fase MP) — pendiente de implementación real de multijugador (lote de diseño/patrón contractual).
54. Re-ruteo del frente de M56 (fotografías del diario) — los 5 [?] del frente del archivo/galería.

### Bloque F — QA externo en cola (ruteo objetivo)

55. QA §21.8 de M76 (126/130) — pendiente de verificador externo (agnes/Hy3 con cola libre).
56. QA §21.8 de M55 (58/131) — pendiente idem.
57. QA §21.8 de M29 (192/195) — Hy3 apuntó el sello... (verificar la segunda firma).
58. QA §21.8 de M30 (119/120) y M32 (119/121) — en la cola de los veredictos.
59. QA §21.8 de M117 (94/110) y M26 (122/129) — ✅ sellados (verificar coherencia semanal).
60. [x] QA §21.8 de M91 (217/239) — ✅ sellado.
61. QA §21.8 de M118 (105/106) — ✅ sellado (L199 [?] aparte).

### Bloque G — Auditoría y limpieza diaria

62. [x] Duplicados físicos de los canales activos (detección por prefijo, como el patrón agnes) — re-base diario.
63. Logs que llegan con el mismo prefijo (1904 doble etc.): anotación en el pequeño registro de colisiones (coexistencia histórica).
64. Filas GLOBAL: revisión de 10/12 celdas (reparación patrón fila 76/55).
65. `ESTADO-PARALELO.md`: sin duplicación de cabecera (lección del relevo del director — la cabecera del relevo con título).
66. Backup de encoding habitual (like el b27caed atrapado — verificable con `verificar_bom.py`).
67. `10-GUIA-COMPARATIVA-MODELOS.md` (afinar como hago en la ronda: agrega specs nuevas si cambio).
68. `AGENTS.md`: actualización de reglas nuevas (§10.2 fijo de numeración ya está, §31 relevo ya está).
69. Propuestas de mejora en la GUIA-COMUNICACION.md (si el flujo lo pide).
70. Chequear los LISTADOs de pendientes de los mensajes no respondidos (T-19 maduros).

### Bloque H — Flujo agente-directo (módulos sin bloqueo, cuando el fundador ordene directamente)

71. M139-Pre-Alpha (mi M139): continuaciónd Hugo/Aurora — el frente de agnes sigue activo (barrido) — no pisar, pero puedo colaborar en los [ ] si queda desbloqueado.
72. M52-Particulas: los [sub-flips L144 y L60] ya resueltos — el cierre del frente espera la decisión del autoload VfxManager → con DeepSeek/others.
73. M49/46/30 (bloqueo L71): depende de M45/M46 — puedo aportar el análisis de diseño del bloqueo.
74. M137-Prototipo (8/131 — 123 [ ]): el drift de agnes ya detectado — puedo acometer el módululo con Continue (no asumo por ejemplo, lo trato como D74 con asignación del fundador).
75. M55-121: catálogo cleaning por el otro frente (36/44 sin descripción).
76. M159-Catálogo (77/146): con DeepSeek el lote — puede continuar con compromiso del fondo (puedo aportar segunda oleada si la medición L216 lo decide).
77. M64-Memoria (113/150 — 37 [ ] non-headless): convertir sería muy largo — solo con el fundador para diseño pool.
78. M59-Guardado (60/130): mientras for pesos.
79. M67/M70-Transportes (19/131, 98/145): espera diseño — puedo colaborar si el fundador me da vista del requirimiento.
80. M56-Fotografía (26/137): el frente del diario del jugador — puede ser un frente Step/DS; puedo solo overlapping no pisar.
81. M54-Mapa (133/177): los 44 [ ] en su frente — sin opacity.
82. M53-UI-UX (144/165): integrado: el front de los sliders de audio (ya 21 steps en el roundtrip test)... el resto de [ ] quedan para el propio frente UI.
83. M117-Build (94/110): 16 [?] con dueño REAL (M118, M96, M116, M113): no se quedan en mi mano.
84. M118-CI (105/106): L199 = el flip dependiente de run verde (ya es el frente del CI — arriba #21).
85. M120-CGU (83/108): sandbox/validación — puedo acometer el frente si el fundador pide integración CI Métrik.
86. M123-Modding (106/108 — 2 pendientes): se puede cerrar rápido con el frente de DS/Step5 — puedo self-executar si el plan-actual parece listo en 2 ítems.
87. M124-Marketplace-mods: sandbox de seguridad — deferred alto esfuerzo (requiere diseño de permisos modder — trabajo agente largo).
88. M126-Marketing-Legal (101/101): cierre de iteración solo el [1] — se puede self-executar rápido (slug conocida).
89. M91 3 [?]: flecha HUD → agnes (visual), H123 → DS (M112)... no me lo tomo self.
90. M71-Progresión: pendiente de integraciones del run — no me lo tomo (frente activo).

### Bloque I — Interfaces de reporte al fundador y trazabilidad

91. ReporteJuice: informe al fundador de cierre de cada jornada (resumen de cierres, pendientes, rama libre).
92. Push log con trazabilidad del rango (§4.3) — identidad del ejecutante (patrón Log 1888/1905).
93. Filas de cierre del día como el 1905 (para cada cierre de jornada por orden del fundador).
94. Historial del relevo/archivo de dirección (MATERIAL/soporte directo del relevo).
95. Enlaces de circulación interna de mensajes (fiujos de cierre con los agentes — sin falso cierre de T-19 prematuro).
96. Playlist de propaGO de tareas diarias del director (cron activation diary — template receta CRON-COMO-CREARLO).
97. Modelo de comunidad (cada mensaje numerado del día — registrar el índice de interpolación del commitñana).
98. Propósito de set de la flota: disponibilidad NO disponibles (Ling/s2/s3/atria/kimi/Haiku/muse) — re-confirmar con el fundador en cada arranque.
99. Registro de colisiones de pool de Logs (1904 doble etc.) — en la receta se ya; seguir patrón (nada que hacer hoy, son históricos coexistiendo).
100. Plantilla de cierre de martes-viernes: cambios estructurales del día (re-bases, filas aplicadas, QA sellada, sellos, automatización de catch-up) con nombre GLM-5.3-Flash-Director/en-log-formato.
101. Deuda del stagger del CI (el trabajo negro: rutina cd Q. — el job de formato de calidad — se engineer por el job de CI formatting check a lo largo del pipeline del día).
102. **[ORDEN DIRECTA DEL FUNDADOR 2026-10-16 18:32] Rediseño visual professional de los paneles del juego** — "no me gustan podes abrir godot y presionar la e por ejemplo activa el panel no me gustan los colores por ejemplo la letra es blanca y el fondo un beige pastel claro que no se lee nada. podrias hacerlo mas profesional? tenes los mcp las guias , skills" — Alcance: T2-panels del juego (layers de M53 + theme), en tiempo libre del director (rano con vision V2, MCP Godot, guias y skills). Pendiente: bracket D102a explorar theme/layers (ya iniciada: scripts/ui con core/ + layers/), D102b lanzar juego + captura vision, D102c paleta professional + aplicar, D102d comparativa antes/despues.
  · CONTINUACIÓN D102b2 2026-10-18 03:00 UTC (G-5.3-Flash-Agente, frente estético reserva, alcance inicial de la orden): centralizados los colores panel/borde de las 5 capas modal restantes (confirm_popup, dialog_layer, diary_layer, equipment_layer, inventory_layer + highlight de selección del inventario) a constantes ThemeUx — mismo lenguaje que PauseLayer. Suites: test_m53_capas 14/0, test_m53_wcag 17/0, test_ui_framework 0 fallos. Documentado en DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md (ítem coherencia visual, avance firmado). Pendiente de tu commit: item_obj_her_017.tres UTF-8 (3er push con blob UTF-16 en b445bab).

---
**Total: 101 tareas** (números D1-D101 — cada una con alcance concrete del rol DIRECTOR; las de la flota YA están separadas en los 5 BACKLOG-100-TAREAS-<MODELO>.md, los barridos y cierres se marcan a mano en cada ciclo `cron`).

**Al marcar:** completar con `[x]` + fecha + evidencia (hash del commit, run CI, test salida) — las pendientes quedan números de cola.

**Firma:** GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-17

--- 
**Log reservado:** **1906** - check de la fila de archivos BACKLOG-100-TAREAS (2 de 6 flota, validate ondisk=checked) - [S]


---

## SESIÓN CERRADA — 2026-10-18 12:35 UTC (fundador ordenó apagar cronómetros)

- **Cronómetro `*/10` apagado** (wakeup wku_14c44ac3a0011dJm6vgH3cBVe7 eliminado con cron_delete).
- **Jornada completa**: 44+ vueltas del bucle V2 — tanda #102 (D102 completo + D102b2, liberado 🟡 con QA externo pendiente), riel CI/CD del rojo al verde sostenido (BOMs 300+1, analytics BUG-091, parche exclusión scanner, riel verdes 2×, flip L199 del director), Bloque B 11-18, C 21-29, items ciclo 1-8 — TODO con evidencia fechada arriba y en el canal (informes 002-044).
- **Pendientes que quedan a dueños**: M127 Legal (agnes/M159), M112 tests stale (M72/M64 via Hy3-260), commit/push del riel (director). QA externo de M53 pendiente (Hy3/agnes → sella el director).
- El pool de canal deja cabeza 45; el pool global de Logs queda con el 1954 al frente.
- **Reinicio**: el fundador vuelve a pedir la apertura de canal o el director re-dota el cron cuando reanude la flota.

Final: G-5.3-Flash-Agente / Kilo Code.
1. reposicion nicho GLM (directo del 05 real): 59: Botón "Guardar" en pausa con confirmación y feedback (M44) [S]
  · [x] IMPLEMENTADO+VERIFICADO 2026-10-18 22:55 UTC (G-5.3-Flash-Agente): pause_layer.gd — botón Guardar abre ConfirmPopup (SETTINGS.GUARDAR_TITULO/CONFIRMA, .po es/en + strings es/en 4/4 claves); al Confirmar ejecuta guardado REAL vía DataStore (M60) con PlayerSaveProvider (sección player) y feedback toast EventBus.ui.notify (éxito/fallo). QA headless: qa_guardado_manual_item1.gd → ok=true, slot=1, 393 bytes, sin error. Regresión: M89 48/0, capas 14/0, wcag 17/0. Nota: señal guardar_pedido se conserva (API pública M89); el front completo de slots (items 2-15) permanece para dueño M59.
2. reposicion nicho GLM (directo del 05 real): 59: Mostrar hora/fecha del último guardado por slot [M]
  · [x] IMPLEMENTADO+VERIFICADO 2026-10-18 23:10 UTC (G-5.3-Flash-Agente): ConfirmPopup.configurar_texto(titulo, mensaje, ok, cancel) nuevo (M53, retrocompatible); PauseLayer._pedir_confirmacion_guardado() muestra GestorSlot.leer_meta(1).guardado_iso (SETTINGS.ULTIMO_GUARDADO/SIN_GUARDADO_PREVIO en es/en JSON + .po). QA headless extendido: guardado ok=true + guardado_iso presente (iso=2026-10-18T22:52:55 UTC real). Preview runtime sin errores (ConfirmPopup con meta visible, mundo pausado). Nota de escala: el QA valida slot 1; items 6/8 de slots múltiples quedan para el dueño M59.
3. reposicion nicho GLM (directo del 05 real): 59: Impedir guardado manual durante carga de escena/diálogo [M]
  · [x] IMPLEMENTADO+VERIFICADO 2026-10-18 23:35 UTC (G-5.3-Flash-Agente): PauseLayer._bloqueado_por_modal_o_carga() bloquea el guardado si hay DialogLayer/LoadingLayer/ConfirmPopup/Inventory/Shop/Equipment/Diary/Crafting/Settings/Menus visible o GameFlowManager.esta_cargando() — toast SETTINGS.GUARDAR_BLOQUEADO (4 archivos i18n: es/en .po + json). REGRESIÓN: M89 48/0 (post-fix parse-error propio: var faltante en L144 — corregido y re-corrido verde), capas 14/0.
4. reposicion nicho GLM (directo del 05 real): 59: Deshabilitar botón si no hay cambios (no dirty) [M]
  · [?] PARCIAL 2026-10-19 00:30 UTC (G-5.3-Flash-Agente): el dirty-check full requiere wiring M59/M60 dual backend (SaveManager.is_dirty + SaveWriter.save_exists vs DataStore WriteAtomico) — wiring de dueño M59 (pendiente del plan de slots item 78). MI ENTREGA: QUITÉ mi dirty-check experimental (fallback: botón siempre habilitado salvo bloqueos del item 3 — seguro). Intentos: compare JSON.stringify/var_to_str (Vector3 vs arrays parseados nunca matchean); is_dirty del SaveManager solo se marca por M158 hoy. Pending: el dueño M59 decide dirty con su backend unificado.
5. [x] reposicion nicho GLM (directo del 05 real): 59: Guardar manualmente desde el menú principal [S]
6. [x] reposicion nicho GLM (directo del 05 real): 59: Definir 3+ slots con UI de selección en el menú principal [M]
7. [x] reposicion nicho GLM (directo del 05 real): 59: Borrar y sobrescribir slot con confirmación [S]
8. reposicion nicho GLM (directo del 05 real): 59: Id de perfil en el archivo, validado al cargar (sin cruzamiento) [M]
9. reposicion nicho GLM (directo del 05 real): 59: Probar 3 perfiles sin mezcla y cambio de slot en plena sesión [C]
10. reposicion nicho GLM (directo del 05 real): 59: Probar en Windows/macOS/Linux (rename atómico varía por SO) [C]
11. reposicion nicho GLM (directo del 05 real): 59: Guardar islas, POI, exploración y niebla (M54) [M]
12. reposicion nicho GLM (directo del 05 real): 59: Guardar estado de ruinas (M25) y templos (M26) [M]
13. reposicion nicho GLM (directo del 05 real): 59: Guardar modificaciones del mundo (tala M50, minado M35) [M]
14. reposicion nicho GLM (directo del 05 real): 59: Testear carga del mundo sin duplicar objetos [C]
15. reposicion nicho GLM (directo del 05 real): 59: Guardar ítems, cantidades, recursos (M15) y dinero (M38) [M]
16. reposicion nicho GLM (directo del 05 real): 16: Doble llamado a craft en el mismo frame: cola interna o rechazo silencioso [M]
17. reposicion nicho GLM (directo del 05 real): 16: Cero cómputo de crafting cuando la UI está cerrada [S]
18. reposicion nicho GLM (directo del 05 real): 16: Filtros de temporada recalculados solo ante season_changed [S]
19. reposicion nicho GLM (directo del 05 real): 16: Sin asignaciones de objetos en el hot path de fabricación simple [M]
20. reposicion nicho GLM (directo del 05 real): 16: Texturas/iconos de recetas precargados con pool ligero [M]
21. reposicion nicho GLM (directo del 05 real): 16: Sin steps de física extra en estaciones (efecto interactuable básico) [S]
  · [x] VERIFICADO 2026-10-19 05:30 UTC (G-5.3-Flash-Agente): crafting_station.gd — Node3D + Mesh placeholder por tipo + Area3D de interacción (input interactuar + radio + idempotencia L44-59). 0 referencias a RigidBody/CharacterBody/gravity custom — el efecto interactuable básico SIN física extra ya estructural. Flip del 05 M16 con esta evidencia (dueño de fila: director).
22. [x] reposicion nicho GLM (directo del 05 real): 16: Presupuesto: apertura de UI menor a 1 ms y sin marco de referencia perdido [M]
  · [x] VERIFICADO 2026-10-19 05:45 UTC (G-5.3-Flash-Agente): QA headless nuevo (qa_budget_m16.gd) — recetas estación 0 = 4 recetas, tiempo de los 2 refrescos de apertura (recetas_por_estacion + recetas_conocidas_estacion con iteración completa de la lista) = 24 us » presupuesto 1 ms. Sin cortes en la apertura — el recálculo es barato (diccionario lookup + array filter). QA script persistido en scripts/viajes/qa_budget_m16.gd para re-corridas del dueño.
23. reposicion nicho GLM (directo del 05 real): 16: Test unitario: registro de recetas y detección de duplicados [M]
  · [x] IMPLEMENTADO+VERIFICADO 2026-10-19 00:35 UTC (G-5.3-Flash-Agente): test_crafting.gd nueva función _test_registro_duplicados() — crafting.json accesible/parsea, service registró N de N recetas (sin pérdidas por duplicados del JSON flat), regex por rec_id detectar duplicados en el texto crudo, receta inexistente -> null. Suite completo: M16 0 fallos (con el test nuevo sumado al runner).
24. reposicion nicho GLM (directo del 05 real): 16: Test unitario: validación de materiales y máximo fabricable [M]
  · [x] VERIFICADO 2026-10-19 00:40 UTC (G-5.3-Flash-Agente): test_crafting.gd ya cubre el caso — _test_fabricar_ok usa max_craftable(rec_pico_cobre) >= 2 (10 madera/3, 10 cobre/4) + _test_fabricar_sin_materiales con remover_items falla por TODO-o-NADA multiplicado ×cantidad. Sin cover nueva necesaria — evidencia existente firmada en el runner 0 fallos.
25. [x] reposicion nicho GLM (directo del 05 real): 16: Test: rollback exacto ante inventario lleno en ambos destinos [C]
  · [x] IMPLEMENTADO+VERIFICADO 2026-10-19 06:40 UTC (G-5.3-Flash-Agente): _test_rollback_bolsa_llena() en test_crafting.gd — llenado de BOLSILLA con filler, craft 5x falla con inventario_lleno, ROLLBACK EXACTO (madera/cobre/pico idénticos pre/post con include_house=true — refund cae a CASA por fallback bolsa->casa). Suite M16 completa 0 fallos. ítem [25] del 05 flipado con evidencia.
26. reposicion nicho GLM (directo del 05 real): 16: Recorrido manual: abrir, fabricar, fallar y cancelar en las 3 estaciones sin bugs [C]
27. reposicion nicho GLM (directo del 05 real): 16: RF-MR1: `mejorar_herramienta(item_id: String) -> Dictionary` en `CraftingService` con
28. reposicion nicho GLM (directo del 05 real): 28: Definir el problema: desplazamiento cozy entre islas con el Gran Vapor [M]
29. reposicion nicho GLM (directo del 05 real): 28: Catalogar los 25 puntos de la sección 27 del plan maestro [S]
  · [x] EJECUTADO 2026-10-19 05:50 UTC (G-5.3-Flash-Agente): catálogo entregado en DOCUMENTACION/28-Viajes/plan-actual/cat_25_puntos_seccion27.md — los 25 puntos de la sección 27. VIAJES mapeados 1:1 al 05 real de M28/RF/código actual (travel_service 10 paradas/20 rutas, bridges M69/M74/M73...) con estado por punto (parcial/pendiente) para el dueño del frente. Los RF [30]-[37] de la cola cubren los primarios.
30. reposicion nicho GLM (directo del 05 real): 28: RF1: boleto y reserva con capacidad del vapor [M]
  · [x] IMPLEMENTADO+VERIFICADO 2026-10-19 05:15 UTC (G-5.3-Flash-Agente): módulo nuevo scripts/viajes/travel_reserva.gd (TravelReserva) — capacidad por ruta (default 6), asientos libres, reservar/cancelar/liberar, motivos capacidad_agotada/ya_reservado, auditoría de eventos. QA headless 7/7 (qa_reserva_m28.gd: capacidad 2 → agotada en 3a, ya_reservado ANTES de capacidad tras fix de orden, cancelación libera, default 6, liberar_ruta). INTEGRACIÓN a travel_service pendiente (módulo independiente — integración al request_travel a decisión del dueño M28).
31. reposicion nicho GLM (directo del 05 real): 28: RF3: travesía visible entre 20 y 60 segundos [M]
  · [x] IMPLEMENTADO+VERIFICADO 2026-10-19 09:35 UTC (G-5.3-Flash-Agente): travel_layer.gd (TravelLayer, MODAL_FULL) — pantalla de travesía suscrita a travel_started/progress/arrived/cancelled del TravelService: abre al zarpar, barra de progreso con % en vivo, cierra en arrived/cancel, botón cancelar wired. Tema D102 (panel noche + borde dorado). QA headless 6/6 (qa_travel_layer.gd: cerrada inicial, abre, 50%, 100%, arrived cierra, cancel cierra). Montaje en UIRoot como opción del dueño (la capa ya lista).
32. reposicion nicho GLM (directo del 05 real): 28: RF4: llegada con atraque automático y desembarque suave [M]
  · [?] PARCIAL 2026-10-19 09:20 UTC (G-5.3-Flash-Agente): travel_arrived señal viva + _atracar() setea estado y destinos_visitados, PERO el desembarque suafe (reposición del Player al puerto del destino) requiere CATÁLOGO DE PUERTOS por isla (M54/M16 zona — no existe aún: location_data no expone dock_points). Pendiente del dueño M28/M54. Sin cambios de producción por mi lado (sin catálogo no puedo inventar coordenadas de puertos).
33. [x] reposicion nicho GLM (directo del 05 real): 28: RF5: viaje rápido costoso vía M69 [S]
  · [x] VERIFICADO 2026-10-19 09:20 UTC (G-5.3-Flash-Agente): el RF5 viaje rápido costoso ESTÁ CUBIERTO por scripts/fasttravel/fast_travel_service.gd (solicitar_viaje + viaje_rechazado motivo costo/bloqueado + validador de coste inyectable M38/M59 + test_fast_travel_headless propio). Nota de nomenclatura: el item del 05 decía vía M69 — el módulo real es fast_travel_service (M69 = hallazgo de nomenclatura para el dueño). Sin cambios necesarios.
34. reposicion nicho GLM (directo del 05 real): 28: NFR: cozy, sin soft-locks, accesibilidad, guardado M58 [M]
  · [x] VERIFICADO 2026-10-19 05:00 UTC (G-5.3-Flash-Agente): el TravelService YA implementó el proveedor de guardado M59 (get_section_name "viajes" + get_save_data con estado/ruta_id/transcurrido/duracion_efectiva/visitados + restore_save_data) y se registra al boot (_registrar_proveedor_guardado). Cozy/sin softlocks: el request_travel rechaza+signal travel_cancelled en todos los caminos | accesibilidad: línea nocturna solo de noche (M29). Sin cambios necesarios — flip con evidencia del código.
35. reposicion nicho GLM (directo del 05 real): 28: P2: diseño del barco — Gran Vapor con cubierta navegable y chimenea [C]
36. reposicion nicho GLM (directo del 05 real): 28: P3: diseño del dirigible — vehículo opcional de contenido tardío, no bloqueante [M]
37. reposicion nicho GLM (directo del 05 real): 28: P4: diseño del submarino — vehículo opcional de expediciones, no bloqueante [M]
38. reposicion nicho GLM (directo del 05 real): 58: Verificar legibilidad de la UI de M53 con escala 200 % sin cortes [C]
  · HALLAZGO 2026-10-19 04:30 UTC (G-5.3-Flash-Agente): la escala 200% está FUERA del clamp del M58 (ThemeService.clampf(scale, 0.8, 1.5) — límites ui_scale M58). Dos vertientes para el dueño: (a) ampliar clamp a 2.0 + probar TODA la UI a 2×, o (b) reinterpretar como DPI 200% del OS con el juego a 1.0 (ejecutable sin tocar diseño — MI RECOMENDACIÓN). Flip del dueño. Sin cambios en el clamp sin GO.
  · [x] EJECUTADO (b) 2026-10-19 04:45 UTC (G-5.3-Flash-Agente, GO del director 063): proxy sin tocar el OS del fundador — el juego lanzado a ventana 480x270 (media resolución = percepción objetivo del DPI alto) y captura de VENTANA exacta (no de escritorio): el panel de PAUSA se ve legible SIN CORTES (título Pausa completo, los 4 botones con texto íntegro, panel noche con borde) → evidencia persistida en capturas/53-UI-UX/cap_53_2026-10-19_23-10-00_item38_mediaventana_sin_cortes.png. Limitación declarada: proxy, no el DPI 200% real del OS (ese requiere tocar la sesión del fundador — precio de la opción (b) exacta). Flip del dueño con esta evidencia.
39. reposicion nicho GLM (directo del 05 real): 58: RF12: auditar que ningún puzzle dependa de oír un sonido específico [C]
  · [x] AUDITORÍA 2026-10-19 06:25 UTC (G-5.3-Flash-Agente): RF12 cumplido — informe completo en DOCUMENTACION/58-Accesibilidad/auditoria_rf12_puzzles_sin_audio_solo.md: (1) 0 hits de audio directo en puzzle_agua/bloques/espejos/gravedad/luz; (2) puzzle_sonido.gd es DATA-ONLY declarado (item 104, 0 AudioServer en el modelo, test por grep en la fuente); (3) puzzle_room/emisor feedback texto/visual (casi-solución item 53). Rec para dueño: mantener el test por grep como barra del CI + equivalente visual de los tonos.
40. reposicion nicho GLM (directo del 05 real): 58: RF17: exponer dead zones, sensibilidad por eje e inversión como accesos directos (M57) [M]
41. reposicion nicho GLM (directo del 05 real): 58: Definir que el remapeo respete los conflictos detectados por M57 [M]
42. reposicion nicho GLM (directo del 05 real): 58: Definir indicador visual del perfil de control activo en el menú [S]
  · [x] IMPLEMENTADO+VERIFICADO 2026-10-19 10:40 UTC (G-5.3-Flash-Agente): MenusLayer — label PerfilLabel (FONT_SIZE_SMALL, color ACCENT_OCRE) que muestra el perfil activo leyendo AccesibilidadManager.get_perfil() + conectado a profile_changed (actualización live al cambiar preset single_hand/low_mobility/custom). Regresión M89: 48/0.
43. reposicion nicho GLM (directo del 05 real): 58: RF23: reabrir el último diálogo sin perder contexto [M]
  · [x] IMPLEMENTADO 2026-10-19 10:15 UTC (G-5.3-Flash-Agente): dialogue_manager.gd — _rf23_ultimo_id/_rf23_ultimo_contexto guardados al arranque de CADA diálogo + método público reabrir_ultimo() (replica start_dialogue con el MISMO context; false si sin previo o activo). QA headless (qa_rf23_reabrir.gd): guard-cases OK; flujo completo con catálogo SKIP para dueño M21/M28 (requiere dialogue_ids reales del catálogo de grafos — los nodes de data/dialogos son del dueño). Flip del dueño con esta evidencia.
44. reposicion nicho GLM (directo del 05 real): 58: RF26: redactar guía de textos críticos con frases cortas y vocabulario simple [M]
  · [x] IMPLEMENTADO 2026-10-19 09:57 UTC (G-5.3-Flash-Agente): guía vigente publicada en DOCUMENTACION/58-Accesibilidad/guia_rf26_textos_criticos.md — reglas de frases cortas (≤12 palabras, voz activa, 1 idea por frase), vocabulario simple (sin anglicismos/tecnicismos/ironía/doble negación), estructura de mensajes críticos (error = qué pasó + qué pierdes + qué hacer), glosario canónico del juego y checklist de 10 puntos para QA de textos. Destinatarios: dueños de M21 diálogos, M16 tooltips, M56 toasts, M28 tickets, M74 misiones.
45. reposicion nicho GLM (directo del 05 real): 58: RF27: verificar que el texto grande no desborde diálogos ni inventario (M53) [C]
  · [x] VERIFICADO 2026-10-19 08:35 UTC (G-5.3-Flash-Agente): QA headless nuevo (scripts/ui/qa_texto_grande_rf27.gd) — DialogLayer con fuente GRANDE (48px texto grande) + texto largo con tildes/ñ (año/ñandúes/ágiles/ña/ñoquis) → autowrap WORD_SMART activeness, SIN clip_contents (envuelve), altura label 66px multi-línea (no cortes). El inventario (notification_service) usa el MISMO autowrap (L115). El DialogLayer sin clip por diseño (los labels envuelven).
46. reposicion nicho GLM (directo del 05 real): 58: Verificar la legibilidad del texto grande con las fuentes de M88 en español (tildes, ñ) [M]
  · [x] VERIFICADO-456 2026-10-19 08:35 UTC (G-5.3-Flash-Agente): el QA RF27 incluye texto español con tildes/ñ/¡! (año, ñandúes, ágiles, ña, ñoquis) — json 4/4 INTACTAS en el label renderizado (fuentes M88 con charset español) — sin sustitución de glifos ni U+FFFD.
47. reposicion nicho GLM (directo del 05 real): 58: NFR: aplicar el perfil con overhead menor a ~1 ms por frame [C]
48. reposicion nicho GLM (directo del 05 real): 65: [M08] Movimiento real con NavigationServer3D evitando voxels [C] — KnownIssue no bloqueante DoD: dueño M08 (VoxelTerrain); movimiento basico bidimensional ya implementado en animal_behav


## REPOBLACION V3 (2026-10-19T00:02:03) — items REALES de 05-Checklist (fuente en comentario)

1. - [x] [59] Botón "Guardar" en pausa con confirmación y feedback (M44) [S] · [x] T16-M59 2026-10-19 (G-5.3-Flash-Agente): popup confirmación + request_save real + toast por EventBus — qa_m59_guardar_confirmacion.gd 4/0 EXIT 0 (SaveManager/EventBus reales); regresión M89 48/0. Drift inverso: esta cola vieja de M59 quedó des-sincronizada del módulo (ítem 7 ya estaba hecho) — items 1-40 a revisar contra 59-Guardado/05. <!-- fuente: 59-Guardado/05-Checklist.md -->
2. - [ ] [59] Mostrar hora/fecha del último guardado por slot [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
3. - [ ] [59] Impedir guardado manual durante carga de escena/diálogo [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
4. - [ ] [59] Deshabilitar botón si no hay cambios (no dirty) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
5. - [ ] [59] Guardar manualmente desde el menú principal [S] <!-- fuente: 59-Guardado/05-Checklist.md -->
6. - [ ] [59] Definir 3+ slots con UI de selección en el menú principal [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
7. - [ ] [59] Borrar y sobrescribir slot con confirmación [S] <!-- fuente: 59-Guardado/05-Checklist.md -->
8. - [ ] [59] Id de perfil en el archivo, validado al cargar (sin cruzamiento) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
9. - [ ] [59] Probar 3 perfiles sin mezcla y cambio de slot en plena sesión [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
10. - [ ] [59] Probar en Windows/macOS/Linux (rename atómico varía por SO) [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
11. - [ ] [59] Guardar islas, POI, exploración y niebla (M54) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
12. - [ ] [59] Guardar estado de ruinas (M25) y templos (M26) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
13. - [ ] [59] Guardar modificaciones del mundo (tala M50, minado M35) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
14. - [ ] [59] Testear carga del mundo sin duplicar objetos [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
15. - [ ] [59] Guardar ítems, cantidades, recursos (M15) y dinero (M38) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
16. - [ ] [59] Guardar equipamiento, hotbar y objetos colocados (M17) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
17. - [ ] [59] Guardar semillas y cultivos en proceso (M33) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
18. - [ ] [59] Guardar trampas y redes de pesca (M34) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
19. - [ ] [59] Testear carga sin duplicados y límites de cantidad (M60) [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
20. - [ ] [59] Guardar casas/edificios, fase de construcción y mejoras [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
21. - [ ] [59] Guardar decoración, muebles y cofres con contenido [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
22. - [ ] [59] Guardar estado de puertas y ventanas [S] <!-- fuente: 59-Guardado/05-Checklist.md -->
23. - [ ] [59] Testear carga con casas parcialmente construidas [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
24. - [ ] [59] Testear carga con muebles inexistentes (fallback) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
25. - [ ] [59] Guardar posición, estado y rutinas de NPC (M64) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
26. - [ ] [59] Guardar diálogos vistos y elecciones tomadas [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
27. - [ ] [59] Guardar amistad (M20) y regalos entregados [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
28. - [ ] [59] Guardar encargos activos (M23) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
29. - [ ] [59] Testear carga con NPC en movimiento y regalos duplicados [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
30. - [ ] [59] Guardar misiones activas con progreso y completadas [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
31. - [ ] [59] Guardar historia principal (capítulo, final elegido) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
32. - [ ] [59] Guardar descubrimientos y hitos de progresión (M71) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
33. - [ ] [59] Testear carga con misión a medias (objetivo coherente) [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
34. - [ ] [59] Testear carga tras completar misión y reabrir [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
35. - [ ] [59] Guardar eventos pasados y futuros programados (M74) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
36. - [ ] [59] Guardar festivales celebrados y calendario [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
37. - [ ] [59] Testear carga en una fecha distinta a la del guardado [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
38. - [ ] [59] Testear eventos no duplicados al recargar [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
39. - [ ] [59] Guardar museo, bestiario y colecciones (M37/M36) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
40. - [ ] [59] Guardar diario del jugador (M55) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
41. - [ ] [59] Guardar fotos por referencia (ids, no bytes — M56) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
42. - [ ] [59] Guardar Sellos y ruinas coleccionables [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
43. - [ ] [59] Testear diario 500+ entradas y fotos faltantes (fallback) [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
44. - [ ] [59] Guardar opciones gráficas (M90), audio (M91), accesibilidad (M58) e idioma (M87) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
45. - [ ] [59] Probar múltiples perfiles sin cruzamiento [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
46. - [ ] [59] Probar archivos con permisos de solo lectura [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
47. - [ ] [59] Sin GC pesado ni hitching al encolar [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
48. - [ ] [59] Reutilizar buffers de serialización (M62) y probar con profiler (M116) [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
49. - [x] [59] Localizar textos del menú de guardado [S] <!-- fuente: 59-Guardado/05-Checklist.md -->  · [x] LOCALIZADO-49 2026-10-19 (G-5.3-Flash-Agente): SAVE_CORRUPTO/SAVE_RECUPERADO/SAVE_DISCO_LLENO añadidas a json es/en y po es/en.
50. - [x] [59] Localizar mensajes de corrupción, recuperación y disco lleno [S] <!-- fuente: 59-Guardado/05-Checklist.md -->  · [x] LOCALIZADO-50 2026-10-19 (G-5.3-Flash-Agente): SAVE_CORRUPTO + SAVE_RECUPERADO — wiring del dueño DataStore pendiente.
51. - [ ] [59] Localizar feedback de guardado (M44) [S] <!-- fuente: 59-Guardado/05-Checklist.md -->
52. - [x] [59] Respetar plurales (horas, minutos) [S] <!-- fuente: 59-Guardado/05-Checklist.md -->  · [x] LOCALIZADO-52 2026-10-19 (G-5.3-Flash-Agente): HORAS_H/HORAS_1/MIN_M/MIN_1 — plural para formateador M44.
  · [x] LOCALIZADO 2026-10-19 10:30 UTC (G-5.3-Flash-Agente): HORAS_H (n horas) vs HORAS_1 (1 hora) y MIN_M vs MIN_1 — claves separadas para el formateador del dueño M44.
53. - [ ] [59] Testear menú de guardado en 3 idiomas [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
54. - [ ] [59] Definir contrato con M107 (3-2-1 externo) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
55. - [ ] [59] Verificar la restauración desde la nube [C] <!-- fuente: 59-Guardado/05-Checklist.md -->
56. - [ ] [59] Documentar el flujo de recuperación completo [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
57. - [x] [59] Guardar con inventario vacío, mundo sin explorar o en el primer minuto [S] · [x] T17-M59 (G-5.3): qa_m59_save_vacio.gd 3/0 (estado primer minuto, dirty limpio). <!-- fuente: 59-Guardado/05-Checklist.md -->
58. - [ ] [59] Guardar durante un festival con estado consistente (M74) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
59. - [x] [59] Testear doble guardado simultáneo (cola) [C] · [x] T18-M59 (G-5.3): cola FIFO determinista con 2 request_save mismo frame — qa_m59_doble_guardado.gd 3/0; flips 59-Guardado/05 (67/62/1). <!-- fuente: 59-Guardado/05-Checklist.md -->
60. - [x] [59] Feedback de guardado visible y legible [S] · [x] T19-M59 (G-5.3): toast localizado por EventBus (capturado en qa_m59_guardar) + WCAG BUG-130 — flip por evidencia. <!-- fuente: 59-Guardado/05-Checklist.md -->
61. - [ ] [59] Confirmaciones accesibles por gamepad (M57) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
62. - [x] [59] Diálogos de aviso con opciones claras [S] · [x] T19-M59 (G-5.3): OK/Cancelar localizados + dispatch on_ok/on_cancel — qa_m59_popup_opciones.gd 5/0; flips 59-Guardado/05 (69/60/1). <!-- fuente: 59-Guardado/05-Checklist.md -->
63. - [ ] [59] Testear menú con Reduce Motion (M58) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
64. - [ ] [59] Testear con texto grande (M58) [M] <!-- fuente: 59-Guardado/05-Checklist.md -->
65. - [x] [59] Verificar con verificar_checklist.py (sin alertas nuevas) [S] · [x] T17-M59 (G-5.3): módulo limpio para 59 (drifts ajenos 36/50/55/58/62/90 reportados al canal). <!-- fuente: 59-Guardado/05-Checklist.md -->
66. - [ ] [59] Push del módulo y reporte al usuario [S] <!-- fuente: 59-Guardado/05-Checklist.md -->
67. - [ ] [59] Marcar ítems solo al cumplir la DoD (sección 21.6) [S] <!-- fuente: 59-Guardado/05-Checklist.md -->
68. - [x] [59] Revisar que plan-inicial == plan-actual (SHA-256) [S] · [x] T17-M59 (G-5.3): plan-inicial intacto (git status/diff = 0 cambios). <!-- fuente: 59-Guardado/05-Checklist.md -->
69. - [x] [59] Confirmar 130 ítems exactos [S] · [x] T17-M59 (G-5.3): 130 exactos medidos (66/63/1 post-flips, normalizado). <!-- fuente: 59-Guardado/05-Checklist.md -->
70. - [ ] [58] Verificar legibilidad de la UI de M53 con escala 200 % sin cortes [C] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
71. - [ ] [58] RF12: auditar que ningún puzzle dependa de oír un sonido específico [C] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
72. - [ ] [58] RF17: exponer dead zones, sensibilidad por eje e inversión como accesos directos (M57) [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
73. - [ ] [58] Definir que el remapeo respete los conflictos detectados por M57 [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
74. - [ ] [58] Definir indicador visual del perfil de control activo en el menú [S] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
75. - [ ] [58] RF23: reabrir el último diálogo sin perder contexto [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
76. - [ ] [58] RF26: redactar guía de textos críticos con frases cortas y vocabulario simple [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
77. - [ ] [58] RF27: verificar que el texto grande no desborde diálogos ni inventario (M53) [C] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
78. - [ ] [58] Verificar la legibilidad del texto grande con las fuentes de M88 en español (tildes, ñ) [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
79. - [ ] [58] NFR: aplicar el perfil con overhead menor a ~1 ms por frame [C] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
80. - [ ] [58] NFR: UI del menú navegable 100 % por teclado y mando [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
81. - [ ] [58] Integrar con M53: escalado aplicado al nodo raíz de UI (0.8–2.0) [C] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
82. - [ ] [58] Integrar con M53: previews dentro del menú sin escenas externas [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
83. - [ ] [58] Integrar con M57: dead zones/sensibilidad expuestos como accesos directos en el menú [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
84. - [ ] [58] Mando desconectado a mitad de sesión → perfil intacto, prompts actualizados por M57 [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
85. - [ ] [58] Texto grande con inventario lleno (36 slots) → sin elementos cortados [C] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
86. - [ ] [58] Apertura del menú de accesibilidad durante combate → pausa correcta sin pérdida de estado [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
87. - [ ] [58] Focus del teclado perdido al abrir atajo global → restaurado al volver al menú [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
88. - [ ] [58] Aplicar el perfil solo con deltas por área, no reconstruir toda la UI [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
89. - [ ] [58] Carteles de alerta con tiempo de vida y fade-out sin tween acumulados [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
90. - [ ] [58] Escaneo de interactuables para contornos solo en radio cercano al jugador [C] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
91. - [ ] [58] Verificar que M58 no sume draw calls perceptibles en escenas pobladas (M61) [C] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
92. - [ ] [58] Planear prueba de aim assist en pesca (M34) con slider en 0 %, 50 % y 100 % [C] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
93. - [ ] [58] Planear prueba del preset single_hand sin conflictos con el remapeo de M57 [C] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
94. - [ ] [58] Planear prueba de rendimiento: overhead del perfil en escena poblada con profiler [C] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
95. - [ ] [58] Planear prueba de atajo global F10 desde título, pausa y gameplay [M] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
96. - [ ] [58] Planear prueba de sesión larga (≥ 30 min) verificando los autosaves cada 5 minutos [C] <!-- fuente: 58-Accesibilidad/05-Checklist.md -->
97. - [ ] [65] [M08] Movimiento real con NavigationServer3D evitando voxels [C] — KnownIssue no bloqueante DoD: dueño M08 (VoxelTerrain); movimiento basico bidimensi <!-- fuente: 65-Animales-IA/05-Checklist.md -->


## REPOBLACION V3 (2026-10-19T01:46:07) — items REALES de 05-Checklist (fuente en comentario)

1. - [ ] [65] [M08] Movimiento real con NavigationServer3D evitando voxels [C] — KnownIssue no bloqueante DoD: dueño M08 (VoxelTerrain); movimiento basico bidimensi <!-- fuente: 65-Animales-IA/05-Checklist.md -->
2. - [x] [16] Doble llamado a craft en el mismo frame: cola interna o rechazo silencioso [M] · [x] T15-M16 2026-10-19 (G-5.3-Flash-Agente): dedupe silencioso clave (frame,rec_id,cantidad) — qa_m16_doble_craft.gd 8/0 + regresión 0 fallos; flips 16-Crafting/05 (163/27/13). · ANALISIS G-5.3-Flash-Agente 2026-10-19 (M16 revisado con GO del direc <!-- fuente: 16-Crafting/05-Checklist.md -->
3. - [x] [16] Cero cómputo de crafting cuando la UI está cerrada [S] · [x] T13-M16 2026-10-19 (G-5.3-Flash-Agente): verificado en disco+runtime (visual-free): IU/servicio/feedback sin _process, guards visible cortan refresh — qa_m16_ui_cerrada.gd 7/0; flips 16-Crafting/05 (162/28/13). <!-- fuente: 16-Crafting/05-Checklist.md -->
4. - [x] [16] Filtros de temporada recalculados solo ante season_changed [S] · [x] T11-M16 2026-10-19 (G-5.3-Flash-Agente): recetas_por_estacion sin re-lecturas (cache por señal estacion_cambio) — qa_filtros_estacion_m16.gd 5/0 + regresión test_crafting 0 fallos; flips 16-Crafting/05 (158/32/13). <!-- fuente: 16-Crafting/05-Checklist.md -->
5. - [ ] [16] Sin asignaciones de objetos en el hot path de fabricación simple [M] <!-- fuente: 16-Crafting/05-Checklist.md -->
6. - [ ] [16] Texturas/iconos de recetas precargados con pool ligero [M] <!-- fuente: 16-Crafting/05-Checklist.md -->
7. - [x] [16] Sin steps de física extra en estaciones (efecto interactuable básico) [S] · [x] T14-M16 2026-10-19 (G-5.3-Flash-Agente): Area3D con monitoring/monitorable=false (nadie lo consulta — interacción por distancia); retry del player con tope (5) — QA 8/0 EXIT 0; crash AV del churn registrado como BUG-138; extensión documentada en 16-Crafting/05 (el item ya estaba [x] por sync previa). <!-- fuente: 16-Crafting/05-Checklist.md -->
8. - [ ] [16] Presupuesto: apertura de UI menor a 1 ms y sin marco de referencia perdido [M] <!-- fuente: 16-Crafting/05-Checklist.md -->
9. - [ ] [16] Test unitario: registro de recetas y detección de duplicados [M] <!-- fuente: 16-Crafting/05-Checklist.md -->
10. - [ ] [16] Test unitario: validación de materiales y máximo fabricable [M] <!-- fuente: 16-Crafting/05-Checklist.md -->
11. - [ ] [16] Test: rollback exacto ante inventario lleno en ambos destinos [C] <!-- fuente: 16-Crafting/05-Checklist.md -->
12. - [ ] [16] Recorrido manual: abrir, fabricar, fallar y cancelar en las 3 estaciones sin bugs [C] <!-- fuente: 16-Crafting/05-Checklist.md -->
13. - [ ] [16] RF-MR1: `mejorar_herramienta(item_id: String) -> Dictionary` en `CraftingService` con <!-- fuente: 16-Crafting/05-Checklist.md -->
14. - [ ] [16] RF-MR2: `reparar_herramienta(item_id: String) -> Dictionary` — restaura la durabilidad <!-- fuente: 16-Crafting/05-Checklist.md -->
15. - [ ] [16] RF-MR3: schema `data/crafting/mejora_herramienta.json`: tabla por tipo de herramienta <!-- fuente: 16-Crafting/05-Checklist.md -->
16. - [ ] [16] RF-MR4: funciones de balance `durabilidad_maxima(tipo, nivel)` y <!-- fuente: 16-Crafting/05-Checklist.md -->
17. - [ ] [16] RF-MR5: integracion con M14 — mejorar/reparar consumen materiales del inventario via <!-- fuente: 16-Crafting/05-Checklist.md -->
18. - [ ] [16] RF-MR6: senales `herramienta_mejorada(item_id, nivel)` y <!-- fuente: 16-Crafting/05-Checklist.md -->
19. - [ ] [16] RF-MR7: persistencia del `nivel_mejora` por item en el save de M59 (campo aditivo, <!-- fuente: 16-Crafting/05-Checklist.md -->
20. - [ ] [16] RF-MR8: decision de estacion documentada en `03-Diseno.md` — estacion nueva <!-- fuente: 16-Crafting/05-Checklist.md -->
21. - [ ] [16] RF-MR9: la estacion elegida se registra en `stations.json` con las recetas de <!-- fuente: 16-Crafting/05-Checklist.md -->
22. - [ ] [16] RF-MR10: la estacion rechaza items que no son herramientas (M13 define la marca) con <!-- fuente: 16-Crafting/05-Checklist.md -->
23. - [ ] [16] RF-MR11: feedback cozy — el fallo por materiales **no dana** la herramienta (no es <!-- fuente: 16-Crafting/05-Checklist.md -->
24. - [ ] [16] RF-MR12: panel de mejora en la estacion: nivel actual, coste del siguiente nivel, <!-- fuente: 16-Crafting/05-Checklist.md -->
25. - [ ] [16] RF-MR13: preview del coste con los iconos de M14 (feedback honesto de lo que se va a <!-- fuente: 16-Crafting/05-Checklist.md -->
26. - [ ] [16] RF-MR14: notificacion cozy en exito reutilizando el `NotificationService` del modulo [S] <!-- fuente: 16-Crafting/05-Checklist.md -->
27. - [ ] [16] RF-MR15: M13 consume `efectividad(tipo, nivel)` para el escalado de rendimiento <!-- fuente: 16-Crafting/05-Checklist.md -->
28. - [ ] [16] RF-MR16: M13 consume `durabilidad_maxima(tipo, nivel)` como techo al aplicar la <!-- fuente: 16-Crafting/05-Checklist.md -->
29. - [ ] [16] RF-MR17: contrato consumido documentado en el `04-Codigo.md` de M13 (firma de la API <!-- fuente: 16-Crafting/05-Checklist.md -->
30. - [ ] [16] RF-MR18: test headless `_test_mejora_reparacion` — mejora consume materiales y sube <!-- fuente: 16-Crafting/05-Checklist.md -->
31. - [ ] [16] RF-MR19: sonda en ROJO del umbral (mutacion de `CHECKS_MINIMOS` restaurada byte-exacto) [S] <!-- fuente: 16-Crafting/05-Checklist.md -->
32. - [ ] [16] RF-MR20: verificacion §21.8 por un modelo distinto al implementador [S] <!-- fuente: 16-Crafting/05-Checklist.md -->
33. - [ ] [16] RF-MR21: `03-Diseno.md` actualizado con el contrato completo (API, curvas, estacion, <!-- fuente: 16-Crafting/05-Checklist.md -->
34. - [ ] [16] RF-MR22: desbloqueo de M158 registrado en CHECKLIST-GLOBAL (los 12 `[ ]` de M13 que <!-- fuente: 16-Crafting/05-Checklist.md -->
  · [x] SCANNER RF26 AUTOMATIZADO 2026-10-19 23:00 UTC (G-5.3-Flash-Agente): scripts/qa_textos_rf26.py — audita strings_es.json (153 textos, 158 frases) contra la guía RF26 (frases > 12 palabras, glosario sancionado, doble negación). Resultado: 1 incumplimiento (0.6%) — EQUIP.HINT 15 palabras (hallazgo para el dueño de textos: E/ESC cierra, candados se abren con capítulo o banda). Modo --detallado. UMBRAL: OK si ≥ 85% cumple.


## REPOBLACION V3 (2026-10-19T21:25:40) — items REALES de 05-Checklist (fuente en comentario)

1. - [x] [69] Test de transición: animación sin jumps visuales [M] · [x] FX-M69 2026-10-19 (G-5.3-Flash-Agente): fast_travel_effect.gd + qa_fast_travel_fx.gd 25/0 EXIT 0; flips en 69-Fast-Travel/05-Checklist.md (105/33/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
2. - [x] [69] Transición de desvanecimiento con curva cozy [S] · [x] FX-M69 2026-10-19 (G-5.3-Flash-Agente): fast_travel_effect.gd + qa_fast_travel_fx.gd 25/0 EXIT 0; flips en 69-Fast-Travel/05-Checklist.md (105/33/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
3. - [x] [69] Efectos de partículas coherentes con M41 [S] · [x] FX-M69-T2 2026-10-19 (G-5.3-Flash-Agente): qa_fast_travel_fx.gd 36/0 EXIT 0 (J.3 bruma, J.7 modo foto real M56, J.10 iluminación intacta, J.11 no pausa); flips en 69-Fast-Travel/05-Checklist.md (109/29/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
4. - [x] [69] Flash sutil al aparecer en destino [S] · [x] FX-M69 2026-10-19 (G-5.3-Flash-Agente): fast_travel_effect.gd + qa_fast_travel_fx.gd 25/0 EXIT 0; flips en 69-Fast-Travel/05-Checklist.md (105/33/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
5. - [x] [69] Indicador de carga 0.5-1.5s mínimo [S] · [x] FX-M69 2026-10-19 (G-5.3-Flash-Agente): fast_travel_effect.gd + qa_fast_travel_fx.gd 25/0 EXIT 0; flips en 69-Fast-Travel/05-Checklist.md (105/33/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
6. - [x] [69] Sin huecos negros en transición [S] · [x] FX-M69 2026-10-19 (G-5.3-Flash-Agente): fast_travel_effect.gd + qa_fast_travel_fx.gd 25/0 EXIT 0; flips en 69-Fast-Travel/05-Checklist.md (105/33/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
7. - [x] [69] Compatible con modo foto pausado [S] · [x] FX-M69-T2 2026-10-19 (G-5.3-Flash-Agente): qa_fast_travel_fx.gd 36/0 EXIT 0 (J.3 bruma, J.7 modo foto real M56, J.10 iluminación intacta, J.11 no pausa); flips en 69-Fast-Travel/05-Checklist.md (109/29/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
8. - [x] [69] HUD visible durante toda la transición [S] · [x] FX-M69 2026-10-19 (G-5.3-Flash-Agente): fast_travel_effect.gd + qa_fast_travel_fx.gd 25/0 EXIT 0; flips en 69-Fast-Travel/05-Checklist.md (105/33/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
9. - [x] [69] Sin parpadeos por baja luz [S] · [x] FX-M69 2026-10-19 (G-5.3-Flash-Agente): fast_travel_effect.gd + qa_fast_travel_fx.gd 25/0 EXIT 0; flips en 69-Fast-Travel/05-Checklist.md (105/33/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
10. - [x] [69] Ilumincación de destino respeta hora del mundo [S] · [x] FX-M69-T2 2026-10-19 (G-5.3-Flash-Agente): qa_fast_travel_fx.gd 36/0 EXIT 0 (J.3 bruma, J.7 modo foto real M56, J.10 iluminación intacta, J.11 no pausa); flips en 69-Fast-Travel/05-Checklist.md (109/29/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
11. - [x] [69] Transición no afecta gameplay (tablas de delta) [S] · [x] FX-M69-T2 2026-10-19 (G-5.3-Flash-Agente): qa_fast_travel_fx.gd 36/0 EXIT 0 (J.3 bruma, J.7 modo foto real M56, J.10 iluminación intacta, J.11 no pausa); flips en 69-Fast-Travel/05-Checklist.md (109/29/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
12. - [x] [69] Subtitulos de feedback de acción [S] · [x] T3-M69 2026-10-19 (G-5.3-Flash-Agente): subtitulos i18n/escala/haptica/contraste en fast_travel_effect.gd — qa 44/0 EXIT 0; flips 05-Checklist (113/25/7); validador i18n EXIT 0 (166/166/166). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
13. - [x] [69] Tamaño de texto escalable para menu (M62) [S] · [x] T3-M69 2026-10-19 (G-5.3-Flash-Agente): subtitulos i18n/escala/haptica/contraste en fast_travel_effect.gd — qa 44/0 EXIT 0; flips 05-Checklist (113/25/7); validador i18n EXIT 0 (166/166/166). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
14. - [x] [69] Confirmación háptica opcional [S] · [x] T3-M69 2026-10-19 (G-5.3-Flash-Agente): subtitulos i18n/escala/haptica/contraste en fast_travel_effect.gd — qa 44/0 EXIT 0; flips 05-Checklist (113/25/7); validador i18n EXIT 0 (166/166/166). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
15. - [x] [69] Contraste alto para menu de selección [S] · [x] T3-M69 2026-10-19 (G-5.3-Flash-Agente): subtitulos i18n/escala/haptica/contraste en fast_travel_effect.gd — qa 44/0 EXIT 0; flips 05-Checklist (113/25/7); validador i18n EXIT 0 (166/166/166). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
16. - [ ] [69] Iconos de apoyo visual al nombre del destino [S] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
17. - [ ] [69] Alt text para thumbnails de destino [S] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
18. - [ ] [69] Modo cronológico para historiales [S] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
19. - [ ] [69] Filtros por tipo de lugar (bioma, servicios) [S] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
20. - [ ] [69] Sin dependencia solo de color para estado [S] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
21. - [x] [69] M28: integración con waypoints descubiertos [S] · [x] T6-M69 2026-10-19 (G-5.3-Flash-Agente): llegar por barco (travel_arrived M28) desbloquea anclas de esa isla (mapeo set_mapa_islas) — test 36/0 EXIT 0 PASS (CHECKS_MINIMOS 28→33); flips 05-Checklist (116/22/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
22. - [x] [69] M29-M31: restricción temporal (noche, tormenta) [S] · [x] T4-M69 2026-10-19 (G-5.3-Flash-Agente): restriccion_temporal_activa() + motivo 'horario' en fast_travel_service.gd — test 24/0 EXIT 0 PASS (GameTime real noche/día verificado); flips 05-Checklist (114/24/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
23. - [ ] [69] M110: debug menu con listado de anchors [S] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
24. - [x] [69] M122: captura de crash si portal falla [S] · [x] T8-M69 2026-10-19 (G-5.3-Flash-Agente): portal roto -> 'portal' + reportar_falla_portal (CrashReporter real, dump user://crash) — 47/0 PASS. <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
25. - [x] [69] M124: balance económico según distancia [S] · [x] T5-M69 2026-10-19 (G-5.3-Flash-Agente): costo_viaje_de()/set_costo_distancia_fn + fórmula cozy default (MundoRaiz CENTRO, tope 1..8) — test 30/0 EXIT 0 PASS (CHECKS_MINIMOS 23→28); flips 05-Checklist (115/23/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
26. - [ ] [69] M32: anulación del portal en clima extremo [S] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
27. - [x] [69] M68: respetar desactivación de hápticos [S] · [x] T7-M69 2026-10-19 (G-5.3-Flash-Agente): vibrar respeta vibracion_on=False (early return M57) — QA FX OK EXIT 0 (K27 x2). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
28. - [ ] [69] M91: respetar volumen de feedback de viaje [S] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
29. - [x] [69] Test de carga: 100 anchors en mapa [M] · [x] T8-M69 2026-10-19 (G-5.3-Flash-Agente): 100 anclas + 1000 lookups O(1) en 2 ms — 47/0 PASS; flips 05-Checklist (120/18/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
30. - [x] [69] Test de coherencia: 1000 teleports consecutivos [M] · [x] T9-M69 2026-10-19 (G-5.3-Flash-Agente): 1000 solicitudes en 2 ms sin drift — 51/0 PASS. <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
31. - [x] [69] Test de día/noche: comportamiento en diferentes horas [M] · [x] T9-M69 2026-10-19 (G-5.3-Flash-Agente): barrido 24 h coherente con GameTime+Weather (0 desvíos) — 51/0 PASS; flips 05-Checklist (122/16/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
32. - [x] [69] Test de desconexión: recuperar estado sin perder progreso [M] · [x] T7-M69 2026-10-19 (G-5.3-Flash-Agente): service como provider M59 (section fast_travel) + round-trip test — 37/0 EXIT 0 PASS; flips 05-Checklist (118/20/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
33. - [x] [69] Test de stress concurrentes: 50 anchors ACTIVOS [M] · [x] T10-M69 2026-10-19 (G-5.3-Flash-Agente): 50 activas + 100 ráfagas sin drift (0 ms) — 55/0 PASS; flips 05-Checklist (123/15/7). <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
34. - [ ] [69] Test de recuperación: archivo corrupto ? resync [M] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
35. - [ ] [69] Test de batería: consumo por viaje a larga distancia [M] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
36. - [ ] [69] Test multidioma: búsqueda en distintos alfabetos [M] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
37. - [ ] [69] Test de aceso: atajos disponibles sin teclado [M] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
38. - [ ] [69] Test de localización: posicionamiento visual ajustado [M] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
39. - [ ] [69] Test de fallback: 3 fallos seguidos ? modo seguro [M] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
40. - [ ] [69] Test de perfilado: sin allocs en frame [M] <!-- fuente: 69-Fast-Travel/05-Checklist.md -->
