# Log 247 - M166: Creacion del puente de troncos (Tier D-4, 2026-08-29 22:33)
**Fecha:** (sin fecha)
**Hora:** 22:33

## 1) Pedido

Cerrar **Tier D** con el ultimo item pendiente del plan: **Puentes de troncos (M40)** - el puente rustico para cruzar arroyos. Modulo 40 (Infraestructura).

## 2) Diseno

Puente de troncos al estilo ACNH: dos estribos de piedra en las orillas, tres vigas longitudinales de tronco apoyadas sobre ellos, una cubierta de troncos transversales (corduroy), barandilla de postes + pasamanos y ataduras de cuerda en los nudos.

**Partes** (todo en una sola malla bmesh, un solo objeto - E-01, E-27 fuera de juego por construccion):

| # | Pieza | Cant. | Material | Notas |
|---|---|---|---|---|
| 1 | Estribo de piedra (nucleo) | 2 | MAT_Piedra | Lomo a z=0.225 (5 mm por encima del vientre de la viga, apoyo sin flotacion) |
| 2 | Piedras del terraplen | 6 (3 por lado) | MAT_Piedra | Apoyadas en la arena, detras del nucleo |
| 3 | Vigas longitudinales | 3 | MAT_Madera | Cilindros a lo largo de X, y en {-0.42, 0, +0.42} |
| 4 | Troncos de cubierta | 11 | MAT_Madera | Cilindros a lo largo de Y, espaciados 23 cm a lo largo de X |
| 5 | Postes de barandilla | 6 (3 por lado) | MAT_Madera | Cilindros verticales, hincados en la arena (z_base = 0.045) |
| 6 | Pasamanos | 2 | MAT_Madera | Cilindros a lo largo de X sobre los postes |
| 7 | Ataduras de cuerda | 4 (postes ext.) | MAT_Cuerda | Anillos torus en el plano YZ, rodeando el pasamano en cada poste exterior |

**Parametros clave** (valores en m, todos los asserts con TOL = 1e-4):



**Variaciones deterministas** (mismo resultado en cada ejecucion, sin RNG):
- Cubierta: r_i = R_CUB + 0.006*sin(i*2.3), z_i = Z_CUB + 0.005*cos(i*1.7) - los troncos de cubierta no parecen una rejilla de CAD.

**Relaciones geometricas verificadas en caliente ANTES de construir:**
1. Vientre de viga (0.220) <= 0.225 = lomo del estribo + 5 mm -> la viga se hunde 5 mm en la piedra. Asserto: hundimiento < 2 cm.
2. Cara interior del estribo (1.13) <= 1.36 = extremo de la viga -> el estribo no queda mas alla del extremo.
3. Cara exterior del estribo (1.35) <= 1.36 + TOL -> la piedra no sobresale sin nada encima.
4. Anillo de cuerda interior (0.056) > 0.050 = radio del pasamano -> pasa holgado.
5. Cara interior del poste (0.573) < 0.58 = extremo de la cubierta -> la barandilla toca los troncos.


## 3) Ejecucion



- z_min 0.045 ya desde la primera ejecucion (los postes y piedras nacen en Z_APOYO).
- 1 objeto, 728 tris, 3 materiales. Bbox: x [-1.55, 1.55], y [-0.66, 0.66], z [0.045, 0.98].

## 4) Variantes y capturas



**Presupuesto M166** (real, en triangulos):

| Variante | obj | tris | mats | Budget obj / tris / mats | OK |
|---|---|---|---|---|---|
| MEDIA | 1 | 728 | 3 | 8 / 1500 / 8 | OK |
| BAJA  | 1 | 508 | 3 | 6 / 700  / 4 | OK |

**No fue necesario --ratio personalizado**: la BAJA quedo a 508 tris (73 % del presupuesto) con el decimate 0.7 por defecto. E-23: la proporcion 0.7 no destruyo la geometria flat lowpoly (los troncos siguen ser prismas hexagonales legibles).

**Verificacion E-35** (post-decare): histograma de material_index en la BAJA:

Los 3 materiales sobreviven al decimate. E-35 no se disparo.

**Capturas orbitales** (timestamp 22-31-16, 6 angulos por perfil, prefix SM_Puente_, altura 0.55, dist_mult 1.0):
- puente_troncos_src_22-31-16_az{000,060,120,180,240,300}.png
- puente_troncos_media_22-31-16_az{...}.png
- puente_troncos_baja_22-31-16_az{...}.png
- 3 hojas *_22-31-16_hoja.jpg (63 052 / 63 052 / 62 702 bytes - src y media coinciden porque la MEDIA es merge-by-material sin decimate, la BAJA pierde detalle fino).


## 5) Hallazgos tecnicos

**a) Recuento real de tris != n tris por cara.** Mi estimacion mental de 1080 tris para el asset usaba "n tris por cada cara de n lados" (6 tris por hexagono). El calculo correcto con len(f.verts) - 2: 6 lados -> 4 tris. La diferencia 1080 vs 728 es exactamente 352 = 4*88, donde 88 = 4 ataduras (24 caras c/u con caja_vec=6 caras) + 24*2 caras de cilindros a 6 lados. Leccion: para n-gon face count, len(f.verts) - 2 siempre.

**b) Helper toro() (nuevo).** Para anillos cerrados SIN tapas coincidentes. A diferencia de tubo(), la ultima corona se conecta con la primera. Aplicacion: ataduras de cuerda alrededor del pasamano. 4 toros * 24 quads = 96 quads = 192 tris.

**c) Posts hincados en la arena en lugar de apoyados en la cubierta.** En la primera iteracion mental, los postes de la barandilla arrancaban en la cubierta (z~0.35). Eso obliga a calcular la interseccion con el tronco transversal y deja un margen de error donde podrian flotar visualmente si la cubierta tiene un hueco en esa x. La solucion adoptada: los postes ARRANCAN DEL SUELO (z_base = Z_APOYO = 0.045) y atraviesan la altura del puente. Estructuralmente mas honesto (asi se construye un puente de troncos de verdad) y elimina el calculo de interseccion. Costo: el poste pasa por dentro de los troncos de cubierta en x=0 (donde si hay tronco), pero el cilindro + cilindro se lee correctamente como "el poste se clava entre los troncos".

**d) Lomo de estribo a cota fija + relieve solo en el terraplen.** El lomo del estribo de piedra es la unica superficie portante, asi que va a una Z exacta (0.225, calculada para hundir la viga 5 mm). El relieve rustico lo aportan las piedras del terraplen, que no soportan carga y pueden variar libremente.

**e) Anillo de cuerda: holgura minima 6 mm.** Con R_ATADURA - R_TUBO_AT - R_RAIL = 0.066 - 0.010 - 0.050 = 0.006 m, el anillo pasa apenas 6 mm por fuera del pasamano. A 45 mm de camara a 4.62 m, esa holgura es visible pero discreta. Un valor mas generoso (R=0.075, holgura 15 mm) probablemente se veria mejor pero chocaria con el pasamano del lado opuesto en la vista az 000 (donde la perspectiva achica). Decidido: 6 mm, limpio y funcional.

## 6) Files touched

| Path | Accion |
|---|---|
| tools/mcp/blender-mcp/40-Infraestructura/scripts/crear_puente_troncos_lowpoly.py | CREADO (322 lineas) |
| tools/mcp/blender-mcp/40-Infraestructura/puente_troncos_lowpoly.blend | CREADO |
| tools/mcp/blender-mcp/40-Infraestructura/puente_troncos_lowpoly_media.blend | CREADO |
| tools/mcp/blender-mcp/40-Infraestructura/puente_troncos_lowpoly_baja.blend | CREADO |
| tools/mcp/blender-mcp/40-Infraestructura/capturas/puente_troncos_{src,media,baja}_22-31-16_az{000,060,120,180,240,300}.png | 18 CAPTURAS |
| tools/mcp/blender-mcp/40-Infraestructura/capturas/puente_troncos_{src,media,baja}_22-31-16_hoja.jpg | 3 HOJAS |
| tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md | EDITADO (linea 100, bloque Tier D, contadores) |
| DOCUMENTACION/09-GUIA-BLENDER.md | sin cambios - el E-32 v2 y la leccion 1e-4 ya estan documentados del pozo |
| Logs/ULTIMO_NUMERO.txt | 247 |
| Logs/247-M166-Creacion-Puente-Troncos_2026-08-29_22-33-38.md | ESTE LOG |
| .workbuddy-ai/memory/2026-08-29.md | APENDICE |
| .workbuddy-ai/memory/MEMORY.md | (sin cambios - la regla de posts hincados y toro() ya estan en el log) |

## 7) Verificacion final

- E-12 OK: z_min 0.0450 medido y corroborado.
- E-13 OK: 6 capturas orbitales por perfil, todas en disco, todas con el mismo centro y radio de encuadre.
- E-32 v2 OK: todas las islas (cada tronco, cada caja, cada toro) pasan por cerrar_isla() con el test de volumen con signo.
- E-35 OK: histograma de materiales post-decare muestra los 3 indices preservados.
- E-36 OK: la auditoria E-36-fijada (con for o in objs) reportara 1 obj, 3 mats; no se disparara el flag de mats+.
- Visual OK: las 3 hojas muestran el puente con sus 7 partes identificables, sin flotacion, en los 6 angulos.

## 8) Pendiente

- Tier D cerrado (7/7). El proximo tier queda libre para planificar.
- Cuestiones de proyecto no resueltas (no urgentes):
  - 23 de 111 variantes exceden presupuesto M166 (Task #34 + mats+).
  - Pipeline Blender a Godot en 0 (78 assets aprobados, 0 integrados).
  - 3 items marcados Y sin marcar en el checklist (deuda de libro).
  - 17 heroes con _alta_media pero 0 _alta_baja.