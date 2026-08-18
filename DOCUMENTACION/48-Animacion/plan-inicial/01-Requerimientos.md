**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 48: Animación

## ID del Módulo
- **Código:** M48 (CHECKLIST-GLOBAL: ID 48 — Animación; plan maestro: sección 47 "ANIMACIÓN")
- **Carpeta:** `DOCUMENTACION/48-Animacion/`
- **Dependencias:** M45 (Arte 3D — mallas, sockets, rigs), M11 (Personaje del Jugador — FSM), M19 (NPC y Vecinos — FSM), M36 (Fauna — estados), M04 (Godot — AnimationPlayer/Skeleton3D). Relaciones: M64 (IA de NPC), M65 (Animales IA), M13 (Herramientas), M17 (Construcción), M50 (Vegetación), M51 (Agua), M74 (Eventos), M21 (Diálogos), M53 (UI/UX), M44 (ASMR y Feedback)
- **Delegable desde:** M45 (rigs y sockets), M11/M19/M36 (FSM de estados), M04 (AnimationPlayer nativo de Godot)

## 1. Problema

Aurora tiene personajes (M11), NPCs (M19), animales (M36) y decenas de objetos animables (puertas, puentes, mecanismos, ascensores, barcos, dirigibles, submarinos, vegetación, agua, fuego, partículas). Sin un sistema de animación definido, el proyecto degeneraría en: importaciones de animación inconsistentes (unas FBX con animación, otras sin ella), FSM de animación duplicadas por actor, mezclas (blend) mal resueltas que se ven robóticas, animaciones caras que rompen el presupuesto de frame (M61), o feedback inconsistente entre sistemas (lo que ve el jugador vs. lo que ocurre en juego). El plan maestro lista explícitamente 25 dominios de animación. El objetivo del módulo es que TODO elemento animable de Aurora tenga su animación definida, producida con una cadena de trabajo común, reproducida con un pool de AnimationPlayer eficiente y verificable.

## 2. Objetivo

Definir el sistema de animación de la isla: flujo de producción de animación (blocking → polish → export), convenciones de importación (naming, tasa de frames, rigs), arquitectura de reproducción (AnimationPlayer + AnimationLibrary + blend/mezcla por FSM), catálogo de animaciones por actor (jugador, NPC, fauna, props, mecánicas), animaciones de mundo (vegetación, agua, fuego, partículas) y de UI (transiciones, recompensas, descubrimientos), reglas de sincronía (sonido M43, feedback M44, partículas M52) y presupuesto de rendimiento (M61) verificable. El resultado debe ser un "kit de animación" central que cualquier actor o sistema consume, con estilos coherentes (cozy, no robótico) y costo de frame acotado.

## 3. Alcance

### 3.1 Dentro del alcance
- Catálogo de animaciones del plan maestro (25 dominios): jugador, NPC, animales, herramientas, vegetación, agua, fuego, partículas, puertas, puentes, mecanismos, ascensores, barcos, dirigibles, submarinos, UI, diálogos, recompensas, descubrimientos, festivales, construcciones, cosecha, pesca, minería, puzzles.
- Flujo de producción: pipeline de animación (rig → blocking → polish → export), tasas de frames y convenciones de exportación.
- Rigs y skins: rigs de M45 compatibles, sockets de herramientas, huesos estándar por familia (humanoide, cuadrúpedo, ave, pez).
- Arquitectura de reproducción: AnimationPlayer + AnimationLibrary por actor, mezcla (blend) de capas, FSM de animación por actor (jugador M11, NPC M19, fauna M36/M65), transiciones y blending modes.
- Animación procedural acotada: vegetación (viento M50), agua (M51), fuego (M52), sujeción de herramientas con sockets.
- Animaciones de UI: transiciones, recompensas, descubrimientos, diálogos (M21/M53).
- Sincronía: keyframes de audio (M43) y de feedback ASMR (M44), triggers de partículas (M52).
- Presupuesto: registro de animaciones contra M61 (coste de huesos actualizados, blend trees acotados).
- Validación: `validate_animation.gd` (editor) verifica naming, tasa de frames, poses de referencia, coste por actor.

### 3.2 Fuera del alcance
- El modelado de mallas y rigs esqueleto: M45 (aquí se consumen).
- Las FSM de comportamiento (IA, input): M11/M64/M65 (aquí se consumen como estados).
- El sonido y el feedback: M43/M44 (se sincronizan vía keyframes).
- Las partículas y VFX: M52 (se trigger desde animaciones).
- El arte 2D de UI (sprites animados del menú): M46/M53 (las animaciones de UI aquí son Tween/AnimationPlayer sobre UI Toolkit/Canvas).
- El movimiento físico (movement physics, Cinemachine/spring-arm): M12.

## 4. Restricciones

- **Godot 4.x (>= 4.4.1):** AnimationPlayer + AnimationLibrary + Skeleton3D nativos; sin skins ni sistemas de animación de terceros (M04).
- **Presupuesto:** el registro de animaciones se verifica contra M61 (frames de huesos, blend trees ≤ N actores, LOD de animación en distancia).
- **Determinismo:** animaciones de mundo (viento, agua, fuego) deterministas por fase fija (TIME) sin RNG.
- **Producción:** animaciones exportadas en 30 fps base (UI 60 fps), con referencias de pose (T-pose) únicas; zero keys redundantes.
- **Acoplamiento:** la capa de animación JAMÁS decide comportamiento; solo refleja el estado del FSM (M11/M64/M65) vía API expuesta.
- **Coherente:** proporcional al estilo cozy (M45); movimientos leves, sin physx exagerado ni snaps.
- **Sincronía:** los eventos de sonido/feedback van EN las animaciones (keyframes), no en lógica.
- **Validable:** cada animación importada pasa `validate_animation.gd` previo a usarse.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Flujo de producción | Pipeline de animación: rig (M45) → blocking → polish → export 30fps; convenciones de exportación (FBX, T-posa, skeletons humanos/cuadrúpedos/aves/peces) |
| RF2 | Kit de animación del jugador | Animaciones de la FSM de M11 (10 estados): idle, caminar, correr, saltar, nadar, escalar, extraer, colocar, minar, pescar, coleta de agricultura, diálogo, dormir, petit-déjener, festejos |
| RF3 | Animaciones de NPC y vecinos | Animaciones de rutina y social de M19: idle, caminar, rutinas de trabajo, conversar, gestos de amistad (M20), festivos (M74) |
| RF4 | Animaciones de fauna | Estados de M36/M65: idle, pastorear, huir, volar, nadar, dormir; manadas/bancos con variantes de fase |
| RF5 | Animaciones de herramientas | Uso de 9 herramientas x 4 niveles (M13) con sockets de M45; swings, minado, plantación, regado, pesca, martilleo, lupa |
| RF6 | Animaciones de mecánicas | Puertas, puentes, mecanismos, ascensores (M24/M26/M66), construcción (M17), cosecha (M33), pesca (M34), minería (M35), puzzles (M24) |
| RF7 | Animaciones de vehículos | Barcos (M28), dirigibles y submarinos (M67): mecánicas de navegación, atraque, ascenso/descenso |
| RF8 | Animaciones de mundo | Vegetación (viento M50), agua (M51), fuego y partículas (M52): procedurales deterministas, costo acotado |
| RF9 | Animaciones de UI | Transiciones de menús (M53), recompensas, descubrimientos, diálogos (M21): Tween/AnimationPlayer, 60 fps, accesibles (M58) |
| RF10 | Sincronía | Keyframes de sonido (M43), feedback ASMR (M44) y partículas (M52) embebidos en las animaciones |
| RF11 | Presupuesto y LOD de animación | Verificación contra M61: actores animados por burbuja (con M64), blend trees acotados, LOD de animación por distancia |
| RF12 | Validación automática | `validate_animation.gd` verifica naming, frames, poses de referencia, coste, sincronía de keyframes |
| RF13 | Naming y organización | Convenciones `anim_`, `rig_`, bibliotecas por actor (M108) |
| RF14 | Registro de animaciones | `animation_budget.json`: coste estimado por actor/animación contra presupuesto de M61 |
| RF15 | API de reproducción | Servicio `AnimationService` (autoload) con API única: `play(actor, estado, blend_time)` — la lógica de gameplay llama animación por ESTADO, no por clip |

## 6. Criterios de Aceptación (Verificables)

1. Todo actor de la isla (jugador, NPCs, fauna) tiene 100% de sus estados FSM cubiertos con animaciones del kit.
2. Toda mecánica listada (puertas, ascensores, barcos, cosecha, pesca, minería, puzzles, construcción) tiene su animación o "sin animación intencional" definida en el catálogo.
3. Las animaciones se generan con el mismo flujo, exportan a 30 fps y pasan `validate_animation.gd` sin errores.
4. Las transiciones entre estados no muestran snaps ni t-poses; blend correcto (≤ 250 ms).
5. Los eventos de sonido y feedback disparan al frame correcto (sin desincronía perceptible).
6. El coste de animación de una escena pivote queda dentro del presupuesto de M61 (verificado por registro).
7. Se respeta el determinismo de mundo (viento/agua/fuego) sin RNG visible en runtime.
8. Las animaciones de UI respetan M58 (reducir movimiento) y corren a 60 fps.