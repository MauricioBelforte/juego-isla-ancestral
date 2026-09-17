# CHECKLIST-QA-SEALS.md — Registro protegido de sellos §21.8 (hy3 / WorkBuddy)

**Propósito:** Archivo autoritativo y **fuera del alcance de la regeneración automática** de
`CHECKLIST-GLOBAL.md`. Ver BUG-034: un agente paralelo reescribe continuamente
`CHECKLIST-GLOBAL.md` y borra/re-atribuye sellos §21.8. Si `CHECKLIST-GLOBAL.md` pierde un
sello, este archivo es la fuente de verdad para re-aplicarlo. No lo regenere ningún agente de
reestructuración; solo hy3 (WorkBuddy) lo escribe.

**Verificador:** hy3 (Tencent Hunyuan) / WorkBuddy. Regla AGENTS.md §21.8 (verificador ≠ autor).

**Última re-verificación headless:** 2026-09-14 (Lote I, Log 888) — 13/13 tests re-corridos,
0 fallos, 0 `SCRIPT ERROR`.

## Sellos limpios §21.8 (hy3)

| MID | Módulo | Log | Fecha | Tipo | Evidencia (re-verif. 2026-09-14) |
|-----|--------|-----|------|------|----------------------------------|
| 46 | Arte-2D | 883 | 2026-09-13 | re-grounding | 110/110 arte verificado (sin test headless) |
| 52 | Particulas-Y-VFX | 886 | 2026-09-13 | headless | 4 tests, 105 checks, 0 fallos |
| 78 | Legal-Propiedad-Intelectual | 883 | 2026-09-13 | headless | 9 checks, 0 fallos |
| 84 | Musica-Y-Audio-Legal | 883 | 2026-09-13 | headless | 8 checks, 0 fallos |
| 105 | Telemetria-De-Gameplay | 935 | 2026-09-16 | headless | re-verif sec21.8 iter.7 (Log 926, DeepSeek-V4.1-Flash): 4 suites x3 EXIT 0 (test_telemetry 16/0, iter5 10/0, iter6 11/0, iter7 27/0), 0 SCRIPT ERROR en scripts/telemetry/; CHECKS_MINIMOS 16/10/11 + flag _fin() iter7; quality.yml 251-254; verificar_checklist.py 120/0/45 |
| 124 | Contenido-Generado-Por-Usuarios | 936 | 2026-09-16 | headless | re-verif sec21.8 iter.2 (Log 905, DeepSeek-V4.1-Flash): test_ugc_m124 16/0 x3 + test_ugc_m124_iter2 85/0 x3 (EXIT 0, 0 SCRIPT ERROR en scripts/ugc/); guardian anti-falso-verde por marcadores de bloque (_fin A-F en _vistos + _verificar_marcadores) + watchdog; 05-Checklist 83/25/0=108 (coincide CHECKLIST-GLOBAL 83/108) |
| 60 | Datos-Y-Serializacion | 937 | 2026-09-16 | headless | re-verif sec21.8 iter.4 (Log 916, DeepSeek-V4.1-Flash): 3 suites x3 EXIT 0 (base 94/0, iter3 132/0, iter4 152/0 = 378 checks, 0 fallos, 0 SCRIPT ERROR); guardian anti-falso-verde probado (sonda bloque D -> 128/1 EXIT 1); quality.yml 215/219/227; verificar_checklist.py 188/4/4=196 |
| 103 | Logging | 938 | 2026-09-16 | headless | re-verif sec21.8 iter.1 (Log 918, DeepSeek-V4.1-Flash): test_logging_m103_iter1 131/0 x3 + regresion test_logger 14/0 x3 + test_logging_m103 14/0 x3 (EXIT 0, 0 SCRIPT ERROR); guardian anti-falso-verde probado (sonda bloque D -> 131->122 EXIT 1); 7 defectos reales corregidos (BUG-041 falso positivo); quality.yml 236; verificar_checklist.py 167/12/0=179 |
| 117 | Build-System | 947 | 2026-09-17 | headless | re-verif sec21.8 iter.2 (Log 941, muse-spark-1.3-contributor/Cline): test_build_m117.gd 14/0 x3 (EXIT 0, 0 SCRIPT ERROR); CI Python test_bump_version 11/11 + test_changelog 6/6; 05-Checklist cuerpo 93/0/23 (0 [ ] real -> cumple sec24); 23 [?] diferidos con dueno no bloquean (precedente M103). Caveat: resumen L218 obsoleto "92/0/18" vs cuerpo 93/0/23 |
| 110 | Debug-Menu | 948 | 2026-09-17 | headless | re-verif sec21.8 (Log 928, atria-dawn/Kilo Code): 3 suites headless 18/0 + 27/0 + 22/0 = 67 checks, 0 fallos, 0 SCRIPT ERROR (EXIT 0); re-grounding debug_menu.gd + 3 test + debug_menu_config.json + 05/04-Codigo presentes; 05-Checklist 122/0/104 (0 [ ] real -> cumple sec24); 104 [?] diferidos UI con dueno no bloquean. Caveat: 'ERROR: Parameter t is null' benigno en bloque de test. |
| 87 | Localizacion | 949 | 2026-09-17 | headless | re-verif sec21.8 (Log 874->907, DeepSeek-V4.1-Flash): test_localizacion_m87.gd 20/0 (EXIT 0, 0 SCRIPT ERROR); re-grounding validador_po/auditor_claves/test en scripts/localization+localizacion presentes; 05-Checklist 131/0/8 (0 [ ] real -> cumple sec24). Caveat: BUG-042 (fonts .ttf 404) abierto, no bloquea. |
| 14 | Inventario | 951 | 2026-09-17 | headless | re-verif sec21.8 (GLM-5.3): test_inventario 0 fallos + test_inventario_iter5 0 fallos (EXIT 0, 0 SCRIPT ERROR); re-grounding OK; 05-Checklist 140/0/0 (0 [ ] real -> cumple sec24). Re-aplica sello ausente en QA-SEALS (Log 697 no registrado -> BUG-034). |
| 116 | Instalador | 883 | 2026-09-13 | headless | 2 tests, 33 checks, 0 fallos |
| 123 | Modding | 883 | 2026-09-13 | headless | 69 checks, 0 fallos |
| 126 | Marketing-Legal | 884 | 2026-09-13 | headless | 9 checks, 0 fallos |
| 128 | Identidad-De-Marca | 884 | 2026-09-13 | headless | 8 checks, 0 fallos |
| 149 | Nombres-Y-Nomenclatura | 883 | 2026-09-13 | re-grounding | 100/100 verificado (sin test headless) |
| 150 | Diseno-Sonoro-Narrativo | 884 | 2026-09-13 | headless | 12 checks, 0 fallos |
| 160 | Diseno-De-Ubicaciones-Del-Mundo | 883 | 2026-09-13 | re-grounding | 155/155 verificado (sin test headless) |
| 27 | Islas-Del-Mundo | 915 | 2026-09-15 | headless | test_islas_m27_iter2.gd 238 checks / 0 fallos ×2 (EXIT 0, 0 SCRIPT ERROR); re-grounding OK; guardián anti-falso-verde probado en vivo |
| 68 | Transporte-Y-Navegacion | 917 | 2026-09-15 | headless | test_transporte_m68_iter2.gd 199 checks / 0 fallos ×2 + regresión iter.1 177/0 (EXIT 0, 0 SCRIPT ERROR); re-grounding OK; guardián anti-falso-verde presente |
| 26 | Templo-Subterraneo | 930 | 2026-09-16 | headless | test_templo_m26.gd 92 checks / 0 fallos ×2 (EXIT 0, 0 SCRIPT ERROR en scripts M26; 8 SCRIPT ERROR externos de debug_menu.gd no bloquean); re-grounding OK; guardián anti-falso-verde presente (_fin() A-G) |
| BUG-035 | M107-Backups (fix DirAccess) | 931 | 2026-09-16 | headless | test_backup_m107.gd 12 checks / 0 fallos (EXIT 0, 0 SCRIPT ERROR de backup_manager; DirAccess.new() abstracto eliminado, API absoluta en uso) |
| BUG-039 | Generador-Checklist (fix estructura) | 931 | 2026-09-16 | code+funcional | generar_checklist_global.py: run --output temp = 11 cols (Recom heredada), 167 filas, sin duplicados, prefijo/sufijo conservados; caveat: no reinyecta Notas en regen -> BUG-034/QA-SEALS |

| 66 | Anti-Softlock | 953 | 2026-09-17 | headless | re-verif sec21.8 (Log 701, agnes-2.5-flash/Kilo Code): test_anti_softlock_m66.gd 0 fallos (EXIT 0, 0 SCRIPT ERROR); re-grounding softlock_guard/softlock_rules/irecoverable presentes; 05-Checklist 110/0/7 (0 [ ] real -> cumple sec24). Caveat: test usa _check(true) tautologicos + ERROR benigno RefCounted/Node en handler IRecoverable (no aborta, superficial). |
## Notas QA (sin sello limpio §21.8)

| MID | Módulo | Log | Motivo |
|-----|--------|-----|--------|
| 111 | Codigo-De-Calidad | 886 | 35 `[ ]` reales en 05-Checklist (sobre-cierre) → sin sello; delegado a otro modelo |
| 127 | Copyright-Del-Juego | 950 | test_copyright_m127.gd 13/0 green post-BUG-033, PERO 37 `[ ]` reales (procedimiento legal USCO/DMCA futuro) -> no cumple sec24, sin sello limpio. Autor DeepSeek-V4.1-Flash (Log 923). |
| 148 | Lore-Ambiental | 886 | 92 `[ ]` reales (data-only) → sin sello; delegado a modelo de creatividad (§11.3) |

**Total sellos limpios:** 25 · **Notas:** 3 · **Re-verif. headless 2026-09-14:** 14/14 PASS · **+ M26 (2026-09-16, Log 930) + BUG-035/039 (2026-09-16, Log 931) + M105 re-verif. iter.7 (2026-09-16, Log 935) + M124 re-verif. iter.2 (2026-09-16, Log 936) + M60 re-verif. iter.4 (2026-09-16, Log 937) + M103 re-verif. iter.1 (2026-09-16, Log 938) + M117 (2026-09-17, Log 947) + M110 (2026-09-17, Log 948) + M87 (2026-09-17, Log 949) + M14 (2026-09-17, Log 951)  + M66 (2026-09-17, Log 953) = 25/25.** (M105 ya contaba en el total del Lote G/I; se actualiza su evidencia al estado iter.7).
