**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 09: Terreno y Geografía

## 1. Catálogo de formaciones (recetas)

### Montañas
- 2-3 cadenas por isla; crestas con clavo de ruido; cumbres > +120 con nieve estacional (M29).
- Material: piedra + capa de césped/grava según altura.
- Regla: ninguna montaña bloquea el acceso al faro/puerto (flujo de jueg). 

### Valles, playas y acantilados
- **Valle:** depresión ≥ 40 m de ancho; cauce de río; ideal Granja.
- **Playa:** banda 5-10 bloques, inclinación 2-3%, arena clara; la arena se entremezcla con agua (profundidad 1).
- **Acantilado:** pared de piedra 15-40 m; borde superior con arbustos; acceso por camino tallado o puente (M40).

### Ríos, lagos y cascadas
- **Río:** spline con ancho 2-4 bloques; profundidad 1-2; bordes de barro.
- **Lago:** depresión con agua nivel; borde de barro + juncos (humedal).
- **Cascada:** regla de flujo: solo donde río corta acantilado ≥ 8 m; animación de agua por partículas (M51).

### Cuevas, túneles y cañones
- **Cueva:** generación por ruido 3D en piedra; entradas a nivel de río/acantilado; interior con cristales (M10 minería).
- **Túnel:** conecta dos zonas de la isla bajo la montaña; ancho 3; luz interior (glifos).
- **Cañón/GRAN GRIETA:** grieta de 10-30 m de ancho, profundidad hasta -40; paredes de piedra; puente roto (desbloqueo con infraestructura); acceso al Templo de la Brisa.

## 2. Catálogo de biomas (con alturas e insumos)

| Bioma | Altura | Material base | Decoración | Islas |
|---|---|---|---|---|
| Costa | 0-15 | arena, agua | conchas, palos | todas |
| Pradera | 5-25 | césped | flores, setos | Aurora, Verde |
| Bosque | 10-60 | césped/piedra | árboles densos M50 | Aurora, Verde |
| Humedal | 0-8 | barro, agua | juncos, nenúfares | Aurora |
| Valle | 5-20 | césped | flores, setos | Aurora |
| Montaña | 60-120 | piedra | grava, musgo | Aurora, Nieve |
| Cumbre | 120+ | piedra/nieve | hielo, viento | Aurora, Nieve |
| Desierto | 0-20 | arena | cactus decorativos | Viaje |
| Nevado | 0-40 | nieve/hielo | pinos | Nieve |
| Volcánico pacífico | 0-80 | basalto | vapor, termales | Cenizas (roadmap) |
| Tropical | 0-25 | arena clara | palmas, flores | Coral, Verde sur |
| Ruinas | variable | piedra estructurada | glifos, columnas | Aurora (cerca templos) |
| Resonancia | variable | cristal + piedra | cristales brillantes | Especial |

## 3. Reglas de transición de biomas

1. Mezcla por 2 ejes: **altura** (temperatura) y **humedad** (ruido) — fronteras diagonales, nunca líneas rectas.
2. Ancho de transición: 8-16 bloques con interpolación de material (tierra→césped→grava).
3. Al borde del agua: regla de marea (humedad alta) → playas/humedales.
4. Regla de legibilidad: ningún bioma de menos de 20×20 m (excepto islotes especiales).
5. Los biomas especiales (ruinas/resonancia) se colocan por marcador narrativo (no por ruido) — M10.

## 4. Erosión visual y elementos naturales

- **Erosión:** bloque auxiliar de suavizado (medio bloque/rampa de grava) en pendientes ≥ 45°; evita escalones crudos.
- **Elementos:** rocas sueltas (1-3 bloques), raíces expuestas, musgo según humedad, conchas en playa. Colocación procedural con decorativos NO sólidos (M50) en cantidad limitada por chunk (perf).

## 5. Puntos de interés (Aurora)

| POI | Ubicación | Rol en el juego |
|---|---|---|
| Faro apagado | Sur-Este | Prólogo (M22) — se enciende como hito |
| Puerto/Muelle | Sur | Gran Vapor, pesca, amor temporal |
| Plaza del pueblo | Centro-valle | Vida comunitaria, eventos (M74) |
| Granja | Valle | Bucle diario (M33) |
| Gran Grieta | Centro-Norte | Camino al Templo de la Brisa (M26) |
| Mirador Norte | Cumbre | Panorámica, logros, cita narrativa |
| Puente del puerto | Oeste | Infraestructura de Finneas (M40) |

## 6. Puntos panorámicos y legibilidad

- Regla de silueta: cresta mínima por encima de la línea de horizonte en 2 bloques.
- Miradores señalizados con marcadores (banderas/glifos) — descubrimiento (M71/M74).
- El render lejano usa LOD Transvoxel + color por bioma (distancia) para leer el paisaje.

## 7. Restricciones anti-softlock (M66)

- Todo POI narrativo tiene ≥ 2 rutas accesibles (subir/margen/puente alternativo).
- La grieta se abre con progresión, pero la isla nunca queda dividida sin alternativa.
- Ninguna formación se genera sobre el puerto/granja/sitios de base.