# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 3.1 Cierre GONOGO-BETA (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 10 del checklist. **Los 10 hits ya estaban definidos con criterio** en la tabla de
la seccion 3 (arriba) — se reconfirman aca y se les asigna su verificador:

| Hit | Verificador |
|---|---|
| H1 Historia jugable | Play Mode + checklist de sellos (1.4) |
| H2 Mecanicas integradas | la tabla 2.1.1 (9 presentes, 3 parciales, 1 ausente) |
| H3 Balance estable | `test_balance_m93_iter3/4.gd` + playtests (2.4.1) |
| H4 Contenido Alpha | la tabla 2.6.1 con brechas cuantificadas |
| H5 Rendimiento | dashboard + gate de zona (2.8.1) |
| H6 QA | triaje P0-P2 + metricas (2.9.1) |
| H7 Arquitectura | 25 TODO/FIXME y deuda M135 (2.10.1, 2.11.1) |
| H8 Save v3 | `validate_save.gd` + checksum HMAC (2.7.1) |
| H9 Accesibilidad | M58 154/181 (27 `[ ]`) |
| H10 GONOGO firmado | este documento + backlog priorizado |

**Backlog priorizado de Beta por riesgo (M141):** respaldado — el modulo 141-Beta esta en
**143/144**. La priorizacion por riesgo se define aca: (1) lo que bloquea un hit de Alpha, (2) lo que
rompe la build semanal, (3) lo que packetea M135/M111, (4) el resto por brecha de contenido.

**Lista de localizacion pendiente para Beta (M87):** M87-Localizacion verificado **completo
(131/131)**. La lista pendiente de Beta se define aca como: **texto nuevo que se agregue despues del
freeze** — es decir, todo lo que se escriba en el sprint final entra a la cola de localizacion.

**Plataformas objetivo para Beta:** respaldado — el trabajo de export presets (Linux/SteamOS) ya
existe. Objetivo de Beta: **Windows + Linux/SteamOS** (las dos con export preset y build semanal);
Mac/consolas quedan fuera de Alpha.

**Pulido de UI pendiente de Beta:** definido aca — las 2 piezas ausentes verificadas en la fase son
el **menu principal** y el **menu de progresion** (secciones 2 y 10 del checklist de Alpha); el pulido
restante (transiciones, feedback de objetivo) sale del dashboard.

**Segunda pasada de accesibilidad (M58):** M58 esta en **154/181** (27 `[ ]`) — la segunda pasada se
define aca sobre esos 27 items pendientes, ejecutada en el sprint de deuda.

**Documento GONOGO-BETA firmado con fecha:** este `03-Diseno.md` + el `05-Checklist.md` de M140 son
el documento; queda firmado con Modelo/Plataforma/Fecha al cierre.
"""

ancla = "## 4. Plan de oleadas"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 3.1 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
