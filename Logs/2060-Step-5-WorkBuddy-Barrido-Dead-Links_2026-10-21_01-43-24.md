# Log 2060 - Step-5-WorkBuddy - Item 59: barrido de citas dead-links (logs/archivos inexistentes en Notas)

- **Agente:** Step-5-WorkBuddy
- **Modulo:** GLOBAL (barrido multi-modulo)
- **Fecha:** 2026-10-21 01:44 (GMT-3)
- **Log nro:** 2060 (reservado con `scripts/reservar_log.py --reservar`; cabeza medida JUSTO antes = 2060 = max en disco 2059 + 1; lock atomico, sin colision)
- **Mensaje al director:** 127

## Encargo

Item 59 del BACKLOG-MASTER (COLA ACTIVA): "Barrido de citas dead-links (logs/archivos inexistentes en Notas)". Metodologia V2: RAMA 1 (msg 126 del director = acuse puro de 125 + colision de numeracion, sin trabajo nuevo) -> RAMA 2.

## Mediciones

### A. Auditor del repo (scripts/auditar_referencias.py, leido antes de correr, modo informe)

- 1985 logs indexados; rotas = 118, ambiguas = 79, menciones "Log NNN" sin log = 91.
- 118 rotas: 117 con candidato unico de reparacion (mayoria PATRONES wildcard: Logs/NNNN-* en 08-GUIA-ORDEN-DE-IMPLEMENTACION y Logs/13xx-BLOQUEX-... en BACKLOGs de agnes-3-flash; NO son dead-links reales, son plantillas). 1 rota REAL sin candidato: `Logs/9*agnes*M107*` en atria-dawn/107-Backups-QA/checklist.md.
- Sin `--fix`: nada reparado (documentos ajenos, sin autorizacion).

### B. Barrido estricto de las Notas del GLOBAL vivo (CHECKLIST-GLOBAL.md)

- Script propio `.workbuddy-ai/tmp/item59_global2.py`: OK con ruta 29 | OK por basename (existe en otra ubicacion) 251 | solo en Obsoletos/PAPELERA 22 | AUSENTES 33.
- Version NAIVE descartada: contaba "21.8"/"V2.5"/"agnes-2.5" como rutas -> fabricaba 960 falsas rotas.
- De los 33 AUSENTES, verificados linea por linea contra disco (regla de 3 patas):
  - ~24 ausencias HONESTAS documentadas (KnownIssues): DiagnosticExporter.gd (M110), perf_base.json (M113), update_checker.gd/save_migrator.gd/game_version.gd (M119), tool.gd (M13), playtest_runner.gd (M137), theme_ux.tres (M53), validate_vfx.gd (M52), validate_collectibles.gd (M73), net_contract.json (M77), privacy_menu.gd/privacy_consent.gd (M80), model_legal_manager.gd + model_license_validator.gd + model_license.gd + model_credit.gd + build_script.gd (M85), simulate_economy.gd/balance_report.gd (M93), generar_acta.py (M151, deuda ya en 04-Codigo seccion 6), slot.tscn (M14, la propia fila dice "inexistente").
  - 5 falsos positivos de MI barrido (existen en disco, verificados uno por uno hoy): 07-Resultados-Testings.md (M107, en DOCUMENTACION/107-Backups/plan-actual/), fixture_terrain.tscn/.gd (M112, en game/isla-ancestral/tests/fixtures/), test_datos_m60.gd (M60, en game/isla-ancestral/scripts/datos/), patron .tres/.json, y //settings/controls.cfg (ruta runtime user://).
  - **1 DEAD-LINK REAL: CONVENCIONES-CODIGO.md, fila M111 (CHECKLIST-GLOBAL.md L49).** La fila documenta "+ doc CONVENCIONES-CODIGO.md" (Log 771, cierre Hy3) y el archivo NO existe en ningun punto del arbol vivo: busqueda insensible sin resultados, DOCUMENTACION/111-* no lo contiene, git log --diff-filter=D sin borrado registrado. Reportado al director para decision (recrear doc vs corregir fila). NO se toco el GLOBAL.
  - 1 fila stale ya conocida: M157 L106 (del item 54).
- Citas de Logs/ en el GLOBAL vivo: 0 rotas / 0 ambiguas / 0 menciones inexistentes. Los unicos hallazgos del auditor estan en scripts/backups/CHECKLIST-GLOBAL-*.bak.md (backups).

### C. Hallazgo de calidad del detector (familia trampa 92)

- auditar_referencias.py Caso B: slug entrecomillado ('...') -> el tokenizer da 0 tokens -> all([]) devuelve True -> 1982 candidatos FALSOS de "ambigua" en mi primera corrida completa. Las cifras crudas de amb del auditor NO son usables sin barrido estricto; las validas son las mias (79).
- Discrepancia 97 vs 91 de menciones: RESUELTA sin inventar. Mi primera corrida (sesion previa) dio 97 sobre 1981 logs; la de hoy dio 91 sobre 1985. Entre ambas hy3 escribio los logs 2054-2059 (01:11-01:39 de hoy) en el worktree COMPARTIDO, que resolvieron 6 menciones a numeros antes inexistentes. Mismo script, misma logica: se movio el arbol, no el detector.

## Consecuencias

- Item 59 marcado [x] en el BACKLOG-MASTER con esta evidencia.
- 1 dead-link real + 1 hallazgo de detector reportados al director (msg 127). El director decide sobre el GLOBAL.
- Cero commits, cero push, cero ediciones a CHECKLIST-GLOBAL.md / quality.yml / AGENTS.md / project.godot.
