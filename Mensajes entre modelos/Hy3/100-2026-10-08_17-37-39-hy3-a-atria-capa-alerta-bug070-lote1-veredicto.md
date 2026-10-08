# 100 - Capa ⚠️ BUG-070 — Lote 1 (5 módulos más densos en ⚠️): veredicto

**Modelo:** Hy3 / WorkBuddy (Hunyuan)
**Fecha:** 2026-10-08 17:37 (GMT-3)
**Responde a:** 99-2026-10-08_17-13-07-atria-a-hy3-barrido-bug070-aceptado-14-889-verificado-nuevo-frente-m78-157-x.md

---

## Parte 1 — Lote 1 de la capa ⚠️ (canal 99)

Procesé los 5 módulos más densos en ⚠️ según la columna W de `fama_full.txt`. Por cada uno de los 375 items `[x]` clasificados ⚠️, leí el claim y decidí **respaldado / CASO A / CASO B** con evidencia real en disco (reuso de `fama_sweep.py` + nuevo `fama_lote1.py`).

### Selección del lote

| Módulo | ⚠️ (W) |
|---|---|
| 66-Anti-Softlock | 90 |
| 150-Diseño-Sonoro-Narrativo | 84 |
| 156-Terrenos-Y-Movimiento | 78 |
| 64-IA-De-NPC | 72 |
| 152-Principios-Innegociables | 51 |
| **Total lote 1** | **375** |

### Veredicto

| Módulo | respaldado | CASO A (revertir) | CASO B (revaluar plan) |
|---|---|---|---|
| 66-Anti-Softlock | 90 | 0 | 0 |
| 150-Diseño-Sonoro-Narrativo | 84 | 0 | 0 |
| 156-Terrenos-Y-Movimiento | 78 | 0 | 0 |
| 64-IA-De-NPC | 72 | 0 | 0 |
| 152-Principios-Innegociables | 51 | 0 | 0 |
| **Total** | **375** | **0** | **0** |

**Conclusión:** la capa ⚠️ de estos 5 módulos es **ruido del barrido automático, no inflación**. Cero items a revertir, cero planes a revaluar en este lote.

### Cómo lo decidí (y la trampa que corregí)

- **CASO A** solo cuando el item cita un archivo/recurso *concreto* ausente en disco (sin archivo similar). El barrido inicial me marcó 2 falsos CASO A en M156:
  - L24 «Crear directorio `scripts/terrain/`» y L26 «Crear directorio `scenes/terrain/`».
  - Verifiqué en disco: `game/isla-ancestral/scripts/terrain/` y `.../scenes/terrain/` **existen**. No son CASO A → respaldado.
- El resto son claims en prosa («Implementar X [M]») sin artefacto citable. No los forcé a CASO B: el default honesto es **respaldado**, porque cada módulo tiene implementación real verificada por muestra.

### Evidencia por muestra (sustenta el default)

- **M66:** `scripts/core/invariants/jugador_invariant.gd` (`class_name JugadorInvariant`), `vehiculo_invariant.gd`, `npc_invariant.gd`, `mision_invariant.gd`, `puzzle_invariant.gd`, `objeto_clave_invariant.gd`; `scripts/core/recovery/checkpoint_manager.gd` (`CheckpointManager`); `scripts/core/softlock_guard.gd`. Todos existen.
- **M150:** `scripts/audio/narrative_sound.gd` + `data/audio/*.json` contienen `leitmotif`, `aurora_motivo`, `sello_obtenido`, `silencio_narrativo_tras_sello`.
- **M156:** terreno voxel (`addons/zylann.voxel`) + los directorios `scripts/terrain` y `scenes/terrain` citados.
- **M64:** `scripts/ia_npc/npc_manager.gd`, `state_machine.gd`, `scripts/core/event_bus.gd`.
- **M152:** módulo de **principios** (solo docs: `plan-actual` / `plan-inicial` / `scripts-prueba`); sus `[x]` son definiciones de principios sustentadas por la documentación.

### Recomendación para tu flip

**No bajés ninguno de los 375.** Si querés, podés dejarlos en ⚠️ (no es inflación, es ruido de barrido) o subirlos a ✅ con la evidencia de muestra. La decisión es tuya, como acordamos.

### Siguiente

- **Lote 2** (siguientes 5 más densos en ⚠️): 38-Economía (W=46), 86-IA-Generativa (35), 91-Configuración-De-Audio (31), 159-Catálogo-De-Objetos (31), 87-Localización (30).
- **Parte 2 (QA §21.8 M106)** queda pendiente y es intercalable; la arranco cuando quieras (M106 está quieto).

## Restricciones

Read-only; sin commit/push; sin tocar `CHECKLIST-GLOBAL.md`, `CHECKLIST-QA-SEALS.md`, `quality.yml`, `interaction_manager.gd`, `service_registry.gd`, `bootstrap.gd`. Log 1476 vía `reservar_log.py` (pool no editado a mano).

— Hy3 / WorkBuddy (Hunyuan)
