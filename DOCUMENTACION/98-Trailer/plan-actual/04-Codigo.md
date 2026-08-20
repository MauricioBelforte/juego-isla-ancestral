**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 98: Trailer

## 1. Archivos involucrados

### 1.1 Assets del tráiler (no código Unity runtime)
| Archivo/Asset | Propósito |
|---------------|-----------|
| `marketing/trailer/teaser/*` | Guion, storyboard, master 16:9, vertical, thumbnail |
| `marketing/trailer/gameplay/*` | Idem + subtítulos SRT/VTT (6 idiomas) + clips 6 valores |
| `marketing/trailer/lanzamiento/*` | Idem + llaves de fecha |
| `marketing/trailer/licencias/*` | Actas de derechos por track (M84) |
| `marketing/trailer/thumbnails/*` | Miniaturas por tráiler |

### 1.2 Herramientas para capturar gameplay
| Herramienta | Uso |
|-------------|-----|
| Debug tools (M109/M110) | Coreografía de planos (cámara, hielo, invencible) |
| In-game photo/camera (M56) | Planos estáticos de máxima resolución |
| Record (OBS/built-in) | Captura 4K/60 del gameplay |
| Editor de video | Corte, ritmo, música, subtítulos |

### 1.3 Quién produce
| Recurso | Detalle |
|---------|---------|
| Editor de video | 1 editor (post de M99) |
| Sonido | Uso de tracks M41 + SFX |
| Localización (M87) | Subtítulos en 6 idiomas |
| Legal (M84) | Licencias de cada track |

## 2. Herramientas y pasos clave
```markdown
Captura:
  1. Escoge nivel/cámara correcta (M109) sin UI.
  2. Graba gameplay a 4K/60 con HDR.
  3. Separa los 6 valores en 6-8 planos coreografiados.

Edición:
  - Corte a 2-3 s por plano; -14 LUFS master.
  - Coloca música (M41) con ritmo de piano.
  - Subtítulos (M87) quemados o SRT.
  - Versiones 16:9 / 9:16 / recortes por plataforma (M96).

Licencias:
  - Registra cada track en acta M84.
```

## 3. Datos / config
| Dato | Ubicación | Sistema |
|------|-----------|---------|
| Tracks licenciados | `licencias/trailer-I.csv` | M84 |
| Subtítulos | SRT/VTT por idioma | M87/M58 |
| Metadatos de video | Master + proxies | YouTube/Steam |
| Checklist anti-spoiler | `trailer/checklist-spoilers.md` | M151 |

## 4. QA del tráiler (M114)
| Prueba | Criterio |
|--------|----------|
| Audio: nivel y clics | -14 LUFS, 0 clipping |
| Subtítulos sincronizados | ±1 frame por idioma |
| Anti-spoiler | Checklist firmado (0 infracciones) |
| Resolución/formatos | 16:9 y 9:16 para M97/M99 |
| Derechos | Acta M84 por track |

## 5. Distribución
- Steam (M97): el tráiler de gameplay se sube como "video promocional" en la página.
- M99: teaser en redes/YouTube; lanzamiento en el runbook de M143.

## 6. Notas de integración
- El tráiler de gameplay es el activo principal de M97; refuerza la wishlist (M99).
- Los subtítulos provienen del pipeline de M87 (mismos textos) y cumplen M58.
- M143 (día 0) incluye el tráiler de lanzamiento en su runbook.