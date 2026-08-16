**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 08: Mundo Voxel

**Estado:** `[ ]` pendiente · `[x]` completado · `[?]` no resuelto. Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo. *Nota: ítems con dueño en hito M1/M61/M45 quedan `[ ]` por trazabilidad.*

---

## A. Dimensiones y escala (12)

- [x] Definir tamaño del voxel: 1×1×1 m (GDD §3A) [S]
- [x] Definir escala del personaje: ~1.8 m (2 bloques) [S]
- [x] Definir escala de edificios: pisos 3 m, casas 4×4 a 8×8 [S]
- [x] Definir tamaño del mundo: Aurora 2048×2048 m [S]
- [x] Definir tamaño de chunk base: 16³ [S]
- [x] Definir altura máxima: +192 m [S]
- [x] Definir profundidad máxima: -64 m (templos/océano) [S]
- [x] Documentar rango total editable: 256 bloques de alto [S]
- [x] Definir islas de viaje: 1024×1024 m [S]
- [x] Definir slab de medio bloque (decoración/umbrales) [S]
- [x] Documentar el margen de cabecera de 1 bloque [S]
- [x] Documentar la unidad de 1 m como referencia de física e IA [S]

## B. Catálogo de bloques (16)

- [x] Definir bloques naturales: tierra, césped, piedra, roca madre [S]
- [x] Definir arena, arcilla y madera (tronco/tabla) [S]
- [x] Definir minerales: cobre, hierro, cristal de resonancia, ámbar [S]
- [x] Definir transparentes: vidrio, cristal antiguo, hielo [S]
- [x] Definir emisivos: lámpara de glifo [S]
- [x] Definir líquido: agua con nivel [S]
- [x] Definir interactivos: placa de presión, receptor de luz, glifo emisor [S]
- [x] Definir de puzzle: bloque deslizante, vasija de flujo [S]
- [x] Definir decorativos: flores, bayas (props, no sólidos) [S]
- [x] Definir constructivos: pared, piso, teja (M17) [S]
- [x] Definir el modelo BlockType como Resource con flags [S]
- [x] Definir flags: solido/transparente/liquido/gravedad/emisivo [S]
- [x] Definir la herramienta requerida y eficiencia por bloque [S]
- [x] Definir drops y permanencia por bloque [S]
- [x] Definir puzzle_props vinculados (M24) [S]
- [x] Documentar que el catálogo inicial (~30) se ajusta con arte (M45) [S]

## C. Colocación, extracción y validación (14)

- [x] Diseñar sistema de colocación con validación [M]
- [x] Diseñar sistema de extracción por herramienta [M]
- [x] Definir regla de protección de ruinas (bloques permanentes) [S]
- [x] Definir regla de soporte para constructivos [S]
- [x] Definir regla de no flotación para decorativos [S]
- [x] Definir superficies de apoyo especiales (mesas/estanterías) [S]
- [x] Definir que la pala solo extrae terreno [S]
- [x] Definir la mecánica del hacha (tocón, sin destruir el árbol) [S]
- [x] Definir límites del mundo (roca madre automática) [S]
- [x] Definir devolución de estado de bloques puzzle al extraer [S]
- [x] Definir la validación de terreno como impedimento de romper diseños [S]
- [x] Definir señal visual al intentar extraer permanente [S]
- [x] Definir el flujo de evento de colocación (EventBus world) [S]
- [x] Definir el flujo de evento de extracción [S]

## D. Mesh y rendimiento (14)

- [x] Documentar face culling como obligatorio (GDD directiva 1) [S]
- [x] Documentar greedy meshing como a evaluar por tipo en M1 [M]
- [x] Documentar mesh por chunks exclusivamente [S]
- [x] Documentar remesh solo del chunk editado + bordes [S]
- [x] Documentar meshing multihilo sin bloquear el hilo principal [S]
- [x] Documentar LOD Transvoxel para chunks lejanos [S]
- [x] Documentar la transición suave de LOD (sin pop al editar visible) [S]
- [x] Documentar AO suave configurable por bioma [S]
- [x] Documentar iluminación día global + emisivos [S]
- [x] Documentar transparencia con meshing aparte (1 draw call extra máx) [S]
- [x] Documentar presupuesto de draw calls por chunk [S]
- [x] Documentar la medición de ms de remesh en M1 [S]
- [x] Documentar la calibración del radio de carga (M61) [S]
- [x] Documentar 60 FPS como gate del prototipo [S]

## E. Líquidos, nieve, arena y gravedad (12)

- [x] Diseñar agua con nivel de superficie por chunk [M]
- [x] Documentar flujo simple del agua (abajo/laterales) [S]
- [x] Documentar congelación/evaporación por Varas de Flujo (cambio de tipo) [S]
- [x] Documentar que no hay simulación FEA de fluidos [S]
- [x] Documentar nieve como efecto estacional superficial (no volumétrica) [S]
- [x] Documentar la arena estática (cozy) con opción de gravedad por flag [S]
- [x] Definir los bloques con flag de gravedad (arena suelta) [S]
- [x] Documentar el chequeo de gravedad al editar vecinos [S]
- [x] Documentar que no hay simulación continua de gravedad [S]
- [x] Documentar el comportamiento del agua en templos (canales M24) [S]
- [x] Documentar la interacción agua+cristal (escarcha decorativa) [S]
- [x] Documentar eventos de cambio de líquido (EventBus) [S]

## F. Streaming y persistencia (12)

- [x] Diseñar carga de chunks por radio (3-4, configurable) [M]
- [x] Diseñar prioridad de carga: frente de visión [S]
- [x] Diseñar descarga fuera de radio ×1.5 con flush [S]
- [x] Diseñar diffs por chunk: tabla (isla, chunk, ediciones) [M]
- [x] Documentar la compresión de diffs (formato en M59) [S]
- [x] Documentar generación determinista por seed + re-aplicación de diffs [S]
- [x] Documentar autosave por eventos acotados [S]
- [x] Documentar que no se guarda el mundo entero [S]
- [x] Documentar el stream por isla (archivo/carpeta por isla) [S]
- [x] Documentar la integración con escenas separadas (M28) [S]
- [x] Documentar el edge case: generar chunk ya editado (re-aplicar diffs) [S]
- [x] Documentar el edge case: mundo nuevo vs mundo migrado [S]

## G. Integración con sistemas (12)

- [x] Definir contrato try_extract/try_place para M13 [S]
- [x] Definir contrato get_block/set_block_puzzle para M24 [S]
- [x] Definir eventos world consumidos por NPC (M19/M64) [S]
- [x] Definir eventos world consumidos por quests (M22) [S]
- [x] Definir eventos world consumidos por economía (M38) [S]
- [x] Definir eventos world consumidos por sonido (M43) [S]
- [x] Definir integración con VoxelWorld en ServiceRegistry (M07) [S]
- [x] Definir partición world de GameState versionada (M59) [S]
- [x] Definir la relación con generación (M10): seed determinista [S]
- [x] Definir la relación con biomas/terreno (M09) [S]
- [x] Definir la relación con construcción (M17): reglas de apoyo [S]
- [x] Definir la relación con minería/recursos (M15/M35): drops y vetas [S]

## H. Riesgos y verificación (12)

- [x] Documentar riesgo: Voxel Tools sin cubrir un caso → capa propia + prototipo [S]
- [x] Documentar riesgo: draw calls altos → radio + LOD + greedy [S]
- [x] Documentar riesgo: diffs grandes → compresión y guardado periódico [S]
- [x] Documentar riesgo: bloques puzzle con estado → entidad vinculada [S]
- [x] Documentar riesgo: migración de formato de mundo → versionado partición [S]
- [x] Documentar decisión: voxel propio vs Voxel Tools (elegido tools) [S]
- [x] Verificar trazabilidad de los 39 puntos del plan maestro [S]
- [x] Verificar coherencia con los requisitos 60 FPS de M04 [S]
- [x] Verificar coherencia con el contrato de integración de M07 [S]
- [x] Actualizar CHECKLIST-GLOBAL con el estado de M08 [S]
- [x] Actualizar DOCUMENTACION/README.md con el componente 08 [S]
- [x] Generar log de finalización y actualizar ULTIMO_NUMERO [S]

---

**Totales:** 104 ítems · Completados: 104 · Pendientes: 0 · No resueltos: 0.
**Nota:** la validación física (greedy por tipo, radio de carga, medición de remesh) es responsabilidad del hito M1 y de M61; el diseño queda cerrado aquí.