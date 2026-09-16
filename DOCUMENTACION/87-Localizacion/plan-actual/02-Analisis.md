**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13 (correcciones doc↔código de la iter. 5; texto original: Deepseek V4 Flash / OpenCode, 2026-08-26)

# 02-Analisis.md — Módulo 87: Localización

## 1. Análisis del dominio

### 1.1 Idiomas del juego

| Idioma | Código Godot | Rol | Estado |
|---|---|---|---|
| Español | `es` | Idioma nativo, fuente de verdad de todos los textos | Lanzamiento inicial |
| Inglés | `en` | Segundo idioma del lanzamiento (mercado cozy/voxel amplio) | Lanzamiento inicial |
| Portugués, francés, alemán, italiano | `pt`, `fr`, `de`, `it` | Candidatos futuros (mismo conjunto de caracteres latinos) | Futuro (infraestructura lista) |
| CJK (chino, japonés, coreano) | `zh`, `ja`, `ko` | Requiere fuentes CJK y layout distinto (M88) | Fuera de alcance inicial |

El español es el idioma en el que se escriben los textos originales del proyecto (mundo cozy y escrito original en español), por eso `es.po` es la fuente de verdad y el fallback de todos los idiomas. El inglés se integra desde el lanzamiento porque es el idioma estándar de distribución en Steam y amplía el público del género cozy.

### 1.2 Flujo de traducción (producción de contenido)

1. Los escritores escriben el contenido en español (fuente de verdad) y lo agregan como nuevas claves en `es.po`.
2. Las claves se copian a `en.po` (los traductores ven el texto español original como referencia en el archivo `.po`).
3. Los traductores humanos traducen los `msgstr` de `en.po` con herramientas estándar (Poedit, etc.).
4. `TranslationValidator` corrobora que no falten claves entre catálogos y que el formato `.po` sea válido.
5. QA de localización: recorrido visual del juego en ambos idiomas buscando desbordes, caracteres faltantes y placeholders mal resueltos.

### 1.3 Claves vs strings literales

**Opción claves (adoptada):** los textos se referencian por clave (`HUD.ENERGIA`) y el valor vive en los catálogos.

- Ventajas: un solo lugar para cambiar el texto (cambiar "Energía" por otro término actualiza todo el juego), sin duplicados, permite glosario consistente, los traductores nunca tocan código, el fallback es natural (clave -> español).
- Desventaja: indirección inicial (escribir `tr_key(...)` en vez del texto). Se mitiga con una convención documentada y con la reutilización de claves por módulo.

**Opción strings literales (rechazada):** usar el texto en español como clave (gettext clásico).

- Ventajas: cero indirección en el código.
- Desventajas: cualquier cambio de redacción del texto fuente obliga a re-traducir en todos los idiomas; es imposible distinguir dos textos idénticos con contexto distinto (ej: "Playa" como bioma vs como destino de viaje); el glosario es incontrolable. En un juego con cientos de nombres propios y términos reutilizados, las claves son la opción correcta.

### 1.4 Placeholders

Los textos dinámicos se escriben en el catálogo con marcadores legibles para traductor:

```
msgid "DIALOGOS.ENTREGA"
msgstr "Recibí {cantidad} de {objeto}."
```

- `LocalizationManager.format_text(texto, params)` reemplaza `{clave}` por su valor con `String.replace()` iterando sobre `params` (NO usa expresión regular — corrección iter. 5). Antes de reemplazar cuenta llaves: si `texto.count("{") != texto.count("}")` deja el texto **literal** y emite un warning de desarrollo, para que un placeholder mal formado (`{sin_cierre`) no genere basura en la UI.
- ⚠️ **Conviven DOS convenciones de placeholder** (hallazgo iter. 5, verificado):
  - `{clave}` — la de este módulo, aplicada por `format_text()`.
  - `%s` / `%d` — operador `%` de Godot, aplicado **por el llamador** después de traducir. En uso real: `SETTINGS.CRAFT_OK` (`crafting_ui.gd`), `TIENDAS.COMPRA_INFO` y `TIENDAS.VENTA_INFO` (`shop_ui.gd`).
  El catálogo no mezcla ambas en una misma entrada, pero la coexistencia contradice la decisión documentada en §1.4 (los `%s` encadenados son posicionales y reintroducen el riesgo de orden al traducir). `ValidadorPO` lo vigila con la regla R12 y el par de idiomas con P3.
- Las claves sin valor en `params` se mantienen visibles y generan un warning de desarrollo (nunca crashean la UI).
- Los placeholders son legibles para traductores humanos (a diferencia de `%s` encadenados), lo que evita errores de orden al traducir.
- Godot 4 expone `tr(message, context, plural_n)` y `TranslationServer.translate()`; el reemplazo de `{clave}` es responsabilidad propia del módulo (no lo resuelve el motor).

### 1.5 Plurales

Godot 4 soporta plurales de gettext nativamente a través de la entrada `msgid_plural` en los `.po`, combinada con el tercer argumento de `tr()` (índice de plural) y la cabecera `Plural-Forms` del catálogo:

- Español e inglés comparten regla: `nplurals=2; plural=(n != 1);` (2 formas: singular y plural).
- Ejemplo español: `msgstr[0] "Recibí {n} objeto"` / `msgstr[1] "Recibí {n} objetos"`.
- El código llama a la traducción con el número y `LocalizationManager` combina el resultado con `format_text` para inyectar `{n}`.
- ⚠️ **Límite real (corrección iter. 5):** la cabecera `Plural-Forms` **está presente** en los `.po` y es válida para Poedit/gettext, pero el módulo **no la parsea**: `_indice_plural(locale, n, nformas)` resuelve el índice con una regla **hardcodeada** para es/en (`0 si n == 1, si no 1`). Consecuencia práctica: un idioma nuevo con más de 2 formas plurales (p. ej. ruso, polaco) requeriría tocar código, lo que contradice RN3 ("idioma nuevo = 1 `.po` + 1 entrada en el selector"). Aceptado para el alcance actual (es/en comparten la regla); queda registrado como deuda técnica.
- Regla del dominio: los plurales se usan solo donde la cantidad es parte visible del texto; el HUD numérico (ej: contador de madera) no requiere plurales porque no lleva palabra acompañante.

### 1.6 Fechas y números

- **Números:** español usa coma decimal y punto de miles (1.234,56); inglés usa punto decimal y coma de miles (1,234.56). `LocaleUtils.format_number(valor, idioma)` aplica la conversión con las tablas por idioma.
- **Fechas:** español `dd/mm/yyyy`; inglés `mm/dd/yyyy`. El juego interno usa el calendario de M29/M30; la presentación delega en `LocaleUtils.format_date(datetime_dict, idioma)`. Los nombres de meses/días también viajan por catálogo cuando el formato los incluye.
- **Hora:** formato 24h en español; en inglés se muestra 12h con AM/PM (estilo cozy, más cercano a la cultura anglófona). Se mantiene configurable (M29).

### 1.7 Pruebas de localización (QA)

- Capturas de pantalla pareadas (es/en) de cada pantalla para detectar desbordes y truncamientos (especialmente textos +30% más largos en inglés).
- Lista de caracteres de cada idioma comparada contra las fuentes de M88 (glifos faltantes).
- Recorrido funcional: diálogos, subtítulos, tooltips, notificaciones, inventario, tiendas, misiones.
- Testing de fallback: borrar una clave del inglés y verificar que la UI cae a español sin errores.
- Testing de catálogos: corromper un `.po` y verificar que el juego arranca con el catálogo válido anterior o el fallback.

### 1.8 Herramientas Godot

- **TranslationServer:** registro de traducciones y `set_locale()` global del motor.
- **Loader de `.po`:** Godot 4 *puede* cargar un `.po` directamente (`load("res://locales/es.po")` devuelve una `Translation`). **Decisión real del módulo (corrección iter. 5):** el código **no usa ese camino**. `_parse_po()` implementa un parser propio y luego construye la `Translation` a mano (`Translation.new()` + `add_message()` por clave) antes de `TranslationServer.add_translation()`. Motivo: el parser propio tolera catálogos corruptos degradando con gracia (edge case del checklist) y separa las formas plurales de los mensajes simples. Coste: no se aprovecha el loader del motor y hay que mantener el parser.
- **`tr()`:** el módulo **no** traduce con `Object.tr()`; su API pública es `tr_key()` / `traducir_clave()` / `tr_ctx()`. La `Translation` registrada en `TranslationServer` deja `tr()` disponible para quien lo prefiera, pero el núcleo no depende de él (evita el acoplamiento al locale global del motor para la cache propia).
- **Autoload:** `LocalizationManager` se registra como autoload `Localization` para acceso global.
- **Editor:** ⚠️ **corrección iter. 5** — `project.godot` **no tiene sección `internationalization`**: el fallback de locale del editor **no está configurado**. La afirmación previa ("el proyecto configura `es` como locale de fallback del editor") era falsa; el idioma efectivo se fija en runtime con `TranslationServer.set_locale()`. Tampoco existe un script `TranslationValidator`: la validación vive en `LocalizationManager.validar_catalogos()` / `obtener_estado_catalogos()` y, desde la iter. 5, en `ValidadorPO` (reglas R1-R13 / P1-P5) y `AuditorClaves` (código↔catálogo).

## 2. Alternativas

### Opción A: Catálogos `.po` + TranslationServer (gettext estándar) — ADOPTADA

- Ventajas: estándar de la industria de localización; herramientas maduras (Poedit, msgmerge, msgfmt); plurales nativos (msgid_plural); contexto por entrada; soporte nativo del motor Godot 4; los traductores profesionales ya conocen el formato; diff en git legible y granular (una entrada por bloque).
- Desventajas: más ceremonia que un JSON simple; editarlo a mano requiere cuidado con la sintaxis. Se mitiga con el validador automático.

### Opción B: Diccionarios JSON propios

- Ventajas: muy simples de leer y editar por un programador.
- Desventajas: sin plurales nativos, sin contexto para traductores, sin herramientas estándar, sin cabeceras de metadatos; fuerza a reinventar validación, glosario y flujo de traducción; el ecosistema gettext de terceros queda fuera. Rechazada.

### Opción C: CSV/TSV

- Ventajas: editable en planillas.
- Desventajas: problemático con comas y saltos de línea dentro de textos largos (diálogos), sin plurales, sin contexto, sin herramientas de traducción. Rechazada.

## 3. Decisiones técnicas

| Tema | Decisión | Justificación |
|---|---|---|
| Formato de catálogos | `.po` (gettext) vía TranslationServer | Estándar, soporte nativo de Godot 4, plurales y contexto |
| Idioma fuente | Español (`es`), como fallback global | El juego se escribe originalmente en español |
| Claves vs strings | Claves `MODULO.SECCION.CLAVE` | Control de glosario, singularidad y mantenibilidad |
| Placeholders | `{clave}` con `format_text()` propio | Legible para traductores, evita errores de orden |
| Plurales | `msgid_plural` + `tr(..., plural_n)` | Nativo de gettext/Godot |
| Fechas y números | `LocaleUtils` con tablas por idioma | Separadores y órdenes distintos por cultura |
| Cambio de idioma | En vivo, con señal `locale_changed` | Mejor UX; Godot re-traduce labels solo en escenas reconstruidas, por eso la señal re-aplica textos |
| Persistencia | Configuración del jugador (M60) | Separación de la lógica y el guardado |
| Precarga | Todos los catálogos soportados en la pantalla de carga | Cambio instantáneo; los `.po` son livianos |
| Fallback | Clave -> español -> clave literal | Nunca una UI vacía o rota |
| Primer arranque | Sugerir idioma del SO con confirmación | Mejor primera impresión sin sorpresas |
| Validación | Script dev/test (`TranslationValidator`) | Evita lanzar builds con claves rotas |
| Idiomas futuros | Solo agregar `.po` + entrada en selector | Escalabilidad sin tocar código |

## 4. Hallazgos verificados (iter. 5 — DeepSeek-V4.1-Flash, 2026-09-13)

Todos los puntos de esta sección salen de correr código, no de leerlo: `AuditorClaves.auditar("res://scripts", "res://locales/es.po")` (702 archivos `.gd` escaneados), `ValidadorPO.validar_par()` y el log de arranque headless del juego.

### 4.1 Inventario de claves código ↔ catálogo

| Métrica | Valor |
|---|---|
| Archivos `.gd` escaneados | 702 |
| Claves usadas en código | 54 |
| Claves en `es.po` | 85 (64 originales + 21 agregadas en la iter. 5) |
| Claves de **producción** usadas y ausentes del catálogo | **0** (antes: 7) |
| Claves usadas solo por tests (probes de `tr_ctx`) | 3 |
| Claves del catálogo consumidas por prefijo dinámico | 14 (`DIARY.CAT_*`) |
| Claves del catálogo sin uso literal ni dinámico | 23 |

**Las 7 claves que la UI invocaba y no existían** (la UI mostraba la clave cruda en pantalla; confirmado en el log de arranque con `[M87] Clave sin traducción: …`):

| Clave | Consumidor | Texto agregado (es / en) |
|---|---|---|
| `DIARY.CATEGORIAS` | `diary_layer.gd:54` | Categorías / Categories |
| `DIARY.ENTRADAS` | `diary_layer.gd:71` | Entradas / Entries |
| `DIARY.SIN_ENTRADAS` | `diary_layer.gd:146` | Todavía no hay entradas… / There are no entries… |
| `LOADING.TITULO` | `loading_layer.gd:98` | Isla Ancestral / Ancestral Island |
| `LOADING.CARGANDO` | `loading_layer.gd:59,114,134` | Cargando... / Loading... |
| `LOADING.TIP` | `loading_layer.gd:140` | Consejo: / Tip: |
| `SETTINGS.FUERA_TEMPORADA` | `crafting_ui.gd:206` | Fuera de temporada / Out of season |

Además se agregaron las **14** variantes dinámicas `DIARY.CAT_<CATEGORÍA>` (lista en `DiaryService.CATEGORIAS`). Los textos son **provisionales**: requieren revisión humana antes del lanzamiento (RN9).

Las **23 claves sin uso literal ni dinámico** no se borraron: la inspección puntual muestra que son claves-semilla documentadas en `03-Diseno.md` §2.4 (`MAIN_MENU.PLAY`, `HUD.VIDA`, `ITEMS.MADERA`, `SETTINGS.IDIOMA`…) que consumirán las integraciones M53/M21 aún pendientes, más claves data-driven. Borrarlas rompería esas integraciones; el auditor las reporta para que el equipo decida.

### 4.2 ⚠️ Conviven DOS autoloads de localización

`project.godot` registra **dos** autoloads que hacen lo mismo por vías distintas:

| Autoload | Script | Catálogos | Consumidores |
|---|---|---|---|
| **`Localization`** (línea 60) | `scripts/localization/localization_manager.gd` (14 KB) | `locales/*.po` + `TranslationServer` | **~20 archivos**: UI (M53), diálogos (M21), crafting, tiendas, reloj, créditos… |
| **`LocalizationManager`** (línea 108) | `scripts/localizacion/localization_manager.gd` (2,7 KB) | `data/localizacion/strings_*.json` | **ninguno de producción**: su `get_texto()` solo aparece en su propio archivo y en su test. Registra `ServiceRegistry.register("localizacion", …)`, que nadie consume |

El segundo arranca en cada boot, parsea 3 catálogos JSON y registra un servicio que nadie usa. `data/localizacion/strings_es.json` sí lo lee `test_capitulos_m74.gd` (directo del archivo, no vía el autoload), y `strings_pt.json` existe aunque el portugués no está en `LOCALES_SOPORTADOS` de ninguno de los dos sistemas.

**Recomendación:** eliminar el autoload `LocalizationManager` (o marcarlo como obsoleto) y dejar `Localization` como única capa. **No se ejecutó en esta iteración**: quitar un autoload es un cambio transversal que puede afectar a otro módulo, así que queda registrado como hallazgo para decisión del usuario/dueño del módulo.

### 4.3 Convención de claves: una excepción real

`npc.catalina` no cumple `MODULO.SECCION.CLAVE` en UPPER_SNAKE, pero **no es un error**: es el `speaker_key` de M21, tomado del `id` del NPC en `data/dialogues/*.json` (minúsculas por diseño de los datos). `ValidadorPO.EXCEPCIONES_CLAVE` la exceptúa explícitamente; renombrarla rompería la integración M21/M22.

Se detectó además que `SETTINGS.*` está **sobrecargado**: contiene textos de menú, pausa, crafting, inventario y tooltips (`SETTINGS.MESA_TRABAJO`, `SETTINGS.CRAFT_OK`, `SETTINGS.INVENTARIO_HINT`). Es una desviación de RN4 ("claves agrupadas por módulo"), no un bug; se deja documentada para una futura normalización.

### 4.4 Rendimiento: el aviso de clave ausente costaba ~16 ms

Medición directa (200 llamadas, headless):

| Escenario | Tiempo | Nota |
|---|---|---|
| Clave **existente** (`SETTINGS.PAUSA`) | **333 µs** | la cache funciona: ~1,6 µs por traducción |
| Clave **ausente** (`MENUS.SALUDOS.HOLA`) | **16.774 µs** | ≈16 ms de **un solo `push_warning`** (imprime backtrace completo) + 199 aciertos de cache |

El coste no era la cache sino el aviso. **Corregido en la iter. 5:** `_avisar_faltante()` deduplica por clave (`_avisadas`), de modo que 50 llamadas a la misma clave ausente generan **1** aviso en vez de 50. Se expone `claves_faltantes()` para dev/CI.

> Este hallazgo salió de un **fallo del test de iteración 2**, que medía la cache con una clave ausente: el umbral de 20 ms se incumplía por el aviso, no por la cache. El test se corrigió para medir con una clave existente y además ahora verifica el dedup.