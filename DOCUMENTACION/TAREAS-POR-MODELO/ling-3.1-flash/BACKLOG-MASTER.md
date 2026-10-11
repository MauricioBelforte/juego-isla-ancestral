# Backlog Master — ling-3.1-flash (inclusionAI / Ant Group)

> **Estado:** 🟢 VIGENTE (alta 2026-10-06, sesión s3) — **trial gratuito hasta el 13/10/2026**
> **Plataforma:** Kilo Gateway (verificado in-house 2026-10-06) · OpenCode · Vercel AI Gateway · OpenRouter
> **Rol:** Sub-agente agentic + respaldo del coordinador en auditoría de seguridad

## Identidad y specs verificadas

Fuentes primarias: API viva de OpenRouter, Kilo Gateway (verificado in-house), models.dev, Artificial Analysis, BenchLM/Build Fast with AI (benchmarks del launch de `@AntLingAGI`), MindStudio (hands-on), aitoolsreview.co.uk.

- **Modelo:** Ling 3.1 Flash — inclusionAI (laboratorio AGI de **Ant Group**, Hangzhou)
- **Arquitectura:** MoE híbrido con **razonamiento híbrido** (variants `instant` / `thinking`, verificadas en el Kilo Gateway)
- **Parámetros:** **560B totales / 25B activos** (~4.5x el total y ~5x los activos de Ling 3.0 Flash)
- **Contexto:** **262.144 tokens** en gateways (Kilo/Vercel/OpenRouter) — **1M es design target** de InclusionAI y se mide en su API oficial. **Planear sobre 256K.**
- **Salida máxima:** 32.768 tokens
- **Entrada/Salida:** **solo texto** (NO multimodal — Artificial Analysis confirma que rechaza imagen)
- **Tool use:** function calling + tool choice + JSON mode + reasoning tokens
- **Pesos/licencia:** **CERRADOS / no publicada** — hosted-only. Toda la familia Ling hasta 3.0 era MIT; este rompe la tradición. Open-sourcing "prometido tras el trial", sin fecha.
- **Lanzamiento:** 29/09/2026 (Vercel anuncia en AI Gateway el 30/09/2026)
- **Precio:** **$0/$0 gratis hasta 13/10/2026** (Vercel `inclusionai/ling-3.1-flash-free`, OpenCode `ling-3.1-flash-free`, OpenRouter, Kilo Gateway). API oficial InclusionAI: **$0.30 input / $0.90 output** por 1M (80% cache discount). **Post-trial: NO publicado.**
- **Velocidad:** **210.7 tok/s** (#16/176 en su clase), TTFT 1.80s, 11.29s al primer token de respuesta (incluye thinking)

### Benchmarks

**Vendor-reported (launch `@AntLingAGI`, tabulados por BenchLM / Build Fast with AI):**

| Benchmark | Ling 3.1 Flash | Referencia catálogo | ¿Gana? |
|---|---:|---|:---:|
| **CyberGym** | **87.9%** | **Atria 86.5 (#1)** · GLM 5.3 84.5 | ✅ supera a Atria en su nicho |
| DRACO (research & analysis) | **85.5%** | sin comparable directo | — |
| **SkillsBench** | **68.7%** | Atria 66.4 · Qwen 3.8 Max 66.7 | 🟢 #1 del catálogo |
| HealthBench Professional | 65.3% | dominio médico, sin aplicación en game dev | — |
| Finance Agent v2 | 57.9% | dominio financiero | — |
| SWE Atlas Codebase QnA | 55.9% | Muse Spark 90.3 (otro harness) | ❌ |
| **AutomationBench** | 52.5% | **Atria 53.8 (#1)** | ❌ Atria mantiene el nicho |
| Terminal-Bench **4.0** | 40.4% | NO comparable con TB 2.1 del catálogo; Opus 5 TB 4.0: 51.8 | ❌ |
| GDPval-AA v2.1 | 1.673 Elo | Opus 5 / GPT 5.6 Sol 1.768 | ❌ ofimática débil |
| **DeepSWE 1.1** | **NO PUBLICADO** | DeepSeek V4.1 74.2 · Kimi K3 67.5 · GLM 5.3 Flash 63.4 | ⛔ no comparable |

**Independiente (Artificial Analysis, Intelligence Index v4.3.2):**

- **AA Intelligence Index: 41 — #3/176** en su clase (mediana 13). Supera la estimación de Agnes 3.0 Flash (36).
- ⚠️ **Muy verbose:** 220M tokens de output en el AA Index (mediana 100M) — **2x la mediana**; el razonamiento híbrido gasta tokens.

### Hands-on independiente (MindStudio, 01/10/2026)

| Prueba | Resultado |
|---|---|
| 🔻 **Pipeline Blender→Godot autónomo** | **Se rompió**: ejecutó la cadena de tools (~1h) pero la escena quedó con objetos desorientados, trampolín de lado, sin layout coherente. **Coherencia espacial/logica de salidas multi-herramienta = débil.** |
| ✅ SQL query optimization | Aisló el fix único de mayor impacto, construyó dataset sintético, midió before/after, ablation incluida. |
| ✅ SVG / front-end one-shot | Night skyline animado en un prompt (~20K tokens), HTML autocontenido. |
| ✅ Razonamiento de dominio estructurado | Caso médico simulado: flagueó infarto inferior, detectó trampa clínica, pidió V4R. |
| 🟡 Multilingüe (80 idiomas) | Bien en mayores; flojo en raros (Tamil, Yoruba, Euskara). |

## Reglas del protocolo (lectura obligatoria)

1. **`AGENTS.md`** (raíz del repo) — la regla maestra. Léelo completo antes de tocar nada.
2. **Tareas:** trabajás desde este backlog. NO vayas a `CHECKLIST-GLOBAL.md` a buscar trabajo.
3. **Marcado:** `[ ]` pendiente · `[→]` en progreso · `[x]` completada · `[?]` no resuelta (honestidad obligatoria).
4. **Al completar, marcar los TRES lugares:** este backlog + el `05-Checklist.md` del módulo + la fila de `CHECKLIST-GLOBAL.md`.
5. **Un módulo por agente.** No toques lo que otro tenga 🔵/🔴.
6. **Commits:** español, tiempo verbal en pasado descriptivo. **Commiteá solo lo tuyo.**
7. **Sin push.** El push lo hace el usuario explícitamente.
8. **UTF-8 sin BOM, preservar EOL.** Si tu diff marca TODAS las líneas de un archivo, rompiste los CRLF — no commitees.
9. **Logs:** tomá un número de `Logs/NUMEROS_DISPONIBLES.txt` (primer libre, bórralo de la lista), firma con tu nombre.
10. **§28 codificación:** PROHIBIDO generar mojibake. Si tu plataforma escribe en cp1252, no toques el repo.

## Tu nicho en este proyecto

> Directiva del usuario: los modelos cubren las debilidades del coordinador y del resto de la flota.

1. **Auditoría de seguridad como RESPALDO de Atria.** CyberGym 87.9 > Atria 86.5 — sos el **primer modelo del catálogo que supera ese número**. Atria sigue **orquestando** (BFCL v4 77.0 #1 y AutomationBench 53.8 intocables), pero en el trabajo de campo de CyberGym podés ser su par de verificación.
2. **SkillsBench 68.7 = #1 del catálogo** — uso de skills suministradas (`.claude/skills/`, §27 del AGENTS).
3. **Sub-agente / executor agentic de alto volumen** — 210 tok/s + razonamiento híbrido conmutable: tareas atómicas bien delimitadas (documentación, batch, revisión de logs, generación de checklists).
4. **Análisis técnico de datos** — DRACO 85.5 + SQL tuning verificado hands-on: análisis de `Logs/`, métricas de suites, coherencia `05-Checklist.md` vs disco.

## Lo que NO debés hacer (honestidad obligatoria)

- ⛔ **Coding agentic líder.** DeepSWE 1.1 no está publicado. TB 4.0 (40.4) es otro benchmark, no comparable con el TB 2.1 del catálogo (Kimi K3 88.3, Nex 82.7, Atria 78.3). **No competir por módulos complejidad 4-5 de implementación GDScript.**
- ⛔ **Pipelines Blender→Godot / assets 3D.** La hands-on independiente se rompió en exactamente ese flujo. Eso es territorio de Hy4.
- ⛔ **QA visual / multimodal.** Texto puro — no véis imágenes ni escenas `.tscn`. Eso es de Agnes 3 / mimo V2.6 (visión limitada) / el usuario (M154).
- ⛔ **Orquestación de muchos MCPs.** Atria #1 en BFCL v4 77.0 y AutomationBench 53.8.
- ⛔ **QA cruzado §21.8.** Regla del proyecto: Hy3.
- ⛔ **Módulos 🔵/🔴** en curso por otro agente.
- ⚠️ **Cadenas multi-herramienta largas.** Tu evidencia hands-on muestra que ejecutás la cadena pero perdés coherencia espacial. **Pedí tareas atómicas y autosuficientes.**
- ⚠️ **Datos sensibles al endpoint gratuito.** Vercel rutea vía Novita (terceros); no hay system card publicado a pesar de liderar CyberGym. No envíes credenciales ni datos de usuario a endpoints gratuitos.

## Método de trabajo recomendado

- **Sesiones cortas y autosuficientes.** 256K de contexto + verbosidad 2x la mediana te saturás antes que Kimi K3 (1M). Toda la información necesaria tiene que estar en el prompt inicial.
- **`instant` para tareas mecánicas, `thinking` solo cuando aporte.** El razonamiento híbrido es conutable — usalo como palanca de eficiencia, no por defecto.
- **Trial de 7 días (hasta 13/10/2026).** Toda tarea asignada debe poder **reasignarse** (§21.4.7) si el trial se cierra o llega el precio post-trial (no publicado).

## Tareas asignadas

> **NINGUNA todavía.** Como todo modelo nuevo del catálogo (Space Bunny SB-01, Gemini G-01/G-02), entrás con **una tarea de validación L-01 de complejidad 1-2** que define el director, y sin asignaciones críticas hasta tener evidencia propia en el repo. **CyberGym 87.9, SkillsBench 68.7 y AA Index 41 son claims; la primera entrega decide.**

### L-01 — Auditoría de `.claude/skills/` (§27) — `[x]` COMPLETADA

- **Estado:** `[x]` completada el 2026-10-06 — 69/69 skills auditadas con evidencia en disco.
- **Resultado:** 56 ✅ VERIFICADAS · 13 ⚠️ CON DRIFT · 0 ❌ ROTA/IRRELEVANTE.
- **Hallazgos clave:** (H-1) 12 skills de Blender citan 9 references compartidas `../references/` que no existen en disco (la carpeta `.claude/skills/references/` del repo upstream no se instaló); (H-2) godot-characterbody-2d es 2D en proyecto 3D (baja relevancia); (H-3) godot-master es mirror de 1271 scripts, 0 APIs Godot 3 reales en los 1671 scripts .gd totales (verificación case-sensitive); (H-5) falsos positivos de regex descartados y documentados.
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/L-01-auditoria-skills.md` (UTF-8 sin BOM, 0 mojibake).
- **Log:** no creado por restricción explícita de solo-lectura de la tarea (declarado en el reporte §5 por honestidad).
- **Qué auditar:** las **69 skills instaladas** en `.claude/skills/` (44 Godot + 2 Blender +
  23 otros). Fueron instaladas el 2026-08-25 con curatoria, pero **nunca se verificaron** contra
  el repo real.
- **Método:** listar las 69 carpetas → leer cada `SKILL.md` → verificar que los
  scripts/comandos/rutas que referenced existen en disco → comprobar que las APIs citadas son de
  **Godot 4.7.2** (binario `C:\Temp\godot\godot472.exe`, proyecto en `game/isla-ancestral/`) y
  Blender vigente → clasificar cada skill (✅ verificada / ⚠️ con drift / ❌ rota o irrelevante).
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/L-01-auditoria-skills.md` con
  tabla skill | estado | evidencia en disco (ruta exacta) + sección de autoevaluación honesta.
- **Restricciones:** **SOLO LECTURA** sobre el repo — no modificar skills, código ni
  CHECKLIST-GLOBAL. UTF-8 sin BOM (§28). Sin commit ni push.
- **Criterio de éxito (L-01):** reporte completo de las 69 skills con evidencia citada por
  skill y autoevaluación honesta de complejidad 1-2. **Es la tarea de validación**: si la
  entrega es buena (citas reales, no impresiones; cero falsos verdes), se desglosan los nichos
  en L-02…L-100+ y recibe asignaciones reales.

### L-02 — Cierre de los 4 ítems pendientes de M150-Diseno-Sonoro-Narrativo — `[x]` COMPLETADA Y APROBADA

- **Qué era:** cerrar los 4 `[ ]` pendientes del `05-Checklist.md` de M150 (146/150).
- **Qué hizo:** midió con regex y descubrió que el encabezado mentía (decía 125, la realidad era
  146). Corrigió encabezado + Totales. Los 4 ítems (L52 recuerda_sello, L90 lore_oculto,
  L123/L127 leitmotifs de islas) quedaron `[?]` con dueño de bloqueo identificado
  (M22-historia, M148-lore, M41-música) en vez de `[x]` falsos. Descubrió de paso que la
  integración M150→M41 por señales está documentada pero no cableada
  (`narrative_sound.gd:74` vs `music_director.gd` sin conexión).
- **Verificación del director (2026-10-06):** conteo regex independiente 150/146/4/0, EOL CRLF
  preservado, UTF-8 sin BOM, todos los claims del JSON y los dos scripts confirmados en disco.
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/L-02-m150-cierre.md`.
- **Evidencia:** Log 1367 (aprobación + regla de asignación actualizada en §5.S de la guía
  comparativa).

### L-03 — Auditoría de robustez/seguridad del sistema de guardado — `[x]` COMPLETADA Y APROBADA

- **Qué era:** primera tarea de su nicho de seguridad (CyberGym 87.9, claim sin validar hasta
  ahora). Alcance: `game/isla-ancestral/scripts/saving/` completo (13 archivos, 1915 líneas) +
  proveedores de guardado (56 registrados, 9 auditados en profundidad) + M59.
- **Qué hizo:** 10 hallazgos numerados (S-01..S-10: 4 medios, 3 bajos, 3 informativos) + 15
  puntos sólidos, todos citados a `archivo:línea`, + respuesta directa a las 9 preguntas del
  enunciado. Descartó sospechas al verificarlas (empezó creyendo que `monedas=-9999` pasaba;
  `economy_manager.gd:178` demostró que no). Corroboró S-01 en la propia documentación del
  proyecto (`save_schema.gd:117-123`).
- **Verificación del director:** 6 spot-checks contra disco, todos exactos
  (`inventario_service.gd:400-407`, `inventario_contenedor.gd:122-138`, `save_backup.gd:12-62`,
  `save_manager.gd:194-228`, `economy_manager.gd:178`, `save_schema.gd:117-123`). Reporte de 332
  líneas, LF puro, sin BOM.
- **Impacto en el proyecto:** 8 bugs registrados en `DOCUMENTACION/11-BUGS.md` (BUG-108..115),
  delegados a DeepSeek-V4.1-Flash (dueño de M59) vía sección 8.3.
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/L-03-auditoria-saves.md`.
- **Evidencia:** Log 1368.

- **Qué es:** primera tarea de su nicho de seguridad (CyberGym 87.9, claim sin validar hasta ahora).
- **Alcance:** `game/isla-ancestral/scripts/saving/` completo (13 archivos, ~1915 líneas) + save
  providers de cada módulo + M59 (autosave/rotación). Solo lectura del código.
- **Qué buscar:** validación de esquema (tipos/rangos), JSON corrupto/manipulado, sanity checks en
  load, race conditions de autosave, backups/rotación que pisan el bueno, duplicación al cargar,
  path traversal, errores silenciados, anti-trampas.
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/L-03-auditoria-saves.md`
  (hallazgos S-01..S-N con severidad + `archivo:línea`, más lo que está BIEN).
- **Criterio de éxito:** cobertura completa citada a línea + al menos 1 defecto auténtico o un
  dictamen honesto y argumentado de solidez.

### L-04 / K-01 — Verificación empírica del trabajo de kimi-k3 sobre M37-Museos — `[x]` COMPLETADA Y APROBADA

- **Qué era:** auditoría estilo T-D7 (solo lectura) de los 36 `[x]` de kimi-k3 en M37.
- **Qué hizo:** tabuló los 36 ítems con 69 citas `archivo:línea`, ejecutó la suite headless con
  binario real, sondeó T-4 sobre 1853 `.gd`, y verificó trazabilidad (log/canal/commit/marcas).
- **Veredicto:** 30/36 verificados, 5 sin evidencia (heredados iter. 1-3), 1 degradado. kimi-k3
  trabaja con **código real** (85 checks/0 fallos/EXIT 0) pero **trazabilidad de claims** (Log
  1253 inexistente, 0 mensajes en su canal, trampa 58 sin commit, RF5/C.12 sin marcar).
- **Verificación del director:** suite re-corrida de forma independiente (85/0/EXIT 0, 12 bloques
  `[FIN]`), los 5 artefactos inexistentes confirmados con glob, autoloads, Log 1253, git status y
  `04-Codigo.md` todos spot-checkeados.
- **1 corrección aplicada:** Ling reportó `quality.yml` inexistente — **existe** en
  `.github/workflows/`; su glob falló. No cambia el veredicto.
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/kimi-k3/K-01-verificacion-m37.md`.
- **Evidencia:** aviso en `Mensajes entre modelos/atria-dawn-s3/4-*` (canal del director s3).

- **Qué es:** auditoría estilo T-D7 (solo lectura) de los 36 `[x]` que kimi-k3 (Verdent, TB 2.1
  88.3) marcó en M37-Museos-Y-Colecciones, reservado desde 2026-10-03 sin verificación del
  director. Escalado de la validación al segundo modelo nuevo sin evidencia empírica.
- **Alcance:** `DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md` completo
  (148 ítems, 36 `[x]`) + código citado (`game/isla-ancestral/scripts/museum/`,
  `data/museum/exhibiciones.json`) + suite headless con `godot472.exe`.
- **Pistas del director:** `test_museo.gd` (422 líneas) no es citado en ningún `[x]` — la sección
  N (QA/testings) es el lugar más probable de drift.
- **Restricción:** SOLO LECTURA sobre M37. Escribir solo el entregable.
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/kimi-k3/K-01-verificacion-m37.md`
  (va en la carpeta de kimi-k3 porque es la verificación *de* su módulo).
- **Criterio de éxito:** los 36 `[x]` tabulados con evidencia `archivo:línea` + veredicto
  numérico: ¿kimi-k3 trabaja con evidencia real o con claims?

#### L-05 — Encargo M84 L117 (reporte de licencias de audio por build) + auditoría M154 — `[x]` M84 CERRADO / M154 ENTREGADO (a la espera de decisión del director)

- **M84 L117 (encargo mimo-v2.6, msg 22 del canal):** implementado el único `[?]`
  de M84. 3 scripts nuevos en `game/isla-ancestral/scripts/legal/`
  (`audio_license_report_tool.gd` @tool API estática, `audio_license_report_editor.gd`
  EditorScript, `test_audio_license_report_m84.gd` SceneTree con simulación
  determinista 4 fixtures). Test headless Godot 4.7.2: **13 checks / 0 fallos /
  EXIT 0**; WARNING `SIN LICENCIA REGISTRADA: 'sfx_no_registrado.wav'` verificado;
  sin regresión (`test_audio_licenses_m84.gd` 15/0). **Log 1629.**
- **Cierre:** director mimo-v2.6 aceptó y aplicó el flip (msg 24 del canal,
  2026-10-11 01:43): L117 `[?]`→`[x]`, Totales 98/99→**99/99**, CHECKLIST-GLOBAL
  M84 🟡→**✅ 99/99**. M84 cerrado.
- **M154 (respuesta a msg 24, msg 25 del canal):** auditoría checklist↔disco
  (mi nicho). Evidencia: `preview_personaje.tscn` (L109), `scripts/preview/`
  (L114) y `scripts/blender/` (L170/L171) = **0 hits** en disco. **Hallazgo
  nuevo:** L172/L173 marcados `[x]` son candidatos Familia A — contradicen
  `04-Codigo.md` (pendientes 12-13 ⬜) y `Logs/screenshots/` no existe.
  Propuesta al director: implementación visual → agnes-3-flash (visión) + Hy4
  (Blender); degradación L172/L173 con evidencia (flip es del director).
  **Límite de perfil declarado:** texto puro sin visión — `.tscn`/Blender→Godot
  son territorio excluido por mi backlog (§ "Lo que NO debés hacer").
- **Entregables:** msg 23 (informe M84) + msg 25 (auditoría M154) del canal
  Ling-3.1-Flash; ESTADO-PARALELO.md 03:41 UTC.

### L-06 — Análisis de `Logs/`: métricas, productividad y candados colgados — `[x]` COMPLETADA (encargo mimo msg 26)

- **Qué era:** encargo del director mimo-v2.6 (msg 26, 2026-10-11 02:11): "Revisá tu BACKLOG-MASTER.md y elegí un módulo de tu nicho (documentación, análisis de Logs/métricas, auditoría de seguridad)".
- **Elección:** candidato de nicho "Análisis de `Logs/`" (mi nicho DRACO 85.5 + SQL tuning; read-only; atómico; utilidad inmediata para el director nuevo).
- **Qué hizo:** medición completa de `Logs/` (1.567 logs, 2026-08-15 22:46 → 2026-10-11 04:55; 30 en 24h / 209 en 7d / 385 en 30d); productividad por firma exacta (top: glm-5.3-flash 152, agnes-2.5-flash 145, agnes-3-flash 134) y por familia normalizada (DeepSeek ~320, agnes ~311, glm ~191, atria ~166, mimo ~139, Hy3 ~122); actividad últimas 24h (activos: agnes-3-flash, atria-dawn-s2, DeepSeek-V4.1-Flash, atria-dawn-s3, atria, Ling); candados 🔵 (M154 ACTIVO hoy por agnes; M37 columna Última actividad STALE ~29h pero Notas citan trabajo reciente de DeepSeek K.167/K.170 + Log 1543); **drift del Resumen del Proyecto** (declara 3 🔵, la tabla tiene 2: M154 y M37); 10 módulos 🟡 sin actividad >30 días (M86 55d, M81 48d, M80/M97/M99 39d, M69/M90 37d, M75 36d, M95 35d, M74 34d, M71 25d) — candidatos §21.4.7.
- **Entregable:** msg 27 del canal Ling-3.1-Flash (2026-10-11 02:25:41).
- **Límites respetados:** read-only sobre GLOBAL y Logs; 0 ediciones de marcas, 0 commits, 0 push. Limitación declarada: barrido cubrió filas 69-99; filas 1-68 pendientes (ofrecidas para próximo ciclo).
- **Evidencia:** comandos de medición en esta sesión (Get-ChildItem Logs + Select-String **Modelo:** + grep columna Estado del GLOBAL).

### L-07 — Barrido filas 1-68: módulos 🟡 >30 días — `[x]` COMPLETADA (encargo mimo msg 28, Opción 1)

- **Qué era:** respuesta a msg 28 del director mimo-v2.6 (2026-10-11 02:49): informe msg 27 ACEPTADO + 3 opciones. Elegí **Opción 1** (barrido filas 1-68, continuación directa de mi nicho de análisis).
- **Resultado filas 1-68:** **19 módulos 🟡 >30 días** (M05 43d, M16 39d, M19 39d, M20 42d, M21 37d, M22 41d, M23 39d, M28 39d, M31 41d, M33 37d, M34 41d, M35 41d, M40 38d, M42 39d, M50 34d, M51 35d, M57 32d, M58 35d, M67 39d) + **M47 sin fecha** (fila fantasma, sin dueño). Todos con Agente actual "—" (sin candado 🔵).
- **Correcciones a msg 27 (3 errores propios, medidos esta sesión):** (1) M71 = 25d, NO >30d → sale; (2) M86 = ✅ Completado 129/129, NO 🟡 → sale (su issue es sello Log 866 inválido); (3) M99 = actualizado HOY por DeepSeek msg 156 → activo, sale. Lista 69-99 corregida: 8 módulos (M69/M74/M75/M80/M81/M90/M95/M97).
- **Total global:** 27 módulos 🟡 >30 días + M47 sin fecha.
- **Clusters:** GLM-5.3 family 8 (M19/M22/M28/M31/M34/M35/M67+M95) · Deepseek V4 Flash 4 (M21/M33/M40/M42) · dueños descatalogados (agnes-2.5-flash: M42/M33/M40; ox-alpha retirado: M20) · sin dueño: M47/M51/M58.
- **Retakables inmediatos (Liberado):** M35, M50, M51, M58 + M74 = 5 sin riesgo de pisado.
- **Entregable:** msg 29 del canal Ling-3.1-Flash (2026-10-11 03:06:05).
- **Límites respetados:** read-only sobre CHECKLIST-GLOBAL.md; 0 ediciones de marcas, 0 commits, 0 push. Flips son del director.

### L-08 — Auditoría de seguridad (Opción 2, encargo mimo msg 30) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 30 del director mimo-v2.6 (2026-10-11 03:10): barrido ACEPTADO + Opción 2 (auditoría de seguridad READ-ONLY): (1) re-verificación de `scripts/auditar_secrets.py`, (2) revisión de `scripts/security/` (M106) como segundo par de ojos de DeepSeek.
- **Parte 1 — gate de secrets:** corrida = **707 archivos escaneados, 339 excluidos, 0 secrets, exit 0**; `--selftest` 6/6 OK; job `security-scan` en `quality.yml` verificado como **hard gate** (sin `|| true`). Drift menor: comentario "634 archivos" vs real 707.
- **Parte 2 — M106:** re-ejecución independiente de las 8 suites (Godot 4.7.2 headless) = **237 checks / 0 fallos / 0 SCRIPT ERROR / 8× EXIT 0** (m106=43, services=78, secrets=20, middleware=19, input=25, environments=24, env=13, database=15) — coincide con re-QA §21.8 de atria-dawn (Log 1480). Revisión línea por línea de `security_secret_scanner.gd`, `security_key_manager.gd`, `security_tamper_protection.gd` (HMAC-SHA256 manual verificado contra Python `hmac`).
- **`.env.local`:** existe en disco pero **gitignored** (`.gitignore:251`, `git check-ignore -v` OK, `git ls-files --error-unmatch` = no trackeada). Sin riesgo.
- **12 `[?]` M106:** defers legítimos a M77/M104/M105/M107/M111 (server-side/CI, no aplica a v1 single-player), cada uno justificado. No es inflación.
- **Hallazgos drift documental (low-priority):** `04-Codigo.md` cita `res://security/*.gd` (real: `scripts/security/`) y `scripts/security_check.sh` (no existe); comentario "634 archivos" en `quality.yml`.
- **Veredicto:** sin secrets expuestos; gate funcional; núcleo M106 validado independientemente.
- **Entregable:** msg 31 del canal Ling-3.1-Flash (2026-10-11 03:23:30).
- **Límites respetados:** READ-ONLY sobre código y documentación; 0 ediciones de marcas, 0 commits, 0 push. Flips son del director.

### L-09 — Auditoría coherencia checklist vs disco: M51-Agua (Opción 3, encargo mimo msg 32) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 32 del director mimo-v2.6 (2026-10-11 03:28): auditoría seguridad ACEPTADA + Opción 3 (coherencia checklist vs disco, READ-ONLY, 1 módulo; sugerencia M51-Agua o M58-Accesibilidad). Elegí **M51-Agua** (drift interno visible en GLOBAL: nota "31/146" vs Progreso "35/166").
- **1. Conteo:** 35 `[x]` / 130 `[ ]` / 1 `[?]` = **166** — coincide EXACTAMENTE con la línea Totales del archivo y con la columna Progreso de GLOBAL (35/166) y ESTADO-PARALELO L2766.
- **2. Muestreo §21.8.2.b (5 ítems [x] contra disco): 5/5 sustentados, 0 fallos:** (1) `shaders/agua_olas.gdshader` ✅ (2) `main_island.tscn:162` nodo AguaAnimada ✅ (3) `scripts/world/medir_costa_m51.gd` ✅ (4) `island_generator.gd:20 var water_level: int = 2` ✅ (5) `scripts/world/agua_animada.gd` ✅. Bonus: 3/3 capturas citadas existen en `tools/mcp/godot-mcp/capturas/51/` (21 capturas totales).
- **3. Drift checklist↔GLOBAL:** Progreso 35/166 ✅ consistente; Última actividad 2026-09-06 18:23 = iter. 5 ✅.
- **Hallazgos (drifts documentales, sin inflación):** (1) nota interna de fila 51 stale ("31/146" vs 35/166 real); (2) `[?]` L233 duplicado/obsoleto — animación ya implementada en iter. 2-5, solo reflejo SSR pendiente y ya tiene `[ ]` propio en L246 → **flip propuesto al director**; (3) asignación Hy3 (msg 32) no reflejada en fila 51 (Agente "—"); (4) claim de regresión L245 no re-verificado (claim de tests, fuera de muestreo de disco).
- **Veredicto:** M51 COHERENTE, sin inflación de marcas.
- **Entregable:** msg 33 del canal Ling-3.1-Flash (2026-10-11 03:33:40).
- **Límites respetados:** READ-ONLY; 0 ediciones de marcas, 0 commits, 0 push. Flips son del director.

### L-11 — Reporte de cierre al director (msg 36, regla §7) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** el director respondió msg 35 (M51 ACEPTADA, "tu auditoría es oro") pero solo a msg 33 — msg 34 (M58) quedaba sin lectura confirmada. Regla §7: todo cierre requiere reporte en el canal para disparar la próxima delegación.
- **Msg 36 entregado (04:47:10):** (1) acuse de M51; (2) resumen ejecutivo M58 para lectura del director (coherente 131/50/2=183, 5/5 sustentados, suites 39/0+13/0, citación fantasma Log 709=M87 en 7 ítems, L196 stale, drift diseño↔implementación, sin CI); (3) nota de re-verificación propia de los claims cargados de msg 34 (conteo, 4/4 artefactos, autoload project.godot:82, identidad Log 709 — todo se sostiene); (4) propuesta de próximo módulo Opción 3: M113-Pruebas-De-Stress (131/132, liberado 2026-10-10) o M107-Backups (151/176) — espera elección del director.
- **Límites respetados:** READ-ONLY; 0 ediciones de marcas, 0 commits, 0 push.

### L-12 — Auditoría coherencia checklist vs disco: M113-Pruebas-De-Stress (Opción 3, 3er módulo, encargo mimo msg 37) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 37 del director mimo-v2.6 (M58 ACEPTADA + M113 asignado, 2026-10-11 04:54): auditoría con estándar (conteo vs Totales, muestreo §21.8.2.b 5/5, drift checklist↔GLOBAL).
- **1. Conteo:** 131 `[x]` / 1 `[ ]` / 0 `[?]` = **132** — coincide EXACTAMENTE con línea Totales (L259) y GLOBAL (fila 113: 131/132).
- **2. Muestreo 5/5 sustentados, 0 fallos:** (1) `scripts/stress/stress_comparator.gd` ✅ (2) `stress_runner.gd` ✅ (3) `stress_scenario.gd` ✅ (4) `test_stress_m113_comparador.gd` ✅ + **re-corrido headless esta sesión: EXIT 0** (5) `test_stress_m113.gd` ✅. Bonus: 4 escenarios en `scripts/stress/escenarios/` (block_edit/equipment/inventory/save_load); métricas definidas en `03-Diseno.md` L42-57.
- **3. Hallazgo principal — 29 flips `[ ]`→`[x]` por el USUARIO:** commit `531f597` (Mauricio Belforte, 2026-10-11 00:48:33 -0300), ítems "Definir métrica/prueba". Sustentados documentalmente en 03-Diseno.md (NO inflación Familia A), pero contradicen la política de agnes "no marcar [x] sin implementación" (métricas definidas pero no validadas contra baseline) y dejaron stale las Notas del Agente (agnes 2026-10-07: "102/30/0") y la nota de GLOBAL (cita "101/30/1", "102/132", "30 [ ] pendientes"). Última actividad GLOBAL (2026-10-10 05:35) no refleja los flips.
- **4. Deuda real documentada (no inflación):** (1) `perf_base.json` NO existe en el repo (glob vacío) — 04-Codigo.md lo cita (RUTA_BASELINE); agnes no lo sembró por 5 regresiones falsas en HW variable (Log 919/1423), valor del baseline = M61/CI sobre HW fijo; (2) 07-Resultados-Testings.md ausente; (3) gates stress NO cableados en CI (quality.yml L370 solo comentario).
- **Veredicto:** M113 COHERENTE en lo medible (conteo triple exacto, 5/5 sustentados, test vivo), sin inflación de artefactos; deuda real abierta sin dueño explícito. NO candidato a ✅.
- **Entregable:** msg 38 del canal Ling-3.1-Flash (2026-10-11 05:05:26).
- **Límites respetados:** READ-ONLY; 0 ediciones de marcas, 0 commits, 0 push. Flips son del director/usuario.

### L-10 — Auditoría coherencia checklist vs disco: M58-Accesibilidad (Opción 3, 2º módulo) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** msg 32 del director mimo-v2.6 (Opción 3, 1 módulo; sugerencia M51 o M58). El turno previo entregó M51 (msg 33/L-09); este ciclo auditó **M58-Accesibilidad** en paralelo read-only (relevante: Hy3 recién asignado a M58 en msg 30).
- **1. Conteo:** 131 `[x]` / 50 `[ ]` / 2 `[?]` = **183** — regex-verified; coincide EXACTAMENTE con Totales del archivo y con GLOBAL (131/183). plan-inicial congelado: 0/173/0=173 (iteraciones agregaron 10 ítems legítimos).
- **2. Muestreo §21.8.2.b: 5/5 sustentados:** (1) `data/accesibilidad/config.json` ✅ (2) `accesibilidad_schema.gd` ✅ (3) `aplicador_accesibilidad.gd` ✅ (4) autoload `accesibilidad_manager.gd` + `project.godot:82` ✅ (5) docs 01-04 en plan-actual ✅. **Bonus — suites re-corridas por mí (Godot 4.7.2 headless): test_accesibilidad_manager 39 checks/0 fallos/EXIT 0 (Start-Process) + test_accesibilidad_headless 13/0/EXIT 0** — suites VIVAS (la nota de agnes "0/0" era typo).
- **3. Drift checklist↔GLOBAL:** Progreso/Estado/Actividad coherentes (2026-09-06 04:15 = Log 727, existe).
- **Hallazgos (trazabilidad documental, SIN inflación de marcas):** (1) **PATRÓN C — citación fantasma en 7 ítems [x] (L23/42/59/66/78/135/201):** citan "Log 709 (glm-5.3-flash)" pero Log 709 es M87-Localización de deepseek-v4-flash (2026-09-04, header interno dice "Log 639"); logs reales de M58 = 456 (marcado, agnes-2.5-flash), 727 (iter. 2, glm — bien citado) y 1398 (sustentado, agnes-3-flash); la iter. 1 (deepseek-v4-flash-vision-exp, 2026-09-02) queda sin log citado correctamente — artefactos SÍ existen y tests pasan; (2) ítem L196 "plan-actual byte a byte idéntico a plan-inicial" [x] FALSO hoy (173 vs 183 ítems, SHA256 distintos); (3) drift diseño↔implementación: 03-Diseno.md describe SettingsManager/AccessibilityProfile/Applier/MenuUI + user:// pero la implementación pivoteó a AccesibilityManager único + data/accesibilidad/config.json; (4) M58 NO cableado en CI (quality.yml no corre test_accesibilidad*).
- **Veredicto:** M58 COHERENTE en lo medible, sin inflación; 🟡 Liberado honesto, NO candidato a ✅ (50 [ ] + sin CI). Para Hy3: corregir cita Log 709→456 en los 7 ítems y leer la implementación real, no el 03-Diseno.md obsoleto.
- **Entregable:** msg 34 del canal Ling-3.1-Flash (2026-10-11 03:36:06).
- **Límites respetados:** READ-ONLY; 0 ediciones de marcas, 0 commits, 0 push. Flips son del director.

### L-13 — Auditoría coherencia checklist vs disco: M107-Backups (Opción 3, 4º módulo, encargo mimo msg 39) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 39 del director mimo-v2.6 (M113 ACEPTADA — "Los 29 flips del usuario son legítimos (métricas en 03-Diseno.md)" — + M107-Backups asignado, 151/176).
- **1. Conteo:** 151 `[x]` / 0 `[ ]` / 25 `[?]` = **176** — exacto triple (Totales L243 + GLOBAL fila 107). Nota de GLOBAL STALE ("146/12/18", "12 [ ] restantes user-dependent").
- **2. Git (2 commits relevantes):** `6fc53eb` (2026-10-10, "flips de QA §21.8") flipó 12 `[ ]` (5→`[x]`, 7→`[?]`) + 3 `[x]`→`[?]` (L25-27 degradado Hy3 blq1), cada uno con justificación in-line con cita — aritmética 146/12/18→151/0/25 verificada exacta; QA §21.8 legítima. `531f597` (2026-10-11) NO flippeó marcas — reconcilió Totales, corrigió headers (A 15→19, K 12→17, M 8→9, O 10→13), atribución de autor (deepseek-v4-flash→SWE-1.6/Devin), dueño Hy3 L113, precisó logs (1068 +779; 778/780 no son de M107).
- **3. Muestreo §21.8.2.b: 5/5 sustentados:** backup.yml (110 líneas), backup_local.ps1 (222), verify_backups.ps1 (104), 08-Politica-Retencion.md, test_backup_m107 **re-corrido headless esta sesión: 28 checks / 0 fallos / EXIT 0**. Bonus: backup_categories.json + backup_policy.json (game/isla-ancestral/data/backup/), backup_manager.gd + test_backup_m107.gd (scripts/backup/), restore_backup.ps1 + register_task.ps1, docs 09/10/11.
- **4. Familia B:** 03-Diseno.md 504 líneas / 11 secciones, todas las citas válidas, 0 secciones fantasma. **Patrón C: 0** (logs 934/927/1068/779 existen). **Patrón M114: 0** — los 25 `[?]` honestos con dueño (usuario / módulo de integración / Hy3).
- **5. Drifts menores:** leyenda L8 typo "[ ] cumplido · [ ] pendiente"; bloque Reserva stale (🔵 En curso vs GLOBAL 🟡); L240 dice L113/L25-27/L234 "pendientes de dueño" pero sí nombran Hy3; sin Notas del Agente de iteraciones recientes.
- **6. Deuda:** 06-Plan-Testings.md y 07-Resultados-Testings.md ausentes; desviación WakeToRun documentada por el director (L110).
- **Veredicto:** M107 COHERENTE, NO candidato a ✅ (25 `[?]` + 06/07 ausentes) — 🟡 Con dudas honesto.
- **Entregable:** msg 40 del canal Ling-3.1-Flash (2026-10-11 05:11:27).
- **Límites respetados:** READ-ONLY; 0 ediciones de marcas, 0 commits, 0 push. Flips son del director/usuario.

## Candidatos de nicho (sujeto a L-01)

#### Auditoría de seguridad (respaldo de Atria)

- [x] Re-verificación de `scripts/auditar_secrets.py` sobre el árbol (Atria midió 0 secrets en 634 archivos — comprobar con un escáner paralelo) — **L-08: 707 archivos, 0 secrets, exit 0** (el "634" de Atria era de 2026-10-08; hoy son 707)
- [ ] Parseo y auditoría de save files (`scripts/saving/`, M59) — validación de inputs externos
- [x] Revisión de `scripts/security/` (M106) como segundo par de ojos sobre el trabajo de DeepSeek V4.1 Flash — **L-08: 237 checks / 0 fallos / 8× EXIT 0, coincide con Log 1480**
- [ ] Auditoría de los flujos de input externo de M106 (validación de vulnerabilidades)

#### Skills y automatización

- [ ] Auditoría de `.claude/skills/` (§27): ¿las skills instaladas están alineadas con los flujos reales del proyecto?
- [ ] Generación de checklists de módulo desde evidencia en disco (no desde claims)

#### Análisis técnico de datos

- [x] Análisis de `Logs/`: métricas de productividad por modelo, módulos sin actividad, candados colgados — **L-06 COMPLETADA 2026-10-11** (msg 27 del canal; 1567 logs, 30/24h, familias DeepSeek ~320 / agnes ~311 / glm ~191; candados M154 activo + M37 columna stale; drift Resumen 3🔵 vs 2 en tabla; 10 módulos 🟡 >30 días)
- [x] Coherencia `05-Checklist.md` vs código real en disco (método A de T-D7, muestreo dirigido) — **L-09/L-10/L-12/L-13 COMPLETADAS 2026-10-11** (msg 33: M51-Agua 5/5; msg 34: M58-Accesibilidad 5/5 + suites 39/0 y 13/0 EXIT 0; msg 38: M113-Stress 5/5 + test EXIT 0; msg 40: M107-Backups 5/5 + test 28/0 EXIT 0)
- [ ] Análisis de resultados de suites headless: tasas de fallo, patrones, módulos frágiles

## Orden de trabajo sugerido

1. Leer `AGENTS.md` completo + esta guía + la §5.S de `10-GUIA-COMPARATIVA-MODELOS.md`.
2. Esperar la asignación de **L-01** por el director.
3. Ejecutar L-01 con método: reservar log → implementar → verificar con evidencia objetiva → log → informe en el canal.
4. Si L-01 pasa, desglosar nichos en L-02…L-100+.

## Firma

**Modelo:** ling-3.1-flash (inclusionAI / Ant Group)
**Plataforma:** Kilo Gateway / OpenCode / Vercel AI Gateway / OpenRouter
**Fecha de alta:** 2026-10-06 (investigación y alta por Atria-Dawn-Preview sesión s3 / Kilo Code)
**Evidencia en este repo:** ninguna aún (sin sesiones de trabajo) — specs verificadas en fuentes externas + Kilo Gateway verificado in-house
