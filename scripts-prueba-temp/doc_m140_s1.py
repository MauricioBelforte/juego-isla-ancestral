# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 1.1 Historia jugable de Alpha (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 1 del checklist con respaldo en disco + definicion. **La estructura narrativa ya
existe**: `DOCUMENTACION/22-Historia-Principal/plan-actual/02-Analisis.md` define prologo, capitulos
1-6, capitulo final, finales alternativos y final secreto. Los 6 capitulos son el esqueleto de los
6 sellos de Alpha.

**Los 6 Sellos (mapeo 1:1 con los capitulos existentes de M22):**

| Sello | Capitulo | Isla | Contenido |
|---|---|---|---|
| S1 | 1 - Primer Baile de la Brisa | Aurora | **libre**: tutorial + primeros vecinos |
| S2 | 2 | Aurora | amistades (nivel 4 de `friendship.json`) |
| S3 | 3 | Aurora | templo + coleccionables |
| S4 | 4 - El Valle de los Vientos | Aurora | agricultura + museo (7 sellos menores) |
| S5 | 5 | Coral | viajes + eventos |
| S6 | 6 - El Corazon del Mundo | Ceniza | todos los sistemas + Sello perfecto |

Simbolos ya presentes en disco: `sym_sello_raiz`, `sym_sello_coral`, `sym_sello_ceniza`,
`sym_sello_aurora` (`inventario_2d.json`).

**3 actos:** **Descubrimiento** (S1-S2: Aurora y su gente) -> **Crisis** (S3-S5: los templos, el
viaje, lo que se pierde) -> **Resolucion** (S6: la Camara del Sello de M26).

**Prerrequisitos de cada Sello:** S1 libre · S2 = 2 amistades a nivel 4 · S3 = Templo de Brisa
completo + 10 coleccionables · S4 = 5 recetas de agricultura + 20 piezas de museo · S5 = Gran Vapor
operativo + 3 eventos · S6 = los 5 anteriores. Cada uno se valida contra datos, no contra flags
sueltos.

**Modelado con `ICondicionDeSello`:** NO EXISTE en disco — queda `[ ]` con nota: la interfaz se
disena como contrato (persistida en save v3) cuando se implemente el sistema de sellos (M22).

**Pistas suaves en el diario (M153):** el diario (modulo 55-Diario-Del-Jugador existe) muestra
entradas por sello obtenido sin adelantar el siguiente; el misterio se mantiene.

**Epilogo en el faro tras el Sello 6:** ya esta esbozado en M22 ("La Brisa y el Sello": restaurar el
Sello en la Camara). Se define el epilogo como escena estatica en el faro de Aurora con el mural y
el balance de los 6 sellos.

**3 rutas de orden de sellos sin bloqueos (M66):** (1) **historia** S1->S6 clasico; (2) **social**
S1->S2->S4->S3->S5->S6 (priorizando amistades y agricultura); (3) **exploracion**
S1->S5->S3->S2->S4->S6 (viajando antes). Las 3 llegan a S6 sin bloqueo porque ningun sello exige un
sello posterior.

**Retorno seguro anti-softlock:** ningun sello se pierde por vender/descartar items clave — los
items de sello son `no_descartables` (regla M66); los coleccionables se pueden re-obtener.

**Elysia:** personaje existente en la biblia (`147-World-Building`: "Elysia: misterio central, capas
de revelacion, M153"). Presencia: aparece como voz/simbolo en S2 y se revela en el Acto 3.

**Coherencia con biblia M147:** los 6 sellos y sus nombres salen de la biblia; los eventos de sello
canonicos quedan registrados ahi. Verificado: M147 y M153 existen en disco.

**Dialogos de hitos de sellos (10+ lineas, M21):** base real — hay 19 archivos de dialogo contextual
por capitulo y NPC (`aur/cor/riz_00X_capN_mision.json`). Los dialogos de hito de sello se escriben
sobre esa estructura cuando se implemente M22.

**Musica de cada acto (M41):** respaldado — `music_context_matrix.json` ya tiene `narr_sello` y
`evento_sello` (capa `base_aurora` + `evento_sello`). La musica de acto se resuelve como variacion
de esa capa por acto.

**30+ misiones secundarias:** **NO cumplido** — `data/balance/quests.json` tiene **2 misiones**
(verificado). Queda `[ ]` como deuda de M23 con el conteo real anotado.

**Registro de estado de historia en el diario (M55):** el diario existe (modulo 55); el registro de
sellos y misiones por entrada queda definido aqui como consumidor.
"""

ancla = "## 2. Mec"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 1.1 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
