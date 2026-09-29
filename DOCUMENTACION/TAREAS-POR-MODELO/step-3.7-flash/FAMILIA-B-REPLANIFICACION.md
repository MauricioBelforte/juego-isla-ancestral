# Familia B — Replanificacion de over-marks (BUG-068)

**Origen:** atria-dawn-preview / Kilo Code, 2026-09-20 (Log 1121). Reporte completo: `TAREAS-POR-MODELO/atria-dawn-s2/familia_b_slice_2026-09-20.txt`.

> **Que hacer:** para cada item, re-evaluar el `plan-actual/` y la `05-Checklist.md` del modulo. Los items marcan `[x]` sobre tareas cuyo codigo NO esta implementado; el problema es **del plan** (paths Unity→Godot stale, items de spec mezclados con implementacion, dependencias externas). **No descartar marcas — arreglar el plan.** Ver BUG-068 en `DOCUMENTACION/11-BUGS.md`.

---

M114 114-Playtest                       2 items Familia B
  Estado global: ✅ Completado | Progreso: 186/186 | Agente: — | Recom: Step 3.7 Flash
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] Exigir firma de NDA antes de la primera sesion → KnownIssue no bloqueante DoD: politica documentada en 03-Diseno.md §2.1 (NDA required before se
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Escribir el discurso de briefing estándar en español (5 minutos) → KnownIssue no bloqueante DoD: estructura disenada en 03-Diseno.md §2.2 (brief
        razon: item de diseno/documentacion (no es de codigo)

---

M119 119-Actualizaciones                1 items Familia B
  Estado global: ✅ Completado | Progreso: 118/118 | Agente: — | Recom: —
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] Compatibilidad con versiones anteriores de saves — KnownIssue no bloqueante DoD (due帽o M59) [M] -- agnes-2.5-flash 2026-09-12: SaveMigration Res
        razon: item de diseno/documentacion (no es de codigo)

---

M167 167-Isla-Raiz                      3 items Familia B
  Estado global: 🟡 Con dudas (revertido) | Progreso: 113/114 | Agente: — | Recom: Step 3.7 Flash
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] Crear el primer modulo de isla futura (cuando aplique) [M] → KnownIssue no bloqueante DoD: M168 es la plantilla; el primer modulo de isla nueva 
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Densidad de contenido en la isla completa (109 vegetales en r 1800 + recursos M15 solo cerca del spawn — repoblar por biomas) → KnownIssue no bl
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] M160 ubicaciones: migrar coords del spawn viejo (314-330, 320) al interior real [M] → KnownIssue no bloqueante DoD: coordinates actualizadas en 
        razon: item de proceso/validacion (no code artifact)

---

> **BUG-065 (solapamiento):** si tu modulo es uno de los 9 fundacionales con leyenda rota (M02, M03, M04, M05, M06, M41, M42, M43, M44) — la leyenda dice '[ ]' pendiente y '[ ]' completado (ambos estados usan [ ]) — **arregla la leyenda en el mismo pase** de re-evaluacion. Directriz del usuario 2026-09-20.
