# Tareas módulo 54 54-Mapa

**Estado:** 🟡 Con dudas (iter. 2 minimap visual)

**Items pendientes:** 93

[ ] T-54-001: Definir el problema: la isla Aurora es grande y el jugador necesita orientarse sin frustración ni costo de rendimiento
[ ] T-54-002: Definir el alcance: superficie de la isla Aurora, regiones/biomas M09/M27, marcadores, niebla, pines y fast travel M69
[ ] T-54-003: Registrar dependencias de datos M09/M27 (regiones y biomas) y M69 (fast travel por interfaz)
[ ] T-54-004: 
[ ] T-54-005: Mostrar regiones/biomas explorados con colores de bioma (M09/M27)
[ ] T-54-006: Mostrar marcadores relevantes (pueblo, casa, tiendas M39, destinos M69)
[ ] T-54-007: Mostrar bordes de región al cruzar de una a otra
[ ] T-54-008: Flecha de borde para marcadores importantes fuera de la vista del widget
[ ] T-54-009: Estilo ilustrado cozy: manchas de bioma con paleta pastel, bordes suaves
[ ] T-54-010: Nombres de región con fuentes M88 (Nunito/Fredoka One) y jerarquía M53
[ ] T-54-011: Marcador "estás aquí" con forma + color del jugador siempre visible
[ ] T-54-012: Cierre con Esc/cancel y restauración del foco (M53)
[ ] T-54-013: Navegación 100% con gamepad y teclado (foco nativo M53)
[ ] T-54-014: Leyenda de iconos legible (M58) y panel de filtros accesible
[ ] T-54-015: Marcadores de tiendas individuales (M39) registrados automáticamente por evento
[ ] T-54-016: Marcador de la casa del jugador
[ ] T-54-017: Marcadores de casas de NPCs (M19) registrados por evento
[ ] T-54-018: Marcadores de islas/zones (M27) según islands exploradas
[ ] T-54-019: Iconos SVG por tipo (casa, tienda, NPC, templo, destino, pin) de M46/M53
[ ] T-54-020: Diferenciación por forma + color para daltonismo (M58)
[ ] T-54-021: Pool de sprites sin crear/destruir nodos al navegar
[ ] T-54-022: Escala constante de los marcadores al hacer zoom (top_level, sin deformar)
[ ] T-54-023: Confirmación amable antes del viaje (confirm popup de M53 con costo/duración si M69 lo define)
[ ] T-54-024: Delegación del viaje por Callable (`register_fast_travel_provider`) sin importar nodos de M69
[ ] T-54-025: Destinos bloqueados hasta desbloquearlos explorando
[ ] T-54-026: SFX de viaje en el bus UI (M91) y toast de llegada (M53)
[ ] T-54-027: Test end-to-end: bloqueado → desbloqueo → viaje → cancelación → llegada
[ ] T-54-028: Estado de exploración por región y por celda (no explorado / visto / visitado)
[ ] T-54-029: Datos de exploración en el dominio (Explorer) desacoplados de la UI
[ ] T-54-030: Marcado de `visited` al cruzar el borde de una región (evento M09/M27)
[ ] T-54-031: Actualización solo en mosaicos sucios (sin regenerar la textura completa por frame)
[ ] T-54-032: Transición suave de revelado (Tween 300 ms) reducible por reduce_motion (M58)
[ ] T-54-033: Límites de región delineados dentro de la niebla (bordes visibles)
[ ] T-54-034: Niebla más clara en zonas visitadas y oscura en no exploradas
[ ] T-54-035: Compatible con la escala completa de la isla (varias islas M27 incluida)
[ ] T-54-036: Regeneración coherente tras carga de un save con exploración parcial
[ ] T-54-037: Crear pin en la posición actual del jugador (tecla/acción dedicada)
[ ] T-54-038: Nombre del pin editable (diálogo de M53, caracteres M87)
[ ] T-54-039: Lista de pines con fecha de creación (M29) y navegación por foco
[ ] T-54-040: Límite máximo de pines (50 por defecto) con toast amable al alcanzarlo
[ ] T-54-041: Eliminar pin con confirmación amable y sin datos perdidos
[ ] T-54-042: Tooltip del pin con nombre y día de creación
[ ] T-54-043: Zoom in/out con rueda del ratón (acciones M57)
[ ] T-54-044: Zoom con triggers o botones de gamepad
[ ] T-54-045: Pan arrastrando con ratón (drag)
[ ] T-54-046: Pan con palanca de gamepad a velocidad cómoda
[ ] T-54-047: Límites de zoom (0.6x-3x) para no perder contexto ni pixelar
[ ] T-54-048: Zoom anclado al cursor (el punto bajo el cursor permanece estable)
[ ] T-54-049: Escala de marcadores y nombres constante al zoom (solo cambia el cluster threshold)
[ ] T-54-050: Textura base generada una sola vez y cacheada en disco (M60)
[ ] T-54-051: Sin allocaciones en el flujo caliente (pool de sprites y tooltips)
[ ] T-54-052: Textura de niebla con modularidad de mosaicos (ImageTexture parcial)
[ ] T-54-053: Compresión de la textura por M108 (Pipeline de assets)
[ ] T-54-054: Verificación en low-end (Steam Deck)
[ ] T-54-055: Test de stress: 100 aperturas/cierres sin fugas de memoria
[ ] T-54-056: Font subsetting por idioma (M88) para nombres de región
[ ] T-54-057: Explorer (niebla) como nodo de dominio con lógica pura de datos
[ ] T-54-058: Acceso a M69 exclusivamente por interfaz Callable (sin imports de nodos)
[ ] T-54-059: ThemeUx, StyleBoxFlat, fuentes e iconos de M53/M88 (sin tema propio)
[ ] T-54-060: Santuario del desacople verificado estáticamente en CI (M01/M07)
[ ] T-54-061: Diagrama de arquitectura documentado en 03-Diseno
[ ] T-54-062: Flujos principales documentados (apertura, revelado, pin, viaje, cluster)
[ ] T-54-063: M09/M27: RegionData alimentado por regiones y biomas del terreno
[ ] T-54-064: M11: posición del jugador por evento a baja frecuencia (ícono + revelado)
[ ] T-54-065: M19: registro de casas de NPCs como marcadores dinámicos
[ ] T-54-066: M28: ruta visual al destino de viaje
[ ] T-54-067: M29/M30: pausa coherente y fecha de pines
[ ] T-54-068: M39: tiendas registradas automáticamente como marcadores
[ ] T-54-069: M58: reduce_motion, daltonismo, contraste AA y todo operable por foco
[ ] T-54-070: M63: bake en background con barra de progreso (AGENTS 8)
[ ] T-54-071: M69: destinos, desbloqueo y viaje por interfaz (sin acoplamiento)
[ ] T-54-072: Viaje rápido solicitado con diálogo abierto: petición encolada por pila M53
[ ] T-54-073: Zoom máximo con marcadores y pines superpuestos al jugador: legible
[ ] T-54-074: Cruce de región por barco (M28): revelado de golpe sin glitch (granos por mosaico)
[ ] T-54-075: Pines con coordenadas inválidas (mundo regenerado): marcados, no borrados
[ ] T-54-076: Guardado/carga con exploración parcial: niebla consistente con el estado guardado
[ ] T-54-077: Save antiguo de una versión previa: datos migrados o marcados correctamente
[ ] T-54-078: Bake incremental por secciones del mundo para no bloquear (M63)
[ ] T-54-079: Pool único de sprites de marcadores, clusters y pines en ambas vistas
[ ] T-54-080: Etiquetas de región refrescadas solo en cambios de zoom/pan (thresholds)
[ ] T-54-081: Culling simple de marcadores por región visible (bounds check)
[ ] T-54-082: Niebla actualizada solo en mosaicos sucios (dirty rects)
[ ] T-54-083: Medición documentada de draw calls y frame time con Profiler (M61)
[ ] T-54-084: Texturas comprimidas y dimensionadas por M108
[ ] T-54-085: 01-Requerimientos creado y firmado
[ ] T-54-086: 02-Analisis creado y firmado (alternativas y decisiones)
[ ] T-54-087: 03-Diseno creado y firmado (arquitectura, flujos, contratos)
[ ] T-54-088: 05-Checklist creado y firmado con 120+ ítems todos `[ ]`
[ ] T-54-089: Plan-actual copiado byte a byte idéntico a plan-inicial (hash verificado)
[ ] T-54-090: Test de rendimiento con el mundo voxel completo cargado (≤ 5% frame)
[ ] T-54-091: Test de navegación completa con gamepad (30 minutos)
[ ] T-54-092: Test de viaje rápido end-to-end con M69
[ ] T-54-093: Minimapa/Mapa completo UI (RF1/RF2), fast travel (RF4), zoom/navegación (RF7), atajo M57 (RF8): iter 2 con M53/M57/M69 (dueño: deepseek-v4-flash-visio
