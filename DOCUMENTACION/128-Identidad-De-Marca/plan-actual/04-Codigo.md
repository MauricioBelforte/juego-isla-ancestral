# Módulo 128: Identidad de Marca — Código

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:29:00

## Archivos a Crear

### 1. `scripts/brand/brand_config.gd` — Configuración de marca

Resource con configuración de identidad de marca del juego. Contiene colores oficiales (primario, secundario, acento, neutros), tipografía (heading, body, mono), logos (principal, mono, icono), nombre del juego y del mundo.

Campos:
- game_name: String = "Isla Ancestral"
- world_name: String = "Aurora"
- color_primary: Color = #2E5A4C (Azul Bosque)
- color_secondary: Color = #D4A843 (Dorado Anciano)
- color_accent: Color = #F5F0E8 (Blanco Perla)
- color_text: Color = #2C2C2C (Carbón)
- color_nature: Color = #5A8A6C (Verde Hoja)
- color_earth: Color = #C47A5A (Terracota)
- color_sky: Color = #8AB4D4 (Cielo Claro)

Funciones:
- get_primary_color(), get_secondary_color()
- has_sufficient_contrast(fg, bg) — WCAG AA (4.5:1)
- _relative_luminance(color) para cálculo de contraste

### 2. `scripts/brand/brand_validator.gd` — Validador de coherencia

Valida que los elementos del juego cumplan guidelines de marca:
- validate_color_usage(element, color) — verifica si color está en paleta
- validate_contrast(fg, bg, element) — verifica contraste WCAG AA
- validate_logo_usage(path, context) — verifica existencia y tamaño mínimo

### 3. `scripts/brand/brand_validation_result.gd` — Resultado

Resource con arrays de errors, warnings, infos y función to_string().

### 4. `scripts/brand/brand_ui_theme.gd` — Tema UI

Aplica colores y tipografía de marca a Theme de Godot:
- apply_to_theme(theme) — configura colores de Label, Button, font heading/body
- apply_to_scene(root) — recorre nodos y aplica brand

## Archivos a Modificar

### 5. `project.godot` — Agregar autoload

```
[autoload]
BrandConfig="*res://scripts/brand/brand_config.gd"
```

## Recursos de Datos

### `resources/brand/brand_config.tres` — Config por defecto

Creado con colores predefinidos de la paleta del juego.

### `brand/` — Directorio de assets de marca

```
brand/
├── logo-principal.png      ← Logo color
├── logo-mono.png           ← Logo B/N
├── logo-icono.png          ← App icon 512x512
├── logo-horizontal.png     ← Para headers
├── manual-de-marca.pdf     ← Documento completo
└── paleta.ase              ← Paleta de colores
```

## Integración con Sistemas Existentes

| Sistema | Cómo se conecta |
|---------|-----------------|
| Arte 2D (M46) | Usa paleta y tipografía de BrandConfig |
| UI/UX (M53) | Aplica tema de marca via BrandUITheme |
| Legal PI (M78) | Registra trademarks definidos en BrandConfig |
| Marketing (M151) | Usa assets de brand/ |
| Comunidad (M152) | Usa guidelines para redes sociales |
