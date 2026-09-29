# Familia B — Replanificacion de over-marks (BUG-068)

**Origen:** atria-dawn-preview / Kilo Code, 2026-09-20 (Log 1121). Reporte completo: `TAREAS-POR-MODELO/atria-dawn-s2/familia_b_slice_2026-09-20.txt`.

> **Que hacer:** para cada item, re-evaluar el `plan-actual/` y la `05-Checklist.md` del modulo. Los items marcan `[x]` sobre tareas cuyo codigo NO esta implementado; el problema es **del plan** (paths Unity→Godot stale, items de spec mezclados con implementacion, dependencias externas). **No descartar marcas — arreglar el plan.** Ver BUG-068 en `DOCUMENTACION/11-BUGS.md`.

---

M32  32-Clima                           14 items Familia B
  Estado global: ✅ Completado | Progreso: 121/121 | Agente: 2026-09-16 21:15 | Recom: —
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] Densidad por calidad grafica (M90) — M90 sin implementar → KnownIssue no bloqueante DoD: especificacion documentada en 03-Diseno.md §2.3; M90 Ha
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Presupuesto ≤ 1 ms GPU pico (M61) — profiling con dueño M61 → KnownIssue no bloqueante DoD: budget documentado en 03-Diseno.md §2.4 (≤1ms GPU bu
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] M36 Fauna: spawns condicionados → KnownIssue no bloqueante DoD: integracion M36 clima documentada en 03-Diseno.md §2.6 (fauna spawn by weather c
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] M50 Vegetación: sway por intensidad → KnownIssue no bloqueante DoD: integracion documentada en 03-Diseno.md §2.7 (vegetation wind sway by climat
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] M51 Agua: ondas por clima → KnownIssue no bloqueante DoD: integracion documentada en 03-Diseno.md §2.8 (water waves by climate); M51 V2. Spec do
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] M30 UI: banner + aviso 1 dia antes → KnownIssue no bloqueante DoD: dato existe (clima_de_manana() probado en test_clima L139-141); UI banner req
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] M08 Voxel: cubierta de nieve visual → KnownIssue no bloqueante DoD: integracion documentada en 03-Diseno.md §2.9 (snow cover visual); M08/M51 V2
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Eventos registrables en diario M55 → KnownIssue no bloqueante DoD: integracion documentada en 03-Diseno.md §2.11 (weather events journal logging
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Aviso de tormenta 1 dia antes (UI) → KnownIssue no bloqueante DoD: dato listo (clima_de_manana()); UI con dueño M30/M53. Spec documented.
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] Opción "Reducir clima" (densidad -50%) → KnownIssue no bloqueante DoD: opcion documentada en 03-Diseno.md §2.12 (climate density reduction optio
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Opción "Sin truenos" (fotosensibilidad) → KnownIssue no bloqueante DoD: accesibilidad documentada en 03-Diseno.md §2.13 (no-thunder option for p
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Opción "Niebla reducida" (visual 80%) → KnownIssue no bloqueante DoD: accesibilidad documentada en 03-Diseno.md §2.14 (reduced fog option 80%); 
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Banner siempre con texto (nunca solo imagen) → KnownIssue no bloqueante DoD: politica documentada en 03-Diseno.md §2.15 (text-always banner rule
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Test: aviso de tormenta con 1 dia de anticipación → KnownIssue no bloqueante DoD: protocolo disenado en 03-Diseno.md §2.16 (storm warning test);
        razon: item de diseno/documentacion (no es de codigo)

---

M93  93-Balance                         18 items Familia B
  Estado global: 🟡 Con dudas (revertido) | Progreso: 131/134 | Agente: — | Recom: GLM-5.3 Flash
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] Definir salida: AO total, recursos por pipeline, desvío vs. diseño [M] — KnownIssue no bloqueante DoD: ídem O.1; requiere simulacion. Design doc
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir API de precios consumida por M39 (tiendas) [M] — agnes-2.5-flash 2026-09-12: API EXPUESTA (get_price/get_sell_price/es_item_historia);Kn
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir evento de compra con ítem y precio [M] — KnownIssue no bloqueante DoD: ídem M105/M38; el evento existiria en el flujo de venta de M38 → 
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir evento de venta con ítem y precio [M] — KnownIssue no bloqueante DoD: ídem M38/M105. Diseñado.
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir métrica de % de jugadores que mantienen rutina semana 1 [M] — KnownIssue no bloqueante DoD: requiere telemetría agregada M105 post-fase-
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir alerta de desvío > 20% vs simulación [M] — KnownIssue no bloqueante DoD: depende de la simulacion (O) + telemetria (S) → fase jugable, M
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir sesión de playtest específica de economía (wallets y rutina) [M] — KnownIssue no bloqueante DoD: M114 (Playtest) fase jugable; el protoc
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir encuesta de percepción de precios (barato/justo/caro) [S] — KnownIssue no bloqueante DoD: ídem M114 (juega gente real). Encuesta disenad
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir comparación percepción vs. simulación [M] — KnownIssue no bloqueante DoD: depende de S (telemetria) + O (simulacion) + playtest → fase j
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir plan de ajuste post-playtest (quién decide y cuándo) [M] — KnownIssue no bloqueante DoD: ídem M114; la regla de bump de version (U.3) ya
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Probar jugador que vende todo (economía estable) [M] — KnownIssue no bloqueante DoD: requiere simulacion dinámica (O) o playtest; el tope de ven
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] Probar jugador que no vende nada (almacenamiento M14 sin penalización) [M] — KnownIssue no bloqueante DoD: ídem; M14 inventario no penaliza por 
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] Definir test de simulación 365 días rutinario [C] — KnownIssue no bloqueante DoD: depende de O (simulate_economy) → iter futura o fase jugable. 
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir feedback de compra con precio claro en UI (M53) [S] — KnownIssue no bloqueante DoD: dueño M53 (UI/UX); los datos de precio están expuest
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir aviso de "descuento de evento" cuando aplique (M74) [S] — KnownIssue no bloqueante DoD: dueño M74 (Eventos) + M53; quests.json bonus_eve
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir que la escasez se comunique sin ansiedad (M94) [M] — KnownIssue no bloqueante DoD: dueño M94/M53; las REGLAS de no-escasez ya están en 0
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir tipografía de precios legible (M88) [S] — KnownIssue no bloqueante DoD: dueño M88 (Localización) + M53. Deferred a M88/M53.
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Definir sonido de moneda/compra coherente con el valor (M43/M44) [S] — KnownIssue no bloqueante DoD: dueño M43/M44 (ASMR/Feedback sonoro); M42 t
        razon: item de diseno/documentacion (no es de codigo)

---

M118 118-CI-CD                          4 items Familia B
  Estado global: ✅ Completado | Progreso: 106/106 | Agente: — | Recom: —
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] P5: despliegue a itch.io al crear tag semver [S] -- agnes-2.5-flash 2026-09-12: workflow disenado en 03-Diseno.md §2.5 (itch.io deploy); requier
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Subida a Itch.io (manual trigger) [S] -- agnes-2.5-flash 2026-09-12: workflow disenado en 03-Diseno.md §3.10 (itch.io manual deploy); requiere B
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Email a stakeholders en tags [S] -- agnes-2.5-flash 2026-09-12: politica disenada en 03-Diseno.md §3.9 (stakeholder notifications); requiere con
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Validación en GitHub Actions real (requiere push; la action firebelley v5.2.1 puede necesitar actualización) [S] -- agnes-2.5-flash 2026-09-12: 
        razon: item de diseno/documentacion (no es de codigo)

---

M145 145-Diseno-De-Experiencia          9 items Familia B
  Estado global: ✅ Completado | Progreso: 105/105 | Agente: ? | Recom: GLM-5.3 Flash
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] Testear onboarding con jugadores nuevos → KnownIssue no bloqueante DoD: requiere build jugable; planificado en plan-testing S1 (M138+). Experien
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Iterar segun feedback de testing → idem; ejecutara tras S1 → KnownIssue no bloqueante DoD — feedback collection requiere jugadores reales. Exper
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] Testear navegacion con jugadores → requiere build; plan-testing S2 (M138) → KnownIssue no bloqueante DoD. Navegacion disenada en 03-Diseno.md.
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Iterar segun feedback → idem → KnownIssue no bloqueante DoD.
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] Testear feedback con jugadores → requiere build; plan-testing S3 (M139). KnownIssue no bloqueante DoD.
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] Testear con herramientas de accesibilidad → requiere build; programado M141/M142 (§3). KnownIssue no bloqueante DoD.
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] Testear ritmo con jugadores → requiere build; plan-testing S3 (M139). KnownIssue no bloqueante DoD.
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] Recolectar feedback cualitativo → requiere sesion real con jugadores (S1-S5). KnownIssue no bloqueante DoD.
        razon: item de proceso/validacion (no code artifact)
  - [ ] - [x] Iterar segun hallazgos → requiere hallazgos de las sesiones → KnownIssue no bloqueante DoD. Proces disenado en 03-Diseno.md §4.
        razon: item de diseno/documentacion (no es de codigo)

---

M146 146-Diseno-Emocional               10 items Familia B
  Estado global: ✅ Completado | Progreso: 100/100 | Agente: ? | Recom: GLM-5.3 Flash
  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + 05-Checklist.md (paths Unity→Godot stale, items de spec mezclados con implementacion). NO descartar marcas — arreglar el plan.
  - [ ] - [x] Design emocional requiere validacion con jugadores → KnownIssue no bloqueante DoD: diseño documentado en 03-Diseno.md + operativa/; validacion r
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Design emocional requiere validacion con jugadores → KnownIssue no bloqueante DoD: diseño documentado en 03-Diseno.md + operativa/; validacion r
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Design emocional requiere validacion con jugadores → KnownIssue no bloqueante DoD: diseño documentado en 03-Diseno.md + operativa/; validacion r
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Design emocional requiere validacion con jugadores → KnownIssue no bloqueante DoD: diseño documentado en 03-Diseno.md + operativa/; validacion r
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Design emocional requiere validacion con jugadores → KnownIssue no bloqueante DoD: diseño documentado en 03-Diseno.md + operativa/; validacion r
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Design emocional requiere validacion con jugadores → KnownIssue no bloqueante DoD: diseño documentado en 03-Diseno.md + operativa/; validacion r
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Design emocional requiere validacion con jugadores → KnownIssue no bloqueante DoD: diseño documentado en 03-Diseno.md + operativa/; validacion r
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Design emocional requiere validacion con jugadores → KnownIssue no bloqueante DoD: diseño documentado en 03-Diseno.md + operativa/; validacion r
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Design emocional requiere validacion con jugadores → KnownIssue no bloqueante DoD: diseño documentado en 03-Diseno.md + operativa/; validacion r
        razon: item de diseno/documentacion (no es de codigo)
  - [ ] - [x] Design emocional requiere validacion con jugadores → KnownIssue no bloqueante DoD: diseño documentado en 03-Diseno.md + operativa/; validacion r
        razon: item de diseno/documentacion (no es de codigo)

---

> **BUG-065 (solapamiento):** si tu modulo es uno de los 9 fundacionales con leyenda rota (M02, M03, M04, M05, M06, M41, M42, M43, M44) — la leyenda dice '[ ]' pendiente y '[ ]' completado (ambos estados usan [ ]) — **arregla la leyenda en el mismo pase** de re-evaluacion. Directriz del usuario 2026-09-20.
