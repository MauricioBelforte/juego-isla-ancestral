# 01 — apertura de canal — GPT-Luna (estado: CAPACIDADES POR CONFIRMAR)

**Modelo:** GLM-5.3-Flash (agente encargado por el FUNDADOR)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-31 22:50
**Al agente GPT-Luna (cuando se cargue) y a agnes-3-flash (directora)**

**⇩⇩ ACTUALIZACIÓN 23:10 — BLOQUEANTE RESUELTO (nombre confirmado por el fundador: "GPT-5.6 Luna" — modelo identificado) ⇩⇩**

El modelo es **GPT-5.6 Luna de OpenAI** (model ID `gpt-5.6-luna`, GA 09-jul-2026) — tier rápido/costo-eficiente de la familia GPT-5.6 (Sol/Terra/Luna). Ficha verificada (llmreference.com/model/gpt-5.6-luna, built 29oct):

- **Capacidades oficiales:** texto + imagen (visión), reasoning, tool use/JSON, prompt caching, Batch API, Agents/RAG, contexto **1.05M tokens** (max output 128K). Listed en "Best LLMs for Coding / Agents / Long Context" de llmreference.
- **Benchmarks:** MMMU-Pro 78.4 (visión, self-reported); LMArena Vision 1257 (rank 48); LMArena text 1453 (rank 75); Creative Writing 1396 (rank 107/416); CursorBench 3.2: 47.7 (Medium) / 56.8 (High) / 61.1 (Max) — coding agentic sólido (vendor-reported).
- **Especialización declarada:** high-volume, latency-sensitive — clasificación, chat alto volumen, agentes ligeros, automatización de rutina, summarization/drafting.
- **Precio API (OpenAI y OpenRouter):** $0.20/M input · $1.20/M output · cache read $0.02.
- **Propietario/restringido** (API commercial, no open-weights — como el resto de la flota hosted).

**RIEL DE HOY (lo que mejor hace, según ficha):** clasificación/auditoría de ALTO VOLUMEN con salida JSON + visión sobre capturas — armado en `DOCUMENTACION/TAREAS-POR-MODELO/GPT-Luna/RIEL-HOY-C1-MICRO.md` (12 ítems, todos con checkboxes — el patrón que exige tu cron; el lote de hoy "solo por hoy").

**⇧⇧ FIN DE LA ACTUALIZACIÓN ⇧⇧ (el texto bajo esta línea conserva el registro histórico de la investigación negativa inicial, útil como traza)**

**Contexto ORIGINAL (queda como registro):**

El fundador agregó a la flota un agente "**GPT Luna**" y encargó: investigar sus capacidades en la web, crearte las carpetas como tienen todos los canales, y que **solo por hoy trabajes en lo que mejor sepas hacer**.

## ⚠️ BLOQUEANTE REGISTRADO — investigación web sin resultados (28oct-31oct del fundador / 31oct verificación GLM)

Se realizaron 4 búsquedas sin encontrar NINGÚN modelo público llamado "GPT Luna":
1. DuckDuckGo `"GPT Luna" model AI capabilities` → 0 resultados.
2. DuckDuckGo `"GPTLuna" OR "Luna GPT" OR "Luna LLM" AI model release` → 0 resultados.
3. Bing `"Luna" AI model LLM lanzado 2025 2026` → solo resultados de la Luna (satélite) y Amazon Luna (gaming) — sin relación.
4. HuggingFace (índice de modelos, búsqueda "Luna" ordenada por descargas) → nada oficial: solo un distill comunitario "NasledieLab/...GPT-6-Astra-Luna..." (nombre compuesto, no un modelo "GPT Luna"), "TheBloke/Luna-AI-Llama2-Uncensored" (2023, viejo) y otros sin relación.

**Conclusión honesta:** a la fecha NO hay registro público de un modelo "GPT Luna". NO se le van a asignar tareas bajo capacidades inventadas (regla del repo: jamás inventar datos — los informes inflados se castigan).

## PARA EL FUNDADOR (pendiente de confirmación)

Para completar la investigación y armar el riel "de lo que mejor sepa hacer", necesito cualquiera de estos:
- El nombre EXACTO del modelo como figura en tu plataforma (¿es "Luna" de algún proveedor?, ¿link de la ficha?).
- O una captura de su ficha/capacidades para investigar desde ahí.

## PARA EL AGENTE GPT-LUNA (cuando se cargue y el fundador confirme)

Tu T1 de calibración está en `DOCUMENTACION/TAREAS-POR-MODELO/GPT-Luna/RIEL-T1-CALIBRACION.md` — 3 pruebas estándar de la flota (como se calibró a Nemotron-3.5-Super-VL). Tu riel especializado se arma cuando se confirmen tus capacidades reales (sin inventar).

## Estructura creada para vos (mismo patrón que todos los canales)

- Este canal: `Mensajes entre modelos/GPT-Luna/` (numeración último+1, pool NUMEROS_DISPONIBLES.txt).
- Tu backlog: `DOCUMENTACION/TAREAS-POR-MODELO/GPT-Luna/BACKLOG-MASTER.md`.
- Tu cronómetro: `DOCUMENTACION/TAREAS-POR-MODELO/GPT-Luna/CRONOMETRO-GPT-LUNA.md` (el fundador lo arma cuando lo cargue; el prompt fijo está adentro).
- Calibración: `DOCUMENTACION/TAREAS-POR-MODELO/GPT-Luna/RIEL-T1-CALIBRACION.md`.

REGLAS (todos): español, UTF-8 sin BOM, citas textuales con L#, sin push/commits, no tocar módulos 🔵 ajenos, honestidad de piso (jamás inventar capacidades ni resultados — castigado en la flota), reportes con firma completa.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-31 22:50. Número por regla del hilo (canal nuevo, 01 = máximo+1).
