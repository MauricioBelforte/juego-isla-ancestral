# Módulo 128: Identidad de Marca — Plantillas de Posts con Marca

**Modelo:** Ling 3.1 Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 23:12 UTC
**Encargo:** mimo-v2.6 (Director) — msg 48 del canal Ling-3.1-Flash (lote documental M128)
**Ítem del checklist:** F.L120 "Crear plantillas de posts con marca"

> Complemento documental de M99 §9.1 ítem 1.6 (plantillas de publicación): aquí está la
> especificación de **marca** (paleta, tipografía, logo, contraste) que toda plantilla
> debe cumplir. Las plantillas gráficas finales (Figma/Canva) son producción de
> marketing (M99) sobre esta especificación.

## Especificación común a las 3 plantillas

| Elemento | Regla de marca |
|----------|----------------|
| Paleta | Fondos: Blanco Perla #F5F0E8 / Crema #FAF8F5 / Azul Bosque #2E5A4C. Acento: Dorado Anciano #D4A843. Texto: Carbón #2C2C2C |
| Tipografía | Títulos: Display (Fredoka One, M88). Cuerpo: Texto (Nunito, M88). Tamaños: título ≥ 24 px, cuerpo 16 px base |
| Logo | ≥ 24 px de altura (mínimo de marca, M99 §9.1 ítem 1.5); espacio de seguridad = 1× la altura del logo; fondo limpio (contraste ≥ 4.5:1) |
| Estilo de pieza (M99 §9.1 ítem 1.4) | Borde redondeado 12 px · textura papel antiguo 8% de opacidad · sombra suave (0 4 12 px, 12% negra) · grid 12 columnas · margen de seguridad 5% del ancho |
| Texto | ≤ 5 palabras (regla de curaduría M99 §9.2 ítem 5.10); nunca spoilers de los 6 sellos |
| CTA | Wishlist (enlace único a la web, M99 §9.2 ítem 5.7) |
| Dimensiones | 1080×1080 (Instagram) · 1080×1920 (TikTok/Shorts/Reels) · 1200×630 (web/OG) |

### Combinaciones de contraste seguras (verificadas WCAG 2.1)

| Texto | Fondo | Contraste | Uso |
|-------|-------|----------|-----|
| Blanco Perla | Azul Bosque | ≈6.9:1 | ✅ AA — variantes sobre fondo oscuro |
| Carbón | Dorado Anciano | ≈6.3:1 | ✅ AA — acentos, fechas, números |
| Carbón | Blanco Perla / Crema | ≈13:1 | ✅ AA — texto principal sobre fondos claros |
| Dorado Anciano | Azul Bosque | ≈3.5:1 | ⚠️ solo texto grande ≥24 px bold (AA-large) |

**Prohibidas** (test H3 de Hy3, 2026-10-11): Carbón/Azul Bosque (1.78) · Blanco
Perla/Dorado Anciano (1.95) · Dorado Anciano/Cielo Claro (1.01).

## Plantilla 1 — Anuncio (teaser, beta, lanzamiento)

```
┌──────────────────────────────┐
│  [LOGO]  (centro superior,   │
│   Blanco Perla, ≥ 48 px)     │
│                              │
│   ┌────────────────────┐     │
│   │                    │     │
│   │  1 CAPTA FUERTE    │     │
│   │  (sin spoilers)    │     │
│   │                    │     │
│   └────────────────────┘     │
│                              │
│   TÍTULO ≤ 5 PALABRAS        │
│   (Display, Blanco Perla)    │
│                              │
│        [ CTA WISHLIST ]      │
│        (Dorado Anciano,      │
│         texto Carbón)        │
└──────────────────────────────┘
Fondo: Azul Bosque pleno
```

- Uso: hitos de comunicación (M140 teaser, M141 beta, M143 lanzamiento).
- Captura: 1 plano fuerte del juego, gameplay real (RF4), sin UI de debug.

## Plantilla 2 — Devlog

```
┌──────────────────────────────┐
│ [LOGO] (esq. superior izq., │
│  ≥ 32 px, Carbón)            │
│                              │
│ TÍTULO DEL DEVLOG (Display,  │
│ Carbón, ≤ 5 palabras)        │
│ ── fecha (Dorado Anciano) ── │
│                              │
│ ┌──────┐ ┌──────┐ ┌──────┐   │
│ │cap.1 │ │cap.2 │ │cap.3 │   │
│ └──────┘ └──────┘ └──────┘   │
│                              │
│ Cuerpo: Nunito 16 px,        │
│ Carbón sobre Crema           │
│                              │
│   [ leer más · wishlist ]     │
└──────────────────────────────┘
Fondo: Crema #FAF8F5
```

- Uso: devlogs mensuales (YouTube + web).
- Capturas: 1-3, gameplay real, con textura papel antiguo 8%.

## Plantilla 3 — Hito (wishlists, festivales)

```
┌──────────────────────────────┐
│        [LOGO] (centro,       │
│         Blanco Perla)        │
│                              │
│      ◆ 10.000 WISHLISTS ◆    │
│   (Display ≥ 48 px bold,     │
│    Dorado Anciano)           │
│                              │
│   ┌────────────────────┐     │
│   │   captura del      │     │
│   │      hito          │     │
│   └────────────────────┘     │
│                              │
│   gracias · [ wishlist ]      │
│   (Blanco Perla)             │
└──────────────────────────────┘
Fondo: Azul Bosque pleno
```

- Uso: hitos numéricos (wishlists, festivales RF12, lanzamiento).
- El número grande (≥48 px bold) usa Dorado Anciano sobre Azul Bosque (≈3.5:1,
  permitido solo por ser texto grande — AA-large).

## Notas de producción

- Las plantillas gráficas (PSD/Canva/Figma) las arma marketing (M99) sobre esta
  especificación; los `.psd` de referencia figuran en `03-Diseno.md` §4
  (`plantillas/plantilla-post-redes.psd` etc.) — pendientes de creación por M46.
- Toda pieza debe pasar el anti-spoiler (M98 §8: 6 sellos, Templo, epílogo) antes de
  publicar.

**Firma:** Ling 3.1 Flash / Kilo Code — 2026-10-11 23:12 UTC
