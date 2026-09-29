# Familia B — Replanificacion de over-marks (BUG-068)

**Origen:** atria-dawn-preview / Kilo Code, 2026-09-20 (Log 1121). Reporte completo: `TAREAS-POR-MODELO/atria-dawn-s2/familia_b_slice_2026-09-20.txt`.

> **Que hacer:** para cada item, re-evaluar el `plan-actual/` y la `05-Checklist.md` del modulo. Los items marcan `[x]` sobre tareas cuyo codigo NO esta implementado; el problema es **del plan** (paths Unity→Godot stale, items de spec mezclados con implementacion, dependencias externas). **No descartar marcas — arreglar el plan.** Ver BUG-068 en `DOCUMENTACION/11-BUGS.md`.

---

M36  36-Fauna                           8 items Familia B
  Estado global: 🟡 Con dudas (revertido) | Progreso: 226/228 | Agente: — | Recom: —
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] [M09] Caches de spawn por bioma [M] — KnownIssue no bloqueante DoD: dueño M09; implementacion deferred a spawner M09.
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] [M65] Movimiento real via NavigationServer3D evitando voxels [C] — KnownIssue no bloqueante DoD: dueño M65; movimiento basico ya opera. Avanzar 
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] [M45] Modelos/meshes de animales [C] — KnownIssue no bloqueante DoD: dueño M45; faunas funcionan con placeholders geometricos. Avanzar cuando M4
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] [M55/M37] UI de diario de fauna y museo [C] — KnownIssue no bloqueante DoD: dueño M55 (Diario) + M37 (Museo); datos de avistamientos existen en 
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] [M61] Presupuesto de simulacion de individuos (M65 ya define 40) [M] — KnownIssue no bloqueante DoD: dueño M61; budget definido (40 individuos).
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] [M61] Pool de nodos para evitar alloc/free por frame [C] — KnownIssue no bloqueante DoD: dueño M61; pool base de M62 existe. Deferred a M61 iter
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] Viñeta/tooltip de avistamiento en HUD (M53) [M] — KnownIssue no bloqueante DoD: dueño M53; datos de avistamientos existen. Avanzar cuando M53 te
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] Sonidos de fauna contextuales (M43) [M] — KnownIssue no bloqueante DoD: dueño M43; sistema SFXManager funciona. Avanzar cuando M43 tenga voces d
        razon: item de proceso/validacion (no code artifact)

---

M65  65-Animales-IA                     3 items Familia B
  Estado global: 🟡 Con dudas (revertido) | Progreso: 88/89 | Agente: — | Recom: deepseek-v4-flash-vision-exp
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] [M45] Modelos/meshes de animales [C] — KnownIssue no bloqueante DoD: dueño M45 (Arte-3D); animadores GLB pendientes de fase arte. Nucleo IA func
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] [M43] Sonidos contextuales de fauna [M] — KnownIssue no bloqueante DoD: dueño M43 (SFXManager); sistema de sonidos base existe. Avanzar cuando M
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] [M61] Pool de nodos para evitar alloc/free [C] — KnownIssue no bloqueante DoD: dueño M61 (Rendimiento); pool existe en M62 Memory pero no especi
        razon: item de proceso/validacion (no code artifact)

---

M94  94-Retencion-Sin-FOMO              1 items Familia B
  Estado global: ✅ Completado | Progreso: 138/138 | Agente: — | Recom: deepseek-v4-flash-vision-exp
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] Definir playtest de 5 usuarios: ¿sienten presión de volver? (M114) [M] -- agnes-2.5-flash 2026-09-12: protocolo disenado en 03-Diseno.md §20.3 (
        razon: item de diseno/documentacion (no es de codigo)

---

> **BUG-065 (solapamiento):** si tu modulo es uno de los 9 fundacionales con leyenda rota (M02, M03, M04, M05, M06, M41, M42, M43, M44) — la leyenda dice '[ ]' pendiente y '[ ]' completado (ambos estados usan [ ]) — **arregla la leyenda en el mismo pase** de re-evaluacion. Directriz del usuario 2026-09-20.
