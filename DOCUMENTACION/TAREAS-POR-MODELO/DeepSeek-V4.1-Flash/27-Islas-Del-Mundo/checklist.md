**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

**Módulo:** 27-Islas-Del-Mundo (27)

# Checklist personal tareas — 27-Islas-Del-Mundo

> Extraídas del `05-Checklist.md` del módulo (192 ítems). Fuente de verdad del ítem: el `05-Checklist.md`.
>
> **iter. 1 (2026-09-11, Log 831):** módulo reclamado §21.4.7 (dueño previo `deepseek-v4-flash-vision-exp`, 9 días inactivo).
> El diseño pedía **1 + 12 islas** y sólo existían 4 en un JSON. Núcleo data-driven implementado: `IslandRing` +
> `IslandDefinition` (13 biomas M09, `validar()` con 13 clases de error) + `Archipielago` + `IslandRegistry` (autoload) +
> `IslandProps` + generador validante del dataset (**13 `.tres`**) + test **171/0** (×3).
>
> **iter. 2 (2026-09-15, Log 912):** los **16 `[ ]` propios** cerrados como lógica pura headless.
> **K** (9 edge cases) → `IslandOps` (cola de operaciones: prioridad viaje>carga>descarga>precarga,
> etapas 60/25/10/5, idempotencia por tipo+isla, una sola en curso) + `IslandTravelGuard` (precarga
> sin congelar · viaje con descarga en curso —el destino se **encola**, no se cancela— · náufrago ·
> ancla pendiente con espera coherente · punto seguro de desembarco · cancelación limpia por destino ·
> guardado que espera · respawn cozy · descarga forzada LRU sin perder el estado de M59).
> **A** (4) → `IslandDesignCatalog` con los **26** puntos reales de la §26 (el checklist decía 24 y el
> plan tiene 26: el desajuste se reporta, no se acepta). **M** (3) → 01/02/03 verificados completos.
> Test `test_islas_m27_iter2.gd` **238/0 ×3** (`SCRIPT ERROR: 0`), 8 bloques y guardián
> anti-falso-verde **probado en vivo** (aborto inyectado → 238→210 y nombra el bloque).
> Regresiones: iter. 1 171/0 · legacy 5/0 · islas↔mapa OK.
> Estado: **99 `[x]` · 93 `[?]` con dueño · 0 `[ ]`**.

## Tareas

- - [x] T-001 Definir el problema: archipiélago con isla principal Aurora + 12 satélites con identidad propia [M]
- - [x] T-002 Catalogar los 24 puntos de la sección 26 del plan maestro (isla principal a relevancia narrativa) [S]
- - [x] T-003 Registrar dependencias: M28, M29; relaciones M08, M09, M10, M51, M61, M63, M54, M59 [S]
- - [x] T-004 Resolver cada punto de la sección 26 (diseño, distancia, navegación, clima, flora, fauna, recursos, NPC, arquitectura, música, puzzles, recompensa, narrativa) [C]
- - [x] T-005 Declarar que el módulo es delegable para implementación tras M08/M10 base y presupuestos M61 [S]
- - [x] T-006 Mantener el alcance separado de M28 (barco/viaje), M51 (agua), M63 (streaming general) [S]
- - [x] T-007 Definir criterios de aceptación verificables (catálogo 13 islas, anclas válidas, viaje ida y vuelta, contenido exclusivo) [S] — catálogo y anclas verificados por test; el viaje es de M28
- - [?] T-008 Asegurar coherencia cozy: sin contenido crítico exclusivo e inaccesible, regreso siempre gratis [S] — el regreso gratis es de **M28**
- - [x] T-009 Verificar que el diseño no contradice los principios innegociables (M152 cozy, sin FOMO) [S]
- - [x] T-010 Documentar el módulo en los 5 archivos obligatorios (plan-inicial y plan-actual) [M]
- - [x] T-011 Create class IslandDefinition como Resource con @export de metadatos [S]
- - [x] T-012 Campo id (StringName) único por isla [S]
- - [x] T-013 Campo nombre_display localizable (M87) [S] — + `nombre_clave` (M87) y `descripcion` (M55)
- - [x] T-014 Campo descripcion/lore para el diario (M55) [S]
- - [x] T-015 Campo bioma_base (id M09) y biomas_mezcla (Array con proporciones) [C] — catálogo de 13 biomas en `IslandDefinition.BIOMAS` (04-Codigo §6.7)
- - [x] T-016 Campos de losa: radio, altura_min, altura_max, playa_ancho [M]
- - [x] T-017 Campo ancla (Vector3i centro) poblado por M10 [M] — campo runtime + `IslandRegistry.anclar()`
- - [x] T-018 Campo semilla_isla derivada de la semilla de partida (PRNG M10) [M] — `semilla_de_isla()` determinista
- - [x] T-019 Campo clima_tendencia (id M32) por isla [S]
- - [x] T-020 Campo musica_theme (id M41) por isla [S] — como `musica_clave` (04-Codigo §6.3)
- - [x] T-021 Campos de contenido exclusivo: recursos, flora, fauna, puzzles, npc_residentes [C]
- - [x] T-022 Campo punto_llegada y punto_partida locales (muelle/embarque) [M]
- - [x] T-023 Campo anillo (enum NUCLEO/CERCANO/MEDIO/LEJANO) que controla distancia y requisitos [M]
- - [x] T-024 Campo es_secreta (oculta en mapa M54 hasta descubrir) [S]
- - [x] T-025 Campo es_flotante para islas del cielo (sin océano debajo) [S]
- - [x] T-026 Campo desbloqueo (Callable) evaluado por M22/M28 [C] — implementado como `desbloqueo_flag: StringName` (un Callable no es serializable en `.tres`; ver 04-Codigo §6.1)
- - [x] T-027 Método bounds_locales() -> Rect2i para streaming M63 [S] — world-relative (04-Codigo §6.6)
- - [x] T-028 Método centro_mundo() -> Vector3 para POI y cámara [S]
- - [x] T-029 Método validar() que devuelve errores de definición (radios, anclas, ids) [M] — 13 clases de error verificadas
- - [x] T-030 Archivo .tres por satélite: 12 definiciones editables (coral, verde, cenizas, cielo, nieve, desierto, volcanica, submarina, flotante, misteriosa, pequena, secreta) [C] — 12 satélites + `aurora.tres`, generados por `generar_islas.gd`
- - [x] T-031 Create autoload IslandRegistry como servicio tipo Service Locator (M07) [S]
- - [?] T-032 init(anclas: Dictionary) que construye el catálogo desde M10 [M] — sustituido por `anclar(id, ancla, semilla)` por isla (04-Codigo §6.5); la capa de anclas es de **M10**
- - [x] T-033 get_isla(id) -> IslandDefinition con manejo de id inexistente (null + log WARN) [S]
- - [x] T-034 todas_las_islas() -> Array ordenada determinista por id (nunca por orden de carga) [M]
- - [x] T-035 isla_principal() -> Aurora (id constante `aurora`) [S]
- - [x] T-036 posicion_ancla(id) -> Vector3i con cache de M10 [M]
- - [x] T-037 vecinas(id, corte_anillo) -> Array de islas dentro de radio de streaming [C]
- - [x] T-038 coordenadas_por_isla(id) -> Rect2i (bounds en voxels para M63) [S]
- - [x] T-039 validar_anclas() -> Array[String] de errores [M]
- - [x] T-040 Señal archipielago_cargado emitida al terminar init [S]
- - [x] T-041 Registro sin duplicados: ids únicos garantizados al cargar .tres [S] — primera gana
- - [?] T-042 Carga de .tres diferida (no bloqueante) al iniciar partida [M] — hoy la carga es síncrona en `_ready()` (13 `.tres` livianos); la carga diferida depende de **M63**
- - [x] T-043 Estado "descubierta/visitada" consultable (delega a M59 GameState) [M]
- - [x] T-044 Orden de catálogo estable entre ejecuciones (misma semilla) [S]
- - [x] T-045 Fallback: si falta un .tres, se loguea ERROR y Aurora siempre carga [M] — verificado con carpetas temporales
- - [?] T-046 Solicitar a M10 la capa de anclas que posiciona cada isla [C] — **M10**
- - [?] T-047 Las anclas se derivan del PRNG de contexto 2 (mismo mundo, misma semilla) [M] — **M10** (M27 sólo deriva `semilla_de_isla`)
- - [x] T-048 Validar distancia mínima entre centros: radio_a + radio_b + MARGEN_MAR (64 m) [M]
- - [?] T-049 Validar que ninguna isla invade el templo subterráneo (M26) ni ruinas (M25) [C] — **M10/M25/M26**
- - [x] T-050 Validar que Aurora está en el centro del mundo/archipiélago [S]
- - [?] T-051 Re-roll de ancla con la misma semilla ante solapamiento (máx 8 intentos) [C] — M27 **detecta**; el re-roll es de **M10**
- - [?] T-052 Log WARN con detalle de cada ancla re-rollada [S] — **M10**
- - [?] T-053 Log ERROR si tras 8 intentos no hay ancla válida (fallback: echar isla al anillo siguiente) [M] — **M10**
- - [?] T-054 Regeneración 80/0 de M10 produce anclas consistentes (test de regen) [C] — **M10**
- - [?] T-055 Estructuras ancladas de M10 respetan las islas (no generan dentro del mar) [M] — **M10**
- - [x] T-056 Semilla dev para tests deterministas de anclas [S] — `semilla_de_isla()` + layout de referencia del test
- - [?] T-057 Los NPC (M19) y POI de M09 se generan sobre el terreno de la isla ya anclado [M] — **M19/M09**
- - [?] T-058 Create servicio IslandLoading separado del generador (no tocar M10) [S]
- - [?] T-059 cargar_isla(id, preferencia) -> bool con estados de progreso [C]
- - [?] T-060 Enum IslandPref { PRELOAD, DESCARGA } [S]
- - [?] T-061 Pesos de carga: losa 60%, props 25%, audio 10%, navmesh 5% [M]
- - [?] T-062 Emitir isla_cargando(id, progreso, etapa) en cada etapa [S]
- - [?] T-063 Emitir isla_cargada(id) al 100% [S]
- - [?] T-064 Emitir isla_descargada(id) al liberar [S]
- - [?] T-065 descargar_isla(id) nunca descarga Aurora (isla principal) [S]
- - [?] T-066 descargar_isla(id) nunca descarga la isla actual del jugador [S]
- - [?] T-067 cacheado(id) -> bool para evitar recargas [S]
- - [?] T-068 isla_actual() -> StringName rastreada por el servicio [S]
- - [?] T-069 punto_de_llegada(id) -> Vector3 world-space del muelle [M]
- - [?] T-070 punto_de_partida(id) -> Vector3 world-space del embarque [M]
- - [?] T-071 Precarga de isla vecina al cruzar el borde de chunks (radio + RADIO_PRECARGA) [C]
- - [?] T-072 Descarga LRU bajo presión de memoria (M62) respetando candidatas [C]
- - [?] T-073 Carga asíncrona sin congelar el frame (threads de Voxel Tools + M63) [C]
- - [?] T-074 Progreso real por pesos reportado a la pantalla de viaje (M28) [M]
- - [?] T-075 Si la carga falla (sin disco/red), log ERROR y mensaje cozy al jugador [M]
- - [?] T-076 El jugador nunca queda atrapado: fallback = seguir en la isla actual [M]
- - [x] T-077 Create servicio IslandProps con registrar_spawner(tipo, callable) [S]
- - [x] T-078 materializar(isla, zona) que invoca spawners registrados [M]
- - [?] T-079 Spawn de flora endémica (contrato M50) solo en bioma de la isla [C] — M27 pasa `items`/`bounds`/`centro`; la colocación es del spawner de **M50**
- - [?] T-080 Spawn de fauna endémica (contrato M36) dentro de los bounds de la isla [C] — **M36**
- - [?] T-081 Spawn de recursos exclusivos (contrato M15) en zonas deterministas [M] — **M15**
- - [?] T-082 Spawn de POI (muelle, plaza, faro, templo, mirador) consumidos por M64 [M] — **M64**
- - [x] T-083 limpiar(id) libera props al descargar la isla [M]
- - [?] T-084 Los props no se generan en el mar (zona acuática M51) [S] — el recorte contra el mar es del spawner / **M51**
- - [x] T-085 Determinismo: misma semilla genera los mismos props (PRNG por isla) [M]
- - [x] T-086 Los props de islas lejanas no se spawnan hasta que la isla se carga [S] — `materializar()` se niega sin ancla
- - [?] T-087 Contrato: M28 consulta posicion_ancla(destino) para trazar la ruta [M]
- - [?] T-088 Embarque: jugador en punto_partida → M28 inicia travesía [M]
- - [?] T-089 Pantalla de viaje muestra progreso real de IslandLoading (M63) [M]
- - [?] T-090 Desembarco posiciona al jugador en punto_de_llegada(destino) [M]
- - [?] T-091 Al desembarcar se marca la isla como visitada (M59/M54) [S]
- - [?] T-092 Regreso a Aurora gratis desde cualquier muelle (anti-frustración) [S]
- - [?] T-093 Viajes estacionales/de expedición consultan calendario M29 [C]
- - [?] T-094 Viajes nocturnos y estacionales respetan clima (M32) y hora (M31) [M]
- - [?] T-095 Boleto/requisitos (M28) no bloquean el regreso a Aurora [S]
- - [?] T-096 NPC viajeros (M28) respetan la isla cargada (spawn solo si su isla activa) [M]
- - [?] T-097 El barco no atraca en islas sin desbloqueo (anillo LEJANO) [M]
- - [?] T-098 Si la isla destino ya está cacheada, la travesía se salta la carga (inmediato) [M]
- - [?] T-099 Nivel de mar global definido (OCEANO_ALTURA) en el mundo voxel [M]
- - [?] T-100 El agua entre islas es navegable por barco (no bloqueo invisible) [C]
- - [?] T-101 Profundidades por isla: arrecife poco profundo de Coral, fosa de Submarina [M]
- - [?] T-102 Espuma de costas (M51) presente en playas de cada isla [S]
- - [?] T-103 Corrientes de M51 no llevan el barco fuera de los bounds del archipiélago [C]
- - [?] T-104 El agua no se congela ni inunda dentro de las islas salvo eventos M32 [M]
- - [?] T-105 La isla Flotante y las del Cielo no tienen océano debajo (es_flotante) [S]
- - [?] T-106 Los sonidos del mar (M42) cambian según distancia a la isla más cercana [M]
- - [?] T-107 El agua interactúa con puzzles de islas (M23/M24) solo isla cargada [M]
- - [?] T-108 Rendimiento del océano: shader de agua (M51) presupuestado por M61 [C]
- - [?] T-109 Cada isla declara bioma_base y mezcla contra el catálogo de 13 biomas de M09 [M]
- - [?] T-110 Transiciones entre biomas dentro de una isla suaves (falloff M09) [M]
- - [?] T-111 Playas/acantilados por recetas de formaciones de M09 [M]
- - [?] T-112 Clima por isla consultado por M32 (lluvia en Verde, nieve en Nieve) [M]
- - [?] T-113 La música cambia al desembarcar (M41 theme de la isla) [S]
- - [?] T-114 La fauna (M36) y vegetación (M50) respetan el bioma al spawnar [M]
- - [x] T-115 Guardar islas_descubiertas (PackedStringArray) en GameState M59 [M]
- - [x] T-116 Guardar islas_visitadas (PackedStringArray) en GameState M59 [M]
- - [x] T-117 Al cargar partida, el registro restaura descubrimiento/visita [M] — round-trip verificado
- - [?] T-118 El mapa (M54) marca islas descubiertas y visitadas [S] — M27 expone `visible_en_mapa`/`esta_descubierta`; el pintado es de **M54**
- - [?] T-119 Islas secretas ocultas en el mapa hasta descubrirlas [S] — lógica en M27, pintado en **M54**
- - [x] T-120 Reintentar regen 80/0 no pierde progreso de islas (persistencia aparte) [C] — sección `islas` independiente del mundo voxel
- - [x] T-121 Carga de isla vecina mientras el jugador navega el borde (sin congelar) [C]
- - [x] T-122 Viajar a una isla mientras otra se está descargando (cola de operaciones) [C]
- - [x] T-123 Ancla faltante en M10 para una isla definida → ERROR + fallback [M]
- - [x] T-124 Anclas inconsistentes entre ejecuciones (misma semilla debe dar lo mismo) [M]
- - [x] T-125 Jugador en el mar sin barco (M28 no iniciado) → salvavidas/limite de zona [M]
- - [x] T-126 Isla secreta descubierta por pista pero su ancla aún no generada → espera coherente [C]
- - [x] T-127 Dos islas con el mismo id en .tres → error de registro y primera gana [S]
- - [x] T-128 Radio negativo o altura invertida en definición → validar() captura [S]
- - [x] T-129 Desembarco sobre agua si el muelle se generó mal → punto seguro por software [M]
- - [x] T-130 Viaje cancelado a mitad de carga → cancelación limpia de task [M]
- - [x] T-131 Guardado durante una carga → el guardado espera a terminar la operación [C]
- - [x] T-132 M54 consulta isla secreta no descubierta → inaccesible (sin leak de datos) [S] — `visible_en_mapa()` devuelve false
- - [x] T-133 El jugador suelta el barco en el océano abierto → respawn cozy en isla más cercana [M]
- - [x] T-134 Streaming falla por memoria baja → descarga forzada sin perder estado de partida [C]
- - [?] T-135 Máximo 2 islas completas en memoria a la vez [C]
- - [?] T-136 Aurora siempre cargada pero con streaming fino de chunks lejanos [M]
- - [?] T-137 Metadatos (definiciones) livianos: sin cargar voxel de islas lejanas [S]
- - [x] T-138 LRU con tope de memoria configurado por M62 [C]
- - [?] T-139 Sin allocs grandes en el hot path de búsqueda de vecinas [M]
- - [?] T-140 Búsquedas de vecinas con índice espacial (grid por anillo) [M]
- - [?] T-141 Carga de props por etapas (sin picos) [M]
- - [?] T-142 Precalentamiento en el menú (M63): cachea Aurora al boot [M]
- - [?] T-143 Telemetría de carga (M105): tiempos por isla, memoria, errores [C]
- - [?] T-144 Profiling: la carga de la isla más grande cabe en frame budget M61 [C]
- - [?] T-145 La precarga de vecinas no inicia si la GPU está al límite (M61) [C]
- - [x] T-146 Los .tres usan PackedStringArray (serialización compacta M60) [S]
- - [x] T-147 01-Requerimientos.md completo (problema, RF, NFR, criterios de aceptación, alcance) [M]
- - [x] T-148 02-Analisis.md: alternativas A/B/C/D evaluadas y justificadas [M]
- - [x] T-149 03-Diseno.md: arquitectura, 4 flujos en texto, contratos API, integraciones [C]
- - [x] T-150 04-Codigo.md: rutas res://, firmas clave, pesos de carga, subs, logs [M]
- - [x] T-151 05-Checklist.md con 100+ ítems verificables [M] — 177 ítems
- - [x] T-152 Logs en Logs/ tras implementación (formato estándar, sección 6 de AGENTS.md) [S]
- - [?] T-153 Mensaje al descubrir una isla (toast/M54) sin romper la inmersión [S]
- - [?] T-154 El mapa muestra nombre de la isla al pasar el cursor (M54) [S]
- - [?] T-155 Transición de embarque suave (M28) con música de travesía [M]
- - [?] T-156 Ningún contenido exclusivo se pierde: accesible luego por otras vías (M73/feria) [M]
- - [?] T-157 El regreso siempre disponible: sin estados bloqueados [S]
- - [?] T-158 Indicador de "isla nueva por descubrir" sutil en el mapa (sin FOMO) [S]
- - [?] T-159 Los NPC residentes comentan sus islas (M21) al volver (coherente con M64) [M]
- - [?] T-160 Test manual de recorrido completo: Aurora → Coral → Aurora (idioma y UX) [C]
- - [x] T-161 Test unitario: validar_anclas detecta solapamiento coral/cenizas [M]
- - [x] T-162 Test unitario: catálogo ordenado y sin duplicados [S]
- - [x] T-163 Test unitario: bounds y centro de isla correctos [S]
- - [x] T-164 Test unitario: registry tolera .tres faltante (error + Aurora) [M]
- - [x] T-165 Test unitario: semilla_id determinista por isla [S]
- - [?] T-166 Test integración: viaje Aurora→Nieve y regreso sin pérdida de estado [C]
- - [?] T-167 Test integración: carga de vecina al navegar el borde sin congelar [C]
- - [?] T-168 Test integración: regen 80/0 conserva anclas válidas [C]
- - [x] T-169 Test integración: guardar/cargar partida restaura descubrimiento [M] — + sección `islas` en el payload de M59
- - [?] T-170 Test de estrés: 2 islas cargadas + 1 precargando bajo presupuesto M61 [C]
- - [x] T-171 Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
- - [x] T-172 `data/islas/islas.json` — config de las 4 islas (RIZ 256/256/256 Raíz, COR 1024/256/220 Coral, CEN 256/1024/220 Ceniza, AUR 1024/1024/200 Aurora) con biomas y color de agua por isla
- - [x] T-173 `scripts/islas/islas_schema.gd` — IslasSchema: valida codigos (RIZ/COR/CEN/AUR), centro 2D, radio>0, nombre, biomas>0, color_agua #RRGGBB
- - [x] T-174 Test headless: 5/5 checks OK (config válida, radio 256 de RIZ, 3 biomas Aurora, detección de color inválido e isla faltante)
- - [?] T-175 Coordenadas/disposición de world (via M160) y generación de islas por viaje (M27/M28) — iter 2 (dueño: deepseek-v4-flash-vision-exp)
- - [x] T-176 `scripts/islas/sincronizar_islas_mapa.gd` — verificador de coherencia Islas (islas.json) ↔ Mapa (map_data.json): 4/4 islas coherentes, 9/9 POIs asignados a islas válidas (exit 0)
- - [x] T-177 El ecosistema de coordenadas del mundo queda verificado: islas ↔ mapa ↔ ubicaciones (LOC-*) ↔ viajes
- - [x] T-178 `scripts/islas/island_ring.gd` — enum anónimo NUCLEO/CERCANO/MEDIO/LEJANO + radios de vecindad y distancia máxima por anillo
- - [x] T-179 `scripts/islas/island_definition.gd` — Resource con 22 `@export`, catálogo de 13 biomas de M09, `validar()` con 13 clases de error, `bounds_locales`/`centro_mundo`/`huella`/`a_diccionario`
- - [x] T-180 `scripts/islas/archipielago.gd` — índice del archipiélago (`islas_esperadas`, `id_principal`) + `comparar()` para detectar faltantes/extra
- - [x] T-181 `scripts/islas/island_registry.gd` — autoload `IslandRegistry`: carga con ids únicos y orden determinista, `anclar`/`posicion_ancla` con cache, `semilla_de_isla`, `validar_anclas`, `vecinas`, descubrimiento/visita, ISaveProvider sección `islas`
- - [x] T-182 `scripts/islas/island_props.gd` — spawn declarativo por spawners registrados, PRNG determinista por isla, se niega a materializar sin ancla
- - [x] T-183 `scripts/islas/generar_islas.gd` — generador validante de los 13 `.tres` + `archipielago.tres` (nunca a mano)
- - [x] T-184 `data/islas/definiciones/*.tres` (13) + `data/islas/archipielago.tres`
- - [x] T-185 Autoload `IslandRegistry` registrado en `project.godot`
- - [x] T-186 `scripts/islas/test_islas_m27.gd` — **171 checks / 0 fallos**, estable en 3 corridas
- - [x] T-187 Regresiones verdes: legacy M27 5/0 · `sincronizar_islas_mapa` OK · M60 iter.3 132/0 · M60 base 94/0 · M68 177/0 · auditor de aliasing OK(9)
- - [x] T-188 `04-Codigo.md` reescrito (rutas reales, API, dataset, contratos, 8 desviaciones, 4 trampas, pendientes honestos)
- - [?] T-189 `IslandLoading` (carga/descarga/streaming) → **M63** (ver bloque E)
- - [?] T-190 Capa de anclas real, re-roll de 8 intentos, regen 80/0 → **M10** (ver bloque D)
- - [?] T-191 Ids reales de contenido exclusivo → **M50/M36/M15/M23-M24/M19** (hoy declarativos/provisionales)
- - [?] T-192 Migrar el mapa de `islas.json` (4) al catálogo de 13 → **M54**
