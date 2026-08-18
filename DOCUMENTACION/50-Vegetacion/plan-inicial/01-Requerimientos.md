**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 50: Vegetación

## ID del Módulo
- **Código:** M50 (CHECKLIST-GLOBAL: ID 50 — Vegetación; plan maestro: sección 49 "VEGETACIÓN")
- **Carpeta:** `DOCUMENTACION/50-Vegetacion/`
- **Dependencias:** M08 (Mundo Voxel — bloques de madera/hojas), M09 (Terreno y Geografía — biomas), M10 (Generación del Mundo — PRNG, densidad), M45 (Arte 3D — mallas), M04 (Godot — MultiMesh). Relaciones: M61 (Rendimiento — instancing/culling), M33 (Agricultura), M29 (Calendario — estaciones), M48 (Animación — viento), M31/M32 (día/noche y clima), M51 (Agua), M47 (texturas), M52 (VFX)
- **Delegable desde:** M08 (tala de árboles como bloques), M10 (densidades por bioma), M45 (mallas de vegetación), M04 (MultiMesh nativo)

## 1. Problema

Aurora tiene 13 biomas (M09) que exigen vegetación diferenciada (hierba, flores, arbustos, árboles pequeños, grandes, ancestrales, palmeras, bambú, plantas tropicales, acuáticas, submarinas, musgo, enredaderas, hongos y plantas luminosas). Sin un sistema de vegetación definido, el proyecto degeneraría en: millones de instancias que rompen el frame (draw calls explotando), vegetación estática que rompe la ilusión de viento (M48), árboles que no interactúan con la tala voxel (M08), estaciones sin efecto visual (M29), o densidades idénticas en biomas que deberían sentirse distintos (jungla vs desierto). El plan maestro lista 26 exigencias: tipos, variantes estacionales, animación de viento, interacción con jugador/clima/agua/terreno, sistema de crecimiento, LOD, culling, instancing y optimización. El objetivo del módulo es que cada bioma tenga su vegetación característica, instanciada eficientemente, con viento, estaciones y respuesta a la interacción, dentro del presupuesto de M61.

## 2. Objetivo

Definir el sistema de vegetación de la isla: catálogo de especies por bioma (26+ tipos del plan maestro), autorreglas de densidad y distribución por bioma (M09/M10, determinista), estrategia de instancing (MultiMesh + GPU) con LOD y culling, animación de viento procedural (M48), interacción con el jugador (talar M08, recolectar M33, pisar hierba), respuesta al clima (M32: lluvia, viento fuerte, nieve), a las estaciones (M29: floración, hojas otoñales, nieve), al agua (plantas acuáticas/submarinas M51) y al terreno (pendientes, alturas), sistema de crecimiento (árboles jóvenes → grandes), y presupuesto de rendimiento verificable. El resultado debe ser vegetación densa pero barata, viva pero determinista, y estacionalmente correcta.

## 3. Alcance

### 3.1 Dentro del alcance
- Catálogo de especies del plan maestro (26+): hierba, flores, arbustos, árboles pequeños/grandes/ancestrales, palmeras, bambú, plantas tropicales, acuáticas, submarinas, musgo, enredaderas, hongos, plantas luminosas.
- Densidades y distribuciones por bioma (M09/M10): tablas por especie (densidad por chunk, distribución, altura, pendiente).
- Instancing: MultiMesh por especie/chunk, culling por distancia (M61), LOD de mallas.
- Viento: animación procedural (M48) — vertex shader con fase por instancia; determinista.
- Interacción con el jugador: tala de árboles voxel (M08), recolección (M33), pisado de hierba (sombras de luz suaves), cosecha estacional.
- Interacción con clima (M32): viento fuerte, lluvia (hojas mojadas no — solo sonido M42), nieve (se cubren visuales opcional).
- Estaciones (M29): variantes de color/hojas por estación; calendario Aurora.
- Agua (M51): plantas acuáticas en zonas costeras; submarinas en el fondo; límites de profundidad.
- Terreno (M09): vegetación según pendiente (no en acantilados), altura (línea de árboles), playa sin vegetación alta.
- Crecimiento: árboles jóvenes → adultos (progresión lenta; control de densidad por chunk).
- LOD/culling/instancing/optimización: presupuesto M61; validación `validate_vegetation.gd`.
- Determinismo: densidades con PRNG de chunk (M10).

### 3.2 Fuera del alcance
- La agricultura doméstica (cultivos, huertos): M33 (consume el sistema de instancias y viento).
- La tala como recurso (leña, madera): M08/M13/M15 (aquí solo la parte visual de los árboles voxel).
- El modelado de mallas de árboles/vegetación: M45 (se consumen aquí).
- La animación de personajes/fauna: M48 (solo el viento de vegetación).
- El sonido de vegetación (hojas, viento): M42 (se consume, no se genera).
- La iluminación de plantas luminosas: M47/M49 (la luz ambiental emisiva se define en M47/M49).

## 4. Restricciones

- **Godot 4.x (>= 4.4.1):** MultiMesh + MultiMeshInstance3D; el viento en vertex shader (GPU), nunca per-instance CPU.
- **Presupuesto:** se verifica contra M61 (draw calls < X por chunk, instancias por tipo, LOD); densidad configurable por preset M90.
- **Determinismo:** densidad y distribución por PRNG de chunk (M10); misma semilla, mismo bosque.
- **Tala coherente:** los árboles TALABLES son voxel (M08); la vegetación decorativa NO es destructible (excepto hierba pisada transitoria).
- **Estaciones:** variantes de color por estación con transiciones suaves (M29); nunca reaparecer árboles talados fuera de límite.
- **Crecimiento:** limitado (LOD visual); el crecimiento NO rompe el determinismo del chunk (se regenera solo por eventos de juego).
- **Validable:** toda escena pasa `validate_vegetation.gd` (densidad, LOD, instancias).

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Catálogo de especies | Las 26+ especies del plan maestro con malla (M45), slots de material (M47), parámetros de densidad y biomas |
| RF2 | Densidad y distribución por bioma | Tabla bioma → especies y densidades (M09); distribución por PRNG chunk (M10) con clamps por pendiente/altura |
| RF3 | Instancing | MultiMesh por especie por chunk; ≤ N instancias por chunk; LOD 2 niveles por especie; culling por distancia |
| RF4 | Viento procedural | Vertex shader determinista por instancia (fase = hash instancia); amplitud por bioma/clima (M32); viento fuerte aumenta amplitud |
| RF5 | Interacción con el jugador | Tala de árboles voxel (M08) con caída visual y regeneración limitada; pisado de hierba (transparente/flectada); recolección de flores (M14/M33) |
| RF6 | Interacción con clima | Viento fuerte (M32) sube amplitud; lluvia moja (sonido M42) no visual; nieve estacionaria cubre opcional |
| RF7 | Interacción con agua | Plantas acuáticas en zonas húmedas poco profundas (M51); submarinas en el fondo; sin vegetación bajo hielo |
| RF8 | Interacción con terreno | Clamp de pendiente (≤ umbral); línea de árboles por altura (M09); playa sin alta vegetación |
| RF9 | Estaciones | Variantes de color por estación (M29) con transición suave; floración en primavera fértil; hojas en otoño; nieve en invierno (opcional) |
| RF10 | Crecimiento | Árboles jóvenes → adultos (progresión por tiempo de mundo, M29); densidad regulada por chunk; sin saltos visuales |
| RF11 | LOD y culling | LOD por especie (alto/bajo), culling frustum + distancia; dentro de presupuesto M61 |
| RF12 | Optimización | Draw calls, instancias activas, memoria de MultiMesh contra M61/M62; pooling de instancias |
| RF13 | Validación | `validate_vegetation.gd`: densidades reales vs tabla, LOD, presupuesto |
| RF14 | Naming | Convention `veg_`, `tree_`, `foliage_` (M108) |

## 6. Criterios de Aceptación (Verificables)

1. Cada bioma muestra su vegetación característica con densidades de la tabla (verificadas por el validador).
2. La escena pivote (bosque + pueblo) corre en preset default sin caída de frame (M61): instancias visibles ≤ N.
3. El viento es determinista: misma semilla, mismas fases; amplitud por bioma/clima correcta.
4. Los árboles talables se cortan con exito (M08) y los decorativos no son destructibles.
5. El cambio de estación cambia el color de la vegetación visualmente en ≤ X segundos de transición (M29).
6. La densidad de vegetación en pendientes/playas/alturas respeta los clamps.
7. El costo de MultiMesh (memoria + draw calls) queda dentro del presupuesto M61/M62.
8. La regeneración de árboles talados ocurre solo por eventos de juego y no rompe el determinismo del chunk.