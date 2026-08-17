**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 17: Construcción

## ID del Módulo
- **Código:** M17 (CHECKLIST-GLOBAL: 0/100, prioridad Alta, complejidad 5)
- **Carpeta:** `DOCUMENTACION/17-Construccion/`
- **Dependencias:** M08 (Mundo Voxel), M14 (Inventario). Relaciones: M18 (Casas), M25 (Ruinas, solo visual), M64 (IA de NPC), M73 (Festival de construcción), M58 (Guardado), M31/M32 (tiempo/clima), M92 (Balance de costes), M93 (Proyectos de construcción), M71 (Logros)
- **Stack:** Godot 4.x (>= 4.4.1) + Voxel Tools (GDExtension) + GDScript

## 1. Problema

El jugador debe poder personalizar Aurora y construir su hogar sobre el mundo voxel: entrar en un modo de construcción con rejilla voxel de 1 m alineada al mundo M08, colocar piezas (paredes, pisos, techos, puertas, ventanas, escaleras, puentes, caminos, cercas, iluminación, muebles y decoración) con previsualización fantasma, rotación, reglas de colocación claras, permisos por zona, costo de recursos del inventario y un ciclo completo de copiar/mover/demoler/devolver — todo cozi, sin combate y sin castigar al jugador. El sistema debe integrarse con M18 (casas), respetar M25 (ruinas como piezas solo visuales), notificar a M64 (NPCs reaccionan a las obras) y persistir en el guardado M58.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Modo construcción y modo decoración | Entrada/salida rápida con herramienta o tecla; HUD propio; catálogo de piezas por categoría; el mundo continúa corriendo (cozy, sin pausa dura) |
| RF2 | Rejilla voxel 1 m | Grid de 1 m alineado al mundo voxel M08 (origen global consistente); piezas ocupan 1x1 o N celdas; snapping de 90° y a altura de planta |
| RF3 | Previsualización fantasma | BuildGhost semi-transparente que sigue al cursor/raycast; verde si válida, rojo si inválida; muestra costo y estado de recursos |
| RF4 | Rotación de piezas | Rotación libre en pasos de 90° por eje Y; la previsualización rotada conserva la validación en vivo |
| RF5 | Elevación y altura | Subir/bajar la pieza por plantas; altura máxima definida; el fantasma revalida soporte en cada nivel |
| RF6 | Permisos de zona | Zonas permitidas (tierra del jugador, parcelas habilitadas) y prohibidas (parcelas de NPC, ruinas M25, terreno narrativo, agua profunda salvo puentes); aviso claro al intentar salir de zona |
| RF7 | Costo de recursos | Cada pieza tiene costo en materiales (M14); se verifica al previsualizar y se descuenta al confirmar; se devuelve (porcentaje configurable) al demoler |
| RF8 | Validación de colocación | Ocupación de celdas, soporte inferior (suelo/pared/piso), reglas por tipo de pieza (puerta y ventana exigen pared; techo exige paredes; escalera toca piso; puente salva agua), no solapar NPCs ni bloquear rutas de IA |
| RF9 | Colocación y deshacer | Confirmación con click; undo de la última acción (colocar/demoler/mover) con restauración exacta de celdas y recursos |
| RF10 | Copiar, mover, recolocar y almacenar | Copiar una pieza existente al fantasma; mover/recolocar piezas colocadas con redondeo a la rejilla; devolver piezas al inventario (M14) |
| RF11 | Demolición y devolución | Demoler cualquier pieza propia con confirmación; devolución parcial de materiales; jamás se destruye sin compensar (cozy) |
| RF12 | Catálogo de piezas | Paredes, pisos, techos, puertas, ventanas, escaleras, puentes, caminos, cercas, iluminación (faroles), muebles y decoración; cada pieza con reglas propias (PlacementRule) |
| RF13 | Integración con módulos | M18: ampliaciones de casa consumen piezas y habitaciones usan el mismo sistema; M25: piezas de ruina son contenido visual no destructible; M64: señal de obra activa y reacción de curiosidad/desvío |
| RF14 | Persistencia | Las construcciones se guardan como lista de piezas (tipo, celda, rotación) y se restauran íntegras en M58; guardado a mitad de colocación no deja estados corruptos |

## 3. Requisitos No Funcionales

- **Cozy:** cero agresividad, cero pérdida injusta de recursos; demolición siempre devuelve algo; el jugador nunca queda atrapado por sus propias construcciones (salida/teletransporte suave).
- **Rendimiento:** la edición del mundo usa escrituras voxel de M08 con dirty flags por chunk (solo se regeneran los chunks afectados); previsualización con pooling de nodos; sin GC spikes (alocaciones minimizadas en el tick de preview).
- **Frame budget:** actualización de la previsualización <= 1 ms por frame; raycast de colocación <= 1 por frame (cooldown si el cursor no se mueve).
- **Determinismo suave:** restauración de construcciones reproducible con PRNG M29; sin diferencias entre cargas.
- **Accesibilidad:** control total con teclado y mando; confirmaciones no punitivas; opción de desactivar el snapping animado.
- **Escalabilidad (M112):** tolerar cientos de piezas en una zona (muchas construcciones) sin caída de FPS; límite suave por zona con aviso.

## 4. Criterios de Aceptación

1. Los 28 puntos de la sección 16 del plan maestro resueltos (modo construcción, decoración, grid, snapping, rotación, elevación, copia, mover, recolocar, almacenar, demolición, devolución, vista previa, objetos inválidos, colisiones, restricciones y las 12 familias de piezas).
2. Colocar, rotar, elevar, copiar, mover, almacenar y demoler una pieza funcionan de punta a punta sobre el mundo voxel M08 con rejilla de 1 m.
3. Validación de ocupación, soporte, zonas y costos verificada con casos límite (pieza en el aire, fuera de zona, encima de NPC, recurso insuficiente).
4. Integración demostrada con M18 (casa ampliable), M25 (ruinas solo visuales) y M64 (NPC desvía su ruta y comenta).
5. Guardado y carga (M58) restauran las construcciones sin pérdidas; test de estrés M112 con muchas construcciones superado.