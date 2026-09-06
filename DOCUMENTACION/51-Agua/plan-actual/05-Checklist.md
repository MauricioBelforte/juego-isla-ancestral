**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 51: Agua

## A. Problema y objetivos

- [x] Definir el problema: sin sistema de agua el océano es caro e inconsistente [S]
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
- [x] Puzzles de compuertas/canales funcionan (M24) [M]
- [ ] Natación suave sin clipping con chapoteo [M]
- [ ] Presupuesto verificado por validador [M]

## AD. Notas finales

- [ ] Documentar el desfase de numeración del plan maestro (50=AGUA → ID 51) [S]
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
## Verificación (2026-09-02 06:00 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Parámetros de la batimetría verificados en código (island_generator): water_level=2, banda 0.94-0.98 = agua CLARA (fondo 2, capa turquesa en y=3 con el fix M167), >0.98 = océano profundo (height 0); paleta Maldivas: water #1A73BF (0.10,0.45,0.75) y shallow_water #40D1C7 (0.25,0.82,0.78)
- [x] Verificación visual (evidencia M167): captura de costa mostrando plato de arena + franja turquesa + azul profundo (cap_167 costa) — el agua clara pisable y el océano azul se renderizan correctamente tras el fix
- [x] Validación programática: get_block_at(503,3,256)=SHALLOW_WATER(30) y get_block_at(530,1,256)=WATER(17) — verificado en runtime y en el validador M167 (28/28)
- [?] Animación de superficie de agua (ondas, transparencia, reflejos) y materiales — iter 2 (dueño: deepseek-v4-flash-vision-exp; requiere shaders/M49)

## Iteración 2 — Agua animada (2026-09-06 16:30, glm-5.3-flash / Kilo Code)

- [x] Shader propio agua_olas.gdshader: olas de 3 ondas cruzadas en vertex (desplazamiento Y + normal por derivadas) [M]
- [x] Fresnel de vista rasante (potencia 3.0) que aclara el horizonte [S]
- [x] Espuma en crestas (smoothstep) con emisión leve [S]
- [x] Transparencia (blend_mix) que deja ver el océano voxel turquesa debajo [S]
- [x] PlaneMesh 1400×1400 con 80×80 subdivisiones en y=4.05 (sobre water_level=2) [S]
- [x] Sombras OFF del plano (no proyecta sobre la isla) [S]
- [x] Integración en main_island.tscn (nodo AguaAnimada + script) [S]
- [x] Verificación visual: espuma en crestas + fresnel + turquesa en juego (capturas/51/) [M]
- [x] Regresión: M31 0 fallos, M47 17/0, M50 5/0; FPS 51-60 [S]
- [ ] Reflejo de escena real (SSR/planos reflejo) — necesita presupuesto de rendering, próxima iteración [C]
- [ ] Sonido de olas (M42/M43) [S]
- [ ] Interacción de olas con la fauna (barcos/estaciones) [M]
- [ ] Confirmación estética del usuario [S]

### Notas del Agente — iter. 2

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-06 16:30
**Estado:** Iteración completada (agua visible como agua viva, no plano estático)

#### Lo que hice
- El agua voxel es bloques LIQUID de la VoxelBlockyLibrary (nada que shader-ear sin tocar el material_override del terreno completo). La solución: plano independiente con shader propio sobre el nivel del mar — olas + fresnel + espuma + transparencia. El agua voxel turquesa queda debajo y se ve a través.
- El plano no proyecta sombras y su superficie (y=4.05) queda apenas sobre el bloque de agua (top y=4).

#### Recomendaciones para el próximo agente
- El shader expone uniforms ajustables (amplitud, velocidad, frecuencia, borde_espuma) para calibrar estética sin tocar código.
- Si se quiere reflejo real de escena: evaluado y descartado por presupuesto de rendering (integrado Forward+ móvil integrada); el fresnel+specular da 90% del look.
- El plano a y=4.05 NO toca las arenas (orilla y≥5): si se ve un borde raro en alguna costa, ajustar Y_SUPERFICIE en agua_animada.gd.
## Fixes usuario 2/3 — olas y arena (2026-09-06 17:43, glm-5.3-flash / Kilo Code)

- [x] FIX: el efecto de olas aparecía sobre la arena seca (cresta 4.21 > arena 4.0) — máscara radial costa en vertex: el plano se hunde 1.2m cerca del borde y las olas se atenúan; y_base 4.05 → 3.7 (cresta máx 3.86 < arena) [M] — Log 736
- [x] AJUSTE usuario: olas plenas hasta el agua clara — transición de hundimiento movida de r 240→300 a r 255→285 (agua clara r 241-264 queda con olas) [S] — Log 736
- [x] Espuma reconvertida en borde de marea: SOLO en la franja costera (costa_mask), ya no en mar abierto [S] — Log 736
- [x] Verificación visual: orilla seca + olas en agua clara (capturas/51/olas_hasta_agua_clara.png) [S] — Log 736
## Iteración 3 — agua premium de cerca (2026-09-06 17:57, glm-5.3-flash / Kilo Code)

- [x] FIX: olas invisibles de cerca — el plano a y 3.7 quedaba bajo el top de los bloques de agua voxel opacos (4.0): al cargar el suelo real lo ocultaban. Plano devuelto a y 4.05 (encima del agua voxel) [M] — Log 749
- [x] Hundimiento de costa desplazado a la franja de arena (r 262-292; antes 255-285 pisaba el agua clara) [S] — Log 749
- [x] Efecto premium orilla: tinte turquesa claro según costa_mask + alpha reducido (marea somera) [S] — Log 749
- [x] Línea de marea: anillo de espuma pulsante (sin TIME) en el borde arena-agua [S] — Log 749
- [x] Confirmación usuario: pelo del jugador OK (fix Log 736 validado) [S]
- [x] Verificación visual en juego: línea de marea + agua clara + olas de fondo, FPS 60 (capturas/51/olas_cerca_premium.png) [S] — Log 749
## Iteración 4-5 — vaivén de marea con shore-fade (2026-09-06 18:23, glm-5.3-flash / Kilo Code)

- [x] Petición usuario: "las olas lleguen hasta la arena porque el efecto está bueno" [S] — Log 750
- [x] Iter. 4 (vaivén radial con wavefront 190±10): DESCARTADA — la medición real (medir_costa_m51.gd, 24 rayos TerrainLocator) mostró que la costa está en r≈180-204 (mediana 184), no en 262 como asumía el shader [M] — Log 750
- [x] Iter. 5 (FINAL): shore-fade por profundidad de pantalla — hint_depth_texture + INV_PROJECTION_MATRIX → profundidad de agua por píxel → fade de alpha + espuma EXACTAMENTE en la línea de costa real, sin radios hardcodeados [C] — Log 750
- [x] Marea somera: tinte turquesa suave cerca de la orilla (0.28/0.68/0.78 al 28% — primer intento lechoso corregido) [S] — Log 750
- [x] Banda de espuma pulsante en la orilla (sin TIME*1.6 + olas) = vaivén natural de marea [S] — Log 750
- [x] Arena seca: alpha 0 sobre arena (desaparece el plano — ya no hay efecto raro) [S] — Log 750
- [x] Verificación visual: orilla limpia + espuma pegada a la arena + mar azul (capturas/51/shorefade_azul.png), FPS 60 [S] — Log 750
- [x] Herramienta reutilizable: medir_costa_m51.gd (escaneo radial de costa con TerrainLocator) [S] — Log 750
- [ ] Confirmación estética final del usuario [S]