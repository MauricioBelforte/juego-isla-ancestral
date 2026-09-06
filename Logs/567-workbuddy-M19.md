# Log 567 — WorkBuddy — M19 NPC base v5 (fix hombros-para-abajo)

**Fecha:** 2026-09-03
**Módulo:** 19-NPCs
**Tarea:** rehacer `crear_npc_base_lowpoly.py` para responder al feedback
*"de la cabeza para arriba esta muy bien pero el diseño de los hombros para
abajo esta raro el torso mejoralo"*.

## Lo que diagnostiqué (con captura visual de v4 + auditoría numérica)

La v4 leía "raro" por DOS problemas que la captura orbital evidenció:

1. **Sin cap de hombro real.** La línea de hombro del loft (rx=0.202)
   apenas superaba al pecho (0.196) y colapsaba a rx=0.112 en 5.5 cm. El
   deltoides humano sobresale 4-5 cm del tórax. Sin esa cápsula, los
   hombros leen como un cierre de perchero.
2. **Pecho plano.** ry=0.100-0.124 daba un ratio ancho:profundo 1.74:1
   (tablero). Perfil de az 180 era una tabla plana.

Además: shorts como cilindro pegado (4 anillos casi rectos, sin cintura,
sin cinturón); piernas con hueco interior en el short (entre z=0.685 y
0.770 no había pierna).

## Lo que cambié en v5 (NO se tocaron cabeza/cara/pelo — aprobados)

- **Deltoides como elipsoides separados.** ico `subdiv=2`, radios
  (0.084, 0.070, 0.052). **Asimétricos en Z** (der 1.175, izq 1.158) →
  el hombro del lado que carga peso queda más bajo, lectura natural del
  contrapposto. Unirlos al torso con `aplicar()` previo (E-75).
- **Pecho profundo.** ry 0.118 → 0.132 en los anillos del pecho
  (anillo 1.110, 1.165, 1.205). Ratio 1.40-1.66 (anatómicamente real).
- **Trapecio más largo.** 1.205 → 1.245 → 1.290 (8.5 cm de pendiente)
  en vez de 1.220 → 1.270 (5.5 cm). Menos cono, más rampa.
- **Cuello metido atrás.** cy −0.013 vs −0.004. El cuello se ve,
  no se funde con el pecho.
- **Shorts A-line.** Ruedo ancho (rx 0.224) → cintura afina (rx 0.167).
  Clearance mínimo 1.5 cm vs el torso.
- **Cinturón de cuero.** 3 anillos sobre el short, MAT_botas. Une al
  short → SM_NPC_RopaBase con 2 mats (E-42 caras USADAS, no slots).
- **Piernas más largas.** Anillo superior z=0.800 (era 0.770) → rellena
  el interior del short (antes tubo hueco).
- **Brazos re-anclados.** Hombro parte del CENTRO del deltoide
  (der x=0.126, izq x=-0.153) no del borde del torso. Hombro más grueso
  (0.066 vs 0.062).
- **Auditoría de silueta numérica.** Cuando la visión está bloqueada
  por el filtro de imágenes, esta función (en `crear_npc_base_lowpoly.py`)
  muestrea la silueta a 6 alturas clave vía vértices reales (E-24).
  Costo: ~50 ms. Salida:

  ```
  z=0.790 (cadera):    ancho=0.388  profundidad=0.256  ratio=1.52
  z=0.960 (cintura):   ancho=0.302  profundidad=0.216  ratio=1.40
  z=1.110 (pecho):     ancho=0.369  profundidad=0.256  ratio=1.44
  z=1.165 (pecho alto): ancho=0.439  profundidad=0.264  ratio=1.66
  z=1.205 (hombro):    ancho=0.402  profundidad=0.256  ratio=1.57
  z=1.175 (deltoide D): ancho=0.431  profundidad=0.264  ratio=1.63
  ```

  Cintura ratio 1.40 confirma que NO es un cilindro. La curva
  cadera → cintura → pecho alto → deltoide (0.39 → 0.30 → 0.44 → 0.43)
  confirma la silueta S del torso humano.

## Resultados

- **14 SM_ / 1672 tris / 6 mats** ALTA — sigue dentro del presupuesto
  (≤16 / ≤6000 / ≤12).
- Huella E-50: 18 verts, 0.31 × 0.30 m (pasa).
- MEDIA: 6 obj / 1672 tris / 6 mats.
- BAJA: 5 obj / 1122 tris / 4 mats.
- 3 GLB (120/96/73 KB) + 3 `.glb.import` (E-65). Import verificado
  por conteo (glb == .glb.import).
- Captura orbital v5: `_hoja_npc_base_v5.jpg` (v4 → v5 diff muestra
  silueta de hombro y shorts A-line).

## Nueva lección: **E-81**

> Torso humano estilizado: el hombro NO es un anillo más ancho, es un
> CAP elipsoidal separado.
>
> Un loft de elipses con `rx/ry > 1.5:1` da silueta LENS (extremos
> puntiagudos), NO cap de hombro. Para tener un cap real hay que:
> (1) profundizar el pecho (`ry ≥ 0.13` en los anillos del pecho),
> (2) unir un elipsoide separado como deltoide (NO anillo más ancho),
> (3) alargar el trapecio a 8+ cm de pendiente. Asimétrico en Z crea
> el tilt natural del contrapposto.

Documentado en `DOCUMENTACION/09-GUIA-BLENDER.md` §3 (E-81) y §4
(checklist).

## Side effects verificados

- **Sombrero_paja**: re-export OK (28/25/19 KB). Una WARNING de Blender
  sobre `SM_NPC_M_cinta.001` aparece al exportar — es ruido benigno del
  extractor del GLTF exporter (mesh fantasma con nombre auto-generado).
  GLB final correcto: el JSON contiene `SM_NPC_Sombrero_Cinta` y
  `SM_NPC_Sombrero_Lazo` limpios.
- **Sombrero_paja MEDIA**: variantes re-generadas preservando el z_min
  -0.081 (Empty `_MONTADO`, E-80) — no se hundió al piso.

## Estado M19

- ✅ NPC base v5 — premium, 14 SM_ / 1672 tris / 6 mats, encaje verificado
  numéricamente + hoja de contacto.
- ✅ Sombrero de paja v1 — primera versión aprobada.
- Pendientes M19: cabeza NPC 3 variantes, vestimenta campesina,
  vestimenta pescador, anciano del templo, NPC sentado.
- M19 assets 3D **LIBERADO** (fila 19 del CHECKLIST-GLOBAL actualizada
  a "—", lock liberado).

## Archivos tocados

- `tools/mcp/blender-mcp/19-NPCs/scripts/crear_npc_base_lowpoly.py`
  (rewritten §3, §7, §9, §11, §12, + auditoría al final).
- `DOCUMENTACION/09-GUIA-BLENDER.md` (E-81 + checklist item).
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` (fila NPC base
  actualizada a v5 con métricas y E-81).
- `CHECKLIST-GLOBAL.md` fila 19 (lock liberado, status assets 3D).
- `.workbuddy-ai/memory/MEMORY.md` (E-81 añadida).
- `.workbuddy-ai/memory/2026-09-03.md` (este log).