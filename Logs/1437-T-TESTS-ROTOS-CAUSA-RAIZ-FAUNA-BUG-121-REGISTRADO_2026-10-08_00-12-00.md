# Log 1437: T-TESTS-ROTOS — causa raíz identificada (autoload de fauna) + BUG-121 registrado

**Fecha:** 2026-10-08
**Hora:** 00:12
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
Frente del director (canal 74): sanear los 3 tests "rotos" (M107/M110/M78) + registrar el patrón en 11-BUGS.

## Hallazgo (diagnóstico corregido)
Los 3 tests NO están rotos (sus checks pasan: M78 60/0 EXIT 0, M110 18/0, M107 [OK]). Los SCRIPT ERROR
`instantiate` sobre null salen del **autoload de fauna** que se instancia al arrancar la SceneTree en headless:
`tortuga_npc.gd:85` / `cangrejo_npc.gd:62` / `jabali_npc.gd:45,86` (`_instanciar_modelo`), que hacen
`load(glb)` (null en headless) + `.instantiate()` **sin null-guard**. Patrón compartido en fauna, no 3 helpers.

## Cambios
- `DOCUMENTACION/11-BUGS.md` §6: **BUG-121** registrado (una entrada, director autorizado). Causa raíz M30-fauna,
  repro, fix de 1 línea (null-guard), dueño = M30-fauna (no lo aplico: fuera de mi alcance).
- Puntero `# NOTA ... BUG-121` en los 3 tests: `test_backup_m107.gd`, `test_debug_m110.gd`,
  `test_legal_m78_v2.gd` (así no se los confunde con "rotos"). Verifiqué parse + M78 60/0 EXIT 0.
- Reporte en MI canal: `agnes-3-flash/75-…t-tests-rotos-causa-raiz-fauna-bug-121.md`.
- Log 1437 (este; tomé 1437, no el 1290 colisionado).

## Pendiente (decisión del director)
- El null-guard real en los 3 NPCs de fauna (M30) — **dueño a derivar**. Si me autorizan a tocar M30-fauna,
  lo hago (1 línea por NPC). Alternativa: suprimir el autoload de fauna en headless.

## Reglas
Sin commit/push (regla de la tanda). 11-BUGS tocado solo para BUG-121 (autorizado en 74). GLOBAL no tocado.
No toqué run_tests.gd (M112 = mimo) ni service_registry/bootstrap/interaction_manager/quality.yml/main_island.
