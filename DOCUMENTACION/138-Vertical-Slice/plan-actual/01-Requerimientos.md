**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 138: Vertical Slice

## ID del Módulo
- **Código:** M138 (CHECKLIST-GLOBAL: ID 138 — Vertical Slice; plan maestro: sección 137 "VERTICAL SLICE")
- **Carpeta:** `DOCUMENTACION/138-Vertical-Slice/`
- **Dependencias:** M137 (Prototipo), M26 (Templo Subterráneo), M19 (NPC y Vecinos). Relaciones: M11 (Jugador), M08/M09/M10 (Mundo), M13 (Herramientas), M15 (Recursos), M16 (Crafting), M17 (Construcción), M18 (Casas), M21 (Diálogos), M24 (Templos y Puzzles), M25 (Ruinas), M41 (Música), M42/M43/M44 (Sonido, SFX, Feedback), M53 (UI/UX), M59/M60 (Guardado/Serialización), M48 (Animación), M52 (Partículas y VFX), M22 (Historia Principal — misión), M46/M47 (Arte), M61 (Rendimiento), M114 (Playtest), M92 (Tutorial), M136 (Roadmap), M152/M153 (Principios, Visión)
- **Delegable desde:** M137 (Prototipo), M136 (Roadmap)

## 1. Problema

El prototipo (M137) validó el núcleo. Ahora hay que probar que el juego puede producirse como **juego completo de punta a punta**: una experiencia breve pero pulida que combine todos los sistemas juntos, con arte, audio, UI, animaciones, VFX, guardado/carga y una misión con recompensa. Sin un Vertical Slice: no se sabe si el proyecto es producible, no se puede mostrar a otras personas (publishers, amigos), y los sistemas que funcionan aislados recién se chocan entre sí en fases tardías (Alpha). El objetivo es la primer porción del juego que se siente "de verdad", de principio a fin, con rendimiento medido.

## 2. Objetivo

Crear el Vertical Slice: la primera zona completa del juego (una esquina de Aurora), jugable de inicio a fin en 20-30 min, que combine TODO lo que el juego será: explorar, extraer, construir, hablar con un NPC con personalidad, resolver un puzzle en una ruina/templo, una misión con recompensa, música, sonidos, UI funcional, animaciones, VFX, guardado y carga — con rendimiento medido (M61) y calidad de "sí, esto es Isla Ancestral". Su propósito: validar la producción, el feel y la visión completa antes de escalar a Pre-Alpha (M139).

## 3. Alcance

### 3.1 Dentro del alcance
- Zona pequeña completa: una porción de Aurora con geografía, vegetación y puntos de interés (M10/M09/M50).
- Un NPC completo: personalidad, rutina de día simple, diálogos, regalos (M19/M21/M64 esbozado).
- Un recurso + una herramienta completa con animación de uso (M15/M13/M48).
- Una casa jugable (M18) y una ruina con puzzle (M25/M24).
- Música (M41) y sonidos/feedback (M42/M43/M44) para toda la zona.
- UI funcional mínima (M53): inventario, diálogo, barras, botones.
- Guardado y carga full del slice (M59/M60) con 0 pérdidas.
- VFX (M52) y animaciones (M48) de los sistemas incluidos.
- Una pequeña misión (M22/M23 esbozo) con recompensa (M38 esbozo).
- Experiencia completa de principio a fin (20-30 min) con tutorial básico (M92).
- Medición de rendimiento real (M61) y playtest de calibrado (M114).

### 3.2 Fuera del alcance
- Océano navegable (M34/M51), viajes entre islas (M28), segundo bioma.
- Economía completa (M38), amistad completa (M20), temporadas (M29).
- Sellos (M153), templos completos (M26), historia larga (M22).
- Arte final de TODO el juego (solo el slice).
- Optimización agresiva (M61 lo mide, la optimización total llega en Alpha).

## 4. Restricciones

- **Tiempo:** 6-10 semanas después del GO del prototipo (M137); el slice debe ser enmarcable (escalable después).
- **Enmarcable:** todo lo del slice debe escalar a la isla completa sin re-trabajo estructural (M07).
- **Rendimiento (M61):** ≥ 60 FPS en config media; frame budget por categoría según perfil (gameplay 2.5ms, voxel 4.0ms, IA 2.0ms, partículas 1.0ms, culling 0.5ms, render 5.0ms, UI 1.5ms → 16.5ms).
- **Cozy (M152):** el slice debe sentirse agradable de principio a fin; sin grind ni ansiedad.
- **Visión (M153):** el slice debe cumplir el contrato O1-O19 en miniatura (ritmo, variedad, misterio).
- **Validable:** checklist de cierre del slice + playtest (M114) + medición FPS real.
- **Calidad:** el slice NO es un prototipo feo; debe ser "demo compartible" (M46/M47 estándar mínimo).
- **Guardado (M59):** carga sin pérdida y con el mundo del slice consistente.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Zona completa | Porción de Aurora con 3-5 puntos de interés y geografía coherente (M10) |
| RF2 | NPC completo | 1 NPC con nombre, personalidad, rutina de día y 6+ líneas de diálogo (M19/M21/M64) |
| RF3 | Recurso y herramienta | Recurso renovable (madera o similar) + herramienta con animación y sonido (M15/M13) |
| RF4 | Casa jugable | Entrar, dormir (pasar el día), guardado automático al dormir (M18/M59) |
| RF5 | Ruina y puzzle | Ruina con 1 puzzle de baja complejidad que recompensa (M25/M24) |
| RF6 | Música | Tema de la zona (loop) + transición acorde (M41) |
| RF7 | Sonidos | SFX para acciones clave + ambiente de la zona (M42/M43/M44) |
| RF8 | UI funcional | Inventario, diálogo, indicador de interactivo, menú pausa básico (M53) |
| RF9 | Guardado/Carga | Save full del slice (M59/M60), carga sin pérdida, 0 bugs conocidos |
| RF10 | VFX | Efectos para extracción, colocación, recompensa, dormir (M52) |
| RF11 | Animaciones | Animación del jugador (caminar, usar), NPC (idle/hablar), puertas (M48) |
| RF12 | Misión | Misión de 3 pasos con recompensa económica mínima (M22/M23/M38) |
| RF13 | Tutorial | Pistas iniciales sin texto (guiado visual, M92) |
| RF14 | Experiencia completa | Loop de 20-30 min de principio a fin para un tester nuevo |
| RF15 | Rendimiento real | Reporte FPS del slice completo en config media (M61) |
| RF16 | Playtest | Sesión de playtest con 5+ testers y encuesta (M114) |
| RF17 | Cierre | Slice versionado con tag `vslice-v1`; decisión documentada de escalar a M139 |

## 6. Criterios de Aceptación (Verificables)

1. RF1-RF14 funcionan integrados: un tester nuevo completa el slice en 20-30 min sin instrucciones externas.
2. El slice se siente "Isla Ancestral" (encuesta: el 100% de testers identifica el juego como cozy/hechizante).
3. ≥ 60 FPS en config media en el punto más denso de la zona (M61).
4. Guardado/Carga con 0 pérdidas en 10 ciclos seguidos (M59).
5. El puzzle no denuncia spoilers de la historia larga (M22/M23 intacta).
6. La misión recompensa sin romper la economía (M93/M38: margen coherente).
7. Música y sonidos no interfieren con la legibilidad de acciones (M43/M44).
8. El tutorial (M92) guía sin texto y sin bloquear la libertad.
9. Todos los assets del slice cumplen el pipeline estándar (M108/M46/M47).
10. El log en `Logs/` está generado y firmado.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M019** — NPC y Vecinos | NPCs en vertical slice |
| **M026** — Templo Subterráneo | Base para templo subterráneo |
| **M137** — Prototipo | Base para prototipo |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M139** — Pre-Alpha | Pre-Alpha |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M019** — NPC y Vecinos | Depende de este módulo |
| **M026** — Templo Subterráneo | Depende de este módulo |
| **M137** — Prototipo | Depende de este módulo |
| **M139** — Pre-Alpha | Este módulo lo necesita |

