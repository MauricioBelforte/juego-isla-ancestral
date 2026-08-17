**Modelo:** SWE-1.6
**Plataforma:** Devin

# 02-Analisis.md — Módulo 88: Fuentes Tipográficas

## 1. Análisis de los puntos del plan maestro (sección 87)

| # | Punto | Resolución |
|---|---|---|
| 1 | Elegir fuente principal | ✅ Fuente principal: Nunito (Google Fonts) - sans-serif, legible, gratuita (SIL Open Font License 1.1) |
| 2 | Elegir fuente secundaria | ✅ Fuente secundaria: Fredoka One (Google Fonts) - rounded, amigable, gratuita (SIL Open Font License 1.1) |
| 3 | Revisar licencia | ✅ Ambas fuentes con SIL Open Font License 1.1 (uso comercial, modificación, distribución, sublicencia, con atribución) |
| 4 | Revisar caracteres | ✅ Soporte completo de caracteres alfabéticos (latín extendido) |
| 5 | Revisar tildes | ✅ Soporte de tildes (á, é, í, ó, ú, Á, É, Í, Ó, Ú) |
| 6 | Revisar ñ | ✅ Soporte de ñ y Ñ |
| 7 | Revisar símbolos | ✅ Soporte de símbolos comunes (¡, ¿, @, #, $, %, &, *, etc.) |
| 8 | Revisar cirílico si corresponde | ✅ Nunito soporta cirílico (para localización futura a ruso/ucraniano) |
| 9 | Revisar CJK si corresponde | ✅ No planeado para CJK en MVP (futuro: considerar Noto Sans CJK) |
| 10 | Revisar legibilidad | ✅ Fuentes legibles en tamaños pequeños (12px) y grandes (48px) |
| 11 | Definir tamaños | ✅ Tamaños: título (32px), subtítulo (24px), cuerpo (16px), pequeño (12px), micro (10px) |
| 12 | Definir pesos | ✅ Pesos: Light (300), Regular (400), Medium (500), Bold (700) |
| 13 | Definir tracking | ✅ Tracking: normal (0), tight (-1), loose (1) |
| 14 | Definir line height | ✅ Line height: 1.2 para cuerpo, 1.0 para títulos |
| 15 | Crear jerarquía visual | ✅ Jerarquía: H1 > H2 > H3 > cuerpo > pequeño > micro |
| 16 | Crear estilos de UI | ✅ Estilos de UI en Godot: Theme, StyleBox, Label, RichTextLabel |
| 17 | Optimizar archivos de fuente | ✅ Optimización: subsetting (latín extendido), compresión (WOFF2) |

## 2. Alternativas de fuentes

### Opción A: Nunito + Fredoka One
**Ventajas:**
- Nunito: sans-serif, legible, amigable, soporta cirílico
- Fredoka One: rounded, amigable, perfecta para estilo cozy
- Ambas gratuitas (SIL Open Font License 1.1)
- Disponibles en Google Fonts
- Buen soporte de caracteres especiales

**Desventajas:**
- Fredoka One solo tiene un peso (bold)
- Nunito no es monoespaciada (no ideal para código/tecnical text)

### Opción B: Open Sans + Nunito
**Ventajas:**
- Open Sans: sans-serif, muy legible, soporta cirílico
- Nunito: amigable, rounded
- Ambas gratuitas (SIL Open Font License 1.1)
- Disponibles en Google Fonts

**Desventajas:**
- Open Sans es más "corporate", menos cozy
- Fredoka One más alineado con estilo cozy

### Opción C: Quicksand + Baloo
**Ventajas:**
- Quicksand: sans-serif, rounded, amigable
- Baloo: rounded, amigable, perfecta para estilo cozy
- Ambas gratuitas (SIL Open Font License 1.1)
- Disponibles en Google Fonts

**Desventajas:**
- Baloo solo tiene un peso (bold)
- Quicksand menos legible en tamaños pequeños

**Decisión:** **Nunito + Fredoka One** (Opción A) - mejor balance de legibilidad, estilo cozy y soporte de caracteres.

## 3. Licencias de fuentes

**SIL Open Font License 1.1:**
- Uso comercial permitido
- Modificación permitida
- Distribución permitida
- Sublicencia permitida
- Atribución requerida (en créditos M131)
- No restriccion de uso

**Atribución en créditos (M131):**
- Nunito by Vernon Adams
- Fredoka One by Fontfolk

## 4. Caracteres especiales

**Tildes:**
- Vocales con tilde: á, é, í, ó, ú, Á, É, Í, Ó, Ú
- Diéresis: ä, ë, ï, ö, ü
- Acento grave: à, è, ì, ò, ù

**Ñ:**
- ñ (minúscula)
- Ñ (mayúscula)

**Símbolos:**
- Puntuación: ¡, ¿, ., ,, ;, :, !, ?, (, ), [, ], {, }
- Matemáticos: +, -, *, /, =, <, >, ≤, ≥
- Moneda: $, €, £, ¥
- Otros: @, #, %, &, *, |, ^, ~, `
- Flechas: →, ←, ↑, ↓

**Cirílico (futuro):**
- Alfabeto cirílico básico: А, Б, В, Г, Д, Е, Ё, Ж, З, И, Й, К, Л, М, Н, О, П, Р, С, Т, У, Ф, Х, Ц, Ч, Ш, Щ, Ъ, Ы, Ь, Э, Ю, Я
- Minúsculas: а, б, в, г, д, е, ё, ж, з, и, й, к, л, м, н, о, п, р, с, т, у, ф, х, ц, ч, ш, щ, ъ, ы, ь, э, ю, я

**CJK (futuro):**
- No planeado para MVP
- Futuro: considerar Noto Sans CJK (Google Fonts)

## 5. Legibilidad

**Factores de legibilidad:**
- Tamaño de fuente: mínimo 12px para cuerpo
- Contraste: texto oscuro sobre fondo claro (WCAG AA: 4.5:1)
- Line height: 1.2 para cuerpo, 1.0 para títulos
- Tracking: normal (0) para cuerpo, tight (-1) para títulos
- Peso: regular (400) para cuerpo, bold (700) para títulos
- Espaciado entre palabras: normal

**Pruebas de legibilidad:**
- Probar en resolución 720p (baja)
- Probar en resolución 1080p (media)
- Probar en resolución 4K (alta)
- Probar en diferentes dispositivos (PC, consola)

## 6. Tamaños de fuente

**Jerarquía visual:**
| Elemento | Tamaño | Peso | Uso |
|----------|--------|------|-----|
| H1 (Título principal) | 32px | Bold (700) | Títulos de pantalla, títulos de menú principal |
| H2 (Subtítulo) | 24px | Medium (500) | Subtítulos, títulos de sección |
| H3 (Título terciario) | 20px | Regular (400) | Títulos de diálogo, nombres de NPC |
| Cuerpo (Body) | 16px | Regular (400) | Texto de UI, descripciones, misiones |
| Pequeño (Small) | 12px | Regular (400) | Texto secundario, tooltips |
| Micro (Micro) | 10px | Light (300) | Texto técnico, metadata |

**Responsive:**
- 720p: reducir tamaños en 20%
- 1080p: tamaños base
- 4K: aumentar tamaños en 20%

## 7. Pesos de fuente

**Pesos disponibles:**
- Light (300): para texto técnico, metadata
- Regular (400): para cuerpo de texto
- Medium (500): para subtítulos, énfasis suave
- Bold (700): para títulos, énfasis fuerte

**Uso:**
- Light: tooltips, metadata, información secundaria
- Regular: cuerpo de texto, diálogos
- Medium: subtítulos, cabeceras de sección
- Bold: títulos, botones, acciones importantes

## 8. Tracking (espaciado entre letras)

**Tracking:**
- Normal (0): para cuerpo de texto
- Tight (-1): para títulos (más compacto)
- Loose (1): para texto técnico (más legible)

**Uso:**
- Normal: cuerpo de texto, diálogos
- Tight: títulos, cabeceras
- Loose: texto técnico, metadata

## 9. Line height (altura de línea)

**Line height:**
- 1.0: para títulos (compacto)
- 1.2: para cuerpo de texto (legible)
- 1.4: para párrafos largos (muy legible)

**Uso:**
- 1.0: títulos, cabeceras
- 1.2: cuerpo de texto, diálogos
- 1.4: párrafos largos, descripciones

## 10. Jerarquía visual

**Jerarquía:**
1. H1 (32px, Bold) → Título principal
2. H2 (24px, Medium) → Subtítulo
3. H3 (20px, Regular) → Título terciario
4. Cuerpo (16px, Regular) → Texto de UI
5. Pequeño (12px, Regular) → Texto secundario
6. Micro (10px, Light) → Texto técnico

**Aplicación:**
- Menú principal: H1 para título del juego
- Menús: H2 para títulos de menú, cuerpo para opciones
- Diálogos: H3 para nombre de NPC, cuerpo para texto de diálogo
- Misiones: H2 para título de misión, cuerpo para descripción
- HUD: Pequeño para información secundaria
- Debug: Micro para información técnica

## 11. Estilos de UI en Godot

**Theme:**
- Font (fuente principal): Nunito
- Font Size (tamaño base): 16px
- Font Color (color): blanco (#FFFFFF) sobre fondo oscuro
- Outline Color (color de contorno): negro (#000000) para contraste

**StyleBox:**
- Background: color de fondo (gris oscuro #2C2C2C)
- Border: borde de 2px, color blanco
- Corner Radius: 4px (rounded)

**Label:**
- Font: Nunito
- Font Size: según jerarquía
- Font Color: blanco
- Horizontal Alignment: left/center/right
- Vertical Alignment: top/center/bottom

**RichTextLabel:**
- Font: Nunito
- Font Size: según jerarquía
- Soporte de BBCode: [b], [i], [color], [url]
- Soporte de tildes, ñ, símbolos

**Button:**
- Font: Nunito
- Font Size: 16px
- Font Color: blanco
- Hover Color: amarillo (#FFFF00)
- Pressed Color: gris (#808080)

## 12. Optimización de archivos de fuente

**Subsetting:**
- Extraer solo caracteres necesarios (latín extendido, símbolos)
- Eliminar caracteres no usados (griego, árabe, hebreo si no se usan)
- Reducir tamaño de archivo de 500KB a 100KB

**Compresión:**
- Convertir a WOFF2 (formato comprimido)
- Reducir tamaño de archivo de 100KB a 50KB

**Caching:**
- Cachear fuentes en Godot (no cargar cada vez)
- Pre-cargar fuentes al inicio del juego

**Performance:**
- Usar fuentes vectoriales (TTF/OTF) en lugar de mapas de bits
- Subsetting para reducir tamaño de archivo
- Compresión para reducir tiempo de carga

## 13. Integración con M58 (Accesibilidad)

**Accesibilidad:**
- Tamaños ajustables en settings (M90)
- Contraste ajustable en settings (M90)
- Soporte para lectores de pantalla (futuro)
- Zoom de UI (futuro)

**Implementación:**
- Slider para tamaño de fuente (0.5x a 2x)
- Toggle para alto contraste (negro/blanco vs gris/blanco)
- Ajustes aplicados en tiempo real

## 14. Integración con M87 (Internacionalización)

**Localización:**
- Fuentes soportan latín extendido (español, portugués, francés, alemán, italiano)
- Fuentes soportan cirílico (ruso, ucraniano) - Nunito
- Fuentes no soportan CJK (chino, japonés, coreano) - futuro: Noto Sans CJK

**Implementación:**
- Cargar fuente según idioma (latín vs cirílico)
- Fallback a fuente alternativa si caracteres no soportados
- Sistema de fallback en Godot

## 15. Integración con M90 (Configuración Gráfica)

**Settings:**
- Tamaño de fuente (slider: 0.5x a 2x)
- Alto contraste (toggle)
- Fuente alternativa (si hay múltiples opciones)

**Implementación:**
- Ajustes guardados en settings (M90)
- Ajustes aplicados en tiempo real
- Ajustes accesibles desde menú de settings

## 16. Pruebas de calidad

**Pruebas manuales:**
- Probar legibilidad en diferentes resoluciones
- Probar legibilidad en diferentes dispositivos
- Probar soporte de caracteres especiales (tildes, ñ, símbolos)
- Probar rendimiento (tiempo de carga de fuentes)
- Probar localización (español, portugués, francés, alemán, italiano, ruso)

**Pruebas automáticas:**
- Tests de carga de fuentes
- Tests de renderizado de caracteres especiales
- Tests de performance (tiempo de carga)
