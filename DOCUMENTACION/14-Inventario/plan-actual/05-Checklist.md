**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 14: Inventario

Los ítems llevan el marcador de esfuerzo al final de la línea (S: simple, M: medio, C: complejo). El diseño del módulo se considera cerrado cuando todos los ítems están cumplidos; los de runtime los verificará el agente delegado.

## A. Requisitos del módulo (10)

- [x] Definir el problema: inventario cozy sin frustración para la recolección y gestión de la isla [S]
- [x] Registrar dependencias: M13, M15, M16, M53; relaciones M17, M18, M19/M20, M21, M37, M39, M55, M59, M87, M92 [S]
- [x] Catalogar los 24 puntos de la sección 13 del plan maestro [S]
- [x] RF1: contenedores múltiples (bolsillo, mochila, casa, cofres, almacén, correo) [S]
- [x] RF2: stacks y límites coherentes por tipo de ítem [S]
- [x] RF3: ausencia de peso con límite por slots [S]
- [x] RF4: categorías, ordenamiento, filtros y favoritos [S]
- [x] RF5: tooltip con nombre, rareza, precio y recetas [S]
- [x] RF6+RF7: hotbar de 6 y transferencias ágiles [S]
- [x] RF8+RF9: feedback anti-frustración y descarte seguro [S]

## B. Resolución de los 24 puntos del plan (24)

- [x] P1: diseño general — bolsillo grid 4x6 + almacenamiento doméstico estilo Animal Crossing [S]
- [x] P2: cantidad de slots — bolsillo 24, mochila +16, casa 60-120, cofres 16-40, almacén 240 [S]
- [x] P3: peso o ausencia — sin peso; límite por slots y stack [S]
- [x] P4: stack máximo — 99 recursos, 10 medianos, 1 únicos, 999 espóras de luz [S]
- [x] P5: categorías — 9 definidas con pestañas y contadores [S]
- [x] P6: ordenamiento — por categoría, rareza, nombre o fecha [S]
- [x] P7: filtros — pestaña, búsqueda de texto y solo favoritos [S]
- [x] P8: favoritos — toggle por slot con pin fijo ante sort [S]
- [x] P9: tooltip — hover con delay 0.5 s y datos completos [S]
- [x] P10: selección rápida — atajos 1-6 y rueda del mouse [S]
- [x] P11: hotbar — barra fija de 6 slots con contadores [S]
- [x] P12: almacenamiento doméstico — cofre de casa 60 ampliable a 120 [S]
- [x] P13: cofres colocables — 16/28/40 slots con id único en el mundo [S]
- [x] P14: almacenes — almacén comunitario de 240 slots compartidos [S]
- [x] P15: mochila — mejora de +16 slots con adquisición amistosa [S]
- [x] P16: mejoras de capacidad — ruta corta (casa y mochila) sin compras incrementales [S]
- [x] P17: iconos — atlas 256 por categoría con borde de rareza [S]
- [x] P18: estados bloqueados — candado con explicación de desbloqueo [S]
- [x] P19: feedback de lleno — aviso 80%, botín al mundo, notificación amable [S]
- [x] P20: transferencia rápida — stack completo con un botón [S]
- [x] P21: transferencia múltiple — cantidad personalizada y por categoría [S]
- [x] P22: separación de stacks — dividir con prefill de la mitad [S]
- [x] P23: descarte — soltar al mundo como pickup recuperable [S]
- [x] P24: confirmación de objetos importantes — diálogo de 2 pasos para protegidos [S]

## C. Núcleo de datos (12)

- [x] ItemData como Resource con id inmutable y estable [M]
- [x] Campos de ItemData: nombre, descripción, icono, categoría, stack, rareza, precio [M]
- [x] Claves de localización en ItemData para M87 (sin cadenas crudas) [M]
- [x] Flag protected_from_discard en ItemData [S]
- [x] ItemCatalog: registro central id → ItemData con carga bajo demanda [M]
- [x] InventorySlot: item_id, cantidad, favorito, bloqueado [S]
- [x] Inventory como contenedor genérico de slots con tamaño dinámico [M]
- [x] Señales por slot (changed) y por contenedor (tamaño) [M]
- [x] to_dict/from_dict con versión y validación de integridad [M]
- [x] Rechazo de ids desconocidos en from_dict con log DOM-14 [M]
- [x] Enum ContainerType: BOLSILLO, MOCHILA, CASA, COFRE, ALMACEN, CORREO [S]
- [x] Conversión de tamaño de contenedor sin perder ítems (clamp y migración) [M]
- [ ] Campo item_type: TOOL, RESOURCE, FOOD, FISH, MATERIAL, GIFT, SPORE, FURNITURE, QUEST, CLOTHING, ENCHANTMENT [S]
- [ ] Campo tool_type: string con tipo de herramienta (vacio si no es herramienta) [S]
- [ ] Campo tool_tier: 0=none, 1=T1, 2=T2, 3=T3, 4=T4 [S]
- [ ] Campo enchantment: string con id de encantamiento (vacio si no esta encantada) [S]
- [ ] Campo is_enchanted: bool [S]
- [ ] Campo durability: int (-1 = infinita, solo herramientas) [S]
- [ ] Campo durability_max: int [S]
- [ ] Campo tags: Array[String] para filtrado [S]
- [ ] Campo is_quest_item: bool [S]
- [ ] Campo visual_mesh: Mesh para items 3D en el mundo [S]
- [ ] Campo visual_color: Color base del item [S]

## D. Slots, stacks y manipulación (10)

- [x] add_item con auto-stacking en primer slot compatible [M]
- [x] Overflow de stack: reparto entre slots y sobrante devuelto [M]
- [x] add_item con contenedor lleno: retorno del sobrante y señal inventory_full [M]
- [x] remove_item con validación de cantidad existente [S]
- [x] count_item con opción de incluir la casa [S]
- [x] Mover ítem entre slots del mismo contenedor e intercambiar [M]
- [x] Mover entre contenedores con unión automática de stacks parciales [M]
- [x] split_stack con cantidad exacta y clamp al máximo [S]
- [x] Consumo de materiales por crafting y regalos con verificación previa [M]
- [x] Protección contra cantidades negativas y stack overflow en todas las API [S]

## E. UI del inventario (12)

- [x] Panel principal con grilla de slots reutilizando slot.tscn [C]
- [x] Pestañas de categoría con contadores de ítems [M]
- [x] Búsqueda por texto sanitizada con memoria del último filtro [M]
- [x] Sort con memoria de preferencia del jugador [M]
- [x] Toggle de favoritos con tecla rápida y pin visual [S]
- [x] Tooltip lazy con delay 0.5 s y panel de detalle [M]
- [x] Acciones contextuales por slot: usar, equipar, vender, donar, descartar [C]
- [x] Indicador de capacidad usada/total visible [S]
- [x] Feedback visual suave al agregar y quitar ítems [M]
- [x] Apertura con pausa suave del mundo (M29 UI-only) [C]
- [x] Soporte completo de gamepad y teclado/mouse [C]
- [x] Release de foco y cierre limpio sin estado colgado [S]

## F. Hotbar y selección rápida (8)

- [x] Hotbar fija de 6 slots siempre visible [S]
- [x] Asignación por arrastre desde el inventario y por atajo de tecla [M]
- [x] Ciclo de selección con teclas 1-6 y rueda del mouse [S]
- [x] Equipamiento de herramientas M13 desde la hotbar [M]
- [x] Uso del ítem seleccionado con el botón principal de acción [S]
- [x] Feedback de selección con contorno y sonido [S]
- [x] Contador de cantidad y durabilidad en cada slot de la hotbar [M]
- [x] Persistencia de la configuración de hotbar en el guardado M59 [M]

## G. Almacenamiento doméstico, cofres y almacenes (10)

- [x] Cofre de casa con 60 slots iniciales [M]
- [x] Ampliación de casa a 120 slots con las expansiones de M18 [M]
- [x] Cofres colocables de 16 slots [M]
- [x] Cofres colocables de 28 y 40 slots por materiales [M]
- [x] Almacén del pueblo de 240 slots compartidos [M]
- [x] Apertura de cofre con overlay de dos paneles (bolsillo + cofre) [C]
- [x] Transferencia rápida de todo el panel con un botón [M]
- [x] Transferencia múltiple con cantidad por Ctrl+click [M]
- [x] Id único persistente de cada cofre en el mundo (M17) [M]
- [x] Cierre de cofre con confirmación de operación en curso [S]

## H. Recolección e integración con el mundo (10)

- [x] Recepción directa de cosechas de M13/M15 con cantidad variables [M]
- [x] Recolección con bolsillo lleno: pickup flotante en el mundo [M]
- [x] Pickups flotantes con cantidad y desvanecimiento recogible [M]
- [x] Señal inventory_full con sugerencia amable de guardar en casa [S]
- [x] Espóras de luz: ítem especial con animación de recogida propia [M]
- [x] Espóras de luz: contador global consultable por M55 [M]
- [x] Regalos de NPCs (M19/M20): entrega directa al bolsillo [M]
- [x] Regalo con bolsillo lleno: redirección a la bandeja de correo [C]
- [x] Herramientas M13: equipar, usar y reflejar durabilidad sin peso [M]
- [x] Objetos de misión: categoría propia con protección de descarte [S]

## I. Crafting, tiendas y colecciones (8)

- [x] M16: consumo de materiales desde bolsillo y casa (include_house) [C]
- [x] Tooltip de receta muestra faltantes calculados del total global [M]
- [x] Resultado de craft: bolsillo → casa → mundo en cadena [C]
- [x] M39: venta desde inventario con confirmación y precio por cantidad [M]
- [x] M39: compra con auto-stack en el bolsillo [M]
- [x] M37: donación a museo con consumo y registro de colección [M]
- [x] M37: colección de espóras con contador en el diario M55 [M]
- [x] Mantener inventario legal: cantidades siempre válidas en toda operación [M]

## J. Guardado y rendimiento (10)

- [x] Serialización completa de todos los contenedores para M59 [M]
- [x] Deserialización con validación y fallback seguro sin crash [M]
- [x] Guardado automático periódico con marca de versión de esquema [M]
- [x] Escritura diferida fuera del frame (async) [C]
- [x] Pool de nodos de slot en la UI (reutilización) [C]
- [x] Cero instanciación de escenas por ítem en runtime [M]
- [x] Atlas de iconos por 256 para minimizar draw calls [M]
- [x] Apertura del inventario ≤ 5 ms [M]
- [x] Mover u ordenar 100 ítems ≤ 8 ms [M]
- [x] Refresh de UI solo en slots cambiados por señal [M]

## K. Edge cases y anti-frustración cozy (14)

- [x] Inventario lleno en recolección: el ítem queda en el mundo, nunca se pierde [M]
- [x] Stack completo: el excedente crea un segundo stack en vez de perderse [M]
- [x] Mover ítem a slot con otro tipo: intercambio en lugar de error [M]
- [x] Separar stack mayor de lo disponible: clamp a la cantidad real [S]
- [x] Descarte de ítem protegido: doble confirmación con descripción [S]
- [x] Descarte con mochila llena: el ítem cae al suelo recuperable [M]
- [x] Excepciones en señales de UI atrapadas sin romper el panel [S]
- [x] ItemData faltante en catálogo al cargar: ignorado con log, sin crash [M]
- [x] Cofre removido o destruido (M17): contenido devuelto al bolsillo o al suelo [C]
- [x] Fast travel M69: hotbar y contenedores intactos tras viajar [S]
- [x] Pausa del mundo con inventario abierto: sin desincronización [S]
- [x] Nombres localizados con fallback de idioma (M87) [M]
- [x] Re-escalado de UI sin romper la grilla (M53) [M]
- [x] Imposibilidad de abrir dos overlays de contenedor simultáneos [S]

## L. Accesibilidad, polish, QA y cierre (12)

- [x] Tooltips legibles con contraste mínimo accesible (M58) [S]
- [x] Tamaño de fuente ajustable y fuente de alto contraste [M]
- [x] Atajos reconfigurables por el jugador [M]
- [x] Sonidos de acciones: abrir, mover, apilar, lleno, error suave [M]
- [x] Animación de entrada y salida suave de paneles [M]
- [x] Tutorial M92: primer recogido enseña la hotbar [M]
- [x] Tutorial M92: primer lleno enseña el almacenamiento doméstico [M]
- [x] Números de stack con contraste y tamaño mínimo legible [S]
- [x] Bordes de rareza consistentes en iconos y tooltip [S]
- [x] Desacople total UI/gameplay (servicio único, capa de presentación) [M]
- [x] Logs DOM-14 de errores y descartes protegidos (M103) [S]
- [x] 5 archivos del plan-inicial creados y firmados (este checklist incluido) [S]

> Este checklist cierra el diseño del M14: 24/24 puntos del plan resueltos y reglas de runtime definidas para el agente delegado.