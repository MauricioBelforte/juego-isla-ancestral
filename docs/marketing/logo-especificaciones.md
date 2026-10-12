# Especificaciones del logo — Isla Ancestral

**Módulo:** M99 Marketing (RF1) · **Fuente de diseño:** `DOCUMENTACION/99-Marketing/plan-actual/03-Diseno.md` §1
**Paleta derivada de:** arte del juego (M45/M46) — verdes océano, arena cálida, coral, niebla ancestral
**Tipografías:** M88 (fuentes del juego)

## 1. Versiones del logo

| Versión | Uso principal | Detalle |
|---|---|---|
| **Principal (color + sombra)** | Web (portada), Steam (M97) cápsula principal, press kit | Sombra suave proyectada; fondo claro o sobre arte del juego |
| **Secundaria (contorno)** | Redes sociales, Discord, fondos con baja legibilidad del color | Solo líneas de contorno, relleno transparente |
| **Monocromo** | Uso sobre fotografía, impresión a 1 tinta, favicon escalado | Un único color de tinta (blanco sobre fotos, negro sobre papel) |

Principio: las tres versiones comparten **la misma silueta** — un visitante debe reconocer la
marca en cualquiera de ellas.

## 2. Favicon

Tamaños a exportar: **32 / 64 / 128 / 512 px** (PNG cuadrado). El origen es la versión
**monocroma** simplificada (sin sombra): a 32 px el detalle se pierde, así que el favicon
deriva de la silueta pura.

- 32 px: barra de navegación web.
- 64 px: escritorio / bookmark.
- 128 px: tile de tienda.
- 512 px: ícono de app / prensa.

## 3. Constraint de uso (espacio de seguridad)

El logo lleva un **espacio libre mínimo** a su alrededor igual a la **altura del glifo principal**
(sin contar la sombra). Dentro de ese perímetro no entra ningún texto, imagen u otro elemento.

Prohibiciones:
- No estirar ni deformar la relación de aspecto.
- No rotar (salvo uso vertical firmado en video, máximo 90°).
- No aplicar filtros de color que rompan el contraste mínimo de la paleta.
- No recortar la silueta para encajarla en un contenedor.

## 4. Logos por canal

| Canal | Versión | Notas |
|---|---|---|
| Web | Principal | Portada; secundaria en header colapsado |
| Steam (M97) | Principal | Cápsula + banner de la página de tienda |
| Discord | Secundaria o monocroma | Ícono del servidor + banner; monocroma sobre fotos de eventos |
| Redes sociales (avatar) | Monocroma sobre color de marca | Se reconoce a 48 px |
| Press kit / media kit | Principal + secundaria | Ver `docs/marketing/` |

## 5. Eslogan / tagline de apoyo

El tagline acompaña al logo **solo en la portada web y en el cierre de tráileres/devlogs**,
nunca en el avatar ni en el favicon. Debe ser corto (≤ 6 palabras), evocar el mood cozy-
exploratorio y **no prometer** mecánicas.

> **Tagline propuesto:** *Descubre la isla que te llama.*

Registro de la propuesta: este documento es la definición operativa; cualquier cambio se
versiona aquí con fecha.

## 6. Exportación

| Formato | Uso |
|---|---|
| **PNG** (24/32 bits, transparencia) | Web, redes, press kit |
| **SVG** (vectorial) | Escalados sin pérdida: favicon grande, impresión, firmas |

Regla: toda exportación raster parte del SVG para no degradar bordes. El PNG se exporta a
2x del tamaño de uso final para pantallas retina.

## 7. Revisión legal

La revisión legal de la marca (registro / conflicto con marcas existentes) depende de **M127**
y queda fuera del alcance de este documento. Acción bloqueante: **no publicar el logo en
canales de pago ni registrar dominio hasta que M127 dé luz verde a la marca.**
