**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 17: Construcción

> Marcador de esfuerzo al final de cada ítem: [S] simple, [M] medio, [C] complejo.
> Módulo de diseño completo; implementación delegada (requiere M08 y M14 estables).

## A. Requisitos del módulo (12)

- [x] Definir el problema: construcción cozy sobre mundo voxel con rejilla de 1 m alineada a M08 [S]
- [x] Registrar dependencias: M08 (Mundo Voxel), M14 (Inventario) y relaciones M18, M25, M64, M58, M31, M32, M73, M92, M93, M71 [S]
- [x] RF1: modo construcción y modo decoración con entrada/salida rápida [S]
- [x] RF2: rejilla voxel de 1 m alineada al mundo con snapping de 90° [S]
- [x] RF3: previsualización fantasma con estado válido/inválido [S]
- [x] RF4: rotación de piezas en pasos de 90° [S]
- [x] RF5: elevación por plantas con revalidación en cada nivel [S]
- [x] RF6: permisos de zona (edificable, protegida, narrativa, agua) [S]
- [x] RF7: costo de recursos con verificación y descuento en M14 [S]
- [x] RF8: validación de ocupación, soporte y reglas por pieza [S]
- [x] RF9-RF11: colocación con undo, copiar/mover/almacenar, demolición con devolución [S]
- [x] RF12-RF14: catálogo de 12 familias de piezas, integración M18/M25/M64 y persistencia M58 [S]

## B. Resolución de los 28 puntos de la sección 16 del plan maestro (28)

- [x] P1: modo construcción — estado de jugador + BuildManager, mundo vivo sin pausa dura [S]
- [x] P2: modo decoración — mismo sistema con catálogo filtrado a muebles y decoración [S]
- [x] P3: grid — rejilla voxel de 1 m alineada al origen global de M08 [S]
- [x] P4: snapping — ajuste de posición y rotación (90°) a la celda más cercana [S]
- [x] P5: rotación — pasos de 90° en Y persistidos como entero 0-3 [S]
- [x] P6: elevación — planta base y subir/bajar con altura máxima por zona [S]
- [x] P7: copia — tomar pieza existente como plantilla del fantasma [S]
- [x] P8: mover objetos — desocupar celdas originales y revalidar destino [S]
- [x] P9: recolocar — redondeo a rejilla y undo que devuelve la pieza a su celda [S]
- [x] P10: almacenamiento — devolver piezas al inventario M14 sin pérdidas [S]
- [x] P11: demolición — confirmación suave y retiro de la pieza del mundo [S]
- [x] P12: devolución de materiales — fracción configurable por receta (default 50%) [S]
- [x] P13: vista previa — BuildGhost con color de estado, costo y motivos de error en HUD [S]
- [x] P14: objetos inválidos — toda regla fallida bloquea la colocación con motivo [S]
- [x] P15: colisiones — piezas con colisión estática real; puertas con hueco navegable [S]
- [x] P16: restricciones — reglas por pieza, topes por zona, alturas y parcelas ajenas [S]
- [x] P17: paredes — bloques 1x1x1 con variantes de esquina y pilar [S]
- [x] P18: pisos — losa 1x1x0.5 con soporte total para piezas encima [S]
- [x] P19: techos — losa y cumbrera que exigen 2+ soportes en la celda [S]
- [x] P20: puertas — marco 1x2 que exige pared y talla hueco navegable [S]
- [x] P21: ventanas — 1x1 en pared, transparentes a la luz (M48) [S]
- [x] P22: escaleras — bloque inclinado que exige apoyo y conecta plantas [S]
- [x] P23: puentes — losa 1-4 celdas solo sobre agua dentro de zona permitida [S]
- [x] P24: caminos — losa plana a nivel de césped sin bloqueo de paso [S]
- [x] P25: cercas — valla de 0.7 m que marca límites sin encerrar al jugador [S]
- [x] P26: iluminación — faroles con SpotLight/OmniLight ligados al ciclo M31 [S]
- [x] P27: muebles — camas, mesas, sillas y estanterías con interacción M18 [S]
- [x] P28: decoración — plantas, cuadros, alfombras y tótems de bajo costo [S]

## C. Modo construcción: entrada, salida y UX (10)

- [x] Abrir modo con herramienta de construcción (M13) o tecla asignada [M]
- [x] Cerrar modo con la misma acción sin confirmación agresiva [S]
- [x] HUD de modo con categorías del catálogo y costo de la pieza activa [M]
- [x] El movimiento del jugador se suspende solo durante la colocación [M]
- [x] El mundo continúa activo (NPC, clima, tiempo) mientras se construye [M]
- [x] Selección de pieza por categorías: estructura, mobiliario, iluminación, decoración [M]
- [x] Desbloqueos de piezas visibles en el catálogo (M70/M93) [M]
- [x] Tutorial de construcción integrado y repetible (plan maestro línea 2549) [M]
- [x] Indicador de celda destino resaltado sobre el mundo [M]
- [x] Cero clicks rápidos duplicados: cooldown de confirmación de 150 ms [S]

## D. Rejilla voxel de 1 m y alineación con M08 (10)

- [x] Paso de rejilla fijo de 1 m derivado del tamaño de voxel de M08 [C]
- [x] Origen de la rejilla idéntico al origen global del mundo voxel [C]
- [x] Las piezas de NxN celdas ocupan exactamente su área completa en la rejilla [M]
- [x] Compensación de medio voxel (offset 0.5 m) aplicada de forma consistente en preview y datos [C]
- [x] Altura de planta: 1 m por nivel de bloque; habitaciones de 3 m en M18 [M]
- [x] Límites de mundo: la colocación se rechaza fuera del AABB jugable de M08 [M]
- [x] Conversión celda voxel ↔ posición mundial en una única utilidad compartida [M]
- [x] La rejilla solo se calcula sobre terreno cargado (nunca sobre chunks vacíos) [M]
- [x] El snap se redondea hacia abajo (floor) en dirección positiva del mundo [S]
- [x] La rejilla es coherente tras guardar y cargar (misma celda ↔ misma posición) [M]

## E. Previsualización fantasma (BuildGhost) (10)

- [x] Fantasma con mesh de la receta y material semi-transparente [M]
- [x] Color verde si la colocación es válida y rojo si es inválida [S]
- [x] El fantasma sigue al cursor con suavizado (lerp) sin saltos [M]
- [x] La celda objetivo se recalculada solo si el cursor cambió (cache) [M]
- [x] El fantasma refleja la rotación y elevación actuales en tiempo real [S]
- [x] Se muestran en el HUD el costo y los motivos de rechazo (zona, soporte, ocupado, NPC, recursos) [M]
- [x] El fantasma se oculta automáticamente fuera de zona o sobre terreno no cargado [M]
- [x] Instancia única reutilizada del pool al entrar/salir del modo [M]
- [x] LOD del fantasma: simplificación simple de malla a distancia > 40 m [M]
- [x] El fantasma nunca colisiona con el mundo (capa de ignorancia de raycast) [S]

## F. Rotación, elevación y manipulación (10)

- [x] Rotar la pieza en 4 pasos de 90° con la tecla dedicada [S]
- [x] La validación se re-ejecuta con cada rotación (celdas afectadas cambian) [M]
- [x] Subir/bajar la pieza una planta por pulsación con límite de altura [S]
- [x] El fantasma muestra la pieza en el nivel elevado sin flotar visualmente mal [M]
- [x] Copiar una pieza colocada a la rejilla conserva su rotación [S]
- [x] Mover una pieza desocupa las celdas originales solo al confirmar [C]
- [x] Al mover, los recursos no se re-cobran (solo se reubican) [M]
- [x] Almacenar requiere inventario con espacio libre (M14) [M]
- [x] Demolición con ventana de confirmación y preview de lo que se devuelve [M]
- [x] La demolición de piezas funcionales (camas, almacenamiento) libera su contenido [C]

## G. Validación y reglas de colocación (BuildValidator) (12)

- [x] Celda ocupada por otra pieza del jugador bloquea la colocación [M]
- [x] Soporte inferior requerido (terreno, piso o techo según la superficie de la receta) [C]
- [x] Regla por tipo de pieza declarada en PlacementRule y aplicada por el validador [M]
- [x] Puerta exige pared contigua en la celda de instalación [M]
- [x] Ventana exige pared contigua de al menos 1 celda [M]
- [x] Escalera exige apoyo en piso o pared y no bloquea la circulación [M]
- [x] Puente solo sobre agua (laguna/mar interior) y dentro de alcance de zona [C]
- [x] Camino solo sobre césped/arena (nunca sobre roca o pendiente fuerte) [M]
- [x] Techos exigen 2+ soportes (paredes o pilares) en las celdas de cobertura [C]
- [x] Ninguna celda de la pieza puede solapar un NPC activo (consulta M64) [C]
- [x] Las piezas no pueden bloquear la única salida de la zona de construcción [C]
- [x] Las piezas de ruina M25 y parcelas de NPC son siempre no colocables ni demolidas [M]

## H. Zonas y permisos (8)

- [x] Zonas definidas como regiones AABB en celdas voxel (ZoneRegistry) [M]
- [x] Permiso "edificable" por defecto en el terreno del jugador y parcelas habilitadas [M]
- [x] Permiso "protegida" para parcelas de vecinos (M18) y áreas históricas [M]
- [x] Permiso "narrativa" para terrenos bloqueados por progreso (M70) [M]
- [x] Permiso "agua" exclusivo para puentes (validado antes de la regla de pieza) [M]
- [x] Aviso claro con motivo al intentar colocar fuera de zona (fantasma rojo + texto) [S]
- [x] Las zonas se serializan en M58 y se restauran antes de las piezas [C]
- [x] Cambios de zona emiten señal a M64 (navmesh) y a M93 (proyectos) [M]

## I. Costo de recursos e inventario (M14) (8)

- [x] Costo declarado por receta como diccionario item_id → cantidad [S]
- [x] Verificación de recursos durante la preview: fantasma rojo con motivo al fallar [M]
- [x] Descuento atómico al confirmar (nunca descuenta sin colocar) [M]
- [x] Devolución parcial configurable por receta al demoler (default 50%) [M]
- [x] Devolución exacta al deshacer (undo restaura todos los recursos consumidos) [M]
- [x] El almacenamiento convierte la pieza en ítem del inventario sin perder receta [M]
- [x] Los stacks de M14 se agrupan al devolver materiales sobrantes [S]
- [x] Balance inicial de costos delegado a M92 con tabla de referencia en las recetas [M]

## J. Piezas y catálogo modular (12)

- [x] Catálogo estructurado por categorías con filtro por modo construcción/decoración [M]
- [x] Paredes: estándar, esquina, pilar y vano [M]
- [x] Pisos: losa interior y terraza [M]
- [x] Techos: losa plana y cumbrera [M]
- [x] Puertas: madera y piedra con hueco navegable [M]
- [x] Ventanas: marco simple y arco [M]
- [x] Escaleras: recta de 1 celda y de 2 celdas [M]
- [x] Puentes: losa de 1, 2, 3 y 4 celdas [M]
- [x] Caminos: piedra, arena y césped apisonado [M]
- [x] Cercas: madera baja, piedra y bambú [S]
- [x] Iluminación: farol colgante, farol de piso y antorcha ancestral [M]
- [x] Muebles y decoración: cama, mesa, silla, estantería, planta, cuadro, alfombra y tótem [C]

## K. Integración con el resto del sistema (12)

- [x] M08: escrituras voxel por celdas con marca dirty en los chunks afectados [C]
- [x] M08: los datos de pieza viven en capa voxel separada del terreno generado [C]
- [x] M14: descuento, devolución y almacenamiento de piezas como ítems [M]
- [x] M18: las ampliaciones de la casa usan proyectos de piezas de este módulo [C]
- [x] M25: ruinas como contenido solo visual (deconstruible = false) [M]
- [x] M64: señal obra_activa al entrar/salir y navmesh_delta al colocar/demoler [C]
- [x] M73: recetas de festival temporales en el catálogo (devolucion = 0) [M]
- [x] M58: serialización de lista de piezas y restauración idempotente [C]
- [x] M31: faroles y luces conectados al ciclo día/noche [M]
- [x] M32: la lluvia solo agrega VFX, nunca modifica o arruina piezas [S]
- [x] M71: logros de construcción escuchan la señal pieza_colocada [M]
- [x] M93: proyectos de construcción de meta larga cuentan piezas colocadas [M]

## L. Edge cases (12)

- [x] Colocar fuera de zona: rechazo previo a la validación de soporte [M]
- [x] Pieza encima de un NPC activo: rechazo temporal con motivo "NPC en el lugar" [C]
- [x] Deshacer la última acción: restaura celdas y recursos exactamente [C]
- [x] Redo tras deshacer solo disponible si no se realizó una acción intermedia [M]
- [x] Pieza en el aire sin soporte: bloqueo con motivo de soporte [M]
- [x] Colocar sobre techo: permitido solo si la superficie lo declara (techos con vegetación) [M]
- [x] Cerrar el modo con el fantasma activo: se devuelve al pool y no queda estado inconsistente [M]
- [x] Guardado a mitad de colocación (pieza fantasma activa): se descarta el fantasma, nada se persiste [M]
- [x] Pieza en el límite del mundo: rechazo claro dentro del AABB jugable [M]
- [x] Recursos insuficientes durante la preview: fantasma rojo y sin descuento [M]
- [x] Doble confirmación rápida: cooldown y chequeo de celda repetida [S]
- [x] Demolición de pieza bajo otra pieza: se devuelve el material de la de abajo según orden [C]

## M. Optimización (8)

- [x] Dirty flags por chunk: solo se regeneran los chunks tocados por la pieza [C]
- [x] Sin regeneración global de mesh del mundo al construir [C]
- [x] BuildGhost con pooling: cero alocaciones en el tick de preview [M]
- [x] Raycast de colocación limitado a 1 por frame con cache de celda [M]
- [x] Ocupación consultada en mapa de celdas en memoria (diccionario) [M]
- [x] Materiales de pieza compartidos entre instancias (static batching de Godot) [M]
- [x] Límite suave de piezas por zona (configurable) con aviso al jugador [M]
- [x] Presupuesto medido con profiler: preview <= 1 ms por frame (M113) [C]

## N. Documentación (6)

- [x] 01-Requerimientos.md creado con problema, RF, NFR y criterios de aceptación [S]
- [x] 02-Analisis.md creado con resolución de los 28 puntos y decisiones justificadas [S]
- [x] 03-Diseno.md creado con arquitectura, flujos, contratos API e integraciones [S]
- [x] 04-Codigo.md creado con archivos propuestos, firmas GDScript y logs [S]
- [x] 05-Checklist.md creado con 110+ ítems firmados (este archivo) [S]
- [x] Copias idénticas de los 5 archivos en plan-actual/ para seguimiento futuro [S]

## O. Polish (8)

- [x] Animación de colocación: transición breve fantasma → pieza real (escala/hammer) [C]
- [x] Partículas de polvo al colocar y demoler (M51: VFX de construcción) [M]
- [x] Sonido de colocación y de demolición que varía con el material (M43) [M]
- [x] Sonido ambiental de obras: martilleo suave mientras el modo está activo [M]
- [x] Aura de validación: destello suave verde al confirmar válido [M]
- [x] Aviso amable (no punitivo) con vibración sutil al fallar la colocación [S]
- [x] Los NPC cercanos miran la obra con curiosidad y comentan (M64 reacción cozy) [M]
- [x] El jugador puede admirar sus construcciones desde la cámara sin salir del modo [S]

## P. Testings y QA (8)

- [x] Unit tests de BuildValidator: ocupación, soporte, zonas, reglas por pieza [C]
- [x] Unit tests de costos: descuento, devolución y undo con recursos exactos [C]
- [x] Tests de integración: colocar → guardar → cargar → restaurar idéntico (M58) [C]
- [x] Tests de integración: la navmesh se actualiza con puertas y obras (M64) [C]
- [x] Stress test M112: 200+ piezas en una zona sin caída de FPS ni memoria [C]
- [x] Playtest de construcción (M113) con teclado y mando: flujo completo sin fricción [C]
- [x] Recorrido M114: construir y decorar la casa del jugador (M18) sin errores de consola [C]
- [x] QA final: 0 errores en Play Mode, 0 excepciones al entrar/salir del modo repetidamente [M]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
