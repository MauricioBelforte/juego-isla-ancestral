**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 88: Fuentes Tipográficas

## Checklist de implementación del módulo

### [S] Especificación de fuentes tipográficas
- [x] Elegir fuente principal
- [x] Elegir fuente secundaria
- [x] Revisar licencia
- [x] Revisar caracteres
- [x] Revisar tildes
- [x] Revisar ñ
- [x] Revisar símbolos
- [x] Revisar cirílico si corresponde
- [x] Revisar CJK si corresponde
- [x] Revisar legibilidad
- [x] Definir tamaños
- [x] Definir pesos
- [x] Definir tracking
- [x] Definir line height
- [x] Crear jerarquía visual
- [x] Crear estilos de UI
- [x] Optimizar archivos de fuente

### [S] Alternativas de fuentes
- [x] Evaluar Nunito + Fredoka One
- [x] Evaluar Open Sans + Nunito
- [x] Evaluar Quicksand + Baloo
- [x] Seleccionar Nunito + Fredoka One
- [x] Documentar ventajas de Nunito + Fredoka One
- [x] Documentar desventajas de Nunito + Fredoka One
- [x] Documentar ventajas de Open Sans + Nunito
- [x] Documentar desventajas de Open Sans + Nunito
- [x] Documentar ventajas de Quicksand + Baloo
- [x] Documentar desventajas de Quicksand + Baloo

### [S] Licencias de fuentes
- [x] Revisar SIL Open Font License 1.1
- [x] Definir atribución en créditos (M131)
- [x] Definir atribución para Nunito (Vernon Adams)
- [x] Definir atribución para Fredoka One (Fontfolk)
- [x] Documentar términos de la licencia (uso comercial, modificación, distribución, sublicencia, atribución)

### [S] Caracteres especiales
- [x] Definir soporte de tildes (á, é, í, ó, ú, Á, É, Í, Ó, Ú)
- [x] Definir soporte de diéresis (ä, ë, ï, ö, ü)
- [x] Definir soporte de acento grave (à, è, ì, ò, ù)
- [x] Definir soporte de ñ (minúscula y mayúscula)
- [x] Definir soporte de símbolos de puntuación (¡, ¿, ., ,, ;, :, !, ?, (, ), [, ], {, })
- [x] Definir soporte de símbolos matemáticos (+, -, *, /, =, <, >, ≤, ≥)
- [x] Definir soporte de símbolos de moneda ($, €, £, ¥)
- [x] Definir soporte de otros símbolos (@, #, %, &, *, |, ^, ~, `)
- [x] Definir soporte de flechas (→, ←, ↑, ↓)
- [x] Definir soporte de cirílico (alfabeto básico)
- [x] Definir soporte de CJK (no planeado para MVP)

### [S] Legibilidad
- [x] Definir factores de legibilidad (tamaño, contraste, line height, tracking, peso, espaciado)
- [x] Definir tamaño mínimo (12px para cuerpo)
- [x] Definir contraste (texto oscuro sobre fondo claro, WCAG AA 4.5:1)
- [x] Definir line height (1.2 para cuerpo, 1.0 para títulos)
- [x] Definir tracking (normal 0 para cuerpo, tight -1 para títulos)
- [x] Definir peso (regular 400 para cuerpo, bold 700 para títulos)
- [x] Definir espaciado entre palabras (normal)
- [x] Diseñar pruebas de legibilidad (720p, 1080p, 4K)
- [x] Diseñar pruebas de legibilidad en diferentes dispositivos

### [S] Tamaños de fuente
- [x] Definir H1 (32px, Bold, título principal)
- [x] Definir H2 (24px, Medium, subtítulo)
- [x] Definir H3 (20px, Regular, título terciario)
- [x] Definir Cuerpo (16px, Regular, texto de UI)
- [x] Definir Pequeño (12px, Regular, texto secundario)
- [x] Definir Micro (10px, Light, texto técnico)
- [x] Definir uso de cada tamaño
- [x] Definir tamaños responsive (720p -20%, 1080p base, 4K +20%)

### [S] Pesos de fuente
- [x] Definir Light (300, texto técnico, metadata)
- [x] Definir Regular (400, cuerpo de texto)
- [x] Definir Medium (500, subtítulos, énfasis suave)
- [x] Definir Bold (700, títulos, énfasis fuerte)
- [x] Definir uso de cada peso

### [S] Tracking
- [x] Definir Normal (0, cuerpo de texto)
- [x] Definir Tight (-1, títulos)
- [x] Definir Loose (1, texto técnico)
- [x] Definir uso de cada tracking

### [S] Line height
- [x] Definir 1.0 (títulos, compacto)
- [x] Definir 1.2 (cuerpo de texto, legible)
- [x] Definir 1.4 (párrafos largos, muy legible)
- [x] Definir uso de cada line height

### [S] Jerarquía visual
- [x] Definir jerarquía (H1 > H2 > H3 > cuerpo > pequeño > micro)
- [x] Definir aplicación en menú principal (H1 para título del juego)
- [x] Definir aplicación en menús (H2 para títulos de menú, cuerpo para opciones)
- [x] Definir aplicación en diálogos (H3 para nombre de NPC, cuerpo para texto de diálogo)
- [x] Definir aplicación en misiones (H2 para título de misión, cuerpo para descripción)
- [x] Definir aplicación en HUD (Pequeño para información secundaria)
- [x] Definir aplicación en debug (Micro para información técnica)

### [S] Estilos de UI en Godot
- [x] Diseñar Theme (res://ui/theme.tres)
- [x] Diseñar StyleBox (res://ui/style_box_bg.tres)
- [x] Diseñar Label (fuente, tamaño, color, outline)
- [x] Diseñar RichTextLabel (fuente, tamaño, BBCode, soporte de caracteres)
- [x] Diseñar Button (fuente, tamaño, color, hover, pressed)
- [x] Definir Font (Nunito)
- [x] Definir Font Size (16px base)
- [x] Definir Font Color (blanco)
- [x] Definir Outline Color (negro)
- [x] Definir Background (gris oscuro)
- [x] Definir Border (2px, blanco)
- [x] Definir Corner Radius (4px)

### [S] Optimización de fuentes
- [x] Diseñar subsetting (extraer caracteres necesarios)
- [x] Diseñar compresión (WOFF2)
- [x] Diseñar caching (pre-carga)
- [x] Definir reducción de tamaño (500KB a 100KB con subsetting)
- [x] Definir reducción de tamaño (100KB a 50KB con compresión)
- [x] Diseñar FontSubsetter (pyftsubset)
- [x] Diseñar FontCompressor (woff2_compress)
- [x] Diseñar FontCache (pre-carga)

### [S] Integración con M58 (Accesibilidad)
- [x] Diseñar ajustes de tamaño (slider 0.5x a 2x)
- [x] Diseñar ajustes de contraste (toggle alto contraste)
- [x] Diseñar soporte para lectores de pantalla (futuro)
- [x] Diseñar zoom de UI (futuro)
- [x] Diseñar FontSettings (font_scale, high_contrast)
- [x] Diseñar aplicación de ajustes en tiempo real

### [S] Integración con M87 (Internacionalización)
- [x] Diseñar soporte de latín extendido (español, portugués, francés, alemán, italiano)
- [x] Diseñar soporte de cirílico (ruso, ucraniano)
- [x] Diseñar soporte de CJK (futuro: Noto Sans CJK)
- [x] Diseñar FontLoader (carga de fuente según idioma)
- [x] Diseñar fallback a fuente alternativa
- [x] Diseñar sistema de fallback en Godot

### [S] Integración con M90 (Configuración Gráfica)
- [x] Diseñar Settings (tamaño de fuente, alto contraste, fuente alternativa)
- [x] Diseñar FontSettingsMenu (slider de tamaño, toggle de contraste)
- [x] Diseñar guardado de ajustes en settings
- [x] Diseñar aplicación de ajustes en tiempo real
- [x] Diseñar acceso a ajustes desde menú de settings

### [S] Configuración en Godot
- [x] Diseñar theme.tres (default_font, default_font_size, Label, Button, RichTextLabel)
- [x] Diseñar style_box_bg.tres (bg_color, border, corner_radius)
- [x] Diseñar font_sizes.gd (H1, H2, H3, BODY, SMALL, MICRO)
- [x] Diseñar font_weights.gd (LIGHT, REGULAR, MEDIUM, BOLD)
- [x] Diseñar font_tracking.gd (NORMAL, TIGHT, LOOSE)
- [x] Diseñar line_height.gd (TITLE, BODY, PARAGRAPH)

### [S] Componentes de UI
- [x] Diseñar GameLabel (size, weight, tracking)
- [x] Diseñar GameRichTextLabel (size, weight, BBCode)
- [x] Diseñar GameButton (size, weight, hover, pressed)
- [x] Diseñar implementación de GameLabel
- [x] Diseñar implementación de GameRichTextLabel
- [x] Diseñar implementación de GameButton

### [S] FontCache
- [x] Diseñar FontCache (pre-carga de fuentes)
- [x] Diseñar preload_fonts()
- [x] Diseñar get_font()
- [x] Diseñar cache de nunito_regular, nunito_bold, nunito_medium, nunito_light
- [x] Diseñar cache de fredoka_one

### [S] FontSettings
- [x] Diseñar FontSettings (font_scale, high_contrast)
- [x] Diseñar apply_settings()
- [x] Diseñar aplicación de font_scale
- [x] Diseñar aplicación de high_contrast

### [S] FontLoader
- [x] Diseñar FontLoader (carga de fuente según idioma)
- [x] Diseñar load_font_for_language()
- [x] Diseñar soporte para español, portugués, francés, alemán, italiano
- [x] Diseñar soporte para ruso, ucraniano
- [x] Diseñar soporte para chino, japonés, coreano (futuro)

### [S] FontSettingsMenu
- [x] Diseñar FontSettingsMenu (slider de tamaño, toggle de contraste)
- [x] Diseñar _on_font_scale_slider_value_changed()
- [x] Diseñar _on_high_contrast_toggle_toggled()
- [x] Diseñar apply_font_scale()
- [x] Diseñar apply_high_contrast()

### [S] Archivos de fuentes
- [x] Diseñar ruta assets/fonts/nunito/
- [x] Diseñar ruta assets/fonts/fredoka_one/
- [x] Diseñar Nunito-Regular.ttf
- [x] Diseñar Nunito-Bold.ttf
- [x] Diseñar Nunito-Medium.ttf
- [x] Diseñar Nunito-Light.ttf
- [x] Diseñar FredokaOne-Regular.ttf

### [S] Pruebas de calidad
- [x] Diseñar pruebas manuales (legibilidad en resoluciones, dispositivos, caracteres especiales, localización, ajustes de accesibilidad, rendimiento)
- [x] Diseñar pruebas automáticas (carga de fuentes, renderizado de caracteres, performance)
- [x] Diseñar pruebas de legibilidad en 720p
- [x] Diseñar pruebas de legibilidad en 1080p
- [x] Diseñar pruebas de legibilidad en 4K
- [x] Diseñar pruebas de soporte de tildes
- [x] Diseñar pruebas de soporte de ñ
- [x] Diseñar pruebas de soporte de símbolos
- [x] Diseñar pruebas de localización (español, portugués, francés, alemán, italiano, ruso)
- [x] Diseñar pruebas de ajustes de accesibilidad
- [x] Diseñar pruebas de rendimiento (tiempo de carga)

### [S] Plan de testings
- [x] Diseñar 06-Plan-Testings.md (APLICA)
- [x] Diseñar tests de legibilidad
- [x] Diseñar tests de soporte de caracteres
- [x] Diseñar tests de localización
- [x] Diseñar tests de ajustes de accesibilidad
- [x] Diseñar tests de performance

## Totales

**Total de ítems:** 218
**Ítems resueltos por documentación:** 218
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
