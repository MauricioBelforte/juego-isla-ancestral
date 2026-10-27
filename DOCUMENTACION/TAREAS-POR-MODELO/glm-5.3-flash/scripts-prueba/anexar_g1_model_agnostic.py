# -*- coding: utf-8 -*-
"""Anexa la regla gate-2 model-agnostic a la doc canonica (directiva fundador 27oct)."""
p = r"DOCUMENTACION\GUIA-GODOT\13-sondas-runtime-gate2.md"
tex = open(p, encoding="utf-8").read()
adenda = """

## GATE-2 MODEL-AGNOSTIC — re-asignación permanente (directiva del fundador 27oct: el método sobrevive a los agentes)

El gate-2 (sondas de runtime) **no pertenece a ningún agente**: pertenece al repositorio. Reglas para que funcione con CUALQUIER agente que tome la tarea:

1. **Prerequisitos del agente-asignado (mínimos):** acceso de lectura al repo + MCP de Godot (run_project/get_debug_output) o poder correr el binario headless (4.7.2) + capacidad de citas textuales. Ningún requisito de modelo, plataforma o vendor.
2. **Onboarding express (30 min):** leer `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md` (método completo) + esta guía → ejecutar 2 sondas calibradas comparadas con un veredicto anterior (referencia: los casos de la tabla) → firma dual cuando exista transmisor; si no existe, doble verificación con re-medición scriptable.
3. **Independencia (§21.8):** el gate-2 NO puede verificar trabajo que el propio agente produjo. Cualquier modelo sirve EXCEPTO el productor.
4. **Sondas que NO requieren agente (scripts permanentes):** las sondeas mecánicas (conteo de emisiones de señales, validadores de suites) se corren con scripts del repo — ver `scripts/red_probe_event_bus.py` (red-probe M14 automatizada; salida: señales 0-emit vs oráculo). Cualquier cron o humano puede correrlas: el veredicto es máquina-verificable.
5. **Si el agente asignado muere:** el gate-2 se re-asigna a cualquier otro que cumpla los prerequisitos — el playbook + esta sección son la única dependencia.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-27, directiva del fundador ("en el futuro quizás tampoco esté Nemotron: el método debe funcionar para cualquier agente").
"""
if "GATE-2 MODEL-AGNOSTIC" not in tex:
    with open(p, "a", encoding="utf-8", newline="\n") as f:
        f.write(adenda)
    print("seccion agregada OK")
else:
    print("ya existia")
