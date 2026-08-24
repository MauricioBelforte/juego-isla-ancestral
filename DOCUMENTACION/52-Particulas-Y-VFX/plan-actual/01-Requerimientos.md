**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 52: Partículas y VFX

## ID del Módulo
- **Código:** M52 (CHECKLIST-GLOBAL: ID 52 — Partículas y VFX; plan maestro: sección 51 "PARTÍCULAS Y VFX")
- **Carpeta:** `DOCUMENTACION/52-Particulas-Y-VFX/`
- **Dependencias:** M04 (Godot — GPUParticles3D), M45 (Arte 3D — sprites/props), M47 (Texturas — materiales luminosos), M49 (Iluminación — glow). Relaciones: M61 (Rendimiento — presupuesto de partículas), M62 (Memoria), M48 (Animación — triggers de timeline), M52 consume de M13/M17/M22/M24/M33/M34/M71 (eventos de juego), M32 (Clima — lluvia/nieve), M31 (Día/Noche), M51 (Agua — salpicaduras), M53 (UI)
- **Delegable desde:** M04 (GPUParticles nativo), M48 (triggers de timeline), M13/M33 (eventos de minado/cosecha)

## 1. Problema

Aurora está llena de momentos que exigen feedback visual: humo de chimeneas, polvo al minar, hojas y pétalos al viento, fuego y lava, chispas al forjar, activación de runas, obtención de Sellos, resolución de puzzles, construcción, cosecha, pesca, descubrimientos, cambios estacionales, partículas de agua/lluvia/nieve y efectos de interfaz. Sin un sistema de VFX definido, el proyecto degeneraría en: cientos de emisores que rompen el frame (overdraw y fill-rate, M61), partículas con RNG que rompen el determinismo (M10), VFX sin sincronía con sonido/feedback (M43/M44), o el mismo efecto implementado de forma distinta en cada sistema. El plan maestro lista 25 exigencias (humo, polvo, hojas, pétalos, chispas, agua, lluvia, nieve, fuego, lava, luz, magia tecnológica, resonancia, runas, teletransporte, Sello, puzzle, construcción, cosecha, pesca, descubrimiento, estaciones, interfaz, atmosféricos, optimización). El objetivo del módulo es que TODO feed-back visual tenga su VFX definido, barato, determinista y armónico con el estilo cozy.

## 2. Objetivo

Definir el sistema de partículas y VFX de la isla: catálogo de efectos del plan maestro (25+), pool central de emisores (GPUParticles3D con reutilización), presupuesto de partículas por escena (M61: límite de emisores y partículas vivas), determinismo (semillas en la emisión, sin RNG por frame), sincronía con timelines de animación (M48), sonido (M43/M44) e iluminación (M49 glow acotado), eventos de juego (runas M24, Sellos M22, puzzles, construcción M17, cosecha M33, pesca M34, descubrimientos M71), efectos atmosféricos por clima/estación (M32/M29/M31), efectos de UI (M53) y accesibilidad (M58: reducir VFX). El resultado debe ser feedback visual satisfecho (cozy, chispas suaves, humo cálido), con coste verificado.

## 3. Alcance

### 3.1 Dentro del alcance
- Catálogo de VFX del plan maestro (25+): humo, polvo, hojas, pétalos, chispas, agua (salpicaduras), lluvia, nieve, fuego, lava, luz, magia tecnológica, resonancia, activación de runas, teletransporte (si existe), obtención de Sello, resolución de puzzle, construcción, cosecha, pesca, descubrimiento, cambio estacional, efectos de interfaz, efectos atmosféricos.
- Pool central: GPUParticles3D reutilizados (one-shot vs looping), con presupuesto por escena (emisores y partículas vivas).
- Determinismo: emisión con semillas fijas; velocidad/posición inicial derivada de PRNG de contexto (M10); sin RNG por frame.
- Sincronía: los triggers de VFX vienen de timelines de animación (M48) y de eventos de juego (M13/M17/M22/M24/M33/M34/M71).
- Glow: bloom acotado (M49), materiales emisivos (M47).
- Atmosféricos: lluvia (M32), nieve (M32/M29), viento con hojas (M50), polvo de desierto, neblina ligera.
- Estacionales: pétalos en primavera, hojas en otoño (M29).
- UI: sprites de partículas 2D en menús (M53) con Reduce Motion (M58).
- Optimización: tope de partículas vivas, culling por distancia, pooling, LOD de emisores (lejos: menos partículas).
- Validación: `validate_vfx.gd` (editor) verifica presupuesto, naming y determinismo.

### 3.2 Fuera del alcance
- El modelado de sprites/texturas de partículas: M45/M47 (se consumen aquí).
- La iluminación de la escena (luces de fuego): M49 (las partículas NO emiten luces; la luz la pone M49).
- El sonido de los efectos: M43/M44 (se coordina, no se genera).
- La animación procedural de vegetación/agua: M50/M51 (los VFX complementan).
- Los shaders de materiales: M47.

## 4. Restricciones

- **Godot 4.x (>= 4.4.1):** GPUParticles3D para 3D; partículas 2D para UI; CPUParticles solo como excepción documentada (M61).
- **Presupuesto:** límite de emisores activos y partículas vivas por escena (M61); sin overdraw > X.
- **Determinismo:** semillas en emisores one-shot; loops con fase fija; sin RNG por frame.
- **Sin luz por partícula:** la luz de fuego/lava la pone M49 (pool de luces), no las partículas.
- **Accesible (M58):** reduce VFX (velocidad/opacidad/desactivación), sin estroboscopios.
- **Coherente:** magnitud de partículas acotada (cozy: chispas suaves, sin humo negro denso).
- **Validable:** todo efecto pasa `validate_vfx.gd`.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Catálogo de VFX | Los 25+ efectos del plan maestro con parámetros (material, emisor, duración, presupuesto) |
| RF2 | Pool central | VfxManager (autoload): emisores one-shot prestados/liberados; loops registro y culling |
| RF3 | Presupuesto por escena | Límite de emisores activos y partículas vivas por escena (contra M61); sin excedentes |
| RF4 | Determinismo | Emisores one-shot con semilla de contexto (M10); loops con fase fija; sin RNG por frame |
| RF5 | Sincronía con animación | Triggers en timelines (M48): minado, cosecha, pesca, construcción, runas, Sello |
| RF6 | Eventos de juego | Obtención de Sello (M22), resolución de puzzle (M24), descubrimiento (M71), victoria de festival (M74) |
| RF7 | Fuego y lava | Humo + ascuas (fuego), burbujas+ascuas (lava M09); la LUZ la emite M49 |
| RF8 | Agua | Salpicaduras al nadar/pisos de agua (M51), gotas de cascada, chapoteo del balde |
| RF9 | Atmosféricos | Lluvia (M32), nieve (M32/M29), polvo del desierto, hojas al viento (M50), pétalos primaverales |
| RF10 | Magia y ancestral | Resonancia de runas, activación de glifos (M24/M26), estelas de luz (M47), magia tecnológica (M86) |
| RF11 | UI | Partículas 2D en menús/recompensas (M53) con Reduce Motion (M58) |
| RF12 | Cambio estacional | Transición de VFX por estación (M29): pétalos↔hojas↔nieve |
| RF13 | Teletransporte (si existe) | Efímero (M28): estela de entrada/salida si se implementa |
| RF14 | Optimización | Tope de partículas, culling por distancia, LOD de emisores, pooling |
| RF15 | Validación | `validate_vfx.gd`: presupuesto, naming, determinismo, sin luz por partícula |
| RF16 | Naming | Convention `vfx_`, `part_` (M108) |

## 6. Criterios de Aceptación (Verificables)

1. Todos los efectos del plan maestro tienen entrada en el catálogo con parámetros y presupuesto.
2. La escena pivote no excede el límite de emisores/partículas (verificado por validador) sin caída de fps.
3. Los VFX one-shot son deterministas (misma semilla → misma distribución visible).
4. Los triggers de VFX sincronizan con animación (M48), sonido (M43) y feedback (M44) al frame.
5. El fuego/lava produce humo y ascuas SIN emitir luz (la luz es de M49, única fuente).
6. Reduce Motion (M58) atenúa o desactiva VFX de UI y sensibles.
7. Los atmosféricos responden a clima/estación (M32/M29) sin lag.
8. El catálogo y la validación están integrados con CI (M118).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M045** — Arte 3D | Partículas sobre modelos |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M045** — Arte 3D | Depende de este módulo |

