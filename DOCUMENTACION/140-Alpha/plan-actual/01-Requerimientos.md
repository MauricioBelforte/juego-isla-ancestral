**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 140: Alpha

## ID del Módulo
- **Código:** M140 (CHECKLIST-GLOBAL: ID 140 — Alpha; plan maestro: sección 139 "ALPHA")
- **Carpeta:** `DOCUMENTACION/140-Alpha/`
- **Dependencias:** M139 (Pre-Alpha). Relaciones: M22 (Historia Principal), M23 (Historias Secundarias), M26 (Templos), M24 (Puzzles), M27 (Islas), M28 (Viajes), M38 (Economía), M93 (Balance), M61-M63 (Rendimiento/Memoria/Streaming), M101 (QA General), M102 (Bug Tracking), M112 (Testing Automático), M114 (Playtest), M07 (Arquitectura), M60 (Datos), M31 (Ciclo Día/Noche), M41-M44 (Audio), M64 (IA NPC), M17 (Construcción), M19 (NPC), M59 (Guardado), M136 (Roadmap), M137/M138/M139 (fases previas)
- **Delegable desde:** M139 (Pre-Alpha), M136 (Roadmap)

## 1. Problema

El Pre-Alpha (M139) entregó "un mundo" intepretable (Aurora completa, sistemas piloto). El salto a **Alpha** es el de "mundo jugable" a "juego completo": en Alpha entran TODAS las mecánicas principales del diseño (historia jugable de punta a punta, todos los sistemas principales integrados y comunicando), el primer balance real, contenido suficiente para una partida completa, rendimiento medible por plataforma y un QA intensivo que convierte bugs en deuda técnica reducida. Si Alpha no se define con criterios medibles, el proyecto entra en "beta para siempre" — por eso este módulo fija la puerta de salida con hits objetivos.

## 2. Objetivo

Completar el salto de mundo Pre-Alpha a **juego Alpha:** todas las mecánicas principales presentes en el núcleo (sin "missing features" de diseño central), historia principal jugable de inicio a fin con los 6 Sellos como esqueleto narrativo (M22/M153), todos los sistemas principales integrados entre sí (economía↔construcción↔amistad↔templos↔viajes), primer balance cuantitativo validado por simulación (M93/M38), contenido suficiente para una partida completa (metas de 60-100 h si el jugador las busca), rendimiento medible y presupuestado (M61-M63), QA intensivo con ciclo cerrado bug→fix→regresión (M101/M102/M112/M114) y reducción explícita de deuda técnica con corrección de arquitectura (M07) — preparando la Beta (M141) con criterios GONOGO.

## 3. Alcance

### 3.1 Dentro del alcance
- **Historía jugable:** secuencia principal completa de los 6 Sellos, con Acto 1 (descubrimiento), Acto 2 (crisis) y Acto 3 (resolución) (M22/M23/M153).
- **Todas las mecánicas principales:** agricultura, pesca, minería, crafting, cocina, construcción, amistad avanzada, viajes entre islas, templos con puzzles complejos, artefactos y progresión completa (M33-M37, M16, M17, M20, M28, M26, M71, M73).
- **Sistemas integrados:** economía global conectada (M38/M93), tiendas por isla (M39), rutinas NPC completas por isla (M19/M64), clima y calendario afectan el mundo (M29-M32), audio completo por zona (M41-M44).
- **Primer balance completo:** precios, curvas, drops, XP/amistad, dificultad de puzzles, tiempos de cultivo — validado con simulación y playtests (M93/M114).
- **Rendimiento medible:** presupuestos de fase con telemetría (M61/M62/M63/M104/M105), profiling por plataforma objetivo.
- **QA intensivo:** un ciclo de hardening de 3-4 semanas con triaje, fix, regresión y métricas de bugs (M101/M102/M112).
- **Arquitectura corregida:** revisiones de diseño por sistema integrado; eliminación de *TODO/FIXME* de las fases previas (M07/M111).
- **Más contenido:** la ruta principal + rutas secundarias mayores, coleccionables completos (M73), museos (M37), eventos de temporada base (M74).

### 3.2 Fuera del alcance
- Contenido completo del 100% (llega en Beta, M141): localización total, pulido fino, balance final de todos los items de postgame.
- Integración de plataformas (M141) y store page final (M141/M97).
- Modo multijugador/postgame completo (M75/M76): solo semillas conceptuales ya existentes.

## 4. Restricciones

- **GONOGO explícito:** Alpha solo se declara cerrada cuando TODOS los hits H1-H10 están cumplidos y documentados (no hay "casi").
- **Presupuesto (M61):** 60 FPS media objetivo; los sistemas nuevos entran solo si su frame budget está medido.
- **Sin deuda nueva:** cada fix en QA paga su deuda asociada; la métrica de todo/FIXME pendiente baja a 0 al cierre (M111).
- **Historia coherente con canon:** la ruta de los Sellos debe cumplir M147 (biblia) y M153 (sin romper misterio).
- **Cozy (M152):** el contenido nuevo conserva ritmo amable; nada de grind obligatorio para avanzar la historia.
- **Save (M59/M60):** v3 extendido a todo el juego; migración sin pérdidas.
- **Accesibilidad (M58):** los sistemas nuevos respetan opciones de accesibilidad (sin reflejos críticos, subtítulos, remapeo).

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Historia jugable completa | Secuencia de 6 Sellos con Actos 1-3 (M22/M153) |
| RF2 | Todas las mecánicas principales | Agricultura, pesca, minería, crafting, cocina, construcción, amistad, viajes, templos, artefactos (M33-M37, M16-M17, M20, M28, M26, M13) |
| RF3 | Sistemas integrados | Economía global, NPC con rutinas por isla, clima/calendario sobre el mundo, audio por zona |
| RF4 | Primer balance completo | Curvas validadas por simulación y playtest (M93/M38/M114) |
| RF5 | Contenido suficiente | Partida completa: ruta principal + secundarias + coleccionables (M71/M73/M37/M74) |
| RF6 | Rendimiento medible | Presupuestos por plataforma con telemetría (M61-M63/M104/M105) |
| RF7 | QA intensivo | 3-4 semanas de hardening; ciclo bug→fix→regresión cerrado (M101/M102/M112) |
| RF8 | Corrección de arquitectura | Revisiones por sistema; 0 TODO/FIXME al cierre (M07/M111) |
| RF9 | Reducción de deuda técnica | Deuda documentada en M135 y pagada en el sprint; métrica visible |
| RF10 | Preparar Beta | GONOGO-BETA (M141) con criterios objetivos y backlog priorizado |

## 6. Criterios de Aceptación (Verificables)

1. RF1: la ruta de Sellos se juega de inicio a fin sin bloqueos y con coherencia de canon (M147/M153).
2. RF2: no existe ninguna mecánica principal del diseño central ausente; el 100% de los items de M71 (Progresión) está presente en alguna forma.
3. RF3: 3 integraciones cruzadas demostradas por sistema (ej: la amistad de Obé afecta precios; el clima afecta cultivos y rutas).
4. RF4: la simulación M93 corre en CI y no encuentra desbalance crítico en 40 h de juego simulado.
5. RF5: una partida completa dura 60-100 h si el jugador busca completar (todos los coleccionables y sellos).
6. RF6: los presupuestos M61-M63 se miden en builds semanales y se cumplen en la plataforma objetivo.
7. RF7: el backlog de bugs conocidos críticos/altos queda en 0 al cierre (solo bajos aceptables documentados).
8. RF8: 0 TO-DO/FIXME pendientes en el repositorio al cierre (M111).
9. RF9: la deuda técnica de M135 se redujo al menos un 50% y su métrica está documentada.
10. RF10: el documento GONOGO-BETA existe, está firmado y el backlog de Beta (M141) tiene prioridad y esfuerzo.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M139** — Pre-Alpha | Alpha sobre pre-alpha |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M141** — Beta | Beta |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M139** — Pre-Alpha | Depende de este módulo |
| **M141** — Beta | Este módulo lo necesita |

