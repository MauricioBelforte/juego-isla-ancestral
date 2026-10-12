# Lista de Capturas — Isla Ancestral (12 shots)

**Módulo:** M97 Steam Store (original, 8 shots) · **M99 Marketing** (ampliación a 12+ con
metadatos por área). Fuente: `DOCUMENTACION/99-Marketing/plan-actual/03-Diseno.md` §4.

## Set mínimo: 12 capturas (una por área clave)

| # | Toma | Área clave | Módulo ref. | Spoiler? | HUD |
|---|------|-----------|-------------|----------|-----|
| 1 | Playa Aurora al amanecer | Mundo / bioma playa | M09 | No | Limpio |
| 2 | Campos de cultivo + riego | Agricultura | M33 | No | Limpio |
| 3 | Río pescando | Pesca | M34 | No | Limpio |
| 4 | Mina con picos | Minería | M35 | No | Limpio |
| 5 | Taller + casa al atardecer | Crafting / construcción | M16/M17 | No | Limpio |
| 6 | Plaza del pueblo con vecinos | Amistad / diálogos | M19-M21 | No | Limpio |
| 7 | Templo en ruinas con antorchas | Misterio / ritual | M24 | Parcial: antorchas, sin sello resuelto | Limpio |
| 8 | Vista aérea en golden hour | Mundo voxel | M09 | No | Limpio |
| 9 | Interior de la casa decorada | Casas / decoración | M18 | No | Limpio |
| 10 | Receta crafteo abierta | Crafteo | M16 | No | Con UI (mostrar panel) |
| 11 | Inventario + objetos raros | Inventario / loot | M14 | No | Con UI (mostrar grid) |
| 12 | Festival / evento del pueblo | Eventos | M74 | No | Limpio |

## Reglas técnicas

- **Resolución 4K (3840x2160)** para Steam (M97); exportación derivada a 1920x1080 para web/redes.
- **UI limpia y HUD opcional:** 10 de 12 tomas sin HUD; las tomas 10-11 muestran a propósito
  los paneles de crafteo/inventario (venden profundidad de sistema).
- **Sin debug:** sin overlays de debug, sin consola, sin watermark del editor.
- **Personaje visible** en todas las tomas de mundo (vende escala e identidad).
- **Sin spoilers de los sellos:** el templo se muestra iluminado pero **nunca con el acertijo
  resuelto ni la cámara del sello (M24)**. La regla se aplica tomando por toma antes de publicar.

## Metadatos por captura (carpeta por área)

Cada PNG lleva un archivo `.txt` adyacente con:

```
titulo:     <nombre de la toma>
area:       <área clave de la tabla>
modulo:     <Mxx referenciado>
resolucion: 3840x2160
hud:        limpio | con-ui
spoiler:    no | parcial-<detalle>
licencia:   Uso promocional del juego; sin derechos de reventa (M127)
```

**Estructura de carpetas** (`capturas-marketing/`): un subdirectorio por área
(`01-mundo/`, `02-agricultura/`, ..., `12-eventos/`) — coincide con la numeración de la tabla,
de modo que encontrar la captura de un área es buscar su número.

## Dependencias

- **M45/M47**: áreas del mundo de las que se toman las capturas.
- **M97**: página de Steam que las consume (junto a `guia-gifs.md` y `descripcion-store.md`).
- **M127**: licencia de uso del material promocional.
