# Log 1356: Bloque 1 de la auditoría de los 34 🟡 (T-D7) — M77/M45 degradados, M61/M04/M13 sustentados

**Fecha:** 2026-10-06
**Hora:** 05:00
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen

Ejecuté el **bloque 1** de la auditoría de los 34 módulos 🟡 de T-D7 que el coordinador (atria, mensaje 44) aprobó con dos condiciones: (1) método A = muestreo dirigido + verificación contra disco, priorizando los de mayor impacto y **saltando M59/M62** (DeepSeek T-D9 / s2 gdUnit4 en curso, regla §21.4); (2) reportar en el canal s2 por bloque. Bloque = **M61, M77, M45, M04, M13**.

Resultado: **153 `[x]` auditados, 6 degradados a `[?]` (falsos-cierres), 147 sustentados. Cero degradaciones injustificadas.**

## Cambios realizados

### M77-Online-Y-Red (4 `[x]` → 0 `[x]`, 4 `[?]`)
- Los 4 `[x]` citaban `mp_contract.json` / `net_contract.json` / `p2p=false` — **NINGÚNO existe en disco** (`*contract*.json` = ∅; `data/` sin net/online).
- Módulo bloqueado por producto (single-player v1, M77 BLOQUEADA). → 4 `[?]` honestas con nota de auditoría.
- `05-Checklist.md`: flippe `[x]`→`[?]` en las 4 líneas de contratos + Totales "Completados 0 / No resueltos 4" + nota de estado en la línea de conteo.
- GLOBAL fila 77: `4/130 → 0/130`.

### M45-Arte-3D (22 `[x]` → 20 `[x]`, 2 `[?]`)
- "Definir asset_catalog.json" y "Definir script validate_mesh.gd" → **ausentes en disco**.
- El arte SÍ existe (868 `.glb` + `data/arte3d/materiales_recursos.json`) → **NO degradé el arte**, solo los 2 ítems de gobernanza.
- `05-Checklist.md`: 2 `[?]` + Totales "Completados 20 / No resueltos 2".
- GLOBAL fila 45: `22/171 → 20/171`.

### M61-Rendimiento / M04-Game-Engine / M13-Herramientas: SUSTENTADOS
- **M61 (39):** `validate_budget.gd` + `bench_recorder.gd` + `scenes/bench_scene_a.tscn` + `data/performance/budgets.json` **con bloque `limites`** (particulas_simultaneas_max/objetos_mundo_max) — todo en disco.
- **M04 (14):** Input Map completo en `project.godot` (mover_norte/sur, interactuar, colocar, camara_zoom_in) + capas físicas + Bootstrap/Main.
- **M13 (84):** `test_herramientas.gd` **0 fallos** (EXIT 0); runtime "Hotbar inicial: 5 herramientas" + "ToolsSaveProvider registrado (sección herramientas_m13)".

### Corrección honesta durante el trabajo
- Primero medí `data/rendimiento/budgets.json` (sin bloque `limites`) y casi degradaba M61. Al verificar a fondo, el bloque `limites` vive en **`data/performance/budgets.json`** (no el de rendimiento). **M61 quedó íntegro** — no degradé por error.

## Archivos modificados/creados
- `CHECKLIST-GLOBAL.md` (filas 45/77 Progreso, byte-level, invariant EOL CRLF=230/CR=146/LF=2/NUL=0 intacto)
- `DOCUMENTACION/77-Online-Y-Red/plan-actual/05-Checklist.md`
- `DOCUMENTACION/45-Arte-3D/plan-actual/05-Checklist.md`
- `Mensajes entre modelos/atria-dawn-s2/46-...bloque-auditoria-5-amarillos-t-d7.md` (informe bloque 1)
- Commit: `99aa435`

## Nota técnica (trampa EOL)
Al escribir `CHECKLIST-GLOBAL.md` con `open(...,"w",newline="")` (texto) me normalizó a LF y rompió el invariant CRLF/CR-suelto. Lo restauré con `git checkout` + re-aplicación **byte-level** (`open("rb")`→`bytes.replace`→`open("wb")`), que NUNCA toca el EOL. **Regla: los archivos de EOL mixto de este proyecto (CHECKLIST-GLOBAL, y los 05-Checklist de M77/M45 que eran all-LF) se editan SIEMPRE a nivel de bytes.**

## Siguiente
Bloque 2 propuesto en s2/46: **M162, M164, M63, M26** (M59/M62 siguen bloqueados). Pendiente confirmación del coordinador.
