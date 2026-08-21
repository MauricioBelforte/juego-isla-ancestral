# Módulo 128: Identidad de Marca — Diseño

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:29:00

## 1. Estructura del Manual de Marca

```
[Manual de Marca - Isla Ancestral]
       │
       ├── 1. Introducción
       │      ├── Bienvenida
       │      ├── Propósito del manual
       │      └── Cómo usar este manual
       │
       ├── 2. Identidad de Marca
       │      ├── Nombre oficial
       │      ├── Tagline
       │      ├── Historia de la marca
       │      └── Valores de la marca
       │
       ├── 3. Logo
       │      ├── Logo principal
       │      ├── Variantes (mono, icono, horizontal, vertical)
       │      ├── Tamaños mínimos
       │      ├── Espacio libre (clear space)
       │      ├── Usos permitidos
       │      └── Usos PROHIBIDOS
       │
       ├── 4. Paleta de Colores
       │      ├── Colores primarios
       │      ├── Colores secundarios
       │      ├── Colores de acento
       │      ├── Neutros
       │      └── Contraste (WCAG)
       │
       ├── 5. Tipografía
       │      ├── Fuente principal
       │      ├── Fuente secundaria
       │      ├── Jerarquía
       │      └── Tamaños y pesos
       │
       ├── 6. Iconografía
       │      ├── Estilo de iconos
       │      ├── Tamaños
       │      └── Uso en interfaces
       │
       ├── 7. Fotografía e Ilustración
       │      ├── Estilo de imágenes
       │      ├── Filtros permitidos
       │      └── Composición
       │
       ├── 8. Uso en Redes Sociales
       │      ├── Perfil y portada
       │      ├── Posts y stories
       │      └── Respuestas
       │
       ├── 9. Merchandise
       │      ├── Usos permitidos
       │      ├── Restricciones
       │      └── Aprobación
       │
       └── 10. Contacto
              ├── Quién aprueba uso de marca
              └── Proceso de solicitud
```

## 2. Reglas de Uso del Logo

### Espacio Libre (Clear Space)

```
┌─────────────────────────┐
│                         │
│   ┌─────────────────┐   │
│   │                 │   │
│   │     LOGO        │   │
│   │                 │   │
│   └─────────────────┘   │
│                         │
└─────────────────────────┘

Espacio libre mínimo = Altura del logo / 4
en TODAS las direcciones
```

### Tamaño Mínimo

| Formato | Tamaño Mínimo |
|---------|---------------|
| Digital | 32px altura |
| Impresión | 10mm altura |
| App Icon | 1024x1024 |

### Usos PROHIBIDOS

- ❌ Cambiar colores del logo
- ❌ Agregar efectos (sombra, brillo, 3D)
- ❌ Distorsionar o estirar
- ❌ Rotar
- ❌ Usar con fondos que dificulten legibilidad
- ❌ Recortar partes del logo
- ❌ Usar versiones no oficiales
- ❌ Combinar con otros logos sin aprobación

## 3. Paleta de Colores Detallada

### Colores Principales

| Nombre | Hex | RGB | CMYK | Uso |
|--------|-----|-----|------|-----|
| Azul Bosque | #2E5A4C | 46, 90, 76 | 78, 30, 58, 24 | Color principal |
| Dorado Anciano | #D4A843 | 212, 168, 67 | 10, 30, 80, 5 | Acentos, UI |
| Blanco Perla | #F5F0E8 | 245, 240, 232 | 3, 4, 8, 0 | Fondos |

### Colores Secundarios

| Nombre | Hex | RGB | Uso |
|--------|-----|-----|-----|
| Verde Hoja | #5A8A6C | 90, 138, 108 | Naturaleza |
| Terracota | #C47A5A | 196, 122, 90 | Tierra, calidez |
| Cielo Claro | #8AB4D4 | 138, 180, 212 | Agua, cielo |

### Neutros

| Nombre | Hex | RGB | Uso |
|--------|-----|-----|-----|
| Carbón | #2C2C2C | 44, 44, 44 | Texto principal |
| Gris Piedra | #6B6B6B | 107, 107, 107 | Texto secundario |
| Crema | #FAF8F5 | 250, 248, 245 | Fondos claros |

## 4. Archivos de Marca

### Estructura de Archivos

```
brand/
├── logo/
│   ├── logo-principal.png
│   ├── logo-principal.svg
│   ├── logo-mono.png
│   ├── logo-mono.svg
│   ├── logo-icono.png
│   ├── logo-horizontal.png
│   └── logo-vertical.png
├── colores/
│   ├── paleta-principal.ase
│   └── paleta-secundaria.ase
├── tipografia/
│   ├── fuente-principal.ttf
│   ├── fuente-secundaria.ttf
│   └── LICENCIA.txt
├── manual-de-marca.pdf
├── manual-de-marca-web/
│   └── index.html
└── plantillas/
    ├── plantilla-post-redes.psd
    ├── plantilla-banner.psd
    └── plantilla-merchandise.psd
```

## 5. Integración con Sistemas del Juego

### Con M46 (Arte 2D)

```
[M46 Iconos] ──► [Brand Guidelines]
                      │
                      ▼
                 [Usar colores de paleta]
                      │
                      ▼
                 [Usar tipografía oficial]
```

### Con M53 (UI/UX)

```
[M53 UI] ──► [Brand Guidelines]
                  │
                  ▼
             [Coherencia visual]
                  │
                  ▼
             [Mismos colores y tipografía]
```
