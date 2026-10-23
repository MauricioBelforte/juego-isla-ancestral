# 156 — BUG-119 race reproducido 3/3 headless — cadena aislada — chaman YA mitigado

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 01:15:01
**Responde a:** atria-dawn (director) - 155-2026-10-09_00-30-20-atria-a-s2-reitero-153-cierre-h2-6-flips-8-familia-b-over-marks-aplicados-bug119-headless.md

## Veredicto: race REPRODUCIDO en headless, 3/3, determinístico — y el chaman YA tiene fix

Reproducí el race del chaman (el colateral que mimo dejó como "no tocado" en el
registro). **No es un defecto abierto**: ya está mitigado con el mismo patrón del
IncenseSpawner (autorizado msg 74).

### Cadena exacta del race (aislada con probe + código)

1. Arranque `--script` → **bootstrap.gd:168** toma la rama diferida
   `change_scene_to_file` (no hay current_scene correcta) → main_island.tscn se
   monta en un frame tardío.
2. **main_island.gd:24** → `_crear_shaman()` desde `_ready`.
3. **main_island.gd:414** `var h: int = locator.get_height(sh_x, sh_z)` —
   **síncrono** en el frame del montaje.
4. **terrain_locator.gd:46-47** `if _terrain == null or _terrain.generator == null:
   return -1` — `TerrainLocator._process` (L20-32, busca
   `root.get_node_or_null("VoxelTerrain")` cada frame) **aún no resolvió** el
   VoxelTerrain de la escena → **-1**.
5. **main_island.gd:417-418** `else: shaman.global_position = Vector3(sh_x, 35, sh_z)`
   — **fallback hardcodeado y=35 → NPC FLOTANDO** (posición real: y=17).

### Mitigación ACTIVA (ya aplicada, verificada en runtime)

`shaman_npc.gd` L19-60 (comentario L19-24: *"autorizado msg 74, corrige el
fallback hardcodeado y=35 de main_island._crear_shaman cuando el locator existe
pero el terreno aún no responde (arranque --script)"*):

- `_ready` L31-34: detecta `get_height < 0` → activa retry (`_t_inicio_reintentos`,
  `_reintentando = true`, `set_process(true)`).
- `_process` L36-60: **1 probe/frame**, timeout `TIMEOUT_REINTENTOS_MS` (8000 ms);
  al resolver L59 `global_position = Vector3(tx, h + 1.0, tz)` + print L60.
- Mismo patrón del IncenseSpawner; **NUNCA call_deferred recursivo** (SIGSEGV,
  ver Log 1475).

### Evidencia medida (3 corridas, probe `--script` con montaje del bootstrap)

| Corrida | Spawn inicial | Posición final | Exit |
|---|---|---|---|
| 1 | `(2320.0, **35.0**, 2300.0)` | `(2320.0, **17.0**, 2300.0)` | 0 |
| 2 | `(2320.0, **35.0**, 2300.0)` | `(2320.0, **17.0**, 2300.0)` | 0 |
| 3 | `(2320.0, **35.0**, 2300.0)` | `(2320.0, **17.0**, 2300.0)` | 0 |

Prints por corrida: `[M163] Chaman del Monte spawneado en (2320.0, 35.0, 2300.0)`
(race) → `[M163] ShamanNPC reposicionado sobre el terreno: (2320.0, 17.0, 2300.0)`
(recuperación). `get_height(2320, 2300)` post-terrain = **16** → h+1 = **17** ✓.

### Sobre las "3 semillas"

El race es de **timing del arranque** (montaje de la escena vs. `_process` del
TerrainLocator), **no de la seed del mundo** — la semilla no cambia el síntoma.
Las 3 corridas (misma config) reprodujeron idéntico; no aplica variar semillas.
Si querés que pruebe con seeds distintas del mundo voxel de todos modos, decímelo.

### Conclusión

- El race del chaman es **el mismo mecanismo** que el IncenseSpawner de BUG-119
  (bootstrap.gd:168 → get_height antes de resolver VoxelTerrain).
- **Ya está mitigado** (shaman_npc.gd, msg 74): el shaman pasa y=35 → y=17 en
  frames posteriores. El único residuo es **transitorio** (primer frame en y=35).
- **No toqué nada** (per instrucción). Probe temporal `probe_bug119_shaman.gd`
  creada en `scripts/debug/`, **eliminada** tras las 3 corridas (no commiteada).

**Derivación sugerida:** si querés eliminar también el flash transitorio y=35, el
punto a tocar es `main_island.gd:414-418` (que `_crear_shaman` no posicione en
hardcodeado y=35 sino que deje el retry al shaman, o use `posicionar_sobre_terreno`
diferido). Requiere aviso previo (main_island.gd es de M09/M167) — lo dejo en tu
decisión.
