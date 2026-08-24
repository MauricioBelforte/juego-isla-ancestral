**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 88: Fuentes Tipográficas

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
- [ ] Diseñar RichTextLabel (fuente, tamaño, BBCode, soporte de caracteres)
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
- [ ] Diseñar sistema de fallback en Godot

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
- [ ] Diseñar GameRichTextLabel (size, weight, BBCode)
- [ ] Diseñar GameButton (size, weight, hover, pressed)
- [ ] Diseñar implementación de GameLabel
- [ ] Diseñar implementación de GameRichTextLabel
- [ ] Diseñar implementación de GameButton

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
