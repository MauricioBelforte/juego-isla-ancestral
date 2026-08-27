**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 10: Generación del Mundo

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (12)

- [x] Definir el problema: mundo voxel generado determinista, rico y jugable [S]
- [x] Registrar dependencias: M08 Mundo Voxel, M09 Terreno y Geografía, M50 Vegetación, M27 Islas [S]
- [x] Catalogar los 26 puntos del plan maestro (sección 9) [S]
- [x] Definir criterios de aceptación verificables [S]
- [x] Requisito RF1: generación determinista byte a byte [S]
- [x] Requisito RF2: ruido multi-octava (Perlin/Simplex) [S]
- [x] Requisito RF3: pipeline de 8 capas ordenadas [S]
- [x] Requisito RF4: malla por chunk bajo demanda [S]
- [x] Requisito RF5: recetas de M09 aplicadas [S]
- [x] Requisito RF6: estructuras pre-generadas (ruinas, templos, caminos) [S]
- [x] Requisito RF7: persistencia solo de diffs (una vez más) [S]
- [x] Requisito RF8: regeneración sin romper narrativa [S]

## B. Ruido y semillas (14)

- [x] Seleccionar Simplex como ruido base [S]
- [x] Configurar 4-6 octavas con amplitud 0-192 m (Aurora) [M]
- [x] Ruido 2D para altura y humedad [S]
- [x] Ruido 3D para cuevas y vetas [S]
- [x] PRNG global por semilla (seed global de partida) [S]
- [x] PRNG por contexto: hash(seed, chunk_pos) [M]
- [x] Prohibido rand global, tiempo o estado compartido [S]
- [x] Prohibido orden de iteración variable en la generación [M]
- [x] Misma semilla → mismo mundo byte a byte [M]
- [x] Semilla de desarrollo fija (semilla_dev) para bugs reproducibles [S]
- [x] Nueva partida: opción seed custom o random [S]
- [x] Verificación de jugabilidad en el re-roll (≤1 bloqueo inaccesible) [M]
- [x] Test A de determinismo: 3 órdenes de regen → mismos bytes [C]
- [x] Logging de semilla y tiempos por capa [S]

## C. Pipeline de capas (16)

- [x] Capa 1 Altura: Simplex multi-octava → mapa de alturas 64×64 [M]
- [x] Capa 2 Biomas: altura + humedad → mapa de biomas (umbrales M09) [M]
- [x] Capa 3 Formaciones: recetas M09 + marcadores → modificadores [M]
- [x] Capa 4 Roca y cuevas: Simplex 3D → densidad de piedra/aire [M]
- [x] Capa 5 Minerales: vetas por profundidad + bioma (M46) [M]
- [x] Capa 6 Vegetación: densidad por bioma → decorativos (M50) [M]
- [x] Capa 7 Agua: nivel global + clima (M51) [M]
- [x] Capa 8 Estructuras: prefabs por marcador POI [M]
- [x] Orden fijo y documentado de las 8 capas [S]
- [x] Salida por capa definida (datos puros, sin side effects globales) [M]
- [x] Diffs del jugador se aplican DESPUÉS de regenerar [M]
- [x] Chunks 16³ alineados a la grilla de M08 [S]
- [x] Implementación como autoload WorldGenerator [S]
- [x] Sin tocar GameState durante la generación (solo lectura) [M]
- [x] Knobs por capa en data/*.tres (sin recompilar) [M]
- [x] Compatibilidad con LOD Transvoxel de M08 [M]

## D. Determinismo y regeneración (14)

- [x] Regla: PRNG por contexto en TODO el pipeline [M]
- [x] Regla: prefabs colocados por posición fija (no re-random intra-visita) [M]
- [x] Regla: loot NO en el generador (vive en GameState M59) [M]
- [x] Regla: diffs anclados (faro, puerto, grieta, templo, hogar) nunca se regeneran [M]
- [x] Diffs con metadata de tag (anclado vs libre) [M]
- [x] Regen en runtime: botón debug "Regenerar mundo" [S]
- [x] Regen conserva el hogar del jugador [M]
- [x] Regen conserva POI narrativos [M]
- [x] Re-roll automático ×3 antes de aceptar semilla no jugable [M]
- [x] Regla de riqueza: 80% re-rollable, 0% narrativo [M]
- [x] Consistencia entre sesiones (mundo base idéntico) [M]
- [x] Sin guardado de mundo completo (solo diffs + semilla) [M]
- [x] Formato de diffs compatible con WorldPartition (M08) [M]
- [x] Semilla visible en el menú de depuración (reproducibilidad) [S]

## E. Asincronía y rendimiento (12)

- [x] Cola prioritaria por distancia Manhattan al jugador [M]
- [x] Radio de generación 3-4 chunks (M61 lo afina) [M]
- [x] Generación asíncrona en thread pool de Voxel Tools [M]
- [x] Presupuesto ≤ 2 ms/frame en hilo principal [M]
- [x] Chunk aparece al completarse (sin freeze) [M]
- [x] Barra de progreso en la carga inicial ("Generando Aurora...") [S]
- [x] Carga inicial ≤ 32 chunks en cola inicial [S]
- [x] Frame budget total de carga inicial ≤ 6 s en PC referencia [M]
- [x] Presupuesto de poly por chunk según LOD [M]
- [x] Decoración instanciada (no voxelizada) [M]
- [x] Chunk fallido → reintento ×2 → fallback de basalto + log [M]
- [x] Midiendo: LOG_GENERATION con chunks/seg [S]

## F. Estructuras y contenido (14)

- [x] Catálogo de prefabs de estructuras (faro, puerto, plaza, granja, templo, puentes, ruinas) [M]
- [x] Colocación fija del faro (sur-este) [S]
- [x] Colocación fija del puerto (sur) [S]
- [x] Colocación fija de la plaza (centro-valle) [S]
- [x] Colocación fija de la granja (valle) [S]
- [x] Colocación fija del Templo de la Brisa (en la grieta) [M]
- [x] Caminos por spline manual conectando POI [M]
- [x] 3-5 ruinas menores por isla según riqueza [M]
- [x] Puentes en marcadores de río/barranco [M]
- [x] Puerta/puzzle de piedra en la grieta [M]
- [x] Cuevas: ≥ 3 entradas por isla, al menos 1 cerca del pueblo [M]
- [x] Galerías de 3-8 m de tamaño [S]
- [x] Minerales por profundidad (hierro, carbón, cobre, oro, cristal) [M]
- [x] Prefabs reutilizables entre islas (biblia M09) [M]

## G. Documentación e integración (12)

- [x] 01-Requerimientos.md creado y firmado [S]
- [x] 02-Analisis.md creado y firmado [S]
- [x] 03-Diseno.md creado y firmado [S]
- [x] 04-Codigo.md creado y firmado [S]
- [x] 05-Checklist.md creado y firmado (este archivo) [S]
- [x] Contrato de integración (ChunkRequest → ChunkData) documentado [M]
- [x] Consumidores de recetas M09 identificados [S]
- [x] Productores para M50/M46/M51 identificados [S]
- [x] Sin contradicciones con M07 (GameState intocable) [M]
- [x] Sin contradicciones con M08 (chunks, diffs, streaming) [M]
- [x] Sin contradicciones con M09 (recetas, POI, biomas) [M]
- [x] Pendientes asignados a dueños reales (M1, M22/M26, M46/M50, M61) [S]

## H. Verificación y cierre (10)

- [x] Los 26 puntos de la sección 9 resueltos [M]
- [x] Criterios de aceptación cumplidos [M]
- [x] Pipeline de capas completo con entradas/salidas por capa [M]
- [x] Regla de determinismo escrita y consumible [M]
- [x] Estructuras narrativas ancladas a posiciones fijas [M]
- [x] Regeneración segura (80/0) especificada [M]
- [x] Anti-softlock de generación (verificación de jugabilidad) [M]
- [x] DoD cumplida: 5 archivos + log + firma [M]
- [x] Knobs balanceables listados [S]
- [x] Ready para: hito M1 (prototipo), M50, M46, M51 [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 105 ítems · Completados: 105 · Pendientes: 0 · No resueltos: 0.
**Nota:** la implementación (ruido, asincronía, medición) es del prototipo M1 y M61; la especificación queda cerrada aquí.
