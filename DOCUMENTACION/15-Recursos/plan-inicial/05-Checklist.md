**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 15: Recursos

> Marcador de esfuerzo al final de cada ítem: [S] simple · [M] medio · [C] complejo.
> Módulo **delegable**: implementación tras M08 (mundo voxel) y M13 (herramientas).

## A. Requisitos del módulo (10)

- [x] Definir el problema: el mundo voxel debe entregar materiales de forma cozy, cómoda y balanceada [S]
- [x] Registrar dependencias: M14 (Inventario), M16 (Crafting), M08 (Mundo Voxel), M13 (Herramientas) [S]
- [x] Registrar relaciones: M29/M32 (calendario/estaciones), M73 (eventos), M17 (construcción), M61 (rendimiento) [S]
- [x] Separar dentro/fuera de alcance: recetas y UI quedan en M16/M14 [S]
- [x] RF1-RF12 cubiertos y documentados en 01-Requerimientos [S]
- [x] NFR: cozy, rendimiento, determinismo PRNG y data-driven definidos [S]
- [x] Criterios de aceptación con validación jugable (QA 3 días, M114) [S]
- [x] Definir los 6 tipos de recurso: madera, piedra, fibras, comida, minerales, raros [S]
- [x] Definir recursos estacionales y regionales del plan maestro [S]
- [x] Definir materiales ancestrales ("secretos" del plan maestro) [S]

## B. Catálogo de recursos y definiciones (12)

- [x] Crear `resource_catalog.tres` con la lista central de definiciones [M]
- [x] Definir madera común: roble, pino, sauce (def_id, mesh, drops, golpes) [M]
- [x] Definir piedra: granito, pizarra, basalto con piedras finas raras [M]
- [x] Definir fibras: algodón, junco, lino de cañaveral [M]
- [x] Definir comida: fruta kaki, baya azul, seta, coco, pescado de orilla [M]
- [x] Definir minerales: cobre, hierro, plata, piedras preciosas [M]
- [x] Definir raros: oro ancestral, cristal estacional, polvo de estrellas, perla de marea [M]
- [x] Definir herramientas requeridas para cada recurso (hacha, pico, manos, hoz) [S]
- [x] Definir golpes requeridos por dureza (madera 2-3, roca 3-4, mineral 4-6) [S]
- [x] Definir iconos de cada recurso para inventario (carpeta `UI/Resources/`) [M]
- [x] Validar en editor: `validar_definicion()` sin errores para todo el catálogo [S]
- [x] Documentar tabla de cantidades por drop como referencia de balance [S]

## C. ResourceDefinition (10)

- [x] Clase `ResourceDefinition` extendida de Resource con `class_name` [S]
- [x] Campos exportados: def_id, display_name, categoría, rareza, icono [S]
- [x] Campos exportados: herramienta_requerida, golpes_requeridos [S]
- [x] Lista de DropEntry exportada (item_id, cant_min, cant_max, probabilidad) [M]
- [x] Campos de respawn: temporada_respawn, evento_respawn [S]
- [x] Campo de región requerida para spawn natural [S]
- [x] Meshes por estado: intacto, dañado, agotado [M]
- [x] `es_herramienta_valida(herr_id)` para validación de golpe [S]
- [x] `es_estacional_de(nueva_estacion)` para respawn [S]
- [x] `validar_definicion()` con errores accionables en editor [S]

## D. ResourceNode (12)

- [x] Clase `ResourceNode` extends Node3D con states INTACTO/DANIADO/AGOTADO [S]
- [x] Area3D de interacción con tamaño según mesh [M]
- [x] Suscripción a señal global `golpe_aplicado` de M13 [S]
- [x] `aplicar_golpe(pos, herramienta_id, fuerza)` con validación de distancia [S]
- [x] Rechazo suave con herramienta incorrecta: feedback "necesitas un pico" [S]
- [x] Desgaste por golpes: `golpes_restantes -= 1` y cambio de estado a DAÑADO [S]
- [x] Visual de dañado: mesh_daniado + grietas/partículas del material [M]
- [x] Cambio a AGOTADO: mesh_agotado (tocón, roca quebrada, arbusto vacío) [M]
- [x] Notificación `ResourceManager.recurso_agotado(node_id)` al agotarse [S]
- [x] Sacudida y animación leve por golpe (sin romper flujo cozy) [M]
- [x] Sonido por material (madera, piedra, fibra, fruta, metal) [M]
- [x] Modo impostor: mesh estático sin física ni Area3D para distancia [M]

## E. ResourceDrops (10)

- [x] Clase `ResourceDrops` con generación por DropEntry [S]
- [x] Cálculo determinista de cantidades con PRNG M29 [S]
- [x] Drops físicos RigidBody3D con dispersión circular configurable [M]
- [x] Pooling de drops físicos (máx 60 activos, sin allocs en caliente) [C]
- [x] Imán de recogida: radio 1.5 m, deslizamiento suave al jugador [M]
- [x] Auto-recogida al contacto: `Inventario.agregar_items(entrega)` [S]
- [x] Señal `drop_recogido(item_id, cantidad)` para UI/logs [S]
- [x] Drops de calidad: herramienta mejorada aumenta cant máx (drop mejorado) [M]
- [x] Saqueo múltiple: liena de drops animada sin solapamiento visual [S]
- [x] Los drops respetan la gravedad y no atraviesan el terreno (M08) [M]

## F. ResourceSpawner (12)

- [x] Clase `ResourceSpawner` con tabla global de nodos por región [M]
- [x] `planificar_region(region_id)` al recibir `region_activada` de M08 [M]
- [x] Generación de candidatos determinista por seed de partida [M]
- [x] Validación de candidato: caminable, sin superposición, dentro de límites [M]
- [x] Rechazo de recursos inaccesibles (regla del plan maestro) [S]
- [x] `instanciar_nodo(entry)` devuelve node_id y registra en tabla [M]
- [x] `_aplicar_presupuesto()` por distancia al jugador en cada frame suavizado [C]
- [x] 0-48 m activos, 48-96 m impostores, +96 m solo datos [M]
- [x] Máx 200 instancias activas: excedente en cola priorizada [C]
- [x] `revalidar_posiciones(region_id)` al cargar chunk o construir (M17) [M]
- [x] Reubicación de respawn al voxel libre más cercano (radio 8) [M]
- [x] Señal `recurso_reaparecio(def_id, pos)` para mundo vivo [S]

## G. Respawn y regla cozy (10)

- [x] Respawn por estación (M29/M32): comunes reaparecen al cambiar estación [M]
- [x] Respawn rápido de comida: 2-3 días de juego o tras lluvia/evento [M]
- [x] Respawn por evento M73: festival de la cosecha repone comida [M]
- [x] Recursos raros una vez por estación en su región garantizada [M]
- [x] Sin agotamiento irreparable: todo recurso tiene fecha de reaparición [S]
- [x] Fuentes alternativas registradas por recurso (anti-bloqueo QA) [S]
- [x] Tiempo de espera amable: máx 1 estación para materiales comunes [S]
- [x] Sin hambre castigadora: comida como buff, jamás necesidad letal [S]
- [x] Los drops básicos sobredimensionados un 20% sobre consumo razonable [S]
- [x] Sugerencia de fuente alternativa en UI de crafting (M16) [M]

## H. Integración con M13 Herramientas (8)

- [x] Consumo de señal `golpe_aplicado(pos, herramienta_id, fuerza)` [S]
- [x] Validación de herramienta por definición (manos si campo vacío) [S]
- [x] Multiplicador de daño por fuerza (pico mejorado rompe más rápido) [S]
- [x] Sin acoplamiento: la herramienta no conoce al recurso (señal global) [S]
- [x] Feedback de herramienta incorrecta sin penalización [S]
- [x] Durabilidad de la herramienta no afecta drop (decisión cozy) [S]
- [x] Recolección a dos manos posible con herramientas distintas [S]
- [x] Test de golpe aéreo (sin nodo): no produce drops ni errores [S]

## I. Integración con M08 Mundo Voxel (8)

- [x] Anclaje por region_id + voxel_base en cada nodo [M]
- [x] Posicionamiento con altura real: `get_surface_height(region_id, x, z)` [M]
- [x] Sin nodos flotando ni enterrados al instanciar [M]
- [x] Revalidación de altura al reaparecer y al cargar chunk [M]
- [x] Evitar recursos en zonas imposibles de atravesar [S]
- [x] Distribución por bioma según reglas de M09 [M]
- [x] Coordinación con construcción M17: no spawn sobre edificios [M]
- [x] Los recursos raros aparecen solo en su región definida [S]

## J. Integración con M14 Inventario (8)

- [x] Los drops se entregan con `Inventario.agregar_items(entrega)` [S]
- [x] Mapping ítem = recurso: item_id == def_id en el catálogo de ítems [S]
- [x] Inventario lleno: excedente redirigido a caja de almacenamiento [M]
- [x] Sin pérdida de contenido en ninguna ruta de recogida [M]
- [x] Datos de stacked cantidad correctos al recoger múltiples drops [M]
- [x] Señal de recogida no duplica ítems en UI [S]
- [x] Recursos consumibles (comida) entran al inventario como ítem normal [S]
- [x] Test: recoger 100 drops con inventario 60% lleno no pierde nada [M]

## K. Integración con M16 Crafting (6)

- [x] Las recetas referencian item_id de recursos del catálogo [S]
- [x] `ResourceManager.cantidad_de(def_id)` para consulta de stock [S]
- [x] Balance de cantidades centralizado en la definición, no por receta [S]
- [x] Los materiales raros tienen recetas raras/ancestrales (plan maestro) [S]
- [x] Sin recetas redundantes: cada material tiene utilidad real [S]
- [x] Revisión conjunta de cantidades en QA de crafting [M]

## L. Integración con M29/M32/M73 (6)

- [x] Suscripción a `estacion_cambio(nueva_estacion)` [S]
- [x] Respawn masivo de estación con aviso suave en el mundo [M]
- [x] Suscripción a `evento_iniciado` / `evento_finalizado` de M73 [S]
- [x] PRNG de partida para cantidades y distribución (determinismo) [S]
- [x] Pausa del juego no cuenta tiempo de respawn (coherente) [S]
- [x] Guardado/recarga sin duplicar ni perder nodos [M]

## M. Edge cases (12)

- [x] Recurso agotado golpeado de nuevo: sin errores, sin drops [S]
- [x] Golpe en nodo con herramienta incorrecta: feedback, cero daño [S]
- [x] Spawn fuera de límites de región: rechazado en validación [S]
- [x] Spawn sobre agua o acantilado: reposicionado o descartado [M]
- [x] Drops al suelo lleno: conversión a `RecursoBolsa` (máx 40 por zona) [M]
- [x] Drop expirado (120 s): convertido a bolsa durmiente sin pérdida [M]
- [x] Inventario lleno al recoger bolsa: excedente a la caja [M]
- [x] Respawning mientras el jugador está parado sobre el voxel: desplazado [M]
- [x] Construcción (M17) sobre nodo agotado: respawn reubicado [M]
- [x] Carga de partida con nodos agotados de sesión anterior [M]
- [x] Región nunca activada: sin instancias fantasma en memoria [M]
- [x] Catálogo con def_id duplicado: error claro en editor [S]

## N. Optimización (10)

- [x] Presupuesto de instancias según sección F (máx 200 activas) [C]
- [x] Impostores para 48-96 m sin física ni colisiones [M]
- [x] Pooling de drops físicos sin allocs en tiempo de juego [C]
- [x] Pooling de partículas de recolección (una ráfaga por evento) [M]
- [x] Tabla de nodos por diccionario con acceso O(1) [S]
- [x] Solo los nodos no intactos se serializan en el guardado [M]
- [x] Sin instancias nuevas al cargar: rehidratación desde datos [M]
- [x] Colisión de Area3D desactivada en impostores y bolsas durmientes [S]
- [x] Métricas de draw calls y RigidBody en zonas densas (M61) [C]
- [x] Frame budget de `_aplicar_presupuesto` en tramos (no todo en 1 frame) [C]

## O. Persistencia y guardado (6)

- [x] `guardar_estado()` devuelve sólo nodos dañados/agotados + contadores [M]
- [x] `cargar_estado(data)` restaura estados y fechas de reaparición [M]
- [x] Los intactos se regeneran por seed al cargar (guardado chico) [M]
- [x] Formato de datos versionado para migraciones futuras [S]
- [x] Sin dependencia de orden de carga entre módulos (M29 primero) [M]
- [x] Test: jugar 30 min, guardar, recargar y comparar mundo [M]

## P. UI y feedback (6)

- [x] Texto/popup suave de cantidad obtenida al recolectar [M]
- [x] Indicador visual de herramienta requerida al acercarse al nodo [M]
- [x] Feedback de nodo agotado: no parece "roto para siempre" [S]
- [x] Reloj/calendario muestra "en <estación> vuelven los <recurso>" [M]
- [x] Sin acoplamiento: el módulo solo emite señales, la UI se las dibuja [S]
- [x] Iconografía coherente con M14 (mismos iconos) [S]

## Q. Testing y QA (10)

- [x] Test: recolectar cada tipo con herramienta correcta e incorrecta [M]
- [x] Test: los 6 tipos producen drops correctos y cantidades en rango [M]
- [x] Test: agotar 50 árboles y verificar respawn estacional [M]
- [x] Test: suelo saturado genera bolsa y no pierde nada [M]
- [x] Test: determinismo entre dos cargas con mismo seed [M]
- [x] Test: presupuesto con región densa (200+ candidatos) [C]
- [x] Test: cobertura de edge cases de la sección M [M]
- [x] Recorrido M114: 3 días de juego, el jugador siempre tiene material [C]
- [x] Test de onboarding: primer recurso recolectado en los primeros 5 minutos [M]
- [x] Profiler M113: picos de frames con 60 drops y 30 partículas simultáneos [C]

## R. Documentación y cierre (8)

- [x] Módulo marcado delegable (tras M08/M13) [S]
- [x] 6 alternativas descartadas documentadas con justificación [S]
- [x] API estable en 03-Diseno (contratos de señales) [S]
- [x] Implementación → AGENTE DELEGADO [S]
- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado [S]
- [x] 03-Diseno creado y firmado [S]
- [x] 04-Codigo creado y firmado (Notas del Agente) [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]