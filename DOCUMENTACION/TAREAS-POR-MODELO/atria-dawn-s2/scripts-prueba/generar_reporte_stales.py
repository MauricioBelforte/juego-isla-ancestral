#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Genera el reporte de clasificacion a/b/c de los 86 stales del GLOBAL."""
import io, os, json

_d = os.path.abspath(__file__)
for _ in range(5):
    _d = os.path.dirname(_d)
ROOT = _d
INTER = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2", "stales_intermedio.json")
OUT = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2", "stales-clasificacion-a-b-c.md")

with io.open(INTER, encoding="utf-8") as f:
    datos = json.load(f)

# clasificacion: mid -> (letra, motivo)
A = {
  4:   ("a", "Fix de `inferir_estado` aceptado por el director + correccion de protocolo (fix real)"),
  8:   ("a", "BUG-091 fix real: verificacion terraindata / fix provider"),
  12:  ("a", "Cierre FASE 3: 2 items [ ] -> [?] con dependencias documentadas (flips)"),
  41:  ("a", "Auditoria T-D7 bloque 5: 2 [x] de M41 degradados (cambio de estado)"),
  45:  ("a", "Auditoria T-D7 bloque 1: M45 degradado (cambio de estado)"),
  57:  ("a", "Fix real de codigo: MinimapWidget robaba el scroll del zoom (bug del usuario)"),
  59:  ("a", "BUG-115 fix real: HMAC + validacion no vacua"),
  62:  ("a", "BUG-069: ciclos CERRADOS (A1 1 -> 0) + estado medido"),
  64:  ("a", "Drift de la fila M64 corregido por el director (100->78). NOTA: correccion de conteo, no avance de implementacion"),
  74:  ("a", "Fix real: BOM UTF-8 en los 7 .tres de capitulos M74 (Parse Error del editor)"),
  75:  ("a", "Iter. 3: 3 items de persistencia verificados contra codigo (17/130)"),
  76:  ("a", "Auditoria T-D7 bloque 8: 3 [x] de M76 degradados (cambio de estado)"),
  77:  ("a", "Auditoria T-D7 bloque 1: M77 degradado (cambio de estado)"),
  80:  ("a", "Implementacion del nucleo iter. 1 (privacidad.json + PrivacyValidator)"),
  85:  ("a", "Re-auditoria DoD: veredicto INFLADO, 4 [x] -> [ ] + nota. NOTA: degradacion por auditoria, no avance"),
  97:  ("a", "Implementacion iter. 1 (store_page.json + StorePageValidator)"),
  98:  ("a", "Implementacion iter. 1 (trailer_spec.json + TrailerValidator)"),
  99:  ("a", "Implementacion iter. 1 (marketing_plan.json + MarketingValidator)"),
  103: ("a", "T-D8: cierre del falso positivo del frame-budget, [?] del checklist cerrados con justificacion"),
  112: ("a", "Fix real del CI: quitados los 2 `|| true` del job lint de testing.yml"),
  114: ("a", "Implementacion iter. 1 (plantillas playtest + PlaytestValidator)"),
  115: ("a", "Reconciliacion post-revert: codigo real verificado y flips restaurados (0/104 -> sustentado)"),
  118: ("a", "Reversion del estado M118 ✅ -> 🟡 (Caso A) + BUG-072 (cambio de estado)"),
  119: ("a", "P-41 reconciliacion plan<->disco: 9 flips + saneo de 04-Codigo (queda 🟡 QA-drift-doc)"),
  128: ("a", "Completitud de contenido de marca: 5 -> 53/100 (avance real de items)"),
  154: ("a", "Avance significativo de implementacion (131/155)"),
  156: ("a", "Auditoria: 9 [x] degradados a [?] (243 -> 234). NOTA: degradacion por auditoria, no avance"),
  159: ("a", "Iter. 2: catalogo ampliado a 94 .tres + tests ItemDatabase"),
  160: ("a", "Cierre de los 3 pendientes heredados + header M160 (cierre de items)"),
  161: ("a", "Iter. 1: base de datos visual de los 23 NPCs cargada en .tres"),
}

B = {
  3:   "Auditoria T-D4 de M03 contra disco (verificacion, sin flips)",
  7:   "P-40: cierre de discrepancia, veredicto final 'modulos limpios' (sin cambio)",
  9:   "QA visual puntual del impostor de M09 (verificacion)",
  13:  "Re-verificacion §21.8 M13 (sello, sin cambio de items)",
  14:  "QA §21.8 M14 SELLADA (solo sello)",
  15:  "Auditoria T-D7 bloque 4: sustentado, 0 degradaciones",
  16:  "Auditoria T-D7 bloque 3: sustentado, 0 degradaciones",
  19:  "Triage V-3 (bug latente, antorcha no instanciada) + observacion al dueño: sin fix aplicado",
  20:  "Auditoria T-D7 bloque 3: sustentado, 0 degradaciones",
  21:  "Auditoria T-D7 bloque 3: sustentado, 0 degradaciones",
  24:  None,  # M24 NO es stale (fecha al dia tras el Log 1446 de s2) - ignorar
  26:  "Auditoria T-D7 bloque 2: sustentado, 0 degradaciones",
  29:  "Auditoria T-D7 bloque 4: sustentado, 0 degradaciones",
  30:  "Auditoria T-D7 bloque 4: sustentado, 0 degradaciones",
  31:  "Auditoria T-D7 bloque 4: sustentado, 0 degradaciones",
  32:  "QA §21.8 P-31: M32 ✅ sellado (solo sello)",
  33:  "Auditoria T-D7 bloque 5: sustentado, 0 degradaciones",
  34:  "Auditoria T-D7 bloque 5: sustentado, 0 degradaciones",
  35:  "Auditoria T-D7 bloque 5: sustentado, 0 degradaciones",
  36:  "Auditoria T-D7 bloque 5: sustentado, 0 degradaciones",
  38:  "QA §21.8 M38: verificacion OK, flag de concentracion familiar (sin sello propio)",
  50:  "Auditoria T-D7 bloque 6: sustentado, 0 degradaciones",
  51:  "Auditoria T-D7 bloque 6: sustentado, 0 degradaciones",
  52:  "QA §21.8 M52 SELLADA (solo sello)",
  53:  "Auditoria T-D7 bloque 6: sustentado, 0 degradaciones",
  54:  "Auditoria T-D7 bloque 6: sustentado, 0 degradaciones",
  58:  "Paquete opcion 1 bloque A: M58 sustentado, 0 degradaciones",
  60:  "QA §21.8 M60 SELLADO (solo sello)",
  63:  "Re-QA de tercero: sello §21.8 de M63 re-establecido (solo sello)",
  78:  "BUG-121 cerrado con fix en fauna; M78 aparece como '0 SCRIPT ERROR en M78' (mencion pasiva)",
  109: "Reparacion de trazabilidad documental de M109 (mantenimiento de docs, sin cambio de items)",
  83:  "BUG-078: verificacion del job `godot-lint` en checkout limpio (verificacion)",
  89:  "QA §21.8 M89 SELLADA + 1 hallazgo ajeno reportado (solo sello)",
  90:  "Auditoria T-D7 bloque 7: M39 sustentado; M90 'deuda señalada' (sin flip)",
  91:  "Paquete opcion 1 bloque A: M91 sustentado, 0 degradaciones",
  93:  "Paquete opcion 1: M93 sustentado, 0 degradaciones",
  100: "Re-auditoria DoD: veredicto DEUDA REAL, 'no flip, no inflado' (explicito)",
  102: "Verificacion cruzada §21.8 M102 (solo validacion de artifacts)",
  105: "Re-auditoria DoD ronda 2: 'Cero flips' (explicito)",
  106: "QA §21.8 M106 SELLADO (solo sello)",
  107: "BUG-121 cerrado con fix en fauna; M107 solo aparece como '0 SCRIPT ERROR en M107' (mencion pasiva)",
  108: "Re-auditoria DoD ronda 2: 'Cero flips' (explicito)",
  110: "BUG-121 cerrado con fix en fauna; M110 aparece como '0 SCRIPT ERROR en M110' (mencion pasiva)",
  111: "QA §21.8 M111 (sello de DeepSeek; fixes H1/H4 son de M78, no de M111)",
  113: "Re-auditoria DoD: veredicto DEUDA REAL, 'no flip, no inflado' (explicito)",
  116: "Paquete opcion 1: M116 sustentado, 0 degradaciones",
  131: "QA §21.8 M131: verificacion OK (solo sello)",
  133: "QA cruzado §21.8 P-34: sello de doble fuente (solo sello)",
  134: "QA cruzado §21.8 P-34: sello de doble fuente (solo sello)",
  135: "QA cruzado §21.8 P-34: sello de doble fuente (solo sello)",
  136: "QA cruzado §21.8 P-34: sello de doble fuente (solo sello)",
  149: "Verificacion del [?] restante (99/100): veredicto deuda externa (sin flip)",
  152: "Paquete opcion 1: M152 sustentado, 0 degradaciones",
  155: "Auditoria T-D7 bloque 3: sustentado, 0 degradaciones",
  162: "Auditoria T-D7 bloque 2: sustentado, 0 degradaciones",
  164: "Auditoria T-D7 bloque 2: sustentado, 0 degradaciones",
  165: "RE-QA cruzado §21.8 M165 (solo sello)",
}

todos = {d["mid"] for d in datos}
clasif = {}
for mid, (letra, motivo) in A.items():
    clasif[mid] = (letra, motivo)
for mid, motivo in B.items():
    if motivo is None:
        continue
    clasif[mid] = ("b", motivo)

sin_clasif = todos - set(clasif)
doble = [m for m in clasif if m not in todos]
print("total stales:", len(todos))
print("clasificados:", len(clasif))
print("SIN clasificar:", sorted(sin_clasif))
print("clasificados de mas (no en L-06):", sorted(doble))

na = sum(1 for m in clasif if clasif[m][0] == "a")
nb = sum(1 for m in clasif if clasif[m][0] == "b")
nc = sum(1 for m in clasif if clasif[m][0] == "c")
print("(a)=%d (b)=%d (c)=%d" % (na, nb, nc))

lineas = []
lineas.append(u"# Frente: 86 timestamps stale del GLOBAL — clasificación a/b/c")
lineas.append(u"")
lineas.append(u"**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)")
lineas.append(u"**Plataforma:** Kilo Code")
lineas.append(u"**Fecha:** 2026-10-08")
lineas.append(u"**Encargo:** director, msg 135 §3 (frente asignado a s2)")
lineas.append(u"**Fuente:** `TAREAS-POR-MODELO/atria-dawn-s3/L-06-timestamps-stale.md` (86 stales)")
lineas.append(u"**Estado:** desglose ANTES de tocar el GLOBAL (el director pidió ver el criterio)")
lineas.append(u"")
lineas.append(u"## Criterio operacional propuesto")
lineas.append(u"")
lineas.append(u"- **(a) Actividad real que avanzó el módulo → actualizar `Última actividad`.** El log registra")
lineas.append(u"  trabajo sustantivo sobre el módulo: implementación/iteración con código o data nueva,")
lineas.append(u"  fix de un bug del propio módulo, cierre de items pendientes, o flips de items")
lineas.append(u"  (incluyendo degradaciones y correcciones de drift, que cambian la fila del GLOBAL).")
lineas.append(u"- **(b) Actividad que NO cambió el estado → NO actualizar, con motivo.** El log solo")
lineas.append(u"  auditó/verificó/selló sin tocar items (auditorías T-D7 \"sustentado, 0 degradaciones\",")
lineas.append(u"  QA §21.8 confirmatoria, re-verificaciones, veredictos \"deuda real\" sin flip), o el")
lineas.append(u"  módulo aparece como mención pasiva (fix de OTRO módulo).")
lineas.append(u"- **(c) Error → arreglar.** Fecha imposible, formato roto, o log que no trata del módulo")
lineas.append(u"  (falso positivo del método de s3, que indexa por nombre de archivo).")
lineas.append(u"")
lineas.append(u"## Totales")
lineas.append(u"")
lineas.append(u"| Categoría | Cantidad | Acción |")
lineas.append(u"|-----------|----------|--------|")
lineas.append(u"| (a) Avance/cambio de estado | %d | actualizar `Última actividad` a la fecha del log |" % na)
lineas.append(u"| (b) Sin cambio de estado | %d | NO actualizar (motivo documentado abajo) |" % nb)
lineas.append(u"| (c) Error | %d | arreglar |" % nc)
lineas.append(u"")
lineas.append(u"**Hallazgo (c):** 0 errores. Los 86 logs existen, mencionan al módulo y las fechas del")
lineas.append(u"GLOBAL son fechas pasadas válidas. El método de s3 (indexar por nombre de archivo)")
lineas.append(u"no produjo falsos positivos en este lote.")
lineas.append(u"")
lineas.append(u"## Detalle (a) — actualizar (%d)" % na)
lineas.append(u"")
lineas.append(u"| MID | Módulo | Log | Fecha nueva | Motivo |")
lineas.append(u"|-----|--------|-----|-------------|--------|")
for d in sorted(datos, key=lambda x: x["mid"]):
    if clasif[d["mid"]][0] == "a":
        lineas.append(u"| %d | %s | %d | %s | %s |" % (d["mid"], d["nombre"], d["log"], d["fecha_log"], clasif[d["mid"]][1]))
lineas.append(u"")
lineas.append(u"## Detalle (b) — NO actualizar (%d)" % nb)
lineas.append(u"")
lineas.append(u"| MID | Módulo | Log | Motivo (no hubo cambio de estado) |")
lineas.append(u"|-----|--------|-----|-------------------------------|")
for d in sorted(datos, key=lambda x: x["mid"]):
    if clasif[d["mid"]][0] == "b":
        lineas.append(u"| %d | %s | %d | %s |" % (d["mid"], d["nombre"], d["log"], clasif[d["mid"]][1]))
lineas.append(u"")
lineas.append(u"## Notas especiales para el director")
lineas.append(u"")
lineas.append(u"3 de los 30 (a) son cambios por **auditoría/saneamiento**, no por implementación:")
lineas.append(u"- **M64** (Log 1330): drift de conteo corregido por el director (100→78).")
lineas.append(u"- **M85** (Log 1424): 4 `[x]`→`[ ]` por veredicto DoD INFLADO.")
lineas.append(u"- **M156** (Log 1388): 9 `[x]`→`[?]` (243→234) por auditoría.")
lineas.append(u"Los cuento como (a) porque la fila del GLOBAL sí cambió y la columna `Última actividad`")
lineas.append(u"debe acompañar ese cambio para mantener el tablero consistente. Si el director prefiere")
lineas.append(u"reservar (a) solo para implementación real, estos 3 pasan a (b) — decisión suya.")
lineas.append(u"")
lineas.append(u"Restricciones respetadas: no se toca Progreso/Estado/Agente de ninguna fila; no se")
lineas.append(u"tocan filas 🔵/🔴 de otros agentes en curso; el GLOBAL se editará con Python")
lineas.append(u"`io.open(..., newline=\\\"\\\")` (LF puro). **Nada aplicado todavía** — espero la OK del director.")
lineas.append(u"")

with io.open(OUT, "w", encoding="utf-8", newline="") as f:
    f.write(u"\n".join(lineas))
print("escrito:", OUT)
