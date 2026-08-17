**Modelo:** SWE-1.6
**Plataforma:** Devin

# 01-Requerimientos.md — Módulo 110: Debug Menu

## ID del Módulo
- **Código:** M110 (plan maestro: sección 109 — Debug Menu)
- **Carpeta:** `DOCUMENTACION/110-Debug-Menu/`
- **Dependencias:** M04 (Game Engine), M07 (Arquitectura), M11 (Personaje), M29 (Tiempo), M31 (Clima), M14 (Inventario), M19 (NPC), M24 (Puzzles), M08 (Mundo Voxel), M103 (Logging)
- **Carácter:** Módulo de herramientas de desarrollo (UI in-game para debugging)

## 1. Problema

El desarrollo necesita un **menú de debug accesible en runtime** para probar funcionalidades rápidamente, visualizar información del juego, diagnosticar problemas y exportar datos para análisis, sin necesidad de recompilar o modificar código.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Teletransporte | Mover al jugador a cualquier coordenada |
| RF2 | Cambio de hora | Modificar la hora del juego (M29) |
| RF3 | Cambio de estación | Cambiar estación actual (M29/M31) |
| RF4 | Cambio de clima | Modificar clima actual (M31) |
| RF5 | Dar objetos | Agregar items al inventario (M14) |
| RF6 | Dar dinero | Modificar dinero/economía (M38) |
| RF7 | Completar misión | Marcar misión como completada (M22) |
| RF8 | Desbloquear herramienta | Desbloquear herramienta específica (M13) |
| RF9 | Desbloquear isla | Desbloquear isla para viaje (M28) |
| RF10 | Desbloquear Sello | Desbloquear Sello del templo (M22) |
| RF11 | Resetear NPC | Reiniciar estado/rutina de NPC (M19) |
| RF12 | Resetear puzzle | Reiniciar estado de puzzle (M24) |
| RF13 | Regenerar chunk | Forzar regeneración de chunk (M08) |
| RF14 | Mostrar colliders | Visualizar colliders en el mundo |
| RF15 | Mostrar FPS | Mostrar contador de FPS |
| RF16 | Mostrar chunks | Visualizar chunks cargados/activos |
| RF17 | Mostrar navegación | Visualizar paths de navegación (M19/M64) |
| RF18 | Mostrar hitboxes | Visualizar hitboxes de entidades |
| RF19 | Mostrar estados de IA | Visualizar estados de IA de NPC (M64) |
| RF20 | Exportar diagnóstico | Exportar estado del juego para bug reports (M102/M103) |

## 3. Requisitos No Funcionales

- Solo accesible en builds de desarrollo (desactivado en release)
- Atajo de teclado configurable (por defecto: F1 o Backtick)
- UI superpuesta que no pausa el juego (opcional pausa)
- Bajo overhead de rendimiento (debug visualización opcional)
- Integración con M103 (Logging) para exportar diagnóstico
- Persistencia de configuración del debug menu (posición, estado)

## 4. Criterios de Aceptación

1. Los 20 puntos de la sección 109 del plan maestro resueltos.
2. Debug menu accesible vía atajo de teclado en builds de desarrollo.
3. Todas las funciones de debug implementadas y probadas.
4. Integración con M102 (Bug Tracking) para exportar diagnóstico.
5. Visualizaciones debug (colliders, FPS, chunks) funcionales y optimizadas.
