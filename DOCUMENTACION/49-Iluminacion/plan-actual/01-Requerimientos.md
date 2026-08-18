**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 49: Iluminación

## ID del Módulo
- **Código:** M49 (CHECKLIST-GLOBAL: ID 49 — Iluminación; plan maestro: sección 48 "ILUMINACIÓN")
- **Carpeta:** `DOCUMENTACION/49-Iluminacion/`
- **Dependencias:** M07 (Arquitectura — capas), M08 (Mundo Voxel — meshes), M31 (Ciclo Día/Noche — 5 franjas), M45 (Arte 3D — estilo), M04 (Godot — RenderingServer/WorldEnvironment). Relaciones: M61 (Rendimiento), M62 (Memoria), M32 (Clima), M58 (Accesibilidad), M47 (materiales luminosos), M50 (Vegetación), M52 (VFX)
- **Delegable desde:** M31 (franjas horarias), M08 (mundo base), M45 (estilo), M04 (rendering nativo)

## 1. Problema

Aurora es un mundo voxel abierto (M08) con ciclo día/noche de 5 franjas (M31), biomas variados (M09), cuevas, templos, ruinas y elementos luminosos (cristales, glifos, esporas de M47). Sin un sistema de iluminación definido, el proyecto degeneraría en: sombras quebradas en el voxel (rogue shadow acne/peter-panning), demasiadas luces dinámicas que rompen el presupuesto de frame (M61), cuevas ilegibles o anegadas en la oscuridad (rompiendo la regla cozy anti-oscuridad de M31), iluminación horaria que no respeta la identidad de las 5 franjas, o algún hardware objetivo (Steam Deck, M58) incapaz de correr la escena. El plan maestro lista 20 exigencias: iluminación global, GI, dinámica, horaria, solar, lunar, interiores, faroles, fuego, cristales luminosos, cuevas, templos, ruinas, clima, niebla, sombras, luces, límites de luces dinámicas, baked lighting y pruebas en hardware. El objetivo del módulo es que TODA escena de Aurora luzca el estilo cozy definido (M45) respetando su paleta y atmósfera por franja, con presupuestos verificables.

## 2. Objetivo

Definir el sistema de iluminación de la isla: jerarquía de luces (sol/luna como globales, luces puntuales de interiores, faroles, fuego, cristales), GI acotado a escenas estáticas (baked/lightmap) y dinámico solo donde hace falta, reglas de iluminación por franja horaria (M31) y por bioma/clima (M09/M32), configuración de niebla, gestión de sombras (cascades, distancia dinámica, calidad por LOD M61), límites duros de luces dinámicas por escena, y el pipeline de verificación en hardware objetivo. El resultado debe ser una iluminación "cozy" consistente (interior siempre legible, exterior con atmósfera por franja), sin cegar ni oscurecer, con coste de frame y memoria verificados.

## 3. Alcance

### 3.1 Dentro del alcance
- Iluminación global y ambiente: WorldEnvironment, ambient light, tonemapping (cozy, no HDR agresivo).
- Sol y luna: luces direccionales por franja de M31 (posición, color, intensidad, altura), incluida la franja PROFUNDA.
- GI: baked lighting (lightmap) para interiores estáticos (casas M18, templos M24/M26, ruinas M25, cuevas), SDFGI/VoxelGI NO por defecto (coste); pruebas de GI acotado en escenas clave.
- Iluminación dinámica: luces puntuales/spot de interiores vivos, faroles, fuego, cristales luminosos; con tope por escena.
- Luces interiores: casas de vecinos (M18), talleres, tiendas (M39), interiores de templos.
- Faroles y fuego: luz cálida con flicker suave (determinista, M61); faroles de pueblo y de caminos.
- Cristales luminosos y glifos ancestrales (M47): luz ambiental sutil + glow (M52) sin bloom agresivo.
- Cuevas y subterráneo: mínima legible (piso 0.15 de M31), luz de esporas (M11), entrada día→cueva gradual.
- Templos y ruinas: rayo de luz cenital, bajorrelieves iluminados, transición de ambientes.
- Clima y niebla: niebla por bioma/franja (M32), densa en jungla, baja en costa; lluvia con dimming solar suave.
- Sombras: cascades ≤ 4, distancia dinámica por calidad (M61/M90), artefactos del voxel mitigados (bias fino, shadow acne previo).
- Límites: máx. N luces dinámicas por escena (presupuesto M61), sin luces por instancia, pool de luces para faroles.
- Baked lighting: estáticos se hornean (lightmaps) donde conviene; dinámicos solo en burbuja (M64) o por evento.
- Hardware: pruebas de iluminación en objetivo (Steam Deck/medio) con métricas M61.
- Validación: `validate_lighting.gd` (editor) verifica límites y presupuesto.

### 3.2 Fuera del alcance
- El ciclo día/noche y sus franjas: M31 (aquí se consume la franja activa).
- El clima y sus efectos: M32 (se consume lluvia/niebla).
- Shaders de materiales luminosos: M47 (consume luz aquí definida).
- El VFX de partículas (fuego visual): M52 (la LUZ del fuego se define aquí).
- La configuración gráfica del jugador (presets, calidad de sombras): M90 (consume los toggles aquí definidos).
- El arte: M45/M46.

## 4. Restricciones

- **Godot 4.x (>= 4.4.1):** rendering Forward+ con tonemapping ACES sutil; XR no aplica.
- **Presupuesto:** cantidad de luces dinámicas, cascades y distancia de sombras se verifican contra M61; memoria de lightmaps contra M62.
- **Cozy:** regla anti-oscuridad de M31 (piso 0.15); sin sombras negras totales; interior siempre legible; sin parpadeo agresivo.
- **Determinismo:** flicker de fuego/farol por fase fija (TIME + semilla por luz), sin RNG impredecible.
- **Estática vs dinámica:** todo lo estático se hornea (lightmap) si genera luz; los dinámicos se poolen.
- **Hardware:** la escena pivote debe correr en el hardware medio (M90/M61) con los presets default.
- **Validable:** toda escena se valida con `validate_lighting.gd` (límites, presupuesto, legibilidad mínima).
- **Accesible (M58):** sin estroboscopios; luces activables/deseabiables por el jugador con opciones M90.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Iluminación global | WorldEnvironment: ambiente base, cielo procedural por bioma (M09), tonemapping ACES sutil, gamma objetivo (valores de referencia) |
| RF2 | Sol y luna | Luces direccionales definidas por franja de M31 (5 franjas: posición, intensidad, color, alturas click); la PROFUNDA casi sin luz exterior (limitada por anti-oscuridad) |
| RF3 | GI y baked lighting | Interiores estáticos (casas, templos, ruinas, cuevas) con lightmap; dinámicos solo en burbuja; SDFGI no por defecto (pruebas documentadas si se activa en escena clave) |
| RF4 | Iluminación dinámica | Luces puntuales de interiores vivos, faroles, fuego, cristales; tope por escena (RF11); pool de luces |
| RF5 | Luces interiores | Casas (M18), tiendas (M39), talleres: luz cálida suave, ventanas con luz día deseeable (baked) |
| RF6 | Faroles | Faroles de pueblo y caminos: esfera cálida + flicker sutil determinista; pool, sin luz por instancia |
| RF7 | Fuego | Hogueras (M17), chimeneas: luz dinámica cálida + parpadeo suave; complemento de partículas M52 |
| RF8 | Cristales y glifos ancestrales | Luz ambiental sutil (M47 emisivos) + glow acotado (M52); no bloquear el rango de luz del jugador |
| RF9 | Cuevas y subterráneo | Piso 0.15 de M31; esporas de luz (M11); transición día→cueva gradual (fade); entrada visible |
| RF10 | Templos y ruinas | Rayo cenital en cámaras principales, bajorrelieves iluminados (M24/M25), ambience suave por sala |
| RF11 | Clima y niebla | Niebla por bioma/franja/clima (M32); lluvia: dim solar suave; niebla densa en jungla/mar; niebla volumétrica NO (coste) |
| RF12 | Sombras | Cascades ≤4 (config M90), distancia dinámica por preset, bias anti-acne, sombras suaves de baja resolución para cozy; sombras de cielo/cielo no |
| RF13 | Optimización de luces | Pool de luces dinámicas, luces dinámicas ≤ N por escena, offscreen desactivadas (con M61) |
| RF14 | Baked donde convenga | Lightmap para estáticos de interiores y estructuras; registro de memoria (M62) |
| RF15 | Hardware objetivo | Test de iluminación en hardware medio (M90): fps, memoria, sin artefactos visuales; presets de calidad de sombras/iluminación |
| RF16 | Validación | `validate_lighting.gd`: límites por escena, legibilidad mínima (piso 0.15), presupuesto del registro |
| RF17 | Naming y organización | Convention `light_`, `env_`, `lightmap_` (M108) |

## 6. Criterios de Aceptación (Verificables)

1. La escena pivote (pueblo al atardecer) corre en el hardware medio ≥ 30 fps (objetivo 60) con preset default (M90/M61).
2. Las 5 franjas horarias se ven distinguibles y correctas (posición/color del sol/luna según M31).
3. Las cuevas mantienen legibilidad mínima (piso 0.15) sin luces por instancia.
4. El número de luces dinámicas por escena es ≤ tope y se verifica con el validador.
5. Los flickers de fuego/farol son deterministas (misma semilla, mismo resultado).
6. El interior de una casa de vecino (M18) está horneado y legible sin luces dinámicas activas.
7. La niebla de jungla/lluvia responde a M32/M09 y no rompe la legibilidad.
8. No hay sombras negras totales ni acne visible en el voxel (revisión visual en hardware objetivo).