**Modelo:** qwen/qwen3.8-max:free
**Plataforma:** Kilo Code

## Reserva actual

| Campo | Valor |
|---|---|
| Módulo | M17 Construcción (iter. 1) |
| Estado | 🔵 En curso |
| Agente | qwen/qwen3.8-max:free (Kilo Code) |
| Fase | F5 (base de producción) |
| Visión | V0 |
| Entrada | M08✅ M14🟢 — sistema de construcción voxel complejo |
| Salida | BuildingService autoload + catálogos data-driven + integración terreno M08 + inventario M14 + economía M38 + persistencia M59 + tests headless |
| Archivos afectados | `game/isla-ancestral/scripts/construccion/` (a crear), `tests/test_construccion.gd` (a crear) |
| Fecha reserva | 2026-09-01 00:15 |

# 05-Checklist.md — Módulo 17: Construcción

> Marcador de esfuerzo al final de cada ítem: [S] simple, [M] medio, [C] complejo.
> Módulo de diseño completo; implementación delegada (requiere M08 y M14 estables).

## A. Requisitos del módulo (12)

- [ ] Definir el problema: construcción cozy sobre mundo voxel con rejilla de 1 m alineada a M08 [S]
- [ ] Registrar dependencias: M08 (Mundo Voxel), M14 (Inventario) y relaciones M18, M25, M64, M58, M31, M32, M73, M92, M93, M71 [S]
- [ ] RF1: modo construcción y modo decoración con entrada/salida rápida [S]
- [ ] RF2: rejilla voxel de 1 m alineada al mundo con snapping de 90° [S]
- [ ] RF3: previsualización fantasma con estado válido/inválido [S]
- [ ] RF4: rotación de piezas en pasos de 90° [S]
- [ ] RF5: elevación por plantas con revalidación en cada nivel [S]
- [ ] RF6: permisos de zona (edificable, protegida, narrativa, agua) [S]
- [ ] RF7: costo de recursos con verificación y descuento en M14 [S]
- [ ] RF8: validación de ocupación, soporte y reglas por pieza [S]
- [ ] RF9-RF11: colocación con undo, copiar/mover/almacenar, demolición con devolución [S]
- [ ] RF12-RF14: catálogo de 12 familias de piezas, integración M18/M25/M64 y persistencia M58 [S]

## B. Resolución de los 28 puntos de la sección 16 del plan maestro (28)

- [ ] P1: modo construcción — estado de jugador + BuildManager, mundo vivo sin pausa dura [S]
- [ ] P2: modo decoración — mismo sistema con catálogo filtrado a muebles y decoración [S]
- [ ] P3: grid — rejilla voxel de 1 m alineada al origen global de M08 [S]
- [ ] P4: snapping — ajuste de posición y rotación (90°) a la celda más cercana [S]
- [ ] P5: rotación — pasos de 90° en Y persistidos como entero 0-3 [S]
- [ ] P6: elevación — planta base y subir/bajar con altura máxima por zona [S]
- [ ] P7: copia — tomar pieza existente como plantilla del fantasma [S]
- [ ] P8: mover objetos — desocupar celdas originales y revalidar destino [S]
- [ ] P9: recolocar — redondeo a rejilla y undo que devuelve la pieza a su celda [S]
- [ ] P10: almacenamiento — devolver piezas al inventario M14 sin pérdidas [S]
- [ ] P11: demolición — confirmación suave y retiro de la pieza del mundo [S]
- [ ] P12: devolución de materiales — fracción configurable por receta (default 50%) [S]
- [ ] P13: vista previa — BuildGhost con color de estado, costo y motivos de error en HUD [S]
- [ ] P14: objetos inválidos — toda regla fallida bloquea la colocación con motivo [S]
- [ ] P15: colisiones — piezas con colisión estática real; puertas con hueco navegable [S]
- [ ] P16: restricciones — reglas por pieza, topes por zona, alturas y parcelas ajenas [S]
- [ ] P17: paredes — bloques 1x1x1 con variantes de esquina y pilar [S]
- [ ] P18: pisos — losa 1x1x0.5 con soporte total para piezas encima [S]
- [ ] P19: techos — losa y cumbrera que exigen 2+ soportes en la celda [S]
- [ ] P20: puertas — marco 1x2 que exige pared y talla hueco navegable [S]
- [ ] P21: ventanas — 1x1 en pared, transparentes a la luz (M48) [S]
- [ ] P22: escaleras — bloque inclinado que exige apoyo y conecta plantas [S]
- [ ] P23: puentes — losa 1-4 celdas solo sobre agua dentro de zona permitida [S]
- [ ] P24: caminos — losa plana a nivel de césped sin bloqueo de paso [S]
- [ ] P25: cercas — valla de 0.7 m que marca límites sin encerrar al jugador [S]
- [ ] P26: iluminación — faroles con SpotLight/OmniLight ligados al ciclo M31 [S]
- [ ] P27: muebles — camas, mesas, sillas y estanterías con interacción M18 [S]
- [ ] P28: decoración — plantas, cuadros, alfombras y tótems de bajo costo [S]

## C. Modo construcción: entrada, salida y UX (10)

- [ ] Abrir modo con herramienta de construcción (M13) o tecla asignada [M]
- [ ] Cerrar modo con la misma acción sin confirmación agresiva [S]
- [ ] HUD de modo con categorías del catálogo y costo de la pieza activa [M]
- [ ] El movimiento del jugador se suspende solo durante la colocación [M]
- [ ] El mundo continúa activo (NPC, clima, tiempo) mientras se construye [M]
- [ ] Selección de pieza por categorías: estructura, mobiliario, iluminación, decoración [M]
- [ ] Desbloqueos de piezas visibles en el catálogo (M70/M93) [M]
- [ ] Tutorial de construcción integrado y repetible (plan maestro línea 2549) [M]
- [ ] Indicador de celda destino resaltado sobre el mundo [M]
- [ ] Cero clicks rápidos duplicados: cooldown de confirmación de 150 ms [S]

## D. Rejilla voxel de 1 m y alineación con M08 (10)

- [ ] Paso de rejilla fijo de 1 m derivado del tamaño de voxel de M08 [C]
- [ ] Origen de la rejilla idéntico al origen global del mundo voxel [C]
- [ ] Las piezas de NxN celdas ocupan exactamente su área completa en la rejilla [M]
- [ ] Compensación de medio voxel (offset 0.5 m) aplicada de forma consistente en preview y datos [C]
- [ ] Altura de planta: 1 m por nivel de bloque; habitaciones de 3 m en M18 [M]
- [ ] Límites de mundo: la colocación se rechaza fuera del AABB jugable de M08 [M]
- [ ] Conversión celda voxel ↔ posición mundial en una única utilidad compartida [M]
- [ ] La rejilla solo se calcula sobre terreno cargado (nunca sobre chunks vacíos) [M]
- [ ] El snap se redondea hacia abajo (floor) en dirección positiva del mundo [S]
- [ ] La rejilla es coherente tras guardar y cargar (misma celda ↔ misma posición) [M]

## E. Previsualización fantasma (BuildGhost) (10)

- [ ] Fantasma con mesh de la receta y material semi-transparente [M]
- [ ] Color verde si la colocación es válida y rojo si es inválida [S]
- [ ] El fantasma sigue al cursor con suavizado (lerp) sin saltos [M]
- [ ] La celda objetivo se recalculada solo si el cursor cambió (cache) [M]
- [ ] El fantasma refleja la rotación y elevación actuales en tiempo real [S]
- [ ] Se muestran en el HUD el costo y los motivos de rechazo (zona, soporte, ocupado, NPC, recursos) [M]
- [ ] El fantasma se oculta automáticamente fuera de zona o sobre terreno no cargado [M]
- [ ] Instancia única reutilizada del pool al entrar/salir del modo [M]
- [ ] LOD del fantasma: simplificación simple de malla a distancia > 40 m [M]
- [ ] El fantasma nunca colisiona con el mundo (capa de ignorancia de raycast) [S]

## F. Rotación, elevación y manipulación (10)

- [ ] Rotar la pieza en 4 pasos de 90° con la tecla dedicada [S]
- [ ] La validación se re-ejecuta con cada rotación (celdas afectadas cambian) [M]
- [ ] Subir/bajar la pieza una planta por pulsación con límite de altura [S]
- [ ] El fantasma muestra la pieza en el nivel elevado sin flotar visualmente mal [M]
- [ ] Copiar una pieza colocada a la rejilla conserva su rotación [S]
- [ ] Mover una pieza desocupa las celdas originales solo al confirmar [C]
- [ ] Al mover, los recursos no se re-cobran (solo se reubican) [M]
- [ ] Almacenar requiere inventario con espacio libre (M14) [M]
- [ ] Demolición con ventana de confirmación y preview de lo que se devuelve [M]
- [ ] La demolición de piezas funcionales (camas, almacenamiento) libera su contenido [C]

## G. Validación y reglas de colocación (BuildValidator) (12)

- [ ] Celda ocupada por otra pieza del jugador bloquea la colocación [M]
- [ ] Soporte inferior requerido (terreno, piso o techo según la superficie de la receta) [C]
- [ ] Regla por tipo de pieza declarada en PlacementRule y aplicada por el validador [M]
- [ ] Puerta exige pared contigua en la celda de instalación [M]
- [ ] Ventana exige pared contigua de al menos 1 celda [M]
- [ ] Escalera exige apoyo en piso o pared y no bloquea la circulación [M]
- [ ] Puente solo sobre agua (laguna/mar interior) y dentro de alcance de zona [C]
- [ ] Camino solo sobre césped/arena (nunca sobre roca o pendiente fuerte) [M]
- [ ] Techos exigen 2+ soportes (paredes o pilares) en las celdas de cobertura [C]
- [ ] Ninguna celda de la pieza puede solapar un NPC activo (consulta M64) [C]
- [ ] Las piezas no pueden bloquear la única salida de la zona de construcción [C]
- [ ] Las piezas de ruina M25 y parcelas de NPC son siempre no colocables ni demolidas [M]

## H. Zonas y permisos (8)

- [ ] Zonas definidas como regiones AABB en celdas voxel (ZoneRegistry) [M]
- [ ] Permiso "edificable" por defecto en el terreno del jugador y parcelas habilitadas [M]
- [ ] Permiso "protegida" para parcelas de vecinos (M18) y áreas históricas [M]
- [ ] Permiso "narrativa" para terrenos bloqueados por progreso (M70) [M]
- [ ] Permiso "agua" exclusivo para puentes (validado antes de la regla de pieza) [M]
- [ ] Aviso claro con motivo al intentar colocar fuera de zona (fantasma rojo + texto) [S]
- [ ] Las zonas se serializan en M58 y se restauran antes de las piezas [C]
- [ ] Cambios de zona emiten señal a M64 (navmesh) y a M93 (proyectos) [M]

## I. Costo de recursos e inventario (M14) (8)

- [ ] Costo declarado por receta como diccionario item_id → cantidad [S]
- [ ] Verificación de recursos durante la preview: fantasma rojo con motivo al fallar [M]
- [ ] Descuento atómico al confirmar (nunca descuenta sin colocar) [M]
- [ ] Devolución parcial configurable por receta al demoler (default 50%) [M]
- [ ] Devolución exacta al deshacer (undo restaura todos los recursos consumidos) [M]
- [ ] El almacenamiento convierte la pieza en ítem del inventario sin perder receta [M]
- [ ] Los stacks de M14 se agrupan al devolver materiales sobrantes [S]
- [ ] Balance inicial de costos delegado a M92 con tabla de referencia en las recetas [M]

## J. Piezas y catálogo modular (12)

- [ ] Catálogo estructurado por categorías con filtro por modo construcción/decoración [M]
- [ ] Paredes: estándar, esquina, pilar y vano [M]
- [ ] Pisos: losa interior y terraza [M]
- [ ] Techos: losa plana y cumbrera [M]
- [ ] Puertas: madera y piedra con hueco navegable [M]
- [ ] Ventanas: marco simple y arco [M]
- [ ] Escaleras: recta de 1 celda y de 2 celdas [M]
- [ ] Puentes: losa de 1, 2, 3 y 4 celdas [M]
- [ ] Caminos: piedra, arena y césped apisonado [M]
- [ ] Cercas: madera baja, piedra y bambú [S]
- [ ] Iluminación: farol colgante, farol de piso y antorcha ancestral [M]
- [ ] Muebles y decoración: cama, mesa, silla, estantería, planta, cuadro, alfombra y tótem [C]

## K. Integración con el resto del sistema (12)

- [ ] M08: escrituras voxel por celdas con marca dirty en los chunks afectados [C]
- [ ] M08: los datos de pieza viven en capa voxel separada del terreno generado [C]
- [ ] M14: descuento, devolución y almacenamiento de piezas como ítems [M]
- [ ] M18: las ampliaciones de la casa usan proyectos de piezas de este módulo [C]
- [ ] M25: ruinas como contenido solo visual (deconstruible = false) [M]
- [ ] M64: señal obra_activa al entrar/salir y navmesh_delta al colocar/demoler [C]
- [ ] M73: recetas de festival temporales en el catálogo (devolucion = 0) [M]
- [ ] M58: serialización de lista de piezas y restauración idempotente [C]
- [ ] M31: faroles y luces conectados al ciclo día/noche [M]
- [ ] M32: la lluvia solo agrega VFX, nunca modifica o arruina piezas [S]
- [ ] M71: logros de construcción escuchan la señal pieza_colocada [M]
- [ ] M93: proyectos de construcción de meta larga cuentan piezas colocadas [M]

## L. Edge cases (12)

- [ ] Colocar fuera de zona: rechazo previo a la validación de soporte [M]
- [ ] Pieza encima de un NPC activo: rechazo temporal con motivo "NPC en el lugar" [C]
- [ ] Deshacer la última acción: restaura celdas y recursos exactamente [C]
- [ ] Redo tras deshacer solo disponible si no se realizó una acción intermedia [M]
- [ ] Pieza en el aire sin soporte: bloqueo con motivo de soporte [M]
- [ ] Colocar sobre techo: permitido solo si la superficie lo declara (techos con vegetación) [M]
- [ ] Cerrar el modo con el fantasma activo: se devuelve al pool y no queda estado inconsistente [M]
- [ ] Guardado a mitad de colocación (pieza fantasma activa): se descarta el fantasma, nada se persiste [M]
- [ ] Pieza en el límite del mundo: rechazo claro dentro del AABB jugable [M]
- [ ] Recursos insuficientes durante la preview: fantasma rojo y sin descuento [M]
- [ ] Doble confirmación rápida: cooldown y chequeo de celda repetida [S]
- [ ] Demolición de pieza bajo otra pieza: se devuelve el material de la de abajo según orden [C]

## M. Optimización (8)

- [ ] Dirty flags por chunk: solo se regeneran los chunks tocados por la pieza [C]
- [ ] Sin regeneración global de mesh del mundo al construir [C]
- [ ] BuildGhost con pooling: cero alocaciones en el tick de preview [M]
- [ ] Raycast de colocación limitado a 1 por frame con cache de celda [M]
- [ ] Ocupación consultada en mapa de celdas en memoria (diccionario) [M]
- [ ] Materiales de pieza compartidos entre instancias (static batching de Godot) [M]
- [ ] Límite suave de piezas por zona (configurable) con aviso al jugador [M]
- [ ] Presupuesto medido con profiler: preview <= 1 ms por frame (M113) [C]

## N. Documentación (6)

- [ ] 01-Requerimientos.md creado con problema, RF, NFR y criterios de aceptación [S]
- [ ] 02-Analisis.md creado con resolución de los 28 puntos y decisiones justificadas [S]
- [ ] 03-Diseno.md creado con arquitectura, flujos, contratos API e integraciones [S]
- [ ] 04-Codigo.md creado con archivos propuestos, firmas GDScript y logs [S]
- [ ] 05-Checklist.md creado con 110+ ítems firmados (este archivo) [S]
- [ ] Copias idénticas de los 5 archivos en plan-actual/ para seguimiento futuro [S]

## O. Polish (8)

- [ ] Animación de colocación: transición breve fantasma → pieza real (escala/hammer) [C]
- [ ] Partículas de polvo al colocar y demoler (M51: VFX de construcción) [M]
- [ ] Sonido de colocación y de demolición que varía con el material (M43) [M]
- [ ] Sonido ambiental de obras: martilleo suave mientras el modo está activo [M]
- [ ] Aura de validación: destello suave verde al confirmar válido [M]
- [ ] Aviso amable (no punitivo) con vibración sutil al fallar la colocación [S]
- [ ] Los NPC cercanos miran la obra con curiosidad y comentan (M64 reacción cozy) [M]
- [ ] El jugador puede admirar sus construcciones desde la cámara sin salir del modo [S]

## P. Testings y QA (8)

- [ ] Unit tests de BuildValidator: ocupación, soporte, zonas, reglas por pieza [C]
- [ ] Unit tests de costos: descuento, devolución y undo con recursos exactos [C]
- [ ] Tests de integración: colocar → guardar → cargar → restaurar idéntico (M58) [C]
- [ ] Tests de integración: la navmesh se actualiza con puertas y obras (M64) [C]
- [ ] Stress test M112: 200+ piezas en una zona sin caída de FPS ni memoria [C]
- [ ] Playtest de construcción (M113) con teclado y mando: flujo completo sin fricción [C]
- [ ] Recorrido M114: construir y decorar la casa del jugador (M18) sin errores de consola [C]
- [ ] QA final: 0 errores en Play Mode, 0 excepciones al entrar/salir del modo repetidamente [M]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
