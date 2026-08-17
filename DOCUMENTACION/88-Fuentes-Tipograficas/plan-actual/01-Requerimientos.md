**Modelo:** SWE-1.6
**Plataforma:** Devin

# 01-Requerimientos.md — Módulo 88: Fuentes Tipográficas

## ID del Módulo
- **Código:** M88 (plan maestro: sección 87 — Fuentes Tipográficas)
- **Carpeta:** `DOCUMENTACION/88-Fuentes-Tipograficas/`
- **Dependencias:** M58 (Accesibilidad), M87 (Internacionalización), M90 (Configuración Gráfica). Dependen de este: M57 (UI), M13 (Herramientas), M16 (Crafting), M19 (NPC), M22 (Misiones)
- **Carácter:** Módulo de assets y configuración de tipografía para UI y texto del juego

## 1. Problema

El proyecto necesita **fuentes tipográficas** legibles, accesibles y localizables para el texto del juego (UI, diálogos, misiones, etc.). Las fuentes deben ser gratuitas, con licencia clara, soportar caracteres especiales (tildes, ñ, símbolos) y ser optimizadas para performance.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Elegir fuente principal | Fuente para UI principal (menús, HUD, diálogos) |
| RF2 | Elegir fuente secundaria | Fuente para títulos, cabeceras, énfasis |
| RF3 | Revisar licencia | Licencia clara y gratuita (Open Font License, SIL, etc.) |
| RF4 | Revisar caracteres | Soporte completo de caracteres alfabéticos |
| RF5 | Revisar tildes | Soporte de tildes (á, é, í, ó, ú) |
| RF6 | Revisar ñ | Soporte de ñ y Ñ |
| RF7 | Revisar símbolos | Soporte de símbolos comunes (¡, ¿, @, #, $, etc.) |
| RF8 | Revisar cirílico si corresponde | Soporte de cirílico si se planea localización a ruso/ucraniano |
| RF9 | Revisar CJK si corresponde | Soporte de CJK si se planea localización a chino/japonés/coreano |
| RF10 | Revisar legibilidad | Fuente legible en tamaños pequeños y grandes |
| RF11 | Definir tamaños | Tamaños de fuente para diferentes elementos de UI |
| RF12 | Definir pesos | Pesos de fuente (regular, bold, italic, etc.) |
| RF13 | Definir tracking | Espaciado entre letras para legibilidad |
| RF14 | Definir line height | Altura de línea para legibilidad |
| RF15 | Crear jerarquía visual | Jerarquía visual de tamaños y pesos |
| RF16 | Crear estilos de UI | Estilos de UI basados en fuentes |
| RF17 | Optimizar archivos de fuente | Optimización de archivos de fuente para performance |

## 3. Requisitos No Funcionales

- Fuentes deben ser gratuitas y con licencia clara
- Fuentes deben ser legibles en resoluciones bajas (720p) y altas (4K)
- Fuentes deben ser optimizadas para performance (subsetting, compresión)
- Fuentes deben ser accesibles (contraste, tamaños ajustables en M58)
- Fuentes deben ser localizables (M87)

## 4. Criterios de Aceptación

1. Los 17 puntos de la sección 87 del plan maestro resueltos.
2. Fuente principal seleccionada con licencia clara.
3. Fuente secundaria seleccionada con licencia clara.
4. Caracteres especiales soportados (tildes, ñ, símbolos).
5. Tamaños definidos para UI (títulos, subtítulos, cuerpo, pequeño).
6. Pesos definidos (regular, bold, italic).
7. Tracking y line height definidos.
8. Jerarquía visual creada.
9. Estilos de UI creados en Godot.
10. Archivos de fuente optimizados (subsetting, compresión).
