# Log 1453: T-M112 extra 2 — quitados los 2 `|| true` del job lint de testing.yml; ambos pasos eran inaptos para CI → BUG-122 delegado (M111/M118)

**Fecha:** 2026-10-08
**Hora:** 02:30
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Encargo del director (msg 61, 2026-10-08): acepta el fix del paso `Run tests`
(msg 59/60) y **amplía la autorización a todo `testing.yml`**: quitar los 2
`|| true` restantes del job `lint` (`Check formatting` y `Run static analysis`),
verificar que los pasos quedan honestos, y si alguno no es apto para CI **no
excluirlo** sino reportarlo para derivarlo a M118/M111.

## Cambios realizados

- `.github/workflows/testing.yml` → job `lint`:
  - `godot --headless --check-only 2>&1 || true` → **sin `|| true`**.
  - `godot --headless --script res://scripts/editor/code_quality_check.gd 2>&1 || true`
    → **sin `|| true`**.
  - Comentario YAML documentando los 2 defectos, la medición y la decisión de
    dejar los pasos **honestos pero rotos a la vista** (sin tocarlos, sin
    excluirlos — indicación explícita del encargo).
- **`testing.yml` queda con 0 ocurrencias de `|| true`** (antes: 3 operativas
  + 2 en comentarios). YAML válido (`yaml.safe_load`: 3 jobs).

## Diagnóstico de honestidad de los 2 pasos (medido en local, 2026-10-08 02:23)

| Paso | Comando | Resultado medido | Causa |
|---|---|---|---|
| `Check formatting` | `godot --headless --check-only` | **COLGADO** (>45 s, proceso matado) — arranca el juego completo (Bootstrap, servicios, VillagerManager) y no termina | `--check-only` solo tiene sentido con `--script`; suelto no valida nada. En CI colgaría hasta `timeout-minutes: 10` en cada push |
| `Run static analysis` | `godot --headless --script res://scripts/editor/code_quality_check.gd` | **FALLA SIEMPRE** con 2 ERROR: `Class 'EditorScript' can only be instantiated by editor` + `Can't load the script ... doesn't inherit from SceneTree or MainLoop` | El checker es un EditorScript no invocable en `--headless --script`; **nunca corrió en CI** (el `|| true` tragaba el error) |

Conclusión: ambos pasos **no son aptos para CI tal como están** → cláusula 3 del
encargo: **no se excluyeron ni arreglaron**; quedan honestos y el caso quedó
registrado para que el equipo decida.

## Registro en 11-BUGS

**BUG-122** (§6, Bugs Abiertos) con estado `[ ]` delegado a **M118** (decisión
del paso `Check formatting`) y **M111** (hacer apto `code_quality_check.gd` o
retirarlo), con comandos, salida exacta, causas y la decisión de dejar el CI
lint rojo-visible mientras tanto (filosofía "rojo-honesto > verde-falso" de los
msgs 59/61). Relación: par directo de BUG-120 (mismo archivo, mismo patrón).

## Evidencia

- Diff del job `lint`: 2 líneas cambiadas (`|| true` eliminado) + comentario.
- `yaml.safe_load` OK; conteo de `|| true` en `steps` de `test` + `lint` = **0**.
- Logs de medición: `check-only` colgado (>45 s) y `code_quality_check.gd` con
  los 2 ERROR estructurales (mismos en cada corrida).
- No se ejecutó GH Actions (no corresponde acá).

## Archivos modificados/creados

- `.github/workflows/testing.yml` (job lint sin `|| true` + comentario)
- `DOCUMENTACION/11-BUGS.md` → **BUG-122** (§6; archivo M con contenido de
  otros agentes → no se indexó, Trampa 114)
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md`
- `Mensajes entre modelos/mimo-v2.6-flash-free/62-…` (informe de cierre)
- `Logs/NUMEROS_DISPONIBLES.txt` (reserva 1453)

## Reglas

Sin commit ni push (staging selectivo). `quality.yml` intocado. No se excluyó
ni modificó ningún paso, script ni suite (M111/M118 son dueños de la decisión
de fix). `interaction_manager`, `service_registry`, `bootstrap`, `main_island`
y CHECKLIST-GLOBAL no tocados.
