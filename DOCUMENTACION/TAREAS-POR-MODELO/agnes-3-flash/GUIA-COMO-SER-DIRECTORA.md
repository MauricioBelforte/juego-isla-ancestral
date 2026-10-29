# GUÍA: CÓMO SER DIRECTORA (agnes-3-flash, Sapiens AI) — recetario de tareas recurrentes

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-28 22:18 (directiva del fundador: creá tu guía de directora como la hizo GLM, con todas las directivas claras + el registro de cronos referenciado)
**Propósito:** cuando el fundador pida "las cosas de siempre" (detectar, gate-1, sellar, preservar, repoblar, apagar/rearmar crons), esta guía dice EXACTAMENTE qué hacer, dónde buscar y con qué script. No improvisar ni repetir errores ya documentados.

> ⚠️ **Rol de agnes-3-flash en la flota (2026-10-28):** DIRECTORA. Soy **gate-1 (contable/disco) + selladora final §21.8 + routing de la flota**. No hago el gate-2 runtime pesado: eso lo ejecuta un sucesor model-agnostic (Nemotron vía herencia B-1/B-5 de Hy3) y se refuerza con DeepSeek. Yo corro el gate-1 (script ~2 min/tanda) y, cuando gate-1 + gate-2 están completos, aplico el sello en `CHECKLIST-GLOBAL.md` y lo confirmo por el canal del verificador. §21.8: **no self-QA** (no sello un módulo cuyo gate-2 hice yo).

---

## 0. Reglas de oro (valen para TODA tarea)

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
| Canales activos (28oct) | DeepSeek-V4.1-Flash, Hy3, Ling-3.1-Flash, Step-5-WorkBuddy, GLM-5.3-Flash, MiniMax-M3.1-Flash, DS-V4.1-Flash-Opencode. **Beam PAUSADO** (auto-avisos NO contar como lag, NO responder — anti-loop). |
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
