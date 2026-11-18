# 23-Backlog: Visual QA restante (314 capturas, 63 batches)

> Creada por: agnes-3-flash - 2026-11-18 01:58
> Nicho: Visual QA (permanente, aprobado 17nov)
> Los 60 primeros ya se hicieron en la prueba 18. Estos son los restantes.

## Tareas

- [x] T23-01: 15-Recursos / cap_15_recursos.png ... cap_15_recursos2.png (2 caps) — 2/2 PROBLEMA: `cap_15_recursos.png` editor Godot con jugador = CAPSULA AZUL sobre terreno voxel y montaña blanca, texto de controles superpuesto y barra `100`; `cap_15_recursos2.png` ventana DEBUG (FPS:60) con la misma capsula azul entre muros verdes.
- [x] T23-02: 154-Vision-Del-Agente / cap_154_2026-10-09_00-17-08_v3_web_preview.png ... cap_154_2026-10-31_18-46-00_gpt-luna_p60frames.png (4 caps) — 4/4 PROBLEMA: `v3_web_preview` mundo VACIO BLANCO, FPS:0, solo HUD reloj/barras (evidencia visual de BUG-127). Las 3 `gpt-luna` muestran menu Pausa legible sobre playa sobreexpuesta, pero con IDE Kilo Code visible detras.
- [x] T23-03: 155-Vestimenta / cap_155_2026-10-26_06-00-00_nemotron_vestimenta_spawn.png ... cap_155_2026-10-26_06-00-00_nemotron_vestimenta_spawn.png (1 caps) — 1/1 PROBLEMA: personaje SI renderiza como modelo (no capsula) sobre archipelago/agua, pero captura contaminada por IDE con texto de reflexion detras; FPS:60.
- [x] T23-04: 155-Vestimenta-Y-Accesorios / cap_155_2026-09-01_18-50-00_jugador.png ... cap_155_2026-09-01_19-36-00_ui_equip4.png (5 caps) — 5/5 PROBLEMA: `jugador` capsula azul con barra de equipo `Pico de cobre 150/150`; `ui_equipamiento` es solo VS Code/Kilo Code; `ui_equip2/3/4` son 3 veces el SPLASH de Godot (una con NullReferenceException en consola).
- [x] T23-05: 155-Vestimenta-Y-Accesorios / cap_155_2026-09-01_19-38-00_printwindow.png ... cap_155_2026-09-01_22-24-00_preview.png (5 caps) — 5/5 PROBLEMA: `printwindow` ventana gris vacia; `region` splash de Godot; `intento6`/`topmost` dialogo "Los archivos han sido modificados fuera de Godot" sin escena; `preview` panel `Vestimenta del jugador` legible pero 4 slots vacios y consola IDE con errores detras.
- [x] T23-06: 155-Vestimenta-Y-Accesorios / cap_155_equipment-integrated_2026-09-06_04-30.png ... cap_155_equipment-integrated_2026-09-06_04-30.png (1 caps) — 1/1 PROBLEMA: capsula azul sobre montaña voxel con arboles, FPS:60, IDE/browsers al fondo. No se ve equipamiento aplicado al modelo.
- [x] T23-07: 16-Crafting / cap_16_crafting_arranque.png ... cap_16_estacion.png (2 caps) — 2/2 PROBLEMA: ambas muestran la misma capsula azul en terreno voxel (FPS:59 y 60) con controles superpuestos; no se distingue una estacion de crafting ni feedback visual.
- [x] T23-08: 161-Diseno-Visual-De-NPCs / swatch_23npc.png ... swatch_23npc_v2.png (2 caps) — 2/2 PROBLEMA: `swatch_23npc.png` tabla de 23 NPCs con casillas GRISES VACIAS; `_v2` paleta coloreada legible, pero es documento de diseno, no render de NPC in-game.
- [x] T23-09: 161-DisenoVisualNPCs / cap_161_2026-10-26_05-30-20_nemotron_diseno_visual_npcs_spawn.png ... cap_161_2026-10-26_05-30-20_nemotron_diseno_visual_npcs_spawn.png (1 caps) — 1/1 PROBLEMA: modelo de personaje visible sobre arena/agua con FPS:60, pero IDE/texto de reflection detras y portal naranja sin contexto. No se ven disenos de NPC.
- [x] T23-10: 163-Sistema-De-Encantamientos / cap_163_2026-10-08_23-28-18_post_bug119_chaman_terreno.png ... cap_163_2026-10-09_03-39-06_bug124_chaman_malla.png (5 caps) — 5/5 PROBLEMA: las 4 primeras muestran SOLO ladera azul/gris sin chamán (evidencia del BUG-124 original); la quinta `bug124_chaman_malla` SI muestra capsula+esfera con Label3D `Chamán`, pero flotando sobre la colina y sin estilo. Fix visual parcial.
- [x] T23-11: 165-Voxel-Tools-Guia / cap_165_2026-09-01_00-41-03_escena_terrero.png ... cap_165_2026-09-01_00-41-34_detalle_biomas.png (2 caps) — 2/2 PROBLEMA: terreno voxel con jugador CAPSULA AZUL, FPS:60; `detalle_biomas` no diferencia biomas (todo verde/rosa).
- [x] T23-12: 167-Isla-Raiz / cap_167_2026-09-01_12-28-00_overview.png ... cap_167_2026-10-31_20-39-56_gpt-luna_continuar-reanuda.png (5 caps) — 4 PROBLEMA + 1 OK. OK: `gpt-luna_isla-reanudada` (modelo, agua/islas, FPS:60). PROBLEMA: `overview` y `smoke_regresion` con capsula azul + IDE/consola; `costa` geometria blanca/cian sin jugador; `continuar-reanuda` modelo con texto de IDE detras.
- [x] T23-13: 167-Isla-Raiz / cap_167_2026-10-31_20-42-21_gpt-luna_60-frames-agua.png ... cap_c1_2026-10-31_19-49-53_gpt-luna_isla-boot.png (4 caps) — 2 OK + 2 PROBLEMA. OK: `60-frames-agua` y `mas-60-frames` (modelo + agua/islas, FPS:60, sin IDE). PROBLEMA: `gpt-luna_spawn` recortado (HUD cortado) y `cap_c1_isla-boot` con IDE al fondo.
- [x] T23-14: 167-IslaRaiz / cap_167_2026-10-26_00-32-40_nemotron_isla_raiz_spawn.png ... cap_167_2026-10-26_00-32-40_nemotron_isla_raiz_spawn.png (1 caps) — 1/1 PROBLEMA: personaje modelo sobre archipielago, FPS:60, pero texto de IDE detras de la ventana.
- [x] T23-15: 19-Muelle / cap_19M-AntorchaPared_antes-despues_2026-09-19_02-46-17.png ... cap_19M-AntorchaPared_antes-despues_2026-09-19_02-46-17.png (1 caps) — 1/1 OK: comparacion ANTES/DESPUES legible sobre fondo plano (`ANTES: flota 0.34 m` vs `DESPUES: E-90, cara interior`). No es gameplay, pero cumple su proposito de QA visual.
- [x] T23-16: 19-NPC / cap_19_2026-10-25_23-05-38_nemotron_npc_spawn.png ... cap_19_2026-10-25_23-05-38_nemotron_npc_spawn.png (1 caps) — 1/1 PROBLEMA: modelo sobre costa con IDE/texto detras; NPC no diferenciable del jugador.
- [x] T23-17: 19-NPC-Y-Vecinos / cap_19_2026-08-28_02-07-15_Catalina Oso NPC visible en isla.png ... cap_19_2026-10-31_gpt-luna_sin-npc-visible.png (3 caps) — 2/3 OK: `gpt-luna_sin-npc-visible` y `_acercamiento` renders limpios (voxel, modelo de personaje, FPS 60/59, sin NPC); `Catalina Oso NPC visible` = pantalla negra con IDE al fondo (1238x630).
- [x] T23-18: 25-Ruinas / cap_21_2026-08-29_17-25-04_dialogo-catalina.png ... cap_21_2026-08-29_18-25-35_catalina-junto-jugador.png (5 caps) — 0/5 OK: capsula azul en las 5; `dialogo-fijado` muestra cuadro de dialogo de Catalina (texto legible) pero terreno inundado de azul; `spawn-arena` capsula gigante ocupa el frame; `catalina-junto-jugador` suelo marron vacio sin NPC.
- [x] T23-19: 25-Ruinas / cap_21_2026-08-29_18-36-02_camara-fijada.png ... cap_21_2026-08-29_19-52-07_spawn-corregido.png (5 caps) — 0/5 OK: `camara-fijada`, `spawn-interior`, `spawn-pradera` = frame azul solido (camara dentro del agua); `spawn-pradera-verificado` suelo marron vacio; `spawn-corregido` terreno voxel + dialogo legible pero capsula azul.
- [x] T23-20: 25-Ruinas / cap_21_2026-08-29_20-04-40_isla-ideal-restaurada.png ... cap_25_2026-08-29_00-57-43_ruina-sobre-terreno.png (5 caps) — 0/5 OK: `isla-ideal-restaurada` vacio blanco + capsula; `terrainlocator` y las 3 `ruina-*` voxel con capsula azul (FPS 57-60), sin ruina claramente distinguible.
- [x] T23-21: 25-Ruinas / cap_25_2026-08-29_01-01-02_ruina-fix-async.png ... cap_25_2026-08-29_01-19-03_preview_limpio.png (5 caps) — 0/5 OK: 4 capturas BYTE-IDENTICAS al splash de Godot (sha256 76c63250d57d, 936x556, 23574 B) bajo nombres `ruina-fix-async`, `ruina-tras-carga`, `preview_ventana`, `preview_limpio` -> evidencia de fix FALSA; `ruina-sin-conn` voxel + capsula.
- [x] T23-22: 25-Ruinas / cap_25_2026-08-29_01-21-05_preview-viewer.png ... cap_25_2026-08-29_01-26-14_preview-final2.png (5 caps) — 0/5 OK: `preview-viewer`/`preview-final2` viewport gris vacio; `preview-generador`/`preview-encuadre` plano gris sin textura; `preview-final` miniature 159x27 px (861 B) recortada, inutilizable.
- [x] T23-23: 25-Ruinas / cap_25_2026-08-29_01-27-28_preview-legible.png ... cap_25_2026-08-29_01-48-18_aire-isla.png (5 caps) — 0/5 OK: `preview-legible` plano gris; `ruina-legible-oficial` ruin gris visible pero sin textura/contexto; `spawn-actual`/`spawn-fix` voxel + capsula; `aire-isla` isla lejana sobre vacio marron + capsula.
- [x] T23-24: 25-Ruinas / cap_25_2026-08-29_01-50-57_meseta-pasto.png ... cap_25_2026-08-29_01-56-49_isla-x10-spawn2.png (5 caps) — 0/5 OK: `meseta-pasto`/`meseta-tierra` voxel + capsula flotando; `isla-x10` isla diminuta; `isla-x10-spawn`/`spawn2` vacio marron con punto azul minusculo. FPS 59-60.
- [x] T23-25: 25-Ruinas / cap_25_2026-08-29_01-58-58_isla-centro.png ... cap_25_2026-08-29_02-13-49_montanas-legibles.png (5 caps) — 0/5 OK: `isla-centro` y `meseta-plana` = vacio marron con punto azul minusculo; `viewer-spawn` = plano verde liso con capsula azul; `montanas-playa` = voxel con capsula azul gigante que tapa el centro; `montanas-legibles` = isla voxel con montanas grises pero sin ruina y capsula azul. FPS 59-60.
- [x] T23-26: 25-Ruinas / cap_25_2026-08-29_02-17-32_spawn-suave.png ... cap_25_2026-08-29_02-33-09_piramide-final.png (5 caps) — 0/5 OK: `spawn-suave`, `playa-oceano`, `playa-cerca`, `piramidal`, `piramide-final` = terreno voxel verde/blanco con capsula azul; sin oceano, sin piramide reconocible, sin ruina. FPS 59-60.
- [x] T23-27: 25-Ruinas / cap_25_2026-08-29_02-35-19_salto-oro.png ... cap_25_2026-08-29_03-02-39_plato-arena.png (5 caps) — 0/5 OK: `salto-oro` y `anillo-arena` = voxel verde sin salto dorado ni anillo; `atolon-2048b`, `sector-montanas`, `plato-arena` = plano de arena blanca con capsula azul y 0-2 bloques verdes; sin atolon, agua ni montanas. FPS 59-60.
- [x] T23-28: 25-Ruinas / cap_25_2026-08-29_03-05-39_plato-256.png ... cap_25_2026-08-29_03-14-54_viewer-seguito.png (5 caps) — 0/5 OK: `plato-256`, `plato-256b`, `plato-completo`, `plato-viewer800`, `viewer-seguito` = plano de arena blanca recortado sobre fondo marron, capsula azul y 0-3 cubos verdes; sin ruina ni geometria distinguishable. FPS 59-60.
- [x] T23-29: 25-Ruinas / cap_25_2026-08-29_03-27-26_montanas-conicas.png ... cap_25_2026-08-29_04-53-01_volcan-monticulos.png (5 caps) — 0/5 OK: `montanas-conicas`, `-altas-suaves`, `-orig` = relieves verdes con escalones oscuros, no conos; `punto-medio` = foso voxel con bloques rosados; `volcan-monticulos` = monticulos con curvas de nivel y capsula azul gigante. Sin ruina. FPS 60.
- [x] T23-30: 25-Ruinas / cap_25_2026-08-29_05-09-09_montanas-multiples.png ... cap_25_preview_ruina.png (5 caps) — 0/5 OK (1 parcial): `montanas-multiples` y `paleta-maldivas` visualmente identicas (hashes distintos) = foso voxel verde con capsula; `verde-55711E` = franja verde/blanca con capsula; `nemotron_ruinas_horizonte` = personaje modelo sobre archipielago con IDE al fondo, sin ruina; `cap_25_preview_ruina` = unico render con muros grises de ruina real, sin textura/contexto/jugador. FPS 59-60.
- [x] T23-31: 30-Reloj-En-Tiempo-Real / cap_30_2026-08-26_19-21-00_iter7_pantalla_completa_verificacion.png ... cap_30_2026-08-26_iter1_preview_reloj.png (5 caps) — 2/3 OK: `20-06-00_inengine` (08:00) y `20-06-01_inengine` (09:00) = panel legible arriba-derecha `Lunes, 1 de Primavera, Año 1 / Primavera`, avance horario medido; PROBLEMA: `iter7_pantalla_completa` y `grab_fresco` contaminados por IDE (reloj 11:00 solo en ventana embebida, grab_fresco sin reloj), `iter1_preview_reloj` = editor Godot con codigo, sin widget.
- [x] T23-32: 30-Reloj-En-Tiempo-Real / cap_30_2026-08-31_23-30-00_00_hover.png ... cap_30_2026-08-31_23-30-00_02_hover.png (3 caps) — 1/3 OK: `02_hover` = tooltip `Fecha y hora / Lunes, 1 de Primavera, Año 1 / Sesion: Mañana / Estacion: Primavera / Próximos eventos: día 2, día 3` legible; PROBLEMA: `00_hover` y `01_hover` BYTE-IDENTICAS (sha256 `43e17985...`, 9633 B) y muestran el reloj reducido a un guion verde sin hora; en las 3 el widget colapsa a barra verde durante el hover.
- [x] T23-33: 30-RelojEnTiempoReal / cap_30_2026-10-25_23-22-34_nemotron_reloj_sin_hud.png ... cap_30_2026-10-25_23-22-34_nemotron_reloj_sin_hud.png (1 caps) — 0/1 OK: DEBUG FPS:60, modelo de personaje sobre archipiélago voxel, SIN widget de reloj (coherente con "sin_hud" en el nombre), pero texto de IDE recortado en el borde superior. sha 755e6e2d0479 / 126350 B / 936x556.
- [x] T23-34: 31-Ciclo-Dia-Noche / cap_31_2026-09-19_05-12-58_dia_0800.png ... cap_31_2026-09-19_05-19-00_atardecer_1900.png (3 caps) — 0/3 OK por contaminación (escritorio Windows completo visible en las 3), PERO evidencia positiva REAL del ciclo: `dia_0800` reloj 08:21 día claro (FPS:59), `noche_2200` reloj 22:44 noche oscura con jugador apenas visible (FPS:60), `atardecer_1900` reloj 19:30 terreno teñido marrón/naranja (FPS:60). Reloj legible en español `Lunes, 1 de Primavera, Año 1 / Primavera / Festividad`. 3 shas distintos (4cd6cd7f1d67 / 9108a3bdf40a / ab2b10cd5b4e), 1920x1080.
- [x] T23-35: 31-CicloDiaNoche / cap_31_2026-10-25_21-16-08_nemotron_ciclo_diurno_sin_hud_hora.png ... cap_31_2026-10-25_21-16-08_nemotron_ciclo_diurno_sin_hud_hora.png (1 caps) — 0/1 OK: DEBUG FPS:60, día claro, modelo de personaje sobre costa voxel, sin HUD de hora (coherente con "sin_hud_hora"), texto de IDE al fondo. sha 943097213c7f / 113728 B / 936x556.
- [x] T23-36: 33-Agricultura / cap_33_2026-10-29_01-40_nemotron_pf-001.png ... cap_33_iter2_cosecha.png (5 caps) — 0/5 OK: 2 `pf-001` (26/31oct) = DEBUG FPS:60, mismo archipiélago modelado con IDE al fondo, sin parcelas visibles; `farm_arranque` = jugador CAPSULA AZUL en hoyo voxel con IDE; `iter2_arranque` = cápsula azul, terreno aterrazado, texto IDE; `iter2_cosecha` = panel DEBUG(F12), reloj 09:21, cápsula azul y terreno aterrazado sin cultivo reconocible, IDE Cline al fondo. Ninguna muestra cosecha/cultivo claro. 5 shas distintos.
- [x] T23-37: 33-Agricultura / cap_33_iter2_debug.png ... cap_33_iter2_plantado.png (4 caps) — 0/4 OK: toda la serie `iter2` en editor Godot con IDE por encima, jugador CAPSULA AZUL sobre terreno aterrazado verde, panel DEBUG(F12), reloj avanza 09:21→21:01→21:04→10:28. `debug` y `dia3` muestran error ROJO en consola: `Failed to load script "res://scripts/ui/hud_hotbar_widget.gd" - Parse error` y `res://scripts/ui/hud_hotbar_widget.gd:52 - Parse Error: variable type inferred from Variant ... (Warning treated as error)` (evidencia visual de script roto en M33/UI); `plantado` sin cultivo reconocible. 4 shas distintos, 1920x1080.
- [x] T23-38: 34-Pesca / cap_34_2026-10-25_21-31-21_nemotron_pesca_sin_ui_visible.png ... cap_34_pesca_arranque.png (2 caps) — 0/2 OK: `nemotron` FPS:59 modelo sobre costa voxel con IDE al fondo, sin UI de pesca visible (coherente con "sin_ui_visible"); `arranque` FPS:60 jugador CAPSULA AZUL en hoyo voxel, sin caña/indicador de pesca, navegador al fondo. 2 shas distintos, 936x556.
- [x] T23-39: 37-Museos-Y-Colecciones / cap_37_2026-10-08_23-59-51_vitrinas_museo.png ... cap_37_2026-10-09_00-08-55_vitrinas_museo.png (3 caps) — 0/3 OK: `2026-10-08_23-59-51` = mundo VACIO (cielo degradado + suelo gris), FPS:0, reloj 08:00 `Lunes, 1 de Primavera`, hotbar `Pico de Cobre 150/150`, sin vitrinas (evidencia visual de BUG-127); las 2 restantes son casi vacías: `00-04-27` = fondo gris liso con un único cuadrito oscuro central (3739 B), `00-08-55` = fondo gris con un cubo blanco/verde suelto (5776 B). Ninguna muestra vitrinas de museo. 3 shas distintos, 1152x648.
- [x] T23-40: 40-Infraestructura / cap_40_2026-10-25_22-31-46_nemotron_infraestructura_spawn.png ... cap_40_infra_arranque.png (2 caps) — 0/2 OK: `nemotron` FPS:60 modelo sobre costa voxel con IDE al fondo, sin infraestructura distinguible; `arranque` FPS:60 sobre terreno montañoso voxel con un pillar gris y jugador CAPSULA AZUL, sin puente/camino/edificio reconocible, IDE al fondo. 2 shas distintos, 936x556.
- [ ] T23-41: 41-Musica / cap_41_2026-10-26_04-45-50_nemotron_musica_spawn.png ... cap_41_2026-10-26_04-45-50_nemotron_musica_spawn.png (1 caps)
- [ ] T23-42: 43-SFX / cap_43_2026-10-26_05-00-54_nemotron_sfx_spawn.png ... cap_43_2026-10-26_05-00-54_nemotron_sfx_spawn.png (1 caps)
- [ ] T23-43: 45-Arte-3D / cap_45_2026-09-06_15-25-34_jugador_voxel_en_juego.png ... cap_45_2026-09-06_17-39-42_pelo_v2_spawn_3persona.png (3 caps)
- [ ] T23-44: 45-Arte3D / cap_45_2026-10-25_23-15-48_nemotron_arte3d_spawn.png ... cap_45_2026-10-25_23-15-48_nemotron_arte3d_spawn.png (1 caps)
- [ ] T23-45: 47-Texturas-Y-Materiales / cap_47_2026-09-06_16-03-16_recursos_materiales_nuevos.png ... cap_47_2026-09-06_16-08-00_recursos_vetas.png (3 caps)
- [ ] T23-46: 47-TexturasMateriales / cap_47_2026-10-25_23-15-48_nemotron_texturas_materiales_spawn.png ... cap_47_2026-10-25_23-15-48_nemotron_texturas_materiales_spawn.png (1 caps)
- [ ] T23-47: 49-Iluminacion / cap_49_2026-09-06_07-24-15_atardecer_1800.png ... cap_49_2026-09-06_07-31-50_mediodia_1200_v2.png (5 caps)
- [ ] T23-48: 49-Iluminacion / cap_49_2026-09-06_07-32-05_atardecer_1800_v2.png ... cap_49_2026-09-06_07-35-01_f3_1800.png (5 caps)
- [ ] T23-49: 49-Iluminacion / cap_49_2026-09-06_07-35-12_f4_0000.png ... cap_49_2026-09-06_07-48-00_franja_1800_final.png (5 caps)
- [ ] T23-50: 49-Iluminacion / cap_49_2026-09-06_10-20-00_amanecer_0600.png ... cap_49_2026-10-31_gpt-luna_luz-runtime-cambio-observado.png (5 caps)
- [ ] T23-51: 49-Iluminacion / cap_49_2026-10-31_gpt-luna_luz-runtime.png ... cap_49_perfil-day-lote1_2026-10-16_20-50.png (5 caps)
- [ ] T23-52: 49-Iluminacion / cap_49_perfil-day-lote2_2026-10-17_01-35.png ... cap_49_perfil-fog-transition-lote1_2026-10-16_20-55.png (2 caps)
- [ ] T23-53: 50-Vegetacion / cap_50_2026-09-02_05-51-00_vegetacion.png ... cap_50_2026-10-19_05-12-10_fps-60-pivote.png (5 caps)
- [ ] T23-54: 50-Vegetacion / cap_50_2026-10-25_20-45-49_nemotron_vegetacion_spawn_adyacente.png ... cap_50_vegetacion-spawned_2026-09-05_23-22.png (5 caps)
- [ ] T23-55: 50-Vegetacion / verif2_arbusto_redondo_horneado.png ... verif3_flor_isla_final.png (5 caps)
- [ ] T23-56: 50-Vegetacion / verif_arbol_frutal.png ... verif_hierba_alta.png (5 caps)
- [ ] T23-57: 50-Vegetacion / verif_palmera_joven.png ... verif_palmera_joven.png (1 caps)
- [ ] T23-58: 51-Agua / cap_51_2026-09-06_16-23-25_agua_olas_v1.png ... cap_51_2026-09-06_17-53-24_olas_cerca_premium.png (5 caps)
- [ ] T23-59: 51-Agua / cap_51_2026-09-06_17-54-14_olas_cerca_premium_frame2.png ... cap_51_2026-09-06_18-06-00_vaiven_f2.png (5 caps)
- [ ] T23-60: 51-Agua / cap_51_2026-09-06_18-06-05_vaiven_f3.png ... cap_51_2026-09-06_18-18-00_shorefade_f1.png (5 caps)
- [ ] T23-61: 51-Agua / cap_51_2026-09-06_18-18-03_shorefade_f3.png ... cap_51_2026-10-08_23-56-40_post_bug105_mar_desde_playa.png (5 caps)
- [ ] T23-62: 51-Agua / cap_51_2026-10-09_00-08-09_post_bug105_mar_desde_playa.png ... cap_51_2026-10-31_gpt-luna_agua-costa-w-confirmado.png (4 caps)
- [ ] T23-63: 52-Particulas-Y-VFX / cap_52M-CalibracionVisual_post-iter6_2026-09-19_03-03-38.png ... cap_52_iter3-turbulencia-flotante.png (5 caps)
- [ ] T23-64: 52-Particulas-Y-VFX / cap_52_iter4-emision-caja-ancha.png ... cap_52_test-v2-mcp.png (2 caps)
- [ ] T23-65: 52-ParticulasVFX / cap_52_2026-10-25_23-12-12_nemotron_particulas_vfx_spawn.png ... cap_52_2026-10-25_23-12-12_nemotron_particulas_vfx_spawn.png (1 caps)
- [ ] T23-66: 52-QA-WEB / cap_web_52_2026-08-25_03-30-39_shot2_polen-web.png ... cap_web_52_2026-08-25_03-30-39_shot2_polen-web.png (1 caps)
- [ ] T23-67: 53-UI-UX / cap_53_2026-10-08_23-28-20_inventario_unificado_overlay.png ... cap_53_2026-10-09_02-11-41_t3_bug126_hud_antes_de_h.png (5 caps)
- [ ] T23-68: 53-UI-UX / cap_53_2026-10-09_02-11-41_t3_bug126_hud_tras_h_sin_cambio_bug128.png ... cap_53_2026-10-09_03-16-57_bug128v2_01_hud_visible_antes_h.png (5 caps)
- [ ] T23-69: 53-UI-UX / cap_53_2026-10-09_03-16-57_bug128v2_02_hud_oculto_tras_h.png ... cap_53_2026-10-18_00-22-30_antes_pausa.png (5 caps)
- [ ] T23-70: 53-UI-UX / cap_53_2026-10-18_00-28-30_despues_pausa.png ... cap_53_2026-10-19_23-10-00_item38_mediaventana_sin_cortes.png (5 caps)
- [ ] T23-71: 53-UI-UX / cap_53_2026-10-25_19-17-43_nemotron_vscode_no_ventana_juego.png ... cap_53_2026-10-25_19-51-15_nemotron_camara_encuadre_inicial.png (5 caps)
- [ ] T23-72: 53-UI-UX / cap_53_2026-10-25_20-02-21_nemotron_camara_frame2_estabilidad.png ... cap_53_2026-10-31_20-31-36_gpt-luna_continuar-mouse-reanudado.png (5 caps)
- [ ] T23-73: 53-UI-UX / cap_53_2026-10-31_20-39-08_gpt-luna_pausa-salta-guardar.png ... cap_53_2026-10-31_gpt-luna_tecla-m.png (5 caps)
- [ ] T23-74: 53-UI-UX / cap_53_2026-10-31_gpt-luna_tecla-p-juego-activo.png ... cap_53_dialogo_cozy.png (5 caps)
- [ ] T23-75: 53-UI-UX / cap_53_dialogo_opciones.png ... cap_53_hud_layout.png (5 caps)
- [ ] T23-76: 53-UI-UX / cap_53_iter4_arranque.png ... cap_c1_2026-10-31_19-55-04_gpt-luna_menu-principal-overlay.png (4 caps)
- [ ] T23-77: 54-Mapa / cap_54_2026-10-02_20-55_m54-run-minimap.png ... cap_54_2026-10-02_22-45_final-fullmap-terrain-texture.png (5 caps)
- [ ] T23-78: 54-Mapa / cap_54_2026-10-03_00-03_final-109-177-62.png ... cap_54_minimap-v1_2026-09-05_17-22.png (4 caps)
- [ ] T23-79: 55-Diario / cap_55_2026-10-26_00-45-36_nemotron_diario_spawn.png ... cap_55_2026-10-26_00-45-36_nemotron_diario_spawn.png (1 caps)
- [ ] T23-80: 56-Fotografia / cap_56_2026-10-09_21-47-29_flujo-directo-tomar-foto-sin-hud.png ... presets_comparativo.png (4 caps)
- [ ] T23-81: 59-SaveLoad / cap_59_2026-10-26_04-45-14_nemotron_save_load_spawn.png ... cap_59_2026-10-26_04-45-14_nemotron_save_load_spawn.png (1 caps)
- [ ] T23-82: 61-Rendimiento / cap_61_2026-09-01_16-45-00_bench_mid.png ... cap_61_2026-09-01_19-01-30_bench_final.png (5 caps)
- [ ] T23-83: 61-Rendimiento / cap_61_2026-10-25_23-20-34_nemotron_rendimiento_hud_fps.png ... cap_61_2026-10-25_23-20-34_nemotron_rendimiento_hud_fps.png (1 caps)
- [ ] T23-84: 62-Audio / cap_62_2026-10-26_04-31-00_nemotron_audio_spawn.png ... cap_62_2026-10-26_04-31-00_nemotron_audio_spawn.png (1 caps)
- [ ] T23-85: 76-Multijugador / cap_76_2026-10-21_02-21-30_inventario_dark_lista_larga.png ... cap_76_2026-10-21_02-23-30_inventario_dark_pestania_mobiliario.png (2 caps)
- [ ] T23-86: 87-Localizacion / cap_87_2026-10-26_01-12-26_nemotron_localizacion_spawn.png ... cap_87_ES_boot_2026-10-24_03-06.png (3 caps)
- [ ] T23-87: 87-Localizacion-Runtime / cap_87_EN_2026-10-20_00-14-00_ui-arranque-en.png ... cap_87_ES_2026-10-20_00-05-30_arranque-limpio.png (2 caps)
- [ ] T23-88: 88-Fuentes / cap_88_2026-10-26_01-45-44_nemotron_fuentes_spawn.png ... cap_88_2026-10-26_04-16-25_nemotron_fuentes_spawn.png (2 caps)
- [ ] T23-89: 88-Fuentes-Tipograficas / cap_88_2026-09-02_02-16-00_legibilidad.png ... cap_88_2026-09-02_02-16-00_legibilidad.png (1 caps)
- [ ] T23-90: M157 / cap_M157_2026-10-30_23-45_nemotron_p1-sin-hud-transporte.png ... cap_M157_2026-10-30_23-45_nemotron_p1-sin-hud-transporte.png (1 caps)
- [ ] T23-91: QA-M51-M31-M19 / cap_QA_2026-09-19_05-04-31.png ... cap_QA_2026-09-19_05-04-31.png (1 caps)
- [ ] T23-92: gameplay / cap_gameplay-fps60_2026-09-06_03-50.png ... cap_gameplay-fps60_2026-09-06_03-50.png (1 caps)

## Tanda 1 cerrada (HY4 Flash, 2026-11-18) — T23-01..08

- **8/8 tareas con veredicto individual**, 22/22 capturas ABIERTAS Y VISTAS (una por una, 0 `[?]`). Rutas resueltas bajo `tools/mcp/godot-mcp/capturas/`; las 22 existen en disco.
- Resultado: **0 OK / 22 PROBLEMA**. Patrones medidos: 6 capturas con jugador como CAPSULA AZUL (T23-01 ×2, T23-04 `jugador`, T23-06, T23-07 ×2), 8 inutilizables para QA (4 splashs de Godot, 1 VS Code, 1 ventana gris, 2 dialogos de archivos modificados), 1 mundo web vacio con FPS:0 (BUG-127), 3 pantallas de Pausa contaminadas por IDE, 1 escena de archipelago con IDE al fondo, 2 swatches de NPC (uno con casillas vacias) y 1 panel de vestimenta legible pero sobre IDE con slots vacios. Suma: 6+8+1+3+1+2+1 = 22.
- Sin arreglos de codigo, sin flips en checklists ajenos. Cola restante del backlog 23: **84 tareas `[ ]`**.

**Firma:** hy4-flash

## Tanda 2 cerrada (HY4 Flash, 2026-11-18) — T23-09..16

- **8/8 tareas con veredicto individual**, 20/20 capturas ABIERTAS Y VISTAS (0 `[?]`). Todas existen en disco.
- Resultado: **4 OK / 16 PROBLEMA** (capturas). Por tarea: **1 OK** (T23-15) y **7 PROBLEMA** (T23-09..14, T23-16).
- Dato relevante para BUG-124: las 4 primeras capturas de T23-10 confirman la colina sin chamán; la quinta (`bug124_chaman_malla`) muestra la malla ya agregada (capsula + esfera + Label3D) pero flotando, sin apoyo en el terreno.
- Cola restante del backlog 23: **76 tareas `[ ]`**. Sin commit/push.

**Firma:** hy4-flash


## Tanda 3 cerrada (HY4 Flash, 2026-11-18) — T23-17..24

- **8/8 tareas con veredicto individual**, 38/38 capturas ABIERTAS Y VISTAS (0 `[?]`). Rutas bajo `tools/mcp/godot-mcp/capturas/`; 19-NPC-Y-Vecinos 3/3 y 25-Ruinas 35/35 existen en disco.
- Resultado: **2 OK / 36 PROBLEMA** (capturas). Por tarea: **0 OK completas**, **1 parcial** (T23-17, 2/3), **7 PROBLEMA** (T23-18..24).
- **Hallazgo sistematico M25**: 4 capturas de la serie `ruina-fix-async / ruina-tras-carga / preview_ventana / preview_limpio` son BYTE-IDENTICAS al splash de Godot (sha256 `76c63250d57d`, 936x556, 23574 B). Estan nombradas como evidencia de fixes y no muestran ningun fix. `preview-final` es una miniatura 159x27 (861 B).
- **Corrobora el hallazgo gpt-luna del director (msg 050)**: las UNICAS 2 capturas utilizables de 38 son `gpt-luna` (31oct). Todo el lote `2026-08-29` de 25-Ruinas esta roto (capsula azul, frames azul solido por camara bajo el agua, vacio marron, splashs, planos grises).
- **Positivo real**: el cuadro de dialogo de Catalina SI renderiza y su texto es legible en `dialogo-fijado` y `spawn-corregido` (M19/M25), aunque el jugador siga siendo capsula azul.
- Cola restante del backlog 23: **68 tareas `[ ]`**. Sin arreglos de codigo, sin flips en checklists ajenos, sin commit/push.

**Firma:** hy4-flash

## Tanda 4 cerrada (HY4 Flash, 2026-11-18) — T23-25..32

- **8/8 tareas con veredicto individual**, **43/43 capturas ABIERTAS Y VISTAS** (0 `[?]`): 25-Ruinas 35/35 y 30-Reloj-En-Tiempo-Real 8/8 existen en disco.
- Resultado: **3 OK / 40 PROBLEMA** (capturas). Por tarea: **2 parciales** (T23-31 2/3, T23-32 1/3) y **6 PROBLEMA** (T23-25..30). Ninguna tarea 100% OK.
- Hallazgos nuevos: (a) `00_hover` y `01_hover` son BYTE-IDENTICAS (sha256 `43e17985...`, 9633 B), asi que la supuesta secuencia de hover no registro dos estados; (b) el widget del reloj colapsa a un guion verde sin hora en los 3 hovers, solo `02_hover` muestra tooltip; (c) en 25-Ruinas la unica imagen con ruina real es `cap_25_preview_ruina` (muros grises sin textura/contexto); el resto del lote 2026-08-29 sigue siendo capsula azul sobre arena/terreno voxel sin ruina.
- Sin arreglos de codigo, sin flips en checklists ajenos, sin commit/push. Cola restante del backlog 23: **60 tareas `[ ]`**.
- Nota: segun mensaje 056 del director no se envia acuse por tanda; unico cierre al llegar a 92/92.

**Firma:** hy4-flash

## Tanda 5 cerrada (HY4 Flash, 2026-11-18) — T23-33..40

- **8/8 tareas con veredicto individual**, **21/21 capturas ABIERTAS Y VISTAS** (0 `[?]`): 30-RelojEnTiempoReal 1/1, 31-Ciclo-Dia-Noche 3/3, 31-CicloDiaNoche 1/1, 33-Agricultura 9/9, 34-Pesca 2/2, 37-Museos 3/3, 40-Infraestructura 2/2. Todas existen en disco, 21 shas distintos (0 byte-idéricas entre sí ni al splash 76c63250d57d).
- Resultado: **0 OK / 21 PROBLEMA**. Ninguna tarea 100% OK. Patrones: 12 capturas con jugador CAPSULA AZUL, 9 con modelo, ~19 contaminadas por IDE/escritorio.
- **Positivo real T23-34**: el ciclo día/noche SI se ve y el reloj es legible en español (08:21 claro → 22:44 oscuro → 19:30 atardecer marrón), reloj avanza; lastima el escritorio Windows detrás. T23-33/35 "sin_hud" coherentes con su nombre (sin reloj).
- **Hallazgo nuevo para el director (T23-37)**: error ROJO en consolaGodot en 2 capturas `iter2` de M33 — `Failed to load script "res://scripts/ui/hud_hotbar_widget.gd" - Parse error` y `hud_hotbar_widget.gd:52 Parse Error: variable type inferred from Variant ... (Warning treated as error)`. Sugiere script de hotbar roto en el estado capturado; contrastar con suite verde actual antes de concluir.
- **BUG-127 confirmado de nuevo (T23-39)**: `cap_37_2026-10-08_23-59-51_vitrinas_museo` = mundo vacío con FPS:0; las otras 2 "vitrinas" son fondos grises con 1 cubo (3739 B y 5776 B). Sin vitrinas de museo en ninguna.
- Sin arreglos de codigo, sin flips en checklists ajenos, sin commit/push. Cola restante del backlog 23: **52 tareas `[ ]`** (40/92).
- Nota: segun mensaje 056 del director no se envia acuse por tanda; unico cierre al llegar a 92/92.

**Firma:** hy4-flash
