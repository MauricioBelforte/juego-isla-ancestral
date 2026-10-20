# Log 2034 - M35 - COLA V3 bloque 2 descubierto y item 1 (P2) medido

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Modulo:** M35-Mineria
**Fecha:** 2026-10-20 01:54 (GMT-3)
**Responde a:** mensaje 330 del director (GLM-5.3 Flash-Director, 05:00): "Segui COLA V3 en orden (23+)"
**Log anterior propio:** 2033 (items 17-22 de M62)

---

## 1. Punto de partida

Tracker `.ultima-revision-deepseek.txt` = 327 al empezar la vuelta anterior; se cerro en 328 con el
acuse del 328. En esta vuelta aparecio un entrante nuevo en la carpeta de canal:

- `330-2026-10-20_05-00-00-glm-5.3-flash-director-a-deepseek-acuse-329.md` (1.020 B)

Contenido operativo del 330: los items 17-22 quedan TOMADOS, el item 3 es la misma condicion del 2
(sin flip duplicado), y la instruccion explicita es **"Segui COLA V3 en orden (23+)"**.

Medido al abrir la vuelta: NN maximo real de la carpeta de canal = **330**. Tracker 328 -> 330.

## 2. Hallazgo estructural: la COLA V3 tiene DOS bloques, no uno

La vuelta anterior cerro el mensaje 329 pidiendo reposicion de cola porque "la COLA V3 no tiene
items ejecutables headless". **Esa conclusion era falsa y este log la corrige.**

Causa del error, medida: al recorrer el backlog corte la seccion en el siguiente encabezado
`## `, y el archivo tiene **dos** bloques con el mismo titulo, creados con 11 segundos de
diferencia:

| Bloque | Linea | Titulo | Items |
|---|---|---|---|
| 1 | 1951 | `## REPOBLACION V3 (2026-10-19T00:01:52)` | 29 (M62) |
| 2 | 1984 | `## REPOBLACION V3 (2026-10-19T00:02:03)` | 31 (M35 + M60) |

El bloque 1 es el que se trabajo en los ciclos 2016-2033. El bloque 2 **nunca se toco**.

## 3. El bloque 2 es mio y sus items son reales (medido, no heredado)

Cruze contra las checklists de origen, contando marcas por prefijo de linea:

| Checklist | Items con marca | `[x]` | `[ ]` | `[?]` |
|---|---|---|---|---|
| `DOCUMENTACION/35-Mineria/plan-actual/05-Checklist.md` | 142 | 101 | **28** | 13 |
| `DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/05-Checklist.md` | 196 | 189 | **3** | 4 |

**28 + 3 = 31 = exactamente los items del bloque 2.** El bloque no esta inflado ni desactualizado:
es la lista honesta de lo que queda abierto en M35 y M60.

Pertenencia de M35: `Mensajes entre modelos/ESTADO-PARALELO.md` L194 asigna
`DeepSeek-V4.1-Flash | M35 (49 [ ])`; hoy M35 esta en 28 `[ ]`, asi que 21 se cerraron desde
entonces. M35 no figura en la lista NO TOCAR de mi backlog (M104, M17, M90, M21, M155, M40, M70,
M140, M63, M112, M92, M91, M88, M160).

## 4. Sondas de falso negativo sobre el codigo de M35

Antes de aceptar que los 28 items de M35 estan abiertos, probe si el codigo ya los cubria
(`scripts/mineria/mining_manager.gd`, 30.850 B; `mining_vein_catalog.gd`, 4.999 B):

| Patron | Ocurrencias | Lectura |
|---|---|---|
| `set_voxel` / `VoxelTerrain` / `voxel_tool` | **0** | no hay escritura en el voxel |
| `remesh` / `remeshing` | **0** | no hay remeshing diferido |
| `collision_mask` / `raycast` / `RayCast` | **0** | no hay raycast de mineria |
| `chunk_size` / `borde` / `border` | **0** | no hay logica de borde de chunk |
| `chunk` | 12 | solo contabilidad (`_chunks_editados`) |
| `zona_quota` / `zone_quota` | 22 | cuota diaria: eso SI esta implementado |

Conclusion: **0 falsos negativos** en las 4 sondas que importan. Los items de voxel/remeshing/
raycast estan genuinamente sin implementar.

## 5. Bloqueante medido: la API de edicion de M08 no existe

`DOCUMENTACION/35-Mineria/plan-actual/03-Diseno.md` L226 declara el contrato:
"Mineria edita bloques via la API de edicion de M08 (`set_block`) con capa de mineral; remeshing
diferido solo del chunk afectado".

Medido en todo el arbol `game/isla-ancestral/scripts/`:

```
grep -rln "func set_block\|set_block(" scripts/ --include=*.gd   ->   0 archivos
```

**`set_block` no existe en ningun sitio del repo.** Por lo tanto estos items de M35 no estan
bloqueados por M35 sino por M08:

- L106 Hook de post-generacion de chunk conectado
- L107 Escritura de bloques de mineral en el voxel
- L108 Remeshing diferido solo del chunk afectado
- L109 Colision por bloque de veta unificada con el voxel
- L114 Compatible con el ahorro de memoria de chunks
- L147 Veta en borde de chunk: sin duplicacion ni perdida
- L154 Remeshing localizado y diferido por chunk
- L161 Frame budget global respetado en remeshing masivo

8 de los 28 items quedan con bloqueante externo medido (M08), no con un "no medible" generico.

## 6. Item 1 del bloque 2 ejecutado: P2 - tabla de 8+ minerales

Item: `1. - [ ] [35] P2: disenar minerales - tabla de 8+ minerales [S]`

### 6.1 Medicion previa (antes de escribir ninguna cifra)

| Medicion | Valor real | Fuente |
|---|---|---|
| Vetas en el catalogo | **6** | `data/mining/ores.json` (2.470 B, LF, sin BOM) |
| Objetivo del item | **8+** | `05-Checklist.md` L24 |
| Items `.tres` en el catalogo | **300** | `data/items/` |
| Items con forma de mineral | **7** | `ancient_crystal`, `copper_ore`, `crystal`, `fragmento_ancestral`, `gemstone`, `iron_ore`, `mineral_cobre` |
| Items de mineral sin uso por ninguna veta | **2** | `gemstone`, `copper_ore` |
| Items de oro | **0** | no existe `gold_ore` ni `mineral_oro` |

Correccion de una medicion propia intermedia: un primer volcado imprimio `prof=None bioma=None`
porque buscaba las claves `profundidad_min`/`bioma`. El JSON real usa `profundidad_banda`
(`superficie`, `subterraneo_medio`, `profundo`, `ancestral`) y `region` (`cantera`, `cueva`,
`templo`). **Las bandas y regiones ya existian**; el hueco real es solo el numero de minerales.

### 6.2 Entrega

Nueva seccion `### 2.5 Catalogo de minerales - tabla de diseno (P2, 2026-10-20)` en
`DOCUMENTACION/35-Mineria/plan-actual/03-Diseno.md`, insertada antes de `## 3. Flujos (texto)`
(ancla unica verificada: 1 ocurrencia). No se renumero ninguna seccion existente, para no romper
citas de seccion de otros documentos.

Contenido de la tabla: 8 filas. Las 6 primeras son las que ya estan en `ores.json` con los valores
leidos del archivo (id, rareza, banda, region, golpes, drop, probabilidad, venta, respawn, item_id).
Las 2 nuevas son:

| # | id | Nombre | Banda | Region | `item_id` | Estado del item |
|---|---|---|---|---|---|---|
| 7 | `veta_gema` | Veta de Gema | profundo | cueva | `gemstone` | el item ya existe y ninguna veta lo usa |
| 8 | `veta_oro_puro` | Oro Puro | subterraneo_profundo | cantera | `gold_ore` | **el item no existe** |

Progresion de valor propuesta: 8 < 15 < 30 < 45 < 60 < 80 < 95 < 120.

### 6.3 Huecos que la tabla destapa (medidos, ninguno tocado)

1. `veta_oro` y `veta_polvo_estrellas` apuntan **al mismo item** (`ancient_crystal`). No es un
   descuido: no existe ningun item de oro en los 300 `.tres`, asi que la veta de oro entrega
   cristal ancestral. Es la deuda real que BUG-132 dejo visible.
2. `gemstone` y `copper_ore` estan en el catalogo de items y **ninguna veta los usa**.
   `copper_ore` duplica funcionalmente a `mineral_cobre` (dos ids para el mismo cobre): decision
   de M15, no de M35.
3. Falta **1 item** (`gold_ore`) para la veta 8. Crearlo es trabajo de M15/M159 (pipeline de items
   + metadata legal), y el gate `validate_asset_metadata.py --check` ya esta en EXIT 1 por los 300
   PNG de `items_m159`. **No se crea desde aqui.**

### 6.4 Verificacion del archivo editado

| Metrica | Antes | Despues |
|---|---|---|
| Bytes | 12.631 | 16.595 |
| Lineas | 272 | 324 |
| CRLF | 0 | 0 |
| LF | 272 | 324 |
| CR suelto | 0 | 0 |
| BOM | no | no |
| Secciones `### 2.5` | 0 | 1 |

EOL por archivo: el doc era LF puro y sigue LF puro. No se normalizo nada.

## 7. Lo que NO se toco

- `05-Checklist.md` de M35 (ni marcas ni notas): el flip lo aplica el director.
- `ores.json`: agregar vetas sin item real violaria la regla de BUG-132.
- `mining_manager.gd` (`VETAS_M35` = 6 ids) y las aserciones de tamano de `test_mineria.gd` /
  `test_mineria_lote2.gd`: subirlos antes de que exista `gold_ore` dejaria una veta sin drop.
- `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot`, `05-Checklist` de M62.
- Archivos de M60 (3 items del bloque 2): no se abrieron en esta vuelta.
- Pool de numeros de otros canales; backlog de otros modelos.

## 8. Artefactos y numeracion

| Artefacto | Numero | Formato verificado |
|---|---|---|
| Este log | **2034** | ASCII puro, CRLF, sin BOM |
| Mensaje al director | **331** | UTF-8 sin BOM, LF |
| Seccion 2.5 en `03-Diseno.md` | - | LF preservado, sin BOM |

Pools medidos justo antes de reservar: Logs cabeza **2034** (ultimo log en disco 2033 -> coincide).
Canal: ultimo NN **330**, cabeza del pool **331** -> `ultimo+1` = 331 = cabeza. Sin discrepancia.

## 9. Proxima vuelta

1. Seguir el bloque 2 **en orden**: items 2 y 3 (P16 rutas, P17 estaciones) son diseno puro y no
   dependen de M08.
2. Los 8 items de voxel/remeshing quedan declarados como bloqueados por M08 con la sonda de
   `set_block` como evidencia reproducible.
3. Pedido al director: decidir si `gold_ore` entra por M15/M159 (y con que metadata legal), porque
   sin ese item la tabla de 8+ minerales no se puede implementar completa.

---

**Firma:** DeepSeek-V4.1-Flash - WorkBuddy - 2026-10-20 01:54 (GMT-3)
**0 commits / 0 push / 0 flips / 0 auto-sellos 21.8.**
