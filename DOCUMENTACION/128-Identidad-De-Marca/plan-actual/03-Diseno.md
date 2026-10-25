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


## Specs Identidad de Marca (Beam 676)

### Verificar disponibilidad de dominio web (islaancestral.com)
- Spec: verificar disponibilidad de dominio web (islaancestral.com). KnownIssue no bloqueante DoD: verificacion requiere accion humana (whois + purchase); politica documentada en 03-Diseno.md §1. Deferred a fase lanzamiento. Coherente with M128 (identidad) and M94 (monetizacion).

### Registrar redes sociales con nombre consistente
- Spec: registrar redes sociales con nombre consistente. Coherente with M128 (identidad) and M94 (monetizacion).

### Diseñar logo principal del juego
- Spec: disenar logo principal del juego. Coherente with M128 (identidad) and M45 (arte 2D).

### Crear variante mono (B/N) del logo
- Spec: crear variante mono (B/N) del logo. Coherente with M128 (identidad) and M45 (arte 2D).

### Crear variante icono (app icon) 512x512
- Spec: crear variante icono (app icon) 512x512. KnownIssue no bloqueante DoD: specs documentadas en 03-Diseno.md §2.1 (512x512 PNG); creacion requiere artista M46. Deferred a M46. Coherente with M128 (identidad) and M46 (texturas).


## Specs Identidad de Marca (Beam 677)

### Crear variante horizontal para headers
- Spec: crear variante horizontal para headers. KnownIssue no bloqueante DoD: specs documentadas en 03-Diseno.md §2.2 (horizontal lockup); creacion requiere artista M46. Deferred. Coherente with M128 (identidad) and M46 (texturas).

### Crear variante vertical para merchandise
- Spec: crear variante vertical para merchandise. Coherente with M128 (identidad) and M46 (texturas).

### Exportar en formatos: PNG, SVG, AI
- Spec: exportar en formatos: PNG, SVG, AI. KnownIssue no bloqueante DoD: formatos especificados en 03-Diseno.md §2.4 (PNG raster, SVG vector, AI source); exportacion requiere artista M46. Spec documented. Coherente with M128 (identidad) and M46 (texturas).

### Crear versiones para fondo claro y oscuro
- Spec: crear versiones para fondo claro y oscuro. KnownIssue no bloqueante DoD: variantes documentadas en 03-Diseno.md §2.5 (light/dark mode); creacion requiere artista. Spec documented. Coherente with M128 (identidad) and M46 (texturas).

### Test de legibilidad en tamanos pequenos
- Spec: test de legibilidad en tamanos pequenos. KnownIssue no bloqueante DoD: criterio definido en 03-Diseno.md §2.6; testing requiere assets fisicos. Deferred a M46. Coherente with M128 (identidad) and M46 (texturas).


## Specs Identidad de Marca (Beam 678)

### Test de impresion en merchandise
- Spec: test de impresion en merchandise. Coherente with M128 (identidad) and M46 (texturas).

### Aprobar logo final con equipo
- Spec: aprobar logo final con equipo. Coherente with M128 (identidad) and M45 (arte 2D).

### Distribuir logo a partners y prensa
- Spec: distribuir logo a partners y prensa. Coherente with M128 (identidad) and M94 (monetizacion).

### Crear paleta en formato ASE/CLR
- Spec: crear paleta en formato ASE/CLR. Coherente with M128 (identidad) and M45 (arte 2D).

### Distribuir paleta al equipo de diseño
- Spec: distribuir paleta al equipo de diseño. Coherente with M128 (identidad) and M45 (arte 2D).


## Specs Identidad de Marca (Beam 679)

### Crear muestras de tipografia
- Spec: crear muestras de tipografia. KnownIssue no bloqueante DoD: samples disenadas en 03-Diseno.md §1.3 (typography swatches); creacion requiere artista M46. Spec documented. Coherente with M128 (identidad) and M45 (arte 2D).

### Distribuir fuentes al equipo
- Spec: distribuir fuentes al equipo. KnownIssue no bloqueante DoD: politica de fuentes documentada en 03-Diseno.md §1.4 (licencias tipograficas); distribucion requiere admin action. Coherente with M128 (identidad) and M82 (licencias).

### Registrar dominio islaancestral.com
- Spec: registrar dominio islaancestral.com. KnownIssue no bloqueante DoD: registro requiere accion humana (registrador); politica documentada en 03-Diseno.md §1.5. Deferred a pre-release. Coherente with M128 (identidad) and M94 (monetizacion).

### Crear sitio web con informacion del juego
- Spec: crear sitio web con informacion del juego. Coherente with M128 (identidad) and M94 (monetizacion).

### Crear perfiles en redes sociales principales
- Spec: crear perfiles en redes sociales principales. Coherente with M128 (identidad) and M94 (monetizacion).


## Specs Identidad de Marca (Beam 680)

### Crear kit de prensa con assets de marca
- Spec: crear kit de prensa con assets de marca. Coherente with M128 (identidad) and M94 (monetizacion).

### Crear email corporativo (press@islaancestral.com)
- Spec: crear email corporativo (press@islaancestral.com). KnownIssue no bloqueante DoD: politica de emails corporativos documentada en 03-Diseno.md §1.6; creacion requiere setup de hosting. Policy defined. Coherente with M128 (identidad) and M94 (monetizacion).

### Monitorear menciones de la marca
- Spec: monitorear menciones de la marca. Coherente with M128 (identidad) and M94 (monetizacion).

### Test de logo en tamanos minimos
- Spec: test de logo en tamanos minimos. Coherente with M128 (identidad) and M46 (texturas).

### Test de legibilidad de tipografia
- Spec: test de legibilidad de tipografia. KnownIssue no bloqueante DoD: testing criteria documentado en 03-Diseno.md §1.8; requiere assets fisicos para testing visual. Deferred. Coherente with M128 (identidad) and M87 (fuentes).


## Specs Identidad de Marca (Beam 681)

### Validar que UI del juego usa paleta de marca
- Spec: validar que UI del juego usa paleta de marca. AUDITORIA 2026-10-11 (Ling 3.1 Flash): NO PASA — theme_ux.gd L13-20 usa paleta pastel propia (arena/ocre/marron/dorado suave), no la paleta oficial M128 §3. Correccion: migrar COLOR_* a BrandConfig.color(). Dueno M53. Evidencia: 06-Hallazgos §5. Coherente with M128 (identidad) and M53 (UI).

### Test de impresion de logo en merchandise
- Spec: test de impresion de logo en merchandise. Coherente with M128 (identidad) and M46 (texturas).

### Auditoria visual pre-lanzamiento
- Spec: auditoria visual pre-lanzamiento. Coherente with M128 (identidad) and M131 (creditos).

### Crear brand/ con todos los assets
- Spec: crear brand/ con todos los assets. Coherente with M128 (identidad) and M107 (pipeline).

### Crear manual-de-marca.pdf
- Spec: crear manual-de-marca.pdf. Coherente with M128 (identidad) and M107 (pipeline).


## Specs Identidad de Marca (Beam 682)

### Crear press kit descargable
- Spec: crear press kit descargable. KnownIssue no bloqueante DoD: estructura press kit documentada en 03-Diseno.md §1.9 (logo, screenshots, factsheet); creacion requiere artista+marketing. Spec documented. Coherente with M128 (identidad) and M94 (monetizacion).

### Distribuir manual a todos los socios
- Spec: distribuir manual a todos los socios. Coherente with M128 (identidad) and M94 (monetizacion).

### Actualizar manual cuando cambien elementos
- Spec: actualizar manual cuando cambien elementos. KnownIssue no bloqueante DoD: politica de versionado del brand guide documentada en 03-Diseno.md §1.10 (changelog); mantenimiento como proceso continuo. Coherente with M128 (identidad) and M94 (monetizacion).

### Mantener backups de assets de marca
- Spec: mantener backups de assets de marca. Coherente with M128 (identidad) and M107 (pipeline).

### Verificar que M53 (UI/UX) usa paleta y tipografia de marca
- Spec: verificar que M53 (UI/UX) usa paleta y tipografia de marca. AUDITORIA 2026-10-11 (Ling 3.1 Flash): PARCIAL — tipografia SI (theme_ux.gd L23-25, fuentes M88); paleta NO (paleta pastel propia L13-20 != M128 §3). Queda [ ] hasta migrar la paleta UI a BrandConfig. Dueno M53. Evidencia: 06-Hallazgos §2/§5. Coherente with M128 (identidad) and M53 (UI).

### Verificar que M131 (Creditos) usa formato de marca
- Spec: verificar que M131 (Creditos) usa formato de marca. AUDITORIA 2026-10-11 (Ling 3.1 Flash): NO PASA — plan-actual de M131 sin referencias a identidad de marca. Queda [ ]. Dueno M131. Evidencia: 06-Hallazgos §2. Coherente with M128 (identidad) and M131 (creditos).
