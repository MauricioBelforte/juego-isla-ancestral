# 62 - 45 Implementables (Nemotron 320: M01 19 + M20 26)

**Creado por:** agnes-3-flash (directora) - 2026-11-25 11:00
**Nicho:** Root-cause + Volumen
**Tareas:** 15 (A 10 + B 5). NOTA 2026-11-25: el msg 150 dice "10 tareas" y "+10", pero el archivo tiene 15 casillas numeradas T62-01..T62-15. Se trabajan las 15; ver msg 152 y Log 2442.

## Contexto

Nemotron 320 (DOC-INT-4 = mensaje 320 de su canal) identifico 45 `[ ]` "implementables ahora" en M01 y M20. HY4 Flash no puede hacer code, PERO puede verificar en disco si cada uno ya esta implementado (grep/archivo) y proponer flip.

**Criterio aplicado (Log 2442):** flip de la casilla de ESTE backlog solo cuando existe el artefacto concreto en `game/isla-ancestral/` (excluido `.godot/`). Un modulo con scripts ajenos NO prueba el item citado; la spec en 03-Diseno NO es implementacion. No se tocaron checklists de modulo.

## A - M01 Fundamentos: 19 implementables (10)

- [x] T62-01: M12 Herramientas: verificar si existe en scripts/ — VERIFICADO 2026-11-25: `scripts/herramientas158/tool_tier_system.gd`, `scripts/herramientas158/jar_manager.gd`, `scripts/tools/tool_controller.gd` (13 archivos / 106 hits en `scripts/herramientas158` + `scripts/tools`).
- [x] T62-02: M16 Construccion: verificar — VERIFICADO: `scripts/construccion/build_manager.gd`, `construccion_mundo.gd`, `build_hud.gd`, `build_ghost.gd` (21 .gd en la carpeta; `build_manager` citado por `qa_m17_modo.gd:30`).
- [x] T62-03: M36 Museos: verificar — VERIFICADO: `scripts/museum/museum.gd`, `collection_registry.gd`, `donation_service.gd` + `scenes/museo/museum.tscn` (3 archivos / 6 hits directos).
- [x] T62-04: M39 Infraestructura: verificar — VERIFICADO: `scripts/core/test_infraestructura_m40.gd` (suite de flujo, 7 bloques, piso 60 checks) + autoloads `GameFlowManager`/`SceneManager` que ejercita; 109 archivos / 373 hits de muelle, puente, faro, plaza y farola en fuentes reales. NOTA: son M40 por el desplazamiento +1 del indice M01.
- [x] T62-05: M44 Arte-3D: verificar — VERIFICADO: `scripts/arte3d/materiales_recursos.gd` y `scripts/validadores/validador_autoloads.gd` (4 archivos / 85 hits). NOTA: `validate_mesh.gd` y `asset_catalog.json` siguen con 0 hits en todo el repo (deuda M44 documentada en b61; NO se flippeo esa deuda).
- [x] T62-06: M50 Agua: verificar — VERIFICADO: `scripts/world/agua_animada.gd`, `scripts/world/validate_water.gd`, `scripts/world/block_catalog.gd` (WATER=17) y `scripts/terrenos/terrain_detector.gd:217` (10 archivos / 34 hits).
- [x] T62-07: M58 Guardado: verificar — VERIFICADO: `scripts/saving/save_manager.gd`, `save_backup.gd`, `save_loader.gd`, `save_writer.gd`, `save_schema.gd` + 24 archivos con 69 hits de SaveManager/autosave.
- [x] T62-08: M66 Vehiculos: verificar — VERIFICADO: `scripts/vehiculos/vehicle_manager.gd` (autoload "Vehiculos"), `vehicle_controller.gd`, `vehicle_preset.gd`, `validate_vehicles.gd` (5 archivos / 13 hits).
- [x] T62-09: M68 Fast-Travel: verificar — VERIFICADO: `scripts/fasttravel/fast_travel_service.gd` (anclas data-driven), `fast_travel_effect.gd`, `test_fast_travel_headless.gd` (3 archivos / 9 hits). Quedan 3 `[?]` en la checklist propia de M69; no son parte de esta casilla.
- [x] T62-10: M108 Herramientas-Internas: verificar — VERIFICADO: `scripts/editor/tools/recipe_tool.gd`, `dialogos_auditor.gd`, `scripts/editor/plugin_herramientas.gd`, `scripts/tools/tool_controller.gd` (4 archivos / 7 hits). NOTA: `scenes/dialogo_ui.tscn` sigue ausente (deuda M21, b61); no se flippeo esa deuda.

## B - M20 Amistad: 26 implementables (5)

- [ ] T62-11: nombres de nivel (L30): verificar en data/ — PENDIENTE 2026-11-25: 0 hits exactos de `Conocido` / `Confidente` / `Mejor amigo` como terminos aislados en `scripts/` + `data/` (los 57 hits son `desconocido` o debug/logging). `data/amistad/amistad_config.tres` solo tiene `umbrales` y `recompensas_nivel`, sin tabla de nombres.
- [x] T62-12: acceso eventos por nivel min (L32): verificar — VERIFICADO: `scripts/eventos/condicion_evento.gd` L18 enum `AMISTAD_MIN` y L55-59 `nivel >= umbral_amistad` sobre `ctx.amistad_npcs`. NOTA: 0 archivos `.tres` de eventos usan hoy esa condicion (deuda de contenido, no de mecanismo).
- [x] T62-13: desbloqueo historias por nivel (L33): verificar — VERIFICADO: 61 archivos `data/dialogues/contextual/*_amistad60.json` y `*_amistad90.json`, con variantes `HISTORIA`; `scripts/dialogos/test_contextual_dialogue_m162.gd` L116-135 mide el gating por `amistad_<npc>`; ademas `CondicionEvento.HISTORIA_PROGRESO` (L19, L61-63). NOTA: `secondary_stories_service.gd` no tiene gate de nivel M23 (deuda aparte).
- [x] T62-14: feedback nivel subido (L38): verificar — VERIFICADO: `scripts/core/event_bus.gd:87` señal `friendship_level_up`, `data/vfx/vfx_catalog.json:649` (`vfx_regalo_amistad`, 12 corazones, bus `npc.friendship_level_up`) y `scripts/dialogos/dialogue_manager.gd:65-70` emite `level_up_reaction` + escena de dialogo. NOTA: "lista de desbloqueos" = 0 hits en `scripts/friendship`, `scripts/ui` y `scenes/`.
- [ ] T62-15: records hablados (L192) + frases despedida (L191) + regalos retorno (L193): verificar — PENDIENTE 1/3: L193 SI (`data/amistad/cartas.json` tiene `adjunto_retorno` = FLOR_SILVESTRE / PASTEL y `scripts/friendship/friendship_service.gd:464-473` agrega el item al inventario al responder la carta); L191 NO (0 hits de despedida *por nivel*: solo `linea_despedida` fija por vecino en `data/villagers/*.tres`); L192 NO (0 hits de `get_recuerdos` en `scripts/dialogos/`; la memoria existe pero nadie la habla).

## Regla

Solo flip [ ] → [x] si el artefacto existe en disco (grep ≥1 hit). Si no existe: dejar [ ] y anotar "pendiente de implementacion".

> **Medicion 2026-11-25 (Log 2442):** 13/15 casillas verificadas con artefacto; 2 pendientes (T62-11 sin tabla de nombres; T62-15 solo 1/3). Cero checklists de modulo tocadas, cero fixes de codigo, cero commits. El recuento canonico de marcas en los 63 archivos de BACKLOGS antes de esta tanda era **3539 [x] / 15 [ ] / 0 [?]**, no 3564 (msg 150): diferencia de 25 cuyo origen se trazo el 2026-11-26 — rupturas internas en la cadena TOTAL ACUMULADO de `BACKLOG-MASTER.md` (L146/L151/L156/L161/L166), documentadas en la seccion "RECUENTO MEDIDO 2026-11-26" de ese archivo y en Log 2469.

## Total

3539[x] + 13 = 3552[x] (13 flips verificados · 2 pendientes · 0 [?]). Cifra del msg 150 (3564+10=3574) corregida: ver nota de medicion y Log 2469.
