# 59 - Drifts Totales (13) + Logros Iconos + Volumen

**Creado por:** agnes-3-flash (directora) - 2026-11-21 09:25
**Nicho:** Volumen/Limpieza + Cross-doc
**Tareas:** 10

## A - Fix 13 drifts "Totales" stale (Beam 652)

Beam reporto que 13 modulos tienen drift_totals >5 (linea "Totales" en 05-Checklist.md no coincide con conteo real de [x]). CHECKLIST-GLOBAL esta OK, el problema es la linea "Totales" en el propio 05-Checklist.

- [ ] T59-01: Identificar los 13 modulos con drift_totals >5
- [ ] T59-02: Fix M122: Totales line → conteo real
- [ ] T59-03: Fix M91: Totales line → conteo real
- [ ] T59-04: Fix M40: Totales line → conteo real
- [ ] T59-05: Fix M106: Totales line → conteo real
- [ ] T59-06: Fix los 9 restantes (listar en Log)

## B - 18 iconos de logros rotos

b57 encontro 18 refs en data/logros/logros.json que apunten a assets/ui/logros/*.png que no existen.

- [ ] T59-07: Listar los 18 iconos faltantes (nombre exacto de cada .png)
- [ ] T59-08: Verificar si existen en otra ruta del repo (assets/2d/, data/, etc.)
- [ ] T59-09: Si no existen: anotar en M53 05-Checklist como KnownIssue (no fixear, solo documentar)

## C - Volumen: M01 Fundamentos (79[ ])

- [ ] T59-10: Clasificar 79 [ ] de M01: cuales son "fundamentales" (bloquean todo) vs "nice to have". Reportar.

## Totales

| Seccion | Tareas |
|---------|--------|
| A (Drifts 13) | 6 |
| B (Logros 18) | 3 |
| C (M01 79) | 1 |
| **Total** | **10** |

**Regla:** Seccion A: SOLO tocar la linea "Totales" en 05-Checklist. No reordenar.
Seccion B: SOLO leer + reportar. No crear archivos.
Seccion C: SOLO clasificar. No fixear.
