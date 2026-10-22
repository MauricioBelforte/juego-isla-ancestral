# Log 2126: M20 entra al CI central — wrapper integrador (79 checks de las 3 suites de amistad)

**Fecha:** 2026-10-22
**Hora:** 06:10 (local; fecha real)
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Que se hizo

Las 3 suites de M20 (79 checks) vivian en `scripts/friendship/`, fuera de `res://tests/`, que es lo UNICO que
descubre `tests/run_tests.gd` -> **M20 no corria en el CI central** (mismo patron que M17).

**`game/isla-ancestral/tests/test_m20_amistad_suites.gd`** (NUEVO): ejecuta las 3 suites como subprocesos
(patron del runner: `cmd.exe /V:ON /C` + redirect + `create_process` + polling) y agrega su resultado.
**Verificado: 8 checks del wrapper, 0 fallos, rc=0, 79 checks de M20 verificados** (`test_amistad.gd` 14 ·
`test_amistad_eventos.gd` 53 · `test_amistad_rf48_m20.gd` 12).

El parser del wrapper tolera los **3 formatos de resumen** que usan esas suites: "N checks, M fallos" · suma de
"(+N checks)" por bloque · conteo de lineas "[OK] <nombre>" (`test_amistad_rf48_m20.gd` no imprime resumen).

**Pisos calibrados con lo MEDIDO** (79 checks): esperado >= 74, minimo >= 69. Nunca por encima de lo medido.

## Hallazgo lateral (para el dueno)

`test_amistad_rf48_m20.gd` imprime `ERROR: Failed to retrieve non-existent singleton 'AnimationService'` y
"6 ObjectDB instances were leaked at exit". El `AnimationService` **ya no existe en Godot 4.7** — mismo API
eliminado que aparecia en la suite de M10. Derivado.

## Estado

M20: **80 [x] / 68 [ ] / 0 [?] (de 148)** — en esta tanda no se cerro ningun item (es una entrega de
infraestructura: que M20 entre al CI). Con las suites ya dentro, escribir los tests que faltan para los 68
pendientes es trabajo mio de una vez y entra verificado.

## Archivos

- Creado: `game/isla-ancestral/tests/test_m20_amistad_suites.gd`, este log, el acuse del canal
- Modificado: `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/05-Checklist.md` (nota del wrapper),
  `BACKLOG-MASTER.md`, `ESTADO-PARALELO.md`
- Sin push ni commits.
