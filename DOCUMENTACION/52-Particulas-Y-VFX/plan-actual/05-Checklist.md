**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 52: Partículas y VFX

## A. Problema y objetivos

- [ ] Definir el problema: sin sistema de VFX el feedback visual es inconsistente y caro [S]
- [ ] Definir el objetivo: VFX baratos, deterministas y armónicos con el estilo cozy [S]
- [ ] Registrar dependencias: M04 (GPUParticles), M45/M47 (materiales), M49 (glow/luz), M61/M62 (presupuestos), M58 (accesibilidad) [M]
- [ ] Mapear la sección 51 "PARTÍCULAS Y VFX" del plan maestro al ID 52 de la tabla global [M]
- [ ] Separar dentro/fuera de alcance: luz de fuego → M49, sonido → M43/M44, sprites → M45/M47 [S]
- [ ] Documentar restricciones: GPUParticles, sin RNG, sin luz por partícula, presupuesto verificable [M]
- [ ] Definir criterios de aceptación verificables (8 criterios) [S]

## B. RF1 — Catálogo de VFX

- [ ] Listar los 25 efectos del plan maestro [M]
- [ ] Humo y polvo [S]
- [ ] Hojas y pétalos [S]
- [ ] Chispas [S]
- [ ] Agua (salpicaduras) [S]
- [ ] Lluvia y nieve [S]
- [ ] Fuego y lava [S]
- [ ] Luz y magia tecnológica [S]
- [ ] Resonancia y activación de runas [S]
- [ ] Teletransporte (si existe) [S]
- [ ] Obtención de Sello [S]
- [ ] Resolución de puzzle [S]
- [ ] Construcción, cosecha y pesca [S]
- [ ] Descubrimiento [S]
- [ ] Cambio estacional [S]
- [ ] Efectos de interfaz [S]
- [ ] Efectos atmosféricos [S]
- [ ] Definir parámetros por efecto (tipo, material, emisor, presupuesto) [M]

## C. RF2 — Pool central

- [ ] Definir VfxManager (autoload) [M]
- [ ] Definir pool de emisores one-shot prestados/liberados [M]
- [ ] Definir loops registrados con culling [M]
- [ ] Definir precalentamiento del pool (8 emisores) [M]

## D. RF3 — Presupuesto por escena

- [ ] Definir máx emisores activos (12 preset medio) [M]
- [ ] Definir máx partículas vivas (4.000 preset medio) [M]
- [ ] Definir presupuesto por preset (M90) [M]
- [ ] Definir log VFX-SKIP cuando se excede [M]

## E. RF4 — Determinismo

- [ ] Definir semillas de contexto (M10) en one-shots [M]
- [ ] Definir loops con fase fija [M]
- [ ] Definir sin RNG por frame [M]
- [ ] Definir verificación de determinismo en validador [M]

## F. RF5 — Sincronía con animación

- [ ] Definir triggers en timelines (M48) [M]
- [ ] Minado, cosecha, pesca, construcción desde animación [M]
- [ ] Definir trigger centralizado VFX+SFX+feedback [M]

## G. RF6 — Eventos de juego

- [ ] Definir obtención de Sello (M22) [M]
- [ ] Definir resolución de puzzle (M24) [M]
- [ ] Definir descubrimiento (M71) [M]
- [ ] Definir festivales (M74) [M]

## H. RF7 — Fuego y lava

- [ ] Definir humo + ascuas de fuego [M]
- [ ] Definir burbujas + ascuas de lava [M]
- [ ] Definir sin luz por partícula (luz = M49) [M]

## I. RF8 — Agua

- [ ] Definir salpicaduras al nadar (M51/M11) [M]
- [ ] Definir gotas de cascada [M]
- [ ] Definir chapoteo de balde (M13) [M]

## J. RF9 — Atmosféricos

- [ ] Definir lluvia por clima (M32) [M]
- [ ] Definir nieve por clima/estación (M32/M29) [M]
- [ ] Definir polvo del desierto [M]
- [ ] Definir hojas al viento (M50) [M]
- [ ] Definir pétalos primaverales (M29) [M]
- [ ] Definir un emisor global por zona (no por chunk) [M]

## K. RF10 — Magia y ancestral

- [ ] Definir resonancia de runas (M24/M26) [M]
- [ ] Definir activación de glifos [M]
- [ ] Definir estelas de luz (M47) [M]
- [ ] Definir magia tecnológica (M86) [S]

## L. RF11 — UI

- [ ] Definir partículas 2D en menús/recompensas (M53) [M]
- [ ] Definir Reduce Motion (M58) [M]
- [ ] Definir sin estroboscopios (>10 Hz prohibido) [M]

## M. RF12 — Cambio estacional

- [ ] Definir transición de VFX por estación (M29) [M]
- [ ] Definir pétalos ↔ hojas ↔ nieve [M]

## N. RF13 — Teletransporte

- [ ] Definir estela de entrada/salida (si se implementa M28) [S]

## O. RF14 — Optimización

- [ ] Definir tope de partículas vivas [M]
- [ ] Definir culling por distancia (40 m pausa) [M]
- [ ] Definir LOD de emisores (25% lejos) [M]
- [ ] Definir pooling (M62) [M]

## P. RF15 — Validación

- [ ] Definir validate_vfx.gd [M]
- [ ] Verificar presupuesto por escena [M]
- [ ] Verificar naming [S]
- [ ] Verificar determinismo (semillas) [M]
- [ ] Verificar sin luz por partícula [M]
- [ ] Verificar mapeo completo de eventos de juego [M]

## Q. RF16 — Naming y organización

- [ ] Definir prefijos vfx_, part_ [S]
- [ ] Alinear con M108 [M]

## R. Requisitos no funcionales

- [ ] Rendimiento: límites + LOD + pooling (M61) [M]
- [ ] Memoria: pool precalentado (M62) [M]
- [ ] Determinismo: semillas + fases fijas [M]
- [ ] Cozy: amplitudes suaves, sin humo denso negro [M]
- [ ] Accesible: vfx_quality 3 niveles (M58) [M]
- [ ] Mantenible: catálogo central único [M]

## S. Alternativas consideradas

- [ ] Descartar CPUParticles para todo [M]
- [ ] Descartar emisores sin pool (GC/stutter) [M]
- [ ] Descartar luz integrada en partículas [M]
- [ ] Descartar RNG en runtime [S]
- [ ] Descartar sin límite de partículas [S]
- [ ] Descartar VFX 100% procedural por shaders [M]

## T. Riesgos y mitigaciones

- [ ] Riesgo de overdraw → presupuesto + tope + LOD [M]
- [ ] Riesgo de desincronía → trigger centralizado [M]
- [ ] Riesgo de determinismo roto → semillas + validador [M]
- [ ] Riesgo de stutter → pool precalentado [M]
- [ ] Riesgo de molestias (fotosensibilidad) → vfx_quality (M58) [M]
- [ ] Riesgo de efectos fuera de estilo → guía de amplitudes + review [M]

## U. Integraciones

- [ ] Documentar integración con M04 (GPUParticles) [S]
- [ ] Documentar integración con M13/M17/M22/M24/M33/M34/M71 (eventos) [S]
- [ ] Documentar integración con M48 (timelines) [S]
- [ ] Documentar integración con M43/M44 (audio/feedback) [S]
- [ ] Documentar integración con M32/M29 (clima/estaciones) [S]
- [ ] Documentar integración con M50/M51 (hojas/salpicaduras) [S]
- [ ] Documentar integración con M47/M49 (materiales/luz) [S]
- [ ] Documentar integración con M53/M58 (UI/accesibilidad) [S]
- [ ] Documentar integración con M61/M62 (presupuestos) [S]
- [ ] Documentar integración con M108/M118 (import/CI) [S]

## V. Herramientas y flujos

- [ ] Documentar flujo de emisión one-shot [M]
- [ ] Documentar flujo de loop ambiental (humo) [M]
- [ ] Documentar flujo de atmosféricos por clima/estación [M]

## W. Criterios de aceptación verificados

- [ ] Todos los efectos del plan maestro en el catálogo [M]
- [ ] Escena pivote sin exceder límites y sin caída de fps [M]
- [ ] One-shots deterministas (misma semilla, misma distribución) [M]
- [ ] Triggers sincronizados con animación/sonido/feedback [M]
- [ ] Fuego/lava sin luz (solo M49) [M]
- [ ] Reduce Motion atenúa/desactiva VFX [M]
- [ ] Atmosféricos responden a clima/estación sin lag [M]
- [ ] Catálogo y validación integrados con CI (M118) [M]

## X. Notas finales

- [ ] Documentar el desfase de numeración del plan maestro (51=PARTÍCULAS Y VFX → ID 52) [S]
- [ ] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [ ] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

## Z. Validación visual del preview (2026-08-24, ox-alpha/Cline)

- [x] Escena `preview_particles.tscn` creada y ejecutada en Godot 4.7.2 [S]
- [x] Emisor CPUParticles3D corriendo sin errores en consola ("Polen creado OK") [M]
- [x] Confirmación visual humana: partículas amarillas visibles emergiendo desde abajo (tipo chispas/fuegos artificiales) [S]
- [x] Lanzamiento reproducible documentado (`scripts-reutilizables/lanzar_preview.py`) [S]
- [x] Primera captura automatizada real del juego: `capturas/52-Particulas-Y-VFX/cap_52_2026-08-24_21-19-22_polen-validacion.png` (verificada visualmente por el agente) [S]
- [x] Mejora estética: quad reducido 0.25→0.06 + textura radial suave generada por código (GradientTexture2D) + transparencia alpha. Verificado en capturas iter2/iter2b: polen pequeño redondeado difuminado, FPS 59 [M]

## Z2. Iteraciones con flujo V4+V2 (2026-08-25, ox-alpha/Cline)

- [x] Iter 3: turbulencia (deriva orgánica tipo brisa) + caída lenta + damping + amount 150→220 + lifetime 6→9. FPS 59 confirmado en iter3b (el 24 inicial era transitorio del arranque) [M]
- [x] Iter 4: emisión en caja ancha (EMISSION_SHAPE_BOX, extents 3.5×0.5×1.0) para distribuir el polen por toda la escena en vez de amontonarlo en una columna. Verificado en captura: polen distribuido flotando a distintas alturas, FPS 59 [M]
- [x] Flujo completo V4+V2 ejercitado: lanzar (script) → capturar (MCP screen) → comparar → ajustar → recapturar, con historial de capturas por iteración [S]
## Verificación visual (2026-09-02 06:50 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Preview de polen (GPUParticles3D, amount 150, quad 0.06 textura radial) ejecutado y capturado: cientos de partículas flotando visibles, textura suave, sin frames rotos
- [x] **Rendimiento visual: FPS 59** en la escena (sin degradación con 150+ partículas — presupuesto OK)
- [x] GPUParticles3D (recomendado por M52) confirmado como vía correcta en D3D12 (no CPU)
- [?] Catálogo de VFX por evento (M44 feedback + M92 tutorial): iter 2 — catálogo data-driven (dueño: deepseek-v4-flash-vision-exp)
