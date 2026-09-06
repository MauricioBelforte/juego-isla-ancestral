# 07-Resultados-Testings.md — Módulo 87: Localización

> **Modelo:** deepseek-v4-flash
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-04
> **Estado:** Ejecutado — 4/4 suites en verde, 0 fallos

## 1. Resumen ejecutivo

| Suite | Check | Resultado |
|---|---|---|
| Núcleo (iter. 1) | `test_localization.gd` | ✅ 0 fallos (exit 0) |
| Iteración 2 | `test_localizacion_iter2.gd` | ✅ 0 fallos (exit 0) |
| Iteración 3 | `test_localizacion_iter3.gd` | ✅ 0 fallos (exit 0) |
| **Iteración 4 (nueva)** | `test_localizacion_iter4.gd` | ✅ 0 fallos (exit 0) |

**Comando:** `godot472.exe --headless --no-window --path game/isla-ancestral --script res://scripts/localization/<suite>.gd`

## 2. Resultados por caso (iteración 4)

| Caso | Descripción | Resultado |
|---|---|---|
| CP-01 | msgstr[ sin índice → omitido sin crash, resto parsea | ✅ |
| CP-02 | msgstr[99] fuera de rango → omitido sin crash | ✅ |
| CP-03 | plurales válidos msgstr[0]/[1] conservados | ✅ |
| CP-04 | `{sin_cierre` queda literal | ✅ |
| CP-05 | `{param}` sin valor queda literal | ✅ |
| CP-06 | params extra no usados ignorados | ✅ |
| CP-07 | placeholders repetidos `{a}{b}{a}` → "xyx" | ✅ |
| CP-08 | estado catálogos: {total, faltantes, vacias, ok} por idioma | ✅ |
| CP-09 | es.ok true; en sin faltantes (evidencia 64/64) | ✅ |
| CP-10 | validar_catalogos sin faltantes | ✅ |
| CP-11 | plurales n=0/1/2/-3 en es y en | ✅ (tras fix n != -1, ver §3) |
| CP-12 | format_number 0 / -1234.5 / 1e6 separadores correctos | ✅ |
| CP-13 | format_hora 0:05 → "12:05 AM" (12h en) | ✅ |
| CP-14 | format_date relleno 07/03/0026 | ✅ |
| CP-15 | regresión núcleo + iter2 + iter3 | ✅ 3/3 |

## 3. Fix aplicado durante la iteración 4 (NÚCLEO)

**Bug real detectado por el test CP-11:** el contrato del núcleo usaba `n >= 0` para activar la rama plural, lo que EXCLUÍA números negativos (`n=-3` devolvía la clave literal). El checklist exigía "plurales con n = 0, 1, 2, números negativos y decimales".

- **Cambio:** en `localization_manager.gd`, `_tr_clave` y `_buscar_texto` ahora usan `n != -1` (donde `-1` = sin plural, valor por defecto). Cualquier otro valor (0, 1, 2, -3...) activa la rama plural.
- **Compatibilidad:** aditivo, no rompe llamadas existentes (el default `n=-1` conserva comportamiento).
- **Verificado:** test iter4 0 fallos + regresión base 0 fallos.

## 4. Evidencia de cobertura de catálogos

- `es.po` (fuente de verdad): **64 claves**.
- `en.po` (traducción): **64 claves**.
- **Faltantes en vs es: 0** → `validar_catalogos()` en verde.
- El caso especial `ITEMS.SE_OFRECEN` (plural gettext msgstr[0]/[1]) parsea correctamente en ambos idiomas.

## 5. Ruido no atribuible (documentado)

Durante el boot headless aparecen avisos de otros sistemas (autoloads de IA/fauna, `get_path of node not in scene tree`, orphanes al cierre). **No afectan los resultados de M87** (los 4 tests reportan 0 fallos propios) y son teardown del boot del proyecto, no del módulo.

## 6. Pendientes con dueño (fuera de alcance de tests headless)

| Pendiente | Dueño | Tipo |
|---|---|---|
| Selector de idioma visual en configuración | M53/M90 | V2 UI |
| Desbordes de texto inglés +30% en layouts | M53 + QA visual (V1/V4) | C visual |
| Confirmación del idioma del SO (diálogo) | M53 | V2 UI |
| Traducción humana de catálogos de producción | Traductor humano | Revisión |
| Integración con subtítulos M44 en UI | M44 | Integración |