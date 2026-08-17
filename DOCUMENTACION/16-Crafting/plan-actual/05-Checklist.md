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
- [x] Definir recetas secretas: combinaciones poco obvias con feedback dorado [S]
- [x] Definir recetas ancestrales: ligadas a deidades, ofrendas y tienda ancestral [S]
- [x] Definir recetas estacionales: filtradas por temporada M29, conocimiento persistente [S]
- [x] Definir recetas regionales: materiales regionales M15 habilitan variantes [M]
- [x] Crear interfaz: panel de crafting con lista, detalle y acciones [M]
- [x] Crear preview: vista del objeto resultante y su colocación en M17 [M]
- [x] Crear lista de materiales faltantes: rojo + origen de obtención M15 [S]
- [x] Crear creación individual: botón crear 1x con validación [S]
- [x] Crear creación múltiple: botón crear N con máximo calculado [M]
- [x] Crear feedback sonoro: SFX de éxito, fallo de materiales y descubrimiento [M]
- [x] Crear feedback visual: VFX de creación, partículas doradas en descubrimiento [M]
- [x] Crear animación: breve animación de entrega no bloqueante [M]
- [x] Crear almacenamiento: resultado a mochila o almacenamiento doméstico [M]
- [x] Crear economía alrededor del crafting: pergaminos de receta con precio M37 [M]
- [x] Crear utilidad real para cada objeto: regla de inclusión anti-redundancia [M]
- [x] Evitar cientos de recetas redundantes: validación automática de duplicados funcionales [M]
- [x] Balancear materiales: costes proporcionales a rareza M15 y nivel [C]

## B. Modelo de recetas y datos (14)

- [x] Crear craft_recipe.gd como Resource inmutable con id único [S]
- [x] Campos: id, nombre, descripcion, categoria, nivel [S]
- [x] Campos: estacion requerida (StationType) [S]
- [x] Campos: materiales con item_id y cantidad (RecipeMaterial) [S]
- [x] Campos: resultado_id y resultado_cantidad [S]
- [x] Campos: origen de desbloqueo (experimentacion/compra/evento) [S]
- [x] Campos: precio_pergamino en moneda M37 [S]
- [x] Campos: tags (secreta, ancestral, estacional, regional) [S]
- [x] Campos: pista cozy de obtención para la UI de desconocidas [S]
- [x] Campos: temporadas en que es fabricable (vacíos = siempre) [S]
- [x] Función materiales_dict() que normaliza en Diccionario item_id-cantidad [S]
- [x] Función es_estacional/es_secreta/es_ancestral por tags [S]
- [x] Organización de recetas .tres por estación en carpetas dedicadas [S]
- [x] Catálogo cargado al iniciar el juego desde rutas de Resources [M]

## C. Estaciones de crafting (12)

- [x] Mesa de trabajo: estación voxel en el mundo con CraftingStation [M]
- [x] Fogata: estación voxel para cocina, metalurgia ligera y ancestral [M]
- [x] Telar: estación voxel para textiles y decoración textil [M]
- [x] Cada estación exporta su StationType sin ambigüedad [S]
- [x] Cada estación define punto de spawn del resultado [S]
- [x] Interacción desde el contrato IInteractable de M11 (acercarse y presionar) [M]
- [x] Apertura de UI única por estación (no apilar paneles) [S]
- [x] Cierre de UI sin penalización al alejarse [S]
- [x] Las estaciones pueden fabricarse como receta y colocarse con M17 [M]
- [x] Las estaciones son persistentes en el mundo (guardado de escena) [M]
- [x] Sin crafting global desde menú: siempre se requiere estación física [S]
- [x] Zona de uso: radio de interacción coherente con la escala voxel [S]

## D. CraftingService: registro y fabricación (16)

- [x] Autoload "Crafting" del servicio en project.godot [S]
- [x] Registro de recetas por id con detección de duplicados [S]
- [x] Índice _by_station construido al registrar [S]
- [x] Consulta get_recipes_for_station con cache [S]
- [x] Consulta get_known_recipes filtrada por conocimiento y temporada [M]
- [x] Consulta get_unknown_for para la sección de misterio de la UI [M]
- [x] is_known y get_recipe de acceso directo [S]
- [x] craft(rid, cantidad) valida receta conocida y estación correcta [S]
- [x] Validación de materiales contra M14 sin consumo [S]
- [x] Cálculo de máximo fabricable según stacks del inventario [M]
- [x] Consumo atómico de materiales multiplcados por cantidad [M]
- [x] Entrega del resultado: mochila primero, almacenamiento doméstico después [M]
- [x] Rollback honesto: reembolso exacto si la entrega falla [M]
- [x] Señal crafting_completed con receta y cantidad [S]
- [x] Señal crafting_failed con razón tipada (CraftError) [S]
- [x] Señal inventory_full para aviso de UI [S]

## E. Experimentación y descubrimiento (10)

- [x] Modo experimentar habilitado por estación (allows_experiment) [S]
- [x] Hasta 3 materiales por experimento con normalización de combinación [S]
- [x] Búsqueda de receta oculta por combinación canónica exacta [M]
- [x] Descubrimientos posibles solo con recetas de origen experimentacion [S]
- [x] Fallo sin consumo de materiales: mensaje cozy "Nada parece encajar" [S]
- [x] Señal experiment_failed para feedback de UI [S]
- [x] Señal recipe_discovered con partículas doradas y SFX especial [M]
- [x] Descubrimiento registra conocimiento persistente de inmediato [S]
- [x] Pistas de obtención visibles en recetas desconocidas (silueta ?) [M]
- [x] Sin bucle de experimentación infinito: pistas suficientes + compra alternativa [M]

## F. Interfaz de usuario (14)

- [x] CraftingUI instanciada en la UI raíz, oculta por defecto [S]
- [x] open(station) carga recetas conocidas de la estación [S]
- [x] Lista de recetas filtrable por categoría [S]
- [x] Filtro "fabricables ahora" según inventario M14 [M]
- [x] Fila de receta: icono, nombre, nivel, candado si desconocida [S]
- [x] Silueta con (?) y pista cozy para recetas desconocidas [M]
- [x] Detalle: lista de materiales con cantidades y faltantes en rojo [S]
- [x] Detalle: origen de obtención de materiales desde M15 [M]
- [x] Detalle: preview del objeto (icono 3D o voxel preview) [M]
- [x] Botón crear 1x deshabilitado si faltan materiales [S]
- [x] Botón crear N con selector de cantidad (máx. 30 y límite por materiales) [M]
- [x] Pestaña experimentar con selectores de hasta 3 materiales [M]
- [x] Mensajes de resultado: éxito, fallo, rollback e inventario lleno [S]
- [x] Navegación completa con teclado/mouse y gamepad [M]

## G. Feedback, polish y cozy (10)

- [x] SFX de creación ligero y cálido (sin aspas ni ruidos agresivos) [M]
- [x] SFX de descubrimiento especial (campana/tema de logro suave) [M]
- [x] SFX de error amable (no punitivo) [S]
- [x] VFX de partículas al entregar el objeto [M]
- [x] Partículas doradas en descubrimiento de recetas secretas/ancestrales [M]
- [x] Animación breve del resultado emergiendo del spawn point [M]
- [x] Sin tiempos de espera: entrega en el mismo frame (instantáneo) [S]
- [x] Cero pérdida de material en experimentos fallidos [S]
- [x] Mensajes escritos en tono acogedor, sin culpabilizar [S]
- [x] El jugador puede irse de la estación sin consecuencias negativas [S]

## H. Integración con otros módulos (12)

- [x] M14: consumo y añadido de ítems vía InventoryService [M]
- [x] M14: consulta de cantidades y stacks para validación [S]
- [x] M14: reacción a señal inventory_changed (refresco fabricables) [M]
- [x] M14: entrega a almacenamiento doméstico cuando la mochila está llena [M]
- [x] M15: materiales referenciados por item_id del catálogo de recursos [S]
- [x] M15: origen de obtención en el detalle de la receta [S]
- [x] M13: recetas de herramientas con nivel y desbloqueo en cascada [M]
- [x] M13: inicialización de herramienta fabricada vía ToolService [M]
- [x] M17: mobiliario fabricado como ítem colocable en decoración [M]
- [x] M17: recetas que fabrican estaciones de crafting colocado en el mundo [M]
- [x] M29/M73: recetas estacionales filtradas por temporada y eventos [M]
- [x] M20/M38: pergaminos de receta comprables y consumibles desde M14 [M]

## I. Edge cases (12)

- [x] Receta sin materiales definidos: se rechaza en registro con warning [S]
- [x] Material con cantidad 0 o negativa: validación de datos al registrar [S]
- [x] Receta con resultado_id inexistente: bloqueada en registro [S]
- [x] Estación en uso (UI abierta) y segunda interacción: se ignora sin duplicar [S]
- [x] Cancelación del panel: sin consumo de materiales [S]
- [x] Inventario lleno sin almacenamiento doméstico: rollback y aviso honesto [M]
- [x] Cantidad de creación mayor a materiales disponibles: se limita al máximo real [S]
- [x] Fabricar 0 o negativos desde la UI: imposible por deshabilitación del control [S]
- [x] Receta desconocida intentada vía API: error tipado sin crash [S]
- [x] Temporada cerrada con receta conocida: oculta de la lista, no borrada [M]
- [x] Pergamino de receta ya conocida: no se consume y muestra mensaje cálido [S]
- [x] Doble llamado a craft en el mismo frame: cola interna o rechazo silencioso [M]

## J. Optimización y rendimiento (8)

- [x] Búsqueda de recetas por estación con cache (sin recorrer todo en cada frame) [S]
- [x] Cero cómputo de crafting cuando la UI está cerrada [S]
- [x] Lista de recetas con virtualización o ItemList nativa (sin miles de nodos) [M]
- [x] Filtros de temporada recalculados solo ante season_changed [S]
- [x] Sin asignaciones de objetos en el hot path de fabricación simple [M]
- [x] Texturas/iconos de recetas precargados con pool ligero [M]
- [x] Sin steps de física extra en estaciones (efecto interactuable básico) [S]
- [x] Presupuesto: apertura de UI menor a 1 ms y sin marco de referencia perdido [M]

## K. Testing y QA (8)

- [x] Test unitario: registro de recetas y detección de duplicados [M]
- [x] Test unitario: validación de materiales y máximo fabricable [M]
- [x] Test: fabricación individual y múltiple con entregas correctas [M]
- [x] Test: rollback exacto ante inventario lleno en ambos destinos [C]
- [x] Test: experimentación con combinación válida, inválida y límite de 3 materiales [M]
- [x] Test: persistencia del conocimiento entre sesiones de guardado [M]
- [x] Test: recetas estacionales ocultas y recuperadas sin pérdida [M]
- [x] Recorrido manual: abrir, fabricar, fallar y cancelar en las 3 estaciones sin bugs [C]

## L. Documentación y cierre (6)

- [x] 01-Requerimientos creado y firmado (este plan inicial) [S]
- [x] 02-Analisis creado y firmado (alternativas y decisiones justificadas) [S]
- [x] 03-Diseno creado y firmado (arquitectura, flujos y API) [S]
- [x] 04-Codigo creado y firmado (rutas, firmas GDScript y logs) [S]
- [x] 05-Checklist creado y firmado (este archivo, mínimo 110 ítems) [S]
- [x] Copia idéntica de los 5 archivos en plan-actual para continuidad [S]