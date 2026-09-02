**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 51: Agua

## A. Problema y objetivos

- [ ] Definir el problema: sin sistema de agua el océano es caro e inconsistente [S]
- [ ] Definir el objetivo: agua determinista, cozy y barata con física coherente [S]
- [ ] Registrar dependencias: M09 (nivel de mar), M10 (splines), M47 (shader), M08 (bloques), M04 (Godot), M61/M62 (presupuestos) [M]
- [ ] Mapear la sección 50 "AGUA" del plan maestro al ID 51 de la tabla global [M]
- [ ] Separar dentro/fuera de alcance: fauna → M36/M65, barcos → M28/M67, sonido → M42, natación → M11 [S]
- [ ] Documentar restricciones: nivel global, determinismo, transparencia acotada, sin refracción global [M]
- [ ] Definir criterios de aceptación verificables (8 criterios) [S]

## B. RF1 — Tipos de agua

- [ ] Listar los 7 tipos del plan maestro [M]
- [ ] Agua de océano [S]
- [ ] Agua de río [S]
- [ ] Agua de lago [S]
- [ ] Agua de cascada [S]
- [ ] Agua subterránea [S]
- [ ] Agua congelada [S]
- [ ] Agua especial (termales/laguna brillante) [S]
- [ ] Definir parámetros por tipo (shader, sonido, física) [M]

## C. RF2 — Nivel del mar

- [ ] Definir nivel de mar global por semilla (M09/M10) [M]
- [ ] Definir consistencia ± 0.01 m entre chunks [M]
- [ ] Definir excepciones de POI documentadas [M]

## D. RF3 — Render de océano

- [ ] Definir mesh por chunk con LOD (lejano plano) [M]
- [ ] Definir olas GPU con fase fija por cuerpo [M]
- [ ] Definir espuma costera (altura de ola vs costa) [M]
- [ ] Definir transparencia con depth_prepass [M]

## E. RF4 — Reflejos y transparencia

- [ ] Definir ReflectionProbe ≤ 2 por escena [M]
- [ ] Definir sin refracción global [M]
- [ ] Definir refracción solo en pools de puzzles (M24) [M]
- [ ] Definir overdraw ≤ 1.5× [M]

## F. RF5 — Olas y corrientes

- [ ] Definir olas deterministas (fase + semilla) [M]
- [ ] Definir corriente por spline de río (M10) [M]
- [ ] Definir corriente mueve objetos (M70) [M]
- [ ] Definir corriente mueve barcos (M28/M67) [M]

## G. RF6 — Cascadas

- [ ] Definir mesh de caída con VF [M]
- [ ] Definir partículas en base (M52) [M]
- [ ] Definir sonido de cascada (M42) [M]

## H. RF7 — Agua subterránea

- [ ] Definir charcos y nivel estático en cuevas (M26) [M]
- [ ] Definir espuma de esporas [S]
- [ ] Definir sin olas [S]

## I. RF8 — Agua congelada

- [ ] Definir congelamiento estacional (M29/M32) [M]
- [ ] Definir hielo caminable con límites de tiempo (M31) [M]
- [ ] Definir derretimiento con fuego (M13) [M]
- [ ] Definir anti-softlock (M66) [M]

## J. RF9 — Agua especial

- [ ] Definir termales sin daño y sin congelamiento [S]
- [ ] Definir lagunas brillantes (M47 emisivos) [S]

## K. RF10 — Inundación y drenaje

- [ ] Definir compuertas y represas (M24) [M]
- [ ] Definir lluvia eleva lagos temporales con tope (M32) [M]
- [ ] Definir sine inundar zonas de juego [M]

## L. RF11 — Evaporación

- [ ] Definir lagos efímeros del desierto (M32) [M]
- [ ] Definir secado gradual determinista [M]
- [ ] Definir sin impacto en progresión [S]

## M. RF12 — Interacción con herramientas

- [ ] Definir balde (M13) y botella (M15) [M]
- [ ] Definir riego (M33) [M]
- [ ] Definir agua como ítem finito (M14) [M]

## N. RF13 — Interacción con puzzles

- [ ] Definir canales y flujo direccional (M24) [M]
- [ ] Definir cerraduras de agua [M]
- [ ] Definir pools con refracción acotada [M]

## O. RF14 — Interacción con barcos

- [ ] Definir flotabilidad del casco [M]
- [ ] Definir deriva por corriente (≤0.3 m/s) [M]
- [ ] Definir olas afectan balanceo visual [M]

## P. RF15 — Interacción con fauna

- [ ] Definir peces nadan según corrientes (M36/M65) [M]
- [ ] Definir sin colisiones duras [S]

## Q. RF16 — Interacción con el jugador

- [ ] Definir natación (M11): flotación suave [M]
- [ ] Definir inmersión visual 0.8 m [S]
- [ ] Definir sprint en agua costoso (M11) [M]
- [ ] Definir chapoteo al entrar/salir [S]

## R. RF17 — Sonidos

- [ ] Definir olas por bioma/franja (M42) [M]
- [ ] Definir chapoteo y balde [S]
- [ ] Definir cascada en loop [S]
- [ ] Definir crujido de hielo [S]

## S. RF18 — Partículas

- [ ] Definir salpicaduras de pies [S]
- [ ] Definir rocío de cascada [S]
- [ ] Definir gotas al salir del agua [S]

## T. RF19 — Colisiones

- [ ] Definir superficie sólida plana por chunk [M]
- [ ] Definir bloques de agua (M08) interactuables [M]
- [ ] Definir física voxel coherente [M]

## U. RF20 — Optimización

- [ ] Definir verts por chunk ≤ 2.000 [M]
- [ ] Definir LOD de malla [M]
- [ ] Definir presupuesto contra M61/M62 [M]

## V. RF21 — Validación

- [ ] Definir validate_water.gd [M]
- [ ] Verificar nivel de mar consistente [M]
- [ ] Verificar presupuesto de render [M]
- [ ] Verificar determinismo de olas [M]

## W. RF22 — Naming y organización

- [ ] Definir prefijos water_, wave_ [S]
- [ ] Alinear con M108 [M]

## X. Requisitos no funcionales

- [ ] Rendimiento: mesh+LOD, probes y refracción acotadas [M]
- [ ] Memoria: buffers de agua (M62) [M]
- [ ] Determinismo: fases fijas + semilla [M]
- [ ] Cozy: corrientes suaves, sin penalización cruel [M]
- [ ] Mantenible: tipos centrales por .tres [M]

## Y. Alternativas consideradas

- [ ] Descartar océano voxel masivo [M]
- [ ] Descartar refracción global [M]
- [ ] Descartar probes por todo el océano [M]
- [ ] Descartar simulación de fluidos [M]
- [ ] Descartar ríos como bloques estáticos [M]
- [ ] Descartar hielo permanente [S]

## Z. Riesgos y mitigaciones

- [ ] Riesgo de overdraw → presupuesto + LOD + depth_prepass [M]
- [ ] Riesgo de nivel inconsistente → valor global + validación [M]
- [ ] Riesgo de softlock de hielo → límites M66 [M]
- [ ] Riesgo de corrientes injustas → fuerza suave + cozy [M]
- [ ] Riesgo de reflejos caros → ≤2 probes + prueba M90 [M]
- [ ] Riesgo de ríos rotos → splines M10 + validador de pendiente [M]

## AA. Integraciones

- [ ] Documentar integración con M08/M10 (bloques/nivel/splines) [S]
- [ ] Documentar integración con M09 (nivel global) [S]
- [ ] Documentar integración con M47 (shader) [S]
- [ ] Documentar integración con M11 (natación) [S]
- [ ] Documentar integración con M13/M15/M33 (herramientas) [S]
- [ ] Documentar integración con M24 (puzzles) [S]
- [ ] Documentar integración con M28/M67 (barcos) [S]
- [ ] Documentar integración con M36/M65 (fauna) [S]
- [ ] Documentar integración con M29/M31/M32 (estaciones/clima) [S]
- [ ] Documentar integración con M42/M44 (sonido/feedback) [S]
- [ ] Documentar integración con M52 (partículas) [S]
- [ ] Documentar integración con M61/M62 (presupuestos) [S]
- [ ] Documentar integración con M66 (anti-softlock) [S]
- [ ] Documentar integración con M70 (objetos) [S]
- [ ] Documentar integración con M108/M118 (import/CI) [S]

## AB. Herramientas y flujos

- [ ] Documentar flujo de generación de chunk de océano [M]
- [ ] Documentar flujo de congelamiento estacional [M]
- [ ] Documentar flujo de puzzle de compuerta [M]

## AC. Criterios de aceptación verificados

- [ ] Nivel de mar consistente entre chunks [M]
- [ ] Océano con olas/espuma dentro del presupuesto [M]
- [ ] Corrientes mueven objetos y barcos [M]
- [ ] Hielo solo estacional y sin softlock [M]
- [ ] Cascadas con sonido + partículas sincronizados [M]
- [ ] Puzzles de compuertas/canales funcionan (M24) [M]
- [ ] Natación suave sin clipping con chapoteo [M]
- [ ] Presupuesto verificado por validador [M]

## AD. Notas finales

- [ ] Documentar el desfase de numeración del plan maestro (50=AGUA → ID 51) [S]
- [ ] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [ ] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
## Verificación (2026-09-02 06:00 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Parámetros de la batimetría verificados en código (island_generator): water_level=2, banda 0.94-0.98 = agua CLARA (fondo 2, capa turquesa en y=3 con el fix M167), >0.98 = océano profundo (height 0); paleta Maldivas: water #1A73BF (0.10,0.45,0.75) y shallow_water #40D1C7 (0.25,0.82,0.78)
- [x] Verificación visual (evidencia M167): captura de costa mostrando plato de arena + franja turquesa + azul profundo (cap_167 costa) — el agua clara pisable y el océano azul se renderizan correctamente tras el fix
- [x] Validación programática: get_block_at(503,3,256)=SHALLOW_WATER(30) y get_block_at(530,1,256)=WATER(17) — verificado en runtime y en el validador M167 (28/28)
- [?] Animación de superficie de agua (ondas, transparencia, reflejos) y materiales — iter 2 (dueño: deepseek-v4-flash-vision-exp; requiere shaders/M49)
