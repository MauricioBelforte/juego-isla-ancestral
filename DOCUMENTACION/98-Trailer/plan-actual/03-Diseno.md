**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 98: Trailer

## 1. Hitos y piezas
| Pieza | Duración | Hito | Público/Propósito |
|-------|----------|------|-------------------|
| **Teaser** | 30-45 s | Anuncio (M140) | Toneli, sin gameplay extenso; CTA wishlist |
| **Gameplay** | 60-90 s | Beta (M141) | M97: el activo de conversión; 6 valores |
| **Lanzamiento** | 45-60 s | M143 día 0 | Remix gameplay + key art + fecha |

## 2. Guion y storyboard (RF2)
| Tráiler | Estructura de guion |
|---------|---------------------|
| Teaser | Gancho (1 plano misterioso) → tono/lore (3-4 planos) → logo + CTA (2 s) |
| Gameplay | Hook (primeros 5 s: mundo descubriéndose) → 6 valores (7-10 s c/u) → logro/emoji → logo + CTA |
| Lanzamiento | Mejores planos remix → fecha (3 s finales) → logo |

- Storyboard: 8-10 planos por tráiler aprobados (persona que conoce el juego).
- Ritmo: cortes cada 2-3 s; 1 plano estático con cámara en movimiento por valor.

## 3. Escenas por valor (RF5)
| Valor | Qué mostrar | Plano sugerido |
|-------|-------------|----------------|
| Mundo | Isla voxel, biomas, día/noche | Drone lento sobre el océano → costa |
| Construcción | Crafteo + edificio + casa | Mano a mano de pesca → casa creciendo |
| NPC | Vida diaria, diálogo, fiesta | Vecino saludando, mercado |
| Puzzles | Templo antiguo + ecos + mecánica | Entrada al templo + una mecánica |
| Viajes | Barco entre islas | Velero + vista de islas distantes |
| Misterio | Ruinas, estatuas, lore (sin sellos) | Ruina con luz + símbolo vago |

- 100% gameplay real (RF4): captura con cámara cinematográfica in-engine (grabación del jugador en build actual).

## 4. Música y audio (RF3/RF12)
| Track | Uso | Licencia |
|-------|-----|----------|
| Track A (M41) | Teaser | Licenciado M84 |
| Track B (M41) | Gameplay (en ascenso) | Licenciado M84 |
| Track C (M41) | Lanzamiento (clímax) | Licenciado M84 |
- SFX del juego para impacto (golpes de puzzle, olas, festejo).
- Mix: -14 LUFS (YouTube) / -14 LUFS (Steam); subtítulos con duración exacta.

## 5. Subtítulos (RF7 — M87/M58)
- Idiomas: 6 (es, en, pt, fr, de, ja).
- Estilo de M58: fuente legible, contraste, 150% soportado.
- Entrega: archivos SRT/VTT por idioma + versión recortada con subtítulos quemados (si se prefiere vertical).

## 6. Versiones (RF8-RF10)
| Formato | Resolución | Usos |
|---------|-----------|------|
| 16:9 horizontal | 3840×2160 máx | Steam (M97), YouTube, web (M99) |
| 9:16 vertical | 1080×1920 | TikTok, Shorts, Reels (M99) |
| Recortes por plataforma | 15-30 s | Steam (clip), EGS/GOG según M96 |
- Compresión: H.264 4K/1080p + versiones WebM para web.

## 7. Thumbnails (RF11)
- Por tráiler: miniatura con identidad visual de M99 (logo + 1 plano fuerte).
- Tamaños: 1920×1080 (YouTube), 1280×720 (Steam), 1080×1920 (vertical).
- Texto: máximo 8 palabras; sin spoilers en la miniatura.

## 8. Anti-spoilers (RF6)
| NO mostrar | Motivo |
|------------|--------|
| Los 6 sellos | Lore central (M148) |
| Templo/laberinto final | Desafío y sorpresa del Acto 3 |
| Epílogo / viaje del Vapor a Coral | Contenido póstumo |
| Render de marketing falso | Honestidad (RF4) |
- Checklist de 8 ítems aplicado por tráiler y firmado por revisor externo (M151).

## 9. Derechos (RF12 — M84/M78)
- Cada track: contrato/licencia en la auditoría de M84.
- Arte (key art, posters): M127.
- Aprobación final: M151 con acta legal.

## 10. Repositorio de activos
```
marketing/trailer/
├── teaser/ (guion, storyboard, master 16:9, vertical, thumb)
├── gameplay/ (idem + subtítulos 6 idiomas)
├── lanzamiento/ (idem + llaves de fecha)
└── licencias/ (actas M84 por track)
```