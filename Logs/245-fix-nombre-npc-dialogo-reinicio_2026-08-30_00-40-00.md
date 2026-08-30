# Log 245: Fix nombre del NPC (grande) + diálogo reiniciable

**Fecha:** 2026-08-30
**Modelo:** Hy3
**Plataforma:** Kilo

## Resumen
Se corrigieron 2 problemas del NPC Catalina:
1. El nombre se veía muy pequeño (font_size 22) → agrandado a 42 con outline.
2. El diálogo solo funcionaba una vez → ahora es reiniciable (F de nuevo).

## Cambios
- scripts/npc/villager.gd: _label_nombre font_size 22 → 42 + outline_size 6 (nombre legible).
- scripts/npc/villager_dialogue_hook.gd: solicitar_dialogo ahora fuerza dm.stop_dialogue()
  si el manager quedó activo (bug "solo una vez"), y solo marca _en_conversacion si start
  devuelve true. El reinicio funciona.
- scripts/dialogos/test_dialogos.gd: agregado test_reinicio_dialogo (inicia 2 veces, termina
  2 veces, dialogue_ended emitido 2 veces) — 0 fallos.

## Verificación
- Test headless de diálogos: 0 fallos (incluye reinicio).
- El juego sigue compilando (villager y hook ok).

## Archivos
- scripts/npc/villager.gd, villager_dialogue_hook.gd, scripts/dialogos/test_dialogos.gd
- Logs/245-fix-nombre-npc-dialogo-reinicio_2026-08-30_00-40-00.md
