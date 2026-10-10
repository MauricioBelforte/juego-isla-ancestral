# Log 1557 - M24 iter. 6: dificultad, tutorial, presion avanzada, simbolos, herramientas y recompensas

**Fecha:** 2026-10-09
**Hora:** 23:38
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Encargo:** mensaje 129 (atria-dawn, 2026-10-09 22:26) - M24 liberacion

## Resumen
Se implementaron 6 capas nuevas de M24 (iter. 6) con datos, clases y suites headless, cerrando
26 de los 27 items `[ ]` pendientes con evidencia MEDIDA. El item 103 (linea de audicion, hook M43)
queda BLOQUEADO por dependencia externa (no se fuerza). El `[?]` 144 (validacion en Editor,
EditorPlugin) queda como esta. El gate de regresion pasa de 13 a 19 suites (TOTAL_MINIMO 649 -> 910;
medido 910 == piso). Sin commits ni push.

## Items trabajados (con evidencia)
| Items | Capa | Evidencia |
|---|---|---|
| 10, 11, 13, 14 | Dificultad (bandas, zonas, ayuda progresiva) | `puzzle_dificultad.gd` + `dificultad.json` + `test_puzzle_dificultad.gd` 43/0 |
| 19, 20, 21, 22, 23 | Tutorializacion (guia, iconografia, narrador M33, visual-primero) | `puzzle_tutorial.gd` + `tutorial.json` + `test_puzzle_tutorial.gd` 39/0 |
| 77, 78, 79, 80 | Presion avanzada (elevadores, puertas encadenadas, sin fallo punitivo) | `puzzle_presion.gd` + `presion_03/04.json` + `test_puzzle_presion.gd` 43/0 |
| 111, 112, 113, 117 | Simbolos (glifos M25, glosario, sello por pareja) | `puzzle_simbolos.gd` + `simbolos_01/02.json` + `test_puzzle_simbolos.gd` 47/0 |
| 121, 122, 123, 124 | Herramientas (pico/gancho/farol + inventario) | `puzzle_herramientas.gd` + `herramientas_01/02.json` + `test_puzzle_herramientas.gd` 45/0 |
| 151 | Documentar anti-arbitrariedad / anti-ambiguedad / metricas | seccion nueva en `03-Diseno.md` |
| 157, 162, 163, 164 | Checkpoints + recompensas (atomico, unicas M66, lore) | `puzzle_recompensas.gd` + `recompensas_01/02.json` + `test_puzzle_recompensas.gd` 44/0 |

Total: 26 items cerrados con evidencia (4+5+4+4+4+1+4 = 26).

## Item 103 (BLOQUEADO, honesto)
"Definir linea de audicion clara como condicion (M43 hook)" sigue `[ ]`: `scripts/audio/` NO expone
"linea de audicion" (0 hits medidos). No se fuerza (condicion 2 del plan iter. 5). Queda para el
dueno de M43. NO lo marco `[?]`: no es una duda de cierre, es una dependencia externa ya reportada.

## Evidencia de ejecucion (MEDIDA, no heredada)
Las 6 suites nuevas en verde, con piso MEDIDO (ajustado tras medir, nunca estimado):
- dificultad 43/0, tutorial 39/0, presion 43/0, simbolos 47/0, herramientas 45/0, recompensas 44/0.
- 0 SCRIPT ERROR y EXIT 0 en las 6.
Gate de regresion: 19 suites, 106 checks, 0 fallos, EXIT 0; total MEDIDO 910 == piso 910.

## Sondas rojas (EN VIVO)
- Gate con JSON real mutado: `presion_03.json` (`niveles` 2 -> 0) -> gate EXIT 1 con
  `test_puzzle_presion` nombrado (EXIT=1, 5 fallos). JSON restaurado byte-exacto (sha256 9f36f609...).
- Guardian probado EN ROJO: bloque fantasma "G" en `test_puzzle_presion.gd` -> el resumen NOMBRO
  "el bloque G NO se ejecuto" y salio EXIT 1; revertido a verde (43/0).
- Cada suite tiene su propio bloque de sonda roja sobre copias mutadas (no toca el JSON real).

## Anclas reales verificadas (no inventadas)
- M66: `scripts/core/recovery/cofre_recuperacion.gd` (depositar / entregar / fue_entregada).
- M33: `scripts/dialogos/dialogue_manager.gd` `start_dialogue(dialogue_id, context) -> bool`.
- M26: `scripts/templos/templo_checkpoint.gd` (guardado atomico tmp -> bak -> rename).
- M15/M160: `scripts/inventario/inventario_service.gd` `count_item(item_id, include_house)`.
- M60: `scripts/datos/catalogos_estaticos.gd` `tiene_item(id)`.
- M25: contrato de glifos DOCUMENTADO en `DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md`
  (`{id, simbolos: Array[String], significado: String}`); el catalogo `data/ruinas/glifos.json`
  NO existe aun -> no se invento.

## IDs de item MEDIDOS (sonda headless)
`tiene_item("item_obj_her_002")=true` (Pico de hierro), `tiene_item("item_obj_luz_005")=true`
(Farol), `tiene_item("OBJ-HER-002")=false`. El indice de `CatalogosEstaticos` indexa por NOMBRE DE
ARCHIVO, no por el id declarado en el `.tres`. Los datos usan los ids medidos.

## Residuales honestos (reportados, NO inflados a [x])
1. Item 122 "uso de gancho": el USO y su condicion de inventario estan definidos y probados, pero el
   catalogo NO tiene item "gancho" -> ese uso queda bloqueado; `residuales()` lo nombra. El item del
   checklist (definir el uso) SI se cierra; el residuo es del catalogo de items (otro modulo).
2. M25: el glosario del templo se define contra el contrato DOCUMENTADO; `data/ruinas/glifos.json`
   no existe aun (M25).
3. Colision de pool AJENA: hay DOS archivos `Logs/1547-*` (`1547-bug103-...` y `1547-m53-...`).
   Reportado, no tocado.

## Higiene
- Nuevos: 6 clases `.gd`, 6 suites `.gd`, 10 JSON de datos, 18 `.uid`. NINGUNA modificacion al
  framework (`puzzle_room.gd`, `puzzle_def.gd`, etc. intactos).
- Docs M24 actualizadas (CRLF puro, sin BOM): 02-Analisis, 03-Diseno, 04-Codigo, 06-Plan-Testings,
  07-Resultados-Testings.
- Sin commits ni push (no autorizado). `CHECKLIST-GLOBAL.md` y `quality.yml` NO tocados.
- Marcas del `05-Checklist.md`: READ-ONLY (reporto; el director flipea).
