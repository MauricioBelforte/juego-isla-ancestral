**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 04: Game Engine

## ID del Módulo
- **Código:** M04 (plan maestro: sección 3 — Game Engine)
- **Carpeta:** `DOCUMENTACION/04-Game-Engine/`
- **Dependencias:** M01 (Fundamentos), M02 (Documentación). **Dependen de este:** M05 (Lenguaje), M07 (Arquitectura), M57 (Interfaz de Control), y todos los módulos de gameplay.

## 1. Problema

El motor define el costo, la viabilidad técnica del voxel (el riesgo #1 del proyecto) y el flujo de trabajo de todos los módulos siguientes. Migrar un sistema voxel de motor después del prototipo equivale a empezar de nuevo (Plan-de-produccion §2). La decisión debe cerrarse ANTES de escribir código de juego.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Soporte voxel editable | Terreno por bloques, extracción/colocación, colisiones voxel, rendimiento 60 FPS |
| RF2 | Face culling / greedy meshing | Solo caras visibles (GDD directiva 1) |
| RF3 | Threading de generación | Remallado de chunks sin bloquear el hilo principal |
| RF4 | LOD y streaming | Chunks lejanos con menos detalle; streaming entre islas |
| RF5 | Costo cero o bajo | Autofinanciado sin presupuesto asegurado |
| RF6 | Exportación multiplataforma | PC (Windows/Linux) + Steam Deck |
| RF7 | Pipeline de audio/UI/animación | Suficiente para cozy sim + puzles |
| RF8 | Integración con herramientas IA/MCP | El usuario desarrolla con agentes IA |

## 3. Requisitos No Funcionales

- Sin regalías ni fee por instalación que pongan en riesgo el modelo autofinanciado.
- Comunidad y documentación suficientes para resolver problemas sin freelance.
- Versión del motor FIJADA durante producción (no actualizar arbitrariamente — plan maestro §3).
- Curva de aprendizaje razonable para el usuario (equipo de 1 persona).

## 4. Criterios de Aceptación

1. Motor elegido con justificación documentada contra los criterios del plan maestro (30 puntos).
2. Versión exacta fijada y registrada.
3. Proyecto base creado con: render pipeline, input, física, capas, tags, escena inicial, build profile.
4. El prototipo del hito M1 valida 60 FPS voxel sobre la elección.

## 5. Restricciones

- La decisión NO puede invertirse después del hito M1 sin re-planificación completa.
- El GDD exige voxel a 60 FPS: esa es la vara mínima del motor.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M001** — Fundamentos del Proyecto | Decisiones de motor y plataforma |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M005** — Lenguaje y Programación | Convenciones GDScript |
| **M007** — Arquitectura General | Arquitectura del engine |
| **M057** — Interfaz de Control | Sistema de entrada |
| **M096** — Plataformas | Multiplataforma |
| **M103** — Logging | Logging |
| **M109** — Herramientas Internas | Herramientas internas |
| **M110** — Debug Menu | Debug menu |
| **M111** — Código de Calidad | Código de calidad |
| **M115** — Hardware | Hardware |
| **M154** — Visión del Agente | Visión del agente |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M001** — Fundamentos del Proyecto | Depende de este módulo |
| **M005** — Lenguaje y Programación | Este módulo lo necesita |
| **M007** — Arquitectura General | Este módulo lo necesita |
| **M057** — Interfaz de Control | Este módulo lo necesita |
| **M096** — Plataformas | Este módulo lo necesita |
| **M103** — Logging | Este módulo lo necesita |
| **M109** — Herramientas Internas | Este módulo lo necesita |
| **M110** — Debug Menu | Este módulo lo necesita |

