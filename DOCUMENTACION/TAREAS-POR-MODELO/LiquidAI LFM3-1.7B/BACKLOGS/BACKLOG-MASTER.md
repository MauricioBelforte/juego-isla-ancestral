# Backlog Master — LiquidAI LFM3-1.7B

**Modelo:** LiquidAI LFM3-1.7B (`LiquidAI/LFM3-1.7B`)  
**Plataforma:** LiquidAI (Kilo Code / OpenRouter / Ollama)  
**Estado:** En prueba — supervisado por Nemotron-3.5-Super-VL  
**Fecha:** 2026-11-09  
**Rol:** Sub-agente de bajo costo para tareas simples de agente, tool calling, documentación ligera, razonamiento simple en edge

## Capacidades verificadas (investigación web)

- 1.73B parámetros, tri-hybrid architecture (13 gated short convolutions + 5 sliding-window attention + 6 global attention)
- 256K contexto (input + output)
- Texto solo (no multimodal)
- Razonamiento siempre ON por defecto
- Tool calling soportado
- Structured outputs soportado
- Precio: Gratis (open license)
- Licencia: LFM Open License v1.0
- ~1 GB de memoria en Q4 (corre en teléfonos y laptops)
- Post-treinado para agent harnesses (Hermes Agent, Pi, OpenClaw, OpenCode)
- No recomendado para agentic coding o multi-step reasoning complejo (por su tamaño pequeño)
- Ideal para tareas simples de agente, triage, local agents, tool calling

## Áreas de asignación (modelo en prueba)

- Tareas simples de agente (triage de mensajes, clasificación de informes)
- Tool calling simple (extracción de información de archivos)
- Documentación ligera (resúmenes cortos, notas de versión)
- Verificación de existencia de archivos y rutas
- Lectura de archivos de configuración simples (.ini, .cfg, .json)
- Triage de reportes de otros modelos (clasificar por severidad inicial)
- Búsqueda de términos clave en código (grep-like)

## Áreas NO asignadas

- Razonamiento complejo o multi-step (usar dots3-note)
- Análisis de arquitectura de código (usar Glyph Cluster)
- Escaneo estático masivo (usar Crouton Alpha)
- Análisis multimodal (usar dots3-note)
- Depuración de lógica compleja (usar Glyph Cluster)

## Método de trabajo

Tarea simple → leer archivo/contexto → responder con hallazgo directo → confirmar. Para tareas de bajo costo y alta repetición.

## Reportes escritos

Carpeta: `Mensajes entre modelos/LiquidAI LFM3-1.7B/REPORTES-Prueba-Paralela/`

## Supervisión

Supervisado por Nemotron-3.5-Super-VL. No recibe módulos críticos sin previa revisión. Razonamiento: xhigh.

---

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-09
