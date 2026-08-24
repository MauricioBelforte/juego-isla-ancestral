**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 98: Trailer

## 1. Problema
El tráiler es el **activo de conversión nº 1** de la página de Steam (M97): el jugador decide en segundos si el juego le interesa. Sin un plan de tráilers (teaser, gameplay, lanzamiento) con guion, storyboard, música, escenas seleccionadas, subtítulos, versiones por formato/plataforma y thumbnails, la página de venta queda coja y la campaña de wishlist (M99) pierde su motor más potente. Además, evita spoilers del lore (M148) y obliga a revisar derechos de música (M84/M78).

## 2. Objetivo del módulo
Documentar el **plan de tráilers** del juego: teaser (anuncio temprano), tráiler de gameplay (foco de la página), tráiler de lanzamiento (M143); guion y storyboard; música (M41) y escenas por área de valor (mundo, construcción, NPC, puzzles, viajes, misterio); política anti-spoilers; subtítulos (M87/M58); versiones horizontal/vertical (redes M99) y por plataforma (M96); thumbnails y revisión de derechos de música (M84/M78).

## 3. Alcance (derivado del plan maestro: sección 97 "TRAILER")
1. **Trailer teaser** — anuncio corto (30-45 s) temprano (con la identidad visual de M99).
2. **Trailer gameplay** — el principal (60-90 s) para la página de Steam (M97).
3. **Trailer de lanzamiento** — para el día 0 (M143) con key art final.
4. **Guion** — estructura por tráiler (gancho, trama, CTA).
5. **Storyboard** — plan de planos por tráiler.
6. **Seleccionar música** — tracks de M41 con ritmo por tráiler.
7. **Seleccionar escenas** — captura de gameplay real (sin pre-render falso).
8. **Mostrar mundo** — el valor principal (isla voxel, biomas).
9. **Mostrar construcción** — crafting/building (M16/17).
10. **Mostrar NPC** — vida y comunidad (M19/20).
11. **Mostrar puzzles** — templos y misterio (M24/25/26).
12. **Mostrar viajes** — navegación entre islas (M28).
13. **Mostrar misterio** — lore y sellos sin spoilers (M147/148).
14. **Evitar spoilers importantes** — política explícita de qué NO mostrar.
15. **Crear subtítulos** — en los 6 idiomas (M87) alineado con M58.
16. **Crear versión horizontal** — YouTube/web/Steam (16:9).
17. **Crear versión vertical** — TikTok/Shorts/Reels (9:16) para M99.
18. **Crear versiones por plataforma** — video de Steam (máx resoluciones), EGS/GOG.
19. **Crear thumbnails** — miniatura por tráiler con identidad.
20. **Revisar derechos de música** — licencias de M41/M84/M78.

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | 3 tráilers definidos (teaser, gameplay, lanzamiento) con fechas |
| RF2 | Guion y storyboard por tráiler aprobados |
| RF3 | Música seleccionada con derechos licenciados (M84) |
| RF4 | Escenas 100% gameplay real (sin falsedad) |
| RF5 | Cobertura de los 6 valores (mundo, construcción, NPC, puzzles, viajes, misterio) |
| RF6 | Política anti-spoilers (no revelar sellos/final) |
| RF7 | Subtítulos en 6 idiomas (M87/M58) |
| RF8 | Versión horizontal 16:9 (Steam/YouTube) |
| RF9 | Versión vertical 9:16 (TikTok/Reels/Shorts) |
| RF10 | Versiones por plataforma según requisitos de M96 |
| RF11 | Thumbnails con identidad visual (M99) |
| RF12 | Derechos de música/arte auditados (M78/M84/M127) |

## 5. Criterios de aceptación (DoD del módulo)
1. 3 tráilers con fecha, guion y storyboard definidos.
2. Música licenciada (M84) y aprobada por track.
3. Escenas capturadas del build real (M140+ en adelante).
4. Los 6 valores cubiertos en el gameplay trailer.
5. Checklist anti-spoilers revisado (0 infracciones).
6. Subtítulos en los 6 idiomas (M87).
7. Versiones 16:9 y 9:16 producidas.
8. Versiones por plataforma empaquetadas según requerimientos (M96/M97).
9. Thumbnails presentados y aprobados.
10. Derechos revisados y documentados (M78/M84).

## 6. Restricciones
- **Aplican:** M97 (Steam page), M99 (marketing — distribución), M41 (música), M84/M78 (legal música/PI), M87 (localización), M58 (accesibilidad/subtítulos), M148 (anti-spoilers), M143 (lanzamiento).
- 100% de las escenas de gameplay real (pantallas del juego, no cinemáticas falsas de marketing).
- Sin spoilers: nunca se muestran los 6 sellos, el Templo final, ni el epílogo.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M097** — Steam / Store Page | Base para steam / store page |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M097** — Steam / Store Page | Depende de este módulo |

