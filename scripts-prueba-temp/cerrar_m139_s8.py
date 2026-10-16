# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00c1","A"),("\u00c9","E"),("\u00cd","I"),("\u00d3","O"),("\u00da","U"),("\u00d1","N"),
                 ("\u00fc","u"),("\u00bf","?"),("\u2192","->")]:
        s = s.replace(a, b)
    return s.lower()

NOTAS = {
 "gran vapor atracado en el puerto": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — generar_red_transporte.gd registra la parada `puerto_aurora` (tipo barco, isla_raiz) dentro de una red de 10 paradas / 20 rutas; definicion del vehiculo en 03-Diseno.md 2.8.1.",
 "interacci\u00f3n de embarque": "COMPLETADO 2026-10-14 (step-5-kilocode): contrato IViajable (creado hoy para la seccion 1) + travel_service.gd que valida el flag de desbloqueo M22 via WorldState; flujo definido en 2.8.1 (hablar con tripulante -> confirmar destino -> validar flag).",
 "cutscene corta de traves\u00eda": "COMPLETADO 2026-10-14 (step-5-kilocode): cutscene de 20-25 s sin gameplay de mar definida en 2.8.1 (salida del puerto, plano del ocena, llegada), con opcion de saltar sin penalizacion.",
 "desembarco en coral y la vuelta": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.8.1 — desembarco en el muelle de Coral con Bram como primer contacto; vuelta desde el mismo muelle, sin costo adicional dentro de la misma sesion.",
 "costo del viaje": "COMPLETADO 2026-10-14 (step-5-kilocode): 25 AO el primer viaje y gratis el resto del dia (regla cozy). Coincide con la recompensa por descubrir ruta nueva (25 AO) que ya existe en data/meta.json, asi que el primer viaje se autofinancia.",
 "qu\u00e9 se puede llevar": "COMPLETADO 2026-10-14 (step-5-kilocode): inventario completo viaja con el jugador (anti-frustracion); las piezas colocadas y las plantas de la parcela no viajan. Regla en 2.8.1.",
 "vista del oc\u00e9ano como anzuelo": "COMPLETADO 2026-10-14 (step-5-kilocode): siluetas de islas no visitadas con neblina durante la cutscene, como unica pista del 2\u00ba bioma; mecanica documentada en 2.2 y 2.8.1 (M51/M152).",
 "c\u00e1mara del gran vapor": "COMPLETADO 2026-10-14 (step-5-kilocode): el sistema de camara existe (camera_rig.gd, camera_spring.gd, camera_mode.gd); la cutscene lo usa en modo fijo sin spring y vuelve al seguimiento al desembarcar. Definido en 2.8.1.",
 "audio de traves\u00eda": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — capas `olas` + `gaviotas` en ambient_biome_bank.json (M42) y el leitmotiv `leit_gran_vapor` en music_context_matrix.json (M41). Mezcla definida en 2.8.1.",
 "el viaje no sea repetitivo": "COMPLETADO 2026-10-14 (step-5-kilocode): 4 lineas rotativas del tripulante (una por viaje del dia, ciclo de 4 dias) + variante nocturna, con registro en world_state para no repetir linea. Definido en 2.8.1.",
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

t = "\n".join(lines)
t = t.replace("Completados: 78 \u00b7 Pendientes: 62 \u00b7 No resueltos: 2", "Completados: 88 \u00b7 Pendientes: 52 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos reales: [x]=%d [ ]=%d [?]=%d" % (x, s, q))
