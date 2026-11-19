**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14 04:05

# 13 - Interiores habitables: como modelar un cuarto que se pueda recorrer

> Creado 2026-11-19 por ERNIE-5.5-Flash-Preview (Kilo Code) mientras modelaba los 5 interiores
> del Crucero (M169). Receta probada, con los errores que ya me costaron una vuelta.

## 1. Principio

Un interior habitable es **una caja con aberturas reales**, no un decorado. Si el jugador
va a caminar adentro, la pieza tiene que estar **cerrada arriba, abierta donde corresponde,
y con el suelo al nivel del spawn**.

## 2. Medidas de partida (proporciones humanas)

| Elemento | Medida | Nota |
|---|---|---|
| Altura libre del piso | **2,40 m** (camarote) / **2,80-3,00 m** (salones) | si es menor, se siente aplastado |
| Ancho de pasillo | **1,60-2,20 m** | menos de 1,20 m no pasan dos personas |
| Puerta interior | **0,80 × 2,00 m** | |
| Puerta doble (suite) | **1,00 × 2,05 m** | |
| Ventana / ojo de buey | 0,55 m (redondo) · 0,90-1,40 m (rectangular) | |
| Baranda | 1,05 m de alto | |
| Escalera | 30-35\u00b0, 0,28 m de huella, 0,18 m de contrahuella | rampa de colisi\u00f3n aparte |

## 3. Receta de modelado

1. **Caja base**: piso + techo + 4 paredes como mesh separados (para poder rediseñar uno sin tocar los otros).
2. **Aberturas por extracción (E-107)**: para ventanas y puertas, **bisecar la pared** en las dos
   alturas, quedarse con las caras del hueco y desplazarlas por la normal. **Nunca** una caja pegada.
4. **Mobiliario por bboxes verificados**: cada mueble con su medida real; verificar que la suma
   de huellas + circulación quepa en el cuarto.
6. **Spawn**: un `Marker3D` a 0,05 m del suelo, dentro del cuarto, mirando al centro.
6. **Puerta**: `Area3D` con `CollisionShape3D`, no una pared con textura de puerta.

## 4. Errores que ya pagué (no repetir)

| # | Error | Costo |
|---|---|---|
| 1 | Camas y muebles **a ojo**, sin medir | quedaron superpuestos y a medio enterrar |
| 2 | Piso de madera **colgando** dentro del volumen de abajo | se veía madera como techo |
| 3 | Camarote con el **techo a 2,05 m** | ahogado; el usuario pidió "poder mirar para arriba" |
| 4 | Puertas como **paneles pegados** a la pared | el usuario no podía entrar |
| 5 | `.tscn` con **aritmética** (`11.0/2 - 3`) | parse error, escena inservible |
| 6 | Camarote "genérico" sin测量 | proporciones falsas |

## 5. Presupuesto por tipo de interior (medido en M169)

| Interior | Superficie | V\u00e9rtices | Densidad |
|---|---:|---:|---:|
| Camarote tipo | 11 m\u00b2 | 204 | 18 v/m\u00b2 |
| Comedor (44 \u00d7 10 m) | 440 m\u00b2 | 984 | 2,2 v/m\u00b2 |
| Casino (22 \u00d7 9 m) | 198 m\u00b2 | 1.034 | 5,2 v/m\u00b2 |
| Puente (9 \u00d7 4,3 m) | 39 m\u00b2 | 456 | 11,7 v/m\u00b2 |
| Bodega (60 \u00d7 11 m) | 660 m\u00b2 | 448 | 0,7 v/m\u00b2 |

**Regla:** un cuarto amueblado \u2248 **15-20 v/m\u00b2**; un salón con muchas mesas \u2248 **3-5 v/m\u00b2** (porque los muebles se instancian, no se copian).

## 6. Verificaci\u00f3n obligatoria

- `z_min` de **cada** pieza contra el suelo del cuarto (nada flotando ni enterrado)
- Distancia de cada mueble a la pared (si es 0 \u2192 incrustado; si es >5 cm \u2192 flotando)
- AABB del cuarto: todo dentro, con 5 cm de holgura
- Altura libre: techo − piso ≥ 2,40 m
- **No** se puede validar "si se ve bien" sin visión: eso lo firma un modelo con imágenes

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code — 2026-11-14 04:05