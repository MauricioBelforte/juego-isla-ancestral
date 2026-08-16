**Modelo:** Devin
**Plataforma:** Antigravity

# 01-Requerimientos.md — Módulo 152: Principios Innegociables

## ID del Módulo
- **Código:** M152 (plan maestro: sección 151 — Principios que no deberían perderse)
- **Carpeta:** `DOCUMENTACION/152-Principios-Innegociables/`
- **Dependencias:** M01 (Fundamentos del Proyecto), M02 (Visión y Concepto). Dependen de este: Todos los módulos de diseño e implementación
- **Carácter:** Módulo de principios de diseño y guía de desarrollo (no código)

## 1. Problema

El proyecto necesita **principios innegociables** que guíen todas las decisiones de diseño e implementación para mantener la visión original del juego y evitar desviaciones que comprometan la experiencia cozy.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | No agregar combate simplemente porque "todo juego necesita combate" | Si no aporta a la visión cozy, no agregar combate |
| RF2 | No convertir el juego en un survival de hambre si contradice la visión | Mantener filosofía cozy, sin FOMO ni castigos irreversibles |
| RF3 | No castigar al jugador por jugar poco | El juego debe ser disfrutable a cualquier ritmo |
| RF4 | No obligar al jugador a optimizar constantemente | Evitar metagaming forzado |
| RF5 | No hacer que todos los NPC sean iguales | Variedad en personalidades, historias, roles |
| RF6 | No llenar el mundo únicamente con contenido procedural vacío | Balance entre procedural y contenido curado |
| RF7 | No usar puzzles arbitrarios | Puzzles con lógica clara y propósito narrativo |
| RF8 | No esconder información esencial detrás de una sola acción fácilmente perdible | Información accesible y redundante |
| RF9 | No diseñar la economía alrededor del grind | Economía cozy, sin grind forzado |
| RF10 | No sacrificar rendimiento por una pequeña mejora visual | Performance prioridad sobre bells and whistles |
| RF11 | No añadir sistemas sin comprobar que aporten algo | Cada sistema debe tener propósito claro |
| RF12 | No ampliar el mapa solamente para hacerlo grande | Calidad > cantidad |
| RF13 | No confundir cantidad con profundidad | Profundidad mecánica > cantidad de contenido |
| RF14 | No introducir monetización que destruya la experiencia | Si hay monetización, debe ser opcional y no intrusiva |
| RF15 | No depender de servicios externos sin plan de contingencia | Offline-first, fallbacks para servicios externos |
| RF16 | No utilizar assets sin licencia clara | Licencias claras y documentadas |
| RF17 | No depender de una sola persona para conocimiento crítico del proyecto | Documentación, pair programming, knowledge sharing |

## 3. Requisitos No Funcionales

- Los principios deben ser consultados antes de cada decisión de diseño
- Los principios deben ser visibles para todo el equipo
- Los principios deben ser revisados periódicamente
- Cualquier desviación de los principios debe ser justificada explícitamente

## 4. Criterios de Aceptación

1. Los 17 puntos de la sección 151 del plan maestro resueltos.
2. Principios documentados con explicaciones claras.
3. Ejemplos de aplicación de cada principio.
4. Proceso de revisión de decisiones contra principios.
5. Mecanismo para registrar desviaciones justificadas.
