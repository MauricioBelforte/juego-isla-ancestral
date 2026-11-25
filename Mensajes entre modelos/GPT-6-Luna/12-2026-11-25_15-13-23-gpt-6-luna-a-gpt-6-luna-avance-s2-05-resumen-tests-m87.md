# 12 - Avance S2-05: síntesis y contraste de pruebas M87

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25 15:13:23
**Responde a:** GPT-6-Luna - 11-2026-11-25_15-02-27-gpt-6-luna-a-gpt-6-luna-avance-s2-10-bug-073.md

## Síntesis S2-05

Actualicé `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-05-sintesis-plan-resultados-m87.json` para añadir el registro de QA posterior citado por `CHECKLIST-GLOBAL.md` (fila/línea 191; hash de fuente incluido).

- `06-Plan-Testings.md` enumera 6 suites y 66 casos CP; cubre iteraciones 1–6 y define C1–C9 para la iteración 7.
- `07-Resultados-Testings.md` registra históricamente 6/6 suites, incluyendo 82 checks/0 fallos/exit 0 ×3 para `test_localizacion_iter6.gd`. En sus tablas hay 15 filas de resultado individual CP (CP-01..15); para rangos posteriores presenta resultados agregados, no una matriz completa C1–C9.
- El inventario estático C1-07 detecta 8 scripts `test_*.gd`, todos presentes al revalidar y con SHA-256 coincidente. Dos no figuran en las tablas de 06/07: `test_placeholders_plurales_m87.gd` y `test_catalogo_exhaustivo_m87.gd`.
- Matiz respecto de la síntesis previa: el GLOBAL registra un gate-2 histórico Hy3 #433/Log 2231 (fecha de sello 2026-10-28) con 169 checks/0 fallos: 46 + 36 + 87 para placeholders, catálogo exhaustivo y validador PO. Esto documenta que las dos suites adicionales sí aparecen en un resultado posterior, sin insertarlas retroactivamente en las tablas de 06/07.
- El nombre del tercer suite en GLOBAL es abreviado (`test_validador_po`); la tabla/inventario lo registran como `test_validador_po_m87.gd`. Esa correspondencia nominal quedó anotada; no leí Log 2231 ni verifiqué su salida primaria.

## Límites y validación

No ejecuté Godot ni pruebas. Las cifras 6/6, 82 y 169 son afirmaciones históricas documentadas, no resultados actuales. No se concluye que una prueba falle por no tener fila individual, ni que el estado actual esté verificado.

Validé parseo JSON, UTF-8 estricto sin BOM ni U+FFFD, hashes de las cuatro fuentes y existencia/hash de 8/8 scripts del inventario; la aritmética 46+36+87=169 cuadra. `git diff --check` pasó. Los documentos canónicos, el código, los checklists y GLOBAL no se modificaron. El backlog no se marcó por la restricción de autorización ya reportada.

**Evidencia:** `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-05-sintesis-plan-resultados-m87.json`.
