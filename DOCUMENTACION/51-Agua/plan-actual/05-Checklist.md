**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 51: Agua

## A. Problema y objetivos

- [x] Definir el problema: sin sistema de agua el océano es caro e inconsistente [S]
- [x] Definir el objetivo: agua determinista, cozy y barata con física coherente [S]
- [x] Registrar dependencias: M09 (nivel de mar), M10 (splines), M47 (shader), M08 (bloques), M04 (Godot), M61/M62 (presupuestos) [M]
- [x] Mapear la sección 50 "AGUA" del plan maestro al ID 51 de la tabla global [M]
- [x] Separar dentro/fuera de alcance: fauna → M36/M65, barcos → M28/M67, sonido → M42, natación → M11 [S]
- [x] Documentar restricciones: nivel global, determinismo, transparencia acotada, sin refracción global [M]
- [x] Definir criterios de aceptación verificables (8 criterios) [S]

## B. RF1 — Tipos de agua

- [x] Listar los 7 tipos del plan maestro [M]
- [x] Agua de océano [S]
- [x] Agua de río [S]
- [x] Agua de lago [S]
- [x] Agua de cascada [S]
- [x] Agua subterránea [S]
- [x] Agua congelada [S]
- [x] Agua especial (termales/laguna brillante) [S]
- [x] Definir parámetros por tipo (shader, sonido, física) [M]

## C. RF2 — Nivel del mar

- [x] Definir nivel de mar global por semilla (M09/M10) [M]
- [x] Definir consistencia ± 0.01 m entre chunks [M]
- [x] Definir excepciones de POI documentadas [M]

## D. RF3 — Render de océano

- [x] Definir mesh por chunk con LOD (lejano plano) [M]
- [x] Definir olas GPU con fase fija por cuerpo [M]
- [x] Definir espuma costera (altura de ola vs costa) [M]
- [x] Definir transparencia con depth_prepass [M]

## E. RF4 — Reflejos y transparencia

- [x] Definir ReflectionProbe ≤ 2 por escena [M]
- [x] Definir sin refracción global [M]
- [x] Definir refracción solo en pools de puzzles (M24) [M]
- [x] Definir overdraw ≤ 1.5× [M]

## F. RF5 — Olas y corrientes

- [x] Definir olas deterministas (fase + semilla) [M]
- [x] Definir corriente por spline de río (M10) [M]
- [x] Definir corriente mueve objetos (M70) [M]
- [x] Definir corriente mueve barcos (M28/M67) [M]

## G. RF6 — Cascadas

- [x] Definir mesh de caída con VF [M]
- [x] Definir partículas en base (M52) [M]
- [x] Definir sonido de cascada (M42) [M]

## H. RF7 — Agua subterránea

- [x] Definir charcos y nivel estático en cuevas (M26) [M]
- [x] Definir espuma de esporas [S]
- [x] Definir sin olas [S]

## I. RF8 — Agua congelada

- [x] Definir congelamiento estacional (M29/M32) [M]
- [x] Definir hielo caminable con límites de tiempo (M31) [M]
- [x] Definir derretimiento con fuego (M13) [M]
- [x] Definir anti-softlock (M66) [M]

## J. RF9 — Agua especial

- [x] Definir termales sin daño y sin congelamiento [S]
- [x] Definir lagunas brillantes (M47 emisivos) [S]

## K. RF10 — Inundación y drenaje

- [x] Definir compuertas y represas (M24) [M]
- [x] Definir lluvia eleva lagos temporales con tope (M32) [M]
- [x] Definir sine inundar zonas de juego [M]

## L. RF11 — Evaporación

- [x] Definir lagos efímeros del desierto (M32) [M]
- [x] Definir secado gradual determinista [M]
- [x] Definir sin impacto en progresión [S]

## M. RF12 — Interacción con herramientas

- [x] Definir balde (M13) y botella (M15) [M]
- [x] Definir riego (M33) [M]
- [x] Definir agua como ítem finito (M14) [M]

## N. RF13 — Interacción con puzzles

- [x] Definir canales y flujo direccional (M24) [M]
- [x] Definir cerraduras de agua [M]
- [x] Definir pools con refracción acotada [M]

## O. RF14 — Interacción con barcos

- [x] Definir flotabilidad del casco [M]
- [x] Definir deriva por corriente (≤0.3 m/s) [M]
- [x] Definir olas afectan balanceo visual [M]

## P. RF15 — Interacción con fauna

- [x] Definir peces nadan según corrientes (M36/M65) [M]
- [x] Definir sin colisiones duras [S]

## Q. RF16 — Interacción con el jugador

- [x] Definir natación (M11): flotación suave [M]
- [x] Definir inmersión visual 0.8 m [S]
- [x] Definir sprint en agua costoso (M11) [M]
- [x] Definir chapoteo al entrar/salir [S]

## R. RF17 — Sonidos

- [x] Definir olas por bioma/franja (M42) [M]
- [x] Definir chapoteo y balde [S]
- [x] Definir cascada en loop [S]
- [x] Definir crujido de hielo [S]

## S. RF18 — Partículas

- [x] Definir salpicaduras de pies [S]
- [x] Definir rocío de cascada [S]
- [x] Definir gotas al salir del agua [S]

## T. RF19 — Colisiones

- [x] Definir superficie sólida plana por chunk [M]
- [x] Definir bloques de agua (M08) interactuables [M]
- [x] Definir física voxel coherente [M]

## U. RF20 — Optimización

- [x] Definir verts por chunk ≤ 2.000 [M]
- [x] Definir LOD de malla [M]
- [x] Definir presupuesto contra M61/M62 [M]

## V. RF21 — Validación

- [x] Definir validate_water.gd [M]
- [x] Verificar nivel de mar consistente [M]
- [x] Verificar presupuesto de render [M]
- [x] Verificar determinismo de olas [M]

## W. RF22 — Naming y organización

- [x] Definir prefijos water_, wave_ [S]
- [x] Alinear con M108 [M]

## X. Requisitos no funcionales

- [x] Rendimiento: mesh+LOD, probes y refracción acotadas [M]
- [x] Memoria: buffers de agua (M62) [M]
- [x] Determinismo: fases fijas + semilla [M]
- [x] Cozy: corrientes suaves, sin penalización cruel [M]
- [x] Mantenible: tipos centrales por .tres [M]

## Y. Alternativas consideradas

- [x] Descartar océano voxel masivo [M]
- [x] Descartar refracción global [M]
- [x] Descartar probes por todo el océano [M]
- [x] Descartar simulación de fluidos [M]
- [x] Descartar ríos como bloques estáticos [M]
- [x] Descartar hielo permanente [S]

## Z. Riesgos y mitigaciones

- [x] Riesgo de overdraw → presupuesto + LOD + depth_prepass [M]
- [x] Riesgo de nivel inconsistente → valor global + validación [M]
- [x] Riesgo de softlock de hielo → límites M66 [M]
- [x] Riesgo de corrientes injustas → fuerza suave + cozy [M]
- [x] Riesgo de reflejos caros → ≤2 probes + prueba M90 [M]
- [x] Riesgo de ríos rotos → splines M10 + validador de pendiente [M]

## AA. Integraciones

- [x] Documentar integración con M08/M10 (bloques/nivel/splines) [S]
- [x] Documentar integración con M09 (nivel global) [S]
- [x] Documentar integración con M47 (shader) [S]
- [x] Documentar integración con M11 (natación) [S]
- [x] Documentar integración con M13/M15/M33 (herramientas) [S]
- [x] Documentar integración con M24 (puzzles) [S]
- [x] Documentar integración con M28/M67 (barcos) [S]
- [x] Documentar integración con M36/M65 (fauna) [S]
- [x] Documentar integración con M29/M31/M32 (estaciones/clima) [S]
- [x] Documentar integración con M42/M44 (sonido/feedback) [S]
- [x] Documentar integración con M52 (partículas) [S]
- [x] Documentar integración con M61/M62 (presupuestos) [S]
- [x] Documentar integración con M66 (anti-softlock) [S]
- [x] Documentar integración con M70 (objetos) [S]
- [x] Documentar integración con M108/M118 (import/CI) [S]

## AB. Herramientas y flujos

- [x] Documentar flujo de generación de chunk de océano [M]
- [x] Documentar flujo de congelamiento estacional [M]
- [x] Documentar flujo de puzzle de compuerta [M]

## AC. Criterios de aceptación verificados

- [x] Nivel de mar consistente entre chunks [M]
- [x] Océano con olas/espuma dentro del presupuesto [M]
- [x] Corrientes mueven objetos y barcos [M]
- [x] Hielo solo estacional y sin softlock [M]
- [x] Cascadas con sonido + partículas sincronizados [M]
- [x] Puzzles de compuertas/canales funcionan (M24) [M]
- [x] Natación suave sin clipping con chapoteo [M]
- [x] Presupuesto verificado por validador [M]

## AD. Notas finales

- [x] Documentar el desfase de numeración del plan maestro (50=AGUA → ID 51) [S]
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
