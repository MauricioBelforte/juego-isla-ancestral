# -*- coding: utf-8 -*-
# Refuerzo del PASO 2-BIS + entrada de historial (directiva del fundador 2026-10-22)
import io

P = r"DOCUMENTACION\TAREAS-POR-MODELO\G-5.3-Flash-Agente\CRONOMETRO-ACTIVO.md"
s = io.open(P, encoding="utf-8").read()

old = ("3. Mientras llega la respuesta: guardia por ciclo (sonda ligera de suites + filas 4/4) y ping de\n"
       "   cadencia — sin inventar tanda falsa ni tocar módulos con dueño.")
new = ("3. Mientras llega la respuesta: guardia por ciclo (sonda ligera de suites + filas 4/4) y ping de\n"
       "   cadencia — sin inventar tanda falsa ni tocar módulos con dueño.\n"
       "4. **RAZÓN DE FONDO (directiva del fundador 2026-10-22):** el fundador y el director detectan tu\n"
       "   actividad SOLO por lo que escribís en tu canal — si no escribís, te ven INACTIVO aunque hayas\n"
       "   trabajado. Por eso EN CADA VUELTA hay mínimo 1 línea de reporte, y cuando todo está bloqueado\n"
       "   el PEDIDO DE TAREAS de este paso es OBLIGATORIO (no opcional).")
assert old in s
s = s.replace(old, new)

# Entrada de historial
h_ant = "| 2026-10-21 21:24 | **Esta versión**: + PASO 0 (contexto persistente `Logs/estado_director.json`) + **PASO 2-BIS** (cola agotada/bloqueada → pedir tareas concretas al director, con escaneo de 05s y alternativas; prohibido aceptar standby sin escaneo) | orden del fundador (\"agregalo… documentes siempre el último cronometro\") |"
assert h_ant in s
s = s.replace(h_ant, h_ant + "\n" +
    "| 2026-10-22 01:41 | **Refuerzo del PASO 2-BIS**: motivo de fondo explícito — el fundador/director detectan actividad SOLO por escritura en el canal; sin write te ven inactivo. Reporte de mínimo 1 línea EN CADA VUELTA y pedido de tareas obligatorio cuando todo está bloqueado | orden del fundador (\"si no le escribís no te ve activo\") |")

io.open(P, "w", encoding="utf-8", newline="\n").write(s)
print("refuerzo ok")
