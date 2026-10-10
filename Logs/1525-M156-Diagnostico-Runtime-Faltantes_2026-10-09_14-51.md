# Log 1525 - M156 - Diagnostico de implementacion runtime (faltantes para que funcione)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy / CodeBuddy
**Fecha:** 2026-10-09 14:51 (GMT-3)
**Modulo:** M156 (Terrenos y Movimiento Diferenciado)
**Tipo:** DIAGNOSTICO DE IMPLEMENTACION (READ-ONLY) - frente 2 opcional del mensaje 114 del director
**Responde a:** canal 114 (atria -> deepseek), frente 2: "que faltaria para que M156 funcione en runtime"
**No es:** auditoria de checklist (eso fue el Lote 11 = M104, canal 115). No se toco M156.

---

## 0. Alcance y restriccion

Pedido del director (msg 114, textual): "M156 sigue teniendo deuda REAL de implementacion (no
documental): TerrainDetector sin montar en el jugador, integracion M11 ausente, huellas/particulas/
audio/indicador UI inexistentes. Un analisis de 'que faltaria para que M156 funcione en runtime'
(no auditoria, diagnostico de implementacion) me serviria para asignar el implementador correcto.
README: no edites M156, solo diagnostico."

Restriccion cumplida: 0 ediciones en `DOCUMENTACION/156-*/`, `game/isla-ancestral/scripts/terrenos/`,
`game/isla-ancestral/scripts/terrain/`, `resources/terrain/`, `data/terrenos/`, `scenes/terrain/`,
`scenes/player/Player.tscn`. Solo lectura + grep/od. Sin commit/push.

---

## 1. Hallazgo estructural previo: hay DOS paquetes de terreno, no uno

Antes de medir "que falta" hay que saber QUE existe. Hay dos implementaciones paralelas y el
checklist apunta a la equivocada.

| Ruta | Que es | Autor / fecha | Consumidores en produccion |
|---|---|---|---|
| `scripts/terrenos/` | **M156 REAL** (TerrainDetector, TerrainModifiers, TerrainProvider, TerrainDataM156) | glm-5.3-flash 2026-09-02 | **0** (solo su test) |
| `data/terrenos/terrenos.json` | catalogo REAL (7 terrenos) | glm-5.3-flash 2026-09-02 | TerrainProvider (autoload) |
| `scripts/terrain/` | **LEGACY** (TerrainDetectorLegacy, TerrainModifiersLegacy, TerrainData, TerrainDataProvider) | deepseek-v4-flash-vision-exp 2026-09-01/02 | **0** (solo un test gdUnit4) |
| `resources/terrain/*.tres` | 7 recursos LEGACY (apuntan a `res://scripts/terrain/terrain_data.gd`) | deepseek-v4-flash-vision-exp | 0 (solo TerrainDataProvider legacy) |
| `scenes/terrain/` | **VACIO** (0 archivos) | - | 0 |

Evidencia:
- `project.godot:92` -> `TerrainProvider="*res://scripts/terrenos/terrain_provider.gd"` (el REAL).
  `project.godot:44` -> `TerrainLocator` (M167/M168, otro servicio, Hy3).
- El header del `05-Checklist.md` (L16) declara los archivos del modulo como
  `scripts/terrain/`, `resources/terrain/`, `scenes/terrain/` -> son las rutas **LEGACY**.
  La implementacion REAL vive en `scripts/terrenos/` (espanol) y NO esta citada en el header.
- `04-Codigo.md` (L13-19) lista `scripts/terrain/*` y `scripts/terrain/terrain_footstep_audio.gd`
  como "Archivos Nuevos" -> tambien rutas legacy / inexistentes.

Consecuencia para el implementador: cualquier tarea debe partir de `scripts/terrenos/`, NO de
`scripts/terrain/`. `scripts/terrain/` es basura heredada (nadie la consume) y `scenes/terrain/`
esta vacio.

---

## 2. Estado runtime por componente (medido)

| Componente | Existe | Clase/carga | Montado en escena | Consumido en runtime |
|---|---|---|---|---|
| TerrainDetector | SI (`scripts/terrenos/terrain_detector.gd`) | `class_name TerrainDetector extends RayCast3D` | **NO** | **NO** |
| TerrainProvider | SI (autoload) | carga 7 terrenos del JSON | autoload OK | **NO** |
| TerrainModifiers | SI (`RefCounted`, estatico) | formula correcta | n/a | **NO** |
| TerrainDataM156 | SI (`Resource`) | placeholders visual/audio | n/a | NO |
| Feedback visual (huellas/particulas) | **NO** | - | - | - |
| Feedback audio | **NO** | - | - | - |
| Indicador UI | **NO** | - | - | - |

Evidencia de "no montado / no consumido":
- `grep -rn "TerrainDetector"` en `scripts/` + `scenes/`: **solo** `scripts/terrenos/test_terrenos.gd`
  (preload + `is RayCast3D`). 0 apariciones en `scenes/` ni en `player.gd`.
- `grep -rn "TerrainModifiers"`: **solo** `test_terrenos.gd`.
- `grep -rn "TerrainProvider"`: **solo** `test_terrenos.gd` (el autoload NO se consulta en produccion).
- `scenes/player/Player.tscn`: 3 nodos -> `Player` (CharacterBody3D), `ModeloVoxel`, `BodyCollision`.
  **No hay TerrainDetector** ni RayCast3D hijo.
- `scripts/player/player.gd`: 0 referencias a TerrainDetector/Modifiers/Provider. Lo unico "terrain"
  es `_terrain: VoxelTerrain` (M08, para VoxelBoxMover) y la senal `EquipmentManager.terrain_bonus_updated`.

---

## 3. Brechas concretas (lo que falta para que funcione en runtime)

### G1. El detector nunca se instancia (bloqueante #1)
`TerrainDetector` es un `RayCast3D` con `_physics_process` que hace el raycast y emite
`terrain_changed`. Pero **no existe en ninguna escena**: ni en `Player.tscn`, ni creado por codigo
en `player.gd`. Sin detector, `current_terrain_id` no se calcula nunca -> el resto del sistema no
tiene entrada. Es la brecha raiz.

### G2. La busqueda del VoxelTerrain tiene un camino muerto
`terrain_detector.gd:56` usa `get_tree().get_first_node_in_group("voxel_terrain")`. Medido:
`grep -rn "voxel_terrain"` -> **ningun nodo se registra en ese grupo** (solo aparece el propio
detector y un nombre de funcion en `debug_menu.gd`). El grupo esta VACIO -> siempre cae al fallback
`current_scene.get_node_or_null("VoxelTerrain")`, que SI funciona en `main_island.tscn` (nodo
`VoxelTerrain` en la raiz). No es fatal, pero el camino primario esta muerto y conviene registrarlo.

### G3. El mapeo bloque->terreno cubre solo 4 de 7 terrenos
`terrain_detector.gd:71-82` `_block_a_terrain()` devuelve **solo** {0 (cesped), 3 (arena),
5 (nieve), 6 (rocas)}. **Nunca** devuelve 1 (barro), 2 (pavimento) ni 4 (agua).
Consecuencia: aun montando el detector, "movimiento lento en barro" (el caso estrella del diseno
sec.4.2) es **inalcanzable** por la via voxel. Requiere tabla de bloques M08 real (tuning).

### G4. collision_mask sin configurar
`terrain_detector.gd` deja `collision_mask` en el default. El diseno sec.4.2 (Layers 2-8 = Terrain_*)
espera que el raycast golpee la capa de terreno. Falta cablear la mascara.

### G5. Integracion M11 ausente (bloqueante #2)
El diseno sec.2.1 pide: M11 conecta `terrain_changed`, guarda `_current_effective_speed` y la usa en
`move_and_slide()`. Medido: `grep _on_terrain_changed|_update_effective_speed|get_current_speed` en
`scripts/` = **0 hits**. `player.gd` mueve con `move_speed` (25.0 en dev, 5.0 en la escena) sin
consultar terreno. El contrato esta expuesto (clase lista) pero **nadie lo consume**.

### G6. El puente M156 -> M155 esta ROTO por idioma de claves (hallazgo nuevo, medido)
Este no estaba listado en el mensaje del director y es el defecto mas silencioso:

- M156 `terrain_modifiers.gd:28-31` `NOMBRES_TERRENO` mapea id -> **nombre en ESPANOL**:
  `{0:"caminado", 1:"barro", 2:"cesped", 3:"arena", 4:"agua", 5:"nieve", 6:"rocas"}`.
- M156 `get_equipment_bonus()` (L33-41) llama `equipment_system.get_terrain_bonus(nombre)` con ese
  nombre espanol.
- M155 `EquipmentSlot` (L8) declara el enum canonico `TerrainType { GRASS, MUD, PAVEMENT, SAND,
  SHALLOW_WATER, SNOW, ROCK }` -> **INGLES**.
- M155 `equipment_manager.gd:176-206` `_load_terrain_bonus_table()` usa claves **INGLES**
  (`grass`, `mud`, `pavement`, `sand`, `shallow_water`, `snow`, `rock`).
- M155 `equipment_slot.gd:39-42` `get_terrain_bonus()` hace lookup DIRECTO por string:
  `if terrain_type in terrain_bonuses: return float(...)`.

Resultado medido por lectura cruzada: `get_terrain_bonus("barro")` **nunca** matchea
`terrain_bonuses` (que tiene `"mud"`) -> `TerrainModifiers.get_equipment_bonus()` devuelve **0.0
SIEMPRE**, con o sin botas. El "caso barro+botas = 4.05" del diseno sec.4.2 y el item R
"Verificar botas de barro mejoran barro [x]" son **falsos en runtime**.

Nota: el test `test_terrenos.gd:152-153` asevera `bonus == 0.0` con M155 real sin equipacion. Ese
check **consagra el bug**: 0.0 es tambien lo que produce el puente roto, asi que el test no
distingue "no hay botas" de "el nombre no matchea".

### G7. El mapa NOMBRES_TERRENO esta desincronizado con el catalogo
Contrastando `NOMBRES_TERRENO` con `data/terrenos/terrenos.json`:
- id 0: JSON `"Cesped"` vs mapa `"caminado"` -> **desalineado**.
- id 2: JSON `"Pavimento"` vs mapa `"cesped"` -> **desalineado**.
- ids 1,3,4,5,6 coinciden en espanol. Pero ademas NINGUNO coincide con las claves inglesas de M155
  (ver G6). El mapa esta mal en dos sentidos a la vez.

### G8. Feedback visual inexistente
`TerrainDataM156.visual_config` (L18-23) tiene `footprint_scene: null`, `particle_scene: null` como
placeholders. `TerrainProvider.get_visual_config()` (L64-66) devuelve `{}` con comentario "las
escenas visuales llegan con M45/M52". En disco: **0** `huella_*.tscn`, **0** `particulas_*.gd`.
`scenes/terrain/` vacio.

### G9. Feedback audio inexistente
`TerrainProvider.get_audio_config()` (L69-71) devuelve `{}`. **0** `terrain_footstep_audio.gd`,
**0** samples. `grep play_footstep` = 0 hits.

### G10. Indicador UI inexistente
**0** `terrain_indicator.tscn`; `TerrainIndicator` = 0 hits en `scripts/` y `scenes/`. `scenes/terrain/`
vacio.

### G11. El diseno cita un archivo fantasma
`03-Diseno.md sec.2.1` y `04-Codigo.md sec.1.2` hablan de `scripts/player/player_movement.gd` y de
`scripts/equipment/equipment_system.gd`. Ninguno de los dos existe: los reales son
`scripts/player/player.gd` y `scripts/player/equipment_manager.gd`. El implementador debe ignorar
las rutas del diseno y usar las reales (trampa 103-bis: localizar el archivo, no asumirlo).

---

## 4. Mapa de prioridad para asignar implementador

Ordenado por "desbloquea a los demas" (no por dificultad):

| P | Brecha | Por que primero | Dificultad |
|---|---|---|---|
| P0 | G1 montar TerrainDetector en `Player.tscn` | sin detector no hay entrada al sistema | S |
| P0 | G6 arreglar el puente de nombres M156<->M155 | hoy el bono de botas es 0.0 siempre | S (1 mapa) |
| P1 | G3 tabla bloque->terreno completa (7/7) | barro/pavimento/agua hoy inalcanzables | M (tuning M08) |
| P1 | G5 integracion M11 (conectar + usar velocidad efectiva) | sin esto el jugador no cambia de velocidad | M |
| P2 | G2 registrar grupo `voxel_terrain` | el camino primario de busqueda esta muerto | S |
| P2 | G4 collision_mask del raycast | depende de las Layers 2-8 | S |
| P3 | G8 huellas/particulas | V2 visual (dueno M45/M52) | C |
| P3 | G9 audio de pasos | V2 audio (dueno M42/M44) | C |
| P3 | G10 indicador UI | V2 UI | M |

Nota de alcance: P0+P1 son **una sola sesion** de implementacion sobre `scripts/terrenos/` +
`scripts/player/player.gd` + `Player.tscn`. P3 depende de modulos de arte/audio con dueno propio.

---

## 5. Lo que SI esta bien (para no inflar el diagnostico)

- El **nucleo data-driven es real y verificable**: `TerrainProvider` autoload carga 7 terrenos del
  JSON (`terrenos.json`: cesped 1.0, barro 0.6, pavimento 1.0, arena 0.75, agua 0.7, nieve 0.8,
  rocas 0.85).
- `TerrainModifiers.calculate_effective_speed` implementa la formula del diseno sec.1.4 con cap de
  equipo 50% (sec.3.1) y fallback 1.0 para terreno desconocido (sec.10.2). Correcto y testeado.
- `test_terrenos.gd` tiene guardian de 3 capas (`CHECKS_MINIMOS=27`, `_fin()` por bloque,
  `_summary()` diferido con `quit(1)`) -> es una suite sana (no es un falso verde).
- El suavizado (`suavizar_velocidad` / `calcular_suavizado`) esta implementado y testeado; solo
  falta que M11 lo llame.

Es decir: M156 **no** es un modulo vacio. Es un nucleo funcional y testeado con **0 consumidores en
produccion**. La deuda es de CABLEADO, no de logica.

---

## 6. Restricciones respetadas / numeracion

- READ-ONLY: 0 ediciones en M156 (docs, codigo, escenas, datos). Verificado con `git status` del
  modulo sin cambios propios.
- Sin commit ni push.
- Log reservado del pool GLOBAL: head medido = **1525** JUSTO antes de reservar
  (`python scripts/reservar_log.py --reservar --agente DeepSeek-V4.1-Flash --modulo M156`);
  head despues = 1526. Este archivo = `Logs/1525-...`.
- Canal: head medido = **116**; reservado 116 (pool restante 384, cabeza 117).
- Colisiones AJENAS detectadas y NO tocadas: **1290** y **1468** (ya reportadas en el ciclo
  anterior; `reservar_log.py --estado` las sigue listando).
- Log ASCII puro verificado por bytes (`LC_ALL=C grep -c '[^ -~]'` = 0).
