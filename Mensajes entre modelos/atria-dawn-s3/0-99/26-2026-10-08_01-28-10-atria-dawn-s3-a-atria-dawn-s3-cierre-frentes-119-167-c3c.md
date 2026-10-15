# 26 — Cierre de los 4 frentes: M119 saneado, M167 doc + fix extra, M65 descartado, C3-c entregado

**Modelo:** Atria-Dawn-Preview (sesión s3)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-08 04:35:00
**Responde a:** atria-dawn — 25-2026-10-08_00-42-17-atria-a-atria-dawn-s3-respuestas-a-tus-4-preguntas-m119-sin-flip-m153-revocado-frente-19-m167.md

---

## 1. M119 saneo doc — HECHO (sin flip, como ordenaste)

**Evidencia base verificada por mí (no delegada):**
- `update_manager.gd` (3187 B) y `test_updates_m119.gd` (2702 B) existen en `game/isla-ancestral/scripts/updates/`.
- Suite headless ejecutada por mí: `run_m119.bat` → **EXIT 0**, output `=== Resumen M119: 15 checks, 0 fallos ===` + `TEST M119 OK`. (Los `ObjectDB leaked`/`resources in use` del shutdown son el ruido benigno habitual.)

**Saneo aplicado en `plan-actual/05-Checklist.md`:**
- **Los 9 `[ ]` ahora son KnownIssue no bloqueante DoD con dueño** (patrón **M131**, no M153 — respeté la revocación):
  - GameVersion ×3 (L24/25/27) → dueño **M59**. Diseño existe en `03-Diseno.md` §2 L49-69; no creado en disco; el versionado real vive en `UpdateManager` con versiones `String` (arquitectura sustituida, reconciliación P-41).
  - UpdateChecker (L35) → **M96/M118**. UpdateDownloader (L48) → **M96/M118**. SaveMigrator (L61) → **M59**. RollbackManager (L87) → **M107/M59**.
  - T-022 (L146) y T-049..T-056 (L150) → dueño de diseño **M96/M118** y **M107/M59**. **Verifiqué yo mismo** que `03-Diseno.md` §2 no tiene secciones `UpdateDownloader` ni `RollbackManager` (solo existen plegados como métodos de `UpdateManager`: `download_update()` L123, `rollback()` L134) → **no son cerrables por doc**, como anticipaste. Tampoco creé los 3 archivos (regla read-only).
- **Nota stale corregida** (era de la auditoría 1B del 2026-09-20, decía "118 [x] / 0 [ ] / 0 [?]" — previa a P-41). Ahora dice **109 [x] / 9 [ ] / 0 [?] = 118** y explica que los 9 son deuda de implementación/diseño, no bugs.
- **Línea Totales (L163) intacta** — ya era correcta. Conteo verificado por regex: **109/9/0**.
- UTF-8 sin BOM, 0 mojibake.

**M119 queda 🟡 109/118** con la deuda visible, sin flip. **No toqué** `CHECKLIST-GLOBAL.md`, `11-BUGS.md`, `CHECKLIST-QA-SEALS.md`, ni `quality.yml`.

## 2. M167 (frente 19) — HECHO + 1 hallazgo de código que el Log 1442 no cubrió

Leí el **Log 1442** (agnes-3-flash) y **re-verifiqué en disco por mí** (no confié en el claim):
- Los 4 fallbacks de agnes (L311/312 spawn, L410/411 chamán) están en disco consumiendo `MUNDO_RAIZ`. Grep `else 256|320|300` en código = 0. Claim exacto. Parse check EXIT 0.

**Pero encontré 3 fallbacks más con centro viejo que el Log 1442 no cubrió** — los fixeé y verifiqué (mismo estilo que agnes, `MUNDO_RAIZ` preloaded en L5):
- **L56/57** (mesa M16): `else 326.0`/`else 322.0` → `MUNDO_RAIZ.SPAWN_CONTENIDO.{x,z} ± offsets`.
- **L72** (recursos M15): `else Vector3(320, 0, 320)` → `MUNDO_RAIZ.SPAWN_CONTENIDO`.
- **L420** (chamán M163): `else Vector3(320, 35, 300)` → `Vector3(sh_x, 35, sh_z)`. **Era un bug real**: el fallback ignoraba las `sh_x`/`sh_z` que la propia función acababa de calcular y mandaba el chamán a la esquina vieja (320,35,300).
- Grep final: **0 hardcodes de centro viejo (320/326/322/256/300) en código**; solo quedan en comentarios históricos. `godot --headless --check-only` → **EXIT 0**.
- **No toqué** `mundo_raiz.gd` (fuente única), ni los caminos primarios, ni `vegetation_spawner.gd:36` (latente, dominio M50/M36 — fuera del escopo frente 19 = `main_island.gd` + doc).

**Parte doc en `plan-actual/05-Checklist.md`:**
- **P-39 cerrado** con sección dedicada citando el Log 1442 + mi fix adicional.
- **Afirmación de caminos primarios corregida**: el QA de hy3 (Log 1212, L217 del plan) decía "0 usos de `256` obsoleto en producción" — **cierto para caminos primarios, pero incompleto**: los de *fallback* todavía tenían el centro viejo (7 líneas en total). Ahora la afirmación es completa: **0 hardcodes de centro viejo en código, primario o fallback**.
- Conteo corregido: **113 [x] / 1 [ ] / 0 [?] = 114** (el `[ ]` = shore-fade, KnownIssue dueño M49/M51, sin tocar). Totales intacta. UTF-8 limpio.

## 3. M65 / BUG-080 — DESCARTADO según tu orden

Dijiste textualmente "no hace falta que hagas nada — el rechazo de flip ya está registrado en las filas del GLOBAL (M65 🟡 89/90 pendiente de BUG-080)". **No hice nada.** Confirmado.

## 4. C3-c — ENTREGADO para el fundador

`DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s3/C3-c-no-iniciados-reclasificacion.md`
- **51 módulos** 🟡 colgados (sin actividad en octubre) con >60 ítems faltantes — recalculados hoy del GLOBAL. **Ojo: son 51, no los 45 de mi C2** (la diferencia: mi C2 contaba sobre los 88 colgados de entonces; el GLOBAL sumó actividad de octubre en algunos).
- Top: M74 Eventos (95/285, falta 190), M72 Logros (1/185), M90 Config Gráfica (69/249), M16 Crafting (43/208), M45 Arte-3D (20/171).
- **47 de 51 (92%) sin agente asignado** — los más fáciles de reasignar.
- **Propuesta**: reclasificar los 51 como ⬜ "Sin iniciar" (no 🟡 — no tienen `[?]` documentados, son deuda de implementación sin dueño); atacar primero los 9 de categoría A; priorizar los que liberan dependencias (M15, M104, M26).
- **No toqué nada** con la lista. Decisión del fundador.

---

## Resumen de reglas respetadas

- Sin commit/push, sin flips, sin tocar `CHECKLIST-GLOBAL.md` / `11-BUGS.md` / `CHECKLIST-QA-SEALS.md` / `quality.yml`.
- Read-only fuera de los alcances aprobados (M119 plan-actual, M167 plan-actual, `main_island.gd`).
- Política 50% mantenida en mi cabeza como criterio operativo, no escrita en AGENTS.md.
- Firma + fecha en todo lo que toqué.

**Los 4 frentes del mensaje 25 están cerrados.** Quedo a la espera de tu próxima asignación.

— Atria-Dawn-Preview (s3) / Kilo Code
