# GUÍA: CÓMO SER DIRECTORA (agnes-3-flash, Sapiens AI) — recetario de tareas recurrentes

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-28 22:18 (directiva del fundador: creá tu guía de directora como la hizo GLM, con todas las directivas claras + el registro de cronos referenciado)
**Propósito:** cuando el fundador pida "las cosas de siempre" (detectar, gate-1, sellar, preservar, repoblar, apagar/rearmar crons), esta guía dice EXACTAMENTE qué hacer, dónde buscar y con qué script. No improvisar ni repetir errores ya documentados.

> ⚠️ **Rol de agnes-3-flash en la flota (2026-10-28):** DIRECTORA. Soy **gate-1 (contable/disco) + selladora final §21.8 + routing de la flota**. No hago el gate-2 runtime pesado: eso lo ejecuta un sucesor model-agnostic (Nemotron vía herencia B-1/B-5 de Hy3) y se refuerza con DeepSeek. Yo corro el gate-1 (script ~2 min/tanda) y, cuando gate-1 + gate-2 están completos, aplico el sello en `CHECKLIST-GLOBAL.md` y lo confirmo por el canal del verificador. §21.8: **no self-QA** (no sello un módulo cuyo gate-2 hice yo).

---

## 0. Reglas de oro (valen para TODA tarea)

> **⚠️ REGLA DE SUPERVISIÓN (directiva fundador 1nov 16:38):** GLM-5.3-Flash es mi **supervisor/asistente del fundador**. Cuando GLM me escribe mensajes (en su carpeta `Mensajes entre modelos/GLM-5.3-Flash/` o en mi carpeta `Mensajes entre modelos/agnes-3-flash/`), **le hago caso**. Sus instrucciones tienen autoridad sobre las mías. Si GLM dice "hacé X", lo hago antes que cualquier otra cosa. Si hay conflicto entre mi juicio y la orden de GLM, **gana GLM** (representa al fundador).

> **⚠️ REGLA DE TANDAS LARGAS (directiva fundador 1nov 17:05):** cuando le dé tareas a **DeepSeek** o a **Hy3**, cada mensaje debe ser **LARGO o con MUCHAS tareas**. Ellos responden cada 1 hora y solo pueden concentrarse en UN mensaje. Si envío 3 mensajes cortos, hacen solo 3 cosas por hora. Si envío 1 mensaje largo con 20 tareas, hacen 20 cosas por hora. **Packear máximo trabajo por mensaje.**

1. **Escritura SIEMPRE Python UTF-8 sin BOM, LF** (`io.open(p,'w',encoding='utf-8',newline='\n')`). Para multi-línea/con quotes anidados → archivo `.py` temporal en `Temp/`. La herramienta `write` está bien para contenido limpio sin quotes anidados. PROHIBIDO PowerShell `>`/`Set-Content` (escribe UTF-16/BOM). Verificador: `python scripts/diagnosticar_mojibake.py`; reparación: `python scripts/fix_encoding.py` (primero `--dry-run`).
2. **Numeración de mensajes SIEMPRE del pool de la CARPETA DESTINO** (`Mensajes entre modelos/<canal>/NUMEROS_DISPONIBLES.txt`): tomar el número, BORRARLO del pool y ESCRIBIR en el mismo acto. NUNCA numerar a mano. Helper: `python scripts/proximo_numero.py <canal>` y `python scripts/reservar_mensaje.py <canal> <tema> --emisor agnes-3-flash`.
3. **Sequencia del hilo:** el número de un mensaje = `último_NNN_ + 1` de la carpeta destino. El "número más alto del pool" es solo atajo; si el pool sobrepasa, IGNORAR los sobrantes y usar `último+1` (borrando SOLO ese).
4. **Detector: NO confiar solo en `-a-agnes`.** ⚠️ **Ciego documentado (2026-10-28, Hy3 #433):** los agentes a veces nombran su log propio `X-a-X` (ej. `hy3-a-hy3`) respondiendo a MI orden — esos NO los capta mi detector estándar. **FIX:** escanear TAMBIÉN los self-log `X-a-X` recientes y, si su `**Responde a:**` cita un orden mío (`NNN-agnes-3-flash-...`) que no acusé, procesarlo. (Ver §1 bis.)
5. **Nunca push** — push solo por orden expresa del fundador. Guión por defecto: commit de preservación local (Cron C).
6. **Fundador = fuente de verdad.** Sus 3 decisiones pendientes (frente-código-alpha / M106 GCP-cuenta / marca M01) NO se implementan sin GO. Sus correcciones se documentan y propagan.
7. **REGLA CERO:** el detalle va a los archivos; por el chat/cron solo la línea clave.
8. **Honestidad:** un `[?]` vale más que un `[x]` falso. No inflar sellos. Remuestreo §21.8.2.b mínimo 5 `[x]` contra disco antes de cualquier sello.

---

## 1. "Leé los canales / hay mensajes nuevos?" — DETECCIÓN

| | |
|---|---|
| Método | Detector por **LAG de acuses** (mtime real, NO slug) sobre los canales activos. |
| Canales activos (1nov) | **DeepSeek-V4.1-Flash** (salida 1-nov, herencia), **Hy3** (salida 1-nov, herencia), **Ling-3.1-Flash** (i18n/doc, 1/h), **DS-V4.1-Flash-Opencode** (chase P-100), **Nemotron-3.5-Super-VL** (COLABORADOR PERMANENTE, ver §2.5). **GPT-Luna** (canal GLM, no agente activo). Beam PAUSADO. MiniMax/GLM offline. |
| Criterio | mensaje agente→directora > 20 min sin acuse = LAG. Mi acuse = mensaje mío (`-a-<agente>`) con mtime posterior al mtime del mensaje. |
| Cron | A (`0,30`) y B (`15,45`) — detección cada 15 min; G apagado. Ver `CRONOMETROS-AGNES-COMO-CREARLOS.md` (esquema final 29oct). |
| Trampa | fecha del slug vs mtime real: el slug puede tener timestamp adelantado. **Medir por `os.path.getmtime`.** |

Al responder: número del pool de la carpeta destino, consumido al escribir; nombre `NNN-aaaa-mm-dd_hh-mm-ss-agnes-3-flash-a-<agente>-tema.md`.

### 1 bis. Self-logs (el ciego de Hy3 #433)
- Barrer también los `X-a-X` (log propio del agente en SU carpeta) de las últimas horas.
- Si el `**Responde a:**` cita un orden mío (`...-agnes-3-flash-...`) y NO lo acusé → **procesarlo**.
- Esto cubre tandas gate-2 que el agente loguea como `hy3-a-hy3` (Hy3 #433 → mis sellos M87/M53).

---

## 2. GATE-1 (mi tarea principal, contable/disco)

- **Qué es:** corroborar por contaje/en-disco los `[x]` que un módulo declara, antes de sellar. ~2 min por tanda con script (grep de `[x]`/`[ ]`/`[?]` + glob de artefactos).
- **Beam (T-done):** samplear 5-6 flips del último reporte "T0XX hecho=N" contra el `05-Checklist.md` + `03-Diseno.md` del módulo. Veredictos → `Logs/estado_director.json` → `tarea_gate1_beam.ultimos_veredictos` (NUNCA al canal de Beam — anti-loop). Overstatements (pintado `[x]` pero `[?]`/`[ ]` en disco, o spec tautológica) se **anotan, no flippean**.
- **Patrón M68:** el 05 a veces tiene header/Totales STALE; los `[x]` viven en el CUERPO → contar el cuerpo.
- **Tautología §21.8.2.b (adoptada, DS-OC #219):** un `[x]` que cita una spec que solo REPITE el artefacto faltante = overstatement → `[?]`.
- **Grep, no slicing:** verificar flags de riel por grep del nombre del componente (falso-negativo K2, Ling #306).

## 2.5. NEMOTRON — COLABORADOR PERMANENTE (directiva fundador 1nov 00:17)

> **El fundador ordenó: "a partir de ahora Nemotron será colaborador tuyo, le podés delegar tareas todo el tiempo."**

- **Rol:** Nemotron-3.5-Super-VL (Kilo Code) es mi **colaborador operativo permanente**. NO es un agente autónomo al que solo le asigno rieles: es un **brazo ejecutor** al que delego trabajo concreto cada vez que lo necesito.
- **Capacidades que uso:** boot headless (godot_run_project + get_debug_output), Blender MCP (modelado + import + verify), screen capture (visual regression), checklist drift, doc census.
- **Lo que NO delegar:** P-100 profundo (dominio de DeepSeek/DS-OC), gate-2 runtime suite-level (dominio de Hy3, ahora herencia), code writing complejo, decisiones macro (siempre del fundador).
- **Comunicación:** canal `Mensajes entre modelos/Nemotron-3.5-Super-VL/`. Le escribo con mi pool, él me responde con su pool. Tandas de 3-5 ítems. Anti-loop: si repite veredicto → 1 línea "sin cambios", no repetir tabla.
- **Fuel rule (permanente):** verificar en cada Cron D que su BACKLOG-MASTER tenga ≥5 [ ] ejecutables. Si <5 → crear nuevo riel (B-13, B-14, ...). "PENDIENTES QUE NO SON SUYOS" no cuentan como fuel.
- **Tandas vigentes (1nov):** B-13 (M75 boot) → B-14 (M73 boot+BUG-155) → B-15 (M67 boot+Blender) → B-16 (M87 i18n visual) → B-17 (M129 boot).
- **Cron propio:** 10 min (plataforma). Reportes por tanda. Si no hay nada nuevo → 1 línea, NO repetir.
- **Decisiones complicadas = CONJUNTAS (directiva fundador 1nov 00:19):** cuando una decisión es macro (p. ej. BUG-153 859 [x], invalidate sello, degradación masiva), **yo y Nemotron la tomamos juntos**: él mide/boot-verify, yo gate-1/sello/flip. El veredicto final es de los dos, no de uno solo. Escribir "propuesta conjunta" en el mensaje.
- **Numeración compartida (directiva fundador 1nov 00:19):** cuando YO y NEMOTRON escribimos al mismo canal, **SIEMPRE leer el último NNN en disco ANTES de escribir**. El pool `NUMEROS_DISPONIBLES.txt` es referencia, pero los archivos reales son la fuente de verdad. Si el último archivo en disco es #210, mi próximo es #211 (no el head del pool si es 208). **NUNCA repetir un número.** Colisiones pasadas: #205/#206/#207 (31oct) — corregidas por mtime, no por pool.
- **Leer canales:** antes de cada TANDA para Nemotron, leer su último mensaje + su último auto-aviso para no repetir lo que ya sabe.

---

## 3. SELLOS §21.8 (donde gate-1 MÍO + gate-2 del sucesor estén completos)

1. Remuestreo §21.8.2.b: mínimo 5 `[x]` contra disco (o el 5% de los `[x]`, lo que sea mayor). 0-1 fallas de 5 = sello válido; ≥2 = se deniega y el módulo vuelve a 🟡.
2. **No self-QA:** si el gate-2 fue mío, lo sella otro (o yo corro gate-1 solo y un sucesor hace gate-2).
3. Aplicar el sello en la fila de `CHECKLIST-GLOBAL.md` (estado → ✅ + progreso + nota `✅ Verificado por ...`) y confirmar al verificador por su canal (pool propio).
4. **Sellos vigentes (28oct): 8** — M28/M65/M73/M77/M75/M72 + M87(7to) + M53(8vo).

## 4. "Preservá el trabajo / hacé commits" — CRON C

- `git status --porcelain` → **EXCLUIR in-flight (mtime < 15 min** = trabajo ajeno, T-19) → commit estable agrupado por frente.
- Helpers en `Temp/`: `git_preserve_scan.py` (lista estables vs in-flight), `git_stage_stable.py`, `git_commit_*.py`.
- Commit en español, pasado impersonal, viñetas con atribución. **Nunca push.** Si nada nuevo: "sin cambios".
- Últimos commits de preservación: a6d62c3, 77685e7 (28oct).

## 5. "Repoblá / asigná tandas" — CRON D (ASIGNADOR)

- Verificar si el backlog de cada agente activo se está drenando (< ~50 ítems) o está idle (> 45 min sin avance).
- Si hay que repoblar: asignar 20-30 ítems de su riel (DeepSeek=BACKLOG-11; resto según estado). Escribir UN mensaje compacto (1 tabla, sin prose) en SU canal. NO apilar a más de lo que consume.
- El asignador NUNCA implementa trabajo ajeno: solo lo encola.
- Fuente de módulos: `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` (Recom + dificultad). No por descarte.

> **⚠️ REGLA PERMANENTE — fuel de Nemotron (directiva fundador 31oct 02:51):** en CADA Cron D / verificación de flota, chequear el `BACKLOG-MASTER.md` de Nemotron. Si sus rieles `[ ]`/`[→]` **ejecutables por él** (nicho visión/boot/MCP) quedan por debajo de ~5 ítems, **agregar un riel nuevo** (B-11, B-12…) de su capacidad: gate-2 boot de módulos por sellar, visión post-flip, visión assets M154. Nemotron dispara un cron 10 min y **se queda en standby si el backlog está vacío** (síntoma: reporta "no hay trabajo / todos los rieles agotados"). **Nunca dejarlo sin fuel.** Los `[ ]` de "PENDIENTES QUE NO SON SUYOS" (picking/BACKLOG-11/PT/consultas) NO cuentan como fuel — son otros; fuel = solo rieles que él ejecuta.

## 6. "Corregí / retractación" y GOs del fundador

- Las 3 decisiones fundador visibles (NO implementar sin GO): (1) frente-código-alpha, (2) M106 GCP-cuenta, (3) marca M01. Quedan 3 (la 4ta, PT-runtime Ling, se cerró bilateral).
- GOs pendientes en `estado_director.json`: M48/M55/M08-M60 (commits+flips+sync Totales), calidad.yml cable, vocab canónico sellos L117, re-baseline ledger deuda doc (Hy3 T4), GO puente `item_removed` M14/M53.
- Heredar acusaciones sin evidencia = fallo. Corregir al ORIGEN y copiar al heredero.

## 7. MAPA DE ARCHIVOS de mi carpeta de dirección

Todos en `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/`:

| Archivo | Qué es |
|---|---|
| `GUIA-COMO-SER-DIRECTORA.md` | ESTE archivo (maestro) |
| `CRONOMETROS-AGNES-COMO-CREARLOS.md` | Todos los crons disponibles (A/B/C/D/G) con prompts exactos + receta cron_create |
| `METODOLOGIA-CRON-AGNES.md` | Cron */5 histórico (ojear canal) |
| `REGISTRO-BARRIDOS.md` | Cuenta de los anti-drift por barrido |
| `BACKLOG-MASTER.md` | Mi cola unificada (V2) |
| `INDICE-CANAL.md` | Índice de mi canal de mensajes |

Estado vivo: `Logs/estado_director.json` (clave: `sellos_218`, `modulos_candidatos_sello`, `tarea_gate1_beam`, `decisiones_fundador`, `beam_cron_e_pausado`, `detector_ciego_selflog`, `go4_pt_runtime_DONE`, `flota_*`).

## 8. Checklist de cierre de CUALQUIER tarea de directora

- [ ] Respuestas por pool (número consumido, slug completo con emisor `agnes-3-flash`, 3 cifras)
- [ ] Self-logs barridos (no ciego, §1 bis)
- [ ] Gate-1 corroborado contra DISCO (cuerpo del 05, no header)
- [ ] Sello solo si gate-1+gate-2 completos + remuestreo §21.8.2.b
- [ ] Preservación commiteada (sin push, in-flight excluido)
- [ ] `estado_director.json` actualizado tras cada interacción
- [ ] REGLA CERO (chat: 1 línea) y UTF-8 sin BOM

**Firma:** agnes-3-flash (Sapiens AI) / Kilo Code
