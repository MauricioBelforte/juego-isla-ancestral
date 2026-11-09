# Reporte de Internacionalización (i18n) — Isla Ancestral

**Autor:** Glyph Cluster  
**Fecha:** 2026-11-09  
**Alcance:** `game/isla-ancestral/scripts/`, `game/isla-ancestral/locales/`, `game/isla-ancestral/data/localizacion/`, `game/isla-ancestral/project.godot`, `docs/i18n/`

---

## Resumen ejecutivo

El proyecto **sí tiene un sistema de internacionalización configurado y operativo** (M87), basado en catálogos `.po` cargados por un autoload `Localization` y un puente de UI (`UiI18n` + `RetraductorUI`). Soporta `es`, `en` y `pt`, con persistencia de idioma vía `DataStore` (M60). Sin embargo, coexiste un **sistema legado/dual** (JSON `strings_*.json` + autoload/manager alternativo en `scripts/localizacion/`), hay **adopción parcial** en la UI (muchos textos siguen hardcodeados o sin clave), y la documentación interna (`docs/i18n/DEUDA-I18N.md`) reconoce deuda viva (divergencias JSON↔PO, claves solo-JSON no traducibles en runtime, y decisiones arquitectónicas pendientes).

---

## 1) ¿Hay sistema de internacionalización configurado?

**Sí.** Existe un sistema principal (M87) y componentes asociados:

| Componente | Archivo | Evidencia (líneas) |
|---|---|---|
| Autoload de localización (runtime .po) | `game/isla-ancestral/scripts/localization/localization_manager.gd` | `extends Node` (L11), sin `class_name` por ser autoload (L9), `locales` soportados `["es","en","pt"]` (L15), parseo `.po` y registro en `TranslationServer` (L35-L47, L270-L361), API `set_locale`/`get_locale`/`tr_key`/`traducir_clave`/`format_*` (L85-L231). |
| Registro como autoload | `game/isla-ancestral/project.godot` | `[autoload]` → `Localization="*res://scripts/localization/localization_manager.gd"` (L59). |
| Catálogos de traducción | `game/isla-ancestral/locales/es.po`, `en.po`, `pt.po` | Existen los 3 archivos; conteo de `msgid` (excl. header) = **276 por idioma** (medido 2026-11-09). `es.po`/`en.po`/`pt.po` con `Content-Type: text/plain; charset=UTF-8` y `Plural-Forms` (p.ej. `es.po` L1-L5, `pt.po` L1-L5). |
| Puente UI M53↔M87 | `game/isla-ancestral/scripts/ui/i18n/ui_i18n.gd` | `class_name UiI18n` (L17), resuelve autoload `Localization` (L28-L33), traduce claves (`traducir` L38-L44, `traducir_param` L47-L53), declara metadatos `text_key`/`tooltip_text_key` (L59-L72), re-traduce vía `RetraductorUI` y se suscribe a `locale_changed` (L76-L98). |
| Re-traductor de UI | `game/isla-ancestral/scripts/localization/retraductor_ui.gd` | `class_name RetraductorUI` (L1), re-traduce nodos con metadatos `text_key`/`tooltip_text_key` sobre props `text/placeholder_text/tooltip_text` (L17-L28, verificado por búsqueda). |
| Localizador de transporte (M68) | `game/isla-ancestral/scripts/transporte/transport_localizer.gd` | `class_name TransportLocalizer` (L28), usa convención `M68.*`, lee `.po` de forma pura para verificar sin efectos laterales y delega formatos a `LocaleUtils` (L1-L27, L134-L166, L249-L285). |
| Formatos por locale | `game/isla-ancestral/scripts/localization/localization_manager.gd` + `LocaleUtils` (referenciado) | Delegación de números/fechas/hora a `LocaleUtils` (L221-L230); plural `es/en/pt` con `nplurals=2` (L357-L361). |

**Configuración en `project.godot`:** no se encontró una sección `[internationalization]` con `locale/translations` declaradas explícitamente (búsqueda en `project.godot` solo arrojó menciones en el listado de warnings del linter, L171). La carga de traducciones se realiza **en código** por el autoload M87 (`_cargar_catalogos()` crea `Translation` y llama `TranslationServer.add_translation`, `localization_manager.gd` L35-L47, L132).

**Conclusión (1):** el sistema i18n está configurado (autoload + `.po` + API + puente UI). Falta integración declarativa en `project.godot` `[internationalization]` (las traducciones se registran por script), lo cual es válido pero menos visible para el editor.

---

## 2) ¿Hay textos hardcodeados en lugar de usar el sistema de traducciones?

**Sí, hay adopción parcial.** Se observan dos patrones:

### 2.1 Adopción del sistema i18n (positivo)
- **34 usos** de `UiI18n.traducir` / `UiI18n.meta_texto` / `text_key` / `tooltip_text_key` en `scripts/ui/**/*.gd` (conteo 2026-11-09).
- Archivos UI que integran el puente: `scripts/ui/core/ui_manager.gd`, `scripts/ui/i18n/ui_i18n.gd`, `scripts/ui/layers/dialog_layer.gd`, `scripts/ui/layers/diary_layer.gd`, `scripts/ui/layers/equipment_layer.gd`, `scripts/ui/layers/pause_layer.gd`, `scripts/ui/widgets/interact_prompt.gd`.
- Ejemplos de integración: `equipment_layer.gd` y `interact_prompt.gd` usan metadatos/UiI18n (verificados por presencia de `text_key`/`UiI18n`); `ui_manager.gd` expone hooks `_conectar_m87` / `_on_locale_changed_ui` (`test_ui_i18n_m53.gd` L163-L165).

### 2.2 Textos literales / hardcodeados (deuda)
- **~135 asignaciones `.text =`** en `scripts/ui/**/*.gd` vs. 34 usos de claves/metadatos i18n (medición aproximada 2026-11-09): indica que una parte relevante de la UI aún asigna texto sin pasar por el sistema de claves.
- Ejemplos concretos detectados:
  - `scripts/ui/layers/credits_layer.gd`: múltiples `.text = "Créditos"`, `"Isla Ancestral"`, `"Programa y Dirección"`, `"Motor"`, `"Arte Visual"`, `"Audio"`, `"Agradecimientos"`, `"Plataformas"`, `"Licencias de terceros"` (búsqueda `Select-String` sobre `scripts/ui/**/*.gd`, líneas reportadas en la inspección; al menos 8 ocurrencias literales en ese archivo).
  - `scripts/ui/widgets/hotbar_widget.gd`: al menos 1 asignación `.text = "..."` literal detectada.
  - `scripts/ui/hud/clock_widget.gd`, `scripts/ui/hud/resource_counter.gd`, `scripts/ui/layers/dialog_layer.gd`, `scripts/ui/layers/diary_layer.gd`, `scripts/ui/layers/inventory_layer.gd`, `scripts/ui/layers/menus_layer.gd`, `scripts/ui/widgets/action_prompt_overlay.gd`, `scripts/ui/widgets/resource_counter.gd`: aparecen en el muestreo de `.text = "..."` (requiere revisión caso a caso; algunos pueden ser placeholders técnicos).
- **Uso directo de `tr()` / `TranslationServer.translate()`**: la búsqueda global encontró usos principalmente en **tests/QA/validadores** (p.ej. `scripts/dialogos/test_*`, `scripts/ui/diag_ui_en.gd`, `scripts/transporte/test_*`, `scripts/localization/test_*`), **no** como patrón dominante de producción en UI. Esto sugiere que la UI de producción tiende a usar `UiI18n` o literales, más que el `tr()` nativo de Godot.

**Conclusión (2):** hay textos hardcodeados y cobertura desigual. El sistema existe, pero no está aplicado de forma uniforme en toda la UI (evidencia: ratio `34` usos i18n vs `~135` asignaciones `.text`).

---

## 3) ¿Hay archivos de traducción incompletos o faltantes?

### 3.1 Catálogos `.po` (sistema M87, runtime)
- **Presentes:** `locales/es.po`, `locales/en.po`, `locales/pt.po` (276 `msgid` c/u, excl. header).
- **Paridad estructural básica:** mismo conteo de `msgid` en los tres (276/276/276). No se detectó ausencia de archivos `.po` de los locales soportados declarados en M87 (`LOCALES_SOPORTADOS = ["es","en","pt"]`, `localization_manager.gd` L15).
- **Calidad de contenido (deuda documentada):** `docs/i18n/DEUDA-I18N.md` (L1-L56) reporta, para HEAD `0d750af` / 2026-11-06:
  - Cruzado JSON↔PO: **159 comunes / 11 solo-JSON / 117 solo-PO** (L9-L15, L22-L27).
  - **4 copias ES→PT sospechosas** (`SETTINGS.HORAS_1`, `HORAS_H`, `MIN_1`, `MIN_M`) — cognatos numéricos a revisar (L17, L33).
  - **2 claves VOLVER\*** (`SETTINGS.VOLVER_TITULO`, `SETTINGS.VOLVER_TITULO_CONFIRMAR`) presentes en los 3 `.po` pero ausentes en `strings_*.json` (divergencia de doble catálogo, L26, L31).
  - 0 placeholders discrepantes en claves comunes, 0 duplicados `msgid`, plurales PT intactos (L16-L20).

### 3.2 Catálogos JSON (sistema legado/dual)
- **Presentes:** `game/isla-ancestral/data/localizacion/strings_es.json`, `strings_en.json`, `strings_pt.json` (L: 8566/8121/8540 bytes; 2 claves de primer nivel en `strings_es.json` según inspección rápida — estructura distinta al `.po`).
- **Problema:** existe un **autoload/manager alternativo** `game/isla-ancestral/scripts/localizacion/localization_manager.gd` (carpeta `localizacion/`, con ñ en el nombre de carpeta según convención histórica del repo) que carga `data/localizacion/strings_*.json` (L11-L13, confirmado). `docs/i18n/DEUDA-I18N.md` lo identifica como deuda H-1: `Localization` (.po, canónico) vs `LocalizationManager` (JSON, sin consumidores de producción claros; preloadado por `_colector_sintaxis.gd`) (L35). **Riesgo:** confusión de fuente de verdad y claves “solo-JSON” no traducibles en runtime M87 (L30).

### 3.3 Claves invocadas vs. catálogo
- `test_ui_i18n_m53.gd` (L1-L222) verifica resolución de claves `EQUIP.*`, `UI.INTERACTUAR`, re-traducción `locale_changed`, tooltips y subtítulos — indica cobertura de esas áreas.
- `localization_manager.gd` advierte **una vez por clave ausente** en sesión (`_avisar_faltante`, L190-L206) y expone `claves_faltantes()`/`validar_catalogos()`/`obtener_estado_catalogos()` (L203-L268) — mecanismo útil para detectar incompletitud, pero depende de ejecución.

**Conclusión (3):** los `.po` de `es/en/pt` existen y están alineados en cantidad, pero hay **deuda de completitud/coherencia** (divergencia JSON↔PO, claves solo-JSON, 4 copias ES→PT por revisar, 2 claves VOLVER* divergentes) documentada en `docs/i18n/DEUDA-I18N.md`. No faltan archivos `.po` para los locales soportados; sí falta consolidar la fuente de verdad (PO canónico vs JSON legado).

---

## 4) ¿Hay preferencias de idioma persistidas?

**Sí.** La persistencia está implementada en M87 con integración a M60 (`DataStore`):

- **Guardar:** `set_locale_persistente(locale)` persiste al cambiar idioma (`localization_manager.gd` L86-L91, L98-L104 llama `_persistir_locale` L365-L377). Escribe en `DataStore.guardar_config()` bajo `config["general"]["idioma"]` (L372-L377).
- **Restaurar al inicio:** `_restaurar_locale_guardado()` en `_ready()` (L29-L31, L48-L65) lee `DataStore.cargar_config()` → `general.idioma` (L68-L74). Si no hay valor guardado, usa sugerencia del SO (`OS.get_locale_language()`) si está soportada y la persiste (L56-L64, L77-L81); fallback a `LOCALE_DEFECTO = "es"` (L16, L65).
- **Dependencia:** requiere autoload `DataStore` (registrado en `project.godot` L89: `DataStore="*res://scripts/datos/data_store.gd"`). Si `DataStore` está ausente o no expone `guardar_config/cargar_config`, M87 emite warning y no persiste (`L69-L71`, `L368-L371`).
- **Autoloads relevantes en orden:** `Localization` está en L59 de `project.godot`; `DataStore` en L89. Ambos son autoloads normales (`*`), por lo que el orden de carga depende de la declaración; la lectura de M60 ocurre en `_ready()`/restauración, lo cual suele ser seguro, pero conviene verificar que `DataStore` esté disponible cuando `Localization._ready()` se ejecute.

**Conclusión (4):** las preferencias de idioma **sí se persisten** (`general.idioma` vía M60 DataStore) y se restauran al arranque, con fallback al idioma del SO y luego a español.

---

## 5) Dos mejoras sugeridas

1. **Unificar la fuente de verdad i18n y eliminar el dualismo JSON/PO (deuda H-1).**  
   - **Acción:** definir `.po` (`locales/*.po` + autoload `Localization`, M87) como **único** runtime canónico; migrar o deprecar `game/isla-ancestral/data/localizacion/strings_*.json` y `game/isla-ancestral/scripts/localizacion/localization_manager.gd` (JSON). Resolver las 11 claves solo-JSON, 2 VOLVER* divergentes y el cruzado 159/11/117 documentado en `docs/i18n/DEUDA-I18N.md` (L22-L35).  
   - **Impacto:** reduce confusión, evita claves “traducidas” en JSON pero invisibles en runtime M87, y simplifica validación CI.  
   - **Verificación:** ejecutar `python -X utf8 scripts/validar_i18n_integridad.py` (DEUDA-I18N L39-L45) tras la consolidación y actualizar `DEUDA-I18N.md`.

2. **Completar la adopción de claves en UI y endurecer la detección de hardcodes.**  
   - **Acción:** migrar textos literales de UI (p.ej. `scripts/ui/layers/credits_layer.gd` y otros detectados por `.text = "..."`) a claves `M87`/`UiI18n.meta_texto`/`text_key`, con entradas en `es/en/pt.po`. Añadir un chequeo automático (script CI o test headless) que falle ante nuevos literales jugador-visibles en `scripts/ui/**` sin `UiI18n`/`text_key`/`tr_key`/excepción explícita.  
   - **Impacto:** mejora cobertura real de idiomas (especialmente `en/pt`), habilita cambio de idioma en vivo en más pantallas (patrón ya usado por `UiI18n`/`RetraductorUI`/`locale_changed`), y evita regresiones.  
   - **Referencia:** patrón existente en `scripts/ui/i18n/ui_i18n.gd` (L59-L98) y cobertura de prueba en `scripts/ui/test_ui_i18n_m53.gd`.

---

## Conclusión final

La internacionalización en `game/isla-ancestral` **está implementada a nivel de sistema** (M87: autoload `Localization`, `.po` para `es/en/pt`, API de traducción/formato/plurales, puente UI `UiI18n`+`RetraductorUI`, y persistencia de preferencia de idioma vía `DataStore`/M60). El estado general es **funcional pero con deuda técnica**: (1) existe un sistema dual JSON legado que compite con el canónico `.po`; (2) la UI tiene adopción parcial (34 usos i18n vs ~135 asignaciones `.text` en `scripts/ui`), con textos hardcodeados visibles (ej. `credits_layer.gd`); (3) `docs/i18n/DEUDA-I18N.md` documenta divergencias JSON↔PO (159/11/117), 4 copias ES→PT y 2 claves VOLVER* a conciliar. **Prioridad recomendada:** consolidar PO como fuente única y expandir el uso de claves en UI, apoyándose en las APIs y tests ya existentes (`UiI18n`, `RetraductorUI`, `test_ui_i18n_m53.gd`, `validar_i18n_integridad.py`).