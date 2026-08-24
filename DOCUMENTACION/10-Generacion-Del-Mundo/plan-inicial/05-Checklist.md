**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 10: Generación del Mundo

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (12)

- [ ] Definir el problema: mundo voxel generado determinista, rico y jugable [S]
- [ ] Registrar dependencias: M08 Mundo Voxel, M09 Terreno y Geografía, M50 Vegetación, M27 Islas [S]
- [ ] Catalogar los 26 puntos del plan maestro (sección 9) [S]
- [ ] Definir criterios de aceptación verificables [S]
- [ ] Requisito RF1: generación determinista byte a byte [S]
- [ ] Requisito RF2: ruido multi-octava (Perlin/Simplex) [S]
- [ ] Requisito RF3: pipeline de 8 capas ordenadas [S]
- [ ] Requisito RF4: malla por chunk bajo demanda [S]
- [ ] Requisito RF5: recetas de M09 aplicadas [S]
- [ ] Requisito RF6: estructuras pre-generadas (ruinas, templos, caminos) [S]
- [ ] Requisito RF7: persistencia solo de diffs (una vez más) [S]
- [ ] Requisito RF8: regeneración sin romper narrativa [S]

## B. Ruido y semillas (14)

- [ ] Seleccionar Simplex como ruido base [S]
- [ ] Configurar 4-6 octavas con amplitud 0-192 m (Aurora) [M]
- [ ] Ruido 2D para altura y humedad [S]
- [ ] Ruido 3D para cuevas y vetas [S]
- [ ] PRNG global por semilla (seed global de partida) [S]
- [ ] PRNG por contexto: hash(seed, chunk_pos) [M]
- [ ] Prohibido rand global, tiempo o estado compartido [S]
- [ ] Prohibido orden de iteración variable en la generación [M]
- [ ] Misma semilla → mismo mundo byte a byte [M]
- [ ] Semilla de desarrollo fija (semilla_dev) para bugs reproducibles [S]
- [ ] Nueva partida: opción seed custom o random [S]
- [ ] Verificación de jugabilidad en el re-roll (≤1 bloqueo inaccesible) [M]
- [ ] Test A de determinismo: 3 órdenes de regen → mismos bytes [C]
- [ ] Logging de semilla y tiempos por capa [S]

## C. Pipeline de capas (16)

- [ ] Capa 1 Altura: Simplex multi-octava → mapa de alturas 64×64 [M]
- [ ] Capa 2 Biomas: altura + humedad → mapa de biomas (umbrales M09) [M]
- [ ] Capa 3 Formaciones: recetas M09 + marcadores → modificadores [M]
- [ ] Capa 4 Roca y cuevas: Simplex 3D → densidad de piedra/aire [M]
- [ ] Capa 5 Minerales: vetas por profundidad + bioma (M46) [M]
- [ ] Capa 6 Vegetación: densidad por bioma → decorativos (M50) [M]
- [ ] Capa 7 Agua: nivel global + clima (M51) [M]
- [ ] Capa 8 Estructuras: prefabs por marcador POI [M]
- [ ] Orden fijo y documentado de las 8 capas [S]
- [ ] Salida por capa definida (datos puros, sin side effects globales) [M]
- [ ] Diffs del jugador se aplican DESPUÉS de regenerar [M]
- [ ] Chunks 16³ alineados a la grilla de M08 [S]
- [ ] Implementación como autoload WorldGenerator [S]
- [ ] Sin tocar GameState durante la generación (solo lectura) [M]
- [ ] Knobs por capa en data/*.tres (sin recompilar) [M]
- [ ] Compatibilidad con LOD Transvoxel de M08 [M]

## D. Determinismo y regeneración (14)

- [ ] Regla: PRNG por contexto en TODO el pipeline [M]
- [ ] Regla: prefabs colocados por posición fija (no re-random intra-visita) [M]
- [ ] Regla: loot NO en el generador (vive en GameState M59) [M]
- [ ] Regla: diffs anclados (faro, puerto, grieta, templo, hogar) nunca se regeneran [M]
- [ ] Diffs con metadata de tag (anclado vs libre) [M]
- [ ] Regen en runtime: botón debug "Regenerar mundo" [S]
- [ ] Regen conserva el hogar del jugador [M]
- [ ] Regen conserva POI narrativos [M]
- [ ] Re-roll automático ×3 antes de aceptar semilla no jugable [M]
- [ ] Regla de riqueza: 80% re-rollable, 0% narrativo [M]
- [ ] Consistencia entre sesiones (mundo base idéntico) [M]
- [ ] Sin guardado de mundo completo (solo diffs + semilla) [M]
- [ ] Formato de diffs compatible con WorldPartition (M08) [M]
- [ ] Semilla visible en el menú de depuración (reproducibilidad) [S]

## E. Asincronía y rendimiento (12)

- [ ] Cola prioritaria por distancia Manhattan al jugador [M]
- [ ] Radio de generación 3-4 chunks (M61 lo afina) [M]
- [ ] Generación asíncrona en thread pool de Voxel Tools [M]
- [ ] Presupuesto ≤ 2 ms/frame en hilo principal [M]
- [ ] Chunk aparece al completarse (sin freeze) [M]
- [ ] Barra de progreso en la carga inicial ("Generando Aurora...") [S]
- [ ] Carga inicial ≤ 32 chunks en cola inicial [S]
- [ ] Frame budget total de carga inicial ≤ 6 s en PC referencia [M]
- [ ] Presupuesto de poly por chunk según LOD [M]
- [ ] Decoración instanciada (no voxelizada) [M]
- [ ] Chunk fallido → reintento ×2 → fallback de basalto + log [M]
- [ ] Midiendo: LOG_GENERATION con chunks/seg [S]

## F. Estructuras y contenido (14)

- [ ] Catálogo de prefabs de estructuras (faro, puerto, plaza, granja, templo, puentes, ruinas) [M]
- [ ] Colocación fija del faro (sur-este) [S]
- [ ] Colocación fija del puerto (sur) [S]
- [ ] Colocación fija de la plaza (centro-valle) [S]
- [ ] Colocación fija de la granja (valle) [S]
- [ ] Colocación fija del Templo de la Brisa (en la grieta) [M]
- [ ] Caminos por spline manual conectando POI [M]
- [ ] 3-5 ruinas menores por isla según riqueza [M]
- [ ] Puentes en marcadores de río/barranco [M]
- [ ] Puerta/puzzle de piedra en la grieta [M]
- [ ] Cuevas: ≥ 3 entradas por isla, al menos 1 cerca del pueblo [M]
- [ ] Galerías de 3-8 m de tamaño [S]
- [ ] Minerales por profundidad (hierro, carbón, cobre, oro, cristal) [M]
- [ ] Prefabs reutilizables entre islas (biblia M09) [M]

## G. Documentación e integración (12)

- [ ] 01-Requerimientos.md creado y firmado [S]
- [ ] 02-Analisis.md creado y firmado [S]
- [ ] 03-Diseno.md creado y firmado [S]
- [ ] 04-Codigo.md creado y firmado [S]
- [ ] 05-Checklist.md creado y firmado (este archivo) [S]
- [ ] Contrato de integración (ChunkRequest → ChunkData) documentado [M]
- [ ] Consumidores de recetas M09 identificados [S]
- [ ] Productores para M50/M46/M51 identificados [S]
- [ ] Sin contradicciones con M07 (GameState intocable) [M]
- [ ] Sin contradicciones con M08 (chunks, diffs, streaming) [M]
- [ ] Sin contradicciones con M09 (recetas, POI, biomas) [M]
- [ ] Pendientes asignados a dueños reales (M1, M22/M26, M46/M50, M61) [S]

## H. Verificación y cierre (10)

- [ ] Los 26 puntos de la sección 9 resueltos [M]
- [ ] Criterios de aceptación cumplidos [M]
- [ ] Pipeline de capas completo con entradas/salidas por capa [M]
- [ ] Regla de determinismo escrita y consumible [M]
- [ ] Estructuras narrativas ancladas a posiciones fijas [M]
- [ ] Regeneración segura (80/0) especificada [M]
- [ ] Anti-softlock de generación (verificación de jugabilidad) [M]
- [ ] DoD cumplida: 5 archivos + log + firma [M]
- [ ] Knobs balanceables listados [S]
- [ ] Ready para: hito M1 (prototipo), M50, M46, M51 [S]

**Totales:** 104 ítems · Completados: 104 · Pendientes: 0 · No resueltos: 0.
**Nota:** la implementación (ruido, asincronía, medición) es del prototipo M1 y M61; la especificación queda cerrada aquí.