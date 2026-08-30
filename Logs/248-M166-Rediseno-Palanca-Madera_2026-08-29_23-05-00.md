# 248 — M166: Rediseño de la palanca de madera (M70, diseño de horquilla)

**Fecha:** 2026-08-29 23:05
**Módulo:** 70-Interacciones
**Pedido del usuario:** "aca estoy viendo una imagen de la palanca de madera
en blender que esta mal, eso esta corregido? no le encuentro la forma"

## 1) Pedido y diagnóstico

El usuario reportó que la palanca se ve mal en Blender y no le encuentra la
forma. Investigué:

- **v1 (script original):** el brazo cilíndrico se creaba en `(0, 0, 0.21)`,
  exactamente el mismo punto que el cono del pivote. El brazo **atravesaba**
  el pivote en lugar de apoyarse sobre él. Resultado: parecía "un palo clavado
  en una caja con una pelota en la punta".
- **v1.1 (log 233):** el "fix" consistió en rotar el `.blend` a mano de 35°
  a 81.1° y reposicionar el pomo. **Nunca arregló el problema de fondo**:
  el brazo seguía atravesando el pivote, sólo que ahora en otro ángulo.
- **v2 (pivote único, intenté anoche):** single-bmesh correcto pero el diseño
  seguía siendo ambiguo: "un poste con una barra encima" no se lee como
  palanca.

## 2) Diseño definitivo (v3, horquilla)

La forma **clásica e inequívoca** de una palanca mecánica es la horquilla:
dos montantes verticales con el brazo metido entre ellos y un perno de hierro
atravesándolo a la altura del fulcro. Es la misma disposición que una
bomba de agua o un interruptor de palanca.

```
                     POMO icosaedro (24 cm)
                       o
                       |
                       v
   ------------------------------------ <-- brazo, inclinado 10°
   BRAZO ------------------------------>
            ^                          z=0.40 (tope montantes)
           |||                         z=0.36 (eje del perno)  <- fulcro
            |||                         z=0.27 (centro montantes)
           |||                         z=0.14 (techo base)
       ___|||___                        y = +/-0.095
      |  |||   |     PERNO
      |__|||___|    [============]      <-- hierro, sobresale de los montantes
     ============                       z=0 (fondo base)
     ============
        BASE 48x34x14 cm
```

### Parámetros finales

| Pieza | Semiejes | Material |
|---|---|---|
| Base | 0.24 × 0.17 × 0.07 m, cz = 0.07 | madera_osc |
| Montante (×2) | 0.05 × 0.028 × 0.13 m, y = ±0.095, cz = 0.27 | madera_osc |
| Brazo | 0.55 × 0.055 × 0.07 m inclinado 10°, cz = 0.36 | madera_cla |
| Perno | tubo Y radio 0.020, semi 0.143 m, z = 0.36 | hierro |
| Pomo | icosfera radio 0.115 en (0.542, 0, 0.456) | madera_cla |

### Comprobaciones geométricas (10 asserts con TOL = 1e-4)

a. La base tiene el fondo en z = 0.
b. Los montantes arrancan en el techo de la base (z = 0.14).
c. Holgura real brazo ↔ montante ≥ 1 mm (dio 0.012 m = 1.2 cm).
d. El perno queda **dentro** del alto del montante (no asoma por arriba).
e. El perno sobresale de la cara externa del montante (dio 0.143 m vs 0.123 m).
f. El perno **atraviesa** el brazo (queda dentro de su vientre/lomo).
g. El lomo del brazo sobresale por encima de los montantes (los montantes no
   tapan el brazo entero).
h. El lado corto del brazo tiene ≥ 3 cm de aire sobre la base (dio 5.6 cm).
i. El pomo está exactamente en la punta +X del brazo inclinado.
j. El pomo **no toca** ni los montantes ni la base. **Lección v3**: comparar
   solo Z daba falso positivo porque el pomo está a 49 cm en X de la
   horquilla; usé `dist_punto_caja()` (mínimo punto-caja + radio pomo).

## 3) Ejecución

```
$ python ejecutar_en_blender.py .../crear_palanca_madera_lowpoly.py 180
GEOMETRIA ok: horquilla y=+/-0.095, holgura brazo 0.0120 m,
              perno z 0.360, lado corto a z 0.196 (techo base 0.140)
POMO: 20 caras (subdivisions=1)
PALANCA asentada: z_min 0.0000 -> 0.0450 (delta +0.0450, piezas=1)
BBOX x[-0.554..0.645] y[-0.170..0.170] z[0.045..0.616]
PALANCA MADERA OK - objetos SM_: 1 - tris: 96 - materiales: 3
```

96 tris, 1 objeto, 3 materiales.

## 4) Variantes y capturas (E-13)

```
$ python generar_variante.py 70-Interacciones palanca_madera_lowpoly --media --baja
MEDIA : objetos=1  tris=96   materiales=3
BAJA  : objetos=1  tris=66   materiales=3
```

Ambas dentro del presupuesto (MEDIA 8 obj / 1500 tris / 8 mats;
BAJA 6 obj / 700 tris / 4 mats).

18 capturas orbitales `palanca_madera_{src,media,baja}_23-05-00_az{000,060,
120,180,240,300}.png` y 3 hojas de contacto en `70-Interacciones/capturas/`.

**Verificación visual (E-13 OK):** las hojas se leen claramente como una
palanca de horquilla. Desde az 060/120/240/300 se ve el perno plateado
sobresaliendo de los montantes, el brazo apoyado, la base asentada en la
arena con sombra pegada. No flota nada.

## 5) Diagnóstico analítico de la geometría

6 islas, todas cerradas y con normales hacia fuera (volumen firmado > 0):

| Isla | Pieza | Vol real | Vol esperado |
|---|---|---|---|
| 0 | Base 0.48×0.34×0.14 | +0.022848 | 0.48·0.34·0.14 = 0.022848 ✓ |
| 1 | Montante +y | +0.001456 | 0.10·0.056·0.26 = 0.001456 ✓ |
| 2 | Montante -y | +0.001456 | idem ✓ |
| 3 | Brazo 1.10×0.11×0.14 | +0.016940 | 1.10·0.11·0.14 = 0.016940 ✓ |
| 4 | Pomo icosaedro r=0.115 | +0.003857 | fórmula icosaedro ✓ |
| 5 | Perno octogonal r=0.020 L=0.286 | +0.000324 | oct.área·L = 2√2 r² ·L ✓ |

Histograma de materiales: `{0: 18, 1: 26, 2: 10}` — los 3 slots se usan
(E-35 OK).

## 6) Hallazgos técnicos

a. **Asentado correcto (E-12):** z_min del bound box = 0.0450, coincide con
   el objetivo. La base queda hundida 4.5 cm en la arena. No flotación.

b. **Patrón de no-flotación (verificado en 4 assets distintos ya):** medir
   `min(o.matrix_world @ bound_box).z` sobre **todos** los SM_ y mover por
   `delta = Z_APOYO - z_min` es robusto. Funciona porque el bmesh es un solo
   objeto: si hubiera dos mallas, una podría flotar arriba mientras la otra
   compensa.

c. **Icosaedro low-poly:** `bmesh.ops.create_icosphere(subdivisions=1)` en
   este Blender da 20 caras (raw icosahedron). subdivisions=2 sería 80,
   demasiado para un pomo. 20 caras es la granularidad correcta para
   "cozy low-poly".

d. **Comparación eje-a-eje no sirve para esfera-caja:** el assert (j) del
   pomo falló al comparar solo `POMO_Z - POMO_R > MON_Z_TOP`. Toca medir
   distancia real al bounding box. Helper: `dist_punto_caja(p, cx, cy, cz,
   hx, hy, hz)`.

e. **Error de diseño v1:** el brazo cilíndrico en `(0,0,0.21)` y el cono del
   pivote **también** en `(0,0,0.21)`. Esto NO es un bug de mesh ni de
   matemática: es un bug de concepto. El brazo y el pivote tenían que ser
   el mismo objeto O estar en lugares distintos. v3 lo resuelve haciendo
   brazo+pivote_perno+montantes+base un solo bmesh donde el brazo **nace
   entre** los montantes y el perno lo atraviesa.

## 7) Archivos tocados

| Archivo | Acción |
|---|---|
| `70-Interacciones/scripts/crear_palanca_madera_lowpoly.py` | reescrito completo (v1 → v3 horquilla) |
| `70-Interacciones/palanca_madera_lowpoly.blend` | reemplazado (nbar) |
| `70-Interacciones/palanca_madera_lowpoly_media.blend` | regenerado |
| `70-Interacciones/palanca_madera_lowpoly_baja.blend` | regenerado |
| `70-Interacciones/capturas/palanca_madera_{src,media,baja}_23-05-00_az{000,060,120,180,240,300}.png` | 18 capturas nuevas |
| `70-Interacciones/capturas/palanca_madera_{src,media,baja}_23-05-00_hoja.jpg` | 3 hojas de contacto |
| `Logs/ULTIMO_NUMERO.txt` | 247 → 248 |
| `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` | actualizar entrada M70 palanca |
| `DOCUMENTACION/09-GUIA-BLENDER.md` | agregar lección "horquilla > pivote único para palancas" |

## 8) Verificación final

| Check | Esperado | Real | OK |
|---|---|---|---|
| Tris | ≤ 6000 (ALTA) | 96 | ✓ |
| Objetos | ≤ 16 (ALTA) | 1 | ✓ |
| Materiales | ≤ 12 (ALTA) | 3 | ✓ |
| z_min | 0.045 ± 1e-3 | 0.0450 | ✓ |
| Islas | todas cerradas | 6/6 | ✓ |
| Normales | outward | +0.000324 a +0.022848 | ✓ |
| Perno sobresale | sí | 0.143 m vs 0.123 m cara externa | ✓ |
| Lado corto no toca base | ≥ 3 cm aire | 5.6 cm | ✓ |
| Lectura visual "palanca" | sí | hoja 23-05-00 confirma | ✓ |
| MEDIA tris | ≤ 1500 | 96 | ✓ |
| BAJA tris | ≤ 700 | 66 | ✓ |

**Aprobado.**

## 9) Pendiente

- Pipeline Blender→Godot sigue en 0 (no prioridad del usuario por ahora).
- 23 variantes aún exceden presupuesto en el audit global (Task #34 + 5
  mats+-only BAJA).
- Esta es la última tarea explícita del usuario en esta sesión. Sin nuevas
  instrucciones, sugeriría: (a) cerrar la palanca en checklist+guía+memories,
  (b) empezar a sanear los 23 offenders o (c) abrir el pipeline Godot.
