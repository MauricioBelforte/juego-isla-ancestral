# Log 1345: T-M1 lote 2 (M55 Diario): validate_diary, detalle con descripcion/refs, persistencia 2 procesos y diagnostico de fotografias

**Fecha:** 2026-10-05
**Hora:** 21:16
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Cierre de los 4 encargos de T-M1 lote 2 del canal 18: (1) validador headless
`validate_diary.gd` en verde con sonda roja demostrada; (2) descripciones y referencias en el
detalle del diario con contenido de fuentes reales; (3) persistencia de estrella y filtros
entre sesiones con dos procesos reales de Godot sobre SaveManager M59; (4) diagnostico de la
categoria fotografias con 0 entradas (frente sin contenido M56, no bug de datos).
Regresion 4/4 verde. M55 pasa de 33 a 37 [x] (37/131).

## Cambios Realizados

1. **`validate_diary.gd` (nuevo, ~290 L, SceneTree):** 6 areas — estructura/mapeo (14
   categorias == `get_categorias()`, ids `^[a-z0-9_-]+$` unicos, titulos, conteo vs
   `total_entradas`); contenido (descripcion no vacia, refs existentes sin self-ref); i18n
   (claves `DIARY.*` de `diary_layer.gd`, literales + `CAT_*` de las 14, con msgstr no vacio
   en `es.po` Y `en.po`, 37 claves); persistencia (round-trip + saneo de ui prefs); rendimiento
   (20 cargas < 500 ms); encoding (BOM/U+FFFD). Ruta alterna de catalogo via user arg para
   sondas. **Verde: 0 fallos / 1 aviso (fotografias) / EXIT 0. Sonda roja: JSON truncado al
   60% -> 21 fallos / EXIT 1** (copia borrada despues).
2. **`diario_catalog.json`:** +8 descripciones (5 personajes desde el campo `historia` de los
   villager .tres; 3 misiones desde `historia_principal.json` y `secundarias.json`) + 3 refs
   (`mision_prologo` y `mision_cadena-faro` -> `vecino_finneas_zorro`;
   `mision_cadena-invernadero` -> `vecino_mateo_mapache`). 36/44 sin descripcion por **no
   tener fuente real** (no se invento contenido). Formato tabs/objeto-en-linea preservado.
3. **`diary_service.gd`:** `_cargar_catalogo` propaga `descripcion`/`refs`; nuevas
   `detalle_entrada(id) -> Dictionary` y `categoria_de(id)`; `_ui_prefs` + `set_ui_prefs`
   (fuera de rango -> defaults 0/"personajes") + `get_ui_prefs()`; `get_save_data` anade
   `"ui"`; `restore_save_data` tolerante.
4. **`diary_layer.gd`:** `LblDetalleDesc` (autowrap, oculto sin texto), `LblRefs` + `RefsBox`
   con botones `Ref_*` (cada ref filtrada con `esta_registrada()` = anti-spoiler),
   `_navegar_a_ref()` (pestaña + limpieza de busqueda/filtro + seleccion de fila),
   `_limpiar_detalle_extra()`; `_guardar_prefs_ui()` en `_on_tab`/`_on_filtro_selected` y
   `_aplicar_prefs_ui()` en `on_layer_opened`; `DIARY.REFERENCIAS` en
   `_aplicar_textos_estaticos`.
5. **i18n:** `DIARY.REFERENCIAS` = "Referencias"/"References" en `es.po`/`en.po`.
6. **`test_diario_persist.gd` (nuevo):** 2 fases con SaveManager M59 real — padre: backup byte
   a byte de slot 3 (`.save`+`.bak`), siembra (2 registros, estrella, estado VISTO, ui prefs
   4/"personajes"), `request_save` esperando `save_completed` por frames, `OS.execute`
   bloqueante del hijo; hijo: `load_slot(3)` verifica y re-serializa; padre restaura el slot
   previo + `SaveWriter.cleanup_orphan_tmp`. **0 fallos, EXIT 0** (con `read_stderr=false`;
   `true` colgaba el pipeline en Windows).
7. **Diagnostico fotografias:** grep global: **no existe emisor `FOTO_TOMADA`**;
   `photo_service.gd` solo `signal modo_foto_cambiado`; `fauna_registry.gd` tiene
   `signal especie_fotografiada` sin conectar al diario. Categoria vacia = **frente sin
   contenido (puente M56->M55 inexistente), NO bug de datos** -> documentado en 05 L53/L212,
   sin implementar.
8. **Regresion 4/4 verde:** validate 0/1 EXIT0 -> test_diario 0 EXIT0 -> test_diario_ui 89/0
   EXIT0 (SCRIPT ERROR `interaction_manager` = BUG-096 preexistente, zona kimi, no tocado)
   -> test_diario_persist 0 EXIT0.
9. **Docs:** 03 §9, 04 (tablas §1.1/§1.2 + Notas iteracion 3), 05 (7 flips ->
   **37 [x] / 3 [?] / 91 [ ]**), 06 (fuera de alcance), 07 (corrida §6 + pendientes §7);
   CHECKLIST-GLOBAL fila 55 -> 37/131; ESTADO-PARALELO (bloque de cierre); backlog L366 `[x]`.

## Archivos Modificados/Creados

- CREADO `game/isla-ancestral/scripts/diario/validate_diary.gd`
- CREADO `game/isla-ancestral/scripts/diario/test_diario_persist.gd`
- MODIFICADO `game/isla-ancestral/scripts/diario/diary_service.gd`
- MODIFICADO `game/isla-ancestral/scripts/ui/layers/diary_layer.gd`
- MODIFICADO `game/isla-ancestral/data/diario/diario_catalog.json`
- MODIFICADO `game/isla-ancestral/locales/es.po`, `locales/en.po`
- MODIFICADO `DOCUMENTACION/55-Diario-Del-Jugador/plan-actual/` (03, 04, 05, 06, 07)
- MODIFICADO `CHECKLIST-GLOBAL.md` (fila 55), `Mensajes entre modelos/ESTADO-PARALELO.md`,
  `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md`,
  `Logs/NUMEROS_DISPONIBLES.txt` (1345 consumido)
- CREADO este log, informe en el canal y mensaje de cierre al director

No tocado (restricciones canal 18): `ui_manager.gd` (s2), `interaction_manager.gd` (kimi),
`service_registry.gd` (agnes), M91, `quality.yml`, guia 08 (working tree ajeno). Sin push.
