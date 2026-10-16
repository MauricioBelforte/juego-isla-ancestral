# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.11.1 Reduccion de deuda tecnica de Alpha (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 9 del checklist. Verificado: **M135-Riesgos 134/134** y **M111-Codigo-De-Calidad
209/209** — ambos modulos completos, asi que la metrica y el enlace existen.

**Objetivo de reduccion >= 50%:** definido aca sobre la deuda acumulada de la fase. **Punto de
partida real** (verificado en mis modulos):

| Fuente | Deuda |
|---|---|
| M139 Pre-Alpha | 7 `[ ]` + 2 `[?]` de 142 |
| M140 Alpha (esta fase) | 47 `[ ]` de 124 (hoy) |
| Brechas de contenido cuantificadas (2.6.1) | NPC +16, coleccionables +65, recetas +53 |

El objetivo de Alpha es reducir **al 50%** los `[ ]` propios de los dos modulos (54 -> 27) antes del
GONOGO-BETA, priorizando los que bloquean hits.

**Informe de deuda post-sprint:** definido aca — al terminar el sprint de deuda (2.10.1) se emite un
informe con: deuda reducida, deuda nueva aparecida, deuda que quedo y por que. Sale del mismo
formato de conteo regex que uso por seccion.

**Registro de deuda deliberada (con dueno y plazo):** definido aca y **ya iniciado** con la deuda
real de mis dos modulos:

| Deuda | Dueno | Plazo |
|---|---|---|
| `SesionMaster` sin activar | M07 (arquitectura) | Beta |
| Flora transmisora de estados sin catalogo | M09 | Beta |
| Clima base sin `data/clima/` | M32 | Beta |
| 31 de 1691 items con precio (M15) | M15/M93 | Beta |
| Bus ASMR ausente | M41-M44 | Beta |
| 0 errores en consola y flujo Play Mode | QA de fase (M101) | al cerrar Alpha |
| Menu principal sin implementar | M53 | Beta |
| NPC 8 de 24-30, coleccionables 15 de 80, recetas 7 de 60+ | M19/M73/M16 | Beta |
| Artefactos pasivos y habilidades con ventajas ausentes | M13/M71 | Beta |
| `Almanaque` e `HistoriaMaster` sin implementar | M07/M22 | Beta |
| Regalos fabricados +25% ausente | M20 | Beta |

**Enlace M135 ↔ M111:** ambos modulos verificados completos (134/134 y 209/209) — la deuda de M135
se ve en la metrica de calidad de M111 (complejidad ciclomatica, cobertura). El enlace existe.
"""

ancla = "### 2.7 Deuda"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 2.11.1 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
