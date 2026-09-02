**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 54: Mapa

## A. Problema, objetivo y alcance (8)

- [ ] Definir el problema: la isla Aurora es grande y el jugador necesita orientarse sin frustración ni costo de rendimiento [S]
- [ ] Definir el objetivo: minimapa discreto + mapa completo cozy que se revela al explorar [S]
- [ ] Definir el alcance: superficie de la isla Aurora, regiones/biomas M09/M27, marcadores, niebla, pines y fast travel M69 [S]
- [ ] Declarar fuera de alcance: interiores, mazmorras y templos subterráneos (M24/M25) no se mapean internamente [S]
- [ ] Registrar dependencia principal M53 (UI/UX: UILayer, foco, ThemeUx, TooltipService) [S]
- [ ] Registrar dependencias de datos M09/M27 (regiones y biomas) y M69 (fast travel por interfaz) [S]
- [ ] Definir la estética: mapa ilustrado cozy, paleta pastel de M53, sin saturación [S]
- [ ] Definir criterios de aceptación medibles (rendimiento, navegación, persistencia, checklist ≥ 120) [S]

## B. RF1 Minimapa (14)

- [ ] Crear MinimapView como widget Control del HUD en esquina sin tapar el centro [S]
- [ ] Ícono del jugador centrado en el widget [S]
- [ ] Rotación fija (norte arriba) para minimizar cinetosis (M58) [S]
- [ ] Mostrar regiones/biomas explorados con colores de bioma (M09/M27) [M]
- [ ] Mostrar marcadores relevantes (pueblo, casa, tiendas M39, destinos M69) [S]
- [ ] Aplicar niebla de guerra también en el minimapa (recorte del FogTextureRect) [M]
- [ ] Mostrar bordes de región al cruzar de una a otra [M]
- [ ] Ocultable con acción de M57 y desde configuración [S]
- [ ] Zoom propio opcional del minimapa (acercar/alejar el widget) [M]
- [ ] Textura caché del MapManager reutilizada sin segundo bake ni re-render por frame [M]
- [ ] Actualización solo por señales (`exploration_changed`, `markers_changed`, posición 2 Hz) [M]
- [ ] Flecha de borde para marcadores importantes fuera de la vista del widget [M]
- [ ] Diferenciación por forma y color (daltonismo M58) [S]
- [ ] Acceso al mapa completo con un click/foco sobre el minimapa (`map_toggle`) [S]

## C. RF2 Mapa completo (12)

- [ ] Crear FullMapLayer como UILayer tipo MODAL_FULL de M53 [S]
- [ ] Generar la textura base del mapa de la isla Aurora desde el chunk data del mundo (M10) [C]
- [ ] Estilo ilustrado cozy: manchas de bioma con paleta pastel, bordes suaves [C]
- [ ] Nombres de región con fuentes M88 (Nunito/Fredoka One) y jerarquía M53 [M]
- [ ] Marcador "estás aquí" con forma + color del jugador siempre visible [S]
- [ ] Pausa del mundo coherente con M29/M30 al abrir el mapa [M]
- [ ] Cierre con Esc/cancel y restauración del foco (M53) [S]
- [ ] Atajo M/`map_toggle` para abrir (M57) con prompts dinámicos [S]
- [ ] Navegación 100% con gamepad y teclado (foco nativo M53) [M]
- [ ] Convivencia con la pila de capas (diálogo abierto + mapa: se encola) [M]
- [ ] Leyenda de iconos legible (M58) y panel de filtros accesible [M]
- [ ] Indicador de "el mapa aún se dibuja" con progreso si el mundo no terminó de generar (M63, AGENTS 8) [M]

## D. RF3 Marcadores (14)

- [ ] Marcador del pueblo (M09/M27) registrado en MarkersCatalog [M]
- [ ] Marcadores de tiendas individuales (M39) registrados automáticamente por evento [M]
- [ ] Marcador de la casa del jugador [S]
- [ ] Marcadores de casas de NPCs (M19) registrados por evento [M]
- [ ] Marcadores de islas/zones (M27) según islands exploradas [M]
- [ ] Marcadores de templos y ruinas (M24/M25) como POIs [M]
- [ ] Iconos SVG por tipo (casa, tienda, NPC, templo, destino, pin) de M46/M53 [M]
- [ ] Clusterización de marcadores cercanos con contador y tooltip con nombres [M]
- [ ] Tooltip del marcador al enfocar/hover (M53 TooltipService) [S]
- [ ] Marcadores ocultos hasta que su región esté explorada (sin spoilers) [M]
- [ ] Filtro por tipo de marcador con persistencia de preferencia [M]
- [ ] Diferenciación por forma + color para daltonismo (M58) [S]
- [ ] Pool de sprites sin crear/destruir nodos al navegar [M]
- [ ] Escala constante de los marcadores al hacer zoom (top_level, sin deformar) [M]

## E. RF4 Fast travel (10)

- [ ] Marcadores de destinos de M69 visibles en el mapa completo [M]
- [ ] Confirmación amable antes del viaje (confirm popup de M53 con costo/duración si M69 lo define) [M]
- [ ] Delegación del viaje por Callable (`register_fast_travel_provider`) sin importar nodos de M69 [M]
- [ ] Destinos bloqueados hasta desbloquearlos explorando [M]
- [ ] Visualización de ruta al destino (línea suave sobre el mapa, M28) [M]
- [ ] Cancelación del viaje desde el mapa sin estado inconsistente [S]
- [ ] Estado del viaje en curso reflejado (`travel_state_changed`) y mapa cerrado durante el trayecto [M]
- [ ] Re-apertura del mapa al llegar con la posición y región actualizada [M]
- [ ] SFX de viaje en el bus UI (M91) y toast de llegada (M53) [S]
- [ ] Test end-to-end: bloqueado → desbloqueo → viaje → cancelación → llegada [C]

## F. RF5 Niebla de guerra (14)

- [ ] Estado de exploración por región y por celda (no explorado / visto / visitado) [M]
- [ ] Datos de exploración en el dominio (Explorer) desacoplados de la UI [M]
- [ ] Revelado progresivo alrededor del jugador con radio configurable en MapaConfig [M]
- [ ] Marcado de `visited` al cruzar el borde de una región (evento M09/M27) [M]
- [ ] Textura de niebla sobre el mapa completo (FogTextureRect opaco, modulate) [M]
- [ ] Textura de niebla aplicada también en el minimapa [M]
- [ ] Actualización solo en mosaicos sucios (sin regenerar la textura completa por frame) [M]
- [ ] Persistencia de exploración con M60 (bits por región/celda, no texturas) [C]
- [ ] Transición suave de revelado (Tween 300 ms) reducible por reduce_motion (M58) [M]
- [ ] Límites de región delineados dentro de la niebla (bordes visibles) [S]
- [ ] Niebla más clara en zonas visitadas y oscura en no exploradas [S]
- [ ] Sin revelado de interiores/mazmorras en el mapa de superficie [S]
- [ ] Compatible con la escala completa de la isla (varias islas M27 incluida) [C]
- [ ] Regeneración coherente tras carga de un save con exploración parcial [C]

## G. RF6 Pines del jugador (10)

- [ ] Crear pin en la posición actual del jugador (tecla/acción dedicada) [M]
- [ ] Crear pin en la posición del cursor sobre el mapa completo [M]
- [ ] Nombre del pin editable (diálogo de M53, caracteres M87) [M]
- [ ] Lista de pines con fecha de creación (M29) y navegación por foco [M]
- [ ] Límite máximo de pines (50 por defecto) con toast amable al alcanzarlo [S]
- [x] Persistencia de pines con M60 (PinData serializable) [C]
- [ ] Validación al cargar: pines fuera de rango se marcan como no disponibles sin borrarse [M]
- [ ] Pines visibles en minimapa y mapa completo con estilo diferenciado [M]
- [ ] Eliminar pin con confirmación amable y sin datos perdidos [S]
- [ ] Tooltip del pin con nombre y día de creación [S]

## H. RF7 Zoom y navegación del mapa (10)

- [ ] Zoom in/out con rueda del ratón (acciones M57) [S]
- [ ] Zoom con triggers o botones de gamepad [M]
- [ ] Pan arrastrando con ratón (drag) [S]
- [ ] Pan con palanca de gamepad a velocidad cómoda [M]
- [ ] Límites de zoom (0.6x-3x) para no perder contexto ni pixelar [S]
- [ ] Clamp del pan a los bordes del mapa [S]
- [ ] Zoom anclado al cursor (el punto bajo el cursor permanece estable) [M]
- [ ] Acción "volver al jugador" (`map_center_player`) [S]
- [ ] Escala de marcadores y nombres constante al zoom (solo cambia el cluster threshold) [M]
- [ ] Foco inicial en "volver al jugador" al abrir el mapa [S]

## I. RN Rendimiento y pocos draw calls (12)

- [ ] Textura base generada una sola vez y cacheada en disco (M60) [C]
- [ ] Minimapa reutiliza la textura base a baja resolución (sin bake propio) [M]
- [ ] Draw calls del mapa ≤ 3 con la pantalla abierta (base + niebla + pool) [M]
- [ ] Presupuesto mapa ≤ 5% del frame con Profiler (M61) en escena poblada [C]
- [ ] Update del mapa solo por señal, nunca por proceso por frame [M]
- [ ] Sin allocaciones en el flujo caliente (pool de sprites y tooltips) [M]
- [ ] Textura de niebla con modularidad de mosaicos (ImageTexture parcial) [M]
- [ ] Referencia del mapa con resolución equilibrada de memoria (máx 2048 px) [M]
- [ ] Compresión de la textura por M108 (Pipeline de assets) [M]
- [ ] Verificación en low-end (Steam Deck) [C]
- [ ] Test de stress: 100 aperturas/cierres sin fugas de memoria [C]
- [ ] Font subsetting por idioma (M88) para nombres de región [M]

## J. Diseño y arquitectura (12)

- [ ] MapManager como autoload de datos (sin conocimiento de UI) [M]
- [ ] MapData con RegionData, RegionState, PinData y MapConfig (Resources) [M]
- [ ] MinimapView y FullMapLayer como vistas de presentación de M53 [M]
- [ ] Explorer (niebla) como nodo de dominio con lógica pura de datos [M]
- [ ] MarkersCatalog con registro por eventos y clusterización [M]
- [ ] PlayerPinsService con CRUD y validación [M]
- [ ] Desacople total: dominio `res://mapa/core,data,fog,markers,pins` no importa UI [M]
- [ ] Acceso a M69 exclusivamente por interfaz Callable (sin imports de nodos) [M]
- [ ] ThemeUx, StyleBoxFlat, fuentes e iconos de M53/M88 (sin tema propio) [S]
- [ ] Santuario del desacople verificado estáticamente en CI (M01/M07) [M]
- [ ] Diagrama de arquitectura documentado en 03-Diseno [S]
- [ ] Flujos principales documentados (apertura, revelado, pin, viaje, cluster) [M]

## K. Integración con módulos (14)

- [ ] M09/M27: RegionData alimentado por regiones y biomas del terreno [C]
- [ ] M10: MapBaker genera la textura desde el chunk data (procesal estable por semilla) [C]
- [ ] M11: posición del jugador por evento a baja frecuencia (ícono + revelado) [M]
- [ ] M19: registro de casas de NPCs como marcadores dinámicos [M]
- [ ] M24/M25: POIs de templos y ruinas como marcadores [M]
- [ ] M28: ruta visual al destino de viaje [M]
- [ ] M29/M30: pausa coherente y fecha de pines [S]
- [ ] M39: tiendas registradas automáticamente como marcadores [M]
- [ ] M53: capa modal, foco, TooltipService, NotificationService y ThemeUx [M]
- [ ] M57: acciones map_toggle, zoom, pan, cierre, pin y centro [M]
- [ ] M58: reduce_motion, daltonismo, contraste AA y todo operable por foco [M]
- [ ] M60: persistencia de exploración, pines, preferencias y caché de textura [C]
- [ ] M63: bake en background con barra de progreso (AGENTS 8) [M]
- [ ] M69: destinos, desbloqueo y viaje por interfaz (sin acoplamiento) [M]

## L. Edge cases (16)

- [ ] Región sin explorar: no muestra detalles ni marcadores (spoiler prevention) [M]
- [ ] Marcador fuera de la vista del minimapa: flecha de borde apunta la dirección [M]
- [ ] Mapa abierto mientras el jugador se mueve (pausa): datos congelados y coherentes [M]
- [ ] Mundo aún generando o sin datos de región: mapa en blanco amable con progreso [M]
- [ ] Jugador en otra isla (M27): selector de islas exploradas y minimapa de la isla actual [C]
- [ ] Viaje rápido solicitado con diálogo abierto: petición encolada por pila M53 [M]
- [ ] Doble apertura del mapa (atajo repetido): idempotente, no rompe la pila [S]
- [ ] Zoom máximo con marcadores y pines superpuestos al jugador: legible [S]
- [ ] Cruce de región por barco (M28): revelado de golpe sin glitch (granos por mosaico) [M]
- [ ] Pines con coordenadas inválidas (mundo regenerado): marcados, no borrados [M]
- [ ] Cambio de resolución (M90) con el mapa abierto: layout sin cortes [M]
- [ ] Guardado/carga con exploración parcial: niebla consistente con el estado guardado [C]
- [ ] Save antiguo de una versión previa: datos migrados o marcados correctamente [M]
- [ ] Marcador de NPC que señala hacia una zona inexplorada: dirección incierta, sin spoiler [S]
- [ ] Tooltip del mapa abierto no bloquea el input del mundo (solo capa modal) [S]
- [ ] Foco perdido al cerrar el mapa: restaurado por UIManager (M53) con test de cierre/reapertura [M]

## M. Optimización (10)

- [ ] No regenerar la textura del mapa en cada apertura (caché persistente) [C]
- [ ] Bake incremental por secciones del mundo para no bloquear (M63) [C]
- [ ] Pool único de sprites de marcadores, clusters y pines en ambas vistas [M]
- [ ] Etiquetas de región refrescadas solo en cambios de zoom/pan (thresholds) [M]
- [ ] Culling simple de marcadores por región visible (bounds check) [M]
- [ ] Niebla actualizada solo en mosaicos sucios (dirty rects) [M]
- [ ] Medición documentada de draw calls y frame time con Profiler (M61) [C]
- [ ] Sin allocaciones por frame en el flujo de render del minimapa [M]
- [ ] Texturas comprimidas y dimensionadas por M108 [M]
- [ ] Verificación en escena poblada: pueblo + HUD + mapa completo + mundo voxel [C]

## N. Documentación y testings (14)

- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado (alternativas y decisiones) [S]
- [ ] 03-Diseno creado y firmado (arquitectura, flujos, contratos) [S]
- [ ] 04-Codigo creado y firmado (rutas, firmas GDScript, logs, Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado con 120+ ítems todos `[ ]` [S]
- [ ] Plan-actual copiado byte a byte idéntico a plan-inicial (hash verificado) [S]
- [ ] Plan de testings: apertura/cierre, zoom, pan, filtros, pines y niebla [M]
- [ ] Test de rendimiento con el mundo voxel completo cargado (≤ 5% frame) [C]
- [ ] Test de navegación completa con gamepad (30 minutos) [M]
- [ ] Test de viaje rápido end-to-end con M69 [C]
- [ ] Test de persistencia: exploración y pines tras guardar/cargar/reiniciar [C]
- [ ] Test de stress: 100 aperturas/cierres del mapa sin fugas ni glitches [C]
- [ ] Verificación de que no se modificaron archivos fuera de DOCUMENTACION/54-Mapa [S]
- [ ] Módulo declarado delegable para implementación en las Notas del Agente [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
## Iteración 1 (2026-09-02 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Datos: `data/map/map_data.json` — 9 POIs reales de la Isla Raíz (spawn/Chozavil/ruina/mesa/faro/templo_raíz/playa/plaza/ladera) con categorías y coordenadas dentro del mundo (radio 256)
- [x] `scripts/map/map_schema.gd` — valida POIs (id único, nombre, categorías permitidas, coords 0-512 dentro del mundo)
- [x] `scripts/map/map_data_service.gd` — MapDataService: POIs (RF3), niebla de guerra por región/celda + porcentaje (RF5), pines del jugador con señales (RF6), dentro_de_isla (geometría RIZ)
- [x] Test headless: 12/12 checks OK (RF3/RF5/RF6, geometría) — exit 0
- [?] Minimapa/Mapa completo UI (RF1/RF2), fast travel (RF4), zoom/navegación (RF7), atajo M57 (RF8): iter 2 con M53/M57/M69 (dueño: deepseek-v4-flash-vision-exp)
