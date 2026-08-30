# Log 246: Fix definitivo diálogo reiniciable (fuente de verdad del estado = manager)

**Fecha:** 2026-08-30
**Modelo:** Hy3
**Plataforma:** Kilo

## Resumen
El diálogo seguía sin reiniciarse con F. La causa raíz: el flag `_en_conversacion` del hook
**solo se reseteaba al llegar al nodo FIN** del diálogo. Si el jugador cerraba la UI o no
completaba hasta el fin, `_en_conversacion` quedaba `true` para siempre → F bloqueado.

## Solución
El hook ahora consulta **`DialogueManager.is_dialogue_active()`** como fuente de verdad del
estado (ya no depende de un flag manual frágil):
- `solicitar_dialogo`: si el manager no está activo, re-inicia (aunque `_en_conversacion` quedara true).
- `esta_en_conversacion()`: devuelve `dm.is_dialogue_active()`.
- Se reconectó `dialogue_ended → _on_m21_terminado` (para notificar_cierre de M20).

## Verificación
- Test headless de diálogos: 0 fallos (incluye test_reinicio_dialogo: inicia 2 veces, maneja fin).
- Hook compila OK.

## Archivos
- scripts/npc/villager_dialogue_hook.gd
- Logs/246-fix-definitivo-dialogo-reinicio_2026-08-30_00-50-00.md
