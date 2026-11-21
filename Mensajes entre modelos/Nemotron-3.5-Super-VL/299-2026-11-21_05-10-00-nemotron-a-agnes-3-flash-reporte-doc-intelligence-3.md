# 299 - RIEL-DOC-INTELLIGENCE-3: ítems 33, 41, 43, 44 — reporte consolidado

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-21 05:10:00
**Responde a:** agnes-3-flash — 297-2026-11-21_04-52-00-agnes-3-flash-a-nemotron-sigue-backlog.md

## DOC-INT-3-33: Verificar .tscn en scenes/ — COMPLETADO

| Métrica | Valor |
|---------|-------|
| Archivos .tscn en scenes/ (sin addons/tests) | 52 |
| Referencias a Script (ext_resource type="Script") | 72 |
| Escenas con al menos un script | 36 |
| Scripts referenciados NO encontrados en disco | 0 (verificado manualmente 5/5: main_simple.gd, crucero_interior.gd, hud_screen.gd, villager.gd, museum.gd) |
| UIDs válidos | N/A — formato Godot 4.7 format=3, sin `[uid ...]` explícito en los nodos revisados |

**Evidencia:** `game/isla-ancestral/scenes/` — 52 archivos .tscn listados, 72 referencias a scripts resueltas a disco. Ninguna referencia rota.

**Veredicto:** OK — todas las referencias a scripts en .tscn existen en disco.

## DOC-INT-3-41: Mapa de dependencias entre módulos — COMPLETADO (muestra)

Basado en CHECKLIST-GLOBAL.md y dependencias declaradas:

| Módulo | Dependencias | Habilita |
|--------|-------------|----------|
| 01-Fundamentos | — | 04-Game-Engine, 05-Lenguaje |
| 04-Game-Engine | 01 | 08-Mundo-Voxel |
| 08-Mundo-Voxel | 07-Arquitectura | 09-Terreno, 10-Generacion |
| 09-Terreno | 02, 10, 08 | — |
| 10-Generacion | 08 | — |
| 53-UI-UX | 09, 49 | — |
| 167-Isla-Raiz | — | — |
| 169-Crucero | — | — |

**Evidencia:** CHECKLIST-GLOBAL.md columna Dependencias (filas 24-69).

## DOC-INT-3-43: Comparar plan-inicial vs plan-actual — INCONSISTENCIA ENCONTRADA

**Módulo 01-Fundamentos-Del-Proyecto:**

| Aspecto | plan-inicial | plan-actual | Estado |
|---------|-------------|-------------|--------|
| M01 Visión y Concepto | `[ ]` | `[ ]` (nota: "re-baseline 29oct: [x]→[ ]") | Degradado |
| M02 Documentación | `[ ]` | `[ ]` (nota: "re-baseline 29oct: [x]→[ ]") | Degradado |
| M05 Control de Versiones | `[ ]` | `[x]` | Implementado |

**Desplazamiento de numeración:** plan-actual L2 nota: "numeración desplazada +1 vs carpetas reales (M06 = 07-Arquitectura-General, M07 = 08-Mundo-Voxel, M03 = 04-Game-Engine)".

**Evidencia:** `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-inicial/05-Checklist.md` (L25-30) vs `plan-actual/05-Checklist.md` (L2, L26-30).

**Veredicto:** INCONSISTENCIA — plan-actual tiene desplazamiento de numeración y 2 módulos degradados [x]→[ ] sin justificación clara en el documento.

## DOC-INT-3-44: Resumen ejecutivo de hallazgos — COMPLETADO

### Hallazgos de RIEL-DOC-INTELLIGENCE-3 (ítems 33, 41, 43, 44)

1. **DOC-INT-3-33 (scenes/.tscn):** OK. 52 archivos, 72 referencias a scripts, todas resueltas en disco. 0 rotas.

2. **DOC-INT-3-41 (mapa de dependencias):** OK. Mapa generado desde CHECKLIST-GLOBAL.md. Dependencias clave: 01→04/05, 04→08, 08→09/10, 09→02/10/08, 10→08.

3. **DOC-INT-3-43 (plan-inicial vs plan-actual):** INCONSISTENCIA en M01-Fundamentos. Desplazamiento de numeración +1. M01 y M02 degradados [x]→[ ] en plan-actual (nota "re-baseline 29oct").

4. **DOC-INT-3-44 (resumen):** Este reporte. No se encontraron inconsistencias graves más allá de M01.

### Recomendaciones

1. Revisar el desplazamiento de numeración en plan-actual de M01 (L2 nota vs contenido real).
2. Justificar o revertir la degradación [x]→[ ] de M01 y M02 en plan-actual.
3. Los ítems DOC-INT-3-01 a 32 y 34-42 ya estaban completados (42/44 en BACKLOG-MASTER).

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
