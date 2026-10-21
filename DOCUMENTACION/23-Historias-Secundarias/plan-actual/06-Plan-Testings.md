# 06 — Plan de Testings — M23: Historias Secundarias

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21 (iter. 2)
**Módulo:** M23 Historias Secundarias — `scripts/historias/`, `data/historias/`

## Alcance

El núcleo de M23 es data-driven: catálogo JSON + motor (`SecondaryStoriesService`,
autoload `Historias`) + validador anti-repetición + persistencia (M59). El plan cubre
el motor y sus integraciones reales (M21 WorldState, M22 Historia, M14 Inventario,
M55 Diary, M07 EventBus, M59 SaveManager). El contenido narrativo (60+ cadenas) y
las integraciones con dueño externo (M68/M32/M36/M37) **no** se testean acá: son
trabajo de esos módulos.

## Suite principal

`game/isla-ancestral/scripts/historias/test_historias.gd` — `extends SceneTree`,
corre con el binario real:

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral --script res://scripts/historias/test_historias.gd
```

### Bloques (7)

| Bloque | Contenido | Integraciones ejercitadas |
|---|---|---|
| A | Carga del catálogo (4 cadenas, sección `secondary_stories`, acceso por id) | JSON |
| B | Validador anti-repetición sobre el catálogo base (contexto >= 10, pasos >= 3, tipos, ids únicos, recompensa/consecuencia, título único) | — |
| C | Cadena completa de 4 pasos con tipos mixtos, rechazo de tipo/evidencia incorrecta, consecuencia → WorldState (M21), recompensa diario → M55, señal `quest_started` (M07) | M21, M55, M07, M14 |
| D | Entrega con inventario: rechazo sin objeto + avance con objeto (consume del inventario) | M14, M21 |
| E | Ocultas: invisibles en `cadenas_disponibles()` hasta iniciarse | — |
| F | Postgame: bloqueada sin final de M22 y abierta tras **cada uno de los 4 finales** (principal/regresar/guardian/secreto), con estado limpio por iteración | M22 |
| G | Persistencia: snapshot `activas`+`completadas`, round-trip, purga de huérfanas | M59 |

### Guarda anti-falso-verde (obligatoria, iter. 2)

1. `_check()` cuenta cada verificación (`_checks`).
2. `_fin("X")` por bloque + lista `BLOQUES`: el resumen nombra el bloque que no corrió.
3. `CHECKS_MINIMOS` = **40**, MEDIDO en verde el 2026-10-21 (no estimado).
4. `_summary()` en un `call_deferred` **separado** del de `_run()`: si `_run()` aborta
   por un `SCRIPT ERROR` de runtime, el resumen corre igual, nombra los bloques
   faltantes, dispara el piso y sale con `quit(1)` — la suite **no cuelga**.
5. Guardián probado EN ROJO por inyección de runtime (`var _n: Node = null; _n.free()`
   tras el bloque B): EXIT 1, nombra C/D/E/F/G, «solo 11 checks (mínimo 40)». Sonda
   borrada; 0 sondas en el repo.

## Regresiones de integración (módulos que M23 toca)

| Suite | Motivo |
|---|---|
| `scripts/historia/test_historia.gd` (M22) | el bloque F usa el grafo y `final_elegido` de M22 |
| `scripts/diario/test_diario.gd` (M55) | recompensa `diario` → registro `mision_{cadena_id}` |
| `scripts/progresion/test_progresion.gd` (M71) | señal `quest_updated` de cosméticos |
| `scripts/saving/validate_save.gd` (M59) | sección `secondary_stories` del snapshot |

## Casos que quedan fuera (honestidad)

- E2E de 10 cadenas completas: el catálogo tiene 4 (ítem de checklist `[ ]` honesto).
- Contenido narrativo, capítulos de diario (`capitulo-*` no existen en el catálogo
  M55), cosméticos y consecuencias visuales: dueños de contenido/M53/M45/M17/M18/M27.
- Variaciones de postgame *por tipo de final* (variantes narrativas): el gate
  implementado es binario (final elegido sí/no); la variación es de M22/contenido.
