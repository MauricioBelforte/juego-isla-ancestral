**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 97: Steam / Store Page

## 1. Problema

"Isla Ancestral" es un juego cozy de mundo voxel (estilo Stardew Valley) ambientado en la isla Aurora, desarrollado en Godot 4.x + Voxel Tools con GDScript. Un juego indie de este género no existe para sus futuros jugadores hasta que tiene una página visible en Steam: la store page es el escaparate principal donde un comprador decide en segundos si desea añadir el juego a su lista de deseos o comprarlo.

Sin una store page profesional y completa, el juego:

1. No genera wishlists durante la fase de marketing previa al lanzamiento (M143).
2. Pierde tráfico de descubrimiento de Steam (tags, keywords, categorías, filtros de deseos).
3. Transmite desconfianza: capturas pobres, descripción confusa o falta de trailer reducen la conversión de visita → wishlist → compra.
4. No tiene un lugar central donde apoyar campañas (capsule art, anuncios, festivales, reseñas de prensa).
5. Queda desalineado con la hoja de ruta (M136) y con el plan de lanzamiento (M143), que dependen de tener la página lista en fechas concretas.

La store page debe existir antes de la campaña de marketing, con contenido que refleje el estado real del juego (pantallas del gameplay real, requisitos honestos, precio coherente con el género).

## 2. Objetivo

Crear y mantener la página de Steam de "Isla Ancestral" con el contenido completo que exige Steamworks:

- Descripción corta y larga persuasiva, en español e inglés (y otros idiomas si aplica).
- 20 tags correctamente elegidos según el género cozy voxel.
- 5–10 capturas de pantalla del gameplay real (sin vertical slices mentirosos).
- Trailer principal (60–90 segundos) y trailer secundario opcional.
- Requisitos mínimos y recomendados honestos y verificados contra el build real.
- Price point definido y coherente con el tier del género cozy ($14.99–$24.99).
- Assets oficiales de Steam (capsule, header, library hero, logo) con las dimensiones vigentes.
- Keywords y metadatos optimizados para el descubrimiento en Steam.
- Integración con la hoja de ruta (M136) y el lanzamiento (M143): fechas de "Coming Soon", festivales y ventana de lanzamiento.

## 3. Alcance

**Incluye:**

- Todos los textos de la página (short description, about, secciones, FAQ si aplica).
- Selección y redacción de tags, categorías y género en Storefront.
- Lista maestra de capturas a generar y su preparación (denoising, encuadre, representatividad).
- Plan del trailer (guion, tomas, música, duración) delegado a producción de medios.
- Tabla de requisitos mínimos/recomendados.
- Decisión y registro del price point con licencia de autoridad del fundador.
- Lista de assets gráficos (capsule, header, library, logo, fondo de página) con dimensiones.
- Keyword list y metadatos SEO.
- Roadmap de la página (hidden → coming soon → launch) alineado a M136/M143.
- Checklist de verificación previa a publicación en Steamworks.

**Fuera de alcance:**

- La integración técnica con la API de Steamworks en el juego (módulo de plataformas, M96).
- Publicar el juego ni gestionar el proceso de review de Steam (M143).
- Localización completa del juego (M96/otros): la store page sí puede traducirse de forma independiente.
- Comprar o producir el trailer final: el módulo planifica y especifica, la producción es de otro agente/disciplina (media).
- Marketing posts, comunidades y Discord (otros módulos/compañeros).
- Decisiones de negocio (precio final, nombre comercial, fecha de lanzamiento): se documentan, pero la decisión es del fundador.

**Dependencias:**

- M96 (Plataformas, ⬜ sin documentar): puede estar sin documentar; este módulo referencia sus entregables sin bloquearse.
- M86 (IA Generativa): textos preliminares asistidos, NO para contenido final sin revisión humana.
- M136 (Hoja de Ruta): fechas de hitos que condicionan la visibilidad de la página.
- M143 (Lanzamiento): plan de lanzamiento que define la ventana y el uso de "Coming Soon".

## 4. Restricciones

1. Motor Godot 4.x + Voxel Tools, lenguaje GDScript (no Unity, no C#): los entregables de este módulo son contenido y especificaciones, no código de gameplay.
2. Todo el contenido debe reflejar el estado REAL del juego: prohibido mostrar capturas/trailers de contenido que no exista en el build (fake footage).
3. No se autoriza contenido generado por IA sin revisión humana; el fundador aprueba todo texto final (M86 aplica).
4. Costo: priorizar assets generables con el propio juego (capturas, video de gameplay) sobre ilustraciones contratadas, salvo decisión del fundador.
5. Los requisitos del contenido de Steam (dimensiones, límites de tags, formatos de video) pueden cambiar: deben verificarse contra la documentación vigente de Steamworks al momento de publicar.
6. El precio final es decisión exclusiva del fundador; este módulo propone un tier de referencia.
7. Idioma: store page al menos en español e inglés (mercado principal). Otros idiomas según presupuesto de localización (M96).

## 5. Requerimientos Funcionales

### RF1: Descripción de la página

- RF1.1: Short description de máximo 300 caracteres, enganche emocional cozy (fantasía: isla, calma, comunidad).
- RF1.2: Descripción larga (About) con estructura: gancho, qué es el juego, sistemas principales (M33 agricultura, M34 pesca, M35 minería, M16 crafting, M17 construcción, M19 NPCs/amistad, M24 templos), por qué es cozy, cierre con llamada a la acción (wishlist).
- RF1.3: Máximo 1–2 párrafos por sección; bullets con iconos si Steam los soporta (se verifica al publicar).
- RF1.4: Español e inglés de calidad editorial (sin IA cruda, revisión humana).

### RF2: Tags y categorías

- RF2.1: Usar los 20 tags permitidos, elegidos entre los disponibles del Storefront (el género e idioma determinan el set).
- RF2.2: Tags troncales del género: Cozy, Farming Sim, Life Sim, Building, Crafting, Voxel, Sandbox, Exploration, Relaxing, Atmospheric, Open World, Singleplayer, Indie, Resource Management, Pixel Graphics (o 3D art alternativo), Mining, Fishing, Mystery, Story Rich, Puzzle.
- RF2.3: Asignar como categoría principal "Singleplayer" y "Controller" si aplica (M57).
- RF2.4: No inventar tags: usar solo los del catálogo oficial de Steam.
- RF2.5: Los tags mal clasificados se corrigen en el primer pase de la página pública (máx. 5 cambios por semana en la herramienta de etiquetas para no penalizar el descubrimiento).

### RF3: Capturas de pantalla

- RF3.1: Mínimo 5, máximo 10 capturas soportadas por Steam.
- RF3.2: Resolución mínima 1280x720 (ideal 1920x1080), ratio 16:9.
- RF3.3: Mostrar gameplay real de distintas zonas y momentos: amanecer en la playa, huerto, pesca, minería, pueblo, templo/puzzle nocturno.
- RF3.4: La primera captura es la más importante (thumbnail en listas): escena icónica de la isla Aurora.
- RF3.5: Prohibidas: UI rota, tutorial en pantalla, texto en español sin subtítulos, logotipos de herramientas de desarrollo.

### RF4: Trailer y vídeo

- RF4.1: Trailer principal de 60–90 segundos (límite Steam: 15 s – 2 min por tramo).
- RF4.2: Formato H.264, MP4, 1920x1080, hasta 2 GB por archivo.
- RF4.3: Guion en 3 actos: hook (5–10 s), sistemas (40–60 s), cierre con logo y llamada a wishlist.
- RF4.4: Trailer secundario opcional (gameplay sin música o features deep-dive) si presupuesto de medios lo permite.
- RF4.5: La música del trailer se licencia correctamente (M41/M44 aplican).

### RF5: Requisitos de sistema

- RF5.1: Requisitos mínimos y recomendados honestos, verificados contra el build real (fps objetivo 30+ en mínimos, 60 en recomendados).
- RF5.2: Mínimo: SO Windows 10 64-bit, i5/ryzen 5 generación media, 8 GB RAM, GPU integrada o dedicada básica (se valida con M90 configuración gráfica).
- RF5.3: Recomendado: Windows 11 64-bit, i5/Ryzen 5 reciente, 16 GB RAM, GPU dedicada de gama media.
- RF5.4: El juego es 64-bit; documentar Linux/macOS según decisión de M96 (plataformas) — se omiten si no son objetivo.
- RF5.5: Espacio en disco estimado 4–8 GB según tamaño real de assets voxel (se ajusta en build final).

### RF6: Precio y price point

- RF6.1: Registrar el price point propuesto: $19.99 USD (tier medio del género cozy) con % opcional de descuento de lanzamiento (-10%/-15%) propuesto.
- RF6.2: El precio es decisión del fundador; el módulo entrega tabla comparativa de referencia del género.
- RF6.3: Precios regionales automáticos de Steam (no fijar manuales salvo desplazamiento de género).
- RF6.4: Coherente con M38 (economía del juego): no prometer contenido que el precio no sustente.

### RF7: Keywords y metadatos

- RF7.1: Keyword list de Steamworks completa (describe el juego para la búsqueda interna de Steam).
- RF7.2: Keywords principales: cozy, farming, island, voxel, relax, adventure, fishing, mining, build, friends (sin repetir los 20 tags: Steam desaconseja duplicar).
- RF7.3: Sin marcas de terceros ni palabras engañosas (prohibido "Stardew-like gratis").

### RF8: Assets gráficos de la tienda

- RF8.1: Header capsule (460x215) con logo y arte cozy.
- RF8.2: Small capsule (231x87), Large capsule y Main capsule (616x353).
- RF8.3: Library capsula horizontal (616x353) y vertical (600x900).
- RF8.4: Library hero (3840x1240, zona segura 1430x1240) y logo en formato grande (570x110 aprox.).
- RF8.5: Página de fondo (header de la página del juego, 1438x810 aprox.) — dimensiones a confirmar en Steamworks.
- RF8.6: Todos los assets en .png/.jpg con los límites de tamaño de Steam; verificar dimensiones vigentes al publicar (Steam puede actualizarlas).

### RF9: Página principal y categorías de Storefront

- RF9.1: Género principal: Sandbox / Simulation; secundario: Adventure.
- RF9.2: Bandera "coming soon" y fecha objetivo según M136/M143 (puede ser "a la venta"/TBA hasta definir).
- RF9.3: Configurar "Controller support" (M57), idiomas soportados y accesibilidad (M58) en la pestaña Store Page.
- RF9.4: Modo cooperativo: NO (el juego es singleplayer por diseño; no prometer multijugador).

### RF10: Integración con M136 y M143

- RF10.1: La página pasa a "Coming Soon" en el hito de marketing definido por M136 (no antes de tener trailer).
- RF10.2: Checklist de lanzamiento de M143 incluye: página pública 3–6 meses antes, revisión de capturas 1 mes antes, actualización de requisitos en build final.
- RF10.3: Activación de la página "oculta" para prensa/Discord antes del coming soon público.

## 6. Requerimientos No Funcionales (RN)

- RN1: Rendimiento de producción: el pase de contenido completo (textos + assets + capturas) debe estar listo en 2–4 semanas de trabajo delegado, no crítico en tiempo de frame (no es runtime).
- RN2: SEO/descubrimiento: título visible, short description y tags coherentes entre sí; keywords no duplican tags; sin relleno.
- RN3: Honestidad: todo material audiovisual corresponde a builds reales; si un sistema cambia, se regraba la captura (nunca retocar UI).
- RN4: Internacionalización: español e inglés nativos de calidad; traducciones adicionales solo con revisión humana.
- RN5: Mantenibilidad: los textos viven en plantillas versionadas (Markdown) dentro de la carpeta del módulo para poder regenerar la página al cambiar el juego.
- RN6: Verificación contra Steamworks: dimensiones, límites de caracteres, formatos de video y reglas de tags se validan contra la documentación vigente de Steam al publicar (Steam puede cambiar estos requisitos).
- RN7: Accesibilidad (M58): subtítulos en el trailer, texto de alto contraste, sin flash parpadeante en capturas/trailer.
- RN8: Seguridad legal (M78): sin assets propietarios, música licenciada, nombres registrados verificados; price point sin promesas de contenido posterior obligatorio.