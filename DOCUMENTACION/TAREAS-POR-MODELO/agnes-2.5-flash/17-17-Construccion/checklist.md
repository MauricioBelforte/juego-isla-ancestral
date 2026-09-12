# Tareas módulo 17 17-Construccion

**Estado:** 🔵 En curso

**Items pendientes:** 164

[ ] T-17-001: Definir el problema: construcción cozy sobre mundo voxel con rejilla de 1 m alineada a M08
[ ] T-17-002: Registrar dependencias: M08 (Mundo Voxel), M14 (Inventario) y relaciones M18, M25, M64, M58, M31, M32, M73, M92, M93, M71
[ ] T-17-003: RF1: modo construcción y modo decoración con entrada/salida rápida
[ ] T-17-004: RF2: rejilla voxel de 1 m alineada al mundo con snapping de 90°
[ ] T-17-005: RF3: previsualización fantasma con estado válido/inválido
[ ] T-17-006: RF4: rotación de piezas en pasos de 90°
[ ] T-17-007: RF5: elevación por plantas con revalidación en cada nivel
[ ] T-17-008: RF6: permisos de zona (edificable, protegida, narrativa, agua)
[ ] T-17-009: RF7: costo de recursos con verificación y descuento en M14
[ ] T-17-010: RF8: validación de ocupación, soporte y reglas por pieza
[ ] T-17-011: RF9-RF11: colocación con undo, copiar/mover/almacenar, demolición con devolución
[ ] T-17-012: RF12-RF14: catálogo de 12 familias de piezas, integración M18/M25/M64 y persistencia M58
[ ] T-17-013: P3: grid — rejilla voxel de 1 m alineada al origen global de M08
[ ] T-17-014: P4: snapping — ajuste de posición y rotación (90°) a la celda más cercana
[ ] T-17-015: P5: rotación — pasos de 90° en Y persistidos como entero 0-3
[ ] T-17-016: P6: elevación — planta base y subir/bajar con altura máxima por zona
[ ] T-17-017: P7: copia — tomar pieza existente como plantilla del fantasma
[ ] T-17-018: P8: mover objetos — desocupar celdas originales y revalidar destino
[ ] T-17-019: P9: recolocar — redondeo a rejilla y undo que devuelve la pieza a su celda
[ ] T-17-020: P10: almacenamiento — devolver piezas al inventario M14 sin pérdidas
[ ] T-17-021: P11: demolición — confirmación suave y retiro de la pieza del mundo
[ ] T-17-022: P14: objetos inválidos — toda regla fallida bloquea la colocación con motivo
[ ] T-17-023: P15: colisiones — piezas con colisión estática real; puertas con hueco navegable
[ ] T-17-024: P16: restricciones — reglas por pieza, topes por zona, alturas y parcelas ajenas
[ ] T-17-025: P17: paredes — bloques 1x1x1 con variantes de esquina y pilar
[ ] T-17-026: P18: pisos — losa 1x1x0.5 con soporte total para piezas encima
[ ] T-17-027: P19: techos — losa y cumbrera que exigen 2+ soportes en la celda
[ ] T-17-028: P20: puertas — marco 1x2 que exige pared y talla hueco navegable
[ ] T-17-029: P21: ventanas — 1x1 en pared, transparentes a la luz (M48)
[ ] T-17-030: P22: escaleras — bloque inclinado que exige apoyo y conecta plantas
[ ] T-17-031: P23: puentes — losa 1-4 celdas solo sobre agua dentro de zona permitida
[ ] T-17-032: P24: caminos — losa plana a nivel de césped sin bloqueo de paso
[ ] T-17-033: P25: cercas — valla de 0.7 m que marca límites sin encerrar al jugador
[ ] T-17-034: P26: iluminación — faroles con SpotLight/OmniLight ligados al ciclo M31
[ ] T-17-035: P27: muebles — camas, mesas, sillas y estanterías con interacción M18
[ ] T-17-036: P28: decoración — plantas, cuadros, alfombras y tótems de bajo costo
[ ] T-17-037: Abrir modo con herramienta de construcción (M13) o tecla asignada
[ ] T-17-038: Cerrar modo con la misma acción sin confirmación agresiva
[ ] T-17-039: HUD de modo con categorías del catálogo y costo de la pieza activa
[ ] T-17-040: El movimiento del jugador se suspende solo durante la colocación
[ ] T-17-041: El mundo continúa activo (NPC, clima, tiempo) mientras se construye
[ ] T-17-042: Selección de pieza por categorías: estructura, mobiliario, iluminación, decoración
[ ] T-17-043: Desbloqueos de piezas visibles en el catálogo (M70/M93)
[ ] T-17-044: Tutorial de construcción integrado y repetible (plan maestro línea 2549)
[ ] T-17-045: Indicador de celda destino resaltado sobre el mundo
[ ] T-17-046: Cero clicks rápidos duplicados: cooldown de confirmación de 150 ms
[ ] T-17-047: Paso de rejilla fijo de 1 m derivado del tamaño de voxel de M08
[ ] T-17-048: Origen de la rejilla idéntico al origen global del mundo voxel
[ ] T-17-049: Las piezas de NxN celdas ocupan exactamente su área completa en la rejilla
[ ] T-17-050: Compensación de medio voxel (offset 0.5 m) aplicada de forma consistente en preview y datos
[ ] T-17-051: Altura de planta: 1 m por nivel de bloque; habitaciones de 3 m en M18
[ ] T-17-052: Límites de mundo: la colocación se rechaza fuera del AABB jugable de M08
[ ] T-17-053: Conversión celda voxel ↔ posición mundial en una única utilidad compartida
[ ] T-17-054: La rejilla solo se calcula sobre terreno cargado (nunca sobre chunks vacíos)
[ ] T-17-055: El snap se redondea hacia abajo (floor) en dirección positiva del mundo
[ ] T-17-056: La rejilla es coherente tras guardar y cargar (misma celda ↔ misma posición)
[ ] T-17-057: Fantasma con mesh de la receta y material semi-transparente
[ ] T-17-058: Color verde si la colocación es válida y rojo si es inválida
[ ] T-17-059: El fantasma sigue al cursor con suavizado (lerp) sin saltos
[ ] T-17-060: La celda objetivo se recalculada solo si el cursor cambió (cache)
[ ] T-17-061: El fantasma refleja la rotación y elevación actuales en tiempo real
[ ] T-17-062: Se muestran en el HUD el costo y los motivos de rechazo (zona, soporte, ocupado, NPC, recursos)
[ ] T-17-063: El fantasma se oculta automáticamente fuera de zona o sobre terreno no cargado
[ ] T-17-064: Instancia única reutilizada del pool al entrar/salir del modo
[ ] T-17-065: LOD del fantasma: simplificación simple de malla a distancia > 40 m
[ ] T-17-066: El fantasma nunca colisiona con el mundo (capa de ignorancia de raycast)
[ ] T-17-067: Rotar la pieza en 4 pasos de 90° con la tecla dedicada
[ ] T-17-068: La validación se re-ejecuta con cada rotación (celdas afectadas cambian)
[ ] T-17-069: Subir/bajar la pieza una planta por pulsación con límite de altura
[ ] T-17-070: El fantasma muestra la pieza en el nivel elevado sin flotar visualmente mal
[ ] T-17-071: Copiar una pieza colocada a la rejilla conserva su rotación
[ ] T-17-072: Mover una pieza desocupa las celdas originales solo al confirmar
[ ] T-17-073: Al mover, los recursos no se re-cobran (solo se reubican)
[ ] T-17-074: Almacenar requiere inventario con espacio libre (M14)
[ ] T-17-075: Demolición con ventana de confirmación y preview de lo que se devuelve
[ ] T-17-076: Celda ocupada por otra pieza del jugador bloquea la colocación
[ ] T-17-077: Soporte inferior requerido (terreno, piso o techo según la superficie de la receta)
[ ] T-17-078: Regla por tipo de pieza declarada en PlacementRule y aplicada por el validador
[ ] T-17-079: Puerta exige pared contigua en la celda de instalación
[ ] T-17-080: Ventana exige pared contigua de al menos 1 celda
[ ] T-17-081: Escalera exige apoyo en piso o pared y no bloquea la circulación
[ ] T-17-082: Puente solo sobre agua (laguna/mar interior) y dentro de alcance de zona
[ ] T-17-083: Camino solo sobre césped/arena (nunca sobre roca o pendiente fuerte)
[ ] T-17-084: Techos exigen 2+ soportes (paredes o pilares) en las celdas de cobertura
[ ] T-17-085: Ninguna celda de la pieza puede solapar un NPC activo (consulta M64)
[ ] T-17-086: Las piezas no pueden bloquear la única salida de la zona de construcción
[ ] T-17-087: Las piezas de ruina M25 y parcelas de NPC son siempre no colocables ni demolidas
[ ] T-17-088: Zonas definidas como regiones AABB en celdas voxel (ZoneRegistry)
[ ] T-17-089: Permiso "edificable" por defecto en el terreno del jugador y parcelas habilitadas
[ ] T-17-090: Permiso "protegida" para parcelas de vecinos (M18) y áreas históricas
[ ] T-17-091: Permiso "narrativa" para terrenos bloqueados por progreso (M70)
[ ] T-17-092: Permiso "agua" exclusivo para puentes (validado antes de la regla de pieza)
[ ] T-17-093: Aviso claro con motivo al intentar colocar fuera de zona (fantasma rojo + texto)
[ ] T-17-094: Las zonas se serializan en M58 y se restauran antes de las piezas
[ ] T-17-095: Cambios de zona emiten señal a M64 (navmesh) y a M93 (proyectos)
[ ] T-17-096: Costo declarado por receta como diccionario item_id → cantidad
[ ] T-17-097: Verificación de recursos durante la preview: fantasma rojo con motivo al fallar
[ ] T-17-098: Descuento atómico al confirmar (nunca descuenta sin colocar)
[ ] T-17-099: Devolución exacta al deshacer (undo restaura todos los recursos consumidos)
[ ] T-17-100: El almacenamiento convierte la pieza en ítem del inventario sin perder receta
[ ] T-17-101: Los stacks de M14 se agrupan al devolver materiales sobrantes
[ ] T-17-102: Balance inicial de costos delegado a M92 con tabla de referencia en las recetas
[ ] T-17-103: Catálogo estructurado por categorías con filtro por modo construcción/decoración
[ ] T-17-104: Paredes: estándar, esquina, pilar y vano
[ ] T-17-105: Pisos: losa interior y terraza
[ ] T-17-106: Techos: losa plana y cumbrera
[ ] T-17-107: Puertas: madera y piedra con hueco navegable
[ ] T-17-108: Ventanas: marco simple y arco
[ ] T-17-109: Escaleras: recta de 1 celda y de 2 celdas
[ ] T-17-110: Puentes: losa de 1, 2, 3 y 4 celdas
[ ] T-17-111: Caminos: piedra, arena y césped apisonado
[ ] T-17-112: Cercas: madera baja, piedra y bambú
[ ] T-17-113: Iluminación: farol colgante, farol de piso y antorcha ancestral
[ ] T-17-114: Muebles y decoración: cama, mesa, silla, estantería, planta, cuadro, alfombra y tótem
[ ] T-17-115: M08: escrituras voxel por celdas con marca dirty en los chunks afectados
[ ] T-17-116: M08: los datos de pieza viven en capa voxel separada del terreno generado
[ ] T-17-117: M14: descuento, devolución y almacenamiento de piezas como ítems
[ ] T-17-118: M18: las ampliaciones de la casa usan proyectos de piezas de este módulo
[ ] T-17-119: M25: ruinas como contenido solo visual (deconstruible = false)
[ ] T-17-120: M64: señal obra_activa al entrar/salir y navmesh_delta al colocar/demoler
[ ] T-17-121: M73: recetas de festival temporales en el catálogo (devolucion = 0)
[ ] T-17-122: M58: serialización de lista de piezas y restauración idempotente
[ ] T-17-123: M31: faroles y luces conectados al ciclo día/noche
[ ] T-17-124: M32: la lluvia solo agrega VFX, nunca modifica o arruina piezas
[ ] T-17-125: M71: logros de construcción escuchan la señal pieza_colocada
[ ] T-17-126: M93: proyectos de construcción de meta larga cuentan piezas colocadas
[ ] T-17-127: Colocar fuera de zona: rechazo previo a la validación de soporte
[ ] T-17-128: Pieza encima de un NPC activo: rechazo temporal con motivo "NPC en el lugar"
[ ] T-17-129: Deshacer la última acción: restaura celdas y recursos exactamente
[ ] T-17-130: Redo tras deshacer solo disponible si no se realizó una acción intermedia
[ ] T-17-131: Pieza en el aire sin soporte: bloqueo con motivo de soporte
[ ] T-17-132: Colocar sobre techo: permitido solo si la superficie lo declara (techos con vegetación)
[ ] T-17-133: Cerrar el modo con el fantasma activo: se devuelve al pool y no queda estado inconsistente
[ ] T-17-134: Guardado a mitad de colocación (pieza fantasma activa): se descarta el fantasma, nada se persiste
[ ] T-17-135: Pieza en el límite del mundo: rechazo claro dentro del AABB jugable
[ ] T-17-136: Recursos insuficientes durante la preview: fantasma rojo y sin descuento
[ ] T-17-137: Doble confirmación rápida: cooldown y chequeo de celda repetida
[ ] T-17-138: Demolición de pieza bajo otra pieza: se devuelve el material de la de abajo según orden
[ ] T-17-139: Dirty flags por chunk: solo se regeneran los chunks tocados por la pieza
[ ] T-17-140: Sin regeneración global de mesh del mundo al construir
[ ] T-17-141: Raycast de colocación limitado a 1 por frame con cache de celda
[ ] T-17-142: Ocupación consultada en mapa de celdas en memoria (diccionario)
[ ] T-17-143: Materiales de pieza compartidos entre instancias (static batching de Godot)
[ ] T-17-144: Presupuesto medido con profiler: preview <= 1 ms por frame (M113)
[ ] T-17-145: 01-Requerimientos.md creado con problema, RF, NFR y criterios de aceptación
[ ] T-17-146: 02-Analisis.md creado con resolución de los 28 puntos y decisiones justificadas
[ ] T-17-147: 03-Diseno.md creado con arquitectura, flujos, contratos API e integraciones
[ ] T-17-148: 05-Checklist.md creado con 110+ ítems firmados (este archivo)
[ ] T-17-149: Copias idénticas de los 5 archivos en plan-actual/ para seguimiento futuro
[ ] T-17-150: Animación de colocación: transición breve fantasma → pieza real (escala/hammer)
[ ] T-17-151: Partículas de polvo al colocar y demoler (M51: VFX de construcción)
[ ] T-17-152: Sonido de colocación y de demolición que varía con el material (M43)
[ ] T-17-153: Sonido ambiental de obras: martilleo suave mientras el modo está activo
[ ] T-17-154: Aura de validación: destello suave verde al confirmar válido
[ ] T-17-155: Aviso amable (no punitivo) con vibración sutil al fallar la colocación
[ ] T-17-156: Los NPC cercanos miran la obra con curiosidad y comentan (M64 reacción cozy)
[ ] T-17-157: El jugador puede admirar sus construcciones desde la cámara sin salir del modo
[ ] T-17-158: Unit tests de costos: descuento, devolución y undo con recursos exactos
[ ] T-17-159: Tests de integración: colocar → guardar → cargar → restaurar idéntico (M58)
[ ] T-17-160: Tests de integración: la navmesh se actualiza con puertas y obras (M64)
[ ] T-17-161: Stress test M112: 200+ piezas en una zona sin caída de FPS ni memoria
[ ] T-17-162: Playtest de construcción (M113) con teclado y mando: flujo completo sin fricción
[ ] T-17-163: Recorrido M114: construir y decorar la casa del jugador (M18) sin errores de consola
[ ] T-17-164: QA final: 0 errores en Play Mode, 0 excepciones al entrar/salir del modo repetidamente
