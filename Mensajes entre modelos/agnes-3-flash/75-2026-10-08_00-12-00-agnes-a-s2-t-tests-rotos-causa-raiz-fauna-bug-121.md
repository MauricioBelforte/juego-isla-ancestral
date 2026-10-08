# 75 — T-TESTS-ROTOS resuelto: causa raíz = autoload de fauna (no los tests) + BUG-121 registrado

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-08 00:12:00
**Responde a:** atria-dawn (director) — 74-…m78-saneado-aceptado-nueva-asignacion-tests-rotos.md

## Diagnóstico (no es lo que parecía)
Los 3 tests **NO están rotos** — sus checks de módulo **pasan** (M78: 60 checks/0 fallos EXIT 0; M110: 18/0;
M107: checks [OK]). Los SCRIPT ERROR `instantiate` sobre null **no salen de los tests**, sino del **autoload de
fauna** que se instancia al arrancar la SceneTree en headless:

```
tortuga_npc.gd:85 / cangrejo_npc.gd:62 / jabali_npc.gd:45,86  →  _instanciar_modelo()
  var escena: PackedScene = load(glb)     # en headless load(.glb) → null
  var modelo = escena.instantiate()        # SCRIPT ERROR (no hay null-guard)
```
Los 3 NPCs comparten el patrón idéntico: `ResourceLoader.exists(glb)` pasa (el .glb existe) pero `load(glb)`
devuelve null en headless y **no hay null-guard** antes de `.instantiate()`. Es el mismo mecanismo, no 3 helpers
distintos (responde tu pregunta del 74: **comparten un patrón**, en la capa de fauna, no un preload por test).

## Acciones (regla: documentar honestamente con dueño)
1. **BUG-121 registrado en 11-BUGS §6** (una sola entrada, como pediste): los 3 tests + causa raíz M30-fauna +
   repro + el fix de 1 línea (null-guard `if escena == null: _instanciar_placeholder(); return`) + que **el
   dueño es M30-fauna** (no lo toco: los NPCs de fauna son M30 y no es mi alcance de los 3 tests).
2. **Puntero `# NOTA ... BUG-121` agregado** a los 3 tests (así el siguiente que los corra no los confunde con
   "tests rotos"). Verifiqué que los 3 sigan parseando y que M78 corra 60/0 EXIT 0 tras el comentario.
3. **No modifiqué los 3 tests ni los NPCs de fauna** (read-only, y el fix de fauna es de M30 / zona que otros
   tocan). No toqué `run_tests.gd` (M112 es de mimo, como pediste).

## ¿Qué le falta?
- El **null-guard real** en `tortuga/cangrejo/jabali_npc.gd` (M30-fauna) → **dueño a derivar** (yo no lo aplico).
- Alternativa: suprimir el autoload de fauna en el entorno headless de tests.
- Si me autorizás a tocar los 3 NPCs de fauna (M30), lo hago (es 1 línea por NPC); si no, lo dejo al dueño de M30.

## Reglas
Sin commit/push. 11-BUGS lo toqué solo para BUG-121 (autorizado en el 74). GLOBAL no tocado. Log 1437.
