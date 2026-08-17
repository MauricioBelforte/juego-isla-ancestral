**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 27: Islas del Mundo

## A. Requisitos y alcance del módulo

- [x] Definir el problema: archipiélago con isla principal Aurora + 12 satélites con identidad propia [M]
- [x] Catalogar los 24 puntos de la sección 26 del plan maestro (isla principal a relevancia narrativa) [S]
- [x] Registrar dependencias: M28, M29; relaciones M08, M09, M10, M51, M61, M63, M54, M59 [S]
- [x] Resolver cada punto de la sección 26 (diseño, distancia, navegación, clima, flora, fauna, recursos, NPC, arquitectura, música, puzzles, recompensa, narrativa) [C]
- [x] Declarar que el módulo es delegable para implementación tras M08/M10 base y presupuestos M61 [S]
- [x] Mantener el alcance separado de M28 (barco/viaje), M51 (agua), M63 (streaming general) [S]
- [x] Definir criterios de aceptación verificables (catálogo 13 islas, anclas válidas, viaje ida y vuelta, contenido exclusivo) [S]
- [x] Asegurar coherencia cozy: sin contenido crítico exclusivo e inaccesible, regreso siempre gratis [S]
- [x] Verificar que el diseño no contradice los principios innegociables (M152 cozy, sin FOMO) [S]
- [x] Documentar el módulo en los 5 archivos obligatorios (plan-inicial y plan-actual) [M]

## B. IslandDefinition — datos por isla

- [x] Create class IslandDefinition como Resource con @export de metadatos [S]
- [x] Campo id (StringName) único por isla [S]
- [x] Campo nombre_display localizable (M87) [S]
- [x] Campo descripcion/lore para el diario (M55) [S]
- [x] Campo bioma_base (id M09) y biomas_mezcla (Array con proporciones) [C]
- [x] Campos de losa: radio, altura_min, altura_max, playa_ancho [M]
- [x] Campo ancla (Vector3i centro) poblado por M10 [M]
- [x] Campo semilla_isla derivada de la semilla de partida (PRNG M10) [M]
- [x] Campo clima_tendencia (id M32) por isla [S]
- [x] Campo musica_theme (id M41) por isla [S]
- [x] Campos de contenido exclusivo: recursos, flora, fauna, puzzles, npc_residentes [C]
- [x] Campo punto_llegada y punto_partida locales (muelle/embarque) [M]
- [x] Campo anillo (enum NUCLEO/CERCANO/MEDIO/LEJANO) que controla distancia y requisitos [M]
- [x] Campo es_secreta (oculta en mapa M54 hasta descubrir) [S]
- [x] Campo es_flotante para islas del cielo (sin océano debajo) [S]
- [x] Campo desbloqueo (Callable) evaluado por M22/M28 [C]
- [x] Método bounds_locales() -> Rect2i para streaming M63 [S]
- [x] Método centro_mundo() -> Vector3 para POI y cámara [S]
- [x] Método validar() que devuelve errores de definición (radios, anclas, ids) [M]
- [x] Archivo .tres por satélite: 12 definiciones editables (coral, verde, cenizas, cielo, nieve, desierto, volcanica, submarina, flotante, misteriosa, pequena, secreta) [C]

## C. IslandRegistry — catálogo del archipiélago

- [x] Create autoload IslandRegistry como servicio tipo Service Locator (M07) [S]
- [x] init(anclas: Dictionary) que construye el catálogo desde M10 [M]
- [x] get_isla(id) -> IslandDefinition con manejo de id inexistente (null + log WARN) [S]
- [x] todas_las_islas() -> Array ordenada determinista por id (nunca por orden de carga) [M]
- [x] isla_principal() -> Aurora (id constante `aurora`) [S]
- [x] posicion_ancla(id) -> Vector3i con cache de M10 [M]
- [x] vecinas(id, corte_anillo) -> Array de islas dentro de radio de streaming [C]
- [x] coordenadas_por_isla(id) -> Rect2i (bounds en voxels para M63) [S]
- [x] validar_anclas() -> Array[String] de errores [M]
- [x] Señal archipielago_cargado emitida al terminar init [S]
- [x] Registro sin duplicados: ids únicos garantizados al cargar .tres [S]
- [x] Carga de .tres diferida (no bloqueante) al iniciar partida [M]
- [x] Estado "descubierta/visitada" consultable (delega a M59 GameState) [M]
- [x] Orden de catálogo estable entre ejecuciones (misma semilla) [S]
- [x] Fallback: si falta un .tres, se loguea ERROR y Aurora siempre carga [M]

## D. Anclas y generación (M10)

- [x] Solicitar a M10 la capa de anclas que posiciona cada isla [C]
- [x] Las anclas se derivan del PRNG de contexto 2 (mismo mundo, misma semilla) [M]
- [x] Validar distancia mínima entre centros: radio_a + radio_b + MARGEN_MAR (64 m) [M]
- [x] Validar que ninguna isla invade el templo subterráneo (M26) ni ruinas (M25) [C]
- [x] Validar que Aurora está en el centro del mundo/archipiélago [S]
- [x] Re-roll de ancla con la misma semilla ante solapamiento (máx 8 intentos) [C]
- [x] Log WARN con detalle de cada ancla re-rollada [S]
- [x] Log ERROR si tras 8 intentos no hay ancla válida (fallback: echar isla al anillo siguiente) [M]
- [x] Regeneración 80/0 de M10 produce anclas consistentes (test de regen) [C]
- [x] Estructuras ancladas de M10 respetan las islas (no generan dentro del mar) [M]
- [x] Semilla dev para tests deterministas de anclas [S]
- [x] Los NPC (M19) y POI de M09 se generan sobre el terreno de la isla ya anclado [M]

## E. IslandLoading — carga, descarga y streaming (M63)

- [x] Create servicio IslandLoading separado del generador (no tocar M10) [S]
- [x] cargar_isla(id, preferencia) -> bool con estados de progreso [C]
- [x] Enum IslandPref { PRELOAD, DESCARGA } [S]
- [x] Pesos de carga: losa 60%, props 25%, audio 10%, navmesh 5% [M]
- [x] Emitir isla_cargando(id, progreso, etapa) en cada etapa [S]
- [x] Emitir isla_cargada(id) al 100% [S]
- [x] Emitir isla_descargada(id) al liberar [S]
- [x] descargar_isla(id) nunca descarga Aurora (isla principal) [S]
- [x] descargar_isla(id) nunca descarga la isla actual del jugador [S]
- [x] cacheado(id) -> bool para evitar recargas [S]
- [x] isla_actual() -> StringName rastreada por el servicio [S]
- [x] punto_de_llegada(id) -> Vector3 world-space del muelle [M]
- [x] punto_de_partida(id) -> Vector3 world-space del embarque [M]
- [x] Precarga de isla vecina al cruzar el borde de chunks (radio + RADIO_PRECARGA) [C]
- [x] Descarga LRU bajo presión de memoria (M62) respetando candidatas [C]
- [x] Carga asíncrona sin congelar el frame (threads de Voxel Tools + M63) [C]
- [x] Progreso real por pesos reportado a la pantalla de viaje (M28) [M]
- [x] Si la carga falla (sin disco/red), log ERROR y mensaje cozy al jugador [M]
- [x] El jugador nunca queda atrapado: fallback = seguir en la isla actual [M]

## F. IslandProps — contenido exclusivo por isla

- [x] Create servicio IslandProps con registrar_spawner(tipo, callable) [S]
- [x] materializar(isla, zona) que invoca spawners registrados [M]
- [x] Spawn de flora endémica (contrato M50) solo en bioma de la isla [C]
- [x] Spawn de fauna endémica (contrato M36) dentro de los bounds de la isla [C]
- [x] Spawn de recursos exclusivos (contrato M15) en zonas deterministas [M]
- [x] Spawn de POI (muelle, plaza, faro, templo, mirador) consumidos por M64 [M]
- [x] limpiar(id) libera props al descargar la isla [M]
- [x] Los props no se generan en el mar (zona acuática M51) [S]
- [x] Determinismo: misma semilla genera los mismos props (PRNG por isla) [M]
- [x] Los props de islas lejanas no se spawnan hasta que la isla se carga [S]

## G. Integración con M28 — Viajes en barco

- [x] Contrato: M28 consulta posicion_ancla(destino) para trazar la ruta [M]
- [x] Embarque: jugador en punto_partida → M28 inicia travesía [M]
- [x] Pantalla de viaje muestra progreso real de IslandLoading (M63) [M]
- [x] Desembarco posiciona al jugador en punto_de_llegada(destino) [M]
- [x] Al desembarcar se marca la isla como visitada (M59/M54) [S]
- [x] Regreso a Aurora gratis desde cualquier muelle (anti-frustración) [S]
- [x] Viajes estacionales/de expedición consultan calendario M29 [C]
- [x] Viajes nocturnos y estacionales respetan clima (M32) y hora (M31) [M]
- [x] Boleto/requisitos (M28) no bloquean el regreso a Aurora [S]
- [x] NPC viajeros (M28) respetan la isla cargada (spawn solo si su isla activa) [M]
- [x] El barco no atraca en islas sin desbloqueo (anillo LEJANO) [M]
- [x] Si la isla destino ya está cacheada, la travesía se salta la carga (inmediato) [M]

## H. Integración con M51 — Agua y océano

- [x] Nivel de mar global definido (OCEANO_ALTURA) en el mundo voxel [M]
- [x] El agua entre islas es navegable por barco (no bloqueo invisible) [C]
- [x] Profundidades por isla: arrecife poco profundo de Coral, fosa de Submarina [M]
- [x] Espuma de costas (M51) presente en playas de cada isla [S]
- [x] Corrientes de M51 no llevan el barco fuera de los bounds del archipiélago [C]
- [x] El agua no se congela ni inunda dentro de las islas salvo eventos M32 [M]
- [x] La isla Flotante y las del Cielo no tienen océano debajo (es_flotante) [S]
- [x] Los sonidos del mar (M42) cambian según distancia a la isla más cercana [M]
- [x] El agua interactúa con puzzles de islas (M23/M24) solo isla cargada [M]
- [x] Rendimiento del océano: shader de agua (M51) presupuestado por M61 [C]

## I. Integración con M09 y M32 — biomas y clima

- [x] Cada isla declara bioma_base y mezcla contra el catálogo de 13 biomas de M09 [M]
- [x] Transiciones entre biomas dentro de una isla suaves (falloff M09) [M]
- [x] Playas/acantilados por recetas de formaciones de M09 [M]
- [x] Clima por isla consultado por M32 (lluvia en Verde, nieve en Nieve) [M]
- [x] La música cambia al desembarcar (M41 theme de la isla) [S]
- [x] La fauna (M36) y vegetación (M50) respetan el bioma al spawnar [M]

## J. Persistencia y mapa

- [x] Guardar islas_descubiertas (PackedStringArray) en GameState M59 [M]
- [x] Guardar islas_visitadas (PackedStringArray) en GameState M59 [M]
- [x] Al cargar partida, el registro restaura descubrimiento/visita [M]
- [x] El mapa (M54) marca islas descubiertas y visitadas [S]
- [x] Islas secretas ocultas en el mapa hasta descubrirlas [S]
- [x] Reintentar regen 80/0 no pierde progreso de islas (persistencia aparte) [C]

## K. Edge cases

- [x] Carga de isla vecina mientras el jugador navega el borde (sin congelar) [C]
- [x] Viajar a una isla mientras otra se está descargando (cola de operaciones) [C]
- [x] Ancla faltante en M10 para una isla definida → ERROR + fallback [M]
- [x] Anclas inconsistentes entre ejecuciones (misma semilla debe dar lo mismo) [M]
- [x] Jugador en el mar sin barco (M28 no iniciado) → salvavidas/limite de zona [M]
- [x] Isla secreta descubierta por pista pero su ancla aún no generada → espera coherente [C]
- [x] Dos islas con el mismo id en .tres → error de registro y primera gana [S]
- [x] Radio negativo o altura invertida en definición → validar() captura [S]
- [x] Desembarco sobre agua si el muelle se generó mal → punto seguro por software [M]
- [x] Viaje cancelado a mitad de carga → cancelación limpia de task [M]
- [x] Guardado durante una carga → el guardado espera a terminar la operación [C]
- [x] M54 consulta isla secreta no descubierta → inaccesible (sin leak de datos) [S]
- [x] El jugador suelta el barco en el océano abierto → respawn cozy en isla más cercana [M]
- [x] Streaming falla por memoria baja → descarga forzada sin perder estado de partida [C]

## L. Optimización y rendimiento (M61/M62)

- [x] Máximo 2 islas completas en memoria a la vez [C]
- [x] Aurora siempre cargada pero con streaming fino de chunks lejanos [M]
- [x] Metadatos (definiciones) livianos: sin cargar voxel de islas lejanas [S]
- [x] LRU con tope de memoria configurado por M62 [C]
- [x] Sin allocs grandes en el hot path de búsqueda de vecinas [M]
- [x] Búsquedas de vecinas con índice espacial (grid por anillo) [M]
- [x] Carga de props por etapas (sin picos) [M]
- [x] Precalentamiento en el menú (M63): cachea Aurora al boot [M]
- [x] Telemetría de carga (M105): tiempos por isla, memoria, errores [C]
- [x] Profiling: la carga de la isla más grande cabe en frame budget M61 [C]
- [x] La precarga de vecinas no inicia si la GPU está al límite (M61) [C]
- [x] Los .tres usan PackedStringArray (serialización compacta M60) [S]

## M. Documentación y logs

- [x] 01-Requerimientos.md completo (problema, RF, NFR, criterios de aceptación, alcance) [M]
- [x] 02-Analisis.md: alternativas A/B/C/D evaluadas y justificadas [M]
- [x] 03-Diseno.md: arquitectura, 4 flujos en texto, contratos API, integraciones [C]
- [x] 04-Codigo.md: rutas res://, firmas clave, pesos de carga, subs, logs [M]
- [x] 05-Checklist.md con 100+ ítems verificables [M]
- [x] Logs en Logs/ tras implementación (formato estándar, sección 6 de AGENTS.md) [S]

## N. Polish y UX cozy

- [x] Mensaje al descubrir una isla (toast/M54) sin romper la inmersión [S]
- [x] El mapa muestra nombre de la isla al pasar el cursor (M54) [S]
- [x] Transición de embarque suave (M28) con música de travesía [M]
- [x] Ningún contenido exclusivo se pierde: accesible luego por otras vías (M73/feria) [M]
- [x] El regreso siempre disponible: sin estados bloqueados [S]
- [x] Indicador de "isla nueva por descubrir" sutil en el mapa (sin FOMO) [S]
- [x] Los NPC residentes comentan sus islas (M21) al volver (coherente con M64) [M]
- [x] Test manual de recorrido completo: Aurora → Coral → Aurora (idioma y UX) [C]

## O. Testing (M112/M114)

- [x] Test unitario: validar_anclas detecta solapamiento coral/cenizas [M]
- [x] Test unitario: catálogo ordenado y sin duplicados [S]
- [x] Test unitario: bounds y centro de isla correctos [S]
- [x] Test unitario: registry tolera .tres faltante (error + Aurora) [M]
- [x] Test unitario: semilla_id determinista por isla [S]
- [x] Test integración: viaje Aurora→Nieve y regreso sin pérdida de estado [C]
- [x] Test integración: carga de vecina al navegar el borde sin congelar [C]
- [x] Test integración: regen 80/0 conserva anclas válidas [C]
- [x] Test integración: guardar/cargar partida restaura descubrimiento [M]
- [x] Test de estrés: 2 islas cargadas + 1 precargando bajo presupuesto M61 [C]