**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 98: Trailer

## 1. Análisis del dominio
En un indie premium, el tráiler de gameplay es el activo que más convierte en la página de Steam: define la primera impresión. Los 20 puntos del maestro cubren: tipos de tráiler, guion/storyboard, música, escenas por valor, anti-spoilers, subtítulos, versiones, thumbnails y derechos. La estrategia se alinea con M99 (marketing) y M97 (Steam).

## 2. Alternativas consideradas y decisiones

### D1: Número y tipo de tráilers
- **A1 (uno solo al final)**: poco tiempo para iterar y para campaña temprana.
- **A2 (3 tráilers: teaser, gameplay, lanzamiento con fechas escalonadas)**: teaser en anuncio (con M140), gameplay en página (con M141), lanzamiento en M143.
- **Decisión:** **A2** — 3 hitos con fechas:
  - **Teaser (30-45 s)**: anuncio + identidad visual (M99), revela tono sin gameplay largo.
  - **Gameplay (60-90 s)**: la pieza de M97, cubre los 6 valores.
  - **Lanzamiento (45-60 s)**: remix + key art final + fecha (M143).

### D2: Material del tráiler
- **A1 (pre-render/cinematic)**: costoso y deshonesto si difiere del juego.
- **A2 (100% gameplay real)**: barato, honesto, describe la experiencia real (alineado con la regla anti-falsedad).
- **Decisión:** **A2** — captura desde el build real; se graban planos coreografiados con debug tools (M110/M109) pero siempre in-engine.

### D3: Música y audio
- **A1 (música de stock)**: no representa el producto.
- **A2 (tracks de M41 licenciados)**: identidad sonora propia; derechos auditados con M84.
- **Decisión:** **A2** — se usan tracks del OST del juego (M41); por tráiler se licencian los tracks seleccionados (M84). SFX de tráiler: Foley/audiencia del juego.

### D4: Versiones
- **A1 (solo 16:9)** — pierde el canal vertical (TikTok/Reels/Shorts de M99).
- **A2 (16:9 + 9:16 + recortes por plataforma)**: las 2 versiones + clips de 15-30 s por canal.
- **Decisión:** **A2** — husbandry completo: 16:9 (Steam/YouTube/web), 9:16 (TikTok/Shorts/Reels) y una versión "sin música de licencia de sync" para canales no comerciales (si aplica).

### D5: Anti-spoilers
- **A1 (sin política)**: riesgo de arruinar el lore (M148).
- **A2 (lista de prohibidos + revisión cruzada)**: los 6 sellos, el Templo final y el epílogo quedan fuera; checklist por plan y revisión por revisor externo (M151).
- **Decisión:** **A2** — política escrita y checklist aplicado a cada tráiler; revisor externo firma (M151).

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Trailer deshonesto (difiere del juego) | Media | Alta | Escenas 100% gameplay; comparación build release |
| Spoiler del lore | Media | Alta | Lista de prohibidos + revisión externa |
| Música sin licencia | Baja | Alta | Auditoría M84 en cada tráiler |
| Trailer largo aburrido | Media | Media | Storyboard con ritmo; corte en 90 s |
| Resolución/plataformas incompatibles | Baja | Media | Versiones por M96 (máx 4K, compresión) |

## 4. Plan de ejecución (fases)
| Fase | Hito | Contenido |
|------|------|-----------|
| **F1 Pre** | Anuncio/M140 | Teaser: guion, storyboard, música, thumbnails |
| **F2 Gameplay** | Beta/M141 | Tráiler gameplay: 6 valores, 16:9 + 9:16 |
| **F3 Lanzamiento** | M143 | Tráiler de lanzamiento: remix + key art + fecha |
| **F4 Legales** | Continuo | Derechos de música/arte auditados (M84) |

## 5. Métricas de éxito
1. Teaser publicado ≤ evento de anuncio (M99).
2. Gameplay trailer lidera la página de Steam (M97) con CTR ≥ meta.
3. 6 valores presentes en el gameplay trailer (checklist).
4. 0 infracciones de spoilers (checklist anti-spoilers).
5. Subtítulos en los 6 idiomas verificados.
6. Versiones 16:9 + 9:16 producidas y distribuidas (M99).
7. Derechos auditados con acta (M84/M151).

## 6. Notas para integración
- El gameplay trailer es el activo principal de M97; la campaña de wishlist (M99) lo distribuye.
- Los subtítulos salen de M87 (localización) y cumplen M58 (accesibilidad).
- El tráiler de lanzamiento se incluye en el runbook de M143 (día 0).