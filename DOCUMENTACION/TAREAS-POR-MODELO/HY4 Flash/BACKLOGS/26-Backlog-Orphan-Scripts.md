# 26-Backlog: Orphan Script Detection (1264 scripts, 64 batches)

> Creada por: agnes-3-flash - 2026-11-18 01:58
> Nicho: Volumen/limpieza (permanente)

## Metodo

Para cada batch de 20 scripts:
1. Grep -rlf "NOMBRE_SCRIPT" game/ DOCUMENTACION/ Mensajes/
2. Si 0 hits en DOCUMENTACION/ = ORPHAN (no documentado)
3. Anotar: SCRIPT / REFERENCIADO? (si/no) / DONDE

## Tareas

- [ ] T26-01: Batch 1-20 - follow_camera.gd ... test_perfil_m58_iter4.gd
- [ ] T26-02: Batch 21-40 - test_sonido_visual_m58.gd ... validar_arte_2d.gd
- [ ] T26-03: Batch 41-60 - materiales_recursos.gd ... test_narrative_m150.gd
- [ ] T26-04: Batch 61-80 - test_sfx_m43.gd ... test_cicd_m118.gd
- [ ] T26-05: Batch 81-100 - test_gates_m118.gd ... test_coleccionables.gd
- [ ] T26-06: Batch 101-120 - test_coleccionables_lote2_m73.gd ... build_ghost.gd
- [ ] T26-07: Batch 121-140 - build_history.gd ... control_input.gd
- [ ] T26-08: Batch 141-160 - prompt_db.gd ... scene_manager.gd
- [ ] T26-09: Batch 161-180 - service_registry.gd ... mision_invariant.gd
- [ ] T26-10: Batch 181-200 - npc_invariant.gd ... qa_m16_station_fisica.gd
- [ ] T26-11: Batch 201-220 - qa_m16_ui_cerrada.gd ... crucero_interior.gd
- [ ] T26-12: Batch 221-240 - crucero_manager.gd ... validar_catalogo_m159.gd
- [ ] T26-13: Batch 241-260 - world_locations.gd ... _probe_debug.gd
- [ ] T26-14: Batch 261-280 - debug_commands.gd ... test_m110_ui3.gd
- [ ] T26-15: Batch 281-300 - test_panels_m110.gd ... qa_rf23_reabrir.gd
- [ ] T26-16: Batch 301-320 - test_apply_effects_hy3.gd ... test_skip_m21.gd
- [ ] T26-17: Batch 321-340 - test_typewriter_m21.gd ... dlc_bundle_manager.gd
- [ ] T26-18: Batch 341-360 - dlc_compatibility_checker.gd ... test_mercado_estacion_ferias.gd
- [ ] T26-19: Batch 361-380 - test_minorista_mayorista.gd ... shaman_npc.gd
- [ ] T26-20: Batch 381-400 - shaman_ui.gd ... crop_definition.gd
- [ ] T26-21: Batch 401-420 - crop_tile.gd ... fauna_manager.gd
- [ ] T26-22: Batch 421-440 - fauna_registry.gd ... auditar_glifos.gd
- [ ] T26-23: Batch 441-460 - font_auditor.gd ... friendship_service.gd
- [ ] T26-24: Batch 461-480 - gift_evaluator.gd ... test_historia.gd
- [ ] T26-25: Batch 481-500 - validar_historia.gd ... house_visit.gd
- [ ] T26-26: Batch 501-520 - interior_camera.gd ... state.gd
- [ ] T26-27: Batch 521-540 - state_machine.gd ... categoria_interaccion.gd
- [ ] T26-28: Batch 541-560 - interactable_base.gd ... inventory_slot.gd
- [ ] T26-29: Batch 561-580 - test_inventario.gd ... asset_attribution_generator.gd
- [ ] T26-30: Batch 581-600 - asset_validation_m78.gd ... merch_manager.gd
- [ ] T26-31: Batch 601-620 - merch_validator.gd ... test_credits_m131_v2.gd
- [ ] T26-32: Batch 621-640 - test_genai_m86.gd ... license_validation_result.gd
- [ ] T26-33: Batch 641-660 - test_license_scanner_m83.gd ... test_validador_po_m87.gd
- [ ] T26-34: Batch 661-680 - validador_po.gd ... test_m72_deuda_assets.gd
- [ ] T26-35: Batch 681-700 - test_m72_rf6_m72.gd ... test_mapa_markers.gd
- [ ] T26-36: Batch 701-720 - marketing_validator.gd ... test_monetizacion.gd
- [ ] T26-37: Batch 721-740 - test_monetizacion_m95.gd ... test_museo_rf1.gd
- [ ] T26-38: Batch 741-760 - test_museo_rf2.gd ... vfx_director.gd
- [ ] T26-39: Batch 761-780 - vfx_factory.gd ... equipment_manager.gd
- [ ] T26-40: Batch 781-800 - equipment_slot.gd ... test_principios_m152.gd
- [ ] T26-41: Batch 801-820 - debug_tc.gd ... test_qa_m101.gd
- [ ] T26-42: Batch 821-840 - asset_profile.gd ... test_m62_colliders_chunk.gd
- [ ] T26-43: Batch 841-860 - test_m62_correspondencia_m61.gd ... texture_memory.gd
- [ ] T26-44: Batch 861-880 - unload_policy.gd ... qa_m59_bloqueo_manual.gd
- [ ] T26-45: Batch 881-900 - qa_m59_doble_guardado.gd ... test_checksum_hmac.gd
- [ ] T26-46: Batch 901-920 - test_close_save.gd ... security_input_validator.gd
- [ ] T26-47: Batch 921-940 - security_key_manager.gd ... reputacion_tienda.gd
- [ ] T26-48: Batch 941-960 - shop.gd ... test_pantalla_carga.gd
- [ ] T26-49: Batch 961-980 - test_pausa_cargas.gd ... support_manager.gd
- [ ] T26-50: Batch 981-1000 - support_validator.gd ... puzzle_gravedad.gd
- [ ] T26-51: Batch 1001-1020 - puzzle_herramientas.gd ... test_puzzle_dificultad.gd
- [ ] T26-52: Batch 1021-1040 - test_puzzle_espejos.gd ... terrain_modifiers.gd
- [ ] T26-53: Batch 1041-1060 - captura_playa.gd ... time_calendar.gd
- [ ] T26-54: Batch 1061-1080 - time_config.gd ... transport_route.gd
- [ ] T26-55: Batch 1081-1100 - transport_route_events.gd ... ugc_limits.gd
- [ ] T26-56: Batch 1101-1120 - ugc_manager.gd ... qa_texto_grande_rf27.gd
- [ ] T26-57: Batch 1121-1140 - subtitle_manager.gd ... ui_root.gd
- [ ] T26-58: Batch 1141-1160 - menu_navigator.gd ... inventory_layer.gd
- [ ] T26-59: Batch 1161-1180 - loading_layer.gd ... test_updates_m119.gd
- [ ] T26-60: Batch 1181-1200 - update_manager.gd ... medir_plan_m50.gd
- [ ] T26-61: Batch 1201-1220 - test_distribucion.gd ... qa_budget_m16.gd
- [ ] T26-62: Batch 1221-1240 - qa_m28_ui_travel.gd ... gen_curvas.gd
- [ ] T26-63: Batch 1241-1260 - gen_season_mod.gd ... world_bible.gd
- [ ] T26-64: Batch 1261-1264 - world_generator.gd ... rutina_ia.gd

