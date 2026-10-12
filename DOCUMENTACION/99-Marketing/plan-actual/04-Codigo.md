**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 99: Marketing

## 1. Archivos involucrados

### 1.1 Sitio web (repo de marketing, no confundir con el build del juego)
| Archivo/Asset | Propósito |
|---------------|-----------|
| `marketing/web/index.html` + `marketing/web/styles.css` | Landing con capturas, trailer embed, CTA wishlist |
| `marketing/web/legal.html` | Privacidad/cookies (M126) |
| `marketing/web/prensa.html` | Press kit público |
| `marketing/web/assets/presskit.zip` | Press kit descargable |
| `marketing/web/blog/*.md` | Devlogs/blog (Markdown → HTML) |
| `marketing/identidad/logo-*.png` | Variantes del logo (principal/secundaria/monocromo/favicon) |
| `marketing/identidad/paleta.ase` / `paleta.md` | Paleta y guía de marca |
| `marketing/plantillas/social-*.png` | Plantillas de post para redes |

### 1.2 Quién produce
| Recurso | Detalle |
|---------|---------|
| Video/edición | 1 editor (anuncios, clips: cortes de gameplay con música M41) |
| Redes | 1 CM en calendario mensual (o 0.5 CM + 0.5 editor) |
| Devlogs | El desarrollador + editor; 1/mes mínimo |
| Web | Static site generator (no requiere backend) |

## 2. Funciones clave / herramientas
| Herramienta | Uso |
|-------------|-----|
| Steamworks | Claves de demo y builds para festivales/creadores (M97) |
| SteamDB / wishlist API | Medición de wishlist y seguimiento de campaña |
| Newsletter (Buttondown/Mailchimp) | Lista + doble opt-in + segmentación |
| Analytics web | Conversión de visitas → wishlist |
| Dashboard de campaña | Hoja de cálculo: creadores/prensa/festivales/estado/fecha de contacto (RF10) |

## 3. Datos / config
| Dato | Ubicación | Sistema |
|------|-----------|---------|
| Códigos de creadores | Hoja de campaña + Steamworks | RF10 |
| Segmentos de newsletter | Proveedor de newsletter | RF8 |
| Fechas de festivales | Calendario de marketing (Notion/Sheets) | RF12 |
| Wishlist diaria | SteamDB export | RF9 |
| Mensajes del día 0 | `marketing/lanzamiento/dia0.md` (runbook) | RF13 |

## 4. Tests / QA de marketing
| Prueba | Criterio |
|--------|----------|
| Resolución de capturas | Publicables en Steam size (mín. 3840×2160 para 4K) |
| Gifs: tamaño/peso | ≤ 5 MB, loop limpio, 1080p máx |
| Clips: extracción | Escenas con subtítulos (M87/M58) y música (M41) |
| Web: SEO/OG/lighthouse | ≥ 90 en performance móvil y SEO |
| Footer legal | M126 (privacidad) presente |
| Enlaces | Todos apuntan a la página correcta (wishlist Steam / Discord) |
| Accesibilidad de contenido | Textos ≤ 150% zoom sin cortes (M58) |

## 5. Calendario de producción (holguras)
| Mes | Pieza núcleo |
|-----|--------------|
| M-18 a M-12 | Identidad + web + canales + primeros devlogs |
| M-12 a M-6 | Press kit, media kit, campaña de wishlist, lista de correo |
| M-6 a M-3 | Festivales + outreach creadores/prensa + demo |
| M-3 a M-0 | Segunda ronda outreach, festival final, plan día 0, freeze |
| Día 0+ | Plan de lanzamiento (M143) y community (M100) |

## 6. Notas de integración
- Todo el material pasa por M126/M127 (marketing legal: claims, derechos de música/arte, redes).
- La wishlist es la métrica maestra: se reporta en el dashboard semanal y alimenta el GONOGO de marketing (con M97).
- El módulo 143 (lanzamiento) consume este runbook: responsable de cada acción día 0 ya está definido aquí.
- No se requiere código dentro de Assets/ del juego para marketing; la integración con el juego es SOLO material (capturas/clips/demo).

## Notas del Agente

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 19:30 (UTC-3)
**Estado:** Completado (lote de 36 definiciones — encargo mimo msg 46)

### Lo que hice
- Lote de 36 definiciones en `03-Diseno.md` §9, agrupadas por tema según el encargo:
  - **9.1 Estrategia de marketing (9):** moodboard, paleta oficial, tipografías, estilo de piezas, guía de uso, plantillas de publicación, stack del sitio, estructura de páginas, landing.
  - **9.2 Redes sociales (9):** lista de canales, rol de cada canal, frecuencia semanal, calendario mensual, horarios, naming unificado, bio y enlaces, reglas de engagement, curaduría.
  - **9.3 Comunidad (9):** estructura del servidor Discord, reglas de la comunidad, rol de creadores, moderación y reportes, integración con la web, eventos, canal de FAQ, respaldo de logs, proveedor de newsletter.
  - **9.4 Análisis y métricas (9):** métricas por canal, medición diaria de wishlist, dashboard semanal, criterio de éxito D1, métricas de apertura y clics, métrica por festival, telemetría demo→wishlist, informe de día 1, plan post-lanzamiento.
- 36 flips `[ ]`→`[x]` en `05-Checklist.md` + Totales actualizado: **43 completados / 126 pendientes / 0 no resueltos = 169**.
- Nota de trazabilidad del lote agregada al final del checklist (junto a la nota de drift de atria-dawn).

### Lo que NO pude hacer (honestidad obligatoria)
- Nada dentro del alcance. Las 36 definiciones son documentación pura; el módulo por diseño no requiere código en `Assets/` del juego (§6 arriba).

### Recomendaciones para el próximo agente
- Los 126 `[ ]` restantes son definiciones de producción de assets (capturas, gifs, clips, devlogs, press/media kit) y ejecución operativa (registro de dominio, creación de canales, outreach, festivales, lanzamiento) — requieren equipo de marketing/usuario, no solo documentación.
- Módulo NO candidato a ✅ (126 pendientes); progreso real 43/169. CHECKLIST-GLOBAL.md lo actualiza el director (restricción del encargo).
## Lote s2 (atria-dawn-s2, 2026-10-11, Log 1698)

Lote documental deterministico de 29 items (parte 1: identidad, web, dominio, capturas, gifs).
Entregables: 4 documentos nuevos + 1 ampliado en docs/marketing/.

| Documento | Items cubiertos |
|---|---|
| docs/marketing/logo-especificaciones.md (nuevo) | L18-23 (versiones, favicon, constraint), L28 (tagline), L30 (PNG/SVG) |
| docs/marketing/web-especificaciones.md (nuevo) | L39 (hosting/HTTPS/analytics), L41 (press kit), L42 (legal M126), L45 (accesibilidad), L46 (CTA newsletter) |
| docs/marketing/dominio-registro.md (nuevo) | L50-55 (dominio, variantes 301, correo, renovacion, WHOIS privado) |
| docs/marketing/lista-capturas.md (ampliado 8 -> 12 tomas) | L140-144 (12+ capturas, 4K, UI limpia, sin spoilers, metadatos por area) |
| docs/marketing/guia-gifs.md (nuevo) | L148-152 (8+ gifs, <=5MB loop, WEBP/MP4, features, uso por canal) |

**Progreso:** 43 -> 72 [x] / 169 (97 [ ], 0 [?]).

**Notas:**
- Todos los items son definiciones documentales (verificables en disco); no requieren codigo
  GDScript (coherente con la nota del agente anterior).
- El tagline propuesto ("Descubre la isla que te llama") es la definicion operativa; cualquier
  cambio se versiona en ese documento con fecha.
- El registro del dominio queda **bloqueante por M127** (luz verde de marca) antes de pagar.
- Pendiente (97 [ ]): capturas/gifs/clips reales (produccion de assets), creacion de canales,
  outreach, festivales, lanzamiento — requieren ejecucion operativa, no documentacion.