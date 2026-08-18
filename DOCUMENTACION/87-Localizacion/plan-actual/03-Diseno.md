**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 87: Localización

## 1. Arquitectura del módulo

```
Localización (M87)
├── LocalizationManager (autoload "Localization")
│   ├── Idioma activo (String, ej: "es", "en")
│   ├── Catálogos registrados en TranslationServer
│   ├── Cache de traducciones frecuentes (Dictionary)
│   ├── Señal: locale_changed(locale)
│   ├── API:
│   │   ├── set_locale(locale)
│   │   ├── get_locale() / get_locale_display_name()
│   │   ├── tr_key(module, section, key, params)
│   │   ├── format_text(text, params)
│   │   ├── format_number(value) / format_date(dict)
│   │   └── validar_catalogos() (dev/test)
│   └── Fallback: clave -> es.po -> clave literal
├── LocaleUtils (RefCounted estático)
│   ├── Formato de números por idioma (comas/puntos)
│   ├── Formato de fechas por idioma (orden d/m/Y vs m/d/Y)
│   └── Nombres nativos de idiomas ("Español", "English")
├── TranslationValidator (dev/test)
│   ├── Claves faltantes entre catálogos
│   ├── Claves sobrantes (huérfanas)
│   ├── Errores de sintaxis .po
│   └── Placeholders inconsistentes entre idiomas
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

La arquitectura sigue la regla de modularidad del proyecto: el `LocalizationManager` es la única capa que conoce el motor de traducción (TranslationServer) y los catálogos; la UI (M53) y los sistemas de texto (M21, M44) solo llaman a sus funciones expuestas, sin acoplarse a `.po` ni a detalles de gettext.

## 2. Componentes

### 2.1 LocalizationManager (autoload "Localization")

Responsabilidades:

1. **Cargar catálogos:** en `_ready()` carga los `.po` de los idiomas soportados (`TranslationServer.add_translation(load(...))`) y precarga los catálogos en la pantalla de carga (M63) para cambio instantáneo.
2. **Aplicar idioma:** `set_locale()` valida el locale contra la lista soportada, aplica `TranslationServer.set_locale()`, limpia la cache, persiste (M60) y emite `locale_changed`.
3. **Traducir:** `tr_key(module, section, key, params)` arma la clave completa, la traduce con cache (`tr_cached`) y aplica `format_text`. Si la traducción devuelve la propia clave (ausente), cae al catálogo español y, en última instancia, devuelve la clave literal (jamas texto vacío).
4. **Formatear:** delega números y fechas en `LocaleUtils` según el idioma activo.
5. **Validar:** en modo desarrollo, `validar_catalogos()` corre `TranslationValidator` y reporta por consola.

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
- En el primer arranque, si el idioma del SO está soportado, se muestra el selector en la pantalla de bienvenida con la sugerencia ya preseleccionada y un botón de confirmación (nunca se cambia el idioma sin consentimiento explícito).
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

### 2.5 Flujo de agregar un idioma nuevo

1. Copiar `es.po` como `xx.po` (xx = código ISO del idioma).
2. Editar la cabecera (`Language: xx`, `Plural-Forms` si difiere del español).
3. Traducir los `msgstr` (dejar en español lo aún no traducido).
4. Agregar el idioma en la lista `SUPPORTED_LOCALES` del `LocalizationManager` y al selector de configuración con su nombre nativo.
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
3. `format_text()` reemplaza `{cantidad}` y `{objeto}` con el patrón `\{\w+\}`; las claves sin valor quedan literales y emiten warning en desarrollo.

### 3.4 Plurales

1. Catálogo declara `msgid_plural` y `msgstr[0]`/`msgstr[1]`.
2. Código: `tr("ITEMS.SE_OFRECEN", "", n)` obtiene la forma correcta según `Plural-Forms` del idioma activo.
3. `format_text()` inyecta `{n}` si el texto lo declara.

### 3.5 Formatos de fecha y número

1. `LocaleUtils` mantiene tablas por idioma: separador decimal, separador de miles, orden de fecha, reloj 12h/24h.
2. `format_number(1234.56)` -> español "1.234,56" / inglés "1,234.56".
3. `format_date(datetime_dict)` -> español "17/08/2026" / inglés "08/17/2026".