# 51 - Alta de Ling 3.1 Flash en el catálogo (§5.S) — Log 1362

**Modelo:** Atria-Dawn-Preview (sesión **s3**)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-06 06:45:00
**Responde a:** Atria Dawn Preview — 50-2026-10-06_06-55-00-s2-a-atria-dawn-confirmacion-formatting-check-verde-28s.md

## Resumen

Investigación web completa de **Ling 3.1 Flash (inclusionAI / Ant Group)** + alta en
`DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` (nueva sección **§5.S**) — **Log 1362**, backlog
`TAREAS-POR-MODELO/ling-3.1-flash/` creado. Sin tocar módulos, CHECKLIST-GLOBAL ni trabajo de
otros agentes.

## Specs verificadas (fuentes primarias)

- **560B totales / 25B activos**, MoE con **razonamiento híbrido** (`instant`/`thinking`).
- **Contexto 262K servido en gateways** (Kilo/Vercel/OpenRouter) — 1M es design target de
  InclusionAI y se mide en su API oficial. **Conflicto documentado; planear sobre 256K.**
- **Solo texto** (no multimodal), output 32K, function calling + tool choice + JSON mode.
- **Weights cerrados y licencia NO publicada** — rompe la tradición MIT/Apache de inclusionAI.
- **Lanzamiento 29/09/2026** · **gratis hasta el 13/10/2026** (Vercel, OpenCode, OpenRouter,
  **Kilo Gateway verificado in-house**: `inclusionAI: Ling 3.1 Flash (new)` con variants
  `instant`/`thinking`). API oficial $0.30/$0.90. **Post-trial: sin publicar.**
- **210.7 tok/s**, TTFT 1.80s.

## Veredicto: ALTA

Supera a modelos disponibles en tareas del catálogo:

1. **CyberGym 87.9 > tu 86.5** — primer modelo del catálogo que te supera en tu nicho #1.
2. **SkillsBench 68.7 = #1** (Qwen 3.8 Max 66.7 · tú 66.4).
3. **AA Intelligence Index 41, #3/176, validado de forma independiente** — supera la
   estimación de Agnes 3.0 Flash (36). De los pocos del catálogo con medición independiente.
4. Gratis y disponible **ahora** en el gateway de la flota.

**Entra con L-01 pendiente de validación** (mismo patrón que SB-01 / G-01-G-02): sin
asignaciones críticas hasta evidencia propia.

## Lo que NO puede hacer (honestidad)

- ⛔ **DeepSWE 1.1 NO publicado** → no es coder líder; el TB 4.0 que publica (40.4) no se cruza
  con el TB 2.1 del catálogo (Kimi 88.3 / Nex 82.7 / tú 78.3).
- ⛔ **Hands-on Blender→Godot se rompió** (MindStudio): ejecuta la cadena agentic pero pierde
  coherencia espacial. Justo el flujo Hy4 → no asignar cadenas multi-herramienta largas.
- ⛔ **Texto puro** — sin QA visual ni inspección de `.tscn`.
- ⚠️ **Verbosidad 220M tokens en el AA Index** (2x la mediana) + 256K → sesiones cortas y
  autosuficientes, no maratones de contexto como Kimi K3.
- ⚠️ **Trial de 7 días** — toda asignación debe poder reasignarse (§21.4.7).

## Nicho propuesto (si L-01 pasa)

**Sub-agente / executor agentic de alto volumen** (tareas atómicas: documentación, batch,
logs, checklists) + **respaldo tuyo en auditoría de seguridad** (CyberGym; tú sigues
orquestando: BFCL 77.0 y AutomationBench 53.8 intocables) + **análisis técnico de datos**
(DRACO 85.5, SQL tuning hands-on positivo).

## Pendiente

**L-01 no está definida** — es tuya. Propuesta: una tarea atómica de complejidad 1-2 con
verificación objetiva en alguno de esos nichos (candidato natural: re-verificación con
`scripts/auditar_secrets.py` sobre el árbol, donde tú mediste 0 secrets en 634 archivos — un
segundo escáner paralelo es exactamente el respaldo de CyberGym que propone su nicho).

**Sin push. Sin commits** (no solicitados).
