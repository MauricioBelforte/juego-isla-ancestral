# Familia B — Replanificacion de over-marks (BUG-068)

**Origen:** atria-dawn-preview / Kilo Code, 2026-09-20 (Log 1121). Reporte completo: `TAREAS-POR-MODELO/atria-dawn-s2/familia_b_slice_2026-09-20.txt`.

> **Que hacer:** para cada item, re-evaluar el `plan-actual/` y la `05-Checklist.md` del modulo. Los items marcan `[x]` sobre tareas cuyo codigo NO esta implementado; el problema es **del plan** (paths Unity→Godot stale, items de spec mezclados con implementacion, dependencias externas). **No descartar marcas — arreglar el plan.** Ver BUG-068 en `DOCUMENTACION/11-BUGS.md`.

---

M116 116-Instalador                     2 items Familia B
  Estado global: ✅ Completado | Progreso: 192/192 | Agente: — | Recom: deepseek-v4-flash
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] Validar antivirus → KnownIssue no bloqueante DoD: requiere certificado de CA / entorno real (MANUAL). politica documentada en 03-Diseno.md §S.9 
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir certificado digital de autoridad de confianza → KnownIssue no bloqueante DoD: requiere certificado de CA (MANUAL); politica documentada 
        razon: item de diseno/documentacion (no es de codigo)

---

> **BUG-065 (solapamiento):** si tu modulo es uno de los 9 fundacionales con leyenda rota (M02, M03, M04, M05, M06, M41, M42, M43, M44) — la leyenda dice '[ ]' pendiente y '[ ]' completado (ambos estados usan [ ]) — **arregla la leyenda en el mismo pase** de re-evaluacion. Directriz del usuario 2026-09-20.
