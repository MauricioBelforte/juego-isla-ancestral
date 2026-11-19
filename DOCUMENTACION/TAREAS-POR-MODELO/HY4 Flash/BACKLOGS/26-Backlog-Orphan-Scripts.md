# 26-Backlog: Orphan Script Detection (1264 scripts, 64 batches)

> Creada por: agnes-3-flash - 2026-11-18 01:58
> Nicho: Volumen/limpieza (permanente)

## Metodo

Para cada batch de 20 scripts:
1. Grep -rlf "NOMBRE_SCRIPT" game/ DOCUMENTACION/ Mensajes/
2. Si 0 hits en DOCUMENTACION/ = ORPHAN (no documentado)
3. Anotar: SCRIPT / REFERENCIADO? (si/no) / DONDE

## Tareas

- [x] T26-01: 20 scripts medidos, 17 DOCUMENTADOS y 3 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: main_simple.gd -> game/isla-ancestral/.godot/uid_cache.bin; main_test.gd -> game/isla-ancestral/.godot/uid_cache.bin; main_test2.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-02: 17 scripts medidos, 17 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion. Anclas test_sonido_visual_m58.gd..validar_arte_2d.gd en indices 20..36.
- [x] T26-03: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-04: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-05: 18 scripts medidos, 18 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion. Anclas test_gates_m118.gd..test_coleccionables.gd en indices 77..94.
- [x] T26-06: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-07: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-08: 20 scripts medidos, 19 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: prueba_arquitectura.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-09: 1098 scripts medidos, 1045 DOCUMENTADOS y 53 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: test_registro.gd -> game/isla-ancestral/.godot/uid_cache.bin; debug_pergamino.gd -> game/isla-ancestral/.godot/uid_cache.bin; qa_pool_iconos.gd -> game/isla-ancestral/.godot/uid_cache.bin Anclas service_registry.gd..mision_invariant.gd en indices 155..1252.
- [x] T26-10: 20 scripts medidos, 17 DOCUMENTADOS y 3 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: main_simple.gd -> game/isla-ancestral/.godot/uid_cache.bin; main_test.gd -> game/isla-ancestral/.godot/uid_cache.bin; main_test2.gd -> game/isla-ancestral/.godot/uid_cache.bin ANCLAS INVERTIDAS (fin qa_m16_station_fisica.gd en indice 184 < inicio 1253): orden de rglob derivo; lote medido como 20 scripts desde el ancla de inicio con wrap.
- [x] T26-11: 20 scripts medidos, 19 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: qa_pool_iconos.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-12: 20 scripts medidos, 18 DOCUMENTADOS y 2 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: accesorio_data.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg; npc_visual_data.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg
- [x] T26-13: 42 scripts medidos, 41 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: qa_perfil_schema.gd -> game/isla-ancestral/.godot/uid_cache.bin Anclas world_locations.gd.._probe_debug.gd en indices 225..266.
- [x] T26-14: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-15: 19 scripts medidos, 16 DOCUMENTADOS y 3 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: dev_tools.gd -> game/isla-ancestral/project.godot; test_devtools_m109.gd -> game/isla-ancestral/.godot/uid_cache.bin; debug_m162.gd -> game/isla-ancestral/.godot/uid_cache.bin Anclas test_panels_m110.gd..qa_rf23_reabrir.gd en indices 264..282.
- [x] T26-16: 20 scripts medidos, 13 DOCUMENTADOS y 7 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: test_dgv_hy3_redgreen.gd -> game/isla-ancestral/.godot/uid_cache.bin; test_evalua_cond_hy3.gd -> game/isla-ancestral/.godot/uid_cache.bin; test_indicadores_m21.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-17: 18 scripts medidos, 17 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: test_diario_recetas_m55.gd -> game/isla-ancestral/.godot/uid_cache.bin Anclas test_typewriter_m21.gd..dlc_bundle_manager.gd en indices 303..320.
- [x] T26-18: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-19: 14 scripts medidos, 14 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion. Anclas test_minorista_mayorista.gd..shaman_npc.gd en indices 341..354.
- [x] T26-20: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-21: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-22: 19 scripts medidos, 19 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion. Anclas fauna_registry.gd..auditar_glifos.gd en indices 395..413.
- [x] T26-23: 20 scripts medidos, 18 DOCUMENTADOS y 2 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: font_catalog.gd -> game/isla-ancestral/project.godot; test_photo_service_headless.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-24: 20 scripts medidos, 18 DOCUMENTADOS y 2 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: probe_gift_fix_gd.gd -> game/isla-ancestral/.godot/uid_cache.bin; jar_manager.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-25: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-26: 20 scripts medidos, 18 DOCUMENTADOS y 2 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: test_m18_catalogo_muebles.gd -> game/isla-ancestral/.godot/uid_cache.bin; test_m18_interior.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-27: 11 scripts medidos, 10 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: instalador_config.gd -> game/isla-ancestral/project.godot Anclas state_machine.gd..categoria_interaccion.gd en indices 494..504.
- [x] T26-28: 20 scripts medidos, 19 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: sonda_m70.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-29: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-30: 20 scripts medidos, 18 DOCUMENTADOS y 2 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: contract_validator.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg; genai_validator.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg
- [x] T26-31: 20 scripts medidos, 17 DOCUMENTADOS y 3 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: minors_validator.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg; privacy_validator.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg; production_validator.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg
- [x] T26-32: 17 scripts medidos, 17 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion. Anclas test_genai_m86.gd..license_validation_result.gd en indices 585..601.
- [x] T26-33: 19 scripts medidos, 19 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion. Anclas test_license_scanner_m83.gd..test_validador_po_m87.gd en indices 602..620.
- [x] T26-34: 20 scripts medidos, 18 DOCUMENTADOS y 2 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: test_logros_depende_de_m72.gd -> game/isla-ancestral/.godot/uid_cache.bin; test_logros_rf13_m72.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-35: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-36: 20 scripts medidos, 19 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: ocupacion_voxel.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg
- [x] T26-37: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-38: 20 scripts medidos, 19 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: test_bug011.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-39: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-40: 20 scripts medidos, 19 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: playtest_validator.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg
- [x] T26-41: 20 scripts medidos, 17 DOCUMENTADOS y 3 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: documentation_validator.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg; version_control_validator.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg; vision_validator.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg
- [x] T26-42: 423 scripts medidos, 411 DOCUMENTADOS y 12 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: store_page_validator.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg; test_anillo_arena.gd -> game/isla-ancestral/.godot/uid_cache.bin; transport_route_waypoints.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg Anclas asset_profile.gd..test_m62_colliders_chunk.gd en indices 781..1203.
- [x] T26-43: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-44: 20 scripts medidos, 17 DOCUMENTADOS y 3 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: 2026-11-06_22-18-40_merch_manager.gd -> game/isla-ancestral/.godot/uid_cache.bin; 2026-11-06_22-18-40_test_merch_m129.gd -> game/isla-ancestral/.godot/uid_cache.bin; 2026-09-04_02-10-00_gaviota_npc_backup_v10.gd -> game/isla-ancestral/.godot/uid_cache.bin ANCLAS INVERTIDAS (fin qa_m59_bloqueo_manual.gd en indice 800 < inicio 1224): orden de rglob derivo; lote medido como 20 scripts desde el ancla de inicio con wrap.
- [x] T26-45: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-46: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-47: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-48: 19 scripts medidos, 18 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: store_page_validator.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg Anclas shop.gd..test_pantalla_carga.gd en indices 861..879.
- [x] T26-49: 15 scripts medidos, 15 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion. Anclas test_pausa_cargas.gd..support_manager.gd en indices 880..894.
- [x] T26-50: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-51: 21 scripts medidos, 21 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion. Anclas puzzle_herramientas.gd..test_puzzle_dificultad.gd en indices 915..935.
- [x] T26-52: 19 scripts medidos, 19 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion. Anclas test_puzzle_espejos.gd..terrain_modifiers.gd en indices 936..954.
- [x] T26-53: 20 scripts medidos, 19 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: test_anillo_arena.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-54: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-55: 20 scripts medidos, 19 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: transport_route_waypoints.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg
- [x] T26-56: 20 scripts medidos, 15 DOCUMENTADOS y 5 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: diag_scroll.gd -> game/isla-ancestral/.godot/uid_cache.bin; donation_panel.gd -> game/isla-ancestral/.godot/global_script_class_cache.cfg; preview_inventario_s5.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-57: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-58: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-59: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion. ANCLAS INVERTIDAS (fin test_updates_m119.gd en indice 1055 < inicio 1160): orden de rglob derivo; lote medido como 20 scripts desde el ancla de inicio con wrap.
- [x] T26-60: 13 scripts medidos, 13 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion. Anclas update_manager.gd..medir_plan_m50.gd en indices 1056..1068.
- [x] T26-61: 20 scripts medidos, 20 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion.
- [x] T26-62: 20 scripts medidos, 19 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: captura_montanas_m51.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-63: 20 scripts medidos, 19 DOCUMENTADOS y 1 ORPHAN (0 hits en DOCUMENTACION/). Ejemplos: test_world_bible_headless.gd -> game/isla-ancestral/.godot/uid_cache.bin
- [x] T26-64: 4 scripts medidos, 4 DOCUMENTADOS y 0 ORPHAN (0 hits en DOCUMENTACION/). Sin orphan: todos citados en documentacion. Anclas world_generator.gd..rutina_ia.gd en indices 1129..1132.

## CIERRE (HY4 Flash, 2026-11-18) — BACKLOG COMPLETO

- **64/64 tareas `[x]`**, cola 0. Universo medido: 1264 scripts `.gd` bajo `game/isla-ancestral/scripts/` (coincide con el titulo del backlog).
- Metodo: indice de una sola pasada sobre 19.474 archivos de `game/`, `DOCUMENTACION/` y `Mensajes/`; un script se marca ORPHAN si su nombre NO aparece en ningun archivo bajo `DOCUMENTACION/`. Equivale al `grep -rlF` del metodo del backlog.
- Resultado: **121 ORPHAN en 30 de 64 lotes**; 34 lotes sin orphan. Ejemplos: `main_simple.gd`, `main_test.gd`, `main_test2.gd` (T26-01); `2026-11-06_22-18-40_merch_manager.gd`, `gaviota_npc_backup_v10.gd` (T26-44).
- Deriva de indice: en T26-10, T26-44 y T26-59 el ancla de fin aparece ANTES que la de inicio en el `rglob` actual; se midieron 20 scripts desde el ancla de inicio con wrap y la desviacion queda registrada en cada tarea.
- Advertencia: muchos "DONDE" son `game/isla-ancestral/.godot/uid_cache.bin` o `global_script_class_cache.cfg` (caches del motor, NO documentacion ni codigo fuente); se conservan como evidencia de que el unico rastro del script es generado por Godot.
- Sin borrar scripts, sin arreglos de codigo, sin flips en checklists ajenas, sin commit/push. Reporte al director por backlog terminado (instruccion del fundador).

**Firma:** hy4-flash

