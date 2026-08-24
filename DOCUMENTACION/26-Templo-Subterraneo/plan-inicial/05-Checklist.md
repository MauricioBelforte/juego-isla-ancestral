# 05 — Checklist — M26: Templo Subterráneo (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Entrada y vestíbulo

- [ ] Diseñar la entrada del templo (pórtico bajo raíces, puerta sellada) [M]
- [ ] Definir respiradero de brisa visible en la entrada [S]
- [ ] Diseñar el vestíbulo con 3 vías de orientación [M]
- [ ] Definir plaza de desembarque de la entrada [S]
- [ ] Definir primera vía al templo (núcleo) [S]
- [ ] Definir vía a la Guarda de la Brisa [S]
- [ ] Documentar entrada y vestíbulo en el plan-actual [S]

## Primera sala y tutorial

- [ ] Diseñar "Sala de los Vientos" con 3 puzzles de viento [M]
- [ ] Definir el tutorial guiado (panel Guía del Templo) [M]
- [ ] Definir 1 puzzle guiado paso a paso [M]
- [ ] Definir banda de dificultad Exploración en la sala inicial [S]
- [ ] Definir acceso al pasillo del Artesano desde la sala [S]
- [ ] Documentar primera sala y tutorial [S]

## Habitaciones intermedias y caminos alternativos

- [ ] Diseñar 6 habitaciones intermedias [M]
- [ ] Definir 2 salas de luz (M24) [S]
- [ ] Definir 1 sala de agua [S]
- [ ] Definir 1 sala de presión [S]
- [ ] Definir 1 sala de sonido [S]
- [ ] Definir 1 sala de secuencia [S]
- [ ] Diseñar el pasillo del Artesano (alternativa lateral) [M]
- [ ] Definir 1 puzzle de herramientas en el pasillo [S]
- [ ] Definir 2+ caminos para cada rama (M66) [M]
- [ ] Documentar habitaciones y caminos alternativos [S]

## Salas secretas

- [ ] Diseñar 4 salas secretas [M]
- [ ] Definir sala bajo placa de presión [S]
- [ ] Definir sala tras puerta falsa [S]
- [ ] Definir sala tras mural giratorio [S]
- [ ] Definir sala bajo el acuífero [S]
- [ ] Definir 2+ caminos de acceso a cada sala [M]
- [ ] Definir recompensas únicas (sellos de cristal) en las salas [S]
- [ ] Documentar salas secretas [S]

## Sala central y mecanismo principal

- [ ] Diseñar la rotonda de la Columna [M]
- [ ] Definir el mecanismo de 7 anillos de viento [C]
- [ ] Definir 4 sellos de cristal de salas secretas [S]
- [ ] Definir 3 sellos de habitaciones intermedias [S]
- [ ] Definir activación de anillo con sello + posición de glifo (M24 símbolos) [M]
- [ ] Definir estado de sala multipllex para los 7 anillos [M]
- [ ] Documentar sala central y mecanismo [M]

## Puzzle final y cámara del Sello

- [ ] Diseñar el puzzle final en 3 fases [C]
- [ ] Definir fase 1: espejo maestro y rayo cenital (luz) [M]
- [ ] Definir fase 2: 3 gongs en el orden de glifos (sonido) [M]
- [ ] Definir pista de la secuencia visible tras 2 intentos [S]
- [ ] Definir fase 3: timón de agua y barca (agua) [M]
- [ ] Diseñar la Cámara del Sello (sancta) [M]
- [ ] Definir pedestal del Sello [S]
- [ ] Definir cutscene contextual mínima (hook M33) [S]
- [ ] Definir restauración del sello abre la salida [M]
- [ ] Documentar puzzle final y cámara del Sello [M]

## Salida y checkpoints

- [ ] Diseñar la salida (túnel del amanecer) [S]
- [ ] Definir atajo al puerto por la salida [S]
- [ ] Definir apertura de salida solo con sello restaurado [M]
- [ ] Diseñar 5 checkpoints (porte, vestíbulo, vientos, central, sello) [M]
- [ ] Definir guardado atómico en cada checkpoint [M]
- [ ] Definir respaldo `.bak` en cada checkpoint [S]
- [ ] Documentar salida y checkpoints [S]

## Iluminación y sonido ambiental

- [ ] Diseñar faros de cristal por sala [M]
- [ ] Definir luz volumétrica suave "brisa" [M]
- [ ] Definir contraste ≥ 4.5:1 en iconografía (M58) [M]
- [ ] Diseñar sonido de brisa en corredores (M42) [S]
- [ ] Diseñar goteo de agua (M43) [S]
- [ ] Definir 3 ambiences por banda de dificultad (M41) [M]
- [ ] Documentar iluminación y sonido ambiental [S]

## Partículas, materiales y texturas

- [ ] Diseñar polvo de luz en la rotonda (M52) [S]
- [ ] Definir viento visible en corredores [S]
- [ ] Definir límite de 256 partículas por escena [S]
- [ ] Definir paleta de materiales del templo (piedra de brisa, cristal, bronce) [M]
- [ ] Definir 3 materiales base + variantes por edad (M47) [M]
- [ ] Definir 12 texturas clave con LOD 0-2 (M47/M63) [M]
- [ ] Documentar partículas, materiales y texturas [S]

## Iconografía y arquitectura

- [ ] Diseñar 8 glifos del Sello (4 comunes + 4 de cámara) [M]
- [ ] Definir glosario en la Guía del Templo (M24) [S]
- [ ] Definir arquitectura voxel-compatible (corredores 4x4x4 m) [C]
- [ ] Definir puertas de 2x3 bloques [S]
- [ ] Definir techos de 3x3 bloques [S]
- [ ] Definir transiciones en 45° [S]
- [ ] Definir rampas con pendiente ≤ 20° [S]
- [ ] Documentar iconografía y arquitectura [M]

## Navegación y telemetría

- [ ] Crear navegación con NavigationServer3D por piso [M]
- [ ] Definir vínculos verticales (rampas y huecos discretos) [M]
- [ ] Definir sin teleports en navegación (anti-exploit) [S]
- [ ] Crear telemetría de puzzles (intentos, pistas, tiempo) [M]
- [ ] Definir exportación JSON a M24 para balance [M]
- [ ] Documentar navegación y telemetría [S]

## Softlocks, exploits y orientación

- [ ] Testear softlocks por zona (suite M66) [M]
- [ ] Testear objetos y llaves perdidos [M]
- [ ] Testear NPC atascados en el templo [M]
- [ ] Testear puzzles irresolubles [M]
- [ ] Testear exploits por acceleración en rampas [M]
- [ ] Testear duplicación de sellos [M]
- [ ] Testear entrada por la salida sellada [M]
- [ ] Implementar mojones visuales cada 40 m [M]
- [ ] Implementar mapa de zona simplificado (panel M58) [M]
- [ ] Definir prueba de deriva (jugador perdido < 2 min) [M]
- [ ] Documentar softlocks, exploits y orientación [M]

## Accesibilidad y rendimiento

- [ ] Definir iconografía ≥ 16 px (M58) [S]
- [ ] Definir contraste ≥ 4.5:1 [M]
- [ ] Definir sin presión temporal en puzzles [S]
- [ ] Definir subtítulos activables (M43) [S]
- [ ] Definir reducción de partículas y parpadeo (fotosensibilidad) [S]
- [ ] Definir presupuesto por región (M63, streaming por piso) [M]
- [ ] Definir instancing de columnas en la rotonda [S]
- [ ] Definir luz volumétrica solo en 2 salas fijas [S]
- [ ] Documentar accesibilidad y rendimiento [M]

## Testings y documentación

- [ ] Diseñar 06-Plan-Testings.md: gating (sellos y salida) [M]
- [ ] Diseñar 06-Plan-Testings.md: anti-exploit (suite de saltos) [M]
- [ ] Diseñar 06-Plan-Testings.md: orientación (deriva) [M]
- [ ] Diseñar 06-Plan-Testings.md: softlocks por zona [M]
- [ ] Diseñar 06-Plan-Testings.md: accesibilidad (contrastes) [M]
- [ ] Definir criterio de éxito: suite completa pasa sin fallos [S]
- [ ] Crear 07-Resultados-Testings.md para registrar la ejecución [S]
- [ ] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [ ] Actualizar plan-actual como espejo del estado real [M]
- [ ] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [ ] Actualizar fila 26 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [ ] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.