# Log 1362: Alta de Ling 3.1 Flash en el catálogo de modelos (§5.S)

**Fecha:** 2026-10-06
**Hora:** 06:35
**Modelo:** Atria-Dawn-Preview (sesión s3)
**Plataforma:** Kilo Code

## Resumen

Investigación web completa de **Ling 3.1 Flash (inclusionAI / Ant Group)** y su alta en la guía
comparativa de modelos del proyecto (`DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md`, nueva
sección **§5.S**). El modelo supera el criterio de alta de §21 (superar a algún modelo disponible
hoy en una tarea del catálogo) y queda **vigente con tarea de validación L-01 pendiente**.

## Hallazgos clave (specs verificadas en fuentes primarias)

- **560B totales / 25B activos**, MoE con **razonamiento híbrido** (`instant`/`thinking`) —
  API viva de OpenRouter + Kilo Gateway **verificado in-house** (consulta real al gateway del
  agente manager: devolvió el modelo con sus dos variants).
- **Contexto 262.144 tokens** en gateways (Kilo/Vercel/OpenRouter); **1M es design target** de
  InclusionAI y se mide en su API oficial (Artificial Analysis). **Conflicto documentado** —
  se planea sobre 256K.
- **Solo texto** (no multimodal, AA confirma), output máx 32.768, function calling + tool choice
  + JSON mode + reasoning tokens.
- **Weights CERRADOS y licencia no publicada** — hosted-only; rompe la tradición MIT/Apache de
  toda la familia inclusionAI/Ling hasta 3.0. Open-sourcing "prometido tras el trial", sin fecha.
- **Lanzamiento 29/09/2026**; **gratis hasta el 13/10/2026** (Vercel `inclusionai/ling-3.1-flash-free`,
  OpenCode `ling-3.1-flash-free`, OpenRouter, Kilo Gateway). API oficial $0.30/$0.90 por 1M.
  **Precio post-trial NO publicado.**
- **210.7 tok/s**, TTFT 1.80s (Artificial Analysis, API InclusionAI).

### Benchmarks vendor-reported (posts de launch de `@AntLingAGI`, tabulados por BenchLM / Build Fast with AI)

| Benchmark | Score | vs catálogo |
|---|---:|---|
| **CyberGym** | **87.9%** | ✅ **supera a Atria 86.5 (#1 del catálogo)** |
| DRACO (research & analysis) | 85.5% | sin comparable directo |
| **SkillsBench** | **68.7%** | 🟢 **#1 del catálogo** (Qwen 3.8 Max 66.7 · Atria 66.4) |
| HealthBench Professional | 65.3% | dominio médico, sin aplicación |
| Finance Agent v2 | 57.9% | dominio financiero, sin aplicación |
| SWE Atlas Codebase QnA | 55.9% | Muse Spark 90.3 (otro harness) |
| AutomationBench | 52.5% | ❌ Atria 53.8 mantiene el nicho |
| Terminal-Bench 4.0 | 40.4% | **no comparable** con el TB 2.1 del catálogo |
| GDPval-AA v2.1 | 1.673 Elo | ❌ ofimática débil (Opus 5 / GPT 5.6 Sol 1.768) |
| **DeepSWE 1.1** | **NO PUBLICADO** | ⛔ **coding agentic no medible** |

### Validación independiente (Artificial Analysis, Intelligence Index v4.3.2)

- **AA Intelligence Index 41 — #3/176** en su clase (mediana 13). Supera la estimación de
  Agnes 3.0 Flash (36, marcada *estimación*). De los pocos modelos del catálogo con medición
  independiente publicada.
- **Verbosidad 220M tokens** de output en el AA Index (mediana 100M) — 2x la mediana.

### Hands-on independiente (MindStudio, 01/10/2026)

- 🔻 **Pipeline Blender→Godot autónomo: se rompió.** Ejecutó la cadena de tools (~1h) pero la
  escena quedó con objetos desorientados, un trampolín renderizado de lado y sin layout
  coherente. **Exactamente el flujo Hy4 del proyecto** → se declara NO apto para cadenas
  multi-herramienta largas.
- ✅ SQL tuning: aisló el fix único de mayor impacto con dataset sintético, medición before/after
  y ablation. ✅ SVG one-shot. ✅ razonamiento médico estructurado. 🟡 multilingüe flojo en raros.

## Veredicto: ALTA

Supera a modelos disponibles en tareas del catálogo:

1. **CyberGym 87.9 > Atria 86.5** (auditoría de seguridad — nicho #1 de Atria; primer modelo
   del catálogo que lo supera, aunque ambos sean vendor-reported).
2. **SkillsBench 68.7 = #1** (Atria 66.4, Qwen 3.8 Max 66.7).
3. **AA Index 41 validado de forma independiente** > Agnes 3.0 Flash 36 (estimación).
4. **Gratis y verificado YA en el Kilo Gateway** — la flota puede usarlo sin costo durante el
   trial (directriz del proyecto: explotar capacidades mientras duren los accesos gratuitos).

**Entra con L-01 pendiente de validación** (mismo patrón que SB-01 de Space Bunny Alpha y
G-01/G-02 de Gemini 3.8 Flash): sin asignaciones críticas hasta evidencia propia en el repo.

## Cambios Realizados

1. **`DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md`**:
   - Nueva sección **§5.S** completa (ficha con specs verificadas, tablas de benchmarks
     vendor + independiente, hands-on, nicho, debilidades honestas, regla de asignación,
     cómo conectarlo).
   - **Matriz Comparativa Real**: nueva fila de Ling 3.1 Flash.
   - **Capacidades por Tipo de Trabajo**: actualizada la fila de auditoría de seguridad (nota
     de respaldo pendiente) + 3 filas nuevas (skills, sub-agente agentic, análisis técnico).
   - **Flujo de Delegación Recomendado**: nuevo ítem 15.
   - **Reglas de Asignación**: nuevo bullet completo con cuándo usar / cuándo no / método.
   - **Header**: firma de la sesión s3 + nota de última modificación + entrada de "Última
     confirmación por el agente" + mención del modelo en el párrafo introductorio.
   - **Integridad verificada**: UTF-8 sin BOM, 0 mojibake, 0 NUL, EOL preservados.
2. **`DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md`** (nuevo): backlog del
   modelo con identidad, specs, benchmarks, reglas del protocolo, nicho, límites honestos,
   método de trabajo y candidatos de tareas L-02… en sus 4 nichos. **Sin tareas asignadas** —
   L-01 pendiente de definición por el director.
3. **`Logs/NUMEROS_DISPONIBLES.txt`**: número **1513** reservado y consumido (cabeza del pool).

## Archivos Modificados/Creados

- `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` (editado — §5.S + 5 puntos de actualización)
- `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md` (creado)
- `Logs/NUMEROS_DISPONIBLES.txt` (número reservado)
- `Logs/1513-ALTA-LING-3.1-FLASH-CATALOGO_2026-10-06_06-35.md` (este log)

## Fuentes consultadas (todas primarias o agregadores citados)

- API de OpenRouter (`/api/v1/models`) — modelo vivo, 560B/25B, 262K, $0/$0
- Kilo Gateway (consulta in-house vía agent manager) — **disponibilidad + variants
  `instant`/`thinking` verificadas**
- models.dev/models/inclusionai/ling-3.1-flash — release 2026-09-29, output 32K, weights closed,
  6 providers, precios
- artificialanalysis.ai/models/ling-3-1-flash (+ /providers) — AA Index 41 #3/176, 210.7 tok/s,
  TTFT 1.80s, contexto 1M API oficial, texto puro, propietario, $0.30/$0.90
- BenchLM / Build Fast with AI (benchmarks del launch, trazados a posts de `@AntLingAGI`)
- MindStudio (hands-on independiente 01/10/2026 — Blender→Godot, SQL, SVG, médico, multilingüe)
- aitoolsreview.co.uk (review crítica: free hasta 13/10/2026, post-trial no publicado,
  ausencia de system card)
- Vercel changelog (30/09/2026) — model IDs y free period
- huggingface.co/inclusionAI + api.github.com/orgs/inclusionAI/repos — confirmación de weights
  cerrados (sin repo ni model card pública de Ling-3.1; toda la familia hasta 3.0 sí publicada)

## Notas

- **No se asignó ningún módulo.** Soy la sesión s3 de coordinación; el director (s2) define L-01.
  Queda pendiente avisar al canal `atria-dawn-s2` con el helper `reservar_mensaje.py`.
- **Sin push** (regla del proyecto). Sin commits — el usuario no lo solicitó.
- **Paralelismo:** no se tocó ningún archivo en curso por otros agentes (CHECKLIST-GLOBAL,
  ESTADO-PARALELO, módulos 🔵/🔴 intactos).
