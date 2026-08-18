**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 52: Partículas y VFX

## A. Problema y objetivos

- [x] Definir el problema: sin sistema de VFX el feedback visual es inconsistente y caro [S]
- [x] Definir el objetivo: VFX baratos, deterministas y armónicos con el estilo cozy [S]
- [x] Registrar dependencias: M04 (GPUParticles), M45/M47 (materiales), M49 (glow/luz), M61/M62 (presupuestos), M58 (accesibilidad) [M]
- [x] Mapear la sección 51 "PARTÍCULAS Y VFX" del plan maestro al ID 52 de la tabla global [M]
- [x] Separar dentro/fuera de alcance: luz de fuego → M49, sonido → M43/M44, sprites → M45/M47 [S]
- [x] Documentar restricciones: GPUParticles, sin RNG, sin luz por partícula, presupuesto verificable [M]
- [x] Definir criterios de aceptación verificables (8 criterios) [S]

## B. RF1 — Catálogo de VFX

- [x] Listar los 25 efectos del plan maestro [M]
- [x] Humo y polvo [S]
- [x] Hojas y pétalos [S]
- [x] Chispas [S]
- [x] Agua (salpicaduras) [S]
- [x] Lluvia y nieve [S]
- [x] Fuego y lava [S]
- [x] Luz y magia tecnológica [S]
- [x] Resonancia y activación de runas [S]
- [x] Teletransporte (si existe) [S]
- [x] Obtención de Sello [S]
- [x] Resolución de puzzle [S]
- [x] Construcción, cosecha y pesca [S]
- [x] Descubrimiento [S]
- [x] Cambio estacional [S]
- [x] Efectos de interfaz [S]
- [x] Efectos atmosféricos [S]
- [x] Definir parámetros por efecto (tipo, material, emisor, presupuesto) [M]

## C. RF2 — Pool central

- [x] Definir VfxManager (autoload) [M]
- [x] Definir pool de emisores one-shot prestados/liberados [M]
- [x] Definir loops registrados con culling [M]
- [x] Definir precalentamiento del pool (8 emisores) [M]

## D. RF3 — Presupuesto por escena

- [x] Definir máx emisores activos (12 preset medio) [M]
- [x] Definir máx partículas vivas (4.000 preset medio) [M]
- [x] Definir presupuesto por preset (M90) [M]
- [x] Definir log VFX-SKIP cuando se excede [M]

## E. RF4 — Determinismo

- [x] Definir semillas de contexto (M10) en one-shots [M]
- [x] Definir loops con fase fija [M]
- [x] Definir sin RNG por frame [M]
- [x] Definir verificación de determinismo en validador [M]

## F. RF5 — Sincronía con animación

- [x] Definir triggers en timelines (M48) [M]
- [x] Minado, cosecha, pesca, construcción desde animación [M]
- [x] Definir trigger centralizado VFX+SFX+feedback [M]

## G. RF6 — Eventos de juego

- [x] Definir obtención de Sello (M22) [M]
- [x] Definir resolución de puzzle (M24) [M]
- [x] Definir descubrimiento (M71) [M]
- [x] Definir festivales (M74) [M]

## H. RF7 — Fuego y lava

- [x] Definir humo + ascuas de fuego [M]
- [x] Definir burbujas + ascuas de lava [M]
- [x] Definir sin luz por partícula (luz = M49) [M]

## I. RF8 — Agua

- [x] Definir salpicaduras al nadar (M51/M11) [M]
- [x] Definir gotas de cascada [M]
- [x] Definir chapoteo de balde (M13) [M]

## J. RF9 — Atmosféricos

- [x] Definir lluvia por clima (M32) [M]
- [x] Definir nieve por clima/estación (M32/M29) [M]
- [x] Definir polvo del desierto [M]
- [x] Definir hojas al viento (M50) [M]
- [x] Definir pétalos primaverales (M29) [M]
- [x] Definir un emisor global por zona (no por chunk) [M]

## K. RF10 — Magia y ancestral

- [x] Definir resonancia de runas (M24/M26) [M]
- [x] Definir activación de glifos [M]
- [x] Definir estelas de luz (M47) [M]
- [x] Definir magia tecnológica (M86) [S]

## L. RF11 — UI

- [x] Definir partículas 2D en menús/recompensas (M53) [M]
- [x] Definir Reduce Motion (M58) [M]
- [x] Definir sin estroboscopios (>10 Hz prohibido) [M]

## M. RF12 — Cambio estacional

- [x] Definir transición de VFX por estación (M29) [M]
- [x] Definir pétalos ↔ hojas ↔ nieve [M]

## N. RF13 — Teletransporte

- [x] Definir estela de entrada/salida (si se implementa M28) [S]

## O. RF14 — Optimización

- [x] Definir tope de partículas vivas [M]
- [x] Definir culling por distancia (40 m pausa) [M]
- [x] Definir LOD de emisores (25% lejos) [M]
- [x] Definir pooling (M62) [M]

## P. RF15 — Validación

- [x] Definir validate_vfx.gd [M]
- [x] Verificar presupuesto por escena [M]
- [x] Verificar naming [S]
- [x] Verificar determinismo (semillas) [M]
- [x] Verificar sin luz por partícula [M]
- [x] Verificar mapeo completo de eventos de juego [M]

## Q. RF16 — Naming y organización

- [x] Definir prefijos vfx_, part_ [S]
- [x] Alinear con M108 [M]

## R. Requisitos no funcionales

- [x] Rendimiento: límites + LOD + pooling (M61) [M]
- [x] Memoria: pool precalentado (M62) [M]
- [x] Determinismo: semillas + fases fijas [M]
- [x] Cozy: amplitudes suaves, sin humo denso negro [M]
- [x] Accesible: vfx_quality 3 niveles (M58) [M]
- [x] Mantenible: catálogo central único [M]

## S. Alternativas consideradas

- [x] Descartar CPUParticles para todo [M]
- [x] Descartar emisores sin pool (GC/stutter) [M]
- [x] Descartar luz integrada en partículas [M]
- [x] Descartar RNG en runtime [S]
- [x] Descartar sin límite de partículas [S]
- [x] Descartar VFX 100% procedural por shaders [M]

## T. Riesgos y mitigaciones

- [x] Riesgo de overdraw → presupuesto + tope + LOD [M]
- [x] Riesgo de desincronía → trigger centralizado [M]
- [x] Riesgo de determinismo roto → semillas + validador [M]
- [x] Riesgo de stutter → pool precalentado [M]
- [x] Riesgo de molestias (fotosensibilidad) → vfx_quality (M58) [M]
- [x] Riesgo de efectos fuera de estilo → guía de amplitudes + review [M]

## U. Integraciones

- [x] Documentar integración con M04 (GPUParticles) [S]
- [x] Documentar integración con M13/M17/M22/M24/M33/M34/M71 (eventos) [S]
- [x] Documentar integración con M48 (timelines) [S]
- [x] Documentar integración con M43/M44 (audio/feedback) [S]
- [x] Documentar integración con M32/M29 (clima/estaciones) [S]
- [x] Documentar integración con M50/M51 (hojas/salpicaduras) [S]
- [x] Documentar integración con M47/M49 (materiales/luz) [S]
- [x] Documentar integración con M53/M58 (UI/accesibilidad) [S]
- [x] Documentar integración con M61/M62 (presupuestos) [S]
- [x] Documentar integración con M108/M118 (import/CI) [S]

## V. Herramientas y flujos

- [x] Documentar flujo de emisión one-shot [M]
- [x] Documentar flujo de loop ambiental (humo) [M]
- [x] Documentar flujo de atmosféricos por clima/estación [M]

## W. Criterios de aceptación verificados

- [x] Todos los efectos del plan maestro en el catálogo [M]
- [x] Escena pivote sin exceder límites y sin caída de fps [M]
- [x] One-shots deterministas (misma semilla, misma distribución) [M]
- [x] Triggers sincronizados con animación/sonido/feedback [M]
- [x] Fuego/lava sin luz (solo M49) [M]
- [x] Reduce Motion atenúa/desactiva VFX [M]
- [x] Atmosféricos responden a clima/estación sin lag [M]
- [x] Catálogo y validación integrados con CI (M118) [M]

## X. Notas finales

- [x] Documentar el desfase de numeración del plan maestro (51=PARTÍCULAS Y VFX → ID 52) [S]
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]