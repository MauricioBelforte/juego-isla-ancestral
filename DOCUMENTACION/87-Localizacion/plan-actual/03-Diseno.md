**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13 (correcciones doc↔código de la iter. 5; texto original: Deepseek V4 Flash / OpenCode, 2026-08-26)

# 03-Diseno.md — Módulo 87: Localización

## 1. Arquitectura del módulo

```
Localización (M87)
├── LocalizationManager (autoload "Localization")
│   ├── Idioma activo (String, ej: "es", "en")
│   ├── Catálogos registrados en TranslationServer
│   ├── Cache de traducciones frecuentes (Dictionary "clave|n")
│   ├── Avisos de clave ausente deduplicados (_avisadas)
│   ├── Señal: locale_changed(locale)
│   ├── API:
│   │   ├── set_locale(locale) / set_locale_persistente(locale)
│   │   ├── get_locale() / get_locale_display_name() / locales_disponibles()
│   │   ├── tr_key(module, section, key, params, n)
│   │   ├── traducir_clave(clave, params, n)
│   │   ├── tr_ctx(contexto, module, section, key, params)
│   │   ├── format_text(text, params)
│   │   ├── format_number(value) / format_date(d) / format_hora(h,m)
│   │   ├── validar_catalogos() / obtener_estado_catalogos() (dev/test)
│   │   └── claves_faltantes() (dev/test, iter. 5)
│   └── Fallback: clave -> es.po -> clave literal
├── LocaleUtils (class_name, RefCounted estático)
│   ├── Formato de números por idioma (comas/puntos)
│   ├── Formato de fechas por idioma (orden d/m/Y vs m/d/Y)
│   └── Nombres nativos de idiomas ("Español", "English")
├── ValidadorPO (class_name, dev/CI — iter. 5)
│   ├── Bytes: BOM (§28), CRLF (RN10), UTF-8 válido
│   ├── Cabecera: Content-Type / Language / Plural-Forms
│   ├── Estructura: msgid↔msgstr, plurales desde 0, duplicados, sintaxis
│   ├── Convención de claves (RF20) con excepciones documentadas
│   ├── Coherencia entre idiomas: faltantes, placeholders, sin traducir
│   └── Reglas R1-R13 (un catálogo) y P1-P5 (par fuente↔traducción)
├── AuditorClaves (class_name, dev/CI — iter. 5)
│   ├── Claves usadas en código y ausentes del catálogo
│   ├── Claves del catálogo sin uso (huérfanas) y por prefijo dinámico
│   └── Veredicto sobre código de producción (los probes de test no cuentan)
├── Catálogos (res://locales/)
│   ├── es.po    (fuente de verdad, español)
│   └── en.po    (inglés)
└── Integraciones
    ├── M21 Diálogos    -> líneas y opciones traducidas + placeholders
    ├── M44 Subtítulos  -> texto visible en idioma activo
    ├── M53 UI-UX       -> labels/buttons con claves + selector de idioma
    ├── M60 Persistencia-> idioma guardado/leído de configuración
    ├── M88 Fuentes     -> FontLoader selecciona fuente según idioma
    └── M58 Accesibilidad -> tamaño de texto no rompe layout localizado
```

> ⚠️ **Nota iter. 5 — autoload duplicado.** Existe además un autoload `LocalizationManager` (`scripts/localizacion/localization_manager.gd`, catálogos JSON) que **no consume ningún módulo de producción**. La arquitectura vigente es la de arriba (`Localization` + `.po`). Ver `02-Analisis.md` §4.2.

La arquitectura sigue la regla de modularidad del proyecto: el `LocalizationManager` es la única capa que conoce el motor de traducción (TranslationServer) y los catálogos; la UI (M53) y los sistemas de texto (M21, M44) solo llaman a sus funciones expuestas, sin acoplarse a `.po` ni a detalles de gettext.

## 2. Componentes

### 2.1 LocalizationManager (autoload "Localization")

Responsabilidades:

1. **Cargar catálogos:** en `_ready()` recorre `LOCALES_SOPORTADOS`, parsea cada `.po` con `_parse_po()` (parser propio, tolerante a catálogos corruptos) y registra una `Translation` construida con `Translation.new()` + `add_message()` por clave, antes de `TranslationServer.add_translation()`. **No usa `load()` sobre el `.po`** (corrección iter. 5).
2. **Aplicar idioma:** `set_locale()` valida el locale contra `LOCALES_SOPORTADOS`, aplica `TranslationServer.set_locale()`, limpia la cache, persiste (M60) y emite `locale_changed`.
3. **Traducir:** `tr_key(module, section, key, params, n)` arma la clave completa y delega en `_tr_clave()`, que consulta la cache `_cache["clave|n"]`, aplica `format_text()` y, en caso de fallo, cae al catálogo español y en última instancia devuelve la clave literal (jamás texto vacío). *(El nombre `tr_cached` que figuraba antes no existe en el código: corrección iter. 5.)*
4. **Formatear:** delega números, fechas y hora en `LocaleUtils` según el idioma activo.
5. **Validar:** `validar_catalogos()` y `obtener_estado_catalogos()` reportan faltantes/vacías en runtime; `claves_faltantes()` (iter. 5) lista lo que el juego pidió y no existía, con **un aviso por clave** (deduplicado). La validación profunda de archivos vive en `ValidadorPO` y el inventario código↔catálogo en `AuditorClaves`, ambos usables desde un script headless de CI.

### 2.2 Catálogos .po (res://locales/)

Formato por entrada:

```
#. Contexto para el traductor (opcional)
msgid "MODULO.SECCION.CLAVE"
msgstr "Texto localizado"
```

Entrada con plurales:

```
msgid "ITEMS.SE_OFRECEN"
msgid_plural "ITEMS.SE_OFRECEN"
msgstr[0] "Se ofrece {n} objeto"
msgstr[1] "Se ofrecen {n} objetos"
```

Cabecera obligatoria del catálogo:

```
msgid ""
msgstr ""
"Content-Type: text/plain; charset=UTF-8\n"
"Language: es\n"
"Plural-Forms: nplurals=2; plural=(n != 1);\n"
```

Reglas:
- En `es.po` (fuente de verdad) el `msgstr` reproduce el texto español final.
- En `en.po` cada clave traducida debe existir; mientras una no tenga traducción, su `msgstr` se deja con el texto español (fallback natural hasta traducir).
- UTF-8 sin BOM, saltos LF, una entrada por bloque.

### 2.3 Selector de idioma (configuración, M53/M90)

- Lista horizontal de opciones o dropdown con los idiomas soportados, mostrados con su **nombre nativo** ("Español", "English").
- Al seleccionar: `Localization.set_locale(locale)` -> cambio en vivo + persistencia (M60).
- En el primer arranque, si el idioma del SO está soportado, se muestra el selector en la pantalla de bienvenida con la sugerencia ya preseleccionada y un botón de confirmación.
- ⚠️ **Desviación real (verificada iter. 5):** el diseño decía "nunca se cambia el idioma sin consentimiento explícito", pero el código **sí lo hace**: `_restaurar_locale_guardado()` aplica la sugerencia del SO (`_aplicar_locale`) **y la persiste** (`_persistir_locale`) en el primer arranque, sin esperar confirmación; la UI de confirmación pertenece a M53 y está pendiente. Queda registrado como desviación consciente y dependiente de M53: cuando M53 agregue el diálogo, la sugerencia debería quedar **solo preseleccionada** hasta que el jugador confirme.
- El selector está enlazado a las opciones de accesibilidad (M58): el tamaño de fuente ajustado se re-aplica en el idioma nuevo.

### 2.4 Convenciones de claves

```
MODULO.SECCION.CLAVE          (todo en mayúsculas, separadores "_" y ".")
MAIN_MENU.PLAY                -> "Jugar"
MAIN_MENU.OPTIONS             -> "Opciones"
HUD.ENERGIA                   -> "Energía"
HUD.VIDA                      -> "Vida"
ITEMS.MADERA                  -> "Madera"
ITEMS.MADERA_DESC             -> "Madera sólida de la isla Aurora."
DIALOGOS.VECINO_SALUDO        -> "¡Hola, vecino! (diálogos M21)"
SUBTITULOS.LLUVIA             -> "La lluvia golpea el techo (M44)"
SETTINGS.IDIOMA               -> "Idioma"
SETTINGS.IDIOMA_DESC          -> "Idioma de los textos del juego"
```

- `MODULO` usa el nombre del sistema según CHECKLIST-GLOBAL (MAIN_MENU, HUD, ITEMS, SETTINGS, DIALOGOS, MISIONES, etc.).
- `SECCION` agrupa (ej: `ITEMS.MADERA` / `ITEMS.MADERA_DESC`).
- UPPER_SNAKE obligatorio; los nombres propios conservan la ortografía original del idioma fuente.
- Un término se declara una sola vez y se reutiliza (glosario); si el mismo texto necesita traducciones distintas según contexto, se desambigua con el campo `#... context` de gettext o con una sección distinta.
- Prohibido repetir el texto visible en código: siempre por clave.

#### 2.4.1 Inventario de prefijos vigentes (auditado TANDA 16, 2026-10-21 — msg 189)

**Catálogos JSON** (`data/localizacion/strings_{es,en,pt}.json` — 170 claves, 14 prefijos):

| Prefijo | Claves | Dominio | Case |
|---|---|---|---|
| SETTINGS | 74 | Configuración + UI de ajustes/crafting/tiendas (M53/M59/M91) | UPPER_SNAKE |
| DIARY | 23 | Diario del jugador (M12) | UPPER_SNAKE |
| TIENDAS | 20 | Tiendas (M16) — prefijo en español | UPPER_SNAKE |
| eventos | 14 | Eventos narrativos — legado runtime M60 | minúscula snake_case |
| EQUIP | 13 | Equipamiento | UPPER_SNAKE |
| TUTORIAL | 7 | Tutorial | UPPER_SNAKE |
| ui | 6 | Etiquetas de UI base — legado M60 | minúscula snake_case |
| msg | 3 | Mensajes de sistema — legado M60 | minúscula snake_case |
| LOADING | 3 | Pantallas de carga | UPPER_SNAKE |
| M69 | 2 | Prefijo por ID de módulo (excepción) | UPPER_SNAKE |
| npc | 2 | Diálogos NPC base — legado M60 | minúscula snake_case |
| HUD | 1 | HUD | UPPER_SNAKE |
| ITEMS | 1 | Ítems | UPPER_SNAKE |
| MAIN_MENU | 1 | Menú principal | UPPER_SNAKE |

**Catálogos .po** (`locales/*.po`): el validador reporta 260 claves (145 comunes + 115 solo-.po: narrativa DIARY extendida, CLOCK.*, etc.). Sobre msgid de línea simple (165) los prefijos son: SETTINGS 75, DIARY 37, TIENDAS 20, EQUIP 13, TUTORIAL 7, ITEMS 3, LOADING 3, MAIN_MENU 2, HUD 2, DIALOGOS 1, npc 1, UI 1.

**Tres convenciones conviven** (hallazgo de la auditoría):
1. **Canónica (§2.4):** `MODULO.SECCION_CLAVE` UPPER_SNAKE — UI de jugador.
2. **Legado M60 (minúscula snake_case):** `ui.*`, `msg.*`, `npc.*`, `eventos.*` — mensajes de runtime del sistema; se conservan por compatibilidad, **no crear claves nuevas en minúscula**.
3. **Prefijo numérico:** `M69.*` — excepción por módulo; preferir el nombre semántico.

**Idioma del prefijo:** la flota mezcla ES (TIENDAS, DIALOGOS, eventos) y EN (SETTINGS, HUD, ITEMS...). El estándar no lo fija: para claves nuevas usar el nombre del sistema tal como figura en CHECKLIST-GLOBAL y mantener coherencia dentro del dominio.

#### 2.4.2 Reglas de creación de claves (vigentes)

1. **UPPER_SNAKE** con separadores `.` y `_` (salvo legado M60 minúscula — no nuevas).
2. **Un término, una clave** (glosario); desambiguar por contexto con sección distinta o campo `#... context` de gettext.
3. **Placeholders:** `%s`/`%d`/`%f` se resuelven en el llamador: `_t("CLAVE") % args` (ej: `SETTINGS.DESCARTAR_MENSAJE`).
4. **Plurales:** `Localization.tr_key("ITEMS", "SE_OFRECEN", "", {}, n)` con formas por `Plural-Forms` del `.po`.
5. **Toda clave nueva ES+EN+PT en el mismo commit** (JSON + `.po` de los 3 idiomas) — regla del director (msg 186); condición de aceptación: `scripts/validar_i18n_integridad.py` EXIT 0.
6. **Prohibido texto visible en código:** siempre por clave (verificado por `scripts/localization/auditor_claves.gd`).
7. Menús data-driven (ej: `data/debug/debug_menu_config.json`) pueden llevar etiquetas literales si son **solo de desarrollo**; migrar a claves `DEBUG.*` si se exponen al jugador (hallazgo TANDA 15, tarea 100).

#### 2.4.3 ID del grupo de localización — estándar de nombres (TANDA 18, 2026-10-21 — msg 194)

**Regla:** un **grupo** = un dominio funcional del juego. El ID del grupo es el prefijo de la clave (`GRUPO.seccion_clave`). Nuevo grupo solo si hay un dominio funcional nuevo; se registra en el inventario §2.4.1 y se crea con la regla ES+EN+PT (§2.4.2 regla 5).

**Los dos grupos en discusión (tarea 64):**
1. **`eventos.*` — grupo de eventos narrativos (M74): ESTÁNDAR VIGENTE Y MIGRADO.** 14 claves `eventos.historia_c{1-7}_{nombre,desc}` en **los tres catálogos** (JSON ES/EN/PT + `es.po` "Las Cenizas Futuras" + `en.po` "The Ashes to Come") — migradas al .po por el riel de la flota (commit `3b43f64`) vía conciliación por lotes (modelo del msg 153). Es el **patrón de éxito** para unificar un grupo: lote → JSON + .po ES/EN → validador EXIT 0.
2. **`tools.*` — grupo de herramientas de desarrollo: NO CREAR.** No existe en ningún catálogo ni código (auditado). Los strings de herramientas de desarrollo **no son jugador-visible** → no requieren i18n (el estándar M87 aplica a texto de jugador, §2.4 regla "prohibido texto visible en código" es para UI). Si el día de mañana hay texto de herramienta jugador-visible (ej: log de diagnóstico que ve el jugador), se crea como `tools.*` con regla ES+EN+PT y registro en §2.4.1.

**Convención de IDs de grupo (resumen):**
- Jugador-visible: UPPER_SNAKE del nombre del sistema (SETTINGS, DIARY, TIENDAS, EQUIP, TUTORIAL, LOADING, HUD, ITEMS, MAIN_MENU, DIALOGOS).
- Legado M60 (no nuevas): minúscula snake_case (`ui.*`, `msg.*`, `npc.*`) — deuda de migración (11 claves solo-JSON, §8b de 04-Codigo).
- Prefijo numérico (`M69.*`): excepción por módulo; preferir nombre semántico.
- Un grupo por dominio; no agrupar dominios distintos bajo un mismo prefijo; no crear prefijos "de reserva" sin consumidor.

#### 2.4.4 Texto de presets de control — "Controles:" del HUD (TANDA 19, 2026-10-21 — msg 196, tarea 72)

**Deuda auditada (hallazgo TANDA 17, §8b de 04-Codigo):**
- `scripts/ui/layers/menus_layer.gd` L107/L124: `"Controles: " + String(acc.get_control_preset())` — literal ES + **ID técnico crudo** jugador-visible. Presets (`accesibilidad_manager.gd` `PERFILES_CONTROL` L152-175): `estandar`, `single_hand`, `low_mobility`. El jugador ve "Controles: single_hand" en cualquier idioma.
- Tests `qa_m58_indicador_perfil.gd` L37/44/49 validan el formato literal (deuda: al traducir, los tests esperan el literal ES).
- **Ninguna clave `CONTROL*`/`PRESET*` existe** en los catálogos (auditado; solo `SETTINGS.RANGO_DINAMICO_PRESET`, ajena a esto).

**Propuesta llave-en-mano (claves + traducciones ES/EN/PT listas para aplicar):**

| Clave | ES | EN | PT |
|---|---|---|---|
| `SETTINGS.CONTROLES` | `Controles: %s` | `Controls: %s` | `Controles: %s` |
| `SETTINGS.PRESET_ESTANDAR` | `Estándar` | `Standard` | `Padrão` |
| `SETTINGS.PRESET_SINGLE_HAND` | `Una mano` | `One hand` | `Uma mão` |
| `SETTINGS.PRESET_LOW_MOBILITY` | `Movilidad reducida` | `Low mobility` | `Mobilidade reduzida` |

**Consumo (para el owner de `menus_layer.gd` — M53/M89, NO ejecutado por M87):**
```gdscript
var preset := String(acc.get_control_preset())
var nombre := _t("SETTINGS.PRESET_" + preset.to_upper())   # estandar -> PRESET_ESTANDAR
label.text = _t("SETTINGS.CONTROLES") % nombre
```
- Las claves **no se crean sin consumidor** (evitar huérfanas del catálogo — el caso `SETTINGS.DESCARTAR*` del 04-Codigo L428): se aplican en el **mismo commit** que el consumo de `menus_layer.gd`, con la regla ES+EN+PT (§2.4.2 regla 5) y los tests M58 actualizados al nuevo formato.
- El preset es un ID técnico: el mapeo a nombre amigable es por clave (no string-literal), coherente con el estándar "un término, una clave" (§2.4.2 regla 2).

#### 2.4.5 Logs y errores del sistema — spans estándar (TANDA 20, 2026-10-21 — msg 198, tarea 73)

**Estándar vigente (auditado):** los mensajes de sistema (`push_error`/`push_warning`) son **de consola (desarrollador), NO jugador-visible** → **no requieren i18n** (coherente con §2.4.3: texto de herramientas de dev). Sí aplican: (a) **idioma español** y (b) **formato `[MNN] mensaje`** con prefijo de módulo.

**Auditoría (388 warning + 109 error en producción, sin tests/qa/Obsoletos):**
- **Estándar cumplido (~98%):** `[MNN] Mensaje en español` — ej: `[M60] Guardado slot %d falló`, `[M87] Clave sin traducción: %s`, `[M42] Bioma desconocido: %s`.
- **Errores jugador-visibles:** van por clave i18n, no por push_error — `SETTINGS.SAVE_CORRUPTO/_RECUPERADO/_DISCO_LLENO` y `SETTINGS.BORRAR_*` (JSON + .po ES/EN, tanda 14) son las claves de fallback de guardado; `data_store.gd`/`writer_atomico.gd` emiten el detalle técnico a consola y la UI muestra la clave.
- **Inconsistencias menores de formato (4 tags fuera de `[MNN]`, del dueño de cada módulo):**
  - `animacion/animation_service.gd` L118/L125 (M48): tag `ANIM-MISSING:` en inglés.
  - `saving/save_manager.gd` L246 (M60/M11): tag `[SAVE]` en inglés.
  - `clima/weather_service.gd` L48 (M31): tag `[Weather]` en inglés.
  - `dialogos/dialogue_manager.gd` L127 (M21): tag `[VAL-DGV]` en inglés.
  - (nombres propios aceptables: `Bootstrap:` de `core/bootstrap.gd`, `asset_preview:` de M108).
- **Deuda documentada (dueños M48/M60/M31/M21):** renombrar los 4 tags al formato `[MNN]` del estándar. No es bloqueante (consola de dev); no ejecutado por M87 (módulos ajenos).

### 2.5 Flujo de agregar un idioma nuevo

1. Copiar `es.po` como `xx.po` (xx = código ISO del idioma).
2. Editar la cabecera (`Language: xx`, `Plural-Forms` si difiere del español).
3. Traducir los `msgstr` (dejar en español lo aún no traducido).
4. Agregar el idioma en la lista `LOCALES_SOPORTADOS` del `LocalizationManager` y al selector de configuración con su nombre nativo.
   - ⚠️ **Corrección iter. 5:** el nombre del const es `LOCALES_SOPORTADOS` (el `SUPPORTED_LOCALES` anterior no existe en el código). Además, la lista de idiomas está **duplicada en tres lugares**: `LocalizationManager.LOCALES_SOPORTADOS`, `LocaleUtils.TABLAS` y `LocaleUtils.NOMBRES_NATIVOS`. Agregar un idioma con reglas numéricas o nombre nativo nuevos exige tocar los tres, lo que **incumple RN3** en su letra ("1 `.po` + 1 entrada en el selector"). Deuda técnica registrada; unificar en `LocaleUtils` sería el arreglo natural.
5. Verificar en M88 que la fuente cubre los caracteres del idioma (FontLoader según idioma).
6. Ejecutar `TranslationValidator` y QA de localización del idioma nuevo.
7. Actualizar la documentación y el checklist del módulo.

## 3. Flujos

### 3.1 Arranque del juego

1. `Localization._ready()` lee el idioma guardado de la configuración (M60).
2. Si no hay guardado: idioma por defecto español; si el SO sugiere otro idioma soportado, se marca la sugerencia en la pantalla de bienvenida.
3. Se cargan los catálogos de los idiomas soportados (o se precargaron en la pantalla de carga, M63).
4. `TranslationServer.set_locale(idioma)` se aplica antes de instanciar la UI principal.
5. Las escenas construyen sus textos con `tr_key(...)`.

### 3.2 Cambio de idioma en vivo

1. El jugador selecciona otro idioma en configuración.
2. `Localization.set_locale(nuevo)` valida, aplica `TranslationServer.set_locale`, limpia cache, persiste el cambio y emite `locale_changed`.
3. La UI suscrita re-traduce sus controls (labels, botones, tooltips) con sus claves; los paneles que muestran contenido dinámico (inventario, misiones) se refrescan.
4. Los diálogos activos (M21) finalizan la línea actual y continúan en el idioma nuevo; un diálogo pausado se reinicia desde su inicio (decisión para evitar textos mixtos).
5. Los subtítulos (M44) en curso se re-traducen en la siguiente aparición.

### 3.3 Texto con placeholders

1. Catálogo: `msgid "DIALOGOS.ENTREGA"` / `msgstr "Recibí {cantidad} de {objeto}."`.
2. Código: `Localization.tr_key("DIALOGOS", "ENTREGA", "", params)` con `params = {cantidad: 5, objeto: tr_key("ITEMS","MADERA")}`.
3. `format_text()` reemplaza `{cantidad}` y `{objeto}` iterando `params` con `String.replace()` (**no** con el patrón `\{\w+\}`: corrección iter. 5). Antes cuenta llaves y, si no coinciden, deja el texto literal con un warning de desarrollo; las claves sin valor en `params` quedan literales y emiten warning.

### 3.4 Plurales

1. Catálogo declara `msgid_plural` y `msgstr[0]`/`msgstr[1]`.
2. Código: `Localization.traducir_clave("ITEMS.SE_OFRECEN", {}, n)` obtiene la forma correcta según el idioma activo. *(El ejemplo anterior usaba `tr("ITEMS.SE_OFRECEN", "", n)`, que no es la API del módulo: corrección iter. 5. El módulo no traduce con `Object.tr()`.)*
   - ⚠️ La forma se elige con `_indice_plural()`, que **hardcodea** la regla es/en; **no** lee `Plural-Forms` de la cabecera del `.po`. Ver `02-Analisis.md` §1.5.
3. `format_text()` inyecta `{n}` si el texto lo declara.

### 3.5 Formatos de fecha y número

1. `LocaleUtils` mantiene tablas por idioma: separador decimal, separador de miles, orden de fecha, reloj 12h/24h.
2. `format_number(1234.56)` -> español "1.234,56" / inglés "1,234.56".
3. `format_date(datetime_dict)` -> español "17/08/2026" / inglés "08/17/2026".