# Log 1165: P-49 se integro el spawner de fauna M36 en main_island (grupos [M65] visibles en runtime)

**Fecha:** 2026-09-25
**Hora:** 06:07
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen

P-49: cerré la deuda que yo misma identificé en P-38 ("los NPCs de main_island son
legacy... el spawner de M36 no está integrado"). Se creó `fauna_spawner.gd` (nodo de
escena) + el nodo `FaunaSpawner` en `main_island.tscn`: el spawner de M36 iter 2 que
`fauna_manager.gd` dejaba pendiente ("instanciar los nodos"). Resultado: las manadas/
bancos de M65 (PackLogic/SchoolLogic) ahora se ven en el runtime de la escena principal.

## Cambios Realizados

1. **Nuevo `game/isla-ancestral/scripts/fauna/fauna_spawner.gd`** (Node, P-49):
   - Zonas de bioma nominales derivadas de `MundoRaiz` (pradera = `SPAWN_CONTENIDO`,
     playa/humedal = banda costera hacia `RADIO_ORILLA`): M09 aún no expone
     `bioma_de_posicion`, así no hay magic numbers.
   - Especie por `fauna.especie_aleatoria_para(hora, bioma)` (hora de `TimeCalendar`) +
     tamaño de grupo por `fauna.candidatos_de_especie(sp, manada_max)` (gregarias:
     rango manada_min..max; solitarias: 1).
   - Criatura = `Node3D` + script `fauna_behavior` + mesh placeholder de esfera
     (M45 entregará los modelos reales; escala/color de `FaunaSpecies`).
   - Snap de terreno vía `TerrainLocator.get_height` (tierra `h>=3` BUG-022; acuáticas
     franja 2.5–4.5; aéreas sobrevuelo).
   - Presupuesto `MAX_INDIVIDUOS=24` ≤ `_presupuesto_max` de `animal_ai` (40).
   - **Lookup de autoloads lazy** vía `Engine.get_main_loop().root.get_node_or_null(...)`
     con reintento hasta frame 120: el `fauna` NO estaba listo en el `_ready` del nodo
     (causa del primer intento fallido).
2. **`game/isla-ancestral/scenes/main_island.tscn`**: +ext_resource
   `fauna_spawner.gd` + nodo `FaunaSpawner` (hermano de `VegetationSpawner`).
3. **Docs**: M36 `04-Codigo.md` §P-49 (archivos + funciones + evidencia + pendiente M09);
   M65 `05-Checklist.md` Notas P-49 (limitación honesta de P-38 levantada).

## Fixes detectados durante la integración (aprendizajes)

- `get_node_or_null("/root/fauna")` en `_ready` devuelve null (timing del autoload,
  aunque el nodo existe en root al frame 2) → lookup lazy + reintento (patrón del repo:
  `fauna_manager._get_animal_ai` / `fauna_behavior._get_animal_ai`).
- `Vector3.xz` es property read-only y NO pasa por el dispatch dinámico de Variant
  (`mundo.SPAWN_CONTENIDO.xz` sobre `Node` no tipado → SCRIPT ERROR) → `Vector2(v.x, v.z)`.
- `var x := helper()` sobre helper que devuelve Variant → "Cannot infer the type" →
  `var x = helper()`.
- `zona.centro` era `Vector2` y usé `.z` (no existe en 2D) → `.y`.

## Evidencia (binario real Godot 4.7.2, headless)

- `main_island.tscn --quit-after 300` **×2 = 0 SCRIPT ERROR, EXIT 0**:
  - `[M65] Manada (PackLogic) creada para conejo_pradera` (run 1: 2, run 2: 4 individuos).
  - `[M65] Banco (SchoolLogic) creado para gaviota_playera` (4) y `para cangrejo_humedal`
    (run 1: 3, run 2: 2).
  - `[M36-SPAWNER] poblacion inicial: 9/10 individuos en 3 zonas` (zona pradera @ spawn
    del jugador (3860,3860) → visible al arrancar).
- **Probe del árbol de escena**: 9 nodos `Fauna_*` con el script `fauna_behavior` bajo
  `FaunaSpawner` (cumple "al menos una criatura con fauna_behavior en el árbol").
- **Regresión**: `tests/test_m65.gd` 0 fallos (35 OK), `scripts/animales_ia/test_m65.gd`
  0 fallos, `scripts/fauna/test_fauna.gd` 0 fallos — M36/M65 no degradados.

## Pool / commit

- La instrucción P-49 indicó "primer libre 1161", pero 1161–1164 fueron consumidos en
  paralelo (P-43b/P-46/P-48/P-50). Por el protocolo anti-colisión (§6.1.d) **se reservó
  1165** (`NUMEROS_DISPONIBLES.txt`, working tree — archivo compartido, sin commitear).
- Commits: 2 coherentes ("Merge (worktree de agnes-3-flash)"): (1) código + escena +
  doc M36; (2) doc M65 + este log + backlog. Verificación `git diff --stat HEAD~1..HEAD`
  por commit (trampa 87; el diff contra working tree marca ~190 files ajenos, el chequeo
  correcto es entre commits). Push NEGATIVO.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/fauna/fauna_spawner.gd` (nuevo)
- `game/isla-ancestral/scenes/main_island.tscn` (nodo + ext_resource)
- `DOCUMENTACION/36-Fauna/plan-actual/04-Codigo.md` (§P-49 + firma)
- `DOCUMENTACION/65-Animales-IA/plan-actual/05-Checklist.md` (Notas P-49)
- `Logs/1165-P-49-Spawner-Fauna-M36-main-island_2026-09-25_06-07-00.md` (este archivo)
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/BACKLOG-MASTER.md` (fila 24)
