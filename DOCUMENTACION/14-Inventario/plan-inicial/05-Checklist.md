**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 14: Inventario

Los ítems llevan el marcador de esfuerzo al final de la línea (S: simple, M: medio, C: complejo). El diseño del módulo se considera cerrado cuando todos los ítems están cumplidos; los de runtime los verificará el agente delegado.

## A. Requisitos del módulo (10)

- [ ] Definir el problema: inventario cozy sin frustración para la recolección y gestión de la isla [S]
- [ ] Registrar dependencias: M13, M15, M16, M53; relaciones M17, M18, M19/M20, M21, M37, M39, M55, M59, M87, M92 [S]
- [ ] Catalogar los 24 puntos de la sección 13 del plan maestro [S]
- [ ] RF1: contenedores múltiples (bolsillo, mochila, casa, cofres, almacén, correo) [S]
- [ ] RF2: stacks y límites coherentes por tipo de ítem [S]
- [ ] RF3: ausencia de peso con límite por slots [S]
- [ ] RF4: categorías, ordenamiento, filtros y favoritos [S]
- [ ] RF5: tooltip con nombre, rareza, precio y recetas [S]
- [ ] RF6+RF7: hotbar de 6 y transferencias ágiles [S]
- [ ] RF8+RF9: feedback anti-frustración y descarte seguro [S]

## B. Resolución de los 24 puntos del plan (24)

- [ ] P1: diseño general — bolsillo grid 4x6 + almacenamiento doméstico estilo Animal Crossing [S]
- [ ] P2: cantidad de slots — bolsillo 24, mochila +16, casa 60-120, cofres 16-40, almacén 240 [S]
- [ ] P3: peso o ausencia — sin peso; límite por slots y stack [S]
- [ ] P4: stack máximo — 99 recursos, 10 medianos, 1 únicos, 999 espóras de luz [S]
- [ ] P5: categorías — 9 definidas con pestañas y contadores [S]
- [ ] P6: ordenamiento — por categoría, rareza, nombre o fecha [S]
- [ ] P7: filtros — pestaña, búsqueda de texto y solo favoritos [S]
- [ ] P8: favoritos — toggle por slot con pin fijo ante sort [S]
- [ ] P9: tooltip — hover con delay 0.5 s y datos completos [S]
- [ ] P10: selección rápida — atajos 1-6 y rueda del mouse [S]
- [ ] P11: hotbar — barra fija de 6 slots con contadores [S]
- [ ] P12: almacenamiento doméstico — cofre de casa 60 ampliable a 120 [S]
- [ ] P13: cofres colocables — 16/28/40 slots con id único en el mundo [S]
- [ ] P14: almacenes — almacén comunitario de 240 slots compartidos [S]
- [ ] P15: mochila — mejora de +16 slots con adquisición amistosa [S]
- [ ] P16: mejoras de capacidad — ruta corta (casa y mochila) sin compras incrementales [S]
- [ ] P17: iconos — atlas 256 por categoría con borde de rareza [S]
- [ ] P18: estados bloqueados — candado con explicación de desbloqueo [S]
- [ ] P19: feedback de lleno — aviso 80%, botín al mundo, notificación amable [S]
- [ ] P20: transferencia rápida — stack completo con un botón [S]
- [ ] P21: transferencia múltiple — cantidad personalizada y por categoría [S]
- [ ] P22: separación de stacks — dividir con prefill de la mitad [S]
- [ ] P23: descarte — soltar al mundo como pickup recuperable [S]
- [ ] P24: confirmación de objetos importantes — diálogo de 2 pasos para protegidos [S]

## C. Núcleo de datos (12)

- [ ] ItemData como Resource con id inmutable y estable [M]
- [ ] Campos de ItemData: nombre, descripción, icono, categoría, stack, rareza, precio [M]
- [ ] Claves de localización en ItemData para M87 (sin cadenas crudas) [M]
- [ ] Flag protected_from_discard en ItemData [S]
- [ ] ItemCatalog: registro central id → ItemData con carga bajo demanda [M]
- [ ] InventorySlot: item_id, cantidad, favorito, bloqueado [S]
- [ ] Inventory como contenedor genérico de slots con tamaño dinámico [M]
- [ ] Señales por slot (changed) y por contenedor (tamaño) [M]
- [ ] to_dict/from_dict con versión y validación de integridad [M]
- [ ] Rechazo de ids desconocidos en from_dict con log DOM-14 [M]
- [ ] Enum ContainerType: BOLSILLO, MOCHILA, CASA, COFRE, ALMACEN, CORREO [S]
- [ ] Conversión de tamaño de contenedor sin perder ítems (clamp y migración) [M]

## D. Slots, stacks y manipulación (10)

- [ ] add_item con auto-stacking en primer slot compatible [M]
- [ ] Overflow de stack: reparto entre slots y sobrante devuelto [M]
- [ ] add_item con contenedor lleno: retorno del sobrante y señal inventory_full [M]
- [ ] remove_item con validación de cantidad existente [S]
- [ ] count_item con opción de incluir la casa [S]
- [ ] Mover ítem entre slots del mismo contenedor e intercambiar [M]
- [ ] Mover entre contenedores con unión automática de stacks parciales [M]
- [ ] split_stack con cantidad exacta y clamp al máximo [S]
- [ ] Consumo de materiales por crafting y regalos con verificación previa [M]
- [ ] Protección contra cantidades negativas y stack overflow en todas las API [S]

## E. UI del inventario (12)

- [ ] Panel principal con grilla de slots reutilizando slot.tscn [C]
- [ ] Pestañas de categoría con contadores de ítems [M]
- [ ] Búsqueda por texto sanitizada con memoria del último filtro [M]
- [ ] Sort con memoria de preferencia del jugador [M]
- [ ] Toggle de favoritos con tecla rápida y pin visual [S]
- [ ] Tooltip lazy con delay 0.5 s y panel de detalle [M]
- [ ] Acciones contextuales por slot: usar, equipar, vender, donar, descartar [C]
- [ ] Indicador de capacidad usada/total visible [S]
- [ ] Feedback visual suave al agregar y quitar ítems [M]
- [ ] Apertura con pausa suave del mundo (M29 UI-only) [C]
- [ ] Soporte completo de gamepad y teclado/mouse [C]
- [ ] Release de foco y cierre limpio sin estado colgado [S]

## F. Hotbar y selección rápida (8)

- [ ] Hotbar fija de 6 slots siempre visible [S]
- [ ] Asignación por arrastre desde el inventario y por atajo de tecla [M]
- [ ] Ciclo de selección con teclas 1-6 y rueda del mouse [S]
- [ ] Equipamiento de herramientas M13 desde la hotbar [M]
- [ ] Uso del ítem seleccionado con el botón principal de acción [S]
- [ ] Feedback de selección con contorno y sonido [S]
- [ ] Contador de cantidad y durabilidad en cada slot de la hotbar [M]
- [ ] Persistencia de la configuración de hotbar en el guardado M59 [M]

## G. Almacenamiento doméstico, cofres y almacenes (10)

- [ ] Cofre de casa con 60 slots iniciales [M]
- [ ] Ampliación de casa a 120 slots con las expansiones de M18 [M]
- [ ] Cofres colocables de 16 slots [M]
- [ ] Cofres colocables de 28 y 40 slots por materiales [M]
- [ ] Almacén del pueblo de 240 slots compartidos [M]
- [ ] Apertura de cofre con overlay de dos paneles (bolsillo + cofre) [C]
- [ ] Transferencia rápida de todo el panel con un botón [M]
- [ ] Transferencia múltiple con cantidad por Ctrl+click [M]
- [ ] Id único persistente de cada cofre en el mundo (M17) [M]
- [ ] Cierre de cofre con confirmación de operación en curso [S]

## H. Recolección e integración con el mundo (10)

- [ ] Recepción directa de cosechas de M13/M15 con cantidad variables [M]
- [ ] Recolección con bolsillo lleno: pickup flotante en el mundo [M]
- [ ] Pickups flotantes con cantidad y desvanecimiento recogible [M]
- [ ] Señal inventory_full con sugerencia amable de guardar en casa [S]
- [ ] Espóras de luz: ítem especial con animación de recogida propia [M]
- [ ] Espóras de luz: contador global consultable por M55 [M]
- [ ] Regalos de NPCs (M19/M20): entrega directa al bolsillo [M]
- [ ] Regalo con bolsillo lleno: redirección a la bandeja de correo [C]
- [ ] Herramientas M13: equipar, usar y reflejar durabilidad sin peso [M]
- [ ] Objetos de misión: categoría propia con protección de descarte [S]

## I. Crafting, tiendas y colecciones (8)

- [ ] M16: consumo de materiales desde bolsillo y casa (include_house) [C]
- [ ] Tooltip de receta muestra faltantes calculados del total global [M]
- [ ] Resultado de craft: bolsillo → casa → mundo en cadena [C]
- [ ] M39: venta desde inventario con confirmación y precio por cantidad [M]
- [ ] M39: compra con auto-stack en el bolsillo [M]
- [ ] M37: donación a museo con consumo y registro de colección [M]
- [ ] M37: colección de espóras con contador en el diario M55 [M]
- [ ] Mantener inventario legal: cantidades siempre válidas en toda operación [M]

## J. Guardado y rendimiento (10)

- [ ] Serialización completa de todos los contenedores para M59 [M]
- [ ] Deserialización con validación y fallback seguro sin crash [M]
- [ ] Guardado automático periódico con marca de versión de esquema [M]
- [ ] Escritura diferida fuera del frame (async) [C]
- [ ] Pool de nodos de slot en la UI (reutilización) [C]
- [ ] Cero instanciación de escenas por ítem en runtime [M]
- [ ] Atlas de iconos por 256 para minimizar draw calls [M]
- [ ] Apertura del inventario ≤ 5 ms [M]
- [ ] Mover u ordenar 100 ítems ≤ 8 ms [M]
- [ ] Refresh de UI solo en slots cambiados por señal [M]

## K. Edge cases y anti-frustración cozy (14)

- [ ] Inventario lleno en recolección: el ítem queda en el mundo, nunca se pierde [M]
- [ ] Stack completo: el excedente crea un segundo stack en vez de perderse [M]
- [ ] Mover ítem a slot con otro tipo: intercambio en lugar de error [M]
- [ ] Separar stack mayor de lo disponible: clamp a la cantidad real [S]
- [ ] Descarte de ítem protegido: doble confirmación con descripción [S]
- [ ] Descarte con mochila llena: el ítem cae al suelo recuperable [M]
- [ ] Excepciones en señales de UI atrapadas sin romper el panel [S]
- [ ] ItemData faltante en catálogo al cargar: ignorado con log, sin crash [M]
- [ ] Cofre removido o destruido (M17): contenido devuelto al bolsillo o al suelo [C]
- [ ] Fast travel M69: hotbar y contenedores intactos tras viajar [S]
- [ ] Pausa del mundo con inventario abierto: sin desincronización [S]
- [ ] Nombres localizados con fallback de idioma (M87) [M]
- [ ] Re-escalado de UI sin romper la grilla (M53) [M]
- [ ] Imposibilidad de abrir dos overlays de contenedor simultáneos [S]

## L. Accesibilidad, polish, QA y cierre (12)

- [ ] Tooltips legibles con contraste mínimo accesible (M58) [S]
- [ ] Tamaño de fuente ajustable y fuente de alto contraste [M]
- [ ] Atajos reconfigurables por el jugador [M]
- [ ] Sonidos de acciones: abrir, mover, apilar, lleno, error suave [M]
- [ ] Animación de entrada y salida suave de paneles [M]
- [ ] Tutorial M92: primer recogido enseña la hotbar [M]
- [ ] Tutorial M92: primer lleno enseña el almacenamiento doméstico [M]
- [ ] Números de stack con contraste y tamaño mínimo legible [S]
- [ ] Bordes de rareza consistentes en iconos y tooltip [S]
- [ ] Desacople total UI/gameplay (servicio único, capa de presentación) [M]
- [ ] Logs DOM-14 de errores y descartes protegidos (M103) [S]
- [ ] 5 archivos del plan-inicial creados y firmados (este checklist incluido) [S]

> Este checklist cierra el diseño del M14: 24/24 puntos del plan resueltos y reglas de runtime definidas para el agente delegado.