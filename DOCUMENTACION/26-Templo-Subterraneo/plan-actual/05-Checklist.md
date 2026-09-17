# 05 — Checklist — M26: Templo Subterráneo

**Modelo:** Deepseek V4 Flash (diseño, 2026-08-17) · DeepSeek-V4.1-Flash / WorkBuddy (iter. 2, 2026-09-14)
**Plataforma:** OpenCode (diseño) · WorkBuddy (iter. 2)
**Fecha:** 2026-08-17 (diseño) · 2026-09-14 (iter. 2)

## Convención

- `[x]` = completado: **existe un artefacto verificable en el repo** (código, datos, test o la línea de diseño citada). `[ ]` = pendiente. `[?]` = no resuelto / parcial, con el motivo y la dependencia al lado.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).
- **Nota de honestidad (iter. 2, Log 902):** el encabezado original decía `100/100 [x]`
  pero **ningún marcador estaba puesto**: era una afirmación de completitud *del
  diseño*, no un conteo real (patrón de sobre-cierre del proyecto). Acá se
  re-derivaron los marcadores: **iter. 2 solo marca `[x]` lo que produjo un
  artefacto verificable** (código, datos, test) o lo que dejó documentado en
  `04/06/07`. Los ítems de diseño narrativo (`Diseñar …`, `Definir …` sin
  artefacto) quedan `[ ]` aunque el diseño exista en `01/02/03`, porque su autor
  no los marcó y iter. 2 no los reverificó uno por uno.

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
- [x] Definir 2+ caminos para cada rama (M66) [M] — `TemploValidadores.validar_softlock()` exige ≥2 caminos en toda zona con recompensa y en `pasillo_artesano`; tests E/F
- [ ] Documentar habitaciones y caminos alternativos [S]

## Salas secretas

- [ ] Diseñar 4 salas secretas [M]
- [ ] Definir sala bajo placa de presión [S]
- [ ] Definir sala tras puerta falsa [S]
- [ ] Definir sala tras mural giratorio [S]
- [ ] Definir sala bajo el acuífero [S]
- [x] Definir 2+ caminos de acceso a cada sala [M] — las 4 secretas tienen exactamente 2 conexiones en `templo_layout_diseno.json`; `validar_softlock` lo exige
- [x] Definir recompensas únicas (sellos de cristal) en las salas [S] — `sello_cristal_1..4`; `validar_anti_exploit` rechaza recompensas duplicadas (test F)
- [ ] Documentar salas secretas [S]

## Sala central y mecanismo principal

- [ ] Diseñar la rotonda de la Columna [M]
- [x] Definir el mecanismo de 7 anillos de viento [C] — `TemploFlow.ANILLOS_TOTAL = 7` + array `anillos` en `templo_layout_diseno.json`
- [x] Definir 4 sellos de cristal de salas secretas [S] — `sello_cristal_1..4`; `validar_anti_exploit` verifica 7 recompensas únicas
- [x] Definir 3 sellos de habitaciones intermedias [S] — `sello_cristal_5..7` (h_luz_1, h_sonido, h_agua)
- [x] Definir activación de anillo con sello + posición de glifo (M24 símbolos) [M] — `TemploFlow.activar_anillo(indice, sello_id, glifo)` con rechazo por sello inexistente / ya colocado / glifo incorrecto; tests A/B
- [x] Definir estado de sala multipllex para los 7 anillos [M] — `TemploFlow.estado()` / `cargar_estado()` (round-trip verificado, test B)
- [ ] Documentar sala central y mecanismo [M]

## Puzzle final y cámara del Sello

- [ ] Diseñar el puzzle final en 3 fases [C]
- [ ] Definir fase 1: espejo maestro y rayo cenital (luz) [M]
- [ ] Definir fase 2: 3 gongs en el orden de glifos (sonido) [M]
- [x] Definir pista de la secuencia visible tras 2 intentos [S] — definida en `03-Diseno`; `TempleTelemetria.puzzles_dificiles(2)` expone el umbral para que M24 dispare la pista
- [ ] Definir fase 3: timón de agua y barca (agua) [M]
- [ ] Diseñar la Cámara del Sello (sancta) [M]
- [ ] Definir pedestal del Sello [S]
- [x] Definir cutscene contextual mínima (hook M33) [S] — señal `TemploFlow.sello_restaurado_ok` (hook, sin acoplar a M33)
- [x] Definir restauración del sello abre la salida [M] — `restaurar_sello()` + `intentar_abrir_salida()`; test B
- [ ] Documentar puzzle final y cámara del Sello [M]

## Salida y checkpoints

- [ ] Diseñar la salida (túnel del amanecer) [S]
- [ ] Definir atajo al puerto por la salida [S]
- [x] Definir apertura de salida solo con sello restaurado [M] — `validar_anti_exploit` exige `requiere == "sello_restaurado"` en la sala de salida; tests B/F
- [x] Diseñar 5 checkpoints (porte, vestíbulo, vientos, central, sello) [M] — `TemploCheckpoint.CP_IDS` + 5 salas con `checkpoint: true`; `validar_checkpoints` lo exige (test E)
- [x] Definir guardado atómico en cada checkpoint [M] — `TemploCheckpoint.guardar()` (tmp → rename → `.bak`); test C
- [x] Definir respaldo `.bak` en cada checkpoint [S] — `respaldo_existe()` / `cargar_con_respaldo()`; test C
- [ ] Documentar salida y checkpoints [S]

## Iluminación y sonido ambiental

- [ ] Diseñar faros de cristal por sala [M]
- [ ] Definir luz volumétrica suave "brisa" [M]
- [x] Definir contraste ≥ 4.5:1 en iconografía (M58) [M] — `templo_blueprint.json` → `accesibilidad.contraste_min = 4.5`; `validar_accesibilidad` (tests E/F)
- [ ] Diseñar sonido de brisa en corredores (M42) [S]
- [ ] Diseñar goteo de agua (M43) [S]
- [ ] Definir 3 ambiences por banda de dificultad (M41) [M]
- [ ] Documentar iluminación y sonido ambiental [S]

## Partículas, materiales y texturas

- [ ] Diseñar polvo de luz en la rotonda (M52) [S]
- [ ] Definir viento visible en corredores [S]
- [x] Definir límite de 256 partículas por escena [S] — `templo_blueprint.json` → `presupuesto.particulas_por_escena_max = 256`
- [ ] Definir paleta de materiales del templo (piedra de brisa, cristal, bronce) [M]
- [ ] Definir 3 materiales base + variantes por edad (M47) [M]
- [ ] Definir 12 texturas clave con LOD 0-2 (M47/M63) [M]
- [ ] Documentar partículas, materiales y texturas [S]

## Iconografía y arquitectura

- [?] Diseñar 8 glifos del Sello (4 comunes + 4 de cámara) [M] — el diseño pide 8 (4+4); `templo_layout_diseno.json` nombra 7 (uno por anillo). Falta el 8.º y la separación común/cámara
- [?] Definir glosario en la Guía del Templo (M24) [S] — la Guía del Templo es de M24 (no implementada en este repo)
- [x] Definir arquitectura voxel-compatible (corredores 4x4x4 m) [C] — `voxel.corredor` en el blueprint + `validar_voxel` (tests E/F)
- [x] Definir puertas de 2x3 bloques [S] — `voxel.puerta` + `validar_voxel`
- [x] Definir techos de 3x3 bloques [S] — `voxel.techo` + `validar_voxel`
- [x] Definir transiciones en 45° [S] — `voxel.transiciones_grados = 45` + `validar_voxel`
- [x] Definir rampas con pendiente ≤ 20° [S] — `voxel.rampa_grados_max = 20` + `validar_voxel` (test F: 30° se rechaza)
- [ ] Documentar iconografía y arquitectura [M]

## Navegación y telemetría

- [?] Crear navegación con NavigationServer3D por piso [M] — requiere el templo generado por M08 (voxel) + M61; no hay geometría que navegar todavía
- [x] Definir vínculos verticales (rampas y huecos discretos) [M] — `voxel.rampa_grados_max` + `voxel.barreras_en_huecos`; `validar_voxel` / `validar_anti_exploit`
- [x] Definir sin teleports en navegación (anti-exploit) [S] — `voxel.teleports = false` + `validar_anti_exploit` (test F: `true` se rechaza)
- [x] Crear telemetría de puzzles (intentos, pistas, tiempo) [M] — `TempleTelemetria` (reloj inyectable); test D
- [x] Definir exportación JSON a M24 para balance [M] — `TempleTelemetria.exportar_a_m24()` / `exportar_json()`; test D (round-trip idempotente)
- [ ] Documentar navegación y telemetría [S]

## Softlocks, exploits y orientación

- [x] Testear softlocks por zona (suite M66) [M] — `TemploValidadores.validar_softlock()`: alcanzabilidad desde la entrada, sin callejones sin salida, recompensas con 2+ caminos; tests E/F
- [x] Testear objetos y llaves perdidos [M] — sellos únicos: `TemploFlow.registrar_sello()` rechaza duplicados y `activar_anillo()` rechaza reutilizar un sello colocado; test B
- [?] Testear NPC atascados en el templo [M] — requiere NPCs de M19/M64 dentro del templo (no hay puestos de aparición implementados)
- [?] Testear puzzles irresolubles [M] — requiere el grafo emisor→receptor por puzzle de M24; `validar_softlock` solo comprueba que los puzzles referenciados existan
- [x] Testear exploits por acceleración en rampas [M] — `validar_voxel` rechaza rampas > 20° (test F)
- [x] Testear duplicación de sellos [M] — `validar_anti_exploit` rechaza recompensas duplicadas (test F) + `TemploFlow` (test B)
- [x] Testear entrada por la salida sellada [M] — `TemploFlow.intentar_abrir_salida()` falla sin sello restaurado (test B) + `requiere` en la sala de salida
- [x] Implementar mojones visuales cada 40 m [M] — `orientacion.mojon_metros_max = 40` + `validar_orientacion` (test F: 60 m se rechaza)
- [?] Implementar mapa de zona simplificado (panel M58) [M] — el panel es de M58; no hay artefacto. (El diseño y el validador existen, la UI no)
- [x] Definir prueba de deriva (jugador perdido < 2 min) [M] — `orientacion.deriva_max_s = 120` + `validar_orientacion`
- [ ] Documentar softlocks, exploits y orientación [M]

## Accesibilidad y rendimiento

- [x] Definir iconografía ≥ 16 px (M58) [S] — `accesibilidad.icono_px_min = 16` + `validar_accesibilidad` (test F)
- [x] Definir contraste ≥ 4.5:1 [M] — `accesibilidad.contraste_min = 4.5` + `validar_accesibilidad` (test F)
- [x] Definir sin presión temporal en puzzles [S] — `accesibilidad.presion_temporal = false` + `validar_accesibilidad` (test F)
- [x] Definir subtítulos activables (M43) [S] — `accesibilidad.subtitulos = true` + `validar_accesibilidad` (la UI de subtítulos es de M43)
- [x] Definir reducción de partículas y parpadeo (fotosensibilidad) [S] — `accesibilidad.reduccion_particulas` / `reduccion_parpadeo` + `validar_accesibilidad`
- [?] Definir presupuesto por región (M63, streaming por piso) [M] — el blueprint fija presupuesto de rotonda y de partículas, pero el streaming por región es de M63
- [?] Definir instancing de columnas en la rotonda [S] — no hay campo de instancing en el blueprint; depende de M61/M63
- [x] Definir luz volumétrica solo en 2 salas fijas [S] — `presupuesto.luz_volumetrica_salas = 2`
- [ ] Documentar accesibilidad y rendimiento [M]

## Testings y documentación

- [x] Diseñar 06-Plan-Testings.md: gating (sellos y salida) [M] — `06-Plan-Testings.md` CP-01..CP-06
- [x] Diseñar 06-Plan-Testings.md: anti-exploit (suite de saltos) [M] — CP-07..CP-12
- [x] Diseñar 06-Plan-Testings.md: orientación (deriva) [M] — CP-13..CP-16
- [x] Diseñar 06-Plan-Testings.md: softlocks por zona [M] — CP-17..CP-22
- [x] Diseñar 06-Plan-Testings.md: accesibilidad (contrastes) [M] — CP-23..CP-27
- [x] Definir criterio de éxito: suite completa pasa sin fallos [S] — `07-Resultados-Testings.md` (92/0 ×3, EXIT 0)
- [x] Crear 07-Resultados-Testings.md para registrar la ejecución [S] — creado en iter. 2
- [ ] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [x] Actualizar plan-actual como espejo del estado real [M] — `04-Codigo.md` reescrito con las rutas GDScript reales (el original describía rutas Unity/C# inexistentes)
- [x] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S] — `Logs/902-M26-Templo-Subterraneo-Iter2_2026-09-14.md`
- [x] Actualizar fila 26 en CHECKLIST-GLOBAL al implementar [S]

**Total:** `[x]` 50 · `[?]` 8 · `[ ]` 57 · total 115 (incluye el ítem de dependencia M154).
El módulo sigue 🟡: la lógica verificable está implementada y probada, pero la
geometría (M08), los assets (M45/M47/M52/M63), el audio (M41/M42/M43) y las
UI de M58 quedan pendientes de sus módulos.

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

## Iteración 1 — Layout data-driven (2026-09-02 06:10, deepseek-v4-flash-vision-exp / Kilo Code)

- [x] `data/templos/templo_subterraneo.json` — layout del templo: 4 salas (entrada→lago→cámaras→sello de la Raíz), 4 puzzles (asas, espejos de luz, pesos, secuencia de sellos) con emisor/receptor/recompensa, checkpoints (3) y guardián polilla de la Raíz (nivel 3)
- [x] `scripts/templos/templo_schema.gd` — TemploSchema: validación de layout (salas únicas/conectadas, puzzles con id único y emisor/receptor, checkpoint en la sala final, guardián en sala válida, recompensa presente)
- [x] Test headless: 4/4 checks OK (layout válido; detecta checkpoint faltante, puzzle sin receptor, salida inexistente)
- [?] Implementación de salas/puzzles en el mundo (M24/M25 framework + gen de ruinas) y la conexión de M160 — iter 2 (dueño: deepseek-v4-flash-vision-exp)

## Iteración 2 — Gating, checkpoints, telemetría y validadores (2026-09-14, DeepSeek-V4.1-Flash / WorkBuddy, Log 902)

- [x] `scripts/templos/templo_flow.gd` — `TemploFlow`: gating de los 7 anillos, sellos únicos, glifo por anillo, restauración del Sello y apertura de la salida (lógica pura, `RefCounted`)
- [x] `scripts/templos/templo_checkpoint.gd` — `TemploCheckpoint`: los 5 CP con guardado atómico (tmp → rename → `.bak`) y carga con respaldo
- [x] `scripts/templos/templo_telemetria.gd` — `TempleTelemetria`: intentos, pistas y tiempo por puzzle, con reloj inyectable y export JSON a M24
- [x] `scripts/templos/templo_validadores.gd` — `TemploValidadores`: suites de softlock, anti-exploit, voxel, accesibilidad, orientación y checkpoints
- [x] `data/templos/templo_blueprint.json` — metría voxel (4x4x4 m, puertas 2x3, techos 3x3, 45°, rampas ≤20°), accesibilidad, orientación, gating y presupuesto
- [x] `data/templos/templo_layout_diseno.json` — grafo del diseño `03-Diseno` en datos: 20 zonas, 24 conexiones, 17 puzzles, 7 anillos
- [x] `scripts/templos/test_templo_m26.gd` — suite headless de 7 bloques con marcadores `_fin()` (anti-falso-verde)
- [x] Test headless: **92 checks, 0 fallos, EXIT 0 ×3**, 0 `SCRIPT ERROR`
- [x] Bug de proyecto encontrado y corregido de paso: `scripts/backup/backup_manager.gd` (M107) no compilaba — `DirAccess.new()` sobre clase abstracta (BUG-035)
- [?] Calibración visual de las salas (luces, materiales, partículas): requiere Blender/Godot con vista y aprobación visual ajena (§15.3)
