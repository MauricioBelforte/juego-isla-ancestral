# 419 - HALLAZGO GRAVE: 13 de 14 claves de i18n del panel de audio no existen. El jugador vería "SETTINGS.MAESTRO"

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 21:30:00
**Responde a:** step-5-kilocode - 418-2026-10-15_18-08-43-...-m91-informe-final-6-items-con-ui-real-para-flip-del-director.md

## El hallazgo

Verificando a fondo los 6 ítems con UI real del informe 418, encontré algo que cambia su
lectura: **el panel de audio construye sus etiquetas con claves de traducción que no
existen en ningún catálogo.**

`settings_audio_layer.gd` referencia **14 claves `SETTINGS.*`**. De esas, **13 no están en
ninguno de los tres idiomas** (`strings_es.json`, `strings_en.json`, `strings_pt.json`):

```
SETTINGS.AUDIO_FALLA      SETTINGS.COMPRESION        SETTINGS.MUSICA
SETTINGS.DISPOSITIVO_SALIDA  SETTINGS.EFECTOS       SETTINGS.OPCIONES
SETTINGS.MAESTRO          SETTINGS.RANGO_DINAMICO    SETTINGS.RANGO_DINAMICO_PRESET
SETTINGS.RANGO_MEDIO      SETTINGS.RANGO_QUIET       SETTINGS.SILENCIAR
SETTINGS.VOLVER
```

La única que existe es `SETTINGS.AUDIO_TITULO`.

## Impacto real en el jugador

Lo verifiqué en el código de `localization_manager.gd` (el que apunta el autoload,
`res://scripts/localization/localization_manager.gd`, 332 líneas — no confundir con el
`scripts/localizacion/localization_manager.gd` de 69 líneas que también existe):

`_buscar_texto()` busca en el catálogo activo, si no está cae a español, y si tampoco:
```gdscript
if texto == null:
    _avisar_faltante(clave)
    return clave          # ← devuelve la CLAVE LITERAL
```

Y `settings_audio_layer.gd` L481-487 (`_t()`) hace lo mismo como segunda capa. Resultado:
**el jugador vería "SETTINGS.MAESTRO", "SETTINGS.MUSICA", "SETTINGS.SILENCIAR" escritos
en pantalla**, en lugar de "Maestro", "Música", "Silenciar".

Esto **no es hipotético**: es el camino que ejecuta el código hoy.

## Por qué esto cambia la lectura de los 6 flips del 418

En el 418 te propuse flippear L198, L199, L200, L147, L208 y L209 porque tienen UI real.
**La UI existe, pero no es presentable**: los controles funcionan, las etiquetas no.

Mi recomendación cambia: **no flippear esos 6 todavía**. Primero hay que agregar las 13
claves a los tres catálogos, que es trabajo chico y mecánico. Después sí, los 6 flips
quedarían legítimos.

## Qué NO hice

No toqué `strings_es.json` ni los otros catálogos: son de M87-Localización, y el ítem
L179 de M91 (subtítulos por idioma) ya apunta a ese dueño. Te lo reporto para que decidas
si lo delega a M87 o lo hago yo con tu visto bueno.

## Dos apuntes menores del mismo barrido

- **Hay dos archivos `localization_manager.gd`** en el proyecto:
  `scripts/localization/localization_manager.gd` (332 líneas, el que usa el autoload) y
  `scripts/localizacion/localization_manager.gd` (69 líneas). El segundo parece muerto.
  No lo toqué, pero puede ser basura descartable.
- **`_avisar_faltante()`** emite un `push_warning` por clave ausente (con guardia para no
  repetir). Con 13 claves faltantes, el log tendría 13 warnings al abrir el panel. No es
  un bug, pero ensucia la consola.

## Estado

M91 sigue **207/239 sin cambios**. Este hallazgo no agrega ni quita ítems: cambia el
criterio para los 6 flips que te propuse en el 418.

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
