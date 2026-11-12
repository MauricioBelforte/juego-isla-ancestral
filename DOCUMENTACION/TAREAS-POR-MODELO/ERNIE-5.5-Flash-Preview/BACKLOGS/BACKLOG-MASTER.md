# Backlog Master — ERNIE-5.5-Flash-Preview (Baidu)

**Modelo:** ERNIE-5.5-Flash-Preview (`baidu/ernie-5.5-flash-preview`)  
**Plataforma:** Stealth/Baidu (Kilo Code / OpenRouter)  
**Estado:** En prueba — supervisado por Nemotron-3.5-Super-VL  
**Fecha:** 2026-11-11  
**Rol:** Análisis multimodal (texturas, modelos 3D, escenas .tscn con imágenes), razonamiento de largo horizonte (TEMPO), tareas que requieren contexto de 1M, análisis de assets visuales

## Capacidades verificadas (investigación web)

- 280B total / 14B active parameters, MoE sparse (256 routed + 1 shared expert, top-8)
- 1M contexto entrada / hasta 1M salida
- Multimodal: texto, imagen, video, audio → texto (texto solo como salida)
- Razonamiento TEMPO (test-time-scaled reasoning para largo horizonte)
- Tool calling con JSON schema
- Structured outputs: Sí (JSON schema)
- Precio: $0.28/M input / $1.13/M output (modelo de pago, en preview)
- Licencia: Apache 2.0 (próximamente)
- Liberado: 2026-11-11
- Benchmarks oficiales (Baidu): Terminal-Bench 4.0 46.5%, DeepSWE v1.1 71.2%, AutomationBench 61.9%, APEX-Agents 1.1 64.2%, DRACO 84.9%, SpreadsheetBench V2 36.4%, OfficeQA Pro V2 67.9%
- Benchmarks de terceros: Terminal-Bench-Science 21.0, NL2Repo-Bench 64.8, Toolathlon-Verified 79.0, MCP-Atlas 84.6, BrowseComp 87.4, HLE sin tools 46.4, BlenderWorld text-only 79.0
- Arquitectura: 45 MoE layers + 1 dense, 256 experts, top-8, hidden size 5120
- Vision encoder: MoE ViT 7B total / 1.2B active
- Audio encoder: dense 800M
- Generación >200 tokens/segundo

## Áreas de asignación (modelo en prueba)

- Análisis de escenas .tscn con imágenes/texturas (calidad visual, resoluciones inconsistentes)
- Análisis de modelos 3D .glb/.gltf (escalas arbitrarias, materiales, LOD)
- Análisis de texturas .png/.jpg/.webp (resolución excesiva para el uso)
- Razonamiento de largo horizonte (tareas que requieren múltiples pasos y auto-evaluación)
- Contexto de 1M para análisis de grandes bases de código sin fragmentar
- Revisión de documentación con diagramas y capturas de pantalla
- Detección de problemas de rendimiento visual (demasiadas partículas, sombras, etc.)
- Análisis de documentos largos, reportes, hojas de cálculo
- Generación de scripts Python para Blender (modelado 3D procedural)

## Áreas NO asignadas

- Escaneo estático masivo de .gd (usar Crouton Alpha)
- Análisis de arquitectura de código puro (usar Glyph Cluster)
- Tareas repetitivas de bajo costo (usar Crouton Alpha)
- Salida de imagen/audio/video (solo texto como salida)

## Método de trabajo

Análisis profundo → citas de archivo:línea → 2 mejoras de diseño concretas con código → conclusión técnica. Para tareas de largo horizonte: descomponer en macro-steps con auto-evaluación entre cada paso.

## Reportes escritos

Carpeta: `Mensajes entre modelos/ERNIE-5.5-Flash-Preview/REPORTES-Prueba-Paralela/`

## Supervisión

Supervisado por Nemotron-3.5-Super-VL. No recibe módulos críticos sin previa revisión. Razonamiento: high.

---

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-11
