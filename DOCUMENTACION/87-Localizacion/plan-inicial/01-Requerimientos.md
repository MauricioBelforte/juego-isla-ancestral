**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 87: Localización

## ID del Módulo
- **Código:** M87 (CHECKLIST-GLOBAL: ID 87 — Localización)
- **Carpeta:** `DOCUMENTACION/87-Localizacion/`
- **Dependencias:** M21 (Diálogos), M53 (UI-UX). Relacionados: M44 (ASMR y Feedback — subtítulos), M58 (Accesibilidad), M60 (Datos y Serialización), M88 (Fuentes Tipográficas), M90/M91 (Configuración)
- **Carácter:** Módulo de internacionalización (i18n) y localización (l10n) de todos los textos del juego

## 1. Problema

El juego "Isla Ancestral" (mundo voxel cozy, isla Aurora) muestra miles de textos al jugador: menús, HUD, descripciones de objetos, diálogos (M21), subtítulos (M44), misiones, carteles y notificaciones. Sin un sistema de localización, todos esos textos quedarían hardcodeados en español, lo que haría imposible lanzar el juego en inglés (segundo idioma del lanzamiento) o en idiomas futuros sin reescribir código y escenas. Además, los textos dinámicos (cantidades, nombres de objetos, fechas, números con separadores distintos) requieren una infraestructura que los maneje correctamente en cada idioma, incluidos los plurales y los cambios en vivo sin reiniciar el juego.

## 2. Objetivo

Implementar sobre Godot 4.x un sistema de localización completo que:

1. Soporte español (idioma nativo) e inglés desde el lanzamiento inicial.
2. Permita agregar idiomas adicionales sin tocar código (solo agregar un archivo de traducción y una entrada en el selector).
3. Traduzca automáticamente los textos de UI (M53), diálogos (M21) y subtítulos (M44).
4. Maneje placeholders, plurales y formatos de fecha y número por idioma.
5. Permita cambiar de idioma en vivo desde la configuración y persistir la elección entre sesiones.

## 3. Alcance

### Incluye
- Sistema de catálogos de traducción (`.po` / TranslationServer de Godot).
- `LocalizationManager` (autoload) como capa central de gestión de idioma.
- Selector de idioma en el menú de configuración (M53/M90).
- Convenciones de claves de traducción para todo el proyecto.
- Integración con textos de UI (M53), diálogos (M21) y subtítulos (M44).
- Formato de fechas, números y plurales por idioma.
- Fallback al idioma nativo (español) ante claves faltantes o catálogos corruptos.

### Excluye
- La traducción real del contenido narrativo extenso (requiere revisión humana de escritores y traductores).
- La localización de assets gráficos con texto incrustado (se evita por diseño; el texto visible siempre viaja por catálogos).
- Traducción automática externa (servicios en la nube) en el build final: el juego debe ser 100% offline.
- Idiomas CJK (requieren fuentes y layout específicos de M88; actualmente fuera del alcance inicial).

## 4. Restricciones

- Motor Godot 4.x, lenguaje GDScript (sin C#/Unity).
- Idiomas iniciales: español (nativo, fuente de verdad) e inglés.
- Prohibido hardcodear texto visible fuera de los catálogos (ni en código, ni en escenas, ni en prefabs).
- El sistema debe funcionar offline, sin servicios externos.
- La elección de idioma se persiste en la configuración del jugador (M60).
- Los caracteres de los idiomas soportados deben estar cubiertos por las fuentes de M88.
- Los catálogos `.po` deben ser editables con herramientas estándar de traducción (Poedit, etc.).
- La zona horaria del juego (M29/M30) se muestra con formato localizado pero el tiempo interno permanece sin cambios.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Idioma por defecto | Español al primer inicio (idioma nativo del juego) |
| RF2 | Seleccionar idioma | Selector de idioma en configuración (español, inglés) |
| RF3 | Cambiar idioma en vivo | El cambio se aplica de inmediato a toda la UI abierta sin reiniciar |
| RF4 | Persistir idioma | La elección se guarda en la configuración del jugador (M60) |
| RF5 | Cargar catálogo | Cargar el catálogo `.po` del idioma activo al iniciar |
| RF6 | Precargar catálogos | Precargar los catálogos de los idiomas soportados para cambio instantáneo |
| RF7 | Traducir clave | `Localization.tr_key(module, section, key)` devuelve el texto localizado |
| RF8 | Placeholders | Textos con `{nombre}` o `{cantidad}` reemplazables dinámicamente |
| RF9 | Plurales | Formas singular/plural según idioma y cantidad (msgid_plural) |
| RF10 | Fechas localizadas | Formato de fecha según idioma (d/m/Y vs m/d/Y) |
| RF11 | Números localizados | Separadores decimales y de miles según idioma |
| RF12 | Fallback de clave | Clave ausente en el idioma activo se muestra en español |
| RF13 | Fallback de catálogo | Catálogo ausente o corrupto no impide arrancar el juego |
| RF14 | Detección de idioma del sistema | Sugerir el idioma del SO (si está soportado) en el primer arranque, con confirmación |
| RF15 | Catálogo español | `es.po` completo y fuente de verdad (msgid = clave, msgstr = texto en español) |
| RF16 | Catálogo inglés | `en.po` con todas las claves traducidas |
| RF17 | Diálogos localizados | M21 resuelve líneas y opciones a través de claves de localización |
| RF18 | Subtítulos localizados | M44 muestra subtítulos en el idioma activo |
| RF19 | UI localizada | M53 usa claves de localización en todos los controles visibles |
| RF20 | Convención de claves | Prefijo `MODULO.SECCION.CLAVE` (UPPER_SNAKE) en todo el proyecto |
| RF21 | Validación de catálogos | Script que detecta claves faltantes, sobrantes y errores de formato `.po` |
| RF22 | Señal de cambio de idioma | Señal `locale_changed` para que la UI suscrita se re-traduzca |
| RF23 | Idiomas en su propio idioma | El selector muestra "Español" y "English" (nombre nativo de cada idioma) |
| RF24 | Contexto desambiguante | Entradas con contexto en `.po` para términos que cambian según uso |

## 6. Requisitos No Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RN1 | Rendimiento | Traducción sin penalizaciones perceptibles (cache de resultados, sin parseos repetidos) |
| RN2 | Offline | Sin llamadas de red; todo el contenido de traducción es local |
| RN3 | Escalabilidad | Agregar idioma = agregar 1 archivo `.po` + 1 entrada en el selector |
| RN4 | Mantenibilidad | Claves agrupadas por módulo y documentadas (convención única) |
| RN5 | Compatibilidad de fuentes | Caracteres del idioma soportados por las fuentes de M88 |
| RN6 | Accesibilidad | Ajustes de tamaño de texto (M58) no rompen la traducción ni el layout |
| RN7 | Longitud variable | El inglés puede alargar textos +30%; los layouts deben tolerarlo |
| RN8 | Consistencia | Un mismo término se traduce igual en todo el juego (glosario) |
| RN9 | Calidad | Revisión humana de las traducciones antes del lanzamiento |
| RN10 | Codificación | Archivos `.po` en UTF-8 sin BOM, saltos LF |
| RN11 | Sin hardcodeo | Ningún texto visible hardcodeado fuera de los catálogos |
| RN12 | Compatibilidad de herramientas | `.po` válido para Poedit y herramientas gettext estándar |

## 7. Criterios de Aceptación

1. El juego arranca en español por defecto en el primer inicio.
2. El jugador cambia a inglés desde configuración y toda la UI abierta cambia al instante.
3. El idioma elegido persiste entre sesiones y se aplica al volver a iniciar.
4. Los diálogos (M21) se muestran en el idioma activo, incluidas las opciones y los placeholders.
5. Los subtítulos (M44) siguen el idioma activo.
6. Una clave inexistente muestra el texto en español sin romper la UI.
7. Un `.po` corrupto o faltante no impide arrancar el juego (usa el catálogo válido o el fallback).
8. Los números y fechas se formatean según el idioma activo (1.234,56 vs 1,234.56).
9. Se puede agregar un idioma futuro solo con un `.po` nuevo y una entrada en el selector.
10. El checklist del módulo (05-Checklist.md) está completo y sin ítems pendientes.