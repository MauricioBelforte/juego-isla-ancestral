**Modelo:** Devin
**Plataforma:** Antigravity

# 01-Requerimientos.md — Módulo 90: Configuración Gráfica

## ID del Módulo
- **Código:** M90 (plan maestro: sección 89 — Configuración Gráfica)
- **Carpeta:** `DOCUMENTACION/90-Configuracion-Grafica/`
- **Dependencias:** M50 (Modelos 3D), M61 (Rendimiento), M88 (Fuentes Tipográficas), M58 (Accesibilidad). Dependen de este: M57 (UI), M13 (Herramientas), M16 (Crafting), M19 (NPC), M22 (Misiones)
- **Carácter:** Módulo de configuración gráfica en settings del juego

## 1. Problema

El proyecto necesita **configuración gráfica** para permitir al usuario ajustar gráficos según su hardware y preferencias. Debe incluir resolución, pantalla completa, VSync, FPS, calidad de sombras, texturas, efectos, vegetación, agua, partículas, anti-aliasing, anisotropic filtering, post-processing, bloom, motion blur, depth of field, upscaling (FSR/DLSS/XeSS), escala de resolución, presets gráficos y detección automática.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Resolución | Selección de resolución (720p, 1080p, 1440p, 4K, nativa) |
| RF2 | Pantalla completa | Toggle de pantalla completa |
| RF3 | Ventana | Modo ventana |
| RF4 | Borderless | Toggle de borderless |
| RF5 | VSync | Toggle de VSync (0, 1, 2) |
| RF6 | FPS | Cap de FPS (30, 60, 120, ilimitado) |
| RF7 | Calidad de sombras | Calidad de sombras (baja, media, alta, ultra) |
| RF8 | Calidad de texturas | Calidad de texturas (baja, media, alta, ultra) |
| RF9 | Distancia de dibujado | Distancia de dibujado (cercana, media, lejana) |
| RF10 | Calidad de efectos | Calidad de efectos (baja, media, alta, ultra) |
| RF11 | Calidad de vegetación | Calidad de vegetación (baja, media, alta, ultra) |
| RF12 | Calidad de agua | Calidad de agua (baja, media, alta, ultra) |
| RF13 | Calidad de partículas | Calidad de partículas (baja, media, alta, ultra) |
| RF14 | Anti-aliasing | Anti-aliasing (off, FXAA, MSAA 2x, MSAA 4x, TAA) |
| RF15 | Anisotropic filtering | Anisotropic filtering (off, 2x, 4x, 8x, 16x) |
| RF16 | Post-processing | Toggle de post-processing |
| RF17 | Bloom | Toggle de bloom e intensidad |
| RF18 | Motion blur | Toggle de motion blur e intensidad |
| RF19 | Depth of field | Toggle de depth of field e intensidad |
| RF20 | FSR/DLSS/XeSS | Upscaling (FSR 1.0, FSR 2.0, DLSS, XeSS) si corresponde |
| RF21 | Escala de resolución | Escala de resolución (50%, 75%, 100%, 125%, 150%) |
| RF22 | Presets gráficos | Presets (bajo, medio, alto, ultra, personalizado) |
| RF23 | Detección automática | Detección automática de hardware y presets |

## 3. Requisitos No Funcionales

- Configuración debe ser accesible desde menú de settings
- Configuración debe guardarse en settings (M90)
- Configuración debe aplicarse en tiempo real cuando sea posible
- Presets gráficos deben balancear calidad y performance
- Detección automática debe recomendar preset según hardware

## 4. Criterios de Aceptación

1. Los 23 puntos de la sección 89 del plan maestro resueltos.
2. Menú de configuración gráfica accesible desde settings.
3. Todas las opciones gráficas disponibles con controles apropiados (sliders, toggles, dropdowns).
4. Presets gráficos funcionales (bajo, medio, alto, ultra, personalizado).
5. Detección automática de hardware y recomendación de preset.
6. Configuración guardada en settings (M90).
7. Configuración aplicada en tiempo real cuando sea posible.
8. Framerate estable y sin stuttering en preset recomendado.
