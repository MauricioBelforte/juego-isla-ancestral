# Log 609 — M162 Diálogos Contextuales de NPCs (iter 3b, RUNTIME)

**Fecha:** 2026-09-04 00:35 GMT-3
**Modelo:** hy3
**Plataforma:** WorkBuddy
**Módulo:** 162 — Diálogos Contextuales de NPCs
**Estado:** 🔵 En curso (iter 3b — verificación runtime del FIX Log 608)

## Resumen
El usuario habilitó el uso de Godot vía MCP (godot-mcp) para verificación runtime.
Se confirmó conectividad (`get_godot_version` -> 4.7.2.stable) y se ejecutó el
selector real `ContextualDialogueManager.seleccionar` en Godot 4.7.2 headless.

## Verificación del FIX de Log 608 (aur_005 día/noche)
- `test_contextual_dialogue_m162.gd` (canónico, ampliado): **323/323 grafos validados, 0 fallos**.
  Se añadió aserción de contenido al fallback diurno del Viajero Misterioso:
  devuelve "No estoy aquí durante el día..." y NO "...Solo aparezco de noche...".
- `test_aur005_fix_log608.gd` (nuevo, focalizado): **0 fallos** —
  noche -> texto de noche; día (es_noche==False, prio 0) -> texto de día.
- Conclusión: el bug de selección día/noche de `DLG-AUR_005-CAP0-SALUDO-DIA`
  (apuntaba al grafo nocturno) QUEDA VERIFICADO EN RUNTIME. Se cierra la
  salvedad de honestidad de Log 608.

## Archivos
- `scripts/dialogos/test_aur005_fix_log608.gd` (nuevo) — test runtime focalizado.
- `scripts/dialogos/test_contextual_dialogue_m162.gd` (modificado) — +aserción de texto día/noche.
- `registry.json` / `aur_005_cap0_saludo_dia.json` sin cambios desde Log 608 (ya correctos).

## Notas de honestidad
- Verificación por lógica directa (sin tecla F sintética: M101 confirmó que el input
  de diálogo no dispara vía mensajes sintéticos). Cubre el camino de código real del selector.
- No se tocaron módulos ajenos ni los cambios sin commit de otros modelos.
