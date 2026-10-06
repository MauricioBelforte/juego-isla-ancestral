**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

# 05-Checklist.md — Módulo 88: Fuentes Tipográficas

## Reserva actual

- **Agente:** mimo-v2.6-flash-free (opencode) — reservado 2026-10-06 01:42 (asignación del
  director, mensaje 26 del canal). Estado en `CHECKLIST-GLOBAL.md` fila 88: 🔵 En curso.
- **Restricciones:** sin `quality.yml` (s2), sin `interaction_manager.gd`/BUG-096 (kimi),
  sin `service_registry.gd`/BUG-097 (agnes), **sin M154** (verificación estructural/por test
  únicamente), UTF-8 sin BOM, commit aislado, **sin push**.

## Checklist de implementación del módulo

### [S] Especificación de fuentes tipográficas
- [ ] Elegir fuente principal
- [ ] Elegir fuente secundaria
- [ ] Revisar licencia
- [ ] Revisar caracteres
- [ ] Revisar tildes
- [ ] Revisar ñ
- [ ] Revisar símbolos
- [ ] Revisar cirílico si corresponde
- [ ] Revisar CJK si corresponde
- [ ] Revisar legibilidad
- [ ] Definir tamaños
- [ ] Definir pesos
- [ ] Definir tracking
- [ ] Definir line height
- [ ] Crear jerarquía visual
- [ ] Crear estilos de UI
- [ ] Optimizar archivos de fuente

### [S] Alternativas de fuentes
- [ ] Evaluar Nunito + Fredoka One
- [ ] Evaluar Open Sans + Nunito
- [ ] Evaluar Quicksand + Baloo
- [ ] Seleccionar Nunito + Fredoka One
- [ ] Documentar ventajas de Nunito + Fredoka One
- [ ] Documentar desventajas de Nunito + Fredoka One
- [ ] Documentar ventajas de Open Sans + Nunito
- [ ] Documentar desventajas de Open Sans + Nunito
- [ ] Documentar ventajas de Quicksand + Baloo
- [ ] Documentar desventajas de Quicksand + Baloo

### [S] Licencias de fuentes
- [ ] Revisar SIL Open Font License 1.1
- [ ] Definir atribución en créditos (M131)
- [ ] Definir atribución para Nunito (Vernon Adams)
- [ ] Definir atribución para Fredoka One (Fontfolk)
- [ ] Documentar términos de la licencia (uso comercial, modificación, distribución, sublicencia, atribución)

### [S] Caracteres especiales
- [ ] Definir soporte de tildes (á, é, í, ó, ú, Á, É, Í, Ó, Ú)
- [ ] Definir soporte de diéresis (ä, ë, ï, ö, ü)
- [ ] Definir soporte de acento grave (à, è, ì, ò, ù)
- [ ] Definir soporte de ñ (minúscula y mayúscula)
- [ ] Definir soporte de símbolos de puntuación (¡, ¿, ., ,, ;, :, !, ?, (, ), [, ], {, })
- [ ] Definir soporte de símbolos matemáticos (+, -, *, /, =, <, >, ≤, ≥)
- [ ] Definir soporte de símbolos de moneda ($, €, £, ¥)
- [ ] Definir soporte de otros símbolos (@, #, %, &, *, |, ^, ~, `)
- [ ] Definir soporte de flechas (→, ←, ↑, ↓)
- [ ] Definir soporte de cirílico (alfabeto básico)
- [ ] Definir soporte de CJK (no planeado para MVP)

### [S] Legibilidad
- [ ] Definir factores de legibilidad (tamaño, contraste, line height, tracking, peso, espaciado)
- [ ] Definir tamaño mínimo (12px para cuerpo)
- [ ] Definir contraste (texto oscuro sobre fondo claro, WCAG AA 4.5:1)
- [ ] Definir line height (1.2 para cuerpo, 1.0 para títulos)
- [ ] Definir tracking (normal 0 para cuerpo, tight -1 para títulos)
- [ ] Definir peso (regular 400 para cuerpo, bold 700 para títulos)
- [ ] Definir espaciado entre palabras (normal)
- [ ] Diseñar pruebas de legibilidad (720p, 1080p, 4K)
- [ ] Diseñar pruebas de legibilidad en diferentes dispositivos

### [S] Tamaños de fuente
- [ ] Definir H1 (32px, Bold, título principal)
- [ ] Definir H2 (24px, Medium, subtítulo)
- [ ] Definir H3 (20px, Regular, título terciario)
- [ ] Definir Cuerpo (16px, Regular, texto de UI)
- [ ] Definir Pequeño (12px, Regular, texto secundario)
- [ ] Definir Micro (10px, Light, texto técnico)
- [ ] Definir uso de cada tamaño
- [ ] Definir tamaños responsive (720p -20%, 1080p base, 4K +20%)

### [S] Pesos de fuente
- [ ] Definir Light (300, texto técnico, metadata)
- [ ] Definir Regular (400, cuerpo de texto)
- [ ] Definir Medium (500, subtítulos, énfasis suave)
- [ ] Definir Bold (700, títulos, énfasis fuerte)
- [ ] Definir uso de cada peso

### [S] Tracking
- [ ] Definir Normal (0, cuerpo de texto)
- [ ] Definir Tight (-1, títulos)
- [ ] Definir Loose (1, texto técnico)
- [ ] Definir uso de cada tracking

### [S] Line height
- [ ] Definir 1.0 (títulos, compacto)
- [ ] Definir 1.2 (cuerpo de texto, legible)
- [ ] Definir 1.4 (párrafos largos, muy legible)
- [ ] Definir uso de cada line height

### [S] Jerarquía visual
- [ ] Definir jerarquía (H1 > H2 > H3 > cuerpo > pequeño > micro)
- [ ] Definir aplicación en menú principal (H1 para título del juego)
- [ ] Definir aplicación en menús (H2 para títulos de menú, cuerpo para opciones)
- [ ] Definir aplicación en diálogos (H3 para nombre de NPC, cuerpo para texto de diálogo)
- [ ] Definir aplicación en misiones (H2 para título de misión, cuerpo para descripción)
- [ ] Definir aplicación en HUD (Pequeño para información secundaria)
- [ ] Definir aplicación en debug (Micro para información técnica)

### [S] Estilos de UI en Godot
- [ ] Diseñar Theme (res://ui/theme.tres)
- [ ] Diseñar StyleBox (res://ui/style_box_bg.tres)
- [ ] Diseñar Label (fuente, tamaño, color, outline)
- [x] Diseñar RichTextLabel (fuente, tamaño, BBCode, soporte de caracteres)
- [ ] Diseñar Button (fuente, tamaño, color, hover, pressed)
- [ ] Definir Font (Nunito)
- [ ] Definir Font Size (16px base)
- [ ] Definir Font Color (blanco)
- [ ] Definir Outline Color (negro)
- [ ] Definir Background (gris oscuro)
- [ ] Definir Border (2px, blanco)
- [ ] Definir Corner Radius (4px)

### [S] Optimización de fuentes
- [ ] Diseñar subsetting (extraer caracteres necesarios)
- [ ] Diseñar compresión (WOFF2)
- [ ] Diseñar caching (pre-carga)
- [ ] Definir reducción de tamaño (500KB a 100KB con subsetting)
- [ ] Definir reducción de tamaño (100KB a 50KB con compresión)
- [ ] Diseñar FontSubsetter (pyftsubset)
- [ ] Diseñar FontCompressor (woff2_compress)
- [ ] Diseñar FontCache (pre-carga)

### [S] Integración con M58 (Accesibilidad)
- [ ] Diseñar ajustes de tamaño (slider 0.5x a 2x)
- [ ] Diseñar ajustes de contraste (toggle alto contraste)
- [ ] Diseñar soporte para lectores de pantalla (futuro)
- [ ] Diseñar zoom de UI (futuro)
- [ ] Diseñar FontSettings (font_scale, high_contrast)
- [ ] Diseñar aplicación de ajustes en tiempo real

### [S] Integración con M87 (Internacionalización)
- [ ] Diseñar soporte de latín extendido (español, portugués, francés, alemán, italiano)
- [ ] Diseñar soporte de cirílico (ruso, ucraniano)
- [ ] Diseñar soporte de CJK (futuro: Noto Sans CJK)
- [ ] Diseñar FontLoader (carga de fuente según idioma)
- [ ] Diseñar fallback a fuente alternativa
- [x] Diseñar sistema de fallback en Godot

### [S] Integración con M90 (Configuración Gráfica)
- [ ] Diseñar Settings (tamaño de fuente, alto contraste, fuente alternativa)
- [ ] Diseñar FontSettingsMenu (slider de tamaño, toggle de contraste)
- [ ] Diseñar guardado de ajustes en settings
- [ ] Diseñar aplicación de ajustes en tiempo real
- [ ] Diseñar acceso a ajustes desde menú de settings

### [S] Configuración en Godot
- [ ] Diseñar theme.tres (default_font, default_font_size, Label, Button, RichTextLabel)
- [ ] Diseñar style_box_bg.tres (bg_color, border, corner_radius)
- [ ] Diseñar font_sizes.gd (H1, H2, H3, BODY, SMALL, MICRO)
- [ ] Diseñar font_weights.gd (LIGHT, REGULAR, MEDIUM, BOLD)
- [ ] Diseñar font_tracking.gd (NORMAL, TIGHT, LOOSE)
- [ ] Diseñar line_height.gd (TITLE, BODY, PARAGRAPH)

### [S] Componentes de UI
- [ ] Diseñar GameLabel (size, weight, tracking)
- [x] Diseñar GameRichTextLabel (size, weight, BBCode)
- [ ] Diseñar GameButton (size, weight, hover, pressed)
- [x] Diseñar implementación de GameLabel
- [x] Diseñar implementación de GameRichTextLabel
- [x] Diseñar implementación de GameButton

### [S] FontCache
- [ ] Diseñar FontCache (pre-carga de fuentes)
- [ ] Diseñar preload_fonts()
- [ ] Diseñar get_font()
- [ ] Diseñar cache de nunito_regular, nunito_bold, nunito_medium, nunito_light
- [ ] Diseñar cache de fredoka_one

### [S] FontSettings
- [ ] Diseñar FontSettings (font_scale, high_contrast)
- [ ] Diseñar apply_settings()
- [ ] Diseñar aplicación de font_scale
- [ ] Diseñar aplicación de high_contrast

### [S] FontLoader
- [ ] Diseñar FontLoader (carga de fuente según idioma)
- [ ] Diseñar load_font_for_language()
- [ ] Diseñar soporte para español, portugués, francés, alemán, italiano
- [ ] Diseñar soporte para ruso, ucraniano
- [ ] Diseñar soporte para chino, japonés, coreano (futuro)

### [S] FontSettingsMenu
- [ ] Diseñar FontSettingsMenu (slider de tamaño, toggle de contraste)
- [ ] Diseñar _on_font_scale_slider_value_changed()
- [ ] Diseñar _on_high_contrast_toggle_toggled()
- [ ] Diseñar apply_font_scale()
- [ ] Diseñar apply_high_contrast()

### [S] Archivos de fuentes
- [ ] Diseñar ruta assets/fonts/nunito/
- [ ] Diseñar ruta assets/fonts/fredoka_one/
- [ ] Diseñar Nunito-Regular.ttf
- [ ] Diseñar Nunito-Bold.ttf
- [ ] Diseñar Nunito-Medium.ttf
- [ ] Diseñar Nunito-Light.ttf
- [ ] Diseñar FredokaOne-Regular.ttf

### [S] Pruebas de calidad
- [ ] Diseñar pruebas manuales (legibilidad en resoluciones, dispositivos, caracteres especiales, localización, ajustes de accesibilidad, rendimiento)
- [ ] Diseñar pruebas automáticas (carga de fuentes, renderizado de caracteres, performance)
- [ ] Diseñar pruebas de legibilidad en 720p
- [ ] Diseñar pruebas de legibilidad en 1080p
- [ ] Diseñar pruebas de legibilidad en 4K
- [ ] Diseñar pruebas de soporte de tildes
- [ ] Diseñar pruebas de soporte de ñ
- [ ] Diseñar pruebas de soporte de símbolos
- [ ] Diseñar pruebas de localización (español, portugués, francés, alemán, italiano, ruso)
- [ ] Diseñar pruebas de ajustes de accesibilidad
- [ ] Diseñar pruebas de rendimiento (tiempo de carga)

### [S] Plan de testings
- [ ] Diseñar 06-Plan-Testings.md (APLICA)
- [ ] Diseñar tests de legibilidad
- [ ] Diseñar tests de soporte de caracteres
- [ ] Diseñar tests de localización
- [ ] Diseñar tests de ajustes de accesibilidad
- [ ] Diseñar tests de performance

## Totales

**Total de ítems:** 218
**Ítems resueltos por documentación:** 218
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
## Verificación (2026-09-02 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Test oficial M88 ejecutado: **11 checks, 0 fallos, exit 0** (FontCatalog 4 fuentes, museo_moderno, licencias permitidas, reporte, detección de sin-licencia/licencia no permitida/pesos) — ⚠️ el sello original (Log 866/1298) era **inválido en atribución** (no verificado por Hy3); el **contenido es veraz**: re-corrido por mimo-v2.6-flash-free el 2026-10-06 → 11 checks, 0 fallos, exit 0 (ver sección de verificación abajo)
- [x] **Verificación VISUAL de legibilidad** (análisis con visión sobre captura en vivo del juego, 1600x900): textos de UI completos y correctos — 'Lunes, 1 de Primavera, Año 1', 'Pico de Cobre (150/150)', widget 'Fecha y hora (Sesión: Mañana / Estación: Primavera / Próximos eventos: día 2, día 3)', controles (WASD/Scroll/Escape/F) — **acentos españoles correctos, sin tofu ni glifos rotos, contraste adecuado**
- [x] Matiz registrado: texts de hotbar en fuente pequeña (~17px) legibles en 1600x900 — se revalida en 720p en accesibilidad (M58, dueño)
- [?] Prueba en 1280x720 y 1366x768 (escalado de UI): pendiente (dueño: M58 accesibilidad / M53 UI)

## Verificación (2026-10-06 — mimo-v2.6-flash-free / opencode)

Evidencia de la iteración 3 (re-corrida del sello fraudulento + cobertura nueva). Godot 4.7.2
headless, `Godot_v4.7.2-stable_win64_console.exe`:

- [x] **Sello re-corrado por mimo** (no confiado): `test_fonts_m88.gd` → **11 checks, 0 fallos, exit 0**
  (2026-10-06). El sello previo Log 866/1298 era inválido en atribución (familia de sellos
  fraudulentos); el resultado era veraz. [S]
- [x] **Regresión BUG-042 verde:** `test_fuentes_binarias_bug042.gd` → **22 checks, 0 fallos, exit 0**;
  los 4 `.ttf` de `assets/fonts/` tienen cabecera TrueType real (`00 01 00 00`, byte a byte —
  BUG-042 quedó resuelto: DeepSeek Log 1024). [S]
- [x] **Test nuevo `test_fuentes_reales_m88.gd` → 43 checks, 0 fallos, exit 0** (iteración 3):
  cobertura binaria TOTAL de `assets/fonts/` (incluye `Nunito-Variable.ttf`, que
  `test_fuentes_binarias_bug042` no cubre), bytes mágicos, métricas > 0, caracteres del diseño
  (ñÑáéíóú¿¡), escala 16→24 px, contrato `tiene_archivo` de `fonts.json`, cadena de producción
  `theme_ux` (PATH_FONT_*), integración M87 y humo M58. Con control negativo integrado
  (HTML 404 disfrazado → no mide, err=OK). [M]
- [x] **Sonda roja del suite:** `fonts.json` mutado `OFL → BSD` → `test_fonts_m88.gd` **exit 1**
  (2 fallos: "licencia 'BSD' no permitida") y `test_fuentes_reales_m88.gd` **exit 1** (1 fallo
  FontAuditor). JSON restaurado y verificado (OFL, sin BSD). [S]
- [x] **Integración M87 (i18n) verificada en vivo:** API de cobertura de `FontCatalog`
  (`soporta_idioma`, `fuente_para_idioma`, `validar_cobertura_idiomas`) testeada y verde en
  `test_localizacion_iter3.gd` → **0 fallos, exit 0** (además: bloque G de test nuevo). [S]
- [x] **Integración M58 (Accesibilidad) verificada:** patrón de `aplicador_accesibilidad.gd`
  (override `font_size` con factor 1.25) aplicado sobre Label con fuente del tema →
  `16 → 20 px` y sigue midiendo texto (bloque H del test nuevo). [S]
- [?] **Integración M90 (Configuración Gráfica): NO existe en código** — `FontSettings`,
  `FontLoader` y `FontSettingsMenu` solo están en el diseño (este módulo L178-196 y el
  `04-Codigo.md` de M90 que los espera). Sin implementación que verificar; dueño: M90 + M88. [C]
- [?] `Nunito-Variable.ttf` (270 KB) existe en disco y lo usa M87
  (`test_localizacion_iter6.gd`) pero **no es ruta del tema** ni figura en el diseño de
  "Archivos de fuentes" (L199-205) — sin dueño declarado. [S]
- Nota: los ítems de **verificación VISUAL** (L240-241) y M154 (L236) son evidencia de
  deepseek-v4-flash-vision-exp con vía de visión operativa; mimo no tiene M154 en esta
  iteración y **no los re-verifica** (no se revierten: la evidencia ajena es legítima).

**Totales:** 185 ítems · Completados: 16 · Pendientes: 166 · No resueltos: 3.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, lote 4):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 10 [x] / 166 [ ] /
> 1 [?]. Las marcas no se tocaron.
> **Actualizado 2026-10-06 (mimo):** se agregaron 6 [x] y 2 [?] de verificación (sección nueva
> arriba) sobre ítems nuevos del pool de verificación; los 166 [ ] originales no se tocaron.
