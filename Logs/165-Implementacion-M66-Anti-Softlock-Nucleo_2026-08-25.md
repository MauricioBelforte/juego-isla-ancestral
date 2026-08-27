# Log 165: Implementación núcleo M66 — Anti-Softlock

**Fecha:** 2026-08-25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen

Implementado el **núcleo funcional del M66 (Anti-Softlock)**: detector central de invariantes (`SoftlockGuard`, autoload), contrato `IRecoverable`, 6 invariantes base, cofre de recuperación con copias inmutables y checkpoints rotativos con escritura atómica reutilizando el patrón de M59. Validado con Godot 4.7.2 headless `--check-only`: **0 errores M66**.

## Archivos creados

| Archivo | Contenido |
|---|---|
| `game/isla-ancestral/scripts/core/softlock_guard.gd` | Autoload detector: tick 60 s, dispatcher por prioridad, cascada vía handlers duck-typed, ventana 3 fallos/10 min, toasts con cooldown. Preloads explícitos para evitar race autoload/class_name |
| `game/isla-ancestral/scripts/core/softlock_rules.gd` | Config central (tiempos, radios, slots) |
| `game/isla-ancestral/scripts/core/invariants/irecoverable.gd` | Contrato IRecoverable + enum CategoriaRecuperable |
| `game/isla-ancestral/scripts/core/invariants/invariant_base.gd` | Base abstracta de invariantes |
| `game/isla-ancestral/scripts/core/invariants/{jugador,mision,npc,objeto_clave,vehiculo,puzzle}_invariant.gd` | 6 invariantes con registro de claves/fallbacks |
| `game/isla-ancestral/scripts/core/recovery/cofre_recuperacion.gd` | Cofre Node: 12 slots, copia inmutable, jamás duplica, serializable |
| `game/isla-ancestral/scripts/core/recovery/checkpoint_manager.gd` | 3 slots/bioma + global; atómico tmp+rename+.bak con SaveWriter (SHA-256) |

Modificados: `project.godot` (autoload SoftlockGuard), `05-Checklist.md` (18 `[x]`), `04-Codigo.md` (Notas del Agente), `CHECKLIST-GLOBAL.md` (fila 66 → 18/117).

## Bugs detectados y corregidos

1. `class_name` en un script que es autoload → "Class hides an autoload singleton". Solución: sin class_name en el autoload.
2. `extends` debe preceder a las declaraciones `const` (preload) en GDScript.
3. Un autoload no puede referenciar `class_name` de scripts no cargados aún → usar `preload()`.
4. API estática DirAccess 4.x: solo existen `dir_exists_absolute`, `make_dir_absolute`, `rename_absolute` (no `folder_exists` ni `dir_exists` estático).
5. `var x := dict.get(k)` no infiere tipo (Variant) → envolver con `int(...)`.

## Validación

```
softlock_guard.gd => Completed load (autoload OK)
save_manager.gd / item_database.gd => Completed load (regresión OK)
Único error del proyecto: main_island.tscn:36 (preexistente, módulo terreno — NO tocado)
```

## Pendientes honestos ([?])

- Hooks de disparo real (transición escena / al guardar): `forzar_chequeo()` existe pero falta conectarlo a SaveManager/scene_router.
- Lógica de detección concreta en NPC/Misiones/Puzzles/Vehículos/Jugador: los sistemas consumidores (M64/M22/M24-M26/M67/player) aún no existen; stubs devuelven válido.
- Tests de provocación de softlocks (06/07-Testings) cuando existan consumidores.
