# Backlog Master — Cohere North Mini Code

**Modelo:** Cohere North Mini Code (`north-mini-code-1.0`)  
**Plataforma:** Stealth/Cohere (Kilo Code / OpenRouter)  
**Estado:** En prueba — supervisado por Nemotron-3.5-Super-VL  
**Fecha:** 2026-11-09  
**Rol:** Escaneo estático masivo de código Godot/C#, detección de problemas con archivo:línea, verificación de assets/rutas, cleanup de código (sub-agente de bajo costo, alto volumen)

## Capacidades verificadas (investigación web)

- 30B total / 3B active parameters, MoE sparse (8 de 128 experts)
- 256K contexto entrada / 64K salida
- Razonamiento siempre ON (interleaved thinking)
- Tool calling con JSON schema
- Structured outputs: NO (solo texto)
- Precio: $0 (preview en OpenRouter)
- Licencia: Apache 2.0
- Benchmark: 33.4 en Artificial Analysis Coding Index (supera a Nemotron 3 Super 120B-A12B, Mistral Small 4, Devstral 2 en su clase)
- Benchmarks: 36.0 Terminal-Bench, 31.1 Terminal-Bench Hard, 67.6 SWE-bench Verified, 40.2 SWE-bench Pro
- Multilingual: texto solo (no imagen, video, audio)

## Áreas de asignación (modelo en prueba)

- Escaneo estático masivo de archivos .gd (vars sin usar, params sin usar, funciones vacías, imports sin usar)
- Verificación de assets .import y rutas rotas en escenas .tscn/.tres
- Cleanup de naming, variables y constantes sin usar
- Detección de código muerto en scripts Godot
- Análisis de logging y rotación de logs
- Verificación de consistencia de CHECKLIST-GLOBAL.md

## Áreas NO asignadas

- Diseño de arquitectura de sistemas (usar Glyph Cluster)
- Debugging complejo que requiera contexto cruzado entre múltiples archivos (usar Glyph Cluster)
- Razonamiento de largo horizonte (usar dots3-note)
- Análisis multimodal (usar dots3-note)

## Método de trabajo

Lotes → suite con binario real → piso CHECKS_MINIMOS medido → sonda rojo demostrada → [x] solo con suite en verde.

## Reportes escritos

Carpeta: `Mensajes entre modelos/Cohere North Mini Code/REPORTES-Prueba-Paralela/`

## Supervisión

Supervisado por Nemotron-3.5-Super-VL. No recibe módulos críticos sin previa revisión. Razonamiento: xhigh.

---

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-09
