**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 97: Steam / Store Page

## 1. Análisis del dominio

### 1.1 Qué necesita una store page de Steam para un indie cozy

La store page de Steam es el embudo de conversión principal del nicho indie cozy. El viaje del comprador típico es:

1. **Descubrimiento** (10 s): llega por tags, categoría, "cozy games" en Discovery Queue, o por enlace externo (Twitter, Discord, YouTube, newsletter).
2. **Escaneo visual** (15–30 s): mira capsule art, primeras 2 capturas, trailer en autoplay (si el mouse pasa por el vídeo).
3. **Lectura rápida** (60–90 s): short description + primer pantallazo del About + requisitos + precio.
4. **Decisión**: wishlist (no compra inmediata en coming soon) o cierre.

Los juegos cozy convierten mejor cuando la página comunica **fantasía y calma** antes que sistemas: "vuelve a casa, cultiva, haz amigos" funciona mejor que "3 sistemas de crafting interconectados". El jugador cozy suele ser sensible al estrés visual y a la promesa de ritmo propio.

### 1.2 SEO de Steam (descubrimiento interno)

- Los **tags** (máx. 20) alimentan las páginas de etiqueta (ej. `/genre/Cozy` o `/tag/Farming%20Sim`), las recomendaciones por similitud y los filtros combinados ("Cozy + Farming"). Un juego con tags correctos aparece en categorías con cientos de miles de jugadores aunque sea desconocido.
- Las **keywords** alimentan SOLO la búsqueda texto interna de Steam (no el SEO de Google). No deben duplicar términos ya cubiertos por tags para no desperdiciar campos.
- La **short description** se muestra en listas y en el widget de embebido; debe ser un gancho, no un resumen técnico.
- Las **categorías** (Singleplayer, Controller, perfil de edad) y los **idiomas soportados** afectan filtros y la insignia de idioma en la página.
- La **fecha de lanzamiento "Coming Soon"** activa el botón de wishlist: todos los esfuerzos de marketing (M136) apuntan a generar wishlists antes del día 1, porque Steam prioriza la relación wishlist → ventas en las primeras 24–72 h.

### 1.3 Tipos de capturas y buenas prácticas

- Steam permite hasta **10 capturas**; la primera es la miniatura principal en todas las listas y búsquedas.
- Las mejores capturas de un cozy voxel: **luz cálida** (amanecer/atardecer), composición con el personaje visible, UI mínima, un sistema reconocible (cultivo, pesca) y un NPC.
- Prohibido en la práctica de Steam para evitar rechazo/baja conversión: HUD de debug, consolas abiertas, texto de desarrollo, capturas de menús flotando, GIFs estáticos mal recortados, textos en otro idioma sin subtítulos.
- Steam comprime y re-encuadra: las capturas se suben a 1280x720 o superiores (ideal nativa del render) en 16:9.

### 1.4 Trailer

- Los trailer de Steam van de **15 s a 2 min** por tramo; el rango efectivo de un indie cozy en el primer trailer es **60–90 s**.
- Formato H.264 MP4, 1920x1080 preferido; el peso máximo por archivo es alto (2 GB) pero el rendimiento de reproducción favorece archivos livianos.
- El autoplay con sonido silenciado es frecuente: la primera parte del trailer debe comunicar visualmente sin depender del audio.
- Un trailer de gameplay real (con UI del juego) pesa más en la decisión que un cinemático "vertical slice" para este género: el jugador cozy quiere ver el ritmo real del juego.

### 1.5 Wishlists

- El objetivo antes del lanzamiento es acumular la mayor cantidad de wishlists posible: es la métrica que el algoritmo de Steam usa para posicionar el juego en "New & Trending" y páginas de género.
- Cada wishlist tiene un valor estimado de 0.5 a 3 USD de impacto en ventas del día 1 (rango común reportado en GDC/Steamworks para indies).
- Todo pase de contenido (capturas nuevas, trailer, changelog) debe terminar en un CTA de wishlist: la página es la landing de todas las campañas.

### 1.6 Price tier del género cozy

Rango observado del mercado cozy indie (2024–2026):

| Tier | Precio | Ejemplos de referencia | Qué espera el jugador |
|------|--------|------------------------|------------------------|
| Bajo | $9.99 | prototipos, juegos cortos | 5–10 h, un sistema central |
| Medio | $14.99 | Stardew Valley (referencia histórica) | experiencia completa, replay |
| Medio-alto | $19.99–$24.99 | cozy modernos con alcance amplio | 20–40 h, mundo rico, pulido |
| Alto | $29.99+ | Calico premium, multi-year devs | casi AAA cozy |

"Isla Ancestral" (mundo voxel, 5+ sistemas, NPCs, templos, historia) pertenece al tier **medio-alto: $19.99 USD sugerido** con descuento de lanzamiento del 10–15%. La decisión final es del fundador (ver 01-Requerimientos, RF6).

### 1.7 Coming Soon vs Early Access vs Full Release

- **Coming Soon**: página con wishlist, sin fecha o con fecha. Es el estado esperado para marketing pre-lanzamiento (M136).
- **Early Access**: NO recomendado para este juego: el género cozy castiga el early access con reviews negativas por contenido incompleto y estrategia de "comprar el potencial".
- **Full Release**: objetivo de M143. La página pasa de Coming Soon a lanzamiento con trailer final + capturas del build gold.

## 2. Alternativas consideradas

1. **Página pública inmediata (sin contenido pulido)**: velocidad alta, pero destruye la primera impresión; las primeras visitas (prensa, early adopters) juzgan la página como producto final. → Descartada.
2. **Desarrollo completo del contenido primero, publicar después**: riesgo de no tener landing para campañas de anuncios y festivales cuando más se necesita. → Descartada; se usa el enfoque por fases (ver 03-Diseno).
3. **Página oculta (solo con enlace directo) mientras se pule**: permite iterar tranquilo y dar el enlace a prensa/whitelists sin exponer fallos. → Adoptada como fase 1.
4. **Contenido asistido por IA sin revisión (M86)**: velocidad alta pero riesgo de textos genéricos que el jugador cozy detecta; descartado como texto final, adoptado solo como borrador inicial.
5. **Tercerizar toda la producción (trailer, capsules)**: calidad profesional pero costo alto; se prioriza assets internos (capturas, trailer de gameplay) y solo se contrata si el fundador lo decide.
6. **Store page en otros escaparates además de Steam (Itch.io, Epic, GOG)**: fuera de alcance del módulo; queda como nota para M96 (plataformas).
7. **Precio sin tier definido (decisión tardía)**: impide planificar descuentos y campañas; se fija una recomendación temprana con autoridad del fundador (RF6).

## 3. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| D1 | Página **oculta** primero, luego Coming Soon | Iterar contenido sin presión externa; prensa con enlace directo |
| D2 | Textos en **español + inglés** como mínimo | Mercado + idioma del desarrollador; otros idiomas tras localización (M96) |
| D3 | **20 tags** del catálogo real, priorizando Cozy/Farming/Life Sim | Máxima exposición en páginas de etiqueta del nicho |
| D4 | **6–8 capturas** de gameplay real a 1920x1080 | Suficientes para el escaneo visual sin diluirse |
| D5 | **1 trailer principal** de 60–90 s (gameplay real con música) | Es el estándar de conversión para cozy; trailer 2 solo si sobra presupuesto |
| D6 | **$19.99 USD sugerido** (tier medio-alto cozy) | Coherente con alcance y duración; decisión final del fundador |
| D7 | Requisitos **honestos y verificados** contra el build | Evita reviews negativas por rendimiento falso anunciado |
| D8 | Contenido IA (M86) solo como **borrador**, nunca final | Coherente con política del proyecto; todo texto lo aprueba el fundador |
| D9 | La página se mantiene como **plantillas Markdown versionadas** | Permite regenerar y comparar cambios por commit |
| D10 | **Verificación contra la documentación vigente de Steamworks** antes de cada subida | Steam puede cambiar dimensiones, límites y reglas; no confiar en memorias |

## 4. Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Steam cambia requisitos de contenido (dimensiones, formatos, tags) | Media | Medio | Verificar contra docs vigentes al publicar (RN6) |
| Capturas desactualizadas tras cambios de juego | Alta | Medio | Regraba de capturas en cada milestone de M136 |
| Precio final distinto al comunicado en campañas | Baja | Alto | Fijar precio antes de las primeras campañas públicas |
| Trailer sin presupuesto | Media | Medio | Trailer de gameplay interno; contrato de música licenciada |
| Reviews negativas por requisitos engañosos | Baja | Alto | Pruebas de rendimiento en máquina mínima antes de publicar requisitos |
| Cuenta de Steamworks rechazada/retrasada | Baja | Alto | Crear la cuenta del publisher con antelación (M143) |

## 5. Conclusión

La store page de "Isla Ancestral" se construye por fases (oculta → coming soon → launch), con contenido 100 % verificado contra el build real, textos en español e inglés, 20 tags del catálogo, 6–8 capturas, 1 trailer de 60–90 s, requisitos honestos y un price point sugerido de $19.99 USD sujeto a decisión del fundador. Todos los requisitos de Steam se revalidan contra la documentación vigente de Steamworks al momento de publicar, ya que la plataforma puede modificar sus políticas en cualquier momento.