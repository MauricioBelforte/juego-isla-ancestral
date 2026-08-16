**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 63: Cargas y Streaming

## 1. Resolución de los 15 puntos del plan maestro

| # | Punto | Resolución |
|---|---|---|
| 1 | Pantalla de carga | Escena `LoadingScreen.tscn` con arte cozy (nubes, islas dibujadas), barra de progreso REAL calculada sobre operaciones encoladas, consejos del mundo y Skip deshabilitado (UX sección 8 AGENTS) |
| 2 | Cargas asíncronas | `ResourceLoader.load_threaded_request(path, type, use_sub_threads)` para: escenas, bancos de audio, texturas grandes; cola con prioridad |
| 3 | Chunks cercanos | El voxel (M08) prioriza chunks por distancia radial; radio streaming base R=3, máx 5 en movimiento rápido; señal por chunk listo |
| 4 | Chunks lejanos | LRU con tope de chunks en memoria; descarga diferida (2 frames después de salir del radio) para evitar parpadeo |
| 5 | NPCs necesarios | Nodos NPC solo dentro de radio de actividad (se instancian al entrar, se pausan al salir — M63-RF4) |
| 6 | Audio | Bancos por región: los de la zona se precargan en el hilo de streaming; sin `load()` en tiempo de juego |
| 7 | Texturas | Atlas por bioma + mips; carga por LOD: mip base al entrar, mip alto al acercar (streaming de mipmaps) |
| 8 | Shaders | Compilación en PRECALIENTE (menú principal): shaders del mundo y de efectos compilados antes del spawn; caché de variantes |
| 9 | Precalentar | En el menú: `precalentar_mundo()` (chunks iniciales + shaders + bancos) → el viaje al mundo es casi instantáneo |
| 10 | Evitar congelamientos | Ninguna carga en el hilo main: reglas verificables (deltas < 50 ms; profiler M113) |
| 11 | Progreso real | El total = suma ponderada de ítems encolados; cada ítem reporta avance (loaded/count) → barra nunca fija ni falsa |
| 12 | Streaming del océano | Océano como mesh semáforo por región (LOD 0 base lejano + mallas costa cerca): solo se actualiza el horizonte (anillo) |
| 13 | Streaming subterráneo | Subterráneo = regiones grandes con LOD profundo; el jugador que profundiza carga por pisos (0-2), descarga techo al salir |
| 14 | Streaming de islas | Islas flotantes (M09/M27): cada isla = chunk StreamableBox; descargar al salir 10 m del borde; subir/bajar sin huecos (encadenado de LOD) |
| 15 | Probar movimientos rápidos | Test de QA: teleport de punta a punta del mapa en 10 s sin hitching ni chunks vacíos visibles |

## 2. Decisiones clave

1. **Progreso real por encolado ponderado**: cada operación es una unidad con peso (chunk=1, banco=3, shader=5); la barra refleja la suma de pesos completados / total — honesto y smooth.
2. **Precalentamiento en menú principal**: el 90% de la carga visible se adelanta; la pantalla de carga del mundo queda corta (~1-3 s).
3. **LRU con tope duro** en chunks (M08): memoria predecible y sin fugas; descarga diferida 2 frames (anti-parpadeo).
4. **Streaming por región** (océano/islas/subterráneo): los mundos con estructura propia no se comportan como voxel plano — cada uno con su LOD y cola.
5. **Cero cargas síncronas en runtime** (regla M61): todo `load`/`preload` ocurre en arranque o en hilos.

## 3. Alternativas descartadas

- **Barra de progreso falsa (fake timers):** engañosa y rompe la sección 8 (progreso real); descartado (pesos por operación).
- **Streaming "todo instanciado de una vez" para islas pequeñas:** el mapa tiene decenas de islas (M27); memoria inaceptable; descartado (StreamableBox por isla).
- **Cambiar LOD de chunks con operaciones síncronas de mesh:** provoca hitching notable (congelamiento); descartado (generación en hilos + cola).