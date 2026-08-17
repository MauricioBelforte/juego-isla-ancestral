**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 17: Construcción

## 1. Resolución de los 28 puntos de la sección 16 del plan maestro (CONSTRUCCIÓN)

| # | Punto | Resolución |
|---|---|---|
| 1 | Modo construcción | Estado del jugador + nodo BuildManager (autoload de construcción): entrada con herramienta/tecla, HUD propio, salida con la misma tecla; el mundo sigue vivo (clima, NPC, tiempo) |
| 2 | Modo decoración | Mismo sistema con filtro de catálogo a muebles/decoración (misma rejilla y validación, costos más bajos); se abre desde el inventario o lejos de obra |
| 3 | Grid | Rejilla voxel de 1 m alineada al origen del mundo M08 (VoxelTools `VoxelBuffer`); piezas de 1x1 y NxN (puertas 1x2, puentes 3x1, etc.) |
| 4 | Snapping | Ajuste de la pieza a la celda voxel más cercana (snap de posición y rotación 90°); redondeo automático al colocar, mover y recolocar |
| 5 | Rotación | Pasos de 90° en Y; datos de rotación persistidos como entero (0-3) para determinismo; la validación se re-evalúa con cada giro |
| 6 | Elevación | Nivel por planta (altura de pared = 1 m base; habitación = 3 m utilizable); teclas de subir/bajar con revalidación de soporte en cada nivel |
| 7 | Copia | Tomar pieza existente como plantilla para el fantasma (sin costo extra durante la copia); utilidad para repetir patrones |
| 8 | Mover objetos | Recolocar una pieza colocada: se desocupan sus celdas originales y se revalida el nuevo destino; los recursos no se re-cobran, solo se reubican |
| 9 | Recolocar | Redondeo a rejilla y revalidación completa al soltar; undo devuelve la pieza a su celda original |
| 10 | Almacenamiento | Devolver piezas al inventario M14 (se convierten en ítems de catálogo); útil para remodelar sin perder nada |
| 11 | Demolición | Confirmación suave (cozy, sin castigo): la pieza se retira del mundo y se reintegra parte de su costo al inventario |
| 12 | Devolución de materiales | Fracción de devolución por tipo de pieza (default 50%, configurable por receta); las piezas de evento (M73) y de ruina (M25) no se devuelven |
| 13 | Vista previa | BuildGhost: MeshInstance3D + material transparente con color = estado (verde válido, rojo inválido); sigue al cursor con suavizado; muestra costo, comida de recursos y advertencias de zona |
| 14 | Objetos inválidos | Toda regla fallida (ocupada, sin soporte, fuera de zona, sin recursos, encima de NPC) bloquea la colocación con motivo texturado en el HUD |
| 15 | Colisiones | Las piezas colocadas reciben colisiones estáticas reales (terreno M08 ya colisiona); ventanas/puertas tienen huecos navegables; el jugador nunca queda encerrado (regla de evacuación) |
| 16 | Restricciones | Reglas por tipo de pieza (PlacementRule), topes por zona, alturas máximas y respeto de parcelas ajenas y ruinas |
| 17 | Paredes | Bloques 1x1x1, variantes de esquina/pilares, material de madera/piedra según receta; soportan techo y puertas |
| 18 | Pisos | Losa 1x1x0.5; base de soporte total para piezas encima; reemplaza césped solo en la celda edificada |
| 19 | Techos | Losa y cumbrera; exige al menos 2 paredes/pilares de soporte en la misma celda |
| 20 | Puertas | Marcos de 1x2; exigen pared; al colocarla se talla hueco navegable para el jugador y NPCs (navmesh M64) |
| 21 | Ventanas | 1x1 en pared; transparentes a la luz (M48 iluminación); decorativas y funcionales (no interactivas en v1) |
| 22 | Escaleras | Bloque inclinado 1x1; exige piso/pared de apoyo; conecta plantas; sube la altura del jugador en modo seguro |
| 23 | Puentes | Losa horizontal de 1-4 celdas; solo sobre agua/techo laguna dentro de zona permitida; devuelve navmesh a la zona |
| 24 | Caminos | Losa plana 1x1 a nivel de césped; sin bloqueo de movimiento; coste mínimo (piedra); decorativos y de guía |
| 25 | Cercas | Vallas 1x1 de 0.7 m; no bloquean el paso del jugador (salto suave) pero señalan límites; parques y parcelas las usan como marcador |
| 26 | Iluminación | Faroles y luces de pieza: SpotLight/OmniLight integrados en la pieza; se encienden con el ciclo M31; costo en resina/ámbar |
| 27 | Muebles | Categoría decoración funcional: camas, mesas, sillas, estanterías (interactúan con M14 almacenamiento en interior M18) |
| 28 | Decoración | Plantas, cuadros, alfombras, tótems y ornamentos; muchas variantes de bajo costo para la personalización cozy |

## 2. Decisiones clave

1. **Construcción por piezas modulares sobre rejilla voxel 1 m, no por bloques sueltos (voxel a voxel).** El mundo base de M08 se genera con Voxel Tools, pero la construcción del jugador usa piezas compuestas (1 a N celdas) que se escriben como subtracción/recorte + datos de pieza. Ventaja: piezas con comportamiento (puertas con hueco navegable, faroles con luz, techos con reglas de soporte) sin que el jugador tenga que construir voxel a voxel; encaja con la estética cozy y el catálogo por ítems.
2. **Rejilla alineada al mundo (global voxel grid de M08), no libre.** Cada celda es un voxel de 1 m; las piezas se anclan a esa cuadrícula con snapping de 90°. Ventaja: serialización trivial (celda + rotación), validación por celdas, y la navmesh y el terreno M08 permanecen coherentes.
3. **Validación por reglas declarativas (PlacementRule por pieza), no un validador único gigante.** Cada receta declara su regla (requiere soporte, requiere pared, solo sobre agua, etc.). Ventaja: agregar piezas nuevas al catálogo no toca BuildValidator.
4. **BuildValidator es la única autoridad de "puede colocar".** BuildManager, BuildPreview y BuildGhost consultan la misma API; no hay rutas de colocación paralelas (evita bugs de validación divergente).
5. **Undo por acciones (pila), no por snapshot del mundo.** Cada acción registra el delta (celdas modificadas + recursos) y se revierte exactamente. Más barato que guardar chunks completos y compatible con M58.
6. **Escritura voxel diferida con dirty flags (M08).** Al confirmar una pieza se marcan los chunks afectados con `VoxelViewer`/`VoxelBuffer` y se regenera solo su mesh. Nunca se regenera el mundo completo.
7. **Zonas declaradas por región (AABB en celdas voxel).** Permisos simples: edificable, protegida (parcelas NPC, ruinas M25), narrativa, agua (solo puentes). Las zonas se comparten con M64 (navmesh) y se consultan antes que las reglas de pieza.

## 3. Alternativas descartadas

- **Colocación libre (sin rejilla) con física de posición:** da control total pero rompe la coherencia con el mundo voxel M08, complica la serialización con floats y genera colisiones impredecibles con el terreno; descartada.
- **Construcción voxel a voxel (edición libre de VoxelBuffer célula por célula):** poderoso, pero frustrante para el público cozy, sin reglas por pieza, sin puertas navegables; descartado como interacción principal (se conserva como límite técnico para contenido de M25).
- **Prefabs prefabricados completos (casas enteras de una pieza):** rápido pero sin personalización ni gradación (no se puede construir pared por pared); descartado; M18 sí usará prefabs de casa para la vivienda del jugador, construida con piezas de este módulo.
- **Undo por snapshot de chunk completo:** memoria excesiva con muchos chunks; descartado en favor del delta por acción.
- **Construcción cooperativa online (plan maestro línea 2184)**: fuera de alcance (single-player); se documenta en 5-FUTURAS-MEJORAS como extensión.
- **Modo pausa dura al construir:** rompe la sensación de mundo vivo (NPC pasan, clima cambia); se usa pausa blanda: el jugador queda en modo construcción pero el mundo continúa.

## 4. Supuestos y alcance

- Alcance v1: piezas estáticas con colisión; vanidad y luz estática. Puertas con hueco navegable; sin mecánicas de puerta animada por jugador (v2).
- La casa del jugador (M18) importa este sistema: ampliaciones = proyectos de paredes/plantas/techos.
- Las ruinas M25 son contenido decorativo fijo: las piezas de ruina solo se pueden admirar o copiar visualmente, nunca demoler (regla `deconstruible = false`).
- El costo de piezas se balancea en M92; los datos de receta (costo, regla, devolución) viven en recursos `.tres`.