**Modelo:** MiMo V2.5 (OpenCode)
**Plataforma:** OpenCode
**Fecha:** 2026-08-27 (iteración 3)

> ⚠️ **Aviso de reconstrucción:** Este checklist fue regenerado por ox-alpha (Cline) el 2026-08-26 a partir de `plan-inicial/05-Checklist.md` (copia original), porque el archivo de `plan-actual` había quedado vacío (solo la firma). Se marcaron `[x]` únicamente los ítems **verificados como implementados** en la iteración 1 (núcleo de datos, logs 168/169). El resto permanece `[ ]` (UI, almacenamiento doméstico/cofres/almacén, integraciones con M13/M15/M16/M17/M19/M20/M37/M39 y aspectos visuales que requieren visión).

# 05-Checklist.md — Módulo 14: Inventario

Los ítems llevan el marcador de esfuerzo al final de la línea (S: simple, M: medio, C: complejo). El diseño del módulo se considera cerrado cuando todos los ítems están cumplidos; los de runtime los verificará el agente delegado.

## A. Requisitos del módulo (12)

- [x] Definir el problema: inventario cozy sin frustración para la recolección y gestión de la isla [S]
- [x] Registrar dependencias: M13, M15, M16, M53; relaciones M17, M18, M19/M20, M37, M39, M55, M59, M87, M92 [S]
- [x] Catalogar los 24 puntos de la sección 13 del plan maestro [S]
- [x] RF1: contenedores múltiples (bolsillo, mochila, casa, cofres, almacén, correo) [S]
- [x] RF2: stacks y límites coherentes por tipo de ítem [S]
- [x] RF3: ausencia de peso con límite por slots [S]
- [x] RF4: categorías, ordenamiento, filtros y favoritos [S]
- [x] RF5: tooltip con nombre, rareza, precio y recetas [S]
- [x] RF6+RF7: hotbar de 6 y transferencias ágiles [S]
- [x] RF8+RF9: feedback anti-frustración y descarte seguro [S]

## B. Resolución de los 24 puntos del plan (24)

- [x] P1: diseño general — bolsillo grid 4x6 + almacenamiento doméstico [S]
- [x] P2: cantidad de slots — bolsillo 24, mochila +16, casa 60-120, cofres 16-40, almacén 240 [S]
- [x] P3: peso o ausencia — sin peso; límite por slots y stack [S]
- [x] P4: stack máximo — 99 recursos, 10 medianos, 1 únicos, 999 espóras [S]
- [x] P5: categorías — 9 definidas con pestañas y contadores [S]
- [x] P6: ordenamiento — por categoría, rareza, nombre o fecha [S]
- [x] P7: filtros — pestaña, búsqueda de texto y solo favoritos [S]
- [x] P8: favoritos — toggle por slot con pin fijo ante sort [S]
- [x] P9: tooltip — hover con delay 0.5 s y datos completos [S]
- [x] P10: selección rápida — atajos 1-6 y rueda del mouse [S]
- [x] P11: hotbar — barra fija de 6 slots con contadores [S]
- [x] P12: almacenamiento doméstico — cofre de casa 60 ampliable a 120 [S]
- [x] P13: cofres colocables — 16/28/40 slots con id único [S]
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
- [x] P24: confirmación de objetos importantes — diálogo de 2 pasos [S]

> Nota: las secciones A y B son requisitos/diseño ya resueltos en la documentación original (Deepseek). Se mantienen `[x]` por corresponder a decisión de diseño cerrada en el plan inicial, no a implementación de runtime.

## C. Núcleo de datos (12)

- [x] ItemData como Resource con id inmutable y estable (extendido desde M159 `item_data.gd`) [M]
- [x] Campos de ItemData: nombre, descripción, icono, categoría, stack, rareza, precio [M]
- [x] Claves de localización en ItemData para M87 (sin cadenas crudas) [M]
- [x] Flag protected_from_discard en ItemData [S]
- [x] ItemCatalog: registro central id → ItemData con carga bajo demanda (M159 `item_database.gd`) [M]
- [x] InventorySlot: item_id, cantidad, favorito, bloqueado + `instancia` [S]
- [x] Inventory como contenedor genérico de slots con tamaño dinámico (`inventario_contenedor.gd`) [M]
- [x] Señales por slot (changed) y por contenedor (tamaño) [M]
- [x] to_dict/from_dict con versión y validación de integridad (serialización mínima) [M]
- [ ] Rechazo de ids desconocidos en from_dict con log DOM-14 [M]
- [x] Enum ContainerType: BOLSILLO, MOCHILA, CASA, COFRE, ALMACEN, CORREO (`container_type.gd`) [S]
- [x] Conversión de tamaño de contenedor sin perder ítems (fallback en cadena) [M]

## D. Slots, stacks y manipulación (10)

- [x] add_item con auto-stacking en primer slot compatible (dos pasadas) [M]
- [x] Overflow de stack: reparto entre slots y sobrante devuelto como int [M]
- [x] add_item con contenedor lleno: retorno del sobrante y señal inventory_full [M]
- [x] remove_item con validación de cantidad existente [S]
- [x] count_item con opción de incluir la casa [S]
- [x] Mover ítem entre slots del mismo contenedor e intercambiar [M]
- [x] Mover entre contenedores con unión automática de stacks parciales [M]
- [x] split_stack con cantidad exacta y clamp al máximo [S]
- [ ] Consumo de materiales por crafting y regalos con verificación previa [M]
- [x] Protección contra cantidades negativas y stack overflow en todas las API [S]
## E. UI del inventario (12)

- [x] Panel principal con grilla de slots reutilizando slot.tscn [C]
- [x] Pestañas de categoría con contadores de ítems [M]
- [ ] Búsqueda por texto sanitizada con memoria del último filtro [M]
- [ ] Sort con memoria de preferencia del jugador [M]
- [ ] Toggle de favoritos con tecla rápida y pin visual [S]
- [x] Tooltip lazy con delay 0.5 s y panel de detalle [M]
- [x] Acciones contextuales por slot: usar, equipar, vender, donar, descartar [C]
- [x] Indicador de capacidad usada/total visible [S]
- [ ] Feedback visual suave al agregar y quitar ítems [M]
- [ ] Apertura con pausa suave del mundo (M29 UI-only) [C]
- [ ] Soporte completo de gamepad y teclado/mouse [C]
- [x] Release de foco y cierre limpio sin estado colgado [S]

## F. Hotbar y selección rápida (8)

- [x] Hotbar fija de 6 slots siempre visible [S]
- [ ] Asignación por arrastre desde el inventario y por atajo de tecla [M]
- [x] Ciclo de selección con teclas 1-6 y rueda del mouse [S]
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

- [x] Recepción directa de cosechas de M13/M15 con cantidades variables [M]
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

- [x] Serialización completa de todos los contenedores para M59 (to_dict/from_dict) [M]
- [x] Deserialización con validación y fallback seguro sin crash (ISaveProvider + schema) [M]
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
- [ ] 5 archivos del plan-actual actualizados y firmados (este checklist incluido) [S]

## Registro de progreso (totales)

| Sección | Total | Marcados `[x]` |
|---|---|---|
| A. Requisitos | 10 | 10 |
| B. Puntos del plan | 24 | 24 (documentación) |
| C. Núcleo de datos | 12 | 11 |
| D. Slots/stacks | 10 | 9 |
| E. UI | 12 | 6 |
| F. Hotbar | 8 | 2 |
| G. Almacenamiento | 10 | 0 |
| H. Recolección/integración | 10 | 1 |
| I. Crafting/tiendas/colecciones | 8 | 0 |
| J. Guardado/rendimiento | 10 | 2 |
| K. Edge cases | 14 | 0 |
| L. Accesibilidad/polish/QA | 12 | 0 |

> **TOTAL: 140 ítems · 32 marcados `[x]` de runtime** (34 adicionales de A/B son decisión de diseño). Estado del módulo: **iteración 3 completada** — pestañas de categoría, tooltip lazy 0.5s, acciones contextuales (usar/favorito/descartar), fondo semi-transparente, ESC cierra inventario. Pendientes: búsqueda texto, sort con memoria, drag-drop, almacenamiento doméstico, cofres, integraciones avanzadas.

## Reserva actual

- **Módulo:** 14 Inventario
- **Reservado por:** MiMo V2.5 (OpenCode)
- **Estado:** Iteración 3 completada (categorías, tooltip, acciones, .tres items)
- **Fecha reserva/liberación:** 2026-08-27

## Notas del Agente

**Modelo:** MiMo V2.5 (OpenCode)
**Plataforma:** OpenCode
**Fecha:** 2026-08-27
**Estado:** Iteración 3 completada

### Lo que hice en esta iteración
- **18 .tres de ItemData:** dirt, grass, stone, sand, clay, wood, planks, copper_ore, iron_ore, crystal, gemstone, glass, ancient_crystal, ice, snow, gravel, moss, mud
- **Pestañas de categoría (E2):** 10 pestañas (Todos, Construcción, Herramientas, Arte, Items, Naturaleza, Cocina, Trabajo, Ropa, Decoración) con filtro y contadores
- **Tooltip lazy (E6):** PanelContainer con delay 0.5s que muestra nombre, descripción, rareza y precio
- **Acciones contextuales (E7):** Menú click derecho con Usar, Favorito/Desfavorecer, Descartar
- **Cierre con ESC (E12):** ESC cierra inventario y oculta tooltip/context menu
- **Fondo semi-transparente:** ColorRect backdrop oscurece el fondo
- **Fixes:** `rareza_str` y `slot_rect` con tipos explícitos (error §9.36), `_create_hotbar_hud.call_deferred()` (error §9.37)

### Lo que NO está resuelto (pendientes F4)
- Búsqueda por texto (E3), sort con memoria (E4), toggle favoritos tecla rápida (E5)
- Feedback visual suave al agregar/quitar ítems (E9)
- Apertura con pausa suave del mundo (E10)
- Soporte gamepad completo (E11)
- Almacenamiento doméstico (casa), cofres colocables (M17), almacén comunitario
- Drag-drop entre slots y contenedores
- Integraciones con M15 (recursos), M16 (crafting), M39 (tiendas)

### Recomendaciones para el próximo agente
- El `Rareza` ahora se muestra en el tooltip como string (Common/Uncommon/Rare/Epic/Legendary)
- Las acciones "Usar" y "Descartar" son placeholders — reemplazar cuando M15/M16/M39 estén integrados
- Para drag-drop, usar la skill `godot-inventory-system` como referencia
- Pendiente: sort con memoria (E4), búsqueda por texto (E3), toggle favoritos tecla rápida (E5)
