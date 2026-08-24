**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 08: Mundo Voxel

**Estado:** `[ ]` pendiente · `[ ]` completado · `[?]` no resuelto. Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo. *Nota: ítems con dueño en hito M1/M61/M45 quedan `[ ]` por trazabilidad.*

---

## A. Dimensiones y escala (12)

- [ ] Definir tamaño del voxel: 1×1×1 m (GDD §3A) [S]
- [ ] Definir escala del personaje: ~1.8 m (2 bloques) [S]
- [ ] Definir escala de edificios: pisos 3 m, casas 4×4 a 8×8 [S]
- [ ] Definir tamaño del mundo: Aurora 2048×2048 m [S]
- [ ] Definir tamaño de chunk base: 16³ [S]
- [ ] Definir altura máxima: +192 m [S]
- [ ] Definir profundidad máxima: -64 m (templos/océano) [S]
- [ ] Documentar rango total editable: 256 bloques de alto [S]
- [ ] Definir islas de viaje: 1024×1024 m [S]
- [ ] Definir slab de medio bloque (decoración/umbrales) [S]
- [ ] Documentar el margen de cabecera de 1 bloque [S]
- [ ] Documentar la unidad de 1 m como referencia de física e IA [S]

## B. Catálogo de bloques (16)

- [ ] Definir bloques naturales: tierra, césped, piedra, roca madre [S]
- [ ] Definir arena, arcilla y madera (tronco/tabla) [S]
- [ ] Definir minerales: cobre, hierro, cristal de resonancia, ámbar [S]
- [ ] Definir transparentes: vidrio, cristal antiguo, hielo [S]
- [ ] Definir emisivos: lámpara de glifo [S]
- [ ] Definir líquido: agua con nivel [S]
- [ ] Definir interactivos: placa de presión, receptor de luz, glifo emisor [S]
- [ ] Definir de puzzle: bloque deslizante, vasija de flujo [S]
- [ ] Definir decorativos: flores, bayas (props, no sólidos) [S]
- [ ] Definir constructivos: pared, piso, teja (M17) [S]
- [ ] Definir el modelo BlockType como Resource con flags [S]
- [ ] Definir flags: solido/transparente/liquido/gravedad/emisivo [S]
- [ ] Definir la herramienta requerida y eficiencia por bloque [S]
- [ ] Definir drops y permanencia por bloque [S]
- [ ] Definir puzzle_props vinculados (M24) [S]
- [ ] Documentar que el catálogo inicial (~30) se ajusta con arte (M45) [S]

## C. Colocación, extracción y validación (14)

- [ ] Diseñar sistema de colocación con validación [M]
- [ ] Diseñar sistema de extracción por herramienta [M]
- [ ] Definir regla de protección de ruinas (bloques permanentes) [S]
- [ ] Definir regla de soporte para constructivos [S]
- [ ] Definir regla de no flotación para decorativos [S]
- [ ] Definir superficies de apoyo especiales (mesas/estanterías) [S]
- [ ] Definir que la pala solo extrae terreno [S]
- [ ] Definir la mecánica del hacha (tocón, sin destruir el árbol) [S]
- [ ] Definir límites del mundo (roca madre automática) [S]
- [ ] Definir devolución de estado de bloques puzzle al extraer [S]
- [ ] Definir la validación de terreno como impedimento de romper diseños [S]
- [ ] Definir señal visual al intentar extraer permanente [S]
- [ ] Definir el flujo de evento de colocación (EventBus world) [S]
- [ ] Definir el flujo de evento de extracción [S]

## D. Mesh y rendimiento (14)

- [ ] Documentar face culling como obligatorio (GDD directiva 1) [S]
- [ ] Documentar greedy meshing como a evaluar por tipo en M1 [M]
- [ ] Documentar mesh por chunks exclusivamente [S]
- [ ] Documentar remesh solo del chunk editado + bordes [S]
- [ ] Documentar meshing multihilo sin bloquear el hilo principal [S]
- [ ] Documentar LOD Transvoxel para chunks lejanos [S]
- [ ] Documentar la transición suave de LOD (sin pop al editar visible) [S]
- [ ] Documentar AO suave configurable por bioma [S]
- [ ] Documentar iluminación día global + emisivos [S]
- [ ] Documentar transparencia con meshing aparte (1 draw call extra máx) [S]
- [ ] Documentar presupuesto de draw calls por chunk [S]
- [ ] Documentar la medición de ms de remesh en M1 [S]
- [ ] Documentar la calibración del radio de carga (M61) [S]
- [ ] Documentar 60 FPS como gate del prototipo [S]

## E. Líquidos, nieve, arena y gravedad (12)

- [ ] Diseñar agua con nivel de superficie por chunk [M]
- [ ] Documentar flujo simple del agua (abajo/laterales) [S]
- [ ] Documentar congelación/evaporación por Varas de Flujo (cambio de tipo) [S]
- [ ] Documentar que no hay simulación FEA de fluidos [S]
- [ ] Documentar nieve como efecto estacional superficial (no volumétrica) [S]
- [ ] Documentar la arena estática (cozy) con opción de gravedad por flag [S]
- [ ] Definir los bloques con flag de gravedad (arena suelta) [S]
- [ ] Documentar el chequeo de gravedad al editar vecinos [S]
- [ ] Documentar que no hay simulación continua de gravedad [S]
- [ ] Documentar el comportamiento del agua en templos (canales M24) [S]
- [ ] Documentar la interacción agua+cristal (escarcha decorativa) [S]
- [ ] Documentar eventos de cambio de líquido (EventBus) [S]

## F. Streaming y persistencia (12)

- [ ] Diseñar carga de chunks por radio (3-4, configurable) [M]
- [ ] Diseñar prioridad de carga: frente de visión [S]
- [ ] Diseñar descarga fuera de radio ×1.5 con flush [S]
- [ ] Diseñar diffs por chunk: tabla (isla, chunk, ediciones) [M]
- [ ] Documentar la compresión de diffs (formato en M59) [S]
- [ ] Documentar generación determinista por seed + re-aplicación de diffs [S]
- [ ] Documentar autosave por eventos acotados [S]
- [ ] Documentar que no se guarda el mundo entero [S]
- [ ] Documentar el stream por isla (archivo/carpeta por isla) [S]
- [ ] Documentar la integración con escenas separadas (M28) [S]
- [ ] Documentar el edge case: generar chunk ya editado (re-aplicar diffs) [S]
- [ ] Documentar el edge case: mundo nuevo vs mundo migrado [S]

## G. Integración con sistemas (12)

- [ ] Definir contrato try_extract/try_place para M13 [S]
- [ ] Definir contrato get_block/set_block_puzzle para M24 [S]
- [ ] Definir eventos world consumidos por NPC (M19/M64) [S]
- [ ] Definir eventos world consumidos por quests (M22) [S]
- [ ] Definir eventos world consumidos por economía (M38) [S]
- [ ] Definir eventos world consumidos por sonido (M43) [S]
- [ ] Definir integración con VoxelWorld en ServiceRegistry (M07) [S]
- [ ] Definir partición world de GameState versionada (M59) [S]
- [ ] Definir la relación con generación (M10): seed determinista [S]
- [ ] Definir la relación con biomas/terreno (M09) [S]
- [ ] Definir la relación con construcción (M17): reglas de apoyo [S]
- [ ] Definir la relación con minería/recursos (M15/M35): drops y vetas [S]

## H. Riesgos y verificación (12)

- [ ] Documentar riesgo: Voxel Tools sin cubrir un caso → capa propia + prototipo [S]
- [ ] Documentar riesgo: draw calls altos → radio + LOD + greedy [S]
- [ ] Documentar riesgo: diffs grandes → compresión y guardado periódico [S]
- [ ] Documentar riesgo: bloques puzzle con estado → entidad vinculada [S]
- [ ] Documentar riesgo: migración de formato de mundo → versionado partición [S]
- [ ] Documentar decisión: voxel propio vs Voxel Tools (elegido tools) [S]
- [ ] Verificar trazabilidad de los 39 puntos del plan maestro [S]
- [ ] Verificar coherencia con los requisitos 60 FPS de M04 [S]
- [ ] Verificar coherencia con el contrato de integración de M07 [S]
- [ ] Actualizar CHECKLIST-GLOBAL con el estado de M08 [S]
- [ ] Actualizar DOCUMENTACION/README.md con el componente 08 [S]
- [ ] Generar log de finalización y actualizar ULTIMO_NUMERO [S]

---

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 105 ítems · Completados: 105 · Pendientes: 0 · No resueltos: 0.
**Nota:** la validación física (greedy por tipo, radio de carga, medición de remesh) es responsabilidad del hito M1 y de M61; el diseño queda cerrado aquí.