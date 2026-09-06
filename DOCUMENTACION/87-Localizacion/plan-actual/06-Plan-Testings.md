# 06-Plan-Testings.md — Módulo 87: Localización

> **Modelo:** deepseek-v4-flash
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-04
> **Estado:** Plan ejecutado en iteración 4 (resultados en 07-Resultados-Testings.md)

## 1. Alcance

Sistema transversal de internacionalización (i18n/l10n) sobre Godot 4.x: LocalizationManager (autoload `Localization`), LocaleUtils (formato números/fechas/hora), catálogos gettext `.po` (es fuente / en traducción), validación RF21 y edge cases de parseo/formato. El selector de idioma visual pertenece a M53/M90 (V2) y se prueba allí.

## 2. Entorno de ejecución

- **Motor:** Godot 4.7.2 stable (`C:\Temp\godot\godot472.exe`)
- **Modo:** headless (`--headless --no-window --path game/isla-ancestral --script res://...`)
- **Proyecto:** `game/isla-ancestral/`

## 3. Suites de tests

| Suite | Archivo | Cobertura |
|---|---|---|
| Núcleo (iter. 1) | `test_localization.gd` | Carga catálogos, traducción es/en, placeholders, plurales, formato, fallback, validar_catalogos |
| Iteración 2 | `test_localizacion_iter2.gd` | Persistencia M60, sugerencia SO, contexto gettext, cache, debug |
| Iteración 3 | `test_localizacion_iter3.gd` | Cobertura M88 (fuentes por idioma), validación RF14 |
| **Iteración 4 (nueva)** | `test_localizacion_iter4.gd` | **Parseo .po corrupto sin crash, placeholders mal formados, estado de catálogos RF21, plurales n=0/negativos, formatos edge** |

## 4. Casos de prueba (iteración 4 — robustez determinista)

### 4.1 Parseo de .po corrupto (T-084)
- **CP-01:** catálogo con `msgstr[ sin_indice]` → se omite la línea, no crashea, el resto del catálogo parsea. Criterio: exit 0, clave sana sigue traduciendo.
- **CP-02:** catálogo con `msgstr[99]` (índice fuera de rango) → se omite, no crashea.
- **CP-03:** catálogo con plurales válidos `msgstr[0]/msgstr[1]` → se conservan íntegros.

### 4.2 Placeholders (T-085/T-086/T-087)
- **CP-04:** texto con `{sin_cierre` → queda literal, no rompe la UI ni crashea.
- **CP-05:** texto con `{param}` sin valor en params → queda literal (foo dev warning).
- **CP-06:** params con claves extra no usadas → se ignoran, texto resultante correcto.
- **CP-07:** placeholders repetidos `{a}{b}{a}` → se reemplazan todas las ocurrencias.

### 4.3 Estados de catálogos (RF21 ampliado)
- **CP-08:** `obtener_estado_catalogos()` devuelve por idioma `{total, faltantes, vacias, ok}`.
- **CP-09:** es (fuente) siempre `ok:true`; en cubre 100% de es (evidencia 64/64).
- **CP-10:** `validar_catalogos()` sin claves faltantes entre es y en.

### 4.4 Plurales y formatos edge
- **CP-11:** plural es/en con n=0, 1, 2 y n=-3 (negativos activan rama plural tras fix iter. 4).
- **CP-12:** `format_number` con 0, negativos y valores ≥ 1e6 (separadores de miles correctos).
- **CP-13:** `format_hora` 12h en medianoche (0:05 → 12:05 AM).
- **CP-14:** `format_date` con día/mes/año de un dígito (relleno 2/4 dígitos).

### 4.5 Regresión
- **CP-15:** las 3 suites anteriores (núcleo, iter2, iter3) siguen en 0 fallos tras los cambios de iteración 4.

## 5. Criterios de éxito

- Exit code 0 en las 4 suites headless.
- 0 fallos en cada suite.
- Sin regresiones en M21 (resolve_text traduce claves) ni M88 (fuentes por idioma) — verificadas por los tests del módulo.

## 6. Límites del plan

- **Selector de idioma visual (M53/M90):** V2, requiere UI — fuera del alcance de tests headless (se prueba en M53).
- **Desbordes de texto +30% en inglés (T-039/T-088):** C, requiere QA visual con capturas (V1/V4) — se delega a revisión con visión.
- **Traducción humana del catálogo completo:** el contenido narrativo crece de forma continua; cada clave nueva debe agregarse a es.po y en.po (validar_catalogos lo controla).