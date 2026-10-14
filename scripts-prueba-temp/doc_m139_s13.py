# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 5.1 Cierre de fase con criterios verificables (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 13 del checklist. **Los H1-H11 ya estaban definidos** (seccion 5, H11 agregado por
mi el 2026-10-14); lo que faltaba eran los **criterios verificables** de cada uno:

| Hit | Criterio verificable (como se comprueba) |
|---|---|
| H1 | Navegar los 6 sectores de Aurora en una sesion sin salir del mundo; GONOGO local pasado |
| H2 | Los 8 NPC del elenco (2.3) con rutina activa y las 10+ lineas de dialogo base por NPC (2.3.3) |
| H3 | Completar las 2 salas del Templo de Brisa (Velas + Carrillon) de punta a punta sin usar consola |
| H4 | Viaje de ida Y vuelta Aurora↔Coral por el Gran Vapor, con desembarco correcto en ambos muelles |
| H5 | 2 tiendas de Aurora + 1 de Coral con ciclo de venta estable; `test_loop_economico.gd` + `test_balance_m93_iter4.gd` en verde |
| H6 | 30 piezas colocables con persistencia perfecta tras guardar/cargar (`buildings_save_provider.gd`) |
| H7 | Save v3 con integridad validada (`validate_save.gd` + checksum HMAC) y menu principal completo |
| H8 | Audio por buses verificados + transiciones por zona/estado sobre `music_context_matrix.json` |
| H9 | Pipeline M108 al 100% (todo asset por cuarentena + validador) y presupuestos de fase OK (4.1) |
| H10 | Playtest 2-4 h con ≥ 5 testers y ≥ 80% "queria seguir jugando" (encuesta M114) |
| H11 | Enclave de Coral terminado e integrado al flujo (muelle, tienda glasswork, Bram) |

**Revision DoD antes de declarar completa la fase (§12 AGENTS.md):** los 3 criterios —
codigo implementado y verificado, documentacion `plan-actual/` alineada con el codigo, y tests
superados. Un hit no se marca cumplido sin evidencia en disco o ejecucion.

**Documento GONOGO firmado:** `DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md` (este archivo)
es el documento GONOGO: queda firmado con Modelo/Plataforma/Fecha del agente que cierra la fase y con
la linea Totales como veredicto numerico. Se considera firmado cuando todos los items estan `[x]` o
tienen `[ ]` con deuda justificada.

**Riesgos residuales que pasan a Alpha:**
1. **Clima base (M32)** — `data/clima/` no existe; la definicion quedo documentada pero sin datos.
2. **Bus ASMR** — hoy cubierto como capas de FeedbackDirector sobre el bus SFX; falta el bus propio.
3. **Menu principal** — no implementado en disco; es la pieza de UI que falta construir.
4. **Catalogo de precios** — de 1691 items con id, solo 31 tienen precio (deuda de M15).
5. **Flujo M17 (construccion)** — el save provider existe pero la fuente M17 no esta implementada.
6. **Verificacion en Play Mode** — los items de consola y flujo completo requieren ejecucion real.

**Mano derecha de continuidad para M140:** se entrega (a) el checklist firmado con las deudas
anteriores, (b) el `03-Diseno.md` con las secciones 2.1.1 / 2.3.1-2.3.3 / 2.5.1 / 2.6.1 / 2.7.1 /
2.8.1 / 3.1 / 4.1 / 5.1 como definicion de fase, (c) los contratos nuevos creados
(`ITienda`, `ITemplo`, `IViajable`, `NpcProfile`, `RutinaIA`, `SesionMaster`), y (d) la lista de
verificaciones pendientes en runtime.

**Registro de learning de la fase:** las lecciones quedaron en los Logs 1819-1824 y en los informes
287-326 — destacadas: (1) verificar cada item contra disco antes de promover, (2) distinguir DISEÑADO
de IMPLEMENTADO, (3) no reservar numeros a mano, (4) confirmar la seccion con el director antes de
arrancar, (5) el detector de agentes colgados con `.ultima-revision-*.txt`.

**0 errores en consola al entrar en Play Mode:** pendiente de ejecucion real — no verificable por
disco. Queda anotado como verificacion de runtime para el cierre.

**Flujo completo verificado en Play Mode:** pendiente de ejecucion real (menu → nuevo juego →
Aurora → templo → viaje a Coral → guardar/cargar). Queda anotado como verificacion de runtime.

**Coste de la fase:** se documenta al cierre con el tiempo real de los 142 items (los lotes cerrados
quedan en los logs 1819-1824 con fecha y hora).

**Inventario de bugs conocidos:** `DOCUMENTACION/11-BUGS.md` es el registro canónico (existe); los
bugs de fase se clasifican por severidad ahi y se referencian desde M101/M102.
"""

ancla = "### 5.1 Cierre de fase"
# insertar antes del final, despues de la tabla de hits
a2 = "---\n**Modelo:**"
idx = t.find("Se aprueba Alpha (M140)")
if idx > 0:
    fin = t.find("\n", idx)
    t = t[:fin+1] + "\n" + seccion.rstrip() + "\n" + t[fin+1:]
    print("seccion 5.1 insertada tras la nota de aprobacion")
else:
    print("AVISO: no se encontro la nota de aprobacion")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
