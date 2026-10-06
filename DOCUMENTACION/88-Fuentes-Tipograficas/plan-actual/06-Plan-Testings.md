# 06-Plan-Testings.md — Módulo 88: Fuentes Tipográficas

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-06 (iteración de cierre, mensaje 35 del director)

> Plan de testings derivado del diseño `03-Diseno.md` §14 y del análisis `02-Analisis.md` §16.
> Suites ejecutables existentes: `scripts/fonts/`.

## 1. Suites ejecutables (Godot 4.7.2 headless)

| Suite | Cubre | Estado |
|---|---|---|
| `scripts/fonts/test_fonts_m88.gd` | FontCatalog (4 fuentes), museo_moderno, licencias permitidas, reporte, detección de sin-licencia/licencia no permitida/pesos | 11 checks, 0 fallos, exit 0 (re-corrido por mimo 2026-10-06) |
| `scripts/fonts/test_fuentes_binarias_bug042.gd` | Cabecera TrueType real de los 4 `.ttf` (bytes mágicos `00 01 00 00`) — regresión BUG-042 | 22 checks, 0 fallos, exit 0 |
| `scripts/fonts/test_fuentes_reales_m88.gd` | Cobertura binaria total de `assets/fonts/` (incluye Nunito-Variable), métricas > 0, caracteres ñÑáéíóú¿¡, escala 16→24 px, contrato `tiene_archivo` de `fonts.json`, cadena `theme_ux` (PATH_FONT_*), integración M87, humo M58, control negativo (HTML 404) | 43 checks, 0 fallos, exit 0 |
| `scripts/i18n/test_localizacion_iter3.gd` (+ iter6) | Integración M87: `soporta_idioma`, `fuente_para_idioma`, `validar_cobertura_idiomas`, `Nunito-Variable` | 0 fallos, exit 0 |

**Sonda roja (obligatoria en cada corrida de release):** mutar `data/fonts/fonts.json`
(`OFL` → `BSD`) debe dejar ambas suites en **exit 1**; restaurar y verificar `OFL`.

## 2. Escenarios manuales (requieren visión M154 — pendientes)

- [ ] Legibilidad en 1280x720 / 1366x768 / 1600x900 / 4K (dueño: M154 visión + M58).
- [ ] Soporte de caracteres en localización completa (es, pt, fr, de, it, ru) en pantalla.
- [ ] Ajustes de accesibilidad en vivo (font_scale 0.5x–2x, alto contraste) sobre UI real.
- [ ] Rendimiento de carga de fuentes (tiempo de precarga en arranque).

> Estos escenarios NO se ejecutan sin vía de visión operativa (sección 25 AGENTS.md).

## 3. Criterios de éxito

1. Todas las suites en exit 0; sonda roja en exit 1.
2. Ninguna licencia fuera de `licencias_permitidas` (OFL, MIT, CC-BY, CC0).
3. Caracteres del diseño (tildes, ñ, ¿¡) renderizan sin tofu.
4. Escalado de tema (`theme_ux.apply(scale_ratio)`) conserva proporciones.

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
