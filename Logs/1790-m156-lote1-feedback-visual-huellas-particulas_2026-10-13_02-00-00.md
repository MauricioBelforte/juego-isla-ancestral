# Log 1790: M156 lote I — feedback visual (huellas + particulas)

**Fecha:** 2026-10-13
**Hora:** 02:00
**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code

## Resumen

Encargo del director (mimo-v2.6, msg #56): "crear los sistemas I/J/L" (I =
huellas visuales, J = audio, L = indicador UI), uno por lote, commit por lote
con pathspec, test headless de cada uno.

Lote I completado: sistema de huellas + sistema de particulas, ambos
data-driven, con pooling, integrados en Player.tscn sin tocar player.gd.
20 flips en el checklist (182/69/56 -> 202/58/47).

## Cambios Realizados

### Sistemas nuevos

- `scripts/terrenos/terrain_footprints.gd` — gestor de huellas (Node3D hijo
  del jugador): pooling de MeshInstance3D, limite max_huellas (24), fade-out
  por tween al expirar, espaciado por distancia recorrida, activacion solo en
  movimiento, autoconexion al hermano TerrainDetector (terrain_changed).
- `scripts/terrenos/terrain_particles.gd` — gestor de particulas: pooling de
  CPUParticles3D, limite max_emisores (6), rafagas por frecuencia data-driven,
  intensidad -> amount.
- `scenes/terrenos/huella_{ceped,barro,pavimento,arena,agua,nieve,rocas}.tscn`
  (7) — PlaneMesh + StandardMaterial3D color del terreno, alpha, cast_shadow
  off, no_depth_test, sin texturas externas.
- `scenes/terrenos/particulas_*.tscn` (7) — CPUParticles3D procedural
  (direction/spread/gravity/initial_velocity/color/scale por terreno).

### Modificaciones

- `data/terrenos/terrenos.json` — schema_version 2: anadidas "huella"
  (distancia/tamano/alpha) y "particulas" (frecuencia/intensidad) por terreno.
- `scripts/terrenos/terrain_provider.gd` — get_visual_config() implementado
  (antes retornaba {}); fix en _cargar_terrenos: ahora conserva las claves
  "huella"/"particulas" (antes las descartaba silenciosamente).
- `scenes/player/Player.tscn` — nodos hijos TerrainFootprints y
  TerrainParticles.
- `DOCUMENTACION/156-Terrenos-Y-Movimiento/plan-actual/05-Checklist.md` —
  20 flips + Totales + Notas del Agente (lote I).

### Tests

- `tests/test_terrain_footprints_m156.gd` — suite nueva: 41 checks.

## Verificacion

- `test_terrain_footprints_m156.gd`: **41 OK / 0 FAIL** (headless Godot 4.7.2).
- Sin regresion: test_terrenos.gd 27/0, test_terrenos_b3.gd 28/0,
  test_terrenos_integracion.gd 39/0.
- Conteo estricto: 202 [x] / 58 [ ] / 47 [?] = 307 (sin drift).
- 0 mojibake en los 20 archivos del lote (verificado antes del commit).

## Decisiones y honestidad

- **CPUParticles3D sobre GPUParticles3D:** funciona en headless sin GPU.
  Consecuencia: ParticleProcessMaterial NO aplica (es de GPUParticles3D,
  medido en runtime) — los items L197-202 quedan `[ ]` con nota "no aplica".
- **Items `Crear particulas_*.gd` (L191-196):** no se crean .gd por terreno
  (la implementacion es escena + gestor unico). Quedan sin flipar.
- Sin texturas/binarios nuevos (todo procedural), por directiva del director.

## Archivos Modificados/Creados

- 2 scripts nuevos, 1 script modificado, 14 escenas nuevas, 1 escena
  modificada, 1 JSON modificado, 1 test nuevo, 1 checklist, 1 log (este).