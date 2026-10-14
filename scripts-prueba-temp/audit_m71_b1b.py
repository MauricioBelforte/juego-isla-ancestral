# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 "Implementar get_unlock(id)": "AUDIT 2026-10-14 (step-5-kilocode): confirmado el degradado de s2 (Log 1714) — 0 hits de los 3 getters; el acceso es interno (_hitost) y por signals. Sigue DEGRADADO, sin cambio.",
 "Garantizar que ningun logro sea imposible": "AUDIT 2026-10-14 (step-5-kilocode): detection existe en codigo — detectar_condiciones_imposibles_estaticas() (L388) mas validacion de catalogo (L529) y suite M71; la garantia postgame (M75) no esta verificada. Parcial.",
 "Definir estadisticas minimas iniciales": "AUDIT 2026-10-14 (step-5-kilocode): stats existen y estan soportadas — _stat() (L241) mas progreso_resumen_cargado; test_progresion.gd valida conteos. La lista exacta del item no se verifico como conjunto.",
 "RNF5: data-driven total en .tres": "AUDIT 2026-10-14 (step-5-kilocode): el catalogo es data-driven pero en JSON (data/progresion/hitos.json), no .tres; la validacion en editor no existe (validacion es runtime, L529). El item pide .tres + editor.",
 "Analizar dominio de desbloqueos": "AUDIT 2026-10-14 (step-5-kilocode): los 5 tipos estan tipados en el dominio — senales progreso_desbloqueado(id_unlock, tipo, valor) (L21) y secciones de tests por tipo (test_progresion.gd L143-193). Analisis documentado.",
 "Analizar dominio de mejoras": "AUDIT 2026-10-14 (step-5-kilocode): M13 9x4 confirmado (conectar_tool_controller L193, nivel_herramienta_cambio) y M18 casas por nivel (player_profile.house_nivel). Progresion vertical implementada como reflejo.",
 "Analizar dominio de reputacion": "AUDIT 2026-10-14 (step-5-kilocode): amistad M20 0-4 confirmada (integrar_amistad + tests M17/L37/L267); la reputacion comunitaria derivada no esta implementada. Parcial.",
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[\?\]", l):
        continue
    if "AUDIT 2026-10-14" in l:
        continue
    for clave, nota in notas.items():
        if clave in l:
            lines[i] = l.rstrip() + " | " + nota
            n += 1
            break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados (M71 b1b):", n)
