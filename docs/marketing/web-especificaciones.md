# Especificaciones de la página web — Isla Ancestral

**Módulo:** M99 Marketing (RF2) · **Fuente de diseño:** `DOCUMENTACION/99-Marketing/plan-actual/03-Diseno.md` §2

## 1. Stack y hosting

- **Stack:** sitio estático (Next/Astro o generador estático equivalente) — sin servidor
  aplicativo: el contenido es marketing puro, el coste de mantenimiento es mínimo.
- **HTTPS obligatorio** (certificados automáticos via Let's Encrypt). Sin HTTPS los navegadores
  marcan el sitio como inseguro y el CTA de wishlist pierde credibilidad.
- **Analytics simple y respetuoso:** Plausible (sin cookies) como preferencia; GA4 solo si el
  editor lo exige. Lo que se mide: visitas a la portada, clics en CTA wishlist, altas de
  newsletter, descargas del press kit. Nada de tracking individual persistente.
- **SEO básico:** `<title>` y meta description por página, Open Graph + Twitter Card,
  `sitemap.xml`, `robots.txt`, URLs en minúsculas con guiones.

## 2. Estructura del sitio

| Página | Contenido | Estado de definición |
|---|---|---|
| Portada | Hero con trailer/capturas + valor del juego + CTA wishlist | Definida |
| El juego | Pillars, features, arte | Definida |
| Galería | Capturas + gifs (ver `lista-capturas.md`, `guia-gifs.md`) | Definida |
| Devlogs / Blog | Posts cruzados con YouTube y newsletter | Definida |
| **Página de prensa** | Press kit descargable (ver abajo) | Definida |
| Newsletter | Formulario de captación | Definida |
| **Página legal** | Privacidad + cookies (M126) | Definida |
| Contacto | Email de prensa / estudio | Definida |

## 3. Página de prensa (press kit)

Objetivo: que un periodista consiga **todo lo que necesita en una sola pantalla**.

Contenido obligatorio:
- **Logline** (una frase) + fact sheet (plataforma, fecha, género, precio, idiomas).
- **Bio** del estudio (3-4 líneas) y del juego (un párrafo).
- **Capturas y clips en alta resolución** (4K, sin marca de agua) descargables.
- **Créditos** completos (M131) y enlaces (Steam, redes).
- **Contacto de prensa dedicado** (email separado del soporte).

Formato: **web descargable** — la página se sirve online Y se ofrece un `.zip` con el mismo
material para uso offline en convenciones.

## 4. Página legal (privacidad / cookies)

Dependencia: **M126** (Legal). Esta página es su salida pública y debe reflejar exactamente:
- Política de privacidad del newsletter (doble opt-in, sin cesión a terceros).
- Uso de cookies: solo las técnicas + analytics anónima (banner de consentimiento minimalista).
- Enlaces a los términos de uso del juego y la política de reembolso de la tienda.

## 5. Accesibilidad web básica

El público cozy valora el detalle; la accesibilidad es parte de la marca:

- **Contraste mínimo AA** (4.5:1 texto normal, 3:1 texto grande) en todos los pares de color
  de la paleta de marca.
- **Texto alternativo descriptivo** en todas las capturas y gifs (no `image.png`).
- **Navegación completa por teclado**: focus visible, orden lógico, sin trampas de tabulador.
- **No depender solo del color** para transmitir estado (ej. el CTA de wishlist lleva ícono
  + texto, no solo color).
- Etiquetas de formulario asociadas a sus inputs; mensajes de error anunciados.

## 6. CTA de newsletter

- **Ubicación:** portada (debajo del hero) + pie de todas las páginas.
- **Texto:** orientado al beneficio ("Únete y recibe el devlog mensual + arte exclusivo"),
  no a la transacción.
- **Incentivo:** wallpaper/arte exclusivo (entrega automática tras confirmación).
- **Doble opt-in obligatorio** (M126): el alta no se completa hasta confirmar por email.
- Tras el alta: redirección a la página de Steam (wishlist) como segundo paso opcional.
