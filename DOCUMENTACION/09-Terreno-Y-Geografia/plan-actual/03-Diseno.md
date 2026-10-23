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

## Presupuestos numericos (Reflection-Beam-1.0, 2026-10-23)

| # | Presupuesto | Valor | Formula/Justificacion |
|---|-------------|-------|----------------------|
| 16 | Presupuesto de poligonos por chunk + total | 50k-100k por chunk, 500k-1M por escena | Coherente con Godot 4.x y presupuesto <0.5 ms/frame de M70. |
| 17 | Ratios de reduccion de LODs por nivel | LOD0 100%, LOD1 50%, LOD2 25%, LOD3 12.5% | Reduccion progresiva (factor 0.5 por nivel). |
| 18 | Pesos de texturas del terreno (MB por material) | 2-4 MB por material, 8-12 materiales por bioma | Total 16-48 MB por bioma. Coherente con presupuesto de VRAM. |
| 19 | Posicion de spawn del jugador | SPAWN_JUGADOR = Vector3(3860, 0, 3860) — a ~1838u del CENTRO (2560, 2560), en la orilla (RADIO_ISLA 1800) | Coherente con biomas (costa 0-15, spawn en costa). PUNTO UNICO DE VERDAD: autoload scripts/world/mundo_raiz.gd (AGENTS.md §26). CORREGIDO 2026-10-23: la version anterior "(0, get_height(0,0)+1, 0)" apuntaba a la esquina (0,0) del mundo 5120² (oceano), no al centro — obsoleta desde el rework "Isla 10x" (commit c107419). |
| 20 | Tiempos de creacion/regeneracion del terreno | Creacion 2-5s, regeneracion 1-3s | Presupuesto de carga de escena: <10s total. |

## Presupuestos numericos II - detalle minucioso (2da capa)

Definidos por Beam-1.0 via Audit-CRON E x8 (auto-auditoria de la 1ra capa) y escalado al fundador. Formula y unidades con dependencias cruzadas (M93 80/dia, M58 0.5ms, M144 <48h SLA).
- **Presupuesto de poligonos por bioma** [x] - tabla por bioma con rangos PCS y con formula de noise que divide como tu M129 (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)
- **Presupuesto de LOD levels por distancia** [x] - formula de distancia-vs-poligonos (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)
- **Presupuesto de texturas MB por bioma** [x] - formula de peso por material coordenada (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)
- **Presupuesto de tiempo de creacion/regeneracion < 30s** [x] - formula con M96/M112 numbers (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)

## Presupuestos numericos II - formulas concretas (Reflection-Beam-1.0, 2026-10-23)

### 11. Poligonos por bioma
- Formula: poligonos_bioma = poligonos_chunk * chunks_activos. Rango: 50k-100k por chunk, 500k-1M por escena (10 chunks activos).
- Coherente con M70 (presupuesto 0.5 ms/frame). 500k poligonos / 60 fps = 8333 poligonos/frame. Razonable.
- Unidad: poligonos. Dependencia: M70 (0.5 ms/frame).

### 12. LODs por distancia
- Formula: LOD0 = 100% (distancia 0-25m), LOD1 = 50% (25-50m), LOD2 = 25% (50-100m), LOD3 = 12.5% (>100m). Reduccion factor 0.5 por nivel.
- Coherente con M50 (presupuesto de instancias) y M138 (MultiMesh).
- Unidad: porcentaje de poligonos. Dependencia: M50, M138.

### 13. Texturas MB por bioma
- Formula: texturas_bioma = materiales_por_bioma * mb_por_material. Rango: 8-12 materiales x 2-4 MB = 16-48 MB por bioma.
- Coherente con presupuesto de VRAM (no declarado, pero 48 MB es razonable para un bioma).
- Unidad: MB. Dependencia: M90 (presets graficos).

### 14. Posicion de spawn del jugador
- Formula: spawn = (0, get_height(0,0) + 1, 0). Costa 0-15. Player en +1 sobre costa.
- Coherente con biomas (costa 0-15, spawn en costa).
- Unidad: coordenadas voxel. Dependencia: M167 (Isla Raiz).

### 15. Tiempos de creacion/regeneracion
- Formula: creacion = 2-5s, regeneracion = 1-3s. Total carga de escena: <10s.
- Coherente con M96 (carga de escena) y M112 (timeout 15 min).
- Unidad: segundos. Dependencia: M96, M112.

