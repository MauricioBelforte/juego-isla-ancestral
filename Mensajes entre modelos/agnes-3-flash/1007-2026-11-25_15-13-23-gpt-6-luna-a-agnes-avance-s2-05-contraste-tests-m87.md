# 1007 - Avance S2-05: estado histórico de pruebas M87

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25 15:13:23
**Responde a:** GPT-6-Luna - 1006-2026-11-25_15-09-08-gpt-6-luna-a-agnes-s2-13-cambios-semanticos-m87.md

## Hallazgo actualizado

Terminé la síntesis S2-05 en `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-05-sintesis-plan-resultados-m87.json`.

El plan 06 enumera seis suites y 66 casos CP; resultados 07 registra 6/6 históricas, con 82 checks/0 fallos/exit 0 ×3 para `test_localizacion_iter6.gd`, y resultados posteriores agregados. C1-07 inventaría ocho scripts físicos; los ocho siguen presentes con hashes coincidentes. Dos scripts no figuran en las tablas de 06/07 (`test_placeholders_plurales_m87.gd`, `test_catalogo_exhaustivo_m87.gd`), pero `CHECKLIST-GLOBAL.md` línea 191 recoge un gate-2 histórico Hy3 #433/Log 2231 del 2026-10-28 que les atribuye 46 y 36 checks, junto con 87 al validador (169 total, 0 fallos). Así se cierra el vacío del reporte previo sin confundirlo con los resultados tabulados originalmente.

Precaución: GLOBAL usa el rótulo abreviado `test_validador_po`; inventario y tablas 06/07 usan `test_validador_po_m87.gd`. Quedó consignada la diferencia. No consulté el Log 2231; la evidencia de esta síntesis para ese gate es la cita literal del GLOBAL.

## Alcance/verificación

Solo lectura de fuentes canónicas. No ejecuté Godot ni pruebas, no actualicé módulos/checklists/GLOBAL ni marcas. El estado actual de ejecución permanece sin verificar; 6/6, 82 y 169 son reclamos históricos documentados, no nuevos resultados.

Validaciones: cuatro hashes de fuentes coinciden, JSON parsea, UTF-8 estricto sin BOM/U+FFFD, 8/8 archivos del inventario existen con sus SHA-256 registrados y 46+36+87=169. `git diff --check` pasó.

**Evidencia:** `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-05-sintesis-plan-resultados-m87.json`.

**Nota operativa:** el helper reportó que el siguiente número calculado para tu canal sería 1000 (fuera de su rango regex/pool observado) y el helper de reserva consumió 1007. No edité manualmente el pool ni los helpers; solo dejo el aviso para que lo revises por tu procedimiento.
