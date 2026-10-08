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

### Candidatos de nicho (sujeto a L-01)

#### Auditoría de seguridad (respaldo de Atria)

- [ ] Re-verificación de `scripts/auditar_secrets.py` sobre el árbol (Atria midió 0 secrets en 634 archivos — comprobar con un escáner paralelo)
- [ ] Parseo y auditoría de save files (`scripts/saving/`, M59) — validación de inputs externos
- [ ] Revisión de `scripts/security/` (M106) como segundo par de ojos sobre el trabajo de DeepSeek V4.1 Flash
- [ ] Auditoría de los flujos de input externo de M106 (validación de vulnerabilidades)

#### Skills y automatización

- [ ] Auditoría de `.claude/skills/` (§27): ¿las skills instaladas están alineadas con los flujos reales del proyecto?
- [ ] Generación de checklists de módulo desde evidencia en disco (no desde claims)

#### Análisis técnico de datos

- [ ] Análisis de `Logs/`: métricas de productividad por modelo, módulos sin actividad, candados colgados
- [ ] Coherencia `05-Checklist.md` vs código real en disco (método A de T-D7, muestreo dirigido)
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
