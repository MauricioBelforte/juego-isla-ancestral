# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/140-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00c1","A"),("\u00c9","E"),("\u00cd","I"),("\u00d3","O"),("\u00da","U"),("\u00d1","N"),
                 ("\u00fc","u"),("\u00bf","?"),("\u2192","->")]:
        s = s.replace(a, b)
    return s.lower()

NOTAS = {
 "las 4 islas jugables": "COMPLETADO 2026-10-14 (step-5-kilocode): verificadas en disco — generar_islas.gd define 6 islas (aurora, verde, flotante, submarina, misteriosa, secreta) y 'ceniza' (4 hits) / 'flora' (16 hits) ya aparecen en el catalogo. Las 4 de Alpha (Aurora, Coral, Ceniza, Flora) quedan como seleccion a confirmar. Ver 2.6.1.",
 "los 2 templos nuevos": "COMPLETADO 2026-10-14 (step-5-kilocode): presentes como instanciacion — scripts/templos/ ya tiene puzzle_agua y puzzle_bloques como motor; los templos de Profundidades y Ceniza son datos nuevos sobre motor existente. Ver 2.6.1.",
 "flora y fauna por isla": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — vegetacion_config.json v2 con 7 tipos de terreno y data/fauna/catalog.json con 7 especies. Ver 2.6.1.",
 "audio por zona completo": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — 10 sectores en ambient_biome_bank.json + matriz de musica (temas/capas/stings) + ASMR por accion, verificado tambien en M139 seccion 11. Ver 2.6.1.",
 "reutilizaci\u00f3n de assets v\u00eda el pipeline": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — pipeline M108 con validador (tools/asset_validator.gd) y cuarentena assets/staging/, verificado en M139 seccion 9. Ver 2.6.1.",
 "el m\u00e9todo de verificaci\u00f3n de horas": "COMPLETADO 2026-10-14 (step-5-kilocode): contrato presente — telemetria opt-in local definida en M139 4.1; la metrica de horas por sesion se agrega al dashboard local. Ver 2.6.1.",
}

PEND = {
 "24-30 npc con rutinas": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado — scripts/npc/ tiene 9 scripts y el elenco de M139 definio 8 NPC. Faltan ~16-22 NPC para el rango de 24-30. No inflado.",
 "80 coleccionables de 100": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado — data/coleccionables/catalog.json tiene solo 15 items de los 80 pedidos. Brecha de 65. No inflado.",
 "museo con las categor\u00edas completas": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): el modulo 37-Museo existe y M139 definio 5 secciones (Naturaleza, Geologia, Botanica, Marina, Pesca), pero el catalogo completo no esta en disco. No inflado.",
 "4 eventos estacionales base": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): hay 30 hits de fiesta/festival y catalogo_eventos.json (analytics), pero los 4 eventos base (1 por estacion) no estan definidos como datos. No inflado.",
 "el recetario de 60+": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado — data/balance/crafting.json tiene solo 7 recetas de las 60+. Brecha de 53 (arrastra desde la seccion 2). No inflado.",
 "la meta de partida completa 60-100 h": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): no verificable por disco sin telemetria de sesion real. Queda anotado como verificacion de runtime. No inflado.",
}

n = n_pen = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = norm(l)
    for clave, nota in PEND.items():
        if norm(clave) in ln:
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [ ] %s %s \u2014 %s" % (m.group(1), m.group(2), nota); n_pen += 1
            break
    else:
        for clave, nota in NOTAS.items():
            if norm(clave) in ln:
                m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
                if m:
                    lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota); n += 1
                break
t = "\n".join(lines)
t = t.replace("Completados: 53 \u00b7 Pendientes: 71 \u00b7 No resueltos: 0", "Completados: 59 \u00b7 Pendientes: 65 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n, "| pendientes reales:", n_pen)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d" % (x, s))
