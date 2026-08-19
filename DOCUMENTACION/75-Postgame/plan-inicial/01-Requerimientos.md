**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 75: Postgame

## ID del Módulo
- **Código:** M75 (CHECKLIST-GLOBAL: ID 75 — Postgame; plan maestro: sección 74 "POSTGAME")
- **Carpeta:** `DOCUMENTACION/75-Postgame/`
- **Dependencias:** M22 (Historia Principal — final), M71 (Progresión). Relaciones: M74 (Eventos), M73 (Coleccionables), M72 (Logros), M27 (Islas — nuevas), M19 (NPC — vecinos), M50 (Plantas), M36 (Fauna — animales), M25 (Ruinas), M24/M26 (Puzzles), M16 (Crafting — herramientas), M17 (Mejoras), M22/M23 (Historias), M51 (Zonas submarinas), M10 (Islas flotantes), M59 (Guardado), M61 (Rendimiento)
- **Delegable desde:** M22 (historia), M71 (progresión)

## 1. Problema

Al completar la historia principal (M22, 7 capítulos y finales), el jugador espera una isla con vida: "¿qué hice? ¿qué me falta?" Sin un postgame definido, el juego muere con los créditos: contenido de 100% sin hoja de ruta, logros finales sin hitos, o promesas de "nuevas islas" que nunca llegan. El plan maestro lista 20 exigencias: contenido después de la historia, nuevas islas, vecinos, muebles, plantas, animales, ruinas, puzzles, colecciones, herramientas, mejoras, historias, eventos, secretos, zonas submarinas, islas flotantes, sistemas opcionales, objetivos de 100%, logros finales y exploración libre. El objetivo es un postgame NÚCLEO PAQUETE definido y priorizado: contenido de libre exploración inmediato tras el final, objetivos de 100% con hoja de ruta, y expansiones (islas, zonas submarinas, sistemas opcionales) catalogadas como contenido = arquitectura lista, contenido = fase 2 (post-lanzamiento) claramente marcado.

## 2. Objetivo

Definir el postgame de la isla: contenido inmediato tras el final (epílogo M22 + exploración libre completa), objetivos de 100% (colecciones M73, museo M37, logros finales M72), nuevos eventos rotativos (M74), sistemas opcionales (jardín acuático, criadero de peces — fase 2), y expansiones de mundo (nuevas islas M27, zonas submarinas M51, islas flotantes M10) priorizadas por valor de diseño. La regla de oro: el postgame NO se siente postcarga — el 100% se persigue con la MISMA satisfacción cozy que la historia, sin grindeo.

## 3. Alcance

### 3.1 Dentro del alcance
- Epílogo: contenido inmediato tras el final (M22), visita de créditos → "¿qué sigue?" (M92 tutorial).
- Exploración libre: la isla queda 100% abierta (M71 ya cumplido).
- Objetivos de 100%: hoja de ruta en el diario (M55) y museo (M37) con % por categoría.
- Logros finales (M72): hitos postgame (colecciones completas, ruinas restauradas, eventos).
- Nuevos eventos (M74): rotativos de postgame programados en el calendario (M29).
- Catálogo de expansiones: nuevas islas (M27), zonas submarinas (M51), islas flotantes (M10), nuevos vecinos (M19), muebles/plantas/animales (M18/M50/M36), ruinas/puzzles (M25/M24), herramientas/mejoras (M16/M17), historias (M22/M23), secretos (M71), colecciones (M73).
- Contenido de fase 2 (post-lanzamiento): marcado claramente en el catálogo (islas flotantes, sistemas opcionales).
- Validación: `validate_postgame.gd`.

### 3.2 Fuera del alcance
- El desarrollo de los sistemas nuevos en sí (islas, zonas): cada uno es su módulo (M27/M51/M10...).
- El sistema de logros: M72 (aquí solo los hitos postgame).
- El sistema de eventos: M74 (aquí solo los eventos postgame).
- La decisión de multijugador: M76.

## 4. Restricciones

- **UI Godot 4:** la hoja de ruta del 100% vive en el diario (M55) y el museo (M37).
- **Sin grindeo:** el 100% se alcanza con actividades naturales (pesca M34, excavación M25), nunca con repeticiones interminables.
- **Fase 2 explícita:** el catálogo de expansiones marca FASE 1 (lanzamiento) vs FASE 2 (post-lanzamiento) — sin ambigüedad.
- **Rendimiento (M61):** las islas flotantes (M10) y zonas submarinas (M51) respetan streaming/LOD.
- **Persistencia (M59):** el progreso postgame se guarda con el mismo sistema versionado.
- **Cozy:** el epílogo cierra la historia sin "créditos fríos"; la isla sigue viva.
- **Validable:** `validate_postgame.gd` sin errores en consola.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Contenido post-historia | Epílogo (M22) + hoja de ruta "¿qué sigue?" (M92) |
| RF2 | Nuevas islas | Catálogo: FASE 1 (isla del Este completa) / FASE 2 (isla flotante) |
| RF3 | Nuevos vecinos | M19: 1-2 vecinos nuevos en FASE 1 (post-lanzamiento) |
| RF4 | Nuevos muebles | M18: colección de muebles postgame |
| RF5 | Nuevas plantas | M50/M33: especies estacionales de postgame |
| RF6 | Nuevos animales | M36: especies raras solo postgame |
| RF7 | Nuevas ruinas | M25: ruina final restaurable |
| RF8 | Nuevos puzzles | M24: puzzle del Sello oculto (FASE 2) |
| RF9 | Nuevas colecciones | M73: categorías postgame (documentos finales) |
| RF10 | Nuevas herramientas | M16: herramienta de jardín acuático (FASE 2) |
| RF11 | Nuevas mejoras | M17: mejora de la casa postgame (ático) |
| RF12 | Nuevas historias | M23: cadenas secundarias postgame |
| RF13 | Nuevos eventos | M74: festivales rotativos de postgame |
| RF14 | Nuevos secretos | M71: secretos desbloqueables solo postgame |
| RF15 | Zonas submarinas | M51: arrecife profundo (FASE 2, con submarino M67) |
| RF16 | Islas flotantes | M10: isla flotante (FASE 2, con dirigible M67) |
| RF17 | Sistemas opcionales | Jardín acuático, criadero (FASE 2) |
| RF18 | Objetivos de 100% | Hoja de ruta con % por categoría (M55/M37/M73) |
| RF19 | Logros finales | M72: hitos postgame |
| RF20 | Exploración libre | Mundo abierto sin bloqueos tras el final |

## 6. Criterios de Aceptación (Verificables)

1. Tras el final (M22), la hoja de ruta del 100% está disponible sin spoilers.
2. El epílogo se siente parte de la historia (M21/M44), no un menú frío.
3. Los objetivos de 100% son alcanzables sin grindeo (actividades naturales).
4. El catálogo de expansiones distingue FASE 1 y FASE 2 sin ambigüedad.
5. Las zonas submarinas e islas flotantes respetan streaming y LOD (M61).
6. Los logros finales (M72) se desbloquean correctamente en postgame.
7. El progreso postgame persiste (M59) y migra (M60).
8. `validate_postgame.gd` pasa sin errores.