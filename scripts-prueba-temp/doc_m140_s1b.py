# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 1.4 Historia jugable: los 6 Sellos (cerrada 2026-10-14, step-5-kilocode)

Complementa 1.3 y 2.3 con el detalle verificado contra disco. **La estructura narrativa ya existe**:
`DOCUMENTACION/22-Historia-Principal/plan-actual/02-Analisis.md` define prologo, capitulos 1-6,
capitulo final, finales alternativos y final secreto. Los 6 capitulos son el esqueleto de los 6 sellos.

**Los 6 Sellos (mapeo 1:1 con los capitulos de M22):**

| Sello | Capitulo | Isla | Contenido |
|---|---|---|---|
| S1 | 1 - Primer Baile de la Brisa | Aurora | **libre**: tutorial + primeros vecinos |
| S2 | 2 | Aurora | amistades (nivel 4 de `friendship.json`) |
| S3 | 3 | Aurora | templo + coleccionables |
| S4 | 4 - El Valle de los Vientos | Aurora | agricultura + museo (7 sellos menores) |
| S5 | 5 | Coral | viajes + eventos |
| S6 | 6 - El Corazon del Mundo | Ceniza | todos los sistemas + Sello perfecto |

Simbolos ya en disco: `sym_sello_raiz`, `sym_sello_coral`, `sym_sello_ceniza`, `sym_sello_aurora`
(`inventario_2d.json`).

**3 actos:** **Descubrimiento** (S1-S2) -> **Crisis** (S3-S5) -> **Resolucion** (S6, la Camara del
Sello de M26).

**Prerrequisitos (validados contra datos, no flags sueltos):** S1 libre · S2 = 2 amistades a nivel 4
· S3 = Templo de Brisa completo + 10 coleccionables · S4 = 5 recetas de agricultura + 20 piezas de
museo · S5 = Gran Vapor operativo + 3 eventos · S6 = los 5 anteriores.

**3 rutas de orden sin bloqueos (M66):** (1) **historia** S1->S6 clasico; (2) **social**
S1->S2->S4->S3->S5->S6; (3) **exploracion** S1->S5->S3->S2->S4->S6. Las 3 llegan a S6 porque ningun
sello exige uno posterior.

**Anti-softlock:** los items de sello son `no_descartables` (regla M66); los coleccionables se
re-obtienen. Ningun sello se pierde por vender o descartar.

**Elysia:** existente en la biblia (`147-World-Building`: "Elysia: misterio central, capas de
revelacion, M153"). Presencia como voz/simbolo en S2, revelacion en el Acto 3.

**Musica de acto (M41):** respaldado — `music_context_matrix.json` ya tiene `narr_sello` y
`evento_sello`; la musica de acto se resuelve como variacion de esa capa por acto.

**Dialogos de hitos (M21):** base real — 19 archivos de dialogo contextual por capitulo y NPC
(`aur/cor/riz_00X_capN_mision.json`); los dialogos de hito se escriben sobre esa estructura.

**Hallazgo honesto (deuda de M23):** `data/balance/quests.json` tiene **2 misiones**, no las 30+ que
pide la tabla 2.3. Queda anotado como deuda real con el conteo verificado.
"""

ancla = "## 2. Dise\u00f1o de sistemas integrados"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 1.4 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
