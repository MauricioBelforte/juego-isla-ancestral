# Log 1018: M66 Anti-Softlock — iter. agnes acotada (gate CI + auditoría core)

**Fecha:** 2026-09-18
**Hora:** 18:45
**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code

## Resumen

Iteración del bucle V0/gate-CI de **agnes-3-flash** sobre **M66 Anti-Softlock** (relevo del
`🟡 Con dudas 110/117`, sin dueño). El core ya estaba verificado (glm Log 913 + QA 953); mi parte es
**proteger ese core en CI** y **confirmar que los 7 `[?]` son externos** (M22/M26/M64/M27).

## Cambios Realizados

- **`quality.yml`:** `test_anti_softlock_m66.gd` y `test_fallbacks_m66.gd` **no estaban** cableados →
  añadidos al **gate duro** (job test-suite), junto a los tests M83/M126/M128. El core anti-softlock
  queda protegido por CI.
- **`05-Checklist.md` M66:** §"Reserva actual" (Log 1018, V3 pool) + §"Iteración agnes — gate CI"
  (verificación core + gap CI + los 7 `[?]` externos).
- **`04-Codigo.md` M66:** §"Iteración agnes — gate CI".
- **`CHECKLIST-GLOBAL.md` fila 66:** `🟡 Con dudas` → **`🟡 Liberado (iter. agnes gate CI)`** 110/117.

## Verificación (godot 4.7.2 headless)

- `godot --headless --path game/isla-ancestral --script res://scripts/core/test_anti_softlock_m66.gd`
  → **0 fallos, exit 0, 0 `SCRIPT ERROR` propios**.
- `godot --headless --path game/isla-ancestral --script res://scripts/core/test_fallbacks_m66.gd`
  → **0 fallos, exit 0, 0 `SCRIPT ERROR` propios**.
- Core presente: `softlock_guard.gd` (autoload, tick 60 s, cascada de invariantes + cooldown toast) +
  `softlock_rules.gd` + `invariants/` (jugador/misión/npc/objeto_clave/vehículo/puzzle + `irecoverable`)
  + `recovery/` (cofre_recuperacion, checkpoint_manager).

## Los 7 `[?]` (externos, NO los cierro)

| `[?]` | Bloqueado por |
|---|---|
| NavigationServer3D 2 caminos | **M27** |
| watchdog NPC (reusado M64) | **M64** |
| sincronización con persistencia de misiones | **M22** |
| pruebas de misiones imposibles (injerto) | **M27/M64/M22/M26** |
| integración M22 (Historia Principal) | **M22** |
| integración M26 (Templo Subterráneo) | **M26** |
| integración M64 (watchdog NPC) | **M64** |

Se abren cuando esos módulos expongan la API. M66 queda **esperando externos + core protegido por CI**.

## Estado de M66
🟡 **Liberado (iter. agnes gate CI, acotada).** 110/117. Mi parte (verificación core + gate CI +
auditoría de los 7 `[?]` externos) entregada. Los 7 `[?]` siguen con **dueño externo** (M22/M26/M64/
M27). QA cruzado §21.8 del Log 1018 pendiente (verificador ≠ agnes-3-flash).
