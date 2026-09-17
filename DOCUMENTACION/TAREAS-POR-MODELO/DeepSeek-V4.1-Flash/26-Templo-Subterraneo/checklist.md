**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

**Módulo:** 26-Templo-Subterraneo (26)

# Checklist personal tareas — 26-Templo-Subterraneo

> Extraídas del `05-Checklist.md` del módulo. Iter. 2 (Log 902): `[x]` 53 · `[?]` 9 · `[ ]` 57 de 119 ítems. Fuente de verdad del ítem: el `05-Checklist.md`. Fuente de verdad del ítem: el `05-Checklist.md`.

## Tareas

- [ ] T-001 Diseñar la entrada del templo (pórtico bajo raíces, puerta sellada) [M]
- [ ] T-002 Definir respiradero de brisa visible en la entrada [S]
- [ ] T-003 Diseñar el vestíbulo con 3 vías de orientación [M]
- [ ] T-004 Definir plaza de desembarque de la entrada [S]
- [ ] T-005 Definir primera vía al templo (núcleo) [S]
- [ ] T-006 Definir vía a la Guarda de la Brisa [S]
- [ ] T-007 Documentar entrada y vestíbulo en el plan-actual [S]
- [ ] T-008 Diseñar "Sala de los Vientos" con 3 puzzles de viento [M]
- [ ] T-009 Definir el tutorial guiado (panel Guía del Templo) [M]
- [ ] T-010 Definir 1 puzzle guiado paso a paso [M]
- [ ] T-011 Definir banda de dificultad Exploración en la sala inicial [S]
- [ ] T-012 Definir acceso al pasillo del Artesano desde la sala [S]
- [ ] T-013 Documentar primera sala y tutorial [S]
- [ ] T-014 Diseñar 6 habitaciones intermedias [M]
- [ ] T-015 Definir 2 salas de luz (M24) [S]
- [ ] T-016 Definir 1 sala de agua [S]
- [ ] T-017 Definir 1 sala de presión [S]
- [ ] T-018 Definir 1 sala de sonido [S]
- [ ] T-019 Definir 1 sala de secuencia [S]
- [ ] T-020 Diseñar el pasillo del Artesano (alternativa lateral) [M]
- [ ] T-021 Definir 1 puzzle de herramientas en el pasillo [S]
- [x] T-022 Definir 2+ caminos para cada rama (M66) [M] — iter. 2 (Log 902): validar_softlock exige >=2 caminos en zonas con recompensa; tests E/F
- [ ] T-023 Documentar habitaciones y caminos alternativos [S]
- [ ] T-024 Diseñar 4 salas secretas [M]
- [ ] T-025 Definir sala bajo placa de presión [S]
- [ ] T-026 Definir sala tras puerta falsa [S]
- [ ] T-027 Definir sala tras mural giratorio [S]
- [ ] T-028 Definir sala bajo el acuífero [S]
- [x] T-029 Definir 2+ caminos de acceso a cada sala [M] — iter. 2 (Log 902): las 4 secretas tienen 2 conexiones; validar_softlock
- [x] T-030 Definir recompensas únicas (sellos de cristal) en las salas [S] — iter. 2 (Log 902): sello_cristal_1..4; validar_anti_exploit rechaza recompensas duplicadas
- [ ] T-031 Documentar salas secretas [S]
- [ ] T-032 Diseñar la rotonda de la Columna [M]
- [x] T-033 Definir el mecanismo de 7 anillos de viento [C] — iter. 2 (Log 902): TemploFlow.ANILLOS_TOTAL=7 + array anillos en el JSON
- [x] T-034 Definir 4 sellos de cristal de salas secretas [S] — iter. 2 (Log 902): sello_cristal_1..4 + validar_anti_exploit
- [x] T-035 Definir 3 sellos de habitaciones intermedias [S] — iter. 2 (Log 902): sello_cristal_5..7 (h_luz_1, h_sonido, h_agua)
- [x] T-036 Definir activación de anillo con sello + posición de glifo (M24 símbolos) [M] — iter. 2 (Log 902): TemploFlow.activar_anillo(indice, sello_id, glifo); tests A/B
- [x] T-037 Definir estado de sala multipllex para los 7 anillos [M] — iter. 2 (Log 902): TemploFlow.estado()/cargar_estado() round-trip; test B
- [ ] T-038 Documentar sala central y mecanismo [M]
- [ ] T-039 Diseñar el puzzle final en 3 fases [C]
- [ ] T-040 Definir fase 1: espejo maestro y rayo cenital (luz) [M]
- [ ] T-041 Definir fase 2: 3 gongs en el orden de glifos (sonido) [M]
- [x] T-042 Definir pista de la secuencia visible tras 2 intentos [S] — iter. 2 (Log 902): definido en 03-Diseno; TempleTelemetria.puzzles_dificiles(2) expone el umbral
- [ ] T-043 Definir fase 3: timón de agua y barca (agua) [M]
- [ ] T-044 Diseñar la Cámara del Sello (sancta) [M]
- [ ] T-045 Definir pedestal del Sello [S]
- [x] T-046 Definir cutscene contextual mínima (hook M33) [S] — iter. 2 (Log 902): senal TemploFlow.sello_restaurado_ok (hook, sin acoplar a M33)
- [x] T-047 Definir restauración del sello abre la salida [M] — iter. 2 (Log 902): restaurar_sello() + intentar_abrir_salida(); test B
- [ ] T-048 Documentar puzzle final y cámara del Sello [M]
- [ ] T-049 Diseñar la salida (túnel del amanecer) [S]
- [ ] T-050 Definir atajo al puerto por la salida [S]
- [x] T-051 Definir apertura de salida solo con sello restaurado [M] — iter. 2 (Log 902): validar_anti_exploit exige requiere=="sello_restaurado"; tests B/F
- [x] T-052 Diseñar 5 checkpoints (porte, vestíbulo, vientos, central, sello) [M] — iter. 2 (Log 902): TemploCheckpoint.CP_IDS + 5 salas con checkpoint:true; validar_checkpoints
- [x] T-053 Definir guardado atómico en cada checkpoint [M] — iter. 2 (Log 902): TemploCheckpoint.guardar() atomico (tmp -> rename -> .bak); test C
- [x] T-054 Definir respaldo `.bak` en cada checkpoint [S] — iter. 2 (Log 902): respaldo_existe()/cargar_con_respaldo(); test C
- [ ] T-055 Documentar salida y checkpoints [S]
- [ ] T-056 Diseñar faros de cristal por sala [M]
- [ ] T-057 Definir luz volumétrica suave "brisa" [M]
- [x] T-058 Definir contraste ≥ 4.5:1 en iconografía (M58) [M] — iter. 2 (Log 902): blueprint accesibilidad.contraste_min=4.5 + validar_accesibilidad
- [ ] T-059 Diseñar sonido de brisa en corredores (M42) [S]
- [ ] T-060 Diseñar goteo de agua (M43) [S]
- [ ] T-061 Definir 3 ambiences por banda de dificultad (M41) [M]
- [ ] T-062 Documentar iluminación y sonido ambiental [S]
- [ ] T-063 Diseñar polvo de luz en la rotonda (M52) [S]
- [ ] T-064 Definir viento visible en corredores [S]
- [x] T-065 Definir límite de 256 partículas por escena [S] — iter. 2 (Log 902): blueprint presupuesto.particulas_por_escena_max=256
- [ ] T-066 Definir paleta de materiales del templo (piedra de brisa, cristal, bronce) [M]
- [ ] T-067 Definir 3 materiales base + variantes por edad (M47) [M]
- [ ] T-068 Definir 12 texturas clave con LOD 0-2 (M47/M63) [M]
- [ ] T-069 Documentar partículas, materiales y texturas [S]
- [?] T-070 Diseñar 8 glifos del Sello (4 comunes + 4 de cámara) [M] — iter. 2 (Log 902): el diseno pide 8 (4+4); el grafo de iter. 2 nombra 7 (uno por anillo)
- [?] T-071 Definir glosario en la Guía del Templo (M24) [S] — iter. 2 (Log 902): la Guia del Templo es de M24 (no implementada)
- [x] T-072 Definir arquitectura voxel-compatible (corredores 4x4x4 m) [C] — iter. 2 (Log 902): blueprint voxel.corredor 4x4x4 + validar_voxel; tests E/F
- [x] T-073 Definir puertas de 2x3 bloques [S] — iter. 2 (Log 902): blueprint voxel.puerta 2x3 + validar_voxel
- [x] T-074 Definir techos de 3x3 bloques [S] — iter. 2 (Log 902): blueprint voxel.techo 3x3 + validar_voxel
- [x] T-075 Definir transiciones en 45° [S] — iter. 2 (Log 902): blueprint voxel.transiciones_grados=45 + validar_voxel
- [x] T-076 Definir rampas con pendiente ≤ 20° [S] — iter. 2 (Log 902): blueprint voxel.rampa_grados_max=20 + validar_voxel (test F: 30 se rechaza)
- [ ] T-077 Documentar iconografía y arquitectura [M]
- [?] T-078 Crear navegación con NavigationServer3D por piso [M] — iter. 2 (Log 902): requiere el templo generado por M08 (voxel) + M61: no hay geometria que navegar
- [x] T-079 Definir vínculos verticales (rampas y huecos discretos) [M] — iter. 2 (Log 902): blueprint rampa<=20 + barreras_en_huecos; validar_voxel/anti_exploit
- [x] T-080 Definir sin teleports en navegación (anti-exploit) [S] — iter. 2 (Log 902): blueprint voxel.teleports=false + validar_anti_exploit (test F)
- [x] T-081 Crear telemetría de puzzles (intentos, pistas, tiempo) [M] — iter. 2 (Log 902): TempleTelemetria (reloj inyectable); test D
- [x] T-082 Definir exportación JSON a M24 para balance [M]
- [ ] T-083 Documentar navegación y telemetría [S]
- [x] T-084 Testear softlocks por zona (suite M66) [M] — iter. 2 (Log 902): TemploValidadores.validar_softlock(); tests E/F
- [x] T-085 Testear objetos y llaves perdidos [M] — iter. 2 (Log 902): sellos unicos: registrar_sello rechaza duplicados, activar_anillo rechaza reuso; test B
- [?] T-086 Testear NPC atascados en el templo [M] — iter. 2 (Log 902): requiere NPCs de M19/M64 con puestos de aparicion en el templo
- [?] T-087 Testear puzzles irresolubles [M] — iter. 2 (Log 902): requiere el grafo emisor->receptor por puzzle de M24
- [x] T-088 Testear exploits por acceleración en rampas [M] — iter. 2 (Log 902): validar_voxel rechaza rampas >20 (test F)
- [x] T-089 Testear duplicación de sellos [M] — iter. 2 (Log 902): validar_anti_exploit (test F) + TemploFlow (test B)
- [x] T-090 Testear entrada por la salida sellada [M] — iter. 2 (Log 902): TemploFlow.intentar_abrir_salida() falla sin sello restaurado (test B)
- [x] T-091 Implementar mojones visuales cada 40 m [M]
- [?] T-092 Implementar mapa de zona simplificado (panel M58) [M] — iter. 2 (Log 902): CORREGIDO: estaba [x] sin artefacto. El panel es de M58; el validador existe, la UI no
- [x] T-093 Definir prueba de deriva (jugador perdido < 2 min) [M] — iter. 2 (Log 902): blueprint orientacion.deriva_max_s=120 + validar_orientacion
- [ ] T-094 Documentar softlocks, exploits y orientación [M]
- [x] T-095 Definir iconografía ≥ 16 px (M58) [S] — iter. 2 (Log 902): blueprint accesibilidad.icono_px_min=16 + validar_accesibilidad (test F)
- [x] T-096 Definir contraste ≥ 4.5:1 [M] — iter. 2 (Log 902): blueprint contraste_min=4.5 + validar_accesibilidad (test F)
- [x] T-097 Definir sin presión temporal en puzzles [S] — iter. 2 (Log 902): blueprint presion_temporal=false + validar_accesibilidad (test F)
- [x] T-098 Definir subtítulos activables (M43) [S] — iter. 2 (Log 902): blueprint subtitulos=true + validar_accesibilidad (la UI es de M43)
- [x] T-099 Definir reducción de partículas y parpadeo (fotosensibilidad) [S] — iter. 2 (Log 902): blueprint reduccion_particulas/reduccion_parpadeo + validar_accesibilidad
- [?] T-100 Definir presupuesto por región (M63, streaming por piso) [M] — iter. 2 (Log 902): el blueprint fija presupuesto de rotonda y particulas; el streaming por region es de M63
- [?] T-101 Definir instancing de columnas en la rotonda [S] — iter. 2 (Log 902): no hay campo de instancing en el blueprint; depende de M61/M63
- [x] T-102 Definir luz volumétrica solo en 2 salas fijas [S] — iter. 2 (Log 902): blueprint presupuesto.luz_volumetrica_salas=2
- [ ] T-103 Documentar accesibilidad y rendimiento [M]
- [x] T-104 Diseñar 06-Plan-Testings.md: gating (sellos y salida) [M] — iter. 2 (Log 902): 06-Plan-Testings.md CP-01..CP-06
- [x] T-105 Diseñar 06-Plan-Testings.md: anti-exploit (suite de saltos) [M] — iter. 2 (Log 902): 06-Plan-Testings.md CP-07..CP-12
- [x] T-106 Diseñar 06-Plan-Testings.md: orientación (deriva) [M] — iter. 2 (Log 902): 06-Plan-Testings.md CP-13..CP-16
- [x] T-107 Diseñar 06-Plan-Testings.md: softlocks por zona [M] — iter. 2 (Log 902): 06-Plan-Testings.md CP-17..CP-22
- [x] T-108 Diseñar 06-Plan-Testings.md: accesibilidad (contrastes) [M] — iter. 2 (Log 902): 06-Plan-Testings.md CP-23..CP-27
- [x] T-109 Definir criterio de éxito: suite completa pasa sin fallos [S] — iter. 2 (Log 902): 07-Resultados-Testings.md: 92/0 x3, EXIT 0
- [x] T-110 Crear 07-Resultados-Testings.md para registrar la ejecución [S] — iter. 2 (Log 902): creado en iter. 2
- [ ] T-111 Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [x] T-112 Actualizar plan-actual como espejo del estado real [M] — iter. 2 (Log 902): 04-Codigo.md reescrito con las rutas GDScript reales
- [x] T-113 Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S] — iter. 2 (Log 902): Logs/902-M26-Templo-Subterraneo-Iter2_2026-09-14.md
- [x] T-114 Actualizar fila 26 en CHECKLIST-GLOBAL al implementar [S]
- [x] T-115 Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
- [x] T-116 `data/templos/templo_subterraneo.json` — layout del templo: 4 salas (entrada→lago→cámaras→sello de la Raíz), 4 puzzles (asas, espejos de luz, pesos, secuencia de sellos) con emisor/receptor/recompensa, checkpoints (3) y guardián polilla de la Raíz (nivel 3)
- [x] T-117 `scripts/templos/templo_schema.gd` — TemploSchema: validación de layout (salas únicas/conectadas, puzzles con id único y emisor/receptor, checkpoint en la sala final, guardián en sala válida, recompensa presente)
- [x] T-118 Test headless: 4/4 checks OK (layout válido; detecta checkpoint faltante, puzzle sin receptor, salida inexistente)
- [?] T-119 Implementación de salas/puzzles en el mundo (M24/M25 framework + gen de ruinas) y la conexión de M160 — iter 2 (dueño: deepseek-v4-flash-vision-exp)

## Iteración 2 — Gating, checkpoints, telemetría y validadores (2026-09-14, DeepSeek-V4.1-Flash / WorkBuddy, Log 902)

- `scripts/templos/templo_flow.gd` — `TemploFlow`: 7 anillos, sellos únicos, glifo por anillo, restauración del Sello y salida sellada.
- `scripts/templos/templo_checkpoint.gd` — `TemploCheckpoint`: 5 CP con guardado atómico (tmp → rename → `.bak`) y carga con respaldo.
- `scripts/templos/templo_telemetria.gd` — `TempleTelemetria`: intentos/pistas/tiempo + export JSON a M24.
- `scripts/templos/templo_validadores.gd` — `TemploValidadores`: softlock, anti-exploit, voxel, accesibilidad, orientación, checkpoints.
- `data/templos/templo_blueprint.json` y `data/templos/templo_layout_diseno.json` (20 zonas, 24 conexiones).
- `scripts/templos/test_templo_m26.gd` — **92 checks, 0 fallos, EXIT 0 ×3**, 0 `SCRIPT ERROR`.
- De paso: el autoload `BackupManager` (M107) no compilaba (`DirAccess.new()` sobre clase abstracta) y ensuciaba toda corrida headless — corregido (BUG-035).
