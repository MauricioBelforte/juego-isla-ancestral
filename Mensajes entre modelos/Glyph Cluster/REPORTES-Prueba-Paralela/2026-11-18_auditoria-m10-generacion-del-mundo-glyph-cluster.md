# Auditoría de Arquitectura — Módulo 10 (Generación del Mundo)

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-18 21:19 (UTC)  
**Módulo auditado:** `10-Generacion-Del-Mundo` (`DOCUMENTACION/10-Generacion-Del-Mundo/plan-actual/`)  
**Alcance de inspección (estático):** `game/isla-ancestral/scripts/world/island_generator.gd`, `world_generator.gd`, `flat_ground_generator.gd`, `block_catalog.gd`, `world_manager.gd`, `mundo_raiz.gd`, `escanear_montanas_m09.gd`, `escanear_conectividad_m09.gd`; `game/isla-ancestral/scripts/main_island.gd`; `game/isla-ancestral/scripts/core/terrain_locator.gd`; `game/isla-ancestral/project.godot` (autoloads relevantes); `DOCUMENTACION/09-Terreno-Y-Geografia/plan-actual/04-Codigo.md` (contrato M09). Búsquedas en `game/isla-ancestral/scripts/`, `data/`, `scenes/` sobre `TerrainFormations`, `FormationRecipe`, `biome_map`, `world_shape`, `data/generation`, formaciones/recetas M09.  
**Método:** lectura de código y documentación, búsqueda de referencias/cadenas de llamada (`_get_island_gen`, `get_height`, `MundoRaiz`, `IslandGenerator`, `VoxelTerrain`). No se ejecutó el proyecto ni se modificó código del juego.

## Resumen ejecutivo

- **M10 no consume M09 como fuente de datos de terreno:** la generación (biomas, agua, minerales, perfil de altura) está implementada de forma autocontenida en `IslandGenerator`; no hay carga de recetas/formaciones/biomas de M09 ni configuración en `data/generation/`.
- **Dependencias ocultas relevantes:** `TerrainLocator` depende en runtime de una API interna del generador (`_get_island_gen()`), y la composición de terreno se acopla por búsqueda de nodos/nombres y por configuración hardcodeada repartida en escena, wrapper y generador.
- **Umbrales hardcodeados:** parámetros de ruido, forma de isla, costas/agua, biomas y vetas están embebidos en código (sin recursos data-driven), dificultando alineación con M09/M46/M51 y calibración.
- **Dependencias circulares de módulo/import:** no se observó un ciclo directo A→B→A de carga/import entre los scripts de generación inspeccionados. Existe acoplamiento bidireccional indirecto en runtime (consumidores consultan la cadena interna del generador) que debe tratarse como deuda arquitectónica.
- **Acoplamiento de composición:** `main_island.gd` concentra la instanciación/configuración del generador, mesher/library y elementos de mundo; `IslandGenerator` declara dependencia a `BlockCatalog` poco utilizada y depende directamente de constantes de `BlockType`.

## Hallazgos

### F-01 — Contrato M10↔M09 no consumido; generación de terreno/biomas desacoplada de las recetas de M09
- **Severidad:** Alto  
- **Ubicación:** `game/isla-ancestral/scripts/world/island_generator.gd:8,11,14,17,20,44-70,73-142,145-200,203-234,236-253`; `game/isla-ancestral/scripts/world/world_generator.gd:1,7-12,21-30,35-47`; `game/isla-ancestral/scripts/main_island.gd:126-153`; `DOCUMENTACION/09-Terreno-Y-Geografia/plan-actual/04-Codigo.md:5-40` (declara que `data/biomes`, `data/formations`, `data/poi` y `FormationRecipe` no existen/no se consumen)  
- **Evidencia:** `IslandGenerator` resuelve forma, altura, biomas, agua superficial/profunda y minerales internamente (ruidos y reglas propias) sin leer artefactos de M09. `world_generator.gd` extiende `VoxelGeneratorScript` e instancia directamente `IslandGenerator` (`:21-30`) delegando bloque a bloque (`:35-47`). La búsqueda en `scripts/`, `data/` y `scenes/` no encontró `TerrainFormations`, `FormationRecipe`, `biome_map`, `world_shape`, `recetas_m09`/`formaciones` aplicadas; no existe `game/isla-ancestral/data/generation/`. M09 (doc) confirma que las recetas propuestas no se crearon, por lo que M10 opera sin insumo canónico de geografía.  
- **Impacto:** divergencia entre diseño de terreno/biomas (M09) e implementación real (M10), duplicación de lógica por módulo consumidor, imposibilidad de validar cumplimiento del contrato y alto costo de cambio para incorporar formaciones/POI/biomas data-driven.  
- **Acción:** materializar un contrato consumible M09→M10 (recursos/datos de biomas, umbrales, formaciones y POI) y adaptar el pipeline para consumirlo; explicitar en código/config qué parte proviene de M09 y qué es fallback local.

### F-02 — Dependencia oculta a API interna del generador (`_get_island_gen`) desde subsistemas externos
- **Severidad:** Alto  
- **Ubicación:** `game/isla-ancestral/scripts/core/terrain_locator.gd:45-52`; `game/isla-ancestral/scripts/world/world_generator.gd:14,19,21-30`; `game/isla-ancestral/scripts/world/island_generator.gd:73`; `game/isla-ancestral/scripts/world/escanear_montanas_m09.gd:17`; `game/isla-ancestral/scripts/world/escanear_conectividad_m09.gd:17`  
- **Evidencia:** `TerrainLocator.get_height` obtiene `terrain.generator`, verifica `has_method("_get_island_gen")` y llama `gen._get_island_gen().get_height(x,z)` (método con convención privada y cadena de tipos concreta). `WorldGenerator` crea/retiene `IslandGenerator` en `_get_island_gen` y expone la instancia implícitamente por ese método. Scripts de análisis headless cargan `world_generator.gd` y dependen del mismo acceso interno.  
- **Impacto:** refactors internos del wrapper o del generador rompen posicionamiento/spawn/herramientas sin señal de compilación de contrato; acoplamiento transversal runtime difícil de rastrear.  
- **Acción:** definir una interfaz pública estable de muestreo de altura/superficie (en generador, terreno o servicio registrado) y migrar consumidores a esa API; prohibir introspección de métodos `_privados` entre subsistemas.

### F-03 — Fuente de verdad fragmentada y hardcode de parámetros de mundo en múltiples capas
- **Severidad:** Alto  
- **Ubicación:** `game/isla-ancestral/scripts/world/island_generator.gd:8,11,14,17,20`; `game/isla-ancestral/scripts/world/world_generator.gd:7-12,23-29`; `game/isla-ancestral/scripts/main_island.gd:148-153`; `game/isla-ancestral/scripts/world/mundo_raiz.gd:16,18,22,24-29`  
- **Evidencia:** `seed`/radio/altura/boost/water level se definen por defecto en `IslandGenerator`, se reexponen como exports en `WorldGenerator`, se vuelven a fijar en `main_island.gd` (`42, 2560, 40, 1.0`) y coexisten con constantes de layout en `MundoRaiz` (`CENTRO 2560,2560`, `RADIO_ISLA 1800`, `RADIO_ORILLA 1700`, `SPAWN_* 3860,3860`). Los valores están duplicados/sin origen único consumido por todos.  
- **Impacto:** riesgo de drift entre generación, posicionamiento y contenido; cambios de escala/radio/semilla requieren ediciones coordinadas manuales y pueden producir inconsistencias sutiles.  
- **Acción:** centralizar parámetros en un perfil/configuración única (recurso o autoload de configuración de mundo) y hacer que escena, wrapper y generador lean la misma fuente.

### F-04 — Umbrales y reglas de generación hardcodeados (no data-driven)
- **Severidad:** Alto  
- **Ubicación:** `game/isla-ancestral/scripts/world/island_generator.gd:44-70,73-142,145-200,203-234,241-253`  
- **Evidencia:** configuración de ruidos (frecuencias 0.02/0.04/0.01/0.1, octavas 3/4/2, offsets de seed +1000/+2000/+3000), curva de isla/costa/agua (p.ej. `dist<=0.94`, `0.94-1.03` agua clara, `>1.03` profunda, potencias y pesos numéricos), capas de superficie/subsuelo/profundidad (`y<=water_level+1`, `height-3`, `height-10`), biomas (`height<=3`, `>max_height*0.8`, `>max_height*0.65`, `height<=8 && humedad>0.45`) y minerales (`val>0.6`, `y<5` cobre, `y<15` hierro, resto cristal) están codificados inline.  
- **Impacto:** calibración frágil, difícil trazabilidad de decisiones de diseño, imposible alinear automáticamente con umbrales/recetas de M09, tablas de M46 o clima/agua de M51 sin editar lógica.  
- **Acción:** extraer umbrales, curvas y tablas por capa/bioma/mineral a datos declarativos versionados y validar rangos/consistencia en carga.

### F-05 — Acoplamiento de composición y conocimiento de infraestructura en `main_island.gd`
- **Severidad:** Medio  
- **Ubicación:** `game/isla-ancestral/scripts/main_island.gd:126-153,140-143,155-179,180-230,231-254`  
- **Evidencia:** la escena principal carga el script del generador por ruta, instancia y configura parámetros, crea `BlockCatalog`/`VoxelMesherBlocky` y asigna `terrain.generator/mesher/material`, además de construir elementos de mundo (océano, disco/base) con posiciones y parámetros acoplados al layout/generación. La orquestación de terreno convive con spawn, UI, NPCs y otros sistemas en el mismo script.  
- **Impacto:** alto radio de cambio en una escena crítica, dificultad para pruebas aisladas del pipeline de generación y acoplamiento entre bootstrap de escena y detalles internos de M10/Voxel Tools.  
- **Acción:** separar un componente de “world setup/composition” responsable de cablear `VoxelTerrain`, generador, mesher y library con configuración inyectada.

### F-06 — `IslandGenerator` acoplado a tipos concretos y contrato de constructor parcialmente innecesario
- **Severidad:** Medio  
- **Ubicación:** `game/isla-ancestral/scripts/world/island_generator.gd:1-3,23,38-41,145-200,246-253,256-264`; `game/isla-ancestral/scripts/world/block_catalog.gd:1-13,149-160`  
- **Evidencia:** `IslandGenerator` requiere `BlockCatalog` en `_init` y lo almacena, pero la lógica de generación usa directamente `BlockType.*`; el catálogo solo se consulta en `get_debug_color` con fallback a `BlockType.create_default`. Esto introduce dependencia de tipo/API sin aportar al muestreo principal y mantiene acoplamiento directo a constantes globales de bloque.  
- **Impacto:** API confusa (dependencia aparente vs real), fricción para sustituir conjuntos de bloques o estrategias de mapeo por bioma/isla, y mayor superficie de cambio en refactors de `BlockType/BlockCatalog`.  
- **Acción:** introducir un proveedor/mapeo de bloques por capa (interfaz) para generación y aislar utilidades de debug; simplificar el constructor a dependencias efectivamente requeridas.

### F-07 — Ciclo de vida oculto del generador mediante singleton estático
- **Severidad:** Medio  
- **Ubicación:** `game/isla-ancestral/scripts/world/world_generator.gd:16-19,21-30`  
- **Evidencia:** `_instancia_global` retiene la instancia de `IslandGenerator` creada en `_get_island_gen()` para evitar liberación durante generación multihilo. `WorldGenerator` se instancia desde escena (`main_island.gd:148`) pero la referencia fuerte es estática/global al script.  
- **Impacto:** ownership implícito, estado que sobrevive más allá del ámbito esperado, riesgo de fugas o contaminación entre recargas/sesiones de test y dificultad para razonar sobre lifetime en threading.  
- **Acción:** hacer explícito el ownership (recurso/objeto gestionado por el terreno o por un servicio de mundo con ciclo de vida controlado) y documentar/encapsular la garantía de vida requerida por Voxel Tools.

### F-08 — Descubrimiento de terreno por nombre/árbol y sondeo por frame en `TerrainLocator`
- **Severidad:** Medio  
- **Ubicación:** `game/isla-ancestral/scripts/core/terrain_locator.gd:13-41,20-23,45-52`  
- **Evidencia:** el localizador busca `VoxelTerrain` por nombre en la escena actual y, si falla, recorre el árbol; reintenta en `_process` mientras `_terrain` sea nulo/inválido. La altura depende de que el nodo encontrado tenga `generator` compatible con la API esperada.  
- **Impacto:** dependencia oculta de la estructura/nombres de escena, coste de sondeo continuo y fallos tardíos o silenciosos cuando la composición cambia.  
- **Acción:** registrar el proveedor de terreno/altura mediante contrato/autoload o señal de inicialización y eliminar polling/búsqueda heurística.

### F-09 — Responsabilidad residual/ambigua en `world_manager.gd`
- **Severidad:** Bajo  
- **Ubicación:** `game/isla-ancestral/scripts/world/world_manager.gd:3-32`; `game/isla-ancestral/scripts/main_island.gd:126-153`  
- **Evidencia:** `world_manager.gd` aplica únicamente `material_override` y documenta que el generador/mesher/library los instala `main_island.gd`, tras un historial de generador competidor. La configuración de terreno queda repartida entre dos puntos con roles no simétricos.  
- **Impacto:** ambigüedad de ownership y riesgo de reintroducir configuraciones divergentes al modificar cualquiera de los dos scripts.  
- **Acción:** consolidar la configuración de `VoxelTerrain` en un único responsable o convertir `world_manager.gd` en fachada explícita sin lógica implícita duplicada.

### F-10 — Herramientas de diagnóstico acopladas a la implementación concreta del wrapper
- **Severidad:** Bajo  
- **Ubicación:** `game/isla-ancestral/scripts/world/escanear_montanas_m09.gd:16-18`; `game/isla-ancestral/scripts/world/escanear_conectividad_m09.gd:16-18`; `game/isla-ancestral/scripts/world/world_generator.gd:21-30`  
- **Evidencia:** los scripts de escaneo instancian `world_generator.gd` por ruta y consumen `._get_island_gen()` para acceder a `get_height`, replicando el acoplamiento interno observado en F-02.  
- **Impacto:** las utilidades de M09/M10 se rompen ante refactors del generador; menor impacto en runtime del juego pero aumenta fricción de mantenimiento.  
- **Acción:** ofrecer una fachada/API de análisis soportada (o reutilizar la interfaz pública propuesta en F-02).

### F-11 — Inconsistencia semántica de constantes de radio/layout frente al radio de generación
- **Severidad:** Ruido  
- **Ubicación:** `game/isla-ancestral/scripts/world/mundo_raiz.gd:16-22`; `game/isla-ancestral/scripts/world/island_generator.gd:11,75-77,112-141`; `game/isla-ancestral/scripts/main_island.gd:150`  
- **Evidencia:** `MundoRaiz` define `RADIO_ISLA=1800` y `RADIO_ORILLA=1700` con semántica de layout/medición, mientras la generación usa `island_radius=2560` como dominio de normalización/forma. Las magnitudes coexisten con significados distintos sin un vínculo explícito en código.  
- **Impacto:** confusión en integraciones futuras (spawn, biomas por anillo, efectos de orilla) y riesgo de usar el radio equivocado.  
- **Acción:** documentar/unificar nomenclatura y relación entre radios de generación, orilla y layout (o derivarlos del mismo perfil).

## Dependencias circulares y acoplamientos en cadena

- **Ciclos de carga/import (estáticos) entre scripts de generación:** **no observados**. `island_generator.gd` (`class_name IslandGenerator`, `extends RefCounted`) no referencia `world_generator.gd`, `main_island.gd` ni `terrain_locator.gd`; `world_generator.gd` depende de `IslandGenerator` y de la API `VoxelGeneratorScript`; `main_island.gd` compone el terreno cargando el wrapper por ruta; `terrain_locator.gd` accede al generador solo en runtime vía árbol de escena.
- **Dependencia inversa oculta en runtime:** presente. `terrain_locator.gd:49-51` (y scripts de escaneo) invocan comportamiento interno de `world_generator.gd:21-30` para llegar a `island_generator.gd:73`. No es un ciclo de módulos, pero crea un acoplamiento bidireccional de hecho entre consumidor de altura y detalle interno del generador.
- **Cadena de composición rígida:** `main_island.gd:140-153` -> `BlockCatalog`/`VoxelMesherBlocky` -> `world_generator.gd` -> `IslandGenerator` -> `BlockType`, con parámetros duplicados y sin punto de inyección de datos M09.

## Dos mejoras de diseño concretas

1. **Perfil único de generación de mundo (data-driven) y puente M09→M10:** crear un recurso/configuración canónica (p. ej. `WorldGenProfile`/`BiomeTable` en `data/generation/` o `data/world/`) que defina seed, dimensiones/radios, ruido, umbrales de costa/agua, biomas, minerales y referencias a formaciones/POI consumibles desde M09. `WorldGenerator` debe recibir ese perfil (export/inyección) y `IslandGenerator` debe muestrear reglas desde datos en lugar de constantes embebidas (`island_generator.gd:44-70,73-142,145-200,203-234,241-253`, `world_generator.gd:7-12,23-29`, `main_island.gd:148-153`). Alinear/derivar `MundoRaiz` desde el mismo perfil para eliminar drift entre layout y generación.
2. **Contrato público de muestreo de terreno + composición desacoplada:** exponer una interfaz estable de altura/consulta de terreno (p. ej. método público en `WorldGenerator` o servicio `TerrainSampler` registrado al iniciar) y migrar `TerrainLocator` y herramientas a ese contrato, eliminando `has_method("_get_island_gen")` y búsquedas por nombre de nodo (`terrain_locator.gd:20-52`, `escanear_*:17`). En paralelo, extraer de `main_island.gd` la construcción de `VoxelTerrain`/mesher/library/generador a un módulo de setup dedicado con dependencias explícitas, dejando la escena como orquestador de alto nivel.

## Cierre

- Auditoría estática; no se modificó código del juego.
- Prioridad sugerida: F-02 y F-03/F-04 (contrato de altura + fuente única de parámetros/umbrales) antes de ampliar capas de generación, para reducir riesgo de regresión y facilitar la integración real de M09.
- Se recomienda registrar las deudas estructurales en el plan de M10/M09 y vincular la corrección de F-02 con `TerrainLocator`/herramientas para evitar roturas en cadena.
