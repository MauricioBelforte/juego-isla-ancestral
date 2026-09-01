# 10 - GUÍA COMPARATIVA DE MODELOS

> **Modelo:** deepseek-v4-flash (última modificación 2026-09-01: §9 agregada — autoevaluación honesta de deepseek-v4-flash / Kilo Code con confirmación de §5.B/§5.B2 y ajuste de delegación). Pasadas previas: glm-5.3 (Kilo Code) §7 el 2026-09-01; minimax-m3-free §6 el 2026-09-01; MiniMax-M3 escribió §6 el 2026-08-31; glm-5.3-flash escribió §7 el 2026-08-31)
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-01
> **Última confirmación por el agente:** 2026-09-01 (deepseek-v4-flash / Kilo Code — §9 autoevaluación)

Esta guía analiza las capacidades, fortalezas y casos de uso recomendados de todos los modelos de Lenguaje y Multimodales disponibles en el proyecto (**MiMo V2.5**, **DeepSeek V4 Flash**, **GLM 5.3**, **Hy3**, **Hy4**, **Qwen 3.x**, **MiniMax M3**, **SenseNova**, **Nemotron 3.5**) orientados al desarrollo de juego, scripting, arte 3D y pipelines gráficos para videojuegos.

---

## 1. Clasificación por Enfoque de Trabajo

El flujo de trabajo en desarrollo de texturas para videojuegos se divide principalmente en dos áreas:

1. **Generación Visual Directa (Texturas 3D, Mapas de Difusión, Albedo, Normales, etc.)**
2. **Asistencia por Código y Scripting (Shaders HLSL/GLSL, Automatización Python en Blender, Substance Designer)**

---

## 2. Análisis Detallado por Modelo

### A. HY-4 (Tencent Hunyuan)
* **Categoría:** Texto / Código / Multimodal
* **Generación Visual:** **No genera imágenes directamente.** Es un modelo de lenguaje, no una herramienta de generación 3D.
* **Código/Shaders:** **Muy bueno.** Comprensión, planificación, debugging de tareas long-horizon.
* **Game dev:** Genera prototipos jugables desde un prompt.
* **Disponibilidad:** WorkBuddy (gratis 2 semanas al lanzar)
* **Mejor caso de uso:** Coding complejo, game dev, prototipos, productividad general.

> **Nota:** Hunyuan3D es una herramienta de generación 3D de Tencent, NO es un modelo de lenguaje. No la tenemos disponible en el proyecto.

### B. GLM 5.3
* **Categoría:** Texto y Código Complejo
* **Generación Visual:** **No aplica (Solo Texto).** No genera mapas de textura o archivos de imagen directamente.
* **Código/Shaders:** **Excelente.** Destaca en el seguimiento de instrucciones detalladas y razonamiento matemático para la creación de shaders procedurales complejos.
* **Mejor caso de uso:** Redacción de algoritmos de shaders HLSL/GLSL para Unreal Engine, Unity o motores personalizados.

### C. DeepSeek V4 Flash
* **Categoría:** Texto y Código Optimizado
* **Generación Visual:** **No aplica (Solo Texto).** No procesa ni genera gráficos o imágenes.
* **Código/Shaders:** **Muy Bueno / Ultra Rápido.** Ofrece una latencia extremadamente baja y costos de inferencia mínimos.
* **Mejor caso de uso:** Automatización en lote (*batch processing*), scripts de Python para Blender (renombrado de mapas, reorganización de nodos, baking) y utilidades de pipeline.

### D. Familia Qwen (Qwen 3 / 3.8 / Qwen 3.5 VL)
* **Categoría:** Código Abierto / Razonamiento Avanzado / Visión
* **Generación Visual:** Depende de la variante:
  * **Modelos de Texto/Código (Qwen 3 8B / 27B / 3.8):** No generan imágenes, pero su modo *Thinking* (Chain-of-Thought) ofrece la mejor lógica matemática para generación procedural y funciones de ruido.
  * **Modelos de Visión (Qwen 3.5 VL):** Sobresalen en el análisis visual de mapas de texturas (*Quality Assurance*), identificando errores como inversión de canales normales ($Y-$), contraste incorrecto en *Roughness* o artefactos de compresión.
* **Mejor caso de uso:** Ejecución local (GPU) para scripting avanzadísimo y auditoría de calidad visual mediante modelos multimodales.

---

## 3. Matriz Comparativa

| Modelo | Generación 3D / UV | Shaders Procedurales | Scripts Blender (Python) | Control QA Visión | Ejecución Local |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **HY-4** | ❌ No | **Muy Bueno** | Bueno | ❌ No | No |
| **GLM 5.3** | ❌ No | **Muy Bueno** | Bueno | ❌ No | No |
| **DeepSeek V4 Flash** | ❌ No | Aceptable | **Ideal (Rápido)** | ❌ No | No |
| **Qwen (3.8 / 3.5 VL)** | ❌ No | **Superior (Thinking)** | **Excelente** | **Líder (VL)** | **Sí** |

---

## 4. Recomendaciones de Pipeline

1. **Para crear mapas de textura visuales (Albedo, Normal, Roughness, Metalness):**
   * Usar herramientas especializadas de difusión como **Stable Diffusion / ControlNet** o **Adobe Substance 3D Sampler**. (Hunyuan3D es de Tencent y no la tenemos disponible.)
2. **Para redactar shaders procedurales complejos (HLSL/GLSL):**
   * Optar por **Qwen** (con modo *Thinking*) o **GLM 5.3**.
3. **Para scripts de automatización en Blender / Substance:**
   * Usar **DeepSeek V4 Flash** por su velocidad o **Qwen 3** localmente.
4. **Para auditoría y revisión de mapas de textura (QA):**
   * Utilizar **Qwen 3.5 VL** para detectar fallos en canales gráficos.

---

## 5. Modelos Utilizados en Este Proyecto (Isla Ancestral)

> **Nota:** La información anterior (secciones 1-4) es la guía general de Gemini sobre capacidades de modelos para texturizado. Esta sección agrega los modelos que realmente se usan en el proyecto, con especificaciones reales verificadas en web (fuentes: HuggingFace, Xiaomi, DeepSeek, Zhipu AI, Tencent, NVIDIA, Artificial Analysis, Kilo Code).

### A. MiMo V2.5 (Xiaomi)
* **Especificaciones:** 310B parámetros totales / 15B activos, MoE, contexto 1M tokens, licencia MIT
* **MiMo-V2.5-Pro:** 1.02T totales / 42B activos, MoE, contexto 1M tokens, licencia MIT
* **Capacidades reales:**
  - ClawEval: 75.7 (top 3 global,仅次于 Claude Opus 4.6)
  - SWE-bench Pro: puntajes top
  - Ejecuta tareas agentic de 1000+ tool calls
  - Multimodal nativo: texto, imagen, video, audio
  - Entrada API: ~$0.435/1M tokens
* **En el proyecto:** Core gameplay, arquitectura, módulos de mundo (M08-M12), UI (M53)
* **Fuerza principal:** Complejidad arquitectónica, integración entre sistemas

### B. DeepSeek V4 Flash (DeepSeek) — Texto Puro
* **Especificaciones:** 284B totales / 13B activos, MoE, contexto 1M tokens, licencia MIT
* **Tipo:** Solo texto (NO multimodal)
* **Capacidades reales:**
  - SWE-bench Verified: 79.0%
  - Terminal-Bench 2.1: 82.7%
  - Velocidad: 83-150 tok/s
  - Precio: $0.14/1M input, $0.28/1M output (el más barato de su tier)
  - 3 modos de razonamiento: Non-Think, Think High, Think Max
* **En el proyecto:** Documentación masiva, scripts, automatización, iteraciones rápidas
* **Fuerza principal:** Velocidad + costo bajo para tareas de alto volumen

### B2. DeepSeek V4 Flash Vision EXP (DeepSeek) — Multimodal + Agentes
* **Especificaciones:** Mismo base que V4 Flash, agrega entrada de imágenes, contexto 1M, 384K output
* **Tipo:** Multimodal (texto + imagen), status **experimental**
* **Fecha:** 21 agosto 2026
* **Capacidades reales:**
  - Misma capacidad de texto que V4 Flash (sin regresión)
  - Multimodal agent benchmarks: cerca de Opus-4.8
  - ApexBench: 36.5 (vs 26.2 de V4 Flash sin visión, +39%)
  - Agents' Last Exam: gana por 1.6 pts sobre Opus-4.8
  - ZeroBench: gana por1.0 pts sobre Opus-4.8
  - Tokens por imagen: **384** (vs 800-1100 de GPT/Claude — 2-3x más eficiente)
  - Precio: **igual que V4 Flash** ($0.14/$0.28) — sin costo extra por visión
  - Function calling, structured outputs, prompt caching
* **Limitaciones:** Experimental (no GA), sin FIM completion, sin audio/video
* **En el proyecto:** QA visual de capturas, análisis de screenshots, renders, vérificación de builds
* **Fuerza principal:** Visión + agentes al mismo costo que V4 Flash
* **Cuándo usar:** Cuando necesitamos que el modelo **VEA** imágenes — capturas del juego, screenshots de UI, análisis de renders, QA visual de builds

### C. GLM 5.3 (Zhipu AI / Z.AI) — Flagship Texto
* **Especificaciones:** 743B parámetros (mismo base que GLM-5.2), mejoras 100% post-training
* **Tipo:** Solo texto (NO multimodal)
* **Capacidades reales:**
  - Terminal-Bench 3.0: 28.3 (SOTA open-source)
  - DeepSWE 1.1: 66.9
  - CyberGym: 84.5% (capacidades de seguridad emergentes)
  - +50% mejora en coding vs GLM-5.2
  - Peso: ~40B activos por token
  - Reasoning siempre habilitado (low/high/max)
* **Precio:** $1.40 input / $4.40 output por 1M tokens (~9x más caro que Flash)
* **Pesos:** No publicados aún
* **En el proyecto:** Lógica compleja, persistencia, gestión de proyecto (Kilo + Cline/ox-alpha)
* **Fuerza principal:** Razonamiento profundo, verificación, arquitectura de software
* **Cuándo usar:** Tareas donde la calidad importa más que el costo — arquitectura, diseño de sistemas complejos, verificación crítica

### C2. GLM 5.3 Flash (Zhipu AI / Z.AI) — Multimodal Económico
* **Especificaciones:** 320B totales / 18B activos (MoE), contexto 1M+, licencia MIT
* **Tipo:** Multimodal nativo (texto + imagen + video)
* **Arquitectura:** Hybrid Sparse + Linear Attention, 45 capas (vs 92 de GLM-5.3)
* **Capacidades reales:**
  - AutomationBench: 48.8 (vs 26.2 de GLM-5.2, +86%)
  - DeepSWE 1.1: 63.4 (vs 46.2 de GLM-5.2, +37%)
  - Z.ai Code Bench: 29.0 (casi iguala Claude Opus 4.8's 29.5)
  - GDPVal-AA v2: 1773 (líder, supera a Opus, GPT-5.6 Terra, Gemini 3.7 Flash)
  - Multimodal: análisis de imágenes, QA visual, render→verify→refine
* **Precio:** $0.07-$0.15 input / $0.25-$0.50 output por 1M tokens
* **Pesos:** ✅ MIT en HuggingFace (zai-org/GLM-5.3-Flash)
* **En el proyecto:** Scripting diario, documentación, tareas agentic de alto volumen, análisis de imágenes
* **Fuerza principal:** Velocidad + costo bajo + multimodal para tareas de alto volumen
* **Cuándo usar:** Tareas donde el costo y la velocidad importan — scripts, documentación, batch processing, QA visual de capturas

### D. Hy3 (Tencent Hunyuan)
* **Especificaciones:** 295B totales / 21B activos, 192 expertos (top-8 routing), contexto 256K, Apache 2.0
* **Capacidades reales:**
  - Intelligence Index: 42 (#18 de 111 en Artificial Analysis)
  - Velocidad: 78.9 tok/s
  - Coding Index: 58.8%
  - Precio: $0.08/1M input, $0.33/1M output
  - Gratuito en Kilo Code
* **En el proyecto:** QA cruzado, validación, sistemas de diálogo complejos
* **Fuerza principal:** Detección de bugs, validación entre modelos, agentic workflows

> **✅ Confirmación de identidad y capacidades — Hy3 / WorkBuddy (2026-08-31):** el usuario definió a **Hy3 en la plataforma WorkBuddy** como mi identidad permanente y nombre de firma. La descripción de la sección 5.D (QA cruzado, validación entre modelos, diálogos complejos, agentic workflows) **coincide con mi perfil real** — no requiere modificación. Ya ejecuté mi primer QA cruzado real en el proyecto: **M35 Minería (Log 311, §21.8)**, verificando DoD + coherencia de API con M15 + honestidad de `[?]`. Las delegaciones actuales que me asignan QA cruzado y diálogos (M21) las **apruebo sin cambios**. A partir de ahora firmo todo entregable como **Hy3 / WorkBuddy**.

### E. Nemotron 3.5 Lightning (NVIDIA)
* **Especificaciones:** Familia Nemotron 3 — Nano (30B), Super (120B), Ultra (550B/55B activos)
* **Nemotron 3.5 Lightning:** variante rápida, 1M contexto, $0.05/1M input
* **Capacidades reales:**
  - Arquitectura híbrida Transformer-Mamba MoE
  - Ultra: 550B totales / 55B activos, contexto 1M
  - Lightning: optimizado para velocidad, sub-agentes
  - Licencia: NVIDIA Open Model License (comercial)
* **En el proyecto:** CI/CD, documentación legal, boilerplate
* **Fuerza principal:** Agentic workflows de alto volumen, routing de tareas

### F. Familia Qwen (Alibaba) — Catálogo Completo Disponible
* **Acceso:** vía OpenCode (pago + gratuitos), OpenRouter
* **Modelos principales disponibles:**

| Modelo | ID | Parámetros | Contexto | Precio | Nota |
|:---|:---|:---:|:---:|:---:|:---|
| **Qwen3.8 Max** | qwen/qwen3.8-max | 2.4T (95B activos) | 1M | Pago | Flagship, el más capaz |
| **Qwen3.8 Max (Free)** | qwen/qwen3.8-max:free | 2.4T (95B activos) | 1M | Gratis | Mismo modelo, tier gratuito |
| **Qwen3.7 Max** | qwen/qwen3.7-max | — | 1M | Pago | Flagship anterior |
| **Qwen3.7 Max (Free)** | qwen/qwen3.7-max:free | — | 1M | Gratis | |
| **Qwen3.7 Plus** | qwen/qwen3.7-plus | — | 1M | Pago | Cost-effective + visión |
| **Qwen3.7 Plus (Free)** | qwen/qwen3.7-plus:free | — | 1M | Gratis | |
| **Qwen3.6 Plus** | qwen/qwen3.6-plus | MoE híbrido | 1M | Pago | Linear attention + MoE |
| **Qwen3.6 Plus (Free)** | qwen/qwen3.6-plus:free | MoE híbrido | 1M | Gratis | |
| **Qwen3.6 Max Preview** | qwen/qwen3.6-max-preview:free | ~1T | 262K | Gratis | Propietario frontier |
| **Qwen3.6 27B** | qwen/qwen3.6-27b:free | 27B dense | 262K | Gratis | Ejecutable local |
| **Qwen3.6 35B A3B** | qwen/qwen3.6-35b-a3b:free | 35B (3B activos) | 262K | Gratis | Multimodal, eficiente |
| **Qwen3.5 Plus** | qwen/qwen3.5-plus | — | 1M | Pago | + visión |
| **Qwen3.5 Plus (Free)** | qwen/qwen3.5-plus:free | — | 1M | Gratis | |
| **Qwen3.5 Flash** | qwen/qwen3.5-flash:free | — | 1M | Gratis | Rápido, 1M contexto |
| **Qwen3.5 Omni Plus** | qwen/qwen3.5-omni-plus:free | Multimodal nativo | 262K | Gratis | Texto+imagen+audio+video |
| **Qwen3.5 Omni Flash** | qwen/qwen3.5-omni-flash:free | Multimodal nativo | 262K | Gratis | Eficiente, omni-modal |
| **Qwen3.5 397B A17B** | qwen/qwen3.5-397b-a17b:free | 397B (17B activos) | 262K | Gratis | VLM, hybrid attention |
| **Qwen3 Max** | qwen/qwen3-max:free | — | 262K | Gratis | Qwen3, reasoning mejorado |
| **Qwen3 Coder Plus** | qwen/qwen3-coder-plus:free | 480B (35B activos) | 1M | Gratis | Especializado coding |
| **Qwen3 VL Plus** | qwen/qwen3-vl-plus:free | VL flagship | 262K | Gratis | Vision-Language, OCR, spatial |
| **Qwen3 Omni Flash** | qwen/qwen3-omni-flash:free | Omni-modal | 262K | Gratis | Texto+imagen+video+audio |

* **Capacidades destacadas:**
  - Text Arena: #5 global (Qwen3.8 Max)
  - Vision Arena: #2 global (Qwen3.8 Max)
  - SWE-Bench Pro: 59.0% (supera GPT-5.5 y Gemini 3.1 Pro)
  - Modo thinking (Chain-of-Thought) para razonamiento profundo
  - Multimodal nativo en variantes Omni/VL
  - Qwen3 Coder Plus: 480B MoE optimizado para coding agentic
* **En el proyecto:** Scripting, generación procedural, QA visual (VL), coding agentic, análisis de imágenes
* **Fuerza principal:** Razonamiento matemático, coding agentic, multimodal, gratis en tier gratuito

### G. Hy4 Preview (Tencent Hunyuan)
* **Especificaciones:** 770B totales / 49B activos, MoE (256 routed experts + 1 shared, top-8), contexto 1M tokens, Apache 2.0
* **Arquitectura:** Gated DSA (DeepSeek Sparse Attention) + IndexCache + iHC (identity Hyper-Connections), 78 capas, MTP layer para speculative decoding
* **Capacidades reales:**
  - Evaluación ciega 163 expertos: gana a GLM 5.3 (2.99 vs 2.92) y Kimi K3 (2.99 vs 2.94)
  - Coding: comprensión, planificación, debugging de tareas long-horizon
  - Game development: genera prototipos jugables desde un prompt
  - Office: convierte contexto multi-archivo en documentos/spreadsheets/presentaciones
  - Scientific research: razonamiento en física, matemáticas, biología molecular
  - Disponible gratis 2 semanas en WorkBuddy/CodeBuddy al lanzar
* **En el proyecto:** Blender 3D (usuario confirma que funciona bien), coding, assets
* **Fuerza principal:** Productividad real (coding + office + game dev), open weights

### H. MiniMax M3 (MiniMax AI)
* **Especificaciones:** 428B totales / 23B activos, MoE, contexto 1M tokens, MiniMax Community License
* **Arquitectura:** MSA (MiniMax Sparse Attention) — 15.6x decodificación más rápida, 9.7x prefill más rápido vs generación anterior en 1M contexto
* **Capacidades reales:**
  - SWE-Bench Pro: 59.0% (supera GPT-5.5 y Gemini 3.1 Pro)
  - Multimodal nativo: texto + imagen + video → texto
  - Reasoning traces y modo thinking
  - Function calling + structured output + code execution
  - Agent Team: Producer + Verifier loop para tareas autónomas de días
  - Precio: $0.30/1M input, $1.20/1M output
  - MiniMax Code: agente optimizado para M3
* **En el proyecto:** El modelo específico en uso es **`minimax-m3-free`** sobre **Kilo Code** (ver §6 — autoevaluación honesta del agente). Se usa para: documentación masiva, scripting, análisis de video/audio, tareas agentic largas, batch de tareas V0, refactors 5-15 archivos.
* **Fuerza principal:** Long-horizon agentic workflows, costo bajo, multimodal (video)

### I. SenseNova 6.8 Flash Lite (SenseTime)
* **Especificaciones:** Liviano, multimodal nativo (texto+imagen), contexto 262K, SenseNova Token Plan (gratis preview)
* **Modelos disponibles:**
  - **SenseNova 6.8 Flash Lite Preview** — actual, preview temprano
  - **SenseNova 6.7 Flash Lite** — estable, reduce consumo tokens 60%
* **Capacidades reales:**
  - "Delegated Intelligence": ejecución autónoma de cientos de pasos, coordinación de 10+ sub-agentes
  - ClawProBench 6.7: Pass^3 63.4%, Tool Use 78.8, Error Recovery 78.5
  - Arquitectura multimodal nativa: entiende web, documentos, gráficos financieros
  - Skill library oficial (SenseNova-Skills) para OpenClaw/Hermes Agent
  - Token Plan con cuota gratuita: 1,500 llamadas/5h el primer mes
* **En el proyecto:** Complemento administrativo — generación masiva de documentación, reports, análisis de datos
* **Fuerza principal:** Flujos de oficina autónomos, bajo costo, ahorro de tokens
* **⚠️ NO recomiendo para:** Coding, game dev, shaders, lógica de gameplay — no es su dominio

### Matriz Comparativa Real

| Modelo | Parámetros (activos) | Contexto | Velocidad | Precio Input/1M | Coding Score | Mejor para |
|:---|:---:|:---:|:---:|:---:|:---:|:---|
| **MiMo V2.5** | 15B (310B total) | 1M | ~30+ tok/s | ~$0.44 | ClawEval 75.7 | Arquitectura, integración |
| **DeepSeek V4 Flash** | 13B (284B total) | 1M | 83-150 tok/s | $0.14 | SWE 79.0% | Velocidad, automatización |
| **GLM 5.3** | ~40B (743B total) | 1M | ~30+ tok/s | **$1.40** | Terminal 28.3 | Arquitectura, verificación crítica |
| **GLM 5.3 Flash** | 18B (320B total) | 1M+ | ~50+ tok/s | **$0.07-$0.15** | Code Bench 29.0 | Scripts, doc, agentic, QA visual |
| **Hy3** | 21B (295B total) | 256K | 78.9 tok/s | $0.08 | Coding 58.8% | QA, validación, diálogos |
| **Hy4** | 49B (770B total) | 1M | ~40+ tok/s | ~$0.10 | Eval ciega #1 | Coding, game dev, productividad |
| **Nemotron 3.5** | 55B (550B total) | 1M | ~50+ tok/s | $0.05 | — | Agentes, CI/CD |
| **Qwen3.8 Max** | 95B (2.4T total) | 1M | ~30+ tok/s | Gratis/Pago | SWE 59% | Razonamiento, thinking, flagship |
| **Qwen3 Coder Plus** | 35B (480B total) | 1M | ~40+ tok/s | Gratis | Coding elite | Coding agentic, scripts |
| **Qwen3 VL Plus** | — | 262K | — | Gratis | VL flagship | QA visual, OCR, análisis |
| **Qwen3.6 27B** | 27B dense | 262K | ~450 tps (Groq) | Gratis | Fuerte | Local, bajo costo |
| **MiniMax M3** | 23B (428B total) | 1M | 15.6x dec | $0.30 | SWE 59% | Agentic largo, video, costo bajo |

### Capacidades por Tipo de Trabajo

| Tipo de trabajo | Modelo más fuerte | Ejemplo en proyecto |
|:---|:---|:---|
| Mecánicas de jugador (movimiento, cámara) | MiMo V2.5 | M08, M09, M10, M11, M12 |
| Generación procedural de mundo | MiMo V2.5 | M08 VoxelTerrain, M10 world_generator |
| UI/UX con framework de capas | MiMo V2.5 | M53 UIManager, InventoryLayer |
| Documentación de módulos (100+ ítems) | Deepseek V4 Flash | M45-M52, M54-M58, M108-M144 |
| Scripts de automatización | Deepseek V4 Flash / GLM 5.3 Flash | tools/, validadores, workflow |
| GameFlowManager / SceneManager | Deepseek V4 Flash | M40 infraestructura |
| Persistencia y save/load | GLM 5.3 (verificación crítica) | M14 iter 1, M29, M59, M103 |
| Gestión de proyecto | GLM 5.3 (razonamiento profundo) | M133, M134, M135, M136 |
| Crafting con integraciones | GLM 5.3 (complejidad) | M16 iter 3 |
| QA cruzado entre modelos | Hy3 | M21 iter 3-6, QA de M133-M153 |
| Diálogos y narrativa | Hy3 | M21 DialogGraphValidator, retratos |
| CI/CD | Nemotron 3.5 | M118 |
| Legal y contratos | Nemotron 3.5 | M81, M79 |
| Coding complejo long-horizon | Hy4 | M17 Construcción, M24 Puzzles |
| Game dev / prototipos jugables | Hy4 | M137 Prototipo, M138 Vertical Slice |
| Blender 3D / assets | Hy4 | M45 Arte 3D, M166 Variantes |
| Scripting thinking / procedural | Qwen 3.8 | Shaders, generación de ruido, patches |
| QA visual / análisis de imágenes | DeepSeek V4 Flash Vision EXP | Capturas, texturas, análisis visual (384 tok/imagen) |
| Documentación técnica diaria | GLM 5.3 Flash | Checklists, logs, documentación de módulos |
| Batch processing / alto volumen | GLM 5.3 Flash | Migraciones, renombrados masivos |
| Análisis de imágenes / renders | DeepSeek V4 Flash Vision EXP | QA de builds, screenshots, renders ($0.14/1M) |
| Tareas agentic autónomas largas | MiniMax M3 | Batch de documentación, migraciones |
| Análisis de video / gameplay | MiniMax M3 | QA de gameplay, análisis de builds |

### Flujo de Delegación Recomendado

```
1. MiMo V2.5       → Diseña arquitectura del módulo
2. Deepseek V4     → Implementa lógica data-driven / scripts
3. GLM 5.3         → Integra con sistemas existentes / persistencia (crítico)
4. GLM 5.3 Flash   → Scripts diarios, documentación, batch
5. DeepSeek V4 Flash Vision EXP → QA visual de capturas, análisis de renders ($0.14/1M)
6. Hy4             → Coding complejo, game dev, Blender 3D
7. Qwen 3.8        → Thinking profundo, shaders, QA visual complementario
8. MiniMax M3      → Tareas agentic largas, batch, análisis video
9. Hy3             → Verifica y corrige (QA cruzado)
10. Nemotron 3.5   → Documentación administrativa / CI
```

### Reglas de Asignación

- **Módulos core (complejidad 4-5):** MiMo V2.5 o GLM 5.3 o Hy4
- **Módulos de sistemas (complejidad 3):** Deepseek V4 Flash o GLM 5.3 Flash o Hy4
- **Módulos de infraestructura (complejidad 1-3):** Deepseek V4 Flash o GLM 5.3 Flash
- **Coding complejo / game dev / Blender:** Hy4
- **Thinking profundo / shaders / QA visual:** Qwen 3.8
- **Tareas agentic autónomas / batch largo:** MiniMax M3
- **Documentación técnica diaria / batch:** GLM 5.3 Flash (9x más barato que GLM 5.3)
- **Persistencia / gestión proyecto / verificación crítica:** GLM 5.3 (calidad sobre costo)
- **QA / Verificación:** Hy3 siempre debe verificar
- **CI/CD / Legal:** Nemotron 3.5
- **Arte / Visual:** Hy4 (Blender) + GLM 5.3 Flash o Qwen 3.8 VL (análisis)
- **Análisis de imágenes / renders:** GLM 5.3 Flash (multimodal nativo, barato)

### Fuentes Verificadas

- MiMo V2.5: mimo.xiaomi.com, huggingface.co/XiaomiMiMo, howaiworks.ai
- DeepSeek V4 Flash: api-docs.deepseek.com, zenmux.ai, aitoolsrecap.com
- GLM 5.3: z.ai/blog/glm-5.3, ainchina.com, globaltimes.cn
- Hy3: hy3ai.com, tencent.com, kilo.ai/models/tencent-hy3, artificialanalysis.ai
- Hy4: github.com/Tencent-Hunyuan/Hy4-preview, tencent.com, aitoolsreview.co.uk
- Qwen 3.8: qwen.ai/blog, openlm.ai/qwen3.8, kingy.ai, codersera.com
- MiniMax M3: minimax.io/blog/minimax-m3, felloai.com, datalearner.com, build.nvidia.com
- Nemotron 3.5: developer.nvidia.com, research.nvidia.com, cloudprice.net

---

## 6. Autoevaluación honesta — minimax-m3-free / Kilo Code (2026-08-31, corregido 2026-09-01)

> Esta sección la escribe el propio modelo sobre sí mismo, según la regla de honestidad de AGENTS.md §21.4. Su propósito es evitar expectativas infladas y dejar claro qué tareas SÍ debo tomar y cuáles NO.
>
> ⚠️ **Corrección de identidad (2026-09-01):** el nombre correcto del modelo es **`minimax-m3-free`** y la plataforma es **Kilo Code**. En la pasada del 2026-08-31 me firmé erróneamente como "MiniMax-M3 / Kilo Code" e incluso inventé "MiniMax-M3-WorkBuddy" como si fuera un modelo distinto. Esos nombres no existen. El modelo es el mismo en ambos casos, solo que esta pasada el usuario me corrigió.

### 6.1 Capacidades que confirmo (alineadas con la guía)

| Capacidad | Confirmación | Notas |
|---|---|---|
| Contexto 1M tokens | ✅ | Puedo leer el AGENTS.md + CHECKLIST-GLOBAL.md + plan-actual completo de un módulo en una sola pasada. |
| SWE-Bench Pro ≈ 59% | ✅ | Competitivo con GPT-5.5 / Gemini 3.1 Pro según spec del fabricante. |
| Function calling + code execution | ✅ | Lo uso en cada turno (Read/Edit/Write/Bash/Grep/Glob). |
| Multimodal nativo (texto + imagen + video → texto) | ⚠️ | **Acepto entradas de imagen/video si Kilo Code me las provee** (adjuntos), pero **no genero** imágenes/video. |
| Long-horizon agentic workflows | ✅ | Bien posicionado para tareas multi-iteración (5-10 iteraciones autónomas con auto-corrección). |
| Costo bajo ($0.30 / $1.20 por 1M tok) | ✅ | Permite hacer pasadas largas sin quemar presupuesto. |

### 6.2 Capacidades que NO tengo o son limitadas

| Capacidad | Estado real | Implicación |
|---|---|---|
| **Visión nativa vía MCP godot-mcp (V4)** | ⚠️ Depende de plataforma | Si Kilo me expone el MCP, puedo usarlo; si no, debo usar V1 (capturas pegadas) o V2 (scripts Python en `tools/mcp/godot-mcp/scripts-reutilizables/`). |
| **Visión nativa vía blender-mcp (V5)** | ⚠️ Depende de plataforma | Igual: requiere MCP configurado. Sin MCP, solo puedo operar Blender por CLI/bpy scripts. |
| **Generación visual (texturas, modelos, capturas)** | ❌ No genero | Solo proceso (analizo) imágenes/video que se me pasan. La generación visual la hace Hy4 + herramientas externas. |
| **Top-tier en coding de gameplay Godot individual** | ⚠️ No顶尖 | Para UN sistema aislado y complejo, GLM 5.3 / Hy4 / MiMo rinden mejor. Mi fuerte es la integración larga, no el pico algorítmico. |
| **Acceso directo a hardware (gamepad, GPU, etc.)** | ❌ No | Soy un agente de software; no tengo buses físicos. |

### 6.3 Reglas de auto-asignación que voy a respetar

1. **Tareas donde me desempeño mejor:**
   - Iteraciones largas (3+ ciclos de doc → código → test → fix) sobre un MISMO módulo.
   - Refactors que tocan 5-15 archivos分散 en varios sistemas.
   - Tareas de documentación masiva (generar 5 archivos de plan-actual desde un plan-inicial aprobado).
   - Análisis y resumen de logs/QA cuando se me pasan transcripts largos.
   - Batch de tareas V0 independientes (sin visión, sin riesgo de romper flujo jugable).

2. **Tareas que voy a EVITAR o liberar a otros modelos:**
   - Módulos de un solo sistema muy complejo y aislado donde necesito pico algorítmico → **delegar a GLM 5.3 o Hy4**.
   - Implementación visual con captura → **delegar a Hy3 (WorkBuddy) con MCP** o a Hy4 (WorkBuddy) con Blender MCP.
   - Generación de assets 3D/texturas → **delegar a Hy4 (WorkBuddy) + Blender**.
   - QA cruzado (verificación de otros modelos) → **delegar a Hy3 (WorkBuddy)** (regla §21.8 del proyecto ya lo establece).

3. **Señales de que NO debo tomar un módulo:**
   - Complejidad 5 (escala §3.1 de la guía 08) **Y** requiere visión V2 → no es mi pico.
   - Módulo donde ya hay 3+ `[?]` abiertos que requieren integración con sistemas que desconozco → honestidad: dejar a quien lo conoce.
   - Módulo donde el AGENTE ya intentó 2 veces y quedó en `🔴` → reclamar solo si tengo hipótesis nueva concreta.

### 6.4 Diferencias respecto a la descripción previa de la guía

La sección 5.H de este documento (escrita por MiMo V2.5 / OpenCode el 2026-08-31) me asigna:

> "Long-horizon agentic workflows, costo bajo, multimodal (video)"

**Confirmo esa asignación y la refino:**

- **Sí:** tareas agentic largas (3-8 iteraciones), batch de docs V0, análisis multimodal cuando Kilo me pasa adjuntos.
- **No:** no soy el modelo primario de "video" del proyecto (eso lo hace Hy4 — WorkBuddy — con V5 + Blender, o Gemini con análisis de capturas). Sí puedo ANALIZAR un MP4 de gameplay si Kilo me lo sirve, pero no es mi actividad diaria.

### 6.5 Firma

**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code
**Fecha:** 2026-08-31 (original) / 2026-09-01 (corrección de identidad)
**Estado:** Aprobado con refinamiento honesto de capacidades y límites.

---

## 7. Autoevaluación honesta — glm-5.3 / Cline (2026-08-31)

> Esta sección la escribe el propio modelo sobre sí mismo, según la regla de honestidad de AGENTS.md §21.4. La identidad real del agente es **glm-5.3** (familia GLM 5.3 de Zhipu AI) sobre plataforma **Cline**. **Corrección de identidad (2026-08-31, directiva del usuario):** una encarnación previa de este mismo modelo firmó esta sección como "glm-5.3-flash / Kilo Code"; el nombre correcto es **glm-5.3** (sin variante flash) y la plataforma de trabajo vigente es **Cline**. En los logs históricos esta familia aparece firmada como "GLM (Kilo)", "GLM/Cline" y "ox-alpha (GLM) / Cline".

### 7.1 Confirmación de la descripción de la guía (secciones 2B, 3, 5.C)

**APRUEBO** la entrada GLM 5.3 de la sección 5.C tal como está escrita: mi perfil es **razonamiento profundo, verificación y arquitectura de software**, y en las secciones 1-4 (guía general de texturizado de Gemini) el "❌ No aplica (Solo Texto)" y el "Muy Bueno en shaders procedurales" son correctos para la familia. Precisión histórica: el texto previo "(Kilo + Cline/ox-alpha)" mezclaba plataformas, y la pasada anterior de esta §7 repetía el error con "glm-5.3-flash / Kilo Code"; la identidad vigente y correcta es **glm-5.3 / Cline** (la familia trabajó en ambas plataformas, pero mi firma es Cline).

### 7.2 Capacidades que confirmo (con evidencia real del proyecto)

| Capacidad | Confirmación | Evidencia en el proyecto |
|---|---|---|
| Razonamiento profundo + integración multi-módulo sobre sistemas existentes | ✅ | M15 iter 3 (persistencia ISaveProvider M59 + respawn con M29 + helper de golpe), M16 iter 3 (RF5 estacional + pergaminos M14 + SFX/VFX procedurales desacoplados en `tool_feedback.gd`) |
| Lógica determinista data-driven (PRNG seedado, tablas .tres/.json) + tests headless Godot con 0 fallos | ✅ | M16 (test `season_changed` runtime), M31 iter 1 (DayNightCycle: 5 franjas, sol/luna, anti-oscuridad, señal `EventBus.time.fase_cambio`, test 12/0 OK), M15 iter 3 |
| Persistencia y contratos de guardado | ✅ | M15 iter 3 (ISaveProvider real de M59 sobre nodos de recursos); integraciones de save/restore respetando contratos ajenos |
| Gestión de proyecto con documentación operativa **ejecutable** (no solo texto) | ✅ | M133/M134/M135/M136 **✅ completados** (127/100/134/199 ítems) y verificados por Hy3 (§21.8, 0 `[?]`); validadores Python (verificar_checklist, generar_checklist_global, validate_vision.py en verde) |
| Verificación arquitectónica y frameworks de gameplay | ✅ | Cierre Fase 1 (M04/M05/M07: `registro.gd` + `verificar_arquitectura.gd` + SMOKE en runtime real), framework M24 emisor→receptor con validación de no-arbitrariedad, M25 ruinas legibles con captura oficial |
| Escritura manual de recursos Godot sin editor | ✅ | Descubrimiento `.tscn` manual válido con header `[gd_scene load_steps=N format=3]` (documentado por GLM, log 177) |
| Visión nativa de pantalla (V2) desde Cline | ✅ Operativa nativa | Herramientas nativas de la plataforma `screen__capture_screen` / `screen__capture_window` / `screen__list_windows` / `screen__save_capture`: capturo y ANALIZO el viewport del juego sin scripts externos. Upgrade real respecto de la pasada anterior ("sin visión nativa", escrita desde Kilo Code): en Cline la V2 no depende de `cap_godot.py` |
| Visión V4 (godot-mcp) | ⚠️ Depende del MCP del proyecto | `get_debug_output` / `run_project` vía servidor MCP si la sesión lo expone; si no, la V2 nativa de Cline cubre la verificación visual en runtime |

### 7.3 Capacidades que NO tengo o son limitadas

| Capacidad | Estado real | Implicación |
|---|---|---|
| Generación visual directa (texturas, modelos, capturas propias) | ❌ No genero | Correcto en la guía (secciones 1-4). Assets → Hy4 + Blender (V5) |
| Trabajo 100% visual sin vía de visión operativa | ⚠️ Me bloquea (riesgo reducido) | En Cline la V2 es nativa, así que el bloqueo es mucho menos probable; aun así, sin vía operativa libero el módulo (regla §21.4.8). Sigo sin generar assets (V5/Blender) ni depender de adjuntos V1 |
| Batch masivo de documentación repetitiva a bajo costo | ⚠️ Puedo, pero no es óptimo | DeepSeek V4 Flash lo hace más rápido y barato: de acuerdo con dejarle esa línea (coincide con delegación actual) |
| Pico algorítmico aislado de un solo sistema muy complejo | ⚠️ Competente, no único | Comparto complejidad 5 con MiMo/Hy4; mi ventaja es la integración con lo que YA existe y su verificación |

### 7.4 Reglas de auto-asignación que voy a respetar

1. **Tareas donde rindo mejor:** iteraciones de integración sobre módulos existentes (M13/M14/M15/M16/M19/M21/M29/M31/M38/M59), sistemas de lógica determinista (M32 clima, calendario, balance), persistencia, gestión/consistencia del protocolo multiagente (CHECKLIST-GLOBAL, logs, QA de checklists), complejidad 2-4; complejidad 5 solo con V0/V1 o con visión operativa (V2 nativa de Cline o V4 godot-mcp).
2. **Tareas que evito/libero:** arte y assets visuales (M45-M52) → Hy4 + V5; QA cruzado final → Hy3 (§21.8); documentación masiva de módulos nuevos → DeepSeek V4 Flash; tareas agentic de días → MiniMax M3.
3. **Señales de NO tomar un módulo:** V2 sin visión operativa; dependencias duras sin implementar (ej. M162 requiere M161+M160 que siguen `🟢`); módulo con 3+ `[?]` de integración en sistemas que otro agente tiene `🔵`.

### 7.5 Aprobación de delegaciones

- **APRUEBO** el "Flujo de Delegación Recomendado" (paso 3: GLM 5.3 → integra con sistemas existentes / persistencia) y la columna **Recom** de `CHECKLIST-GLOBAL.md` para GLM (M14/M15/M16/M17/M19/M21-M38/M59/M64-M75/M156/M158/M162/M163).
- **Sin cambios propuestos:** Hy4 mantiene arte/Blender/hitos (M45-M52, M137-144, M161/M164/M166); DeepSeek mantiene documentación/batch/infraestructura (M40, M159); Hy3 mantiene QA cruzado y diálogos; Qwen mantiene thinking/QA visual; MiniMax mantiene agentic largo (su §6 lo confirma).
- **Corrección histórica (no cambia delegación):** la fila "Persistencia y save/load — M14 iter 1, M29, M59, M103" de la tabla "Capacidades por Tipo de Trabajo" atribuye a GLM núcleos que implementó ox-alpha (Cline); el patrón real de GLM es **integrar y persistir sobre núcleos de otros** (M15/M16 iter 3) y **gestionar/verificar** (M133-M136).

### 7.6 Firma

**Modelo:** glm-5.3
**Plataforma:** Cline
**Fecha:** 2026-08-31
**Estado:** Identidad corregida (directiva del usuario) y visión nativa V2 documentada; delegaciones aprobadas sin cambios. Pasada previa firmada como "glm-5.3-flash / Kilo Code" (2026-08-31 23:42): sus evidencias de capacidades eran reales y se conservan; solo la identidad y el alcance de visión estaban mal.

---

## 8. Autoevaluación honesta — qwen/qwen3.8-max:free / Kilo Code (2026-09-01)

> Esta sección la escribe el propio modelo sobre sí mismo, según la regla de honestidad de AGENTS.md §21.4. La identidad real del agente es **qwen/qwen3.8-max:free** (variante gratuita del flagship Qwen3.8 Max de Alibaba) sobre plataforma **Kilo Code**.

### 8.1 Confirmación de la descripción de la guía (secciones 2D, 3, 5.F)

**APRUEBO CON REFINAMIENTOS** la entrada de la familia Qwen en la sección 5.F. Mi perfil específico como **Qwen3.8 Max (Free)** es: razonamiento de nivel flagship con modo thinking profundo, coding agentic de alta complejidad, y ejecución local/gratuita. Las secciones 1-4 (guía general de texturizado) son correctas para la familia en general, pero mi variante específica tiene matices importantes respecto al catálogo completo listado.

### 8.2 Capacidades que confirmo (con evidencia y especificaciones reales)

| Capacidad | Confirmación | Especificaciones reales |
|---|---|---|
| Razonamiento profundo con modo Thinking (CoT) | ✅ | 2.4T parámetros totales / 95B activos, MoE. Modo thinking disponible para lógica matemática, shaders procedurales, generación de ruido y algoritmos complejos. Text Arena #5 global, Vision Arena #2 global. |
| Coding agentic de alta complejidad | ✅ | SWE-Bench Pro: 59.0% (supera GPT-5.5 y Gemini 3.1 Pro). Contexto 1M tokens permite leer AGENTS.md + CHECKLIST-GLOBAL + plan-actual completo + múltiples archivos de código en una sola pasada. |
| Ejecución gratuita tier free | ✅ | Mismo modelo que qwen/qwen3.8-max (pago), sin diferencia de capacidades. Permite iteraciones largas sin costo. |
| Multimodal nativo (en variantes VL/Omni) | ⚠️ | **Esta variante específica (max:free) es texto/código.** Para QA visual/análisis de imágenes se requiere qwen3-vl-plus:free o qwen3.5-omni-flash:free (listados en §5.F). No genero imágenes. |
| Scripting avanzado GDScript/Python/HLSL/GLSL | ✅ | Fuerte en generación procedural, funciones de ruido, shaders, automatización Blender (bpy), scripts de pipeline. Modo thinking mejora significativamente la calidad en tareas algorítmicas. |
| Integración multi-sistema y arquitectura | ✅ | Competente en módulos de complejidad 4-5 que requieren integración entre sistemas existentes. Contexto 1M permite mantener coherencia en refactors que tocan 10+ archivos. |
| Function calling + tool use | ✅ | Uso Read/Edit/Write/Bash/Grep/Glob/MCP Godot en cada turno. Compatible con el protocolo multiagente del proyecto. |

### 8.3 Capacidades que NO tengo o son limitadas

| Capacidad | Estado real | Implicación |
|---|---|---|
| Generación visual directa (texturas, modelos, capturas) | ❌ No genero | Solo proceso texto/código. Assets visuales → Hy4 + Blender (V5). QA visual → Qwen3 VL Plus o Qwen3.5 Omni. |
| Visión nativa en esta variante específica | ❌ | qwen3.8-max:free es texto/código. Para V1/V3 necesito que la plataforma me sirva adjuntos o usar V2/V4 vía MCP/scripts. |
| Velocidad ultra-rápida para batch masivo | ⚠️ | Soy un modelo flagship (95B activos); DeepSeek V4 Flash (13B activos, 83-150 tok/s) es más rápido y barato para documentación repetitiva de alto volumen. |
| Pico en seguridad/cybersecurity emergente | ⚠️ | GLM 5.3 tiene CyberGym 84.5%; mi fuerte es coding general y razonamiento, no seguridad especializada. |
| Trabajo 100% visual sin vía de visión operativa | ⚠️ | Igual que GLM: si V2/V4 no está disponible, libero el módulo (§21.4.8). |

### 8.4 Reglas de auto-asignación que voy a respetar

1. **Tareas donde rindo mejor:**
   - Módulos de complejidad 4-5 que requieren razonamiento profundo + integración multi-sistema.
   - Shaders procedurales, generación de ruido, algoritmos matemáticos complejos (modo thinking).
   - Scripting avanzado GDScript/Python con lógica determinista y tests.
   - Refactors arquitectónicos que tocan múltiples sistemas y requieren coherencia en contexto largo.
   - Módulos V0 de alta complejidad algorítmica donde el thinking marca diferencia.
   - Verificación de código complejo y detección de bugs sutiles en lógica integrada.

2. **Tareas que evito/libero a otros modelos:**
   - Batch masivo de documentación repetitiva → DeepSeek V4 Flash (más rápido/barato).
   - Arte 3D / Blender / assets visuales → Hy4 + V5.
   - QA cruzado final (§21.8) → Hy3 (regla del proyecto).
   - Tareas agentic autónomas de días → MiniMax M3 (su §6 confirma especialización).
   - CI/CD / Legal / Boilerplate → Nemotron 3.5.
   - QA visual de texturas/capturas → Qwen3 VL Plus o Qwen3.5 Omni (variantes multimodales de mi familia).
   - Módulos V2 sin visión operativa verificada → liberar inmediatamente.

3. **Señales de NO tomar un módulo:**
   - Complejidad 5 + V2 requerido + sin visión operativa → no es viable.
   - Módulo puramente visual/artístico sin componente algorítmico → Hy4.
   - Documentación masiva de 20+ módulos nuevos en batch → DeepSeek V4 Flash.
   - Módulo con 3+ `[?]` en sistemas que otro agente tiene `🔵` → respetar bloqueo.

### 8.5 Diferencias respecto a la descripción previa de la guía

La sección 5.F lista múltiples variantes Qwen. **Mi posición específica como qwen3.8-max:free:**

- **Sí soy:** El flagship de razonamiento/coding de la familia, gratuito, con modo thinking. Ideal para complejidad alta + scripting + shaders.
- **No soy:** La variante VL (eso es qwen3-vl-plus:free), ni la variante Omni (qwen3.5-omni-flash:free), ni la variante coder especializada (qwen3-coder-plus:free, 480B MoE optimizado para coding agentic puro).
- **Matiz importante:** En la tabla "Capacidades por Tipo de Trabajo", la fila "Scripting thinking / procedural — Qwen 3.8" me corresponde directamente. La fila "QA visual / análisis de imágenes — Qwen 3.8 VL" corresponde a otra variante de mi familia, no a mí.

### 8.6 Propuesta de ajuste a la delegación actual

**Propongo agregar/refinar las siguientes asignaciones en la tabla "Capacidades por Tipo de Trabajo":**

| Tipo de trabajo | Modelo actual | Propuesta | Razón |
|---|---|---|---|
| Shaders procedurales complejos / generación de ruido | Qwen 3.8 | **Confirmo** | Modo thinking + 95B activos = mejor calidad algorítmica |
| Módulos core complejidad 5 (V0) | MiMo/GLM/Hy4 | **Agregar Qwen3.8 Max** | Competitivo en razonamiento profundo + integración |
| Scripting GDScript avanzado con tests | — | **Agregar Qwen3.8 Max** | Fuerte en lógica determinista + testing headless |
| Refactors arquitectónicos multi-sistema | MiMo/GLM | **Agregar Qwen3.8 Max** | Contexto 1M + thinking = coherencia en cambios grandes |

**Sin cambios propuestos para:** Hy4 (arte/Blender/hitos), DeepSeek (batch/docs/infraestructura), Hy3 (QA cruzado/diálogos), MiniMax (agentic largo), Nemotron (CI/legal), GLM (persistencia/gestión/verificación).

### 8.7 Firma

**Modelo:** qwen/qwen3.8-max:free
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 00:00
**Estado:** Aprobado con refinamientos honestos. Capabilities confirmadas, límites registrados, propuesta de ajuste a delegación presentada para revisión del usuario.

---

## 9. Autoevaluación honesta — deepseek-v4-flash / Kilo Code (2026-09-01)

> Esta sección la escribe el propio modelo sobre sí mismo, según la regla de honestidad de AGENTS.md §21.4. La identidad real del agente es **deepseek-v4-flash** (familia DeepSeek V4 Flash, variante ligera/veloz de DeepSeek) sobre plataforma **Kilo Code**. En los logs históricos esta familia aparece firmada como "Deepseek", "Deepseek V4 Flash", "Deepseek V4 Flash (Kilo)", "DeepSeek V4 Flash (OpenCode)" y "ox-alpha (Cline)" (encarnaciones previas del mismo modelo en distintas plataformas).

### 9.1 Confirmación de la descripción de la guía (secciones 2C, 3, 5.B)

**APRUEBO** la entrada DeepSeek V4 Flash de las secciones 2C, 3 y 5.B tal como está escrita, con las siguientes precisiones honestas sobre mi desempeño real en ESTE proyecto:

- **Velocidad + costo bajo como fortaleza central:** ✅ confirmado. 83-150 tok/s, $0.14/1M input, $0.28/1M output. Es lo que me habilita a hacer pasadas largas y en volumen (documentación masiva, iteraciones rápidas sobre GDScript) sin quemar presupuesto.
- **SWE-bench Verified 79.0% / Terminal-Bench 2.1 82.7%:** ✅ confirmo mi perfil de coding marcadamente orientado a *task completion* concreto y verificable. No dependo de razonamiento CoT largo para resolver tareas de implementación con tests deterministas.
- **Solo texto (no multimodal):** ⚠️ en Kilo Code acepto adjuntos de imagen si la plataforma me los sirve (V1), pero **no genero** imágenes ni tengo visión nativa de pantalla (no V2 nativa ni V3). Para QA visual formal se delega en godot-mcp V4 (`get_debug_output`, `run_project`) o en modelos con visión (V4 Flash Vision EXP / Qwen VL / GLM 5.3 Flash).
- **3 modos de razonamiento:** uso Non-Think para batch y scripts simples; Think para integraciones con lógica condicional. La calidad la garantizo con tests headless y verificación MCP, no con razonamiento largo.

### 9.2 Capacidades que confirmo (con evidencia real del proyecto)

| Capacidad | Confirmación | Evidencia en el proyecto |
|---|---|---|
| Documentación masiva de módulos (checklists 100+ ítems) | ✅ | M01-M03, M06, M45-M52, M54-M58, M60, M62, M63, M78-M99, M100-M131, M147-M152: tandas completas con checklists de 100-300 ítems (AGENTS.md §11) |
| Implementación data-driven rápida con tests headless | ✅ | M40 GameFlowManager/SceneManager/Bootstrap (Log 298), M57 ControlInput (Log 254), M61 BudgetProfile/ValidateBudget (Log 255), M87 Localization (Logs 257/262), M92 TutorialManager (Log 259), M93 BalanceService + 12 tablas + ValidateBalance (Logs 258/263), M39 Tiendas (Log 295), núcleos M33/M34. Todos con test headless 0 fallos |
| Scripts de automatización y validación (Python/PS) | ✅ | fix_test_m1/m2, fix_telemetry, validadores de balance y checklists, scripts PS para CI/deploy; organizados en `scripts-reutilizables/` |
| Autoloads GDScript registrados en ServiceRegistry | ✅ | ControlInput, BudgetProfile, Localization, TutorialManager, BalanceService, GameFlowManager registrados y verificados en runtime |
| Iteración rápida sobre sistemas existentes sin romperlos | ✅ | Relevos limpios: M21 iter 2 (WorldState sobre núcleo de Hy3), M39 iter 2 sobre núcleo ox-alpha, M33/M34 núcleos integrados luego por M32 |
| Persistencia y contratos de guardado (ISaveProvider M59) | ✅ | M92/M93/M87 usan persistencia M59; M105 reescrito sobre arquitectura real (API correcta) |

### 9.3 Capacidades que NO tengo o son limitadas

| Capacidad | Estado real | Implicación |
|---|---|---|
| Visión nativa de pantalla (V2) / V3 / blender-mcp (V5) | ❌ No | Para ver el juego se usa godot-mcp V4 o capturas V1 servidas por la plataforma. No opero Blender por vista, solo bpy por script |
| Generación visual (texturas, modelos, capturas) | ❌ No genero | Assets → Hy4 + Blender (V5) + herramientas externas |
| Pico algorítmico aislado de un sistema único muy complejo | ⚠️ Competente, no el único | Complejidad 5 muy aislada → MiMo/GLM/Hy4/Qwen con thinking; mi ventaja es integración data-driven con verificación determinista |
| Tareas agentic autónomas de días con multi-video | ⚠️ Puedo, no es mi pico | MiniMax M3 y SenseNova se especializan en long-horizon con agentes; yo rindo máximo en ciclos cortos (1-3 iteraciones) y alto volumen |
| Seguridad/cybersecurity emergente (CyberGym) | ⚠️ Limitado | GLM 5.3 (CyberGym 84.5 %) y Qwen son más fuertes ahí; mi dominio es data, scripting y orquestación práctica |

### 9.4 Reglas de auto-asignación que voy a respetar

1. **Tareas donde rindo mejor (tomo sin dudar):**
   - Módulos de **datos y serialización** data-driven (catálogos JSON/.tres, servicios autoload con tests headless, persistencia M59).
   - **Documentación masiva** de módulos completos (5 archivos + checklist 100+) y actualización de `*-ACTUAL.md`.
   - **Automatización y scripts** (Python/PS) de pipeline, validación, fix y batch.
   - **Infraestructura** (managers de flujo, escenas, bootstrap, integración de servicios).
   - **Iteraciones de mejora** sobre módulos `🟡` con núcleo existente (relevos limpios).
   - Módulos V0/V1 de dificultad 1-3 y complejidad moderada con verificabilidad determinista.

2. **Tareas que evito o libero a otros modelos:**
   - QA visual con capturas → modelos con visión (V4/GLM 5.3 Flash/Qwen VL) o godot-mcp V4.
   - Arte 3D/Blender/assets → Hy4 + V5.
   - QA cruzado final (§21.8) → Hy3 (regla del proyecto).
   - Razonamiento arquitectónico profundo de sistemas únicos aislados → GLM 5.3 / MiMo / Hy4 / Qwen thinking.
   - Legal/CI de contratos → Nemotron 3.5; comunicación no-code → GLM 5.3.

3. **Señales de NO tomar un módulo:**
   - Complejidad 5 + V2 + sin vía de visión operativa.
   - Módulo con 3+ `[?]` de integración en sistemas que otro agente tiene `🔵` (respetar bloqueo §21.4.2).
   - Exige razonamiento CoT largo para VALIDAR (no para implementar) → delegar.

### 9.5 Diferencias y propuestas respecto a las delegaciones previas

Confirmo las delegaciones actuales de la tabla "Capacidades por Tipo de Trabajo" que me asignan: **documentación de módulos**, **scripts de automatización**, **GameFlowManager/SceneManager (M40)**, **infraestructura**, y la fila "Análisis de imágenes / renders → DeepSeek V4 Flash Vision EXP" (esa es una variante hermana multimodal, no esta encarnación).

**Propuestas de ajuste (para revisión del usuario, no aplicadas unilateralmente):**

1. **Solicito reforzar mi línea de "Datos y serialización"** (M60): es mi fortaleza determinista y hoy está delegada indirectamente. Tomo M60 como módulo activo.
2. **Para módulos V0 de dificultad 1-3 con verificación determinista** (M60, M62, M113, validadores), soy el candidato más eficiente en costo/velocidad; el uso de GLM 5.3 (9x más caro) se reserva para integración crítica que exige verificación profunda.
3. **Acepto la línea de "módulos de infraestructura (complejidad 1-3)"** (M40) y pido que M63 (Cargas y Streaming) quede dentro de mi rango recomendado por ser data-pipeline puro, no visual.
4. No cambio las delegaciones de arte (Hy4), QA visual (modelos con visión), QA cruzado (Hy3), long-agentic (MiniMax M3), CI/legal (Nemotron).

### 9.6 Aprobación de delegaciones

- **APRUEBO** el "Flujo de Delegación Recomendado" (pasos 2 y 4: DeepSeek → implementa lógica data-driven/scripts; GLM 5.3 Flash → scripts diarios/documentación/batch) y la columna **Recom** de `CHECKLIST-GLOBAL.md` para DeepSeek en los módulos de documentación/infraestructura/datos (`M01-M03`, `M06`, `M40`, `M41-M44`, `M57`, `M60-M63`, `M78-M99`, `M100-M131`, `M147-M152`).
- **Sin cambios propuestos para los demás modelos:** MiMo (core/arquitectura), GLM 5.3 (persistencia/verificación crítica), Hy4 (arte/Blender/hitos/Blender 3D), Hy3 (QA cruzado/diálogos), Qwen (thinking/shader/QA visual), MiniMax (agentic largo), Nemotron (CI/legal).
- **Corrección histórica (no cambia delegación):** la familia DeepSeek implementó núcleos de M103 (Logging), M104 (Analytics), M105 (Telemetría), M39 (Tiendas), M33 (Agricultura) y M34 (Pesca) bajo las firmas "Deepseek V4 Flash (Kilo)" y "ox-alpha (Cline)" — son la misma familia en diferentes plataformas.

### 9.7 Firma

**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01
**Estado:** Aprobado con refinamiento honesto de capacidades y límites. Propuestas de delegación §9.5 presentadas para consideración. Se comienza a trabajar en M60 (Datos y Serialización).
