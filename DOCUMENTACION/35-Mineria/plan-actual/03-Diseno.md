**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code

# 03-Diseno.md — Módulo 35: Minería

## 1. Arquitectura

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                  MiningManager (Autoload)                   â”‚
│  registro de definiciones · distribución en chunks · regen  │
│  límites por zona · persistencia · señales de eventos       │
â””â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
        â”‚ API                â”‚ API               â”‚ API
â”Œâ”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚   OreVein       â”‚  â”‚  MiningTool    â”‚  â”‚  M08 Mundo Voxel   â”‚
│ estado de veta  │  │ pico (M13)     │  │ edición de bloques │
│ golpes restantes│  │ raycast·golpe  │  │ remeshing diferido │
│ temporizador    │  │ durabilidad    │  │ iluminación        │
â””â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
        â”‚ OreDefinition      â”‚ drops
â”Œâ”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”          â”‚
â”‚  OreDefinition  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ (Resource .tres)â”‚  â”‚  M15 Recursos   â”‚   â”‚ M26 Templo Sub.  â”‚
│ id·dureza·drops │  │ inventario      │   │ capa ancestral   │
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Patrones:** Composición (OreVein usa OreDefinition), Service Locator (MiningManager autoload), capa de datos en Resources (`.tres`), señales para eventos de gameplay. La UI consume señales; ninguna clase de UI se referencia desde los managers.

## 2. Componentes

### 2.1 OreDefinition (Resource)

Datos puros de un mineral, instanciable como `.tres` en el catálogo.

| Propiedad | Tipo | Descripción |
|---|---|---|
| `id` | StringName | Identificador único (coincide con M15) |
| `display_name` | String | Nombre en español |
| `rarity` | enum (COMUN/RARO/ANCESTRAL) | Rareza para colecciones |
| `depth_min` / `depth_max` | int | Banda de profundidad en bloques |
| `hardness` | int | Golpes por bloque (2-4) |
| `drop_min` / `drop_max` | int | Cantidad de recurso por bloque |
| `double_drop_chance` | float 0..1 | Probabilidad base de doble drop |
| `respawn_days` | float | Días de juego para regenerar |
| `brightness` | Color | Brillo/emisivo de la veta |
| `particle_scene` | PackedScene | Partículas de extracción |
| `sound_hit` / `sound_break` | AudioStream | Sonidos del mineral |

### 2.2 OreVein (Node3D)

Estado de una veta en el mundo. **No duplica geometría**: la geometría es del voxel M08.

| Propiedad | Tipo | Descripción |
|---|---|---|
| `ore_id` | StringName | Mineral de la veta |
| `blocks` | Array[Vector3i] | Posiciones de los bloques en el voxel |
| `state` | enum (INTACTA / AGOTADA / REGENERANDO) | Estado actual |
| `blocks_remaining` | int | Bloque actual a golpear |
| `golpes_actual` | int | Golpes restantes del bloque actual |
| `regen_remaining` | float | Tiempo de juego restante (días) |

**Señales:** `vein_depleted(vein)` · `vein_recovered(vein)`

### 2.3 MiningTool (Node3D)

Equivalente funcional del pico de M13. Se monta en el pico equipado.

| Propiedad | Tipo | Descripción |
|---|---|---|
| `tool_power` | int | Poder del pico (1-3) |
| `cooldown` | float | Segundos entre golpes (0.6 base) |
| `range` | float | Alcance del raycast (3-4 bloques) |
| `durability_current` / `durability_max` | int | Durabilidad (compartida con M13) |

**Señales:** `swing_started()` · `hit_vein(vein, drops)` · `hit_air()`

### 2.4 MiningManager (Autoload `mineria`)

Orquestador global.

| Señal | Descripción |
|---|---|
| `ore_dropped(ore: OreDefinition, amount: int, world_pos: Vector3)` | Recursos entregados a M15 |
| `vein_recovered_global(vein_id: int)` | Veta regenerada en el mundo |
| `zone_exhausted(zona: StringName)` | Límite diario suave alcanzado |

### 2.5 Catálogo de minerales — tabla de diseño (P2, 2026-10-20)

Estado **medido en disco** antes de diseñar (no heredado de la checklist):

| Medición | Valor real | Fuente |
|---|---|---|
| Vetas en el catálogo | **6** (`ores.json`, 2.470 B) | `game/isla-ancestral/data/mining/ores.json` |
| Objetivo de P2 | **8+** | `05-Checklist.md` L24 |
| Items en el catálogo M15/M159 | **300** `.tres` | `game/isla-ancestral/data/items/` |
| Items con forma de mineral | **7** | `ancient_crystal`, `copper_ore`, `crystal`, `fragmento_ancestral`, `gemstone`, `iron_ore`, `mineral_cobre` |
| Items de mineral **sin uso** | **2** | `gemstone`, `copper_ore` |
| Item de oro | **0** | no existe `gold_ore` ni `mineral_oro` |

Tabla de diseño propuesta. Las 6 primeras filas son las que ya existen en `ores.json`
(valores leídos del archivo, no inventados); las 2 últimas son las que faltan para llegar a 8.

| # | id | Nombre | Rareza | Banda | Región | Golpes | Drop | Prob. | Venta | Respawn | `item_id` | Estado |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `veta_cobre` | Veta de Cobre | COMÃšN (0) | superficie | cantera | 2 | 1-2 | 1.0 | 8 | 2 d | `mineral_cobre` | existe |
| 2 | `veta_hierro` | Veta de Hierro | COMÃšN (1) | subterraneo_medio | cantera | 3 | 1-2 | 1.0 | 15 | 3 d | `iron_ore` | existe |
| 3 | `veta_oro` | Veta de Oro | COMÃšN (2) | subterraneo_medio | cantera | 4 | 1-1 | 1.0 | 30 | 4 d | `ancient_crystal` | existe, **item mal apuntado** |
| 4 | `veta_cristal` | Veta de Cristal Estacional | RARO (2) | profundo | cueva | 4 | 1-1 | 1.0 | 45 | 4 d | `crystal` | existe |
| 5 | `veta_ancestral` | Mineral Ancestral | RARO (3) | ancestral | templo | 6 | 1-1 | 0.3 | 80 | 5 d | `fragmento_ancestral` | existe |
| 6 | `veta_polvo_estrellas` | Polvo de Estrellas | RARO (3) | ancestral | templo | 6 | 1-1 | 0.2 | 120 | 7 d | `ancient_crystal` | existe, **item compartido** |
| 7 | `veta_gema` | Veta de Gema | RARO (2) | profundo | cueva | 5 | 1-1 | 0.4 | 60 | 4 d | `gemstone` | **nueva**, item ya existe y está sin uso |
| 8 | `veta_oro_puro` | Oro Puro | RARO (3) | subterraneo_profundo | cantera | 6 | 1-1 | 0.15 | 95 | 6 d | `gold_ore` | **nueva**, requiere item nuevo |

**Progresión de valor (coherencia interna):** 8 < 15 < 30 < 45 < 60 < 80 < 95 < 120.
Cada banda tiene al menos una veta y la rareza nunca baja al subir de banda.
Los `valor_venta` son **propuesta**: el ítem `[?]` "Precios de venta coherentes con economía M36"
sigue pendiente de M38, así que no se fijan como definitivos.

**Huecos que esta tabla destapa (medidos, ninguno tocado):**

1. **`veta_oro` y `veta_polvo_estrellas` apuntan al mismo item** (`ancient_crystal`). No es un
   descuido de datos: es el único item disponible con forma de mineral raro, porque **no existe
   ningún item de oro** en los 300 `.tres`. La veta de oro entrega cristal ancestral.
2. **`gemstone` y `copper_ore` están en el catálogo de items y ninguna veta los usa.** `gemstone`
   cubre la veta 7 sin crear assets nuevos; `copper_ore` duplica funcionalmente a `mineral_cobre`
   (dos ids para el mismo cobre) — decisión de M15, no de M35.
3. **Falta 1 item para la veta 8** (`gold_ore`). Crearlo es trabajo de M15/M159 (pipeline de items
   + metadata legal), no de M35; y hoy el gate `validate_asset_metadata.py --check` ya está en
   EXIT 1 por los 300 PNG de `items_m159`, así que **no se crea desde aquí**.

**Impacto declarado en código (no ejecutado):** `mining_manager.gd` L92 fija
`const VETAS_M35 := [6 ids]`. Cuando el catálogo pase a 8, esa constante y las aserciones de
tamaño de `test_mineria.gd` / `test_mineria_lote2.gd` tienen que subir a la vez; hacerlo antes de
que exista `gold_ore` dejaría una veta sin drop real (violaría la regla de BUG-132).

**Conclusión de P2:** la tabla de diseño de 8+ minerales queda **definida y medida**; la
implementación de las 2 nuevas depende de 1 item (`gold_ore`) que no es de este módulo.

### 2.6 Rutas de acceso a las zonas — tabla de diseño (P16, 2026-10-20)

Estado **medido en disco** antes de diseñar (ninguna cifra heredada de la checklist):

| Medición | Valor real | Fuente |
|---|---|---|
| Regiones de minería | **3** — `cantera` (3 vetas), `cueva` (1), `templo` (2) | `data/mining/ores.json` |
| `zone_id` declarados en gates | **6** — `zona_bosque_denso`, `zona_cantera`, `zona_raices`, `zona_templo_ceniza`, `zona_cueva_cristal`, `zona_tumba_ancestral` | `data/herramientas/tiers_config.json` |
| Llamadores de producción de `can_access_zone()` | **0** (sólo la definición, un comentario y `test_tiers.gd`) | `grep` sobre `scripts/` |
| Apariciones de `gate_muro_piedra` / `gate_sello_ancestral` / `gate_cristal_bloqueado` en código | **0** | `grep` sobre `scripts/` |
| Ubicaciones del mundo | **10** (`ubic_*`); **ninguna** para cantera ni cueva | `data/ubicaciones/ubicaciones.json` |
| Hueco declarado por M160 | cantera/cueva sin ubicación y `zone_id` sin mapeo a `ubic_*` | `data/m160/catalogo_ubicaciones.json` → `huecos_de_mapeo` |
| Islas y geometría | RIZ `[256,256]` r256 · COR `[1024,256]` r220 · CEN `[256,1024]` r220 · AUR `[1024,1024]` r200 | `catalogo_ubicaciones.json` → `islas` |
| Piezas de construcción | **46**, familias: `camino` 3, `escalera` 2, `puente` 5, `iluminacion` 3, `mueble` 4 | `data/construccion/piezas/*.tres` |
| Piezas de camino disponibles | `camino_arena`, `camino_cesped`, `camino_piedra` (esta última: `stone` 2, `altura` 0.1, `superficie_ok` = terreno) | `camino_piedra.tres` |
| Límite blando por zona | **12** extracciones/día (`DEFAULT_ZONE_QUOTA`) | `mining_manager.gd:81` |
| Efecto de gameplay de `familia = camino` | **0** — el camino es decorativo: ninguna pieza altera velocidad ni acceso | `grep` en `scripts/construccion/` |

**Lectura de esas mediciones:** las zonas de minería existen como **datos** (región + banda) y
como **gates declarados**, pero no existen como **geografía**: no hay ubicación, no hay puerta y
nadie consulta el gate. Por eso P16 no es "dibujar un camino sobre un mapa que ya está": es fijar
la geografía mínima que hoy falta, usando ids que ya existen.

Tabla de rutas propuesta. Las columnas "Piezas" usan **ids reales** de
`data/construccion/piezas/`; las longitudes son **propuesta** (no hay dato previo).

| # | Ruta | Zona / banda | Entrada | Piezas (ids reales) | Gate | Largo | Estación |
|---|---|---|---|---|---|---|---|
| R1 | Sendero de la Cantera | `zona_cantera` / superficie | `ubic_spawn_riz` â†’ borde norte de la cantera | `camino_cesped` (tramo blando), `camino_piedra` (tramo rocoso), `farol_piso` cada 12 bloques | **ninguno** | 60 bloques | E1 en la boca |
| R2 | Rampa de descenso | `zona_cantera` / subterraneo_medio | boca de R1 | `escalera_recta` + `escalera_doble` (tramos de 4), `farol_piso`, `cerca_piedra` como baranda | `gate_muro_piedra` | 24 bloques verticales | E2 a media rampa |
| R3 | Galería de la cueva | `zona_cueva_cristal` / profundo | pared este de la cantera | `camino_piedra`, `puente_1`..`puente_4` sobre huecos, `antorcha_ancestral` | boca **abierta**; `gate_cristal_bloqueado` en el ramal profundo | 90 bloques | E1 a 30 bloques de la boca |
| R4 | Sello del Templo | `zona_templo_ceniza` / ancestral | `ubic_templo_ceniza` (isla CEN) | `camino_piedra`, `monolito_glifos` como hitos de progreso | `gate_sello_ancestral` (`blocks_story: true`) | 40 bloques | E3 (forja de isla CEN) |
| R5 | Acceso ancestral permanente | `zona_tumba_ancestral` / ancestral | tras completar M26 | `camino_piedra`, `puente_2`, `farol_colgante` | `gate_tumba_ancestral` | 50 bloques | E4 (mirador/atajo) |

**Reglas de ruta (propuesta, coherentes con el resto del diseño):**

1. **Una ruta nunca es obligatoria para volver.** Todo tramo con `escalera_*` lleva un descenso
   alternativo (`escalera_recta` en paralelo) para que el jugador no quede encerrado si agota
   herramientas — misma filosofía que el respawn con desplazamiento suave de §6.
2. **El camino no da ventaja mecánica** (medido: 0 efectos hoy). Se propone que `camino_piedra`
   sólo evite el crecimiento de vegetación decorativa; **no** velocidad ni acceso. Cambiar eso
   sería una decisión de M17, no de M35.
3. **Los gates viven en la ruta, no en la zona.** El gate se coloca en el tramo (R2, R3-ramal,
   R4, R5) y se consulta al cruzarlo, no al entrar a la región. Motivo medido: `can_access_zone()`
   tiene 0 llamadores, así que hoy no hay ningún punto de control; ponerlo en el cruce del tramo
   es un único sitio que cablear en vez de un volumen que vigilar.
4. **Las rutas respetan el límite blando de 12/día** (no lo eluden): llegar por R2 a la banda
   media no recarga la cuota de `zona_cantera`.

**Matriz de progresión — el hueco que P16 destapa (medido, no corregido):**

| Tier | Forja (isla) | Material que pide `forjas` | Id real en el catálogo de 300 items | Veta que lo da | Zona / banda | Gate de esa zona | ¿Ciclo cerrado? |
|---|---|---|---|---|---|---|---|
| T1 | RIZ (gratis, carpintero) | — | — | — | — | — | no |
| T2 | CEN (`herrero`) | `hierro` x10 + 500 AO | **`hierro` NO existe** (el real es `iron_ore`) | `veta_hierro` | cantera / subterraneo_medio | `gate_muro_piedra` **exige T2_HIERRO** | **SÍ** |
| T3 | COR (`orfebre`) | `oro` x20 + 2.000 AO | **`oro` NO existe** (no hay item de oro: `gold_ore` tampoco) | `veta_oro` | cantera / subterraneo_medio | `gate_muro_piedra` | **SÍ** (arrastra) |
| T4 | AUR (`cristalero`) | `cristal` x5 + 5.000 AO | **`cristal` NO existe** (el real es `crystal`) | `veta_cristal` | cueva / profundo | `gate_cristal_bloqueado` **exige T4_CRISTAL** | **SÍ** |

Son **dos defectos independientes** y hay que nombrarlos por separado:

1. **Ids de material inexistentes.** `forjar()` valida con `count_item("hierro") < 10`; como ese
   id no existe en los 300 `.tres`, el conteo es 0 y la forja devuelve
   `{"ok": false, "motivo": "faltan materiales: hierro x10"}` **siempre**. La prueba de que
   `hierro` es una **etiqueta** y no un id está en el propio repo: `build_hud.gd:33` traduce
   `"iron_ore": "hierro"` para mostrar el nombre. Y el defecto está **duplicado**: M158 lo repite
   en su propio catálogo (`data/m158/catalogo_herramientas.json` L160 `"hierro": 10`, L169
   `"oro": 20`), así que corregir sólo `tiers_config.json` dejaría la otra copia mintiendo.
   Lo que lo tapa es el
   propio test: `test_tiers.gd` inyecta `_inv.agregar_items({"hierro": 10})` y `{"oro": 20}`
   directamente en el inventario, así que la suite queda **verde (0 fallos, EXIT 0, medido)** con
   ids que ningún sistema de producción puede generar. Es la familia "el test consagra el defecto".
2. **Ciclo de progresión.** El gate de la cantera exige el tier que sólo se consigue con material
   de dentro de la cantera. Hoy no duele porque **el gate no se consulta en ningún lado**
   (0 llamadores); duele el día que se cablee, que es exactamente lo que P16 propone.

**Resoluciones propuestas (NO aplicadas — tocan datos de M158):**

- **P16-D1:** `gate_muro_piedra.required_tier` â†’ `T1_COBRE`. Un muro de piedra se rompe con pico
  de cobre; el ramal profundo (donde vive el oro) pasa a un segundo gate `T2_HIERRO`. Así el
  hierro que paga T2 queda **fuera** de lo que el muro cierra.
- **P16-D2:** la boca de `zona_cueva_cristal` queda **abierta**; `gate_cristal_bloqueado` se mueve
  al ramal de la banda profunda, por el mismo motivo (el cristal que paga T4 está adentro).
- **P16-D3:** `forjas[].materiales` debe usar ids del catálogo (`iron_ore`, `ancient_crystal`,
  `crystal`). Es dato de **M158** y se reporta; no se edita desde M35.

**Conclusión de P16:** las 5 rutas quedan definidas con piezas e ids reales, y queda medido que
la progresión de tiers **no es recorrible** tal como está declarada. La implementación sigue
bloqueada por el hook de post-generación de M08 (ítem 4 de la checklist: `set_block` = 0
apariciones en `scripts/`), pero el diseño ya no depende de esa API.

### 2.7 Estaciones: puestos de descanso y mejoras (P17, 2026-10-20)

Estado **medido en disco** antes de diseñar:

| Medición | Valor real | Fuente |
|---|---|---|
| Forjas de isla | **4** — RIZ `T1_COBRE` gratis (carpintero) · CEN `T2_HIERRO` hierro 10 + 500 AO (herrero) · COR `T3_ORO` oro 20 + 2.000 AO (orfebre) · AUR `T4_CRISTAL` cristal 5 + 5.000 AO (cristalero) | `tiers_config.json` → `forjas` |
| Cursos de profesión | **4** (300 / 1.500 / 5.000 / 10.000 AO) | `tiers_config.json` → `cursos` |
| API de forja | `forjar(isla, tool_type) -> Dictionary` (valida tier previo, materiales y monedas; anti-doble-forja cozy) | `tool_tier_system.gd` |
| Llamadores de producción de `forjar()` | **0** (sólo `test_tiers.gd`) | `grep` sobre `scripts/` |
| Modelo de energía del jugador | `PlayerEnergy`: máx 100, fatiga avisada al **30%**, `recargar_dormir()` = 100%, `recargar_descanso()` = **+30%**, regen 1/min, correr 1/min | `scripts/player/player_energy.gd` |
| Coste de herramienta | **2-8** de energía por uso (M13) — el único drenaje real | `player_energy.gd` (docstring) |
| Sistema de descanso del jugador | **no existe**: `descanso`/`dormir` en `scripts/` son necesidades de **NPC** (M64/M65) y el "dormir" de `interaction_manager.gd` es el estado suspendido del gestor, no dormir del jugador | `grep` sobre `scripts/` |
| `cama` como pieza | existe (`familia = mueble`, `es_mueble`, `grass` 2 + `planks` 4) **sin efecto de gameplay** medido | `data/construccion/piezas/cama.tres` |
| `tool_power` (M35 §4) | **0 apariciones** en `scripts/`: `MiningTool` no está implementado | `grep` sobre `scripts/` |

**Consecuencia de diseño:** "puesto de descanso" no hay que inventarlo de cero — hay **modelo de
energía con las dos recargas exactas** (`dormir` 100%, `descanso` +30%) y hay **piezas** para
construirlo. Lo que falta es el **objeto de mundo** que conecte pieza con modelo, y la regla de
dónde puede existir.

Tabla de estaciones propuesta. Costes con **ids reales** del catálogo; los importes son propuesta.

| id | Nombre | Función | Piezas (ids reales) | Coste propuesto | Requisito |
|---|---|---|---|---|---|
| E0 | Cama (hogar) | dormir → `recargar_dormir()` (100%) | `cama` | `grass` 2 + `planks` 4 (ya existe) | dentro de construcción M17 |
| E1 | Puesto de avanzada | descanso (+30%), guardar, fijar respawn | `cama`, `farol_piso`, `cofre_ancestral` | `planks` 6 + `stone` 4 + `grass` 2 | ruta con acceso (R1/R3) |
| E2 | Forja de campo | **reparar** durabilidad (½ del coste de fabricación, M13 §4); **no** sube tier | `mesa`, `antorcha_ancestral`, `lingote_metal` | `planks` 4 + `stone` 6 + `iron_ore` 2 | T1 forjado |
| E3 | Forja de isla | **subir tier** — es la `forjas` de M158, no una estación nueva | (estructura fija de la isla) | la de `tiers_config.json` | isla correspondiente |
| E4 | Mirador / atajo | desbloquea el atajo permanente de la ruta al limpiarla | `farol_colgante`, `monolito_glifos` | `planks` 4 + `stone` 8 | ruta completa recorrida |

**Reglas de descanso (propuesta):**

1. **Dormir sólo en E0/E1** y siempre avanza el reloj al amanecer siguiente con la API de dormir
   de M30 (`GameTime.avanzar_hasta`, medida y usada en el arnés de límite de memoria de M62).
   Dormir es la única acción que recarga al 100%.
2. **Descansar (sentarse) en E1/E4** da `recargar_descanso()` (+30%). Sin límite diario: la regla
   cozy del modelo es que la energía **nunca** llega a cero por caminar o correr, así que el
   descanso es una comodidad, no un peaje.
3. **Ninguna estación cobra energía ni monedas por usarse.** El coste está en construirla y en el
   material de la forja; cobrar por dormir contradice el tono cozy del módulo.
4. **La fatiga al 30% es informativa, no bloqueante** (así está en el modelo desde el msg 135 del
   director). Un puesto de descanso **no** debe convertirla en un bloqueo.
5. **Respawn:** dormir en un E1 lo fija como punto de reaparición. Si la zona está ocupada al
   regenerar (§6), se aplica el desplazamiento suave ya diseñado, no un teletransporte.

**Puente entre mejoras y `tool_power` (decisión que P17 tiene que cerrar):**

`03-Diseno.md` §4 declara `tool_power` 1-3 en `MiningTool`, y M158 declara 4 tiers con
`dano` 1.0 / 2.0 / 3.5 / 5.0 y `area` 1 / 1 / 2 / 2. Como `tool_power` **no existe en código**
(0 apariciones), la propuesta es **derivar `tool_power` del tier** en vez de duplicar la escala:

| Tier | `tool_power` propuesto | Efecto en `OreVein.hit()` |
|---|---|---|
| T1_COBRE | 1 | 1 golpe descontado por golpe |
| T2_HIERRO | 2 | 2 golpes descontados |
| T3_ORO | 3 | 3 golpes descontados (tope del contrato §4) |
| T4_CRISTAL | 3 + `area` 2 | mismo poder, pero golpea 2 bloques contiguos (el `area` de M158) |

Así el contrato de §4 (1-3) se respeta y el `area` de T3/T4 no queda huérfano.

**Conclusión de P17:** las estaciones quedan definidas sobre piezas y modelos que **ya existen**
(`cama`, `farol_piso`, `cofre_ancestral`, `mesa`, `PlayerEnergy`, `forjas`), sin crear sistemas
nuevos. Queda medido que la cadena de mejora **no es ejecutable hoy** por los ids de material
(P16-D3) y que `tool_power` es una pieza de contrato sin implementación.

## 3. Flujos (texto)

### Flujo F1 — Extracción

1. Jugador equipa el pico (M13) y apunta a un bloque de veta.
2. `MiningTool.use()` valida `can_use()` (cooldown, durabilidad).
3. Raycast con máscara exclusiva de vetas; si no hay veta -> `hit_air()`, sin gasto de durabilidad.
4. Si hay veta: `OreVein.hit(tool_power)` descuenta golpes; swing + partículas + sonido.
5. Si `golpes_actual == 0` y `blocks_remaining > 0`: siguiente bloque, sin drops intermedios.
6. Si `blocks_remaining == 0`: `MiningManager.on_vein_depleted(vein)` calcula drops con PRNG M29 y `double_drop_chance + tool_power`.
7. MiningManager entrega los drops a **M15** (`agregar_recursos`), emite `ore_dropped` y la UI muestra texto flotante.
8. La veta pasa a `AGOTADA`; se registra `regen_remaining = respawn_days` y se persiste.

### Flujo F2 — Regeneración (respawn lento)

1. Cada tick de juego (M30), `MiningManager.process_regen(delta)` avanza `regen_remaining` solo si el juego no está en pausa.
2. Cuando `regen_remaining <= 0`: **validación de ocupación** en el voxel M08 para cada bloque de la veta.
3. Si la zona está libre -> bloques restaurados, `state = INTACTA`, chispa de anuncio visual y `vein_recovered_global`.
4. Si la zona está ocupada (construcción M17, otro bloque, jugador dentro) -> se difiere 1 tick y se reintenta (máx. 3 intentos).
5. Si el jugador está en un bloque de la veta -> desplazamiento suave de 0.5 bloques al espacio libre más cercano.
6. Tras 3 reintentos fallidos la veta espera hasta el siguiente día de juego, evitando ciclos de spin.

### Flujo F3 — Distribución en el mundo (M08)

1. M08 genera un chunk y emite el hook de post-generación.
2. `MiningManager.place_veins_in_chunk(origin, rng)` decide con PRNG M29 si el chunk tiene veta y cuántas (densidad por zona: cantera > superficie > zona ancestral M26).
3. Selección de mineral por profundidad (`depth_min`/`depth_max`) y bioma.
4. Se escriben 1-3 bloques en el voxel (capa mineral), con soporte garantizado (nunca flotan).
5. Se crea el `OreVein` registrado en el manager y se persiste su estado.

### Flujo F4 — Persistencia

1. Al guardar: `MiningManager.serialize()` devuelve Dict con definiciones usadas, vetas (estado, golpes, temporizador, posición) y contadores de zona.
2. Al cargar: `deserialize()` reinstancia las vetas, sincroniza bloques con el voxel y reanuda temporizadores con acumulación (sin reset por guardado).

## 4. Contratos API (GDScript)

### OreDefinition

```gdscript
class_name OreDefinition
extends Resource

enum Rarity { COMUN, RARO, ANCESTRAL }

@export var id: StringName
@export var display_name: String
@export var rarity: Rarity = Rarity.COMUN
@export var depth_min: int = 0
@export var depth_max: int = 64
@export var hardness: int = 2
@export var drop_min: int = 1
@export var drop_max: int = 2
@export_range(0.0, 1.0) var double_drop_chance: float = 0.1
@export var respawn_days: float = 2.0
@export var brightness: Color = Color.SILVER
@export var particle_scene: PackedScene
@export var sound_hit: AudioStream
@export var sound_break: AudioStream
```

### OreVein

```gdscript
class_name OreVein
extends Node3D

signal vein_depleted(vein: OreVein)
signal vein_recovered(vein: OreVein)

enum State { INTACTA, AGOTADA, REGENERANDO }

@export var ore_id: StringName
var blocks: Array[Vector3i] = []
var state: State = State.INTACTA
var blocks_remaining: int = 0
var golpes_actual: int = 0
var regen_remaining: float = 0.0

func setup(p_ore: OreDefinition, p_blocks: Array[Vector3i]) -> void
func hit(tool_power: int) -> bool
func is_depleted() -> bool
func can_respawn() -> bool
func apply_occupancy_shift() -> Vector3i   # desplazamiento si el jugador ocupa
func serialize() -> Dictionary
func deserialize(data: Dictionary) -> void
```

### MiningTool

```gdscript
class_name MiningTool
extends Node3D

signal swing_started()
signal hit_vein(vein: OreVein, drops: Array[Dictionary])
signal hit_air()

@export_range(1, 3) var tool_power: int = 1
@export var cooldown: float = 0.6
@export var range: float = 3.5
@export var durability_max: int = 100
var durability_current: int = 100

func can_use() -> bool
func use() -> Dictionary   # {"acierto": bool, "drops": Array[Dictionary]}
func _raycast_vein() -> OreVein
func consume_durability(amount: int) -> void
```

### MiningManager (Autoload `mineria`)

```gdscript
extends Node

signal ore_dropped(ore: OreDefinition, amount: int, world_pos: Vector3)
signal vein_recovered_global(vein_id: int)
signal zone_exhausted(zona: StringName)

const REGEN_TICK := 0.5

func register_definition(def: OreDefinition) -> void
func get_definition(id: StringName) -> OreDefinition
func place_veins_in_chunk(chunk_origin: Vector3i, rng: RandomNumberGenerator) -> void
func register_vein(vein: OreVein) -> void
func process_regen(delta: float) -> void
func get_zone_density(zona: StringName) -> float
func consume_zone_quota(zona: StringName) -> void
func is_zone_exhausted(zona: StringName) -> bool
func serialize() -> Dictionary
func deserialize(data: Dictionary) -> void
```

## 5. Integración con otros módulos

### M08 (mundo voxel)
- Hook de post-generación de chunk -> `place_veins_in_chunk`.
- Minería edita bloques vía la API de edición de M08 (`set_block`) con capa de mineral; remeshing diferido solo del chunk afectado.
- Validación de ocupación y soporte (bloque debajo) reutilizan la API de lectura de M08.

### M13 (herramientas)
- `MiningTool` es el componente de golpe del pico equipado; `tool_power` se deriva de la mejora del pico (M13).
- Durabilidad compartida: la UI de M13 muestra el mismo valor; el descuento ocurre solo con acierto sobre veta.

### M15 (recursos)
- Los drops son recursos existentes del catálogo M15 (cobre, hierro, oro_ancestral, cristal_estacional, polvo_de_estrellas).
- MiningManager entrega vía `M15.agregar_recursos(...)`; Minería no conoce inventario interno.
- `OreDefinition.id` debe coincidir con el `id` de M15 para no duplicar definiciones.

### M26 (Templo Subterráneo)
- La capa ancestral solo existe en las cuevas de M26; los nodos especiales (veta gigante de cristal) se siembran por eventos de M26.
- El Templo no bloquea puzzles con vetas: ninguna veta interfiere con mecanismos (checklist específico).
- Al completar el Templo, la densa zona ancestral queda accesible permanentemente.

### M29 / M30 / M36 / M73
- PRNG M29 para eventos de drops y distribución; calendario de días para `respawn_days`.
- Reloj M30 congela `process_regen` en pausa (leyendo `M30.is_paused()`).
- Los lingotes/fundición y precios se definen en M16/M36; Minería solo entrega materia prima.
- Festivales M73 pueden duplicar temporalmente la probabilidad de doble drop (evento festivo).

## 6. Estados de la veta (diagrama de texto)

```
        [generación de chunk]
                 |
                 v
           +----------+  blocks_remaining==0   +----------+
           | INTACTA  | ----------------------> | AGOTADA  |
           +----------+                         +----------+
                 ^                                  |
                 |  veín recuperada                 | regen_remaining = respawn_days
                 |  (validación de ocupación)       v
                 +-------------------------- +-------------------+
                                              | REGENERANDO      |
                                              | tick = process_  |
                                              +-------------------+
```

## 7. Decisiones de diseño clave

1. **Geometría en M08, estado en OreVein**: la veta es un bloque especial del voxel; OreVein solo administra estado. Evita duplicación de meshes y colisiones.
2. **Respawn con validación de ocupación** (D1): nunca se regenera sobre construcciones ni sobre el jugador.
3. **Durabilidad sin castigo**: errar un golpe no gasta durabilidad; solo cuenta el acierto.
4. **Límite suave por zona** (D5): no prohíbe, desalienta y empuja a explorar.
5. **Cero acoplamiento con UI**: los managers emiten señales; la capa de presentación las consume.
## Specs Minería (Beam 504)

### Remeshing diferido solo del chunk afectado
- Spec: remeshing diferido solo del chunk afectado (no todo el mundo). Coherente con M35 (minería) y M08 (terreno).

### Remeshing localizado y diferido por chunk
- Spec: remeshing localizado y diferido por chunk. Coherente con M35 (minería) y M08 (terreno).

### Frame budget global respetado en remeshing masivo
- Spec: frame budget global respetado en remeshing masivo. Coherente con M35 (minería) y M61 (rendimiento).

## Specs Mineria (Beam 693)

### P2: diseñar minerales — tabla de 8+ minerales
- Spec: P2: disenar minerales — tabla de 8+ minerales. Coherente with M35 (mineria) and M14 (recursos).

### P16: diseñar rutas — caminos de acceso a las zonas
- Spec: P16: disenar rutas — caminos de acceso a las zonas. Coherente with M35 (mineria) and M27 (islas).

### P17: diseñar estaciones — puestos de descanso y mejoras
- Spec: P17: disenar estaciones — puestos de descanso y mejoras. Coherente with M35 (mineria) and M16 (construccion).

### Hook de post-generacion de chunk conectado
- Spec: hook de post-generacion de chunk conectado. Coherente with M35 (mineria) and M08 (terreno).

### Escritura de bloques de mineral en el voxel
- Spec: escritura de bloques de mineral en el voxel. Coherente with M35 (mineria) and M08 (terreno).


## Specs Mineria (Beam 694)

### Colision por bloque de veta unificada con el voxel
- Spec: colision por bloque de veta unificada con el voxel. Coherente with M35 (mineria) and M08 (terreno).

### Validacion de ocupacion reutilizando API de lectura M08
- Spec: validacion de ocupacion reutilizando API de lectura M08. Coherente with M35 (mineria) and M08 (terreno).

### Vetas en paredes y techos de cuevas
- Spec: vetas en paredes y techos de cuevas. Coherente with M35 (mineria) and M25 (templo).

### Iluminacion de brillo en vetas profundas
- Spec: iluminacion de brillo en vetas profundas. Coherente with M35 (mineria) and M48 (iluminacion).

### Nodos especiales de cristal gigante sembrados por eventos de M26
- Spec: nodos especiales de cristal gigante sembrados por eventos de M26. Coherente with M35 (mineria) and M26 (templos).


## Specs Mineria (Beam 695)

### Zona ancestral accesible permanentemente tras completar el Templo
- Spec: zona ancestral accesible permanentemente tras completar el Templo. Coherente with M35 (mineria) and M26 (templos).

### Iluminacion del Templo resalta vetas raras
- Spec: iluminacion del Templo resalta vetas raras. Coherente with M35 (mineria) and M48 (iluminacion).

### Acceso a cuevas desde el interior del Templo
- Spec: acceso a cuevas desde el interior del Templo. Coherente with M35 (mineria) and M25 (templo).

### Evento de derrumbe decorativo en la sala del mineral ancestral
- Spec: evento de derrumbe decorativo en la sala del mineral ancestral. Coherente with M35 (mineria) and M74 (eventos).

### Respawn con zona ocupada: reintento diferido
- Spec: respawn con zona ocupada: reintento diferido. Coherente with M35 (mineria) and M08 (terreno).


## Specs Mineria (Beam 696)

### Respawn con jugador dentro: desplazamiento suave
- Spec: respawn con jugador dentro: desplazamiento suave. Coherente with M35 (mineria) and M10 (personaje).

### Respawn con construccion M17 encima: espera al proximo dia
- Spec: respawn con construccion M17 encima: espera al proximo dia. Coherente with M35 (mineria) and M17 (construccion).

### Veta en borde de chunk: sin duplicacion ni perdida
- Spec: veta en borde de chunk: sin duplicacion ni perdida. Coherente with M35 (mineria) and M08 (terreno).

### Pool de particulas de mineria
- Spec: pool de particulas de mineria. Coherente with M35 (mineria) and M52 (particulas).

### Particulas de chispas al golpear
- Spec: particulas de chispas al golpear. Coherente with M35 (mineria) and M52 (particulas).


## Specs Mineria (Beam 697)

### Specs items degradados T197 (2026-10-26, Reflection-Beam-1.0)
- **L14 (cuevas con vetas en paredes y techos RF4):** M35 iter 1 cubre datos; escenas M26 pendientes (fuera de iter 1).
- **L56 (color/emisivo brillo por mineral):** placeholder; assets M45 pendientes.
- **L57 (partículas de extracción por mineral):** placeholder; M52.
- **L73 (desplazamiento suave si jugador ocupa bloque):** M17 + M08; pendiente integración.
- **L88 (actualización UI durabilidad M13):** pendiente M53 UI.
- **L96 (distribución vetas por chunk al generar):** M15 ResourceSpawner lo cubre; M35 hereda.
- **L97 (selección mineral por profundidad y bioma con PRNG M29):** M15 lo cubre.
- **L124 (fundición de lingotes con minerales M16):** fuera de iter 1 — dueño M16.
- **L125 (precios de venta coherentes con economía M36):** valor_venta en JSON; M38 economía pendiente.
- **L180 (test veta a medias sobrevive guardado/carga):** M15 cubre por nodo; M35 cubre zone_quota — pendiente prueba end-to-end con GameTime real.
- **L184 (profiler en cueva con 50 vetas activas):** pendiente M61 benchmarks; no bloquea iter 1.
- **L185 (recorrido cozy completo cantera/cueva norte/Templo):** pendiente M138/M26.
