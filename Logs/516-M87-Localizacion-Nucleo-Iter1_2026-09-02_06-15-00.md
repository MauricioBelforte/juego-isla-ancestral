# Log 516: M87 Localización — Núcleo Iter. 1

## Resumen

Se implementó el núcleo del Módulo 87 (Localización): LocalizationManager autoload (catálogo de cadenas por idioma, idioma activo, fallback a ES, persistencia en M58) y catálogos strings_es.json/strings_en.json con 11 cadenas cada uno. Test headless 11/0 OK, regresión M60 66/0 OK.

## Archivos

- scripts/localizacion/localization_manager.gd (autoload)
- scripts/localizacion/test_localizacion_m87.gd
- data/localizacion/strings_es.json, strings_en.json

## Verificación

- Test M87: 11 checks, 0 fallos
- Regresión M60: 66/0 OK

## Pendientes (97 ítems)

Ampliar catálogo de cadenas, traducciones completas, integración con UI (M53) y configuración de idioma en M58.

