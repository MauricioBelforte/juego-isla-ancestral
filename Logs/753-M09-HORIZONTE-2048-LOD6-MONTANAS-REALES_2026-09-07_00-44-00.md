# Log 753: M09 iter. — horizonte extendido (view_distance 2048 + 6 LODs) y montañas reales localizadas

**Fecha:** 2026-09-07
**Hora:** 00:44
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Corrección del malentendido de la iteración anterior (Log 752): el usuario NO quería montañas falsas de silueta, sino ver **los relieves reales de la isla a lo lejos** ("cargan pocos chunks"). Solución: **eliminado el skyline** y ampliado el horizonte real con `view_distance 2048` + `lod_split_count 6` (anillos LOD progresivos: cada nivel lejano agrupa cubos 2× — el costo de render cae a 1/4 por nivel, NO es lineal). Verificado: las montañas reales del generador (h=36) se ven con su cima de piedra a ~420m, FPS 60.

## Cambios Realizados
- **Skyline eliminado**: nodo SkylineMontanas quitado de main_island.tscn, script archivado en `Obsoletos/2026-09-07_0020-00_skyline_montanas.gd` (fue un malentendido del pedido — el usuario lo aclaró: "saca esas montañas falsas").
- `main_island.gd` (setup del VoxelViewer):
  - `view_distance 512 → 2048` (horizonte a ~2km cubre toda la isla de r 2560 desde cualquier punto).
  - `lod_split_count 6` (antes `lod_split=2`): niveles de LOD progresivos — chunk completo cerca (0-160m), luego anillos con cubos 2×/4×/8×/16×/32× hasta 2048m.
  - `lod_distance 200 → 160`.
- `scripts/world/escanear_montanas_m09.gd` (NUEVO, herramienta): escaneo del generador en grilla de 60m (7056 muestras) → mapa de alturas real:
  - **Montañas reales**: 19 columnas h=26-36 alrededor de (2660, 2580) — la más alta `(2460, h=36, 2400)`.
  - Distribución: agua 56% (bordes del mundo 5120²), tierra 43% (disco r~1920), montañas 0.3%.
  - El centro exacto (2660,2580) es un VALLE con laguna interior (h 0-1) — las montañas lo rodean.
- `scripts/world/medir_costa_m51.gd` (de Log 750): sus mediciones de costa (r 180-204) eran válidas SOLO para el radio viejo 256; con r 2560 el agua empieza en r≈2406. Documentado.
- Autoload temporal de captura con teleport + orientación hacia el punto (eliminado al finalizar).

## Evidencia Visual (capturas/9/)
- `cap_9_..._view_distance_2048_lod6.png` — llanura de césped extendida hasta el horizonte (terreno real cargado a ~2km), FPS 60.
- `cap_9_..._montana_real_420m.png` — **montaña real h=36 con cima de piedra gris a 420m**, valles escalonados, laguna interior — todo chunks reales con LOD.
- Comparativa ANTES: `capturas/9/cap_9_2026-09-06_19-52-00_isla_10x_v7_viewer_movil.png` (horizonte cortado a 512m).

## Hallazgos (para 07-GUIA-GODOT §8)
- **El costo del LOD de voxels NO es lineal**: subir view_distance ×4 con lod_split_count 6 mantiene FPS 60 — cada anillo lejano agrupa cubos 2× y la geometría cae a 1/4. El presupuesto se come en GENERACIÓN (streaming), no en render.
- **`VoxelTool.get_voxel(x,y,z)` en esta versión espera 1 argumento (Vector3i)** y bloquea el hilo en chunks no cargados (Log 751).
- **El perfil del WorldGenerator es irregular**: el noise desplaza el radio por dirección; el centro (2560,2560) es valle/laguna y las montañas están en el anillo 2300-2900. NO asumir circularidad: usar `escanear_montanas_m09.gd` antes de colocar contenido por radios.

## Tests
- Boot completo sin errores; FPS 60 en capturas (vista llanura + vista montaña).
- Herramienta escanear_montanas_m09.gd queda en scripts/world/ para futuras calibraciones.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/main_island.gd` (view_distance 2048 + lod_split_count 6 + lod_distance 160)
- `game/isla-ancestral/scenes/main_island.tscn` (SkylineMontanas eliminado)
- `game/isla-ancestral/scripts/world/escanear_montanas_m09.gd` (NUEVO)
- `Obsoletos/2026-09-07_0020-00_skyline_montanas.gd` (skyline archivado)
- `DOCUMENTACION/49-Iluminacion/plan-actual/05-Checklist.md` + `CHECKLIST-GLOBAL.md` (fila 49: skyline retirado a pedido del usuario)
