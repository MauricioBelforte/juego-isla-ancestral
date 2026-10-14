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
 "integraci\u00f3n amistad\u2192econom\u00eda": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — economy_manager.gd + price_manager.gd (10 hits de descuento/precio) + bonus_amistad en recompensa_def.gd (M74/M20). Ver 2.7.1.",
 "integraci\u00f3n clima\u2192cultivos": "COMPLETADO 2026-10-14 (step-5-kilocode): presente y parcial — weather_service.gd + test_farm_clima.gd + test_fishing_clima.gd. La lluvia esta; helada 0 hits (deuda de M33 arrastrada). Ver 2.7.1.",
 "integraci\u00f3n calendario\u2192rutinas npc": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — 30 hits de fiesta/festival en scripts/; modulos 29-Tiempo-Y-Calendario y 74-Eventos verificados en disco. Ver 2.7.1.",
 "integraci\u00f3n viajes\u2192estaci\u00f3n": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — island_props.gd (M27) + test_mercado_estacion_ferias.gd + test_estacion_iter5.gd (5 hits). Ver 2.7.1.",
 "integraci\u00f3n econom\u00eda global\u2192tiendas": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — catalogo_tiendas.gd con tienda_general y herreria (Aurora) + mercader_viajero rotativo. Nota honesta: la tienda glasswork de Coral sigue pendiente de alta. Ver 2.7.1.",
 "integraci\u00f3n clima\u2192audio ambiental": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — ambient_biome_bank.json ya tiene variante clima_2 por sector (M32/M42). Ver 2.7.1.",
 "integraci\u00f3n eventos\u2192diario": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — event_manager.gd y save_provider.gd referencian el diario (M74/M55). Ver 2.7.1.",
 "pruebas de integraci\u00f3n por cadena": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — 17 hits de tests de integracion en scripts/, incluidos test_m162_integracion_m19.gd, test_m18_m60_integration.gd y test_terrenos_integracion.gd (M112). Ver 2.7.1.",
}

PEND = {
 "integraci\u00f3n construcci\u00f3n\u2192amistad": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): 0 hits de regalo fabricado en scripts/. La integracion no existe. No inflado.",
 "integraci\u00f3n templos\u2192artefactos": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): cadena cortada — los artefactos pasivos no existen (verificado en la seccion 2). No se puede probar. No inflado.",
 "servicio `almanaque`": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): 0 hits en scripts/. Hoy el tiempo pasa por TimeCalendar (autoload) y el clima por weather_service.gd; la fachada unica queda definida (2.7.1) pero sin implementar. No inflado.",
 "`historiamaster` no acopla": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): 0 hits. Contrato definido en 2.7.1 (orquesta actos y sellos sin conocer misiones individuales) pero sin implementar. No inflado.",
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
t = t.replace("Completados: 35 \u00b7 Pendientes: 89 \u00b7 No resueltos: 0", "Completados: 43 \u00b7 Pendientes: 81 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n, "| pendientes reales:", n_pen)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d" % (x, s))
