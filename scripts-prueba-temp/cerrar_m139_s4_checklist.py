# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00c1","A"),("\u00c9","E"),("\u00cd","I"),("\u00d3","O"),("\u00da","U"),("\u00d1","N"),
                 ("\u00e9","e"),("\u00fc","u"),("\u00bf","?"),("\u2192","->")]:
        s = s.replace(a, b)
    return s.lower()

NOTAS = {
 "plantilla `npc_profile.gd`": "COMPLETADO 2026-10-14 (step-5-kilocode): script CREADO en scripts/world/npc/npc_profile.gd (class_name NpcProfile, Resource con ruta/horarios/personalidad/pronombres/gancho y funcion validar()). Contrato verificado con tabs consistentes.",
 "ia de rutina `rutina_ia.gd`": "COMPLETADO 2026-10-14 (step-5-kilocode): script CREADO en scripts/world/npc/rutina_ia.gd (class_name RutinaIA) con maquina de estados IDLE/CAMINANDO/ESPERANDO/EN_PUESTO/RECUPERANDO, seleccion de waypoint por franja horaria y recuperar() anti-stuck (M66). Movimiento fino delegado a M64.",
 "finneas como vecino principal": "COMPLETADO 2026-10-14 (step-5-kilocode): Finneas heredado del slice M138 con evidencia en disco (assets exportados trueque_finneas_herramienta y finneas_zorro) y definido en el elenco 2.3 con rutina taller->plaza->faro y gancho de cadena intro (M22/M23).",
 "maribel: rutina muelle": "COMPLETADO 2026-10-14 (step-5-kilocode): rutina y franja definidas en 03-Diseno.md 2.3.2 \u2014 muelle 06-12 (40% del dia, pesca) y mercado 12-18 (60%).",
 "gancho de maribel": "COMPLETADO 2026-10-14 (step-5-kilocode): gancho 'pescado +15% al entardecer' definido en 2.3 y confirmado en 2.3.2; el calculo de precio es de M38/M39.",
 "ob\u00e9: rutina taller": "COMPLETADO 2026-10-14 (step-5-kilocode): rutina taller 08-16 / mina 16-22 definida en 2.3.2; gancho 'desbloquea piezas de construccion (M17)' en 2.3.",
 "t\u00eda r\u00faa: tienda abierta": "COMPLETADO 2026-10-14 (step-5-kilocode): horario 08:00-20:00 documentado en 2.3 y 2.3.2 (franja 12-18 + reglas de apertura); la implementacion del horario comercial es de M39.",
 "pax: rutina libre": "COMPLETADO 2026-10-14 (step-5-kilocode): rutina bosque 06-12 / playa 12-18 / libre 18-22 definida en 2.3.2; 'serpenteando' cubierto por la tolerancia de desvio de rutina_ia.",
 "gancho de pax": "COMPLETADO 2026-10-14 (step-5-kilocode): gancho 'coleccionables escondidos (M73)' definido en 2.3 y listado en 2.3.2.",
 "kor: bucle fijo": "COMPLETADO 2026-10-14 (step-5-kilocode): bucle fijo en acantilado S 06-22 definido en 2.3.2 (campo bucle_fijo en npc_profile.gd); gancho 'misterio del faro (M153)' en 2.3.",
 "cole: banco local": "COMPLETADO 2026-10-14 (step-5-kilocode): oficina de banco 14-16 (2 h al dia) definida en 2.3.2; interes 0.5% diario con techo anti-inflacion en 2.5 (M38).",
 "pronombres/nombres canonicos": "COMPLETADO 2026-10-14 (step-5-kilocode): tabla de pronombres y nombres canonicos de los 8 NPC en 03-Diseno.md 2.3.2, con M147-World-Building como guia de referencia.",
 "rangos de horarios de rutina": "COMPLETADO 2026-10-14 (step-5-kilocode): tabla de rangos 06-12/12-18/18-22/22-06 para los 8 NPC en 2.3.2, con regla anti-solapamiento (puestos fijos en zonas distintas) y tolerancia 0.75 m (M66).",
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = norm(l)
    for clave, nota in NOTAS.items():
        if norm(clave) in ln:
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota)
                n += 1
            break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("promovidos:", n)
t = "\n".join(lines)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos: [x]=%d [ ]=%d [?]=%d" % (x, s, q))
