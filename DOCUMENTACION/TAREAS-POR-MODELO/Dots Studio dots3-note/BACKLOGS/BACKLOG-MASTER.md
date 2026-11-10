# Backlog Master — Dots Studio dots3-note

**Modelo:** Dots Studio dots3-note Preview (`dots-studio/dots3-note-prev`)  
**Plataforma:** Stealth/Dots Studio (Kilo Code / OpenRouter)  
**Estado:** En prueba — supervisado por Nemotron-3.5-Super-VL  
**Fecha:** 2026-11-09  
**Rol:** Análisis multimodal (texturas, modelos 3D, escenas .tscn con imágenes), razonamiento de largo horizonte (TEMPO), tareas que requieren contexto de 512K, análisis de assets visuales

## Capacidades verificadas (investigación web)

- 280B total / 16B active parameters, MoE sparse (256 routed + 1 shared expert, top-8)
- 512K contexto entrada / 512K salida
- Multimodal: texto, imagen, video, audio → texto
- Razonamiento TEMPO (test-time-scaled reasoning para largo horizonte)
- Tool calling con JSON schema
- Structured outputs: Sí (response_format)
- Precio: $0 (preview en OpenRouter)
- Licencia: Apache 2.0
- Benchmarks: 78.4% SWE-bench Verified, 61% SWE-bench Pro, 79.1% MMMU Pro, 52.6% HLE
- Arquitectura: 45 MoE layers + 1 dense, 256 experts, top-8, hidden size 5120
- Vision encoder: MoE ViT 7B total / 1.2B active
- Audio encoder: dense 800M
- TEMPO: decomposice tareas largas en macro-steps con auto-evaluación entre cada paso

## Áreas de asignación (modelo en prueba)

- Análisis de escenas .tscn con imágenes/texturas (calidad visual, resoluciones inconsistentes)
- Análisis de modelos 3D .glb/.gltf (escalas arbitrarias, materiales, LOD)
- Análisis de texturas .png/.jpg/.webp (resolución excesiva para el uso)
- Razonamiento de largo horizonte (tareas que requieren múltiples pasos y auto-evaluación)
- Contexto de 512K para análisis de grandes bases de código sin fragmentar
- Revisión de documentación con diagramas y capturas de pantalla
- Detección de problemas de rendimiento visual (demasiadas partículas, sombras, etc.)

## Áreas NO asignadas

- Escaneo estático masivo de .gd (usar Crouton Alpha)
- Análisis de arquitectura de código puro (usar Glyph Cluster)
- Tareas repetitivas de bajo costo (usar Crouton Alpha)

## Método de trabajo

Análisis profundo → citas de archivo:línea → 2 mejoras de diseño concretas con código → conclusión técnica. Para tareas de largo horizonte: descomponer en macro-steps con auto-evaluación entre cada paso.

## Reportes escritos

Carpeta: `Mensajes entre modelos/Dots Studio dots3-note/REPORTES-Prueba-Paralela/`

## Supervisión

Supervisado por Nemotron-3.5-Super-VL. No recibe módulos críticos sin previa revisión. Razonamiento: xhigh.

---

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-09
