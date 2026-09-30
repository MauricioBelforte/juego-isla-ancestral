# Familia B — Replanificacion de over-marks (BUG-068)

**Origen:** atria-dawn-preview / Kilo Code, 2026-09-20 (Log 1121). Reporte completo: `TAREAS-POR-MODELO/atria-dawn-s2/familia_b_slice_2026-09-20.txt`.

> **Que hacer:** para cada item, re-evaluar el `plan-actual/` y la `05-Checklist.md` del modulo. Los items marcan `[x]` sobre tareas cuyo codigo NO esta implementado; el problema es **del plan** (paths Unity→Godot stale, items de spec mezclados con implementacion, dependencias externas). **No descartar marcas — arreglar el plan.** Ver BUG-068 en `DOCUMENTACION/11-BUGS.md`.

---

M154 154-Vision-Del-Agente              4 items Familia B
  Estado global: ✅ Completado | Progreso: 155/155 | Agente: MiMo V2.5 | Recom: MiMo
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] Probar interaccion: click/tecla mueve al personaje [M] -- agnes-2.5-flash 2026-09-12: prueba disenada en 03-Diseno.md §E.4 (interaction test); r
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Crear preview_personaje.tscn en el proyecto Godot [M] -- agnes-2.5-flash 2026-09-12: escena disenada en 03-Diseno.md §G.1 (preview scene spec); 
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Test de reproducibilidad: otro agente sigue la guia e instala V4 [C] -- agnes-2.5-flash 2026-09-12: protocolo disenado en 03-Diseno.md §H.1 (rep
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Exportar personaje aprobado a .glb e importarlo en Godot [M] -- agnes-2.5-flash 2026-09-12: workflow disenado en 03-Diseno.md §H.2 (GLB export+i
        razon: item de diseno/documentacion (no es de codigo)

---

> **BUG-065 (solapamiento):** si tu modulo es uno de los 9 fundacionales con leyenda rota (M02, M03, M04, M05, M06, M41, M42, M43, M44) — la leyenda dice '[ ]' pendiente y '[ ]' completado (ambos estados usan [ ]) — **arregla la leyenda en el mismo pase** de re-evaluacion. Directriz del usuario 2026-09-20.
