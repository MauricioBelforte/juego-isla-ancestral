**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Reserva actual

- Estado: 🟡 Liberado — iteración 3 cerrada 2026-08-31
- Agente: GLM (Kilo) — iter 1-2 Deepseek V4 Flash (Kilo)
- Fase: 4 (Prototipo mínimo divertido)
- Dificultad: 3
- Vision: V1 (con visión in-engine para respawn visual)
- Entrada: M14 ✅, M11 ✅, M13 ✅, M29 ✅, iter 1-2 (Deepseek, Logs 256/260/264)
- Salida: Persistencia ISaveProvider (M59), respawn con M29, helper `recibir_golpe_en_nodo`, test 0 fallos
- Archivos: `scripts/resources/resource_node.gd`, `resource_definition.gd`, `resource_manager.gd`, `resource_spawner.gd`, `test_recursos_persistencia.gd` (nuevo)
- Fecha: 2026-08-31 07:55

# 05-Checklist.md — Módulo 15: Recursos

> **Nota 2026-08-30 (Deepseek V4 Flash / Kilo):** núcleo data-driven implementado: ResourceManager
> autoload (catálogo, drops, validación herramienta, integración M14), ResourceDefinition class_name
> (6 tipos), ResourceDropEntry. Test headless 0 fallos. Los ítems de nodos 3D (ResourceNode),
> spawner en mundo voxel y respawn estacional requieren visión (V1/V2) y quedan pendientes. Log 256.

> Marcador de esfuerzo al final de cada ítem: [S] simple · [M] medio · [C] complejo.
> Módulo **delegable**: implementación tras M08 (mundo voxel) y M13 (herramientas).

## A. Requisitos del módulo (10)

- [ ] Definir el problema: el mundo voxel debe entregar materiales de forma cozy, cómoda y balanceada [S]
- [ ] Registrar dependencias: M14 (Inventario), M16 (Crafting), M08 (Mundo Voxel), M13 (Herramientas) [S]
- [ ] Registrar relaciones: M29/M32 (calendario/estaciones), M73 (eventos), M17 (construcción), M61 (rendimiento) [S]
- [ ] Separar dentro/fuera de alcance: recetas y UI quedan en M16/M14 [S]
- [ ] RF1-RF12 cubiertos y documentados en 01-Requerimientos [S]
- [ ] NFR: cozy, rendimiento, determinismo PRNG y data-driven definidos [S]
- [ ] Criterios de aceptación con validación jugable (QA 3 días, M114) [S]
- [ ] Definir los 6 tipos de recurso: madera, piedra, fibras, comida, minerales, raros [S]
- [ ] Definir recursos estacionales y regionales del plan maestro [S]
- [ ] Definir materiales ancestrales ("secretos" del plan maestro) [S]

## B. Catálogo de recursos y definiciones (12)

- [ ] Crear `resource_catalog.tres` con la lista central de definiciones [M]
- [ ] Definir madera común: roble, pino, sauce (def_id, mesh, drops, golpes) [M]
- [ ] Definir piedra: granito, pizarra, basalto con piedras finas raras [M]
- [ ] Definir fibras: algodón, junco, lino de cañaveral [M]
- [ ] Definir comida: fruta kaki, baya azul, seta, coco, pescado de orilla [M]
- [ ] Definir minerales: cobre, hierro, plata, piedras preciosas [M]
- [ ] Definir raros: oro ancestral, cristal estacional, polvo de estrellas, perla de marea [M]
- [ ] Definir herramientas requeridas para cada recurso (hacha, pico, manos, hoz) [S]
- [ ] Definir golpes requeridos por dureza (madera 2-3, roca 3-4, mineral 4-6) [S]
- [ ] Definir iconos de cada recurso para inventario (carpeta `UI/Resources/`) [M]
- [ ] Validar en editor: `validar_definicion()` sin errores para todo el catálogo [S]
- [ ] Documentar tabla de cantidades por drop como referencia de balance [S]

## C. ResourceDefinition (10)

- [ ] Clase `ResourceDefinition` extendida de Resource con `class_name` [S]
- [ ] Campos exportados: def_id, display_name, categoría, rareza, icono [S]
- [ ] Campos exportados: herramienta_requerida, golpes_requeridos [S]
- [ ] Lista de DropEntry exportada (item_id, cant_min, cant_max, probabilidad) [M]
- [ ] Campos de respawn: temporada_respawn, evento_respawn [S]
- [ ] Campo de región requerida para spawn natural [S]
- [ ] Meshes por estado: intacto, dañado, agotado [M]
- [ ] `es_herramienta_valida(herr_id)` para validación de golpe [S]
- [ ] `es_estacional_de(nueva_estacion)` para respawn [S]
- [ ] `validar_definicion()` con errores accionables en editor [S]

## D. ResourceNode (12)

- [x] Clase `ResourceNode` extends Node3D con states INTACTO/DANIADO/AGOTADO [S]
- [x] Area3D de interacción con tamaño según mesh [M]
- [ ] Suscripción a señal global `golpe_aplicado` de M13 [S]
- [x] `aplicar_golpe(pos, herramienta_id, fuerza)` con validación de distancia [S]
- [x] Rechazo suave con herramienta incorrecta: feedback "necesitas un pico" [S]
- [x] Desgaste por golpes: `golpes_restantes -= 1` y cambio de estado a DAÑADO [S]
- [x] Visual de dañado: mesh_daniado + grietas/partículas del material [M]
- [x] Cambio a AGOTADO: mesh_agotado (tocón, roca quebrada, arbusto vacío) [M]
- [x] Notificación `ResourceManager.recurso_agotado(node_id)` al agotarse [S]
- [ ] Sacudida y animación leve por golpe (sin romper flujo cozy) [M]
- [ ] Sonido por material (madera, piedra, fibra, fruta, metal) [M]
- [ ] Modo impostor: mesh estático sin física ni Area3D para distancia [M]

## E. ResourceDrops (10)

- [ ] Clase `ResourceDrops` con generación por DropEntry [S]
- [ ] Cálculo determinista de cantidades con PRNG M29 [S]
- [ ] Drops físicos RigidBody3D con dispersión circular configurable [M]
- [ ] Pooling de drops físicos (máx 60 activos, sin allocs en caliente) [C]
- [ ] Imán de recogida: radio 1.5 m, deslizamiento suave al jugador [M]
- [ ] Auto-recogida al contacto: `Inventario.agregar_items(entrega)` [S]
- [ ] Señal `drop_recogido(item_id, cantidad)` para UI/logs [S]
- [ ] Drops de calidad: herramienta mejorada aumenta cant máx (drop mejorado) [M]
- [ ] Saqueo múltiple: liena de drops animada sin solapamiento visual [S]
- [ ] Los drops respetan la gravedad y no atraviesan el terreno (M08) [M]

## F. ResourceSpawner (12)

- [x] Clase `ResourceSpawner` con tabla global de nodos por región [M]
- [x] `planificar_region(region_id)` al recibir `region_activada` de M08 [M]
- [ ] Generación de candidatos determinista por seed de partida [M]
- [ ] Validación de candidato: caminable, sin superposición, dentro de límites [M]
- [ ] Rechazo de recursos inaccesibles (regla del plan maestro) [S]
- [x] `instanciar_nodo(entry)` devuelve node_id y registra en tabla [M]
- [ ] `_aplicar_presupuesto()` por distancia al jugador en cada frame suavizado [C]
- [ ] 0-48 m activos, 48-96 m impostores, +96 m solo datos [M]
- [x] Máx 200 instancias activas: excedente en cola priorizada [C]
- [ ] `revalidar_posiciones(region_id)` al cargar chunk o construir (M17) [M]
- [ ] Reubicación de respawn al voxel libre más cercano (radio 8) [M]
- [x] Señal `recurso_reaparecio(def_id, pos)` para mundo vivo [S]

## G. Respawn y regla cozy (10)

- [ ] Respawn por estación (M29/M32): comunes reaparecen al cambiar estación [M]
- [ ] Respawn rápido de comida: 2-3 días de juego o tras lluvia/evento [M]
- [ ] Respawn por evento M73: festival de la cosecha repone comida [M]
- [ ] Recursos raros una vez por estación en su región garantizada [M]
- [ ] Sin agotamiento irreparable: todo recurso tiene fecha de reaparición [S]
- [ ] Fuentes alternativas registradas por recurso (anti-bloqueo QA) [S]
- [ ] Tiempo de espera amable: máx 1 estación para materiales comunes [S]
- [ ] Sin hambre castigadora: comida como buff, jamás necesidad letal [S]
- [ ] Los drops básicos sobredimensionados un 20% sobre consumo razonable [S]
- [ ] Sugerencia de fuente alternativa en UI de crafting (M16) [M]

## H. Integración con M13 Herramientas (8)

- [ ] Consumo de señal `golpe_aplicado(pos, herramienta_id, fuerza)` [S]
- [ ] Validación de herramienta por definición (manos si campo vacío) [S]
- [ ] Multiplicador de daño por fuerza (pico mejorado rompe más rápido) [S]
- [ ] Sin acoplamiento: la herramienta no conoce al recurso (señal global) [S]
- [ ] Feedback de herramienta incorrecta sin penalización [S]
- [ ] Durabilidad de la herramienta no afecta drop (decisión cozy) [S]
- [ ] Recolección a dos manos posible con herramientas distintas [S]
- [ ] Test de golpe aéreo (sin nodo): no produce drops ni errores [S]

## I. Integración con M08 Mundo Voxel (8)

- [ ] Anclaje por region_id + voxel_base en cada nodo [M]
- [ ] Posicionamiento con altura real: `get_surface_height(region_id, x, z)` [M]
- [ ] Sin nodos flotando ni enterrados al instanciar [M]
- [ ] Revalidación de altura al reaparecer y al cargar chunk [M]
- [ ] Evitar recursos en zonas imposibles de atravesar [S]
- [ ] Distribución por bioma según reglas de M09 [M]
- [ ] Coordinación con construcción M17: no spawn sobre edificios [M]
- [ ] Los recursos raros aparecen solo en su región definida [S]

## J. Integración con M14 Inventario (8)

- [ ] Los drops se entregan con `Inventario.agregar_items(entrega)` [S]
- [ ] Mapping ítem = recurso: item_id == def_id en el catálogo de ítems [S]
- [ ] Inventario lleno: excedente redirigido a caja de almacenamiento [M]
- [ ] Sin pérdida de contenido en ninguna ruta de recogida [M]
- [ ] Datos de stacked cantidad correctos al recoger múltiples drops [M]
- [ ] Señal de recogida no duplica ítems en UI [S]
- [ ] Recursos consumibles (comida) entran al inventario como ítem normal [S]
- [ ] Test: recoger 100 drops con inventario 60% lleno no pierde nada [M]

## K. Integración con M16 Crafting (6)

- [ ] Las recetas referencian item_id de recursos del catálogo [S]
- [ ] `ResourceManager.cantidad_de(def_id)` para consulta de stock [S]
- [ ] Balance de cantidades centralizado en la definición, no por receta [S]
- [ ] Los materiales raros tienen recetas raras/ancestrales (plan maestro) [S]
- [ ] Sin recetas redundantes: cada material tiene utilidad real [S]
- [ ] Revisión conjunta de cantidades en QA de crafting [M]

## L. Integración con M29/M32/M73 (6)

- [ ] Suscripción a `estacion_cambio(nueva_estacion)` [S]
- [ ] Respawn masivo de estación con aviso suave en el mundo [M]
- [ ] Suscripción a `evento_iniciado` / `evento_finalizado` de M73 [S]
- [ ] PRNG de partida para cantidades y distribución (determinismo) [S]
- [ ] Pausa del juego no cuenta tiempo de respawn (coherente) [S]
- [ ] Guardado/recarga sin duplicar ni perder nodos [M]

## M. Edge cases (12)

- [ ] Recurso agotado golpeado de nuevo: sin errores, sin drops [S]
- [ ] Golpe en nodo con herramienta incorrecta: feedback, cero daño [S]
- [ ] Spawn fuera de límites de región: rechazado en validación [S]
- [ ] Spawn sobre agua o acantilado: reposicionado o descartado [M]
- [ ] Drops al suelo lleno: conversión a `RecursoBolsa` (máx 40 por zona) [M]
- [ ] Drop expirado (120 s): convertido a bolsa durmiente sin pérdida [M]
- [ ] Inventario lleno al recoger bolsa: excedente a la caja [M]
- [ ] Respawning mientras el jugador está parado sobre el voxel: desplazado [M]
- [ ] Construcción (M17) sobre nodo agotado: respawn reubicado [M]
- [ ] Carga de partida con nodos agotados de sesión anterior [M]
- [ ] Región nunca activada: sin instancias fantasma en memoria [M]
- [ ] Catálogo con def_id duplicado: error claro en editor [S]

## N. Optimización (10)

- [ ] Presupuesto de instancias según sección F (máx 200 activas) [C]
- [ ] Impostores para 48-96 m sin física ni colisiones [M]
- [ ] Pooling de drops físicos sin allocs en tiempo de juego [C]
- [ ] Pooling de partículas de recolección (una ráfaga por evento) [M]
- [ ] Tabla de nodos por diccionario con acceso O(1) [S]
- [ ] Solo los nodos no intactos se serializan en el guardado [M]
- [ ] Sin instancias nuevas al cargar: rehidratación desde datos [M]
- [ ] Colisión de Area3D desactivada en impostores y bolsas durmientes [S]
- [ ] Métricas de draw calls y RigidBody en zonas densas (M61) [C]
- [ ] Frame budget de `_aplicar_presupuesto` en tramos (no todo en 1 frame) [C]

## O. Persistencia y guardado (6)

- [ ] `guardar_estado()` devuelve sólo nodos dañados/agotados + contadores [M]
- [ ] `cargar_estado(data)` restaura estados y fechas de reaparición [M]
- [ ] Los intactos se regeneran por seed al cargar (guardado chico) [M]
- [ ] Formato de datos versionado para migraciones futuras [S]
- [ ] Sin dependencia de orden de carga entre módulos (M29 primero) [M]
- [ ] Test: jugar 30 min, guardar, recargar y comparar mundo [M]

## P. UI y feedback (6)

- [ ] Texto/popup suave de cantidad obtenida al recolectar [M]
- [ ] Indicador visual de herramienta requerida al acercarse al nodo [M]
- [ ] Feedback de nodo agotado: no parece "roto para siempre" [S]
- [ ] Reloj/calendario muestra "en <estación> vuelven los <recurso>" [M]
- [ ] Sin acoplamiento: el módulo solo emite señales, la UI se las dibuja [S]
- [ ] Iconografía coherente con M14 (mismos iconos) [S]

## Q. Testing y QA (10)

- [ ] Test: recolectar cada tipo con herramienta correcta e incorrecta [M]
- [ ] Test: los 6 tipos producen drops correctos y cantidades en rango [M]
- [ ] Test: agotar 50 árboles y verificar respawn estacional [M]
- [ ] Test: suelo saturado genera bolsa y no pierde nada [M]
- [ ] Test: determinismo entre dos cargas con mismo seed [M]
- [ ] Test: presupuesto con región densa (200+ candidatos) [C]
- [ ] Test: cobertura de edge cases de la sección M [M]
- [ ] Recorrido M114: 3 días de juego, el jugador siempre tiene material [C]
- [ ] Test de onboarding: primer recurso recolectado en los primeros 5 minutos [M]
- [ ] Profiler M113: picos de frames con 60 drops y 30 partículas simultáneos [C]

## R. Documentación y cierre (8)

- [ ] Módulo marcado delegable (tras M08/M13) [S]
- [ ] 6 alternativas descartadas documentadas con justificación [S]
- [ ] API estable en 03-Diseno (contratos de señales) [S]
- [ ] Implementación → AGENTE DELEGADO [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado (Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]

## N. Iteración 3 — Persistencia + Respawn + Helper golpe (GLM Kilo 2026-08-31) — Log 305

> Cierra los pendientes reportados en iter 2 (persistencia de nodos, respawn M29, señal golpe M13). Test 0 fallos. Liberado a 🟡 con 1 [?] honesto (cableado M13→M15).

### N.1 Implementado y verificado (test_recursos_persistencia.gd 0 fallos)

- [x] `ResourceNode`: campos `respawn_dia_absoluto: int` y `respawn_estacion: int` (M15 iter 3) [S]
- [x] `ResourceNode.esta_listo_para_respawn() -> bool` [S]
- [x] `ResourceNode.programar_respawn(dia_absoluto: int)` [S]
- [x] `ResourceNode.evaluar_respawn(dia_actual, estacion_actual) -> bool` con filtro de temporada [M]
- [x] `ResourceNode.configurar()` setea `respawn_estacion` desde `def.get_respawn_estacion_int()` [S]
- [x] `ResourceDefinition.dias_para_respawn: int = 2` (export) [S]
- [x] `ResourceDefinition.get_respawn_estacion_int() -> int` (mapeo temporada_respawn→0..3 o -1) [S]
- [x] `ResourceManager` ISaveProvider real: `get_save_data()` v2 con array de nodos (def_id, pos, estado, golpes_restantes, respawn_dia) [M]
- [x] `ResourceManager.restore_save_data()` valida version=2 y almacena `_estado_guardado_pendiente` [S]
- [x] `ResourceManager.consumir_estado_guardado_para(def_id, pos) -> Dictionary` (match por pos <0.5m, consume una vez) [M]
- [x] `ResourceManager.registrar_nodo(nodo)` / `desregistrar_nodo(nodo)` [S]
- [x] `ResourceManager.recibir_golpe_en_nodo(nodo, herramienta) -> bool`: valida herramienta, aplica golpe, al agotar programa respawn + entrega drops (M14) + emite `recurso_agotado` [M]
- [x] `ResourceManager._on_dia_cambio_m29()` conecta a GameTime.dia_cambio y llama `_evaluar_respawn_global()` [S]
- [x] `ResourceSpawner.instanciar_nodo()` aplica estado guardado vía `consumir_estado_guardado_para` y registra el nodo en el manager [M]
- [x] Test: `_test_persistencia_round_trip` — save/restore + match por pos [M]
- [x] Test: `_test_respawn_con_dia_y_estacion` — día exacto, todas-estaciones, filtro estacional [M]
- [x] Test: `_test_helper_golpe_y_drops` — validación herramienta, agotado, drops, respawn programado [M]
- [x] Test: `_test_registro_y_lista_nodos` — registro/desregistro refleja en save [S]
- [x] Regresión M16 Crafting: 0 fallos [S]
- [x] Regresión M31 Ciclo Día/Noche: 12/0 OK [S]
- [x] Regresión M15 iter 2 (test_recurso_nodo): 0 fallos [S]
- [x] Log 305 generado y firmado [S]

### N.2 Pendientes con dueño (no resueltos en iter 3)

- [?] Cableado M13→M15: M13 `tool_controller.gd` usa `VoxelTool.raycast` (terreno voxel) y NO detecta `ResourceNode` (Node3D con Area3D). El helper `ResourceManager.recibir_golpe_en_nodo(nodo, herramienta)` existe y está testeado; el cableado real (un `RayCast3D` adicional en M13 o un `input_event` en el Area3D del ResourceNode) requiere un cambio en M13 (Hy3) o en el ResourceNode. Documentado en Notas del Agente. [M]
- [?] Meshes del arte (placeholders funcionales ahora) [C]
- [?] `recolectar` en lote/área (M13 área 3×3) para ResourceNode [C]
- [?] Persistencia de `ResourceSpawner` (regiones planificadas, presupuesto) [M]
- [?] Test de cambio de día en runtime que dispare respawn vía GameTime [S]

**Iteración 3 — 25 ítems [x], 5 ítems [?] honestos. Módulo liberado a 🟡. Total: 25 [x] + 135 [ ] + 5 [?] (de 165).**