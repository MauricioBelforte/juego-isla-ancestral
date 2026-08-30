**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 16: Crafting

> Marcadores de esfuerzo: [S] simple · [M] medio · [C] complejo.
> Estado: los ítems de diseño de este plan inicial se declaran cumplidos en esta planificación; la implementación en Godot los verificará según la Definición de Completado del protocolo.

## A. Requisitos del módulo (plan maestro sección 15) (25)

- [x] Diseñar banco de trabajo: mesa de trabajo como estación base del pueblo [S]
- [x] Diseñar estaciones de crafting: mesa de trabajo, fogata y telar con identidad propia [S]
- [x] Diseñar recetas: modelo Resource con materiales, cantidades y resultado [S]
- [x] Definir categorías: herramientas, estructura, textiles, cocina, decoracion, ancestral, oculta [S]
- [x] Definir niveles de recetas: escala 1 a 5 ligada a progreso [S]
- [x] Definir materiales: referencia por item_id al catálogo M15 [S]
- [x] Definir cantidades: coste verificable y balanceado por nivel [S]
- [x] Definir desbloqueos: conocimiento por experimentación y compra a NPC [S]
- [ ] Definir recetas secretas: combinaciones poco obvias con feedback dorado [S]
- [ ] Definir recetas ancestrales: ligadas a deidades, ofrendas y tienda ancestral [S]
- [ ] Definir recetas estacionales: filtradas por temporada M29, conocimiento persistente [S]
- [ ] Definir recetas regionales: materiales regionales M15 habilitan variantes [M]
- [ ] Crear interfaz: panel de crafting con lista, detalle y acciones [M]
- [ ] Crear preview: vista del objeto resultante y su colocación en M17 [M]
- [ ] Crear lista de materiales faltantes: rojo + origen de obtención M15 [S]
- [ ] Crear creación individual: botón crear 1x con validación [S]
- [ ] Crear creación múltiple: botón crear N con máximo calculado [M]
- [ ] Crear feedback sonoro: SFX de éxito, fallo de materiales y descubrimiento [M]
- [ ] Crear feedback visual: VFX de creación, partículas doradas en descubrimiento [M]
- [ ] Crear animación: breve animación de entrega no bloqueante [M]
- [ ] Crear almacenamiento: resultado a mochila o almacenamiento doméstico [M]
- [ ] Crear economía alrededor del crafting: pergaminos de receta con precio M37 [M]
- [ ] Crear utilidad real para cada objeto: regla de inclusión anti-redundancia [M]
- [ ] Evitar cientos de recetas redundantes: validación automática de duplicados funcionales [M]
- [ ] Balancear materiales: costes proporcionales a rareza M15 y nivel [C]

## B. Modelo de recetas y datos (14)

- [ ] Crear craft_recipe.gd como Resource inmutable con id único [S]
- [ ] Campos: id, nombre, descripcion, categoria, nivel [S]
- [ ] Campos: estacion requerida (StationType) [S]
- [ ] Campos: materiales con item_id y cantidad (RecipeMaterial) [S]
- [ ] Campos: resultado_id y resultado_cantidad [S]
- [ ] Campos: origen de desbloqueo (experimentacion/compra/evento) [S]
- [ ] Campos: precio_pergamino en moneda M37 [S]
- [ ] Campos: tags (secreta, ancestral, estacional, regional) [S]
- [ ] Campos: pista cozy de obtención para la UI de desconocidas [S]
- [ ] Campos: temporadas en que es fabricable (vacíos = siempre) [S]
- [ ] Función materiales_dict() que normaliza en Diccionario item_id-cantidad [S]
- [ ] Función es_estacional/es_secreta/es_ancestral por tags [S]
- [ ] Organización de recetas .tres por estación en carpetas dedicadas [S]
- [ ] Catálogo cargado al iniciar el juego desde rutas de Resources [M]

## C. Estaciones de crafting (12)

- [ ] Mesa de trabajo: estación voxel en el mundo con CraftingStation [M]
- [ ] Fogata: estación voxel para cocina, metalurgia ligera y ancestral [M]
- [ ] Telar: estación voxel para textiles y decoración textil [M]
- [ ] Cada estación exporta su StationType sin ambigüedad [S]
- [ ] Cada estación define punto de spawn del resultado [S]
- [ ] Interacción desde el contrato IInteractable de M11 (acercarse y presionar) [M]
- [ ] Apertura de UI única por estación (no apilar paneles) [S]
- [ ] Cierre de UI sin penalización al alejarse [S]
- [ ] Las estaciones pueden fabricarse como receta y colocarse con M17 [M]
- [ ] Las estaciones son persistentes en el mundo (guardado de escena) [M]
- [ ] Sin crafting global desde menú: siempre se requiere estación física [S]
- [ ] Zona de uso: radio de interacción coherente con la escala voxel [S]

## D. CraftingService: registro y fabricación (16)

- [ ] Autoload "Crafting" del servicio en project.godot [S]
- [ ] Registro de recetas por id con detección de duplicados [S]
- [ ] Índice _by_station construido al registrar [S]
- [ ] Consulta get_recipes_for_station con cache [S]
- [ ] Consulta get_known_recipes filtrada por conocimiento y temporada [M]
- [ ] Consulta get_unknown_for para la sección de misterio de la UI [M]
- [ ] is_known y get_recipe de acceso directo [S]
- [ ] craft(rid, cantidad) valida receta conocida y estación correcta [S]
- [ ] Validación de materiales contra M14 sin consumo [S]
- [ ] Cálculo de máximo fabricable según stacks del inventario [M]
- [ ] Consumo atómico de materiales multiplcados por cantidad [M]
- [ ] Entrega del resultado: mochila primero, almacenamiento doméstico después [M]
- [ ] Rollback honesto: reembolso exacto si la entrega falla [M]
- [ ] Señal crafting_completed con receta y cantidad [S]
- [ ] Señal crafting_failed con razón tipada (CraftError) [S]
- [ ] Señal inventory_full para aviso de UI [S]

## E. Experimentación y descubrimiento (10)

- [ ] Modo experimentar habilitado por estación (allows_experiment) [S]
- [ ] Hasta 3 materiales por experimento con normalización de combinación [S]
- [ ] Búsqueda de receta oculta por combinación canónica exacta [M]
- [ ] Descubrimientos posibles solo con recetas de origen experimentacion [S]
- [ ] Fallo sin consumo de materiales: mensaje cozy "Nada parece encajar" [S]
- [ ] Señal experiment_failed para feedback de UI [S]
- [ ] Señal recipe_discovered con partículas doradas y SFX especial [M]
- [ ] Descubrimiento registra conocimiento persistente de inmediato [S]
- [ ] Pistas de obtención visibles en recetas desconocidas (silueta ?) [M]
- [ ] Sin bucle de experimentación infinito: pistas suficientes + compra alternativa [M]

## F. Interfaz de usuario (14)

- [ ] CraftingUI instanciada en la UI raíz, oculta por defecto [S]
- [ ] open(station) carga recetas conocidas de la estación [S]
- [ ] Lista de recetas filtrable por categoría [S]
- [ ] Filtro "fabricables ahora" según inventario M14 [M]
- [ ] Fila de receta: icono, nombre, nivel, candado si desconocida [S]
- [ ] Silueta con (?) y pista cozy para recetas desconocidas [M]
- [ ] Detalle: lista de materiales con cantidades y faltantes en rojo [S]
- [ ] Detalle: origen de obtención de materiales desde M15 [M]
- [ ] Detalle: preview del objeto (icono 3D o voxel preview) [M]
- [ ] Botón crear 1x deshabilitado si faltan materiales [S]
- [ ] Botón crear N con selector de cantidad (máx. 30 y límite por materiales) [M]
- [ ] Pestaña experimentar con selectores de hasta 3 materiales [M]
- [ ] Mensajes de resultado: éxito, fallo, rollback e inventario lleno [S]
- [ ] Navegación completa con teclado/mouse y gamepad [M]

## G. Feedback, polish y cozy (10)

- [ ] SFX de creación ligero y cálido (sin aspas ni ruidos agresivos) [M]
- [ ] SFX de descubrimiento especial (campana/tema de logro suave) [M]
- [ ] SFX de error amable (no punitivo) [S]
- [ ] VFX de partículas al entregar el objeto [M]
- [ ] Partículas doradas en descubrimiento de recetas secretas/ancestrales [M]
- [ ] Animación breve del resultado emergiendo del spawn point [M]
- [ ] Sin tiempos de espera: entrega en el mismo frame (instantáneo) [S]
- [ ] Cero pérdida de material en experimentos fallidos [S]
- [ ] Mensajes escritos en tono acogedor, sin culpabilizar [S]
- [ ] El jugador puede irse de la estación sin consecuencias negativas [S]

## H. Integración con otros módulos (12)

- [ ] M14: consumo y añadido de ítems vía InventoryService [M]
- [ ] M14: consulta de cantidades y stacks para validación [S]
- [ ] M14: reacción a señal inventory_changed (refresco fabricables) [M]
- [ ] M14: entrega a almacenamiento doméstico cuando la mochila está llena [M]
- [ ] M15: materiales referenciados por item_id del catálogo de recursos [S]
- [ ] M15: origen de obtención en el detalle de la receta [S]
- [ ] M13: recetas de herramientas con nivel y desbloqueo en cascada [M]
- [ ] M13: inicialización de herramienta fabricada vía ToolService [M]
- [ ] M17: mobiliario fabricado como ítem colocable en decoración [M]
- [ ] M17: recetas que fabrican estaciones de crafting colocado en el mundo [M]
- [ ] M29/M73: recetas estacionales filtradas por temporada y eventos [M]
- [ ] M20/M38: pergaminos de receta comprables y consumibles desde M14 [M]

## I. Edge cases (12)

- [ ] Receta sin materiales definidos: se rechaza en registro con warning [S]
- [ ] Material con cantidad 0 o negativa: validación de datos al registrar [S]
- [ ] Receta con resultado_id inexistente: bloqueada en registro [S]
- [ ] Estación en uso (UI abierta) y segunda interacción: se ignora sin duplicar [S]
- [ ] Cancelación del panel: sin consumo de materiales [S]
- [ ] Inventario lleno sin almacenamiento doméstico: rollback y aviso honesto [M]
- [ ] Cantidad de creación mayor a materiales disponibles: se limita al máximo real [S]
- [ ] Fabricar 0 o negativos desde la UI: imposible por deshabilitación del control [S]
- [ ] Receta desconocida intentada vía API: error tipado sin crash [S]
- [ ] Temporada cerrada con receta conocida: oculta de la lista, no borrada [M]
- [ ] Pergamino de receta ya conocida: no se consume y muestra mensaje cálido [S]
- [ ] Doble llamado a craft en el mismo frame: cola interna o rechazo silencioso [M]

## J. Optimización y rendimiento (8)

- [ ] Búsqueda de recetas por estación con cache (sin recorrer todo en cada frame) [S]
- [ ] Cero cómputo de crafting cuando la UI está cerrada [S]
- [ ] Lista de recetas con virtualización o ItemList nativa (sin miles de nodos) [M]
- [ ] Filtros de temporada recalculados solo ante season_changed [S]
- [ ] Sin asignaciones de objetos en el hot path de fabricación simple [M]
- [ ] Texturas/iconos de recetas precargados con pool ligero [M]
- [ ] Sin steps de física extra en estaciones (efecto interactuable básico) [S]
- [ ] Presupuesto: apertura de UI menor a 1 ms y sin marco de referencia perdido [M]

## K. Testing y QA (8)

- [ ] Test unitario: registro de recetas y detección de duplicados [M]
- [ ] Test unitario: validación de materiales y máximo fabricable [M]
- [ ] Test: fabricación individual y múltiple con entregas correctas [M]
- [ ] Test: rollback exacto ante inventario lleno en ambos destinos [C]
- [ ] Test: experimentación con combinación válida, inválida y límite de 3 materiales [M]
- [ ] Test: persistencia del conocimiento entre sesiones de guardado [M]
- [ ] Test: recetas estacionales ocultas y recuperadas sin pérdida [M]
- [ ] Recorrido manual: abrir, fabricar, fallar y cancelar en las 3 estaciones sin bugs [C]

## L. Documentación y cierre (6)

- [ ] 01-Requerimientos creado y firmado (este plan inicial) [S]
- [ ] 02-Analisis creado y firmado (alternativas y decisiones justificadas) [S]
- [ ] 03-Diseno creado y firmado (arquitectura, flujos y API) [S]
- [ ] 04-Codigo creado y firmado (rutas, firmas GDScript y logs) [S]
- [ ] 05-Checklist creado y firmado (este archivo, mínimo 110 ítems) [S]
- [ ] Copia idéntica de los 5 archivos en plan-actual para continuidad [S]