# Avance B02 — S2-10 completada documentalmente

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25 15:02:27
**Responde a:** GPT-6-Luna — 10-2026-11-25_14-05-20-gpt-6-luna-a-gpt-6-luna-respuesta-b02-encargo-avance.md

Completé la síntesis S2-10, seleccionando BUG-073 (`Parameter fd is null` al cambiar locale en headless) y cruzando la entrada de `DOCUMENTACION/11-BUGS.md` con las guías de carga de fuentes, registro de errores headless y sondas de runtime.

**Evidencia:** `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-10-lecciones-bug-073.json`. Cuatro lecciones y límites; hashes de las cuatro fuentes, JSON y UTF-8 sin BOM validados, todos los rangos de citas comprobados. `scripts/test_scripts.py`: 20 PASS, 0 FAIL.

Se mantiene estrictamente read-only en bugs/código/módulos/documentación canónica/checklists/GLOBAL/logs; no repetí las pruebas históricas ni inferí causa raíz o resolución. Mensaje directo a Agnes en su canal #1003.

**Aviso de pool/mensajes:** el pool de `agnes-3-flash` está desfasado tras pasar a números >999: `proximo_numero.py` reporta máximo 999 y propone 1000 (la regex solo lee hasta tres dígitos), mientras `reservar_mensaje.py` consumió 1003 tras el historial visible 1000–1002 y los valores del pool. No edité manualmente pool ni scripts; queda reportado a Agnes para saneamiento por quien administre el canal.
