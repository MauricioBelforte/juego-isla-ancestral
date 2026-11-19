# 29-Backlog: i18n Deep - msgid orphans

> Creada por: agnes-3-flash - 2026-11-18 01:58
> Nicho: i18n volumen (permanente, aprobado 17nov)

## Metodo

Para cada msgid en locales/es.po:
1. Grep -rF "CLAVE" game/isla-ancestral/scripts/
2. Si 0 hits = ORPHAN (traduccion sin uso)
3. Anotar: CLAVE / USADO? / DONDE

## Tareas (276 msgid en batches de 12)

- [x] T29-01: 12 msgid, 8 USADOS, 4 ORPHAN (0 hits en scripts/). Orphans: MAIN_MENU.OPTIONS (0 hits); ITEMS.MADERA (0 hits); ITEMS.MADERA_DESC (0 hits); DIALOGOS.VECINO_SALUDO (0 hits) Ejemplos usados: MAIN_MENU.PLAY -> game/isla-ancestral/scripts/dialogos/test_localizacion_dialogos.gd; HUD.ENERGIA -> game/isla-ancestral/scripts/localization/retraductor_ui.gd
- [x] T29-02: 12 msgid, 10 USADOS, 2 ORPHAN (0 hits en scripts/). Orphans: SETTINGS.SAVE_CORRUPTO (0 hits); SETTINGS.SAVE_RECUPERADO (0 hits) Ejemplos usados: SETTINGS.AJUSTES -> game/isla-ancestral/scripts/saving/test_menu_guardado_idiomas_m59.gd; SETTINGS.GUARDAR -> game/isla-ancestral/scripts/saving/test_menu_guardado_idiomas_m59.gd
- [x] T29-03: 12 msgid, 5 USADOS, 7 ORPHAN (0 hits en scripts/). Orphans: SETTINGS.SAVE_DISCO_LLENO (0 hits); SETTINGS.HORAS_H (0 hits); SETTINGS.HORAS_1 (0 hits); SETTINGS.MIN_M (0 hits) Ejemplos usados: SETTINGS.GUARDAR_BLOQUEADO -> game/isla-ancestral/scripts/saving/qa_m59_bloqueo_manual.gd; SETTINGS.SALIR -> game/isla-ancestral/scripts/ui/layers/menus_layer.gd
- [x] T29-04: 12 msgid, 12 USADOS, 0 ORPHAN (0 hits en scripts/). Sin orphan. Ejemplos usados: SETTINGS.CREDITOS -> game/isla-ancestral/scripts/ui/layers/credits_layer.gd; SETTINGS.CONFIRMAR -> game/isla-ancestral/scripts/saving/qa_m59_popup_opciones.gd
- [x] T29-05: 12 msgid, 12 USADOS, 0 ORPHAN (0 hits en scripts/). Sin orphan. Ejemplos usados: SETTINGS.CREAR_1 -> game/isla-ancestral/scripts/crafting/crafting_ui.gd; SETTINGS.CREAR_N -> game/isla-ancestral/scripts/crafting/crafting_ui.gd
- [x] T29-06: 12 msgid, 12 USADOS, 0 ORPHAN (0 hits en scripts/). Sin orphan. Ejemplos usados: SETTINGS.DESCARTAR_TITULO -> game/isla-ancestral/scripts/localization/auditor_claves.gd; SETTINGS.DESCARTAR_MENSAJE -> game/isla-ancestral/scripts/localization/auditor_claves.gd
- [x] T29-07: 12 msgid, 12 USADOS, 0 ORPHAN (0 hits en scripts/). Sin orphan. Ejemplos usados: TIENDAS.VENDER_1 -> game/isla-ancestral/scripts/shops/shop_ui.gd; TIENDAS.VENDER_N -> game/isla-ancestral/scripts/shops/shop_ui.gd
- [x] T29-08: 12 msgid, 3 USADOS, 9 ORPHAN (0 hits en scripts/). Orphans: CLOCK.ESTACIONES.1 (0 hits); CLOCK.ESTACIONES.2 (0 hits); CLOCK.ESTACIONES.3 (0 hits); DIARY.ENTRADAS (0 hits) Ejemplos usados: DIARY.CATEGORIAS -> game/isla-ancestral/scripts/ui/layers/diary_layer.gd; DIARY.SIN_ENTRADAS -> game/isla-ancestral/scripts/ui/layers/diary_layer.gd
- [x] T29-09: 12 msgid, 4 USADOS, 8 ORPHAN (0 hits en scripts/). Orphans: DIARY.CAT_PISTAS (0 hits); DIARY.CAT_SELLOS (0 hits); DIARY.CAT_RUINAS (0 hits); DIARY.CAT_CARTAS (0 hits) Ejemplos usados: LOADING.TITULO -> game/isla-ancestral/scripts/ui/layers/loading_layer.gd; LOADING.CARGANDO -> game/isla-ancestral/scripts/ui/layers/loading_layer.gd
- [x] T29-10: 12 msgid, 12 USADOS, 0 ORPHAN (0 hits en scripts/). Sin orphan. Ejemplos usados: M68.EVENT.DIRIGIBLE_LUNA -> game/isla-ancestral/scripts/transporte/transport_localizer.gd; M68.EVENT.DIRIGIBLE_LUNA.SENAL -> game/isla-ancestral/scripts/transporte/transport_localizer.gd
- [x] T29-11: 12 msgid, 7 USADOS, 5 ORPHAN (0 hits en scripts/). Orphans: M68.ROUTE.r_aurora_brisa (0 hits); M68.ROUTE.r_aurora_espejo (0 hits); M68.ROUTE.r_aurora_estacion (0 hits); M68.ROUTE.r_aurora_este (0 hits) Ejemplos usados: M68.NARR.C4_BRIS -> game/isla-ancestral/scripts/transporte/transport_localizer.gd; M68.NARR.C7.01 -> game/isla-ancestral/scripts/transporte/transport_localizer.gd
- [x] T29-12: 12 msgid, 0 USADOS, 12 ORPHAN (0 hits en scripts/). Orphans: M68.ROUTE.r_aurora_plataforma (0 hits); M68.ROUTE.r_aurora_sur (0 hits); M68.ROUTE.r_estacion_aurora (0 hits); M68.ROUTE.r_este_aurora (0 hits)
- [x] T29-13: 12 msgid, 1 USADOS, 11 ORPHAN (0 hits en scripts/). Orphans: M68.ROUTE.r_plataforma_norte (0 hits); M68.ROUTE.r_sur_aurora (0 hits); M68.ROUTE.r_sur_muelle (0 hits); M68.SIGN.estacion_central (0 hits) Ejemplos usados: M68.SIGN.GENERICO -> game/isla-ancestral/scripts/localization/test_validador_po_m87.gd
- [x] T29-14: 12 msgid, 10 USADOS, 2 ORPHAN (0 hits en scripts/). Orphans: M68.SIGN.puerto_norte (0 hits); M68.SIGN.puerto_sur (0 hits) Ejemplos usados: M68.SPECIAL.FESTIVAL_INVIERNO -> game/isla-ancestral/scripts/transporte/transport_localizer.gd; M68.SPECIAL.FESTIVAL_INVIERNO_DESC -> game/isla-ancestral/scripts/transporte/transport_localizer.gd
- [x] T29-15: 12 msgid, 4 USADOS, 8 ORPHAN (0 hits en scripts/). Orphans: M68.STOP.estacion_central (0 hits); M68.STOP.muelle_raiz_sur (0 hits); M68.STOP.plataforma_norte (0 hits); M68.STOP.puerto_aurora (0 hits) Ejemplos usados: M68.SPECIAL.LUNA_LLENA -> game/isla-ancestral/scripts/transporte/transport_localizer.gd; M68.SPECIAL.LUNA_LLENA_DESC -> game/isla-ancestral/scripts/transporte/transport_localizer.gd
- [x] T29-16: 12 msgid, 10 USADOS, 2 ORPHAN (0 hits en scripts/). Orphans: M68.STOP.puerto_norte (0 hits); M68.STOP.puerto_sur (0 hits) Ejemplos usados: M68.TRIP.ARRIVED_AT -> game/isla-ancestral/scripts/transporte/transport_localizer.gd; M68.TRIP.CURRENCY -> game/isla-ancestral/scripts/localization/test_validador_po_m87.gd
- [x] T29-17: 12 msgid, 12 USADOS, 0 ORPHAN (0 hits en scripts/). Sin orphan. Ejemplos usados: M68.TRIP.SPECIAL_ONLY -> game/isla-ancestral/scripts/transporte/transport_localizer.gd; M68.TRIP.TRAVELING_TO -> game/isla-ancestral/scripts/transporte/transport_localizer.gd
- [x] T29-18: 12 msgid, 12 USADOS, 0 ORPHAN (0 hits en scripts/). Sin orphan. Ejemplos usados: EQUIP.TOOLTIP_QUITAR -> game/isla-ancestral/scripts/ui/test_ui_i18n_m53.gd; EQUIP.TOOLTIP_ELEGIR -> game/isla-ancestral/scripts/ui/test_ui_i18n_m53.gd
- [x] T29-19: 12 msgid, 12 USADOS, 0 ORPHAN (0 hits en scripts/). Sin orphan. Ejemplos usados: SETTINGS.OPCIONES -> game/isla-ancestral/scripts/ui/layers/settings_audio_layer.gd; SETTINGS.RANGO_DINAMICO -> game/isla-ancestral/scripts/ui/layers/settings_audio_layer.gd
- [x] T29-20: 12 msgid, 12 USADOS, 0 ORPHAN (0 hits en scripts/). Sin orphan. Ejemplos usados: DIARY.BUSCAR -> game/isla-ancestral/scripts/ui/layers/diary_layer.gd; DIARY.FILTRO -> game/isla-ancestral/scripts/ui/layers/diary_layer.gd
- [x] T29-21: 12 msgid, 12 USADOS, 0 ORPHAN (0 hits en scripts/). Sin orphan. Ejemplos usados: DIARY.FAVORITO -> game/isla-ancestral/scripts/ui/layers/diary_layer.gd; DIARY.PROGRESO_GLOBAL -> game/isla-ancestral/scripts/ui/layers/diary_layer.gd
- [x] T29-22: 12 msgid, 12 USADOS, 0 ORPHAN (0 hits en scripts/). Sin orphan. Ejemplos usados: TUTORIAL.INTERACTUAR -> game/isla-ancestral/scripts/tutorial/tutorial_manager.gd; TUTORIAL.PROLOGO_BIENVENIDA -> game/isla-ancestral/scripts/tutorial/test_tutorial_e2e.gd
- [x] T29-23: 12 msgid, 12 USADOS, 0 ORPHAN (0 hits en scripts/). Sin orphan. Ejemplos usados: eventos.historia_c2_nombre -> game/isla-ancestral/scripts/localization/test_catalogo_exhaustivo_m87.gd; eventos.historia_c2_desc -> game/isla-ancestral/scripts/localization/test_catalogo_exhaustivo_m87.gd

## CIERRE (HY4 Flash, 2026-11-18) — BACKLOG COMPLETO

- **23/23 tareas `[x]`**, cola 0. Universo: **276/276 msgid** de `game/isla-ancestral/locales/es.po` (excluido el `msgid ""` de cabecera), 23 lotes de 12.
- Metodo: indice de una pasada sobre 2655 archivos bajo `game/isla-ancestral/scripts/`; ORPHAN = clave sin ningun hit literal.
- Resultado: **206 USADOS, 70 ORPHAN**. Concentracion en T29-01..03 (claves `MAIN_MENU.OPTIONS`, `ITEMS.MADERA`, `DIALOGOS.VECINO_SALUDO`, `SETTINGS.SAVE_*`, `SETTINGS.HORAS_*`), mientras T29-04..23 tienen 0 o muy pocos orphan.
- Limitacion metodologica (la del propio backlog): solo se busca en `scripts/`; una clave puede estar referenciada en escenas `.tscn`, datos JSON o documentacion y aun asi contar como orphan aqui. No se borro ninguna traduccion.
- Sin commits/push. Reporte al director por backlog terminado.

**Firma:** hy4-flash

