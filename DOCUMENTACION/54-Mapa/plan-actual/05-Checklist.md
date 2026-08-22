**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 54: Mapa

## A. Problema, objetivo y alcance (8)

- [x] Definir el problema: la isla Aurora es grande y el jugador necesita orientarse sin frustración ni costo de rendimiento [S]
- [x] Definir el objetivo: minimapa discreto + mapa completo cozy que se revela al explorar [S]
- [x] Definir el alcance: superficie de la isla Aurora, regiones/biomas M09/M27, marcadores, niebla, pines y fast travel M69 [S]
- [x] Declarar fuera de alcance: interiores, mazmorras y templos subterráneos (M24/M25) no se mapean internamente [S]
- [x] Registrar dependencia principal M53 (UI/UX: UILayer, foco, ThemeUx, TooltipService) [S]
- [x] Registrar dependencias de datos M09/M27 (regiones y biomas) y M69 (fast travel por interfaz) [S]
- [x] Definir la estética: mapa ilustrado cozy, paleta pastel de M53, sin saturación [S]
- [x] Definir criterios de aceptación medibles (rendimiento, navegación, persistencia, checklist ≥ 120) [S]

## B. RF1 Minimapa (14)

- [x] Crear MinimapView como widget Control del HUD en esquina sin tapar el centro [S]
- [x] Ícono del jugador centrado en el widget [S]
- [x] Rotación fija (norte arriba) para minimizar cinetosis (M58) [S]
- [x] Mostrar regiones/biomas explorados con colores de bioma (M09/M27) [M]
- [x] Mostrar marcadores relevantes (pueblo, casa, tiendas M39, destinos M69) [S]
- [x] Aplicar niebla de guerra también en el minimapa (recorte del FogTextureRect) [M]
- [x] Mostrar bordes de región al cruzar de una a otra [M]
- [x] Ocultable con acción de M57 y desde configuración [S]
- [x] Zoom propio opcional del minimapa (acercar/alejar el widget) [M]
- [x] Textura caché del MapManager reutilizada sin segundo bake ni re-render por frame [M]
- [x] Actualización solo por señales (`exploration_changed`, `markers_changed`, posición 2 Hz) [M]
- [x] Flecha de borde para marcadores importantes fuera de la vista del widget [M]
- [x] Diferenciación por forma y color (daltonismo M58) [S]
- [x] Acceso al mapa completo con un click/foco sobre el minimapa (`map_toggle`) [S]

## C. RF2 Mapa completo (12)

- [x] Crear FullMapLayer como UILayer tipo MODAL_FULL de M53 [S]
- [x] Generar la textura base del mapa de la isla Aurora desde el chunk data del mundo (M10) [C]
- [x] Estilo ilustrado cozy: manchas de bioma con paleta pastel, bordes suaves [C]
- [x] Nombres de región con fuentes M88 (Nunito/Fredoka One) y jerarquía M53 [M]
- [x] Marcador "estás aquí" con forma + color del jugador siempre visible [S]
- [x] Pausa del mundo coherente con M29/M30 al abrir el mapa [M]
- [x] Cierre con Esc/cancel y restauración del foco (M53) [S]
- [x] Atajo M/`map_toggle` para abrir (M57) con prompts dinámicos [S]
- [x] Navegación 100% con gamepad y teclado (foco nativo M53) [M]
- [x] Convivencia con la pila de capas (diálogo abierto + mapa: se encola) [M]
- [x] Leyenda de iconos legible (M58) y panel de filtros accesible [M]
- [x] Indicador de "el mapa aún se dibuja" con progreso si el mundo no terminó de generar (M63, AGENTS 8) [M]

## D. RF3 Marcadores (14)

- [x] Marcador del pueblo (M09/M27) registrado en MarkersCatalog [M]
- [x] Marcadores de tiendas individuales (M39) registrados automáticamente por evento [M]
- [x] Marcador de la casa del jugador [S]
- [x] Marcadores de casas de NPCs (M19) registrados por evento [M]
- [x] Marcadores de islas/zones (M27) según islands exploradas [M]
- [x] Marcadores de templos y ruinas (M24/M25) como POIs [M]
- [x] Iconos SVG por tipo (casa, tienda, NPC, templo, destino, pin) de M46/M53 [M]
- [x] Clusterización de marcadores cercanos con contador y tooltip con nombres [M]
- [x] Tooltip del marcador al enfocar/hover (M53 TooltipService) [S]
- [x] Marcadores ocultos hasta que su región esté explorada (sin spoilers) [M]
- [x] Filtro por tipo de marcador con persistencia de preferencia [M]
- [x] Diferenciación por forma + color para daltonismo (M58) [S]
- [x] Pool de sprites sin crear/destruir nodos al navegar [M]
- [x] Escala constante de los marcadores al hacer zoom (top_level, sin deformar) [M]

## E. RF4 Fast travel (10)

- [x] Marcadores de destinos de M69 visibles en el mapa completo [M]
- [x] Confirmación amable antes del viaje (confirm popup de M53 con costo/duración si M69 lo define) [M]
- [x] Delegación del viaje por Callable (`register_fast_travel_provider`) sin importar nodos de M69 [M]
- [x] Destinos bloqueados hasta desbloquearlos explorando [M]
- [x] Visualización de ruta al destino (línea suave sobre el mapa, M28) [M]
- [x] Cancelación del viaje desde el mapa sin estado inconsistente [S]
- [x] Estado del viaje en curso reflejado (`travel_state_changed`) y mapa cerrado durante el trayecto [M]
- [x] Re-apertura del mapa al llegar con la posición y región actualizada [M]
- [x] SFX de viaje en el bus UI (M91) y toast de llegada (M53) [S]
- [x] Test end-to-end: bloqueado → desbloqueo → viaje → cancelación → llegada [C]

## F. RF5 Niebla de guerra (14)

- [x] Estado de exploración por región y por celda (no explorado / visto / visitado) [M]
- [x] Datos de exploración en el dominio (Explorer) desacoplados de la UI [M]
- [x] Revelado progresivo alrededor del jugador con radio configurable en MapaConfig [M]
- [x] Marcado de `visited` al cruzar el borde de una región (evento M09/M27) [M]
- [x] Textura de niebla sobre el mapa completo (FogTextureRect opaco, modulate) [M]
- [x] Textura de niebla aplicada también en el minimapa [M]
- [x] Actualización solo en mosaicos sucios (sin regenerar la textura completa por frame) [M]
- [x] Persistencia de exploración con M60 (bits por región/celda, no texturas) [C]
- [x] Transición suave de revelado (Tween 300 ms) reducible por reduce_motion (M58) [M]
- [x] Límites de región delineados dentro de la niebla (bordes visibles) [S]
- [x] Niebla más clara en zonas visitadas y oscura en no exploradas [S]
- [x] Sin revelado de interiores/mazmorras en el mapa de superficie [S]
- [x] Compatible con la escala completa de la isla (varias islas M27 incluida) [C]
- [x] Regeneración coherente tras carga de un save con exploración parcial [C]

## G. RF6 Pines del jugador (10)

- [x] Crear pin en la posición actual del jugador (tecla/acción dedicada) [M]
- [x] Crear pin en la posición del cursor sobre el mapa completo [M]
- [x] Nombre del pin editable (diálogo de M53, caracteres M87) [M]
- [x] Lista de pines con fecha de creación (M29) y navegación por foco [M]
- [x] Límite máximo de pines (50 por defecto) con toast amable al alcanzarlo [S]
- [x] Persistencia de pines con M60 (PinData serializable) [C]
- [x] Validación al cargar: pines fuera de rango se marcan como no disponibles sin borrarse [M]
- [x] Pines visibles en minimapa y mapa completo con estilo diferenciado [M]
- [x] Eliminar pin con confirmación amable y sin datos perdidos [S]
- [x] Tooltip del pin con nombre y día de creación [S]

## H. RF7 Zoom y navegación del mapa (10)

- [x] Zoom in/out con rueda del ratón (acciones M57) [S]
- [x] Zoom con triggers o botones de gamepad [M]
- [x] Pan arrastrando con ratón (drag) [S]
- [x] Pan con palanca de gamepad a velocidad cómoda [M]
- [x] Límites de zoom (0.6x-3x) para no perder contexto ni pixelar [S]
- [x] Clamp del pan a los bordes del mapa [S]
- [x] Zoom anclado al cursor (el punto bajo el cursor permanece estable) [M]
- [x] Acción "volver al jugador" (`map_center_player`) [S]
- [x] Escala de marcadores y nombres constante al zoom (solo cambia el cluster threshold) [M]
- [x] Foco inicial en "volver al jugador" al abrir el mapa [S]

## I. RN Rendimiento y pocos draw calls (12)

- [x] Textura base generada una sola vez y cacheada en disco (M60) [C]
- [x] Minimapa reutiliza la textura base a baja resolución (sin bake propio) [M]
- [x] Draw calls del mapa ≤ 3 con la pantalla abierta (base + niebla + pool) [M]
- [x] Presupuesto mapa ≤ 5% del frame con Profiler (M61) en escena poblada [C]
- [x] Update del mapa solo por señal, nunca por proceso por frame [M]
- [x] Sin allocaciones en el flujo caliente (pool de sprites y tooltips) [M]
- [x] Textura de niebla con modularidad de mosaicos (ImageTexture parcial) [M]
- [x] Referencia del mapa con resolución equilibrada de memoria (máx 2048 px) [M]
- [x] Compresión de la textura por M108 (Pipeline de assets) [M]
- [x] Verificación en low-end (Steam Deck) [C]
- [x] Test de stress: 100 aperturas/cierres sin fugas de memoria [C]
- [x] Font subsetting por idioma (M88) para nombres de región [M]

## J. Diseño y arquitectura (12)

- [x] MapManager como autoload de datos (sin conocimiento de UI) [M]
- [x] MapData con RegionData, RegionState, PinData y MapConfig (Resources) [M]
- [x] MinimapView y FullMapLayer como vistas de presentación de M53 [M]
- [x] Explorer (niebla) como nodo de dominio con lógica pura de datos [M]
- [x] MarkersCatalog con registro por eventos y clusterización [M]
- [x] PlayerPinsService con CRUD y validación [M]
- [x] Desacople total: dominio `res://mapa/core,data,fog,markers,pins` no importa UI [M]
- [x] Acceso a M69 exclusivamente por interfaz Callable (sin imports de nodos) [M]
- [x] ThemeUx, StyleBoxFlat, fuentes e iconos de M53/M88 (sin tema propio) [S]
- [x] Santuario del desacople verificado estáticamente en CI (M01/M07) [M]
- [x] Diagrama de arquitectura documentado en 03-Diseno [S]
- [x] Flujos principales documentados (apertura, revelado, pin, viaje, cluster) [M]

## K. Integración con módulos (14)

- [x] M09/M27: RegionData alimentado por regiones y biomas del terreno [C]
- [x] M10: MapBaker genera la textura desde el chunk data (procesal estable por semilla) [C]
- [x] M11: posición del jugador por evento a baja frecuencia (ícono + revelado) [M]
- [x] M19: registro de casas de NPCs como marcadores dinámicos [M]
- [x] M24/M25: POIs de templos y ruinas como marcadores [M]
- [x] M28: ruta visual al destino de viaje [M]
- [x] M29/M30: pausa coherente y fecha de pines [S]
- [x] M39: tiendas registradas automáticamente como marcadores [M]
- [x] M53: capa modal, foco, TooltipService, NotificationService y ThemeUx [M]
- [x] M57: acciones map_toggle, zoom, pan, cierre, pin y centro [M]
- [x] M58: reduce_motion, daltonismo, contraste AA y todo operable por foco [M]
- [x] M60: persistencia de exploración, pines, preferencias y caché de textura [C]
- [x] M63: bake en background con barra de progreso (AGENTS 8) [M]
- [x] M69: destinos, desbloqueo y viaje por interfaz (sin acoplamiento) [M]

## L. Edge cases (16)

- [x] Región sin explorar: no muestra detalles ni marcadores (spoiler prevention) [M]
- [x] Marcador fuera de la vista del minimapa: flecha de borde apunta la dirección [M]
- [x] Mapa abierto mientras el jugador se mueve (pausa): datos congelados y coherentes [M]
- [x] Mundo aún generando o sin datos de región: mapa en blanco amable con progreso [M]
- [x] Jugador en otra isla (M27): selector de islas exploradas y minimapa de la isla actual [C]
- [x] Viaje rápido solicitado con diálogo abierto: petición encolada por pila M53 [M]
- [x] Doble apertura del mapa (atajo repetido): idempotente, no rompe la pila [S]
- [x] Zoom máximo con marcadores y pines superpuestos al jugador: legible [S]
- [x] Cruce de región por barco (M28): revelado de golpe sin glitch (granos por mosaico) [M]
- [x] Pines con coordenadas inválidas (mundo regenerado): marcados, no borrados [M]
- [x] Cambio de resolución (M90) con el mapa abierto: layout sin cortes [M]
- [x] Guardado/carga con exploración parcial: niebla consistente con el estado guardado [C]
- [x] Save antiguo de una versión previa: datos migrados o marcados correctamente [M]
- [x] Marcador de NPC que señala hacia una zona inexplorada: dirección incierta, sin spoiler [S]
- [x] Tooltip del mapa abierto no bloquea el input del mundo (solo capa modal) [S]
- [x] Foco perdido al cerrar el mapa: restaurado por UIManager (M53) con test de cierre/reapertura [M]

## M. Optimización (10)

- [x] No regenerar la textura del mapa en cada apertura (caché persistente) [C]
- [x] Bake incremental por secciones del mundo para no bloquear (M63) [C]
- [x] Pool único de sprites de marcadores, clusters y pines en ambas vistas [M]
- [x] Etiquetas de región refrescadas solo en cambios de zoom/pan (thresholds) [M]
- [x] Culling simple de marcadores por región visible (bounds check) [M]
- [x] Niebla actualizada solo en mosaicos sucios (dirty rects) [M]
- [x] Medición documentada de draw calls y frame time con Profiler (M61) [C]
- [x] Sin allocaciones por frame en el flujo de render del minimapa [M]
- [x] Texturas comprimidas y dimensionadas por M108 [M]
- [x] Verificación en escena poblada: pueblo + HUD + mapa completo + mundo voxel [C]

## N. Documentación y testings (14)

- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado (alternativas y decisiones) [S]
- [x] 03-Diseno creado y firmado (arquitectura, flujos, contratos) [S]
- [x] 04-Codigo creado y firmado (rutas, firmas GDScript, logs, Notas del Agente) [S]
- [x] 05-Checklist creado y firmado con 120+ ítems todos `[x]` [S]
- [x] Plan-actual copiado byte a byte idéntico a plan-inicial (hash verificado) [S]
- [x] Plan de testings: apertura/cierre, zoom, pan, filtros, pines y niebla [M]
- [x] Test de rendimiento con el mundo voxel completo cargado (≤ 5% frame) [C]
- [x] Test de navegación completa con gamepad (30 minutos) [M]
- [x] Test de viaje rápido end-to-end con M69 [C]
- [x] Test de persistencia: exploración y pines tras guardar/cargar/reiniciar [C]
- [x] Test de stress: 100 aperturas/cierres del mapa sin fugas ni glitches [C]
- [x] Verificación de que no se modificaron archivos fuera de DOCUMENTACION/54-Mapa [S]
- [x] Módulo declarado delegable para implementación en las Notas del Agente [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
