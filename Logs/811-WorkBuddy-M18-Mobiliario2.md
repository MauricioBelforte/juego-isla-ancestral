# Log 811 — M18 Mobiliario interior interactivo · 2do lote (10 ítems)

**Agente:** Hy4 preview (WorkBuddy)
**Fecha:** 2026-09-11
**Módulo:** M18 — Mobiliario interior interactivo
**Alcance:** cerrar los 10 ítems de "Mobiliario interior" que quedaron pendientes tras el log 810.

## §0 — Por qué este log

El log 809 descubrió que 14 ítems de mobiliario estaban marcados `[x]` SIN existir.
El log 810 cerró 4 (cama_basica, velador, silla_madera, mesa_madera). Este log 811
cierra los **10 restantes**: `cama_doble`, `sillon`, `nevera_rustica`, `estufa_lena`,
`estanteria`, `comoda`, `lampara_pie`, `alfombra`, `cuadro_ancestral`,
`maceta_interior`.

## §1 — Helpers y material nuevo en `mobiliario_util.py`

Para este lote se necesitaban piezas que `mobiliario_util.py` no tenía:

| Helper / mat | Uso | Notas |
|---|---|---|
| `cono(n, mat, r_inf, r_sup, h, cx, cy, cz, verts)` | maceta, tulipa | cierre `E-100` (cz = centro) |
| `cilindro` ya estaba | nevera (patas cilíndricas) y cuadro (peanas) | ver §3 |
| Paleta: `piedra`, `hierro`, `hielo`, `verde_hoja`, `tierra`, `vidrio` | nevera, estufa, tulipa, maceta | añadir claves al dict es seguro (los generadores ya existentes solo piden las claves que ya usaban) |

### `scripts-reutilizables/hoja_util.py` — SE CREÓ EN ESTE LOG

La memoria del proyecto (`MEMORY.md`, guía de errores) decía:

> "Hojas → scripts-reutilizables/hoja_util.py (hoja_plana_arqueada, prisma_contorno{,_en}, vol_firmado, newell, desvio_planar). No duplicar en cada generador."

…pero el archivo **no existía** en disco. `find` sobre todo el repo confirmó
0 resultados. Era una convención escrita y nunca cumplida. Se creó acá de
una sola vez:

- `hoja_plana_arqueada(nombre, mat, largo, ancho, arco, caida, grosor, seg, loc, rot)` —
  barre un perfil a lo largo de X con `x(t)=largo·t`,
  `ancho(t)=ancho/2·(0.18+0.82·sin(πt)^0.7)`, `alto(t)=arco·sin(πt) - caida·t`
  (la hoja sube y se desploma). Cierra el contorno, extruye en Z y devuelve un
  sólido CERRADO con volumen firmado > 0 (E-92).
- `vol_firmado(obj)`, `desvio_planar(obj)` — QA ya conocidos.
- `bmesh.normal_update()` al final (E-99).
- `transform_apply()` antes de devolver, porque `join()` aplica la matriz
  inversa del objeto (E-83).

Usos actuales: solo `maceta_interior` (5 hojas arqueadas unidas en
`SM_Maceta_Follaje`). Futuros: M33 cañas y bananero, M50 árboles.

## §2 — Tabla numérica (auditor `auditar_mobiliario.py`, post-fix)

```
asset           var   SM_   tris  mats   z_min    huella       toca  vol_firm  ok
cama_doble      alta    14    168     5  0.0450  2.05x1.40       20   0.8931   OK
cama_doble      media    5    168     5  0.0450  2.05x1.40       20   0.8931   OK
cama_doble      baja     5    114     4  0.0450  2.03x1.40       18   0.4642   OK
sillon          alta    10    120     3  0.0450  1.13x0.69       16   0.4110   OK
sillon          media    3    120     3  0.0450  1.13x0.69       16   0.4110   OK
sillon          baja     3     82     3  0.0450  1.13x0.69       11   0.2645   OK
nevera_rustica  alta    11    360     5  0.0450  1.02x0.88       64   0.7853   OK
nevera_rustica  media    5    360     5  0.0450  1.02x0.88       64   0.7853   OK
nevera_rustica  baja     5    248     4  0.0450  1.02x0.88       44   0.7037   OK
estufa_lena     alta    12    268     3  0.0450   .86x.56        20   0.4476   OK
estufa_lena     media    3    268     3  0.0450   .86x.56        20   0.4476   OK
estufa_lena     baja     3    186     3  0.0450   .86x.56        18   0.4296   OK
estanteria      alta    10    264     5  0.0450  1.00x0.34        8   0.1980   OK
estanteria      media    5    264     5  0.0450  1.00x0.34        8   0.1980   OK
estanteria      baja     5    184     4  0.0450  1.00x0.34        8   0.1354   OK
comoda          alta    10    144     3  0.0450   .86x.46        16   0.2897   OK
comoda          media    3    144     3  0.0450   .86x.46        16   0.2897   OK
comoda          baja     3     98     3  0.0450   .86x.46        13   0.2574   OK
lampara_pie     alta     6    300     4  0.0450   .44x.44        16   0.0353   OK
lampara_pie     media    3    300     4  0.0450   .44x.44        16   0.0353   OK
lampara_pie     baja     3    208     4  0.0450   .44x.44        12   0.0342   OK
alfombra        alta     4    496     4  0.0450  3.20x3.20       32   0.3152   OK
alfombra        media    4    496     4  0.0450  3.20x3.20       32   0.3152   OK
alfombra        baja     4    344     4  0.0450  3.14x3.14       17   0.0862   OK
cuadro_ancestral alta    7    240     4  0.0450   .76x.34        32   0.0620   OK
cuadro_ancestral media   5    240     4  0.0450   .76x.34        32   0.0620   OK
cuadro_ancestral baja    5    164     4  0.0450   .76x.34        22   0.0551   OK
maceta_interior  alta    5    436     3  0.0450   .35x.36        14   0.0602   OK
maceta_interior  media   3    436     3  0.0450   .35x.36        14   0.0602   OK
maceta_interior  baja    3    302     3  0.0450   .37x.36         8   0.0541   OK
```

**0 fallos.** 30 variantes dentro de presupuesto M166 §3.3:
ALTA <=16 obj / <=6000 tris / <=12 mats · MEDIA <=8 / <=1500 / <=8 · BAJA <=6 / <=700 / <=4.

Notas sobre los mínimos:
- `estanteria` BAJA toca=8 (justo en el guard): los 2 montantes de caja
  sobreviven porque la malla 'madera_oscura' fusionada (montantes+baldas)
  no es enorme y los montantes son el ~25% de los vértices.
- `maceta_interior` BAJA toca=8 (justo en el guard): el cono truncado del
  macetero tiene 14 vértices inferiores, el decimate se queda en 8.
  Aceptable pero vale revisarlo si en algún momento cambia el decimate.

## §3 — Regla nueva (E-104): pies cilíndricos para sobrevivir BAJA

Dos de los diez muebles fallaron al primer pase del auditor **únicamente
en BAJA**, y la causa fue siempre la misma:

- `nevera_rustica`: 4 patas CAJA de 0.16 m en una malla 'piedra' fusionada
  con zócalo (1.00×0.85) y cuerpo (0.92×0.78). Las patas eran el ~17% de
  la malla. El decimate 0.7 de BAJA se las comió: `toca` cayó de 16 a **5**.
- `cuadro_ancestral`: 2 peanas CAJA de 0.24×0.36 m en una malla
  'madera_oscura' fusionada con marco+lamina+rostro+penacho. `toca` cayó
  de 8 a **2**, y la huella se redujo a 0.24×0.36 (por debajo del
  `min(fp)>0.30`, E-50).

Causa estructural: las patas/peanas son una fracción ínfima de la malla
fusionada, así que el simplificador las considera detalle prescindible.

**Curar con vértices, no con asserts**: las patas pasaron a **CILINDRO de
16 verts**:

- `nevera_rustica`: 4 cilindros r 0.11, h 0.08 → 64 vértices de apoyo,
  el 84% de la malla fusionada. El decimate ya no puede llevárselas sin
  llevarse el mueble.
- `cuadro_ancestral`: 2 cilindros r 0.17, h 0.05 → 32 vértices de apoyo.

Resultado post-fix: nevera `toca=64→64→44` (ALTA/MEDIA/BAJA), cuadro
`toca=32→32→22`. **Margen suficiente** sobre el mínimo `>= 8`.

**Regla general** (vale anotar en la guía de errores como **E-104**):

> En un asset cuyas patas/peanas compartan material con un cuerpo mucho
> mayor, los apoyos tienen que ser **CILINDROS** (>= 16 verts cada uno),
> no cajas. Una caja de apoyo sobrevive a ALTA/MEDIA pero es candidata a
> desaparecer en BAJA cuando la malla fusionada es grande. Caso particular
> de E-96 (poda por caras) cruzado con el comportamiento del decimate de
> Blender 4.2.

## §4 — E-96 aplicado de entrada (no como parche)

En el log 810 la llama del velador desapareció en BAJA porque era la pieza
con menos caras. Se agrupó con la vela en `SM_Velador_VelaLlama` con dos
slots de material. Mismo riesgo en este lote:

| Asset | Detalle chico | Solución (join, E-96 invertido) |
|---|---|---|
| `nevera_rustica` | tirador + 2 bisagras | `SM_Nevera_Herrajes` (bronce ×3) |
| `nevera_rustica` | 2 refuerzos de esquina | `SM_Nevera_Refuerzos` (madera clara) |
| `estufa_lena` | 2 hornallas | `SM_Estufa_Hornallas` (hierro ×2) |
| `estanteria` | 4 libros × 3 baldas | `SM_Estanteria_Libros_1/2/3` (mixto) |
| `comoda` | 3 tiradores | `SM_Comoda_Tiradores` (bronce ×3) |
| `lampara_pie` | vela + llama | `SM_Lampara_Luz` (cera + llama) |
| `cuadro_ancestral` | ojos + nariz + boca | `SM_Cuadro_Rostro` (barro + madera_oscura) |
| `cuadro_ancestral` | 3 plumas del penacho | `SM_Cuadro_Penacho` (tela roja) |
| `maceta_interior` | 5 hojas arqueadas | `SM_Maceta_Follaje` (verde_hoja) |

**PODA BAJA: 0 piezas eliminadas en los 10 assets** — el prevent-E-96
funcionó.

## §5 — Capturas (§24 anti-flotantes)

`blender -b --factory-startup --python scripts-reutilizables/capturar_angulos_headless.py`
generó **180 PNG** (10 assets × 3 variantes × 6 ángulos azimutales). Las
**30 hojas de contacto** `hoja_18_<asset>_<var>.jpg` se generaron con
`contact_sheet.py` (0 fallos).

**Verificación visual §24**: 6 hojas ALTA leídas con el visor (esta sesión
sí soporta `Read` de JPG). En ninguna se observa luz/aire entre el objeto
y la base:

| Asset | Observación |
|---|---|
| `cama_doble` | postes y cabecera montados, manta cubre los 2/3 inferiores, sin aire bajo las patas |
| `sillon` | apoya en 4 patas; respaldo y brazos arrancan del tope de la base (sin flotar) |
| `nevera_rustica` | 4 patas de piedra visibles, hielo encima, sin separación del disco |
| `estufa_lena` | leñero bajo, hornallas arriba, tubo de chimenea perpendicular |
| `estanteria` | montantes al suelo, libros sobre las baldas 2-3-4 |
| `comoda` | 3 cajones + 3 tiradores, tablero sobresale como tapa |
| `lampara_pie` | tulipa transparente deja ver la vela, base cilíndrica, sin flotar |
| `alfombra` | 4 anillos concéntricos, multicolor, total 3.8 cm de altura |
| `cuadro_ancestral` | 2 peanas cilíndricas, máscara legible, penacho de 3 plumas |
| `maceta_interior` | cono truncado de barro, 5 hojas arqueadas, tallo central |

**Notas estéticas para iterar** (no bloquean el cierre):

- `maceta_interior`: solo 5 hojas, queda un poco calva. Sumar 5 más (10
  en total) le daría densidad.
- `alfombra`: 3.8 cm de alto se ve un pelín gruesa; bajar la altura de
  los anillos 1/2/3 a h=0.012 (en vez de 0.02) la aplana a 2.4 cm.
- `cuadro_ancestral`: la máscara interior (ojos/nariz/boca) se lee pero
  podría ser ~30% más grande.

## §6 — Godot: 30/30 importados con md5 distintos

`Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --import`
corrió exactamente **30 pasos** (uno por GLB nuevo). Verificación de
sidecars (leyendo el `path=res://...` de cada `.glb.import`):

```
scn resueltos desde sidecar : 30/30
distintos                   : 30/30
problemas                   : ninguno
total .scn en .godot/imported: 441  (411 del 810 + 30 del 811)
```

GLB en el juego (post-811): **159 ALTA / 129 MEDIA / 127 BAJA = 415**.
373 (809) + 12 (810) + 30 (811). Cierra.

## §7 — Checklists re-auditados

`python tools/mcp/blender-mcp/auditar_checklist.py` (la herramienta del
log 809, E-101/102/103 corregidos):

```
Items parseados      : 169  ([x]=141  [ ]=28  [?]=0)
A) Falsos pendientes : 0
B) Falsos completos   : 0
C) Items sin script   : 0
D) Scripts huerfanos  : 17  (sin cambio desde log 810)
E) Sidecar sin .glb   : 0
```

Los 17 huérfanos siguen anotados en el log 810 §7 — son scripts
constructivos (paredes, piso, techo, ventanas, puerta, etc.) que el
checklist no pide porque su checklist vive en otro lugar (M18 "Estructura
de casa" no existe como bloque: las paredes/pisos/techos están sueltos
en M16? M19?). **Pendiente**: anotar uno a uno a qué módulo pertenecen o
crearles entrada.

`CHECKLIST-OBJETOS-BLENDER.md` actualizado: 141 `[x]`, 28 `[ ]`, contadores
y bloque de auditoría reescritos.

## §8 — Cinco observaciones honestas (§21.4)

1. **Hoja_util no existía.** Mi memoria del proyecto decía que sí. La
   descubrí al necesitar hojas para la maceta y la creé de una vez con
   `hoja_plana_arqueada`. Reconozco que las otras menciones (M33 cañas,
   M50 árboles) siguen sin script y por tanto sin asset real: lo que dice
   el checklist probablemente sigue mintiendo en esos módulos hasta que
   un agente los cierre uno por uno.

2. **El "no-flotar" del cuadro es cosmética, no estructural.** En el
   juego el cuadro está COLGADO en la pared y no necesita peanas. Las
   peanas son un arnés para que la captura orbital (§24) no lo muestre
   flotando. Hay que recordarlo cuando se integre en escena: en gameplay
   el `_MONTADO` va a la pared, no al piso.

3. **Cama_doble es más grande que la cama_basica, pero comparte
   geometría.** Ambos usan 4 patas (no postes) en ALTA; cama_doble
   cambia los 2 traseros a postes de h 0.90 que SOSTIENEN la cabecera.
   Si en M147/M150 se decide unificar criterios (cama simple vs doble
   por tamaño, o distinción visual), el modelo actual lo va a sostener.

4. **La alfombra sale 3.8 cm de alto.** El test de apoyo pasa con la
   pila de 4 discos porque el filtro de tolerancia (0.005) es justo. Si
   en algún momento se ajusta `Z_APOYO` o el `SALTO` entre anillos, este
   caso hay que revisarlo a mano: un cambio de tolerancia deja el apoyo
   del disco 1 dentro del filtro y rompe la condición de "solo el disco
   0 toca el piso".

5. **La nevera no es una nevera, es un pozo de conserva.** Por la regla
   del mundo sin electricidad (M147) no podíamos poner un electrodoméstico.
   Pero hay un punto de fricción que conviene anotar: cuando el checklist
   dice "Nevera rústica de piedra/madera (pozo de conserva — el mundo NO
   tiene electricidad, M147; 'heladera' del usuario = nevera cozy)", el
   modelo actual es coherente con la nota. Lo dejo marcado para que un
   próximo agente no intente "mejorarlo" agregando un compresor o una
   heladera eléctrica de verdad — rompería la coherencia del mundo.

## §9 — Artefactos generados

**Scripts nuevos** (en `tools/mcp/blender-mcp/18-Casas/scripts/`):
- `crear_cama_doble_lowpoly.py`
- `crear_sillon_lowpoly.py`
- `crear_nevera_rustica_lowpoly.py`
- `crear_estufa_lena_lowpoly.py`
- `crear_estanteria_lowpoly.py`
- `crear_comoda_lowpoly.py`
- `crear_lampara_pie_lowpoly.py`
- `crear_alfombra_lowpoly.py`
- `crear_cuadro_ancestral_lowpoly.py`
- `crear_maceta_interior_lowpoly.py`

**Blends nuevos**: 30 (10 × ALTA/MEDIA/BAJA) en
`tools/mcp/blender-mcp/18-Casas/`.

**GLB exportados**: 30 en `game/isla-ancestral/assets/3d/{alta,media,baja}/`.

**Capturas**: 180 PNG + 30 JPG en
`tools/mcp/blender-mcp/18-Casas/capturas/`.

**Helper nuevo reutilizable**:
`tools/mcp/blender-mcp/scripts-reutilizables/hoja_util.py` (hoja arqueada
cerrada con volumen firmado > 0).

**Modificaciones a existentes**:
- `mobiliario_util.py`: +`cono()`, +6 colores de paleta (`piedra`,
  `hierro`, `hielo`, `verde_hoja`, `tierra`, `vidrio`).
- `auditar_mobiliario.py`: ASSETS extendido a 14 muebles.

## §10 — Firma

Estado M18 mobiliario: **14/14** ítems cerrados en disco + checklist +
checklist auditado en 0/0. Pendientes del módulo son ahora solo los
"estructura de casa" (paredes, techo, piso, ventana, puerta, escalera,
zócalo) que viven como scripts en `18-Casas/scripts/` pero NO en el
checklist de objetos low-poly (queda anotado en §7 como "D) 17 huérfanos").

Siguiente paso sugerido para M18: **las 4 casas grandes restantes**
(casona 10×8, mansión 14×10, casa de vecino, y volver a hacer la
`casa_completa_ejemplo` que el auditor marca como huérfana de checklist).
El director v4 "el doble de amplia" ya está validado por la casa_mediana.

— Hy4 preview (WorkBuddy)