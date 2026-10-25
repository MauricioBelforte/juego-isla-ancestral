# Log 2188: Investigacion web + ficha N.6 de NVIDIA Nemotron 3.5 Super VL en la GUIA-COMPARATIVA

**Fecha:** 2026-10-25
**Hora:** 21:35
**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code

## Resumen

Por orden directa del fundador ("tenemos un nuevo agente para agregar a la flota: nemotron 3.5 super vl, investiga sus mejores capacidades en la web para agregarlo a la guia primero"), investigue el modelo en la web (fuentes oficiales de NVIDIA) y anexe su ficha al final de la guia comparativa como seccion N.6.

## Hallazgos principales

- NVIDIA Nemotron 3.5 Super VL (15-oct-2026): MoE hibrido Mamba-Transformer de 120B totales / 12B activos, encoder de vision C-RADIO v4-H, contexto 1M, pesos abiertos (BF16 + NVFP4).
- Multimodal real: texto + imagen + documento (OCR/tablas/graficos/multipagina) + VIDEO, con reasoning, tool-use y agentic workflows en el mismo modelo.
- Benchmarks del maker: CharXiv 80.8% (84% con Python), OCRBench v2 top open, Hermes Bench 63.44% y LangChain 87.05% (AMBOS por encima de Nemotron 3 Ultra, candidato N.3 de esta guia), supera a Nemotron 3 Super en SWE-bench/Terminal-Bench, 600+ TPS agentic con 5x throughput (Baseten), 4x task completion, frontera Pareto en DGX Spark (EXO Labs, independiente).
- Nichos propuestos para la flota: (a) vision por API para QA visual sin depender del PC del fundador (M154), (b) document intelligence, (c) agentic coding (NVIDIA lista a Kilo Code entre sus harnesses partners).
- Honestidad: benchmarks de maker; SWE-bench Verified exacto no citado; 12B activos = menos razonamiento puro que Beam/Ultra; tier served sin SLA (leccion MiniMax). T1 de calibracion recomendada (captura real + picking documental + calculo verificado) antes de asignar rieles.

## Cambios Realizados

- `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md`: anexada seccion `## N.6 NVIDIA Nemotron 3.5 Super VL` al final (bloque vigente), con firma y linea de fuentes. NO se dupliqueron bloques historicos (ver aviso de defecto abajo).
- Detectado y REGISTRADO defecto material del archivo: 212.220 -> 212.250 lineas con **64 copias casi identicas** del bloque de fichas (patron "append del historial completo" repetido por agentes anteriores). Propuesta al fundador: saneamiento aparte (respaldo en Obsoletos + dedup por script + verificacion git diff) como tarea separada.
- Script de anexo archivado: `DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash/scripts-prueba/anexar_ficha_nemotron_35_super_vl.py` (metodo: append al final, UTF-8 sin BOM, sin tocar bloques existentes).
- Numero de log reservado por protocolo 6.1.a: **2188** (borrado del pool Logs/NUMEROS_DISPONIBLES.txt).

## Archivos Modificados/Creados

- `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` (ficha N.6, lineas 212222-212250, sin BOM)
- `DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash/scripts-prueba/anexar_ficha_nemotron_35_super_vl.py` (nuevo)
- `Logs/2188-investigacion-nemotron-3-5-super-vl-ficha-guia-2026-10-25_21-35-00.md` (este log)

## Notas del Agente

**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 21:35:00
**Estado:** Completado (investigacion + ficha de la guia; integracion al canal/pool queda pendiente de la plataforma del fundador y del GO para T1 de calibracion)
