**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 49: Iluminación

## A. Problema y objetivos

- [ ] Definir el problema: sin sistema de luz el voxel degenera en sombras quebradas y coste desbordado [S]
- [ ] Definir el objetivo: iluminación cozy consistente por franja con presupuestos verificables [S]
- [ ] Registrar dependencias: M31 (franjas), M32 (clima), M09 (biomas), M08 (voxel), M04 (Godot), M61/M62 (presupuestos), M90 (presets), M58 (accesibilidad) [M]
- [ ] Mapear la sección 48 "ILUMINACIÓN" del plan maestro al ID 49 de la tabla global [M]
- [ ] Separar dentro/fuera de alcance: franjas → M31, clima → M32, VFX → M52, materiales → M47 [S]
- [ ] Documentar restricciones: Forward+, ACES sutil, piso anti-oscuridad 0.15, determinismo, sin niebla volumétrica [M]
- [ ] Definir criterios de aceptación verificables (8 criterios) [S]

## B. RF1 — Iluminación global

- [ ] Definir WorldEnvironment base (tonemapping ACES, gamma 2.2) [M]
- [ ] Definir cielo procedural por bioma (M09) [M]
- [ ] Definir ambiente por franja con piso mínimo [M]
- [ ] Definir sky material por bioma en materials/ [S]

## C. RF2 — Sol y luna

- [ ] Definir una única direccional (sol/luna con curvas de color) [M]
- [ ] Definir presets por las 5 franjas de M31 (elevación, color, intensidad) [M]
- [ ] Definir easing de 3 s entre franjas (sin snaps) [M]
- [ ] Definir curva fría de la luna en NOCHE/PROFUNDA [M]

## D. RF3 — GI y baked lighting

- [ ] Decidir: lightmaps para estáticos (casas, templos, ruinas, cuevas) [M]
- [ ] Decidir: SDFGI/VoxelGI OFF por defecto (prueba documentada si se activa) [M]
- [ ] Definir bake en CI (M118) con semilla fija [M]
- [ ] Definir memoria de lightmaps contra M62 [M]

## E. RF4 — Iluminación dinámica

- [ ] Definir pool de luces dinámicas (M62) [M]
- [ ] Definir tope con sombra ≤ 6 por escena [M]
- [ ] Definir tope total ≤ 20 por escena [M]
- [ ] Definir desactivación por distancia 30 m (M61) [M]

## F. RF5 — Luces interiores

- [ ] Definir luz cálida de casas (M18) [S]
- [ ] Definir luz de tiendas (M39) y talleres [M]
- [ ] Definir ventanas con luz diurna (baked) [M]
- [ ] Definir perfil interior_casa.gd [M]

## G. RF6 — Faroles

- [ ] Definir faroles de pueblo y caminos [M]
- [ ] Definir flicker determinista (fase + semilla) [M]
- [ ] Definir luz desde el pool (no por instancia) [M]
- [ ] Definir opción de desactivación (M58/M90) [S]

## H. RF7 — Fuego

- [ ] Definir luz cálida de hogueras/chimeneas [M]
- [ ] Definir parpadeo suave (≤2 Hz, ≤15%) [M]
- [ ] Integrar con partículas de M52 [S]

## I. RF8 — Cristales y glifos ancestrales

- [ ] Definir luz ambiental sutil de cristales (M47) [M]
- [ ] Definir glow acotado (sin bloom agresivo) [M]
- [ ] No bloquear rango de luz del jugador [S]

## J. RF9 — Cuevas y subterráneo

- [ ] Definir piso anti-oscuridad 0.15 en cuevas (M31) [M]
- [ ] Definir esporas de luz (M11) como luz ambiental [M]
- [ ] Definir transición gradual día→cueva (fade) [M]
- [ ] Definir perfil subterraneo.gd [M]

## K. RF10 — Templos y ruinas

- [ ] Definir rayo cenital en salas principales (M24/M25) [M]
- [ ] Definir iluminación de bajorrelieves [M]
- [ ] Definir ambience suave por sala [M]
- [ ] Definir perfil interior_templo.gd [M]

## L. RF11 — Clima y niebla

- [ ] Definir niebla exponencial por bioma/franja (M09/M32) [M]
- [ ] Definir lluvia: dimming solar suave [M]
- [ ] Descartar niebla volumétrica (coste) [S]
- [ ] Definir niebla de jungla densa y costa baja [M]

## M. RF12 — Sombras

- [ ] Definir cascades ≤ 4 (por preset M90) [M]
- [ ] Definir distancia dinámica de sombras (45 m / 25 m bajo) [M]
- [ ] Definir bias voxel fino sin acne [M]
- [ ] Definir resolución de shadow atlas por preset (1024/2048) [M]
- [ ] Definir sombras suaves (PCF ≥ 4 samples) [M]
- [ ] Prohibir siluetas negras (ambiente de relleno) [M]

## N. RF13 — Optimización de luces

- [ ] Definir pool con MAX_DINAMICAS y MAX_CONT_SOMBRA [M]
- [ ] Descartar luz por instancia de props [M]
- [ ] Definir desactivación offscreen (M61) [M]

## O. RF14 — Baked lighting

- [ ] Definir dónde hornea (interiores y estructuras) [M]
- [ ] Definir formato/registro de memoria (M62) [M]
- [ ] Definir regeneración en CI [M]

## P. RF15 — Hardware objetivo

- [ ] Definir prueba de iluminación en hardware medio (M90) [M]
- [ ] Definir presets de calidad de sombras/luz (M90) [M]
- [ ] Definir objetivo 30 fps mínimo / 60 deseado [M]

## Q. RF16 — Validación

- [ ] Definir validate_lighting.gd [M]
- [ ] Verificar límites de luces por escena [M]
- [ ] Verificar piso ambiental 0.15 [M]
- [ ] Verificar niebla en rango por bioma/franja [M]
- [ ] Verificar flicker por accesibilidad [M]
- [ ] Definir lighting_budget.json [M]

## R. RF17 — Naming y organización

- [ ] Definir prefijos light_, env_, lightmap_ [S]
- [ ] Alinear con M108 [M]

## S. Requisitos no funcionales

- [ ] Rendimiento: límites + pool + distancias (M61) [M]
- [ ] Memoria: lightmap + registro (M62) [M]
- [ ] Cozy: atmósfera por franja, legibilidad siempre [M]
- [ ] Accesible: flicker suave, opciones M58/M90 [M]
- [ ] Determinismo: fase fija, semilla por luz [M]
- [ ] Mantenible: presets centrales por franja/bioma [M]

## T. Alternativas consideradas

- [ ] Descartar SDFGI global por defecto [M]
- [ ] Descartar lightmap de todo el mundo abierto [M]
- [ ] Descartar niebla volumétrica [S]
- [ ] Descartar luz por instancia [M]
- [ ] Descartar un único preset de sombras [S]
- [ ] Descartar flicker con RNG [S]

## U. Riesgos y mitigaciones

- [ ] Riesgo de overdraw en pueblo → pool + topes + distancia [M]
- [ ] Riesgo de acne voxel → bias fino + validación visual [M]
- [ ] Riesgo de bake desactualizado → CI con bake + versión en registro [M]
- [ ] Riesgo de snaps entre franjas → easing 3 s [M]
- [ ] Riesgo de cuevas ilegibles → piso 0.15 + niebla diferenciada [M]
- [ ] Riesgo de sombras caras → distancias por preset + pruebas M90 [M]

## V. Integraciones

- [ ] Documentar integración con M31 (franjas) [S]
- [ ] Documentar integración con M32 (clima) [S]
- [ ] Documentar integración con M09 (biomas/sky) [S]
- [ ] Documentar integración con M08/M10 (voxel) [S]
- [ ] Documentar integración con M18/M24/M25/M26 (interiores) [S]
- [ ] Documentar integración con M47 (emisivos) [S]
- [ ] Documentar integración con M11 (esporas) [S]
- [ ] Documentar integración con M52 (fuego) [S]
- [ ] Documentar integración con M61/M62 (presupuestos) [S]
- [ ] Documentar integración con M90 (presets) [S]
- [ ] Documentar integración con M58 (accesibilidad) [S]
- [ ] Documentar integración con M108/M118 (import/bake) [S]

## W. Herramientas y flujos

- [ ] Documentar flujo de transición de franja [M]
- [ ] Documentar flujo de entrada a cueva [M]
- [ ] Documentar flujo de validación de escena [M]

## X. Criterios de aceptación verificados

- [ ] Escena pivote ≥ 30 fps en hardware medio con preset default [M]
- [ ] 5 franjas distinguibles y correctas según M31 [M]
- [ ] Cuevas legibles (piso 0.15) sin luces por instancia [M]
- [ ] Luces dinámicas ≤ tope verificado por validador [M]
- [ ] Flicker determinista con misma semilla [M]
- [ ] Interior de casa horneado y legible sin dinámicas [M]
- [ ] Niebla por bioma/lluvia sin romper legibilidad [M]
- [ ] Sin sombras negras ni acne visible [M]

## Y. Notas finales

- [ ] Documentar el desfase de numeración del plan maestro (48=ILUMINACIÓN → ID 49) [S]
- [ ] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [ ] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
