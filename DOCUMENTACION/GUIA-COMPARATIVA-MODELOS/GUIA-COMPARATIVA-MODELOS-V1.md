### 6. Glyph Cluster (Tencent Hunyuan / Kilo Code) — **EN FLOTA** (lanzado 2026-10-07)

**Rol:** Razonamiento para código y análisis de largo contexto, acoplamiento, dependencias circulares, arquitecturas de UI, progresión, físicas, colisiones, migraciones, debugging profundo.

**Evidencia empírica verificada (fuente oficial Tencent/Vercel):**
- 224B total params (64B Engram), 12B active/token.
- 256K contexto de entrada y salida, texto solo (sin imágenes, sin archivos, sin audio).
- Tool calling (funciones definidas por usuario), streaming, razonamiento xhigh.
- Especialidad: análisis de acoplamiento, dependencias circulares entre autoloads, arquitecturas de UI, sistemas de progresión, físicas y colisiones.
- También es excelente para: planificación de migraciones de código, debugging de fallos, cuantitativo, comparación de información en entradas largas, análisis de sistemas complejos, código en cualquier lenguaje.
- Modelo gratuito en Vercel AI Gateway (stealth/glyph-cluster), proveedor kilo.

**Debilidades:** Sin entrada de imágenes o archivos, sin salida estructurada (JSON schema), prompts y respuestas pueden ser retenidos para entrenamiento (no usar con datos sensibles).

**Regla de asignación:** Análisis de arquitectura profunda, detección de acoplamiento y dependencias circulares, UI, progresión, físicas, colisiones, refactorización compleja, migraciones de código, debugging de fallos, análisis de largo contexto (hasta 256K tokens).

---

### 7. Reflection-Beam-1.0 (Reflection AI / Kilo Code) — **EN FLOTA** (lanzado 2026-10-16)

**Rol:** Auditoría de consistencia, contadores, fórmulas, off-by-one, verificación CHECKLIST-GLOBAL, conteos exactos, razonamiento matemático y científico, software engineering, agente de herramientas.

**Evidencia empírica verificada (fuente oficial Reflection AI/Hugging Face):**
- 501B total params (Mixture-of-Experts), 23B active/token.
- 1M contexto de entrada, texto solo.
- Soporta tool calling, razonamiento matemático y científico, software engineering, agente de herramientas (MCP, navegación web).
- Especialidad: contadores, fórmulas, off-by-one, verificación CHECKLIST-GLOBAL, conteos exactos.
- También es excelente para: resolver issues de GitHub reales, operar en CLI y DevOps, integrarse con herramientas de codificación agente, código en múltiples lenguajes, razonamiento matemático complejo, planificación de largo alcance, evaluación de políticas, análisis de datos.
- Modelo gratuito en WorkBuddy/Kilo Code (reflection/Beam-1.0-501B-A23B), proveedor kilo.

**Debilidades:** Ediciones rápidas de funciones existentes sin releer scope (puede introducir cambios no intencionados), conteo sesgado por memoria en lugar de por prefijo (necesita validación cruzada), no auto-sellarse (siempre pide QA cruzado).

**Regla de asignación:** Auditoría de consistencia, contadores, fórmulas, off-by-one, verificación CHECKLIST-GLOBAL, conteos exactos, fórmulas de balance, validación de entrada, razonamiento matemático complejo, software engineering en CLI/DevOps, integración con herramientas de codificación agente.

---

## Reglas de uso

- Protocolo de comunicación: `Mensajes entre modelos/GUIA-COMUNICACION.md`.
- Protocolo multiagente: `CHECKLIST-GLOBAL.md` §21.

**Modelo:** Gemini 3.8 Flash / Nemotron-3.5-Super-VL (editor)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-17