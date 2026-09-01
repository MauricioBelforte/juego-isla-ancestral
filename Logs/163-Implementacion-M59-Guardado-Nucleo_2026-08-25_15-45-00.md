# Log 163: Implementación núcleo M59 Guardado (Godot 4.7)

**Fecha:** 2026-08-25
**Hora:** 15:45
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen

Se reclamó el módulo 59 (Guardado, complejidad 5, prioridad Alta) y se implementó la capa de servicio completa del sistema de guardado en el proyecto Godot real (`game/isla-ancestral/`). La implementación fue validada con una suite de QA headless ejecutada con el binario real de Godot 4.7.2: **13/13 checks OK, exit 0**.

## Cambios Realizados

- Creado `scripts/saving/` con 8 scripts GDScript:
  - `save_schema.gd`: schema versionado (v1), defaults de 14 secciones, validación de estructura.
  - `save_writer.gd`: escritura atómica `.tmp`+rename; formato determinista `checksum\npayload`; SHA-256 vía HashingContext.
  - `save_backup.gd`: rotación local (`slot_N_rK.bak`, 2 rotaciones) y backups manuales fechados.
  - `save_loader.gd`: carga validada (checksum → estructura → versión), recuperación automática desde backup, migración solo-hacia-delante.
  - `save_snapshot.gd` / `save_provider.gd`: contrato ISaveProvider y colecta/restaura por sección.
  - `save_manager.gd`: autoload con cola (1 guardado a la vez), slots 1-3, bloqueo, metadatos, auto-save temporizado configurable y señales.
  - `validate_save.gd`: suite QA headless (13 checks).
- Registrado `SaveManager` como autoload en `project.godot`.
- **Bug detectado y corregido:** el diseño original hasheaba `JSON.stringify(payload)` dentro del propio JSON — no determinista tras round-trip (falsos positivos de corrupción). Se rediseñó a formato `checksum\npayload`. Documentado en 07-GUIA-GODOT §9.11.
- Actualizados: `plan-actual/04-Codigo.md` (implementación real + Notas del Agente), `plan-actual/05-Checklist.md` (27/130 honesto), `CHECKLIST-GLOBAL.md` (fila 59 → 🟡 27/130), `ESTADO-PARALELO.md`.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/saving/save_schema.gd` (nuevo)
- `game/isla-ancestral/scripts/saving/save_writer.gd` (nuevo)
- `game/isla-ancestral/scripts/saving/save_backup.gd` (nuevo)
- `game/isla-ancestral/scripts/saving/save_loader.gd` (nuevo)
- `game/isla-ancestral/scripts/saving/save_snapshot.gd` (nuevo)
- `game/isla-ancestral/scripts/saving/save_provider.gd` (nuevo)
- `game/isla-ancestral/scripts/saving/save_manager.gd` (nuevo)
- `game/isla-ancestral/scripts/saving/validate_save.gd` (nuevo)
- `game/isla-ancestral/project.godot` (autoload agregado)
- `DOCUMENTACION/59-Guardado/plan-actual/04-Codigo.md` (firmado ox-alpha)
- `DOCUMENTACION/59-Guardado/plan-actual/05-Checklist.md` (27/130)
- `DOCUMENTACION/07-GUIA-GODOT.md` (§9.11 nuevo descubrimiento)
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `Logs/ULTIMO_NUMERO.txt`

## Verificación

```
Godot --headless --path game/isla-ancestral --script res://scripts/saving/validate_save.gd
→ 13 checks, 0 fallos — VALIDACIÓN OK, exit code 0
```

Nota: el error de parse de `main_island.tscn:36` es pre-existente (trabajo sin commitear de otro módulo, zona terreno/voxel restringida); verificado que escena estable (`main_test.tscn`) corre limpia con el autoload activo.

## Adendum (mismo día): auditoría contra skills instaladas (.claude/skills)

Se auditó la implementación contra la skill `godot-save-load-systems` (regla AGENTS §27):
- Cumplimiento verificado de las reglas NEVER principales (versión+migración, user://, sin nodos, validación, cierre de archivos).
- **Corrección aplicada:** chequeo del retorno bool de `FileAccess.store_string()` (cambio 4.4+ documentado en `migration-notes.md` de la skill). Re-validado: 13/13 checks OK, exit 0.
- Tabla completa de auditoría en `plan-actual/04-Codigo.md` §0.1.

## Adendum 2 (mismo día): corrección de errores de parse reportados por el usuario

El LSP del editor reportaba errores de versiones intermedias (caché). Verificación definitiva con `--check-only` por script:
- Los 7 scripts de `scripts/saving/` → **OK, sin errores** (eran caché del LSP; ya estaban corregidos en disco).
- `scripts/test_terrain.gd:55` → error real (`do_point()` es void, no asignable) — **corregido** por ox-alpha, validado con `--check-only`: OK.
- Descubrimiento documentado en `07-GUIA-GODOT.md` §9.12 y corregido también el ejemplo erróneo en `06-GUIA-DE-CONEXION-VISION.md`.

Nota para el usuario: si el editor sigue mostrando los errores viejos, recargar el proyecto (`Proyecto > Volver a cargar proyecto actual`) para refrescar el LSP.

