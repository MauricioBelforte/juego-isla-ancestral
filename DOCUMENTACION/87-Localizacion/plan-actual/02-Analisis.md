**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

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

- `LocalizationManager.format_text(texto, params)` reemplaza `{clave}` por su valor con una expresión regular `\{\w+\}`.
- Las claves sin valor en `params` se mantienen visibles y generan un warning de desarrollo (nunca crashean la UI).
- Los placeholders son legibles para traductores humanos (a diferencia de `%s` encadenados), lo que evita errores de orden al traducir.
- Godot 4 expone `tr(message, context, plural_n)` y `TranslationServer.translate()`; el reemplazo de `{clave}` es responsabilidad propia del módulo (no lo resuelve el motor).

### 1.5 Plurales

Godot 4 soporta plurales de gettext nativamente a través de la entrada `msgid_plural` en los `.po`, combinada con el tercer argumento de `tr()` (índice de plural) y la cabecera `Plural-Forms` del catálogo:

- Español e inglés comparten regla: `nplurals=2; plural=(n != 1);` (2 formas: singular y plural).
- Ejemplo español: `msgstr[0] "Recibí {n} objeto"` / `msgstr[1] "Recibí {n} objetos"`.
- El código llama a la traducción con el número y `LocalizationManager` combina el resultado con `format_text` para inyectar `{n}`.
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
- **Loader de `.po`:** Godot 4 carga archivos `.po` directamente (`load("res://locales/es.po")` devuelve una `Translation`), sin compilación previa a `.translation`. Mecanismo estándar documentado del motor.
- **`tr()`:** método de `Object` que traduce con el locale activo; soporta contexto y plural.
- **Autoload:** `LocalizationManager` se registra como autoload `Localization` para acceso global.
- **Editor:** el proyecto configura `es` como locale de fallback del editor para previsualizar textos; los catálogos se validan con `TranslationValidator` en modo desarrollo/test.

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