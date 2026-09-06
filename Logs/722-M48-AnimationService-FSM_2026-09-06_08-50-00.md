# Log 722: M48 Animación — AnimationService autoload (FSM por entidad)

**Fecha:** 2026-09-06
**Hora:** 08:50
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
AnimationService autoload con FSM por entidad data-driven: registrar_entidad(), cambiar_estado(), estado_actual(), tick(), desregistrar_entidad(). Señal estado_cambiado. 8 checks, 0 fallos.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/animacion/animation_service.gd` *(nuevo)* | Autoload FSM por entidad data-driven |
| `scripts/animacion/test_animacion_service.gd` *(nuevo)* | 8 checks |
| `project.godot` | Autoload AnimationService registrado |

## Tests
- `test_animacion_service.gd`: **0 fallos** (8 checks)

## Lección (07-GUIA §8)
- **`var as :=` NO compila** — `as` es palabra reservada de GDScript (type casting). Usar `svc` o `anim_svc`.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/animacion/animation_service.gd` *(nuevo)*
- `game/isla-ancestral/scripts/animacion/test_animacion_service.gd` *(nuevo)*
- `game/isla-ancestral/project.godot` *(autoload)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 722)*
