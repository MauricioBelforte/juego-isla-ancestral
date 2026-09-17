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

## Notas QA (sin sello limpio §21.8)

| MID | Módulo | Log | Motivo |
|-----|--------|-----|--------|
| 87 | Localizacion | 883 | `test_localizacion_m87.gd` falla por aserciones obsoletas → BUG-032, delegado a DeepSeek-V4.1-Flash |
| 111 | Codigo-De-Calidad | 886 | 35 `[ ]` reales en 05-Checklist (sobre-cierre) → sin sello; delegado a otro modelo |
| 127 | Copyright-Del-Juego | 883 | `test_copyright_m127.gd` falla por aserciones obsoletas → BUG-033, delegado a DeepSeek-V4.1-Flash |
| 148 | Lore-Ambiental | 886 | 92 `[ ]` reales (data-only) → sin sello; delegado a modelo de creatividad (§11.3) |

**Total sellos limpios:** 20 · **Notas:** 4 · **Re-verif. headless 2026-09-14:** 14/14 PASS · **+ M26 (2026-09-16, Log 930) + BUG-035/039 (2026-09-16, Log 931) + M105 re-verif. iter.7 (2026-09-16, Log 935) + M124 re-verif. iter.2 (2026-09-16, Log 936) + M60 re-verif. iter.4 (2026-09-16, Log 937) + M103 re-verif. iter.1 (2026-09-16, Log 938) = 20/20.** (M105 ya contaba en el total del Lote G/I; se actualiza su evidencia al estado iter.7).
