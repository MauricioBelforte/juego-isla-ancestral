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