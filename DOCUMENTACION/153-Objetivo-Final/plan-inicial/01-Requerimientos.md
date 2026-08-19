**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 153: Objetivo Final del Proyecto

## ID del Módulo
- **Código:** M153 (CHECKLIST-GLOBAL: ID 153 — Objetivo Final del Proyecto; plan maestro: sección 152 "OBJETIVO FINAL DEL PROYECTO")
- **Carpeta:** `DOCUMENTACION/153-Objetivo-Final/`
- **Dependencias:** M151 (Principios que no deberían perderse). Relaciones: TODOS los módulos (es la visión transversal); centrales: M21 (Historia), M15 (Construcción), M18/M19 (NPC/Amistad), M24 (Ruinas), M26-M28 (Islas/Viajes), M40-M44 (Audio), M74 (Postgame), M10 (Jugador), M09 (Generación)
- **Estado previo:** 🔵 En curso por B2-Composer desde 2026-08-16 17:35 con 0 de avance (no existía carpeta); **RECLAMADO por Deepseek V4 Flash** el 2026-08-19 por inactividad >24 h (regla 21.4.7)

## 1. Problema

El plan maestro cierra con 19 compromisos de VISIÓN: Aurora como hogar, curiosidad por la siguiente isla, recordar a los NPC, curiosidad por las ruinas, disfrutar construyendo sin avanzar la historia, poder ignorar la historia, poder perseguirla, construcciones que importan, decisiones que afectan el entorno, comprender la historia de la Resonancia, mundo que continúa tras los créditos, ampliabilidad con islas sin romper arquitectura, contenido que reutiliza sistemas, coherencia del mundo, tecnología al servicio de la experiencia, experiencia al servicio de la historia, historia que refuerza la identidad, mundo agradable sin eventos, quedarse escuchando música mirando el mar. **El problema:** estos 19 objetivos son el "por qué" del proyecto, pero sin convertirse en criterios de diseño verificables se pierden en el desarrollo (cada módulo los olvida).

## 2. Objetivo

Convertir los 19 objetivos en un **contrato de visión verificable**: cada objetivo → criterio de aceptación → módulo(s) dueño(s) → indicador de cumplimiento. Este documento es la vara final del proyecto: el juego NO está terminado hasta que TODOS los criterios se cumplen (se usa en el Control Final M150 y en el QA cruzado).

## 3. Alcance

### 3.1 Dentro del alcance
- Los 19 objetivos del plan maestro como contrato con criterio verificable y módulos dueños.
- Métricas/indicadores de cumplimiento por objetivo (dónde se observa en el juego).
- Regla de integración: cada módulo nuevo declara qué objetivos refuerza.
- Plantilla de "prueba de visión" para playtests y QA (M113/M101).
- Validación: `validate_vision.gd` (lista de objetivos ↔ módulos dueños).

### 3.2 Fuera del alcance
- La implementación de cada objetivo (vive en sus módulos dueños).
- Los principios (cero combate, cero FOMO...): son M151, ya documentado.

## 4. Restricciones

- **Verificable:** cada objetivo tiene UN criterio de aceptación observable (nunca "se siente bien" a secas).
- **Coherente con el cozy:** cero presión, cero castigos, cero grindeo (refuerza M151).
- **Transversal:** no acopla código (es visión + validación); ningún módulo depende técnicamente de M153.
- **Ampliable:** nuevos objetivos futuros se agregan al contrato con su criterio.
- **Validable:** `validate_vision.gd` sin errores en editor.

## 5. Requisitos Funcionales (19 objetivos → contrato)

| # | Objetivo (plan maestro) | Criterio verificable | Módulos dueños |
|---|---|---|---|
| O1 | Aurora como hogar | El jugador personaliza su casa (M17) y vuelve a ella voluntariamente ≥1 vez por sesión de 30 min | M17, M15, M18 |
| O2 | Querer explorar la siguiente isla | El jugador ve la siguiente isla (M26) y el viaje se siente deseable (M27/M28) | M26, M27, M28 |
| O3 | Recordar a los NPC | ≥2 vecinos recordados por nombre tras 3 sesiones (verificable en test de memoria, M113) | M18, M19, M21 |
| O4 | Curiosidad por las ruinas | Las ruinas visibles (M24) invitan a acercarse sin tutorial (métricas de aproximación, M104) | M24, M25 |
| O5 | Disfrutar construyendo sin avanzar historia | 15+ min de construcción continua sin progreso de historia y con disfrute (playtest, M113) | M15, M16, M17 |
| O6 | Poder ignorar la historia | El mundo vive completo sin tocar misiones (M22); sin bloqueos por falta de historia | M22, M15, M74 |
| O7 | Poder perseguir la historia cuando quiera | Objetivo activo siempre visible (M53 diario), sin ventanas de tiempo | M22, M53, M92 |
| O8 | Construcciones que importan | Construir desbloquea contenido (vecinos M18, eventos M74); el mundo recuerda (M59) | M15, M18, M74 |
| O9 | Decisiones que afectan el entorno | Elige de orden de eventos (M74) y construcción altera el mapa visible (M54) | M74, M15, M54 |
| O10 | Comprender la historia de la Resonancia | Al terminar M21 el jugador explica la Resonancia en sus palabras (test narrativo M113) | M21, M23 |
| O11 | Mundo continúa tras los créditos | Postgame activo (M75) con vida propia ≥10 h post-créditos | M74, M75 |
| O12 | Ampliable con islas sin romper arquitectura | Agregar una isla nueva (M26) NO requiere cambiar sistemas centrales (check modular M06/M15) | M06, M26 |
| O13 | Contenido que reutiliza sistemas | Todo contenido nuevo usa sistemas existentes (regla de checklist global: sin duplicación) | Todos |
| O14 | Mundo coherente | Sin contradicciones narrativas/lógicas en QA transversal (M101/M113) | M21, M23, M57 |
| O15 | Tecnología al servicio de la experiencia | Cada sistema técnico declara qué experiencia sirve (documentado en su 01-Requerimientos) | Todos |
| O16 | Experiencia al servicio de la historia | Cada mecánica refuerza al menos un hilo de M21/M23 | M21, M23 |
| O17 | Historia refuerza identidad del mundo | El lore (M146/M147) y la historia se integran (documentos M73, ruinas M24) | M146, M147, M24 |
| O18 | Mundo agradable sin eventos | 30 min sin eventos con disfrute medido (playtest M113, telemetría M104) | M30, M31, M40 |
| O19 | Quedarse escuchando música mirando el mar | Audio M40-M43 + vista al mar (M10/M11) invitan a la pausa; criterio: ≥2 momentos de 5 min sin input en playtest | M40, M41, M42, M43, M10 |

## 6. Criterios de Aceptación

1. Los 19 objetivos tienen criterio verificable y módulos dueños (tabla §5).
2. Cada módulo nuevo declara en su `01-Requerimientos.md` qué objetivos (O#) refuerza.
3. `validate_vision.gd` valida la tabla (objetivos ↔ dueños) sin errores.
4. El Control Final (M150) usa este contrato como lista de verificación.
5. El QA (M113/M101) incluye la "prueba de visión" (O1-O19) en cada playtest importante.
6. Ningún objetivo contradice los principios de M151 (cero combate, cero FOMO, sin grind).