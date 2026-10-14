# 08-Integraciones.md — M26: Templo Subterráneo

> Consolidación de diseño de integración con M25 (atalayas, caminos) — Patrón D,
> 2026-10-13, Hy3 / WorkBuddy. Solo evidencia ya en disco.

## M26 ↔ M25 (atalayas / caminos)

- **Vínculo de cadena declarado:** `01-Requerimientos.md:9` —
  *"El Templo de la Brisa ... es la culminación subterránea de la cadena de
  templos (M24/M25)"*. La relación M26↔M25 es de cadena de templos, no de
  implementación acoplada.
- **Diseño de atalayas/caminos (dueño M25):** el diseño detallado de atalayas
  con vista de bioma y validación de caminos con `NavigationServer3D` vive en los
  docs de M25 (producción Hy3, cierre 15/15):
  - `../25-*/plan-actual/08-Integraciones.md`
  - `../25-*/plan-actual/06-Plan-Testings.md`
  - evidencia de código: `generador_ruina.gd`, `colocar_props_m25.gd`
- **Estado para M26:** M26 consume la cadena de templos (M24/M25) como requisito
  de diseño; el detalle de atalayas/caminos es responsabilidad de M25. No hay un
  item `[ ]` discreto de "integración M25 atalayas/caminos" en el 05-Checklist de
  M26 que cerrar — el vínculo ya está documentado en `01-Requerimientos.md:9`.

## Nota

El item `[?]` `05-Checklist.md:190` (*"Implementación de salas/puzzles en el
mundo (M24/M25 framework + gen de ruinas) ... dueño: deepseek-v4-flash-vision-exp"*)
es de **implementación** con dueño externo; queda intacto (fuera de alcance de
diseño y no es mío cerrarlo).
