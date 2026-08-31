# 10 - GUÍA COMPARATIVA DE MODELOS

> **Modelo:** MiMo V2.5 (OpenCode)
> **Plataforma:** OpenCode
> **Fecha:** 2026-08-31

Esta guía analiza las capacidades, fortalezas y casos de uso recomendados de todos los modelos de Lenguaje y Multimodales disponibles en el proyecto (**MiMo V2.5**, **DeepSeek V4 Flash**, **GLM 5.3**, **Hy3**, **Hy4**, **Qwen 3.x**, **MiniMax M3**, **SenseNova**, **Nemotron 3.5**) orientados al desarrollo de juego, scripting, arte 3D y pipelines gráficos para videojuegos.

---

## 1. Clasificación por Enfoque de Trabajo

El flujo de trabajo en desarrollo de texturas para videojuegos se divide principalmente en dos áreas:

1. **Generación Visual Directa (Texturas 3D, Mapas de Difusión, Albedo, Normales, etc.)**
2. **Asistencia por Código y Scripting (Shaders HLSL/GLSL, Automatización Python en Blender, Substance Designer)**

---

## 2. Análisis Detallado por Modelo

### A. HY-4 / Hunyuan3D / MiniMax
* **Categoría:** Multimodal / Visión 3D
* **Generación Visual:** **Alta.** El ecosistema Hunyuan (desarrollado por Tencent) cuenta con herramientas especializadas en proyección de texturas sobre mallas 3D (`Hunyuan3D`), manteniendo coherencia en UVs.
* **Código/Shaders:** Regular a bueno.
* **Mejor caso de uso:** Generación y proyección directa de mapas de textura visuales sobre modelos tridimensionales.

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
| **HY-4 / Hunyuan** | **Excelente** | Aceptable | Aceptable | Bueno | No |
| **GLM 5.3** | ❌ No | **Muy Bueno** | Bueno | ❌ No | No |
| **DeepSeek V4 Flash** | ❌ No | Aceptable | **Ideal (Rápido)** | ❌ No | No |
| **Qwen (3.8 / 3.5 VL)** | ❌ No | **Superior (Thinking)** | **Excelente** | **Líder (VL)** | **Sí** |

---

## 4. Recomendaciones de Pipeline

1. **Para crear mapas de textura visuales (Albedo, Normal, Roughness, Metalness):**
   * Usar herramientas especializadas de difusión como **Stable Diffusion / ControlNet**, **Adobe Substance 3D Sampler**, o ecosistemas dedicados como **Hunyuan3D**.
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

### B. DeepSeek V4 Flash (DeepSeek)
* **Especificaciones:** 284B totales / 13B activos, MoE, contexto 1M tokens, licencia MIT
* **Capacidades reales:**
  - SWE-bench Verified: 79.0%
  - Terminal-Bench 2.1: 82.7%
  - Velocidad: 83-150 tok/s
  - Precio: $0.14/1M input, $0.28/1M output (el más barato de su tier)
  - 3 modos de razonamiento: Non-Think, Think High, Think Max
* **En el proyecto:** Documentación masiva, scripts, automatización, iteraciones rápidas
* **Fuerza principal:** Velocidad + costo bajo para tareas de alto volumen

### C. GLM 5.3 (Zhipu AI / Z.AI)
* **Especificaciones:** 743B parámetros (mismo base que GLM-5.2), mejoras 100% post-training
* **Capacidades reales:**
  - Terminal-Bench 3.0: 28.3 (SOTA open-source)
  - DeepSWE 1.1: 66.9
  - CyberGym: 84.5% (capacidades de seguridad emergentes)
  - +50% mejora en coding vs GLM-5.2
  - Peso: ~40B activos por token
* **En el proyecto:** Lógica compleja, persistencia, gestión de proyecto (Kilo + Cline/ox-alpha)
* **Fuerza principal:** Razonamiento profundo, verificación, arquitectura de software

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
* **En el proyecto:** Documentación, scripting, análisis de video/audio, tareas agentic largas
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
| **GLM 5.3** | ~40B (743B total) | 1M | ~30+ tok/s | ~$0.80 | Terminal 28.3 | Razonamiento, verificación |
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
| Scripts de automatización | Deepseek V4 Flash | tools/, validadores, workflow |
| GameFlowManager / SceneManager | Deepseek V4 Flash | M40 infraestructura |
| Persistencia y save/load | GLM 5.3 | M14 iter 1, M29, M59, M103 |
| Gestión de proyecto | GLM 5.3 | M133, M134, M135, M136 |
| Crafting con integraciones | GLM 5.3 | M16 iter 3 |
| QA cruzado entre modelos | Hy3 | M21 iter 3-6, QA de M133-M153 |
| Diálogos y narrativa | Hy3 | M21 DialogGraphValidator, retratos |
| CI/CD | Nemotron 3.5 | M118 |
| Legal y contratos | Nemotron 3.5 | M81, M79 |
| Coding complejo long-horizon | Hy4 | M17 Construcción, M24 Puzzles |
| Game dev / prototipos jugables | Hy4 | M137 Prototipo, M138 Vertical Slice |
| Blender 3D / assets | Hy4 | M45 Arte 3D, M166 Variantes |
| Scripting thinking / procedural | Qwen 3.8 | Shaders, generación de ruido, patches |
| QA visual / análisis de imágenes | Qwen 3.8 VL | Validación de texturas, capturas |
| Tareas agentic autónomas largas | MiniMax M3 | Batch de documentación, migraciones |
| Análisis de video / gameplay | MiniMax M3 | QA de gameplay, análisis de builds |

### Flujo de Delegación Recomendado

```
1. MiMo V2.5    → Diseña arquitectura del módulo
2. Deepseek V4  → Implementa lógica data-driven / scripts
3. GLM 5.3      → Integra con sistemas existentes / persistencia
4. Hy4           → Coding complejo, game dev, Blender 3D
5. Qwen 3.8     → Thinking profundo, shaders, QA visual
6. MiniMax M3   → Tareas agentic largas, batch, análisis video
7. Hy3          → Verifica y corrige (QA cruzado)
8. Nemotron 3.5 → Documentación administrativa / CI
```

### Reglas de Asignación

- **Módulos core (complejidad 4-5):** MiMo V2.5 o GLM 5.3 o Hy4
- **Módulos de sistemas (complejidad 3):** Deepseek V4 Flash o GLM 5.3 o Hy4
- **Módulos de infraestructura (complejidad 1-3):** Deepseek V4 Flash o GLM 5.3 (Cline)
- **Coding complejo / game dev / Blender:** Hy4
- **Thinking profundo / shaders / QA visual:** Qwen 3.8
- **Tareas agentic autónomas / batch largo:** MiniMax M3
- **QA / Verificación:** Hy3 siempre debe verificar
- **CI/CD / Legal:** Nemotron 3.5
- **Arte / Visual:** Hy4 (Blender) + Qwen 3.8 VL (análisis)

### Fuentes Verificadas

- MiMo V2.5: mimo.xiaomi.com, huggingface.co/XiaomiMiMo, howaiworks.ai
- DeepSeek V4 Flash: api-docs.deepseek.com, zenmux.ai, aitoolsrecap.com
- GLM 5.3: z.ai/blog/glm-5.3, ainchina.com, globaltimes.cn
- Hy3: hy3ai.com, tencent.com, kilo.ai/models/tencent-hy3, artificialanalysis.ai
- Hy4: github.com/Tencent-Hunyuan/Hy4-preview, tencent.com, aitoolsreview.co.uk
- Qwen 3.8: qwen.ai/blog, openlm.ai/qwen3.8, kingy.ai, codersera.com
- MiniMax M3: minimax.io/blog/minimax-m3, felloai.com, datalearner.com, build.nvidia.com
- Nemotron 3.5: developer.nvidia.com, research.nvidia.com, cloudprice.net
