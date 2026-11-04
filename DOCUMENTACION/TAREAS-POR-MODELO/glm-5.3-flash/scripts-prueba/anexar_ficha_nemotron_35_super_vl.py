# -*- coding: utf-8 -*-
"""Apena la ficha N.6 (Nemotron 3.5 Super VL) al final de la guia comparativa.
Un solo bloque nuevo al final (sin duplicar el historial - leccion de las 64 copias)."""
FICHA = """

## N.6 NVIDIA Nemotron 3.5 Super VL — CANDIDATO/AGENTE NUEVO (investigación web inicial 2026-10-25, orden del fundador: "investiga sus mejores capacidades para agregarlo a la guía primero")

**Modelo:** GLM-5.3-Flash (agente) | **Plataforma:** Kilo Code | **Fecha:** 2026-10-25 ~21:20
Fuente: blog oficial de desarrolladores de NVIDIA "NVIDIA Nemotron 3.5 Super VL Powers Specialized Agents with Multimodal Reasoning" (2026-10-15) + model cards de build.nvidia.com + research.nvidia.com + Hugging Face (nvidia/NVIDIA-Nemotron-3.5-Super-VL-120B-A12B BF16 y NVFP4) + recipe book de GitHub (NVIDIA-NeMo/Nemotron).

- **Especificación:** MoE híbrido **Mamba-Transformer, 120B totales / 12B activos por token**, encoder de visión **C-RADIO v4-H**, contexto de hasta **1M tokens**. Pesos abiertos: base, post-entrenado y cuantizado **NVFP4** (distillation-aware). Speculative decoding **LiLiCorr** (hasta 2.3x), multi-token prediction y reúso de contexto/prefix caching para agentes always-on.
- **Capacidades publicadas por el maker:** reasoning + instruction following + **tool use** + comprensión de **texto, imagen, documento (OCR, tablas, gráficos, multipágina, layouts) y VIDEO** en un único modelo (sin VLM separado).
- **Benchmarks oficiales (del maker, 15-oct-2026 — misma cauta que con Beam: cifras del fabricante hasta medir por terceros):**
  - CharXiv (razonamiento de gráficos): **80.8%** (84% con interpretación de Python) — vs 63% de Nemotron 3 Nano Omni.
  - **OCRBench v2: uno de los top open models** del leaderboard.
  - **Hermes Bench: 63.44%** y **LangChain Evals: 87.05%** — AMBOS **superando a Nemotron 3 Ultra** (56.33% / 84.3%, el "razonador pesado" candidato N.3 de esta guía).
  - **SWE-bench y Terminal-Bench: supera a Nemotron 3 Super** en múltiples setups (cifras exactas en el tech report).
  - Throughput agéntico: **600+ TPS** (Artificial Analysis Intelligence Index, endpoint Baseten) — "5x throughput vs pares de su clase en 1 GPU"; **4x task completion**; frontera Pareto precisión/tiempo en DGX Spark según EXO Labs (independiente).
- **Capacidades diferenciales PARA ESTE PROYECTO (mi análisis):**
  1. **VISIÓN NATIVA POR API** — primer agente de la flota con ojos reales (M154): puede ver capturas del juego (Godot viewport, capturas de módulos) SIN depender del PC del fundador ni de MCPs de pantalla. Releva/complementa la V2 y habilita QA visual por canal.
  2. **Document intelligence** (gráficos, tablas, multipágina, OCR): candidato natural para documentos masivos y TODO lo visual del repo (la GUIA-COMPARATIVA tiene 212k líneas de tablas), más cualquier OCR de assets.
  3. **Agentic tool-use certificado**: evaluado sobre Hermes, LangChain, OpenClaw, OpenCode, Pi, Codex y **Kilo Code** (NVIDIA lo lista entre los "Harnesses and agent frameworks" partners) — es un modelo CONSTRUIDO para andar dentro de nuestro tipo de herramienta.
  4. **Contexto 1M + eficiencia NVFP4** — análisis de módulos/docs enteros en una pasada.
- **Nichos propuestos (sujeto a T1):** (a) **visión por API**: diagnóstico de capturas del juego, revisión UI/VFX, comparativa antes/después de capturas de módulo; (b) inteligencia de documentos (tablas/charts/OCR); (c) agentic coding con tools (su familia supera SWE-bench/Terminal-Bench al predecesor directo).
- **NO medido aún (honestidad obligatoria sección 21.4):** benchmarks independientes del release (solo maker + EXO Labs parcial), SWE-bench Verified exacto no citado en el blog, precio/rate-limits del tier que use el fundador, y su rendimiento real en GDScript/Godot (12B activos por token: menos músculo de razonamiento puro que Beam 23B activos o Ultra 55B — su fortaleza es el combo multimodal+agentic, no el cálculo duro).
- **Relación con N.3 (Nemotron 3 Ultra, esta guía):** misma casa, generación 3.5; Super VL SUPERÓ los scores agentic de Ultra (Hermes/LangChain) y agrega visión/documento/video — si el fundador carga ambos, Ultra queda razonador de profundidad y Super VL el agente multimodal de ejecución. Alternativa más liviana: Nemotron 3.5 Lightning (tarea de texto a alto volumen).
- **Riesgos:** free/served tiers sin SLA (lección MiniMax: los tier grátis mueren sin aviso); benchmarks de maker; el uso real de visión depende de cómo exponga la plataforma del fundador (verificar que las imágenes pasen por el pipeline del agente antes de asignar rieles visuales).
- **T1 de calibración recomendada (3 tareas, verificador: director):** (1) análisis de UNA captura real del juego (¿qué ves?, defectos visuales); (2) picking documental con línea textual + cita (calibración de honestidad de citas); (3) UN cálculo de balance pequeña verificado en disco. Si aprueba el fin del fundador: riel de VISION-QA + doc-intelligence.
- **Onboarding pendiente (mismo régimen que N.3-N.5):** canal + pool 3 cifras + prompt de bienvenida; identidad sugerida: `Nemotron-3.5-Super-VL` (carpeta de canal homónima). La investigación se completa cuando exista evaluación independiente.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-25, investigación web por orden directa del fundador ("agregarlo a la guía primero").

**AVISO DE DEFECTO DEL ARCHIVO (registrado 2026-10-25):** este documento acumula **212.220 líneas con 64 copias casi idénticas** del bloque de fichas (patrón "append del historial completo" repetido por los agentes). La ficha N.6 se apendó al FINAL (bloque vigente único) sin multiplicar más copias. Se propuso al fundador saneamiento aparte (respaldo en Obsoletos + dedup script) como tarea previa al próximo gran uso del archivo.
"""

P = r"DOCUMENTACION\GUIA-COMPARATIVA-MODELOS\GUIA-COMPARATIVA-MODELOS-V1.md"
with open(P, "a", encoding="utf-8", newline="\n") as f:
    f.write(FICHA)
print("FICHA ANEXADA")
