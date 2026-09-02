# Log 432: M13 Herramientas iter. 5 — niveles → progresión (puente M13→M71) — glm-5.3-flash

**Fecha:** 2026-09-02
**Hora:** 01:20
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen

Iteración 5 del M13 Herramientas (V0/V1, sobre el núcleo de ox-alpha/Cline): la señal estándar `nivel_herramienta_cambio` que el diseño M71 §3.6/§5 requería, sin tocar el núcleo M13. Desbloquea las condiciones `nivel_modulo` de M71. Módulo liberado 🟡 67/102.

## Cambios Realizados

### event_bus.gd (M07, aditivo)
- Dominio nuevo `progresion` con señales nivel_herramienta_cambio/nivel_casa_cambio/nivel_amistad_cambio (contrato del diseño M71 §5 para M13/M18/M20).

### progression_manager.gd (M71, aditivo)
- conectar_tool_controller(tc): helper público para que la escena conecte el ToolController (nodo de escena, no autoload).
- _on_herramienta_equipada(tool): traduce herramienta_equipada → nivel_herramienta_cambio con tool_id legible (pico/azada/hacha/...) + estadística monótona nivel_<id> en PlayerProfile (solo sube con niveles mayores — condición nivel_modulo §3.6).

### test_nivel_herramienta.gd (nuevo)
- ToolData.crear(PICO, HIERRO/ORO/COBRE) → herramienta_equipada → señal emitida + estadística monótona (sube 1→2, no baja con equipo menor) → **0 fallos**.

### Registro
- Regresiones: test_progresion M71 0 fallos, test_herramientas M13 0 fallos.
- Checklist: +2 ítems [x] (RF8 persistencia niveles via PlayerProfile + señal estándar). Progreso 65→67/102.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/core/event_bus.gd` (dominio progresion, aditivo)
- `game/isla-ancestral/scripts/progresion/progression_manager.gd` (puente + helper público)
- `game/isla-ancestral/scripts/progresion/test_nivel_herramienta.gd` (nuevo)
- `DOCUMENTACION/13-Herramientas/plan-actual/04-Codigo.md` (Notas del Agente iter. 5)
- `DOCUMENTACION/13-Herramientas/plan-actual/05-Checklist.md` (67/102 + reserva liberada)
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`

## Verificación

- test_nivel_herramienta.gd: 0 fallos · regresiones M71/M13: 0 fallos (Godot 4.5 headless).

## Pendiente con dueño

- La escena principal (main_island.tscn / Bootstrap) debe llamar `ProgressionManager.conectar_tool_controller($ToolController)` al montar el ToolController — 1 línea, dueño del escenerio.
