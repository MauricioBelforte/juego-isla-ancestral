# -*- coding: utf-8 -*-
import io

P = r"DOCUMENTACION\TAREAS-POR-MODELO\G-5.3-Flash-Agente\CRONOMETRO-ACTIVO.md"
s = io.open(P, encoding="utf-8").read()

old = ("REPORTE AL DIRECTOR EN CADA VUELTA: escribir en tu canal qu\u00e9 hiciste (tarea(s), estado,\n"
       "evidencia \u2014 aunque no cierres todo) + marca [x] honesta en el BACKLOG (solo verificable en\n"
       "disco) + fila de CHECKLIST-GLOBAL si el m\u00f3dulo aplica.")
assert old in s, "ancla vieja no"
new = ("REPORTE AL DIRECTOR EN CADA VUELTA \u2014 OBLIGATORIO SIN EXCEPCIONES: escribir en tu canal\n"
       "M\u00cdNIMO 1 L\u00cdNEA aunque no haya tanda ni novedad (guardia: suites + filas en estado). Si no\n"
       "escrib\u00eds, el fundador/director te ven INACTIVO (lecci\u00f3n ping 226). La directiva \u201csolo novedad\n"
       "material\u201d NO anula este piso por ciclo. Adem\u00e1s: (tarea/estado/evidencia) + marca [x] honesta\n"
       "en el BACKLOG + fila de CHECKLIST-GLOBAL si el m\u00f3dulo aplica.")
s = s.replace(old, new)

h_old = "| 2026-10-22 01:41 | **Refuerzo del PASO 2-BIS**: motivo de fondo expl\u00edcito \u2014 el fundador/director detectan actividad SOLO por escritura en el canal; sin write te ven inactivo. Reporte de m\u00ednimo 1 l\u00ednea EN CADA VUELTA y pedido de tareas obligatorio cuando todo est\u00e1 bloqueado | orden del fundador (\"si no le escrib\u00eds no te ve activo\") |"
h_add = "| 2026-10-22 03:28 | **PISO de reporte SIN EXCEPCIONES**: m\u00edn 1 l\u00ednea por vuelta aunque no haya novedad (lecci\u00f3n: 4 vueltas sin ping que el fundador detect\u00f3; \"solo novedad material\" NO anula el piso) | orden del fundador |"
if h_old in s and h_add not in s:
    s = s.replace(h_old, h_old + "\n" + h_add)

io.open(P, "w", encoding="utf-8", newline="\n").write(s)
print("doc reforzada ok")
