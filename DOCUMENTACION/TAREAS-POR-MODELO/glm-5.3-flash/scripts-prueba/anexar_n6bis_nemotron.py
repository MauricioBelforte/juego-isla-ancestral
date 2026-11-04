# -*- coding: utf-8 -*-
"""Adenda 2 a la ficha N.6: datos independientes (Artificial Analysis) + veredicto de nichos操作性."""
ADENDA = """

### N.6-bis ADENDA — datos independientes + veredicto operativo (2026-10-25 ~21:40, GLM-5.3-Flash / Kilo Code)

**Fuentes:** artificialanalysis.ai/models/nemotron-3-5-super-vl + openrouter.ai/nvidia/nemotron-3.5-super-vl:free + llm-stats.com + benchlm.ai.

- **Medición independiente confirmada (Artificial Analysis):** Intelligence Index **26 — N.1 de 67 modelos open-weights de su clase Medium (40B-150B)** (mediana de clase: 8). La de maker (charla NVIDIA) quedó ratificada por terceros.
- **Velocidad de elite: 446.2 t/s** (mediana de 8 providers; mediana de clase: 106.4) y **TTFT 0.73s** (clase: 1.91s). Para contexto de flota: Beam 1.0 andaba en 342.9 t/s — Super VL corre MAS rapido.
- **Costo (tier pago): $0.23/M input, $0.57/M output** (barato). **Hay tier FREE en OpenRouter: `nvidia/nemotron-3.5-super-vl:free`** — mismo camino de integracion que Beam/MiniMax.
- **Licencia OpenMDW-1.1: uso comercial permitido** (mejor que "Commercial Use Restricted"). Pesos abiertos.
- **Es modelo REASONING** (con thinking). **Input: texto + imagen** (vision nativa confirmada por AA; video/documentos via preprocessing). Contexto **1M**.
- **Verboso: 170M tokens por Intelligence Index vs mediana 100M** — genera el doble de texto por tarea; en free no cuesta $, pero alarga turnos.
- **Señal mixta honesta:** BenchLM.ai (tercero) lo pone #104/228 con 49.23/100 "Estimated" — en su indice generalista queda medio-pack. Contraste: AA lo sube #1 de clase con benchmark agentic (Terminal-Bench 4.0 + AutomationBench-AA integrados a su indice). Tomar AA como comparable con los datos que usamos para la flota, y BenchLM como bandera de cautela.
- **Contraste con la flota:** Beam 1.0 = AA 30 (y AIME N.1 97.7) — Sigue por delante como razonador matematico. Super VL (26) NO lo reemplaza ahi: aporta lo que la flota NO tiene: **vision por API**.

**Veredicto operativo (propuesta a decision del fundador):**

1. **Nicho N.1 de este agente: QA VISUAL por API (venia M154)** — ver capturas reales del juego desde un canal sin PC del fundador. Primero de la flota con ojos nativos. Sirve para tandas visuales: UI/UX (M53), herramientas (M13), camara (M12), agua (M51), vegetacion (M50), carga/progress bars (M63), mapa (M54): validar "se ve bien / que falta / sonido o UI rota" sobre capturas reales del repo (capturas/ ya versionadas por modulo).
2. **Nicho secundario: document intelligence** (tablas de checklists, graficos, OCR de capturas/capturas de estado) y **picking [S]/[C] por velocidad** (446 t/s: tandas micro muy rapidas; complementa a Beam en volumen documental).
3. **NO delegarle:** matematica dura de balance (M93/M95: eso es de Beam), ni verificaciones de codigo GDScript critico en primera linea (12B activos; su coding agentic esta medido arriba del predecesor pero sin numero publico en SWE-Verified — T1 lo dira).
4. **T1 de calibracion sugerida (3 tareas, verificador: director o su delegado):**
   - T1.1 VISION: 1 captura real del juego (tomar de capturas/ de cualquier modulo): que describe, que detecta roto/mejorable. Criterio: descripciones verificables en disco (elementos de UI reales de esa captura).
   - T1.2 CITAS: picking documental con linea textual + cita de modulo (patron flota). Criterio: citas exactas.
   - T1.3 CODIGO: 1 fix pequerio con test o 1 analisis de modulo small (12B activos: medir el techo real).
5. **Riesgos a verificar en T1:** (a) que el endpoint FREE exponga imagenes de verdad (si no, el nicho 1 muere), (b) rate-limit del free (leccion MiniMax: tiers gratis mueren sin aviso — su herencia debe quedar en el repo), (c) verbosidad en tandas largas.
6. **Independencia 21.8:** modelo NUEVO y DISTINTO de los 9 actuales — puede verificar y ser verificado por cualquiera de la flota.

Firma adenda: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-25.
"""

P = r"DOCUMENTACION\GUIA-COMPARATIVA-MODELOS\GUIA-COMPARATIVA-MODELOS-V1.md"
with open(P, "a", encoding="utf-8", newline="\n") as f:
    f.write(ADENDA)
print("ADENDA ANEXADA")
