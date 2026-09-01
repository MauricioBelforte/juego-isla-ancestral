# Log 226: Cierre de Fase 1 — Fundacion ejecutable (M04, M05, M07)

**Fecha:** 2026-08-29
**Hora:** 01:25
**Modelo:** Hy3
**Plataforma:** Kilo

## Resumen
Se tomaron los 3 modulos de la Fase 1 (M04 relevo >24h de GitHub Copilot segun 21.4.7; M05/M07 libres) y se completaron los 6 items pendientes de la guia 08. Puerta F1 cerrada: el proyecto arranca, los servicios se registran y no hay errores de arquitectura.

## Implementacion
- **M04** (`project.godot`): seccion [layer_names] 3D (mundo/jugador/npc/interactuable/agua) e [input] inicial con 18 acciones: mover (WASD + stick izquierdo), interactuar E, colocar Q, inventario B, favorito F, hotbar 1-9, zoom por rueda, rotacion de camara por stick derecho, pausa ESC. Bootstrap y Main ya ejecutables (verificado).
- **M05** (`scripts/core/registro.gd`): utilidad estatica de logging y validacion (info/aviso/error/verificar/verificar_no_nulo con contadores). Test headless `test_registro.gd`: 0 fallos.
- **M07** (`scripts/core/verificar_arquitectura.gd` + `scenes/prueba_arquitectura.tscn`): verificador headless (0 fallos) que valida orden/precedencias de autoloads y dependencias unidireccionales de scripts/core; escena vacia con SMOKE OK en runtime real (autoloads, registro de servicios y EventBus por dominios).

## Hallazgos
- El EventBus fue refactorizado a "senales por dominios" (EventBus_ con WorldEvents/EconomyEvents/...) por M53/M111 en curso — el smoke test se adapto al patron real y las senales planas (notify/day_started) ya no existen en el bus.
- Bootstrap no es el ultimo autoload (pos 14/18): recomendado moverlo al final cuando M53/M112 liberen project.godot (aviso del verificador, diferido).
- M04/M05/M07 tenian checklists sin marcar pese a tener el nucleo implementado: se marcaron solo los items con evidencia directa; la auditoria completa queda pendiente (65-125 items por modulo).

## Archivos
- `game/isla-ancestral/project.godot` ([layer_names] + [input])
- `game/isla-ancestral/scripts/core/registro.gd`, `test_registro.gd`, `verificar_arquitectura.gd`
- `game/isla-ancestral/scenes/prueba_arquitectura.tscn`, `scripts/core/prueba_arquitectura.gd`
- Checklists/guia 08/CHECKLIST-GLOBAL/ESTADO-PARALELO actualizados; `Logs/ULTIMO_NUMERO.txt` -> 226