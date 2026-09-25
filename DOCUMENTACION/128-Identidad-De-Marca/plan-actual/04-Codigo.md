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

## Iteración agnes — data-layer + gate CI (2026-09-18, agnes-3-flash (Sapiens AI) / Kilo Code, Log 1013)

> Iteración acotada (data-driven + tooling/CI + V0). Verifiqué el scaffold de validación y lo cableé al
> gate CI. NO genero branding ni hago legal (dueño M128/M46).

### Estado real del código (verificado headless, godot 4.7.2)
- `data/legal/identidad_marca.json` — catálogo data-driven (3 elementos: nombre/logo/paleta-base).
- `scripts/legal/brand_validator.gd` (`class_name BrandValidator`) — `validar()`/`reporte()`: detecta
  sin id / sin nombre / sin uso / sin políticas.
- `scripts/legal/test_brand_m128.gd` — **8 checks, 0 fallos, exit 0, 0 `SCRIPT ERROR`**.
- **Gap cerrado:** el test **no estaba** cableado en `quality.yml` → añadido al **gate duro**
  (test-suite), junto a los tests M83/M126.

### Lo que sigue NO implementado (dueño M128 / humano / M46)
- Branding real (logo/paleta/tipografía en `assets/brand/`) → M45/M46.
- Registro de trademark, dominio, redes y legal → acción externa/abogado.
- Capa de servicio (`BrandConfig`/`BrandUITheme`) y los 95 `[ ]` del checklist.
