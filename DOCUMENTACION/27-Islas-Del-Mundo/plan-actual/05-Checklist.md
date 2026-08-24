**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 27: Islas del Mundo

## A. Requisitos y alcance del módulo

- [ ] Definir el problema: archipiélago con isla principal Aurora + 12 satélites con identidad propia [M]
- [ ] Catalogar los 24 puntos de la sección 26 del plan maestro (isla principal a relevancia narrativa) [S]
- [ ] Registrar dependencias: M28, M29; relaciones M08, M09, M10, M51, M61, M63, M54, M59 [S]
- [ ] Resolver cada punto de la sección 26 (diseño, distancia, navegación, clima, flora, fauna, recursos, NPC, arquitectura, música, puzzles, recompensa, narrativa) [C]
- [ ] Declarar que el módulo es delegable para implementación tras M08/M10 base y presupuestos M61 [S]
- [ ] Mantener el alcance separado de M28 (barco/viaje), M51 (agua), M63 (streaming general) [S]
- [ ] Definir criterios de aceptación verificables (catálogo 13 islas, anclas válidas, viaje ida y vuelta, contenido exclusivo) [S]
- [ ] Asegurar coherencia cozy: sin contenido crítico exclusivo e inaccesible, regreso siempre gratis [S]
- [ ] Verificar que el diseño no contradice los principios innegociables (M152 cozy, sin FOMO) [S]
- [ ] Documentar el módulo en los 5 archivos obligatorios (plan-inicial y plan-actual) [M]

## B. IslandDefinition — datos por isla

- [ ] Create class IslandDefinition como Resource con @export de metadatos [S]
- [ ] Campo id (StringName) único por isla [S]
- [ ] Campo nombre_display localizable (M87) [S]
- [ ] Campo descripcion/lore para el diario (M55) [S]
- [ ] Campo bioma_base (id M09) y biomas_mezcla (Array con proporciones) [C]
- [ ] Campos de losa: radio, altura_min, altura_max, playa_ancho [M]
- [ ] Campo ancla (Vector3i centro) poblado por M10 [M]
- [ ] Campo semilla_isla derivada de la semilla de partida (PRNG M10) [M]
- [ ] Campo clima_tendencia (id M32) por isla [S]
- [ ] Campo musica_theme (id M41) por isla [S]
- [ ] Campos de contenido exclusivo: recursos, flora, fauna, puzzles, npc_residentes [C]
- [ ] Campo punto_llegada y punto_partida locales (muelle/embarque) [M]
- [ ] Campo anillo (enum NUCLEO/CERCANO/MEDIO/LEJANO) que controla distancia y requisitos [M]
- [ ] Campo es_secreta (oculta en mapa M54 hasta descubrir) [S]
- [ ] Campo es_flotante para islas del cielo (sin océano debajo) [S]
- [ ] Campo desbloqueo (Callable) evaluado por M22/M28 [C]
- [ ] Método bounds_locales() -> Rect2i para streaming M63 [S]
- [ ] Método centro_mundo() -> Vector3 para POI y cámara [S]
- [ ] Método validar() que devuelve errores de definición (radios, anclas, ids) [M]
- [ ] Archivo .tres por satélite: 12 definiciones editables (coral, verde, cenizas, cielo, nieve, desierto, volcanica, submarina, flotante, misteriosa, pequena, secreta) [C]

## C. IslandRegistry — catálogo del archipiélago

- [ ] Create autoload IslandRegistry como servicio tipo Service Locator (M07) [S]
- [ ] init(anclas: Dictionary) que construye el catálogo desde M10 [M]
- [ ] get_isla(id) -> IslandDefinition con manejo de id inexistente (null + log WARN) [S]
- [ ] todas_las_islas() -> Array ordenada determinista por id (nunca por orden de carga) [M]
- [ ] isla_principal() -> Aurora (id constante `aurora`) [S]
- [ ] posicion_ancla(id) -> Vector3i con cache de M10 [M]
- [ ] vecinas(id, corte_anillo) -> Array de islas dentro de radio de streaming [C]
- [ ] coordenadas_por_isla(id) -> Rect2i (bounds en voxels para M63) [S]
- [ ] validar_anclas() -> Array[String] de errores [M]
- [ ] Señal archipielago_cargado emitida al terminar init [S]
- [ ] Registro sin duplicados: ids únicos garantizados al cargar .tres [S]
- [ ] Carga de .tres diferida (no bloqueante) al iniciar partida [M]
- [ ] Estado "descubierta/visitada" consultable (delega a M59 GameState) [M]
- [ ] Orden de catálogo estable entre ejecuciones (misma semilla) [S]
- [ ] Fallback: si falta un .tres, se loguea ERROR y Aurora siempre carga [M]

## D. Anclas y generación (M10)

- [ ] Solicitar a M10 la capa de anclas que posiciona cada isla [C]
- [ ] Las anclas se derivan del PRNG de contexto 2 (mismo mundo, misma semilla) [M]
- [ ] Validar distancia mínima entre centros: radio_a + radio_b + MARGEN_MAR (64 m) [M]
- [ ] Validar que ninguna isla invade el templo subterráneo (M26) ni ruinas (M25) [C]
- [ ] Validar que Aurora está en el centro del mundo/archipiélago [S]
- [ ] Re-roll de ancla con la misma semilla ante solapamiento (máx 8 intentos) [C]
- [ ] Log WARN con detalle de cada ancla re-rollada [S]
- [ ] Log ERROR si tras 8 intentos no hay ancla válida (fallback: echar isla al anillo siguiente) [M]
- [ ] Regeneración 80/0 de M10 produce anclas consistentes (test de regen) [C]
- [ ] Estructuras ancladas de M10 respetan las islas (no generan dentro del mar) [M]
- [ ] Semilla dev para tests deterministas de anclas [S]
- [ ] Los NPC (M19) y POI de M09 se generan sobre el terreno de la isla ya anclado [M]

## E. IslandLoading — carga, descarga y streaming (M63)

- [ ] Create servicio IslandLoading separado del generador (no tocar M10) [S]
- [ ] cargar_isla(id, preferencia) -> bool con estados de progreso [C]
- [ ] Enum IslandPref { PRELOAD, DESCARGA } [S]
- [ ] Pesos de carga: losa 60%, props 25%, audio 10%, navmesh 5% [M]
- [ ] Emitir isla_cargando(id, progreso, etapa) en cada etapa [S]
- [ ] Emitir isla_cargada(id) al 100% [S]
- [ ] Emitir isla_descargada(id) al liberar [S]
- [ ] descargar_isla(id) nunca descarga Aurora (isla principal) [S]
- [ ] descargar_isla(id) nunca descarga la isla actual del jugador [S]
- [ ] cacheado(id) -> bool para evitar recargas [S]
- [ ] isla_actual() -> StringName rastreada por el servicio [S]
- [ ] punto_de_llegada(id) -> Vector3 world-space del muelle [M]
- [ ] punto_de_partida(id) -> Vector3 world-space del embarque [M]
- [ ] Precarga de isla vecina al cruzar el borde de chunks (radio + RADIO_PRECARGA) [C]
- [ ] Descarga LRU bajo presión de memoria (M62) respetando candidatas [C]
- [ ] Carga asíncrona sin congelar el frame (threads de Voxel Tools + M63) [C]
- [ ] Progreso real por pesos reportado a la pantalla de viaje (M28) [M]
- [ ] Si la carga falla (sin disco/red), log ERROR y mensaje cozy al jugador [M]
- [ ] El jugador nunca queda atrapado: fallback = seguir en la isla actual [M]

## F. IslandProps — contenido exclusivo por isla

- [ ] Create servicio IslandProps con registrar_spawner(tipo, callable) [S]
- [ ] materializar(isla, zona) que invoca spawners registrados [M]
- [ ] Spawn de flora endémica (contrato M50) solo en bioma de la isla [C]
- [ ] Spawn de fauna endémica (contrato M36) dentro de los bounds de la isla [C]
- [ ] Spawn de recursos exclusivos (contrato M15) en zonas deterministas [M]
- [ ] Spawn de POI (muelle, plaza, faro, templo, mirador) consumidos por M64 [M]
- [ ] limpiar(id) libera props al descargar la isla [M]
- [ ] Los props no se generan en el mar (zona acuática M51) [S]
- [ ] Determinismo: misma semilla genera los mismos props (PRNG por isla) [M]
- [ ] Los props de islas lejanas no se spawnan hasta que la isla se carga [S]

## G. Integración con M28 — Viajes en barco

- [ ] Contrato: M28 consulta posicion_ancla(destino) para trazar la ruta [M]
- [ ] Embarque: jugador en punto_partida → M28 inicia travesía [M]
- [ ] Pantalla de viaje muestra progreso real de IslandLoading (M63) [M]
- [ ] Desembarco posiciona al jugador en punto_de_llegada(destino) [M]
- [ ] Al desembarcar se marca la isla como visitada (M59/M54) [S]
- [ ] Regreso a Aurora gratis desde cualquier muelle (anti-frustración) [S]
- [ ] Viajes estacionales/de expedición consultan calendario M29 [C]
- [ ] Viajes nocturnos y estacionales respetan clima (M32) y hora (M31) [M]
- [ ] Boleto/requisitos (M28) no bloquean el regreso a Aurora [S]
- [ ] NPC viajeros (M28) respetan la isla cargada (spawn solo si su isla activa) [M]
- [ ] El barco no atraca en islas sin desbloqueo (anillo LEJANO) [M]
- [ ] Si la isla destino ya está cacheada, la travesía se salta la carga (inmediato) [M]

## H. Integración con M51 — Agua y océano

- [ ] Nivel de mar global definido (OCEANO_ALTURA) en el mundo voxel [M]
- [ ] El agua entre islas es navegable por barco (no bloqueo invisible) [C]
- [ ] Profundidades por isla: arrecife poco profundo de Coral, fosa de Submarina [M]
- [ ] Espuma de costas (M51) presente en playas de cada isla [S]
- [ ] Corrientes de M51 no llevan el barco fuera de los bounds del archipiélago [C]
- [ ] El agua no se congela ni inunda dentro de las islas salvo eventos M32 [M]
- [ ] La isla Flotante y las del Cielo no tienen océano debajo (es_flotante) [S]
- [ ] Los sonidos del mar (M42) cambian según distancia a la isla más cercana [M]
- [ ] El agua interactúa con puzzles de islas (M23/M24) solo isla cargada [M]
- [ ] Rendimiento del océano: shader de agua (M51) presupuestado por M61 [C]

## I. Integración con M09 y M32 — biomas y clima

- [ ] Cada isla declara bioma_base y mezcla contra el catálogo de 13 biomas de M09 [M]
- [ ] Transiciones entre biomas dentro de una isla suaves (falloff M09) [M]
- [ ] Playas/acantilados por recetas de formaciones de M09 [M]
- [ ] Clima por isla consultado por M32 (lluvia en Verde, nieve en Nieve) [M]
- [ ] La música cambia al desembarcar (M41 theme de la isla) [S]
- [ ] La fauna (M36) y vegetación (M50) respetan el bioma al spawnar [M]

## J. Persistencia y mapa

- [ ] Guardar islas_descubiertas (PackedStringArray) en GameState M59 [M]
- [ ] Guardar islas_visitadas (PackedStringArray) en GameState M59 [M]
- [ ] Al cargar partida, el registro restaura descubrimiento/visita [M]
- [ ] El mapa (M54) marca islas descubiertas y visitadas [S]
- [ ] Islas secretas ocultas en el mapa hasta descubrirlas [S]
- [ ] Reintentar regen 80/0 no pierde progreso de islas (persistencia aparte) [C]

## K. Edge cases

- [ ] Carga de isla vecina mientras el jugador navega el borde (sin congelar) [C]
- [ ] Viajar a una isla mientras otra se está descargando (cola de operaciones) [C]
- [ ] Ancla faltante en M10 para una isla definida → ERROR + fallback [M]
- [ ] Anclas inconsistentes entre ejecuciones (misma semilla debe dar lo mismo) [M]
- [ ] Jugador en el mar sin barco (M28 no iniciado) → salvavidas/limite de zona [M]
- [ ] Isla secreta descubierta por pista pero su ancla aún no generada → espera coherente [C]
- [ ] Dos islas con el mismo id en .tres → error de registro y primera gana [S]
- [ ] Radio negativo o altura invertida en definición → validar() captura [S]
- [ ] Desembarco sobre agua si el muelle se generó mal → punto seguro por software [M]
- [ ] Viaje cancelado a mitad de carga → cancelación limpia de task [M]
- [ ] Guardado durante una carga → el guardado espera a terminar la operación [C]
- [ ] M54 consulta isla secreta no descubierta → inaccesible (sin leak de datos) [S]
- [ ] El jugador suelta el barco en el océano abierto → respawn cozy en isla más cercana [M]
- [ ] Streaming falla por memoria baja → descarga forzada sin perder estado de partida [C]

## L. Optimización y rendimiento (M61/M62)

- [ ] Máximo 2 islas completas en memoria a la vez [C]
- [ ] Aurora siempre cargada pero con streaming fino de chunks lejanos [M]
- [ ] Metadatos (definiciones) livianos: sin cargar voxel de islas lejanas [S]
- [ ] LRU con tope de memoria configurado por M62 [C]
- [ ] Sin allocs grandes en el hot path de búsqueda de vecinas [M]
- [ ] Búsquedas de vecinas con índice espacial (grid por anillo) [M]
- [ ] Carga de props por etapas (sin picos) [M]
- [ ] Precalentamiento en el menú (M63): cachea Aurora al boot [M]
- [ ] Telemetría de carga (M105): tiempos por isla, memoria, errores [C]
- [ ] Profiling: la carga de la isla más grande cabe en frame budget M61 [C]
- [ ] La precarga de vecinas no inicia si la GPU está al límite (M61) [C]
- [ ] Los .tres usan PackedStringArray (serialización compacta M60) [S]

## M. Documentación y logs

- [ ] 01-Requerimientos.md completo (problema, RF, NFR, criterios de aceptación, alcance) [M]
- [ ] 02-Analisis.md: alternativas A/B/C/D evaluadas y justificadas [M]
- [ ] 03-Diseno.md: arquitectura, 4 flujos en texto, contratos API, integraciones [C]
- [ ] 04-Codigo.md: rutas res://, firmas clave, pesos de carga, subs, logs [M]
- [ ] 05-Checklist.md con 100+ ítems verificables [M]
- [ ] Logs en Logs/ tras implementación (formato estándar, sección 6 de AGENTS.md) [S]

## N. Polish y UX cozy

- [ ] Mensaje al descubrir una isla (toast/M54) sin romper la inmersión [S]
- [ ] El mapa muestra nombre de la isla al pasar el cursor (M54) [S]
- [ ] Transición de embarque suave (M28) con música de travesía [M]
- [ ] Ningún contenido exclusivo se pierde: accesible luego por otras vías (M73/feria) [M]
- [ ] El regreso siempre disponible: sin estados bloqueados [S]
- [ ] Indicador de "isla nueva por descubrir" sutil en el mapa (sin FOMO) [S]
- [ ] Los NPC residentes comentan sus islas (M21) al volver (coherente con M64) [M]
- [ ] Test manual de recorrido completo: Aurora → Coral → Aurora (idioma y UX) [C]

## O. Testing (M112/M114)

- [ ] Test unitario: validar_anclas detecta solapamiento coral/cenizas [M]
- [ ] Test unitario: catálogo ordenado y sin duplicados [S]
- [ ] Test unitario: bounds y centro de isla correctos [S]
- [ ] Test unitario: registry tolera .tres faltante (error + Aurora) [M]
- [ ] Test unitario: semilla_id determinista por isla [S]
- [ ] Test integración: viaje Aurora→Nieve y regreso sin pérdida de estado [C]
- [ ] Test integración: carga de vecina al navegar el borde sin congelar [C]
- [ ] Test integración: regen 80/0 conserva anclas válidas [C]
- [ ] Test integración: guardar/cargar partida restaura descubrimiento [M]
- [ ] Test de estrés: 2 islas cargadas + 1 precargando bajo presupuesto M61 [C]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
