# Investigación de detalles — buque M169 (HY4 Flash, 2026-11-19)

## Alcance
Investigación previa al rediseño del exterior. No modifica documentación ajena; es una propuesta visual en `DISENO-HY4F/`.

## Fuentes consultadas

| # | Fuente | Dato extraído |
|---|---|---|
| F1 | `DOCUMENTACION/169-Crucero/plan-actual/01-Requerimientos.md` R1-R10, CA2 | Eslora **72 m**, casco ×14 m, 4 cubiertas, 2 chimeneas, botes, puente; `Z_APOYO=0,045`; pivot en flotación; ≤9.000 v alta; `SM_`/`MAT_Crucero_*`; sin texturas; CA2 exige 72 m auditables. |
| F2 | `DOCUMENTACION/169-Crucero/plan-actual/03-Diseno.md` §2-3 | 4 cubiertas de 72×14, 66×13,2, 56×12,4, 34×10 m; puntal 9,6 m; calado visual 1,8 m; desglose con tajamar, hélice/timón, 4 botes, 24 ventanas, luces, ancla. |
| F3 | `DOCUMENTACION/169-Crucero/plan-actual/05-Checklist.md` B-02..B-15, C-01..C-07 | Pendientes reales: tajamar/mascarón, popa con hélice/timón, barandas con balaustres cada 1,5 m, 2 escaleras, 24 ventanas, luces de navegación, 4 botes, pescantes, ancla/cadena, escotillas, chicla, carga. |
| F4 | Wikipedia *Cruise ship* (consulta 2026-11-19) | Crucero = "hotel flotante" multi-cubierta; casino, restaurantes, teatro y espacios públicos; estabilidad por centro de masa bajo y gran manga. Justifica la silueta escalonada y el casino/comedor del M169. |
| F5 | Wikipedia *Lifeboat (ship)* | SOLAS/LSA: botes en **babor y estribor** para que quede uno aunque el buque escorre; lanzamiento con **pescantes**; capacidad certificada; botes a cierta distancia de la hélice. Justifica 2+2 botes simétricos y lejos de popa. |
| F6 | MSA China, *Adoption of amendments to SOLAS 1974* (PDF, búsqueda 2026-11-19) | Fragmento: los botes se estiban **tan a proa de la hélice como sea practicable**. No se pudo extraer el PDF completo con la herramienta web; se usa solo el fragmento indexado, marcado como evidencia parcial. |
| F7 | Wikipedia *Bulbous bow* | Bulbo bajo la flotación cancela la cresta de proa por interferencia destructiva; típico en buques de pasajeros rápidos/grandes; **perjudicial en buques lentos o pequeños** por área mojada. Decisión: no bulbo en un buque de 72 m de línea de islas; sí tajamar/mascarón como pide F3. |
| F8 | Wikipedia *Bridge (ship)* | Las alas del puente se extienden hasta la manga total o más (3-4,6 m en algunos casos) para ver la banda al atracar. Justifica alas que lleguen a ±7 m con manga 14 m. |
| F9 | Wikipedia *Navigation light* / COLREG Regla 21 y 23 | Blanca de mástil 225°, verde estribor y roja babor 112,5°, blanca de popa 135°; buques ≥50 m llevan **segunda luz de mástil más alta y a popa** de la delantera. |

## Medición del estado actual

| Asset | Medición real | Veredicto |
|---|---|---|
| `crucero_grande_v22.blend` (ERNIE) | 235,91 m de eslora, 52,18 m de manga, z 0,05..29,44, 191 mallas, materiales `MAT_Crucero_*` | **Drift**: 3,28× la eslora spec; consecuencia de `ESC=3.2` en `construir_crucero.py`. No se corrige: es autoría ajena. |
| `buque_HY4F_concepto_v1.blend` (HY4F) | 84,36 × 19,0 × 24,49 m; 221 mallas, 2.624 v | Rompe R7 (72 m), manga 14 m y R5 (`z_min=0,045`). Sirve como prueba visual, no como entregable final. |

## Brechas a corregir en v2

| # | Brecha | Fuente | Corrección |
|---|---|---|---|
| G1 | Escala 84,36 m vs 72 m | F1, F3 | Eslora exacta 72,0 m ±0,5; manga 14,0 m. |
| G2 | Quilla en z=-3,4 vs Z_APOYO 0,045 | F1 | `KEEL=0,045`, flotación en `KEEL+1,80`; `z_min` auditable. |
| G3 | 3 niveles + cubiertas no escalonadas | F2 | 4 cubiertas con esloras 72/66/56/34 y mangas 14/13,2/12,4/10. |
| G4 | Sin tajamar ni mascarón | F3 | Proa con tajamar y mascarón dorado; sin bulbo (F7). |
| G5 | Popa plana, sin hélice/timón | F3, F5 | Popa redonda con hélice y timón; botes lejos de la hélice (F6). |
| G6 | 10 botes, no 4 | F3, F5 | 4 botes (2 por banda) con pescantes. |
| G7 | Sin barandas con balaustres cada 1,5 m | F3 | Balaustres cada 1,5 m en 4 cubiertas. |
| G8 | Sin escaleras exteriores | F3 | 2 tramos con 30° y rampa. |
| G9 | Ventanas número incorrecto | F3 | 24 ventanas de camarote en fila. |
| G10 | Sin luces de navegación | F9 | Roja babor, verde estribor, 2 blancas de mástil (la popa más alta), blanca de popa. |
| G11 | Sin ancla/cadena, escotillas ni carga | F3 | Ancla + cadena, escotillas y cajas. |
| G12 | 221 objetos → draw calls altos | F1 (P-05 ≤40) | Agrupar mallas por material `MAT_Crucero_*`, objetivo ≤20 objetos de casco. |
| G13 | Sin LOD media/baja | F3 D-01/D-02 | Generar 3 LOD con el mismo contorno: alta ≤9.000 v, media ≤3.500, baja ≤1.500. |

## Decisiones dudosas / abiertas
- F2 da puntal 9,6 m desde flotación hasta cubierta 4, pero también 4×3,2 m libres + forjado; son incompatibles si la cubierta 1 está 2,2 m sobre flotación. Se prioriza F1/F2 (4 cubiertas y eslora) y se documenta la altura final en el generador.
- F6 es evidencia parcial por PDF no extraíble; no se usa para derivar una distancia numérica, solo el principio "a proa de la hélice".
- La escala de ERNIE (235,91 m) se reporta como drift, no se corrige ni se consume como referencia.

## Resultados medidos de la v2 (2026-11-19 05:03 GMT-3)

| LOD | Vértices | Límite | Estado |
|---|---:|---:|---|
| Alta | 6.730 | 9.000 | ✅ |
| Media | 2.266 | 3.500 | ✅ |
| Baja | 1.362 | 1.500 | ✅ |

**Cota real (LOD alta):** 72,3 m de eslora (spec 72,0 ±0,5 ✅), 18,9 m de manga total including botes/alas; casco 14,0 m ✅; `z_min=0,045` ✅.

### Correcciones aplicadas durante la verificación visual
1. Manga inflada a 27,37 m: `NIVELES` usaba 14,0 como semimanga en lugar de 7,0 → corregido.
2. `z_min=-0,455`: timón y ancla sumergidos → reubicados; `z_min=0,045` medido.
3. Barandas giradas 90° por restar `π/2` al ángulo del segmento → corregido.
4. Ventanas y botes dentro de la pared → reubicados en superficie real.
5. Puente sin vidrio → fachada y bandas laterales añadidas.
6. Luces flotando → montadas en mástil, fachada y coronamiento.
7. Ventana huérfana en popa (vista 3/4) → fila recortada a y=-25..25.

### Limitación abierta
La LOD baja se simplificó de 12 a 8 puntos en el contorno de las cubiertas. Resultado medido: 1.362 vértices, dentro del límite de 1.500. Silueta conservada; ventanas reducidas a 6 por banda.

### No verificado
No se exportó GLB ni se corrió `auditar_glb_490.py`: eso requiere integración en Godot y GO del director. Este entregable es propuesta visual en Blender.
