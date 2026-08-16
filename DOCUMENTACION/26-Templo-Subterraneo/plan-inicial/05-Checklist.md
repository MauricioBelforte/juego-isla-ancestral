# 05 — Checklist — M26: Templo Subterráneo (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Entrada y vestíbulo

- [x] Diseñar la entrada del templo (pórtico bajo raíces, puerta sellada) [M]
- [x] Definir respiradero de brisa visible en la entrada [S]
- [x] Diseñar el vestíbulo con 3 vías de orientación [M]
- [x] Definir plaza de desembarque de la entrada [S]
- [x] Definir primera vía al templo (núcleo) [S]
- [x] Definir vía a la Guarda de la Brisa [S]
- [x] Documentar entrada y vestíbulo en el plan-actual [S]

## Primera sala y tutorial

- [x] Diseñar "Sala de los Vientos" con 3 puzzles de viento [M]
- [x] Definir el tutorial guiado (panel Guía del Templo) [M]
- [x] Definir 1 puzzle guiado paso a paso [M]
- [x] Definir banda de dificultad Exploración en la sala inicial [S]
- [x] Definir acceso al pasillo del Artesano desde la sala [S]
- [x] Documentar primera sala y tutorial [S]

## Habitaciones intermedias y caminos alternativos

- [x] Diseñar 6 habitaciones intermedias [M]
- [x] Definir 2 salas de luz (M24) [S]
- [x] Definir 1 sala de agua [S]
- [x] Definir 1 sala de presión [S]
- [x] Definir 1 sala de sonido [S]
- [x] Definir 1 sala de secuencia [S]
- [x] Diseñar el pasillo del Artesano (alternativa lateral) [M]
- [x] Definir 1 puzzle de herramientas en el pasillo [S]
- [x] Definir 2+ caminos para cada rama (M66) [M]
- [x] Documentar habitaciones y caminos alternativos [S]

## Salas secretas

- [x] Diseñar 4 salas secretas [M]
- [x] Definir sala bajo placa de presión [S]
- [x] Definir sala tras puerta falsa [S]
- [x] Definir sala tras mural giratorio [S]
- [x] Definir sala bajo el acuífero [S]
- [x] Definir 2+ caminos de acceso a cada sala [M]
- [x] Definir recompensas únicas (sellos de cristal) en las salas [S]
- [x] Documentar salas secretas [S]

## Sala central y mecanismo principal

- [x] Diseñar la rotonda de la Columna [M]
- [x] Definir el mecanismo de 7 anillos de viento [C]
- [x] Definir 4 sellos de cristal de salas secretas [S]
- [x] Definir 3 sellos de habitaciones intermedias [S]
- [x] Definir activación de anillo con sello + posición de glifo (M24 símbolos) [M]
- [x] Definir estado de sala multipllex para los 7 anillos [M]
- [x] Documentar sala central y mecanismo [M]

## Puzzle final y cámara del Sello

- [x] Diseñar el puzzle final en 3 fases [C]
- [x] Definir fase 1: espejo maestro y rayo cenital (luz) [M]
- [x] Definir fase 2: 3 gongs en el orden de glifos (sonido) [M]
- [x] Definir pista de la secuencia visible tras 2 intentos [S]
- [x] Definir fase 3: timón de agua y barca (agua) [M]
- [x] Diseñar la Cámara del Sello (sancta) [M]
- [x] Definir pedestal del Sello [S]
- [x] Definir cutscene contextual mínima (hook M33) [S]
- [x] Definir restauración del sello abre la salida [M]
- [x] Documentar puzzle final y cámara del Sello [M]

## Salida y checkpoints

- [x] Diseñar la salida (túnel del amanecer) [S]
- [x] Definir atajo al puerto por la salida [S]
- [x] Definir apertura de salida solo con sello restaurado [M]
- [x] Diseñar 5 checkpoints (porte, vestíbulo, vientos, central, sello) [M]
- [x] Definir guardado atómico en cada checkpoint [M]
- [x] Definir respaldo `.bak` en cada checkpoint [S]
- [x] Documentar salida y checkpoints [S]

## Iluminación y sonido ambiental

- [x] Diseñar faros de cristal por sala [M]
- [x] Definir luz volumétrica suave "brisa" [M]
- [x] Definir contraste ≥ 4.5:1 en iconografía (M58) [M]
- [x] Diseñar sonido de brisa en corredores (M42) [S]
- [x] Diseñar goteo de agua (M43) [S]
- [x] Definir 3 ambiences por banda de dificultad (M41) [M]
- [x] Documentar iluminación y sonido ambiental [S]

## Partículas, materiales y texturas

- [x] Diseñar polvo de luz en la rotonda (M52) [S]
- [x] Definir viento visible en corredores [S]
- [x] Definir límite de 256 partículas por escena [S]
- [x] Definir paleta de materiales del templo (piedra de brisa, cristal, bronce) [M]
- [x] Definir 3 materiales base + variantes por edad (M47) [M]
- [x] Definir 12 texturas clave con LOD 0-2 (M47/M63) [M]
- [x] Documentar partículas, materiales y texturas [S]

## Iconografía y arquitectura

- [x] Diseñar 8 glifos del Sello (4 comunes + 4 de cámara) [M]
- [x] Definir glosario en la Guía del Templo (M24) [S]
- [x] Definir arquitectura voxel-compatible (corredores 4x4x4 m) [C]
- [x] Definir puertas de 2x3 bloques [S]
- [x] Definir techos de 3x3 bloques [S]
- [x] Definir transiciones en 45° [S]
- [x] Definir rampas con pendiente ≤ 20° [S]
- [x] Documentar iconografía y arquitectura [M]

## Navegación y telemetría

- [x] Crear navegación con NavigationServer3D por piso [M]
- [x] Definir vínculos verticales (rampas y huecos discretos) [M]
- [x] Definir sin teleports en navegación (anti-exploit) [S]
- [x] Crear telemetría de puzzles (intentos, pistas, tiempo) [M]
- [x] Definir exportación JSON a M24 para balance [M]
- [x] Documentar navegación y telemetría [S]

## Softlocks, exploits y orientación

- [x] Testear softlocks por zona (suite M66) [M]
- [x] Testear objetos y llaves perdidos [M]
- [x] Testear NPC atascados en el templo [M]
- [x] Testear puzzles irresolubles [M]
- [x] Testear exploits por acceleración en rampas [M]
- [x] Testear duplicación de sellos [M]
- [x] Testear entrada por la salida sellada [M]
- [x] Implementar mojones visuales cada 40 m [M]
- [x] Implementar mapa de zona simplificado (panel M58) [M]
- [x] Definir prueba de deriva (jugador perdido < 2 min) [M]
- [x] Documentar softlocks, exploits y orientación [M]

## Accesibilidad y rendimiento

- [x] Definir iconografía ≥ 16 px (M58) [S]
- [x] Definir contraste ≥ 4.5:1 [M]
- [x] Definir sin presión temporal en puzzles [S]
- [x] Definir subtítulos activables (M43) [S]
- [x] Definir reducción de partículas y parpadeo (fotosensibilidad) [S]
- [x] Definir presupuesto por región (M63, streaming por piso) [M]
- [x] Definir instancing de columnas en la rotonda [S]
- [x] Definir luz volumétrica solo en 2 salas fijas [S]
- [x] Documentar accesibilidad y rendimiento [M]

## Testings y documentación

- [x] Diseñar 06-Plan-Testings.md: gating (sellos y salida) [M]
- [x] Diseñar 06-Plan-Testings.md: anti-exploit (suite de saltos) [M]
- [x] Diseñar 06-Plan-Testings.md: orientación (deriva) [M]
- [x] Diseñar 06-Plan-Testings.md: softlocks por zona [M]
- [x] Diseñar 06-Plan-Testings.md: accesibilidad (contrastes) [M]
- [x] Definir criterio de éxito: suite completa pasa sin fallos [S]
- [x] Crear 07-Resultados-Testings.md para registrar la ejecución [S]
- [x] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [x] Actualizar plan-actual como espejo del estado real [M]
- [x] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [x] Actualizar fila 26 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [x] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.