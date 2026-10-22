**Modelo:** Ling-3.1-Flash (último modificador — tandas 16-22; previo: DeepSeek-V4.1-Flash / WorkBuddy, iter. 5, 2026-09-13; texto original: Deepseek V4 Flash / OpenCode, 2026-08-26)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-13 (correcciones doc↔código de la iter. 5; tandas 16-22 de 2026-10-21/22)

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

#### 2.4.6 Strings del jugador (logins, nombre, búsqueda) — evaluación de aplicabilidad (TANDA 21, 2026-10-21 — msg 200, tarea 71)

**Pregunta de la tarea 71:** ¿aplica el language a los "strings del jugador (los logins)"? **Respuesta: al login NO (no existe en v1); al nombre del jugador NO (dato del usuario); al UI estático del jugador SÍ (y hay deuda en M06).**

**1. Login / autenticación — NO APLICA (no existe en v1).**
- El juego v1 es single-player local. Contrato multijugador (`scripts/multijugador/validate_mp_contract.gd`): bloque B L126-128 exige **cero archivos `mp_*.gd` y cero refs de red** (ENet/multiplayer_peer) en scripts v1; bloque C L148-149: `mp_v1 == "single"`, `servidores_v1 == false`, `coste_estimado_mensual == 0` (RF24).
- No hay pantalla de login, cuentas ni autenticación → **no hay strings de login que traducir**. El MP (y sus strings de login) es futuro (invitaciones delegadas a M77, L141-142).

**2. Nombre del jugador — DATO DEL USUARIO, no se traduce.**
- RF13 (`identidad.nombre_jugador_editable == true`, L144) existe en el contrato, pero su UI está delegada al futuro (lista_amigos M77).
- Un nombre propio es dato del usuario: no pasa por el language (igual que los nombres de NPC, que conservan la ortografía del idioma fuente — §2.4).

**3. Texto que el jugador ESCRIBE (búsquedas) — no se traduce; su PLACEHOLDER SÍ (UI estático).**
- Auditados los 3 LineEdit de búsqueda de producción:
  - `ui/layers/diary_layer.gd` L211: `_t("DIARY.BUSCAR")` ✓ (es.po L710 "Buscar en el diario…")
  - `ui/layers/inventory_layer.gd` L147: `_t("SETTINGS.BUSCAR")` ✓ (es.po L177 "Buscar")
  - `player/player.gd` L637: `"Buscar ítem..."` — **literal ES (deuda, ver punto 4)**.

**4. DEUDA M06 (Jugador): 13 literales ES en `scripts/player/player.gd` (panel de inventario del jugador).**
Auditoría (L598-L1117): 11 traducibles + 2 no (`"X"` L644 y `"x%d"` L794 — símbolo y formato numérico).

| Línea | Literal | Clave | Estado |
|---|---|---|---|
| L598 | `Inventario` | `SETTINGS.INVENTARIO` | existe (JSON + .po ES/EN) |
| L616 | `Todos` | `DIARY.FILTRO_TODOS` | existe ("Todos"/"All") |
| L637 | `Buscar ítem...` | `SETTINGS.BUSCAR` | existe ("Buscar"/"Search") |
| L661 | `Ordenar:` | `SETTINGS.ORDENAR` | existe (usada por inventory_layer L158) |
| L672 | `Aplicar` | `SETTINGS.APLICAR` | existe (JSON + .po ES/EN) |
| L726 | `Cerrar (B)` | `SETTINGS.CERRAR` + `" (B)"` | existe; `(B)` = acelerador de teclado, se concatena |
| L945 | `Usar` | `ITEMS.USAR` | **NUEVA** (ES/EN/PT listos) |
| L952 | `Favorito`/`Desfavorecer` | `ITEMS.FAVORITO` / `ITEMS.DESFAVORECER` | **NUEVAS** (par) |
| L960 | `Descartar` | `SETTINGS.DESCARTAR` | existe — **resuelve la huérfana de tanda 17** (04-Codigo §8b) |
| L1117 | `Sin herramienta` | `ITEMS.SIN_HERRAMIENTA` | **NUEVA** (ES/EN/PT listos) |

**Claves nuevas propuestas (ES/EN/PT — regla §2.4.2 regla 5):**

| Clave | ES | EN | PT |
|---|---|---|---|
| `ITEMS.USAR` | `Usar` | `Use` | `Usar` |
| `ITEMS.FAVORITO` | `Favorito` | `Favorite` | `Favorito` |
| `ITEMS.DESFAVORECER` | `Desfavorecer` | `Unfavorite` | `Desfavoritar` |
| `ITEMS.SIN_HERRAMIENTA` | `Sin herramienta` | `No tool` | `Sem ferramenta` |

**Consumo (para el owner de M06 — NO ejecutado por M87, módulo ajeno):** reemplazar cada literal por `_t("CLAVE")` (ej: `title.text = _t("SETTINGS.INVENTARIO")`; `search_line.placeholder_text = _t("SETTINGS.BUSCAR")`; `fav_btn.text = _t(s.favorito ? "ITEMS.DESFAVORECER" : "ITEMS.FAVORITO")`). Las 4 claves nuevas se crean **en el mismo commit** que el consumo (evitar huérfanas — política §2.4.4), con ES+EN+PT en JSON + es.po + en.po.
- Nota: `DIARY.FILTRO_TODOS` ("Todos") viene del dominio del diario; si el owner de M06 prefiere desacoplamiento, alternativa `ITEMS.TODOS` (mismo texto — el glosario §2.4 "un término, una clave" favorece el reuso).

**Regla derivada (estándar M87):** el language aplica al **UI estático** y al **contenido del juego**; NO aplica a (a) login/autenticación (inexistente en v1), (b) nombre del jugador (dato de usuario, RF13 futuro), (c) el texto que el jugador escribe (búsquedas, chat futuro).

**Seguimiento de la deuda M06 (cierre de tanda 22, 2026-10-22):** `scripts/player/player.gd` **sin cambios** desde su último commit `1e62132` (2026-10-16, «D102 ajuste fino: paneles aclarados...») — las 4 claves propuestas `ITEMS.USAR` / `ITEMS.FAVORITO` / `ITEMS.DESFAVORECER` / `ITEMS.SIN_HERRAMIENTA` **siguen ausentes de los catálogos** (grep: 0 hits en `data/localizacion/` y `locales/`; solo figuran en esta documentación). La deuda queda **pendiente de encargo al owner de M06** (clave + consumo en el mismo commit — política §2.4.4).

#### 2.4.7 Estándar de lenguaje técnico del repositorio — comentarios, logs y la regla de frontera (TANDA 22, 2026-10-22 — tareas 97/98/99)

**Las tres preguntas de las tareas 97-99, respondidas con auditoría en disco:**

**1. Tarea 97 — Comentarios de código: NO se traducen (no son contenido del juego).**
- Auditoría (`core/bootstrap.gd` L2-22, `logging/logger.gd` L1-27): los comentarios son **100% en español** (idioma del equipo — AGENTS.md §1: «Todas las comunicaciones deben realizarse estrictamente en español»; commits en español, §4.1).
- Estándar: comentarios en **español** con **terminología técnica canónica en inglés** cuando el término de plataforma lo es (`autoload`, `headless`, `frame budget`, `stdout`, `crash-proof`, `fallback`) — no se traducen términos del stack Godot/.NET (el inglés técnico es el idioma franco de la plataforma).
- **Nunca pasan por M87**: el jugador no ve comentarios; traducirlos sería ruido de proceso (el repositorio es monolingüe de trabajo).

**2. Tarea 98 — Logs de sistema: mensaje en español, etiquetas técnicas canónicas en inglés.**
- El servicio central es `GameLogger` (autoload `scripts/logging/logger.gd`, M103): `info("Logger inicializado", Category.BOOT)` L87 — **mensaje ES**; sus metadatos son **tags canónicos EN** (`Level`: DEBUG/INFO/WARNING/ERROR/CRITICAL L45; `Category`: BOOT/SYSTEM/GAMEPLAY/WORLD/NETWORKING/ANALYTICS/CRASH L46) — vocabulario estándar de logging (Godot, Python `logging`, .NET `ILogger`).
- Los `print`/`push_warning`/`push_error` de producción siguen §2.4.5 (`[MNN] mensaje en español`, ~98% cumplido).
- Estándar derivado: **«mensaje en español para humanos, etiqueta canónica EN para máquinas»** — la etiqueta se parsea y se filtra (`set_category_enabled`, API L9), no se traduce; el mensaje se lee, va en el idioma del equipo.

**3. Tarea 99 — El logger no clampea idioma: los logs NO se traducen porque no son jugador-visible.**
- Superficies del logger: (a) stdout (consola de dev), (b) `user://logs/game.log` (archivo de diagnóstico), (c) señal `line_emitted` → consola in-game de **M110** (`debug/debug_menu.gd` L621-627 conecta `GameLogger.line_emitted`) — menú de **desarrollo**, no funcionalidad de juego (§2.4.3: herramientas de dev).
- Decisión: las tres superficies permanecen en **español** sin pasar por M87 — verificado: `logger.gd` tiene **0 consumos** de `_t()`/`tr()`/`TranslationServer` (grep). Si algún día la consola de M110 se expone al jugador final (hoy es development-only), ahí sí correspondería i18n — registrado como deuda condicional, no como bug.

**La regla de frontera (síntesis de las tandas 20-22 — qué se traduce y qué no):**

| Superficie | ¿i18n? | Base |
|---|---|---|
| UI estática (labels, botones, placeholders, tooltips) | **SÍ** | jugador-visible |
| Contenido del juego (diálogos, historia, items, tips de carga) | **SÍ** | jugador-visible |
| Errores jugador-visibles | **SÍ** (por clave; el detalle técnico va a consola) | §2.4.5 |
| Logs de consola / archivo de log / consola de debug (M110) | NO | consola de dev (§2.4.5, tarea 99) |
| Comentarios de código | NO | documentación de repo (tarea 97) |
| Nombre del jugador y texto que el jugador escribe | NO | dato de usuario (§2.4.6) |
| Identificadores técnicos (IDs, tags de log, IDs de recursos) | NO | máquinas, no humanos (tarea 98) |
| Login/autenticación | NO aplica | no existe en v1 (§2.4.6) |
| Nombre del hablante y etiqueta de expresión (M21/M53) | **SÍ** (jugador-visible; hoy muestra el ID crudo — deuda §2.4.8) | §2.4.8 |

#### 2.4.8 Nombre del hablante y etiqueta de expresión (`speaker_key`) — aplicación de la regla de frontera (TANDA 23, 2026-10-22 — tarea 33, cierre de H3 de la Tanda 10)

**Medición (auditoría en disco):** `data/dialogues/` = **375 archivos JSON, 787 nodos con `speaker_key`, 27 claves únicas**: `npc` (x11), `npc.anciano` (x4), `npc.aur_001..005` (x35/27/29/27/37), `npc.catalina` (x6), `npc.cen_001..005` (x27/27/27/29/25), `npc.chaman` (x9), `npc.cor_001..005` (x31/27/27/27/25), `npc.riz_001..008` (x75/51/45/53/41/23/21/21).

**Presencia exacta en catálogos:** `es.po`/`en.po` (275 msgid): **solo `npc.catalina`** (`msgstr "Catalina"`), y es **excepción documentada** del propio `ValidadorPO` (`validador_po.gd` L30 `EXCEPCIONES_CLAVE`, L34 y L43 `NO_TRADUCIBLES` — «nombre propio del NPC»). `strings_es/en/pt.json` (172 claves): **0/27**.

**Veredicto (regla de frontera):** `speaker_key` = **ID técnico interno** (como un `reaccion_id` o un asset path) → **NO traducible, NO va al catálogo**. Cierra la pregunta abierta H3 de la Tanda 10 («¿ID interno o clave traducible?»): **ID interno**. El consumidor es passthrough de ID (`dialogue_node.gd` L18 `@export`, `dialogue_graph.gd` L35, `dialogue_manager.gd` L210-211/L280, `dialogue_ui.gd` L215 color + L604 animación, `test_dialogos.gd` L75) — **0 llamadas `tr("npc.*")`** en `scripts/` (grep). Las 26 ausencias de `.po` son **correctas por diseño**, no defecto. La entrada `npc.catalina` es coherente con la frontera (nombre propio: forma de origen en todos los idiomas) y no tiene consumidor de traducción — figura como excepción del validador, no como clave activa.

**DEUDA jugador-visible derivada a M21/M53 (dueños Hy3 / G-5.3-Flash-Agente) — NO ejecutada por M87 (módulos ajenos):** el retrato se instancia siempre (`dialogue_ui.gd` L161 `load("res://scripts/dialogos/ui/npc_portrait_ui.gd").new()`) y muestra IDs crudos al jugador en 4 puntos:

1. `npc_portrait_ui.gd` L61 — `_name_label.text = speaker_key` → el jugador ve `npc.catalina` / `npc.riz_001` en cada diálogo.
2. `npc_portrait_ui.gd` L77 — `_expr_label.text = _expression` → ve `feliz_intenso` / `feliz` / `neutral`.
3. `dialogue_ui.gd` L251 — `_expresion.text = expresion if expresion != "" else reaccion_id` → ve `R_AMADO` / `R_GUSTA` / `R_NEUTRAL` / `R_DUPLICADO` (IDs de `gift_evaluator.gd` L64).
4. `dialogue_ui.gd` L258 — `_expresion.text = "nivel_subio_" + str(new_level)` → ve `nivel_subio_3`.

El comentario del propio archivo (`npc_portrait_ui.gd` L58) ya dice «fija el hablante (npc.<id>) y su nombre visible», pero alimenta el label con el ID. Por la frontera, estos 4 puntos son **jugador-visibles → corresponde i18n o tabla `display_name` data-driven**.

**Propuesta llave-en-mano (para el owner; crear + consumir en el mismo commit — política anti-huérfana §2.4.4):** `NPC.CATALINA` / `NPC.CHAMAN` / `NPC.ANCIANO` / `NPC.AUR_001..005` / `NPC.CEN_001..005` / `NPC.COR_001..005` / `NPC.RIZ_001..008` (26 claves; nombres propios — iguales en es/en/pt por la frontera, salvo que el owner defina nombres traducidos), `EXPRESION.FELIZ_INTENSO` / `EXPRESION.FELIZ` / `EXPRESION.NEUTRAL` (3), y `REACCION.*` para los 4 `reaccion_id` de M20. Alternativa sin claves nuevas: tabla de `display_name` en `data/` (nombres de NPC y expresiones como datos), que mantiene los catálogos intactos y respeta la frontera sin crear huérfanas.

#### 2.4.9 Auditoría de coherencia de strings por módulo — bloque G (TANDA 24, 2026-10-22 — tareas 41/42/43/44/45)

Auditoría estática report-only de los datos de string de M147/M160/M95/M100/M121 (el catálogo central no los cubre: son datos data-driven). Medida en disco 2026-10-22:

**T41 — M147 WorldBible canon 1.0.0 (`data/world_data.json`, autoload `WorldBible` = `scripts/world/world_bible.gd`, getters `get_personaje/get_lugar/get_simbolo` L46-53):**

- canon_version 1.0.0 presente. **6 personajes: Finneas (guía, Raíz), Lía (curandera, Raíz), Bruno (constructor, Coral), Nilo (pescador, Coral), Vera (herrera, Ceniza), Orión (navegante, Aurora)**.
- **Corrección de dato de la tarea 41:** el backlog citaba «(Catalina, Bruno...)» — **Catalina NO es personaje del canon 1.0.0**; es NPC de diálogo M21 (`villagers/catalina_oso.tres`, `speaker_key` `npc.catalina`). El canon no la incluye.
- Coherencia cruzada Bruno: canon + `amistad/cumpleanos.json` (BRUNO) + `villagers/bruno_sapo.tres` («Bruno») — 3/3 coherente.
- **0/6 personajes y 0/8 lugares en `es.po`/`en.po`/`strings_*.json` — CORRECTO**: nombres propios y lugares data-driven; por la frontera §2.4.8 los nombres propios conservan su forma en es/en/pt.
- **DEUDA (owner M147, deepseek):** `bios` (6), `lugares` (8 nombre+descripcion), `simbolos` (4), `linea_tiempo` (5 épocas) = literales ES accesibles por getters runtime → en locale EN/PT el jugador los vería en ES (clase data-driven, igual que los diálogos H1 Tanda 10). Propuesta: `M147.*` ES/EN/PT o campos por locale; crear+consumir mismo commit.

**T42 — M160 ubicaciones (`data/ubicaciones/ubicaciones.json`, 10 entradas; `data/m160/catalogo_ubicaciones.json`, índice):**

- **Ambos archivos con 0 consumidores de producción** (grep: solo `test_ubicaciones_headless.gd` lee `ubicaciones.json`; el índice no lo lee nadie) → datos/documentación, no runtime.
- **Coordenadas en escala VIEJA (pre-rework):** `ubicaciones.json` x/z en rango 200-1200 (isla 512×512 vieja; «Punto de partida» en 256,256 = centro viejo). El mundo vigente es 5120×5120, centro (2560,2560), radio 1800 (autoload `mundo_raiz.gd`, AGENTS.md §26). El índice repite el stale: Isla Raíz «centro» [256,256] / «radio» 256. **Deuda documental/data para el owner M160 (mimo):** re-escalar coordenadas a la escala 10× o declararlas obsoletas.
- **Divergencia de nombres canon↔catálogo (6/8 lugares):** canon `world_data.json` vs `ubicaciones.json` — «Templo de los Orígenes» vs «Templo de la Raíz»; «Laguna de Coral» vs «Laguna Coral»; «Templo de las Profundidades» vs «Templo Coral»; «Templo de la Forja» vs «Templo de la Ceniza»; «Cúpula de Aurora» vs «Cielo de la Aurora»; «Templo del Cazador» vs «Templo de la Aurora». El jugador vería nombres distintos del mismo lugar según la superficie. **Deuda de coherencia derivada a owners M147/M160** (alinear a una fuente canónica).
- 0/10 nombres en catálogos — correcto (data-driven).

**T43 — M95 ediciones/DLC (`data/monetizacion/ediciones.json` + `dlc.json`; consumidores `edicion_catalogo.gd`, `dlc_catalogo.gd`, `sincronizar_dlc.gd`):**

- 3 ediciones: Standard $24.99 / Deluxe $34.99 / Coleccionista $59.99 (física); 2 DLC: «Expansión: Isla de los Cielos» $14.99 / «Pack Decoración Aurora» $4.99.
- `obtener(id)` devuelve el dict completo → la UI lee `nombre`/`descripcion` tal cual: **ES-only en data, 0/5 en catálogos, 0 traducciones EN/PT** → en locale EN/PT la tienda mostraría textos ES (deuda data-driven).
- **Propuesta llave-en-mano (owner M95):** `M95.EDICION.STANDARD/DELUXE/COLECCIONISTA` + `M95.DLC.ISLA_CIELOS/DECORACION_AURORA` (+ `_DESC`), ES/EN/PT en el mismo commit que el consumo; alternativa sin claves: campo `nombre` por locale `{"es":…,"en":…,"pt":…}`. Precios: formattación por idioma vía LocaleUtils (tarea 67, bloque L).

**T44 — M100 community (`data/community/faq.json`):**

- 15 FAQs; **declara `"idiomas": ["es","en"]` pero el contenido es 100% ES** — incoherencia declarado vs materializado.
- **Voseo argentino mezclado con tuteo** (6 instancias: «Verificá» ×5, «Seguí», «Usá» frente a «¿Puedo…?», «Sí.») — inconsistencia de registro ES.
- `canales_oficiales.steam` = `steam://store/1XXXXXX` (placeholder sin resolver).
- **Deuda para owner M100:** traducciones EN (o ajustar `idiomas` a `["es"]`) + uniformizar registro (tuteo o voseo) + resolver placeholder steam.

**T45 — M121 support (`data/support/faq.json`; consumidores `support_manager.gd` + `faq_manager.gd` FAQManager data-driven):**

- 15 FAQs; `politica_respuesta.idiomas: ["es","en"]` con **contenido 100% ES** — misma incoherencia T44.
- Categorías: 10 declaradas = 10 usadas (coherentes).
- **Deuda para owner M121:** traducciones EN (FAQManager busca por texto ES — en locale EN el search operaría sobre texto ES) o declarar ES-only.

**Síntesis bloque G:** los 5 módulos tienen strings jugador-visibles (o potencialmente visibles vía getters/consumidores) como literales ES en datos data-driven, fuera del catálogo central — la misma clase de deuda que los diálogos (H1 Tanda 10). La frontera §2.4.8 aplica: nombres propios/lugares NO se traducen (forma de origen), pero bios/descripciones/FAQs/ediciones SÍ son contenido jugador-visible → corresponde i18n data-driven (claves o campos por locale), decisión y ejecución de cada owner (módulos ajenos, no ejecutados por M87).

#### 2.4.10 QA de strings con expresiones — bloque L (TANDA 25, 2026-10-22 — tareas 66/67/68/69/70)

Auditoría estática report-only del bloque L (strings con expresiones/formato). Medida en disco 2026-10-22:

**T66 — M21 diálogos (control de wrap):** censo de 394 textos en `data/dialogues/` — palabra más larga 21 chars («EJEMPLO_M21_OPCION_SI», clave del archivo de ejemplo), texto más largo 125 chars (`riz_001_cap0_historia_noche.json`). **Proxy estático: sin riesgo de wrap** — la palabra máxima (21 chars) cabe holgadamente en una línea de diálogo típica (~35-45 chars a 16px) y el texto máximo (125 chars) lo pagina el paginador de `dialogue_ui.gd` (`_paginar_texto`). **LÍMITE (honesto):** la verificación de píxeles (`get_string_size` + ancho de panel) requiere Godot headless — no disponible en el entorno; pendiente para sesión con Godot (igual que Tanda 11).

**T67 — M95 precios (formattación de monetización):** la UI de economía muestra números con `%d` crudo: `shop_ui.gd` L183 `"%s: %d" % [_t("TIENDAS.SALDO"), int(eco.saldo)]` y L202 `"%s — %d AO (x%d)" % [_nombre_item(...), precio, cantidad]`; `museo_sign.gd` L76 `"Progreso global: %d%%"`. Los precios in-game son **enteros** (sin separador decimal — no aplica), pero el **separador de miles no se aplica**: el tope de saldo (M38 `MAX_SALDO = 999999`) se vería «999999» en cualquier idioma, cuando ES canonical es «999.999» y EN «999,999». `LocaleUtils.format_number` (es «1.234,56» / en «1,234.56», validado en Tanda 3) **tiene 1 único consumidor** (`transport_localizer.gd`, M16) — el formateo numérico por idioma **no está adoptado en la UI de economía**. **DEUDA de adopción (owners M39/M53/M37):** enrutar contadores ≥1000 (saldo, precios, progreso) por `LocaleUtils.format_number`. «AO» = código de moneda (canónico, no se traduce — correcto por la frontera §2.4.8). Los precios de `monetizacion.json` (24.99 USD) son store-facing (ficha de Steam), no runtime del juego — fuera del alcance de M87 runtime.

**T68 — M100 community (strings de mantenimiento comunitario):** los 5 archivos de `data/community/` son **contenido para plataformas de comunidad (Discord/web), NO UI del juego** — consumidores: `discord_setup.py` (creación server-side de la estructura Discord, Python de devs) y `community_manager.gd` (M100, calendario de comunidad); `roadmap.json` y `report_categories.json` tienen **0 consumidores**. Por la frontera §2.4.7, lo que no es superficie del juego **no lo traduce M87** (es contenido de comunidad, trabajo del equipo de comunidad). Hallazgos de coherencia: (1) `roadmap.json` **mezcla ES (hitos) con EN (categorias: «Core Gameplay», «Content», «Technical», «Polish»)** — inconsistencia de idioma dentro de un archivo; (2) todos los archivos 100% ES — si la comunidad objetivo es multi-idioma, la traducción es un trabajo de contenido de comunidad (fuera del runtime); (3) «NSFW» (report_categories.json) = sigla canónica EN, correcto no traducirla.

**T69 — M159 nombres largos de ítems (control de wrap):** censo de **300 `.tres` en `data/items/`, 300 con `nombre`** — nombre más largo **28 chars** («Pergamino: Rec. Tela de Lino»); top-5 ≤28 chars. **Proxy estático: sin riesgo de wrap** — 28 chars caben en una celda de inventario típica (~150-200 px a 12-16 px). **LÍMITE (honesto):** verificación de píxeles pendiente Godot headless.

**T70 — M76 contrato MP (strings multijugador):** `data/multijugador/mp_contract.json` = **contrato de diseño técnico** (`mp_v1: "single"`, `servidores_v1: false`, `coste_estimado_mensual: 0`, permisos booleanos, IDs de emotes). **0 strings jugador-visible** — los valores son configuración/IDs (frontera §2.4.7: IDs técnicos no traducibles); consumido por `validate_mp_contract.gd` (validación de contrato, no display). Los únicos textos potencialmente jugador-visibles (emotes `set_base` hola/gracias/risa/enojo, chat «frases rapidas») son de **MP futuro** (`mp_future: "local_first"`; v1 single-player, cero red — auditado en Tanda 21 tarea 71). **Deuda condicional registrada:** cuando el MP se implemente, las etiquetas de emote/frases rápidas serán jugador-visibles → i18n data-driven entonces (claves M76.* ES/EN/PT).

**Síntesis bloque L:** sin defectos de traducción bloqueantes. Las deudas son de **adopción** (formateo numérico por idioma, T67) y **condicionales** (emotes MP futuro, T70); los contenidos de comunidad (T68) quedan fuera del runtime de M87 por la frontera; los wrap (T66/T69) pasan el proxy estático con verificación de píxeles pendiente Godot.

#### 2.4.11 QA del spillover de la interfaz — bloque N (TANDA 26, 2026-10-22 — tareas 75/76/77/78)

Auditoría estática report-only del bloque N (spillover de UI: tooltips, títulos, botones). Medida en disco 2026-10-22:

**T75 — Tooltips por idioma: DEUDA HALLADA (8 tooltips + 5 textos de botón literales ES).** La vía correcta existe y funciona: metadato `tooltip_text_key` + `RetraductorUI` (`retraductor_ui.gd` L28, `PROPS_TEXTO` incluye `tooltip_text`) + `TooltipService.show_tooltip_key` (`ui_manager.gd` L94-106, Log 1118) — adoptada en producción por `diary_layer.gd` L154/L161/L371 (`DIARY.PROGRESO_CAT` ×3). Pero 2 capas usan literales ES jugador-visibles:
- `full_map_layer.gd` (M68): L75 `center_btn.text = "Jugador"` + L76 `tooltip_text = "Volver al jugador (map_center_player)"`.
- `credits_layer.gd` (M129): tooltips L152 «Tiempo de visualización», L294 «Detener o reanudar el desplazamiento automático», L297 «Tamaño de letra (S / M / L)», L300 «Velocidad del desplazamiento», L303 «Modo de alto contraste», L309 «Cambiar idioma de los créditos», L311 «Cerrar créditos (ESC)»; y botones L296 «Tamaño: %s», L299 «Velocidad: %s», L302 «Contraste: %s», L308 «Idioma: %s». El layer SÍ tiene el helper `_tl(clave, defecto)` y lo usa en L100/L140/L293 — el patrón está aplicado a medias.
- Deuda menor: `inventory_layer.gd` L205 `tooltip = item_id` (el tooltip del slot muestra el ID técnico, no el nombre canónico).
**DEUDA owners M68/M129/M06:** migrar los 13 literales a `text_key`/`tooltip_text_key` (claves nuevas con consumo en el mismo commit, regla anti-huérfanas §2.4.2).

**T76 — Títulos de menú por idioma: CORRECTO.** `pause_layer.gd`: título `_t("SETTINGS.PAUSA")` L60 + botones `SETTINGS.CONTINUAR/AJUSTES/GUARDAR/BORRAR_SLOT/SALIR` L72-81 (todos por clave). `settings_audio_layer.gd`: `_t("SETTINGS.AUDIO_TITULO")` L102 + `SETTINGS.MAESTRO/MUSICA/EFECTOS` L109-111 + `CLAVES_RANGO` (SETTINGS.RANGO_*) L44-48. `inventory_layer.gd`: `_t("SETTINGS.INVENTARIO")` L89. `credits_layer.gd`: `_tl("SETTINGS.CREDITOS", "Créditos")` L100. `confirm_popup.gd`: título y mensaje por clave (`configurar(title_key, message_key)` L69-71). Única deuda de título: `menus_layer.gd` L107/L124 «Controles: » + preset técnico — **ya documentada en §2.4.4 (tarea 72)** con propuesta llave-en-mano pendiente del owner M53/M89.

**T77 — Botones de diálogo (Sí/No/Espera): CORRECTO.** `confirm_popup.gd`: `_t("SETTINGS.CONFIRMAR")` / `_t("SETTINGS.CANCELAR")` en ambas variantes (L72-73/L84-85). `dialog_layer.gd`: `SETTINGS.ELEGIR_OPCION` L294 / `SETTINGS.ADVANCED` L296. `pause_layer.gd`: botones por clave. Los literales «Sí»/«No» hallados están SOLO en generators legales dev-side (`audio_credits_generator.gd` L109, `asset_attribution_generator.gd` L51-54 — generan archivos de atribución, no UI runtime → no jugador-visible). «Espera»: 0 ocurrencias en UI de producción.

**T78 — Fondos genéricos vs texto (contraste D102): LÍMITE HONESTO.** Requiere captura en Godot en ejecución (visión) — no disponible en sesión headless; pendiente para sesión con Godot (igual que Tandas 11/25). El tema base (`theme_ux.gd` `_setup_button_styles` L290-298: `COLOR_BTN_ELEVADO` + borde `COLOR_ACCENT_OCRE`) existe y es centralizado — la verificación de contraste real es visual.

**HALLAZGO CROSS-BLOQUE (M159/M39/M53) — resolución de nombres de ítem inconsistente:** `inventory_layer.gd` `_nombre_item` L249-254 SÍ consume el `.tres nombre` canónico (ES, data-driven) con fallback ID maquillado; pero `shop_ui.gd` `_nombre_item` L342-345 y `hotbar_widget.gd` `_friendly_name` L164-165 muestran SOLO el item_id maquillado (`item_id.replace("_", " ")`). El jugador ve nombres DIFERENTES del mismo ítem según la superficie (inventario: «Pergamino: Rec. Tela de Lino»; tienda/hotbar: «Pergamino rec tela lino»). **DEUDA owners M39/M53/M159:** unificar la resolución de nombres (canónico en todas las superficies) como prerequisito del i18n data-driven de M159. Adicional: `CATEGORY_NAMES` (inventory_layer L16-22) = 16 categorías de inventario ES literales jugador-visibles (tabs) — data-driven pendiente de claves i18n (owner M06/M14).

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

**Auditoría TANDA 22 (2026-10-22, tarea 74 — "el texto del BOOT por idioma"):**
- **Texto jugador-visible del boot:** la pantalla de carga (`ui/layers/loading_layer.gd`, M63) es el único texto jugador-visible del flujo de arranque. El `bootstrap.gd` solo imprime a consola ("=== Bootstrap Iniciando ===" L40/L52) — logs de dev, no i18n (§2.4.5).
- **Traducido (3 claves LOADING vigentes):** `LOADING.TITULO` "Isla Ancestral" (L98), `LOADING.CARGANDO` "Cargando..." (L114/L134), `LOADING.TIP` "Consejo:" (L140) — todas en es.po/en.po/JSON ✓.
- **DEUDA (el "boot strings desync"):** los **8 consejos cozy** (`const TIPS`, L17-26) son **literales ES** jugador-visible — el prefijo "Consejo:" se traduce pero el contenido no:
  1. `"Recuerda regar tus plantas cada día..."` (L18)
  2. `"Los vecinos aprecian los regalos..."` (L19)
  3. `"Explora las ruinas antiguas con cuidado..."` (L20)
  4. `"El comercio justo es la clave..."` (L21)
  5. `"Las estaciones cambian la vida de la isla..."` (L22)
  6. `" fotografía puede capturar momentos únicos..."` (L23) — **ANOMALÍA: espacio inicial** (truncamiento de "Una"; confirmar con el owner de M63)
  7. `"El diario registra tus descubrimientos..."` (L24)
  8. `"Respeta la naturaleza de la isla..."` (L25)

**Propuesta llave-en-mano:** 8 claves nuevas `LOADING.TIP_01`..`LOADING.TIP_08` (ES/EN/PT, regla §2.4.2-5):

| Clave | ES | EN | PT |
|---|---|---|---|
| `LOADING.TIP_01` | `Recuerda regar tus plantas cada día...` | `Remember to water your plants every day...` | `Lembre-se de regar suas plantas todos os dias...` |
| `LOADING.TIP_02` | `Los vecinos aprecian los regalos...` | `Neighbors appreciate gifts...` | `Os vizinhos apreciam presentes...` |
| `LOADING.TIP_03` | `Explora las ruinas antiguas con cuidado...` | `Explore the ancient ruins carefully...` | `Explore as ruínas antigas com cuidado...` |
| `LOADING.TIP_04` | `El comercio justo es la clave...` | `Fair trade is the key...` | `O comércio justo é a chave...` |
| `LOADING.TIP_05` | `Las estaciones cambian la vida de la isla...` | `The seasons change island life...` | `As estações mudam a vida na ilha...` |
| `LOADING.TIP_06` | `Una fotografía puede capturar momentos únicos...` (¿"Una" truncado en el literal?) | `A photograph can capture unique moments...` | `Uma fotografia pode capturar momentos únicos...` |
| `LOADING.TIP_07` | `El diario registra tus descubrimientos...` | `The diary records your discoveries...` | `O diário registra suas descobertas...` |
| `LOADING.TIP_08` | `Respeta la naturaleza de la isla...` | `Respect the nature of the island...` | `Respeite a natureza da ilha...` |

**Consumo (para el owner de M63 — NO ejecutado por M87, módulo ajeno):**
```gdscript
const TIP_CLAVES := ["LOADING.TIP_01", "LOADING.TIP_02", "LOADING.TIP_03", "LOADING.TIP_04", "LOADING.TIP_05", "LOADING.TIP_06", "LOADING.TIP_07", "LOADING.TIP_08"]

func _mostrar_tip_aleatorio() -> void:
	if _tip_label and TIP_CLAVES.size() > 0:
		var idx := randi() % TIP_CLAVES.size()
		_tip_label.text = _t("LOADING.TIP") + " " + _t(TIP_CLAVES[idx])
```
Las 8 claves se crean en el **mismo commit** que el consumo (política anti-huérfanas §2.4.4). **Encargo:** asignar al owner de M63.

**Hallazgo de orden de arranque (riesgo de desync):** si la pantalla de carga se instanciara ANTES de que `Localization` cargue los .po, `_t()` devuelve la clave cruda (fallback L143-149). El autoload `Localization` corre antes que los nodos de escena (orden de autoload de Godot) — riesgo bajo — pero el tip literal **no depende del catálogo** (por eso el desync es invisible en runtime: siempre muestra ES). Al migrar a claves, verificar que el tip se muestre después de la carga de catálogos.

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