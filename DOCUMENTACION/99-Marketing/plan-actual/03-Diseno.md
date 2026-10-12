**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 99: Marketing

## 1. Identidad visual y logo (RF1)
| Elemento | Definición |
|----------|-----------|
| Paleta | Derivada del arte del juego (M45/M46): verdes océano, arena cálida, coral, niebla ancestral |
| Tipografías | De M88 (fuentes del juego) |
| Logo | 3 variantes: principal (color + sombra), secundaria (contorno), monocromo; favicon 32-512px |
| Moodboard | Tablero público de inspiración (Pinterest/Notion) |
| Aplicaciones | Web, Steam (M97), redes, press kit, gifs, videos, Discord |

## 2. Página web y dominio (RF2)
- Dominio: `islaancestral.com` (o variante disponible); registrar + reenvíos de variantes.
- Stack: sitio estático (Next/Astro o similar) + SEO básico (title, OG, sitemap).
- Estructura: Portada (valor con trailer/capturas + CTA wishlist) · El juego · Galería · Devlogs/Blog · Página de prensa · Newsletter · Contacto/legal (M126).
- Hosting con HTTPS y analytics simple (plausible/GA4 mínimo).
- Actualización: mínimo mensual (devlog cruzado).

## 3. Canales sociales (RF3)
| Canal | Rol | Frecuencia |
|-------|-----|-----------|
| YouTube | Núcleo: devlogs, clips largos, trailer | 1 video/mes mínimo |
| Discord | Núcleo: comunidad (M100) | Diaria |
| TikTok | Extensión: clips cortos 30-60 s | 3/semana |
| Instagram | Extensión: capturas + reels | 3/semana |
| Bluesky/X | Extensión: anuncios breves | 2/semana |
| Newsletter | Núcleo: comunicados, fechas | 1/mes |

- Calendario mensual con 12 piezas programadas y plan B (de 3 a 5 días hábiles de holgura).
- Todas las publicaciones enlazan a la wishlist de Steam (M97).

## 4. Material (RF4-RF8)
| Artifacto | Cantidad mínimo | Formato |
|-----------|-----------------|---------|
| Press kit | 1 página web descargable | PDF + zip |
| Media kit | 1 pack | ZIP (logo, capturas, gifs, bio) |
| Capturas | 12+ (una por área clave) | PNG 4K |
| Gifs | 8+ | WEBP/MP4 loop |
| Clips | 6+ (1 por feature: pesca, construcción, templos...) | MP4 1080p |
| Devlogs | 8+ antes del lanzamiento | YouTube + web |
| Blog | 6+ artículos | Web |

## 5. Audiencia: Discord, newsletter, lista de correo y wishlist (RF8/RF9)
- **Discord** (M100): canales #anuncios #devlogs #capturas #sugerencias #bug-reportes; reglas y moderación; rol de creador.
- **Newsletter**: 1 vez al mes (devlog + fechas + sorteos); formulario en web con incentivo (wallpaper/arte exclusivo).
- **Lista de correo**: segmentada (jugadores / creadores / prensa); DOBLE OPT-IN (legal M126).
- **Campaña de wishlist**:
  - Meta: ≥ 10 000 al lanzamiento.
  - Hitos: 1 000 / 5 000 / 10 000 con recompensas de comunidad (emotes, wallpapers).
  - Palancas: devlogs, festivales, creadores, newsletter, Steam (M97) cross-promo.
  - Promociones de descuento solo dentro de las reglas de M95 (6 meses post-lanzamiento, máx 25%).

## 6. Outreach (RF10-RF12)
- **Creadores**: lista de 20+ segmentada (cosy/sim/exploración/voxel) con pitch personalizado: one-liner, diferenciales, clave de demo, fecha de lanzamiento, material de streaming. Seguimiento a los 7-14 días.
- **Prensa**: 10+ contactos (PCGamer, Eurogamer, RockPaperShotgun, Destructoid, GameStar, VidaExtra/3DJuegos, Niche Gamer, GamingBolt...) con dosier + imágenes + clave.
- **Demo** (M138): build estable con controller/ml; distribuida por festival y a demanda con claves limitadas; telemetría de conversión (M105).
- **Festivales**: candidatura a 3+ (festivales indie/cosy/editor, ejemplos: LudoNarraCon, Wholesome Direct, Steam Next Fest); ventana de demo alineada a la fecha del evento.

## 7. Plan de lanzamiento día 0 (RF13 — feed M143)
1. **T-30 días**: freeze de materiales (comunicados, assets, claves).
2. **T-14**: envío de notas de prensa y claves a creadores.
3. **T-7**: aviso final a newsletter + Discord + redes.
4. **Día 0**: publicación en Steam (M97/M96), anuncio simultáneo en todos los canales, live stream opcional, monitorización (M143).
5. **D+1 a D+7**: agradecimiento, FAQ, seguimiento de reviews (M100), informe de día 1.
- Runbook con responsables y holguras; respaldo de humano para el día 0 (M143 staff).

## 8. Qué NO se hace
- No early access (comunicación asumida de lanzamiento completo premium).
- No descuentos anticipados fuera de reglas M95.
- No spoilers del final (los 6 sellos solo se revelan en el juego).
- No publicidad paga sin datos de conversión orgánica previa.
- No promesas de fechas que no estén comprometidas en el roadmap (M136).

## 9. Lote de definiciones (Ling-3.1-Flash, Kilo Code, 2026-10-11 — encargo mimo msg 46)

### 9.1 Estrategia de marketing (RF1/RF2)

**Moodboard (ítem 1.1):** tablero público en Notion con 5 tablas: (1) paleta y color, (2) texturas del arte (M45/M46), (3) composición y luz, (4) UI de referencia, (5) tono de comunicación. Cada tabla cita los assets de M45/M46 que la inspiran. Actualización por hito (M140/M141).

**Paleta oficial (ítem 1.2):** 5 roles — Primario (océano), Secundario (arena cálida), Acento (coral), Neutro (niebla ancestral), Texto (tinta). Entrega: HEX + RGB + archivo `.ase` en `marketing/identidad/paleta.ase`. Valores muestreados del arte de M45/M46 al producir el archivo; contraste WCAG AA para texto (test de 04-Codigo §4).

**Tipografías de marca (ítem 1.3):** Display (títulos, de M88), Texto (cuerpo, de M88), Mono (datos/tablas). Fallback: system-ui/sans-serif. Uso: Display ≥ 24 px, Texto 16 px base, Mono para métricas y tablas.

**Estilo de piezas (ítem 1.4):** borde redondeado 12 px, textura papel antiguo al 8% de opacidad, sombra suave (0 4 12 px, 12% negra), grid de 12 columnas, margen de seguridad 5% del ancho.

**Guía de uso de la identidad (ítem 1.5):** mínimos — logo ≥ 24 px, espacio de seguridad = 1x la altura del logo, fondo limpio (contraste ≥ 4.5:1). Prohibiciones — no estirar, no recolorear, no rotar, no añadir efectos, no colocar sobre arte ocupado.

**Plantillas de publicación (ítem 1.6):** 3 plantillas (anuncio, devlog, hito) en Figma/Canva: fondo de identidad + logo + captura + texto ≤ 5 palabras + CTA wishlist. Exportación: 1080×1080 (Instagram), 1080×1920 (TikTok), 1200×630 (web/OG).

**Stack del sitio (ítem 3.1):** generador de sitio estático (Astro o Next.js estático), sin backend, contenido en Markdown en el repo, build estático en hosting (Netlify/Vercel/GitHub Pages).

**Estructura de páginas (ítem 3.2):** 6 páginas — Portada (hero + trailer + CTA), El juego (features + capturas), Galería (capturas 4K + gifs), Devlogs/Blog (Markdown), Prensa (press kit descargable), Legal (M126). Wireframe común: header (logo + nav + CTA wishlist), contenido, footer (legal + redes + newsletter).

**Landing (ítem 3.3):** hero superior al fold: trailer (embed), 3 capturas clave, tagline, CTA wishlist (botón primario). Debajo: features (3 columnas), último devlog, newsletter (CTA), footer.

### 9.2 Redes sociales (RF3)

**Lista de canales (ítem 5.1):** YouTube (núcleo), Discord (núcleo, M100), TikTok (extensión), Instagram (extensión), Bluesky (extensión). X/Twitter: no adoptado (API de pago; decisión documentada en ítem 10.4).

**Rol de cada canal (ítem 5.2):** núcleo = YouTube (devlogs largos), Discord (comunidad), newsletter (comunicados); extensión = TikTok/Instagram/Bluesky (amplificación de las piezas núcleo).

**Frecuencia semanal (ítem 5.3):** YouTube 1 video/mes · Discord diaria · TikTok 3/semana · Instagram 3/semana · Bluesky 2/semana · newsletter 1/mes.

**Calendario mensual (ítem 5.4):** 12 piezas programadas/mes (3 por semana), con plan B: 3-5 días hábiles de holgura por pieza; calendario en Notion/Sheets compartido.

**Horarios (ítem 5.5):** EU 18:00 CET · US 19:00 EST (audiencia EU/US); eventos Discord: sábados 17:00 CET.

**Naming unificado (ítem 5.6):** juego "Isla Ancestral" (mayúsculas iniciales, sin abreviar); estudio: nombre unificado en todos los canales (mismo handle donde esté disponible).

**Bio y enlaces (ítem 5.7):** bio ≤ 150 caracteres: qué es + diferencial + CTA wishlist; enlace único a la web (islaancestral.com) que distribuye a Steam/Discord.

**Reglas de engagement (ítem 5.8):** respuestas en ≤ 24 h (horario laboral), tono cálido y sin spoilers, escalado de reportes a moderación (M100).

**Curaduría (ítem 5.10):** nunca spoilers de los 6 sellos (solo se revelan en el juego); aprobación de capturas/clips contra la lista de spoilers antes de publicar.

### 9.3 Comunidad (RF3/RF4/RF7/RF8)

**Estructura del servidor Discord (ítem 6.1):** categorías — Anuncios (#anuncios), Desarrollo (#devlogs, #capturas), Comunidad (#sugerencias, #bug-reportes, #general), Recursos (#faq, #reglas).

**Reglas de la comunidad (ítem 6.2, M100):** 5 reglas — respeto, no spoilers, no spam, no contenido NSFW, reportar bugs en #bug-reportes. Aceptación obligatoria al entrar.

**Rol de creadores (ítem 6.3):** rol "Creador" con perks: acceso anticipado a devlogs, clave de demo prioritaria, mención en créditos (M140/M141).

**Moderación y reportes (ítem 6.4, M100):** 3 niveles — advertencia → mute temporal → ban; reportes vía #bug-reportes o DM a moderadores; log de moderación (M100).

**Integración con la web (ítem 6.5):** invite de Discord en el footer de todas las páginas + banner en la portada.

**Eventos de comunidad (ítem 6.6):** sorteos mensuales (arte/wallpapers), Q&A trimestral con el desarrollador, participación en festivales (RF12).

**Canal de FAQ fijo (ítem 6.7):** #faq fijado con 10 preguntas frecuentes (wishlist, demo, fecha, plataformas, spoilers).

**Respaldo de logs (ítem 6.8, M100):** export semanal de canales clave (anuncios, sugerencias, bug-reportes) a `logs/` del repo de marketing.

**Proveedor newsletter (ítem 11.1):** Buttondown o Mailchimp con doble opt-in (confirmación por email), GDPR-compliant (M126).

### 9.4 Análisis y métricas (RF9/RF10/RF12/RF13)

**Métricas por canal (ítem 5.9):** KPIs — impresiones, engagement (likes/comentarios/compartidos), conversión (clics → wishlist). Tabla por canal con meta mensual.

**Medición diaria de wishlist (ítem 20.4):** export diario de SteamDB (wishlist total, variación diaria); registro en la hoja de campaña.

**Dashboard semanal de campaña (ítem 20.6):** hoja de cálculo con 6 KPIs: wishlist total, Δ semanal, suscriptores newsletter, apertura/CTR, creadores contactados, festivales. Revisión semanal.

**Criterio de éxito D1 (ítem 20.7, M143):** D1 = día 1 post-lanzamiento; métricas: wishlist alcanzada vs meta (10 000), ventas D1, conversión visitas→wishlist; el dato lo consume M143 (lanzamiento) para el informe.

**Métricas de apertura y clics (ítem 19.4):** newsletter — open rate meta ≥ 40%, CTR meta ≥ 5%; medición por envío en el proveedor.

**Métrica por festival (ítem 24.5):** wishlists y conversión atribuidos al festival (clave de demo por festival); comparación entre festivales para selección futura.

**Telemetría de conversión demo → wishlist (ítem 23.5, M105):** tracking anónimo de jugadores de demo → wishlist (opt-in), tasa de conversión meta ≥ 15%.

**Informe de día 1 (ítem 25.8):** wishlist final, ventas D1, conversión, reviews iniciales (M100), top de feedback; entrega a M143.

**Plan post-lanzamiento (ítem 25.9):** retroalimentación M100/M143 — revisión semanal de reviews y feedback, backlog de comunidad, plan de contenido post-lanzamiento (parches, devlogs).

## 10. Lote de definiciones bloque 3 — contenido/SEO (Ling-3.1-Flash, Kilo Code, 2026-10-11 — encargo mimo msg 55)

> **Nota de reconciliación:** 6 ítems de este bloque ya estaban definidos en `docs/marketing/` (atria-dawn-s2, Log 1698) y se flippean con cita a esa fuente, sin reescribir: ítems 12.1-12.4 y 22.4 (el contacto de prensa dedicado se define una sola vez) → `web-especificaciones.md` §3; ítem 13.2 → `logo-especificaciones.md` §6. Las 23 definiciones nuevas siguen abajo.

### 10.1 Press kit y media kit (RF5)

**Actualización del press kit por hito (ítem 12.5, M140/M141):** revisión del press kit en cada hito de desarrollo (M140/M141): capturas nuevas, fact sheet actualizado (estado, specs), créditos nuevos (M131). Versionado: `press-kit_v<semver>.zip` con fecha en el nombre; changelog de qué cambió, en la página de prensa.

**Pack ZIP del media kit (ítem 13.1):** ZIP descargable `media-kit_v<semver>.zip` con: logo (PNG/SVG, `logo-especificaciones.md` §1/§6), paleta (`.ase`, ítem 1.2), 6 capturas (`lista-capturas.md`), 3 gifs (`guia-gifs.md`), bio del estudio. Checksum SHA-256 publicado junto al ZIP.

**Extras para streamers (ítem 13.3):** `streamer-kit` aparte: overlay de stream (transiciones, paneles de inicio/corte) y panel de donación con arte del juego. Arte: M46 (la especificación es este ítem; la producción es de M46). Entrega en ZIP con guía de uso de 1 página.

**Reglas de uso del material (ítem 13.4, M127):** permitido — streaming, videos, reseñas (con monetización), capturas en prensa; prohibido — redistribuir el ejecutable, presentar el material como oficial de otro producto, uso comercial del logo sin permiso. Atribución: "Isla Ancestral" + enlace a la web. Aprobación legal (M127) antes de publicar.

### 10.2 Clips (RF6)

**Set mínimo de clips (ítem 16.1):** 6+ clips de 15-30 s: 1 trailer corto, 2 de gameplay (exploración + mecánica voxel), 1 de ambiente, 1 de comunidad, 1 de hito (M140/M141). Formato MP4 (H.264), 1080p, 30 fps, audio estéreo.

**Clips con música y subtítulos (ítem 16.2, M41/M87):** música de las pistas del juego (M41 — hoy bloqueado por contenido de audio: 0 archivos en el repo, ver M131); subtítulos quemados (M87) en ES/EN, ≤ 40 caracteres por línea, 2 líneas máximo, con fondo semitransparente para legibilidad.

**Archivo maestro y recortes (ítem 16.3):** archivo maestro 4K (3840×2160) sin comprimir en archive; del mismo maestro, recortes verticales 1080×1920 (TikTok/Reels/Shorts) y cuadrados 1080×1080. Un solo maestro → todos los recortes (consistencia de color y audio).

**Thumbnails (ítem 16.4):** 1 thumbnail por clip, 1280×720, texto ≤ 5 palabras, logo en esquina (ítem 1.5: ≥ 24 px, espacio de seguridad), contraste AA con la paleta de marca (ítem 1.2). Plantilla unificada (ítem 1.6).

**Duración y ritmo (ítem 16.5):** cada feature grabada en 15-30 s: 3 s de gancho (la imagen más fuerte), 12-20 s de feature sin narración (o voz en off suave), 3 s de cierre con CTA de wishlist. Ritmo: corte cada 2-4 s máximo.

### 10.3 Devlogs (RF7)

**Frecuencia (ítem 17.1):** 8+ devlogs antes del lanzamiento, 1 por mes mínimo; el calendario mensual (ítem 5.4) reserva la fecha de grabación y de publicación.

**Plataforma (ítem 17.2):** YouTube (video 5-12 min, canal núcleo ítem 5.1) + entrada de blog en la web (Markdown en el repo, mismo contenido adaptado); embed del video en la entrada.

**Formato (ítem 17.3):** 5-12 min con secciones fijas — gancho (30 s), qué se hizo (2-4 min), cómo se hizo / técnica (2-4 min), qué sigue (30 s), CTA wishlist (15 s).

**Guion honesto (ítem 17.4):** incluye fallos reales y decisiones descartadas (qué se intentó y no funcionó); cero promesas de features no implementadas; aprobación contra la lista de spoilers (ítem 5.10) antes de publicar.

**CTA de wishlist (ítem 17.5):** al final de cada devlog: link directo a la página de Steam + recordatorio de 1 línea; mismo CTA en la descripción del video y en la entrada de blog cruzada (ítem 18.3).

**Tags SEO (ítem 17.6):** conjunto consistente por devlog: "Isla Ancestral", "juego indie", "voxel", "Godot 4", "desarrollo indie", "cozy game" + 2 tags específicos del tema del devlog (ver `docs/marketing/keywords-tags.md`). Mismos tags en YouTube (campo tags) y en el blog (meta keywords).

**Calendario de grabación (ítem 17.7):** grabación con 3-5 días de holgura antes de la publicación (plan B del ítem 5.4); si un devlog se retrasa, pieza de repuesto: captura + gif con texto (del ítem 1.6).

### 10.4 Blog (RF7)

**Artículos en profundidad (ítem 18.1):** 6+ artículos antes del lanzamiento, 1 cada 2-3 semanas; 800-1500 palabras; en la sección Devlogs/Blog del sitio (Markdown en el repo, ítem 3.1).

**Temas (ítem 18.2):** 4 ejes — diseño de mundo (biomas, la Isla Raíz), lore sin spoilers (mitología superficial), técnica voxel (terreno 5120×5120, impostores), economía (recursos, comercio). 1 artículo por eje mínimo, 2 extras a elección.

**Cruzamiento devlog ↔ blog ↔ newsletter (ítem 18.3):** cada devlog genera: 1 entrada de blog (contenido extendido) + 1 mención en newsletter (resumen + link). El blog embebe el video; la newsletter cita el blog.

**Categorías y autoría (ítem 18.4):** categorías fijas — Desarrollo, Diseño, Lore, Técnica; autoría: "Equipo de Isla Ancestral" (o el nombre del desarrollador si es individual); byline consistente en todos los artículos.

**SEO por artículo (ítem 18.5):** por artículo — title tag ≤ 60 caracteres con la keyword principal, meta description ≤ 155 caracteres, 1 H1, URL slug corta con keyword (`/blog/diseno-mundo-voxel`), alt text en todas las imágenes, 2-3 links internos (artículos previos). Base: `docs/marketing/keywords-tags.md`.

### 10.5 Outreach y demo (RF10/RF11)

**Pitch personalizado (ítem 21.2):** plantilla de 3 líneas — one-liner ("un juego de exploración voxel cozy en una isla ancestral"), 2 diferenciales (terreno 5120×5120 generado; animales bimodo), y el ask (clave de demo / cobertura); + 1 línea de personalización por creador (por qué le interesa según su contenido).

**Límite de contenido de la demo (ítem 23.4):** la demo incluye la Isla Raíz completa y 1 bioma adicional; excluye: los 6 sellos (spoilers del final), contenido post-game y el final. Aviso "work in progress" en el arranque (ítem 23.2) y en la página de la demo.