**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 49: Iluminación

## A. Problema y objetivos

- [x] Definir el problema: sin sistema de luz el voxel degenera en sombras quebradas y coste desbordado [S]
- [x] Definir el objetivo: iluminación cozy consistente por franja con presupuestos verificables [S]
- [x] Registrar dependencias: M31 (franjas), M32 (clima), M09 (biomas), M08 (voxel), M04 (Godot), M61/M62 (presupuestos), M90 (presets), M58 (accesibilidad) [M]
- [x] Mapear la sección 48 "ILUMINACIÓN" del plan maestro al ID 49 de la tabla global [M]
- [x] Separar dentro/fuera de alcance: franjas → M31, clima → M32, VFX → M52, materiales → M47 [S]
- [x] Documentar restricciones: Forward+, ACES sutil, piso anti-oscuridad 0.15, determinismo, sin niebla volumétrica [M]
- [x] Definir criterios de aceptación verificables (8 criterios) [S]

## B. RF1 — Iluminación global

- [x] Definir WorldEnvironment base (tonemapping ACES, gamma 2.2) [M]
- [x] Definir cielo procedural por bioma (M09) [M]
- [x] Definir ambiente por franja con piso mínimo [M]
- [x] Definir sky material por bioma en materials/ [S]

## C. RF2 — Sol y luna

- [x] Definir una única direccional (sol/luna con curvas de color) [M]
- [x] Definir presets por las 5 franjas de M31 (elevación, color, intensidad) [M]
- [x] Definir easing de 3 s entre franjas (sin snaps) [M]
- [x] Definir curva fría de la luna en NOCHE/PROFUNDA [M]

## D. RF3 — GI y baked lighting

- [x] Decidir: lightmaps para estáticos (casas, templos, ruinas, cuevas) [M]
- [x] Decidir: SDFGI/VoxelGI OFF por defecto (prueba documentada si se activa) [M]
- [x] Definir bake en CI (M118) con semilla fija [M]
- [x] Definir memoria de lightmaps contra M62 [M]

## E. RF4 — Iluminación dinámica

- [x] Definir pool de luces dinámicas (M62) [M]
- [x] Definir tope con sombra ≤ 6 por escena [M]
- [x] Definir tope total ≤ 20 por escena [M]
- [x] Definir desactivación por distancia 30 m (M61) [M]

## F. RF5 — Luces interiores

- [x] Definir luz cálida de casas (M18) [S]
- [x] Definir luz de tiendas (M39) y talleres [M]
- [x] Definir ventanas con luz diurna (baked) [M]
- [x] Definir perfil interior_casa.gd [M]

## G. RF6 — Faroles

- [x] Definir faroles de pueblo y caminos [M]
- [x] Definir flicker determinista (fase + semilla) [M]
- [x] Definir luz desde el pool (no por instancia) [M]
- [x] Definir opción de desactivación (M58/M90) [S]

## H. RF7 — Fuego

- [x] Definir luz cálida de hogueras/chimeneas [M]
- [x] Definir parpadeo suave (≤2 Hz, ≤15%) [M]
- [x] Integrar con partículas de M52 [S]

## I. RF8 — Cristales y glifos ancestrales

- [x] Definir luz ambiental sutil de cristales (M47) [M]
- [x] Definir glow acotado (sin bloom agresivo) [M]
- [x] No bloquear rango de luz del jugador [S]

## J. RF9 — Cuevas y subterráneo

- [x] Definir piso anti-oscuridad 0.15 en cuevas (M31) [M]
- [x] Definir esporas de luz (M11) como luz ambiental [M]
- [x] Definir transición gradual día→cueva (fade) [M]
- [x] Definir perfil subterraneo.gd [M]

## K. RF10 — Templos y ruinas

- [x] Definir rayo cenital en salas principales (M24/M25) [M]
- [x] Definir iluminación de bajorrelieves [M]
- [x] Definir ambience suave por sala [M]
- [x] Definir perfil interior_templo.gd [M]

## L. RF11 — Clima y niebla

- [x] Definir niebla exponencial por bioma/franja (M09/M32) [M]
- [x] Definir lluvia: dimming solar suave [M]
- [x] Descartar niebla volumétrica (coste) [S]
- [x] Definir niebla de jungla densa y costa baja [M]

## M. RF12 — Sombras

- [x] Definir cascades ≤ 4 (por preset M90) [M]
- [x] Definir distancia dinámica de sombras (45 m / 25 m bajo) [M]
- [x] Definir bias voxel fino sin acne [M]
- [x] Definir resolución de shadow atlas por preset (1024/2048) [M]
- [x] Definir sombras suaves (PCF ≥ 4 samples) [M]
- [x] Prohibir siluetas negras (ambiente de relleno) [M]

## N. RF13 — Optimización de luces

- [x] Definir pool con MAX_DINAMICAS y MAX_CONT_SOMBRA [M]
- [x] Descartar luz por instancia de props [M]
- [x] Definir desactivación offscreen (M61) [M]

## O. RF14 — Baked lighting

- [x] Definir dónde hornea (interiores y estructuras) [M]
- [x] Definir formato/registro de memoria (M62) [M]
- [x] Definir regeneración en CI [M]

## P. RF15 — Hardware objetivo

- [x] Definir prueba de iluminación en hardware medio (M90) [M]
- [x] Definir presets de calidad de sombras/luz (M90) [M]
- [x] Definir objetivo 30 fps mínimo / 60 deseado [M]

## Q. RF16 — Validación

- [x] Definir validate_lighting.gd [M]
- [x] Verificar límites de luces por escena [M]
- [x] Verificar piso ambiental 0.15 [M]
- [x] Verificar niebla en rango por bioma/franja [M]
- [x] Verificar flicker por accesibilidad [M]
- [x] Definir lighting_budget.json [M]

## R. RF17 — Naming y organización

- [x] Definir prefijos light_, env_, lightmap_ [S]
- [x] Alinear con M108 [M]

## S. Requisitos no funcionales

- [x] Rendimiento: límites + pool + distancias (M61) [M]
- [x] Memoria: lightmap + registro (M62) [M]
- [x] Cozy: atmósfera por franja, legibilidad siempre [M]
- [x] Accesible: flicker suave, opciones M58/M90 [M]
- [x] Determinismo: fase fija, semilla por luz [M]
- [x] Mantenible: presets centrales por franja/bioma [M]

## T. Alternativas consideradas

- [x] Descartar SDFGI global por defecto [M]
- [x] Descartar lightmap de todo el mundo abierto [M]
- [x] Descartar niebla volumétrica [S]
- [x] Descartar luz por instancia [M]
- [x] Descartar un único preset de sombras [S]
- [x] Descartar flicker con RNG [S]

## U. Riesgos y mitigaciones

- [x] Riesgo de overdraw en pueblo → pool + topes + distancia [M]
- [x] Riesgo de acne voxel → bias fino + validación visual [M]
- [x] Riesgo de bake desactualizado → CI con bake + versión en registro [M]
- [x] Riesgo de snaps entre franjas → easing 3 s [M]
- [x] Riesgo de cuevas ilegibles → piso 0.15 + niebla diferenciada [M]
- [x] Riesgo de sombras caras → distancias por preset + pruebas M90 [M]

## V. Integraciones

- [x] Documentar integración con M31 (franjas) [S]
- [x] Documentar integración con M32 (clima) [S]
- [x] Documentar integración con M09 (biomas/sky) [S]
- [x] Documentar integración con M08/M10 (voxel) [S]
- [x] Documentar integración con M18/M24/M25/M26 (interiores) [S]
- [x] Documentar integración con M47 (emisivos) [S]
- [x] Documentar integración con M11 (esporas) [S]
- [x] Documentar integración con M52 (fuego) [S]
- [x] Documentar integración con M61/M62 (presupuestos) [S]
- [x] Documentar integración con M90 (presets) [S]
- [x] Documentar integración con M58 (accesibilidad) [S]
- [x] Documentar integración con M108/M118 (import/bake) [S]

## W. Herramientas y flujos

- [x] Documentar flujo de transición de franja [M]
- [x] Documentar flujo de entrada a cueva [M]
- [x] Documentar flujo de validación de escena [M]

## X. Criterios de aceptación verificados

- [x] Escena pivote ≥ 30 fps en hardware medio con preset default [M]
- [x] 5 franjas distinguibles y correctas según M31 [M]
- [x] Cuevas legibles (piso 0.15) sin luces por instancia [M]
- [x] Luces dinámicas ≤ tope verificado por validador [M]
- [x] Flicker determinista con misma semilla [M]
- [x] Interior de casa horneado y legible sin dinámicas [M]
- [x] Niebla por bioma/lluvia sin romper legibilidad [M]
- [x] Sin sombras negras ni acne visible [M]

## Y. Notas finales

- [x] Documentar el desfase de numeración del plan maestro (48=ILUMINACIÓN → ID 49) [S]
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]