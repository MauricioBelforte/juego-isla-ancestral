**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 10: Generación del Mundo

## 1. Análisis de los puntos del plan maestro (sección 9)

| # | Punto | Resolución |
|---|---|---|
| 1 | Generación procedural | ✅ Pipeline de 8 capas sobre el voxel-world de M08 |
| 2 | Ruido (Perlin/Simplex) | ✅ Simplex 2D/3D multi-octava (ruido propio en GDScript o addon; si no alcanza 60 FPS → Voxel Tools asistencia) |
| 3 | Semillas | ✅ PRNG global por seed (xoshiro/PCG), sub-PRNG por contexto de chunk |
| 4 | Chunk | ✅ Generación por chunk de 16³, bajo demanda con streaming (M08), asíncrona |
| 5 | Biomas | ✅ Aplicar mapa de biomas de M09 (altura+humedad) |
| 6 | Vegetación | ✅ Capa 6: densidad/catálogo por bioma (árboles, setos, flores) — instanciación Playground pues decorativos no voxel (M50) |
| 7 | Minerales | ✅ Vetas por ruido 3D con distribución por profundidad (M46) |
| 8 | Agua | ✅ Capa 7: nivel de agua por mapa de altura (M51 detalles de clima) |
| 9 | Estructuras | ✅ Capa 8: ruinas, templos, puentes, caminos según recetas (M09) y prefabs propios (no voxel a voxel) |
| 10 | Ruinas | ✅ Generadas con plantilla de POI (estilo: ruinas de la Antigua era) |
| 11 | Caminos | ✅ Splines manuales (no auto-generados): conectan POI productivos y narrativos |
| 12 | Montañas | ✅ Crestas con ruido de clavos + nieve estacional (M29) |
| 13 | Cuevas | ✅ Ruido 3D en piedra; entradas según reglas de M09 |
| 14 | Templos | ✅ El Templo de la Brisa se "coloca" por marcador (no por ruido); puerta en grieta |
| 15 | Determinismo | ✅ MISMO mundo byte a byte: sin rand global, sin tiempo, sin Physics de scan |
| 16 | Rendimiento | ✅ Quince chunks/seg con trabajo distribuido en hilos de Voxel Tools si hace falta (M61 mide) |
| 17 | Edición en runtime | ✅ Los diffs del jugador se re-aplican sobre el mundo regenerado (M08) |
| 18 | Persistencia de cambios | ✅ WorldPartition (M08): carpetas `session/` y `saved/` |
| 19 | Mods | ⏸ post-v1.0: API de mazmorras; decisiones de integridad de mundo aun pendientes (M_release) |
| 20 | Regeneración | ✅ Solo lo no anclado (sin cortar faro/puerto/templo). Regla: 80% de riqueza re-roll soportada; 0% de puntos narrativos |
| 21 | Carga inicial | ✅ Splash → "Generando Aurora..." barra de progreso (UX obligatorio, AGENTS §8) |
| 22 | Proto-build | ✅ Semilla de desarrollo fija `semilla_dev` para reproducción de bugs |
| 23 | Ajuste fino | ✅ Knobs por capa (amplitudes, thresholds, densidades) en archivos .tres (data/ ) |
| 24 | Logging | ✅ `LOG_GENERATION`: semilla, tiempo por capa, chunks/seg (Logger rotativo M05) |
| 25 | Errores frecuencia | ✅ Chunk fallido → reintento ×2 → chunk de basalto (fallback visible + log) |
| 26 | Herramientas | ✅ Menu de debug en editor: "Regenerar mundo", "Inspeccionar chunk", seeds pruebas |

## 2. Alternativas descartadas

- **Mundo 100% guardado en archivo:** descartado — mundo enorme; diffs ganan en tamaño y velocidad.
- **Generación síncrona:** descartado — freeze de frames; asíncrono con cola prioritaria (cerca del jugador primero).
- **Mazmorras/dungeons procedurales en v1.0:** descartado — el roadmap lo lleva post-v1.0 (Cenizas) junto con la API de mods.
- **Caminos auto-generados (pathfinding):** descartado — splines manuales garantizan coherencia narrativa y evitan softlocks.

## 3. Decisión: tokenísticas del pipeline (entradas/salidas por capa)

| Capa | Entrada | Salida | Fuente |
|---|---|---|---|
| 1. Altura | PRNG(chunk) + seed global | Mapa de alturas (64×64) | Simplex multi-octava |
| 2. Bioma | Altura + humedad | Mapa de biomas | Reglas M09 |
| 3. Formaciones | Recetas M09 + bioma | Modificadores de altura/estructura | Marcadores narrativos |
| 4. Roca/cuevas | Altura + ruido 3D | Densidad de piedra/aire | Simplex 3D |
| 5. Minerales | Profundidad + ruido 3D | Vetas (M46) | Tabla por bioma |
| 6. Vegetación | Bioma + densidad | Lista de árboles/decorativos | Catálogo M50 |
| 7. Agua | Mapa de alturas | Nivel de agua | Nivel global + clima (M51) |
| 8. Estructuras | Marcadores POI | Ruinas, templos, caminos | Prefabs M09/M26 |