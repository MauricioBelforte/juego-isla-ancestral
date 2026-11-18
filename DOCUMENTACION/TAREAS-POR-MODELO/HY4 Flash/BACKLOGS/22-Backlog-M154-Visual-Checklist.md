# 22-Backlog: M154 Visual Checklist + Drift GLOBAL restante

> Creada por: agnes-3-flash - 2026-11-18 01:55
> Nicho: visual QA (aprobado) + verificacion de conteos

## Parte A: M154 Visual Checklist (8 tareas - desde tus hallazgos)

Los 58 problemas que encontraste en la prueba 18. Organizarlos en
DOCUMENTACION/154-Vision-Del-Agente/plan-actual/05-Checklist.md
como nueva seccion "Barrido HY4 Flash 17nov".

- [x] T22-01: Crear seccion en 05-Checklist M154 — **EVIDENCIA:** seccion `## Barrido HY4 Flash 17nov` agregada al 05-Checklist de M154; CRLF preservado (218 -> 319), sin BOM/FFFD, 0 checkboxes nuevos
- [x] T22-02: Agregar 15 capturas inutilizables (splash/negro/IDE) con rutas — **EVIDENCIA:** 15 capturas inutilizables con T18-id + modulo + nombre de archivo (grupo 1 de la seccion)
- [x] T22-03: Agregar 19 capsula azul en vez de modelo (rutas + modulo) — **EVIDENCIA:** 19 capturas con capsula azul (grupo 2)
- [x] T22-04: Agregar 5 triangulos verdes flotando (rutas + modulo) — **EVIDENCIA:** 5 capturas con triangulos verdes (grupo 3)
- [x] T22-05: Agregar 4 HUD tapando inventario (rutas + modulo) — **EVIDENCIA:** 4 capturas con HUD tapando inventario (grupo 4)
- [x] T22-06: Agregar 5 franjas horarias indistinguibles (rutas + modulo) — **EVIDENCIA:** 5 capturas con franjas horarias indistinguibles (grupo 5)
- [x] T22-07: Agregar terreno blanco / costuras / script error (rutas) — **EVIDENCIA:** 9 capturas con terreno/costuras/SCRIPT ERROR (grupo 6)
- [x] T22-08: Agregar demas hallazgos (58 - 53 = 5 restantes) — **EVIDENCIA:** 8 capturas restantes (grupo 7): los patrones 1-6 se solapan en 7 ids, union=50, no 53. Cuenta verificada 58/58 PROBLEMA listados, 0 OK incluidos

## Parte B: Drift GLOBAL re-verificacion (4 tareas)

Verificar que los drifts que reportaste en backlog 09 esten fixeados
en CHECKLIST-GLOBAL. Si NO lo estan, reportar de nuevo.

- [x] T22-09: Verificar M41-M60 drift GLOBAL (10 modulos) — **EVIDENCIA:** re-medido 20/20 modos M41-M60: 18 con drift<=5; M46 +8, M50 +7 SIGUEN en GLOBAL
- [x] T22-10: Verificar M61-M80 drift GLOBAL (10 modulos) — **EVIDENCIA:** re-medido 20/20 modos M61-M80: 17 con drift<=5; M63 +26, M66 +7, M69 +19 SIGUEN en GLOBAL
- [x] T22-11: Verificar M81-M100 drift GLOBAL (10 modulos) — **EVIDENCIA:** re-medido 20/20 modos M81-M100: 19 con drift<=5; M94 +6 SIGUE en GLOBAL
- [x] T22-12: Verificar M101-M120 drift GLOBAL (10 modulos) — **EVIDENCIA:** re-medido 20/20 modos M101-M120: 18 con drift<=5; M104 +8, M106 +12 SIGUEN en GLOBAL



## Cierre de tanda (HY4 Flash, 2026-11-18 03:xx UTC)

- **12/12 tareas cerradas** con evidencia medida. Parte A: 58/58 hallazgos organizados en M154. Parte B: 80/80 modulos re-medidos contra `CHECKLIST-GLOBAL.md`.
- **Resultado Parte B:** 8 drifts >5 persisten (7 reportados en backlog 09 + M50 nuevo). Reportados al director; NO se edita GLOBAL ni checklists ajenos.
- **Discrepancia de cuenta:** T22-08 estimaba 5 hallazgos restantes; la medicion da 8 por solapamiento de 7 capturas entre patrones.
- Sin commit/push. Sin flips en `05-Checklist` de modulos ajenos (solo se anadio la seccion de evidencia autorizada en M154).

**Firma:** hy4-flash
