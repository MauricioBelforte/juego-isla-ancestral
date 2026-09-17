**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 27: Islas del Mundo

> **🟡 Cerrado (iter. 2) — DeepSeek-V4.1-Flash / WorkBuddy, Log 912 (2026-09-15):**
> `83 [x]` · `93 [?]` · `16 [ ]` → **`99 [x]` · `93 [?]` · `0 [ ]`** (192 ítems).
> Se cerraron los **16 `[ ]` propios**: **K** (9 edge cases → `IslandOps` +
> `IslandTravelGuard`), **A** (4 → `IslandDesignCatalog` con los **26** puntos reales de la
> §26; el checklist decía 24 y el plan tiene 26 — el desajuste se reporta, no se acepta), **M**
> (3: 01/02/03 verificados completos). Los `93 [?]` siguen siendo ajenos: `IslandLoading` es
> de M63/M61 (19), anclas reales de M10, mapa de M54, ids de contenido de M50/M36/M15/M23/M19,
> viaje de M28. Test: `test_islas_m27_iter2.gd`, **238 checks / 0 fallos** ×3.

## A. Requisitos y alcance del módulo

- [x] Definir el problema: archipiélago con isla principal Aurora + 12 satélites con identidad propia [M]
- [x] Catalogar los 24 puntos de la sección 26 del plan maestro (isla principal a relevancia narrativa) [S] — 26 puntos REALES (el checklist decía 24: el plan tiene 26) en `IslandDesignCatalog`
- [x] Registrar dependencias: M28, M29; relaciones M08, M09, M10, M51, M61, M63, M54, M59 [S]
- [x] Resolver cada punto de la sección 26 (diseño, distancia, navegación, clima, flora, fauna, recursos, NPC, arquitectura, música, puzzles, recompensa, narrativa) [C] — 15 resueltos por código M27 · 7 declarativos · 4 externos con dueño citado; `validar()` verde
- [x] Declarar que el módulo es delegable para implementación tras M08/M10 base y presupuestos M61 [S]
- [x] Mantener el alcance separado de M28 (barco/viaje), M51 (agua), M63 (streaming general) [S] — `IslandOps` es cola pura, la guardia decide pero no mueve el barco, e `IslandLoading` NO se implementó (M63)
- [x] Definir criterios de aceptación verificables (catálogo 13 islas, anclas válidas, viaje ida y vuelta, contenido exclusivo) [S] — catálogo y anclas verificados por test; el viaje es de M28
- [?] Asegurar coherencia cozy: sin contenido crítico exclusivo e inaccesible, regreso siempre gratis [S] — el regreso gratis es de **M28**
- [x] Verificar que el diseño no contradice los principios innegociables (M152 cozy, sin FOMO) [S] — respawn cozy, guardado que espera, nunca descargar la principal ni la actual: sin pérdida ni castigo
- [x] Documentar el módulo en los 5 archivos obligatorios (plan-inicial y plan-actual) [M]

## B. IslandDefinition — datos por isla

- [x] Create class IslandDefinition como Resource con @export de metadatos [S]
- [x] Campo id (StringName) único por isla [S]
- [x] Campo nombre_display localizable (M87) [S] — + `nombre_clave` (M87) y `descripcion` (M55)
- [x] Campo descripcion/lore para el diario (M55) [S]
- [x] Campo bioma_base (id M09) y biomas_mezcla (Array con proporciones) [C] — catálogo de 13 biomas en `IslandDefinition.BIOMAS` (04-Codigo §6.7)
- [x] Campos de losa: radio, altura_min, altura_max, playa_ancho [M]
- [x] Campo ancla (Vector3i centro) poblado por M10 [M] — campo runtime + `IslandRegistry.anclar()`
- [x] Campo semilla_isla derivada de la semilla de partida (PRNG M10) [M] — `semilla_de_isla()` determinista
- [x] Campo clima_tendencia (id M32) por isla [S]
- [x] Campo musica_theme (id M41) por isla [S] — como `musica_clave` (04-Codigo §6.3)
- [x] Campos de contenido exclusivo: recursos, flora, fauna, puzzles, npc_residentes [C]
- [x] Campo punto_llegada y punto_partida locales (muelle/embarque) [M]
- [x] Campo anillo (enum NUCLEO/CERCANO/MEDIO/LEJANO) que controla distancia y requisitos [M]
- [x] Campo es_secreta (oculta en mapa M54 hasta descubrir) [S]
- [x] Campo es_flotante para islas del cielo (sin océano debajo) [S]
- [x] Campo desbloqueo (Callable) evaluado por M22/M28 [C] — implementado como `desbloqueo_flag: StringName` (un Callable no es serializable en `.tres`; ver 04-Codigo §6.1)
- [x] Método bounds_locales() -> Rect2i para streaming M63 [S] — world-relative (04-Codigo §6.6)
- [x] Método centro_mundo() -> Vector3 para POI y cámara [S]
- [x] Método validar() que devuelve errores de definición (radios, anclas, ids) [M] — 13 clases de error verificadas
- [x] Archivo .tres por satélite: 12 definiciones editables (coral, verde, cenizas, cielo, nieve, desierto, volcanica, submarina, flotante, misteriosa, pequena, secreta) [C] — 12 satélites + `aurora.tres`, generados por `generar_islas.gd`

## C. IslandRegistry — catálogo del archipiélago

- [x] Create autoload IslandRegistry como servicio tipo Service Locator (M07) [S]
- [?] init(anclas: Dictionary) que construye el catálogo desde M10 [M] — sustituido por `anclar(id, ancla, semilla)` por isla (04-Codigo §6.5); la capa de anclas es de **M10**
- [x] get_isla(id) -> IslandDefinition con manejo de id inexistente (null + log WARN) [S]
- [x] todas_las_islas() -> Array ordenada determinista por id (nunca por orden de carga) [M]
- [x] isla_principal() -> Aurora (id constante `aurora`) [S]
- [x] posicion_ancla(id) -> Vector3i con cache de M10 [M]
- [x] vecinas(id, corte_anillo) -> Array de islas dentro de radio de streaming [C]
- [x] coordenadas_por_isla(id) -> Rect2i (bounds en voxels para M63) [S]
- [x] validar_anclas() -> Array[String] de errores [M]
- [x] Señal archipielago_cargado emitida al terminar init [S]
- [x] Registro sin duplicados: ids únicos garantizados al cargar .tres [S] — primera gana
- [?] Carga de .tres diferida (no bloqueante) al iniciar partida [M] — hoy la carga es síncrona en `_ready()` (13 `.tres` livianos); la carga diferida depende de **M63**
- [x] Estado "descubierta/visitada" consultable (delega a M59 GameState) [M]
- [x] Orden de catálogo estable entre ejecuciones (misma semilla) [S]
- [x] Fallback: si falta un .tres, se loguea ERROR y Aurora siempre carga [M] — verificado con carpetas temporales

## D. Anclas y generación (M10)

- [?] Solicitar a M10 la capa de anclas que posiciona cada isla [C] — **M10**
- [?] Las anclas se derivan del PRNG de contexto 2 (mismo mundo, misma semilla) [M] — **M10** (M27 sólo deriva `semilla_de_isla`)
- [x] Validar distancia mínima entre centros: radio_a + radio_b + MARGEN_MAR (64 m) [M]
- [?] Validar que ninguna isla invade el templo subterráneo (M26) ni ruinas (M25) [C] — **M10/M25/M26**
- [x] Validar que Aurora está en el centro del mundo/archipiélago [S]
- [?] Re-roll de ancla con la misma semilla ante solapamiento (máx 8 intentos) [C] — M27 **detecta**; el re-roll es de **M10**
- [?] Log WARN con detalle de cada ancla re-rollada [S] — **M10**
- [?] Log ERROR si tras 8 intentos no hay ancla válida (fallback: echar isla al anillo siguiente) [M] — **M10**
- [?] Regeneración 80/0 de M10 produce anclas consistentes (test de regen) [C] — **M10**
- [?] Estructuras ancladas de M10 respetan las islas (no generan dentro del mar) [M] — **M10**
- [x] Semilla dev para tests deterministas de anclas [S] — `semilla_de_isla()` + layout de referencia del test
- [?] Los NPC (M19) y POI de M09 se generan sobre el terreno de la isla ya anclado [M] — **M19/M09**

## E. IslandLoading — carga, descarga y streaming (M63)

> **Bloque DELEGADO (iter. 1) — dueño M63:** `IslandLoading` depende del streaming y de los presupuestos de memoria de M63/M61. M27 ya expone lo que necesita (`coordenadas_por_isla()`, `vecinas()`, `punto_llegada_mundo()`, `punto_partida_mundo()`). Ítems marcados `[?]`.

- [?] Create servicio IslandLoading separado del generador (no tocar M10) [S]
- [?] cargar_isla(id, preferencia) -> bool con estados de progreso [C]
- [?] Enum IslandPref { PRELOAD, DESCARGA } [S]
- [?] Pesos de carga: losa 60%, props 25%, audio 10%, navmesh 5% [M]
- [?] Emitir isla_cargando(id, progreso, etapa) en cada etapa [S]
- [?] Emitir isla_cargada(id) al 100% [S]
- [?] Emitir isla_descargada(id) al liberar [S]
- [?] descargar_isla(id) nunca descarga Aurora (isla principal) [S]
- [?] descargar_isla(id) nunca descarga la isla actual del jugador [S]
- [?] cacheado(id) -> bool para evitar recargas [S]
- [?] isla_actual() -> StringName rastreada por el servicio [S]
- [?] punto_de_llegada(id) -> Vector3 world-space del muelle [M]
- [?] punto_de_partida(id) -> Vector3 world-space del embarque [M]
- [?] Precarga de isla vecina al cruzar el borde de chunks (radio + RADIO_PRECARGA) [C]
- [?] Descarga LRU bajo presión de memoria (M62) respetando candidatas [C]
- [?] Carga asíncrona sin congelar el frame (threads de Voxel Tools + M63) [C]
- [?] Progreso real por pesos reportado a la pantalla de viaje (M28) [M]
- [?] Si la carga falla (sin disco/red), log ERROR y mensaje cozy al jugador [M]
- [?] El jugador nunca queda atrapado: fallback = seguir en la isla actual [M]

## F. IslandProps — contenido exclusivo por isla

- [x] Create servicio IslandProps con registrar_spawner(tipo, callable) [S]
- [x] materializar(isla, zona) que invoca spawners registrados [M]
- [?] Spawn de flora endémica (contrato M50) solo en bioma de la isla [C] — M27 pasa `items`/`bounds`/`centro`; la colocación es del spawner de **M50**
- [?] Spawn de fauna endémica (contrato M36) dentro de los bounds de la isla [C] — **M36**
- [?] Spawn de recursos exclusivos (contrato M15) en zonas deterministas [M] — **M15**
- [?] Spawn de POI (muelle, plaza, faro, templo, mirador) consumidos por M64 [M] — **M64**
- [x] limpiar(id) libera props al descargar la isla [M]
- [?] Los props no se generan en el mar (zona acuática M51) [S] — el recorte contra el mar es del spawner / **M51**
- [x] Determinismo: misma semilla genera los mismos props (PRNG por isla) [M]
- [x] Los props de islas lejanas no se spawnan hasta que la isla se carga [S] — `materializar()` se niega sin ancla

## G. Integración con M28 — Viajes en barco

> **Bloque DELEGADO (iter. 1) — dueño M28:** el barco, la travesía y la pantalla de viaje son de M28. Ítems marcados `[?]`.

- [?] Contrato: M28 consulta posicion_ancla(destino) para trazar la ruta [M]
- [?] Embarque: jugador en punto_partida → M28 inicia travesía [M]
- [?] Pantalla de viaje muestra progreso real de IslandLoading (M63) [M]
- [?] Desembarco posiciona al jugador en punto_de_llegada(destino) [M]
- [?] Al desembarcar se marca la isla como visitada (M59/M54) [S]
- [?] Regreso a Aurora gratis desde cualquier muelle (anti-frustración) [S]
- [?] Viajes estacionales/de expedición consultan calendario M29 [C]
- [?] Viajes nocturnos y estacionales respetan clima (M32) y hora (M31) [M]
- [?] Boleto/requisitos (M28) no bloquean el regreso a Aurora [S]
- [?] NPC viajeros (M28) respetan la isla cargada (spawn solo si su isla activa) [M]
- [?] El barco no atraca en islas sin desbloqueo (anillo LEJANO) [M]
- [?] Si la isla destino ya está cacheada, la travesía se salta la carga (inmediato) [M]

## H. Integración con M51 — Agua y océano

> **Bloque DELEGADO (iter. 1) — dueño M51:** el océano, las profundidades y la espuma son de M51. Ítems marcados `[?]`.

- [?] Nivel de mar global definido (OCEANO_ALTURA) en el mundo voxel [M]
- [?] El agua entre islas es navegable por barco (no bloqueo invisible) [C]
- [?] Profundidades por isla: arrecife poco profundo de Coral, fosa de Submarina [M]
- [?] Espuma de costas (M51) presente en playas de cada isla [S]
- [?] Corrientes de M51 no llevan el barco fuera de los bounds del archipiélago [C]
- [?] El agua no se congela ni inunda dentro de las islas salvo eventos M32 [M]
- [?] La isla Flotante y las del Cielo no tienen océano debajo (es_flotante) [S]
- [?] Los sonidos del mar (M42) cambian según distancia a la isla más cercana [M]
- [?] El agua interactúa con puzzles de islas (M23/M24) solo isla cargada [M]
- [?] Rendimiento del océano: shader de agua (M51) presupuestado por M61 [C]

## I. Integración con M09 y M32 — biomas y clima

> **Bloque DELEGADO (iter. 1) — dueño M09/M32:** las recetas de bioma y el clima por isla son de M09/M32. Ítems marcados `[?]`.

- [?] Cada isla declara bioma_base y mezcla contra el catálogo de 13 biomas de M09 [M]
- [?] Transiciones entre biomas dentro de una isla suaves (falloff M09) [M]
- [?] Playas/acantilados por recetas de formaciones de M09 [M]
- [?] Clima por isla consultado por M32 (lluvia en Verde, nieve en Nieve) [M]
- [?] La música cambia al desembarcar (M41 theme de la isla) [S]
- [?] La fauna (M36) y vegetación (M50) respetan el bioma al spawnar [M]

## J. Persistencia y mapa

- [x] Guardar islas_descubiertas (PackedStringArray) en GameState M59 [M]
- [x] Guardar islas_visitadas (PackedStringArray) en GameState M59 [M]
- [x] Al cargar partida, el registro restaura descubrimiento/visita [M] — round-trip verificado
- [?] El mapa (M54) marca islas descubiertas y visitadas [S] — M27 expone `visible_en_mapa`/`esta_descubierta`; el pintado es de **M54**
- [?] Islas secretas ocultas en el mapa hasta descubrirlas [S] — lógica en M27, pintado en **M54**
- [x] Reintentar regen 80/0 no pierde progreso de islas (persistencia aparte) [C] — sección `islas` independiente del mundo voxel

## K. Edge cases

- [x] Carga de isla vecina mientras el jugador navega el borde (sin congelar) [C] — K1 `debe_precargar()` + `coste_por_frame()` (1 op/frame, `no_congela`)
- [x] Viajar a una isla mientras otra se está descargando (cola de operaciones) [C] — K2 `evaluar_viaje()` + `IslandOps`: el destino en descarga se ENCOLA, no se cancela
- [x] Ancla faltante en M10 para una isla definida → ERROR + fallback [M]
- [x] Anclas inconsistentes entre ejecuciones (misma semilla debe dar lo mismo) [M]
- [x] Jugador en el mar sin barco (M28 no iniciado) → salvavidas/limite de zona [M] — K3 `evaluar_naufrago()`: salvavidas dentro del radio, respawn cozy fuera
- [x] Isla secreta descubierta por pista pero su ancla aún no generada → espera coherente [C] — K4 `estado_destino()` → `ancla_pendiente` con `espera_coherente: true` (medido: 13/13 sin ancla)
- [x] Dos islas con el mismo id en .tres → error de registro y primera gana [S]
- [x] Radio negativo o altura invertida en definición → validar() captura [S]
- [x] Desembarco sobre agua si el muelle se generó mal → punto seguro por software [M] — K5 `punto_seguro()`: proyección radial al interior del disco
- [x] Viaje cancelado a mitad de carga → cancelación limpia de task [M] — K6 `cancelar_viaje()` + `cancelar_por_isla()`; `limpio` es por destino, no global
- [x] Guardado durante una carga → el guardado espera a terminar la operación [C] — K7 `evaluar_guardado()` → `esperar: true` con cola pendiente o carga en curso
- [x] M54 consulta isla secreta no descubierta → inaccesible (sin leak de datos) [S] — `visible_en_mapa()` devuelve false
- [x] El jugador suelta el barco en el océano abierto → respawn cozy en isla más cercana [M] — K8 `respawn_cozy()`: isla más cercana + punto seguro en tierra firme
- [x] Streaming falla por memoria baja → descarga forzada sin perder estado de partida [C] — K9 `descarga_forzada()` LRU + `sincronizar_estado_partida()` + `snapshot_estado()`

## L. Optimización y rendimiento (M61/M62)

> **Bloque DELEGADO (iter. 1) — dueño M61/M62:** los presupuestos de memoria/frame y el LRU son de M61/M62. Ítems marcados `[?]`.

- [?] Máximo 2 islas completas en memoria a la vez [C]
- [?] Aurora siempre cargada pero con streaming fino de chunks lejanos [M]
- [?] Metadatos (definiciones) livianos: sin cargar voxel de islas lejanas [S]
- [x] LRU con tope de memoria configurado por M62 [C]
- [?] Sin allocs grandes en el hot path de búsqueda de vecinas [M]
- [?] Búsquedas de vecinas con índice espacial (grid por anillo) [M]
- [?] Carga de props por etapas (sin picos) [M]
- [?] Precalentamiento en el menú (M63): cachea Aurora al boot [M]
- [?] Telemetría de carga (M105): tiempos por isla, memoria, errores [C]
- [?] Profiling: la carga de la isla más grande cabe en frame budget M61 [C]
- [?] La precarga de vecinas no inicia si la GPU está al límite (M61) [C]
- [x] Los .tres usan PackedStringArray (serialización compacta M60) [S]

## M. Documentación y logs

- [x] 01-Requerimientos.md completo (problema, RF, NFR, criterios de aceptación, alcance) [M] — verificado: problema, RF, NFR, criterios de aceptación y alcance presentes
- [x] 02-Analisis.md: alternativas A/B/C/D evaluadas y justificadas [M] — verificado: alternativas A/B/C/D evaluadas y justificadas + análisis de riesgo
- [x] 03-Diseno.md: arquitectura, 4 flujos en texto, contratos API, integraciones [C] — verificado: arquitectura, 4 flujos F1–F4, contratos API e integraciones
- [x] 04-Codigo.md: rutas res://, firmas clave, pesos de carga, subs, logs [M]
- [x] 05-Checklist.md con 100+ ítems verificables [M] — 177 ítems
- [x] Logs en Logs/ tras implementación (formato estándar, sección 6 de AGENTS.md) [S]

## N. Polish y UX cozy

> **Bloque DELEGADO (iter. 1) — dueño M54/M28/M21:** mapa, transiciones y comentarios de NPC son de M54/M28/M21. Ítems marcados `[?]`.

- [?] Mensaje al descubrir una isla (toast/M54) sin romper la inmersión [S]
- [?] El mapa muestra nombre de la isla al pasar el cursor (M54) [S]
- [?] Transición de embarque suave (M28) con música de travesía [M]
- [?] Ningún contenido exclusivo se pierde: accesible luego por otras vías (M73/feria) [M]
- [?] El regreso siempre disponible: sin estados bloqueados [S]
- [?] Indicador de "isla nueva por descubrir" sutil en el mapa (sin FOMO) [S]
- [?] Los NPC residentes comentan sus islas (M21) al volver (coherente con M64) [M]
- [?] Test manual de recorrido completo: Aurora → Coral → Aurora (idioma y UX) [C]

## O. Testing (M112/M114)

> **Bloque DELEGADO (iter. 1) — dueño M28/M63/M10/M61:** los tests de integración/estrés requieren esos módulos vivos. Ítems marcados `[?]`.

- [x] Test unitario: validar_anclas detecta solapamiento coral/cenizas [M]
- [x] Test unitario: catálogo ordenado y sin duplicados [S]
- [x] Test unitario: bounds y centro de isla correctos [S]
- [x] Test unitario: registry tolera .tres faltante (error + Aurora) [M]
- [x] Test unitario: semilla_id determinista por isla [S]
- [?] Test integración: viaje Aurora→Nieve y regreso sin pérdida de estado [C]
- [?] Test integración: carga de vecina al navegar el borde sin congelar [C]
- [?] Test integración: regen 80/0 conserva anclas válidas [C]
- [x] Test integración: guardar/cargar partida restaura descubrimiento [M] — + sección `islas` en el payload de M59
- [?] Test de estrés: 2 islas cargadas + 1 precargando bajo presupuesto M61 [C]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
## Iteración 1 — Config de islas data-driven (2026-09-02 06:20, deepseek-v4-flash-vision-exp / Kilo Code)

- [x] `data/islas/islas.json` — config de las 4 islas (RIZ 256/256/256 Raíz, COR 1024/256/220 Coral, CEN 256/1024/220 Ceniza, AUR 1024/1024/200 Aurora) con biomas y color de agua por isla
- [x] `scripts/islas/islas_schema.gd` — IslasSchema: valida codigos (RIZ/COR/CEN/AUR), centro 2D, radio>0, nombre, biomas>0, color_agua #RRGGBB
- [x] Test headless: 5/5 checks OK (config válida, radio 256 de RIZ, 3 biomas Aurora, detección de color inválido e isla faltante)
- [?] Coordenadas/disposición de world (via M160) y generación de islas por viaje (M27/M28) — iter 2 (dueño: deepseek-v4-flash-vision-exp)
## Iteración 2 (2026-09-02 21:30 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] `scripts/islas/sincronizar_islas_mapa.gd` — verificador de coherencia Islas (islas.json) ↔ Mapa (map_data.json): 4/4 islas coherentes, 9/9 POIs asignados a islas válidas (exit 0)
- [x] El ecosistema de coordenadas del mundo queda verificado: islas ↔ mapa ↔ ubicaciones (LOC-*) ↔ viajes

## Iteración 3 — Núcleo data-driven del archipiélago 1+12 (2026-09-11 23:05, DeepSeek-V4.1-Flash / WorkBuddy)

Reserva de log: **831** (el 830 colisionó con GLM-5.3/M32). Reclamo §21.4.7 (dueño anterior
`deepseek-v4-flash-vision-exp`, última actividad 2026-09-02 21:30; el diseño pedía 1+12 islas y sólo existían 4 en JSON).

- [x] `scripts/islas/island_ring.gd` — enum anónimo NUCLEO/CERCANO/MEDIO/LEJANO + radios de vecindad y distancia máxima por anillo
- [x] `scripts/islas/island_definition.gd` — Resource con 22 `@export`, catálogo de 13 biomas de M09, `validar()` con 13 clases de error, `bounds_locales`/`centro_mundo`/`huella`/`a_diccionario`
- [x] `scripts/islas/archipielago.gd` — índice del archipiélago (`islas_esperadas`, `id_principal`) + `comparar()` para detectar faltantes/extra
- [x] `scripts/islas/island_registry.gd` — autoload `IslandRegistry`: carga con ids únicos y orden determinista, `anclar`/`posicion_ancla` con cache, `semilla_de_isla`, `validar_anclas`, `vecinas`, descubrimiento/visita, ISaveProvider sección `islas`
- [x] `scripts/islas/island_props.gd` — spawn declarativo por spawners registrados, PRNG determinista por isla, se niega a materializar sin ancla
- [x] `scripts/islas/generar_islas.gd` — generador validante de los 13 `.tres` + `archipielago.tres` (nunca a mano)
- [x] `data/islas/definiciones/*.tres` (13) + `data/islas/archipielago.tres`
- [x] Autoload `IslandRegistry` registrado en `project.godot`
- [x] `scripts/islas/test_islas_m27.gd` — **171 checks / 0 fallos**, estable en 3 corridas
- [x] Regresiones verdes: legacy M27 5/0 · `sincronizar_islas_mapa` OK · M60 iter.3 132/0 · M60 base 94/0 · M68 177/0 · auditor de aliasing OK(9)
- [x] `04-Codigo.md` reescrito (rutas reales, API, dataset, contratos, 8 desviaciones, 4 trampas, pendientes honestos)
- [?] `IslandLoading` (carga/descarga/streaming) → **M63** (ver bloque E)
- [?] Capa de anclas real, re-roll de 8 intentos, regen 80/0 → **M10** (ver bloque D)
- [?] Ids reales de contenido exclusivo → **M50/M36/M15/M23-M24/M19** (hoy declarativos/provisionales)
- [?] Migrar el mapa de `islas.json` (4) al catálogo de 13 → **M54**

## Iteración 4 — Edge cases K1–K9 + catálogo de la §26 (2026-09-15 03:20, DeepSeek-V4.1-Flash / WorkBuddy)

Reserva de log: **912**. Cierra los **16 `[ ]` propios** del módulo (K = 9, A = 4, M = 3).
Los `93 [?]` quedan intactos: son de M63/M61, M10, M54, M50/M36/M15/M23/M19 y M28.

### K — 9 edge cases (`island_ops.gd` + `island_travel_guard.gd`)

- K1 precarga de isla vecina al navegar el borde sin congelar — `debe_precargar()` respeta presupuesto y margen; `coste_por_frame()` declara `MAX_OPS_POR_FRAME == 1` y `no_congela`
- K2 viajar a una isla mientras otra se descarga — `evaluar_viaje()` encola el destino en descarga (no lo cancela: cancelar dejaría chunks a medio liberar)
- K3 jugador en el mar sin barco — `evaluar_naufrago()`: salvavidas dentro del radio de seguridad, respawn cozy fuera
- K4 isla secreta descubierta pero sin ancla generada — `estado_destino()` → `ancla_pendiente` con `espera_coherente: true`; medido: 13/13 islas del registry real sin ancla y la guardia no crashea
- K5 desembarco sobre agua por muelle mal generado — `punto_seguro()` proyecta al interior del disco (`radio - playa - 1`, porque el borde exacto cae fuera por redondeo float)
- K6 viaje cancelado a mitad de carga — `cancelar_viaje()` + `cancelar_por_isla()`; `limpio` es **por destino** (cancelar coral no declara libre la cola de verde)
- K7 guardado durante una carga — `evaluar_guardado()` devuelve `esperar: true` con cola pendiente o carga en curso
- K8 jugador suelta el barco en océano abierto — `respawn_cozy()` a la isla más cercana, sobre tierra firme
- K9 streaming falla por memoria baja — `descarga_forzada()` LRU que **nunca** descarga la principal ni la actual; sólo toca `cargada`, y el estado de partida (M59) se verifica intacto vía `sincronizar_estado_partida()` + `snapshot_estado()`

### A — 4 requisitos

- Catálogo de los **26** puntos reales de la §26 (`island_design_catalog.gd`; el checklist decía 24 y el plan tiene 26 — `validar()`/`informe()` exponen el desajuste)
- Cada punto con resolución declarada: **15 resueltos** por código M27, **7 declarativos**, **4 externos** con dueño citado
- Alcance separado de M28/M51/M63: `IslandOps` es cola pura, la guardia decide pero no mueve el barco, `IslandLoading` NO se implementó
- Cozy sin FOMO: respawn cozy, guardado que espera, nunca descargar la principal ni la actual

### M — 3 documentos

- `01-Requerimientos.md` verificado completo (problema, RF, NFR, criterios de aceptación, alcance)
- `02-Analisis.md` verificado (alternativas A/B/C/D evaluadas y justificadas + riesgos)
- `03-Diseno.md` verificado (arquitectura, 4 flujos F1–F4, contratos API, integraciones)

### Artefactos y verificación

- `scripts/islas/island_ops.gd` — cola de operaciones (prioridad, etapas 60/25/10/5, idempotencia, cancelación)
- `scripts/islas/island_travel_guard.gd` — los 9 K como lógica pura + `sincronizar_estado_partida()`
- `scripts/islas/island_design_catalog.gd` — catálogo §26 + `claves_localizacion()` para M87
- `scripts/islas/test_islas_m27_iter2.gd` — **238 checks / 0 fallos** ×3, EXIT 0, 0 `SCRIPT ERROR`, 8/8 bloques
- Guardián anti-falso-verde **probado**: aborto inyectado en el bloque D → el test lo delata y lo nombra (`bloques que no terminaron: ["D"]`); 238 → 210 checks
- Regresiones verdes: `test_islas_m27.gd` 171/0 · `test_islas_headless.gd` 5/0 · `sincronizar_islas_mapa` OK (4 islas + 9 POIs)
- `06-Plan-Testings.md` y `07-Resultados-Testings.md` creados; test cableado en `.github/workflows/quality.yml`
- `04-Codigo.md` actualizado (API 2.6–2.8, reglas, trampas 5–8, pendientes honestos)
- Nadie llama todavía a `IslandOps`/`IslandTravelGuard` → **M63** (streaming) y **M28** (barco) deben cablearlas
- Asimetría de M59: `esta_descubierta(aurora) == true` pero `islas_descubiertas()` no la lista → **M59/M54**

