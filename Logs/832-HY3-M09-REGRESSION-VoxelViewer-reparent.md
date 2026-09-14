# Log 832 — Hy3 / WorkBuddy — M09: regresión VoxelViewer reparent (boot ERROR)

**Modelo:** Hy3 (Tencent Hunyuan)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-11
**Módulo:** 09-Terreno-Y-Geografia / 10-Generacion-Del-Mundo (escena `main_island.gd`, M09/M10)
**Tipo:** QA cruzado (§21.8) + fix de regresión detectada en boot smoke test

## Contexto
Durante el QA cruzado de M09 (mi rol primario §21.8) ejecuté un boot smoke test headless
del proyecto (`Godot 4.7.2 --headless --path game/isla-ancestral --quit`). El proyecto
cargaba, pero en `_ready` aparecía un `ERROR` de arranque:

```
ERROR: Can't add child 'VoxelViewer' to 'Player', already has a parent 'Main'.
```

## Root cause
`_enganchar_voxel_viewer(player)` (en `scripts/main_island.gd`) hacía
`player.add_child(viewer)` **sin antes des-parentar** el nodo. Como `VoxelViewer`
sigue siendo hijo de `Main` en el árbol de escena, Godot rechazaba el reparent y
el streaming de chunks no se anclaba al jugador.

Esta era una guarda defensiva que **ya había aplicado y verificado en una sesión
anterior** (reparent seguro: `if viewer.get_parent() != player: remove_child + add_child`).
El código actual tenía la versión simplificada sin la guarda → la fix previa fue
**pisada/regresada por otro agente** (riesgo conocido: "otros agentes pisan archivos
compartidos" — ver `.workbuddy-ai/memory/MEMORY.md`).

## Fix (Log 831)
En `scripts/main_island.gd`, `_enganchar_voxel_viewer`:
```gdscript
func _enganchar_voxel_viewer(player: Node) -> void:
	var viewer := get_node_or_null("VoxelViewer") as VoxelViewer
	if viewer == null or player == null:
		return
	if viewer.get_parent() != player:
		var padre_viejo := viewer.get_parent()
		if padre_viejo != null:
			padre_viejo.remove_child(viewer)
		player.add_child(viewer)
	viewer.position = Vector3.ZERO
	print("[M09] VoxelViewer enganchado al Player — streaming alrededor del spawn")
```

## Verificación
Re-ejecutado boot smoke test headless (`Logs/qa_m09_2026-09-11.txt`):
- `ERROR: Can't add child 'VoxelViewer'...` → **desaparecido**.
- Aparece `[M09] VoxelViewer enganchado al Player — streaming alrededor del spawn`.
- Único `ERROR` restante: `9 resources still in use at exit` (limpieza de shutdown,
  no de boot; benigno en `--quit` headless).
- `EXIT=0`.

## Impacto
- Boot limpio del proyecto (ya no hay ERROR de parenting en arranque).
- Streaming de terreno voxel se ancla correctamente al jugador (M09/M10).
- Afecta a TODOS los módulos (error era a nivel de escena principal), no solo M09.

## Nota de gobernanza
La regresión evidencia que una fix verificada de Hy3 fue sobreescrita por otro agente
sin re-verificar. Recomiendo: (a) los agentes que tocan `main_island.gd` corren el boot
smoke test antes de liberar; (b) re-auditoría de `main_island.gd` en busca de otras fixes
de Hy3 pisadas.
