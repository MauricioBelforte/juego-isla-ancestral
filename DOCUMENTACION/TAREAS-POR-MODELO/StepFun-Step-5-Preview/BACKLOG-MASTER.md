# Backlog Master — StepFun-Step-5-Preview

> **Estado:** 🔵 EN CURSO (alta 2026-10-10, sesión s3) — funcional directo, prioridad del director
> **Sesión:** `ses_ee2159967ffeZWsqhZj75LT4xF`
> **Rol:** Auditoría anti-inflación + QA §21.8 con sondas rojas. **El ejecutor más fiable de la flota.**

## Identidad

- **Modelo:** StepFun Step 5 Preview (StepFun AI / StepFunZ AI)
- **Plataforma:** Kilo Code (canal `Mensajes entre modelos/StepFun-Step-5-Preview/`)
- **Alta en la guía:** 2026-10-10, sección §21.17 de `10-GUIA-COMPARATIVA-MODELOS.md`
- **Regla de entrega:** **NUNCA por Agent Manager** (el reply falla). Siempre por canal con
  `python scripts/reservar_mensaje.py StepFun-Step-5-Preview "<tema>" --emisor StepFun-Step-5-Preview`

## Historial verificado (18 entregas consecutivas sin error)

| Encargo | Resultado | Verificado por |
|---|---|---|
| Triaje E-12d M110-Debug-Menu (5 bloques, 89 ítems) | **0 errores de conteo**, 90 `[?]` → 0 | s3 (QA §21.8, 115 checks 0 fallos) |
| QA §21.8 M24-Templos-Y-Puzzles | 126/1/1, 14 ítems muestreados, 3 suites binario real → **SELLADO** | director msg 32 + s3 (re-corrió `test_puzzles.gd`, 0 fallos) |
| BUG E-10 (M50 spawner leak) | cerrado; refutó su propia hipótesis con instrumentación | s3 re-verificación |
| BUG E-11, E-12b/c | cerrados | s3 |
| BUG-034 bloque 1 (19 filas sellos Hy3) | 19 VÁLIDAS / 6 DÉBILES / 0 INVÁLIDAS | msg 35 |
| BUG-034 bloque 2 | **EN CURSO** (54+26 filas, sub-bloques ~18-20) | — |

**Comportamiento clave:** honestidad que se auto-regula (ofrió bajar su propio `[x]` en L268),
corrige al director con evidencia (midió el archivo antes de aceptar el encargo), distingue
inflación de drift (M24 L229).

## Tareas

### En curso

- [x] **BUG-034 bloque 2** (CERRADO 2026-10-13, msg 255: 83 filas auditadas, 0 violaciones §21.8.4; el registro de hy3 está sano) — 54+26 filas de sellos §21.8 de Hy3 en `CHECKLIST-QA-SEALS.md`.
      Sub-bloques de ~18-20. ⚠️ Hy3 verificó módulos que él mismo implementó → marcar cada
      violación de la regla de independencia §21.8.4. (Delegada por el director, msg 36.)

### En cola (delegadas)

- [x] **S1 — Auditoría anti-inflación de M48-Animacion** (CERRADO 2026-10-13, msg 256: M48 honesto en 9/123, 9/9 [x] respaldados en disco, 2 suites verdes 8/0 y 12/0, 0 inflación. NOTA: la advertencia de que el núcleo no existía era del LOTE 9 de BUG-070, previo a mi Fase 1 del Log 1603) (delegada, director msg 159). Prioridad 1
      de la flota. M48 declara 9/123 pero el LOTE 9 de BUG-070 verificó que su núcleo **no existe
      en disco** (`validate_animation.gd`, `jugador_lib.tres`, `npc_humanoide_lib.tres`, 0 hits).
      Método E-12d: contar → verificar artefacto contra disco → clasificar binario. **READ-ONLY
      absoluto** (el director aplica los flips). Entra al terminar BUG-034 sub-bloque 2C. M48
      subido a 🔴 en `CHECKLIST-GLOBAL.md`.

### Pendientes (sugeridos por s3, sin delegar)

- [x] **S2 — QA §21.8 de M53-UI-UX** (CERRADO 2026-10-12, msg 242: 143→144/165, 17 ítems muestreados, 4 suites verdes, BUG-133 resuelto; 1 ítem inflado detectado y 2 falsos negativos) (cuello de botella #1: 11 módulos lo esperan, 🟡 139/165).
      Independencia ✓ (lo trabajaron Hy4 y glm-5.3-flash, ambos inactivos).
- [x] **S4 — Barrido de inflación en módulos ⬜/🟢 sin tocar** (CERRADO 2026-10-12, msg 246: M01/M02/M98/M99 barridos, 2 drift de Totales, M99 violaba DoD y fue bajado de ✅) (M01 0/152, M02 0/172, M98, M99).
      Su precisión de conteo los dejaría honestos de una pasada.

## Límites (regla de independencia §21.8)

- **No puede verificar módulos que él mismo triaje.** Si hace el triaje, la QA la hace otro (s3 o
  Hy3).
- **Sin evidencia de arquitectura visual / escenas 3D.** Su nicho es auditoría y verificación.
- **Sin evidencia de implementación nueva.** Hizo triaje y QA, no codeó módulos desde cero.

## Reglas del protocolo

1. `AGENTS.md` (raíz) — la regla maestra.
2. Trabajás desde este backlog. NO vayas a `CHECKLIST-GLOBAL.md` a buscar trabajo.
3. Marcado: `[ ]` pendiente · `[→]` en progreso · `[x]` completado · `[?]` no resuelto.
4. Al completar, marcar los TRES lugares: este backlog + `05-Checklist.md` del módulo +
   `CHECKLIST-GLOBAL.md`.
5. **Un `[?]` vale más que un `[x]` falso.** Sin excepciones.

## Registro de logs reservados

- [x] Log creado: **1768** — BUG-098, 2 archivos con parseo roto corregidos (renumerado desde 1690 el 2026-10-12 por colisión de número, orden del director mimo msg 215; el 1690 original quedó para Ling 3.1 Flash).
