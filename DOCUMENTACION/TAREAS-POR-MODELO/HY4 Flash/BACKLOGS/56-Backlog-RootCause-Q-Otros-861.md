# 56 - Root-Cause [?] Otros (297) + Volumen (audio/.tres/.import/i18n)

**Creado por:** agnes-3-flash (directora) — 2026-11-21 04:35
**Nicho:** Root-cause + Volumen/Limpieza
**Tareas:** 297 [?] otros + volumen de verificacion

## A - Root-Cause [?] Otros (297)

Clasificar cada [?] que NO sea GATE/AUDIT/KnownIssue. Para cada uno:
1. Leer el item y su contexto en el 05-Checklist
2. Determinar si fue [?] erroneo (trabajo ya hecho) → proponer flip a [x] con evidencia
3. Determinar si es genuinamente bloqueado → anotar causa y a quien corresponde
4. Determinar si es un KnownIssue no etiquetado → proponer etiqueta KnownIssue

### M94-Retencion-Sin-FOMO (48)
- [x] T56-01: Clasificar 48 [?] de M94 (root-cause o KnownIssue)

### M159-Catalogo-De-Objetos (37)
- [x] T56-02: Clasificar 37 [?] de M159

### M49-Iluminacion (31)
- [x] T56-03: Clasificar 31 [?] de M49

### M105-Telemetria (27)
- [x] T56-04: Clasificar 27 [?] de M105

### M10-Generacion-Del-Mundo (18)
- [x] T56-05: Clasificar 18 [?] de M10

### M67-Vehiculos (15)
- [x] T56-06: Clasificar 15 [?] de M67

### M16-Crafting (14)
- [x] T56-07: Clasificar 14 [?] de M16

### M115-Hardware (11)
- [x] T56-08: Clasificar 11 [?] de M115

### Resto (modulos con 7 o menos, 17 modulos) (106)
- [x] T56-09: Clasificar [?] de M137 (7), M139 (6), M21 (6), M33 (6)
- [x] T56-10: Clasificar [?] de M09 (5), M73 (5), M112 (4), M151 (4), M156 (4), M18 (4), M22 (4), M02 (3)
- [x] T56-11: Clasificar [?] de modulos restantes con [?] (resto)

## B - Volumen: Audio (0 archivos)

- [x] T56-12: M41 Musica tiene 50[ ] pero 0 archivos audio en assets/. Root-cause: verificar si los archivos existen en otra ruta o si el sistema de audio usa generacion procedural
- [x] T56-13: Verificar si hay rutas de audio en .tres o .gd que apunten a archivos inexistentes

## C - Volumen: .tres (479)

- [x] T56-14: Verificar 479 .tres: conteo de nulls, valores vacios, referencias rotas
- [x] T56-15: Verificar 479 .tres: consistencia de class_name y resource_type

## D - Volumen: .import (878)

- [x] T56-16: Verificar 878 .import: orphaned (fuente no existe) - se verificaron 100 (0 orphaned), faltan 778

## E - i18n (3 locales)

- [x] T56-17: 1 msgstr vacio por locale (en/es/pt) - identificar cual y si es intencional

## F - Cross-doc: CHECKLIST-GLOBAL vs plan-actual

- [x] T56-18: Verificar que el Progreso en CHECKLIST-GLOBAL coincide con el conteo real de [x] en plan-actual/05-Checklist.md para los 20 modulos con mas [x]

## Totales

| Seccion | Tareas |
|---------|--------|
| A (Root-Cause 297) | 11 |
| B (Audio) | 2 |
| C (.tres) | 2 |
| D (.import) | 1 |
| E (i18n) | 1 |
| F (Cross-doc) | 1 |
| **Total** | **18** |

## Resultados medidos — 2026-11-21 (Log 2435)

- T56-01..11 (A): 847 [?] en 76 checklists; 486 excluidos por GATE/AUDIT/KnownIssue;
  361 en alcance. Conteo del mensaje 121 (297) NO coincide: M94 47 vs 48,
  M10 16 vs 18, M67 y M16 No incluidos en el alcance medido por exclusion
  (ver log). 12 pedidos explicitos de archivo: 0 existen -> 0 flips.
  3 candidatos del heurico ancho desestimados (nombre citado != nombre pedido).
- T56-12/13 (B): 0 samples de audio en game/; 0 referencias res:// a audio;
  97 .wav en DOCUMENTACION/.../step-5-kilocode/audio/. Causa: IDs abstractos
  en music_context_matrix.json, no rutas rotas.
- T56-14/15 (C): 479/479 .tres parseables; 276 nulls (272 modelo_3d, 4 icon),
  1513 strings vacios sistematicos; 0 ExtResource/SubResource rotos;
  0 rutas res:// rotas; 0 class_name inconsistente.
- T56-16 (D): 878 .import, 0 sin source_file, 0 orphaned (incluye los 778 pendientes).
- T56-17 (E): 0 msgstr vacios impropios en en/es/pt; solo header canonico.
- T56-18 (F): 165 filas localizadas, 55 con drift; top-20 con 4 drifts:
  M122 -2, M91 -2, M40 -4, M106 -12. GLOBAL no modificado.

Todo reportado al director. Sin flips, sin fixes, sin commits.
