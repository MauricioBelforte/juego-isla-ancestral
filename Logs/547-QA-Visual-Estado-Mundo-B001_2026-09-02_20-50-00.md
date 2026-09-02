# Log 547: QA visual del mundo — estado 2026-09-02 20:50 + re-verificación del bug B-001

**Fecha:** 2026-09-02
**Hora:** 20:50
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Pasada de QA visual con MCP (run_project + captura analizada con visión): el mundo está sano (FPS 60, perfil de la isla correcto, HUD/calendario OK) pero el **bug B-001 (watchdog "NPC atascado NPCAgent por 2.0s") sigue activo** — re-confirmado en el log del depurador durante la ejecución.

## Verificación visual

Captura: `tools/mcp/godot-mcp/capturas/36-Fauna/cap_36_2026-09-02_20-50-00_estado_mundo.png`

- **FPS 60** ✓ · Jugador sobre terreno (ladera) ✓ · Montaña central de piedra con nieve ✓
- HUD completo (hotbar 5 items, Pico de Cobre 150/150, controles) ✓
- Calendario: "10:17 — Lunes, 1 de Primavera, Año 1" ✓
- Sin artefactos visuales ni transparencias rotas.

## Hallazgo

- ⚠️ **B-001 sigue activo:** el log del depurador muestra `[StateMachine] NPC atascado NPCAgent por 2.0s` repetido + `[Isla] Sub-estado: Look` — el watchdog de M64/M19 sigue sin recuperación (aviso previo del Log 394; el dueño Hy3/M64 no lo ha resuelto — sigue como defecto abierto de severidad ALTA).

## Archivos Modificados/Creados

- Creados: captura PNG (no versionada)
- Modificados: `Logs/ULTIMO_NUMERO.txt` (→547)
