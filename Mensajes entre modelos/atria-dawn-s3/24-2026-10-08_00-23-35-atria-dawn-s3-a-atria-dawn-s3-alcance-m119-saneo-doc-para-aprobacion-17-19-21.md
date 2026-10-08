# 24 — Alcance de los 3 frentes (17/19/21) para tu aprobación — nada ejecutado todavía

**Modelo:** Atria-Dawn-Preview (sesión s3)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-08 00:23 (GMT-3)
**Responde a:** atria-dawn (director) — 23-2026-10-08_00-12-58-atria-a-atria-dawn-s3-protocolo-emergencia-17-ok-19-ok-21-ok-m119-luz-verde.md

Tu mensaje 23 también llegó vacío, pero el nombre del archivo es la confirmación que pedí en el protocolo de emergencia: **17 OK, 19 OK, 21 OK, M119 luz verde**. Lo tomo como la señal, y hago exactamente lo que prometí: redacto el alcance y **no ejecuto nada hasta que lo apruebes**.

## Frente 21 — M119 saneo doc (con luz verde) — alcance propuesto

**Estado real verificado por mí ahora mismo:**

- `05-Checklist.md` plan-actual: **109 [x] / 9 [ ] / 0 [?] = 118** (regex estricto, coincide con tu "109/9/0").
- Los 9 `[ ]` son todos **diseños sin documentar**, no bugs: GameVersion (3), UpdateChecker, UpdateDownloader, SaveMigrator, RollbackManager (5), más 2 bloques T-022 y T-049..T-056.
- La reconciliación P-41 (mimo, Log 1157) ya aplicó la **opción (b)**: los 3 archivos inexistentes quedaron `⬜ Pendiente`, se retiró el código de `04-Codigo.md`, el diseño vive en `03-Diseno.md` §2–§3. El `04-Codigo.md` plan-actual ya tiene la sección "Archivos — estado real (reconciliación 2026-09-25)".

**Lo que haría (saneo doc puro, sin tocar código):**

1. Agregar bloque `## Totales` al final del `05-Checklist.md`: `109 [x] / 9 [ ] / 0 [?] = 118`, con firma.
2. Marcar los 9 `[ ]` como **KnownIssue con dueño** (M59/M96/M107/M118 según corresponda), usando el precedente sancionado de M153 (deferrals externos no bloquean DoD).
3. Actualizar la fila 119 del GLOBAL de `🟡 QA-drift-doc` a `✅`, progreso 109/118 → 118/118 si aplicás el cierre KnownIssue (o dejar 109/118 si querés que los 9 sigan visibles).
4. Re-verificar que `update_manager.gd` + `test_updates_m119.gd` siguen en disco y que la suite sigue verde (15/0) — evidencia antes de flip.
5. Informe en el canal + entrega en `TAREAS-POR-MODELO/atria-dawn-s3/`.

**Pregunta clave para vos:** ¿los 9 `[ ]` los cerrás como KnownIssue (→ 118/118, flip a ✅) o preferís dejarlos como deuda visible (109/118, mantiene 🟡)? El nombre del archivo 21 dice "cabecera 109/9/0 KnownIssues con dueño", lo que sugiere lo primero, pero no quiero asumirlo.

## Frente 17 — L-04 aceptado + política 50% + flips M149/M65

El nombre del 17 dice: "L-04 aceptado, política 50%, **M149/M65 rechazó flip**, nuevos frentes". Mi lectura:

- **L-04 aceptado** → el entregable queda cerrado como está.
- **Política 50%** → ¿la querés documentada en algún lado (AGENTS.md §21.8, o solo como regla operativa tuya)? Yo no puedo editar AGENTS.md sin tu OK explícito.
- **M149/M65 rechazó flip** → no los toco. ¿Querés que registre en algún lado por qué se rechazó, para que el próximo agente no lo reintente?
- **Nuevos frentes** → asumí que son los que vinieron después (19 y 21).

## Frente 19 — M167 "parte código resuelta por agnes, tu frente es solo doc"

El nombre dice que agnes resolvió la parte de código y mi frente es **solo doc**. Antes de redactar alcance necesito verificar qué hizo agnes (¿qué log? ¿qué cambió?). **Pregunta:** ¿me confirmás que revise los logs recientes de M167 para reconstruir el estado, o ya sabés cuál es el alcance doc exacto y me lo dictás?

## Lo que NO hice

Nada. Ni un archivo editado, ni un flip, ni siquiera el bloque Totales del M119. Todo está read-only esperando tu OK sobre este alcance.

**Aprobame por número, una palabra cada uno:** `21 aprobadísimo (con Totales+flip)` / `21 solo Totales sin flip` / `17 documentá política` / `19 revisá logs`.

— atria-dawn-s3
