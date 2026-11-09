# Reporte i18n / Localización — Isla Ancestral

**Modelo:** Crouton Alpha
**Fecha:** 2026-11-08
**Alcance:** `game/isla-ancestral/` — archivos `.gd`, `.tscn`, `.tres`, `.po`, `.csv`, `.translation`, `.json` de i18n

## 1. ¿Hay sistema de internacionalización configurado?

**Sí. Sistema propio M87 (doble implementación) + Godot no usado como sistema de traducciones.**

### Lo que existe

| Componente | Archivo | Rol |
|---|---|---|
| Autoload `Localization` | `game/isla-ancestral/project.godot:59` → `scripts/localization/localization_manager.gd` (377 líneas) | Núcleo real M87: carga `.po` con parser propio, traduce `MODULO.SECCION.CLAVE`, placeholders `{param}`, plurales `msgstr[N]`, formato `números/fechas/hora` por locale, validación `validar_catalogos()` / `obtener_estado_catalogos()`, cache, fallback a `es`, aviso único de faltantes, persistencia |
| Autoload duplicado legacy | `scripts/localizacion/localization_manager.gd` (82 líneas, 2.729 bytes vs 15.219 del nuevo) | Implementación anterior JSON: `data/localizacion/strings_*.json`. **No es el autoload activo** en `project.godot`, pero convive en repo |
| `LocaleUtils` | `scripts/localization/locale_utils.gd:8` (`class_name LocaleUtils`) | Tablas `es/en/pt`: separadores decimal/miles, orden fecha, reloj 24h/12h, nombres nativos |
| `RetraductorUI` | `scripts/localization/retraductor_ui.gd:1` | Re-traducción selectiva visible al cambiar idioma (salta invisibles), presupuesto 16,67 ms |
| `UiI18n` (puente M53↔M87) | `scripts/ui/i18n/ui_i18n.gd:17` | `traducir(clave)`, `meta_texto(nodo, clave)` via `set_meta("text_key",…)`, `retraducir()` |
| Auditoría y validación | `scripts/localization/auditor_claves.gd:18` (`AuditorClaves`), `scripts/localization/validador_po.gd:19` (`ValidadorPO`), `scripts/localization/glosario.gd:1` (`Glosario`), `scripts/localization/analizador_layout.gd:1` (`AnalizadorLayout`) | Detección código↔catálogo, `.po` UTF-8/BOM/Plural-Forms/placeholders, consistencia terminológica ES→EN, encaje/expansión de texto |
| Catálogos `.po` | `locales/es.po` (864 lín.), `locales/en.po` (860 lín.), `locales/pt.po` (911 lín.) | 276 claves no-cabecera cada uno, UTF-8, cabeceras `Content-Type`/`Language`/`Plural-Forms` presentes |
| JSON decoy / legacy | `data/localizacion/strings_es.json`, `strings_en.json`, `strings_pt.json` (175 lín. c/u, 170 cadenas c/u) + `data/localization/glosario.json` (2.445 bytes) | Catalogo anterior. Comentario en `.po` (es:822, en:818, pt:869) dice explícitamente “catálogo decoy”. Glosario sí se usa: `Glosario.RUTA_DEFECTO = "res://data/localization/glosario.json"` (`glosario.gd:18`) |
| Idiomas soportados | `localization_manager.gd:15` → `LOCALES_SOPORTADOS := ["es","en","pt"]`, `LOCALE_DEFECTO := "es"` (`:16`), `RUTA_CATALOGOS := "res://locales/"` (`:17`) | 3 idiomas |
| `TranslationServer` | `localization_manager.gd:42-46, 132` (`add_translation`, `set_locale`) | Registra los `.po` parseados en `TranslationServer` para `tr()` estándar, pero **casi nadie lo usa**: solo 4 ocurrencias de `tr(` nativo en todo `scripts/` (fuera de addons) vs 71 `traducir_clave` + 143 `_t(` en 1586 `.gd` |
| Godot `[internationalization]` | `project.godot` | **Ausente.** Secciones reales: `application`, `autoload`, `display`, `gdscript`, `input`, `layer_names`, `physics`, `plugins`, `rendering` — **no hay `[internationalization]`, ni `translation/remaps`, ni `fallback_locale`**. Consecuencia: sin remap nativo de `.po` a `.translation`, sin locale fallback Godot, sin carga en export presets, sin `OS.get_locale_language()` a nivel engine. El sistema es 100% manual vía `localization_manager.gd:_cargar_catalogos()` |

### Tests de localización (evidencia de que el sistema se usa y se testea)

- `scripts/localization/test_localization.gd`, `test_localizacion_iter2.gd`, `test_localizacion_iter3.gd`, `test_localizacion_iter4.gd`, `test_localizacion_iter6.gd`, `test_validador_po_m87.gd`, `test_placeholders_plurales_m87.gd`, `test_catalogo_exhaustivo_m87.gd`
- `scripts/ui/test_ui_i18n_m53.gd` (14 `set_locale`), `scripts/ui/test_diario_ui.gd:45-46,278-279`, `scripts/clock/test_reloj_localizacion.gd:57-68`
- `scripts/fonts/test_glifos_i18n_m88.gd`

### Presencia de archivos por tipo

- `.po`: 3 (`es.po`, `en.po`, `pt.po`) — OK, paridad perfecta (ver §3)
- `.translation` (binarios Godot): **0 encontrados**
- `.csv`: **0 encontrados**
- `.tscn` con texto literal: 69 `.tscn` totales, 15 con heurística de texto literal (ver §2, la mayoría son `FPS: 0` debug o addons)
- `.tres` con `*_clave`: 479 `.tres`, 80 claves distintas declaradas

## 2. ¿Hay textos hardcodeados en lugar de usar el sistema de traducciones?

**Sí. Hay deuda hardcodeada real, aunque contenida. El sistema existe pero no cubre toda la UI.**

### 2.1 `.gd` — asignaciones `.text = "..."` con literal español (49 candidatos, fuera addons ~25)

Metodología: regex `\.text\s*=\s*"([^"]{4,})"` con ≥3 palabras o carácter no-ASCII, excluyendo claves con `.` y fixtures de test. Resultados destacados (producción, no test/debug):

| Archivo:línea | Texto hardcodeado | Observación |
|---|---|---|
| `scripts/enchantment/shaman_ui.gd:33` | `"Encantamientos del Chaman"` | Título de panel sin clave `ENCHANT.*` |
| `scripts/enchantment/shaman_ui.gd:37,174` | `"Selecciona una herramienta y un encantamiento"` | Duplicado en 2 líneas |
| `scripts/enchantment/shaman_ui.gd:244` | `"Encantamiento aplicado con exito!"` | Feedback sin clave |
| `scripts/enchantment/shaman_npc.gd:87` | `"Chamán"` (nombre NPC) | Nombre propio debería ser clave |
| `scripts/houses/casas_panel.gd:34` | `"Casas del Jugador"` | Título sin clave |
| `scripts/houses/casas_panel.gd:60,65,80` | `"HouseManager no disponible"`, `"Sin casa registrada"`, `"Etapa Máxima"` | Mensajes sin clave |
| `scripts/mapa/full_map_layer.gd:65` | `"Mapa de la Isla"` | Título sin clave |
| `scripts/mapa/full_map_layer.gd:101` | `"Leyenda / Filtros:"` | Label sin clave |
| `scripts/ui/donation_panel.gd:41,83,93,128` | `"Museo — Donaciones"`, `"Museo — Donar a: "`, `"No hay items donables para esta exposición."`, `"¡Gracias! Donaste: "` | Panel completo sin claves |
| `scripts/ui/museo_sign.gd:39` | `"Museo de Aurora"` | Señal sin clave |
| `scripts/crafting/crafting_ui.gd:209` | `"→ %s"` | Formato sin clave (el `.po` sí tiene `M68.SIGN.*` para este patrón) |
| `scripts/dialogos/ui/dialogue_ui.gd:503` | `"pág %d/%d"` | Paginación sin clave |
| `scripts/ui/hud/clock_widget.gd:11` | `"%s %d, %02d:%02d"` | Formato de fecha/hora **hardcodeado**, ignora `LocaleUtils.format_date/format_hora` |
| `scripts/shops/shop_ui.gd:202,225` | `"%s — %d AO (x%d)"` | Formato compra/venta sin clave (existe `TIENDAS.COMPRA_INFO`/`VENTA_INFO` en `.po` pero este path lo compone a mano) |
| `scripts/ui/layers/credits_layer.gd:225,296` | `"[center](catálogo de créditos no disponible)[/center]"`, `"Tamaño: %s"` | Textos de créditos sin clave |
| `scripts/debug/panels/panel_entidades.gd:116,126`, `panel_mundo.gd:116,124` | `"IA: n/d (sin NPC seleccionado)"`, `"Hora: n/d (M29 no disponible)"` | Debug: aceptable no traducir, pero igual son literales |

Descartados (no son deuda): `scripts/clock/caso_reloj.gd:37`, `preview_reloj.gd:104` (comentarios de escena de prueba), `bench_recorder.gd:185` (diagnóstico), `qa_texto_grande_rf27.gd:45` (fixture de glifos), addons `gdUnit4` (terceros).

Positivos: `traducir_clave` se usa en 27 archivos de `scripts/`, `_t(` en 143 sitios, `RetraductorUI` + `UiI18n.meta_texto` fuerzan a pasar por el sistema cuando se usa. Pero los archivos de §2.1 **no llaman** a ninguno.

### 2.2 `.tscn` — texto literal en escenas

15 `.tscn` con `text = "..."` literal (≥2 palabras o acento). De esos, producción real: `scenes/test_arquitectura.tscn` (`"Cargando test..."`), `scenes/debug/debug_menu.tscn` (`"Debug Menu — Isla Ancestral"`). El resto es `scenes/main*.tscn` con `"FPS: 0"` (debug, aceptable) o addons `gdUnit4` (terceros). No hay un `text_key` en metadato de ningún `.tscn` del juego en el muestreo — el contrato `RetraductorUI.clave_de` (`text_key`/`tooltip_text_key`/`tr_key`) se declara **desde código** vía `UiI18n.meta_texto`, no en escena.

### 2.3 `.tres` — claves declaradas que no llegan al `.po` (ver §3)

80 claves distintas en `*.tres` (`*_clave`), 56 sin entrada en ningún `.po`. Es deuda de catálogo, no “hardcodeo” literal, pero el efecto en pantalla es el mismo: texto en español del recurso o clave cruda.

### 2.4 Patrones mixtos

- `SETTINGS.HORAS_H = "%d horas"` (`es.po:86`) usa `printf` mientras el resto usa `{llaves}` — `ValidadorPO` avisa mezcla (R12) pero el `.po` lo conserva.
- `npc.catalina` (`es.po:201`) y `eventos.historia_c*_nombre/desc` (`es.po:824-864`) usan minúsculas y no cumplen `MODULO.SECCION.CLAVE` — documentados como excepción en `validador_po.gd:30` y `auditor_claves.gd`, pero rompen la convención RF20.

## 3. ¿Hay archivos de traducción incompletos o faltantes?

### 3.1 Paridad entre los 3 `.po`: PERFECTA en claves, vacías y cabecera

Medido por regex `^msgid "([^"]*)"` + diff de conjuntos:

- `es.po`: 277 entradas (276 no-cabecera) · `en.po`: 277 · `pt.po`: 277
- `es - en`: **∅** · `es - pt`: **∅** · `en - es`: **∅** · `pt - es`: **∅**
- `msgstr ""` vacío: **0** en los 3
- Cabeceras: los 3 traen `Content-Type: text/plain; charset=UTF-8`, `Language: es/en/pt`, `Plural-Forms: nplurals=2; plural=(n != 1)` (es:5, en:5, pt:5; pt usa `n > 1` en `pt.po:5`, correcto para portugués)

Esto contradice `data/control_final/estado_release.json:22` (“6 idiomas sin claves rotas necesita el build”) — el release state habla de 6 idiomas, el código solo soporta 3 (`localization_manager.gd:15`).

### 3.2 “Idénticos” que son realmente cognados vs no-traducidos

- `es == en` idénticos: **21** → `ITEMS.SE_OFRECEN` (plural), `SETTINGS.SLOTS`, `npc.catalina`, `M68.SIGN.*` (11 plantillas `→ {destino} · {metros} m`), `M68.TRIP.CURRENCY` (`AO`), `M68.TRIP.HORAS_MINUTOS`, `M68.TRIP.HORAS/MINUTOS/SEGUNDOS` (forma singular con `{n}`), `EQUIP.EQUIPADO`. Todas están exentas con `#. no-traducir:` o en `ValidadorPO.NO_TRADUCIBLES` (`validador_po.gd:43`) → **no es deuda real**.
- `es == pt` idénticos: **63** → cognados legítimos (`HUD.VIDA`, `SETTINGS.PAUSA`, `SETTINGS.DISPOSITIVO_SALIDA`, etc.) y plantillas `M68.SIGN.*`. La mayoría lleva `#. no-traducir: cognato legítimo (PT=ES)` en `pt.po` (`:18, :28, :43`). En `pt.po` hay al menos 6 exenciones explícitas auditables.

### 3.3 Faltantes reales (fuera del `.po`)

1. **56 claves de `.tres` sin `.po`** — `AuditorClaves` las detecta (`auditor_claves.gd:73-82`, `RE_CLAVE_RECURSO`), pero **no bloquean el `ok`** (`auditor_claves.gd:153-156`: “el arreglo es de CONTENIDO… convertirlo en rojo dejaría el CI en rojo” → se reportan sin fallar). Muestra: `aurora_boreal_nombre/desc`, `niebla_faro_nombre/desc`, `concurso_minero_*`, `desafio_agricola_*`, `torneo_pesca_*`, `feria_colmena_*`, `festival_invierno/luces/otono/primavera/verano_*`, `ceremonia_templos_*`, `vigilia_luna_*`, `regalo_puerta_*`, `visita_sorpresa_*` (+26 más, total 56). La auditoría documenta “44 claves en 25 `.tres`, 30 ausentes” (2026-10-21) — hoy son 80/56.
2. **JSON decoy `data/localizacion/strings_*.json`** (170 cadenas c/u): no es fuente de runtime del autoload activo. Comparación con `.po`: el JSON contiene claves que el `.po` ya aspiró (`eventos.historia_c*` — ver comentario `es.po:821-823`) y carece de claves `.po` posteriores. Su presencia como “catálogo” es una **trampa de doble fuente**: un traductor puede editar el JSON y no ver efecto. `LocalizationManager` nuevo (`.po`) y legacy (JSON) conviven con APIs distintas (`traducir_clave` vs `get_texto`, `set_locale` vs `set_idioma`).

### 3.4 Idiomas “anunciados” que no existen como catálogo

- `data/marketing/trailer_spec.json:10` declara `idiomas_subtitulos: ["es","en","pt","de","fr","it"]`
- `data/support/faq.json:6`, `data/community/faq.json:4`, `data/legal/creditos.json:52`, `data/localization/glosario.json:4` declaran `["es","en"]`
- `data/control_final/estado_release.json:22` habla de “6 idiomas”
- Solo `es/en/pt` tienen `.po` real. `de/fr/it` **no existen** como catálogo.

## 4. ¿Hay preferencias de idioma persistidas?

**Sí. Persistencia REAL en M60 `DataStore` + `GestorConfig` (no es placeholder).**

| Flujo | Archivo:línea | Detalle |
|---|---|---|
| Lectura al arranque | `localization_manager.gd:48-65` (`_restaurar_locale_guardado`), `:68-74` (`_leer_locale_m60`) | Orden: `config` M60 → sugerencia del SO → `es`. Solo aplica si está en `LOCALES_SOPORTADOS` |
| Sugerencia del SO | `localization_manager.gd:77-81` (`OS.get_locale_language()`) | Si el SO es `es/en/pt`, se aplica **y se persiste** (`:63`) sin esperar confirmación UI — el comentario remite la confirmación a M53 |
| Escritura | `localization_manager.gd:86-90` (`set_locale_persistente`), `:98-104` (`set_locale` → `_persistir_locale`), `:365-377` (`_persistir_locale`) | `DataStore.cargar_config()` → `general["idioma"] = locale` → `DataStore.guardar_config(config)` |
| Defaults | `scripts/datos/gestor_config.gd:17` (sección `general`), `:39-41` (`"general": {"idioma": "es"}`) | `GestorConfig.DEFAULTS_BASE` incluye idioma; `RUTA_CONFIG = "user://config.cfg"` (`:13`) vía `WriterAtomico` checksum |
| `GameSettings` | `scripts/core/game_settings.gd` | **NO guarda idioma.** `user://settings.cfg` solo `controls/audio/video` (`:37-47`). El comentario en `localization_manager.gd:50-51` explica: “el núcleo consultaba GameSettings que no existe — placeholder honesto” → migrado a M60 |
| `DataStore` | `scripts/datos/data_store.gd:421-431` (`guardar_config`/`cargar_config` → `GestorConfig`) | Delega a `GestorConfig`, atómico, con señal `config_guardada` |
| `TranslationServer` | `localization_manager.gd:132` | `set_locale(locale)` en cada cambio, más señal `locale_changed` (`:13`) para re-render (`RetraductorUI`, `UiI18n.conectar_locale`) |

Implicación: la preferencia sobrevive sesiones y se sugiere del SO en primer arranque, pero **no hay selector de idioma propio en `GameSettings`** — el cambio de idioma depende de que alguna pantalla (M53 `SETTINGS.IDIOMA`, `es.po:26-30`) llame a `Localization.set_locale_persistente()`. Verificado por tests: `test_ui_i18n_m53.gd:37-187`, `test_settings_audio_roundtrip.gd:42-43`.

## 5. Mejoras sugeridas (2)

### Mejora 1 — Unificar en una sola fuente y activar Godot i18n nativo

**Problema:** doble stack `.po` (runtime) vs `strings_*.json` (decoy) + doble `localization_manager` (`localization` vs `localizacion`) + cero sección `[internationalization]` en `project.godot`. Un traductor puede editar el JSON y no ver efecto; un build de export no sabe de los `.po`.

**Acción:**
1. Borrar o archivar `scripts/localizacion/localization_manager.gd` y `data/localizacion/strings_*.json` tras migrar cualquier clave faltante a `.po` (conservar solo `data/localization/glosario.json`).
2. Generar `.translation` desde los `.po` con `msgfmt`/Poedit y registrarlos en `project.godot [internationalization] translation/remaps` + `locale/fallback="es"`, o mover el parser propio a tool de build. Así `tr()` nativo deja de ser “4 usos” y el `TranslationServer` del runtime pasa de espejo a fuente primaria.

**Impacto:** elimina la trampa decoy, Habilita PO→`.translation` en CI, reduces 82 líneas de código legacy y 3 JSON de 175 líneas a una sola vía.

### Mejora 2 — Cerrar la deuda hardcodeada con auditoría bloqueante y completar `.tres` → `.po`

**Problema:** §2.1 muestra ~25 literales de producción fuera del sistema (panels de `shaman_ui`, `casas_panel`, `full_map_layer`, `donation_panel`, `museo_sign`, `clock_widget`, `shop_ui`) y §3.3 muestra 56 claves `.tres` sin `.po` que el auditor reporta sin fallar.

**Acción:**
1. Mover los literales de §2.1 a claves `.po` (`ENCHANT.*`, `CASA.*`, `MAPA.*`, `MUSEO.*`, etc.) y reemplazar `.text = "…"` por `UiI18n.meta_texto(nodo, "CLAVE")` o `traducir_clave("CLAVE")`. Para `clock_widget.gd:11` y `shop_ui.gd:202,225`, usar `LocaleUtils.format_date/format_hora/format_number` y las claves existentes `TIENDAS.COMPRA_INFO`/`VENTA_INFO`.
2. Cambiar `auditor_claves.gd:_finalizar` para que `claves_recurso_sin_catalogo` entre en `inf["ok"]` (hoy no entra, `:175`), y añadir las 56 claves `.tres` faltantes a `es.po`/`en.po`/`pt.po`.
3. Añadir a CI el `ValidadorPO.validar_par(es,en)` y `validar_par(es,pt)` + `AuditorClaves.auditar("res://scripts", "res://locales/es.po")` como gate (hoy existen como tests, pero el CI no los corre como blocking por el `ok` parcial).

**Impacto:** cero texto fuera del catálogo, cero `.tres` huérfanos, y la paridad que hoy medimos perfecta en `.po` (277/277) pasaría a medirse contra el universo real código+recursos+escenas.

## Conclusión final

**El sistema de internacionalización está configurado y es de nivel producción para lo que cubre: sí, M87 es real y no un placeholder.** Autoload `Localization` (377 líneas, `project.godot:59`) carga 3 catálogos `.po` (276 claves c/u, paridad perfecta, cero `msgstr` vacías) con parser propio, plurales, placeholders, formato `números/fechas/hora` por locale y persistencia real en M60 (`gestor_config.gd:40` → `user://config.cfg`, con sugerencia del SO en primer arranque). Tests extensos (M87 iter. 2-6, M53, M88) y herramientas de auditoría (`AuditorClaves`, `ValidadorPO`, `Glosario`, `AnalizadorLayout`) que detectan código↔catálogo y `.tres`↔catálogo.

**Pero la cobertura es incompleta y la fuente es doble:** (1) no hay sección `[internationalization]` en `project.godot`, cero `.translation`, cero `.csv` — el engine no participa; (2) conviven `scripts/localization/` (activo, `.po`) y `scripts/localizacion/` + `data/localizacion/strings_*.json` (decoy legacy, 170 cadenas c/u) — editar el JSON no tiene efecto; (3) ~25 literales hardcodeados de producción fuera del sistema (`scripts/enchantment/shaman_ui.gd:33-244`, `houses/casas_panel.gd:34-83`, `mapa/full_map_layer.gd:65-310`, `ui/donation_panel.gd:41-138`, `ui/hud/clock_widget.gd:11`, `shops/shop_ui.gd:202,225`, etc.); (4) 56 claves declaradas en 479 `.tres` sin entrada en ningún `.po`, que el auditor reporta sin bloquear CI; (5) `de/fr/it` anunciados en marketing/FAQ/release state no tienen catálogo.

**Preferencias de idioma: sí persistidas.** `Localization._leer_locale_m60` / `_persistir_locale` (`localization_manager.gd:68-377`) sobre `DataStore` → `GestorConfig` sección `general["idioma"]` (default `es`). `GameSettings` (`user://settings.cfg`) **no** guarda idioma — el histórico placeholder fue reemplazado por M60.

**Prioridad:** aplicar las 2 mejoras de §5 (unificar fuente + activar Godot nativo; migrar literales a `.po` y hacer bloqueante la auditoría `.tres`) antes de añadir idiomas nuevos. Con eso, la paridad 277/277 pasaría de “tres archivos iguales” a “todo el juego traducible en `es/en/pt` sin texto fuera del catálogo”.
