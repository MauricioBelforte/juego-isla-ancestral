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



Riel design-docs SIN DATOS (encargo agnes-3-flash msg 255, 2026-10-24 21:08; GO directora). Produce-first line-based, sin vision: cada numero medido en disco con cita archivo:linea (recorrido python -X utf8 + Grep/Read; sin ejecutar Godot). Las capas I/II (Beam 1.0, 2026-10-23) quedan intactas; aqui se groundean con mediciones reales y se documentan los drift hallados. **Modelo:** Ling-3.1-Flash / **Plataforma:** Kilo Code / **Fecha:** 2026-10-25

## Presupuestos numericos III - mediciones en disco (Ling-3.1-Flash, 2026-10-25)

### 16. Constantes medidas en disco (terreno voxel)
| Medida | Valor medido | Cita archivo:linea |
|--------|--------------|--------------------|
| Centro del mundo | Vector2(2560, 2560) | scripts/world/mundo_raiz.gd L16 (autoload, punto unico de verdad, AGENTS.md §26) |
| Radio de la isla | RADIO_ISLA = 1800.0 (mundo 5120x5120) | scripts/world/mundo_raiz.gd L18 |
| Spawn del jugador | Vector3(3860, 0, 3860) — a ~1838u del CENTRO, en la orilla | scripts/world/mundo_raiz.gd L26 |
| Altura maxima del terreno | max_height = 40 (boost 1.0; techo absoluto 80 = 40x2.0) | scripts/world/island_generator.gd L14/L17; tests/test_generacion_m10_atria.gd L199 |
| Chunk | CHUNK_SIZE = 32 (constante global, arista de chunk) | scripts/utils/game_constants.gd L9 |
| Techo de malla agua por chunk | VERTS_PER_CHUNK_MAX = 2000; OVERDRAW_MAX = 1.5; REFLECTION_PROBES_MAX = 2 | scripts/world/validate_water.gd L13-15 (check L59) |
| view_distance VoxelViewer (prod) | 1024.0 m (antes 256.0) | scripts/world/main_island.gd L161; scripts/rendimiento/bench_recorder.gd L142; tests usan 256 (test_terrain.gd L76) y 128 (test_terrenos_b3.gd L184) |

### 17. Umbrales de bioma medidos (island_generator.gd L203-234)
| Bioma | Condicion medida | Bloque de superficie | Cita |
|-------|------------------|----------------------|------|
| beach | height <= 3 | SAND | island_generator.gd L210-211, L173-174 |
| snow | height > 0.8 x max_height = 32 | SNOW | island_generator.gd L218-219 (FIX BUG-043: snow ANTES que mountain) |
| mountain | height > 0.65 x max_height = 26 | STONE | island_generator.gd L222-223 |
| wetland | height <= 8 AND humedad > 0.45 | MUD | island_generator.gd L227-228 |
| forest | humedad > 0 | GRASS | island_generator.gd L231-232 |
| grassland | else | GRASS | island_generator.gd L234 |
- Sub-superficie: 3 capas segun bioma (L185-195); profundidad STONE con minerales si ruido 3D > 0.6 y y < height-10 (L196-200, L241-243); BEDROCK en y <= 0 (L162-164).
- Biomas alcanzables verificados por test: beach, snow, mountain, wetland, forest, grassland (6) — tests/test_generacion_m10_atria.gd L145-146 (umbral_mountain = int(40*0.65), umbral_snow = int(40*0.8)), L158.
- Receta por capas y tabla de orilla (0-0.86 arena 3-6 m; 0.86-0.94 arena 3; 0.94-0.98 agua clara 2; >0.98 agua profunda 0; montañas 55-65% del radio): DOCUMENTACION/GUIA-GODOT/08-terreno-voxel.md L15-41.

### 18. Impostor de horizonte medido (terreno_horizonte.gd)
- PASO 64 m (L21); CENTRO_ISLA (2560, 2560) (L23); RADIO_CUBIERTO 2700 m (L25); FACTOR_ALTURA 0.85 (L27); exageracion de montañas x4.0 cerca / x1.0 lejos con transicion 0-2100 m (L32-35); H_MIN 4.0 (L37); DISCO_BASE_Y 4.3 (L39); DISCO_R 1800 (L42); ANILLO arena 1800-3000 m con ocultar <150 m (L46-47, L51); TAMANO_TILE 640 m (L57); TILE_OCULTAR_UMBRAL 400 m (L60); FILAS_POR_FRAME 6 (L66); INTENTOS_MAX 12 (L74); colores por altura L68-72; tiles n = ceil(2 x 2700 / 640) = 9 -> grilla 9x9 (L167); disco base opaco hasta r 2100 a y=0.2 (L238-240, Log 800); conteo de tiles activos reportado en runtime por print L234.

### 19. Renderizado del terreno: vertex colors, NO texturas (hallazgo material)
- MEDIDO: el terreno voxel renderiza por color de vertice — block_catalog.gd L69-95 (_color_canonico, 42 referencias a Color), world_manager.gd L30-31 (mat.vertex_color_use_as_albedo = true; terrain.material_override = mat), terreno_horizonte.gd L222/L287/L306 (mismo mecanismo en el impostor).
- MEDIDO: assets totales del proyecto = 848 archivos (.tres/.material/.png/.jpg/.svg/.webp/.stex) = 3.01 MB (tools 1.31 MB, reports 0.95 MB, data 0.33 MB, assets 0.14 MB, addons 0.13 MB). resources/terrain/ = 7 .tres (arena, agua, barro, ceped, nieve, rocas, pavimento).
- DRIFT: el presupuesto de capa I #18 ("2-4 MB/material, 8-12 materiales/bioma, 16-48 MB/bioma") NO tiene contraparte en disco: el terreno no usa texturas por bioma (vertex-color es la optimizacion M167/impostores). El rango 16-48 MB/bioma queda como presupuesto de diseño sin sustento medido. No se viola nada; se documenta para que el proximo agente no busque texturas de terreno inexistentes.

### 20. Tiempos de creacion/regeneracion (deuda de medicion, honesta)
- NO hay tiempos de generacion de terreno medidos en disco: ningun log ni test persiste segundos de generacion masiva de get_height.
- Presupuesto de diseño (capa I #20): creacion 2-5 s, regeneracion 1-3 s, carga total <10 s.
- Anclas medidas cercanas: boot headless + quit sin escena = 2.8 s (M112 05-Checklist L124, diagnostico 2026-10-21); carga de escena <10 s = presupuesto M96; suite completa de tests 545.3 s (M112, Log 2078).
- Propuesta de medicion (no aplicada — este riel es sin datos/no ejecuta Godot): instrumentar tests/test_generacion_m10_atria.gd con OS.get_ticks_msec() alrededor de la generacion del mundo y volcar el numero al informe de la siguiente ronda.
