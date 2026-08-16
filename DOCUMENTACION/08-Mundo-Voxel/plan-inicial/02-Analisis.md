**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 08: Mundo Voxel

## 1. Análisis de los 39 puntos del plan maestro (sección 7)

| # | Punto | Resolución |
|---|---|---|
| 1 | Tamaño del voxel | ✅ **1×1×1 m** (GDD §3A) |
| 2 | Escala del personaje | ✅ ~1.8 m (2 bloques de alto) |
| 3 | Escala de edificios | ✅ Pisos de 3 m; casas 4×4 a 8×8 bloques |
| 4 | Tamaño máximo del mundo | ✅ Isla: 2048×2048 m; altura -64 a +192 (256 bloques) |
| 5 | Tamaño de chunk | ✅ 16³ (base); 32³ evaluado para test |
| 6 | Altura máxima | ✅ +192 (nubes/flotantes roadmap) |
| 7 | Profundidad máxima | ✅ -64 (templos/océano) |
| 8 | Tipos de bloques | ✅ Catálogo §3 de 03-Diseno (~30 iniciales) |
| 9 | Materiales | ✅ Resource por bloque (textura/color, sonido, forma) |
| 10 | Propiedades de cada bloque | ✅ Flags: solidez, transparencia, líquido, gravedad, puzzle, interactivo |
| 11 | Bloques sólidos | ✅ Tierra, piedra, madera estructural, cerámica… |
| 12 | Bloques transparentes | ✅ Vidrio, cristal antiguo, hielo |
| 13 | Bloques líquidos | ✅ Agua (flujo superficial), lava no (sin violencia) |
| 14 | Bloques interactivos | ✅ Placas, receptores de luz, grifos de agua (framework M24) |
| 15 | Bloques decorativos | ✅ Muebles/bloques decorativos (no físicos) |
| 16 | Bloques destructibles | ✅ Recurso (tierra, mineral) — relación con M15 |
| 17 | Bloques permanentes | ✅ Roca madre, ruinas protegidas (regla de validación) |
| 18 | Bloques especiales de puzzle | ✅ Espejos, bloques deslizantes, vasijas de flujo |
| 19 | Sistema de colocación | ✅ Reglas §4 (validación de terreno) |
| 20 | Sistema de extracción | ✅ Herramientas con eficiencia (M13) |
| 21 | Validación de terreno | ✅ Igual a protección de ruinas; terreno solo reemplazable |
| 22 | Colisiones voxel | ✅ Voxel Tools (raycast a grilla) |
| 23 | Mesh generation | ✅ Voxel Tools (surface meshing + full) |
| 24 | Face culling | ✅ Obligatorio (GDD directiva 1) |
| 25 | Greedy meshing | ✅ Evaluado: activado en bloques regulares; desactivado en puzzle (deben verse individuales?) → definir en M1 |
| 26 | Chunk meshing multihilo | ✅ Voxel Tools lo soporta (thread pool) |
| 27 | Generación procedural | ✅ M10 (generadores); Voxel Tools stream |
| 28 | Actualización parcial de chunks | ✅ Remeshar solo chunk editado + vecinos si borde |
| 29 | Streaming | ✅ Carga por radio + descarga fuera |
| 30 | Unloading | ✅ A distancia de descarga + volcado de diffs |
| 31 | Guardado de cambios | ✅ Diffs por chunk (partición world de GameState) |
| 32 | Iluminación de voxels | ✅ Luz del día global + luz por bloque (lámparas, glifos) |
| 33 | Ambient occlusion | ✅ Voxel Tools AO configurable (estética cozy → AO suave) |
| 34 | Transparencia | ✅ Ordenado por meshing (cristal), sin blended en masa |
| 35 | Líquidos | ✅ Agua superficial con nivel (no simulación pesada); varas de flujo la alteran (M24) |
| 36 | Nieve | ✅ Acumulación estacional superficial (efecto, no bloque de nieve volumétrico) |
| 37 | Arena | ✅ Cae con gravedad? NO (cozy): arena estática salvo bloques congravedad marcados |
| 38 | Gravedad de ciertos bloques | ✅ Flag por bloque (arena suelta/piedra pómez si aplica) |
| 39 | Coherencia con 60 FPS | ✅ Validación del hito M1 |

## 2. Decisiones de plataforma

- **Voxel Tools como base del mundo** (no reinventar): meshing, AO, LOD Transvoxel, streaming y colisiones ya resueltos y optimizados en C++.
- Construir encima (propio): catálogo de bloques (data), reglas de validación, persistencia de diffs, integración con EventBus/framework de puzzles.
- Alternativa evaluada: meshing propio en GDScript → descartado (perf, tiempo); propio en C++ → costo de mantenimiento injustificable.

## 3. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Voxel Tools no cubre un caso (ej. agua con nivel) | Capa propia sobre el volumen; prototipo lo detecta |
| Draw calls altos con chunks 16³ sin culling | Radio de carga conservador + LOD + greedy para regulares |
| Diffs grandes en islas con mucha edición | Compresión + guardado por regiones/periodos |
| Bloques puzzle con estado (espejo girado) | Estado aparte del voxel (entidad puzzle vinculada a posición) |
| Migración de formatos de mundo | Versionado de la partición world en GameState |