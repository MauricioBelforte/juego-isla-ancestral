# BACKLOG-MASTER — DeepSeek-V4.1-Flash — UNIFICADO (metodología V2, fundador 2026-10-17, corregido 04:56)

**Mantenido por:** GLM-5.3-Flash-Director (GLM-5.3-Flash) / Kilo Code — actualizado con evidencia y según nicho (GUIA-COMPARATIVA `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` + estado real del proyecto).
**Unificación 2026-10-17 (directiva del fundador: un solo backlog, en TAREAS-POR-MODELO, NO en canales):** este archivo integra (A) la COLA ACTIVA de 100+ tareas curada por el director y (B) el estado/registro histórico del BACKLOG-MASTER anterior (preservado íntegro desde git). **ESTE es el único backlog válido de DeepSeek-V4.1-Flash.** Tu canal (`Mensajes entre modelos/DeepSeek-V4.1-Flash/`) queda SOLO para comunicación (mensajes + pool de numeración).

## TU CICLO COMO AGENTE (en este orden)

1. **PRIMERA INSTANCIA:** lee si el director te escribió un mensaje en tu canal (`Mensajes entre modelos/DeepSeek-V4.1-Flash/`). Si hay mensaje dirigido a ti, RESPÓNDELO primero (numeración de hilo: último + 1; borra SOLO ese número del pool `NUMEROS_DISPONIBLES.txt` de tu carpeta de canal — pools NO se commitean).
2. [x] **SEGUNDA INSTANCIA:** si NO hay mensajes del director, toma el próximo item `[ ]` de la COLA ACTIVA (sección A) según tu nicho. Trabaja una TANDA de tareas (las que elijas).
3. **CIERRE DE TANDA:** al terminar, escribe un REPORTE en tu canal al director: qué cerraste (ids), evidencia (archivos/tests), y marca `[x]` honesto en ESTE archivo (solo verificable en disco — REGLA CERO: sin reporte, el trabajo no existe).
4. [x] El director actualizará ESTE backlog, la fila de `CHECKLIST-GLOBAL.md` y te responderá.

**Reglas fijas:** reserva 🔵 §21.3 en los 4 registros antes de tocar módulos · UTF-8 §28 · independencia QA §21.8/§21.23 · no editar el backlog de otro modelo · marcas `[ ]/[→]/[x]/[?]` honestas.

---

# (A) COLA ACTIVA — 100+ TAREAS (tandas curadas por el director)

# BACKLOG 100+ TAREAS PARA DEEPSEEK-V4.1-FLASH (WorkBuddy) — Investigación previa por GLM-5.3-Flash

**Modelo:** GLM-5.3-Flash (encargo del fundador 2026-10-16)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 00:00
**Nicho del modelo** (GUIA-COMPARATIVA §5.B3 — TB 2.1 90.6 #1, DeepSWE 74.2, coding agentic/terminal + visión nativa, 1M contexto): coding agentic largo, infraestructura, CI/CD, telemetría, logging, serialización, herramientas, i18n, integración multi-sistema. ⚠️ No confundir con el director `De-Director V4.1` (mismo modelo, rol distinto — §31 AGENTS; ninguno verifica/sella módulos del otro).
**Autoridad:** CANDIDATOS para el director/fundador — nada se arranca sin encargo o reclamo §21.3 en los 4 registros. Conteos estimados a validar contra `05-Checklist.md` al reclamar.

## Reglas del reparto (anti-pisado §17/§21.4)

- Confirmar en CHECKLIST-GLOBAL + ESTADO-PARALELO que el módulo no esté 🔵/🔴 de otro.
- Un módulo por agente a la vez; cerrar marcando 3 lugares + reporte al director (REGLA CERO).

## LAS 100+ TAREAS

> **CICLO 2026-10-23 (Log 2162, msg 378) — RAMA 2, tarea 2 (M01 b1): clasificacion de los 123
> pendientes del indice.** El mensaje **377 del director llego VACIO** (288 B, cuerpo
> `<cuerpo del mensaje aca>`): plantilla sin rellenar, sin directiva. No se invento contenido a
> partir del nombre del archivo (su "42 inconsistencias" no coincide con ninguna medicion de hoy).
> Precedente en HEAD: el 360 de Hy3 marcado **T-19 "mensaje caido"** por el mismo sintoma. Pedido
> de reenvio en el 378. **Premisa medida antes de aceptar la tarea:** el indice esta en
> **29 [x] / 123 [ ] / 0 [?] = 152** y `29 = 26 (iter.8) + 6 aplicados - 3 revertidos` -> los 6
> candidatos de la iter.8 **ya estan aplicados**; repetir ese metodo daba 0. **Entregado:** modo
> `--pendientes` en `scripts/auditar_indice_m01.py` (**EXTENDIDO, no duplicado**: comparte el mapeo
> M## -> carpeta {##+1}, la lectura del GLOBAL y las guardas de ceguera) + bloques I y J en la suite
> (**30 checks / 0 fallos / EXIT 0 x3**, piso re-**MEDIDO** 15 -> 30, **sonda EN ROJO** por
> inyeccion de la rama `resoluble_headless` con restauracion byte-exacta sha256, y sonda de piso
> 30 -> 99 = EXIT 1) + `plan-actual/09-Clasificacion-Pendientes.md` (10.974 B, CRLF, UTF-8 sin BOM).
> **Medido: 123 pendientes = 3 resolubles + 9 bloqueados por la FILA + 4 con la fila sobre-afirmada
> + 107 dependientes del modulo + 0 sin checklist.** Resolubles (propuestos, **NO flipeados**):
> M69 -> `70-Interacciones` 198/0/0, M98 -> `99-Marketing` 169/0/0, M117 -> `118-CI-CD` 113/0/0
> (cautela: es el modulo con CI rojo en HEAD; decision del director). **36 casi cerradas** (<= 5
> abiertos) = cola de candidatos futuros. **Hallazgo grave reportado:** el `05-Checklist.md` de M01
> quedo con **EOL MIXTO** (HEAD 275 LF puro -> worktree 267 CRLF + 9 LF, y esas 9 son exactamente
> las 9 lineas que edito el director) -> `git diff` crudo 276/275 vs **10/9** real con
> `--ignore-cr-at-eol`; si se commitea asi, todo diff futuro de M01 es reescritura total. **NO
> tocado** (05-Checklist de modulo = no tocar sin orden). **Defecto propio corregido:** este BACKLOG
> tenia **1 byte NUL** en su ultima linea (una nota anterior cito el NUL literalmente en vez de
> escaparlo) y por eso git lo trataba como binario (`i/-text w/-text`) y grep lo saltaba en
> silencio; ahora `w/lf`, 0 NUL, 2556 LF intactos. Verificador hoy: **48 alertas** = 39
> inconsistencias + 1 cobertura + 8 colgados; la de M107 del msg 376 ya no aparece. **0 commits /
> 0 push / 0 flips.**

> **CICLO 2026-10-23 (Log 2160, msg 376) — RAMA 1, director 375 -> COLA (tarea 1, M01):** la
> tarea 1 ("diagnostico Patron D de los 126 restantes y mapa de lotes") tenia la **premisa VENCIDA**:
> ese diagnostico ya existe DOS veces dentro del propio `05-Checklist.md` de M01 (iter. 6, 2026-10-14;
> iter. 7, 2026-10-15, Log 1858) y las dos midieron **0 candidatos nuevos**. Lo que faltaba era un
> **refresco medido** 8 dias despues. **Entregado:** `scripts/auditar_indice_m01.py` (NUEVO; criterio
> "checklist propia cerrada Y fila GLOBAL OK", mapeo M## -> carpeta {##+1}, guarda de ceguera exit 3)
> + `scripts/test_auditar_indice_m01.py` (NUEVO) **15 checks / 0 fallos / EXIT 0 x3**, piso 15
> **MEDIDO**, sondas EN ROJO (piso 99 -> exit 1; auditor ciego a candidatos -> exit 1 con 3 fallos),
> restauracion byte-exacta por sha256 + `plan-actual/08-Diagnostico-Indice-Maestro.md` (13,4 KB).
> **Medido hoy:** indice **26 [x] / 126 [ ] / 0 [?] = 152** (coincide con `Totales` y con la fila 01
> del GLOBAL); de los 26, **20 validos + 6 STALE**; **6 CANDIDATOS NUEVOS** (la iter. 7 habia medido
> 0): M05->06-Control-De-Versiones, M18->19-NPC-Y-Vecinos, M21->22-Historia-Principal,
> M89->90-Configuracion-Grafica, M99->100-Community-Management, M113->114-Playtest. **STALE:** M31
> (32-Clima, 2 [?] por sello denegado), M77 (78-Legal, 1 [?]), M112 (113-Pruebas-De-Stress, 1 [?] por
> MI degradacion de P5b), M101 (102-Bug-Tracking, cerrada pero Estado "En curso"), M115
> (116-Instalador, fila corrupta), M124 (125-Terminos, cerrada pero celda en amarillo). **Hallazgo
> estructural:** **8 filas** del GLOBAL (ids 09, 70, 99, 112, 116, 118, 123, 144) tienen la celda
> Modulo ocupada por un check y todo corrido una celda a la izquierda, **conservando 11 celdas** (por
> eso ni el verificador ni un conteo de celdas las ve); verificado que estan asi en **HEAD**
> (`git status --porcelain CHECKLIST-GLOBAL.md` vacio). **Palanca real:** **15 modulos** estan
> cerrados y solo esperan que su fila diga OK (5 se destraban corrigiendo la fila, 2 la celda Estado).
> **Progreso:** suma de las 152 checklists = **19.476 [x] / 993 [?] / 1.586 [ ] = 22.055** vs iter. 7
> (17.485 / 970 / 3.508) -> **+1.991 [x] / -1.922 [ ]** en 8 dias. **Lotes:** A 61 / B 9 / C 13 /
> D 28 / E 0 / F 15 (+20 validos +6 candidatos = 152). **0 commits / 0 push / 0 flips.**

> **CICLO 2026-10-23 (Log 2157, msg 374) — RAMA 1, director 373 (P5d APLICADO):** aplicados los
> **3 flips** autorizados (L36 RF9, L51 Copia 3, L55 Local -> `[x]`, con cita "autorizado por el
> director, msg 373; cita: DeepSeek 372 + Log 2156") y los **5 items** L204-208 pasados a `[ ]` con
> la nota "procedimiento en `03-Diseno.md` §5.1; EJECUCION pendiente del fundador (requiere SU cuenta
> Google)". **§5.1 escrita**: nueva, 116 lineas (+117/-0), 7 pasos (proyecto GCP, Drive API,
> consentimiento con scope `auth/drive`, credencial OAuth **Desktop app**, `rclone authorize`, 3
> secrets, verificacion por `GITHUB_STEP_SUMMARY`) + notas de operacion. Estado M107 medido:
> **177 `[x]` / 0 `[?]` / 5 `[ ]` = 182** (antes 174/8/0; el total no cambia).
> **Correccion al diagnostico del 372:** `04-Codigo.md` §6 **si** enumera los 8 pasos, pero como
> TITULOS; lo que faltaba es el procedimiento (`grep -rn "rclone authorize"` = **0** en todo el repo).
> Los pasos estaban **nombrados, no procedimentados**. **Drift de `Totales`/GLOBAL: NO tocado** (el
> director se lo reservo, msg 373 punto 3): `verificar_checklist.py` sale 1 con 45 inconsistencias, 44
> ajenas preexistentes y 1 mia (`GLOBAL 174/182` vs checklist `177/182`). Tambien corregido
> `12-Solucion-Problemas.md` (+2/-2), que afirmaba que los items "permanecen `[?]`".
> **Hallazgos reportados sin tocar:** `.github/workflows/backup.yml` cita `docs/backup_gdrive_setup.md`
> (no existe, `git ls-files -- "*gdrive*"` = 0) y `07-Resultados-Testings.md` L74 dice "25 `[?]`"
> (drift preexistente). **Pedidos del director ejecutados:** patron de entrada ampliado a
> `*glm-5-3-flash*a-deepseek*` + trampa 129 ("cita EN rango pero MAL atribuida") agregada al skill.
> Numeracion: log **2157**, mensaje **374**. 0 commits / 0 push / 0 flips fuera de los autorizados.

> **CICLO 2026-10-23 (Log 2156, msg 372) — RAMA 1, director 371 (GO P5d M107):** P5d CERRADO con
> **0 flips**. De los 8 `[?]` de M107, **3 estan REFUTADOS** (L36 RF9, L51 Copia 3, L55 Local: la
> justificacion "no verificable headless" es falsa — `backup_local.ps1` implementa la verificacion de
> unidad de destino y el banco `scripts/test_backup_ps1.py` da **49/0/EXIT 0**, con el bloque D
> simulando "disco desconectado" con `Q://` inexistente -> exit 1) y **5 son hueco de DOCUMENTACION**
> (L204-208: los 5 pasos de Google Cloud; `03-Diseno.md` §5 documenta el workflow y los 3 secrets
> pero NO como obtenerlos, grep = 0). Propuestas: L36/L51/L55 -> `[x]`; L204-208 -> `[ ]` o `[x]` si
> escribo `03-Diseno.md §5.1`. **Corregida 1 cita mal atribuida** (L51: `03-Diseno.md L52` -> L86,
> script en L227). **Drift PREEXISTENTE reportado:** M107 en disco = 174/8/182 pero `Totales` y
> GLOBAL dicen 168/176; los 6 `[x]` de diferencia estan apendidos DESPUES del Totales (L399-408) y ya
> estaban en HEAD. Numeracion: log 2156, mensaje 372. 0 commits / 0 push.
> **Trampa nueva:** el director firmo el 371 como `glm-5-3-flash` (guiones) y el patron documentado
> (`glm-5.3-flash-director`) NO matchea -> el mensaje se detecto solo por el orden de NN. Pedido al
> director de ampliar el patron.


> **CICLO 2026-10-23 (Log 2153, msg 370) — RAMA 1, director 369 (P5 a/b/c/d):** P5a CERRADO (el
> `CHECKS_MINIMOS` de M90 ya estaba en HEAD, commit `26f4542`; verificado 57/0 x3 y probado EN ROJO
> con 2 sondas: aborto de runtime y piso subido -> EXIT 1 las dos). P5b CERRADO con resultado
> INVERSO al pedido: de los 50 `[x]` con citas rotas, 19 ya estaban degradados (corrida mia previa,
> commiteados, auditados y correctos) y los **29 restantes NO son degradables** (8 citas imprecisas
> con el artefacto existente, 3 no-artefactos, 1 plantilla, 2 `user://`/scratch, 15 que ya
> documentan la correccion en el propio item) -> 0 flips. P5c CERRADO: la cita `moon_curve.tres`
> (L54) corregida en 3 sitios con las lineas MEDIDAS (carga en `day_night_cycle.gd:114`; L345/L354/
> L377/L381) — la premisa "L54 es de day_night_cycle.gd" era imprecisa: L54 es un comentario.
> **P5d (M107 8 [?], etc.) NO arrancado**: el hallazgo de P5b cambia el criterio (ver P4 del msg 370).
> Drift abierto en CHECKLIST-GLOBAL por las 19 degradaciones previas, pendiente de que el director
> aplique: 113 -> `131/132`, 137 -> `118/131`, 147 -> `130/134`, 164 -> `120/129`.


### Registro de delegaciones (mantenido por GLM-5.3 Flash-Director — ultima pasada 2026-10-16 05:05)

> ⚠️ **División de frentes DeepSeek (directiva del fundador: aprovechar ambos):** este backlog lo usa `DeepSeek-V4.1-Flash` (WorkBuddy). El nuevo **`DS-V4.1-Flash-Opencode`** (OpenCode) tiene canal propio y su encargo inicial: **M117-Build-System + poblado de su backlog** (msg 02 de su canal, 2026-10-16 02:08). Al reclamar tareas de este banco, marcar cuál frente la lleva.

- **M118-CI-CD → DELEGADO por el director (canal DeepSeek-V4.1-Flash msg 264, 2026-10-15 23:00: 12 flips M64 aprobados + commit ok, siguiente M118).** Tarea 20 en vuelo de DeepSeek — no re-clamar. **ACTUALIZACIÓN 2026-10-16 (msg 267): M118 commit HECHO por DeepSeek — pendiente QA §21.8 externa.**
- **M64-IA-De-NPC → QA/flips cerrados por el director (msg 264: 12 flips aprobados).** Tarea 93 queda como refresco/continuación si el director la re-abre.
- **M26-Templo-Subterraneo → DELEGADO formalmente (encargo mens 269, 2026-10-16 02:02): pedido por el propio DeepSeek (su 267), validado por el director (🟡 117/129, complejidad 4, F6).** En vuelo — no re-clamar. QA §21.8 → se deriva a Hy3/agnes al recibir su reporte.

### Bloque A — Su módulo ancla M01 y deuda fundacional

1. [x] M01-Fundamentos (26/152): diagnóstico Patrón D de los 126 restantes y mapa de lotes — 10 [M] — **ENTREGADO 2026-10-23 (Log 2160, msg 376), código + suite + informe.** Premisa VENCIDA: el diagnóstico ya existía en las iters. 6 y 7 (esta última Log 1858), las dos con **0 candidatos**. Refresco medido 8 días después con `scripts/auditar_indice_m01.py` (NUEVO) + suite NUEVA **15/0/EXIT 0 x3** (piso 15 MEDIDO, 2 sondas en rojo, restauración sha256) + `plan-actual/08-Diagnostico-Indice-Maestro.md`. **Resultado: 6 candidatos nuevos** (M05, M18, M21, M89, M99, M113), **6 `[x]` stale** (M31, M77, M112 = regresión real; M101, M115, M124 = bloqueo de fila), **8 filas corruptas** en el GLOBAL y **15 módulos cerrados** bloqueados solo por su fila. **0 flips aplicados** (los aplica el director).
2. [x] M01 b1: resolver bloque dependencias/documentales factibles headless — 10 [M] — **ENTREGADO 2026-10-23 (Log 2162, msg 378), herramienta + suite + informe.** Medido antes de escribir: el indice tiene **29 [x] / 123 [ ] / 0 [?] = 152**, y `29 = 26 (iter.8) + 6 aplicados − 3 revertidos` → **los 6 candidatos de la iter.8 ya estan aplicados** (M05/M18/M21/M89/M99/M113) y los 3 stale revertidos (M31/M77/M112); repetir ese metodo daba 0. Lo que faltaba era clasificar los 123 `[ ]` por la condicion que los bloquea. **Entregado:** `--pendientes` en `scripts/auditar_indice_m01.py` (extendido) + bloques I/J en la suite **30/0/EXIT 0 x3** (piso re-MEDIDO 15→30, sonda EN ROJO por inyeccion + sonda de piso 30→99, restauracion sha256) + `plan-actual/09-Clasificacion-Pendientes.md`. **Resultado: 3 resolubles** (M69→70-Interacciones 198/0/0, M98→99-Marketing 169/0/0, M117→118-CI-CD 113/0/0; propuestos, NO flipeados) **+ 9 bloqueados por la FILA** (M04, M35, M94, M118, M125, M141, M142, M149, M152 — dos con la fila ATRASADA: M35 228/228 vs 227/228, M152 130/130 vs 123/130) **+ 4 con la fila `✅` sobre-afirmada** (M08 106/9/0, M111 228/4/0, M122 106/2/0, M143 104/2/0 = 4 de las 39 inconsistencias del verificador) **+ 107 dependientes del modulo** (de los cuales **36 estan a <=5 abiertos**). **0 flips / 0 commits / 0 push.**
3. M01 b2: continuar (docs del 05-Checklist con cita de archivo) — 10 [M]
4. M01 b3: cierre de lo factible; [?] honestos para el resto — 8 [M]
5. [x] M03-Documentación (130/133): 3 pendientes heredados (L67/L68/L69) — 4 [S]
6. [x] M04/M05: deuda residual (hitos M1) documentada o desdoblada — 4 [S]

### Bloque B — Infraestructura de juego (Recom DeepSeek)

7. [x] M40-Infraestructura (175/211): 36 pendientes → lote 1 con tests headless — 10 [C]
8. M40 b2: continuar — 10 [C]
9. M40 b3: cierre (integración GamedFlowManager/SceneManager) — 8 [M]
10. M62-Memoria (113/150): 37 `[ ]` NO-headless → convertir los posibles a suites reproducibles — 10 [C]
11. M62 b2: iteración 7 (integraciones M08/M41-M44/M63/M09) — 10 [C]
12. [x] M60-Datos (189/196): 7 pendientes — 6 [S]
13. [x] M59-Guardado (60/130): diagnóstico de los 70 y plan de 3 iteraciones — 10 [C]
14. [x] M59 b1: implementar lote 1 (save slots) con suite headless — 10 [C]
15. [x] M63-Cargas (67/101): 34 pendientes → streaming/prioridad — 10 [C]
16. [x] M110-Debug-Menu (150/225): 75 pendientes → lotes de 10 (paneles de debug) — 10 [C]
17. M110 b2: continuar (integración con telemetría M105) — 10 [C]
18. M112-Testing (211/225): 14 pendientes — 10 [M]
19. M117-Build (92/110): 18 pendientes — 10 [M]
20. M118-CI/CD (105/106): cerrar el 1 Pendiente + pulir quality.yml — 3 [S]
21. M123-Modding (106/108): 2 pendientes — 3 [S]
22. M124-CGU (83/108): 25 pendientes → sandbox/validación de mods — 8 [M]
23. M64-IA-De-NPC (102/119): 17 pendientes — 8 [M]
24. M69-Fast-Travel (98/145): 47 pendientes → lote infra (waypoints) — 10 [C]
25. [x] M67-Vehiculos (19/131): plan de iteraciones y lote 1 (física/controles) — 10 [C]
26. [x] M68-Transporte (99/131): 32 pendientes — 8 [C]

### Bloque C — Telemetría, logging y QA de sus sistemas (inf³ propia)

27. M105-Telemetría (129/162): resolver/degradar los 45 [?] con justificación o fix — 10 [C] — **ENTREGADO 2026-10-21 (Log 2075, msg 349), código + suite (no sólo diseño).** Medido antes de escribir: el checklist tiene **33 `[?]`, no 45** (129 [x] / 33 [?] / 0 [ ] = 162). **Hallazgo principal:** las **13 `track_*` tenían 0 llamadores de producción** (grep `.track_X(` sin `test_*` = 0 en las 13; se descartaron patrones alternativos: las 17 menciones de `track_` fuera del director son `track_id` de audio/DLC) → el ítem que afirma «M105 ya emite los 11 eventos first» era un **falso verde**: la API existe, el consumidor no. **Premisa vencida del ítem 228:** decía que el hook de M22 «requiere M22 iteración adicional», pero `EventBus.quest.prereq_met` **existe** y `story_manager.gd:187` **ya lo emite** en producción; faltaba el consumidor de este lado. **Entregado:** `scripts/telemetry/telemetry_bridge.gd` (NUEVO, tabla declarativa `EventBus → track_*`, fail-closed, idempotente, `verificar()` auditable, sin `class_name` por la trampa 123, no saltea el opt-in) + cableado en `telemetry_director._ready()` por `call_deferred` (**0 archivos de M22/EventBus tocados**) + suite NUEVA `test_telemetry_bridge_m105.gd` (9 bloques) **38/0/EXIT 0 ×3**, piso 38 **MEDIDO** (la 1.ª versión puso 40 de memoria y el piso la delató), **guardián en rojo ×3** (aborto de runtime, `_fin` de cierre suprimido, piso 99; las 3 TERMINAN). Regresión 5 suites del módulo: **81 checks / 0 fallos**. **Mapeo decidido por medición de emisores de producción:** de 13 trackers sólo 1 tiene productor real (`prereq_met`); `quest_completed` NO se mapea (es M23, no capítulo), `entrada_nueva` NO (el tracker espera `museo_id`) y `item_added`/`island_loaded`/`travel_started`/`dialog_finished`/`purchase_done` tienen **0 emisores** (arista muerta). **2 defectos propios corregidos:** (1) aserté «un sello distinto sí emite» cuando `_track_first(&"sello")` deduplica por CLAVE, no por id (trampa 88) → se corrigió la aserción, no el código; (2) la sonda B original era un Parse Error por un `replace` de un tab sobre dos. **Flips PROPUESTOS, no aplicados:** 228/227/229 → `[x]`; 322/323 → `[x]`; 198 → corregir la nota pero NO flipear (10 de los 11 siguen sin fuente de datos). **0 commits / 0 push / 0 flips.**
28. M105 b2: re-sello §21.8.2.b luego de resolver [?] (muestreo 5+) — 6 [M]
29. M103-Logging (173/179): 6 [?] (SB-02 etc.) → resolver los factibles y justificar el resto — 8 [M] — **ENTREGADO 2026-10-21 (Log 2072, msg 347), codigo + suite.** El `[?]` de RF18 tenia la **premisa vencida**: decia que M122 no existia y M122 tiene **12 scripts** en `scripts/crash/` + autoload `CrashReporter` (`project.godot:106`). Lo que faltaba era que **nadie llamaba** `flush()` ni exportaba el buffer: el helper `crash_logging.gd` de M122 solo lo usaba su propia suite (**muerto en produccion**). Implementado `crash_log_bridge.gd` (fail-closed, idempotente) + cableado en `logger._ready()` sobre la senal publica `crash_reportado` -> `crash_{timestamp}.log` con las ultimas 1000 lineas + metadata de 03-Diseno 8.4. **Sin tocar un solo archivo de `scripts/crash/`** (dependencia M103 -> M122). Suite nueva `test_crash_bridge_m103.gd` **49/0/EXIT 0 x3**, piso 49 MEDIDO, **4 inyecciones en rojo** (aborto de runtime, piso 99, `_fin` ausente, volcado vacio). **Cableado de produccion verificado con sonda de arranque**: `conectado=true`, `conexiones=1`. Regresiones **365 checks / 0 fallos** (M103 184 + M122 181). Los otros 5 `[?]` re-medidos y acotados: `bug_*.log` 0 apariciones (M102), consola in-game existe en M110 pero 0 busqueda / scroll solo a nivel widget / coloreado por comando y no por nivel (M110), criterio 4 acotado a que `crash_bug_tracking.formatear_cuerpo()` no cita el crash log (M122). Flip `[->]` del RF18 PROPUESTO, no aplicado.
30. M101-QA-General: refresco de plantillas con casos nuevos de la flota — 6 [M]
31. M102-Bug-Tracking: unificar métricas con 11-BUGS.md (reporte automático) — 8 [C] — **ENTREGADO 2026-10-21 (Log 2080, msg 351), herramienta + suite + informe (no sólo diseño).** Medido antes de escribir: `docs/bug_metrics.md` y `.github/workflows/bug_metrics.yml` cuentan **solo GitHub Issues** y el dashboard declara `0 abiertos / 0 cerrados / "sin bugs registrados aún"`, mientras `11-BUGS.md` tiene **25 no resueltos** (14 `[ ]` + 7 `[?]` + 4 `[→]`, 92 filas, 67 `[x]`) y ninguna herramienta de métricas leía el registro (16 archivos citan `11-BUGS`, ninguno cuenta). **Entregado:** `scripts/metricas_bugs.py` (34.141 B; métricas + 9 familias de defecto + drift tabla↔entradas + comparación con el dashboard; `--json` puro, `--check`, `--report`, `--selftest`, exit 3 = detector ciego) + suite `scripts/test_metricas_bugs.py` **20/0/EXIT 0 ×3** con invariantes (no fija los conteos vivos, que cambian a diario) + informe `DOCUMENTACION/102-Bug-Tracking/plan-actual/08-Metricas-Bugs.md` (10.139 B, regenerable). **Prueba EN ROJO:** 4 inyecciones en el medidor (EXIT 1 las 4, cada una nombrando sus fallos, restauración byte-exacta por sha256) + piso recortado a 17 checks → `[FALLO] solo 17 checks ejecutados (minimo 20)` / EXIT 1. **Medido en el registro: 79 defectos** — 49 `entrada_sin_fila`, 8 `entrada_duplicada`, 8 `fila_sin_entrada`, 4 `id_duplicado_tabla`, 4 etiquetas de severidad inconsistentes, 3 `fila_malformada` (L153/L177/L205 = 14/15/6 celdas), 1 `estado_sin_marca` (L141) y 1 `seccion_pegada` (L3061: `## 7. …## BUG-119` deja la entrada invisible), 1 `dashboard_divergente` (0 vs 25). Huecos: 3, clasificados (`[23,119]` mencionados sin entrada canónica, `[45]` ausente del registro). **Límites declarados:** solo lee el registro (no lo edita), no cuenta como entrada un encabezado de formato alternativo, y `--check` sale **1 hoy** → no se cablea a CI sin baseline (decisión del director). **0 commits / 0 push / 0 flips / 0 auto-sellos.** **CIERRE DEL GATE 2026-10-22 (Log 2120, msg 353):** `DEUDA_CONOCIDA` con **71 firmas** (generada por `--deuda`, no escrita a mano) + `_gate()` que compara **MULTISET** (una 2a ocurrencia de una firma conocida tambien es NUEVA) y solo pone rojo con defecto NUEVO + job `bug-registry` en `quality.yml` (suite piso **30** medido / sonda de inyeccion / `--check`), agregado a `summary.needs`, a su `echo` y a la **condicion de fallo** (sin eso el job no bloquearia nada). **Saneamiento del registro: 80 -> 71 defectos** (fila_malformada 4->0, seccion_pegada 1->0, estado_sin_marca 1->0, etiquetas 4->2, **26 celdas de severidad normalizadas**, 2 filas pegadas separadas, BUG-119 despegado, fecha de BUG-127 tomada de su propia entrada). **`--check` = EXIT 0 REAL** (0 nuevos / 0 obsoletas). Sonda `probar_gate_metricas.py` **11/11** (rojo nombrando `fila_sin_entrada:BUG-999`, sha256 del registro real sin cambios). Suite **30/0** x3, piso 30 probado en rojo. **NO** renumerados los 4 ids colisionados (BUG-071/129/130/139 = bugs distintos; decision del director) ni tocadas las 3 etiquetas contradictorias. **0 commits / 0 push / 0 flips.** **RESIDUO SANEADO 2026-10-22 (Log 2128, msg 355):** el director ratificó M102 (msg 354) y pidió seguir el residuo con el mismo criterio de firma. Medido antes: 71 defectos (48 `entrada_sin_fila`, 8 `entrada_duplicada`, 8 `fila_sin_entrada`, 4 `id_duplicado_tabla`, 2 etiquetas, 1 dashboard). Se midió la extraibilidad de las 48 entradas (45 con `**Severidad:**`/`**Estado:**`, 43 con marca, 40 con fecha, 37 con módulo) y se demostró que la fila resumen se puede **transcribir** sin inventar. **Entregado:** `scripts/sanear_tabla_bugs.py` (reutiliza `leer_registro()` del medidor como única fuente de verdad, valida cada celda con `normalizar_*` antes de escribir, diff puramente aditivo, idempotente, `--check`, guardián que aborta si aparece una firma NUEVA) + `scripts/test_sanear_tabla_bugs.py` **23/0/EXIT 0 ×3** con piso 23 **medido** y guardián probado en rojo (estado ilegible → `ok=False`; ancla ausente → aborta). **Resultado: 71 → 24 defectos** (45 filas agregadas en bloque consolidado al final de la §5, 2 omitidas por no declarar `**Estado:**` = BUG-047/070, 1 id corregido L173 `BUG-071`→`BUG-072` ejecutando la RESOLUCIÓN FINAL ya ratificada por atria-dawn en §8.3, `DEUDA_CONOCIDA` purgado 71→24 firmas). **Gate `--check` = EXIT 0** (0 nuevos / 0 obsoletas); `test_metricas_bugs.py` 30/0. Diff del registro **+51/-1** (la única baja es la línea del id), 561788 B, sin BOM, 0 CRLF. **No resueltos 24 → 44 por honestidad**, no por regresión: 20 bugs delegados/abiertos eran invisibles en la tabla. Los 24 restantes **no son mecánicos**: 2 sin `**Estado:**` (deducir el estado contradice la RE-APERTURA de BUG-047), 3 filas huérfanas con id de otro bug (L155/156/160), 8 entradas duplicadas, 8 filas sin entrada, 2 etiquetas, 1 dashboard. **0 commits / 0 push / 0 flips / 0 auto-sellos.** Pedidos: P1 autorizar la sección como fuente de estado, P2 id nuevo o baja de las 3 huérfanas, P3 commit de 4 paths, P4 cablear la suite nueva a `quality.yml`, P5 reposición de cola (9.ª vez). **DUPLICADOS CONSOLIDADOS 2026-10-22 (Log 2130, msg 357):** aceptada la oferta del director (msg 356) de cerrar el residuo sin decidir contenido: `scripts/consolidar_entradas_duplicadas.py` demota el encabezado redundante de 6 pares del MISMO bug (047/051/061/062/089/120) a un puntero `> **Registro previo consolidado...**` conservando el 100% del texto (diff +6/-6; invariante = multiset de lineas, -1 encabezado +1 puntero por consolidacion). **24 -> 18 defectos**, gate `--check` EXIT 0, `DEUDA_CONOCIDA` purgado 24 -> 18 firmas. Selftest **23/23** (piso 23 MEDIDO, 2 guardianes en rojo: fila inyectada nombrada / linea borrada por multiset); gate en rojo por inyeccion (`fila_sin_entrada:BUG-999`, restaurado byte-exacto por sha256). Suites 30/0 · 23/0 · 11/0. Los 18 restantes son **6 decisiones de contenido** (8 filas sin entrada; 5 ids a renumerar: 129/130/139 + uno de 052 y uno de 058; 2 pares con bugs distintos; 2 entradas sin `**Estado:**`; 3 etiquetas de severidad; 1 dashboard). **0 commits / 0 push / 0 flips.**
32. M104-Analytics (107/119): 12 pendientes (catálogo de eventos vs. telemetría) — 8 [M]
33. M107-Backups (167/176): 9 pendientes — 8 [M] — **ENTREGADO 2026-10-22 (Log reservado: 2133, msg 361), codigo + suite (no solo diagnostico).** Medido antes de escribir: el checklist tiene **167 [x] / 0 [ ] / 9 [?] = 176**; los «9 pendientes» son los 9 `[?]` (4 por hardware: L36/L51/L55/L91; 5 por cuenta de Google: L204-L208) -> ninguno flipeable hoy. **Hueco real medido:** `grep -rn "\.ps1" scripts/test_*.py` = **0 referencias** y `quality.yml` solo corre suites `.gd`/`.py`: los 4 scripts de `scripts/backup/` no tenian NINGUNA prueba. **Entregado:** suite NUEVA `scripts/test_backup_ps1.py` (494 lineas, 8 bloques) **49 checks / 0 fallos / EXIT 0 x3**, piso 49 **MEDIDO** en verde, fixtures en temporal (no toca `D:\Backups` ni el hardware); cubre camino feliz + exclusiones reales (`.godot`/`build`) + retencion (archivo+`.sha256`+entrada) + `-Kind mensual` + unidad de destino ausente (L91) + `verify` OK/`[CORRUPTO]`/`[FALTANTE]`/exit 2 + `restore` con checksum previo y round-trip **byte-exacto** + PATH hostil. **2 bugs REALES encontrados y corregidos:** (D-1) `checksums.txt` se corrompe en la **2a** corrida: `$existing + "$hash  $fileName"` **concatena strings** cuando `Get-Content` devuelve un **escalar** (1 linea) -> linea pegada ilegible, `verify` reporta FALTANTE un backup que existe y `restore` extrae **sin verificar el checksum**; el script sale **exit 0** igual (falla en silencio); fix `@()` (+6 lineas). (D-2) `& tar.exe` hereda el PATH: con GNU tar delante (Git/MSYS) `-C 'C:\...'` se lee como `host:ruta` remota -> `tar (child): cannot connect to c: resolve failed`, exit 2; fix `Resolve-TarExe` explicito a `%SystemRoot%\System32\tar.exe` en `backup_local.ps1` y `restore_backup.ps1`. **Guardian EN ROJO x3** (revertir el `@()` = 6 fallos/EXIT 1; piso 99; aborto de runtime en bloque F), restaurado byte-exacto con sha verificado. Diff: `backup_local.ps1` +27/-6, `restore_backup.ps1` +16/-1, suite nueva; EOL respetado por archivo (CRLF/LF), sin BOM, 0 U+FFFD. **0 commits / 0 push / 0 flips** (M107 sigue 167/176). Pedidos: P1 commit de 3 paths, P2 cablear la suite a `quality.yml` (necesita runner **Windows con PS 5.1**), P3 flip propuesto de **L91** y decision de severidad para D-1; `register_task.ps1` queda fuera de la suite a proposito (registra una tarea en el Programador del usuario). **VUELTA 2026-10-22 17:43 (RAMA 1, msg 362 -> reporte 363, Log 2136):** P1 y P3 los ejecuto el director (commit `0dbe925` con los 3 paths + flip L91). Medido por mi sobre HEAD: M107 = **168 [x] / 0 [ ] / 8 [?] = 176**; suite `test_backup_ps1.py` **49/0/EXIT 0** re-corrida (no heredada). **D-1 registrado como BUG-149** en `DOCUMENTACION/11-BUGS.md` (fila en §5 L262 + entrada en §7 + linea en §9; ID 149 porque la lista informal del final ya usa 141-148). Severidad: `🟠 Mayor` **con nota** de que el director pidio "Alta" (la tabla no tiene esa etiqueta y usarla abria un defecto nuevo de `etiqueta_severidad_inconsistente`); `Prioridad sugerida: Alta`. Gate `--check` **EXIT 0** con las mismas **18** firmas de deuda (139 -> 140 filas, 132 -> 133 entradas, 95 -> 96 resueltos). Guardian probado EN ROJO por inyeccion: `estado_sin_marca:BUG-149` -> **EXIT 1**; real EXIT 0. Diff de `11-BUGS.md` **+44/-0**. **Hallazgos:** (a) la fila **107** del `CHECKLIST-GLOBAL.md` sigue en `167/176` — NO esta sincronizada, aunque el 362 lo afirma (archivo protegido: pedido al director); (b) los **8 IDs informales 141-148** de `## Bugs abiertos` no tienen fila ni entrada y el medidor no los ve; (c) el riel de Beam (`BACKLOG-04-VERIFICACION-RETROSPECTIVA.md`) es un protocolo de 6 lineas **sin lote asignado**. **0 commits / 0 push / 0 flips.**
34. M113 (si aplica): hooks de debug con el MCP de Godot — 6 [M] — **[→] MEDIDO 2026-10-22 (Log 2138, msg 365), NO ejecutado:** M113 = `113-Pruebas-De-Stress`, checklist **132 [x] / 0 [ ] / 0 [?]** (287 lineas); **64 items [M], todos [x]**; items con MCP/debug = **1** (`05-Checklist.md:36`, integracion con Debug Menu M110, ya `[x]`). **No hay 6 pendientes que implementar** -> el trabajo real es auditoria contra disco de 6 items [M] (metodo ya escrito y probado: `out/p5_cross_verificador.py`, 14/15 en M91/M147/M24). BLOQUEADO a decision del director (a: 6 que yo elija / b: 6 que designe el / c: reponer items).
35. [→] Refactor de scripts-* duplicados (detección y unificación con evidencia) — 10 [C] — **MEDIDO Y ENTREGADO 2026-10-22 (Log 2141, msg 366).** Universo real: **967** `.py`/`.ps1` (la 1.ª medición dio 4942 archivos y 57 grupos exactos, pero 40 eran `pip/_vendor/rich` de `tools/mcp/.venv` → se excluyeron dependencias vendorizadas y se re-midió). Medido: **2 duplicados exactos, 1 normalizado, 81 funciones duplicadas, 4 nombres repetidos**. **Entregado:** `scripts/detectar_duplicados.py` (3 métodos: sha256 / huella AST con `include_attributes=False` / cuerpo de función sin nombre ni firma; `exit 3` = DETECTOR CIEGO, `--json` puro, baseline `{firma: motivo}` que avisa de firmas OBSOLETAS y conserva los motivos al regenerarse) + `scripts/test_detectar_duplicados.py` **29 checks / 0 fallos / EXIT 0 ×3** con piso 28 **MEDIDO** y 6 controles negativos + `scripts/duplicados_baseline.json` (2 firmas con motivo, gate `--check` **EXIT 0**). **Guardián EN ROJO 3/3** por inyección (ceguera desactivada / deuda obsoleta silenciada / suite recortada), restauración byte-exacta por sha256. **Unificación aplicada (1 caso):** `scripts-reutilizables/generar_tareas_modelo.py` (80 líneas, sin CLI, `__main__` ausente, modelo y módulos de deepseek-v4-flash HARDCODEADOS) quedaba citado como "el patrón" en `GUIA-METODOLOGIA.md:83` mientras el canónico es `scripts/generar_tareas_modelo.py` (220 líneas, CLI `--modelo/--recom/--plataforma/--dry-run`, mtime 11 h posterior) → banner `SUPERSEDED` (contenido intacto como sufijo exacto, verificado por sha256) + la guía cita el canónico. **NO tocados (escalados):** `crear_casa_01_choza.py` idéntico en CASA_01_CHOZA y CASA_02_CASA_MEDIANA (defecto de trazabilidad del asset: la MEDIANA tiene su propio `.glb` con el script de la CHOZA), `nutria_ribera_alta.py` duplicado en `36-Fauna/scripts-blender/` (subcarpeta de 1 archivo), las 81 funciones de boilerplate Blender (`crear_mat` en **42 archivos**) y 2 scratch sin trackear. **0 commits / 0 push / 0 flips.** Pedidos P1-P5 en el msg 366.

### Bloque D — Config y UX técnica

36. [→] M90-Configuración-Grafica (149/249): 100 pendientes → lote 1 (presets) — 10 [C] — **MEDIDO 2026-10-22 (Log 2142, msg 368): PREMISA VENCIDA, NO EJECUTABLE.** Conteo estricto por prefijo: el checklist tiene **249 [x] / 0 [ ] / 0 [?] = 249 items** (el propio archivo lo declara en su linea `**Totales:**`: «Completados: 249 - Pendientes: 0»); no hay 100 pendientes. **Verificacion positiva contra disco (no basta con decir «no hay pendientes»):** `game/isla-ancestral/scripts/settings/graphics_config.gd` 24.630 B / 575 lineas con `EFECTOS` L68 `{baja 0.25, media 0.5, alta 0.85, ultra 1.0}`, `PRESETS` L126, `aplicar_preset()` L174, `preset_actual()` L182; y las 2 suites corridas HOY con el binario real Godot 4.7.2 headless: `test_graphics_config.gd` **85 checks / 0 fallos / 6 bloques / EXIT 0** y `test_graphics_config_post_m90.gd` **57 checks / 0 fallos / EXIT 0**, ambas con 0 SCRIPT ERROR. **Los 249 [x] de M90 estan respaldados por codigo y pruebas reales; 0 falsos verdes encontrados.** **2 huecos reales medidos y NO tocados (M90 esta en NO TOCAR):** (a) la suite post no tiene `CHECKS_MINIMOS` (su `_fin()` solo mira `_fallos == 0`), asi que una corrida recortada seguiria diciendo PASS; (b) ninguna de las 2 suites esta cableada a un workflow (el propio checklist dice «Sin gate en CI: el test NO corre en ningun workflow»). **Auditoria de citas del modulo (herramienta nueva de esta vuelta): 293 citas, 0 defectos.** Items 37 y 38 son igual de vacuos (mismo modulo). **0 commits / 0 push / 0 flips.**
37. M90 b2: continuar (escala de resolución/VSync) — 10 [C]
38. M90 b3: cierre con export de settings a M60 — 8 [C]
39. M91-Configuración-De-Audio (212/239): 27 pendientes (trabajo en vuelo de step-5-kilocode) — 10 [C]
40. M91 b2: cierre + regresión completa de buses — 8 [C]
41. M57-Interfaz-De-Control (91/119): 28 pendientes (remapeo) — 8 [M]
42. M58-Accesibilidad (154/183): 29 pendientes → lote técnico (subtítulos, daltonismo) — 10 [M]
43. M58 b2: cierre con test de contraste — 8 [M]
44. M53-UI (144/165): 21 pendientes técnicas (no visuales globales) — 8 [M]

### Bloque E — i18n y localización (deuda conocida de Ling M87.5)

45. [x] M87-Localización (131/136): cerrar 5 pendientes — 6 [M]
46. i18n clave-exhaust: aspirar las 112 claves externas documentadas por Ling (canal) — 10 [C] — **ENTREGADO 2026-10-21 (Log 2063, msg 340), flip `[->]` PROPUESTO (no aplicado).** Medido antes de escribir: las 112 claves de Ling viven en `data/localizacion/strings_*.json`, que el autoload `Localization` **NO lee** (carga `res://locales/*.po`) → el catálogo que las contiene es un **decoy**. De las 25 que seguían sin entrada en el `.po`, **14 tienen consumidor real** (los 7 recursos de capítulo de M149, campos `nombre_clave`/`descripcion_clave`) y 11 son huérfanas. **Aspiradas las 14** a `es.po` y `en.po` (260 → **274** claves cada uno, `+45/−0`, LF, sin BOM, 0 U+FFFD). **Guardia nueva:** `auditor_claves.gd` `+62/−2` — el auditor solo miraba `.gd`, así que una clave declarada en un `.tres` era invisible; se agrega `RE_CLAVE_RECURSO` con **`(?m)`** obligatorio (sin el flag el barrido da 0 en silencio), `_escanear_recurso()` en buckets propios y los campos `recursos`/`claves_recurso_total`/`claves_recurso_sin_catalogo` (no entran en `ok`: es deuda de contenido). Suite NUEVA `test_catalogo_exhaustivo_m87.gd` (7 bloques) **36/0/EXIT 0 ×3**, piso **36 MEDIDO**; guardián probado EN ROJO por inyección (clave quitada de un `.po` → detectada; `_fin` quitado → EXIT 1; piso 99 → EXIT 1). Regresión 9 suites i18n: **355 checks / 0 fallos**. **Falso verde corregido:** `test_capitulos_m74.gd` validaba el decoy `strings_es.json` y pasaba VERDE con las 14 claves ausentes del catálogo real; ahora valida `es.po`/`en.po` y nombra las faltantes (+18/−10), probado en rojo con `range(1,9)` → EXIT 1. **Hallazgo de contenido NO tocado:** el barrido nuevo mide **25 `.tres`, 44 claves declaradas, 30 ausentes** — los 15 eventos base de M74 sin catálogo; no las aspiré porque **no hay texto de origen** y no invento contenido narrativo → decisión del director. **Hallazgo estructural:** copia MUERTA del manager en `scripts/localizacion/localization_manager.gd` (JSON-based, 2.729 B) + `strings_pt.json` sin `pt.po` (idioma imposible de mostrar). **0 commits / 0 push / 0 flips / 0 auto-sellos.**
47. i18n b2: validación de placeholders y pluralización — 10 [C] — **ENTREGADO 2026-10-20 (Log 2050), código + suite (no solo diseño).** Medido antes de escribir: `validador_po.gd` ya cubría R1-R13 + P1/P3/P5 (el placeholder entre IDIOMAS ya estaba), así que el hueco real eran 3 cosas. **R14 (nueva, ERROR):** la cabecera declara `nplurals=2` y solo se verificaba que existiera el índice 0 -> un plural con `msgstr[0]` y nada más pasaba VERDE y el motor cae siempre a la forma 0. **R15 (nueva, ERROR):** `placeholders_de()` UNE todas las formas plurales en un conjunto, así que una forma que pierde `{n}` era invisible (texto sin el número, sin error en runtime); ahora se comparan firmas POR FORMA. **Tercer hueco:** nada verificaba que una clave con `%d`/`%s` se resuelva con el operador `%` (`.format()` sobre `%d` no sustituye y no lanza -> el jugador ve `Comprar: %d AO`). Artefactos: `validador_po.gd` +46/−1 (`nplurals`, `_nplurals_de()`, `_firma_placeholders()`, `_unir()`, R14, R15) y suite NUEVA `test_placeholders_plurales_m87.gd` (7 bloques) **46 checks / 0 fallos / EXIT 0 ×3 / 0 SCRIPT ERROR**, piso 46 MEDIDO en verde; guardián EN ROJO por inyección (piso 99 -> EXIT 1; `_fin("r15_formas")` -> `pass` -> EXIT 1). Regresiones verdes: validador_po_m87 **87**, test_localization **23**, iter2 **21**, iter3 **12**, iter4 **25**, iter6 **82**, M68 **177/199/108**. Datos reales: los `.po` PASAN las 3 reglas (no había defecto vivo; faltaba la red). Hallazgos: `tr_n()` de producción = **0** (el proyecto pluraliza por `_plural_forms`), y **2 claves huérfanas con placeholder** (`SETTINGS.HORAS_H`, `SETTINGS.MIN_M`, 0 sitios de llamada en 737 `.gd`) -> decisión del director. **No se tocó** `quality.yml` (cablear al CI es del director). Flip `[->]` propuesto; marca sin tocar.
48. i18n b3: migración de fuentes tipográficas si faltan glifos (M88) — 8 [M] — **ENTREGADO 2026-10-21 (Log 2064, msg 342), código + suite (no sólo diseño).** Medido antes de escribir: los `.po` exigen **79** codepoints (74 en `es.po`, 69 en `en.po`; 275 entradas y 278 formas cada uno) y las **4 fuentes reales** de `assets/fonts` cubren **78 de 79**: el único glifo ausente es **`U+2192` (flecha)**, que usan **31 claves** (`M68.SIGN.*`, `M68.ROUTE.*`, la misma clave en los 2 idiomas) y **3 sitios de producción** (`crafting_ui.gd:209`, `diary_layer.gd:634`, `transport_localizer.gd:327/400`). **Dos falsos verdes corregidos:** (1) el único detector de cobertura del repo (bloque B de `test_fuentes_reales_m88.gd`) decidía "falta el glifo" por **ANCHO** — un glifo ausente se dibuja como `.notdef` y su avance **no es cero** (medido: `U+2192` = **14.0 px** con `has_char() == false`); prueba comparada con el MISMO input: método viejo **43/0/EXIT 0 (falso verde)**, método nuevo **43/4/EXIT 1** nombrando `["→"]`; (2) `_check(..., true, ...)` infalsificable en L206, reemplazada por el contrato inverso (`tiene_archivo=false` con el `.ttf` en disco) y probada en rojo copiando `Nunito-Regular.ttf` como `museo_moderno.ttf` → EXIT 1. **Artefactos:** `scripts/fonts/auditar_glifos.gd` (8.912 B, parser `.po` por ENTRADAS —los comentarios no son texto mostrable: 16 no-ASCII por bytes vs. 14 reales, `U+2500` sólo vive en `# ──`— + cobertura por `has_char` + informe), suite NUEVA `test_glifos_i18n_m88.gd` (6 bloques) **50/0/EXIT 0 ×3**, piso 50 MEDIDO, guardián en rojo por 3 inyecciones (incluido un aborto de RUNTIME: nombra A + `solo 39 checks`), y `data/fonts/glifos_sustitutos.json` (tabla `U+2192`→`U+00BB` como DATO, **sin cablear**: 0 consumidores). Regresiones 15 suites: 332 i18n + 484 M68 + 126 fuentes, 0 fallos. **La mitigación NO está activa** (el jugador sigue viendo la caja): el contenido (62 entradas) y el cableado son decisión del director; flip **parcial** propuesto, no aplicado. **0 commits / 0 push / 0 flips / 0 auto-sellos.**
49. M88-Fuentes (174/185): 11 pendientes — 8 [M] — **ENTREGADO 2026-10-21 (Log 2066, msg 345), código + suite (no sólo diseño).** Medido antes de escribir: los 11 «pendientes» son los 11 `[?]` (el checklist tiene 0 `[ ]`) y **sólo uno tiene bloqueo de código y dueño M88**: L36 «Optimizar archivos de fuente», cuyo KnownIssue dice literalmente que el subsetter/compressor está DISEÑADO en 03 §9 y NO implementado. Causa raíz medida: §9 delega en `pyftsubset` y `woff2_compress` y **ninguna está instalada** (`import fontTools` → `ModuleNotFoundError`). **Artefacto nuevo `tools/font_subsetter.py`** (stdlib pura, ~590 líneas): parsea sfnt + `cmap` (4/12), conserva glifo 0 + glifos alcanzables + **cierre transitivo de componentes**, reconstruye `glyf`/`loca`/`hmtx`/`hhea`/`maxp`/`head`/`cmap`(format 4)/`post`(v3.0), descarta `GDEF`/`GPOS`/`GSUB`/`kern`/`hdmx`/`VDMX`/`LTSH`/`DSIG` (referencian IDs de glifo), recalcula checksums y **verifica su salida antes de escribirla** (8 checks; si falla, exit 1 sin escribir). **Medido:** `Nunito-Regular` 132.312→**10.620 B** (92,0%), `Nunito-Bold` 132.280→**10.596 B** (92,0%), `FredokaOne` 39.724→**11.328 B** (71,5%); **total 304.316→32.544 B = 89,31% menos (271.772 B)**; glifos 1.103→83. **No están corruptos:** Godot los carga, `has_char` cubre **78/79** (falta sólo `U+2192`, igual que el original) y `get_string_size("Hola mundo")` = 89,00 px. **Caso ROJO:** subset de 1 carácter → 1.852 B, `A=true ñ=false →=false`. **Suite nueva `test_fuentes_optimizadas_m88.gd`** (6 bloques) **49/0/EXIT 0 ×3**, piso **49 MEDIDO**, guardián en rojo por 3 inyecciones (piso 99; `CODEPOINTS_ESPERADOS` 78 → 4 fallos; aborto de RUNTIME → nombra D/E/F). **Hallazgo de diseño propio corregido:** con `_summary()` al final de `_correr()`, un aborto de runtime **COLGABA** la suite (2m07s hasta matarla) en vez de fallar; ahora el resumen va en un `call_deferred` **separado**. **Triangulación:** los 79 codepoints del catálogo salen idénticos por GDScript (`auditar_glifos.gd`) y por Python (mismo conjunto, 0 diferencias en ambos sentidos); dos errores propios corregidos al medir (filtro `> 0x7F` daba 13; contar cabecera + `msgid`-clave daba 94). Regresión 5 suites de fuentes: **175 checks / 0 fallos / 0 SCRIPT ERROR**. **La optimización NO está aplicada** (los assets quedan intactos, verificado por sha256): aplicarla, cablear la suite en `quality.yml` y los flips son decisión del director. **Hallazgos NO tocados:** L216 `[?]` con **premisa falsa** (`FredokaOne-Regular.ttf` SÍ existe: 39.724 B, 222 glifos, carga en Godot) y KnownIssue 215/216 cruzados; criterio de marcado inconsistente en 212-216 (**L214 `[x]` Nunito-Medium sin archivo** vs **L216 `[?]` con archivo**).

### Bloque F — Datos, clock, calendario, eventos técnicos

50. M29-Tiempo (192/195): 3 pendientes — 4 [S] — **MEDIDO 2026-10-21 (Log 2072, msg 347): NO EJECUTABLE, no se toco.** El conteo real es **193 [x] / 0 [ ] / 2 [?] = 195** (uno de los 3 ya se cerro) y los 2 `[?]` son el MISMO item duplicado (L75 y L207/D72 'Flecha indicadora en el HUD'). `grep -rn flecha` sobre `game/isla-ancestral/` = **0 flechas de HUD**. La API de M29 si esta y si tiene consumidor (`w_reloj.gd:299` conecta `evento_proximo` -> badge con el nombre del evento), pero el **badge de M30 no es la flecha**: el artefacto es UI de **M53**. OpenCode ya midio lo mismo el 2026-10-16 (Log 1896). No se flipea por conveniencia.
51. M30-Reloj (119/120): 1 pendiente — 2 [S]
52. M31-Ciclo-Día/Noche (120/169): 49 pendientes → lote técnico (skybox/luz) — 10 [C]
53. M32-Clima (119/121): 2 pendientes — 3 [S]
54. M74-Eventos (227/285): 58 pendientes → lote técnico de scheduler — 10 [C]
55. M74 b2: continuar eventos (hooks con M22/M23) — 10 [C]
56. M71-Progresión (168/213): 45 pendientes → lote XP/niveles — 10 [C]
57. M72-Logros (77/185): diagnóstico completo + lote 1 de logros técnicos — 10 [C]
58. M73-Coleccionables (26/135): lote técnico de tracking y persistencia — 10 [C]
59. M75-Postgame (17/130): lote técnico de gating postgame — 10 [C]

### Bloque G — Mundo técnico (Recom compartido)

60. M09-Terreno (100/105): 5 pendientes (recetas/pipeline glb) — 8 [C]
61. M10-Generación (88/106): BUG-043 snow + capas faltantes (cuevas/estructuras) — 10 [C]
62. M10 b2: knobs/config del generador (autoload, retry de chunks) — 10 [C]
63. M11-Personaje (75/123): 48 pendientes → lote de control/animación — 10 [C]
64. M11 b2: continuar (movimiento de voxel + cámara) — 10 [C]
65. M12-Cámara (57/102): 45 pendientes → lote zoom/colisión de cámara — 10 [C]
66. M14-Inventario (136/140): 4 pendientes — 4 [S]
67. M16-Crafting (157/203): 46 pendientes técnicas — 10 [C]
68. M33-Agricultura (106/153): 47 pendientes → lote técnico de crecimiento/ciclos — 10 [C]
69. M34-Pesca (99/153): 54 pendientes → lote técnico (cañas/estanques) — 10 [C]
70. M35-Minería (101/142): 41 pendientes — 10 [C]

### Bloque H — Social y económico (integración)

71. M20-Amistad (50/148): lote técnico (puntos/regalos) — 10 [C]
72. M21-Dialogos (82/143): 61 pendientes → lote técnico de graph/nodos — 10 [C]
73. M23-Historias (24/104): lote técnico de triggers/notas — 10 [C]
74. M472-Relaciones? N/A — reemplazo: M22-Historia-Principal (✅ 91/91): refresco de hooks con M31/M74 — 4 [S]
75. M37-Museos (96/148): lote técnico (exposiciones) — 10 [C]
76. M38/M39 (✅): refrescos de integración con M16/M159 — 6 [S]
77. M54-Mapa (133/177): 44 pendientes técnicas (markers/fog) — 10 [C]
78. M55-Diario (37/131): lote técnico de UI de diario — 10 [C]
79. M56-Fotografía (26/137): lote técnico (cámara de foto, export) — 10 [C]

### Bloque I — Legal/marketing técnico (cero-riesgo)

80. M80-Privacidad (142/144): 2 pendientes — 3 [S]
81. M81-Menores (135/137): 2 pendientes — 3 [S]
82. M82-Clasificación (95/100): 5 pendientes — 4 [S]
83. M83-Licencias (98/100): 2 pendientes — 3 [S]
84. M87×M126 (Marketing-Legal, 100/101): 1 pendiente — 2 [S]
85. M126-Marketing-Legal: cierre — 3 [S]
86. M127-Copyright (76/100): 24 pendientes de atribución por archivo (pipeline glb) — 8 [M]
87. M128-Identidad (60/100): lote técnico de paleta/logo assets export — 8 [M]
88. M129-Merchandising (101/108): 7 pendientes — 6 [S]
89. M131-Créditos (86/95): 9 pendientes — 6 [S]
90. M96-Plataformas (105/106): 1 pendiente — 2 [S]
91. M99-Marketing (155/169): 14 pendientes técnicas (embeds, metas) — 8 [M]

### Bloque J — Mundo/NPC avanzado + QA técnica cruzada

92. M19/M65 (✅): refrescos de runtime verificable — 4 [S]
93. M64 b2 (IA-NPC): pathfinding — 10 [C]
94. M84-Economía/Precios: refresco headless de shops/test_loop_economico (14/1 pendiente) — 6 [M]
95. M93-Balance (131/134): 3 pendientes — 4 [S]
96. M94-Retención (87/138): lote técnico de metrics/FOMO-off — 8 [M]
97. M92-Tutorial (132/185): 53 pendientes técnicas — 10 [C]
98. M51-Agua (140/166): 26 técnicous pendientes — 8 [C]
99. M50-Vegetación (129/142): 13 pendientes técnicas — 6 [M]
100. M52-Partículas (147/148): 1 pendiente — 2 [S]
101. M66-Anti-Softlock (110/117): 7 pendientes — 6 [M]
102. M61-Rendimiento (53/148): lote técnico de perfil/culling (tarea suya del nicho CI) — 10 [C]
103. [x] Re-contado global honesto: corrida de `scripts/verificar_checklist.py` y reporte — 6 [M] — **HECHO 2026-10-17 (Log 1940, msg 295)**: 167 modulos, 19.207 `[x]` / 3.656 `[ ]` / 1.150 `[?]` = 24.013; 178 alertas; **GLOBAL ciego en 16 modulos** por tabla degradada (L22 cabecera+separador fusionados, 16 filas con celdas vacias iniciales, 6 sin `|` de cierre). Reparacion de `CHECKLIST-GLOBAL.md` pedida al director (archivo protegido para mi).
104. [x] Barrido de módulos ✅ sin verificación reciente: muestreo §21.8.2.b pedido por director — 10 [C] — **EN CURSO 2026-10-17 (Log 1944, msg 297)**: 5 de los 9 verdes con sello viejo muestreados (M07 6/6 · M111 12/12 · M136 9/9 · M165 6/6 · M125 4/5) = **38 ítems, 1 falla (2,6%)** → **5/5 sellos VÁLIDOS**. Falla real: **M125 L135** `legal/terms_policy.md` NO existe y su propio `04-Codigo.md:227` lo marca "IMPLEMENTACIÓN INMEDIATA" (inflación Familia A). Hallazgo transversal: **3 verdes con ítems abiertos** (M04 126/128 · M05 99/103 · M140 100/124) = DoD §21.6 violada, mismo criterio que bajó M24/M85. Quedan por muestrear M86, M79, M168, M78. GLOBAL tras la reparación del director: 68 filas mal formadas (antes 152), 2 líneas con mojibake, Totales 126/129 con línea duplicada al final. **SEGUNDA MITAD 2026-10-17 (Log 1949, msg 299):** muestreados los 4 verdes restantes — M78 41 citas válidas/12 rotas · M79 0/103 sin cita · M86 3 válidas/12 rotas · M168 0/104 sin cita = **493 ítems, 44 con cita verificable (8,9%), 24 citas a subsecciones inexistentes, 2 `[x]` sin sustancia en M86 (L94, L124)**. Límite del método declarado: 425 ítems (86,2%) no llevan cita → **M79 y M168 NO son muestreables por cita** (no es que pasen: no hay nada que medir).
105. [x] Preparación de specs para módulos ✅→🟡 por [?]. — 8 [M] — **HECHO 2026-10-17 (Log 1950, msg 301)**: el universo medido es de **2 módulos y 2 ítems**, no más: `M125 L135` (falta `legal/terms_policy.md`) y `M86 L124` (música que “suena similar”). **M86 lo abrió otro agente hoy** (degradó L124 a `[?]`), así que el universo genuino era 1. Specs preparadas con contrato medido: M125 → el artefacto **no lo consume código** (el runtime lee `res://data/legal/terminos.json`; `terms_config.gd:13`), molde hermano `game/isla-ancestral/legal/terms_of_service.md` (159 líneas, 11 secciones), y desajuste a declarar: `terms_date="2026-01-01"` vs documento fechado `2026-10-03`. M86 → la cita `03-Diseno.md §3.8` es **fantasma** (el doc tiene `## 1.` a `## 8.`, la 3 es una tabla); la decisión ya estaba en `plan-inicial/05-Checklist.md:124` (“se descarta si hay duda”) pero nunca se transcribió al diseño. Criterios de cierre entregados (5 puntos M125, 4 puntos M86). **HALLAZGO A (nuevo y grave): al `CHECKLIST-GLOBAL.md` le faltan 6 filas** — 167 checklists vs 162 filas; ausentes 48, 104, 115, 127, 139 y 148; existían íntegras en `4d1ee65` (2026-09-15, 167 filas) y la serie de commits medida es 152 (`3f8382a`) → 159 (`b9e6062`) → 162 (`1bc3dca`) → 162 (`304fdc5`): el director ya recuperó 10, quedan 6. El verificador **no puede verlo** (trampa 91: compara contra el diccionario que arma con las filas que encuentra). **HALLAZGO C**: 3 alertas nuevas en M86 (25→28) por un edit ajeno que aplicó mi hallazgo de L124 pero rompió `validar()`→`alidar()` y borró el newline final. **NO aplicado**: las 6 filas (sin autorización; 6 de 11 columnas son manuales), los artefactos (dueño agnes-2.5-flash), el gate de cobertura (requiere `isla-ancestral-qa-gate`) y ningún commit.

> **Registro de la vuelta 2026-10-17 19:35 (RAMA 2, ítem 104):** Log reservado **1944** (`Logs/1944-M07-Barrido-Verdes-Muestreo-21.8.2.b_2026-10-17_19-35-00.md`, ASCII puro + CRLF, 10.663 B); mensaje **297** al director (UTF-8 sin BOM, LF, 6.167 B). Pool de Logs: cabeza medida justo antes = 1944 → 1945. Pool de canal: 296 → consumido 297 (cabeza 298). 0 commits, 0 push, 0 flips, 0 auto-sellos §21.8.

> **Registro de la vuelta 2026-10-17 23:10 (RAMA 2, punto 5 del msg 302):** Log **1959** (`Logs/1959-M118-Reanclaje-Citas-Fantasma-Y-16-Totales_2026-10-17_23-07-50.md`, ASCII puro + CRLF, 8.725 B) y mensaje **304** al director (UTF-8 sin BOM, LF, 6.265 B). Pool de Logs: cabeza medida justo antes = 1959 -> 1960. Pool de canal: 304 consumido -> cabeza 305. **Re-anclaje:** 11 citas fantasma corregidas a anclas verificadas en disco (9 de M86 `§3.x`, 2 de M78 `§1.6`/`§1.7`, estas 2 marcadas como PARCIALES en la propia linea); 4 de M78 declaradas irrecuperables (`§1.8`, `§1.9`, `§1.10`, `§1.11`). Fantasmas medidos: **30 -> 19** (M78 17->15, M86 13->4). **`Totales`:** 12 bloques vigentes re-medidos + 2 historicos relabelados (M156 L432, M31 L425); excluidos 104 (lista NO TOCAR) y 159 (checklist sucio por otro agente). Verificador: **35 -> 21 alertas**, `Totales` incoherentes **16 -> 2**. 0 flips, 0 cambios de marca (conteo `[x]/[ ]/[?]` identico a HEAD en los 15 archivos). **0 commits / 0 push.** **Discrepancia con el director:** su 302 dice «items 106+ listos» y asigna los items 149/150, pero esta COLA ACTIVA **termina en el 105** y 149/150 no existen en el archivo -> pedido de que los mande escritos.

---
> **Registro de la vuelta 2026-10-18 00:20 (RAMA 1, msg 305 del director — puntos 2 y 3):** Log **1963** (`Logs/1963-M78-M86-Citas-Fantasma-19-Reanclaje-Y-Muestreo-79-86_2026-10-18_00-15-00.md`, ASCII puro + CRLF, 9.640 B) y mensaje **306** al director (UTF-8 sin BOM, LF, 5.391 B). Pool de Logs: cabeza medida justo antes = 1963 → 1964. Pool de canal: 305 consumido → cabeza 306. **Citas fantasma: 19 → 0 vivas** — 9 re-ancladas con la línea destino leída antes de escribir (M78 L67/L68/L91/L125/L130/L134/L136, M86 L64/L65) y 10 declaradas irrecuperables con marcador `[CITA IRRECUPERABLE 2026-10-18: §X no existe...]` (M78 L96/L100/L106/L140/L151/L152/L183/L185, M86 L124/L143). **Flip aplicado por orden escrita del 305:** M78 L95 `[x]` → `[?]` (el ítem pide EUIPO/WIPO/INPI; el doc solo documenta USPTO) → M78 **157/0/0 → 156/0/1**, `**Totales:**` actualizado + nota de re-medición. M86 sin cambio de marcas (128/0/1 = 129). **Consecuencia declarada:** 2 alertas nuevas en `verificar_checklist.py` (M78 GLOBAL dice 157/157 vs 156/157 real, y `[?]` con estado `✅ Completado`) — celda del GLOBAL pedida al director (archivo NO TOCAR). **Muestreo sello-cabecera 79-86 (la "próxima" del 305):** 6 hallazgos medidos, ninguno tocado — **M79 L7 define `[x]` como completado Y como pendiente** (103/103 infalsable, trampa 18), M81/M82 cabecera con emoji destruido `??` y estado ≠ GLOBAL, M83 EOL mixto (250 CRLF + 2 LF), M84 un **U+FEFF** suelto en el offset 575, M85 celda `Estado` del GLOBAL con 2 progresos embutidos. EOL respetado por archivo (M78 `w/crlf`, M86 `w/lf`), 0 BOM, 0 CR sueltos, diff 18/17 y 4/4. **0 commits / 0 push / 0 auto-sellos §21.8.**

> **Registro de la vuelta 2026-10-18 23:19 (RAMA 2, ítem 45 — M87-Localización, por el CI rojo):** Log **2005** (`Logs/2005-M87-Auditor-Claves-Falso-Positivo-Literal_2026-10-18_23-19-37.md`, ASCII puro + CRLF, 10.726 B) y mensaje **314** al director (UTF-8 sin BOM, LF, 8.770 B). Pool de Logs: cabeza medida justo antes = 2005 → 2006. Pool de canal: 314 consumido → cabeza 315. **CI (3 jobs rojos medidos):** `legal-tools` = 300 PNG de `assets/2d/items_m159/` sin metadata (deuda de M159); `encoding-guard` = **3 BOM en HEAD** (M161 ×2, M83) con el fix **ya en el worktree sin commitear**; `test-suite` = **M87, 84 checks / 2 fallos / EXIT 1**. **Causa raíz del test-suite (reproducida en local):** el auditor capturaba `), ` como clave de PRODUCCIÓN desde un **literal de cadena** (`src.contains("_t(")` en `diag_ui_en.gd:299` y `test_diario_ui.gd:294`, archivos ajenos NO tocados). **Fix en `auditor_claves.gd`** (+55/−8): `RE_CLAVE_VALIDA = ^[A-Za-z0-9_.|]+$` (las 243 claves de `es.po` lo cumplen — medido), `_registrar()` como único punto de entrada con descarte, y `inf["descartadas"]` auditable en el informe. **`test_validador_po_m87.gd`** (+15/−1): 3 checks de regresión con el fixture exacto + control negativo; `CHECKS_MINIMOS` re-MEDIDO 84 → 87. **Medido: 87 / 0 / EXIT 0 ×3 corridas, 0 SCRIPT ERROR, `usadas_sin_clave` = [], veredicto OK.** Prueba **EN ROJO** por inyección de una clave ausente real: 87 / 2 fallos / EXIT 1 nombrando archivo y clave (sonda borrada, verde re-medido). Regresión de las 5 suites hermanas: 23/0, 21/0, 12/0, 25/0, 82/0. **Hallazgo grave NO buscado:** `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md` fueron **re-codificados** (doble mojibake + BOM + CRLF) a las **23:14:43 / 23:15:02**, 3-4 min después de HEAD, con **filas idénticas** (182 / 202) y **sin inverso limpio** (probado `cp1252` y `latin-1`: ambos fallan) → **no se tocan**, decisión al director. **Corrección heredada:** la COLA ACTIVA **no** está agotada — de los 105 ítems numerados solo 3 llevan `[x]`; los otros 102 no tienen checkbox y el `grep '- [ ]'` no podía matchear nada. Se retira el pedido de reposición. **El ítem 45 queda SIN marca** (no cierro los 5 pendientes; el flip lo aplica el director). **0 commits / 0 push / 0 flips / 0 auto-sellos §21.8.**

> **Registro de la vuelta 2026-10-19 00:47 (RAMA 1, msg 315 del director — punto 3, `quality.yml` AUTORIZADO por escrito):** Log **2011** (`Logs/2011-M118-Aviso-Suite-Fallida_2026-10-19_00-47-32.md`, ASCII puro + CRLF, 6465 B) y mensaje **316** al director (UTF-8 sin BOM, LF, 3958 B). **Cambio:** solo el job `test-suite` de `quality.yml` — helpers `suite()`/`py_suite()` con los argumentos PASADOS TAL CUAL + una línea `::error::FALLO <script>` por suite fallida + resumen con contadores medidos en la corrida. **Medido:** 93 invocaciones cableadas (91 godot + 2 python); 2 `|| FAIL=1` intactos fuera del job (steps de un solo comando); equivalencia de argumentos viejo-vs-nuevo = 99 vs 99 llamadas y **0 diferencias**; verde EXIT 0/0 anotaciones; rojo 1 y rojo 3 = EXIT 1 con 1 y 3 líneas que nombran la suite exacta (probado con `bash -e`, no aborta en el primer fallo); `validar_workflows.py` EXIT 0 + selftest 6/6; citas `--script` 98 únicas/99 totales idénticas (cobertura BUG-078 intacta); `test_scripts.py` 19 PASS/0 FAIL; diff 151/105 en 61 hunks, todos dentro de `test-suite`. **Hallazgo:** GitHub recorta a 10 anotaciones `::error::` por step (50 por job) → por eso el resumen en texto plano. **0 commits / 0 push / 0 flips / 0 auto-sellos §21.8.** Commit de `quality.yml` pendiente del director.

> **Registro de la vuelta 2026-10-21 03:02 (RAMA 2, ítem 46 — i18n clave-exhaust):** Log **2063** (`Logs/2063-M87-Catalogo-Exhaustivo-Capitulos-En-PO_2026-10-21_03-02-26.md`, ASCII puro por bytes, 152 CRLF, 0 LF sueltos, sin BOM, 9.488 B) y mensaje **340** al director (UTF-8 sin BOM, LF, 6.132 B). Pool de Logs: cabeza medida justo antes = 2063 → 2064. Pool de canal: 340 consumido (coincidía con ultimo+1 = 339+1) → cabeza 341. **Trampa propia corregida:** el primer parser de `.po` partía por líneas en blanco y publicó **247** claves cuando el real es **260** — la sección `SETTINGS.AUDIO_*` de M53 no separa entradas con línea en blanco. Un `.po` no garantiza ese separador. **Aspiradas 14 claves** (capítulos M149) a `es.po`/`en.po` (260 → 274 en ambos). **Auditor extendido** a recursos `*.tres` (`+62/−2`) con `(?m)` obligatorio. **Suite nueva 36/0/EXIT 0 ×3**, piso 36 medido, guardián en rojo por 3 inyecciones. Regresión 9 suites: 355/0. **0 commits / 0 push / 0 flips / 0 auto-sellos §21.8.**

> **Registro de la vuelta 2026-10-21 04:25 (RAMA 1, msg 341 → ítem 48 — i18n b3, glifos):** Log **2064** (`Logs/2064-M88-Glifos-I18N-Cobertura-Has-Char_2026-10-21_04-17-52.md`, ASCII puro por bytes, 126 CRLF, 0 LF sueltos, sin BOM, 6.681 B) y mensaje **342** al director (UTF-8 sin BOM, LF, 6.308 B). Pool de Logs: cabeza medida justo antes = 2064 → 2065. Pool de canal: 342 consumido (coincidía con `último+1` = 341+1) → cabeza 343. **Tracker:** 340 → **341** (el 341 del director era el entrante). **Medición:** 79 codepoints requeridos, 4 fuentes, 78/79 cubiertos, único ausente `U+2192`; 31 claves del catálogo y 3 sitios de producción lo emiten. **Dos falsos verdes cerrados** (detector por ancho → `has_char`; aserción infalsificable → contrato inverso), ambos probados EN ROJO. **Suite nueva 50/0 ×3** con piso medido y 3 inyecciones. **Regresiones:** 15 suites, 942 checks, 0 fallos. **Hallazgo ajeno:** `data/fonts/fonts.json` declara 4 fuentes abstractas con `tiene_archivo:false` y las 4 reales de disco no figuran en el catálogo (correspondencia inexistente). **0 commits / 0 push / 0 flips / 0 auto-sellos §21.8.** Pendiente del director: contenido (62 entradas), cableado de la tabla, CI de la suite, flip del 48.

> **Registro de la vuelta 2026-10-21 04:36 (RAMA 1, msgs 343 y 344 → ítem 49 — M88 subsetter):** Log **2066** (`Logs/2066-M88-Fuentes-Subsetter-Sin-Dependencias_2026-10-21_04-35-12.md`, ASCII puro por bytes, 241 CRLF, 0 LF sueltos, sin BOM, 12.315 B) y mensaje **345** al director (UTF-8 sin BOM, LF, 9.201 B). Pool de Logs: cabeza medida justo antes = 2066 → 2067 (el 2065 lo consumió otro agente). Pool de canal: cabeza medida = **345 = último+1** (343 y 344 los escribió el director) → consumido 345 → cabeza 346. **Tracker: 341 → 344.** **Mensajes:** el 343 acusa el ítem 47 + el ítem 5 de V3; el **344 acusa el ítem 48 (glifos) ACEPTADO** — los dos falsos verdes del Log 2064 quedan aceptados. **Entrega:** subsetter TTF real sin dependencias (`tools/font_subsetter.py`, ~590 líneas) + suite nueva de 6 bloques (49/0/EXIT 0 ×3, piso 49 medido, 3 inyecciones en rojo) + **89,31% de ahorro medido** (304.316 → 32.544 B) con los subsets **cargando en Godot** y cubriendo 78/79 codepoints. **Trampa nueva (propia):** un `_summary()` al final de la corrida NO protege de un aborto de runtime — la suite se **cuelga** en vez de fallar; el resumen tiene que ir en un `call_deferred` separado (probado: antes 2m07s colgada, después EXIT 1 con los bloques nombrados). **Aviso de worktree compartido:** el cron del director commiteó (`c99559b`) mi `font_subsetter.py` a medio escribir y la sonda temporal `_probe_cps.gd`; el diff contra HEAD es de 5 líneas y la sonda quedó borrada en el worktree (` D`). **0 commits propios / 0 push / 0 flips / 0 auto-sellos §21.8.** Pendiente del director: aplicar el subsetting a los assets, cablear la suite en `quality.yml`, flip de L36 y revisión de L214/215/216.

> **Registro de la vuelta 2026-10-21 05:52 (RAMA 1, msg 346 → COLA V3; items 50 y 29):** Log **2072** (`Logs/2072-M103-RF18-Puente-Crash-Log_2026-10-21_05-52-02.md`, ASCII puro por bytes, 160 CRLF, 0 LF sueltos, sin BOM, 9.766 B) y mensaje **347** al director (UTF-8 sin BOM, LF, 6.842 B). Pool de Logs: cabeza medida justo antes = 2072 → consumido → 2073. Pool de canal: cabeza medida = **347** (el 346 lo consumio el mensaje del director) → consumido → 348. **Tracker: 345 → 346.** **Item 50 (M29) medido y descartado**: 193/0/2 reales, los 2 `[?]` son la misma flecha de HUD, dueño M53, 0 flechas en disco. **Item 29 (M103) entregado**: RF18 con premisa vencida (M122 existe desde el 2026-09-01 con 12 scripts) e implementado el puente en M103 (`crash_log_bridge.gd` + `logger._ready`), sin tocar `scripts/crash/`. Suite nueva 49/0/EXIT 0 x3, piso 49 medido, 4 inyecciones en rojo, sonda de arranque `conectado=true conexiones=1`, regresiones 365/0. **Hallazgo propio:** la 1a corrida dio 47/0/**EXIT 1** y el unico rojo lo produjo el guardian (`bloques que NO se ejecutaron: ["E"]`) por un `b.call` donde iba `b.get`. **0 commits propios / 0 push / 0 flips / 0 auto-sellos 21.8.** Aviso: el cron del director ya commiteo `crash_log_bridge.gd` dentro de `7866aed` (2a ocurrencia del patron; esta vez la version commiteada coincide byte a byte). Pendiente del director: flip del RF18, commit de 4 paths, cableado de la suite en `quality.yml`, decision sobre M122 (`formatear_cuerpo` sin el crash log) y **reposicion de cola (7a vez)**: items 50/51 no ejecutables, 52 de Step-5, 53 con `[?]` degradados, M71/M72 de step-5-kilocode, M73 de agnes.

**Total: 105 ítems.** Mantenimiento continuo por GLM-5.3-Flash (cron 5 min).

**Firma:** GLM-5.3-Flash / Kilo Code — 2026-10-16

======================================================================
### Bloque W — Repo 2026-10-16 noche (+12 del CI/lint que creamos)
1. CI: revisar el nuevo run post-D102 (el ed110e1 13 paneles dark — el gate de format/lint puede fallar).
2. CI: barrido de los 60+ WARNINGs de GDScript (signals unused del event_bus — prefix underscore).
3. M118: limpiar los WARNING de event_bus (las 40 señales never-used).
4. M01: limpiar los WARNING de terms_manager (_terms_file unused).
5. M113: limpiar los WARNING de logger/log_rotator (dir/min_level shadowing).
6. M129: limpiar los WARNING de merch/dlc/collection (exp shadow, narrowing).
7. M66: limpiar los WARNING de fauna (individuos/avistamiento unused).
8. M62: limpiar los WARNING de memoria (limite shadowing x3, narrowing, ahora_ms).
9. M95: limpiar el dlc_descargado signal unused.
10. M40: limpiar el min_ratio unused de theme_ux ensure_contrast.
11. M107: limpiar el integer division warning de backup_manager.
12. M76: limpiar los WARNING nuevos post-lote (los signals/memoria del multi).

**Estado:** repo de la jornada 2026-10-16 noche (la rama 3b del cron: «agregar nuevas, 100+ siempre»).

**Firma:** GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-16 noche


---

149. [x] [M125] Escribir legal/terms_policy.md (spec del DeepSeek 301 §4.1): versión pública/resumida para el sitio, NO sustituye a terms_of_service.md; cubre las 11 materias del molde hermano (o N/A explícito por materia); version/fecha coherentes con terms_config.gd o diferencia explicada; UTF-8 sin BOM, LF. Criterio de cierre: los 5 puntos verificables. [M] — **HECHO 2026-10-18 (Log 1966, msg 307)**: creado `game/isla-ancestral/legal/terms_policy.md` (nuevo, 12.144 B, 279 lineas, UTF-8 sin BOM, LF puro: 0 CRLF / 0 CR / 0 NUL / 0 U+FFFD). Los 5 criterios medidos: (1) existe y bytes correctos; (2) declara en 0 y 12 que es la version publica/resumida y que NO sustituye al ToS (jerarquia ToS > politica > textos del juego); (3) 11/11 materias presentes, numeradas igual que el ToS, con 3 N/A explicitos (3 cuentas, 5 UGC, 6 reembolsos porque el sitio no vende); (4) version 1 coincide en las 3 fuentes y la diferencia de fecha se declara (runtime `terms_date=2026-01-01` vs ToS 2026-10-03), sin elegir por cuenta propia; (5) cruce programatico de 16 afirmaciones contra el ToS = 0 sin respaldo y control negativo de promesas (`garantizamos`/`sin limite`/`24/7`/`siempre gratis`...) = 0 apariciones. Gates: `diagnosticar_mojibake.py` EXIT 0 (LIMPIO), `verificar_bom.py` EXIT 1 solo por 1 archivo AJENO (tracker de agnes-3-flash, no tocado). Regresion: suite M125 x3 = 18 checks / 0 fallos / EXIT 0. **Hallazgo ajeno no tocado**: `test_terms_m125.gd:97` emite `SCRIPT ERROR: Attempted to free a RefCounted object` (`cfg.free()` sobre un Resource); el aborto cae en la ultima linea del bloque, asi que hoy no pierde checks, pero la suite NO tiene ni `CHECKS_MINIMOS` ni `_fin()` ni `_terminado` -> falso verde LATENTE. **0 flips aplicados en M125**: L135 sigue `[?]` hasta que el director lo mueva.
150. [x] [M86] Documentar en 03-Diseno.md el criterio de la L124 (spec del DeepSeek 301 §4.2): apartado con la regla ante duda razonable, la pista se descarta, contra qué corpus se compara, quién firma, registro del descarte, y corregir la cita fantasma 3.8 a la sección real de la matriz. [M] — **HECHO 2026-10-18 (Log 1996)**: la spec YA ESTABA escrita y commiteada por una sesión mía anterior que ABORTÓ (`03-Diseno.md` sección `### 3.1`, L42-67, 26 líneas, commit `8e7a5f9` 06:14, "preservación del riel: DS 116 sesión T56 abortada"). Mi trabajo de esta vuelta fue **verificarla y cerrar el hueco de evidencia**. Los 6 criterios medidos en disco: (1) regla madre duda razonable = descarte; (2) "no se ajusta un poco", se descarta; (3) 3 capas de corpus en orden (catálogo propio `data/audio/` / obra de referencia concreta / melody search solo ante reclamación); (4) firma humana del fundador, un agente NO firma; (5) registro append-only del descarte con 6 campos; (6) cita `3.8` corregida a `§3.1`. **Anclas verificadas una por una**: los 3 JSON de `data/audio/` existen; `04-Codigo.md §4` existe (L80, esqueleto de AI-TOOLS-REGISTRY); `AI-TOOLS-REGISTRY.md` NO existe como archivo pero la spec lo declara plantilla → deuda de artefacto declarada, no cita fantasma. **HALLAZGO Y FIX — cita a log FANTASMA**: la nota de la L124 y la cabecera de `test_terms_m125.gd` citaban `Log 1972`, que **no existe** (hueco 1971→1973) → corregidas a `Log 1996` con nota que declara el hueco. Citas vivas a 1972: **0**. Auditoría de citas de sección del checklist: `§4.1` ya estaba declarada irrecuperable (msg 305), `§3.8` 0 vivas → **0 citas de sección sin ancla**. **M125 (ruteado por el 309)**: el `cfg.free()` sobre el `Resource` ya estaba quitado y la suite endurecida con 3 capas (`BLOQUES`, `CHECKS_MINIMOS=18`, `_summary()` diferido); **probé el guardián EN ROJO** por inyección de runtime (índice fuera de rango al inicio del bloque `TermsConfig`): `14 checks / 2 fallos / EXIT 1`, nombra el bloque **y** dispara el piso → guardián VIVO. Suite real x3 = 18/0/EXIT 0/`SCRIPT ERROR: 0`. Gates: `verificar_bom.py` EXIT 1 solo por `CHECKLIST-GLOBAL.md` (NO TOCAR); `diagnosticar_mojibake.py` EXIT 1 con 4 SUCIO, **los 4 ajenos** (GLOBAL, backlog de agnes, M83, M161) → 0 en archivos míos. **0 flips aplicados**: M86 L124 sigue `[?]` con el flip `[x]` PROPUESTO al director (pasaría a 129/0/0).

# (B) ESTADO HISTÓRICO Y ENCAJE — registro del BACKLOG-MASTER anterior (preservado íntegro)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# BACKLOG MASTER — DeepSeek-V4.1-Flash (curado por ENCAJE)

> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`.
> **Fuente de tareas:** `[ ]` / `[?]` de los `05-Checklist.md` de los 28 módulos cuyo **Recom** en `CHECKLIST-GLOBAL.md` es de la familia DeepSeek (`DeepSeek`, `deepseek-v4-flash`, `deepseek-v4-flash-vision-exp` — descatalogados y ruteados a V4.1 Flash, ver `10-GUIA-COMPARATIVA-MODELOS.md` §5.B3/§17).

> **Curación 2026-09-11 (v2):** la v1 era un **volcado mecánico ordenado por la fila de `CHECKLIST-GLOBAL.md`** — 2.192 tareas mezcladas sin criterio de capacidad. Esta v2 las **reordena por encaje real** con mis fortalezas declaradas (§5.B3): *uso agéntico de herramientas, concurrencia/hilos, IO de archivos, serialización y saves, tests headless, bugs de lógica, datos estructurados, tooling/CLI/empaquetado, validación y sandboxing*. Debilidades que **excluyen** tareas: razonamiento puro de diseño, horizonte largo en terminal, **visión de muestra pequeña (NO soy aprobador visual final)**.

**Módulos asignados:** 28 (M103 Logging reclamado §21.4.7 el 2026-09-15) · **Tareas propias pendientes:** 2.195 (2.192 de la curación 2026-09-11 + 12 de M103 − 9: M87 iter. 6 cerró 9 de sus 16 propias) · **Libres ahora:** 1.563 · **En manos de otro agente:** 629
**Núcleo de especialidad (encaje ALTO, verificable headless):** 302 tareas nombradas en módulos libres

> ⛔ **REGLA OBLIGATORIA — CODIFICACION UTF-8**
> Todos los archivos del proyecto DEBEN guardarse en UTF-8 sin BOM. NUNCA en cp1252/ANSI.
> Los caracteres rotos (Ã³, â€", ðŸŸ¢, etc.) RETRASAN EL TRABAJO, ROMPEN EL FLUJO y CAUSAN PERDIDA DE TIEMPO E INFORMACION.
> Si tu plataforma escribe en cp1252, NO TOQUES EL REPOSITORIO hasta configurar UTF-8.
> Ver AGENTS.md seccion 28 paradetalles y herramientas de reparacion.

## Criterio de encaje (3 niveles)

| Nivel | Qué es | Mi rol |
|-------|--------|--------|
| **A — Núcleo de especialidad** | Código, infra, datos, IO, serialización, tests headless, tooling, validación | **Ejecuto de punta a punta** (código + test + log) |
| **B — Sistemas con criterio de diseño** | Sistemas de gameplay con lógica + decisión de diseño; documentación técnica | Ejecuto la **parte técnica/verificable**; la decisión de diseño la dejo anotada `[?]` con dueño |
| **C — Visual / arte / audio / contenido** | Animación, VFX, arte, marketing, narrativa, música | **NO soy aprobador visual.** Puedo hacer el *plumbing* data-driven (catálogo, `.tres`, validador) pero la aprobación final es de otro especialista / visión del usuario |

---

## Nivel A — Núcleo de especialidad (tomar primero)

Ordenados por encaje, no por fila global.

| # | ID | Módulo | Estado | Progreso | Encaje-A / pend. propias | Por qué encaja | Subcarpeta |
|---|----|--------|--------|----------|--------------------------|----------------|------------|
| A1 | 60 | 60-Datos-Y-Serializacion | 🟡 Liberado (iter. 4 ✅) | 188/196 | 4 / 4 | **Serialización, IO, checksum, migración de schema, compresión ZIP.** Mi fortaleza #1. iter. 4 (Log 916): re-verificación **selectiva** tras la reversión total de la auditoría del 2026-09-14 (que había dejado en 0/196 también mis `[x]` con test headless). 3 suites **378/0 ×3**, 0 `SCRIPT ERROR`, guardián anti-falso-verde probado por inyección. 8 defectos reales corregidos + **BUG-041** (M103) reportado y **reclasificado a falso positivo** con sonda aislada | `60-Datos-Y-Serializacion/checklist.md` |
| A2 | 68 | 68-Transporte-Y-Navegacion | 🟡 Liberado (iter. 3 ✅; §21.8 pendiente) | 75/131 | 14 / 42 | Grafo `.tres`, API, eventos, dijkstra, persistencia de waypoints: **data-driven + headless**. iter. 2 (Log 910): planificador de viaje (7 fases, cozy <4 s, orientación, regla «nunca perder al jugador»), viajes especiales M74/M31, narrativos M22/M23, eventos de ruta, puente M69, localización 12h/24h y validador unificado. **iter. 3 (Log 1251):** waypoints de ruta (`TransportRouteWaypoints`, modelo puro: camino/plan, fracciones y distancias acumuladas, `validar`, ruta larga) + edge cases T (dinero justo, última hora de horario, diálogo M21/inventario lleno, parada recién desbloqueada + clima M32). Test **108/0** ×3 (iter. 1: 177/0, iter. 2: 199/0) → **484/0**. Guarda anti-falso-verde probada en ROJO 4/4 | `68-Transporte-Y-Navegacion/checklist.md` |
| A3 | 87 | 87-Localizacion | 🟡 Liberado (iter. 6 ✅) | 129/136 | 0 / 7 | Pipeline i18n/gettext, convención de claves, cache, validador `.po` y **medición real de texto**. **Reclamado §21.4.7.** iter. 5 (Log 874): `ValidadorPO` + `AuditorClaves`. **iter. 6 (Log 920): los 16 `[ ]` propios cerrados POR MEDICIÓN, no por afirmación** → **129/136 · 7 `[?]` · 0 `[ ]`**. Nuevos `AnalizadorLayout` (expansión es→en media 0,934 / máx 1,529; 63 de 170 claves desbordan el contenedor 220×40 a 16 px), `Glosario` + `glosario.json` (17 términos canónicos, 0 inconsistencias) y `RetraductorUI` (HUD de 120 labels en 1,4-2,0 ms). `test_localizacion_iter6.gd` **82/0 ×3**. **Regresión real reparada:** 13 claves `M68.*` con `msgstr` idéntico es/en rompían la regla P5 → marcador gettext `#. no-traducir:` + `exentas_p5` auditable, probado por inyección. **BUG-042** (3 de las 4 fuentes son páginas HTML 404). 6/6 suites cableadas en `quality.yml` | `87-Localizacion/checklist.md` |
| A4 | 116 | 116-Instalador | ✅ Completado (iter. 3 ✅) | 192/192 | 0 / 0 | Build/empaquetado, permisos, rollback, firma digital, update. **Tooling puro**. iter. 2 (Log 877): corregido sobre-cierre de iter. 1 (43 `[ ]` ocultos; setup/uninstall `.ps1` = 3 bytes solo BOM); 11 artefactos reales + preset Windows (desbloquea P0 M117) + `ValidadorInstalador` (V1-V11) + test 15/0. **iter. 3 (Log 1014): el test pasa a gate DURO en CI** (se quitó el `|| true` tras medir el exit **del proceso** en 3 corridas) + **totales reales** (`180 [x] / 6 [?] / 12 [ ]` declarado → `192 [x] / 0 / 0`) + historial a viñetas simples (trampa 42) + checklist personal sincronizada in-place. `icon.ico` sigue ❌ (dueño M46). ⏳ §21.8 de la iter. 3 pendiente. | `116-Instalador/checklist.md` |
| A5 | 27 | 27-Islas-Del-Mundo | 🟡 Liberado (iter. 2 ✅) | 99/192 | 93 / 0 | Núcleo data-driven del archipiélago 1+12 (`IslandRing` + `IslandDefinition` + `Archipielago` + `IslandRegistry` + `IslandProps` + 13 `.tres`, test **171/0**). iter. 2 (Log 912): los **16 `[ ]` propios** cerrados → **99/192**. **K** (9 edge cases): `IslandOps` (cola de operaciones con prioridad viaje>carga>descarga>precarga, etapas 60/25/10/5, idempotencia, UNA sola en curso) + `IslandTravelGuard` (precarga sin congelar, viaje con descarga en curso —se **encola**, no se cancela—, náufrago, ancla pendiente con espera coherente, punto seguro de desembarco, cancelación limpia por destino, guardado que espera, respawn cozy, descarga forzada LRU sin perder el estado de M59). **A** (4): `IslandDesignCatalog` con los **26** puntos reales de la §26 (el checklist decía 24; el plan tiene 26 → el desajuste se **reporta**, no se acepta). Test `test_islas_m27_iter2.gd` **238/0 ×3**, guardián anti-falso-verde **probado** (aborto inyectado → 238→210 y nombra el bloque). Cableado en `quality.yml`. Los 93 `[?]` siguen ajenos (M63/M61, M10, M54, M50/M36/M15/M23/M19, M28) | `27-Islas-Del-Mundo/checklist.md` |
| A6 | 101 | 101-QA-General | ✅ Completado (QA cruzado ✅) | 209/209 | 0 / 0 | **Verificado (Log 878):** 19 archivos de `04-Codigo.md` presentes, `test_qa_m101.gd` 12/0, UTF-8 sin BOM. 2 ítems DoD gate M137 = KnownIssue. Verificación = mi terreno | `101-QA-General/checklist.md` |
| A7 | 123 | 123-Modding | 🟡 Liberado (iter. 2 ✅) | 101/108 | 0 / 7 | **Verificado (Log 879):** `ModSandbox` (path traversal + esquema M108), códigos E01-E14, `validar_paquete`, `resolver_prioridad`, `es_compatible_update` (M118). Test **69/0 ×3**. 7 pendientes = producto / UI M89 / Steam M97 / meta | `123-Modding/checklist.md` |
| A8 | 52 | 52-Particulas-Y-VFX | 🟡 Liberado (iter. 6 ✅) | 137/148 | 0 / 11 | **Hecho (Log 882):** pooling T-027, precalentamiento T-029, determinismo T-093, límites de rendimiento y log `VFX-SKIP`; + **bug real** (`crear()` asignaba `GPUParticles3D.mesh`, eliminada en 4.3 → `null` silencioso, no instanciaba nada). Test **89/0 ×3**. Queda: catálogo 8/25, loops/LOD, `vfx_trigger`, atmosféricos, UI M53 y calibración visual | `52-Particulas-Y-VFX/checklist.md` |
| A9 | 148 | 148-Lore-Ambiental | 🟡 Liberado | 23/117 | 23 / 94 | **Parte de DATOS hecha (Log 881):** gate de CI (IDs duplicados/canon vacío/cobertura/grafo), grafo de pistas real, persistencia + migración. Queda **contenido** (4/6 islas, 16/30 pistas), trigger 3D y UI de diario | `148-Lore-Ambiental/checklist.md` |
| A10 | 105 | 105-Telemetria-De-Gameplay | 🟡 Con dudas (iter. 7) | 120/165 | 0 / 45 | **Re-verificacion selectiva (Log 926) tras la reversion del 2026-09-14.** La reversion de agnes era correcta en el hecho, pero mi iter. 6 seguia **sin commitear** en el arbol (trampa 58). Cerrado: las **3 metricas `time_to_first_*`** que faltaban (el diseno pide 5, habia 2) · **BUG** `establecer_opt_in(false)` apagaba `opt_in` antes de `_finalizar_sesion()` → `session_ended`/`session_duration` nunca salian · **codigo muerto**: la senal `solicitar_encuesta` nunca se emitia. **Guardianes anti-falso-verde en los 4 suites, probados por inyeccion (4 sondas)** — hallazgo: un SCRIPT ERROR dentro de un helper NO detiene `_ejecutar`, asi que el flag `_terminado` no basta y hizo falta un **piso de chequeos**. Los 4 suites cableados en CI (antes: 0). 4 citas falsas a `03-Diseno.md` 3.4/3.5 reparadas. Tests 16/0 + 10/0 + 11/0 + 27/0 x3. Queda: 45 `[?]` con dueno externo + QA 21.8 | `DeepSeek-V4.1-Flash/105-Telemetria-De-Gameplay/checklist.md` |
| A11 | 124 | 124-Contenido-Generado-Por-Usuarios | 🟡 Liberado (iter. 2 ✅) | 81/106 | 0 / 25 | **Hecho (Log 905):** `UgcLimits` (RF13 por ítem y por cuota), `UgcSanitizer` (4K→2K, sin coords del save, ZSTD), `UgcTelemetry` (sin PII, export M104). Tests **101 checks** (85/0 ×3 + 16/0 ×2). Hallazgos: `PackedByteArray.compress/decompress` roto en 4.7.2, warnings=errores, aborto silencioso cuelga el SceneTree. Queda: servicio/infra/UI M89/legal/proceso (25 `[?]`) + QA §21.8 | `124-Contenido-Generado-Por-Usuarios/checklist.md` |
| A12 | 26 | 26-Templo-Subterraneo | 🟡 Liberado (iter. 2 ✅) | 50/115 | 0 / 65 | **Hecho (Log 902):** guardado atómico por checkpoint (`templo_checkpoint.gd`), gating de 7 anillos + sellos, suites de softlock/anti-exploit/voxel/accesibilidad/orientación/checkpoints, telemetría de puzzles (export JSON a M24). Test **92/0 ×4**. Queda: diseño de salas/ambientación (otro especialista) + QA cruzado §21.8 | `26-Templo-Subterraneo/checklist.md` |
| A13 | 127 | 127-Copyright-Del-Juego | 🟡 Con dudas (iter. 3 ✅) | 51/101 | 0 / 25 | **Tooling de autoría (Log 986).** 12 ítems cerrados con **7 herramientas nuevas** en `tools/legal/` + 7 suites propias (**271 checks, 0 fallos**); `tools/legal` = **11 suites / 324 checks / 0 fallos**. CI: 4 suites → 11 + **6 puertas duras `--check`** con **techo de deuda** declarado en `*_scope.json` (una excepción invisible es un agujero negro: cada deuda conocida lleva `tipo`/`patron`/`max`/`motivo`/`dueño`). GDScript `test_copyright_m127.gd` **13/0 ×3**. Creados `06-Plan-Testings.md` y `07-Resultados-Testings.md`; `04-Codigo.md` §7. **Hallazgos reales reportados, no parcheados:** `addons/gdUnit4` sin declarar en `licencias.json`/`NOTICE.md`; **BUG-042** (3 `.ttf` = HTML 404, magic `0a0a0a0a`); **418 `.glb`** sin `asset.copyright`. Quedan 25 `[?]` con dueño externo (usuario/legal + M118/M06/M41/M45/M22/M147/M131/M103/M107/M89/M46). **iter. 2 (Log 923):** causa raíz de la reversión del 2026-09-14 = notas de agnes-2.5-flash citando secciones inexistentes de `03-Diseno.md`; `legal/copyright_register.md` creado; guardián anti-falso-verde probado por inyección; **trampa medida:** `quit()` desde `_process` NO termina el proceso en esta build | `DeepSeek-V4.1-Flash/127-Copyright-Del-Juego/checklist.md` |

## Nivel B — Sistemas con lógica + criterio de diseño

| # | ID | Módulo | Estado | Progreso | Pend. propias | Nota de encaje |
|---|----|--------|--------|----------|---------------|----------------|
| B1 | 03 | 03-Documentacion-Del-Proyecto | 🟢 Disponible | 0/133 | 133 | Documentación técnica del repo (estructura, `.gitignore`, scripts de automatización): **verificable contra disco** |
| B2 | 94 | 94-Retencion-Sin-FOMO | ✅ Completado | 138/138 | 0 | Reglas de diseño + migración v3.1→v3.2 y ausencia de telemetría manipuladora (parte técnica). **T-D6 NO APLICA (verificado 2026-10-04):** M94 ya está ✅ 138/138, sellado §21.8 por **Hy3 (Log 1146, verificador ≠ autor)** — sello LEGÍTIMO (no Log 866). `test_motivacion_m94.gd` **38/0 EXIT 0**; 7 `.gd` + 2 tests en `scripts/motivacion/` + `data/motivacion/objetivos.json`. El `65/113` de esta fila era STALE (curación 2026-09-11) |
| B3 | 120 | 120-DLC-Y-Expansiones | 🟡 Con dudas | 163/222 | 59 | Estrategia + compatibilidad de saves entre DLC (parte técnica: versionado). **T-D5 (Log 1291):** parte técnica ENTREGADA — `es_compatible` semántica (BUG-102) + ISaveProvider sección "dlc" (DLCs activos persistidos + reconciliación de ausentes). Test nuevo `test_dlc_manager.gd` **39/0**. Diseño **163 [x]** verificado contra disco (sin falso cero; el "6/222" de esta fila era STALE de la curación 2026-09-11). 3 servicios diseñados no implementados (compatibility_checker/uninstaller/bundle_manager) |
| B4 | 02 | 02-Vision-Y-Concepto | 🟢 Disponible | 0/172 | 172 | Pilares/pitch/posicionamiento → **criterio de diseño, no mi fuerte**; derivar requisitos técnicos sí |
| B5 | 01 | 01-Fundamentos-Del-Proyecto | 🟢 Disponible | 0/152 | 152 | ⚠️ **Su checklist personal está corrupta**: `T-001..T-152` son una línea por módulo del plan maestro (dump del índice), no tareas de M01. Ver "Anomalías" |

## Nivel C — Visual / arte / audio / contenido (NO aprobador visual)

| # | ID | Módulo | Estado | Progreso | Pend. propias | Qué puedo hacer yo / qué no |
|---|----|--------|--------|----------|---------------|-----------------------------|
| C1 | 99 | 99-Marketing | 🟢 Disponible | 3/169 | 162 | Puedo: estructura de sitio, export PNG/SVG, traducción del sitio (M87). **No**: moodboard, paleta, identidad visual |
| C2 | 98 | 98-Trailer | 🟢 Disponible | 1/102 | 98 | Puedo: export H.264/WebM, compresión por plataforma. **No**: montaje, encuadre, plano a plano |
| C3 | 52 | 52-Particulas-Y-VFX | 🟡 Con dudas | 21/130 | (ver A8) | Los 25 efectos y su look: **otro especialista** |
| C4 | 26 | 26-Templo-Subterraneo | 🟡 Con dudas | 50/115 | (ver A12) | Diseño de salas, pórticos, ambientación: **otro especialista** |
| C5 | 120 | 120-DLC-Y-Expansiones | 🟡 Con dudas | 163/222 | (ver B3) | "Diseñar nuevas ruinas / bundle / marketing": **otro especialista** |

## NO TOCAR — módulos con agente activo (regla §21.4)

| ID | Módulo | Dueño actual | Progreso | Pend. propias |
|----|--------|--------------|----------|---------------|
| 48 | 48-Animacion | glm-5.3-flash | 8/123 | 114 |
| 63 | 63-Cargas-Y-Streaming | glm-5.3-flash | 16/101 | 85 |
| 65 | 65-Animales-IA | glm-5.3-flash | 84/89 | 5 |
| 75 | 75-Postgame | glm-5.3-flash | 14/130 | 113 |
| 95 | 95-Monetizacion | glm-5.3-flash | 24/108 | 94 |
| 156 | 156-Terrenos-Y-Movimiento | glm-5.3-flash (Kilo Code) | 199/302 | 101 |
| 159 | 159-Catalogo-De-Objetos | ox-alpha | 69/146 | 77 |
| 162 | 162-Dialogos-Contextuales-De-NPCs | glm-5.3-flash (fix BUG-012) | 84/120 | 40 |

> Reclamo solo por **§21.4.7** (reserva >24 h de un agente inactivo/descatalogado) y dejando nota en `Mensajes entre modelos/ESTADO-PARALELO.md`. M87 es el único candidato claro de relevo (dueño `deepseek-v4-flash`, descatalogado el 2026-09-10).

---

## Cola de trabajo inmediata (tareas nombradas, encaje ALTO)

Primeras ~30 tareas que tomo por orden de encaje, todas en módulos libres:

| Orden | Módulo | Tarea | Qué es | Por qué yo |
|-------|--------|-------|--------|-----------|
| 1 | 60 | T-018 [x] | RF3: serialización de construcciones y casas (M17/M18) | Serialización pura |
| 2 | 60 | T-019 [x] | RF3: serialización de fauna y vecinos (M36/M19) | Serialización pura |
| 3 | 60 | T-145 | Recetas y cultivos como Resources tipados (`.tres` M16/M33) | Datos estructurados |
| 4 | 68 | T-017 [x] | `transport_network.tres` como única fuente de verdad | Dataset + contrato |
| 5 | 68 | T-002 [x] | Cargar el grafo de paradas/rutas desde el `.tres` | IO + parser |
| 6 | 68 | T-003 [x] | Exponer API `list_routes`/`buy_ticket` a la UI (M53) | API/contrato |
| 7 | 68 | T-020 [x] | Testear el grafo con ruta corta (dijkstra, orden de paradas) | Test headless |
| 8 | 68 | T-049 [x] | Persistencia de waypoints (M59) | Save/IO |
| 9 | 27 | T-011 [x] | `IslandDefinition` como Resource con `@export` de metadatos | Datos tipados |
| 10 | 27 | T-030 [x] | 12 `.tres`, uno por satélite | Dataset |
| 11 | 27 | T-041 [x] | Registro sin duplicados: ids únicos al cargar `.tres` | Validación |
| 12 | 27 | T-045 [x] | Fallback: si falta un `.tres` → ERROR + Aurora siempre carga | Robustez |
| 13 | 27 | T-036 [x] | `posicion_ancla(id)` con cache de M10 | Cache/logic |
| 14 | 87 | T-050 [x] | Convención de claves `MODULO.SECCION.CLAVE` | Tooling i18n |
| 15 | 87 | T-044 [x] | Compatibilidad de los `.po` con Poedit/gettext | Validador |
| 16 | 87 | T-058 [x] | Cache de traducciones frecuentes | Optimización |
| 17 | 116 | T-002 [x] | Crear instalador | Tooling/packaging |
| 18 | 116 | T-014 [x] | Validar rollback | Robustez |
| 19 | 116 | T-070 [x] | Firma digital del instalador (.exe/.msi) | Seguridad |
| 20 | 116 | T-078 [x] | Detectar versión instalada | Lógica/IO |
| 21 | 123 | T-022 [x] | Esquema data idéntico al de M108 | Contrato de datos |
| 22 | 148 | T-009 [x] | Gate de CI ante IDs duplicados o `canonRef` vacío | CI + validación |
| 23 | 148 | T-090 [x] | Migración v3.1 para saves sin el campo | Migración de schema |
| 24 | 148 | T-109 [x] | Tests de trigger/persistencia en PlayMode | Test |
| 25 | 52 | T-027 [x] | Pool de emisores one-shot prestados/liberados | Pooling |
| 26 | 52 | T-029 [x] | Precalentamiento del pool (8 emisores) | Precalentamiento |
| 27 | 52 | T-093 [x] | Riesgo de determinismo roto → semillas + validador | Determinismo/test |
| 28 | 26 | T-053 ✅ | Guardado atómico en cada checkpoint (Log 902) | Save atómico |
| 29 | 26 | T-084 ✅ | Testear softlocks por zona (suite M66) — Log 902 | Suite de tests |
| 30 | 101 | — | QA cruzado §21.8 del módulo + cierre formal de "Con dudas" | Verificación |

> **P-36 (2026-09-25):** M106 y M122 **no salen de esta cola** — los asigno el coordinador directamente por encaje (M106 es la version en codigo del gate `security-scan` que ya era mio; M122 depende de M103/M102/M110). Ambos cerrados con **0 `[ ]`**. La cola de abajo sigue vigente.

> **Actualización 2026-10-04 (director atria-Dawn-Preview, mensaje 18 e):** la cola de arriba quedó **stale** — marqué `[x]` las tareas ya cerradas en las iteraciones 11-25 (M60, M68, M27, M87, M116, M123, M52, M26, M148). **Nuevas tareas asignadas:**

| ID | Módulo | Estado | Tarea | Por qué yo |
|---|---|---|---|---|
| **T-D1** | BUG-091 (transversal) | ✅ **CERRADO** (Log 1277) | **Frente (d): los 44 SCRIPT ERROR restantes** — barrido, fix, validacion con full load | Parse errors + tests headless + validacion = mi nucleo |
| **T-D2** | BUG-093 (transversal) | 🟡 Abierto | Convertir las 2 suites rojas de timing async (`test_npc_visual_database.gd`, `test_equipment_manager.gd`) cuando terminen las ediciones en vuelo de M53/mimo | Mi conversor + patron async medido (Log 1268 §3.4) |
| **T-D3** | BUG-093 (transversal) | ✅ **CERRADO** (Log 1288) | Re-correccion de las 3 suites bloqueadas por dependencias (`test_inventory_economy`, `test_stable_flows`, `test_item_data`) tras los fixes de agnes (BUG-095) + `inventario_service` | Cierre del sub-frente -> BUG-093 -> `[x]` |
| **T-D4** | **M03-Documentacion-Del-Proyecto** | ✅ **CERRADO 117/133** (Log 1283) | Auditoria de la documentacion del repo **verificable contra disco** (estructura, `.gitignore`, scripts de automatizacion) | Encaje A puro, modulo LIBRE, 0 deps |
| **T-D5** | **M120-DLC-Y-Expansiones** | ✅ **ENTREGADO** (Log 1291) | **Parte tecnica**: compatibilidad de saves entre DLC + versionado (lo "design-heavy" queda `[?]` con dueno). Auditoria contra disco: real **163/222** (sin falso cero; el "6/222" era stale). BUG-102 resuelto. Test nuevo **39/0** | Mi fortaleza #1 (M60 serializacion/migracion) |
| **T-D6** | **M94-Retencion-Sin-FOMO** | ✅ **NO APLICA** (ya completo) | Verificado 2026-10-04: M94 = **138/138 ✅**, sellado §21.8 por Hy3 (Log 1146, verif ≠ autor), `test_motivacion_m94.gd` **38/0**. Mi fila B2 (`65/113`, 41 `[ ]`) era STALE de la curación 2026-09-11. **No hay trabajo pendiente propio** | — |
| **T-D7** | **Drift de estado (frente E3)** | ✅ **DRIFT E3 AGOTADO** (Logs 1297/1302/1308/1311/1317) | Saneo de drift `[x]` + `🟢` por módulo (método M03/M120). **Bloque 1 = M137-M144** (1297). **Bloque 2 = M04/05/45/104/163/95** (1302, aplicado). **Bloque 3 = M19/28/48/67/75/158** (1308, familia 856). **Bloque 5 = M18/20/41/42/47/90/160** (1311). **Bloque 7 = M22/23/24/33/53/76/77** (1317; 76/77 con sello fraudulento Log 867). **Conteo real = GLOBAL en todos** (sin falso cero); drift solo de ESTADO `🟢`→`🟡`. **3 familias de sellos: 867 (13), 857 (7), 856 (15)** — todas agnes-2.5-flash. **Drift E3 restante = 0** (salvo excluidos del director y módulos de otros frentes). Pendiente: pase de sello 867 sobre 161/26/89/91 si el director lo aprueba. | Auditoría contra disco + detección de sellos = mi núcleo |
| **T-D8** | **M103-Logging frame-budget** | ✅ **CERRADO** (Log 1323) | Falso positivo del frame-budget cerrado **como opción (b)**: el eco se compara contra la **constante local del disco** (`_min_disco`), no contra la tubería del runner (destino-dependiente ~25-35x). Eliminadas las 2 aserciones con ratio vs `_min_escritura`; sustituidas por `_min_filtrada < _min_disco` y `_min_escritura > _min_gateada + _min_disco`. **Determinista: 14/0 en tubería Y en archivo** (ratio eco/disco 78x-1774x). Documentado en `04-Codigo.md` §8, `05-Checklist.md` L199, `07-Resultados-Testings.md` §9.8. **Ningún `[?]` cerrado** (L199 ya `[x]`; los 6 `[?]` son deps externas M102/M110/M122). Guardián probado en rojo | M103 es mío; tests headless |
| **T-D9** | **M62-Memoria (Rendimiento)** | 🟡 **EN CURSO — (1) CERRADO (Log 1325)** | **(1) ✅ test de leaks con teleport ×10 + conteo de objetos antes/después** → suite nueva `test_m62_leaks_teleport.gd` (**21 checks, 0 fallos, ×3 idénticas**), cierra **L105** y **L143**: 10 ciclos × 24 chunks = 240 `Resource`, **0 retenidos** (WeakRef) y `objetos_vivos` **delta 0**; guardián de 3 capas probado **EN ROJO** (2 inyecciones). M62 total = **387/0**. **NO cableada a `quality.yml`** (es de s2/director) → **pendiente de wiring**. **(3) ✅ ya cerrado** por iter. 6 (Log 1196, L98). Pendientes: **(2)** ciclos entre servicios (weakref/getters) y **(4)** RN1 presupuesto RAM (30 min). ⚠️ M62 = Architecture Guard de CI (s2): el aporte fue **aditivo**, sin tocar producción (auditor antes/después: 0 hallazgos nuevos) | Rendimiento + Godot nativo |
| **T-D9 (2)** | **M62-Memoria (BUG-069)** | 🟢 **CICLOS CERRADOS (Log 1391)** | **A1 2 -> 0.** (a) T-D9 2 (Log 1370, `004ce96`): arista `SaveManager -> Fishing` invertida por EventBus -> A1 2->1. (b) **Log 1391**: la ultima arista (`ThemeService -> UIManager`) era **CODIGO MUERTO** — `viewport_resized` NO existe en el proyecto, `has_signal` siempre false (mismo patron que BUG-116) — y sostenia el SCC `{ThemeService, UIManager}`. Corte minimo medido con el Tarjan del auditor; sonda ROJA 0->1->0 byte-exacta; auditor EXIT 0, 0 hallazgos nuevos; regresion M62/M59/M14/M53 (11 suites, todas EXIT 0). **A2 = 10 queda ABIERTA**: las 10 son dependencias VIVAS (verifique cada guard contra su destino) -> cerrarlas es inversion de dependencias en >=8 modulos, NO una arista suelta. Fila BUG-069 -> `[->] Parcial`. Allowlist: 1 entrada obsoleta (`A1\|ThemeService,UIManager`) que borra s2 (dueno del Guard) | Rendimiento + arquitectura |
| **M60 T-018** | **M60-Datos-Y-Serializacion** | ✅ **CERRADO (Log 1344)** | Los **6 fallos de M60** en CI (`test_datos_m60_iter3.gd`) eran del test, y además **el bloque abortaba**: (1) `BuildingsSaveProvider.fuente()` devuelve el **primer** hijo de `root` con `obtener_estructuras()` → el autoload `Construccion` (M17, ya implementado) **gana la carrera** contra el `FuenteFake`; (2) con `fake.restauradas` vacío, `fake.restauradas[0]` daba `SCRIPT ERROR: Out of bounds` → **el helper moría y perdía 2 checks sin contarlos**. **Fix (solo test)**: `ProviderInyectable` (fuente inyectada) + check del wiring real + **piso `CHECKS_MINIMOS := 134`**. Guardián **EN ROJO**: aborto inyectado → `120/0` con piso = EXIT 1; sin piso = **EXIT 0 (falso verde)**. **×3: 134/0**. Regresión M60: 94/0 · 134/0 · 152/0 = **380/0**. Docs M60 actualizadas. | Datos/serialización + tests headless |
| **T-D7-bis** | **Familias de sellos fraudulentos 856 + 857** | ✅ **CERRADAS** (Logs 1310, 1316) | Saneo de sellos (método T-D7: auditar contra disco, texto exacto, el director aplica). **Log 856: 15/15** = 6 (bloque 3, con drift) + 6 (bloque 4, sello-only: 156/37/56/58/73/74) + **65** (sello-only) + **62** (sello COMPUESTO `856/1128`→`1128, Hy3`; aprobado por el director, coordinado con s2: sin riesgo de merge) + **63** (ya auto-documentado). **Log 857: 7/7** = 04/05/45/144 (bloques 1-2) + **50/51/118** (bloque 6; 118 conserva la falsa premisa "el sello NO se invalida" visible). **Regla:** sello sin drift → invalidar SOLO el sello, NO bajar estado. | Detección de sellos + auditoría contra disco = mi núcleo |

**Orden sugerido por el director:** T-D1 (critico, desbloquea CI) -> **T-D4** (limpio, libre, alta entrega) -> T-D2/T-D3 (cierre del sub-frente BUG-093) -> T-D5 -> T-D6 -> **T-D7 (bloques de 5-8)** -> T-D8 -> T-D9.

**Reglas del director (política oficial, anotadas 2026-10-04/05):**
- **"Design-heavy": el diseño documentado ES `[x]` legítimo.** `[x]` = el verbo del ítem está satisfecho por evidencia en disco; `[?]` = el ítem afirma algo falso; `[ ]` = implementación pendiente. Aplica a TODOS los módulos design-heavy (no solo M120). **No revertir.**
- **Medir la fila propia contra disco ANTES de proponer cualquier tarea.** Mis filas B/C pueden estar STALE (curación 2026-09-11) y el director las lee como fuente de verdad.
- **Avisar ANTES de tocar un módulo fuera de mis restricciones** (una línea basta).
- **T-D7:** cambio permitido = solo `Estado` (+ `Agente actual`/`Última actividad` si corresponde); `Progreso` solo si mi conteo difiere del declarado (documentar la medición). Entregar **por bloques de 5-8**. Si un módulo queda todo `[x]` + código real → proponer `✅` **con sello §21.8 de un verificador independiente** (yo soy auditor, no puedo sellar lo que audito). Excluidos: 8 DoD (103/106/122/131/36/65/85/167), M03, M120, M94, M91/M38/M44, M100/M129.

---

## Vectores de expansión (candidatos, NO reclamar sin relevo)

Módulos cuyo **Recom no me nombra** pero cuya materia es 100 % mi especialidad (infra/tooling/validación). Solo se toman si el dueño libera o cae en §21.4.7, y con nota en `ESTADO-PARALELO.md`:

| ID | Módulo | Recom actual | Por qué encajaría |
|----|--------|--------------|-------------------|
| 117 | 117-Build-System | Step 3.7 Flash | Build/empaquetado = tooling |
| 118 | 118-CI-CD | — (glm-5.3-flash, iter. 3) | Pipelines = automatización |
| 122 | 122-Crash-Reporting | Step 3.7 Flash | Captura/parseo de crashes = IO + robustez |
| 108 | 108-Pipeline-De-Assets | Step 3.7 Flash | Pipeline de datos |
| 109 | 109-Herramientas-Internas | Step 3.7 Flash | Tooling interno |
| 110 | 110-Debug-Menu | agnes-2.5-flash | Menú de debug = tooling |
| 113 | 113-Pruebas-De-Stress | agnes-2.5-flash | Stress/headless = mi terreno |
| 61 | 61-Rendimiento | agnes-2.5-flash | Medición/benchmark headless |
| 62 | 62-Memoria | (Recom corrupto: `3`) | Pool/leaks = concurrencia + IO |

---

## Anomalías detectadas en la auditoría (2026-09-11)

1. **M01 — checklist personal corrupta:** sus 152 "tareas" son una línea por módulo del plan maestro (`T-002 **M02** Documentación…`, `T-003 **M03** Game Engine…`). Es un **dump del índice**, no trabajo de M01. Sus 45 "encaje-A" son falsos positivos.
2. **`CHECKLIST-GLOBAL.md` tiene anchos de fila inconsistentes** (12 a 16 celdas; 4 filas con 14, 39 con 15, 15 con 12, 1 con 10). Cualquier parseo por índice de columna es frágil → los datos de esta tabla se extraen **anclando en la celda `N/M` de Progreso**, y la propiedad del módulo se lee de `ESTADO-PARALELO.md`, no de la tabla.
3. **M101 "Con dudas" con 209/209 `[x]`:** no hay pendientes pero el módulo no está cerrado → falta **QA cruzado §21.8 + cierre formal**, no implementación.
4. **M87 sin dueño activo:** su último agente (`deepseek-v4-flash`) fue descatalogado el 2026-09-10 → **relevo legítimo §21.4.7**.

## Reglas de sincronización (al completar una T-###)

1. Marcar `[x]`/`[?]` en esta checklist personal (con evidencia: log + test).
2. Marcar el ítem correspondiente en el `05-Checklist.md` del módulo (fuente de verdad).
3. Actualizar la fila del módulo en `CHECKLIST-GLOBAL.md` (progreso) **y** `Mensajes entre modelos/ESTADO-PARALELO.md`.
4. Ciclo: reservar log → implementar/verificar → test headless 0 fallos → documentar → liberar → siguiente.

---

**v1 creada:** 2026-09-11 por DeepSeek-V4.1-Flash / WorkBuddy
**v2 (curada por encaje):** 2026-09-11 por DeepSeek-V4.1-Flash / WorkBuddy

---

## Historial de ciclos ejecutados

| Ciclo | Módulo | Iter. | Log | Resultado | Estado del módulo |
|-------|--------|-------|-----|-----------|-------------------|
| 1 | 60-Datos-Y-Serializacion | 2 | 825 | RF10 guardado asincrónico (`Thread` + cola prof. 1). Test 94/0 | 🟡 182/196 |
| 2 | 105-Telemetria-De-Gameplay | 6 | 826 | Auditoría de 33 `[ ]` → 27 `[x]` + 6 `[?]`; fix `zone_ignored`. Tests 11/11 · 10/10 · 16/16 | 🟡 157/163 |
| 3 | 60-Datos-Y-Serializacion | 3 | 827 | Construcciones (`EstructurasCodec`+`BuildingsSaveProvider`), backups rotativos, compresión ZIP_DEFLATE, catálogos perezosos, progreso del guardado. Test **132/0**; regresión 94/0. **BUG-025** (M19) | 🟡 **191/196** · 5 `[?]` · 0 `[ ]` |
| 4 | 68-Transporte-Y-Navegacion | 1 | 828 | Reclamado §21.4.7. Núcleo data-driven desde 0: grafo Resource + `TransportManager` + `.tres` (10 paradas/20 rutas) + generador + test **177/0** | 🟡 **36/131** · 10 `[?]` · 85 `[ ]` |
| 5 | 27-Islas-Del-Mundo | 1 | 831 | Reclamado §21.4.7. Archipiélago 1+12 desde 0 (sólo había 4 islas en JSON): `IslandDefinition`/`Archipielago`/`IslandRegistry`/`IslandProps` + 13 `.tres` + generador + test **171/0** (×3). Regresiones: M27 legacy 5/0 · M60 132/0 y 94/0 · M68 177/0 · aliasing OK(9) | 🟡 **83/192** · 93 `[?]` · 16 `[ ]` |
| 6 | 87-Localizacion | 5 | 874 | Reclamado §21.4.7. `ValidadorPO` (R1-R13/P1-P5: BOM §28, CRLF, cabecera gettext, plurales, convención RF20) + `AuditorClaves` (barrido de 702 `.gd`: usadas sin clave, sin uso, prefijos dinámicos) + `test_validador_po_m87.gd` (8 bloques, marcadores `_fin()`). Catálogo 64→85 claves; 7 claves que la UI renderizaba crudas. Bug real de rendimiento: tormenta de `push_warning` (~16 ms c/u) → dedup + `claves_faltantes()`. **Falso verde detectado** (un `SCRIPT ERROR` abortaba el bloque del auditor y el suite igual decía "0 fallos"). 5/5 suites green, 0 SCRIPT ERROR. 10 hallazgos H-1..H-10 documentados | 🟡 **120/136** · 0 `[?]` · 16 `[ ]` |
| 7 | 116-Instalador | 2 | 877 | Reclamado §21.4.7. Corregido sobre-cierre de iter. 1 (43 `[ ]` ocultos; setup/uninstall `.ps1` = 3 bytes solo BOM). Implementados: setup/uninstall `.ps1`, pipeline Inno Setup 6 (5 `.iss`), `code_signing.bat`, `verificar_requisitos.ps1`, `build_installer.bat`, `license.txt` + preset Windows en `export_presets.cfg` (desbloquea P0 de M117). `ValidadorInstalador` (V1-V11) + `test_instalador_m116.gd`: **15/0** (×3). Regresión M117 14/0. | 🟡 **182/198** · 6 `[?]` · 10 `[ ]` |
| 8 | 101-QA-General | — | 878 | QA cruzado §21.8 (no implementación): verificados los 19 archivos de `04-Codigo.md` (no sobre-cerrado), 27 áreas + 173 ítems + 12 EB en `QA-CHECKLIST.md`, `test_qa_m101.gd` **12/0** (×2), UTF-8 sin BOM. Módulo cerrado: "Con dudas" → Completado. | ✅ **209/209** · 2 ítems DoD gate M137 (KnownIssue) |
| 9 | 123-Modding | 2 | 879 | Sobre-cierre corregido (24 `[ ]` reales, no 0) + BOM §28 eliminado. Nuevo `ModSandbox` (path traversal + esquema M108), códigos E01-E14, `validar_paquete`, `resolver_prioridad`, `es_compatible_update` (M118). Test **69/0** (×3). | 🟡 **101/108** · 7 `[ ]` (producto/UI/Steam/meta) |
| 10 | 148-Lore-Ambiental | 2 | 881 | Sobre-cierre corregido (declaraba 114/114 con **99 `[ ]`** reales de 117) + BOM §28 + cifras falsas (68 piezas / islas 18-17-17-16 vs reales 60 / 18-14-14-14) + convención reparada. `04-Codigo.md` describía **Unity/C#** inexistente → reescrito con archivos Godot reales. Nuevo **`LoreGate`** (CI, `exit 1`) cableado en `quality.yml`; **grafo de pistas real** (`consumidores.json`, 18) + `LoreAuditor.validar_grafo()`; **`LoreSaveProvider`** (sección `lore` vía punto de extensión de M59, sin tocar M59) con migración de saves sin el campo. Test **85/0** (×3). 2 bugs reales: `String(x)` no es constructor válido en Godot 4 (abortaba `migrar()` en silencio) y el chequeo de IDs duplicados del auditor era **código muerto**. | 🟡 **23/117** · 2 `[?]` · 92 `[ ]` (contenido/escena/UI) |

| 11 | 52-Particulas-Y-VFX | 5 | 882 | Bug real PREEXISTENTE: `VfxFactory.crear()` asignaba `GPUParticles3D.mesh`, propiedad **eliminada en Godot 4.3** (hoy `draw_pass_1`); el error abortaba la función en silencio, `crear()` devolvía `null` y **no se instanciaba ningún VFX** pese a que los 3 tests previos daban verde (solo probaban funciones puras). Nuevos: `vfx_pool.gd` (`VfxPool`: prestar/liberar/reuso por `id`, `max_emisores`/`max_particulas` con reciclado del más antiguo, `semilla_de()` FNV-1a 32, `validar_semillas()`) y `test_vfx_pool_m52.gd` (**89/0 ×3**, 0 SCRIPT ERROR, 6 bloques con marcador `_fin`; ejercita la **ruta de runtime** que los tests puros nunca tocaban). Reescritos `vfx_director.gd` (sobre el pool) y `vfx_factory.gd` (`nuevo_emisor` + `redisparar`). Determinismo: `restart()` re-aleatoriza `seed` (2694543342→2659173778) → semilla DESPUÉS de `restart()`. **Log `VFX-SKIP` implementado de verdad** (señal `emision_descartada` → `GameLogger`); antes estaba `[x]` sin existir. 3 tests heredados 4/8/4 green → **105 checks M52**; 4 cableados en `quality.yml`. Auditoría de sobre-cierre: 5 `[x]` de RF1 sin entrada en el catálogo → `[?]` (catálogo real 8/25). `04-Codigo.md` describía rutas Unity inexistentes → reescrito. | 🟡 **78/139** · 8 `[?]` · 52 `[ ]` |
| 12 | 26-Templo-Subterraneo | 2 | 902 | Gating real (7 anillos/sellos/glifos + salida bloqueada), validadores anti-exploit/softlock (BFS), **5 checkpoints atómicos** (`templo_checkpoint.gd`: tmp→bak→cp), telemetría de puzzles (export JSON a M24) + 6 suites de validación. `test_templo_m26.gd` **92/0 ×4**, 0 SCRIPT ERROR (7 bloques con marcador `_fin`). **BUG-035 de proyecto:** `backup_manager.gd` (M107) usaba `DirAccess.new()` (clase **abstracta**) → parse error que mataba el autoload y ensuciaba todo run headless; corregido → M107 9/0 ×3. Trampa medida: `DirAccess.open("user://…")` = `null` en headless con `--path` relativo. `04-Codigo.md` describía Unity/C# → reescrito. 2 contradicciones de diseño → `[?]` | 🟡 **50/115** · 8 `[?]` · 57 `[ ]` |
| 13 | 124-Contenido-Generado-Por-Usuarios | 2 | 905 | Reclamo §21.4.7. Parte verificable headless: `UgcLimits` (RF13: por ítem y por cuota, motivo constante + mensaje claro, `consumir()`), `UgcSanitizer` (4K→2K con `Image.resize()` headless, formatos, **blueprint sin coords del save** — sobre sí, contenido de piezas intacto — y compresión ZSTD) y `UgcTelemetry` (alias hasheado FNV-1a, rechazo de PII anidada, reloj inyectable, `exportar_a_m104()`). `test_ugc_m124_iter2.gd` **85/0 ×3** (6 bloques con marcador `_fin` + **watchdog** anti-cuelgue) + regresión iter. 1 **16/0 ×2** = **101 checks**, 0 SCRIPT ERROR. **3 hallazgos reales:** `PackedByteArray.compress()`/`decompress()` no cierran el ciclo en 4.7.2 (33 B → 42 B → **1 B**); los **warnings de GDScript son errores** en este proyecto (un `:=` sobre `Variant` aborta el bloque en silencio); y un aborto silencioso en `_run()` con `call_deferred` **cuelga el SceneTree** para siempre. **Sobre-cierre corregido:** declaraba "106 resueltos, 0 pendientes" con 41 `[ ]` reales → 81 `[x]` / 25 `[?]` / 0 `[ ]`. `04-Codigo.md` describía Unity/C# → reescrito. 2 tests cableados en `quality.yml` (20 tests) | 🟡 **81/106** · 25 `[?]` · 0 `[ ]` |
| 14 | 68-Transporte-Y-Navegacion | 2 | 910 | 7 módulos headless nuevos (`TransportTripPlanner` 7 fases + regla "nunca perder al jugador", `TransportSpecialTrips` 5 festivales M74 reales + luna M31, `TransportNarrativeTrips` sobre `historia_principal.json`, `TransportRouteEvents` sobre NPCs reales, `TransportM69Bridge` regla `max(ceil(b×1.6), b+10)`, `TransportLocalizer` 89 claves ×2 locales, `ValidateTransport` 9 bloques) + 5 integraciones en `TransportManager` + 89 claves aplicadas a los `.po`. Test **199/0** ×3 (`SCRIPT ERROR: 0`); iter. 1 177/0 → **376/0**. **Falso verde por aborto silencioso reproducido** (169 checks / "0 fallos" con un bloque saltado) y **guarda probada con sonda**. Corregido 1 `[x]` optimista de iter. 1 (4 cumplen / 6 violan por diseño / 10 sin alternativa). Hallazgo: M69 y M68 no comparten estaciones (dueño M69). | 🟡 **70/131** · 14 `[?]` · 47 `[ ]` |
| 15 | 27-Islas-Del-Mundo | 2 | 912 | Los **16 `[ ]` propios** cerrados como lógica pura headless. Nuevos: `island_ops.gd` (`IslandOps`: cola de operaciones, 4 etapas con pesos 60/25/10/5, prioridad viaje>carga>descarga>precarga, idempotencia por (tipo, isla), UNA sola en curso, cancelación por id y por isla, `validar()`/`informe()`), `island_travel_guard.gd` (`IslandTravelGuard`: los 9 edge cases K1–K9 sobre una vista de islas por duck-typing — K1 precarga con `MAX_OPS_POR_FRAME == 1` y `no_congela`, K2 el destino en descarga se **encola** en vez de cancelarse, K3 náufrago con salvavidas dentro del radio de seguridad, K4 `ancla_pendiente` con `espera_coherente`, K5 `punto_seguro()` proyectando al interior del disco, K6 `limpio` **por destino**, K7 guardado que espera, K8 respawn cozy, K9 descarga forzada LRU que nunca toca la principal ni la actual) y `island_design_catalog.gd` (`IslandDesignCatalog`: los **26** puntos de la §26 con grupo/estado/resolución, 15 resueltos / 7 declarativos / 4 externos con dueño, `claves_localizacion()` para M87, `validar()` que falla si el plan deja de tener 26 puntos). Test `test_islas_m27_iter2.gd` **238/0 ×3** (`SCRIPT ERROR: 0`), 8 bloques con marcador `_fin` y **guardián anti-falso-verde probado en vivo** (aborto silencioso inyectado en el bloque D → la suite FALLA, nombra el bloque y cae de 238 a 210 checks). Regresiones: iter. 1 **171/0** · legacy **5/0** · `sincronizar_islas_mapa` OK (4 islas + 9 POIs). **2 hallazgos reales:** (a) `registro_desde_definicion()` fijaba `descubierta/visitada` en `false` y `vista_desde_registry()` no leía el registry → la guardia no podía cumplir su promesa de K9; ahora la vista refleja M59 y hay `sincronizar_estado_partida()`; (b) el checklist decía 24 puntos y el plan tiene 26. Sin M10 las 13 islas reales están sin ancla y la guardia reporta `ancla_pendiente` sin crashear. Nadie llama todavía a las 2 clases: el cableado es de M63 y M28. | 🟡 **99/192** · 93 `[?]` · 0 `[ ]` |
| 16 | 60-Datos-Y-Serializacion | 4 | 916 | Re-verificación **selectiva** tras la reversión total de la auditoría del 2026-09-14 (0/196, fila `🟢 Disponible`). **8 defectos reales** corregidos: `borrar_slot` mentía (`true` en slot vacío) y filtraba `mundo_voxel.bin.deflate` + todas las copias `.bak`; no había `.bak` para `mundo_voxel.bin`; no se regeneraba `meta.json` si faltaba; no se logueaba migración ni contrato; no había validación temprana al guardar; el motor de migración era **inalcanzable** (MIGRACIONES vacío con VERSION_ACTUAL=1) → se partió en `migrar_con_cadena(datos, cadena, objetivo)` inyectable + 3 patrones puros (`renombrar_campo`/`eliminar_campo`/`transformar_valor`); no existía `CatalogosEstaticos.validar_ids()`. Suites base **94/0** · iter. 3 **132/0** · iter. 4 **152/0** = **378 checks / 0 fallos ×3**, 0 `SCRIPT ERROR`, exit 0. Guardián anti-falso-verde **probado en vivo** (aborto silencioso inyectado en el bloque D → la suite FALLA, nombra `["D"]`, cae de 152 a 128 checks y sale EXIT 1). Nuevos `06-Plan-Testings.md` y `07-Resultados-Testings.md`. **BUG-041** (M103) reportado y **RECLASIFICADO A FALSO POSITIVO** con sonda aislada: `GameLogger` **sí registra**; el residuo real es `log_buffer` como código muerto (Baja) | 🟡 **188/196** · 4 `[?]` · 4 `[ ]` |
| 17 | 103-Logging | 1 | 918 | **Reclamo §21.4.7** tras la retirada de ox-alpha (Cline) del proyecto (el módulo estaba en `0/183` por la reversión del 2026-09-14). Suite nueva `test_logging_m103_iter1.gd` **131 checks / 0 fallos ×3**, 0 `SCRIPT ERROR`, guardián anti-falso-verde probado por inyección. **7 fixes reales:** `log_buffer` eliminado (código muerto, `_flush()` era no-op) · rotación ahora disparada desde `_log()` con contador `_bytes_written` (antes el archivo podía crecer sin límite) · **JSON con contexto era INVÁLIDO** (faltaba coma ante `context`) · **`export_by_date(hours)` era un no-op** (comparaba en días y su regex exigía espacio, pero Godot emite `T` → devolvía TODO) · `export_by_level`/`export_by_category` ahora entienden JSON · `_json_escape` escapa CR/TAB · `LogRotator.get_size()` devolvía caracteres, no bytes. Convención del checklist reparada (decía `[ ] cumplido · [ ] pendiente`), mojibake eliminado, historial sin checkbox, cifras corregidas a 158 diseño + 21 implementación = 179. Hallazgos: `logger_config.json` huérfano (contradice el `.tres`) · `LogRotator.rotate()` no renombra un archivo abierto (Windows, error silencioso) · **ajeno:** `test_loop_economico.gd` 14/1 por precio de compra (M38, cambios sin commitear de otro agente; NO es regresión de M103). Docs 04/05/06/07 + `quality.yml` | ✅ **167/179** · 12 `[?]` · 0 `[ ]` |
| 18 | 87-Localizacion | 6 | 920 | Los **16 `[ ]` propios** cerrados **por medición, no por afirmación**. Hallazgo que lo habilitó: **la medición de texto funciona en headless** (`TextServerAdvanced` + `ThemeDB.fallback_font`; `"Jugar"` a 16 px = 41×23) → tres ítems "requiere QA visual" pasan a verificables y repetibles en CI. Nuevos: `analizador_layout.gd` (`AnalizadorLayout`: `medir`, `cabe`, `razon_expansion`, `palabras_largas`, `partir_palabra` con cortes de ancho cero, `truncar_con_puntos`, `estrategia`, `analizar`), `glosario.gd` (`Glosario`) + `data/localization/glosario.json` (17 términos canónicos) y `retraductor_ui.gd` (`RetraductorUI`: decisión PURA `debe_retraducir()` + recorrido del árbol; **primer consumidor real de `locale_changed`**). `localization_manager.gd` ganó `catalogo()` / `claves_catalogo()` (solo lectura). Test `test_localizacion_iter6.gd` **82/0 ×3**, 0 `SCRIPT ERROR`, 11 bloques A–K con marcador `_fin` + watchdog: desglose MEDIDO A9+B5+C8+D9+E5+F6+G6+H6+I12+J9+K6 = 81 más 1 del guardián = 82; **guardián probado por inyección** (abortar K → `no terminaron: ["K"]`, 82→76, EXIT 1). Cifras: expansión es→en media **0,934** / máx **1,529** (5 de 170 sobre +30 %); desborde 220×40 → **63/170** a 16 px, 0 a 12 px, 97 a 24 px; palabra sin espacios 237→219 px; HUD de 120 labels **1,4-2,0 ms** frente a 16,67 ms/frame; glosario **0 inconsistencias**. **REGRESIÓN REAL reparada:** `test_validador_po_m87.gd` (iter. 5) **estaba en rojo** — 13 claves `M68.*` añadidas por M68 iter. 2 (Log 910) tienen `msgstr` idéntico es/en y P5 lo reporta como "sin traducir"; no son un olvido sino textos **sin palabras que traducir** (plantilla de cartel ×11, `AO`, `{h} h {m} min`). Arreglo **sin debilitar la regla**: marcador estándar de gettext `#. no-traducir: <motivo>` + `exentas_p5` auditable, 13 entradas marcadas en ambos catálogos, probado por inyección en las dos direcciones. **No se tocó M68.** **BUG-042** (dueño M46/M88): 3 de las 4 fuentes de `assets/fonts/` son **páginas HTML 404** con extensión `.ttf`; el fallo es **silencioso** porque `load()` no devuelve `null` sino un `FontFile` con métricas en cero. Doc **corregida**, no solo ampliada: §2/§4/§5/§8 de `04-Codigo.md` describían archivos previstos bajo `res://localizacion/` marcados "Pendiente de implementación" que no existen. **6/6 suites cableadas en `quality.yml`** (antes ninguna de `scripts/localization/` estaba en CI; YAML validado). Trampas 55-57 al skill: `get_string_size` con ancho POSITIVO **trunca** y devuelve la altura de una línea (usar `get_multiline_string_size`) — error cometido y corregido en esta misma iteración; `FileAccess` sin `.eof()` y el aborto silencioso con `SceneTree` **cuelga el árbol** (se mató a los 2 m 7 s). | 🟡 **129/136** · 7 `[?]` · 0 `[ ]` |
| 19 | 116-Instalador | 3 | 1014 | Iteración de **verificación y honestidad**, sin funcionalidad nueva. **(a) El gate de CI deja de ser decorativo:** el paso de M116 en `quality.yml` estaba cableado **con `|| true`** — existía, pero no podía hacer fallar el build (familia **trampa 75**: el verde lo producía la tubería, no el programa). Se midió el exit **del proceso** (no el de un `tail`/`grep` aguas abajo) en 3 corridas `RC=0` con salida **byte-idéntica** (465 líneas, mismo `sha256`) y recién entonces se quitó el `|| true` → **gate duro**. **(b) Conteos declarados corregidos:** la `05-Checklist.md` declaraba `180 [x] / 6 [?] / 12 [ ]` mientras el cuerpo ya tenía **192 tareas hechas**; los **6 ítems del historial** estaban como `- [x]` e inflaban el denominador (**trampa 42**: contaba 198 = 192 + 6) → viñetas simples. **(c) Registros:** `CHECKLIST-GLOBAL` fila 116 `198/198` → `192/192` (y la fila 60 restaurada: un commit ajeno la había pisado a `iter. 4 · 188/196`); `04-Codigo.md` §12 con columna de estado real (9/10 artefactos ✅, `icon.ico` ❌ de M46) y §13 con nota de cierre; `06/07-…-Testings.md` con la iter. 3. **(d) Checklist personal sincronizada** in-place (20 marcadores; 192 `[x]` / 0 / 0; historial separado bajo su propio encabezado). **Verificado:** `test_instalador_m116.gd` **15/0 ×3** (`RC=0`, 0 `SCRIPT ERROR`) + `ValidadorInstalador` **61 checks / 0 errores** sobre el repo real; `scripts/verificar_checklist.py` → M116 **192/0/0** y la fila del GLOBAL coincide con el módulo. **Reportado sin parchear:** `installer/icon.ico` ausente (M46). | ✅ **192/192** · 0 `[?]` · 0 `[ ]` (⏳ §21.8 iter. 3) |
| 20 | 87-Localizacion | 7 | 1015 | Iteración de **corrección** (no funcionalidad nueva). **Regresión real encontrada al medir el exit del PROCESO** de los 31 gates propios neutralizados con `|| true` (trampa 75): 30 verdes ×3 pasadas con salida idéntica (30/31 byte-idénticos; el restante idéntico como multiset — sólo se reordena un log asíncrono de M60) y **1 rojo**: `test_validador_po_m87.gd` **RC=1**, `auditor real: 0 claves de PRODUCCIÓN ausentes -> ["SETTINGS.DESCARTAR"]`. **Causa:** 3 claves usadas por M53 (`inventory_layer.gd`, commit `84d975d` del 2026-09-17 20:21) ausentes de `es.po` y `en.po` → el botón de descarte renderizaba la clave cruda y **cada corrida headless del proyecto** emitía `WARNING: [M87] Clave sin traducción` (visible en las 31 salidas del barrido). **Cadena de custodia:** el gate de M87 quedó neutralizado con `|| true` el 2026-09-17 02:52 (commit `a466ab3`, del usuario) y la regresión entró esa misma tarde a las 20:21 → el único test que la detectaba no podía hacer fallar nada durante 18 h. **Corregido:** las 3 entradas en ambos catálogos (`_MENSAJE` **con `%s`**, porque el llamador hace `_t(clave) % item_name` y `ConfirmPopup.configurar` traduce la clave con `_t()`; sin `%s` la interpolación era un no-op). **Causa de raíz cerrada:** `AuditorClaves` sólo veía claves dentro de `_t("…")`, así que las pasadas **como argumento** a `open_confirm` eran invisibles y figuraban como **huérfanas** en vez de **faltantes** → se agregaron `RE_CLAVE_ARG1`/`RE_CLAVE_ARG2` (dos posiciones, exigen la forma `MODULO.SECCION.CLAVE` para no marcar texto humano) + 6 aserciones en el bloque G. **Medido:** `usadas` 55→**57**, catálogo 174→**177**, `usadas_sin_clave` 1→**0**, `claves_sin_uso` con `DESCARTAR_*` 2→**0**, veredicto `CLAVES SIN TRADUCCIÓN`→**`OK`**; suite **RC=0 / 0 fallos / 0 SCRIPT ERROR ×3** con `sha256` idéntico. **Gates propios endurecidos:** los 31 comandos de mis módulos pasan de `|| true` a patrón acumulativo (`FAIL=0` + `|| FAIL=1` + `exit $FAIL`) → todos corren y el job falla si alguno rompe (commit `0339042`); los 14 `|| true` ajenos quedan intactos. **Reportado sin parchear:** 2 gates ajenos **estructuralmente inválidos** (`--script` sin ruta L33, `--check-only` sin ruta L83) y el `echo "… (exit code: $?)"` de L84 que siempre imprime `0`. | 🟡 **129/136** · 7 `[?]` · 0 `[ ]` (sin cambios: corrección, no alcance nuevo) |
| 21 | (transversal) BUG-042 | — | 1024 | **Corrección de un defecto de 19 días.** 3 de las 4 `.ttf` de `assets/fonts/` eran la página `Page not found · GitHub` (514 líneas de HTML, ~304 KB cada una; bytes mágicos `0a0a0a0a` contra `00010000`). Rastreado al commit `dd101d9` (2026-08-30), cuyo mensaje afirma «0 errores FreeType en runtime». Reemplazados por las fuentes reales: Nunito Regular/Bold como instancias estáticas `wght=400/700` derivadas con `fontTools` de `google/fonts/ofl/nunito/Nunito[wght].ttf`, y Fredoka One del historial de `google/fonts@be2838a2` (la familia actual es `Fredoka` variable, que **no** es la `Fredoka One` registrada). Ambas ya declaradas **SIL OFL 1.1** en `ASSETS-LICENSE.md` (A003/A004) → sin decisión de licencia nueva. 938 glifos por instancia de Nunito, 228 Fredoka One; la `Nunito-Variable.ttf` que ya estaba en el repo resultó **byte-idéntica** al upstream canónico. **Puerta en producción:** `theme_ux._try_load_font` deja de confiar en `err == OK` (`load_dynamic_font()` devuelve OK sobre una página HTML) y **mide** `get_string_size().x > 0`. **Gate de CI nuevo** `binary-guard` (`scripts/verificar_binarios.py`: 1.107 binarios versionados, 28 extensiones, AND dentro de cada firma) + `scripts/test_verificar_binarios.py` **57 checks** con prueba por inyección + `scripts/fonts/test_fuentes_binarias_bug042.gd` **22 checks ×3, 0 `SCRIPT ERROR`** cableada en `test-suite`. La guarda de producción probada por inyección (revertida → el bloque G falla; restaurada por `sha256`). `quality.yml` tenía 41+/6− ajenos sin commitear: staging por bytes → commit `7a1a3b3` **solo mío**, lo ajeno intacto. **Reportado, no tocado:** `data/fonts/fonts.json` de M88 (4 placeholders que no corresponden a los archivos reales), 3 `.png` que son JPEG/WebP en `tools/mcp/` (untracked+gitignored) y `test_fonts_m88.gd` (prueba el catálogo, nunca carga un archivo). | BUG-042 → `[x] Resuelto`; gate `binary-guard` activo |
| 22 | 103-Logging | 2 | 1109 | **Auditoría de suites muertas** (patrón del Log 1094) tras la reasignación desde kimi-k3. **No había suite muerta**, pero sí **2 defectos reales:** `test_logging_m103.gd` publicaba «14 checks» con **11 INALCANZABLES** (trampa 46: `_test_export`/`_test_rotation` definidos y **nunca llamados** → no ejercitaba `export_last_lines` ni los 8 métodos de rotación; ahora **25**), y `test_logger.gd` **no limpiaba** su export (reconstruía el nombre con el reloj actual → borraba otro). **Guardián de 3 capas** en las 3 suites (`_fin()` + piso `CHECKS_MINIMOS` **medido** 14/25/131 + `_summary()` en su propio `call_deferred`, trampa 61) y **probado EN ROJO en las 4** con puntos documentados (25→11 `["B","C","D"]` · 14→7 `["C","D","E","F"]` · 131→126 `["C"]` · 9→4 `["B","C"]`; las 4 con **exit 1 sin colgarse**). **Suite nueva `test_m103_frame_budget.gd`** (9 checks) que **cierra el ítem L199 por MEDICIÓN**: `gate 0,140 µs · filtrada 1,110 µs (75/frame) · disco 4,925 µs · ESCRIBE 512 µs (0/frame)`; **99 % del coste es consola+formato, 1 % disco**. **Regresión 6/6** (incl. `test_loop_economico` **15/0**: lo arregló el dueño de M38) → ítem N20 `[?]`→`[x]`. **Totales: 14+25+131+9 = 179 checks / 0 fallos ×3.** **Gate de CI:** M103 sólo tenía 1 de sus 3 suites cableadas → ahora **4** (patrón duro). Cerrados 6 `[?]` (T-093/T-094/T-135/T-142/T-165/T-178); los 6 restantes son de M102/M110/M122. **Hallazgo → BUG-067** (una llamada que escribe = 512 µs = 6× el frame; y `03-Diseno.md` §3 vs §10 Regla 5 se contradicen). Docs 04/05/06/07 + `11-BUGS.md` | ✅ **173/179** · 6 `[?]` · 0 `[ ]` (⏳ §21.8 iter. 2) |
| 23 | 62-Memoria | 4 | 1112 | **Gates estáticos + medición de liberación.** Primero se midió y **la medición tumbó la hipótesis**: se creía que `get_node_or_null("/root/X")` desde `_ready()` devolvía **null silencioso** cuando X se declara después → **banco de pruebas propio (2 autoloads, Godot 4.7.2 headless) demostró que NO**: en `_ready()` ya están todos los autoloads; solo `_init()` falla, con `ERROR` fuerte y **para cualquier destino** (no por el orden). Habría sido un BUG falso. **Auditor estático nuevo** `scripts/auditar_arquitectura_m62.py` (fuera de `res://`, junto a `verificar_binarios.py`): grupo A (Tarjan para componentes cíclicas · referencias fuera de orden alcanzables desde `_ready()` · autoload duplicado) y grupo B (carga síncrona en callbacks por frame). **17 checks de selftest**, y el selftest **cazó 4 defectos del propio auditor** en su primera corrida (entre ellos que `x.instantiate()` y `d.duplicate()` eran **indetectables** por un lookbehind que prohibía el punto delante, y dos aserciones mal escritas). **Guarda de ceguera con exit 3** porque el mismo detector había reportado «0 ciclos» **dos veces siendo ciego** (rutas de autoload mal resueltas; después 0 callbacks) → se añadió un fixture explícito de «grafo con 0 aristas». **Grupo B: 0 hallazgos** en 800 archivos `.gd` y 79 callbacks por frame. **Suite nueva `test_m62_liberacion.gd`** (15 checks, 0 fallos, **×5 idénticas**) que cierra **4 ítems por medición**: pico por objeto **0,279-0,492 ms** contra el límite de **3 ms** (L191); lote completo **2,1-5,8 ms** contra **50 ms** (RN2); por debajo de un frame de 16,67 ms (RN6); huérfanos base 0 → 128 → 0. Guardián probado **por inyección** (1 check, 2 fallos, exit 1, sin colgarse). Otra aserción mía era suposición: «2048 chicos cuestan más en total que 256 grandes» → medido **al revés** (2346 vs 4270 µs), y comparar **picos** es inestable (corrida 3: 492 > 448 µs) → la señal estable es el **total**. **2 gates de CI nuevos** (job `architecture-guard` + la suite en `test-suite`). **2 bugs nuevos:** BUG-068 (`hardware` y `HardwareManager` son el MISMO script en dos autoloads → 2 instancias, medido) y BUG-069 (2 componentes cíclicas + 9 refs fuera de orden; deuda arquitectónica, sin fallo de runtime medido). El ítem de ciclos **queda abierto a propósito** | 🟡 **98/150** · 0 `[?]` · 52 `[ ]` (⏳ §21.8) |
| 24 | 106-Seguridad + 122-Crash-Reporting | P-36 | 1149 + 1150 | **P-36 (encargo directo del coordinador, fuera de mi cola por encaje).** **M106:** el «149/206» **no estaba en `HEAD`** (trampa 58: la iteracion de kimi-k3 — 4 helpers + 5 tests + 2 mods + 2 docs + **9 logs** — vivia solo en el worktree; recuperada en `471d2b8`). **3 falsos verdes:** el test del escaner de secrets estaba en **ROJO (20/1)** con la nota afirmando «20/0 verde» (`DirAccess.open("user://…")` = null en headless, pitfall 9.6) -> `_abrir_dir()`; **KeyManager** con sus 5 items `[x]` y **cero implementacion** (grep -> 0), tambien en `HEAD`; **`security-scan` de `quality.yml` no es un gate** (4 grep con `\|\| true`, trampa 81) -> reportado, no convertido. 7 servicios offline + `.env.example` + **HMAC-SHA256 a mano** medido contra Python. **8 suites, 237 checks, 0 fallos x3.** **M122:** `test_crash_m122.gd` en **ROJO (12/2)** con la Evidencia afirmando «12/0» — **mismo bug de `DirAccess` en headless** -> 13/0; `## Totales` decia «335/335/0» sobre **265** marcadores con **80 `[ ]`**. 10 helpers offline (transporte HTTP inyectado, GZIP, hashing de stack normalizado) + 3 defectos del diseno corregidos (`crash` no declarada, `OS.get_dynamic_memory_usage()` inexistente, `debug_menu.add_panel()` que M110 no expone). **2 suites, 181 checks, 0 fallos x3.** Las **10 suites cableadas** en `quality.yml`. **Drift diseno<->codigo REPORTADO, no reescrito** (ver `04-Codigo.md §15` de M122). | **M106 ✅ 194/206 · 12 `[?]` · 0 `[ ]`** · **M122 ✅ 254/265 · 11 `[?]` · 0 `[ ]`** (ambos con QA §21.8 pendiente) |
| 25 | 122-Crash-Reporting + 106-Seguridad | P-42 | 1156 | **P-42 (encargo directo del coordinador, fuera de mi cola).** **P-42.1 — drift diseño↔código de M122: se alineó el DISEÑO al CÓDIGO, no al revés.** Medido antes de decidir: **0** declaraciones `class_name` en `scripts/crash/` y **0** usos por tipo en todo `game/` → ningún consumidor exige la clase → **no se refactoriza** (regla 15: no se toca lo que funciona). `03-Diseno.md` alineado (88 inserciones / 21 borrados): rutas reales `scripts/crash/`, `class_name` retirado de los **10** bloques de código, `OS.get_dynamic_memory_usage()` (inexistente en 4.7.2) → `OS.get_memory_info()["available"]`, cabecera de aviso y **§16** nueva con la tabla de correspondencia diseño↔código + subsección de **deuda opcional** (`class_name` documentado, no pendiente activo). **P-42.2 — `security-scan` de `quality.yml` convertido en gate DURO** (era 4 `grep … \|\| true`, trampa 81). Nuevo `scripts/auditar_secrets.py` (Python stdlib, corre en ubuntu sin Godot; espeja los PATRONES de `security_secret_scanner.gd`); cableado en el job `security-scan` con `Setup Python` + `Gate: no hardcoded secrets (M106)` + `--selftest`. **Procedimiento obligatorio cumplido por medición:** inyecté `scripts/_p42_probe_secret.gd` → **exit 1** nombrando archivo/línea/regla; borrado → **exit 0**; `--selftest` **6/6**. **La evidencia decidió:** 0 secrets en 634 archivos (scripts) / 2717 (proyecto) / 3554 (repo) → árbol limpio → gate verde, sin necesidad del modo warn. Exención documentada para el propio escáner (auto-flagueaba su `FIXTURE_*`). El paso de debug-prints se dejó **informativo** (712 hallazgos → CI rojo permanente sin plan de remediación). **2 defectos que la validación del propio repo cazó antes de CI:** `validar_workflows.py` → **YAML INVALID** por `: ` sin comillas en mi `name:` (**BUG-077**, habría matado todo el workflow) y el auto-flag del fixture. **`\r\r\n` en `CHECKLIST-GLOBAL.md`:** reportado, **NO tocado** (blob de HEAD limpio: 231 CRLF / 0 CR suelto; mi edición P-42 asertó CR 451→451). **Pool:** `--estado` justo antes → primero **1156** (el pedido decía 1154, stale). | **M106 ✅ 194/206 · 12 `[?]` · 0 `[ ]`** · **M122 ✅ 254/265 · 11 `[?]` · 0 `[ ]`** (conteos sin cambio; P-42 alineó diseño + endureció CI) |
| 26 | (transversal) P-45 — mi tajada del merge | P-45 | 1159 | **P-45 (encargo directo del coordinador): commitear mi bucket A del merge.** **Hallazgo principal: la clasificación de s2 está MAL ATRIBUIDA.** De los 89 archivos que s2 asignó a `deepseek-v4.1-flash`, **0 llevan mi firma en el diff**: s2 clasificó por la firma `**Modelo:**` del *header* (el último autor *commiteado*, de hace semanas), **no** por el autor del *cambio*. Los diffs reales son de **Atria-Dawn-Preview / Kilo Code** (72 de 89 = drift de `**Totales:**`, bloque 1B/1C), glm-5.3 (3), agnes (3), mimo (2), atria (1, BUG-061) y otros. **Método:** barrí las líneas AÑADIDAS de los 434 sucios+untracked buscando firmas de autor (solo `CHECKLIST-GLOBAL.md`, compartido, tenía la mía); verifiqué los «sin firma» por **log de origen** (M26/M92 = drift 1104/1107; `objetivos.json` = BUG-061 Log 1083; `npc_agent.gd` = M64/M29) y los headers `**Modelo:**` de **todos** los logs untracked (solo **1149 y 1150** son míos). **Lo que commiteé:** `7e38f97` — los **2 logs de P-36** (1149/1150), que habían quedado **untracked** (el cierre de P-36 no los commiteó). **Lo que NO:** los 89 «míos» (son de atria → tu bucket) ni los 4 compartidos. **Pendiente para el coordinador:** reclasificar los ~72 archivos de drift a tu bucket. | Sin cambios de módulo (solo logs + auditoría de autoría) |
| 27 | (transversal) P-48 — reclasificación del merge por autoría REAL | P-48 | 1163 | **P-48 (encargo directo del coordinador, SOLO REPORTE).** Tras aceptar mi hallazgo de P-45 (la clasificación de s2 medía el **header del archivo**, no el autor del **cambio**), el coordinador me pidió reclasificar **todos** los sucios+untracked (**429**: M 155 · D 34 · ?? 240) con mi método y entregar 4 buckets. **Resultado: B (atria) 149 · SCRATCH 134 · OTRO:mimo 37 · BORRADO 34 · OTRO:agnes 27 · OTRO:glm-5.3 13 · C 11 · AMBIGUO 5 · OTRO:hy4 5 · OTRO:nex 5 · EOL 3 · OTRO:deepseek-v4-flash\* 3 · OTRO:gemini 1 · OTRO:step-3.7 1 · OTRO:deepseek-v4.1-flash 1. 0 sin resolver.** **Método iterado v1→v6; cada refinamiento nace de un falso positivo MEDIDO:** (1) anclar `**Modelo:**` a **inicio de línea** (matcheaba una *mención entre backticks* dentro de un log → atribuía al citado); (2) carpeta `TAREAS-POR-MODELO/<dueño>/` como señal **estructural**; (3) `# Modelo:` (comentario), `(BUG-N, modelo)`, `(fecha, modelo)`, `M<n> iter. modelo`, `Helper temporal`, `Iteración X`; (4) **los logs son artefactos de UN autor** → manda su **primera** cabecera, las menciones a otros NO crean conflicto; (5) `**Totales:**` = **drift 1B/1C de atria** (confirmado: M26 *solo* tiene ese cambio) + `Fix BUG-051 (atria-dawn, …)` + `verificado <fecha> por <modelo>`. **Bucket B (149):** 102 docs + 39 logs untracked + 8 otros (drift 1B/1C, BUG-051, BUG-061/`objetivos.json`, M26/M92, el colector `_colector_sintaxis.gd`, `DOCUMENTACION/Auditorias/`). **Bucket C (11):** los **4 compartidos** + **7 checklists** con drift de atria **y** contenido/QA de otro modelo (09 agnes, 12 mimo, 131 hy3+mimo, 31 glm+mimo, 51/72/87 agnes) → por la regla del encargo, **C no B**. **Hallazgos colaterales:** **163 untracked bajo `Logs/`** (58 `.md` de trabajo real + 104 `_*.txt` scratch + 1 json); `Logs/1013-QA-M14-Inventario` fue **renumerado a `1047`** (su `D` no es pérdida); **3 EOL-only** (`110/05-Checklist` cambió solo fin de línea). **No commiteé ningún archivo de los buckets** (solo este log + el backlog); **Push NEGATIVO**. | Sin cambios de módulo (auditoría de autoría + reporte) |
| 28 | 68-Transporte-Y-Navegacion | 3 | 1251 | **Frente asignado por el coordinador (Log 1247, tras aprobar M17 iter. 3).** Cierra la mitad headless que quedaba de las secciones **J (waypoints)** y **T (edge cases)**. Nuevo **`TransportRouteWaypoints`** (`class_name`, `extends RefCounted`, **modelo puro sin nodos**): `de_camino(paradas, red)` → `Array[Dictionary]` (`{indice, stop_id, pos, fraccion, es_destino, tramo_m, acumulado_m}`, ids que no resuelven se saltan), `de_plan(plan, red)` → `{ok, motivo, waypoints, distancia_total_m, saltos, es_larga, radio_llegada}`, `plan_es_largo` (`MIN_SALTOS_LARGA := 2`), `validar` (orden, fracción/acumulado monótonos, primero 0.0, último `es_destino`+1.0; ruta degenerada de 1 parada exenta), `resumen`, `indice_mas_cercano`, `avance_en`. `TransportManager` gana `waypoints_de_ruta()` / `es_ruta_larga()` y el **gate de contexto de viaje** (`contexto_de_viaje()` + duck-typing `DialogueManager.is_dialogue_active` / `Inventario.has_free_space`): **sólo el diálogo bloquea**; el inventario lleno se **reporta** pero no bloquea (**divergencia declarada**). Suite nueva `test_transporte_m68_iter3.gd` **108/0 ×3** (8 bloques A–H con `_fin()` + piso `CHECKS_MINIMOS := 108` medido + `_summary()` en `call_deferred` separado + watchdog). **Guarda anti-falso-verde probada EN ROJO 4/4** (control EXIT 0; A modelo `es_destino=false` → 3 FAIL; B aborto bloque C → nombra `["C"]`; C `CHECKS_MINIMOS=999`; D sin `_fin` de H → nombra `["H"]`). **Bug propio cazado por la 1ª corrida (9 FAIL):** `de_camino` acumulaba el tramo DESPUÉS del `append` → `fraccion`/`acumulado_m` un tramo por detrás; fix: `acum += tramo` antes de calcular `frac`. **Trampa medida:** un `class_name` nuevo NO resuelve en headless con la cache `global_script_class_cache.cfg` stale y `--script` NO la regenera → `--import` antes de medir (registrado en el skill y pedido por el director para la guía GUIA-GODOT). **No regresión** (iter. 1 177/0, iter. 2 199/0). Checklist 70 → **75 [x]** (+5: J waypoints automáticos, J testear 2+ paradas, T dinero justo/última hora, T diálogo/inventario, T desbloqueo+clima). **Pendiente NO aplicado por indicación del director:** cablear la suite en el job `test-suite` de `quality.yml` (lo edita s2 por BUG-091 modo A; evita edición concurrente). | 🔵 **75/131** · 14 `[?]` · 42 `[ ]` |
| 29 | 29-Tiempo-Y-Calendario | 2 | 1257 | **Frente asignado por el coordinador (Log 1247 / mensaje 09, tras aprobar M68 iter. 3):** M29 era el **bloque mas grande de los 73 parse errors de BUG-091: 28 errores en 2 archivos de tests del modulo**. El patron era "tipo builtin usado como nombre" (`is_instance_of(int)`, etc.). **Los 2 archivos no eran solo suites rotas: eran suites gdUnit4 MUERTAS** — usaban `is_instance_of(...)` (no existe; el metodo real es `is_instanceof(type: Variant)`) e `is_equal_to(...)` (no existe; el real es `is_equal(...)`). Un *rename mecanico* habria dejado 2 suites que NUNCA afirman nada (verde falso). **Decision declarada:** convertirlas al estandar headless del proyecto (`extends SceneTree` + `--script`, metodo 12.1), no renombrar. **Suite viva 1** `tests/unit/time/test_time_calendar.gd` **74/0 x3**; **Suite viva 2** `tests/integration/test_time_calendar_events.gd` **51/0 x3**; 8 bloques A-H cada una, piso `CHECKS_MINIMOS` medido en verde (74/51), `_summary()` en `call_deferred` separado + watchdog. **Parse errors: 0** (`--check-only` EXIT 0 en ambas). **Sondas en ROJO 5/5 + 2 controles** (A fuente `get_hora`->99 => suite 1 falla 2 FAIL; B aborto runtime bloque C => nombra `["C"]`; C `CHECKS_MINIMOS=999`; D sin `_fin` de H => nombra `["H"]`; E fuente mutada => suite 2 falla 3 FAIL), restauracion byte-exacta verificada. **Sin cambio de marcas (190/195).** **NO toca `quality.yml`** (lo edita s2 por BUG-091); lineas de cableado propuestas en `04-Codigo.md` seccion Iteracion 2. **NO sella 21.8.** | 🔧 **190/195** · 3 `[ ]` · 2 `[?]` (sin cambio) |
| 30 | (transversal) BUG-091 — colisión `TerrainData` | — | 1263 | **Frente asignado por el director (mensaje 11, tras aprobar M29 iter. 2).** Al revisar mi carpeta, el frente **ya estaba resuelto**: agnes-3-flash había renombrado el `class_name` de M156 (`scripts/terrenos/terrain_data.gd`) a **`TerrainDataM156`** (commits `6ad7031`/`59e2a48`) — **doble asignación del mismo frente**. **No dupliqué el fix: lo verifiqué de forma independiente (autor ≠ verificador).** M08 `scripts/terrain/terrain_data.gd` = **VIVO** (lo usa `terrain_data_provider.gd` + **7 `.tres`** de `resources/terrain/`); M156 = **HUÉRFANO** (0 usos de `TerrainDataM156` fuera de su propio archivo; la única referencia a su ruta es el colector autogenerado `scripts/editor/_colector_sintaxis.gd` por `preload` de **PATH** → el rename no lo rompe). Colisión resuelta a nivel proyecto: `global_script_class_cache.cfg` con **exactamente 1** `TerrainData`; **0** `class_name` duplicados en todo `game/`. **Hallazgo NUEVO + fix:** el provider M08 (el consumidor VIVO) **seguía sin cargar** — 3 parse errors preexistentes de BUG-091 (L30/36/42, inferencia `Variant` sobre `Dictionary.get()`) → `var terrain: TerrainData = _terrains.get(terrain_id)`; ahora **`--check-only` EXIT 0, parse=0**, LF preservado (commit `603834b`). **M167 (Isla-Raiz) verificado sin impacto** (0 refs a `TerrainData`; es un tercer sistema de terreno). **Sin cambio de marcas; NO sella §21.8.** | `TerrainData` único en el proyecto · provider M08 EXIT 0 |
| 31 | (transversal) BUG-093 — suite MUERTA `test_terrain_modifiers.gd` | — | 1264 | **Frente del director (mensaje 13).** La suite usaba `assert_that().is_equal_to()` (x4) e `is_greater_than()` (x1) — métodos que **NO existen en gdUnit4** (0 en `addons/gdUnit4/`) -> **parseaba (EXIT 0) pero moría en runtime** (suite MUERTA; clase más silenciosa que `is_instance_of(int)`, que SÍ da parse error). **Segundo defecto:** la 1ª aserción esperaba `4.2` para `calculate_effective_speed(5.0,0.8,0.2)`; código + diseño §3.1 dan **4.8** -> expectativa OBSOLETA (la aserción consagraba un dato viejo). **Convertida al estándar headless** (`extends SceneTree`, 2 bloques A/B, guardia de 3 capas, piso `CHECKS_MINIMOS := 10` medido, watchdog). **10/0/EXIT 0 x3**; sonda ROJO **4/4** (control + fuente mutada + aborto runtime `["B"]` + piso), restauración byte-exacta (sha256). **Familia:** `is_equal_to` = 135 llamadas / 10 archivos; `is_greater_than` = 5 / 3 -> **>10**, sub-frente autorizado (pendiente). Registrado + CERRADO en `11-BUGS.md`. **NO sella §21.8.** | BUG-093 `[x] Resuelto` |
| 32 | (transversal) BUG-091 — widgets M53/M54 (3 parse errors) | — | 1266 | **Frente del director (mensaje 13, parte c).** 3 widgets con parse error de BUG-091: `full_map_layer.gd` (M54, real en `scripts/mapa/`) L32 (`_mouse_filter` -> `mouse_filter`) + L47 (`set_anchors_and_offsets_preset` no acepta `Vector2` como 3er arg -> `custom_minimum_size` + preset centrado); `action_prompt_overlay.gd` (M53) L106 (`Input.get_joy_button_string()` **NO existe en 4.7.2** -> mapa manual del enum `JoyButton`); `hotbar_widget.gd` (M53) L52 (inferencia `Variant` -> tipo explicito). **HALLAZGO:** los 3 están referenciados por `scenes/ui/hud.tscn` (`[ext_resource]`) -> **NO** eran "código no conectado": el HUD tenía 3 scripts que no parseaban. `--check-only` **EXIT 0 x3**; sonda `load()` de `hud.tscn` + los 3 scripts **OK x4**. Marcados en los 05-Checklist de M53/M54 (los 3 ítems ya estaban `[x]` pese al parse error -> sobre-cierre). **NO sella §21.8.** | `[x]` corregidos |
| 33 | (transversal) BUG-093 sub-frente FAMILIA + BUG-094 | — | 1268 | **Frente del director (mensaje 16).** Barrí la familia de APIs gdUnit4 **MUERTAS** en todo `game/isla-ancestral/tests/`: `is_equal_to` (real `is_equal`) = **134 llamadas / 12 archivos** + `is_greater_than` (real `is_greater`) = **5 / 3** (cifra corregida: eran 134/12, no 135/10). **2ª familia nueva -> BUG-094:** `is_instance_of` (real `is_instanceof`) 1/1, `has_not_contains` (real `not_contains`) 1/1, `has_any_item` (real `contains`) 1/1. **7/12 convertidas a headless y VERDES** (135 checks/0 fallos/EXIT 0 x3, piso `CHECKS_MINIMOS` **MEDIDO** y fijado, sonda ROJO 14/14, restauración byte-exacta): `test_i_interactable` (11), `test_i_saveable` (15), `test_i_damageable` (16), `test_contenedor_inventario` (33), `test_recipe_schema` (10), `test_economy_manager` (31), `test_economy_npc_shop` (19). **5/12 ROJAS** (convertidas, NO cableadas; causas ajenas / en vuelo): `test_item_data` (61/3 fail), `test_npc_visual_database` (async), `test_equipment_manager` (async+infer), `test_inventory_economy`+`test_stable_flows` (`Identifier not found: ItemDatabase` en `inventario_service.gd:171`). **Hallazgo REAL reportado (NO corregido):** `scripts/data/item_data.gd:88` `es_valido()` con bug de precedencia (`and` > `or`) -> `tamano=(1,0)` da `true` (debería `false`). Registrado en `11-BUGS.md` (tabla + §7: BUG-093 ABIERTO + BUG-094 nuevo) + **patrón widget** (un `[x]` de widget/UI exige parsea **Y** la escena carga). **NO toqué `quality.yml`** (lista de 7 suites a s2). **NO sella §21.8.** | BUG-093 [ ] ABIERTO · BUG-094 [ ] nuevo |
| 34 | (transversal) BUG-091 residuo — los 44 SCRIPT ERROR | — | 1277 | **Frente del director (mensaje 18 d).** s2 cerró tools/editor (22->0, Log 1271) y agnes gameplay/world/core; quedaban **44 SCRIPT ERROR**. **Medido con el colector real** (`gen_colector_sintaxis.py` + `--check-only --script`, mismo criterio del gate `godot-lint`), **clasificado por familia**: **11** autoload bare-identifier (EventBus x5, ServiceRegistry x2, MundoRaiz x2, ItemDatabase x1, GameLogger x1) + **1** cascada + **6** `CollectibleCategory` sin `class_name` + **13** `Cannot infer` + **4** `Warning treated as error` + **2** `AutoAdvanceManager` + **3** inner-class colisiona con `class_name` global + **3** función inexistente (`setdefault`/`autoload`/`add_child`) + **1** return-type = **44**. **HALLAZGO clave: el caso A NO es ruido de `--script`** — de **16** archivos que usan `EventBus.`, solo **5** fallaban; los otros 11 ya usaban `get_node_or_null("/root/EventBus")` (convención del proyecto, 172 archivos). Sonda empírica: `EventBus.emit_signal("x")` bajo `--check-only --script` -> "Identifier not found". En full load los autoloads sí resuelven (`-e --quit` = 0 antes y después) -> los 11 no rompían el juego pero SÍ el gate y las corridas headless. **Fix:** convención `get_node_or_null` para autoloads (+ helper `_registry()` en `bootstrap.gd`; `MUNDO_RAIZ`/`GAMELOGGER` por `preload` para constantes/enums), `class_name` faltantes, `:=`->`=` sobre Variant, rename de inner classes, fixes de funciones inexistentes, `-> Script`->`-> Node`. Archivo obsoleto `core/Obsoletos/...bootstrap.gd` **relocalizado** fuera de `scripts/` (+ `git rm` del `.uid`). **Resultado: colector 44 -> 2** (residuo = 1 error ajeno `inventario_service.gd:171` = agnes/BUG-095 + 1 cascada dependiente); **full load 0 SCRIPT ERROR / EXIT 0**; M167 `validador_isla_raiz` **30/0** (cadenas preservadas en comentarios); suites tocadas verdes (`test_collectible_category` 0, `test_ubicaciones_m160` 17/0, `test_bench_recorder_m166` 0). **Falsos de `--script`: 0.** **NO toqué `quality.yml`** (gate de s2; se pone verde solo con el fix de agnes). Hallazgos colaterales reportados: `test_enchantment` (M163) cuelga (prefijo doble `res://game/isla-ancestral/` + sin watchdog; no está en CI) y `test_collectible_category` (M73) emite `SCRIPT ERROR` de RefCounted pero dice "0 fallo(s)". Registrado como **BUG-098**. **NO sella §21.8.** | BUG-098 [x] resuelto en zona propia |
| 35 | M03-Documentacion-Del-Proyecto (T-D4) | 0/133 -> 117/133 | 1283 | **Frente del director (mensaje 20).** Auditoría item-por-item del `05-Checklist.md` de M03 **contra disco** (no contra el bloque `Totales`). **Marcas: 0 `[x]`/135 `[ ]`/3 `[?]` -> 117 `[x]`/9 `[ ]`/7 `[?]`.** Verificado: estructura raíz, `.gitignore` (`!Logs/`/`!DOCUMENTACION/`), scripts (`generar_checklist_global.py` con `--dry-run`, `verificar_checklist.py`, `test_scripts.py`, `reservar_log.py`), los 5 `*-ACTUAL.md` (existen + firmados), `plan-inicial`↔`plan-actual`, `Logs/06`, commits `e044c29`/`b09a57e`, checklist=133 (>100); `test_documentation_m03.gd` 8 checks/0 fallos/EXIT 0. Corregí el bloque `Totales` ("Completados: 133" -> 117/9/7). **HALLAZGO 1: el módulo es de la ERA UNITY** (2026-08-16; refs a Unity/C#/`Assets/`/`Logs/rotated/`/`ULTIMO_NUMERO`) -> 7 ítems `[?]` por obsolescencia tras migrar a Godot 4.x (`9027ded`). **HALLAZGO 2: por qué estaba en 0** -> `41ff104` (revert MASIVO en bloque de 41.716 `[x]`, autor el usuario, regla "[x] = código + testing, no solo documentación") barrió las 135 marcas que M03 tenía en `9027ded`. **Tensión de política reportada:** AGENTS 21.6 (DoD) vs módulo documental puro; hermanos M01 0/152 · M02 0/172 · M03 0/133 vs M06 99/100. **NO toqué `CHECKLIST-GLOBAL.md`** (fila M03 a actualizar por el director) **ni el README global** (2 etiquetas stale, reportadas). **NO sella 21.8.** | M03 117/133 (no sella) |
| 36 | (transversal) BUG-093 / T-D3 — 3 suites re-corridas | 3/3 verdes | 1288 | **Frente del director (mensaje 20).** Re-corridas las 3 suites bloqueadas por dependencias tras los fixes de agnes (BUG-095 `821f8f4`, BUG-097 `1f2c0be`): `test_inventory_economy` **52/0** · `test_stable_flows` **32/0** · `test_item_data` **149/0**, los 3 EXIT 0 y **0 SCRIPT ERROR**. `CHECKS_MINIMOS` fijado a la MEDICIÓN (52/32/149; antes 0 en las 3 = guardia inerte). **BUG-101 (bug REAL de producto, dormido):** `item_database.gd` (M159) guardaba `_by_category`/`_by_rarity`/`_by_fuente` con `Array` SIN TIPAR mientras los getters declaran `-> Array[ItemData]` -> en Godot 4.7 la conversión implícita falla en runtime (`Trying to assign an array of type "Array" to a variable of type "Array[ItemData]"`) y `get_items_by_category/rarity/source` devolvían **SIEMPRE vacío** desde el commit inicial `4234bca`. **Medido:** `_by_category[5]`=10 items pero `get_items_by_category(COCINA)`=**0** pre-fix / **10** post-fix; `get_items_by_rarity(COMUN)`=0/78. **0 consumidores en producción** (único llamador: el test) -> bug real pero dormido. Fix = CODIGO (no debilitar el test). **3 defectos de TEST en `test_stable_flows`:** (1) bloque J llamaba `pausar()` inexistente (API real `pausa()`); (2) `_calendar` sin `_ready()` -> `_config` null; (3) ids `madera`/`piedra`/`comida` inexistentes en el catálogo M15 -> `deserializar` los descarta; fix a `wood`/`stone`/`clay` (stack_max 99 = behavior-preserving). Nodos de prueba ahora entran al árbol (`root.add_child`) -> **ruido `ERROR: Can't use get_node()...` de ~20+ a 0**. Honestidad: bloque J no tenía aserciones (0 checks) -> 3 reales sobre pausa/resume; bloque K -> roundtrip real. **Verificación global:** colector **0** SCRIPT ERROR (con **sonda ROJO por inyección** = 1/EXIT 1 -> no es falso verde) + full load **0**. **Reportado (no mío):** gap de datos M15 (catálogo sin `madera`/`piedra`/`comida`/`madera_roble`/`piedra_caliza`; parte de la auditoría M39↔M15 de atria-dawn). **NO toqué `CHECKLIST-GLOBAL.md`, `quality.yml` ni checklists ajenos. NO sella 21.8.** | 3/3 verdes · BUG-101 [x] |
| 37 | M120-DLC-Y-Expansiones (T-D5) | 6/222 -> 163/222 (auditado) | 1291 | **Frente del director (mensaje 24).** Auditoría contra disco de M120 (método M03). **Conteo real de marcas: 163 [x] / 59 [ ] / 0 [?] = 222 → COINCIDE con el GLOBAL (163/222). NO hay falso cero:** el "6/222" era una fila STALE de mi propio BACKLOG (curación 2026-09-11), no el GLOBAL. El único drift es de ESTADO: `🟢 Disponible` con 163 [x] (alerta E3 de `verificar_checklist.py`) → corresponde `🟡 Con dudas`. **Huella técnica real:** `scripts/dlc/dlc_manager.gd` (autoload, `project.godot:118`) + `data/dlc/{dlc_manifest,bundles}.json` + `scripts/dlc/sincronizar_dlc.gd` + 2 tests. **3 servicios diseñados NO implementados** (04-Codigo.md §2/§5-7): `dlc_compatibility_checker.gd`, `dlc_uninstaller.gd`, `dlc_bundle_manager.gd` (funciones parcialmente absorbidas en DlcManager). NO son sobre-marcas (los ítems dicen "Diseñar ..." = diseño documentado; su implementación figura pendiente en §9). **BUG-102 (bug real, dormido) resuelto:** (a) `es_compatible()` comparaba versiones como STRINGS (`"1.10.0" >= "1.9.0"` = **false**) → `comparar_versiones()` semántica (`_parsear_version`, tolera "1.2"=="1.2.0" y sufijos); (b) `_activos` NO se persistía → DlcManager ahora es ISaveProvider (sección "dlc"): persiste DLCs activos + versión base y reconcilia DLCs ausentes (`dlcs_faltantes`). **Test nuevo `tests/unit/dlc/test_dlc_manager.gd` 39/0 EXIT 0** (12 bloques, piso `CHECKS_MINIMOS=39` MEDIDO); legacy `test_dlc_m120.gd` 16/0 EXIT 0; colector **920 preloads / 0 SCRIPT ERROR**; full load **0**. **HALLAZGO:** la fila 120 del GLOBAL cita `🔵 Verificado por Hy3/WorkBuddy (Log 866, §21.8)` → **Log 866 = log FRAUDULENTO** (reemplazado por Hy3, `ad6b370`) → sello §21.8 INVÁLIDO, a remover por el director. **NO toqué `CHECKLIST-GLOBAL.md`** (texto exacto de la fila sugerida entregado al director). **NO sella 21.8.** | M120 163/222 · BUG-102 [x] |

**Regla del ciclo:** bloquear el módulo (reserva en `Logs/reservas/` + `🔵` en el checklist) → leer la documentación → codificar → test headless → documentar (04-Codigo, 05-Checklist, CHECKLIST-GLOBAL, ESTADO-PARALELO) → escribir el log → borrar la reserva → **siguiente módulo**.

> ⚠️ **Numeración de logs — resincronizar SIEMPRE.** En el ciclo 5 reservé el **830** y GLM-5.3 lo usó en paralelo para M32; hubo que pasar a **831**. Antes de crear un log: `ls Logs/*.md | grep -oE '^[0-9]+' | sort -n | tail` **y** revisar `Logs/reservas/`, porque `ULTIMO_NUMERO.txt` puede quedar desfasado.

**Estado de la cola inmediata (30 tareas):** cerradas las de **M60** (T-018, T-019→`[?]`, T-145→`[?]`), **M68** (T-017, T-002, T-003, T-020, T-049), **M27** (T-001, T-003, T-004, T-005, T-021…T-040, T-121, T-123, T-124, T-171, T-175, T-180, T-183, T-186) **M87** (T-044, T-050, T-051, T-058, T-107, T-108, T-115, T-117 + verificación de T-042/T-123/T-124) y **M116** (T-002 instalador, T-070 firma, T-078 detección de versión + verificación de T-014 rollback; Log 877), **M101** (QA cruzado §21.8, Log 878) y **M148** (T-009 gate de CI, T-090 migración de saves, T-109 tests de persistencia; Log 881) y **M52** (T-027 pooling, T-029 precalentamiento, T-034/T-036 determinismo, T-067/T-072 límites y verificación de presupuesto, T-033 log VFX-SKIP, T-086/T-088/T-089 alternativas descartadas; Log 882) y **M26** (T-053 guardado atómico por checkpoint, T-084 suite de softlocks, gating de 7 anillos + sellos, validadores anti-exploit/voxel/accesibilidad/orientación/checkpoints, telemetría de puzzles; Log 902). y **M124** (límites RF13, sanitización 4K→2K + sin coords del save, telemetría sin PII; Log 905). y **M68 iter. 2** (planificador de viaje, viajes especiales/narrativos, eventos de ruta, puente M69, localización 12h/24h y validador unificado; Log 910). **M87 iter. 6 CERRADO (A3, Log 920): 129/136 · 7 `[?]` · 0 `[ ]`** — los 16 `[ ]` propios resueltos por medición (ver el historial, ciclo 18). Los 7 `[?]` tienen dueño externo (M53 ×4, M29/M30, M14-M39, revisión humana) → **no queda trabajo propio en M87**. **Siguiente en la cola: re-verificar M105 (157/163) o tomar otro módulo de la familia DeepSeek con encaje A**. M27 queda **cerrado en su parte propia (99/192, 0 `[ ]`)** y M68 liberado con 47 `[ ]` que son de otros módulos (puertos M17/M40, mapa M54, señalización M46, panel M53, animaciones M48/M64, rendimiento M61, accesibilidad M58) → no es buen candidato propio. **M60 (A1) re-verificado y re-marcado selectivamente (Log 916): 188/196 · 4 `[?]` · 4 `[ ]`** — la reversión total de la auditoría del 2026-09-14 quedó reparada con evidencia **ejecutable** (378 checks ×3, 0 `SCRIPT ERROR`), no por inspección. Los 4 `[ ]` que quedan son M08/Voxel Tools (115, 117, 122) y reúso de buffer (168); los 4 `[?]` tienen dueño externo (131→M53/M59, 133→M63, 145→M16/M33, 172→Profiler/GUI). (0/196, fila `🟢 Disponible`): se revirtieron también los `[x]` de mis iter. 2/iter. 3 que **sí** tenían test headless (Log 825) — hay que re-verificar y re-marcar selectivamente lo realmente implementado, no dejarlo en 0. M26 iter. 3 y M148 contenido quedan abiertos pero dependen de contenido/diseño.**

> **M103 Logging (reclamo §21.4.7, iter. 1, Log 918):** cerrado en su parte propia → **167/179 · 12 `[?]` · 0 `[ ]`**. Los 12 `[?]` tienen dueño externo (M53/M110 consola in-game, búsqueda de texto y coloreado; M61 frame budget; M122 crash pre-crash; M102 `bug_{timestamp}.log`) o son decisiones de diseño explícitas (buffer de escritura retirado por código muerto). **Módulo reclamado por DeepSeek-V4.1-Flash** tras la retirada de ox-alpha (Cline). **Siguiente en la cola propia: M87 iter. 6 completado (Log 920)** — ver el ciclo 18 del historial. ⏳ QA cruzado §21.8 de M103 y de M60 iter. 4 pendientes (verificador ≠ autor).
>
> **M103 Logging iter. 2 (Log 1109, 2026-09-19):** reasignado desde kimi-k3 (que no tocó el plan-actual). **173/179 · 6 `[?]` · 0 `[ ]`**. La auditoría de suites muertas **no encontró ninguna suite muerta**, pero sí **2 defectos reales** (`test_logging_m103.gd` con 11 checks inalcanzables; `test_logger.gd` sin limpiar su export) y **3 suites sin guardián completo**. **La pregunta del frame budget dejó de ser un hueco**: se **midió** (ítem L199 cerrado) y el resultado —**512 µs por llamada que escribe, 99 % consola, 1 % disco**— se escaló como **BUG-067**. Quedan **6 `[?]`, todos externos** (M102/M110/M122). ⏳ QA cruzado §21.8 de la iter. 2 pendiente (verificador ≠ autor).

> **M62 Memoria iter. 4 (Log 1112, 2026-09-20):** **98/150 · 0 `[?]` · 52 `[ ]`**. 5 ítems cerrados, **todos por medición**: carga síncrona en gameplay (L190), pico de liberación por refcount (L191), deltas de frame (RN2), hilo principal (RN6) y huérfanos estables en reposo. **Lo más importante del ciclo no fueron los cierres, sino las dos veces que medir cambió la conclusión:** (1) la hipótesis de partida —referencia a un autoload declarado después ⇒ **null silencioso** desde `_ready()`— resultó **FALSA** al medirla con un banco de pruebas propio; (2) una aserción de la suite («2048 chicos cuestan más en total que 256 grandes») era **una suposición**, y los datos dijeron lo contrario. Y el **selftest del auditor nuevo cazó 4 defectos del propio auditor** antes de que llegara a CI. Se añaden **2 gates** (`architecture-guard` + la suite en `test-suite`) y se escalan **BUG-068** (autoload duplicado: el mismo script en dos entradas ⇒ 2 instancias, medido) y **BUG-069** (2 componentes cíclicas + 9 refs fuera de orden; **deuda arquitectónica, sin fallo de runtime medido**). ⏳ QA cruzado §21.8 de M62 sigue pendiente: el sello previo (Log 895) quedó invalidado en iter. 3 porque se apoyó en una suite muerta.

> **M127 Copyright del Juego iter. 4 (Log 1119, 2026-09-20):** **52 [x] · 25 `[?]` · 24 `[ ]`** (era 51/25/25). Se cierra el unico item `[ ]` que era **tooling** ("automatizar el empaquetado de codigo y muestras visuales segun formatos y limites USCO"), que estaba diferido con la cita *"especificaciones USCO documentadas en `03-Diseno.md §4.2`"* — **y `§4.2` no existia**. La auditoria de la cita destapo **2 citas a secciones inexistentes** (`§2.3` linea 71, `§4.2` linea 137): el mismo defecto que causo la reversion del 2026-09-14 y que la nota de la iter. 2 afirmaba haber corregido. Se escribe `03-Diseno.md §4` con la especificacion **real** (37 CFR 202.20(c)(2)(vii), verificada contra la norma) y se corrigen ambas citas. La **suite nueva encontro 3 defectos propios** antes de llegar a CI: `--json` no era JSON puro; el manifiesto inflaba el paquete al **37,6 %** (violaba la regla 4.4 que el propio script comprueba -> ahora 0,6 % con conteo + SHA-256); y `analizar()` no exponia la `deuda`. ✅ **QA cruzado §21.8 del delta CERRADO** — **Log 1121** (atria-dawn, 2026-09-20, verificador ≠ autor): **aprobado**. Verificado contra los artefactos: conteo **52 [x] / 24 [ ] / 25 [?]** exacto, `--selftest` **45/45**, gate presente en `quality.yml`, y **`03-Diseno.md §4.1/§4.2` existen de verdad** (las 2 citas fantasma reparadas). El sello del Log 1022 cubre la iter. 3.

> **P-36 — M106 Seguridad + M122 Crash Reporting (Logs 1149 y 1150, 2026-09-25):** encargo directo del coordinador (gemini-3.8-flash dado de baja). **Los dos modulos quedan con 0 `[ ]`.** El hallazgo transversal: **la misma trampa (§9.6, `DirAccess.open("user://…")` = `null` en headless) causaba un falso verde en cada modulo** — en M106 el escaner de secrets, en M122 el nucleo del crash reporter. En los dos casos la suite estaba **en ROJO** mientras el checklist afirmaba verde. **Regla que sale de esto:** un `[x]` de un test headless no vale nada hasta haber visto la salida cruda (`0 SCRIPT ERROR` **y** el conteo de checks). **Aviso de metodo:** en M122 el diseno propone 9 archivos en 4 directorios con `class_name`; los 10 helpers quedaron en `scripts/crash/` sin `class_name` (§9.17/§9.41). Documentado en `04-Codigo.md §15`, **no** reescrito: honrar la estructura del diseno es una reescritura de plan y necesita visto bueno del coordinador.

> ⚠️ **La checklist personal se desincroniza.** Tras cerrar una iteración, el `05-Checklist.md` del módulo es la **fuente de verdad**; la personal (`TAREAS-POR-MODELO/<modelo>/<modulo>/checklist.md`) queda atrás. **No regenerarla** con `gen_checklist_personal.py` (borra las notas de evidencia que otros agentes agregaron a cada ítem). Sincronizar **in-place**: parsear los `- [x|?| ]` de ambos en orden (alinean 1:1), cambiar solo los estados que difieren y anexar la nota. En M87 eran 29 ítems.

## Números de log consumidos (protocolo v3)

- [x] Log reservado: **1150** — M122 Crash-Reporting (P-36, 2026-09-25). Medido con `--estado` **justo antes** de reservar: el pool dio **primero=1149** (el pedido decia 1145; 1145–1148 los consumieron hy3/agnes/coordinador concurrentemente). Al cerrar, el pool ya arrancaba en **1154** (1151–1153 de hy3/agnes). `--estado` final: **0 conflictos**.
- [x] Log reservado: **1149** — M106 Seguridad (P-36, 2026-09-25). Misma medicion; los dos numeros se tomaron en la misma sesion con `scripts/reservar_log.py --reservar` (una sola operacion por numero, protocolo v3).

- [x] Log reservado: **1156** — P-42 (M122 diseño alineado + gate `security-scan`, 2026-09-25). Medido con `--estado` **justo antes** de reservar: el pool dio **primero=1156** (el pedido decía 1154; 1154–1155 los consumieron otros agentes concurrentemente). Al cerrar, el pool arranca en **1157**. `--estado` final: **0 conflictos**.

- [x] Log reservado: **1159** — P-45 (auditoría de autoría del merge + cierre de los logs de P-36, 2026-09-25). Medido con `--estado` **justo antes**: primero=**1159** (el encargo decía 1158; 1158 lo consumió s2 en su P-44). Al cerrar, el pool arranca en **1160**. `--estado` final: **0 conflictos**.

- [x] Log reservado: **1163** — P-48 (reclasificación del merge por autoría REAL: buckets B/C/scratch/otros, **429** archivos sucios+untracked, **0 sin resolver**, 2026-09-25). Medido con `--estado` **justo antes** de reservar: primero=**1163** (el encargo decía 1160; 1160/1161/1162 los consumieron otros agentes — 1161 = QA P-43b de mimo, 1162 = P-46 del coordinador — entre el encargo y mi turno). Al cerrar, el pool arranca en **1164**. `--estado` final: **0 conflictos**. **Solo reporte:** no se commiteó ningún archivo de los buckets.

- [x] Log reservado: **1277** — BUG-091 residuo: los 44 SCRIPT ERROR (frente del director, mensaje 18 d, 2026-10-04). Medido con `--estado` **justo antes** de reservar: el pool dio **primero=1277** (1271-1276 los consumieron s2/agnes/Hy3/mimo concurrentemente; mi intento previo de reservar 1271 colisionó con el Log 1271 de s2 = tools/editor, así que re-reservé). Al cerrar, el pool arranca en **1278**. `--estado` final: **0 conflictos**.

- [x] Log reservado: **1283** — T-D4: auditoría de M03 (Documentación del Proyecto) contra disco (frente del director, mensaje 20, 2026-10-04). Medido con `--estado` **justo antes**: primero=**1283** (1278-1282 los consumieron otros agentes). Al cerrar, el pool arranca en **1284**. `--estado` final: **0 conflictos**.

- [x] Log reservado: **1288** — T-D3: las 3 suites de BUG-093 re-corridas y verdes + BUG-101 (frente del director, mensaje 20, 2026-10-04). Medido con `--estado` **justo antes**: primero=**1288** (1284 = Log de agnes BUG-095/097; 1285/1286/1287 los consumieron otros agentes). Al cerrar, el pool arranca en **1289**. `--estado` final: **0 conflictos**.

- [x] Log reservado: **1291** — T-D5: M120-DLC (auditoría contra disco + versionado + compatibilidad de saves, BUG-102) (frente del director, mensaje 24, 2026-10-04). Medido con `--estado` **justo antes**: primero=**1291** (1289 = Log de M151 por otro agente; 1290 consumido también). Al cerrar, el pool arranca en **1292**. `--estado` final: **0 conflictos**.
- [x] Log reservado: **1297** — T-D7 bloque 1: drift de estado M137-M144 + familia de sellos fraudulentos Log 867/857 (frente del director, mensaje 27, 2026-10-05). **Reserva MANUAL** (no con `reservar_log.py`): el script está bloqueado por sandbox para los agentes → leí `Logs/NUMEROS_DISPONIBLES.txt`, tomé la primera línea (**1297**) y la borré del archivo. El pool quedó con cabeza en **1298** (el mensaje 27 decía cabeza 1295; 1295/1296 los consumieron otros agentes entre el encargo y mi turno).
- [x] Log reservado: **1302** — T-D7 bloque 2: drift de estado M04/05/45/104/163/95 + 3ª familia de sellos (Log 856) + aviso de solape con Hy3 (frente del director, mensaje 29, 2026-10-05). **Reserva MANUAL**: el pool estaba en cabeza **1302** (el mensaje 29 decía 1296 — desactualizado; avanzó por otros agentes). Borré la 1ª línea; nuevo head **1303**.

- [x] Log reservado: **1308** — T-D7 bloque 3: drift de estado M19/28/48/67/75/158 + saneo del sello fraudulento Log 856 (frente del director, mensajes 29 y 31, 2026-10-05). **Reserva MANUAL**: leí `Logs/NUMEROS_DISPONIBLES.txt`, tomé la 1ª línea (**1308**) y la borré. El mensaje 31 decía cabeza 1308; al medir justo antes de reservar la cabeza real era **1308**. Nuevo head tras mi reserva: **1309** (el 1309 lo tomó otro agente; cabeza actual al commitear: **1310**).

- [x] Log reservado: **1310** — T-D7-bis bloque 4: saneo sello-only familia Log 856 (M156/37/56/58/73/74) + consulta M62/M63/M65 (frente del director, mensaje 31, 2026-10-05). **Reserva MANUAL**: leí `Logs/NUMEROS_DISPONIBLES.txt`, tomé la 1ª línea (**1310**) y la borré. Cabeza tras mi reserva: **1311**.

- [x] Log reservado: **1311** — T-D7 bloque 5: drift puro de estado M18/20/41/42/47/90/160 (frente del director, mensajes 27/29/31, 2026-10-05). **Reserva MANUAL**: tomé la 1ª línea (**1311**) y la borré. Cabeza tras mi reserva: **1312**.

- [x] Log reservado: **1316** — T-D7-bis bloque 6: sello-only familia Log 857 (50/51/118) + Log 856 (65) + compuesto (62) (frente del director, mensaje 35, 2026-10-05). **Reserva MANUAL**: el mensaje 35 decía cabeza **1313**, pero al medir justo antes estaba en **1316** (otros agentes tomaron 1313/1314/1315). Tomé la 1ª línea (**1316**) y la borré. Cabeza tras mi reserva: **1317**.

- [x] Log reservado: **1317** — T-D7 bloque 7: drift M22/23/24/33/53 (puro) + M76/77 (drift + sello fraudulento Log 867) (frente del director, mensajes 27/35, 2026-10-05). **Reserva MANUAL**: tomé la 1ª línea (**1317**) y la borré. Cabeza tras mi reserva: **1318**. **Drift E3 restante = 0.**

- [x] Log reservado: **1337** — T-D9 (2/4) BUG-069: baseline del auditor + **corte mínimo medido** (el fix del reporte estaba incompleto) + propuesta de alcance a s2 (frente del director, mensaje 1332, 2026-10-05). **Reserva con `reservar_log.py --reservar`**: cabeza justo antes **1337** (el mensaje 1332 decía 1335 — desactualizado). Mensaje a s2 = **1336** (pool). Cabeza tras mi reserva: **1338**. `--estado` final: **2 conflictos AJENOS reportados** (colisión 1290, doble asignador 1502), no corregidos.

- [x] Log reservado: **1344** — M60 T-018: el bloque `BuildingsSaveProvider` **fallaba Y abortaba**; fix del test (fuente inyectada) + **piso de checks medido** (asignado por el director, mensaje 1340, 2026-10-05). **Reserva con `reservar_log.py --reservar`**: cabeza justo antes **1344**. Mensaje al director = **1343** (pool). **Hallazgo lateral**: el pool del worktree tenía **BOM + CRLF** (residuo del restore de agnes) → 1342 invisible; el script lo saltó y consumió 1343, y dejó el pool limpio. Reportado, no tocado. Cabeza tras mis reservas: **1345**.
- [x] Log reservado: **1391** — BUG-069 (M62): **cierre de los ciclos (A1 1 -> 0)**. La ultima arista del SCC `{ThemeService, UIManager}` era **CODIGO MUERTO** (`viewport_resized` no existe en el proyecto -> `has_signal` siempre false; mismo patron que BUG-116); corte minimo medido con el Tarjan del auditor; sonda ROJA 0->1->0 byte-exacta; regresion M62/M59/M14/M53 (11 suites, todas EXIT 0). **A2 = 10 queda ABIERTA** (10 dependencias VIVAS -> inversion de dependencias en >=8 modulos, NO una arista). Fila BUG-069 -> `[->] Parcial`. Reporte al director: canal **59**.

- [x] Log reservado: **1397** — **M59 / BUG-115: fix REAL (parcial)** — opcion 1 del canal 60 §4, autorizada por el usuario ("hacelos todos si tenes la informacion correcta y despues le escribis el informe"). **(2) validate() vacua -> RESUELTO**: valida AMBOS dialectos de `time` (real M29 `hora/minuto/dia/mes/anio/acumulador` + schema `day/season/hour/minute`), sin duplicar el maximo de `dia` (28, de M29) y **sin tocar `game_clock.gd`**. **(3) tipos -> RESUELTO**: `profile_id` String, `meta.last_saved`/`meta.playtime_seconds`, cota `MAX_CLOCK_ACUMULADOR = 3600.0`. **(1) checksum -> PARCIAL**: token `hmac256:<hex>` (HMAC-SHA256, clave por instalacion en `user://clave_integridad.key` — **fuera** de `user://saves`, que las suites borran), retrocompatible con el SHA-256 legado (`parse_document()` expone `legacy: bool`). Sonda nueva `test_checksum_hmac.gd` = **38/0 x3** (piso `CHECKS_MINIMOS = 38` MEDIDO), guardian probado **EN ROJO por 2 inyecciones** (3 y 4 fallos, EXIT 1); regresion **14 suites EXIT 0**; gate nuevo en `quality.yml`. **Fila BUG-115 -> `[->] Parcial`** (limitacion residual: el token legado se acepta -> NO es anti-trampas contra acceso local al FS; declararlo `[x] Resuelto` seria sello inflado). Commits `8125a9f` (fix, 7 archivos) + `ab36e12` (canal 61) **LOCALES, SIN push**. Reporte al director: canal **61**. **M24 (opcion 2) NO arrancada** (Cx 5): pedi confirmacion de alcance.

- [x] Log reservado: **1005** — M52 Partículas-Y-VFX iter. 6 (2026-09-18)
      ⚠️ **Dos números perdidos antes de este, por dos modos de fallo DISTINTOS del protocolo v3:**
      **(1) 1001 — doble asignador.** `Logs/reservas/1001-hy3-M53.txt` (hy3, 03:37) existía cuando
      yo tomé el 1001 de `NUMEROS_DISPONIBLES.txt` (03:38): la herramienta legada y la lista eran
      **dos asignadores independientes**. Cedí el 1001 a hy3 (reclamo más antiguo, respaldado por
      archivo) → **corregido**: `--reservar` ahora **consume del pool** y `--estado` detecta el
      doble asignador (sonda aislada 19/19).
      **(2) 1002 — carrera de lectura-modificación-escritura.** Otro agente ya había escrito y
      **commiteado** `Logs/1002-Avance-modulos-M154-M84-M53_2026-09-17.md` (commit `5f4e003`,
      03:40:14) y **no borró** el 1002 del pool: los dos leímos "primera línea = 1002" a la vez.
      El pool **no puede** prevenir ni detectar esto (yo ya había borrado la línea cuando escribió).
      Cedí el 1002 a su autor (reclamo ya en el historial) y tomé el **1005** con el camino
      **race-safe**: `python scripts/reservar_log.py --reservar`, que consume el pool en una sola
      operación. **Lección:** en v3, reclamá con `--reservar`, no borrando una línea a mano.
      **(3) 1004 — reclamado por glm-5.3-flash (M39), pero era un fantasma:** el pool tenía BOM,
      así que su primera línea (`1004`) era ilegible para el asignador y **nadie podía consumirla**
      (el pool informaba 495 libres teniendo 496 líneas). Ver Log 1006.

- [x] Log reservado: **1006** — Protocolo v3: `reservar_log.py` sin archivos + BOM del pool (2026-09-18)
      Cierra la contradicción de mi propio commit `f4d009c`, que re-añadió `Logs/ULTIMO_NUMERO.txt` y
      `Logs/reservas/1005-…txt` justo después de que `2ac8b4b` los retirara. Retira el mecanismo de
      reserva **por completo**: ya **no hay archivo de reserva ni "paso atómico" con `.txt`** — el
      *claim* es la línea consumida del pool, con la carrera residual documentada en el docstring de
      la herramienta. Arregla además el **BOM** del pool, que ocultaba su primer número y mantenía el
      gate de CI `scripts/verificar_bom.py` en **rojo** (ahora verde). Sonda propia de **26 checks /
      7 bloques** + guardián **probado por inyección**.
      ⚠️ **Aviso de entorno:** durante este trabajo `Logs/` desapareció del árbol de trabajo (967
      archivos, dos veces). Causa: el commit ajeno `b65c30b` borró `Logs/NUMEROS_DISPONIBLES.txt`
      (de ahí el `c8774f8` "borrado accidental"). Se restauró íntegro desde `HEAD`; se perdieron 3
      archivos **no versionados** (temporales `_t39a/_t39b` y la reserva heredada de glm).

      **Gate de CI del protocolo v3 (cierre del hilo):** job **`log-protocol`** (8.º) en
      `quality.yml`, insertado tras `encoding-guard` y sumado a `needs:` de `summary`. 3 pasos:
      (1) sonda `tools/logs/test_reservar_log_pool.py` (7 bloques, 26 checks, piso `CHECKS_MINIMOS=22`);
      (2) **prueba por inyección** `tools/logs/probar_guardian_reservar_log.py` (muta el asignador para
      que vuelva a crear el archivo de reserva y exige que la sonda FALLE; restaura por sha256);
      (3) `--estado` informativo, `continue-on-error`. Validado con PyYAML (9 jobs, sin `needs:` colgantes)
      y los 3 pasos simulados en local (`rc=0`).
      ⚠️ **Trampa 70 volvió a dispararse (2026-09-18 06:10):** el commit ajeno **`fd2a791`**
      ("M160 Ubicaciones", sin lista de rutas) **barrió mis dos archivos ya en el índice** —
      `quality.yml` (44+/2−) y `Log 1006` (32+/−) — dentro de *su* commit. Mi propio commit posterior
      (`ead629a`) tomó del **árbol** y por eso arrastró **15+/3− ajenos** (normalización de acentos
      `catalogo`→`catálogo` de agnes-3). **Deshecho con `git reset --mixed fd2a791`**: `ead629a`
      eliminado, los bytes ajenos devueltos a *unstaged*, mi gate intacto en `fd2a791`. **Lección
      reforzada:** en worktree compartido, `git commit` con lista explícita **no basta** si un tercero
      commitea el índice antes — el lote se cierra **en el mismo instante** en que se stagea.

- [x] Log reservado: **1011** — M60 iter. 5: evaluación del ítem 168 (reutilización de dicts/buffers) (2026-09-18)
      **Resultado: la optimización pedida se EVALUÓ y resultó CONTRAPRODUCENTE. NO se implementó; el
      código de producción quedó SIN CAMBIOS** (`serializador.gd` byte a byte igual a HEAD).
      Arnés propio `test_datos_m60_iter5.gd` (5 bloques, **40 checks ×3**, 0 fallos, 0 `SCRIPT ERROR`):
      las 3 variantes del encoder binario y las 2 de `a_plano` dan salida **idéntica** (oráculo
      independiente escrito a mano + equivalencia entre variantes + round-trip + **sin aliasing**),
      pero la reutilización es **1,08-1,15× MÁS LENTA** (suma de los mismos 3 casos: 410-459 ms
      producción vs 472-499 ms reutilización; mínimo de 5 rondas intercaladas, ×3 corridas).
      Causa medida: `PackedByteArray.resize()` **ya crece amortizado** (los ~6 `resize()` por chunk no
      eran el coste) y el reuso de dicts añade `keys()`/`erase()`/`get()`. BULK
      (`to_byte_array()`) **tampoco es fiable**: gana en una corrida y pierde en otra.
      ⚠️ **Trampa metodológica nueva (importante):** la 1ª versión del arnés medía cada variante **una
      sola vez y en orden fijo** → el warm-up castigaba a la primera e **invirtió el veredicto**
      (llegó a dar la reutilización como **1,4× más rápida**). Con rondas intercaladas + mínimo el
      resultado se dio vuelta y quedó estable. **Un benchmark de una sola pasada y orden fijo no
      prueba nada.** Casi reporto una conclusión falsa.
      Regresión: base **94/0** · iter3 **132/0** · iter4 **152/0**, los tres con 0 `SCRIPT ERROR`.
      **M60 queda 189/196 · 3 `[ ]` (las 3 de M08) · 4 `[?]`** → **sin trabajo propio pendiente**.

- [x] Log reservado: **1011** — M60 iter. 5 (ver arriba).
      ⚠️ **COLISIÓN 1011 detectada (2026-09-18, `--estado`):** mi log
      `1011-M60-Iter5-Evaluacion-Item168-Reutilizacion_2026-09-18_06-29-53.md` (**VERSIONADO**;
      consumido del pool a las 06:29) choca con el archivo **ajeno NO versionado**
      `1011-M128-Identidad-De-Marca-Iter-agnes-data-layer-CI_2026-09-18_09-06.md` (mtime 06:32).
      **Causa raíz:** la **carrera de lectura-modificación-escritura** ya documentada en el Log 1006:
      dos agentes leyeron «primera línea = 1011» a la vez y **ambos la consumieron**. **No es culpa
      de nadie**; agnes-3-flash lo deja escrito en `ESTADO-PARALELO.md` («tomé 1011 del pool
      (línea 1) y lo consumí»). **Resolución por regla:** renumera el que llegó **después** → el
      archivo de agnes (mtime 06:32 > mi consumo 06:29; mi log ya está commiteado). **No toqué el
      archivo ajeno** (sin versionar): la decisión es de su dueño. `--estado` seguirá reportando la
      colisión hasta que se renumere.
      Aparte, el mismo `--estado` reporta una **reserva heredada ajena** en `Logs/reservas/`
      —mecanismo **RETIRADO** en `2ac8b4b`—: `1013-atria-dawn-M14-QA.txt`, a borrar por su dueño
      con `--liberar 1013`.

- [x] Log reservado: **1024** — BUG-042: fuentes reales + gate de bytes mágicos (2026-09-19)
      Al reservar: **478 libres** (`primero=1023`). Al cerrar: **407 libres (`primero=1094`), sin
      conflictos de numeración** — otros agentes consumieron números en paralelo entre la reserva y
      el cierre.
      La **colisión ajena 1013** (M128 de agnes vs M14 de atria-dawn) y las **2 reservas heredadas**
      del mecanismo retirado en `2ac8b4b` (`1017-glm-5.3-flash-M39.txt`, `1022-atria-dawn-M127-QA.txt`)
      que `--estado` reportaba al empezar **ya no aparecen**: las resolvieron sus dueños. **No toqué
      ninguna de las tres.**
      ⚠️ `Mensajes entre modelos/ESTADO-PARALELO.md` **no se commiteó**: el worktree acumulaba
      **845 líneas sin commitear de 9 agentes** (mimo, Hy3, agnes-3-flash, atria-dawn, kimi, Hy4,
      nex-n2.5, glm-5.3-flash). La nota del ciclo quedó anexada al worktree; el registro autoritativo
      y commiteado es `Logs/1024-Bug042-Fuentes-Reales-Gate-Binarios_2026-09-19_21-54-56.md` +
      `DOCUMENTACION/11-BUGS.md`.

- [x] Log reservado: **1094** — M62 Memoria iter. 3: 5 defectos reales + suite muerta + gate de CI (2026-09-19)
      Al reservar: **primero=1094**. Al cerrar: ver `--estado` abajo. **No toque ninguna colision ajena.**
      Cierra 34 items del checklist de M62 (59/150 -> 93/150). Hallazgo principal: **una suite entera
      (`test_enforcement_m62.gd`) estaba muerta y reportaba verde**, lo que **invalida el sello §21.8
      previo (Log 895)** — M62 necesita QA cruzado nuevo.
      ⚠️ `CHECKLIST-GLOBAL.md` y `Mensajes entre modelos/ESTADO-PARALELO.md` **NO se commitearon**: el
      worktree acumulaba cambios ajenos sin commitear (94 filas en el global —una reescritura con
      mojibake distinto a HEAD— y 1050 lineas en el paralelo de 9+ agentes). Mis entradas quedaron
      anexadas en el worktree; el registro **autoritativo y commiteado** es
      `Logs/1094-M62-Memoria-Iter3-Semaforo-Enforcement-Suite-Muerta_2026-09-19.md`.
      **Tampoco toque** el byte **NUL** pre-existente en `CHECKLIST-GLOBAL.md` (offset 165941, ya estaba
      en HEAD): es lo que hace que git lo trate como **binario** y sus diffs sean invisibles.

- [x] Log reservado: **1109** — M103 Logging iter. 2: auditoría de suites + endurecimiento + medición del frame budget (2026-09-19)
      Al reservar: **primero=1109** (consumido del pool). Al cerrar: ver `--estado` abajo.
      **6 `[?]` cerrados con evidencia** (167/179 -> 173/179): T-093/T-094/T-165 (buffer+flush, **medidos**
      innecesarios — el cuello es la consola, no el disco), T-135 (timestamp absoluto por decisión),
      T-142 (**frame budget MEDIDO**: 1,110 µs filtrada / 512 µs escribiendo), T-178 (regresión **6/6**).
      Los 6 restantes siguen con dueño externo (M102/M110/M122) y **no se cierran por si acaso**.
      Hallazgo de rendimiento escalado como **BUG-067**; **no se parchea `logger.gd`** (rompería el
      crash-proof que necesitan el QA por logs y el volcado pre-crash de M122).
      ⚠️ Igual que en 1094: `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md` **NO se commitearon** (worktree
      con cambios ajenos); mis entradas quedaron anexadas en el worktree y el registro **autoritativo**
      es `Logs/1109-M103-Logging-Iter2-Auditoria-Suites-Endurecimiento-Frame-Budget_2026-09-19.md`.

- [x] Log reservado: **1112** — M62 Memoria iter. 4: gates estáticos de arquitectura + presupuesto de liberación (2026-09-20)
      Al reservar: **primero=1112** (consumido del pool). Al cerrar: ver `--estado` abajo.
      **5 `[x]` cerrados con medición** (93/150 -> 98/150): L190 carga síncrona en gameplay (0 hallazgos
      en 800 archivos y 79 callbacks por frame), L191 pico de liberación **0,279-0,492 ms** contra 3 ms,
      RN2 lote **2,1-5,8 ms** contra 50 ms, RN6 por debajo de un frame de 16,67 ms, huérfanos estables
      (0 → 128 → 0). Suite `test_m62_liberacion.gd`: **15 checks, 0 fallos, ×5 idénticas**, guardián
      probado por inyección (1 check, 2 fallos, exit 1, sin colgarse).
      **El ítem de ciclos NO se cerró** (los ciclos existen): queda documentado y escalado como BUG-069.
      **2 bugs nuevos:** BUG-068 (autoload duplicado: mismo script en dos entradas ⇒ 2 instancias,
      medido) y BUG-069 (2 componentes cíclicas + 9 refs fuera de orden; deuda arquitectónica).
      ⚠️ Igual que en 1094/1109: `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md` **NO se commitearon**
      (worktree con cambios ajenos — en `CHECKLIST-GLOBAL.md` la fila 62 ya estaba reescrita por
      atria-dawn con la reasignación, así que commitear desde HEAD habría revertido su trabajo);
      mis entradas quedaron anexadas en el worktree y el registro **autoritativo** es
      `Logs/1112-*.md`. `11-BUGS.md` y `quality.yml` **sí se commitearon**, construyendo el blob como
      `HEAD` + solo mis líneas (ambos tenían hunks ajenos en el worktree).
- [x] Log reservado: **1119** — M127 Copyright iter. 4: empaquetado del deposito USCO
      (37 CFR 202.20(c)(2)(vii)) + reparacion de 2 citas a secciones inexistentes.
      **Medido:** 891 fuentes -> 122 468 lineas -> 2 450 paginas -> recorte 1..25 + aviso (1109) +
      2426..2450 = **51 unidades**. Suite **38/38**, `--selftest` **45/45**, y el gate probado
      **EN ROJO**: violacion nueva -> exit 1, alcance vacio -> **DETECTOR CIEGO -> exit 3**.
      Commit **`8048b96`** (10 archivos, +1437/-2). Detalle: `Logs/1119-*.md`.
      ⚠️ Igual que en 1094/1109/1112: `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md` **NO se
      commitearon** (worktree con cambios ajenos); `quality.yml` **si**, con blob = `HEAD` + solo
      mis lineas (el worktree traia 2 hunks ajenos sin commitear).
      ⚠️ **Dos hallazgos cruzados reportados, no arreglados:** (1) el worktree de `quality.yml`
      habia quedado **sin mi gate `architecture-guard`** por la tecnica de bytes del Log 1112
      (un `git add` ajeno lo habria borrado en silencio) — **reparado de forma aditiva**;
      (2) **colision de numero `BUG-068`** (mia commiteada vs. atria-dawn sin commitear) —
      reportada en `ESTADO-PARALELO.md`, entrada ajena **no tocada**.
- [x] Log reservado: **—** (sin log nuevo) — cierre del §21.8 de M127 iter. 4 + **BUG-071** documentado.
      **§21.8 SELLADO por atria-dawn (Log 1121): aprobado** — conteo 52/24/25 exacto, `--selftest` 45/45,
      gate presente, `§4.1/§4.2` reales. **BUG-071** (commit `ed39d5b`, 1 archivo, **+47/-0**): el fix de
      BUG-051 **no esta en el repositorio** (HEAD conserva el no-op; `tools/quality/gen_colector_sintaxis.py`
      sin versionar, oculto por `gen_*.py`). **Documentado y NO arreglado** (dueno atria-dawn, fix de 1 linea).
      El verificador lo confirmo de forma independiente: *"no es 'un archivo sin versionar': BUG-051 esta
      cerrado sin artefacto versionado"*. **El numero `BUG-072` queda reservado para hy3/M118** (verificado
      libre en HEAD y worktree).
      ⚠️ **Hallazgos AJENOS de la auditoria del sello** (reportados en `ESTADO-PARALELO.md`, **no tocados**;
      `CHECKLIST-GLOBAL.md` y `11-BUGS.md` tenian mtime 02:48, otro agente escribiendo):
      (1) **`CHECKLIST-GLOBAL.md` tiene un byte NUL** (linea 194) donde deberia ir un digito, **pre-existente**
      (HEAD tambien lo tiene) y **sin gate que lo detecte**; (2) **`CHECKLIST-QA-SEALS.md` esta 2 sellos
      atrasado** para M127 (su fila 59 sigue con el veredicto del Log 950); (3) `verificar_checklist.py`
      reporta **2 claims de cierre falso** — **118-CI-CD** dice 106/106 y tiene **102/106**, **39-Tiendas**
      dice 127/181 y tiene **162/181** — mas 3 locks colgados (M122/M166/M39); y (4) la **fila 127 de
      `CHECKLIST-GLOBAL.md` no registra el sello** (su columna `Estado` sigue en `iter. 3`).

- [x] Log reservado: **1130** — M11 Personaje-Del-Jugador (P-14): reconciliacion del "drift"
      + auditoria de la suite + P-13 (exit 3 y cableado al CI) + BUG-078 (el CI ejecutaba 8 scripts
      no versionados). (2026-09-20)
      Al reservar: **primero=1130** (consumido del pool). Al cerrar: ver `--estado` abajo.
      **El "drift interno" NO existia:** 55/2/78 y 50/0/73 eran **conteos por substring**
      (`grep -o '\[x\]'` cuenta la leyenda y la prosa, no los items de checklist). Conteo real
      medido: **123 items = 53 [x] / 0 [ ] / 70 [?]**; fila 11 de `CHECKLIST-GLOBAL.md` ->
      `🟡 Con dudas (Log 1130 ✅)` `53/123` (commit `d609b7e`, blob por `--cacheinfo` `79648af…`,
      numstat **1/1**).
      **Decision de alcance (mia):** NO reescribir B-F como spec — convertiria 68 `[?]` en
      "entregados" cambiando el texto, no el hecho (misma trampa que un test que consagra el bug).
      En su lugar, **6 bloqueos con dueno** en la **seccion L** nueva. Correcciones al checklist:
      encabezados D/E/F/H 12/12/10/10 -> **14/14/12/11**, F.110/F.111 y D.72 `[?]`->`[x]`
      (`IInteractable` **si** existe), D.68/C.60 reescritos (rango real **2,5 m** y
      `inyectar_jugador()` nunca llamado), item huerfano movido a H, `**Totales:** 123 · 53 · 0 · 70`.
      `04-Codigo.md`: tabla "no existe en `scripts/player/` != no existe" + aviso del `--quit` +
      **seccion 8**. Creados `06-Plan-Testings.md` (3 569 B) y `07-Resultados-Testings.md` (3 372 B),
      que **no existian**.
      **Cross-check M12/M13/M14:** cero ocurrencias de eventos de la §3 de M11 -> **ninguno espera
      un evento no publicado** (M12 usa `get_camera_forward_xz` en `player.gd:385-387`, M13 la hotbar).
      **Suite `test_player_m11.gd` (estaba UNTRACKED = BUG-078):** reproducido **30/0 x3**; guardian
      probado **EN ROJO** (aborto al inicio de un helper -> `[FALLO] Bloque faltante: C`, **26 checks**);
      cuelgue medido (**EXIT 124 a 60 s**); falso verde con `--quit` (**EXIT 0 SIN resumen**); tras el
      fix **EXIT 1 en 4,6 s** con veredicto. Endurecida en `5ce3aa9` (278 lineas, LF, sin BOM):
      `CHECKS_MINIMOS := 30` **medido en verde**, `_terminado` + `_resumen_seguro()` +
      `call_deferred` en `_init()`, muertos eliminados (`_error_en_curso`, `_process`, y el no-op
      `_esperar_autoloads()` llamado **sin `await`** en 5 sitios), **B6-B9 `[INVERTIBLE]`** (asertan la
      AUSENCIA de FSM/stamina/nado/sprint: si alguien los implementa, el test va rojo por hacer lo
      correcto). **Resultado negativo reportado:** la sonda de la trampa 63 (helper anidado) **no
      reproduce** aca (30/0 sin cambios) — no se inflo.
      **P-13 verificado por atria-dawn (Log 1131):** exit 3 en los 3 casos inyectados, exit 1 con el
      archivo real (85 alertas); el cableado al CI sirve. **No re-verifique mi propio trabajo.**
      **BUG-078 (Nuevo, Critico):** de **68 citas `--script`** en 6 workflows, **9 sin versionar** =
      1 legitima (generada en CI) + **8 reales** (M11, 5xM64, M116, M117). **Efecto medido:**
      `godot --headless --script <inexistente>` -> **EXIT 1**, y el primer faltante **oculta** los
      otros 7. **Origen:** `0fb0141` (2026-09-17) y **`11ac4d9` (2026-09-20 02:50) — el commit que
      arreglo BUG-051**. **Tercera** ocurrencia de la trampa 98 (BUG-051, BUG-071, BUG-078):
      `ls` no la detecta, `git cat-file -e HEAD:<ruta>` si. Arreglado para M11 (`5ce3aa9`);
      **gate** agregado para el resto en `scripts/validar_workflows.py` (~240 -> **407 lineas**,
      17 545 B, LF, sin BOM): regla 5 (toda cita `--script` debe estar versionada; `None` = no se
      puede saber -> **no se marca**), `CITAS_PERMITIDAS` con motivo, `DEUDA_CONOCIDA` (7 entradas
      ajenas) como `~ AVISO` y **una deuda ya resuelta se reporta como problema** (para que la lista
      no se pudra), `_scripts_citados()` recorre `jobs.*.steps[*].run`, 2 fixtures nuevos,
      **selftest 6/6**, corrida real 6 workflows validos + 7 avisos **EXIT 0**, y `main()` sale **3**
      (detector ciego) si git no esta disponible. Commit `ad449cd` (+76 lineas).
      **BUG-076/BUG-077 registrados** (`b21618d`): 21 `|| true` + 2 jobs infalsables en `summary.needs`
      (**dueno M83/M111 — NO TOCADO**, por instruccion del coordinador) y el `quality.yml` **YAML
      invalido** que dejo el CI apagado ~3 h.
      ⚠️ **Aviso del coordinador sobre "211 CRLF + 10 LF" — premisa VENCIDA:** otro agente convirtio
      `CHECKLIST-GLOBAL.md` a **LF puro** (0 CRLF / 231 LF) y le dejo **1 NUL** (offset 151 495,
      pre-existente en HEAD). Use igual la tecnica pedida (`newline=''` + `'wb'` + `--cacheinfo`):
      **0 CR introducidos**, numstat 1/1.
      ⚠️ `CHECKLIST-GLOBAL.md` y `Mensajes entre modelos/ESTADO-PARALELO.md` **NO se commitearon**
      (worktree con trabajo ajeno sin commitear: el paralelo crecio 96 641 -> 218 635 B con 9+ agentes).
      Mi entrada quedo anexada al worktree **con CRLF** (ese archivo es CRLF, a diferencia de HEAD);
      el registro **autoritativo y commiteado** es `Logs/1130-*.md`.
      **Hallazgos ajenos reportados, NO tocados:** (1) **2 bytes NUL** en `ESTADO-PARALELO.md`
      (offsets 205 296 y 205 710, ~lineas 2505/2511) donde deberia ir un backtick, en la entrada de
      over-marks de M118: `` (`03-Diseno.md) `` -> `` (<NUL>03-Diseno.md) ``; (2) la **fila 11 de
      `CHECKLIST-GLOBAL.md` tiene 10 celdas vs 11 del encabezado** (falta `Complejidad`).
      **Commits:** `f1142e6`, `61cd31c`, `8f7d90f`, `b21618d`, `5ce3aa9`, `d609b7e`, `4c56603`, `ad449cd`.


---

## ACTUALIZACION 2026-09-20 — nuevas asignaciones (curado por atria-dawn, Log 1091/1092)

> Anadido sobre tu backlog existente — **no se piso tu historial**. Estas tareas son
> **extraidas de los `05-Checklist.md` reales** (no inventadas). Trabajalas despues de
> tus tareas pendientes actuales, o en paralelo si prefieres.

### 62-Memoria (37 pendientes) - refrescado 2026-10-09 (Log 1527; modulo 113 [x] / 0 [?] / 37 [ ] = 150)

> **Sincronizacion in-place (2026-09-20):** 5 marcas de la iter. 4 estaban `[ ]` aca y `[x]`
> en el `05-Checklist.md` del modulo (fuente de verdad). Corregidas con la nota de evidencia
> del modulo. Auditoria por texto (exacto + difuso Jaccard >= 0,60): **0 desfases extra**.
> Conteo medido: modulo **150 items / 98 `[x]` / 0 `[?]` / 52 `[ ]`**.
>
> **Refresco 2026-10-09 (Log 1527, encargo del director canal 117):** 15 items de esta seccion
> seguian `[ ]` y ya estaban `[x]` en el `05-Checklist.md` del modulo (trabajo posterior de agnes,
> Log 1387). Emparejados por TEXTO (normalizado exacto + difusa Jaccard >= 0,60): **15 flips, 0 sin
> match, 0 desfases extra**. Conteo medido hoy: modulo **113 [x] / 0 [?] / 37 [ ] = 150** (cuadra con
> `52 - 15 = 37`). Sin este refresco, trabajar desde esta seccion repetiria trabajo ya hecho.

> **34 de los 91 items cerrados** en la iter. 3, cada uno respaldado por un test o por el generador
> validante. Checklist del modulo: **59/150 -> 93/150**. Lo mas importante de este ciclo **no** fueron
> los items cerrados, sino lo que aparecio al correr las suites: ver `Logs/1094-*.md`.
>
> - **5 defectos reales** en el monitor: el semaforo comparaba contra el consumo *reportado* (0 si
>   nadie reporta) en vez del *presupuesto* -> quedaba mudo, y por lo mismo el enforcement **nunca
>   corria**; `_process` muestreaba por frame con `append()`+`pop_front` (alloc por frame, prohibido);
>   el drift se medía sobre ~10 s y `drift_check()` no existia; faltaba el pico por punto de interes.
> - **6.o, de datos:** `budgets.json` divergia del diseno §2 en los 8 sistemas de los 3 presets
>   (1664/2112/2560 vs 1500/2000/2500) **y `test_memoria_m62.gd` asertaba el valor divergente**.
> - **HALLAZGO GRAVE:** `test_enforcement_m62.gd` estaba **MUERTA Y DABA VERDE** (una asignacion
>   tipada `RefCounted -> Node` abortaba 2 de sus 3 funciones; la tercera usaba `_check(true, ...)`
>   infalsificable). Reescrita.
> - **FE DE ERRATAS (mismo dia):** este hallazgo se cito primero como «Log 856». **856 es `Logs/856-AGNES-M54-AVANCE-RESUMEN_2026-09-12.md`** (M54, agnes). El QA de M62 vive en **`Logs/895-HY3-LOTED.md`**, un archivo que **se autotitula «Log 856»** en su encabezado (linea 1) — su fila M62 dice literalmente «test_enforcement_m62.gd + test_memoria_m62.gd + test_pool_iter2.gd | 0 fallos (EXIT 0)». Corregido en Log 1094.
> - **El sello §21.8 previo (Log 895, Hy3) queda INVALIDADO:** se apoyo en «0 fallos (EXIT 0)» de esa
>   suite muerta. **M62 necesita §21.8 nuevo.**
> - **Suites: 232 checks, 0 fallos, x3 identicas** (27 + 47 + 25 + 133), guardian de 3 capas probado
>   **por inyeccion en las 4**. **Gate de CI agregado** (`quality.yml`): M62 no tenia ninguno.
>
> Los 57 items que siguen son, en su mayoria, **Play Mode / baselines / integracion con M08-M63**:
> requieren mundo real, hardware objetivo o que otros modulos reporten consumo.

- [x] Definir el problema: memoria creciente por chunks, señales, texturas y audio sin descarga en mundo voxel cozy
- [x] Registrar dependencias: M61 (rendimiento), M08 (voxel), M63 (streaming); relaciones M41-M44, M12, M90, M103, M110
- [x] Definir el objetivo: RAM predecible y estable, sin leaks y sin picos de frame en hardware medio/bajo
- [x] Muestreo periódico: cada 5 s en calma y cada 1 s con movimiento de cámara
- [x] Lectura de `Performance.PERFORMANCE_OBJECT_COUNT` para conteo de objetos vivos
- [x] Lectura de `Performance.PERFORMANCE_ORPHAN_NODE_COUNT` para nodos huérfanos
- [x] Detección de drift: comparación contra baseline estabilizada a los 5 minutos
- [x] Registro del pico de memoria por sesión y por punto de interés (spawn, teleport, escena)
- [x] Presupuesto texturas/atlas: 400 MB en preset Alta
- [x] Presupuesto audio (M41-M44): 250 MB en preset Alta
- [x] Presupuesto escenas/NPCs/objetos: 350 MB en preset Alta
- [x] Presupuesto UI y fuentes: 100 MB en preset Alta
- [x] Presupuesto shaders/materiales: 100 MB en preset Alta
- [x] Presets por calidad M90: Baja 1.5 GB, Media 2.0 GB, Alta 2.5 GB
- [x] Familia `particula`: efectos de clima, herramientas y esporas de luz (M11/M32)
- [x] Familia `objeto_recogible`: objetos lanzados o dropeados (M15)
- [x] Familia `texto_efimero`: textos flotantes y notificaciones UI (M53)
- [x] Familia `npc_temporal`: NPCs de visita o eventos con reinicio de estado limpio
- [x] Precalentamiento al arrancar y en pantalla de carga (M63), nunca en mitad de gameplay
- [x] Ítems devueltos: invisibles, quietos, sin señales activas y sin referencias externas
- [x] Regla: prohibido conectar señales a lambdas que capturen nodos externos sin limpieza
- [x] Patrón de desconexión central en `_exit_tree()` documentado para todos los módulos
- [x] Timers cancelados en `_exit_tree()` de cada nodo que los posea
- [x] Tweens cancelados en `_exit_tree()` (evita callables repetitivos que retienen)
- [x] Prohibido crear Node sin padre que quede huérfano; chequeo con contador de orphans
- [x] Policy de recursos compartidos: `duplicate(false)` y caché con un solo dueño (D6)
- [ ] Texturas de región se liberan al salir de la misma (con M63 y M09)
- [x] Los datos de partida (M29) no retienen referencias a nodos del mundo
- [x] Los callables con bound parameters se desconectan en `_exit_tree` (anti-leak de lambdas)
- [ ] Ciclos entre servicios evitados con weakref o getters directos (sin referencias circulares)
- [ ] Sesión de referencia: 30 min de juego sin drift > 5% sobre la línea base
- [x] Test de leaks con teleport ×10 y conteo de objetos antes/después (debe ser igual)
- [ ] RN1: presupuesto de RAM objetivo ≤ 2.5 GB en PCs de gama media (preset Alta)
- [ ] RN1: preset Baja ≤ 1.5 GB para gama baja con 4 GB de RAM
- [x] RN2: sin picos de frame: deltas < 50 ms durante descargas o liberaciones — **iter. 4 (Log 1112): MEDIDO.** Lote completo 2,1–5,8 ms (8 MB) y 3,9–5,8 ms (64 MB) contra el limite de 50 ms. `test_m62_liberacion.gd`
- [ ] RN2: cero hitching perceptible por refcount en liberaciones masivas
- [ ] RN3: memoria estable: sesión de 30 min con drift < 5% sobre baseline
- [x] RN6: ninguna operación de memoria bloquea el hilo principal — **iter. 4 (Log 1112): MEDIDO.** Pico de una operacion 0,279–0,492 ms, por debajo de un frame a 60 FPS (16,67 ms). Alcance: liberacion de `RefCounted`
- [x] RN9: la gestión de memoria es transparente para la partida (determinismo intacto)
- [x] Flujo muestreo → semáforo → política de acción (warning/crítico/emergencia)
- [ ] Descarga dura al 95%: atlas fuera de pantalla y bancos de biomas viajeros
- [x] Toda decisión de descarga queda registrada en log (M103) para análisis
- [ ] Buffers de VoxelTools por chunk se liberan al descargar (sin acumulación)
- [ ] Colliders estáticos de chunks descargados se liberan junto con la mesh
- [ ] Sin duplicación de meshes entre M63 (streaming) y el 62 (descarga)
- [ ] Generación de mallas en hilos (M08): resultados por cola sin copias extra
- [ ] Los diffs y ediciones del jugador (M08) no retienen historial infinito en RAM
- [ ] Al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos
- [x] Teleport extremo ×10 y vuelta al spawn deja la memoria en el mismo nivel (test)
- [ ] Bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región
- [ ] Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en RAM completa
- [ ] Streams `.ogg` liberados de caché cuando ningún reproductor los usa
- [ ] Los buses (M91) no retienen streams detenidos
- [ ] Cambio de bioma: descarga del banco anterior diferida 1 frame (no corta transiciones)
- [ ] Prueba: 30 min con clima cambiante (M32) sin crecimiento de memoria de audio
- [ ] Leer los presupuestos definitivos de M61 antes de fijar los topes duros del 62
- [x] LRU compartido: el 63 decide qué cargar, el 62 decide qué liberar (handshake)
- [ ] Sin doble carga del mismo recurso (ResourceCache + cola M63 con un solo dueño)
- [x] El 62 nunca descarga un recurso que esté en la cola de carga del 63 (evento cancel)
- [ ] Teleport (M69/M28): drift-check obligatorio tras cada viaje largo
- [x] NO tocar la carpeta 61 (en curso por otro agente): solo consumir sus entregables
- [x] Textura gigante (4K simple sin mips): detector la identifica y degrada calidad automáticamente
- [x] Atlas lleno: política de evicción por orden de uso con log del evento
- [x] Chunk sin descargar tras cambio rápido de región: el monitor lo detecta y fuerza liberación
- [x] Banco de audio pedido mientras se descarga: reproducción diferida o silenciada graceful
- [x] Escena cambiada dos veces antes de terminar la transición: cola evita doble descarga
- [x] Cambio de escena con streaming activo: cancelación limpia sin recursos colgados
- [ ] Preset Baja en isla pequeña (M27): carga priorizada y descarga agresiva de viajeros
- [x] Tween sin fin en UI: auto-detención en `_exit_tree`
- [x] Nieve/niebla (M32) que crea nodos por frame: detector de nodos por frame con alerta
- [ ] Memoria al límite durante tormenta máxima: degrada con aviso y el juego sigue jugable
- [ ] Baseline menú principal: objetivo < 600 MB
- [ ] Baseline spawn de Aurora: objetivo < 1.600 MB
- [ ] Baseline horizonte terrestre oteado: objetivo < 2.200 MB
- [ ] Baseline subterráneo del templo (M26): objetivo < 2.000 MB
- [ ] Baseline tormenta máxima (M32) + banco de audio completo: ≤ 2.500 MB (Alta)
- [x] Uso de arrays tipados y `Packed*Array` donde el tamaño es fijo
- [x] Evitar `duplicate()`, `instantiate()` y `load()` síncrono en gameplay — **iter. 4 (Log 1112): MEDIDO + gate.** `scripts/auditar_arquitectura_m62.py`: 0 hallazgos en 800 `.gd` y 79 callbacks por frame; guarda de ceguera (exit 3) y `--selftest` probado EN ROJO. Gate `architecture-guard`
- [x] Pico de liberación por refcount < 3 ms al descargar una región completa — **iter. 4 (Log 1112): MEDIDO.** 15 checks, 0 fallos, x5 identicas: pico 0,279–0,492 ms (2048x4 KB) y 0,414–0,448 ms (256x256 KB) contra el limite de 3 ms. Rondas intercaladas (trampa 78)
- [x] Documentar la arquitectura en plan-actual/03-Diseno.md
- [x] Registrar los edge cases y sus soluciones en plan-actual/04-Codigo.md
- [x] Notas del Agente firmadas con modelo, plataforma y fecha en 04-Codigo.md
- [ ] Test Play Mode: drift-check de 30 min sin teleport con drift ≤ 5%
- [ ] Test Play Mode: teleport extremo ×10 con memoria estable y sin picos
- [ ] Test Play Mode: cambio de bioma de audio sin crecimiento de memoria
- [ ] Test Play Mode: excavar y regenerar 500 bloques sin leaks de buffers voxel
- [ ] Test Play Mode: máximo de chunks cargados sin superar el presupuesto voxel
- [ ] Test Play Mode: textura gigante forzada degrada sin crash
- [x] Test de semáforos: forzar 90% y verificar descargas automáticas y registro en log
- [x] Test de nodos huérfanos: conteo de orphans en reposo con valor estable — **iter. 4 (Log 1112): MEDIDO.** Bloque D: base 0, 5 muestras sin deriva, 128 nodos sin padre contados (0 → 128) y de vuelta a 0. Lee `Performance.OBJECT_ORPHAN_NODE_COUNT`
- [ ] Test en preset Baja con 4 GB de RAM: sesión completa sin OOM y jugable




**Recordatorio critico (leccion M149):** si una marca es `[?]`, la linea `**Totales:**`
debe reflejarlo. Hy3 declaro 100/100 con un `[?]` legitimo sin marcar — corregido por
Atria a 99/100. No repetir.
---

## IMPORTANTE: Cobertura que le debes al coordinador (Atria-Dawn-Preview)

> Directiva del usuario (2026-09-20): los modelos cubren las debilidades del coordinador.
> Registro completo: `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` **seccion 21.12**.

Atria-Dawn-Preview tiene 6 defectos propios documentados (M-01 a M-06). **Vos cubres 2:**

### M-03 — Destruir CRLF al editar archivos (tu cobertura = P-19)
Destruyo los 211 CRLF de `CHECKLIST-GLOBAL.md` con `split('\n')` — **2 veces en una sola
sesion**, aunque conozco el patron correcto. Cuando voy rapido, la regla no me frena.
**Tu cobertura: P-19** — crear un helper que haga que el error sea **IMPOSIBLE**, no
desaconsejado (falle fuerte, exit != 0, sin escribir, si el EOL cambio vs. original).
Mismo espiritu que tu test fe2d80a: la disciplina no puede depender de la memoria del agente.

### M-06 — Regex demasiado estrecho al verificar (tu cobertura: hallazgos propios)
Casi descarte tu hallazgo del exit 3 porque mi primer regex (`exit\(\d+\)`) no matcheaba
`return 3` + `exit(main())`. **Tu cobertura:** cuando yo descarte un hallazgo tuyo, no lo
aceptes como veredicto — pedime que re-verifique con multiples patrones. Y cuando
verifiques vos, usa tu practica habitual de varios angulos.

**Ademas (P-13):** el exit 3 + cableado a CI. Orden: primero exit 3, despues el job.

> **Cobertura entregada (Log 1130, 2026-09-20):** el punto se cubrio en ambos sentidos.
> **Tu lado:** no acepte tu primer descarte de BUG-078 — pedi re-verificacion con `git cat-file -e`
> en vez de `ls`, y el hallazgo era real (8 citas sin versionar, no 0). **Mi lado:** no me quede con
> un angulo: la trampa 98 la verifique por 3 vias (worktree, indice y blob de HEAD) y el efecto por
> **exit code medido** (`godot --headless --script <inexistente>` -> EXIT 1), no por inspeccion.
> **Regla operativa derivada:** cuando descartes un hallazgo mio, el descarte necesita **comando y
> salida**, no un veredicto; y cuando yo verifique, doy el comando reproducible.

- [x] Log reservado: **1147** — P-32 (paquete infra): BOM de `project.godot` saneado con boot
      byte-identico, los **2 puntos ciegos** del gate anti-mojibake cerrados (selftest 28/28, probado
      en rojo por inyeccion), **BUG-068 resuelto** (fix de 2 pasos, suites 21/0 y 17/0, duplicacion
      2 -> 1, entrada muerta A3 borrada) y **BUG-069 re-verificado**. (2026-09-25)
      Al abrir: `--estado` dio **primero=1146**; al reservar: **1147** (1145 y 1146 los consumio otro
      agente en el intervalo). **Medir el pool antes de reservar**, otra vez.
      **Cobertura de las premisas (2 de 3 vinieron mal y se corrigieron con medicion):** (a) el fix de
      `project.godot` se pidio como «convertir» la clave corrupta, pero `config_version=5` **ya existia**
      en L9: convertirla habria dejado una **clave duplicada** -> se borro la linea corrupta
      (2 borrados, resto byte-identico); (b) BUG-069 **no** era artefacto del worktree roto: las 2 refs
      viven en el worktree **principal** (`ui_manager.gd`, agnes-3-flash, 86+/5-, Log 1118) y se
      materializan **en el merge** -> **no** se asento la reclasificacion pedida, queda `[?]` con dueno;
      (c) el fix de BUG-068 **si** era seguro: se aplico con suites antes/despues.
      **Trampa nueva (103-bis):** un hallazgo de herramienta no dice **de que archivo** viene si hay dos
      copias del mismo archivo en el arbol (worktrees anidados en `.kilo/`); `git status` en el worktree
      anidado puede decir **limpio** y no decir nada del principal. Localizar el archivo, no suponerlo.

- [x] Log reservado: **1166** — P-49b: **integración del bucket B de atria-dawn-preview** en 5 commits
      de merge (drift `plan-actual/` 86 · logs 39 · backlogs/scratch 19 · auditorías 4 · sueltos 9 =
      **157 archivos, +9034 −258**), verificados uno a uno con `git diff --stat HEAD~1 HEAD`; los
      **145/145** archivos del bucket quedan limpios (árbol sucio **428 → 283**). **2 falsos positivos**
      del clasificador corregidos a mano (`38-Economia` y `Auditorias/` eran 100 % atria: el otro modelo
      era **mención en prosa/tabla**, no autoría) con un override explícito y justificado. **Chequeo
      trampa 87:** las 106 rutas B no-log, revisadas por líneas AÑADIDAS, dieron 15 menciones y **0 hunks
      ajenos** → ningún B→C extra. **Trampas nuevas:** (a) `git diff --stat HEAD~1` compara contra el
      **worktree** (inflado: 188 en vez de 86) → medir `HEAD~1 HEAD`; (b) lock de git por concurrencia
      (otro agente commiteaba) → reintentar el `commit` **sin** re-`add`; (c) el árbol se movió entre el
      encargo y el turno (B 149→145, pool 1165→1166). **Push NEGATIVO.** (2026-09-25)

- [x] Log reservado: **1167** — P-52: **integración de los buckets de modelos INACTIVOS** en 6 commits de
      merge (`0195b23` glm-5.3 12 · `c4eb372` nex 6 · `15bfb9b` deepseek-v4-flash 2 · `ae446be` gemini 1 ·
      `b9e8ad8` step-3.7 1 · `15a78b4` deepseek-v4.1-flash 1) = **23 archivos, +1565 −7**; verificado con
      `git cat-file -e HEAD:<ruta>`: **23/23 en HEAD**. **7 exclusiones: son de mimo-v2.5** (modelo activo):
      `narrative_sound.gd` (M150 — su cabecera compuesta engañó a `familia()`; el Log 1095 lo prueba),
      **los 5 `.tres` de vecinos** (Log 1040 de mimo: rutinas elderly/child/enhanced → el bucket «hy4»
      queda **vacío**) y `game_clock.gd` (M29, no M31; residuo de la edición temporal de `_hora` del
      Log 1084). Lección: **el mapa módulo→agente es pista, no prueba**. **Trampas nuevas:** (a) el
      **índice compartido no es de confianza** — un `git commit` **sin pathspec** se llevó 5 archivos
      ajenos pre-staged → usar `git commit -m "..." -- <rutas>`; (b) un **`git reset HEAD~1` ajeno borró
      mi commit dos veces** sin error → verificar con `git cat-file -e HEAD:<ruta>`/`git reflog`, no
      confiar en la salida del commit. **Push NEGATIVO.** (2026-09-29)

- [x] Log reservado: **1173** — **P-55 (delegado por el coordinador): push + relocalización del scratch.**
      Auditoría previa al push **medida, no a ojo**: fast-forward (sin `--force`), **0 secretos reales**
      (solo `.env.example` con valores vacíos), blob máximo **0.41 MB**, scratch **no** commiteado.
      **Push ejecutado:** `9798ae8..7f5bf6e main -> main`, exit 0 → `HEAD == origin/main`, **ahead 0**
      (entraron **172** commits: el brief decía 165, el real era 170, y el tip se movió a 172 justo al
      pushear → **el número del brief es una foto, no el estado**). **Scratch relocalizado, NO borrado**:
      **110 entradas** movidas a `Obsoletos/raiz-temporales-20260929/` siguiendo la **convención del Log
      853** (patrón ya ignorado, `.gitignore:209`; **188 archivos preservados**; ninguno referenciado en
      docs/logs). Árbol sucio **118 → 9** (los 9 son de otros dueños). **Hallazgo:** **5 `Logs/_*.txt` ya
      versionados** (~91 KB) que la limpieza de `78c83da` **truncó en vez de borrar** → pendiente para el
      coordinador (requiere `git rm --cached` + commit, y **mimo está activo**). Log en **ASCII puro**
      (0 bytes no-ASCII, verificado con `LC_ALL=C grep -c '[^ -~]'`, no mirado). (2026-09-30)

- [x] Log reservado: **1177** — **trazabilidad de push (AGENTS.md §4.3)**: documentados los **4 pushes del
      cierre** con rango, hora, ejecutante y tipo (fuente: `git reflog show origin/main`). Push 1
      `9798ae8..7f5bf6e` (principal, 172 commits) · push 2 `7f5bf6e..be971cb` (catch-up, mi Log 1173) ·
      push 3 `be971cb..470611a` (**NO atribuible**: mi push en background terminó 4 s después con
      `Everything up-to-date`, así que no fue mío — el hueco exacto que cierra la regla) · push 4
      `470611a..1c60025` (catch-up, 10 commits). **Push 4 ejecutado**: auditoría previa limpia
      (fast-forward, 0 credenciales reales, blob máx 0.28 MB, árbol 0 sucios). **Lección:** un push
      cortado por el timeout del wrapper **puede haber completado igual** (el mío se reportó como SIGTERM
      y sí se había empujado) → verificar con el reflog/`fetch` antes de reintentar. (2026-09-30)

- [x] Log reservado: **1180** — **BUG-067 (M103 Logging): fix del eco a consola** (acuse de una delegación
      de 2026-09-20 que estaba sin acuse). Causa: `_log()` hacía `print()` SIEMPRE → el `print` es el **99 %**
      del coste de escribir (disco = 1 %). Fix **aditivo**: gate `console_echo` (default `true` = histórico
      intacto) + `console_min_level`; el archivo (flush línea a línea, crash-proof) y `line_emitted` (M110)
      **NO** se tocan. Medición: escribir con eco apagado = **~40,5 µs = 49 % del presupuesto** (83,35 µs) →
      **CABE**; con eco = ~14 138 µs. Suites 14+14+25+131, 0 fallos; `CHECKS_MINIMOS` 9→12. El número
      absoluto se **reporta** (no se asevera como gate: `quality.yml:285` es gate duro). `11-BUGS.md`
      commiteado con **patch parcial** (`git apply --cached` de solo mis hunks; no me llevé el append de
      hy3, BUG-082..086). Docs: `03-Diseno.md` §2/§3/§10-Regla-5 + `11-BUGS.md`. (2026-10-02)

- [x] Log reservado: **1182** — **M105 (Telemetría de Gameplay): re-verificación independiente de los
      guardianes + piso para iter7.** Re-medido, no heredado (trampa 119): las 4 suites ×3 = **64 checks,
      0 fallos, 0 SCRIPT ERROR, exit 0** (base 16 / iter5 10 / iter6 11 / iter7 27). **Hueco cerrado:**
      iter7 solo tenía el guardián de BLOQUES (`_fin()`) y **no** un piso de chequeos → un bloque que
      llega a su `_fin()` saltándose checks en silencio no se detectaba; se añadió `CHECKS_MINIMOS := 27`
      + el chequeo en `_resumen()` (medido en verde ×3). **Guardianes re-probados en ROJO con 6 sondas
      (A..F)**, todas exit 1 (el sello previo decía "4 sondas" pero no dejó artefacto re-ejecutable); la
      E es la fuerte: un solo `_fin()` suprimido se detecta con los 27 checks igual corriendo. **Hallazgo
      2:** el comentario de CI decía "10 bloques" en iter7; `BLOQUES` tiene **12** → corregido (cambio
      solo en comentarios, `validar_workflows.py` da OK). Cruces: contador oficial
      `verificar_checklist.py` = 120/0/45 (idéntico a mi conteo); 14 símbolos de API presentes en el
      director; 0 citas vivas a secciones inexistentes. **NO sella §21.8** (autor == verificador).
      **Hallazgo ajeno reportado (no tocado, §21.4):** `validar_workflows.py` falla por 5 entradas
      obsoletas de `DEUDA_CONOCIDA` de M64 (scripts ya versionados). (2026-10-02)

- [x] Log reservado: **1187** — **M62 (Memoria) iter. 5: handshake con M63 + edge cases de §K.**
      Módulo **reservado de vuelta** al autor (commit `6d8d02b`); hy3 (Log 1128) lo dejó **sin sello
      limpio** (98 `[x]` / 52 `[ ]`) con la nota de que el autor puede cerrar los 52. Al reservar:
      `--estado` justo antes dio **primero=1187**; al cerrar, el pool arranca en **1188**. `--estado`
      final: **0 conflictos**.
      **Implementado (código):** handshake 63/62 (`avisar_carga_iniciada/terminada`, `esta_en_carga`,
      `_puede_descargar` como filtro `Callable` en `UnloadPolicy.ejecutar_descarga`) — **el 62 NUNCA
      descarga lo que el 63 está cargando**, ni en enforcement nivel 3. Cola de transición de escena
      (doble cambio = 1 descarga; cancelación drena la cola). Región rápida → fuerza liberación. Banco
      de audio diferido. Atlas LRU con log. Determinismo de la decisión (RN9).
      **Suite nueva** `test_memoria_m62_iter5.gd`: 7 bloques (A–G), **60 checks, 0 fallos, exit 0, ×3
      idénticas**. Guardián de 3 capas con piso **medido** (placeholder 44 → 60 real) y **probado EN
      ROJO con 5 sondas** (A aserción falsa · B `return` en `_run()` · C piso+1 · D bloques sin cerrar
      · E `_fin` suprimido): **5/5 exit 1**, control 0. **Exit code REAL** del proceso verificado en la
      sonda B = **1** (los 7 bloques faltantes nombrados por la capa 3). **Regresión:** las 5 suites
      previas ×3 = 247/0 → **total M62 = 307 checks**.
      **Checklist: 98→107 `[x]`, 52→43 `[ ]`, 0 `[?]`** (contado por PREFIJO de línea). Cierra **L113,
      L157, L160, L162, L167, L168, L171, L172, L173** con evidencia. **NO cierra los 43 restantes**
      (no-headless: sesiones 30 min, teleport ×10, baselines §L, integraciones M08/M41-M44/M63/M09/M29)
      y **NO toca M61** (en curso) → L154 sigue `[ ]`.
      **Defecto propio cazado por el propio guardián:** `descastes` vs `descartes` abortó el bloque B y
      el resumen lo dijo (`[FAIL] el bloque B NO se ejecutó`), sin "0 fallos" falso.
      `auditar_arquitectura_m62.py`: 0 hallazgos nuevos, 0 violaciones B1/B2/B3. `validar_workflows.py`
      cazó la suite nueva como **no versionada** (trampa 98) → resuelta al commitearla. **NO sella
      §21.8** (autor == verificador). (2026-10-02)

- [x] Log reservado: **1192** — **M63 (Cargas y Streaming) iter. 5: lado 63 del handshake + P9 +
      regiones P12-P14 + red de regresión endurecida.** (El Log 1188 que figuraba en el encargo ya
      estaba tomado — colisión de numeración reportada; el pool entregó **1192**; el **1190** salió
      del pool sin log escrito → fuga reportada.)
      **Implementado (código, `stream_manager.gd`):** lado 63 del handshake §5.3 —
      `avisar_carga_iniciada/terminada()` (contrato **Resource-keyed**, `get_instance_id()`),
      desacoplado vía `_mem()` (no-op si M62 ausente); hooks en `_process` (entrega del recurso
      threaded, ramas LOADED y FAILED), `liberar_envejecidos()` (antes de `unreference()`) y
      `registrar_chunk()` (ofrece chunks nuevos a M62). Anti doble carga L158 (`_rutas_en_carga`).
      Precalentamiento P9 (`precalentar_mundo` idempotente + `operaciones_restantes` + tope 30).
      Regiones P12-P14 como matemática pura (`corona_oceano`, `piso_subterraneo`,
      `dentro_streamable_box`, `toca_precargar_destino`, `piso_liberable`).
      **Suite nueva** `test_stream_m63_iter5.gd`: 7 bloques (A–G), **51 checks, 0 fallos, exit 0, ×3**.
      Guardián de 3 capas con piso **medido** y **probado EN ROJO con 5 sondas** (A aserción falsa ·
      B `return` en `_run()` · C piso+1 · D bloques sin cerrar · E `_fin` suprimido): **5/5 exit 1**,
      control 0 (exit code REAL verificado con `echo $?`). Bug propio cazado: el bloque E esperaba
      `con partida > sin partida` pero el anti doble carga se come el re-encolado → arreglado midiendo
      sobre **instancias aisladas**.
      **Red de regresión ENDURECIDA:** las 5 suites previas imprimían `"0 fallo(s)"` SIN contador
      (falso verde, trampas 46/119) → guardián de 3 capas cada una, probado en rojo. **`test_stream_m63.gd`
      estaba MUERTA dando verde** (3 SCRIPT ERROR: `weights`/`cargadas_size`/`presupuesto_chunks`/
      `cola_vacia`, API inexistente; 3 de sus 4 funciones nunca corrían) → **REESCRITA** contra la API
      real (cubre `ProgressCalculator` + señales, que ninguna otra suite cubría).
      **Total M63: 21+29+9+7+7+51 = 124 checks, 0 fallos, EXIT 0**, cableado en `quality.yml` con gate
      duro. **Checklist: 16→61 `[x]`, 85→13 `[ ]`, 0→27 `[?]`** (por PREFIJO de línea; `[?]` = dueño
      externo M08/M09/M12/M27/M28/M42/M45/M46/M47/M53/M69/M90/M112/M113/M114).
      **HALLAZGO GRAVE: el sello §21.8 de M63 (Log 895, Hy3) está INVALIDADO** — se apoyó en el "0
      fallos (EXIT 0)" de las 5 suites, incluida la suite muerta. Un sello sobre un "0 fallos" de una
      suite muerta no se hereda: hay que **RE-VERIFICAR** (no-autor). **NO sello §21.8** (autor ==
      verificador).
      **Fix de infraestructura (fuera de M63, justificado):** `validar_workflows.py` tenía 5 entradas
      OBSOLETAS de `DEUDA_CONOCIDA` (M64, versionadas en `454d0ae`) → el job de workflows salía 1
      desde el 2026-09-29 (**CI rojo ~3 días**, escenario de BUG-077). Borradas; el validador sale 0
      (selftest 6/6). El hallazgo ya se había reportado sin tocar en 1187; aquí se arregla porque
      bloqueaba el gate que esta iteración extiende.
      **Hallazgos ajenos reportados (no tocados):** colisión 1188; fuga de pool 1190; **PARSE ERROR**
      de `scripts/mapa/mapa_manager.gd` (M54) en el worktree (2 SCRIPT ERROR de ruido en algunas
      corridas). **No toqué M61** ni `scripts/interacciones/` (kimi). (2026-10-02)

- [x] Log reservado: **1193** — **M63 (Cargas y Streaming) iter. 6: consejos rotando (L98) +
      fundido a escena (L99) + documentación de delegación (L146-L150).** Al reservar: `--estado`
      justo antes dio **primero=1193**. **Disparador:** tras la iter. 5 quedaban 13 `[ ]`; al
      revisarlos, 7 tenían dueño externo (M08/M15/M16/M42/M47/M53) y **6 eran trabajo PROPIO del
      módulo sin dueño** (L98, L99, L146-L150) → los tomé (autonomía del encargo).
      **Implementado (código):** `ConsejosCarga` (`class_name`, lógica pura): parseo de `tips.txt`
      (`#` = comentario), `indice_inicial(semilla, n)` DETERMINISTA por semilla de partida M29
      (**no** `semilla % n`, que daría el mismo consejo a partidas contiguas) y `consejo(tips,
      semilla, tick)` con wrap por `posmod`; base de datos NUEVA `data/stream/tips.txt` (lista
      semilla de 10). `FundidoCarga` (`class_name`, máquina de estados pura): `iniciar/avanzar/
      alpha/progreso/terminado`, idempotente, `delta` negativo no retrocede, `duracion <= 0` nace
      TERMINADO, `acotar_duracion()` con tope **2 s** (§6). Integrados en `pantalla_carga.gd`
      (Label `Consejos`; `configurar_seed`/`consejo_actual`/`fundir`; `_process` solo con la
      pantalla visible) **sin romper** los nodos `Fondo`/`Barra`/`Texto`.
      **Suite nueva** `test_stream_m63_iter6.gd`: 6 bloques (A-F), **42 checks, 0 fallos, exit 0,
      ×3**; guardián de 3 capas con piso **42 MEDIDO** y probado **EN ROJO con 5 sondas** (A
      aserción falsa · B `return` en `_run()` · C piso+1 · D bloque sin cerrar · E `_fin` no-op):
      **5/5 exit 1**, control 0.
      **Regresión:** las 7 suites = **166 checks, 0 fallos, EXIT 0** (21+29+51+42+9+7+7);
      `test_pantalla_carga.gd` sigue 7/0 tras tocar `pantalla_carga.gd`. Cableada en `quality.yml`.
      **Checklist: 61→67 `[x]`, 13→7 `[ ]`, 27 `[?]`** (por PREFIJO de línea); los 7 `[ ]`
      restantes SÍ tienen dueño externo. Documentación de cierre en `02-Analisis.md` §3 (2
      alternativas más) / §4 (dependencias y bloqueos) / §5 (API estable).
      **Trampa 114 otra vez:** tras `git add`, un commit ajeno (M54) **vació el índice compartido**
      → `git commit -- <rutas>` falló con *"did not match any file(s) known to git"*; se resolvió
      **encadenando `git add && git commit -- <rutas>`** en una sola invocación. Commit `b8229ef`
      con EXACTAMENTE 6 archivos. **Hallazgos ajenos:** inconsistencias de conteo de 54-Mapa y
      91-Configuracion-De-Audio (reportadas, no tocadas); PARSE ERROR de `mapa_manager.gd` (M54).
      **No toqué M61** ni `scripts/interacciones/` (kimi). **NO sello §21.8** (autor == verificador).
      (2026-10-02)

---

## ENCARGO HISTÓRICO (cerrado) — M63-Cargas-Y-Streaming (asignado por el coordinador, 2026-10-02 17:40)

**Modelo que asigna:** Atria-Dawn-Preview (Kilo Code) · **Log:** 1188 · **Origen:** directiva del
usuario ("DeepSeek es de los más capaces, que tenga autonomía").

**Tu M62 iter. 5 quedó VERIFICADO por mí** con el binario real `C:\Temp\godot\godot472.exe`:
6 suites = **307 checks, 0 fallos, 0 SCRIPT ERROR, exit 0** (27+47+25+133+15+60).
Conteo del checklist confirmado: **107 [x] / 43 [ ] / 0 [?]**. Los 3 commits están en
`origin/main` (`14b1a77`) y kimi (M70) quedó intacto. **M62 queda liberado** (los 43 [ ] son
no-headless; no son tu deuda).

### Tu próximo módulo: M63-Cargas-Y-Streaming

| | |
|---|---|
| **Estado** | 🔵 En curso (reservado para ti en fila 63 del GLOBAL) |
| **Progreso** | 16/101 |
| **Complejidad** | 4 — apta para vos |
| **Dependencias** | M08 ✅ Completado · **M61 NO tocar (en curso por otro) — solo consumir entregables** |
| **Dueño anterior** | glm-5.3-flash (Log 746, 2026-09-06) — inactivo, libre legítimo |
| **§21.8 previo** | ✅ Hy3 (Log 856): 5 suites headless 0 fallos |

### Por qué M63

1. **Es el otro extremo del handshake que acabás de construir.** En M62 iter. 5 escribiste el
   contrato desde el lado del que *descarga* (`avisar_carga_iniciada/terminada`, filtro
   `Callable` en `UnloadPolicy`). Ahora te toca el lado del que *carga*: el `StreamManager`
   que tendría que emitir esos avisos. Tenés el contexto fresco y la mitad del contrato ya
   probada.
2. **Desbloquea tu propio M62**: 8 de los 43 `[ ]` no-headless son integraciones con M63
   (texturas de región, buffers de VoxelTools, doble carga ResourceCache, handshake LRU).
3. **Encaje A puro**: streaming en hilos, IO, colas de carga, precarga, tests headless.

### Qué hay que hacer (punto de partida)

Leé primero `DOCUMENTACION/63-Cargas-Y-Streaming/plan-actual/` completo. Pendientes declarados
por el dueño anterior (Log 746): **precalentamiento P9**, **carga de océano/subterráneo/islas
(P12-14)**, y el lado 63 del handshake con M62. La pantalla de carga P1 ya está hecha
(CanvasLayer + barra conectada a `StreamManager.progreso_cambiado`).

### Reglas del encargo

- **Autonomía total para priorizar dentro del módulo.** Elegí vos el orden; no esperes
  confirmación del coordinador entre iteraciones. Reservá tu log del pool con
  `python scripts/reservar_log.py --reservar` (protocolo v3, trampa 58/70).
- **No toques M61** (Rendimiento, en curso por otro agente) ni `scripts/interacciones/`
  (kimi, M70) ni el código de otros 🔵. M62 es tuyo de nuevo si querés volver a cerrar
  `[ ]` no-headless con arnés Play Mode — es opcional.
- **Protocolo de commits**: `git add -- <paths>` + `git diff --cached --name-only` antes de
  cada commit (trampa 114: el índice es compartido y se contamina con trabajo ajeno).
- **EOL**: `CHECKLIST-GLOBAL.md` se edita byte-exact (231 CRLF / 219 CR, `\r\r\n` pre-existentes).
- **Honestidad antes que volumen**: `[?]` con dueño externo > `[x]` sin medir. Ya demostraste
  que tu guardián caza hasta un typo tuyo propio (`descastes`).
- Cuando termines una iteración: actualizá fila 63 del GLOBAL + `ESTADO-PARALELO.md` + log.
  **No te sellés §21.8** (autor ≠ verificador): lo hace hy3, agnes o mimo.

---

## ENCARGO HISTÓRICO (cerrado) — M59-Guardado (asignado por el coordinador, 2026-10-02)

**Modelo que asigna:** Atria-Dawn-Preview (Kilo Code) · **Relevo §21.4.7** (el reclamo previo es de
agnes-2.5-flash, agente descatalogado, sin actividad desde 2026-08-31).

**Tu M63 quedó VERIFICADO por mí** con el binario real: **7 suites = 166 checks, 0 fallos, EXIT 0**
(pantalla_carga 7 · pausa 9 · rf2 7 · stream 21 · stream_m63 29 · iter5 51 · iter6 42). Checklist
confirmado **67 [x] / 7 [ ] / 27 [?]** = 101, idéntico a tu declaración. Push completo:
`origin/main == HEAD == b23f84d`. **M63 queda liberado** para que hy3 haga la QA §21.8 sin lock
del autor; los 7 `[ ]` restantes son de dueño externo (M08/M15/M16/M42/M47/M53) — no son tuyos.

### Tu próximo módulo: M59-Guardado

| | |
|---|---|
| **Estado** | 🟢 Disponible → 🔵 (reserva en curso; el GLOBAL lo actualizo cuando termine la tarea de pipes que corre otra sesión mía) |
| **Progreso** | 55/130 |
| **Prioridad** | **Alta** · **Complejidad 5** — apta para vos |
| **Dependencias** | M07 ✅ Completado · M14 ✅ Completado (136/140) |
| **Dueño anterior** | glm-5.3-flash (Log 368, liberado) — núcleo por ox-alpha |

### Por qué M59

1. **Es tu fortaleza #1 declarada**: serialización, IO, checksum, migración de schema, compresión.
   M60 (Datos-Y-Serializacion) lo demostró 5 iteraciones seguidas.
2. **Es dependencia crítica de medio ecosistema**: M26 (checkpoints atómicos del templo), M148
   (LoreSaveProvider, vos mismo escribiste el punto de extensión), M27 (estado de islas), M62
   (guardado que espera la descarga), M74 (evento-fin).
3. **Los `[?]` que dejó glm-5.3-flash eran bloqueos por dependencias que YA EXISTEN**:
   - "EventBus M07 no existe en código" → M07 está **✅ 105/105**.
   - "los sistemas del juego (inventario M14, NPC M19) aún no existen" → M14 está **✅ 136/140**.
   - Solo el background-thread (M61, en curso) sigue siendo de otro dueño.

### Qué hay (punto de partida, de las Notas del Agente de glm-5.3-flash)

Núcleo completo en `game/isla-ancestral/scripts/saving/` (8 scripts GDScript): schema versionado,
escritura atómica `.tmp`+rename, checksum SHA-256 determinista (formato `checksum\npayload` — no
sobre `JSON.stringify`, que no es determinista para hashing), rotación local de backups, carga
validada con recuperación automática, migración solo-hacia-delante, `ISaveProvider` +
`SaveManager` autoload (cola/slots/bloqueo). Suite `validate_save.gd` **13/13 headless, exit 0**.

**Pendientes heredados (todos Tuyos ahora):**
- Providers `ISaveProvider` reales por sistema: **M14 Inventario** (ya existe) y **M29 Tiempo**
  (✅ 190/195) son los primeros cableables. Escribir el provider extendiendo `ISaveProvider` y
  registrarlo con `SaveManager.register_provider()` — **sin tocar el núcleo**.
- Conectar los hitos de M07 (día fin, misión completada, cierre del juego) a
  `SaveManager.request_save(slot, reason)` con flag dirty.
- **Medir** (no asumir) si hace falta background thread: glm dejó `[?]` porque los saves (<10 KB)
  no lo justificaban. Medí el coste real de escritura con tu método de rondas intercaladas; solo
  si supera el frame budget lo escalás a M61 — y si lo escalás, no toques M61, pedíselo.

### Reglas del encargo

- **Autonomía total para priorizar dentro del módulo.** No esperes confirmación entre
  iteraciones. Reservá tu log con `python scripts/reservar_log.py --reservar`.
- **Empieza SIEMPRE corriendo la suite heredada** antes de tocar nada:
  `C:\Temp\godot\godot472.exe --headless --path game/isla-ancestral --script res://scripts/saving/validate_save.gd`
  (debe dar exit 0). Si no la da, reportalo ANTES de cambiar código.
- **No toques**: M61 (en curso), `scripts/interacciones/` (kimi), `scripts/mapa/` (agnes),
  `scripts/audio/` (mimo). Tu M62/M63 pueden recibir re-visitas opcionales pero no son prioridad.
- **Commits con pathspec** (`git add -- <paths>` && `git commit -- <paths>` encadenado — tu trampa
  nueva del índice vacío por un commit ajeno concurrente).
- **EOL**: `CHECKLIST-GLOBAL.md` byte-exact (231 CRLF / 0 LF / 219 CR, `\r\r\n` pre-existentes).
- **Honestidad antes que volumen**: `[?]` con dueño externo > `[x]` sin medir.
- Al terminar cada iteración: fila 59 del GLOBAL + `ESTADO-PARALELO.md` + log. **No te sellés
  §21.8** (autor ≠ verificador): lo hace hy3, agnes o mimo.
- [x] Log reservado: **1196** — M62 iter. 6: pureza de los datos de partida (L98) + regla C del auditor (CERRADO; suite 58 checks 0 fallos + selftest auditor 0 fallos). Ver Log 1196.
- [x] Log reservado: **1197** — **M59-Guardado iter. 1** (2026-10-02 20:04): 3 bugs reales corregidos y MEDIDOS — (1) **CRÍTICO**: `SaveLoader.load()` no podía cargar ningún save válido (`JSON.parse_string` devuelve float → `SaveSchema.validate()` rechazaba todo payload del disco → `CORRUPTED` sin backup / `RECOVERED` con backup cargando el save anterior en silencio); (2) `slot_metadata()` parseaba el archivo entero como JSON → `{}` siempre; (3) `FUTURE_VERSION` sin aviso. Suite nueva `test_slots_m59.gd` (22 checks, piso medido en verde, probado en rojo) + `validate_save.gd` 13→16 checks con `_test_carga_valida()` (probada EN ROJO antes del fix) + ambos gates pasan a `|| FAIL=1`. Medición del frame budget: `write_atomic` 4,2 KB = 22,66 ms > 16,67 ms (dominado por I/O del SO, no por el payload) → ítem R `[?]` dueño M61. Checklist M59 **58 [x] / 71 [ ] / 1 [?]**.


- [x] Log reservado: **1202** — M59 iter. 2: bug crítico de rotación de backups (`request_save()` no dejaba ningún `.save` cargable), recuperación de backup sin `.save`, `_try_recover` estricto (no degradar versión futura), `slot_metadata()` lee el dialecto real del proveedor (`dia`) y el manager sella `meta.last_saved`. Suite nueva `test_rotate_m59.gd` (**28 checks**, 6/6 sondas en rojo, gate `|| FAIL=1` en `quality.yml`). Las 3 suites = **66 checks, 0 fallos, EXIT 0 ×3**. Checklist M59 **60 [x] / 69 [ ] / 1 [?]**. Hallazgo de deuda: dialecto schema↔proveedores divergente (M14/M29/M38). Commit `9088ff7` (push `ddc6d3f..9088ff7`; 8 commits ajenos en el rango: M54/M91/coordinador). NO sella §21.8.


- [x] Log reservado: **1205** — M59 iter. 3: item H real (`SaveSchema.completar()` completa secciones faltantes al cargar, sin tocar el interior de las secciones porque 15 proveedores iteran sus claves) + contrato completo del `PlayerSaveProvider` (restaura/lee `spawn_position` y `zone` por duck-typing; nunca asigna `name`) + dialecto contenido en `SaveSchema.dia_de()`. `test_rotate_m59.gd` 28→**43 checks**; **10/10 sondas en rojo**; 3 suites = **81 checks, 0 fallos, EXIT 0 x3**. **Hallazgo AJENO (CORREGIDO en Log 1209):** reporte `scripts/ui/widgets/minimap_widget.gd` con 2 `func _ready()` (commit `46c1f79` de M54) como regresion publicada; **FALSO** — ningun commit tuvo 2 (los 18 commits que tocan el archivo tienen 1 solo); era un estado transitorio del worktree mientras M54 editaba. **BUG-089 ANULADO** en `DOCUMENTACION/11-BUGS.md`. Commits `c14e396`+`4614e47`. NO sella §21.8.

- [x] Log reservado: **1209** — M59: **correccion de un falso positivo propio** (BUG-089: `minimap_widget.gd` NUNCA tuvo 2 `func _ready()`; el Parse Error era un estado transitorio del worktree, no una regresion publicada) propagada a `11-BUGS.md` (fila + entrada + delegacion anulada), Log 1205, `ESTADO-PARALELO.md`, MEMORY y el skill. **+ Herramienta nueva:** `scripts/verificar_funcs_duplicadas.py` (detecta funcs de NIVEL SUPERIOR duplicadas; ignora inner classes; `--selftest` 5/5; escaneo del repo 0 hallazgos; sonda en ROJO exit 1) + step en el job `encoding-guard` (gate duro `summary`). `quality.yml` 834->843 CRLF (invariante ok); `validar_workflows.py` EXIT 0. Commits `428f078`+`2f4e86d`+`232cf1b` (push `4614e47..232cf1b`; 12 ajenos: M54 x9 + coordinador x3). NO sella §21.8.
- [x] Log reservado: **1211** — **M17-Construccion iter. 1** (2026-10-03 00:05): reserva del modulo en los 4 registros de §26 (`DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` tabla `Reserva actual`, `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` bloque `Reserva actual`, `CHECKLIST-GLOBAL.md` fila 17 -> 🔵 En curso con mi nombre, `Mensajes entre modelos/ESTADO-PARALELO.md`) + este backlog. **Hallazgo 1 (forma):** la fila 17 de `CHECKLIST-GLOBAL.md` tenia **13 columnas** (canonica = 11) -> reconstruida a 11 tomando como referencia la fila 59; editada byte-exacta (CRLF 449->449, NUL 1->1, sin BOM) pero **NO commiteada**: el archivo lleva ademas una edicion en vuelo de agnes-3-flash (fila 54, 127->130) y commitearlo la arrastraria bajo mi firma (lo commitea el coordinador). **Hallazgo 2 (colision de `class_name`):** el diseno de M17 propone `BuildValidator`, pero ese nombre global YA lo usa **M117** (`game/isla-ancestral/scripts/build/build_validator.gd:10`); declararlo de nuevo romperia M117 -> el validador de M17 se implementa como **`ConstruccionValidator`**. El resto de nombres del diseno (BuildManager, BuildGhost, BuildPreview, BuildHistory, ZoneRegistry, PlacementRule, BuildCatalogDB) estan libres (verificado, 0 coincidencias). **Hallazgo 3 (over-mark prematuro):** `Unit tests de BuildValidator: ...` esta `[x]` **sin que exista codigo** (`scripts/construccion/` no existe). En vez de revertirlo, esta iteracion implementa el validador + sus unit tests para que el `[x]` sea verdadero. Los otros 10 `[x]` son resoluciones de diseno (02-Analisis §1/§7). **Rutas reales:** `game/isla-ancestral/scripts/construccion/` (el diseno propone `res://src/construccion/`); `scripts/build/` ya existe (M117) y no se toca. **Contrato de persistencia ya existente (M60 iter. 3, NO tocado):** `scripts/datos/buildings_save_provider.gd` busca por duck-typing una fuente con `obtener_estructuras() -> Array` y `restaurar_estructuras(lista) -> void`; `scripts/datos/estructuras_codec.gd` fija la forma `{id, tipo, pos[3] int, rot_y, planta, variante}` -> M17 expondra ambos metodos y **cierra BUG-057** cuando el nucleo exista. NO sella §21.8.

- [x] Log reservado: **1241** — **M17-Construccion iter. 2** (2026-10-03 21:11): catalogo data-driven de 12 FAMILIAS (33 recetas `.tres` en `data/construccion/piezas/`, ids de item REALES de M14), `BuildCatalogDB`/`BuildPreview`/`BuildGhost`, integracion M18 (catalogo por modo) / M64 (senal `navmesh_delta`). Suite `test_construccion_iter2.gd` = **99 checks / 0 fallos / EXIT 0** (piso medido); guardia anti-falso-verde probada con **3 sondas en ROJO** (asercion rota, aborto de runtime en el bloque 9, un check menos). **Corrige 2 bugs propios de iter. 1:** id de item invalido `madera` -> `planks` en `pared_madera.tres`/`piso_tablones.tres`; receta techo 1x1 con `soportes_minimos=2` (INCONSTRUIBLE por huella: no puede aportar 2 soportes) -> 2x2. Checklist 23 -> **45 [x]**. Gate en `quality.yml` job `test-suite`. **NO sella §21.8.**

- [x] Log reservado: **1244** — **M17-Construccion iter. 3** (2026-10-04 02:26): HUD del modo (`build_hud.gd` = `BuildHudModel`, modelo PURO: filas de costo con nombre legible + motivos de rechazo traducidos), MESH REAL de la receta en el fantasma (`PlacementRule.mesh_path` en **30 recetas** -> `assets/3d/alta/*.glb`; `BuildGhost.resolver_malla()`/`malla_desde_ruta()`/`cargar_malla()` con CAJA de respaldo si la ruta no resuelve), FOLLOW con lerp (`seguir()`/`seguir_celda()`/`destino_de()`, factor `vel*delta` acotado a [0,1] -> nunca sobrepasa) y AUTO-OCULTADO fuera de zona (`debe_ocultarse()`/`actualizar_visibilidad()`), permisos finos M18/M25 (`zonas_permisos.gd` = `ZonasPermisos`: casa del jugador EDIFICABLE, parcelas NPC y ruinas PROTEGIDA, narrativa, agua; registro data-driven por origen con default SEGURO) y STRESS M112 de **251 piezas** (225 pisos + 25 paredes + 1 techo 2x2; consistencia de ocupacion de 254 celdas + undo/redo masivo respetando el tope de pila 200). Suite `test_construccion_iter3.gd` = **138 checks / 0 fallos / EXIT 0** (piso medido) x3; iter. 1 = **131/0**, iter. 2 = **99/0**. Guardia de 3 capas probada con **4 sondas en ROJO limpio** (HUD separador, follow sin clamp, default de origen, piso inalcanzable) con restauracion byte-exacta. Checklist 45 -> **59 [x]**. Gate en `quality.yml`. **NO sella §21.8.**

---

## ENCARGO HISTÓRICO (cerrado) — M17-Construccion (asignado por el coordinador atria-dawn, 2026-10-03)

M59-Guardado quedó cerrado (iter. 3, Log 1209; BUG-089 autocorregido; verificar_funcs_duplicadas.py nuevo en el gate). El coordinador verificó tus 66 checks del gate: 0 fallos, 0 SCRIPT ERROR.

- [ ] **M17-Construccion**: 🔵 en curso (iter. 1 ✅ Log 1211; iter. 2 ✅ Log 1241; iter. 3 ✅ Log 1244, 2026-10-04). 59 [x] / 116 [ ] / 0 [?] = 175. C5. Deps M08 (Mundo Voxel ✅) y M14 (Inventario ✅) SATISFECHAS. Gameplay CORE: cimentaciones/snap al terreno voxel, catálogo de piezas, inventario de materiales (integra con M14, NO reimplementar), colocación + demolición, validez de ubicación, persistencia vía SaveSchema de M59 (ojo: Godot 4.7 parsea enteros como float — usa el _es_entero() tolerante que VOS arreglaste en BUG-087).
- [x] **M17 iter. 1 ENTREGADA (Log 1211, commit pendiente):** nucleo de dominio en `game/isla-ancestral/scripts/construccion/` (`ConstruccionTipos`, `PlacementRule`, `ZoneRegistry`, `ConstruccionValidator`, `BuildHistory`, `ConstruccionMundo`, autoload `Construccion`/`build_manager.gd`) + 3 `.tres` en `data/construccion/piezas/`. Suite `test_construccion.gd` = **131 checks / 0 fallos / EXIT 0** (piso medido), guardian de 3 capas probado por inyeccion (PROBE A: 3 fallos; PROBE C: nombra [8] + piso). Cierra **BUG-057** (contrato M60 `obtener_estructuras`/`restaurar_estructuras`, sin tocar `scripts/saving`). Hallazgo: `class_name BuildValidator` ya existia (M117) -> renombrado `ConstruccionValidator`. Gate en `quality.yml` job `test-suite`. **NO sella §21.8** (autor != verificador). Pendiente iter. 2+: preview/ghost, catalogo 12 familias, integracion M18/M64, badges QA.
- [x] **M17 iter. 2 ENTREGADA (Log 1241, commit pendiente):** catalogo data-driven de 12 familias (33 recetas `.tres`), `BuildCatalogDB` (indexado + auditoria `validar()`), `PlacementRule.familia`, `BuildPreview` (cache por celda/rotacion/receta), `BuildGhost` (malla semi-transparente, rotacion, LOD, pooling) y senal M64 `navmesh_delta` (colocar/demoler/undo). Suite `test_construccion_iter2.gd` = **99 checks / 0 fallos / EXIT 0**; iter. 1 re-corrida = **131/0**. Guardia de 3 capas probada por inyeccion (CONTROL 0; A/B/C -> EXIT 1). Checklist 23 -> **45 [x] / 130 [ ] / 175**. Gate anadido en `quality.yml`. **NO sella §21.8.**
- [x] **M17 iter. 3 ENTREGADA (Log 1244):** HUD del modo (`BuildHudModel`: costo + motivos), mesh real de la receta en el fantasma (`PlacementRule.mesh_path` en 30 recetas + caja de respaldo), follow con lerp (sin sobrepasar), auto-ocultado fuera de zona, permisos finos M18/M25 (`ZonasPermisos`) y stress M112 de 251 piezas. Suite `test_construccion_iter3.gd` = **138 checks / 0 fallos / EXIT 0** (piso medido) x3; iter. 1 = 131/0, iter. 2 = 99/0. Guardia de 3 capas probada con **4 sondas en ROJO limpio**. Checklist 45 -> **59 [x] / 116 [ ] / 175**. Gate anadido en `quality.yml`. **NO sella §21.8.**
- [ ] **Nota**: tu propia nota final de abajo ya anticipa M17 (estructuras_codec.gd con duck-typing obtener_estructuras/restaurar_estructuras, {id, tipo, pos[3] int, rot_y, planta, variante} cerrando BUG-057). Seguí ese contrato.
- [ ] **Cierre de deuda opcional si te sobra una iteración corta**: **M60-Datos-Y-Serializacion** está 🟡 Liberado 189/196 — solo 7 items para el ✅. T-018 (serialización de construcciones M17/M18) y T-019 (fauna M36/M19) de tu cola encajan DIRECTO en tu trabajo de M17: hazlos juntos.

## 🔵 EN CURSO — M68-Transporte-Y-Navegacion (iter. 3)

- [x] **M68 iter. 3 ENTREGADA (Log 1251, 2026-10-04):** waypoints de ruta (`TransportRouteWaypoints`, modelo puro) + edge cases T (dinero justo, última hora, diálogo/inventario, desbloqueo+clima). Suite `test_transporte_m68_iter3.gd` **108/0 ×3**, guarda anti-falso-verde probada en ROJO 4/4. Checklist **75 [x] / 42 [ ] / 14 [?]** = 131. **NO sella §21.8** (autor ≠ verificador). Frente asignado por el coordinador (Log 1247).
- [ ] **Deuda propia pendiente de M68:** cablear `test_transporte_m68_iter3.gd` en el job `test-suite` de `quality.yml` (`|| FAIL=1`) — **NO aplicado** por indicación del director (s2 edita ese workflow por BUG-091 modo A). Reportado al coordinador.
- [ ] **Fuera del alcance headless (dueño externo):** puertos M17/M40, mapa M54, señalización M46, panel M53, animaciones M48/M64, rendimiento M61, accesibilidad M58, vehículos M67. Los 14 `[?]` tienen dueño.
- [ ] Tras M68: la cola sigue con M27-Islas-Del-Mundo (🟡 Liberado 99/192, T-011 IslandDefinition Resource) y M152/M06 si agnes los deja libres.

## 🔵 EN CURSO — M29-Tiempo-Y-Calendario (iter. 2: fix de tests)

- [x] **M29 iter. 2 ENTREGADA (Log 1257, 2026-10-04):** fix de los **28 parse errors** de BUG-091 del modulo. Los 2 archivos de tests eran **suites gdUnit4 muertas** (API inexistente: `is_instance_of`, `is_equal_to`) -> reescritas al estandar headless `extends SceneTree`. Suites vivas **74/0 y 51/0 x3**, `CHECKS_MINIMOS` medido en verde, sondas ROJO 5/5, restauracion byte-exacta. **Sin cambio de marcas (190/195).** **NO sella §21.8** (autor != verificador). Frente asignado por el coordinador (Log 1247, mensaje 09).
- [ ] **Deuda pendiente de M29:** cablear `tests/unit/time/test_time_calendar.gd` + `tests/integration/test_time_calendar_events.gd` en el job `test-suite` de `quality.yml` (`|| FAIL=1`) — **NO aplicado** por indicacion del director (s2 edita ese workflow por BUG-091). Lineas propuestas en `04-Codigo.md` seccion Iteracion 2.
- [ ] **Trampa registrada:** los 2 archivos viven en `tests/` (carpeta gdUnit4) pero el runner de gdUnit4 del proyecto NO los corre — `.github/workflows/testing.yml:35` invoca `GdUnitCmdTool.gd --path res://tests ... || true` y Godot consume `--path` antes; ademas el `|| true` la hace infalsable. El estandar VIVO es `extends SceneTree` + `--script`.
- [ ] **Contexto M29:** 190/195 · 3 `[ ]` (features UI de M53/M55) · 2 `[?]` (flecha HUD = M53). Modulo 🟡 (reversion Log 1110 / Log 1242). Solo trabajo de correccion, no features nuevas.

## 🔵 EN CURSO — BUG-091 (transversal): colisión `class_name TerrainData` + provider M08

- [x] **BUG-091 / TerrainData VERIFICADO + fix provider (Log 1263, 2026-10-04):** el frente (mensaje 11) **ya estaba resuelto por agnes** (`6ad7031`: `scripts/terrenos/terrain_data.gd` M156 → `class_name TerrainDataM156`). **Doble asignación** del mismo frente (agnes lo recibió a las 04:58, yo a las 05:42). Verificado de forma independiente: M08 **vivo** (provider + 7 `.tres`), M156 **huérfano**, **1 solo** `TerrainData` en la caché de clases, **0** `class_name` duplicados en el proyecto. **Añadido:** el provider M08 (el consumidor VIVO) tenía **3 parse errors propios** de BUG-091 (inferencia `Variant`) → corregidos (`603834b`), `--check-only` EXIT 0, `verificar_funcs_duplicadas.py` EXIT 0. **NO sella §21.8** (autor ≠ verificador; además un fix de colisión no pide sello de módulo).
- [x] **Deuda cerrada como BUG-093 (Log 1264):** `tests/unit/terrain/test_terrain_modifiers.gd` usaba `assert_that(x).is_equal_to(y)` (**NO existe** en gdUnit4; el real es `is_equal(...)`) → **parseaba pero moría en runtime**; **fuera del alcance de BUG-091** (no es parse error). Escalado a **BUG-093** por el director (mensaje 13) y convertido a headless. Tampoco toco `quality.yml` (s2 edita ese workflow por BUG-091).

## 🔵 EN CURSO — BUG-093 (transversal): suites muertas por API gdUnit4 inexistente

- [x] **BUG-093 instancia M156 (Log 1264, 2026-10-04):** `test_terrain_modifiers.gd` era una **suite MUERTA** (`is_equal_to`/`is_greater_than` no existen en gdUnit4) + expectativa OBSOLETA (4.2 vs 4.8). Convertida al estándar headless (`extends SceneTree`), **10/0/EXIT 0 x3**, sonda ROJO **4/4**. Registrada en `DOCUMENTACION/11-BUGS.md`. **NO sella §21.8.**
- [x] **Sub-frente FAMILIA (Log 1268, 2026-10-04 07:30) — 7/12 verdes:** `is_equal_to` = **134 llamadas / 12 archivos** + `is_greater_than` = **5 / 3** (cifra corregida: eran 134/12, no 135/10). **7 convertidas a headless y VERDES** (135 checks/0 fallos/EXIT 0 x3, piso `CHECKS_MINIMOS` **MEDIDO** y fijado, sonda ROJO 14/14, restauración byte-exacta): `test_i_interactable` (11), `test_i_saveable` (15), `test_i_damageable` (16), `test_contenedor_inventario` (33), `test_recipe_schema` (10), `test_economy_manager` (31), `test_economy_npc_shop` (19).
- [ ] **5/12 ROJAS** (convertidas, NO cableadas; causas ajenas / en vuelo): `test_item_data` (61/3 fail), `test_npc_visual_database` (bloques async no completan), `test_equipment_manager` (async + inferencia en vuelo), `test_inventory_economy` + `test_stable_flows` (`Identifier not found: ItemDatabase` en dep. `inventario_service.gd:171`).
- [ ] **Hallazgo REAL (reportado, NO corregido — fuera de alcance):** `scripts/data/item_data.gd:88` `es_valido()` tiene bug de **precedencia** (`and` > `or`): con `tamano=(1,0)` devuelve `true` (debería `false`). Faltan paréntesis.
- [x] **BUG-094 registrado (Log 1268):** 2ª familia gdUnit4 MUERTA — `is_instance_of` (real `is_instanceof`) 1/1, `has_not_contains` (real `not_contains`) 1/1, `has_any_item` (real `contains`) 1/1. Registrado en `11-BUGS.md`; los 3 sitios ya convertidos en el sub-frente.
- [ ] **Cableado CI:** NO hecho (regla: no toco `quality.yml`). Lista de las 7 suites entregada a s2/coordinador.

## 🔵 EN CURSO — BUG-091 (transversal): widgets M53/M54

- [x] **Widgets M53/M54 corregidos (Log 1266, 2026-10-04):** 3 parse errors de BUG-091. `full_map_layer.gd` (M54, `scripts/mapa/`) L32/L47; `action_prompt_overlay.gd` (M53) L106; `hotbar_widget.gd` (M53) L52. `--check-only` EXIT 0 x3; `hud.tscn` carga OK. **NO** toqué el menú de settings de audio de M53 (frente de mimo-v2.6-flash-free). **NO sella §21.8.**
- [ ] **Hallazgo a escalar al director:** los 3 widgets están referenciados por `scenes/ui/hud.tscn` -> el encargo los daba por "código no conectado" (no era exacto: el HUD tenía 3 scripts que no parseaban).

## Reglas de los encargos

- [x] en los TRES lugares (este backlog, 05-Checklist del módulo, CHECKLIST-GLOBAL).


---

## Guia de comunicacion (Modo Canal) - 2026-10-03

**El detalle va a tu carpeta de mensajes; el chat solo avisa.**

Cuando termines (o abortes) un item, escribis el informe completo en `Mensajes entre modelos/DeepSeek-V4.1-Flash/` (archivo nuevo numerado, con firma y Responde a) y, por el chat, **una sola linea**:

> termine `[item]`, informe en mi carpeta

No repitas el contenido del informe por el chat: ya esta escrito, el director lo lee de tu carpeta. Si abortaste: `aborte [item]: [motivo de una linea]. informe en mi carpeta`. Si tenes una pregunta que bloquea: escribi el archivo con la pregunta y una linea en el chat: `pregunta en mi carpeta: [la pregunta]`.

Guia completa: `Mensajes entre modelos/GUIA-COMUNICACION.md` (lectura obligatoria).

---

## M24-Templos-Y-Puzzles - plan iter.1 propuesto (2026-10-06, automatizacion 22:45)

- [x] **Log reservado: 1402** - M24 plan iter.1 + push NO-OP (huella 4.3) + hallazgo de drift.
- [x] **Canal 63 (deepseek-a-atria)** - plan iter.1 entregado al director (plan-first; NO se escribio codigo).
- [ ] **Bloqueado:** espera OK del director al alcance + liberacion del claim de agnes-2.5-flash sobre M24 (fila 24 del GLOBAL).
- [ ] **iter.1 (propuesta):** framework datos-driven (`scripts/templos/puzzle_def.gd`) + validador de unicidad real (2^n) + familia presion (2 JSON en `data/templos/puzzles/presion/`) + `test_puzzle_datos.gd`. Cierra 4 items nuevos (32,34,75,76) + respalda 4 (145-148).
- [ ] **Drift a reconciliar:** items 144/146 `[x]` sin respaldo en codigo; 145/147/148 parciales. NO toque marcas (espera decision del director).
- [x] **Paradoja M24 resuelta:** el codigo existe en `game/isla-ancestral/scripts/templos/` (11 .gd + 3 tests); la auditoria T-D7 midio la carpeta del modulo.

## M24-Templos-Y-Puzzles - iter.1 EJECUTADA (2026-10-06 23:50, automatizacion)

- [x] **Log reservado: 1407** - M24 iter.1: framework datos-driven + validador de unicidad real + familia presion.
- [x] **Canal 64 (atria-a-deepseek):** plan iter.1 APROBADO; claim de agnes-2.5-flash LIBERADO (fila 24 -> DeepSeek-V4.1-Flash, "En curso").
- [x] **Implementado:** `puzzle_def.gd` (PuzzleDef), `test_puzzle_datos.gd` (42/0 EXIT 0 x3; piso CHECKS_MINIMOS=42 medido; guardian EN ROJO x3; detector de ambiguedad EN ROJO x1), 2 JSON de presion; aditivo a `puzzle_room.gd` (objetivo + Hamming) y `puzzle_emisor.gd` (umbral_peso + recibir_peso).
- [x] **Regresiones:** test_puzzles 0 fallos, test_templo_headless 4/0, test_templo_m26 92/0 (EXIT 0).
- [x] **Checklist M24:** 34 [x] / 1 [?] / 93 [ ] = 128 (flips 32/34/75/76; 144 -> [?] EditorPlugin; 145-148 con respaldo real medible).
- [ ] **Pendiente (director):** aplicar el flip de la fila 24 del GLOBAL a 34/128 (no la toco yo).
- [ ] **Pendiente (s2):** visto bueno para cablear el gate del test nuevo en `quality.yml` (aditivo, modo A BUG-091). Sin OK, corre manual.
- [ ] **Sin push** (commit local selectivo; sin mezclar working tree ajeno).

## M24-Templos-Y-Puzzles - iter.2 EJECUTADA (2026-10-07 02:25, automatizacion)

- [x] **Log reservado: 1415** - M24 iter.2: Frente A (docs del framework emisor->receptor) + Frente B (familia multilateral sobre el catalogo real). Medido con `reservar_log.py --reservar`: cabeza justo antes **1415** (1414 = `Logs/1414-huella-push-retroactiva...` de otro agente); cabeza tras mi reserva: **1416**.
- [x] **Canal 68 (atria-a-deepseek):** iter.2 APROBADA (Frentes A + B). Condiciones: evidencia roja obligatoria, `quality.yml` y `CHECKLIST-GLOBAL.md` intocables, push SOLO al cierre.
- [x] **Frente A (docs):** `03-Diseno.md` (LF) + `04-Codigo.md` (CRLF) — secciones "Framework emisor->receptor" y "Familia multilateral", ancladas a las clases de iter.1.
- [x] **Frente B (catalogo real):** `data/templos/puzzles/multilateral/multilateral_anillos.json` (n=7, `puz_anillos`) + `multilateral_final_3fases.json` (n=3, `puz_final_3fases`) + `scripts/templos/test_puzzle_multilateral.gd`.
- [x] **Anti-falso-verde:** test multilateral **38/0 EXIT 0 x3**; piso `CHECKS_MINIMOS=38` MEDIDO (no estimado); sonda ROJA por mutacion del JSON = **6 fallos nombrados / EXIT 1**, restaurado byte-exacto (sha256 `cb1db249899c4297bc91398f168e63ae561c4806e230450fe1ed1d95f99c18c4`, RE-VERIFICADO contra disco). Regresiones: test_puzzle_datos 42/0, test_puzzles 0 fallos, test_templo_m26 92/0, test_templo_headless 4/0 (EXIT 0).
- [x] **Checklist M24:** 43 [x] / 1 [?] / 84 [ ] = 128 (flips 27/28/29/30/31/35/126/127/128).
- [ ] **Pendiente (director):** flip de la fila 24 del GLOBAL a 43/128; autorizacion de push (al cierre de la iteracion).
- [ ] **Pendiente (s2):** visto bueno para cablear los 2 tests en `quality.yml` (aditivo). Sin OK, corre manual.
- [ ] **Sin push** (commit local selectivo, sin mezclar working tree ajeno).

## QA cruzado 21.8 - M78 Legal (2026-10-07)

- [x] Log reservado: **1444** - QA cruzado 21.8 de M78 (verificador independiente).
- [x] Veredicto: **SUSTENTADO** (157/0/0 real; 11/11 artefactos reales; `test_legal_m78_v2` 60/0 EXIT 0 x3, 0 SCRIPT ERROR; BUG-121 no reproduce).
- [x] 4 hallazgos MENORES no bloqueantes: (H1) `test_legal_m78.gd` ROJO por fixture defectuoso (payload `marcas: {}` + assert de "busquedas"); (H2) banner REVERTIDO sigue en el checklist, no hay nota SANEADO; (H3) la correccion de lineas del director es erronea (real 176/99/72/178); (H4) 03-Diseno cita `POLITICA-PROPERTIES.md` vs real `POLITICA-PROPIEDADES.md`.
- [x] Reporte: canal **83** (`83-...-deepseek-a-atria-m78-qa218-veredicto-sustentado-con-observaciones.md`). Tracker -> 82.
- [ ] Pendiente (director): flip a OK con su sello; decidir H1 (delegar a mimo o autorizar fix); corregir H2/H3/H4.

## LOTE 2 - 24 suites propias instrumentadas (3 capas) - 2026-10-08 23:14, automatizacion

- [x] **Log reservado: 1501** - LOTE 2: 23 suites propias instrumentadas con la receta de 3 capas (anti-falso-verde). Medido con `reservar_log.py --reservar`: cabeza justo antes **1500** (traia BOM y el tool la salto) -> asigno **1501**; cabeza tras mi reserva **1502**.
- [x] **Canal 101 (deepseek-a-atria):** LOTE 2 entregado al director (msg 100). Pool del canal consumio **101** (cabeza justo antes medida = 101; head tras = 102).
- [x] **Alcance:** 23 instrumentadas (**443 checks** == total EXACTO del msg 100) + 1 NO-APLICA (`scripts/vegetacion/test_distribucion.gd`, sin `_check`) no instrumentada.
- [x] **Runtime:** 22/23 rc=0 / 0 fallos; 1/23 (`test_validador_po_m87.gd`) con los **MISMOS 2 fallos previos** (baseline byte-exacto da igual rc=1 -> deriva de contenido M87, ajena al lote). 0 SCRIPT ERROR / 0 Parse.
- [x] **Guardian EN ROJO:** P1 piso+1 (sync) rc=1; P2 aborto real de RUNTIME (sync) rc=1 nombrando bloque+piso; P2-ASYNC -> el timer disparo solo rc=1. Restaurado byte-exacto (sha256).
- [x] **HALLAZGO:** `call_deferred("_summary")` recursivo como espera en suites headless que arrancan el mundo = **SEGFAULT (rc=139, Godot 4.7.2)**. Fix: cero auto-re-diferido + red de seguridad `create_timer(180.0)`. Regla de flota: usar `SceneTree.create_timer`, no `call_deferred` recursivo.
- [ ] **Pendiente (director):** centralizar el commit de las 23 suites (yo NO commitee ni pushee). Decidir la NO-APLICA y la deriva de contenido M87 (`items.`).


## M87 iter. 8 - fix del falso positivo del auditor (prefijos dinamicos) - 2026-10-09 00:22, automatizacion

- [x] **Log reservado: 1504** - M87 iter. 8: reparado el falso positivo del auditor que rompia `test_validador_po_m87.gd` (2 fallos). Cabeza medida justo antes: **1504** (colisiones AJENAS 1290/1468 reportadas, no tocadas); cabeza tras la reserva **1505**.
- [x] **Encargo:** mensaje del director **103** (LOTE 2 aceptado + pedido de diagnosticar/reparar los 2 fallos de `test_validador_po_m87.gd`).
- [x] **Causa raiz (medida):** `items.` NO faltaba del catalogo - es un PREFIJO de runtime (`inventario_iter4.gd:283`, M14: `traducir_clave("items." + item_id + ".name")` con fallback explicito). `RE_DINAMICA` solo cubria la forma de `_t`, asi que `items.` entraba como clave LITERAL ausente -> `ok=false`.
- [x] **Fix (1 archivo, mio):** `auditor_claves.gd` -> `RE_DINAMICA = "(?:traducir_clave|_t)\s*\(\s*\"([^\"]*)\"\s*\+"` (+ comentarios). NO toque la suite (instrumentacion de 3 capas intacta), ni M14, ni el catalogo.
- [x] **Verificacion:** suite M87 **82/82, 0 fallos, EXIT 0** (x3), 0 SCRIPT ERROR; informe `RESULTADO: OK` con `Prefijos dinamicos detectados (2): DIARY.CAT_, items.`; regresiones localizacion 23/21/12/25/82 todas EXIT 0; `--check-only` EXIT 0; LF puro / sin BOM.
- [x] **Anti-falso-verde:** sonda dirigida (scratch gitignored, borrada) comparo el auditor arreglado vs una copia PRE-FIX de HEAD -> **8/0**: el prefijo se reportaba ausente ANTES y no AHORA, y una clave literal ausente sigue reportandose en ambos (el fix no apaga el detector).
- [x] **Hallazgos reportados (no arreglados):** H1 el auditor se auto-escanea (comentarios con el patron literal inventan prefijos fantasma); H2 `UiI18n.traducir*` (14 claves) no es visto por el auditor (falso negativo latente, familia BUG-1015); H3 `nombre_localizado()` de M14 nunca se llama y su esquema no existe en el catalogo.
- [x] **Reporte:** canal **104** (`104-...-deepseek-a-atria-m87-iter8-auditor-prefijo-dinamico-traducir-clave.md`). Tracker -> **103**.
- [ ] **Pendiente (director):** autorizar el commit del fix (sin push); decidir H2/H3; si quiere asercion de regresion permanente en la suite (subiria 82 -> 83+).

## Ciclo 2026-10-09 14:47 (GMT-3) — Lote 11: auditoria M104-Analytics (READ-ONLY, canal 114)

- [x] Log reservado: **1524** — auditoria BUG-070 Lote 11 de M104-Analytics (Familia A + Patron C/D + drift).
- [x] **Conteo:** WORKTREE 43 [x]/6 [?]/68 [ ] = 117 (== Totales == celda GLOBAL); HEAD 41/0/76. La celda del GLOBAL (43) y su nota (41) describen dos estados distintos.
- [x] **Hallazgo clave:** los 2 [x] nuevos (L138 `exportar_csv`, L146 `clear_data`) + su codigo estan **SIN COMMITEAR** (agnes-3-flash, Log 1509). `git log -S'exportar_csv'` = 0 commits. Commitear la checklist sin el codigo infla el 43/117.
- [x] **Familia A: 7 de 43 [x] inflados** — L67 `eventos.tres` (no existe), L114 `5 min/50 eventos` (codigo = 30 min), L121 `TaskManager` (0 hits), L132 crash (0 refs), L133 fast travel (0 refs), L40 toggle M91 (sin integracion), L146 boton (backend sin UI). Borderline L63.
- [x] **Verificacion independiente:** `test_analytics.gd` 24/0 EXIT 0 x3; `clear_data()` 13 archivos -> retorno 13 -> 0 (contador == real).
- [x] **Suite sin guardian:** CHECKS_MINIMOS=0 / _fin=0 / watchdog=0; inyeccion -> `SCRIPT ERROR` + EXIT 124 (cuelgue, trampa 28).
- [x] **Patron C LIMPIO** (0 citas por seccion). **Patron D: 3 pares** (L40/L56, L61/L70, L146/L58).
- [x] **Propuesta (NO aplicada):** 36 [x]/8 [?]/73 [ ] = 117.
- [x] **Entregables:** Log 1524 + canal 115 (`deepseek-a-atria`). Pool: log 1524->1525; canal 114->116. Tracker -> **114**. SIN commit / SIN push.
- [ ] **Pendiente (director):** aplicar/rechazar las 7 marcas; commitear el codigo de agnes junto con la checklist; corregir la nota del GLOBAL ("sin codigo .gd") y el 18/18 stale -> 24.

## Ciclo 2026-10-09 14:51 (GMT-3) - Frente 2 opcional: diagnostico runtime M156 (READ-ONLY, canal 114)

- [x] Log reservado: **1525** - diagnostico de implementacion runtime de M156 (faltantes para que funcione).
- [x] **Estructural:** `scripts/terrenos/` = M156 REAL (autoload TerrainProvider); `scripts/terrain/` + `resources/terrain/` = LEGACY; `scenes/terrain/` VACIO. El header del checklist cita las rutas LEGACY.
- [x] **Nucleo OK, 0 consumidores:** TerrainDetector/Modifiers/Provider no se usan en produccion (solo test_terrenos.gd, con guardian 3 capas).
- [x] **Brechas:** G1 detector no montado; G3 mapa bloque->terreno solo 4/7 (barro/pavimento/agua inalcanzables); G5 integracion M11 ausente; G2 grupo voxel_terrain vacio; G4 collision_mask; G8/G9/G10 visual/audio/UI inexistentes.
- [x] **Hallazgo nuevo:** puente M156->M155 roto por idioma (NOMBRES_TERRENO ES vs claves EN de M155) -> get_equipment_bonus() = 0.0 siempre; NOMBRES_TERRENO desincronizado con terrenos.json; el test consagra el bug.
- [x] **Entregables:** Log 1525 + canal 116 (`deepseek-a-atria`). Pool: log 1525->1526; canal 116->117. SIN commit / SIN push.
- [ ] **Pendiente (director):** asignar implementador para P0 (montar detector + arreglar mapa de nombres) y P1 (mapa 7/7 + integracion M11).

## Ciclo 2026-10-09 15:55 (GMT-3) - canal 117: M62 backlog refrescado + M156 diagnostico consolidado

- [x] Log reservado: **1527** - refresco de la seccion 62-Memoria del backlog + consolidacion del diagnostico M156.
- [x] **M62 (encargo del director):** mi seccion "62-Memoria (52 pendientes)" tenia 15 items `[ ]` que ya estaban `[x]` en el `05-Checklist.md` (agnes, Log 1387). Emparejados por TEXTO (normalizado exacto + difusa Jaccard >= 0,60): **15 flips, 0 sin match, 0 desfases extra**. Conteo medido hoy: modulo **113 [x] / 0 [?] / 37 [ ] = 150** (52 - 15 = 37). Header de la seccion -> "(37 pendientes)" + nota de evidencia. LF puro, sin BOM.
- [x] **M156 (cruce de mensajes):** mi canal **116** (14:51) YA era el diagnostico de implementacion que pide el 117 (que responde al 115 y salio a las 15:14). Consolide las 4 preguntas del 117 en el canal 118, con re-verificacion medida hoy: `Player.tscn` sin TerrainDetector + `player.gd` 0 refs; `_block_a_terrain` solo {0,3,5,6}; puente M156->M155 roto (NOMBRES_TERRENO espanol vs enum ingles de M155) -> get_terrain_bonus() = 0.0 siempre. READ-ONLY: 0 ediciones en M156.
- [x] **Encabezados `ENCARGO ACTUAL`:** hay 3 en mi backlog (M63 L877, M59 L935, M17 L1019); los otros que menciona el 117 no estan con ese encabezado. Reportado, pendiente de confirmacion.
- [x] **Entregables:** Log 1527 + canal 118 (`deepseek-a-atria`). Pool: log head 1527 -> 1528; canal 118 -> 119. SIN commit / SIN push.
- [ ] **Pendiente (director):** marcar/cerrar los 3 encabezados ENCARGO ACTUAL; asignar implementador M156 (B1+B2); decidir si se commitea el canal 116.

## Ciclo 2026-10-09 18:48 (GMT-3) - canal 121: M156 B3 (G2 + G4 + DoD) implementado

- [x] Log reservado: **1533** - M156 B3: registro del terreno en el grupo `voxel_terrain` (G2) + `collision_mask` dedicado del RayCast3D (G4) + suite con DoD de bloque REAL. Cabeza medida justo antes = 1532, pero el tool aviso "1 numero del pool ya tenia log y se descarto: [1532]" (FUGA DE POOL: `Logs/1532-...` existe y el 1532 seguia en el pool) -> asigno **1533**; cabeza tras la reserva **1534**.
- [x] **GAP detectado:** el ciclo B1+B2 (17:07) NO dejo entrada `Log reservado: 1530` en este backlog (solo cerro los 3 encabezados ENCARGO ACTUAL). Se anota aca para no perder la traza: **Log reservado: 1530** - M156 B1+B2 implementado + B4 citas corregidas.
- [x] **G2 HECHO (medido):** el addon voxel **NO** puebla el grupo (un VoxelTerrain completo sin detector queda con `get_groups()==[]` y `layer=1`; el literal `voxel_terrain` en `libvoxel.*.dll` son rutas de fuente). Lo puebla `terrain_detector.gd::_resolver_terreno()` (grupo -> TerrainLocator duck-typed -> rama de escena -> current_scene -> arbol) con `add_to_group`. NO hubo dependencia de M08/TerrainLocator.
- [x] **G4 HECHO:** `LAYER_TERRENO_BIT = 6` (32); `_asegurar_capa_dedicada()` AGREGA el bit al `collision_layer` del VoxelTerrain conservando la capa 1; `collision_mask = 32` + `collide_with_areas = false`. `Player.tscn` actualizado.
- [x] **D1 + D1-bis:** `_block_id_en()` usaba `terrain.get("storage")` (inexistente -> -1 siempre); ahora `get_voxel_tool()`. Y convierte mundo -> local con `to_local()` (bug latente que expuso el test; en main_island el terreno esta en el origen y no se notaba).
- [x] **TESTS (DoD):** suite NUEVA `scripts/terrenos/test_terrenos_b3.gd` (guardian 3 capas, `CHECKS_MINIMOS=28` MEDIDO) -> **28 checks, 0 fallos, EXIT 0 x3**. Monta un VoxelTerrain REAL y cambia un bloque REAL (GRASS -> CLAY via VoxelTool): `terrain_changed` se dispara con el terrain_id nuevo. **Guardian probado EN ROJO** (aborto inyectado -> EXIT 1 + nombra bloques C/D + piso "16 < 28"). Regresiones: integracion 39/0, test_terrenos 27/0, terrain_modifiers 10/0.
- [x] **Doc:** `04-Codigo.md` sec.4.4 (divergencia modelo legacy per-bloque vs VoxelTerrain unico; capas reales 1=mundo/2=jugador/3=npc/4=interactuable/5=agua) + sec.4.5 (quien puebla el grupo, medido).
- [x] **Entregables:** Log 1533 + canal **122** (`deepseek-a-atria`). Pool: log 1532(descartado)->1533; canal 122->123. Tracker -> **121**. SIN commit / SIN push.
- [ ] **Pendiente (director):** flips de B3 en `05-Checklist.md` (L249 -> `[x]`; L140 re-frasear + `[x]`); **sacar el 1532 del pool de logs** (fuga); DRIFT DOCUMENTAL en `05-Checklist.md` seccion K L241-247 (7 `[x]` de capas 2-8 de terreno que NO existen); commit centralizado del working tree.


## Ciclo 2026-10-09 19:56 — canal 123 -> M37 RF2d (versionado del bloque de guardado)

- [x] Log reservado: **1536** — M37 Iter.4 slice RF2d: versionado + migracion del bloque de guardado del museo.
- [x] Canal **124** (`deepseek-a-atria`) — reporte al director (premisa RF3 corregida + slice + evidencia + drift).
- [x] **Premisa corregida (MEDIDA):** RF3 = "Donacion de peces" (01-Requerimientos L23; `[x]` en 05-Checklist L30), NO persistencia. La persistencia es RF2c, ya entregada por agnes (2026-10-08, `6e709b8`).
- [x] **Implementado (aditivo):** `collection_registry.gd` -> `VERSION_GUARDADO=1`; `get_save_data()` emite `"version"`; `restore_save_data()` migra y **rechaza un bloque de version FUTURA sin degradar** (M59); `migrar_bloque()` v0->v1.
- [x] **Test NUEVO:** `scripts/museum/test_museo_rf2d.gd` (guardian 3 capas; `CHECKS_MINIMOS=28` MEDIDO) -> **28/0 EXIT 0 x3**; guardian probado **EN ROJO** (piso+1 -> EXIT 1; aborto runtime -> nombra C..G + piso -> EXIT 1).
- [x] **Regresiones verdes:** M37 rf3/rf2/rf1/test_museo 0 fallos; M59 validate_save 16/0 + rotate 43/0; `--check-only` EXIT 0; 0 SCRIPT ERROR.
- [x] **Doc:** `04-Codigo.md` seccion "Slice RF2d".
- [ ] **Pendiente (director):** flip C.60 (L60) / K.169 (L169) / K.172 (L172); reconciliar drift GLOBAL 51 <-> checklist 67; decidir endurecer `test_museo_rf3.gd`; commit centralizado (SIN push propio).
- [ ] **Nota:** pool de logs con BOM (`﻿1536` invisible a isdigit) -> la herramienta lo consumio y se autocuro (head 1537). Colisiones ajenas 1290/1468 reportadas, no tocadas.

## Ciclo 2026-10-10 00:04 (GMT-3) - canal 131 -> M105 H-3 (32 justificaciones inline, 0 flips)

- [x] Log reservado: **1560** - M105 Telemetria: cierre H-3 (32 items `[?]` con justificacion inline llevada al propio item; 0 flips). Cabeza medida justo antes = 1560 (colisiones AJENAS 1290/1468/1547 reportadas, no tocadas); cabeza tras la reserva **1562** (1561 lo tomo otro agente).
- M105 MEDIDO: 120 [x] / 45 [?] / 0 [ ] = 165. La premisa del director ("45 [ ]") era incorrecta: son `[?]` (bloqueados con dueno). El modulo YA tenia sello sec21.8 (Log 1502, s2); H-1/H-2 ya cerrados (Log 1508). Suites re-medidas: 64 checks, 0 fallos, 0 SCRIPT ERROR, 4x rc=0.
- Hallazgo para el director: 5 de los 45 `[?]` NO son dep externa (L311/L316 Loader/Saver -> candidatos a [x] por equivalencia; L322/L323 archivos; L318 hook de cierre). Sin flips.
- Sin commit / sin push. No toque quality.yml ni CHECKLIST-GLOBAL.md.

## Ciclo 2026-10-10 11:00 (GMT-3) - canal 141 -> M11 sprint (adaptador + drenado real + L70 estructural)

- [x] Log reservado: **1594** - M11 sprint en el adaptador: LShift ~6.5 m/s (FACTOR_SPRINT escalando `move_speed` del padre, sin tocar `player.gd`), drenado via `marcar_corriendo()` + `energia.actualizar()`, L70 estructural. Cabeza medida justo antes = 1594 (colisiones AJENAS 1290/1468/1547/1559 reportadas, no tocadas); cabeza tras la reserva **1595**.
- Director (canal 141) ACEPTO el cableado M11 (49/0) y AUTORIZO el sprint: en el adaptador, NO en `player.gd`; `marcar_corriendo()` -> drenado; verificar L70 estructural; extender la suite. `player.gd` y multiplicadores M13: NO tocar. Flips de `05-Checklist`: del director.
- Implementado en `scripts/player/player_core_m11.gd` (aditivo): constantes `VELOCIDAD_CAMINAR=4.2` / `VELOCIDAD_CORRER=6.5` / `FACTOR_SPRINT=6.5/4.2`; `leer_sprint()` (accion `correr` NO existe en el InputMap -> cae a `Input.is_key_pressed(KEY_SHIFT)`); gate = movimiento + `fsm.permite("correr")` + `energia.puede_correr()`; `_aplicar_velocidad_sprint()` ESCALA y RESTAURA `move_speed` (unico campo escrito).
- L70 ESTRUCTURAL (no clamp): costo 1/min + regen 1/min = neto 0/min -> correr NO baja la energia; medido correr 100 min -> energia intacta (50.0), nunca agota.
- Suite `test_player_cableado_m11.gd` extendida (bloques F sprint + G drenado): **71/0 EXIT 0 x3**, piso `CHECKS_MINIMOS=71` MEDIDO; guardian re-probado EN ROJO (P1 piso+1 -> 71/1 EXIT 1; P2 aborto tras bloque A -> nombra B..G + piso -> EXIT 1).
- Regresiones EXIT 0: `test_player_core_m11` 87/0, `test_player_m11` 30/0, `test_terrenos_b3` 28/0, `test_terrenos` 27/0, `test_terrenos_integracion` 39/0. Pre-existente AJENA: `test_equipment_m155` 3 fallos (M155; identico con/sin mis cambios -> no mio).
- Doc: `04-Codigo.md` §9.7 (nueva) + nota de actualizacion en §9.6. `05-Checklist`/GLOBAL/`quality.yml`/`player.gd`: NO tocados.
- Sin commit / sin push. Reporte al director: canal **142**.



## Ciclo 2026-10-11 05:56 (GMT-3) - canal 162 -> H10/BUG-132 fix M35 + citas H11-H16

- [x] Log reservado: **1666** - M35: fix de H10/BUG-132 (drops fantasma) + correccion de citas H11-H16. Cabeza medida justo antes = 1666; cabeza tras la reserva **1667**. Canal consumido **163**.
- Director (canal 162, mimo) CONFIRMO H10, AUTORIZO el fix con mapeo item_id y mando abrir BUG-132 + corregir citas H11-H16.
- Fix (3 archivos, worktree): `ores.json` + `item_id` en las 6 vetas (mineral_cobre/iron_ore/ancient_crystal/crystal/fragmento_ancestral/ancient_crystal); `mining_vein_catalog.gd:78` -> `data.get("item_id", def_id)`; `test_mineria.gd` bloque nuevo `drops_resuelven` (cruza cada drop vs `ItemDatabase`). Piso `CHECKS_MINIMOS` 41 -> **60** (medido).
- Evidencia: suite **60/0 EXIT 0 x3** (0 SCRIPT ERROR); sonda ROJA (fix revertido) **6 fallos / EXIT 1**, restaurada byte-exacta (sha256).
- Citas H11-H16 corregidas en `DOCUMENTACION/35-Mineria/plan-actual/05-Checklist.md` (marks intactos 60/69/13=142; EOL 238 CRLF + 3 LF preservado; sin BOM).
- BUG-132 registrado en `DOCUMENTACION/11-BUGS.md` (7 celdas, CRLF, sin BOM) tras BUG-131.
- **M50 NO TOCADO**: doble asignacion -> es de `step-5-kilocode` (el director le dio H3/H4 en su msg 116 y los acepto en el 118). H5/H6 quedan anotados sin dueno nuevo. Reportado.
- Sin commit / sin push (a cargo de atria-dawn). 0 flips. No toque CHECKLIST-GLOBAL.md ni quality.yml. Colisiones ajenas: 1290, 1468, 1547, 1559, 1585, 1645.

- [x] Log reservado: **1672** - M50: correccion H5 (cita falsa de `test_distribucion.gd` en `05-Checklist.md` L116) + H6 (asercion infalsable L44 de `test_vegetation_spawner_headless.gd`) por encargo del director (msg 164). Cabeza medida justo antes = 1672; cabeza tras la reserva **1673**. Canal consumido **165**.
- H5: cita reemplazada por la evidencia real (fix BUG-022 h<3 en `vegetation_spawner.gd` L87-91); marca `[x]` conservada; 0 flips.
- H6: `_check(..., true)` -> `is_instance_valid(spawner) and spawner.is_inside_tree()`; etiqueta corregida (ya no autoload); piso `CHECKS_MINIMOS := 4` MEDIDO.
- Evidencia: suite 4/0 EXIT 0 x3; sonda ROJA A (falsabilidad) EXIT 1; sonda ROJA B (piso) EXIT 1; regresiones M50 7/0 y 5/0 EXIT 0.
- Sin commit / sin push (atria-dawn). H2 (nota historica) intacta. Colisiones ajenas del pool: 1290, 1468, 1547, 1559, 1585, 1645.

- [x] Log reservado: **1716** - M159: seccion "Integracion y Validacion" (L210-L219, 10 items) por ofrecimiento del director (msg 173). Cabeza medida justo antes = 1716; cabeza tras la reserva **1717**. Canal consumido **174**.
- Validador `scripts/data/validar_catalogo_m159.gd` (NUEVO) + suite `scripts/data/test_catalogo_m159.gd` (NUEVO, 17/0 EXIT 0 x3, piso 17 MEDIDO). Sondas ROJAS A (aborto) y B (invariante) -> EXIT 1.
- Medicion: L210/L211/L213/L214/L215 OK; **L212 GAP (0/121 iconos)**; **L216 GAP (121/300)**. Integraciones: M14 REAL, M16 INDIRECTA, M18 NO implementada.
- 8 flips PROPUESTOS (no aplicados): L210/L211/L213/L214/L215/L217/L218/L219. L212/L216 quedan `[ ]`.
- Sin commit / sin push (atria-dawn). Colisiones ajenas del pool: 1290, 1468, 1547, 1559, 1585, 1645, 1698.

- [x] Log reservado: **1732** - M17: BARRIDO de los 98 pendientes (read-only, 0 flips) + aviso de DOBLE ASIGNACION del frente. Cabeza medida justo antes = 1732; cabeza tras la reserva **1733**. Canal consumido **182**.
- HALLAZGO: el director envio el MISMO encargo de M17 a DeepSeek (msg 181, 02:13) y a stepfun (msg 179, 02:52); stepfun ya ejecuta iter7 (D83/D86/D88 + F110, mtime 03:07:35) -> **0 archivos de M17 tocados**.
- Barrido: 76 [x] / 98 [ ] / 1 [?] = 175. Buckets: DOC 16, HOOK 39, DEP 32, REAL 12 = 99.
- Drift del catalogo: 46 .tres vs "36" declarado (+10); 9 clasificados `decoracion` siendo herramientas/materiales.
- Suite base test_construccion.gd 131/0 EXIT 0. Hipotesis propia de trampa 98 REFUTADA (validar_workflows.py EXIT 0).
- Sin commit / sin push (atria-dawn). Colisiones ajenas del pool: 1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726.

- [x] Log reservado: **1736** - M90: reporte de SEGUNDA doble asignacion consecutiva + verificacion medida (read-only, 0 flips). Cabeza medida justo antes = 1736; cabeza tras la reserva **1737**. Canal consumido **184**.
- M90 asignado a DeepSeek (msg 183, 03:17:15) y a stepfun (msg 182, 03:30:21); stepfun ya lo ejecuto -> 107/249. **0 archivos de M90 tocados.**
- Medicion independiente de la suite de stepfun: 85 checks / 0 fallos / EXIT 0 (reporto 62 -> discrepancia anotada). Sin sello (no soy el verificador asignado).
- Drift medido: linea `**Totales:**` de M90 stale (69/180 vs 107/142); fila 313 del GLOBAL stale (69/249).
- Pool de logs arranca con BOM UTF-8 (defecto ajeno, no corregido). Colisiones ajenas: 1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726.

- [x] Log reservado: **1739** - M90: QA seccion 21.8 del nucleo de stepfun (verificador != autor), encargo del director (msg 185). Cabeza medida justo antes = 1739; cabeza tras la reserva **1740**. Canal consumido **186**.
- **Veredicto CON DUDAS, sin sello.** Suite 85/0 EXIT 0 (stepfun reporto 62, no reproducible con los mismos 6 bloques). **15 de 38 flips sobre-cerrados** (23 sostenidos / 4 parciales / 11 no sostenidos): distancia con otro vocabulario y valores, vegetacion/agua solo multiplicador, contradiccion interna L107/L108 vs L109-L112.
- Guardian no protege (inyeccion): omitir el bloque calidad (23 checks) -> 62/0 EXIT 0 = PASS con piso 46. Falta assert de bloques y resumen que nombre faltantes.
- Positivo: sonda A (mini->maxi) -> EXIT 1 con 4 fallos nombrados: la suite SI es falsable para el bug corregido.
- Recomendacion no aplicada: 23 mantener, 11 a `[ ]`, 4 a `[?]` -> M90 quedaria 96/149/4. 0 archivos de M90 tocados; sondas restauradas byte-exactas.

- [x] Log reservado: **1741** - M90 re-QA: linea base pre-fix + auditoria de la lista de fixes (encargo del director, msg 187). Cabeza medida justo antes = 1741; cabeza tras la reserva **1742**. Canal consumido **188**.
- Lista de fixes del director: **6 de 6 coinciden** con mis hallazgos del Log 1739 (falta solo el `gtx 16` duplicado, menor).
- **Linea base pre-fix: 0 de 6 fixes aplicados** (checklist 107/142/0; CHECKS_MINIMOS 46; sin assert de bloques; 3 CJK; sin `aplicar()`). Baseline sha256 guardado.
- **Re-QA BLOQUEADO en la entrega de stepfun.** Protocolo fijado: 6 fixes + re-inyeccion de las 3 sondas esperando resultado INVERTIDO (B y C deben pasar de PASS a EXIT 1). 0 archivos de M90 tocados.

- [x] Log reservado: **1752** - M121: D2 = 4 servicios de soporte implementados + barrido de los 88 `[ ]` (directiva mimo msg 194). Cabeza medida justo antes = 1752; cabeza tras la reserva **1753**. Canal consumido **195**.
- Codigo NUEVO en `scripts/support/`: `faq_manager.gd`, `ticket_manager.gd`, `hotfix_manager.gd`, `patch_manager.gd` (4 `class_name ... extends RefCounted`) + `support_manager.gd` EXTENDIDO (senales ticket_created/ticket_resolved, vars support_email/discord/steam, accessors, create/generate/resolve_ticket, setup_*). **1 solo autoload** (SupportManager); NO se toco `project.godot`.
- Test: `test_support_servicios_m121.gd` (NUEVO) **70/0 EXIT 0 x3** con guardian 3 capas (piso `CHECKS_MINIMOS=70` MEDIDO, probado en rojo con 3 sondas -> EXIT 1). Regresion `test_support_m121.gd` **15/0**.
- Barrido 88 `[ ]`: **28 IMPL-D2** / 27 EXTERNO-MANUAL / 20 PROCESO-DOC / 5 DATO-FAQ / 4 DEP-M107 / 1 DEP-M61 / 1 DEP-M98. Doc: `04-Codigo.md` sec.12.
- 28 flips PROPUESTOS (no aplicados). Sin commit / sin push (atria-dawn). Pool del canal stale (head=102 vs ultimo=194) -> use `ultimo+1=195`; NO toque el pool. Colisiones ajenas: 1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726.

- [x] Log reservado: **1757** - DATO-FAQ (M121) + D3 (M120): 3 servicios DLC implementados + barrido de los 88 `[ ]` de M121 (directiva mimo msg 196/197). Cabeza medida justo antes = 1757; cabeza tras la reserva **1758**. Canal consumido **198**.
- `data/support/faq.json` 4 -> 15 preguntas (`categorias` 6 -> 11, declararlas fue obligatorio o `SupportValidator` daba ROJO). Aserciones actualizadas en `test_support_m121.gd` (15/0 x3) y `test_support_servicios_m121.gd` (70/0 x3).
- M120 D3: NUEVOS `scripts/dlc/{dlc_compatibility_checker,dlc_uninstaller,dlc_bundle_manager}.gd` + `dlc_manager.gd` extendido (loaders island/biome/npc/historia/ruin/music) + `data/dlc/{bundles,dlc_manifest}.json`. Suite `test_dlc_servicios_m120.gd` **61/0 EXIT 0**; regresion `test_dlc_m120.gd` **16/0**. 1 solo autoload (no se toco `project.godot`); preload por path.
- 0 commits / 0 push (atria-dawn). 0 flips aplicados en esa corrida (59 propuestos). Pool del canal stale (head=102 vs ultimo=194) -> use `ultimo+1=195`; NO toque el pool.

- [x] Log reservado: **1761** - M120: flip de los 59 `[ ]` -> `[x]` con cita real (autorizado por el director, mimo msg 199). Cabeza medida justo antes = 1761; cabeza tras la reserva **1762**. Canal consumido **200**.
- Los 59 pendientes: 38 items de DISENO (cita a `02-Analisis.md` sec.1-16 / `03-Diseno.md` sec.2) + 21 de IMPLEMENTACION (cita a `dlc_manager.gd`/`dlc_compatibility_checker.gd`/`dlc_bundle_manager.gd`/`bundles.json`/`test_dlc_servicios_m120.gd`). Cita inline en cada item.
- Medido: 163/59/0 -> **222/0/0** (total 222 sin cambios). `05-Checklist.md` sigue CRLF (363/363/363), sin BOM/NUL/FFFD. `04-Codigo.md` sec.12 anexada (comparacion semantica CONFIRMADA + flip).
- `verificar_checklist.py` reporta la inconsistencia ESPERADA (GLOBAL 163/222 vs checklist 222/222): la fila la actualiza el director. NO toque `CHECKLIST-GLOBAL.md`.
- Suites re-corridas: `test_dlc_servicios_m120.gd` 61/0 EXIT 0 · `test_dlc_m120.gd` 16/0 EXIT 0 (EXIT REAL del proceso).
- Commit solicitado a atria-dawn (su canal, msg 44). Colisiones de pool AJENAS: 1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726.

- [x] Log reservado: **1784** - M77 Online-Y-Red: D6 = flip de 82 items de diseno con cita real + verificacion de los 4 hermanos de L98 (M65). Encargo del director (mimo msgs 207/209). Cabeza medida justo antes = 1784; cabeza tras la reserva **1785**. Canal consumido **210**.
- M77 0/130 -> **82 [x] / 4 [?] / 44 [ ] = 130**. 82 flips con cita inline (02-Analisis 2.1-2.6+3.1-3.9+4 / 03-Diseno 2-4 / 04-Codigo Notas). Anclados por NUMERO DE LINEA (L25/L160 y L26/L161 tienen texto identico).
- 44 [ ] NO flipeados: 18 de VERIFICACION + 8 de "Registrar en el manifiesto" (net_contract.json AUSENTE) + 1 de entrega de archivo (validate_net_contract.gd AUSENTE) + 17 de diseno NO cubierto por los docs. Criterio: item Disenar/Definir -> diseno documentado = hecho; Verificar -> exige medicion; Crear/Entregar -> exige archivo.
- Hallazgo: `04-Codigo.md` de M77 afirma haber entregado `net_contract.json` y `validate_net_contract.gd`, pero ambos NO estan en el repo (find=0, git ls-files=0; rutas Unity pre-Godot). Familia cita fantasma (trampa 95).
- M65 (encargo opcional): los 4 hermanos de L98 se SOSTIENEN (base del modulo dueno EXISTE: fauna_spawner.gd / 6 GLB 36-Fauna_* / sfx_manager.gd / global_pool.gd). 2 citas imprecisas (L99 cita fauna_registry.gd en vez del spawner; L100 dice "esferas placeholder" pero los GLB existen). 0 ediciones a M65.
- Higiene M77: bytes 8473 -> 11655; CRLF 216/216; LF sueltos 1/1; CR sueltos 1/1; sin BOM/NUL/FFFD. `verificar_checklist.py`: 1 inconsistencia ESPERADA (GLOBAL 0/130 vs 82/130). 0 commits / 0 push (atria-dawn). Colisiones de pool AJENAS: 1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726.


## D7-M76 (Multijugador) - 2026-10-12 22:50 (Log 1788)

- [x] Log reservado: **1788** - D7-M76 Multijugador (80 flips de diseno con cita real)
- Mensaje 211 (mimo): D6-M77 ACEPTADO; habilita cola D7-M76 / D8-M151 / D9-M105 / D10-M45.
- M76 = modulo de CONTRATO/DISENO (v1 single-player cozy, MP diferido). 1/130 -> **81/130**:
  80 flips (Definir/Documentar con cita a 01-Requerimientos 5 RF1-25 / 02-Analisis / 03-Diseno / 04-Codigo Notas).
- 46 [ ] honestos: 18 Verificar (sin medicion) + 7 Registrar-en-manifiesto + 19 Definir/Documentar
  sin respaldo en 01-04 (grep: el termino solo aparece en el checklist) + 1 Entregar (archivo ausente) + 1 proceso.
- Hallazgo: `mp_contract.json` y `validate_mp_contract.gd` AUSENTES (rutas Unity `Assets/_Project/`;
  0 archivos bajo Assets/ en el repo) -> artefactos fantasma, patron M77. Deuda historica ajena.
- Hallazgo: item L212 NO cumplido (plan-inicial != plan-actual: 01-Requerimientos y 05-Checklist difieren).
- Evidencia: [x]=81 [ ]=46 [?]=3; git diff --numstat 81/81; CRLF 214/214 + LF 6/6 (EOL intacto);
  sin BOM/NUL; verificar_checklist.py: 1 inconsistencia esperada (GLOBAL 1/130 vs 81/130).
- Higiene: 0 commits / 0 push (atria-dawn). Colisiones de pool AJENAS: 1290, 1468, 1547, 1559,
  1585, 1645, 1698, 1726 (+ BOM preexistente en NUMEROS_DISPONIBLES.txt, trampa 77).
- Reporte 212; solicitud de commit a atria (msg 59). Tracker 209 -> 211.


## D8-M151 (Control Final) - 2026-10-12 23:16 (Log 1792)

- [x] Log reservado: **1792** - D8-M151 Control Final (71 flips de diseno con cita real)
- Mensaje 213 (mimo): D7-M76 ACEPTADO (81/130 exacto); los 19 "Definir/Documentar" sin respaldo
  se quedan `[ ]`. Habilita cola D8-M151 / D9-M105 / D10-M45.
- M151 = modulo DOCUMENTAL/DE PROCESO (auditoria de los 26 puntos maestros post-lanzamiento;
  sin codigo de runtime del juego). 23/167 -> **94/167**: 71 flips con cita real a 01-Requerimientos
  (3/5/6/8) / 02-Analisis (2 D1-D5, 4, 5, 6) / 03-Diseno (2 mapa de 26 puntos, 3, 4) / 04-Codigo (3, 5).
- Criterio por verbo (el aceptado en M77/M76): `Definir X` basta si X existe en 01-04;
  `Verificar`/`Crear`/`Entregar` exigen medicion o archivo. En M151 casi todos los items dicen
  "Definir ...", incluidos los "Definir verificacion de X".
- 67 [ ] honestos: conceptos que SOLO estan en el checklist (grep -ic = 0 en los 4 docs):
  retencion/fatiga, legibilidad/friccion, curiosidades/coleccionables, pistas, amistad, exploits,
  artefactos, retroalimentacion UI, fauna silvestre, decorado estacional, audio estacional,
  musica por acto, ducking, volumen, contraste UI, streaming, LOD/culling, backup/cloud,
  migracion de versiones, anti-softlock, hardware minimo, remapeo/subtitulos/flashing,
  6 idiomas, vigencia/respaldo de contratos, licencias de audio/Unity, capturas, requisitos de
  tienda, FAQ, triaje, rollback, notas de parche, in-place, mejoras de comunidad, log de cierre.
- Deuda ya documentada (NO tocada, es de la iter. 3 de SB): `04-Codigo.md` sec.6 declara que
  `generar_acta.py`, `importar_telemetria.py`, `importar_encuestas.py` y el acta `.json` NO existen.
- Evidencia: [x]=94 [ ]=67 [?]=6 (total 167); git diff --numstat 72/71; bytes 21988 -> 25367;
  LF 377, CRLF 0, CR 0, BOM False, NUL 0, FFFD 0; git ls-files --eol i/lf w/lf.
  verificar_checklist.py: 17 -> 18 inconsistencias (la nueva = la ESPERADA: GLOBAL 23/167 vs 94/167).
- Higiene: 0 commits / 0 push (atria-dawn). Colisiones de pool AJENAS: 1290, 1468, 1547, 1559,
  1585, 1645, 1698, 1726. Pool de logs: 1792 consumido (head post 1793), NO commiteado.
- Reporte 214; solicitud de commit a atria (msg 62). Tracker 211 -> 213.
- Proxima: mensajes `*mimo*a-deepseek*` / `*atria*a-deepseek*` con NN > 213. NO reprocesar mi 214.
  Cola: D9-M105 (confirmar/refutar "sin trabajo real pendiente" contra disco), D10-M45-Arte-3D.


## D9-M105 (Telemetria) - 2026-10-12 23:49 (Log 1795)

- [x] Log reservado: **1795** - D9-M105 Telemetria (confirmar/refutar "sin trabajo real pendiente")
- Mensaje 215 (mimo): D8-M151 ACEPTADO (94/167 exacto, GLOBAL actualizado); los 67 [ ] se quedan.
  Habilita D9-M105 y D10-M45. Confirmado: atria pusheo M151 (a50686b, bd014fc..a50686b).
- D9-M105 = VERIFICACION contra disco. **VEREDICTO: REFUTADO.** La fila 105 del GLOBAL (HEAD)
  dice "M105 sin trabajo real pendiente - liberar agente"; contra disco hay **7 items con
  trabajo real de M105**.
- Categoria C (trabajo real, 7): L318 hook de cierre (`_notification`/`NOTIFICATION_WM_CLOSE_REQUEST`/
  `_exit_tree` = 0 en telemetry_director.gd; `03-Diseno.md` sec.4 sin paso de cierre) - L165
  `chapter_completed` = 0 - L200/L231/L234/L237 analisis de datos (03-Diseno.md solo tiene sec.1-6,
  NO existe seccion de analisis; dos citas previas a sec.3.4/3.5 eran FALSAS) - L236 sin dueno
  ni justificacion.
- Categoria A (delegado por diseno, 26): 189, 191, 193, 204, 205, 209, 210, 215, 216, 217, 220, 221,
  224, 227, 228, 229, 233, 245, 250, 293, 295, 296, 299, 300, 301, 302 (M104/M53/M91/M71/M22/M102/legal).
  Verificado: `generate_session_id`/`session_id`/`save_events_to_cache`/`show_difficulty_survey` = 0
  en M105 (correcto), y las APIs que M105 si expone existen (`solicitar_encuesta` 4, `puzzle_abandoned` 1,
  `zone_ignored` 4, `time_to_first` 9, `session_duration` 5, `track_*` 12, `enviar_evento` 10,
  `registrar_evento` 10, `establecer_opt_in` 2, `cambio_opt_in` 3).
- Categoria B (datos post-release, 5): 145, 196, 197, 198, 199. Categoria D (residuales, 2): 322, 323.
  26+5+7+2 = 40.
- CONFIRMADO (no todo negativo): nucleo operativo SI - 4 suites headless re-corridas hoy con EXIT real:
  test_telemetry 16/0, iter5 10/0, iter6 11/0, iter7 27/0 = **64 checks, 0 fallos, 4x EXIT 0**.
  Autoload real en project.godot L29.
- HALLAZGO: M105 se contradice en sus totales. L337 dice "Total de items: 165"; L345 dice 162;
  real medido = **122 [x] / 0 [ ] / 40 [?] = 162**; GLOBAL (HEAD) dice `122/165` (stale por 3).
  Explicacion: 3 fusiones Patron D (43->40) + 2 flips H-3 (120->122) = 165-5+2 = 162.
  `verificar_checklist.py` NO lo detecta (su Verificacion 4 solo mira lineas `**Totales:**`).
- Evidencia: 05-Checklist.md de M105 NO modificado (0 bytes de diferencia); log 1795 ASCII puro,
  LF, 7272 B. Pool: 1795 consumido (head JUSTO antes = 1795 con BOM preexistente, trampa 77;
  head post 1796). NO se commiteo el pool.
- Ajeno NO tocado: (1) ERROR "non-existent singleton 'AnimationService'" en las 4 corridas
  (animacion_jugador_m48.gd:40; no aborta, EXIT 0). (2) CHECKLIST-GLOBAL.md en reescritura ACTIVA
  por otro agente (mtime 23:41:28; 160 filas; faltan IDs 2, 3, 62, 105, 142, 143, 152, 157;
  filas concatenadas con `||`, trampa 86) -> la fila 105 se leyo desde `git show HEAD`.
- Recomendacion NO ejecutada (no aplico cambios sin autorizacion): (1) hook de cierre + paso en
  03-Diseno sec.4 + check en suite; (2) seccion de analisis en 03-Diseno; (3) definir
  chapter_completed y dar dueno a L236; (4) alinear L337 165->162 y GLOBAL 122/165->122/162;
  (5) L322/L323 a [x] por "plan-inicial descartado" si se autoriza.
- Reporte 216; solicitud de commit a atria (msg 64). Tracker 213 -> 215.
- Proxima: mensajes `*mimo*a-deepseek*` / `*atria*a-deepseek*` con NN > 215. NO reprocesar mi 216.
  Cola: D10-M45 (Arte-3D).
- [x] Log reservado: **1803** - M39-Tiendas: fix de tests obsoletos pre-BUG-106 (2 suites migradas de ids: `madera_roble`->`wood`, `baya_roja`->`OBJ-ITE-024`) + correccion de las 4 afirmaciones falsas del `05-Checklist.md` (L13/L14/L304/L315). Encargo del director (mimo msg 221). 6/6 suites EXIT 0, 0 SCRIPT ERROR. Cabeza medida justo antes = 1803; cabeza tras la reserva **1804**. Canal consumido **222** (informe). Commit pedido a atria-dawn (msg 74).
- [x] Log reservado: **1814** - M35-Mineria: lote 3 = **21 flips de diseno con cita real** (seccion B "Resolucion de los 24 puntos del plan", criterio por verbo). Encargo del director (mimo msg 224: "M35 primero"). **80/142 -> 101/142**; quedan **28 [ ]** (3 de diseno sin evidencia: P2 8+ minerales -> el diseno tiene 6, P16 rutas y P17 estaciones = grep 0; + 25 de implementacion en M08/M26/M52/M43, ausencia medida en `mining_manager.gd`). Cabeza medida justo antes = 1814; cabeza tras la reserva **1815**. Canal consumido **225** (informe a mimo). Commit pedido a atria-dawn (msg 82). Pendiente del director: fila 35 del GLOBAL `80/142` -> `101/142`.
- [x] Log reservado: **1825** - M02-Vision-Y-Concepto: lote b3 = **3 flips de verificacion cruzada con cita real** (L220/L221/L222 contra GDD IDEA-BASE-DEL-JUEGO.md seccion 1 / Biblia HISTORIA-DEL-JUEGO.md / Plan-de-produccion.md seccion 1). **165/172 -> 168/172**; quedan **3 [ ]** con motivo medido (L225 modulos dependientes, L227 honestidad por tercero, L228 premisa stale "153 modulos" -> CHECKLIST-GLOBAL tiene 168 filas). Cabeza medida justo antes = 1825; cabeza tras la reserva **1826**. Canal consumido **227** (informe a mimo). Commit pedido a atria-dawn. Pendiente del director: fila 02 del GLOBAL 151/172 -> 168/172. HALLAZGO: M76 BLOQUEADO (mp_contract.json AUSENTE; 11 items "Registrar en el manifiesto" no cerrables; M76 es gate post-v1 de M77).
- [x] Log reservado: **1828** - M01-Fundamentos-Del-Proyecto: **medicion completa del indice maestro** (152 modulos) + lote **b1** + propuesta de 5 candidatos. Encargo del director (mimo msg 500: "Segui con M01"). **Indice = 21 [x] / 131 [ ] / 0 [?]** (coincide con Log 1727 y fila 01 del GLOBAL). **b1 (13 primeros [ ]: M001-M005 + M008-M015) = 0 flips** (todos modulos en curso, GLOBAL Amarillo). **5 candidatos reales a [x]** (unico barrido completo): M042 43-Efectos-De-Sonido (97/97), M115 116-Instalador (192/192), M119 120-DLC-Y-Expansiones (222/222), M120 121-Soporte-Post-Lanzamiento (211/211), M129 130-Artbook (134/134) -> si el director los aplica, `21/152` -> `26/152`. Excluidos (checklist cerrada pero GLOBAL no-completado): M018 19-NPC-Y-Vecinos, M021 22-Historia-Principal, M099 100-Community-Management. **0 flips aplicados** (los aplica el director; regla del encargo 177). Cabeza medida justo antes = 1828; cabeza tras la reserva **1829**. Canal consumido **501** (informe a mimo). Commit pedido a atria-dawn (msg 201: M02 Log 1825 + checklist + esta corrida).

## Ciclo 2026-10-14 03:53 (GMT-3) — canal 238 -> M05 diseno faltante (91/103)

- Encargo del director (mimo msg 235): escribir el diseno faltante de M05 (E8-E10 anti-patrones + H1-H6 edge cases) en `03-Diseno`; "con eso M05 pasaria a ~91/103".
- HECHO: `03-Diseno` +sec.7 (7.1 E8 deferred / 7.2 E9 `_process` / 7.3 E10 duplicar) +sec.8 (8.1 migracion GDScript 3->4 / 8.2 senales antes de ready / 8.3 resources compartidos / 8.4 `res://` vs `user://` / 8.5 floats-determinismo / 8.6 threads+nodos). Citas reales: GUIA-GODOT/01 sec.4/13/14/24/26/29/31, GUIA-GODOT/09, M27/04-Codigo sec.8 trampas 1-2, y rutas medidas (`bootstrap.gd:47-50`, `scene_manager.gd:33`, `accesibilidad_manager.gd:207/266`, `save_schema.gd:17`, `save_writer.gd:49`, `island_generator.gd:47/54/61/68`, `game_clock.gd:203`).
- 9 flips `[ ]`->`[x]` con cita a las secciones nuevas. **M05 82/103 -> 91/103** (x=91, [?]=0, [ ]=12; total 103 conservado).
- Acuse del msg 237 (sistema `.ultima-revision-<nombre>.txt`): tracker leido al empezar (233) y actualizado al cerrar (**237**).
- HALLAZGO reportado (no editado): la fila 05 de `CHECKLIST-GLOBAL.md` sigue en **4/103** (el msg 235 decia que ya estaba en 82/103). Su Nota ademas sigue describiendo el drift de rutas ya corregido el 2026-10-13 en `04-Codigo` sec.2.
- Higiene por bytes: `03-Diseno` LF/sin BOM (12468 B); `05-Checklist` LF/sin BOM (15238 B); Log ASCII puro LF. 0 ediciones a GLOBAL/quality.yml/AGENTS/project.godot. 0 commits/0 push.
- `reservar_log.py --estado`: 8 colisiones de pool AJENAS (1290/1468/1547/1559/1585/1645/1698/1726) -> reportadas, no tocadas.
- Reporte 238; commit pedido a atria-dawn (msg 105).
- Proxima: mensajes `*mimo*a-deepseek*` / `*atria*a-deepseek*` con NN > 237. Pendiente del director: fila 05 GLOBAL `4/103` -> `91/103`. Ofrecido: Lote B = M76 o los 12 `[ ]` de M05 que si son de M05.

- [x] Log reservado: **1837** - M05-Lenguaje-Y-Programacion: iteracion 2 = **diseno faltante escrito** (sec.7 E8-E10 + sec.8 H1-H6) + **9 flips de diseno con cita real**. Encargo del director (mimo msg 235). **82/103 -> 91/103**; quedan **12 [ ]** (F7/F9/F10/G2/G6/G8/G9/G10/H7/H8/H9/H11, con motivo y dueno en la seccion "Diseno faltante escrito" del checklist). Cabeza medida justo antes = 1837; cabeza tras la reserva **1838**. Canal consumido **238** (informe a mimo). Commit pedido a atria-dawn (msg 105). HALLAZGO: fila 05 del GLOBAL sigue en `4/103` (no 82/103 como decia el msg 235).
- [x] Log reservado: **1835** - M05-Lenguaje-Y-Programacion: iteracion 1 = auditoria contra 01-04 (**78 flips con cita real**) + M01 indice maestro (**5 flips**). Encargo del director (mimo msgs 232/233). **M05 4/103 -> 82/103**; **M01 indice 21/152 -> 26/152**. Cabeza medida justo antes = 1835; cabeza tras la reserva **1836**. Canal consumido **234** (informe a mimo). Commit pedido a atria-dawn (msg 98). (Entrada agregada retroactivamente el 2026-10-14: faltaba en el backlog.)

## M05 (Lenguaje y Programacion) — cierre de items de proceso, 2026-10-14

- [x] Log reservado: **1842** — M05 cierre de 4 items de proceso (F9/F10/H7/H11) -> 95/103
- Estado M05 tras iter 3: **95 [x] / 8 [ ] / 0 [?] = 103**. Pendiente del director: fila 05 del
  GLOBAL `91/103` -> `95/103`. Informe **240** a mimo; commit pedido a atria-dawn (**107**).
- Hallazgo: la fila 05 de CHECKLIST-GLOBAL arranca con celda vacia -> `verificar_checklist.py` no
  cruza su Progreso (drift invisible, misma familia que la fila 04).

## M60 (Datos y Serializacion) - reverificacion de los 7 items abiertos (Patron D), 2026-10-15

- [x] Log reservado: **1860** - M60-Datos-Y-Serializacion: reverificacion de los **4 [?] + 3 [ ]** contra disco (Patron D; encargo del director mimo msg 253, que al modulo lo llama "M59"). **VEREDICTO: 0 flips** - los 7 siguen honestos con el mismo dueno que ya declaraba la iter. 4 (Log 916). Los 3 `[ ]` son items "M08:" (L174 regeneracion con semilla: `main_island.gd:170` la tiene HARDCODEADA; L176 contrato de edits: 0 consumidores del binario fuera de `scripts/datos/`; L181 log de chunks CARGADOS: solo hay `print` al guardar). Los 4 `[?]` son de dueno externo (L190 UI M53/M59: `guardado_en_curso()` solo lo consumen los tests de M60; L192 build M63 que sigue 67/101 con 27 [?]; L204 `.tres` M16/M33: 0 `.tres` de recetas/cultivos bajo `data/`; L231 Profiler: requiere build GUI). **Suites headless x4 = 94/134/152/40 = 420 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR** (exit code leido del PROCESO, no de la tuberia). Cabeza medida justo antes = 1860; tras la reserva **1861**. Canal consumido **254** (informe a mimo). Commit propio con pathspec explicito (sin push).
- Estado M60: **189 [x] / 4 [?] / 3 [ ] = 196**, sin cambio (coincide con la fila 60 del GLOBAL). **No se edito el checklist** (0 flips) ni el GLOBAL.
- HALLAZGO 1: `test_datos_m60.gd` (suite base) **no tiene piso `CHECKS_MINIMOS` ni marcadores `_fin()`** -> un SCRIPT ERROR que aborte un bloque daria "0 fallos" + EXIT 0 (familia falso-verde 11/85/122). Los otros 3 suites del modulo si tienen proteccion (iter3 e iter5 piso; iter4 marcadores). Sugerido al director; no lo toque (cambio de codigo, fuera del encargo).
- HALLAZGO 2: la cifra "iter. 3 = 132" del checklist es HISTORICA, no drift: `07-Resultados-Testings.md:15` ya documenta T-018 (commit `acaa3b4`) "iter3 paso de 132 a 134" al agregarle el piso medido. Hoy mide 134 estable (2 corridas).
- HALLAZGO 3: 8 colisiones de numeracion de logs AJENAS (1290/1468/1547/1559/1585/1645/1698/1726) reportadas por `reservar_log.py --estado` - reportadas, NO tocadas.
- Proxima: mensajes `*mimo*a-deepseek*` / `*atria*a-deepseek*` con NN > **253**. NO reprocesar mis 246/247/252/254. Pendiente del director: asignar modulo (M60 no tiene trabajo propio pendiente).

## M160 (Diseno de Ubicaciones del Mundo) - reverificacion de los 10 abiertos (Patron D), 2026-10-15

- [x] Log reservado: **1862** - M160-Diseno-De-Ubicaciones-Del-Mundo: reverificacion de los **7 [?] + 3 [ ]** contra disco (Patron D; encargo del director mimo msg 255, que dice "10 [?]" - el disco tiene 7 [?] + 3 [ ]). **VEREDICTO: 0 flips limpios** - 9 siguen honestos con el mismo dueno; 1 candidato parcial (L193). Los 7 [?]: L54 (M39, 0 consumidores de WorldLocations en tiendas), L55 (M18, llamada MUERTA), L72 (M25), L197/L224/L229/L235 (M28/M54, ambos incompletos: M28 50/130, M54 133/177). Los 3 [ ]: L48 (horarios, delegado a M39/M21), L193 (regen 57/57; tier 40/57), L196 (M25 runtime). **Evidencia: `test_ubicaciones_m160.gd` headless = 17 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR** (exit del PROCESO). Cabeza medida justo antes = 1862; tras la reserva **1863**. Canal consumido **256** (informe a mimo). Commit propio con pathspec explicito (sin push).
- Estado M160: **145 [x] / 7 [?] / 3 [ ] = 155**, sin cambio (coincide con la fila 160 del GLOBAL). No se edito el checklist (0 flips) ni el GLOBAL.
- HALLAZGO: la integracion M18 <-> M160 esta MUERTA - `scripts/houses/house_manager.gd:236-238` llama `wl.buscar_cerca(...)`, que NO existe en todo el proyecto (0 definiciones; `world_locations.gd` expone get_location/get_locations_by_island/get_locations_by_type/can_access/get_conexiones/get_recolectables). El guard `has_method("buscar_cerca")` falla -> retorna `true` siempre -> L238 es codigo muerto (familia BUG-116 / trampa 24). L55 [?] no es resoluble.
- Candidato a flip (NO aplicado): L193 [ ] "Objetos con regeneracion (regeneracion_seg) y herramienta/tier M158 por objeto" - regeneracion 57/57 recolectables; herramienta/tier 40/57 (70%). Decision del director. No se aplico por la regla de la automatizacion (los flips los aplica el director).
- Proxima: mensajes `*mimo*a-deepseek*` / `*atria*a-deepseek*` con NN > **255**. NO reprocesar mis 246/247/252/254/256.


## M160 (2 ediciones autorizadas) + M21-Dialogos (reverificacion de los 6 [?]) - 2026-10-15

- [x] Log reservado: **1865** - M160 cierre de pendientes (2 ediciones autorizadas por mimo msg 257) + M21-Dialogos reverificacion Patron D de los 6 . Cabeza medida justo antes = 1865; tras la reserva **1866**. Canal consumido **258** (informe a mimo).
- **M160: 2 ediciones aplicadas** en `plan-actual/05-Checklist.md`: (a) L48 `[ ]` -> `[?]` con dueno M39/M21 (horarios runtime, no resoluble en M160); (b) L193 conserva `[ ]` con anotacion de medicion (regeneracion_seg 57/57; herramienta/tier 40/57 = 70%, flip parcial prohibido por 21.6). Totales y Estado actualizados. **Conteo: 145 [x] / 8 [?] / 2 [ ] = 155** (antes 145/7/3). EOL LF sin BOM antes y despues.
- **M21: 0 flips.** Los 6 `[?]` reverificados uno por uno contra disco, todos siguen honestos: L39 (RF10-RF12: RF11 sin catalogo central por NPC - grep 0; RF12 sin proximidad/M64), L62 (limite real de `JSON.parse_string`, declarado en el propio validador L174-175), L63 (Dictionary colapsa IDs duplicados; `validate()` no chequea), L100 (`dialogue_manager.gd:229` emite options sin filtrar; UI las muestra todas), L103 (KEY_1..KEY_4 si, flechas no), L194 (ver hallazgo). **Evidencia: 15 suites headless, todas EXIT 0 y 0 SCRIPT ERROR** = 126 checks nombrados / 0 fallos + 7+8 OK M162 + 366/366 grafos validados.
- HALLAZGO M21: el item L194 pide un test end-to-end con `dialogo_ejemplo.json` y **ese archivo no existe en todo el repo** (0 resultados de `find`). Item inejecutable tal como esta redactado -> decision del director (re-apuntar / crear / dejar `[?]`).
- BUG registrado: **BUG-135** en `DOCUMENTACION/11-BUGS.md` (seccion 8.5, append, **sin commitear** por estar en la lista de no-commit): la integracion M18 -> M160 esta MUERTA (`house_manager.gd:231-238` llama `WorldLocations.buscar_cerca()`, 0 definiciones). Estado `[?] Delegado` (dueno M18/M160). Hallazgo colateral: `test_m18_casas.gd:117` consagra el bug (espera `true`).
- Limites: 0 push; 0 ediciones a CHECKLIST-GLOBAL/quality.yml/AGENTS.md/project.godot; 0 auto-sellos 21.8. Pool de logs y pool del canal NO commiteados.
- Proxima: mensajes `*mimo*a-deepseek*` / `*atria*a-deepseek*` con NN > **257**. NO reprocesar mis 246/247/252/254/256/258.

## M124 (reverificacion Patron D de los 25 [?]) - 2026-10-15

- [x] Log reservado: **1867** - M124-Contenido-Generado-Por-Usuarios reverificacion Patron D de los 25 `[?]` contra disco (encargo del director mimo msg 259). Cabeza medida justo antes = 1867; tras la reserva **1868**. Canal consumido **260** (informe a mimo).
- **M124: 0 flips.** 83 [x] / 25 [?] / 0 [ ] = 108 (coincide con la fila GLOBAL 124 y con la linea `**Totales:**` L241). Los 25 [?] son delegaciones genuinas: 9 de proceso/servicio/infra post-V2 (L53/L54/L64/L65/L66/L79/L89/L107/L113; 0 refs a CDN/bucket en `scripts/`), 4 de decision humana producto/legal (L13/L14/L16/L104; M100 = 220/220 [x] pero sin criterio de demanda UGC), 9 de modulo vecino NO resuelto (L22: M56 seccion O = 3 `[ ]`; L33: M18 sin "blueprint"; L45: M17 sin "materiales requeridos"; L47: M109 valida terreno pero no el limite del jugador; L58: M100 sin cola de reportes UGC; L87: M80 identifica el riesgo, el almacenamiento por region es infra; L123/L125: M125 sin "lenguaje simple"/"menores"; L126: M126 revertido por auditoria) y 3 de UI M89 (L148/L149/L151: M89 sin galeria publica ni tarjeta de item UGC).
- **Evidencia runtime:** `test_ugc_m124.gd` **16/0** + `test_ugc_m124_iter2.gd` **85/0** = **101 checks, EXIT 0, 0 SCRIPT ERROR** (exit del PROCESO). Ambas cableadas en `quality.yml` L322-323 con `|| FAIL=1` (gate duro).
- HALLAZGO (drift documental, NO toca marcas): el bloque `## Totales` (L164-168) dice **106 items / 81 completados** y el titulo (L4) dice **110**; el real medido es **108 (83/25/0)**. `verificar_checklist.py` NO lo marca (usa la linea `**Totales:**`, no el bloque). Decision del director.
- **M21 L194 y commit de M160: YA hechos** por el director/fundador (M21 checklist mtime 2026-10-15 05:04:54; commit `c225c0f` = "M160: reclasificar L48 a [?]...", 1 archivo +7/-6). No duplique nada.
- Limites: 0 flips / 0 ediciones al `05-Checklist.md` de M124 / 0 commits / 0 push; 0 ediciones a CHECKLIST-GLOBAL/quality.yml/AGENTS.md/project.godot; 0 auto-sellos 21.8. Pools de logs y del canal NO commiteados. 8 colisiones de pool AJENAS reportadas sin tocar.
- Proxima: mensajes `*mimo*a-deepseek*` / `*atria*a-deepseek*` con NN > **259**. NO reprocesar mis 246/247/252/254/256/258/260.

## M64 (reverificacion fix BUG-129 + auditoria Patron D) - 2026-10-15

- [x] Log reservado: **1870** - M64-IA-De-NPC: reverificacion del fix BUG-129 + auditoria Patron D (encargo del director mimo msg 261). Cabeza medida justo antes = 1870; tras la reserva **1871**. Canal consumido **262** (informe a mimo).
- **M124 drift corregido** (autorizado msg 261): `05-Checklist.md` L4 (110->108), L166 (106->108), L167 (81->83) + L168 agrega `[ ]: 0`. L241 intacta. CRLF 245->246, LF sueltos 0, sin BOM.
- **M64 paso 1: BUG-129 CONFIRMADO.** `state_machine.gd` L41-49 (`if state.get_parent() == null: add_child(state)` + comentario BUG-129) presente en el **blob de HEAD** (versionado, no solo worktree). Runtime: `test_ia_npc_m64_iterN.gd` **82/0 EXIT 0 0 SCRIPT ERROR**; `test_bug129_estados_orphan.gd` **states orphans=0, total_strays=0, 7 agentes, EXIT 0**. Sonda de CONTROL POSITIVO (medidor no ciego): 0->1 huerfano detectado + `register_state` parentea. Sonda creada y borrada.
- Matiz: el total de strays hoy es **0** (no 201) porque el fix de M50 (`vegetation_spawner.gd:88 inst.free()`) tambien aterrizo -> mas fuerte que lo reportado (56->0 states; 257->0 total).
- **M64 paso 2: Patron D. Conteo 102 [x] / 17 [?] / 0 [ ] = 119** (ANTES=DESPUES; coincide GLOBAL 160 y tabla `## Totales` interna; LF puro, sin BOM). **Los 17 [?] son honestos** (5 runtime/visual + 10 dueno externo M08/M17/M20/M21/M65 + L88 variacion +-15min con 0 hits) -> **0 flips disponibles** entre los abiertos.
- **11 `[x]` INFLADOS reportados (NO flipados, los aplica el director):** Familia A sub-estados inexistentes L56-L62 (7: solo IdleState tiene SUB_STATES; 22 de 25 nombres con 0 hits); Familia B navegacion L110 (desvio de obstaculos: 0 hits avoid/RID) y L111 (apply_separation definida en npc_agent.gd:237 con **0 callers** = codigo muerto); Familia C metricas L150 (`_update_performance_metrics` = `pass`, no-op, la propia nota QA L37 lo decia); Familia D cita L117 (test_rendimiento_m64 no instancia NavigationAgent3D -> no mide pathfinding).
- Borderline reportados: L113 (tope de paths vs `MAX_AGMPS_FULL=60` de agentes), L79-L86 (8 items con villanos inexistentes; dataset real = 14 perfiles con rutina), L75/L76 (RoutineDefinition/Slot inexistentes, marcados "NO requerido"), test_rendimiento con 2 aserciones infalsables (`elapsed >= 0`).
- Lo que SI se sostiene: L185 CI gate (quality.yml L485-490, 5 suites con `|| FAIL=1`, gate duro); L55; L248/L249.
- Limites: 0 commits / 0 push; 0 ediciones a CHECKLIST-GLOBAL/quality.yml/AGENTS.md/project.godot; 0 auto-sellos 21.8. Pools de logs y del canal NO commiteados. 8 colisiones de pool AJENAS reportadas sin tocar.
- Proxima: mensajes `*mimo*a-deepseek*` / `*atria*a-deepseek*` con NN > **261**. NO reprocesar mis 246/247/252/254/256/258/260/262.

## M118-CI-CD (fix del YAML invalido de quality.yml - CI rojo) - 2026-10-15

- [x] Log reservado: **1879** - M118-CI-CD: diagnostico y fix del ScannerError L286-287 de quality.yml (encargo del director De-Director V4.1, msg 264). Cabeza medida justo antes = 1879; tras la reserva **1880**. Canal consumido **265** (informe al director).
- **Commit autorizado msg 264 sec. 3: HECHO -> `7274c3d`** (Log 1870 + informe 262 + BACKLOG-MASTER + drift M124 `05-Checklist.md`; 4 archivos, +320/-3). Sin push (origin/main = d2efb964).
- **Diagnostico:** NO era un `:` sin comillas. Las 24 lineas 281-304 del bloque `run: |` del job `test-suite` (arranca en L178, contenido a 10 espacios) quedaron **desindentadas a columna 0** -> el escalar de bloque termina en L281 -> 281-304 pasan a YAML de raiz -> L286 (`godot --headless ...`) es un escalar plano sin `:` -> ScannerError. Confirmado: las 281-304 son las unicas 24 lineas con LF suelto (1036 CRLF + 24 LF).
- **Fix:** prefijo de 10 espacios a las 24 lineas. 1 solo hunk `@@ -281,24 +281,24 @@`, 24/24. 0 cambios en suites/umbrales/gates/jobs/needs. EOL NO normalizado (CRLF 1036 -> 1036). sha256 `0463ceb2731384e94317dd6e362c39235a25823769f96b6bb1b3e50ca5153c31`.
- **Antes/despues medido:** `python scripts/validar_workflows.py` -> **EXIT 1** (YAML INVALIDO L287) a **EXIT 0** (6/6 workflows validos); `yaml.safe_load` -> ScannerError L286/287 a **PARSE OK** (12 jobs).
- **Suites recuperadas (headless, Godot 4.7.2 real, `--import` previo EXIT 0):** test_graphics_config.gd 85 checks/0 fallos/6 bloques EXIT 0; test_m40_contratos.gd 19/0/4 EXIT 0; test_layer_type_m53.gd 10/0/4 EXIT 0; cross_module_linter.py 1065 .gd / 408 class_name / 146 autoloads OK EXIT 0; test_cross_module_linter.py 9/0 EXIT 0. **0 SCRIPT ERROR** en las 3 Godot. Total 114 checks. Ruido preexistente observado (no bloqueante, no tocado): `ERROR: Failed to retrieve non-existent singleton 'AnimationService'.` al cierre.
- **Origen y magnitud (gh):** ultimo run verde de quality.yml **2026-10-07T07:17:22Z** (d9534a0a); primer run con duracion **0s** (workflow RECHAZADO por GitHub) **2026-10-12T23:34:20Z** (`40543103`); **47 runs 0s consecutivos** hasta `d2efb964` (= origin/main, 2026-10-14T07:13:22Z). Commit que lo introdujo: **9e8e37d** (2026-10-12 20:31:07 -0300, "Se bajo el piso de checks de la suite de graphics_config y se agrego su gate a CI"), via `git log -S`. CI muerto ~32 h.
- **M118 L199 [?]** ("Validacion en GitHub Actions real"): el fix SI cae dentro del pendiente (el rojo era defecto propio, no deuda externa), pero el cierre necesita push + run verde. **0 flips aplicados** (orden: lo decide el fundador). Conteo del modulo: 105 [x] / 1 [?] / 0 [ ] = 106.
- **PENDIENTE: commit NO autorizado** para `quality.yml` + Log 1879 + informe 265 + BACKLOG-MASTER + tracker->264. Riesgo: el fix vive solo en el worktree.
- Limites: 0 ediciones a CHECKLIST-GLOBAL.md/AGENTS.md/project.godot/05-Checklist de modulos; 0 auto-sellos 21.8; quality.yml editado SOLO por orden explicita del director y solo para reparar el YAML; pools NO commiteados; 8 colisiones de pool ajenas sin tocar.
- Proxima: mensajes con NN > **264** (`de-director*v4.1*a-deepseek`, `mimo*a-deepseek`, `atria*a-deepseek`, y los `mimo-*` sin sufijo). NO reprocesar mis 246/247/252/254/256/258/260/262/265.

## M118 (commit autorizado ejecutado) + M64 re-medicion + propuesta M26 - 2026-10-16

- **Commit autorizado (De-Director V4.1 msg 266 sec. 2): HECHO -> `830efc5`** (padre `80b0576` M31 ajeno). 5 archivos, +364/-25: `.github/workflows/quality.yml` (24/24, 1 solo hunk `@@ -281,24 +281,24 @@`), `Logs/1879-*`, informe 265, este BACKLOG, tracker. Pathspec explicito, `add`+`commit` encadenados, indice previo vacio. **Sin push.**
- **Fix verificado EN HEAD (no en el worktree):** L281 del blob con 10 espacios; `yaml.safe_load(blob HEAD)` = PARSE OK 12 jobs; `validar_workflows.py` EXIT 0 (6/6); EOL `quality.yml` 1036 CRLF + 24 LF preexistentes, sin BOM (NO normalizado). Pool ya comiteado por el director (`091a5a3`): HEAD del pool = 1884 -> no lo toque.
- **M118 L199:** sigue `[?]` (el cierre exige push + run verde; decision del fundador). 0 flips.
- **M64 re-medido por PREFIJO de linea: 90 [x] / 29 [?] / 0 [ ] = 119 -> 0 DRIFT.** Coincide con el estado post-flip del director y con la fila 160 del GLOBAL. `verificar_checklist.py` NO marca M64. Confirmado: 102 - 12 degradados = 90 y 17 + 12 = 29 (mi "102/17" previo quedo viejo). La linea L251 (`102/119 [x] · 17 [?]`) es un **snapshot historico pre-flip**, no drift -> se deja.
- **Informe 267** al director (canal 267; el pool del canal esta STALE en 264 -> se usa `ultimo+1`, NO se toca el pool). Tracker -> **266**.
- **Propuesta de proximo modulo: M26-Templo-Subterraneo** (117 [x] / 10 [?] / 2 [ ] = 129). Unico modulo de Nivel A con `[ ]` PROPIOS cerrables por medicion: L148 (documentar softlocks/exploits/orientacion) y L160 (documentar accesibilidad/rendimiento); las suites a documentar YA existen (`test_templo_m26.gd`, `test_regresion_templos.gd`, `test_templo_headless.gd`, `templo_validadores.gd`). Fila 26 del GLOBAL con 12 celdas y agente `—`, ultima actividad 2026-10-12 -> reclamable §21.4.7. Pendiente de confirmacion del director.
- **CORRECCION DE MI TABLA (stale):** la fila **A2 (M68)** de este backlog decia "14/42 pend. propias" -> **FALSO**. Estado real 99/14/18 = 131 y su dueno actual en el GLOBAL es **agnes-3-flash**; sus 18 `[ ]` son UI/visual bloqueante (M53/M46/M67/M57/M48/M50/M61/M64), NO mios. Tambien stale: A12 (M26 decia 50/115 -> real 117/10/2), A11 (M124 decia 81/106 -> real 83/25/0), A13 (M127 decia 51/101 -> real 76/24/0), A9 (M148 decia 23/117 -> real 115/2/0), A1 (M60 decia 188/196 -> real 189/4/3, los 3 `[ ]` son de M08), B3 (M120 decia 163/222 -> real 222/0/0, ya cerrado).
- **Alternativas medidas y descartadas:** M60 (3 `[ ]` = trabajo M08), M148/M105/M124/M127/M03 (0 `[ ]` propios), **M41 (58/2/50) y M42 (62/0/38)** = de mi familia `deepseek-v4-flash` PERO sus pendientes son **produccion de audio** (Nivel C, contenido, no mi rol), M76 (bloqueado: `mp_contract.json` ausente; dueno `agnes-2.5-flash` descatalogado), M55/M57/M161 (dueno Hy4 -> no tocar).
- **Limites:** 0 push; 0 ediciones a CHECKLIST-GLOBAL/AGENTS.md/project.godot/05-Checklist de modulos; 0 auto-sellos 21.8; 0 flips; pools NO commiteados.
- Proxima: mensajes con NN > **266** (`de-director*v4.1*a-deepseek`, `mimo*a-deepseek`, `atria*a-deepseek`, y los `mimo-*` sin sufijo). NO reprocesar mis 246/247/252/254/256/258/260/262/265/267.

## M26-Templo-Subterraneo iter. 3 + COMMIT autorizado - 2026-10-16

- **Encargo del GLM-5.3 Flash-Director (msg 269).** Clasificados los 12 pendientes: **5 cerrados con artefacto medido** (L118 catalogo de 8 glifos; L157 presupuesto por region; L158 instancing de columnas; L148 softlocks/exploits/orientacion documentados; L160 accesibilidad/rendimiento documentados) y **7 `[?]` con dueño externo nombrado** (L119->M24, L129->M08/M61, L140->M19/M64, L141->M24, L146->M58, L190->M24/M25+M160, L203->M45/M47/M52 §15.3).
- **Checklist M26: 117/129 -> 122 [x] / 7 [?] / 0 [ ] = 129** + bloque `**Totales:**` reparado (declaraba 101/18/10 y se contradecia con las marcas reales 117/2/10). Conteo verificado por prefijo de linea.
- **Evidencia:** `test_templo_m26.gd` **110 checks / 0 fallos / EXIT 0 x3**, 0 `SCRIPT ERROR`, 8 marcadores `_fin()`; piso `CHECKS_MINIMOS = 110` medido en verde; **guardian probado EN ROJO** con 2 sondas (borradas); gate `test_regresion_templos.gd` **106/0 EXIT 0** con piso M26 92 -> 110; vecinos 38/0, 42/0, 4/0 sin regresion.
- **Log 1886** (ASCII puro: 0 bytes no-ASCII, 96 CRLF, sin BOM). `reservar_log.py --reservar` fallo 1 vez con `OSError 22`; el reintento dio **1886** (cabeza 1886 -> 1887).
- **Registros reclamados (3 de 4):** guia 08 §17 (fila M26 agregada), bloque `Reserva actual` en el 05-Checklist, seccion 🔵 en ESTADO-PARALELO. **La fila 26 de `CHECKLIST-GLOBAL.md` NO la edite** (prohibicion absoluta de mi directiva) -> **aplicada por el director** (122/129).
- **Informe 270** al canal. **COMMIT AUTORIZADO por el msg 271 y EJECUTADO -> `108ba96e4f1fd85e71bbbbd4c3f9714e9a6636e8`** (padre `268de98` ajeno): 11 archivos, +1131/-95, pathspec explicito, `add`+`commit` encadenados, indice vacio antes. **0 push** (origin/main = `d2efb96`).
- **DESVIO DECLARADO:** de los 12 paths, **exclui `Logs/NUMEROS_DISPONIBLES.txt`** (la autorizacion dice "pools excluidos" y a la vez lo lista; ademas el diff arrastra el `1887` de Step-5-WorkBuddy). El pool queda modificado en el worktree (cabeza **1888**). Confirmacion pedida en el msg 272.
- **Correccion aceptada (punto 4.4 del director):** `1876` y `1878` NO estan en el pool fresco (cabeza 1888) -> son Logs suyos con consumo legitimo. **Retirados de mi lista de colisiones ajenas** (quedan 8: 1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726). Leccion: medir el pool FRESCO al correr, no un snapshot.
- **Trampa de tooling medida:** el tool `Edit` reescribe el archivo con **LF puro** aunque fuera CRLF -> hay que normalizar a CRLF despues de editar (aplicado al `05-Checklist.md` de M26). Los mensajes de canal son **LF por norma**.
- **HALLAZGO ajeno reportado, no tocado:** 4 bytes NUL preexistentes en `Mensajes entre modelos/ESTADO-PARALELO.md` (un agente escribio `\0` donde iba `0`) -> `grep` lo trata como binario. Lo limpia el director.
- **Limites:** 0 push; 0 ediciones a `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot`, 05-Checklist de modulos; 0 auto-sellos 21.8; 0 flips; QA §21.8 de M26 derivada por el director a Hy3 (no la hago yo: familia DeepSeek).
- Proxima: mensajes con NN > **271** (`glm-5.3-flash-director*a-deepseek`, `de-director*v4.1*a-deepseek`, `mimo*a-deepseek`, `atria*a-deepseek`, y los `mimo-*` sin sufijo). NO reprocesar mis 246/247/252/254/256/258/260/262/265/267/270/272. Pendiente del director: confirmar si el pool de Logs va dentro del commit; proxima cola o criterio para nueva propuesta.

## M118: el run REAL de CI tras el fix del YAML es ROJO (errores ajenos) - 2026-10-16

- **Encargo (msg 273 del GLM-5.3 Flash-Director):** medir `gh run list --workflow=quality.yml` + el run nuevo con duracion; si da VERDE, proponer el flip L199 de M118. El director confirmo el **PUSH REALIZADO** (`d2efb96..04e111d`, Log 1888) y que el fix `830efc5` ya esta en el remoto.
- **Medicion:** **15 runs consecutivos, los 15 en `failure`**; duraciones **5m30s-8m0s** (antes 0s). **Ultimo verde de la historia: `37586410221` (2026-10-07T07:17:22Z, `d9534a0`)**. Frontera medida por API (`created_at` vs `updated_at`): ultimo run **0s/rechazado** = `38526929167` (2026-10-14T07:13:22Z); primer run con **duracion real** = `38856429359` (2026-10-16T05:33:50Z -> 05:41:57Z).
- **CONCLUSION:** el fix del YAML **ES EFECTIVO** (0s/0 jobs -> 5m30s-8m0s/12 jobs). **No arreglo el CI: destapo su estado real** (~3 dias de workflow rechazado = ninguna suite corrio = nadie vio los fallos). **L199 NO es flippeable -> 0 flips propuestos, 0 aplicados.** M118 sigue **105 [x] / 1 [?] / 0 [ ] = 106**.
- **Run `38861603180` (6m38s): 12 jobs, 8 verdes / 4 rojos.** Rojos: Run Test Suite (exit 1 al cierre), UTF-8 sin BOM, GDScript Linter (GATE DURO BUG-091), GDScript Formatting Check (+ Quality Gate Summary por `needs`).
- **Causa raiz A = 21 SCRIPT ERROR, 4 archivos + 1 cascada (NINGUNO mio):**
  - `world/npc/rutina_ia.gd:69` (**PRODUCCION**, commit `3bf4c9a` M139 10-13): `if desde <= hora < hasta:` -> GDScript **no soporta comparacion encadenada** (`Invalid operands "bool" and "int"`). Verificado en el **blob de HEAD**. Fix: `if desde <= hora and hora < hasta:`.
  - `npc/test_catalogo_m19_atria.gd` (9 err, `b107794` M19 10-12): `var p = load(...)` **sin tipar** -> `p.get("id","")` resuelve `Object.get()` (1 arg) -> `Too many arguments`. Fix: tipar a `Dictionary`/`Resource`.
  - `eventos/test_barrido_m74.gd` (7 err, `10776c0` M74 10-12) y `farm/test_farm_voxel_m33.gd` (3 err, `72dfbe2` M33 10-12): `var x := metodo()` con **metodo sin tipo de retorno** -> `Cannot infer the type`.
  - `editor/_colector_sintaxis.gd`: **cascada** (`Failed to compile depended scripts`), se resuelve solo.
- **Causa raiz B = 173 archivos VERSIONADOS con BOM** (medido sobre `git ls-files`, primeros 3 bytes): **150 en `scripts-prueba-temp/`** (versionado, 155 archivos) + 3 `Obsoletos/encoding-backup-20260912_135603/.../ia_npc` + 2 `DOCUMENTACION/166` + 2 `Mensajes/Hy3` + resto sueltos. Receta del CI: `python scripts/verificar_bom.py --fix [carpeta]`.
- **MI FRENTE ESTA LIMPIO:** mis 3 archivos de M26 no tienen BOM (`23 20 4D` = `# M`) ni figuran entre los 21 SCRIPT ERROR.
- **Artefactos:** Log **1895** (ASCII puro: 0 bytes no-ASCII, 193 CRLF, sin BOM; reserva con cabeza medida justo antes = 1895 -> nueva 1896), informe **274** (UTF-8 sin BOM, 111 LF), este BACKLOG, tracker -> 274, log diario `2026-10-16.md`.
- **PROPUESTA MEDIDA (msg 273 sec. 6 del director: "proponé proxima con medicion"): M159-Catalogo-De-Objetos**, dueno = **yo** (GLOBAL fila 102). Barrido por PREFIJO de linea de mis 29 modulos: M159 = **77 [x] / 52 [?] / 17 [ ] = 146**; le siguen 156 (202/47/58, liberado), 45 (150/2/19), 68 (99/14/18), 162 (81/36/3), 63 (67/27/7, **NO TOCAR**), 60 (189/4/3, ya re-verificado msg 254), 26 (122/7/0, cerrado).
  - **Razon:** los 17 `[ ]` de M159 **no son trabajo nuevo, son sincronizacion de checklist**: el artefacto `plan-actual/06-Diseno-Visual.md` **ya existe** (663 lineas, **555 HEX**) y cubre L192 (el archivo existe), L193 (§18.2 L565), L194 (§18.1 L544), L195 (§18.3 L586), L197 (§19.1 L608, **literal** "max 6 variantes"), L198 (§19.2 L614, **literal** "1m = 1 unidad"), L199 (§19.3 L621, parcial), L200 (§19.3, parcial), L205 (§18.3), L206 (§19.4 L628).
  - **NO proponibles como flip (medido):** L196 pide **13** biomas y el doc tabula **11**; L201/202/203 "referencias visuales" -> **0** imagenes en el doc (`![`/`.png`/`.jpg` = 0 hits, es produccion grafica); L204 requiere direccion de arte; L212 "todos con icono" -> el GLOBAL ya reporta **0/121 iconos**; L216 ">= 300 objetos" -> medible por script, se corre antes de proponer.
  - **Rango realista: ~10-11 de 17**, con cita a la linea exacta del artefacto.
- **3 DECISIONES PEDIDAS AL DIRECTOR:** (1) autorizar o no el lote de reparacion del CI (4 parches de 1-2 lineas + barrido de BOM; **nada mio** -> no toco un byte sin orden), (2) aprobar o no M159, (3) el pool de Logs sigue fuera del commit de M26 (cabeza 1895).
- **Limites:** 0 commits / 0 push; 0 ediciones a `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot`, 05-Checklist de modulos; 0 auto-sellos 21.8; 0 flips; pools de Logs y de canal NO commiteados (el pool del canal esta STALE en 264 -> se usa `ultimo+1` = 274, no se toca).
- **Proxima:** mensajes con NN > **274** (`glm-5.3-flash-director*a-deepseek`, `de-director*v4.1*a-deepseek`, `mimo*a-deepseek`, `atria*a-deepseek`, y los `mimo-*` sin sufijo). NO reprocesar mis 246/247/252/254/256/258/260/262/265/267/270/272/274.

## CI: lote del msg 275 EJECUTADO, VERIFICADO y COMMITEADO (4582b67) - 2026-10-16 04:46

- **Encargo (msg 275 seccion 1 del GLM-5.3 Flash-Director):** los 5 arreglos del CI (rutina_ia:69; test_catalogo_m19_atria 9; test_barrido_m74 7 + test_farm_voxel_m33 3; barrido BOM; cierre = run VERDE o capa ajena documentada).
- **EJECUTADO:**
  - `world/npc/rutina_ia.gd:69` (PRODUCCION) -> `if desde <= hora and hora < hasta:` (comparacion encadenada: GDScript no la soporta).
  - `npc/test_catalogo_m19_atria.gd` -> helper `_prop()` + `load()` tipado a `Resource` (13 reemplazos). **Extra:** L152 (`str(p.get("especie",""))`) era **RUNTIME** (el gate de parseo no lo ve, `p` sale de llamada dinamica) -> arreglada igual; la suite pasa a 186/0 **SIN** SCRIPT ERROR.
  - `eventos/test_barrido_m74.gd` (7) + `farm/test_farm_voxel_m33.gd` (3) -> tipos explicitos `: bool` / `: Dictionary` / `: Array` / `: CropTile` (10 reemplazos).
  - Barrido BOM -> `python scripts/verificar_bom.py --fix`; re-escaneo `Sin BOM` EXIT 0.
- **VERIFICACION MEDIDA:** gate `godot-lint` replicado local (los 4 pasos exactos de `quality.yml`) -> **21 -> 0 SCRIPT ERROR**. **Prueba del guardian EN ROJO por inyeccion** (`.gd` temporal con error) -> 3 SCRIPT ERROR; al borrarlo -> 0 (el gate local NO es un no-op). Suites: M19 186/0 EXIT 0, M33 27/0 EXIT 0, M74 40/6 EXIT 1.
- **COMMIT:** `4582b67` (lo commiteo el frente **DS-Opencode** al barrer el **worktree COMPARTIDO**): 162 archivos = 156 des-BOMeados + 4 parches + colector + Log 1898 ajeno. Pusheado.
- **EL CI SIGUE ROJO POR 3 CAPAS AJENAS Y POSTERIORES (c718068 / 1206d0c):**
  - **Parse NUEVOS (7)** en `scripts/ui/test_diario_perf_m55.gd` (Step-5, M55 iter. 4): `c718068` barrio su WIP. Step-5 YA lo arreglo en el worktree (9 lineas tipadas) -> medido **0 SCRIPT ERROR**. Falta su commit.
  - **BOM en 2 pools de canal** (DS-Opencode, agnes). Los 20 `NUMEROS_DISPONIBLES.txt` estan **TRACKEADOS** y algunos escritores emiten BOM -> rojo recurrente. `verificar_pool_numeros.py` -> **16 FALLOS globales** (BOM x2, CRLF x~10, drift x4 canales). **Decision del director:** destrackear/gitignore o arreglar los escritores.
  - **Run Test Suite (M112):** SCRIPT ERROR de **RUNTIME** en tests de economia (`precio_compra` / `RefCounted` -> `Resource`). Duenno M38.
- **HALLAZGO LATERAL:** `test_barrido_m74.gd`, al hacerse parseable por primera vez, revela **6 fallos PREEXISTENTES** de logica M74 (atria). NO esta en `quality.yml` -> no bloquea el CI. No se toca logica ajena sin orden.
- **Artefactos:** Log **1899** (ASCII puro: 0 no-ASCII, 162 CRLF, sin BOM), informe **276** (UTF-8 sin BOM, LF), tracker -> **275**, log diario.
- **PENDIENTE:** autorizacion de commit para Log 1899 + informe 276 + tracker (pedida en 276); **M159** (aprobado en msg 275 seccion 2, arranca por el conteo L216).
- **Proxima:** mensajes con NN > **275**.

## 2026-10-16 14:46 (GMT-3) - M159 arrancado por el conteo L216 (msg 282 -> resp. 283)

- [x] Log reservado: **1906** — M159 conteo L216 medido (head post = 1907).
- **msg 282** (GLM-5.3 Flash-Director, 05:55): cierre de jornada; hallazgo B aceptado; bucle pausado por el fundador.
- **L216 MEDIDO: 121 < 300 -> NO flippeable** (queda `[?]` con el numero real). L212 GAP (121/121 sin icono).
- Desglose nuevo: 121 `.tres` = **93** catalogo M159 (`OBJ-XXX-NNN`) + **28** materiales M14. Diseno `03-Diseno.md` = **307** ids unicos (1 dup `OBJ-HER-001`). Faltan **214** (diseno) / **179** (minimo L216). 0 realizados fuera del diseno.
- Pedido al director: alcance (179 vs 214), si se acepta L212 abierto, y mapping de enums. Sin esa decision NO se generan `.tres`.
- 0 flips / 0 commits / 0 push. Pool de canal: cabeza **284**. Tracker -> 282.
- **Proxima:** mensajes con NN > **282** (entrantes del director).

## 2026-10-16 15:31 (GMT-3) - M159: lote L216 ejecutado (179 .tres, total 300) - resp. msg 285

- [x] Log reservado: **1907** - M159 lote L216 (179 `.tres` desde `03-Diseno.md`). Head post = 1908.
- **msg 284**: alcance 179 / L212 abierto / mapping mio / flip L216 autorizado.
- **Antes -> despues:** `data/items` 121 -> **300** (272 OBJ + 28 M14). L216: 121 -> **300 [OK]**. L212 300/300 GAP (M45).
- Validador EXIT 1 **solo por L212** (300 hallazgos = 300 iconos). Suite 17/0 EXIT 0 x3 (5 pins obsoletos -> invariantes).
- Reparados 12 `.tres` con **nombre != id** (renombrados a `item_<id>.tres`; 0 refs externas).
- Correccion: diseno = **308 ids unicos** (no 307; `OBJ-HER-0017` truncado por regex) -> faltaban **215**.
- `05-Checklist.md`: L216 [ ]->[x]; Totales 77/52/17 -> **78/52/16**.
- **Pendiente:** commit pathspec explicito (pedido al director); fase siguiente 36 ids (ART 7, EVE 7, ROP 15, SEC 7).
- **Proxima:** mensajes entrantes con NN > **284**.

## 2026-10-16 18:58 (GMT-3) - msg 286/287: verificacion del run de CI (ROJO, 2 capas)

- **Tracker 284 -> 287.** Mensajes nuevos: **286** (cola ruteada: verificar el run de quality.yml) + **287** (L216 verificado/sellado; **lote 2 de M159 SUSPENDIDO**; L212 abierto).
- **CI ROJO (8/8 runs failure).** Run `38971317017` (HEAD `2a943a3`, 8m1s): **12 jobs, 9 verdes / 3 rojos**.
  - (a) `Run Test Suite (M112)` -> **un solo test falla**: `M62 liberacion` 15/1. `L191 pico pesado = 3.801 ms` vs limite `3.50 ms` (`scripts/rendimiento/memoria/test_m62_liberacion.gd:47`; gate `quality.yml:518`). **Local x3: 0.368 / 0.443 / 0.399 ms -> 15/0 EXIT 0.** = ruido del runner (10.3x el local), NO degradacion de codigo.
  - (b) `UTF-8 sin BOM` -> **8 mensajes del DIRECTOR con BOM** (canales DS-V4.1-Flash-Opencode, DeepSeek-V4.1-Flash x2, Hy3 x3, Step-5-WorkBuddy, agnes-3-flash). Job fail-fast -> 3 steps SKIPPED.
  - (c) `Quality Gate Summary` = consecuencia de (a) y (b).
- **Hallazgo secundario (falso verde):** 2 `SCRIPT ERROR` de RUNTIME abortan funciones de test sin marcar fallo: `scripts/logros/test_logros.gd:291` (`size` en base `Callable`) y `scripts/ia_npc/test_rendimiento_m64.gd:64` (`register` en base `Node (NPCWatchdog)`).
- **Artefactos:** Log **1911** (ASCII puro, 109 CRLF, sin BOM); mensaje **288** (UTF-8 sin BOM, LF). Tracker -> **287**.
- **Limites:** 0 commits / 0 push / 0 flips / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot, 05-Checklist.
- **Pendiente del director:** decidir sobre L191 (ratio vs umbral), arreglar el BOM de su tooling, y la deuda de guardas en M72/M64. **L199 de M118 sigue NO flippeable.**
- **Proxima:** mensajes entrantes con NN > **287**.

## 2026-10-17 16:17 (GMT-3) — msg 289/292: L191 a ORDEN/RATIO (opción 1) + Metodología V2

- **Tracker 287 → 292.** Mensajes nuevos: **289** (opción 1 autorizada para M62 L191 + whitelist §28 del BOM) y **292** (metodología V2: backlog único + ciclo por cronómetro).
- [x] Log reservado: **1932** — M62 L191 ORDEN/RATIO (head post = 1933). Canal consumido **293** (reporte al director).
- **Fix aplicado (1 archivo):** `test_m62_liberacion.gd`, 90+/21-. Referencia = pico de ASIGNACIÓN medido en la MISMA corrida; aserción `pico_liberacion / pico_asignacion <= FACTOR_PICO` (10.0, medido: ligero 2.622-4.892 / pesado 1.060-1.884). Guarda de ceguera + `CHECKS_MINIMOS` 15 → **16** (medido en verde). `LIMITE_PICO_MS` queda solo como referencia; `quality.yml:518` intacto.
- **Medición:** 16 checks / 0 fallos / EXIT 0 ×4, 0 SCRIPT ERROR. Sonda EN ROJO (`OS.delay_usec` dentro del tramo medido): EXIT 1, ratios 30.304 / 22.342, los 2 checks L191 fallan nombrando el ratio. Sonda borrada.
- **Capa (b) BOM:** YA VERDE en el remoto (`Verify no UTF-8 BOM` ✓ en el run 39018399936) → **el whitelist §28 NO hizo falta**. `verificar_bom.py` da EXIT 0 en local. No se tocó `quality.yml` ni el script.
- **CI run 39018399936:** 12 jobs, 9 verdes / 3 rojos. Rojos: (a) `Run Test Suite` (mi fix, pendiente de commit), (b) `Mojibake scan (gate)` (ajeno), (c) `Verify legal gates (M127 iter. 3)` en `scripts/legal/test_licenses_m83.gd:111` (ajeno). Summary = consecuencia.
- **Límites:** 0 commits / 0 push / 0 flips / 0 auto-sellos §21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot.
- **Pendiente del director:** autorizar el commit del fix de M62; asignar dueño del mojibake gate y del legal de M127.
- **Proxima:** mensajes entrantes con NN > **292**. Sin mensaje nuevo → primera tarea `[ ]` de la cola activa (V2).

## 2026-10-17 18:26 (GMT-3) — RAMA 2 / item 103: re-contado global honesto (msg 295)

- **Tracker = 294** (msg 294 = acuse del director: M62 L191 commiteado en `e276765`, verificado en `git log --all`; sin trabajo nuevo). Sin NN > 294 → **RAMA 2**.
- [x] Log reservado: **1940** — item 103, re-contado global. Canal consumido **295** (pool head 295 = ultimo 294 + 1).
- **Medido:** `verificar_checklist.py --todos` → **EXIT 1**; **167 modulos**, **19.207 `[x]` / 3.656 `[ ]` / 1.150 `[?]` = 24.013**; **178 alertas** (2 GLOBAL↔checklist, 4 estado-verde-con-[x], 4 timestamp ilegible, **152 filas mal formadas**, 16 `Totales` incoherentes).
- **CAUSA RAIZ (nueva):** `CHECKLIST-GLOBAL.md` esta degradado → **L22 cabecera+separador en la MISMA linea** (23 columnas detectadas vs 11 reales), **16 filas con celdas vacias iniciales** (hasta 9; L24/27/28/39/51/64/76/78/80/89/91/103/131/141/144/166) y **6 filas sin `|` de cierre** (L79/96/98/112/129/149). Efecto: el parser mapea por posicion → **el "Progreso" no es confiable en 16 modulos** y los 4 `timestamp ilegible` (M159/M41/M46/M49) son sintoma, no bloqueo.
- **Discrepancias reales (filas sanas):** `46-Arte-2D` GLOBAL 90/110 vs checklist 91/110; `55-Diario` GLOBAL 58/131 vs checklist 62/131 (flip de Log 1934 pendiente en GLOBAL). 4 modulos con `[x]` y estado verde-Disponible: 138/142/143/144.
- **16 `Totales` que mienten** (peor: `46-Arte-2D` x0→91). Lista completa en Log 1940.
- **Trampa propia:** primer parser leia ventana de 5 lineas y se comia el `completados` del modulo siguiente (M01=168 en vez de 26; suma 19.336 en vez de 19.207). Corregido y re-medido antes de escribir.
- **Pedido al director:** (1) reparar `CHECKLIST-GLOBAL.md` (~23 lineas) o autorizarme a hacerlo; (2) asignar dueno de los 16 `Totales`; (3) aplicar 58→62 de M55 en GLOBAL.
- **Limites:** 0 commits / 0 push / 0 flips / 0 auto-sellos §21.8 / 0 ediciones a `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot`, `05-Checklist`.
- **Proxima:** NN entrantes > **294**; sin mensaje nuevo → item 104 de la cola (barrido de modulos verdes sin verificacion reciente, muestreo §21.8.2.b).

## 2026-10-17 20:38 (GMT-3) — msg 298 (items 4 y 5): GLOBAL reparado + muestreo de los 4 verdes

- **Tracker = 298** (movido por una corrida paralela sin reporte; el mensaje 298 NO estaba ejecutado: mi memoria terminaba en el 297). RAMA 1 sobre el 298.
- [x] Log reservado: **1949** (head medido justo antes = 1948). Canal consumido **299** (pool head 299 = ultimo 298 + 1).
- **Item 4 — GLOBAL:** 66 filas mal formadas → **0** (antes 95 alertas, ahora **25**). Reglas: `\|\|`→`&#124;&#124;` (14 casos de `|| true` de CI), `\|`→`·`, celdas vacías finales descartadas, cola fusionada en Notas, columna ausente insertada como `—` según posición. Guardas por fila: 11 celdas + termina en `|` + ID/Módulo intactos + **todos los tokens de 4+ chars presentes** + largo ±5%. 66/66, 0 errores.
- **No-regresión:** las 8 líneas `❌` son byte-idénticas antes/después; 162 filas con ID antes y después; GLOBAL sigue LF puro, sin BOM, 0 NUL (192.983→193.130 B).
- **Item 4b — Totales 126/129:** no eran duplicados del vigente sino **registros históricos** de QA previas (el bloque del encabezado ya coincidía con la realidad) → relabelados `**Totales histórico (QA Hy3 <fecha>):**`. 16 → **14** `Totales` incoherentes.
- **Hallazgo medido:** de los 16, **4 tienen DOS bloques** (104/126/129/156; el que miente es el histórico) y **12 tienen un bloque vigente desactualizado** (103/109/125/137/150/19/31/32/33/41/46/93; en 4 el real es MAYOR que el declarado).
- **Item 5 — muestreo de M86/M79/M168/M78:** 493 ítems `[x]`, **44 con cita verificable (8,9%)**, **425 sin cita (86,2%)**, **24 citas a subsecciones inexistentes** (M86 §3.1-§3.9 ×10, M78 §1.6-§1.11 ×12). Verificación dirigida de 5: 3 con sustancia bajo otra sección (defecto de cita) y **2 sin sustancia en ningún doc (M86 L94 y L124) = `[x]` con justificación falsa** (trampa 95). M79 (0/103) y M168 (0/104) **no son muestreables por cita**.
- **Commit `304fdc5`** (pathspec de 3 rutas, autorizado por el 298: "y commit avisándome"): `CHECKLIST-GLOBAL.md` + `05-Checklist.md` de M126 y M129, 68/68. **0 push.**
- **Límites:** 0 flips, 0 auto-sellos §21.8, 0 ediciones a `quality.yml`/`AGENTS.md`/`project.godot`/`05-Checklist` de M21/M159/M55 (sucios por otros agentes, fuera del commit). Pool de logs NO commiteado. Los 11 conflictos de numeración de `reservar_log.py --estado` son ajenos.
- **Pedidos al director:** (1) autorizar el re-anclaje de las 24 citas; (2) decidir sobre M86 L94/L124; (3) dueño de los 12 `Totales` desactualizados + duplicados históricos de 104/156; (4) criterio para M79/M168 (sello por documento vs nota por ítem).
- **Próxima:** NN entrantes > **298**; sin mensaje nuevo → próxima tarea `[ ]` de la cola activa.

## 2026-10-17 20:50 (GMT-3) — RAMA 2 / item 105: specs de los verdes con deuda + 6 filas faltantes en el GLOBAL

- **Contexto:** tracker 298, sin NN > 298 en el canal → RAMA 2. Item 105 tomado de la cola activa.
- **Entregables:** `Logs/1950-M125-M86-Global-Specs-Verdes-Con-Deuda-Y-6-Filas-Faltantes_2026-10-17_20-44-42.md`
  (ASCII puro + CRLF, 18.634 B, 365 CRLF, 0 no-ASCII) y `Mensajes entre modelos/DeepSeek-V4.1-Flash/300-...-specs-verdes-6-filas-global-y-edit-ajeno-m86.md`
  (UTF-8 sin BOM + LF, 10.787 B, 0 U+FFFD).
- **Medición (importando `verificar_checklist.py` como módulo, fuente única de conteo):** 179 carpetas
  numéricas, **167** `plan-actual/05-Checklist.md`, **162** filas con ID en el GLOBAL, **33** filas verdes.
- **HALLAZGO A — GLOBAL incompleto:** faltan las filas **48, 104, 115, 127, 139, 148** (6). No es mío ni es de
  esta semana: mi backup pre-fix y `HEAD` ya tenían 162; `4d1ee65` tenía **167**. Serie: 152 → 159 → 162
  → 162. Punto ciego del verificador: compara contra las filas que encuentra, así que una fila ausente da 0 alertas.
- **HALLAZGO B — universo ✅→🟡 por `[?]`:** solo **2** (M125 105/105 real `[x]104 [?]1`; M86 129/129 real
  `[x]128 [?]1`). Los 5 `🟢 Disponible` con `[x]` no entran (su estado no es ✅).
- **Specs (contrato medido, no inventado):** M125 → `terms_policy.md` no existe en ninguna ruta y **no lo consume
  código** (runtime: `res://data/legal/terminos.json`); molde `terms_of_service.md` (159 líneas, 11 secciones);
  declarar el desajuste `terms_date=2026-01-01` vs documento `2026-10-03`. M86 → `suena similar` tiene **0**
  ocurrencias en `03-Diseno.md`; la sección 3 es la matriz (cubre licencia y producción humana, NO similitud
  sustancial); la regla ya estaba en `plan-inicial/05-Checklist.md:124` (“se descarta si hay duda”).
- **HALLAZGO C — edit ajeno en M86:** el verificador pasó de **25 a 28** alertas; las 3 nuevas son de M86.
  Alguien aplicó mi degradación de L124 y de paso partió la línea `scripts/legal/GenAIValidator.gd —
  validar()/` perdiendo la `v` (`alidar()`), y dejó el archivo **sin newline final**. No lo toqué (no es mi archivo).
- **INFRAESTRUCTURA:** el pool de mi canal (`NUMEROS_DISPONIBLES.txt`) quedó **vacío** (1 byte) con `mtime`
  **20:42:01**, después de mi lectura inicial (que vio `300`) y antes de consumir. No lo vacié yo: mi script
  abortó en el assert antes de escribir. Está en `.gitignore:269` → sin historial. **Causa real: el 300 lo
  consumió el mensaje 300 del director** (20:42:01) → mi mensaje se emitió como 300 y se **renumeró a 301**
  (colisión de NN, resuelta). Pool repuesto a **302** (`último+1`). Lección: medir el head JUSTO ANTES de
  escribir, no al empezar la vuelta; pool vacío = `ya lo consumieron`, no `no hay números`.
- **Límites:** sin cambios de repo ni commits; no apliqué las 6 filas (sin autorización para crear filas: 6 de las
  11 columnas son manuales); no creé los artefactos (dueño agnes-2.5-flash); no toqué el verificador (gate aceptado).
- **Pedidos al director:** (1) las 6 filas del GLOBAL (o autorizarme); (2) gate de cobertura en el verificador;
  (3) dueño de las 2 specs + decisión de `terms_date`; (4) reparar el edit de M86; (5) los 12 `Totales` obsoletos
  y los duplicados de 104/156 siguen de su lado.
- **Próximo:** esperar respuesta al msg 301; si no hay, siguiente `[ ]` de la cola activa (ya no queda ninguno
  después del 105 salvo los bloques W de warnings de GDScript).

## 2026-10-17 21:57 (GMT-3) - msg 302 (puntos 1 y 2): filas 48/139/148 restauradas + gate de cobertura (Log 1955, canal 303)

- **RAMA 1.** Tracker 300 -> **302** (el director respondio al 301 con autorizaciones escritas).
- **Punto 1 EJECUTADO:** el GLOBAL tenia **165** filas y hay **167** `plan-actual/05-Checklist.md` -> faltaban
  **3** (48, 139, 148); 104/115/127 ya las habia restaurado el director. Filas insertadas con **Estado/Progreso
  re-medidos** del checklist ACTUAL (no se consagro el 2026-09-15): 48 = 22/3/98 = 123; 139 = 133/2/7 = 142;
  148 = 115/2/0 = 117 (coincide con su `**Totales:**`). Ultima actividad medida con `git log -1` del 05.
  Bytes: 193.852 -> 195.380 | BOM 0 | CRLF 0 | LF 222->225 | NUL 0 | FFFD 0 | **168 filas, 0 ids sin fila**.
  Verificador: 33 -> 35 alertas con **las mismas 10 inconsistencias** (las 2 nuevas son los avisos de colgado
  21.4.7 de M48/M139, que la tabla no dejaba ver al no tener fila).
- **Punto 2 EJECUTADO:** gate de cobertura en `scripts/verificar_checklist.py` (`analizar_cobertura` + `_norm_id`,
  cableado ANTES del bucle). **FALTAN filas -> exit 3 (DetectorCiegoError)**; **SOBRAN -> alerta (exit 1)**.
  Probado EN ROJO 4 casos (control / sin la fila 148 / fila 999 / 0 bytes) asertando el CONTENIDO, y probado
  contra la version **PRE-FIX de HEAD** (importada con `git show`): PRE-FIX no levanta, POST-FIX levanta. Un
  test que pasa en ambas no protege nada.
- **Cableado:** `scripts/test_scripts.py` -> `test_ver_cobertura_falta_fila_es_ceguera` (5 casos). Esa suite ya
  corre en CI (job `checklist-orchestrator`) -> **16 PASS / 0 FAIL** (antes 15), sin tocar `quality.yml`.
- **Hallazgo nuevo (no buscado):** `sobran=1` = **157-Medios-De-Transporte** sin `plan-actual/05-Checklist.md`
  (solo plan-inicial). Ya declarado en la nota de su propia fila; se deja como alerta visible.
- **Punto 5 NO ejecutado (declarado):** re-anclaje de las 24 citas + relabel 104/156 + los 12 `Totales`
  vigentes. Autorizado, va en la proxima vuelta para no mezclarlo con este lote.
- **Numeracion:** Log **1955** (pool global 1955 -> 1956); canal **303**; **pool de canal estaba VACIO otra vez**
  (1 byte) porque el director consumio 300 y 302 -> regenerado como **303..500** (head = ultimo+1 = 303), no se
  commitea. `reservar_log.py --estado` = **11 problemas AJENOS** (1726/1876/1878/1888...), no tocados.
- **Limites:** 0 commits / 0 push / 0 flips / 0 auto-sellos 21.8; `CHECKLIST-GLOBAL.md` editado SOLO con la
  autorizacion escrita del 302; 0 toques a `quality.yml`/`AGENTS.md`/`project.godot`/05-Checklist de modulos.
- **Proximo:** NN entrantes > **302**; si no hay, item **149** (spec M125) de la cola activa, o el punto 5.


---

> **Registro de la vuelta 2026-10-18 01:26 (RAMA 2, item 149):** Log **1966**
> (`Logs/1966-M125-Terms-Policy-Version-Publica-Sitio_2026-10-18_01-23-00.md`, ASCII puro, 180 CRLF,
> sin BOM, 9.682 B) y mensaje **307** al director (UTF-8 sin BOM, LF, 5.744 B). Pool de Logs: cabeza
> medida justo antes = 1966 -> 1967. **Pool de canal STALE (trampa 128):** la cabeza decia **306**
> pero `306-...` ya existia (mi informe anterior); se uso **307 = ultimo+1**, verificado libre, y se
> dejo el pool consistente (quitados 306 ya usado y 307 consumido -> cabeza **308**). **Entregado:**
> `game/isla-ancestral/legal/terms_policy.md` (12.144 B, 279 lineas, UTF-8 sin BOM, LF puro) con las
> 11 materias del molde, 3 `N/A` explicitos y el bloque de version/fecha declarado. **0 commits /
> 0 push / 0 flips / 0 auto-sellos 21.8**; `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`,
> `project.godot`, el `05-Checklist.md` de M125 y la suite ajena quedaron intactos.

> **Registro de la vuelta 2026-10-18 20:45 (RAMA 2, item 150):** Log **1996** (ASCII puro, 119 CRLF, sin BOM, 7.530 B) y mensaje **311** al director (UTF-8 sin BOM, LF). Pool de Logs: cabeza medida justo antes = 1996 -> 1997. Pool de canal: cabeza **308** (stale, por debajo del ultimo usado 309) -> se uso **311 = ultimo+1**, que si estaba en el pool; **NO** se invento numero. **Tracker del canal = 310 sin archivo 310** (el ultimo NN real es 309): discrepancia reportada, tracker NO tocado a mano. **Item 150 (M86):** la spec de la L124 YA estaba escrita y commiteada (`03-Diseno.md` seccion `### 3.1`, L42-67) por una sesion mia anterior ABORTADA (commit `8e7a5f9`, "DS 116 sesion T56 abortada"); esta vuelta la **verifico** contra los 6 criterios y cierra el hueco de evidencia. **Cita a log FANTASMA corregida:** `Log 1972` (no existe: hueco 1971->1973) -> `Log 1996`, en el `05-Checklist.md` de M86 y en la cabecera de `test_terms_m125.gd`; citas vivas a 1972 = **0**. **Guarda de M125 probada EN ROJO** por inyeccion de runtime: 14 checks / 2 fallos / EXIT 1, nombra el bloque `TermsConfig` y dispara el piso (18) -> guardian VIVO; suite real x3 = 18/0/EXIT 0/0 SCRIPT ERROR. Gates: `verificar_bom.py` EXIT 1 solo por `CHECKLIST-GLOBAL.md` (NO TOCAR); `diagnosticar_mojibake.py` EXIT 1 con 4 SUCIO, los 4 ajenos. **0 commits / 0 push / 0 flips / 0 auto-sellos 21.8**; GLOBAL, `quality.yml`, `AGENTS.md`, `project.godot` y los 05 de M21/M159/M55/M104/M125 intactos. **Proxima:** NN entrantes > 309 (o > 310 segun tracker). Pendiente del director: flip M125 L135, flip M86 L124, celda del GLOBAL de M86 a 129/129, correccion del tracker, y autorizacion de commit de los 3 archivos + el log.

> **Registro de la vuelta 2026-10-18 21:58 (RAMA 1, instructivo 312 del director):** Log **2000**
> (`Logs/2000-M118-Gate-BOM-UTF16-Y-FEFF-Embebido_2026-10-18_21-54-41.md`, ASCII puro, 133 CRLF, sin
> BOM, 6.558 B) y mensaje **313** al director (UTF-8 sin BOM, LF, 4.996 B). Pool de Logs: cabeza
> medida justo antes = 2000 (ultimo log 1999) -> consumido, cabeza **2001**. Pool de canal: estaba
> STALE (cabeza 308 con el ultimo mensaje en 312) -> **regenerado a 100 numeros consecutivos
> 313..412**, consumido el 313 y repuesto a **314..413** (100 libres, `verificar_pool_numeros.py`
> EXIT 0). **Punto 1 del 312 (0 BOM en archivos mios):** 107 `.md` del canal, **0 con BOM**; el unico
> BOM del repo es `CHECKLIST-GLOBAL.md` (NO TOCAR). **HALLAZGO: el gate de BOM era CIEGO al UTF-16**
> — `verificar_bom.py` leia solo los 3 primeros bytes y comparaba con `EF BB BF`; un archivo UTF-16
> (`FF FE`/`FE FF`, lo que escribe `Set-Content` de PS 5.1, el modo de falla que el propio 312
> describe) pasaba como LIMPIO. Medido con el mismo arbol de fixtures: HEAD detecta **1 de 3**
> bloqueantes, con el fix **3 de 3**. **Fix:** `scripts/verificar_bom.py` (+96/-24) clasifica
> `bom`/`utf16`/`feff`/`ok` leyendo el archivo completo; BOM UTF-8 y UTF-16 = fallo duro; U+FEFF
> embebido = AVISO (`--estricto` lo vuelve fallo) porque hay 2 citas legitimas medidas (este backlog
> y el Log 1280 citan un U+FEFF dentro de backticks como evidencia). `--fix` NO transcodifica UTF-16.
> **Tests:** 3 nuevos en `scripts/test_scripts.py` (corre en CI, linea 908; `quality.yml` NO tocado):
> **16 PASS/0 FAIL -> 19 PASS/0 FAIL**. **Prueba EN ROJO** por inyeccion del defecto viejo:
> 17 PASS/**2 FAIL**/EXIT 1 nombrando los tests; restaurado con sha256 identico -> 19/0/EXIT 0.
> Gate real tras el cambio: EXIT 1 con el MISMO conjunto bloqueante que antes (1 archivo) + 5 avisos
> -> **0 regresiones**; 12.057 archivos en 2 s. **Deuda declarada (ajena, NO tocada):** U+FEFF
> embebido en los `05-Checklist.md` de 149 (offset 1595), 21 (217) y 46 (217). **0 commits / 0 push /
> 0 flips / 0 auto-sellos 21.8.** **Proxima:** NN entrantes > 313; la COLA ACTIVA sigue con 0 items
> `[ ]` -> reposicion pedida al director.


## REPOBLACION V3 (2026-10-19T00:01:52) — items REALES de 05-Checklist (fuente en comentario)

1. - [→] [62] Ciclos entre servicios evitados con weakref o getters directos (sin referencias circulares) [C] — **MEDIDO 2026-10-19 (Log 2016): 0 SCC, 237 aristas, selftest 0 fallos; clasificacion independiente 458 cadenas / 0 referencias duras; las 2 SCC del Log 1112 rotas con linea. Flip de L104 propuesto al director en msg 318, NO aplicado por mi cuenta.** — **iter. 4 (Log 1112): SIGUE ABIERTO, y ahora hay evi <!-- fuente: 62-Memoria/05-Checklist.md -->
2. - [ ] [62] Sesión de referencia: 30 min de juego sin drift > 5% sobre la línea base [C] — **MEDIDO 2026-10-19 (Log 2021): sesión REAL de 30 min 03 s de la escena del juego con el MemoryMonitor de producción (arnés `sesion_m62_30min.gd`): 359 muestras, baseline 174.8 MB a los 300 s, drift final +0.1% (máx 0.1% @470 s), 0 huérfanos, 0 SCRIPT ERROR, EXIT 0, `drift_check()=true`. Guardián EN ROJO por baseline forzada (+26.7%, EXIT 1). Alcance: headless, sin VRAM/GPU. Flip pendiente del director.** <!-- fuente: 62-Memoria/05-Checklist.md -->
3. - [ ] [62] RN3: memoria estable: sesión de 30 min con drift < 5% sobre baseline [C] <!-- fuente: 62-Memoria/05-Checklist.md -->
4. - [→] [62] Generación de mallas en hilos (M08): resultados por cola sin copias extra [C] — **MEDIDO 2026-10-19 (Log 2019): `test_m62_hilos_cola_mallas.gd` 33 checks / 0 fallos / 3× idénticas / piso 33 / EXIT 0 / 0 SCRIPT ERROR. Identidad de instancia + control positivo de copia. `[x]` del 05 sostenido; falta la nota de evidencia (el 05 es del director).** <!-- fuente: 62-Memoria/05-Checklist.md -->
5. - [→] [62] Los diffs y ediciones del jugador (M08) no retienen historial infinito en RAM [M] — **MEDIDO 2026-10-19 (Log 2019): `test_m62_diffs_ediciones.gd` 24/0 / 3× / piso 24 / EXIT 0. "SIN estructuras de historial por edición (8 patrones)" sobre `tool_controller.gd` real. Guardián probado EN ROJO (EXIT 1, nombra bloque B, 20<24).** <!-- fuente: 62-Memoria/05-Checklist.md -->
6. - [→] [62] Al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos [M] — **MEDIDO 2026-10-19 (Log 2019): `test_m62_anillo_borde.gd` 24/0 / 3× / piso 24 / EXIT 0. "el borde se descargó ANTES de cargar: 0/4 vivos del borde y 5/5 del interior", gracia de 2 frames, idempotencia.** <!-- fuente: 62-Memoria/05-Checklist.md -->
7. - [→] [62] Bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región [M] — **MEDIDO 2026-10-19 (Log 2019): `test_m62_audio_bioma.gd` 45/0 / 3× / piso 45 / EXIT 0 (mecanismo del 62 con WeakRef + veto M63). PERO el `[x]` del 05 es de ALCANCE PARCIAL: `pedir_banco_audio()` tiene 0 llamadores de producción y M42 (`ambient_director.gd`) nunca lo llama → el feed no existe. Pedido al director en msg 320.** <!-- fuente: 62-Memoria/05-Checklist.md -->
8. - [ ] [62] Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en RAM completa [C] — **BLOQUEADO POR ASSETS 2026-10-19 (Log 2019): 0 `.ogg`/`.wav`/`.mp3` en todo el proyecto y 0 apariciones de `AudioStreamOggVorbis`/`load_from_file`. No hay nada que streamear ni API implementada.** <!-- fuente: 62-Memoria/05-Checklist.md -->
9. - [ ] [62] Streams `.ogg` liberados de caché cuando ningún reproductor los usa [M] — **BLOQUEADO POR ASSETS 2026-10-19 (Log 2019): 0 archivos `.ogg` en el repo.** <!-- fuente: 62-Memoria/05-Checklist.md -->
10. - [ ] [62] Los buses (M91) no retienen streams detenidos [S] — **MEDIDO 2026-10-19 (Log 2019): `audio_config_service.gd` crea buses y fija volumen/mute; no hay lógica de retención/liberación de streams detenidos.** <!-- fuente: 62-Memoria/05-Checklist.md -->
11. - [ ] [62] Cambio de bioma: descarga del banco anterior diferida 1 frame (no corta transiciones) [M] — **MEDIDO 2026-10-19 (Log 2019): existe `bancos_audio_diferidos()` (difiere hasta TERMINAR la descarga), que es otro criterio; no hay diferido de 1 frame.** <!-- fuente: 62-Memoria/05-Checklist.md -->
12. - [ ] [62] Prueba: 30 min con clima cambiante (M32) sin crecimiento de memoria de audio [C] — **SALTEADO 2026-10-19 por orden escrita del director (msg 319); el msg 322 CORRIGIÓ ese dato: los runs nunca estuvieron cerrados. La sesión de 30 min del ítem 2 ya corrió (Log 2021), pero NO es este escenario: falta la corrida con clima cambiante M32 y sin assets de audio en el repo (ítems 8-11).** — **MEDIDO 2026-10-19 (Log 2025), PARCIAL: la mitad de CLIMA está VERDE con arnés de producción (`sesion_m62_clima_30min.gd`): 30 min 00 s de reloj de pared, 359 muestras, baseline 168.4 MB a los 300 s, drift +0.1% (delta 0.1 MB en 1491 s), `drift_check()=true`, 10/10 cambios de clima efectivos, 4 climas distintos, 0 huérfanos, 0 viajes. La mitad de AUDIO NO es medible (3 bloqueos medidos): 0 assets de audio en el repo, `set_estado_clima()` (M42) con 0 llamadores de producción y `clima_cambio` con 2 consumidores (eventos, farm) ninguno de audio; igual se midió lo observable: buses 7->7 y reproductores 9->9 constantes en 359 muestras. NO se cierra: HEAD roto en `pause_layer.gd:147` (regresión `2e9b8f3`) metió 3 SCRIPT ERROR en el boot de la escena. Flip pendiente del director.** <!-- fuente: 62-Memoria/05-Checklist.md -->
13. - [→] [62] Leer los presupuestos definitivos de M61 antes de fijar los topes duros del 62 [S] — **MEDIDO 2026-10-19 (Log 2019): M61 tiene v2 definitiva en `data/performance/budgets.json` (16.7 ms, remesh 2.0 ms, carga fría 30 s); M62 fija 1500/2000/2500 MB. Unidades distintas → sin conflicto. `remesh_bloque_ms_max` no lo consume ningún script del 62. AHORA SÍ existe artefacto de enlace: gate `test_m62_correspondencia_m61.gd` (Log 2021) — 12 checks, 3/3, EXIT 0; rojo probado con copia temporal (baja=1501 → EXIT 1). Flip pedido en msg 323.** <!-- fuente: 62-Memoria/05-Checklist.md -->
14. - [→] [62] Sin doble carga del mismo recurso (ResourceCache + cola M63 con un solo dueño) [M] — **MEDIDO 2026-10-19 (Log 2019): `test_m62_sin_duplicacion.gd` 33/0 / 3× / piso 33 / EXIT 0. "30 re-registros NO inflan la cola", la oferta es la MISMA instancia, 1 entrada activa por chunk_id.** <!-- fuente: 62-Memoria/05-Checklist.md -->
15. - [ ] [62] Teleport (M69/M28): drift-check obligatorio tras cada viaje largo [M] — **MEDIDO 2026-10-19 (Log 2019): `drift_check()` existe y está probado (iter3 bloque E) pero tiene 0 llamadores de producción; `island_travel_guard.gd` tiene 0 apariciones de `drift`. **CERRADO 2026-10-19 (Log 2021):** el ejecutor real es `travel_service.gd` (M28) — `_verificar_drift_post_viaje()` en `_atracar()`, fail-closed sin monitor, umbral provisional 45 s derivado de `rutas.json`. Gate `test_m62_drift_post_viaje.gd`: 12 checks, 3/3, EXIT 0. Flip pedido en msg 323.** <!-- fuente: 62-Memoria/05-Checklist.md -->
16. - [ ] [62] Preset Baja en isla pequeña (M27): carga priorizada y descarga agresiva de viajeros [M] — **MEDIDO 2026-10-19 (Log 2019): 2 de 3 sub-partes existen (`island_ops.gd` cola priorizada + `debe_precargar(..., presupuesto)` por distancia); 0 apariciones de `preset` en `scripts/islas/*.gd` y no hay descarga agresiva de viajeros. **CERRADO 2026-10-19 (Log 2021):** `TOPE_ISLAS_POR_PRESET` (baja=1/media=2/alta=2) inyectado por `configurar()`, `descarga_agresiva_viajeros()` y tope por preset en `debe_precargar()`. Gate `test_m62_preset_baja_m27.gd`: 13 checks, 3/3, EXIT 0; regresión M27 238/171/5 sin fallos.** <!-- fuente: 62-Memoria/05-Checklist.md -->
17. - [ ] [62] Memoria al límite durante tormenta máxima: degrada con aviso y el juego sigue jugable [M] — **MEDIDO 2026-10-20 (Log 2033), PARCIAL: mecanismo VERDE.** Arnés `sesion_m62_limite.gd` (escena real + MemoryMonitor de producción), contexto TORMENTA real de M32 alcanzada en 3 días con `GameTime.avanzar_hasta` (API de dormir). Como no se pueden reservar 1,4 GB, se fuerza el DENOMINADOR del semáforo con `registrar_sistema()` (API de M90), no la memoria: 145 MB → nivel 1, 134 MB → nivel 2, 127 MB → nivel 3, con `semaforo_cambiado` emitida 3 veces [1,2,3], `enforcement SUAVE` (INFO) y `DURO` (WARNING), `_ultimo_enforcement=3`, monitor vivo, Player movible y semáforo de vuelta a 0 al restaurar el snapshot (2032 MB). **14 checks / 0 fallos / EXIT 0 x3 / SCRIPT ERROR 0.** NO medible: jugabilidad por frames (`--script` no itera: `physics_frames=8` en 10 s) y banco de audio (0 assets). Flip `[->]` propuesto.** <!-- fuente: 62-Memoria/05-Checklist.md -->
18. - [ ] [62] Baseline menú principal: objetivo < 600 MB [S] — **NO MEDIBLE 2026-10-20 (Log 2033):** no existe escena de menú principal. Las 4 candidatas (`scenes/main_menu.tscn`, `scenes/ui/main_menu.tscn`, `scenes/ui/menu.tscn`, `scenes/menu.tscn`) dan `ResourceLoader.exists()` = false; `main_scene` = `res://scenes/main_island.tscn`. El único `*menu*.tscn` del repo es `scenes/debug/debug_menu.tscn`. El arnés sale EXIT 3 (no medible).** <!-- fuente: 62-Memoria/05-Checklist.md -->
19. - [ ] [62] Baseline spawn de Aurora: objetivo < 1.600 MB [S] — **MEDIDO 2026-10-20 (Log 2033): 174,9 / 175,1 / 174,3 MB x3** con la escena real y el monitor de producción (`M62_ESCENARIO=spawn`, 45 s de asentamiento, 9 muestras, 0 huérfanos, 7 checks / 0 fallos / EXIT 0). Alcance declarado: headless sin renderer → es un PISO de carga, no el baseline de Play Mode (la VRAM no entra en `OS.get_static_memory_usage()`). Flip `[->]` propuesto; NO `[x]`.** <!-- fuente: 62-Memoria/05-Checklist.md -->
20. - [ ] [62] Baseline horizonte terrestre oteado: objetivo < 2.200 MB [S] — **NO MEDIBLE 2026-10-20 (Log 2033):** la cámara de seguimiento no está sobre el Player: Camera3D en (3050.5, 13.2, 3062.5) vs Player en (3860, 8, 3860) = **1136 m**; `_target` sí está seteado y el grupo `player` tiene 1 nodo, pero 12 eventos WHEEL_DOWN por `_unhandled_input` no movieron la cámara. Sin oteo el número sería idéntico al del spawn (falso verde) → EXIT 3.** <!-- fuente: 62-Memoria/05-Checklist.md -->
21. - [ ] [62] Baseline subterráneo del templo (M26): objetivo < 2.000 MB [S] — **NO MEDIBLE 2026-10-20 (Log 2033):** el árbol sí tiene 1 `VoxelTerrain` (contado por clase nativa), pero `get_statistics().updated_blocks = 0`: en headless el terreno no genera bloques (coincide con el Log 2028). Bajar al Player 40 m (Y 8.0 → -32.0) no ejercita el subterráneo → EXIT 3.** <!-- fuente: 62-Memoria/05-Checklist.md -->
22. - [ ] [62] Baseline tormenta máxima (M32) + banco de audio completo: ≤ 2.500 MB (Alta) [S] — **MEDIDO 2026-10-20 (Log 2033), PARCIAL: 173,2 / 173,3 / 173,6 MB x3** con TORMENTA real de M32 (alcanzada en 3 días) y el monitor de producción; 7 buses de audio y 9 reproductores en el árbol. **La mitad de audio NO es medible:** 0 assets de audio en el repo (Log 2028), así que "banco de audio completo" no existe. Piso de carga headless, no baseline de Play Mode. Flip `[->]` propuesto.** <!-- fuente: 62-Memoria/05-Checklist.md -->
23. - [ ] [62] Test Play Mode: drift-check de 30 min sin teleport con drift ≤ 5% [C] — **MEDIDO 2026-10-19 (Log 2025) con el arnés de clima: 30 min 00 s de reloj de pared, 359 muestras, baseline 168.4 MB, drift +0.1% <= 5%, `drift_check()=true`, 0 eventos `travel_started` (servicio presente y instrumentado), 0 huérfanos. Misma salvedad que el ítem 12: 3 SCRIPT ERROR de `pause_layer.gd:147` (regresión `2e9b8f3`) en el boot. Flip pendiente del director.** <!-- fuente: 62-Memoria/05-Checklist.md -->
24. - [ ] [62] Test Play Mode: cambio de bioma de audio sin crecimiento de memoria [M] — **NO MEDIBLE 2026-10-20 (Log 2028):** 0 archivos `.ogg`/`.wav`/`.mp3` en `game/isla-ancestral`; `set_estado_clima()` (M42) 0 llamadores de produccion (los 3 matches son 2 del propio `test_ambient_m42.gd` y 1 comentario de mi arnes); `pedir_banco_audio`/`iniciar_descarga_audio` 0 llamadores fuera de mis suites. Sin streams no hay crecimiento de memoria de audio que medir. Deuda de M41/M42/M44/M91.** <!-- fuente: 62-Memoria/05-Checklist.md -->
25. [x] - [ ] [62] Test Play Mode: excavar y regenerar 500 bloques sin leaks de buffers voxel [C] — **MEDIDO 2026-10-20 (Log 2028) a nivel de BUFFER, con alcance declarado:** arnes `sesion_m62_voxel_500.gd` (escena real + MemoryMonitor de produccion). Buffer real de VoxelTools 16^3 con `BlockType.BEDROCK`: **500/500 excavados** leidos de vuelta como AIR, **500/500 regenerados** con el ID original, **5 buffers temporales creados / 0 vivos** (WeakRef), memoria **135.8 -> 135.8 MB (+0.0%)**, huerfanos 0. **9 checks / 0 fallos / EXIT 0 x3 / SCRIPT ERROR 0.** Sondas EN ROJO: `M62_RETENER_BUFFERS=1` (5 vivos, EXIT 1) y `M62_SIN_REGENERAR=1` (0/500, EXIT 1). **Limite medido:** el VoxelTerrain de la escena real no sirve headless (`updated_blocks=0`, `set_voxel` no persiste) y el generador invocado fuera del motor escribe 0 -> el camino Play Mode exige corrida CON renderer. Flip pendiente del director.** <!-- fuente: 62-Memoria/05-Checklist.md -->
26. [x] - [ ] [62] Test Play Mode: máximo de chunks cargados sin superar el presupuesto voxel [M] — **MEDIDO 2026-10-20 (Log 2028), PARCIAL:** `test_m62_chunks_presupuesto.gd` contra `budgets.json` real (preset media, tope voxel 650 MB) y el LRU real (StreamManager, bloque 16^3 segun `mesh_block_size=16`). Coste por chunk de **DATOS = 8.4 KB** (512 buffers, delta 4306.9 KB). Maximo por presupuesto: baja 60.952 / media 79.238 / alta 97.523 chunks. Tope LRU de produccion 4096 chunks = **34 MB = 5.2% del tope voxel** (19x de margen); el LRU respeta el tope EXACTO (20.100 registrados con tope 20.000 -> activos 20.000) y libera con 0 recursos vivos. **6 checks / 0 fallos / EXIT 0 x3 / SCRIPT ERROR 0**; sonda roja `M62_SIN_TOPE=1` -> EXIT 1. **No medible:** mallas/colliders por chunk (headless sin renderer), que es la parte que puede dominar el presupuesto -> item parcial, NO cerrado.** <!-- fuente: 62-Memoria/05-Checklist.md -->
27. - [ ] [62] Test en preset Baja con 4 GB de RAM: sesión completa sin OOM y jugable [C] — **NO MEDIBLE 2026-10-20 (Log 2028):** no hay forma de imponer un tope de 4 GB al proceso headless, y "sin OOM" no se puede afirmar sin ese tope. Lo medible queda medido: preset **baja = 1500 MB** de topes totales (voxel 500) contra 4096 MB = **36.6%**; memoria de boot real de la escena **135.8 MB**. Requiere una corrida con limite de RAM del SO.** <!-- fuente: 62-Memoria/05-Checklist.md -->
28. - [ ] [160] Objetos con regeneración (regeneracion_seg) y herramienta/tier M158 por objeto (T1..T3 según isla) — medido 2026-10-15 (DeepSeek, Log 1862): regenerac <!-- fuente: 160-Diseno-De-Ubicaciones-Del-Mundo/05-Checklist.md -->
29. - [ ] [160] Integracion runtime de puzzles de ruinas con M25 — M25 cerrado (122/122), integracion pendiente <!-- fuente: 160-Diseno-De-Ubicaciones-Del-Mundo/05-Checklist.md -->


## REPOBLACION V3 (2026-10-19T00:02:03) — items REALES de 05-Checklist (fuente en comentario)
1. - [ ] [68] Puertas/gangways animados en paradas (M48) [M] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
2. - [ ] [68] Bandera del barco con viento (M50) en paradas [S] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
3. - [ ] [68] NPC pasajeros en paradas (M64) [M] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
4. - [ ] [68] NPC abordando el vehículo (M67) [M] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
5. - [ ] [68] Testear animaciones con LOD (M61) [M] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
6. - [ ] [68] HUD del viaje legible con alto contraste [M] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
7. - [ ] [68] Reduce Motion: transiciones cortas sin zoom [M] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
8. - [ ] [68] Subtítulos en mensajes de viaje [S] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
9. - [ ] [68] Panel de transporte accesible con gamepad (M57) [M] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
10. - [ ] [68] Señalización batchable (M46, ≤ 4 carteles por escena) [M] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
11. - [ ] [68] Capa de mapa sin draw calls nuevos [M] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
12. - [ ] [68] Transición reutilizable (SceneTransition M61) [M] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
13. - [ ] [68] Probar con profiler (M116) [C] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
14. - [ ] [68] Documentar el estado condicional de la estación de tren [S] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
15. - [ ] [68] Actualizar DOCUMENTACION/README.md con el módulo 68 [S] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
16. - [ ] [68] Verificar con verificar_checklist.py (sin alertas nuevas) [S] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
17. - [ ] [68] Push del módulo y reporte al usuario [S] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
18. - [ ] [68] Revisar que plan-inicial == plan-actual (SHA-256) [S] <!-- fuente: 68-Transporte-Y-Navegacion/05-Checklist.md -->
19. - [ ] [108] Vincular el problema con la optimización obligatoria del proyecto (AGENTS.md 21.4.8) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
20. - [ ] [108] Definir el alcance: models 3D, texturas, materiales, audio, fuentes, UI y paletas voxel [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
21. - [ ] [108] Excluir del alcance: el terreno voxel generado en runtime por Voxel Tools (M08) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
22. - [ ] [108] Registrar dependencias: M45 (Arte 3D) y M78 (Legal PI), con relaciones a M04, M08, M47, M48, M61, M62, M63, M86, M107, M111, M112, M118 [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
23. - [ ] [108] Establecer que M45 puede estar sin documentar y se referencia por su catálogo de entregables [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
24. - [ ] [108] Fijar los criterios de aceptación del módulo (7 criterios del 01-Requerimientos) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
25. - [ ] [108] RF2: admitir gltf + bin en staging para edición y diffs legibles [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
26. - [ ] [108] RF2: definir PNG como textura lossless con canal alfa [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
27. - [ ] [108] RF2: definir WebP como textura lossy sin alfa dura [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
28. - [ ] [108] RF2: definir OGG Vorbis como audio estándar (música, ambiente, SFX) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
29. - [ ] [108] RF2: admitir WAV solo para loops cortos de UI/feedback ≤ 5 s [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
30. - [ ] [108] RF3: prohibir FBX como entrada directa y documentar la ruta de conversión Blender → glTF [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
31. - [ ] [108] RF3: prohibir TGA, BMP y GIF como texturas de entrada [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
32. - [ ] [108] RF3: prohibir MP3, M4A y MIDI como audio de entrada [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
33. - [ ] [108] Definir TTF/OTF con licencia libre verificada como fuente (M88: Nunito, Fredoka One) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
34. - [ ] [108] Exigir potencias de 2 en texturas para compresión VRAM eficiente [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
35. - [ ] [108] Fijar límites de resolución por tipo: props ≤ 2048², atlas ≤ 4096², iconos ≤ 256² [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
36. - [ ] [108] Definir paletas voxel como PNG atlas con mipmaps off y filtrado off (anti-bleeding M08) [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
37. - [ ] [108] RF4: definir prefijos obligatorios por tipo: mdl_, tex_, mat_, aud_, anim_, fnt_, ui_, vox_ [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
38. - [ ] [108] RF4: usar snake_case en minúsculas sin espacios, tildes, ñ ni caracteres especiales [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
39. - [ ] [108] RF4: definir la secuencia {prefijo}_{entidad}_{variante}_{sufijo} [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
40. - [ ] [108] RF4: numerar variantes en dos dígitos (_01) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
41. - [ ] [108] RF4: usar sufijos de mapa: _albedo, _normal, _roughness, _emission, _height [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
42. - [ ] [108] RF4: garantizar que el id nunca se reutiliza tras un retiro [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
43. - [ ] [108] Definir la convención opcional de respaldo _lod0/_lod1/_lod2 para LODs manuales [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
44. - [ ] [108] RF5: definir preset de textura 3D: mipmaps on, VRAM Compressed, high_quality, filter on, repeat off [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
45. - [ ] [108] RF5: definir preset de textura UI: mipmaps off, VRAM Compressed, filter off según caso [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
46. - [ ] [108] RF5: definir preset de paleta voxel: mipmaps off, filter off, repeat off [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
47. - [ ] [108] RF5: definir preset de audio OGG con calidad por uso (música alta, SFX media) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
48. - [ ] [108] RF5: definir preset de audio WAV loop con normalize, trim y bounds de loop [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
49. - [ ] [108] RF5: definir preset de fuente TTF con MSDF on, antialiasing on y subsetting [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
50. - [ ] [108] RF6: activar mipmaps en todas las texturas de runtime [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
51. - [ ] [108] RF6: usar compresión VRAM BPTC/S3TC en PC vía Godot [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
52. - [ ] [108] RF6: generar shadow mesh en meshes para sombras baratas [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
53. - [ ] [108] RF6: definir presupuesto por tipo: props ≤ 1.5k tris, NPCs ≤ 6k, fauna ≤ 4k, mobiliario ≤ 2.5k [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
54. - [ ] [108] RF6: instanciar props repetidos con MultiMesh o VoxelInstancer (M08) [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
55. - [ ] [108] RF6: usar un solo mesh con N transforms para vegetación y piedras decorativas [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
56. - [ ] [108] Usar atlas ≤ 4096² con margen de 4 px anti-bleeding para props compartidos [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
57. - [ ] [108] Preparar los presets para poder cambiar a ETC2/ASTC si hubiera mobile (M96) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
58. - [ ] [108] Verificar en review ausencia de popping visible en transición de LODs [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
59. - [ ] [108] RF9: revisar escala correcta en grilla de 1 m del mundo (M08) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
60. - [ ] [108] RF9: revisar origen y pivote del modelo en posición correcta [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
61. - [ ] [108] RF9: revisar UVs sin superposición accidental y normal maps consistentes [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
62. - [ ] [108] RF9: revisar alfa sin bordes blancos (fix_alpha_border) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
63. - [ ] [108] RF9: revisar mipmaps y filtrado visualmente sin saltos [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
64. - [ ] [108] RF9: revisar LODs a las distancias de uso y sombras sin artefactos [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
65. - [ ] [108] RF9: revisar look dev cozy coherente con la dirección de arte [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
66. - [ ] [108] RF9: revisar peso estimado en memoria contra la tabla por tipo [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
67. - [ ] [108] RF9: revisar que la ficha esté completa, incluida la licencia (M78) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
68. - [ ] [108] RN: calidad visual cozy sin texturas 4K indiscriminadas; atlas y MultiMesh para draw calls bajos [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
69. - [ ] [108] RN: binarios grandes gestionados con Git LFS (M06/M107) [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
70. - [ ] [108] Justificar WebP sobre JPG: sin artefactos de bloque en arte flat cozy [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
71. - [ ] [108] Justificar PNG sobre TGA: soporte universal y canal alfa [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
72. - [ ] [108] Justificar OGG sobre MP3: sin licencias de códec y streaming nativo [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
73. - [ ] [108] Analizar la compresión por plataforma: BPTC/S3TC PC, ETC2/ASTC futuro mobile [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
74. - [ ] [108] Analizar batching y atlasing por categorías visuales del proyecto [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
75. - [ ] [108] Documentar el riesgo de bleeding de atlas y su mitigación (margen + mipmaps off) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
76. - [ ] [108] Definir que staging/ es la única puerta de entrada (RF1) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
77. - [ ] [108] Definir que archive/ conserva retirados sin cargarse [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
78. - [ ] [108] Definir el flujo de estados: staging → validado → en_review → aprobado → retirado [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
79. - [ ] [108] M45: modelar props y NPCs respetando la metría de 1 m del mundo voxel [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
80. - [ ] [108] M47: respetar los sufijos de mapas (albedo/normal/roughness/emission) definidos en Texturas y Materiales [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
81. - [ ] [108] M48: animaciones embebidas en glb; anim_ solo para clips excepcionales [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
82. - [ ] [108] M63: ids estables = rutas estables para el caché LRU y el streaming de texturas [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
83. - [ ] [108] M08: paletas voxel en voxel_palettes/ con filtrado off y mipmaps off [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
84. - [ ] [108] M08: props del mundo instanciados con VoxelInstancer/MultiMesh compartido [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
85. - [ ] [108] M61: ejecutar los presupuestos finos de Rendimiento cuando estén publicados (en curso) [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
86. - [ ] [108] Atlas que excede 4096²: rechazo con sugerencia de dividir por categorías [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
87. - [ ] [108] Audio WAV de más de 5 s: rechazo con sugerencia de conversión a OGG [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
88. - [ ] [108] Reportes markdown con resumen ejecutivo (aprobados, errores, pendientes) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
89. - [ ] [108] El apilado de atlas se hace una sola vez por categoría y se cache a su resultado [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
90. - [ ] [108] El índice _APROBADAS.md se regenera incrementalmente, no de cero [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
91. - [ ] [108] Probar el edge case de textura sin comprimir y su corrección con presets [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
92. - [ ] [108] Probar la generación de LODs y shadow meshes en un glb de referencia [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
93. - [ ] [108] Probar el promote/retiro dejando el índice _APROBADAS.md correcto [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->

1. - [ ] [35] P2: disenar minerales — tabla de 8+ minerales [S] <!-- fuente: 35-Mineria/05-Checklist.md --> — **MEDIDO Y ENTREGADO 2026-10-20 (Log 2034), diseno completo; implementacion bloqueada por 1 item.** Medido antes de disenar: `data/mining/ores.json` tiene **6** vetas (objetivo 8+), `data/items/` tiene **300** `.tres` de los que solo **7** tienen forma de mineral y **2** (`gemstone`, `copper_ore`) no los usa ninguna veta; **0** items de oro. El JSON SI trae `profundidad_banda` (superficie/subterraneo_medio/profundo/ancestral) y `region` (cantera/cueva/templo) completas -> el hueco es solo el numero. Entregada la seccion `### 2.5 Catalogo de minerales - tabla de diseno (P2)` en `03-Diseno.md` (12.631 -> 16.595 B, LF preservado, sin BOM) con 8 filas: las 6 reales con valores leidos del archivo + `veta_gema` (item `gemstone`, ya existe y esta sin uso) + `veta_oro_puro` (item `gold_ore`, NO existe). Huecos destapados: `veta_oro` y `veta_polvo_estrellas` entregan el MISMO item (`ancient_crystal`) porque no hay item de oro; `copper_ore` duplica a `mineral_cobre`. **No se toco** `ores.json`, `VETAS_M35` ni las aserciones de tamano de los tests: crear la veta sin item real violaria BUG-132. Flip `[->]` propuesto; el `[x]` necesita `gold_ore` por M15/M159.
2. - [ ] [35] P16: disenar rutas — caminos de acceso a las zonas [S] <!-- fuente: 35-Mineria/05-Checklist.md --> — **ENTREGADO 2026-10-20 (Log 2038), diseno completo; implementacion bloqueada por M08.** Seccion nueva `### 2.6 Rutas de acceso a las zonas` en `03-Diseno.md` (16.595 -> 29.859 B, LF preservado, sin BOM, `git diff --numstat` 156/0, 6 tablas y 0 desalineadas): 5 rutas (R1 sendero de cantera sin gate, R2 rampa de descenso, R3 galeria de cueva, R4 sello del templo, R5 acceso ancestral permanente) con ids REALES de piezas (`camino_cesped`, `camino_piedra`, `escalera_recta`, `escalera_doble`, `puente_1`..`puente_4`, `farol_piso`, `antorcha_ancestral`, `cerca_piedra`, `monolito_glifos`, `farol_colgante`) + 4 reglas de ruta + matriz de progresion T1-T4. **Medido antes de disenar:** 6 `zone_id` de gates; **0 llamadores de produccion de `can_access_zone()`**; **0 apariciones** de `gate_muro_piedra`/`gate_sello_ancestral`/`gate_cristal_bloqueado` en `scripts/`; 10 `ubic_*` con **0** para cantera/cueva (hueco ya declarado por M160 en `huecos_de_mapeo`); 46 piezas de construccion; `familia = camino` con **0 efectos de gameplay**. **Hallazgo: ciclo de progresion cerrado** — `gate_muro_piedra` exige T2_HIERRO y el hierro que paga T2 esta dentro de la cantera; `gate_cristal_bloqueado` exige T4_CRISTAL y el cristal que paga T4 esta dentro de la cueva. Hoy latente porque el gate no se consulta en ningun lado. Propuestas P16-D1/D2/D3 entregadas al director; **NO aplicadas** (son datos de M158). Flip `[->]` propuesto.
3. - [ ] [35] P17: disenar estaciones — puestos de descanso y mejoras [S] <!-- fuente: 35-Mineria/05-Checklist.md --> — **ENTREGADO 2026-10-20 (Log 2038), diseno completo sobre piezas y modelos que ya existen.** Seccion nueva `### 2.7 Estaciones: puestos de descanso y mejoras` (mismo archivo, misma escritura): 5 estaciones E0-E4 con ids reales (`cama`, `farol_piso`, `cofre_ancestral`, `mesa`, `antorcha_ancestral`, `lingote_metal`, `farol_colgante`, `monolito_glifos`); 5 reglas de descanso ancladas al modelo real (`PlayerEnergy`: dormir 100% via `recargar_dormir()`, descanso +30% via `recargar_descanso()`, fatiga 30% informativa y no bloqueante); puente `tool_power` 1-3 (contrato §4) <-> tiers de M158 resuelto **derivando `tool_power` del tier** (T1..T3 = 1..3) y usando el `area` de M158 en T4. **Medido:** 4 forjas y 4 cursos; **0 llamadores de produccion de `forjar()`**; **0 apariciones de `tool_power`** (`MiningTool` no implementado); **no existe sistema de descanso del jugador** (los hits de `descanso`/`dormir` son necesidades de NPC M64/M65 y el estado suspendido de `interaction_manager.gd`). **Hallazgo: los materiales de las forjas usan ids inexistentes** — `hierro`/`oro`/`cristal` no existen en los 300 items (los reales son `iron_ore`/`ancient_crystal`/`crystal`; 0 items de oro), el defecto esta duplicado en `data/m158/catalogo_herramientas.json` L160/L169, y `test_tiers.gd` queda **VERDE (0 fallos, EXIT 0 medido)** porque inyecta esos ids falsos en el inventario. Flip `[->]` propuesto.
4. - [ ] [35] Hook de post-generacion de chunk conectado [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
5. - [ ] [35] Escritura de bloques de mineral en el voxel [M] <!-- fuente: 35-Mineria/05-Checklist.md -->
6. - [ ] [35] Remeshing diferido solo del chunk afectado [C] <!-- fuente: 35-Mineria/05-Checklist.md -->
7. - [ ] [35] Colision por bloque de veta unificada con el voxel [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
8. - [ ] [35] Validacion de ocupacion reutilizando API de lectura M08 [M] <!-- fuente: 35-Mineria/05-Checklist.md -->
9. - [ ] [35] Vetas en paredes y techos de cuevas [M] <!-- fuente: 35-Mineria/05-Checklist.md -->
10. - [ ] [35] Iluminacion de brillo en vetas profundas [M] <!-- fuente: 35-Mineria/05-Checklist.md -->
11. - [ ] [35] Compatible con el ahorro de memoria de chunks [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
12. - [ ] [35] Nodos especiales de cristal gigante sembrados por eventos de M26 [M] <!-- fuente: 35-Mineria/05-Checklist.md -->
13. - [ ] [35] Zona ancestral accesible permanentemente tras completar el Templo [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
14. - [ ] [35] Iluminacion del Templo resalta vetas raras [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
15. - [ ] [35] Acceso a cuevas desde el interior del Templo [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
16. - [ ] [35] Evento de derrumbe decorativo en la sala del mineral ancestral [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
17. - [ ] [35] Respawn con zona ocupada: reintento diferido [M] <!-- fuente: 35-Mineria/05-Checklist.md --> — **ENTREGADO 2026-10-20 (Log 2043), codigo + test (no solo diseno).** Guarda de ocupacion INYECTABLE en `barrido_regeneracion(vetas, dia, estacion, ocupado := Callable())`: si el lugar esta ocupado la veta NO respawnea en ese barrido y se reintenta en el siguiente (el barrido de produccion corre en `dia_cambio`, asi que el reintento cae al proximo dia). Se decide ANTES de M15 porque `evaluar_respawn()` MUTA el estado y no consulta ocupacion (medido: 0 apariciones de `ocupad|bloqueado_por|player_encima|jugador_encima` en los 11 `.gd` de `scripts/resources/`). Telemetria acotada (`MAX_DIFERIDOS=64`): `veta_diferida()`, `diferidos()`, `diferidos_por_veta()`, `limpiar_diferidos()`. Suite nueva `test_mineria_respawn_ocupado.gd` **60/0/EXIT 0 x3** (piso 60 medido en verde, 0 SCRIPT ERROR); regresiones `test_mineria` **92/0** y `test_mineria_lote2` **104/0**; sonda de FEATURE en rojo (EXIT 1, 9 fallos en B + 3 en C) y sonda de GUARDIAN en rojo (EXIT 1, nombra los 6 bloques y dispara el piso 16<60). **Caveat medido:** `barrido_regeneracion` tiene **0 llamadores de produccion** (solo tests), asi que la guarda esta disponible pero no cableada. Flip `[->]` propuesto.
18. - [ ] [35] Respawn con jugador dentro: desplazamiento suave [M] <!-- fuente: 35-Mineria/05-Checklist.md -->
19. - [ ] [35] Respawn con construccion M17 encima: espera al proximo dia [M] <!-- fuente: 35-Mineria/05-Checklist.md --> — **MECANISMO ENTREGADO 2026-10-20 (Log 2043) por la misma guarda de J2.** El predicado `ocupado` es generico: una construccion de M17 se pasa como `Callable(Vector3)->bool` y la veta espera al siguiente barrido (= proximo dia en produccion). Probado con el predicado `_ocupado_x_menor_500` en el bloque D: **difiere solo la veta con construccion y respawnea la libre**. Lo que NO se entrega: el cableado real con M17 (M17 no expone hoy una consulta de ocupacion por posicion; se verifico que la guarda funciona con un predicado, no que exista el predicado de produccion). Flip `[->]` propuesto.
20. - [ ] [35] Veta en borde de chunk: sin duplicacion ni perdida [M] <!-- fuente: 35-Mineria/05-Checklist.md -->
21. - [ ] [35] Remeshing localizado y diferido por chunk [C] <!-- fuente: 35-Mineria/05-Checklist.md -->
22. - [ ] [35] Pool de particulas de mineria [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
23. - [ ] [35] Raycast con mascara de colision exclusiva [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
24. - [ ] [35] Frame budget global respetado en remeshing masivo [C] <!-- fuente: 35-Mineria/05-Checklist.md -->
25. - [ ] [35] Particulas de chispas al golpear [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
26. - [ ] [35] Particulas de satisfaccion al extraer [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
27. - [ ] [35] Sonido de golpe distinto por material [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
28. - [ ] [35] Sonido de extraccion gratificante [S] <!-- fuente: 35-Mineria/05-Checklist.md -->
29. - [ ] [60] M08: el resto del mundo se regenera con la semilla (procedural) [C] -- iter. 4: es trabajo de M08 (Voxel Tools). M60 guarda y devuelve la semilla (ver <!-- fuente: 60-Datos-Y-Serializacion/05-Checklist.md -->
30. - [ ] [60] M08: contrato de "edits" ajustado al formato real de Voxel Tools [M] -- agnes-2.5-flash 2026-09-12: formato contractual (coord int32x3, type uint8) do <!-- fuente: 60-Datos-Y-Serializacion/05-Checklist.md -->
31. - [ ] [60] M08: log con cantidad de chunks editados cargados [S] -- iter. 4: no existe (sólo hay `print` al GUARDAR). Se deja abierto. <!-- fuente: 60-Datos-Y-Serializacion/05-Checklist.md -->

## 2026-10-19 02:14 (GMT-3) - RAMA 1 / msg 317: homogeneizacion de los 2 gates + item 1 de la COLA V3 (Log 2016, canal 318)

- **Tracker 316 -> 317.** Entrante nuevo del director = 317 (autoriza por escrito
  homogeneizar los 2 `|| FAIL=1` restantes de `quality.yml` con
  `::error::FALLO <step>` y commitear; repone la COLA V3 y pide seguirla en orden).
- **Homogeneizacion HECHA:** L719 (`legal-tools`, USCO) y L931 (`architecture-guard`,
  M62) con `|| { FAIL=1; echo "::error::FALLO <script>"; }`. Ocurrencias de CODIGO
  de `|| FAIL=1` restantes: **0** (las 3 lineas que quedan son comentarios).
- **Prueba en verde y en rojo, medida:** harness que extrae el bloque `run:` REAL
  del YAML y lo corre con `bash -e` + stub de `python3`/`python` en el PATH.
  HEAD pre-fix: rojo con **0 anotaciones** (ciego) en ambos steps. Con el fix:
  verde exit 0 / 0 anotaciones; rojo exit 1 / 1 anotacion con el nombre exacto.
  El grupo `{ ...; }` no se come el exit code. Gates: `validar_workflows.py` EXIT 0
  (6 workflows) + selftest 6/6; `test_scripts.py` **19 PASS / 0 FAIL**;
  bytes 64.112, BOM no, CRLF 0, LF 1108, tabs 0.
- **Commit `4f0d461`** (1 archivo, 2+/2-, pathspec selectivo, sin `-A`, sin
  `--amend`, **sin push**).
- **Item 1 de la COLA V3 (M62 L104, ciclos):** auditor **0 SCC / 237 aristas /
  0 hallazgos nuevos**, selftest 0 fallos con los 5 casos de ceguera. Verificacion
  INDEPENDIENTE (parser propio, criterio mas permisivo): 759 apariciones ->
  301 comentario / 458 cadena / 28 "codigo", y esas 28 son variables locales
  (`eventos`, `hotbar`), 1 docstring y 1 comentario inline -> **0 referencias duras,
  0 preload/load de otro autoload**. Las 2 SCC del Log 1112 rotas con linea:
  `save_manager.gd` sin aristas a Inventario/Fishing en codigo; `theme_service.gd`
  sin arista a UIManager en codigo (L64/L66 comentarios). **Flip de L104 propuesto,
  NO aplicado** (los flips los aplica el director). El auditor avisa que
  `A1|ThemeService,UIManager` de `PERMITIDOS` ya no se observa: limpieza sugerida,
  **NO ejecutada** (gate aceptado, sin orden escrita).
- **Lectura honesta:** contando las busquedas por ruta como aristas, el grafo de
  DEPENDENCIAS sigue con 1 SCC de 38 nodos (criterio permisivo). Es deuda de
  DISENO, no ciclo de referencias: ningun servicio retiene al otro.
- **Numeracion:** Log **2016** (cabeza medida antes = 2016; `--estado` = 985 libres,
  11 colisiones AJENAS). Canal: ultimo mensaje real **317**, pool **STALE** (cabeza
  316) -> se uso **318 = ultimo+1** y se dejo el pool en **319..418**
  (`verificar_pool_numeros.py` OK, todos los pools sanos).
- **Artefactos:** Log 2016 (ASCII puro por bytes, 180 CRLF, sin BOM, 8.569 B) +
  msg 318 (UTF-8 sin BOM, LF, 5.419 B); este registro; log diario; tracker 317.
- **0 push / 0 flips / 0 auto-sellos 21.8**; `CHECKLIST-GLOBAL.md`, `AGENTS.md`,
  `project.godot`, `05-Checklist` de modulos y backlogs ajenos intactos; el auditor
  **no** se modifico (solo se midio).
- **Proxima:** NN entrantes > 317. Item 2 de la COLA V3 es runtime/Play Mode
  (30 min sin drift): pedido criterio de aceptacion al director; los items 4-16
  son verificables estaticamente.

## 2026-10-19 03:44 (GMT-3) - RAMA 1 / msg 319: COLA V3 items 4-16 auditados (Log 2019, canal 320)

- **Tracker 318 -> 319.** Entrante nuevo = 319: acepta el homogeneizado, ordena
  SALTEAR el item 2 (runtime 30 min) y seguir con los items 4-16 estaticos.
- **Metodo:** los 13 items se midieron con tres fuentes: suites headless reales
  (Godot 4.7.2, 3 corridas cada una), codigo de produccion de los modulos duenos
  y los artefactos que cada item necesita para ser cierto (assets, callers).
- **Items 4, 5, 6, 7 y 14 CONFIRMADOS** (`[x]` del 05 sostenido, con evidencia
  nueva): hilos 33 checks, diffs 24, anillo 24, audio_bioma 45, sin_duplicacion
  33; todos 3/3 identicas, EXIT 0, 0 SCRIPT ERROR, `CHECKS_MINIMOS` igual al
  conteo medido, cero `_check(true`. Las cinco usan la cola REAL de M63.
- **Guardian EN ROJO (no heredado):** inyeccion de runtime al inicio del bloque B
  de `test_m62_diffs_ediciones.gd` sobre una COPIA temporal -> `SCRIPT ERROR`,
  `[FALL] el bloque B NO se ejecuto`, `[FALL] solo 20 checks (minimo 24)`, EXIT 1.
  El original conserva sha256 `0689b07d...e24e3`; la copia se borro.
- **Hallazgo A:** 17 suites en `scripts/rendimiento/memoria/`, solo 7 en
  `quality.yml`. **10 fuera de CI**, entre ellas las 5 que sostienen esta tanda.
  Propuesta de cableado al director (el workflow es NO-TOCAR para mi).
- **Hallazgo B (L149):** `pedir_banco_audio()` / `iniciar_descarga_audio()` tienen
  **0 llamadores de produccion**; M42 (`ambient_director.gd`) nunca llama a la
  API del 62. El `[x]` es de MECANISMO, no de punta a punta: decision pedida.
- **Items 8, 9, 10 y 11 BLOQUEADOS POR ASSETS:** 0 `.ogg`/`.wav`/`.mp3` en todo
  `game/isla-ancestral` y 0 apariciones de `AudioStreamOggVorbis`/`load_from_file`.
  El presupuesto de audio de los presets (150/200/250 MB) no tiene contraparte en
  disco. La deuda es de M41/M42/M44/M91, no del 62.
- **Item 13:** M61 SI tiene presupuestos definitivos (v2: 16.7 ms, remesh 2.0 ms,
  carga fria 30 s) y M62 fija 1500/2000/2500 MB. Unidades distintas -> sin
  conflicto. `remesh_bloque_ms_max` no lo consume ningun script del 62 y no hay
  artefacto que enlace ambos archivos: flip pedido con la tabla de correspondencia.
- **Item 15:** `drift_check()` existe y esta probado, pero **0 llamadores de
  produccion**; `island_travel_guard.gd` tiene 0 apariciones de `drift`. Falta 1
  punto de llamada post-viaje.
- **Item 16:** 2 de 3 sub-partes ya existen (`island_ops.gd` prioridad +
  `debe_precargar(..., presupuesto)`); **0** apariciones de `preset` en
  `scripts/islas/*.gd`.
- **Item 12 SALTEADO** por la misma razon que el 2 (orden escrita del director).
- **Numeracion:** Log **2019** (cabeza medida justo antes = 2019; pool en 2020).
  Canal: ultimo real **319**, pool con cabeza **320** = ultimo+1 -> se uso **320**
  y el pool quedo en **321..420**. `verificar_pool_numeros.py`: EXIT 0, todos los
  pools sanos.
- **0 commits / 0 push / 0 flips / 0 auto-sellos 21.8.** Sin tocar
  `CHECKLIST-GLOBAL.md`, `AGENTS.md`, `project.godot`, `quality.yml` ni ningun
  `05-Checklist`.
- **Proxima:** NN entrantes > 319. La cola de M62 queda sin items ejecutables
  estaticamente: 8-11 esperan assets de audio, 2 y 12 esperan runs del fundador.
  **Reposicion de cola pedida al director.**

## 2026-10-19 21:20 (GMT-3) - RAMA 1 / msgs 321-322: item 2/12 con run real + gaps 13/15/16 cerrados (Log 2021, canal 323)

- **Tracker 320 -> 322.** Entrantes: **321** (acuse de la auditoria 320: 5 items
  confirmados y flipeados por el director; seguir la cola y detallar el gap de los
  3 "hueco preciso") y **322** (CORRECCION del fundador: los runs de Godot NUNCA
  estuvieron cerrados; el item 2/12 se puede encarar con run real).
- **Item 2 (y RN3 del item 3) MEDIDO EN VERDE:** arnes nuevo
  `sesion_m62_30min.gd` que corre la escena REAL del juego 30 min de reloj de
  pared con el MemoryMonitor de produccion. 359 muestras, baseline 174.8 MB a
  los 300 s, **drift final +0.1%** (max 0.1% @470 s), objetos 7880 -> 7899,
  0 huerfanos en las 359 muestras, 0 SCRIPT ERROR, EXIT 0, `drift_check()=true`.
  Guardian probado EN ROJO: baseline forzada durante el arranque -> +26.7%,
  EXIT 1. Alcance declarado: headless (sin VRAM) y sin input de jugador.
- **Item 15 CERRADO:** el ejecutor real de viajes es `travel_service.gd` (M28):
  `_verificar_drift_post_viaje()` dentro de `_atracar()`, resuelve el monitor por
  duck-typing en `ServiceRegistry`, **fail-closed** sin monitor, umbral
  provisional 45 s derivado de `rutas.json` (20/30/45/60 s). Gate
  `test_m62_drift_post_viaje.gd`: 12 checks, 3/3, EXIT 0, piso 12 medido.
  Matiz nuevo: `FastTravelService.viaje_solicitado` (M69) tampoco tiene
  consumidor de produccion, pero el flujo de M28 si.
- **Item 16 CERRADO:** `TOPE_ISLAS_POR_PRESET` (baja=1/media=2/alta=2) inyectado
  por `configurar()` (M27 no lee M90 ni M62), `descarga_agresiva_viajeros()` y
  tope por preset en `debe_precargar()`. Gate `test_m62_preset_baja_m27.gd`:
  13 checks, 3/3, EXIT 0.
- **Item 13 CERRADO como artefacto:** gate `test_m62_correspondencia_m61.gd`
  enlaza `data/performance/budgets.json` (M61) con `data/rendimiento/budgets.json`
  (M62): 12 checks, 3/3, EXIT 0; rojo probado con copia temporal (baja=1501).
- **Hallazgo lateral (M28):** `test_viajes.gd:149` tenia un `%` sin escapar que
  abortaba una funcion de test con **EXIT 0** (falso verde). Corregido a `%%`:
  0 SCRIPT ERROR, 0 `FALLO:`. Pendiente: esa suite no imprime resumen ni conteo.
- **Regresion:** M27 iter2 238/0, M27 171/0, M27 headless 5/0, test_viajes
  post-fix 0 SCRIPT ERROR, test_harbor_viajes EXIT 0.
- **Numeracion:** Log **2021** (cabeza medida justo antes = 2021). Canal: ultimo
  real **322**, pool con cabeza **323** = ultimo+1 -> se uso **323**; pool en
  **324..423**.
- **0 commits / 0 push / 0 flips / 0 auto-sellos 21.8.** `CHECKLIST-GLOBAL.md`,
  `AGENTS.md`, `project.godot`, `quality.yml` y los `05-Checklist` intactos.
- **Proxima:** NN entrantes > 322. Los ejecutables estaticos de la COLA V3 se
  agotaron: quedan 8-11 (sin assets de audio) y 17-27 (baselines / Play Mode).
  Reposicion pedida en el msg 323.

## 2026-10-19 23:16 (GMT-3) — RAMA 1 / msg 324: ítem 12 (clima 30 min) medido, audio no medible, HEAD roto (Log 2025, canal 325)

- **Tracker 323 -> 324.** Entrante único = **324** (acuse del director: ítem 2/12
  aceptado con el run real, gaps 13/15/16 cerrados, orden de seguir la COLA V3 con el
  estándar "medido con arnés de producción").
- **Arnés nuevo** `scripts/rendimiento/memoria/sesion_m62_clima_30min.gd` (13.836 B, LF,
  sin BOM): escena real + MemoryMonitor de producción; cada 180 s avanza **un día** por la
  API de producción (`GameTime.avanzar_hasta`, la de "dormir en cama") → `dia_cambio` →
  `Weather._recalcular_dia_actual()` → `EventBus.weather.clima_cambio`. Sin climas inventados.
- **Ítem 12, mitad de CLIMA: VERDE.** 30 min 00 s de reloj de pared (22:42:42→23:12:42),
  **359 muestras**, baseline 168.4 MB a los 300 s, **drift +0.1%** (memoria 168.4→168.5 MB,
  delta 0.1 MB en 1491 s), `drift_check()=true`, **10/10 cambios de clima efectivos**,
  **4 climas distintos** (SOLEADO/NUBLADO/LLUVIA/TORMENTA), 0 huérfanos, 0 viajes.
- **Ítem 12, mitad de AUDIO: NO MEDIBLE (3 bloqueos medidos).** (1) 0 `.ogg`/`.wav`/`.mp3`
  en el proyecto; (2) `AmbientDirector.set_estado_clima()` (M42) con **0 llamadores de
  producción**; (3) `clima_cambio` con 2 consumidores (`event_manager.gd:107`,
  `farm_service.gd:55`) y **ninguno es audio**. Lo observable sí se midió: buses 7→7 y
  reproductores 9→9 constantes en las 359 muestras.
- **Ítem 23 (condición "sin teleport"): MEDIDO** con el mismo run: drift +0.1% ≤ 5%,
  `drift_check()=true`, **0 eventos `travel_started`** (servicio presente e instrumentado).
- **Arnés probado EN ROJO:** sonda A (fuga inyectada +4 MB/muestra) → +216.7%, EXIT 1 y
  **único fallo el de drift**; sonda B (`M62_SIN_CAMBIOS=1`, 420 s, baseline de producción)
  → drift +0.0%, `drift_check()=true` y fallan **solo** los 2 checks de escenario (0 cambios,
  0 climas). Sonda B es además el control verde del camino de drift.
- **HALLAZGO GRAVE (no buscado): HEAD ROTO en `pause_layer.gd:147`.** `_buscar_confirm_popup`
  aparece **solo como llamada** (la función no existe en el repo). Worktree == HEAD (sha256
  `426c7d58…`, `git status` vacío) → está commiteado. `--check-only` → **EXIT 1**.
  Commit que lo introdujo: **`2e9b8f3`** (tanda M59 de G-5.3-Flash-Agente, 22:25:35), +24
  líneas con la llamada y sin el helper. Conteo def/llamada: `0b8fa70` 1/2, `b311264` 0/0,
  `335c1b7` 0/0, `2e9b8f3` **0/1**, `c3c95be` 0/1. Efecto: `UIRoot._build_layers()` aborta
  → la escena real arranca **sin la capa de pausa** y con **3 SCRIPT ERROR** en el boot.
  No se tocó (módulo ajeno); reportado en el msg 325 con el texto de BUG listo.
- **Por eso NO se cierran 12 ni 23:** el drift no depende de una capa de UI ausente, pero en
  este proyecto "verde sin `SCRIPT ERROR: 0` no es verde". Decisión del director: aceptar con
  la salvedad declarada o re-run de 30 min tras el fix.
- **Numeración:** Log **2025** (cabeza medida justo antes = 2025; queda en 2026). Canal:
  último real **324**, cabeza del pool **325** = último+1 → se usó **325**; pool en **326**.
- **0 commits / 0 push / 0 flips / 0 auto-sellos 21.8.** `CHECKLIST-GLOBAL.md`, `AGENTS.md`,
  `project.godot`, `quality.yml` y los `05-Checklist` intactos.
- **Próxima:** NN entrantes > 324. Pendiente del director: commit del arnés nuevo, decisión
  sobre el re-run del ítem 12 y dueño de la regresión `2e9b8f3`. Ítems 18-22 sin sustrato
  headless (topes con GPU); 24-27 son Play Mode y se pueden armar con el mismo patrón.



## 2026-10-20 00:41 (GMT-3) — RAMA 1 / msg 326: ítems 25 y 26 medidos, 24/27 no medibles, tracker 800 corregido (Log 2028, canal 327)

- **Tracker:** estaba en **800** (commit `1ecc611` lo pasó de 323 a 800) mientras el último NN
  real del canal era **326** → el canal quedaba ciego a todo mensaje futuro. **Corregido a 326.**
- **Entrante único = 326** (acuse del 325: ítem 12 aceptado con salvedad, commit del arnés de
  clima hecho, BUG autorizado, GO a ítems 24-27, regla de flota "reportar SCRIPT ERROR").
- **Punto 3 cumplido sin duplicar:** el BUG de `2e9b8f3` **ya estaba** registrado como
  **BUG-137** (`DOCUMENTACION/11-BUGS.md:157`, resuelto 2026-10-19 23:25 por G-5.3-Flash-Agente,
  con mi hallazgo atribuido). Verificado el fix en disco (`_buscar_confirm_popup()` en
  `pause_layer.gd:158`, secuencia `2e9b8f3` → `0ecdad5`) y **medido**: boot de la escena real
  headless con **SCRIPT ERROR = 0** en 6 corridas.
- **Ítem 25 (500 bloques) MEDIDO a nivel de BUFFER** con arnés nuevo `sesion_m62_voxel_500.gd`:
  500/500 excavados leídos como AIR, 500/500 regenerados, 5 buffers temporales / 0 vivos,
  memoria 135.8 → 135.8 MB, huérfanos 0, **9 checks / 0 fallos / EXIT 0 ×3 / SCRIPT ERROR 0**.
  Sondas EN ROJO: retención (5 vivos) y sin regenerar (0/500), ambas EXIT 1 y nombrando el check.
  **Hallazgo del método:** con la fuga inyectada el delta de memoria es +0.0% → el check de
  memoria NO caza fugas de 80 KB; la guarda real es el WeakRef.
  **Límites medidos:** VoxelTerrain headless `updated_blocks=0` y `set_voxel` no persiste;
  `_generate_block()` fuera del motor escribe 0 aunque `get_block_at()` devuelva 4.
- **Ítem 26 PARCIAL** con arnés nuevo `test_m62_chunks_presupuesto.gd`: coste por chunk de
  DATOS **8.4 KB** (bloque 16³, `mesh_block_size=16`); máximo por presupuesto baja 60.952 /
  media 79.238 / alta 97.523; tope LRU de producción **4096 = 34 MB = 5.2% del tope voxel**;
  LRU respeta el tope exacto (20.100 → 20.000) y libera con 0 recursos vivos;
  **6 checks / 0 fallos / EXIT 0 ×3**; sonda roja `M62_SIN_TOPE=1` EXIT 1. **Mallas/colliders no
  medibles headless** → no se cierra.
- **Trampa nueva:** `VoxelBuffer` lleno con `fill()` de un solo valor se guarda **comprimido**
  (0.4 KB/chunk, 20× optimista). Hay que materializar con un segundo valor distinto.
  Otras: sonda sin watchdog se cuelga si un SCRIPT ERROR aborta `_initialize()`;
  `StreamManager.registrar_chunk()` exige `Resource` (un `VoxelBuffer` aborta con TypeError).
- **Ítems 24 y 27 NO MEDIBLES** con evidencia re-medida: 24 → 0 assets de audio y 0 llamadores
  de producción de `set_estado_clima`; 27 → no se puede imponer tope de 4 GB (solo lo medible:
  preset baja 1500 MB de topes = 36.6% de 4096 MB, boot real 135.8 MB).
- **Numeración:** Log **2028** (cabeza medida justo antes = 2028). Canal: último real **326**,
  pool con cabeza **327** = último+1 → se usó **327**.
- **0 commits / 0 push / 0 flips / 0 auto-sellos 21.8.** `CHECKLIST-GLOBAL.md`, `quality.yml`,
  `AGENTS.md`, `project.godot`, `11-BUGS.md` y los `05-Checklist` intactos.
- **Próxima:** NN entrantes > 326. Pendiente del director: flips de 25 (o criterio con renderer)
  y 26 (parcial), cableado de las 2 suites a `quality.yml`, decisión sobre 24/27.


## 2026-10-20 01:48 (GMT-3) - RAMA 1 / msg 328 + COLA V3 items 17-22 (Log 2033, canal 329)

- **Tracker 327 -> 328.** Entrante unico = 328 (acuse: 25 aceptado, 26 parcial conforme, 24/27
  bloqueo de assets, flips 25/26 ya aplicados por el director). Verificado en disco: L1977/L1978
  empiezan con `25. [x]` / `26. [x]`. 0 flips de mi parte.
- **Dos arneses nuevos** en `scripts/rendimiento/memoria/`: `sesion_m62_baselines.gd` (18-22, un
  escenario por proceso) y `sesion_m62_limite.gd` (17, fuerza el denominador del semaforo).
- **Item 17 PARCIAL con mecanismo VERDE**: 14 checks / 0 fallos / EXIT 0 x3 / SCRIPT ERROR 0.
  Niveles 1-2-3 forzados (145/134/127 MB), `semaforo_cambiado` [1,2,3], enforcement SUAVE (INFO) y
  DURO (WARNING), monitor vivo, Player movible, restauracion exacta a 2032 MB y nivel 0.
- **Baselines**: spawn **174,3-175,1 MB** (x3, EXIT 0) y tormenta **173,2-173,6 MB** (x3, EXIT 0)
  como PISO de carga headless. Menu/horizonte/subterraneo **NO MEDIBLES (EXIT 3)** con causa
  medida: no hay escena de menu; camara a 1136 m del Player; VoxelTerrain con 0 bloques generados.
- **Hallazgo**: el preset `media` suma **2032 MB en runtime vs 2000 MB del dataset** (+32 MB);
  `cargar()`/`set_preset()` no restauran el estado vivo -> el arnes usa snapshot exacto por
  `tope_de()` + `registrar_sistema()`. No se toco `budgets.json`.
- **Defectos propios cazados por las guardas**: `call("semaforo")` sobre una propiedad (SCRIPT ERROR
  que aborto `_ejecutar`; lo delato el piso 4<12), fraccion pasada como MB, VoxelTerrain contado por
  ruta de script (detector ciego) y la camara equivocada (`camera_rig` vs `follow_camera`).
- Artefactos: Log **2033** (ASCII puro/CRLF/sin BOM, 8.686 B), msg **329** (UTF-8 sin BOM/LF,
  5.782 B), tracker 328, pool de canal 330, pool de logs 2034.
- **0 commits / 0 push / 0 flips / 0 auto-sellos.** La COLA V3 queda sin items ejecutables headless:
  3 (duplicado del 2), 8-12 (audio), 18/20/21/23/24/27 (Play Mode / assets / tope de RAM del SO).
  Reposicion pedida en el canal.


## 2026-10-20 01:55 (GMT-3) - RAMA 1 / msg 330: correccion del 329 + COLA V3 bloque 2 + item P2 (Log 2034, canal 331)

- **Correccion propia:** el 329 pidio reposicion de cola porque "la COLA V3 no tiene items
  ejecutables". **Falso.** El backlog tiene DOS bloques `## REPOBLACION V3` (L1951 y L1984, creados
  con 11 s de diferencia); al recorrer la seccion corte en el siguiente `## ` y solo vi el bloque 1
  (M62, 29 items, trabajado en los ciclos 2016-2033). El bloque 2 **nunca se toco**.
- **El bloque 2 es mio y sus 31 items son reales:** M35 tiene 28 `[ ]` y M60 tiene 3 `[ ]` = 31
  exacto (conteo por prefijo de linea sobre las checklists de origen). M35 asignado a
  DeepSeek-V4.1-Flash (`ESTADO-PARALELO.md` L194) y fuera de la lista NO TOCAR.
- **Item 1 (P2) medido y entregado:** `ores.json` = 6 vetas vs objetivo 8+; 300 `.tres` con 7
  minerales y 2 sin uso (`gemstone`, `copper_ore`); 0 items de oro. Seccion `### 2.5` nueva en
  `35-Mineria/plan-actual/03-Diseno.md` (12.631 -> 16.595 B, LF, sin BOM, 0 renumeraciones) con la
  tabla de 8: las 6 reales + `veta_gema` (usa `gemstone`, que ya existe) + `veta_oro_puro` (necesita
  `gold_ore`, que no existe).
- **Huecos medidos, ninguno tocado:** `veta_oro` y `veta_polvo_estrellas` apuntan al mismo item
  (`ancient_crystal`) porque no hay item de oro; `copper_ore` duplica a `mineral_cobre`. Crear la
  veta 8 sin item real violaria BUG-132 -> pedido a M15/M159.
- **Bloqueante medido para 8 de los 28 items de M35:** `grep -rln "set_block" scripts/` = **0**;
  la API de edicion de M08 que el propio `03-Diseno.md` L226 declara **no existe en el repo**. Sondas
  de falso negativo sobre `mining_manager.gd`: `set_voxel`/`VoxelTerrain`/`voxel_tool` 0, `remesh` 0,
  `collision_mask`/`raycast` 0, `borde`/`chunk_size` 0 (lo unico implementado es `zone_quota`, 22
  menciones).
- Artefactos: Log **2034** (ASCII puro / CRLF / sin BOM, 9.419 B), msg **331** (UTF-8 sin BOM / LF,
  5.694 B), `03-Diseno.md` de M35, tracker 328 -> **330**, pool de canal 331 consumido -> cabeza 332.
- **0 commits / 0 push / 0 flips / 0 auto-sellos.** Proxima: bloque 2 items 2 y 3 (P16 rutas, P17
  estaciones), diseno puro sin dependencia de M08.

## 2026-10-20 03:02 (GMT-3) - RAMA 1 / msg 333: COLA V3 bloque 2 items 2-3 (P16 rutas + P17 estaciones), Log 2038 -> canal 334

- **Tracker 332 -> 333.** Unico entrante = **333** (acuse del director: bloque 2 + P2 tomados con
  flips aplicados por el; M14 verificado sin items de localizacion; instruccion "segui COLA V3,
  siguiente bloque"). **0 flips mios.**
- **Items 2 (P16) y 3 (P17) ENTREGADOS** como diseno puro en `03-Diseno.md`: secciones nuevas
  `### 2.6` y `### 2.7`. Archivo 16.595 -> **29.859 B**, `git diff --numstat` **156/0** (no se toco
  ninguna linea previa, incluida la §2.5 del ciclo anterior), LF puro, sin BOM, 0 U+FFFD,
  **6 tablas y 0 desalineadas**.
- **P16 (5 rutas)**: R1 sendero de cantera (sin gate), R2 rampa de descenso (`gate_muro_piedra`),
  R3 galeria de cueva, R4 sello del templo (`gate_sello_ancestral`, `blocks_story`), R5 acceso
  ancestral permanente. Todas con **ids reales** de `data/construccion/piezas/`. 4 reglas: ninguna
  ruta es obligatoria para volver; el camino no da ventaja mecanica (medido: 0 efectos); el gate vive
  en el tramo y no en la zona (un solo sitio que cablear); se respeta la cuota de 12/dia.
- **P17 (5 estaciones)**: E0 cama, E1 puesto de avanzada, E2 forja de campo (repara, no sube tier),
  E3 forja de isla (la `forjas` de M158), E4 mirador/atajo. Reglas ancladas a `PlayerEnergy`
  (dormir 100%, descanso +30%, fatiga 30% informativa). Puente `tool_power` <-> tiers resuelto
  derivando `tool_power` del tier.
- **HALLAZGO 1 (medido, no corregido):** `forjas` pide `hierro`/`oro`/`cristal` x10/x20/x5 y **esos
  ids no existen** en los 300 items (`iron_ore`/`ancient_crystal`/`crystal`; 0 items de oro).
  `forjar()` devuelve "faltan materiales" **siempre**. Prueba de que `hierro` es etiqueta:
  `build_hud.gd:33` traduce `"iron_ore": "hierro"`. Defecto **duplicado** en
  `data/m158/catalogo_herramientas.json` L160/L169.
- **HALLAZGO 2:** `test_tiers.gd` queda **VERDE (EXIT 0, 0 fallos, 0 SCRIPT ERROR, corrida real)**
  porque inyecta `{"hierro": 10}` y `{"oro": 20}` en el inventario. El test consagra el defecto.
- **HALLAZGO 3 (latente):** ciclo de progresion cerrado: `gate_muro_piedra` exige T2 y el hierro de
  T2 esta dentro de la cantera; `gate_cristal_bloqueado` exige T4 y el cristal de T4 esta dentro de
  la cueva. Hoy no duele: `can_access_zone()` tiene **0 llamadores de produccion** y los 3 gate_id
  aparecen **0 veces** en `scripts/`.
- Artefactos: Log **2038** (ASCII puro / CRLF / sin BOM, 12.257 B, 241 lineas), msg **334**
  (UTF-8 sin BOM / LF, 5.780 B), backlog anotado (2 notas + esta seccion, LF preservado), tracker
  **333**, pool de canal 334 consumido -> cabeza 335, pool de logs 2038 consumido -> cabeza 2039.
- **0 commits / 0 push / 0 flips / 0 auto-sellos.** El bloque 2 queda **sin items de diseno
  ejecutables**: 4-27 dependen de la API de M08 (`set_block` = 0) y 28-31 son de M08. Pedido al
  director: decision sobre P16-D1/D2/D3 o reposicion de cola sin M08.
- **Trampas nuevas:** (1) `estacion` en este repo es casi siempre "estacion del ano" (136 archivos,
  homonimo): desambiguar antes de contar; (2) `ores.json` es un ARRAY, no un dict con clave `vetas`
  (volcar `type()` antes de indexar); (3) un `git diff --numstat` 156/0 es la prueba barata de que no
  se piso trabajo previo en un archivo que otro agente ya edito; (4) un test de recetas puede estar
  verde validando ids que no existen, porque el inventario acepta cualquier String.

## 2026-10-20 05:40 (GMT-3) - RAMA 1 / msg 335: COLA V3 bloque 2, items J2 + J4 (respawn con ocupacion), Log 2043 -> canal 336

- **Tracker 334 -> 335.** Entrante unico = **335** (acuse del director: P16/P17 entregados, bloque
  ejecutable cerrado; orden: "segui con P18+ si hay disponible headless o el siguiente bloque de la
  COLA V3"). **P18-P24 ya estan `[x]`** (diseno verificado 2026-10-13) y los items 4-28 del bloque 2
  siguen bloqueados por la API de M08 (`set_block` = 0): **no habia "P18+"**. Se tomo el primer par
  de items del bloque 2 que NO depende de M08: **J2** y **J4**.
- **ENTREGADO (codigo + test, no solo diseno):** guarda de ocupacion inyectable en
  `barrido_regeneracion()`. `mining_manager.gd` 30.850 -> 33.876 B (`git diff --numstat` **71/4**),
  `test_mineria_respawn_ocupado.gd` nuevo (12.364 B).
- **Medido antes de implementar:** (a) `evaluar_respawn()` de M15 MUTA estado y **no** consulta
  ocupacion (**0** apariciones de `ocupad|bloqueado_por|player_encima|jugador_encima` en los 11 `.gd`
  de `scripts/resources/`); (b) `barrido_regeneracion` tenia **0 llamadores de produccion** (solo
  tests); (c) `intentar_extraccion` SI es produccion (`tool_controller.gd:347`).
- **Evidencia:** suite nueva **60 checks / 0 fallos / EXIT 0 x3**, `CHECKS_MINIMOS = 60` medido en
  verde, **0 SCRIPT ERROR**. Regresiones `test_mineria` **92/0** y `test_mineria_lote2` **104/0**.
  Sonda de FEATURE en rojo: neutralizar el `if ocupado` -> **EXIT 1** con 9 fallos (B) + 3 (C).
  Sonda de GUARDIAN en rojo: aborto de RUNTIME en `_run()` -> **EXIT 1**, nombra los 6 bloques
  faltantes y dispara el piso (`solo 16 checks ejecutados (minimo 60)`).
- **HALLAZGO 1 (M15):** el item D9 del checklist de M35 ("Validacion de ocupacion antes de
  reaparecer", hoy `[x]`, delegado a M15) es **FALSO**: M15 no tiene esa validacion (0 apariciones).
  Es justo la base de J2/J3/J4, por eso la guarda se implemento del lado de M35. Flip a `[ ]`/`[?]`
  propuesto; **no aplicado**.
- **HALLAZGO 2 (M52, bloquea K/L):** `VfxDirector` y `VfxTrigger` tienen **0 instanciaciones de
  produccion** (0 referencias fuera de `scripts/particles/`, ningun autoload VFX en `project.godot`).
  El catalogo espera `bloque_roto` en el bus `world.block_removed`, pero **M35 no lo emite** y el
  renderer no existe en produccion: cablear M35 al VFX seria cablear a un subsistema muerto (la
  trampa del guard que nunca pasa). K ("pool de particulas"), L1 ("chispas al golpear": bus vacio,
  dueno M13) y L2 ("satisfaccion al extraer") quedan **NO entregables** hasta que el director
  decida dueno del runtime VFX.
- **0 commits / 0 push / 0 flips / 0 auto-sellos 21.8.**
- Artefactos: Log **2043** (ASCII puro / CRLF / sin BOM), msg **336** (UTF-8 sin BOM / LF), este
  backlog (LF preservado), `04-Codigo.md` de M35 (30.094 -> 33.724 B, LF, sin BOM, 0 U+FFFD), log
  diario. Pools: logs 2044 (otro agente consumio el 2044), canal 336 consumido -> head 337 en el momento del reporte, **338** medido al cerrar (otro agente consumio el 337).
- **Proxima:** NN > 335. Bloque 2 sin items headless restantes: 4-16 y 20-24 dependen de la API de
  M08 (`set_block` = 0), 22/25/26 del runtime VFX de M52 (no instanciado), 27/28 de assets de audio
  (0 en el repo), 29-31 son de M08. Reposicion de cola pedida (4ta vez) + decision sobre D9 y sobre
  el dueno del runtime VFX.

- [x] Log reservado: **2043** - M35: guarda de ocupacion en el respawn (items J2 + J4), codigo + suite headless

- [x] Log reservado: **2132** — M102 residuo (18 medidos, 0 cerrables sin decisión) + recon del paquete M20 (2026-10-22, mensaje 358). Pool medido justo antes con `reservar_log.py --reservar`: 2132 → cabeza 2133. Canal 359 → cabeza 360.

> **Registro de la vuelta 2026-10-22 14:31 (RAMA 1, mensaje 358 de GLM-5.3-Flash):** Log **2132**, reporte **359**. Se ejecutó la opción (1) del mensaje hasta el fondo: **0 de los 18 defectos residuales de `11-BUGS.md` son cerrables sin decisión**, medido por familia. Hallazgo que cambia el cálculo: **renumerar no baja el conteo** — en las 3 colisiones de id (129/130/139) la entrada pertenece a una fila y la otra queda `fila_sin_entrada` (18→18); igual con 052/058 (`entrada_duplicada`→`entrada_sin_fila`). **Corrección del reporte 357:** BUG-047 SÍ declara `**Estado:** [x] RESUELTO 2026-10-04` (en el bloque-puntero L5436-5444 que dejó mi consolidación); lo que falta es la severidad en la escala de la tabla (`Alta` no aparece en 139 filas: critica=Crítica 20/20, mayor=Mayor 43/43, menor=Menor 58/58). Opción (2): **delegación M20 aceptada** y paquete ya medido — wrapper `tests/test_m20_amistad_suites.gd` en HEAD (`683e9b5`), EXIT 0, 8 checks, total **79** (14+53+12); las 3 suites verdes por separado (EXIT 0, 0 SCRIPT ERROR). **Falso verde probado en rojo:** `_ejecutar()` devuelve `{"rc": 0}` sin leer el exit del hijo → una suite que sale 1 pasa como `rc=0 / TEST OK` (sonda temporal, borrada, `git status` de `tests/` vacío). Piso 69/74 contra 79 medidos (10 de holgura); cabecera dice "77" (tercera cifra); doble ejecución por descubrimiento de `run_tests.gd`. **0 archivos del repo modificados, 0 commits, 0 push, 0 flips.** Pedidos P1-P7 en el reporte 359 (el bloqueante real: decisiones P2/P3, que bajan 18→16).

- [x] Log reservado: **2141** — item 35: deteccion y unificacion de scripts duplicados (2026-10-22, RAMA 2, mensaje 366). Pool de Logs medido justo antes con `reservar_log.py --reservar`: primero=**2141**.

> **Registro de la vuelta 2026-10-22 20:43 (RAMA 2, item 35 de la COLA ACTIVA):** Log **2141**, reporte **366**. Sin mensaje nuevo del director (maximo del canal 364 = tracker), se tomo el item 35. **Universo medido: 967** `.py`/`.ps1`; la primera medicion dio 4942 archivos y 57 grupos exactos pero **40 eran `pip/_vendor/rich`** de `tools/mcp/.venv` -> se excluyeron dependencias vendorizadas y se re-midio. **Resultado real: 2 exactos, 1 normalizado, 81 funciones duplicadas, 4 nombres.** Entregado `scripts/detectar_duplicados.py` + suite **29/0/EXIT 0 x3** (piso 28 MEDIDO) + `scripts/duplicados_baseline.json` (2 firmas con motivo, `--check` EXIT 0). Guardian EN ROJO 3/3 por inyeccion con restauracion byte-exacta. **Unificacion (1):** `scripts-reutilizables/generar_tareas_modelo.py` marcado SUPERSEDED (era un one-off de 80 lineas con el modelo y los modulos de deepseek-v4-flash hardcodeados, sin `__main__`, citado como 'el patron' por `GUIA-METODOLOGIA.md:83`) y la guia pasa a citar el canonico `scripts/generar_tareas_modelo.py`. **NO tocados:** los 2 exactos restantes (assets de M18-BIS y de 36-Fauna: la CASA_02_MEDIANA tiene su propio `.glb` pero el script de la CHOZA -> es trazabilidad, no copia) y las 81 funciones de boilerplate Blender (`crear_mat` en 42 archivos). **0 commits / 0 push / 0 flips.** Pedidos P1-P5. Trampas nuevas: un detector que incluye `site-packages` mide pip y no el proyecto; `ast.dump` con atributos hace que el mismo codigo en otra linea sea 'distinto'; el piso de checks escrito antes de medir hace fallar una suite SANA; la FIRMA byte-based cambia legitimamente al agregar un comentario (lo que no cambia es la huella AST); un invariante de EOL por CONTEOS convierte un cambio correcto en fallo (el invariante es el TIPO).

- [x] Log reservado: **2142** — item 36: auditor de citas de checklists + verificacion de M90 (2026-10-22, RAMA 1 mensaje 367 + trabajo de cola, mensaje 368). Pool de Logs medido justo antes con `reservar_log.py --reservar --agente DeepSeek-V4.1-Flash --modulo M00`: cabeza **2142** = ultimo log 2141 + 1, cabeza tras la reserva **2143**. Canal: cabeza medida **368** = mensaje 367 del director + 1; consumido 368, cabeza tras consumir **369**.

> **Registro de la vuelta 2026-10-22 21:02 (RAMA 1, mensaje 367 de GLM-5.3-Flash):** Log **2142**, reporte **368**. El director ratifico el item 35 completo (P1 commit `48c022c`, P2 en espera del fundador, P3/P4 escalados al dueno de assets, **P5 `[→]` ratificado**); sin tarea nueva, segui con la cola. **Item 36 medido y NO ejecutable:** M90 tiene **249 [x] / 0 [ ] / 0 [?]**, no los 100 pendientes que declara el item, y sus 249 `[x]` estan respaldados por codigo y por 2 suites que corri HOY con el binario real (**85/0/6 bloques** y **57/0**, ambas EXIT 0, 0 SCRIPT ERROR). **Entregado:** `scripts/auditar_citas_checklist.py` (3 metodos, `exit 3` = detector ciego, `--check` con baseline `{firma: motivo}`) + `scripts/test_auditar_citas_checklist.py` (**42 checks / 0 fallos / EXIT 0 x3**, piso **42 MEDIDO**, 6 controles negativos, comprueba que el auditor no escribe) + `scripts/citas_baseline.json` (**150 firmas** con motivo). **Medido sobre 167 checklists y 13.811 citas: 195 defectos** (192 citas de archivo rotas + 2 refs de linea fuera de rango + 1 checklist binaria), de los cuales **50 estan en items `[x]`** (falso verde declarado) y 144 en prosa; informativos: 57 dirs ausentes, 51 globs, 8 citas de clase imprecisas. **M90 medida aparte: 293 citas, 0 defectos.** **Guardian EN ROJO 3/3** por inyeccion (ceguera desactivada / clasificador permisivo / suite recortada) con restauracion byte-exacta por sha256; **gate en rojo** probado sobre el corpus real con un baseline recortado (EXIT 1 nombrando la firma). **Hallazgos escalados:** la checklist de **M159 tiene 1 byte NUL** (offset 356, `\x006-Diseno-Visual.md` debia ser `06-Diseno-Visual.md`) y por eso **grep la salta en silencio**; la cita `moon_curve.tres L54` de M31 esta **mal atribuida** (el `.tres` tiene 5 lineas, el L54 es de `day_night_cycle.gd`); `validar_catalogo_m159.gd` citado en L210 tiene 181 lineas. **Aviso:** el CRON commiteo en vuelo (`8f97325`) una version **a medio construir** del auditor (545 lineas) — la version final en disco tiene 651 lineas y pide commit (P1). **0 commits / 0 push / 0 flips.**

- [x] Log reservado: **2165** — M01 iter. 10: clasificacion de los 111 modulos bloqueados por TIPO de dependencia (2026-10-24, RAMA 1, mensaje 379 punto 5). Pool de Logs medido justo antes con `reservar_log.py --reservar`: cabeza **2165** = ultimo 2163 + 2 (el 2164 lo consumio otro agente); cabeza tras la reserva **2166**. Canal: cabeza medida **380** = ultimo archivo 379 + 1; consumido 380, cabeza tras consumir **381**.

> **Registro de la vuelta 2026-10-24 00:42 (RAMA 1, mensaje 379 de GLM-5.3-Flash):** Log **2165**, reporte **380**. **Dos premisas del mensaje no cerraban y se midieron antes de trabajar:** (1) decia **107** bloqueados, el disco tiene **111** (efecto de los flips M69/M98/M117 posteriores al 378) y el indice maestro **32 [x] / 120 [ ] / 0 [?] = 152**, no 29/152; (2) **el codigo de la iter.10 ya estaba en HEAD** (`c96721d`, mtime 23:12, "las herramientas y sondas del indice M01") **sin log ni mensaje** — el cron del director commiteo el worktree en vuelo; se verifico en vez de reescribirlo. **Lo que aporto la vuelta: medir la PRECISION antes de publicar el conteo.** Muestreo deterministico y lectura item por item: `cuenta_externa_fundador` **5/5 = 100 %**, `hardware` **9/13 = 69 %**, `asset` **19/34 = 56 %**, `decision_proyecto` **4/4 = 100 %**. **Dos correcciones de patron medidas:** (a) `hardware` cazaba implementacion y targets (16 de 56 items, 28,6 %: "FPS overlay cada 0.5s", "Definir objetivo 30 fps") -> ahora exige token DURO de dispositivo o token de performance + verbo de medicion; **56 -> 37**. (b) `asset` cazaba vocabulario tecnico (`mesh`/`malla`/`material`/`particula`/`vfx`: "Pool de meshes reutilizado" es implementacion) -> **206 -> 168**. (c) ceguera a plurales (`\bdispositivo\b` no matcheaba "dispositivos"): 5 items del residual. (d) el residual `sin_senal` se renombro a `sin_dependencia_declarada` porque se leia como detector ciego. **Resultado sobre 2571 items:** cta 5 (0,2 %), hdw 37 (1,4 %), asset 168 (6,5 %), decision 4 (0,2 %), otro_modulo 803 (31,2 %), trabajo_propio 74 (2,9 %), sin_dependencia_declarada 1480 (57,6 %). **Hallazgo principal: ~5 % de la deuda abierta espera a un tercero**; **52 de los 111 modulos no tienen ni un item externo** (su bloqueo es su propia checklist). **Evidencia:** suite **62/0/EXIT 0 x3**, piso 54 -> **62 MEDIDO**, **sonda EN ROJO** de la regla nueva (revertir el patron -> EXIT 1 con 5 fallos que nombran los checks del bloque O; restauracion byte-exacta por sha256 + control 62/0), ceguera probada (exit 3). **Entregables:** `scripts/auditar_indice_m01.py` (`--dependencias`, `--bloque`, `--tam`, `--json`), `scripts/test_auditar_indice_m01.py` (bloque O), `plan-actual/10-Clasificacion-Dependencias.md` (metodo, precision, bloque 0 con los 5 items del fundador, los 52 modulos, 6 tablas de 20 modulos). **0 commits / 0 push / 0 flips.** Pedidos: commit de 3 paths, drift de la fila 01 (dice 29/152, disco 32/152), y decision sobre `asset` (168 con 56 % de precision: cota superior o triage por dueno; NO propongo mas regex).
