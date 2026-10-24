# -*- coding: utf-8 -*-
# APILADOR v2: tranche P-100 (minimo, fundador 22oct 06:59) — publica hasta 100 tareas inline
import io, os, json, re, subprocess, sys, glob

BASE = "DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0"
ESTADO = os.path.join(BASE, "APILADOR_ESTADO.json")
CANAL = "Mensajes entre modelos/Reflection-Beam-1.0"
TARGET = 100

QUEUES = ["BACKLOG-10-PAQUETE-D6-DETALLE.md", "BACKLOG-14-MICRO-TAREAS.md",
          "BACKLOG-13-REPOSICION-100.md", "BACKLOG-11-PAQUETE-D8-DETALLE.md",
          "BACKLOG-12-PAQUETE-D5-C-DETALLE.md"]

st = {"colas": {}, "orden": QUEUES}
if os.path.isfile(ESTADO):
    st.update(json.loads(io.open(ESTADO, "r", encoding="utf-8").read()))

def item_modulo_de_linea(fila):
    m = re.match(r"-\s*\(L\d+\)\s*(?:\[(.*?)\]\s*)?(.*)$", fila)
    mod = m.group(1) or "" if m else ""
    return mod.split("-")[0].split(" ")[0].strip()

def cargar_item_real(pref, linea_n):
    g = glob.glob(os.path.join("DOCUMENTACION", pref + "*", "plan-actual", "05-Checklist.md"))
    if not g:
        return None
    lineas = io.open(g[0], "r", encoding="utf-8", errors="replace").read().splitlines()
    if linea_n - 1 >= len(lineas):
        return None
    s = lineas[linea_n - 1].strip()
    if s.startswith("- [x]"):
        return None
    return s[6:].strip() if s.startswith("- [") else s

publicadas = 0
pq = None
for cola in (st.get("orden") or QUEUES):
    if publicadas >= TARGET:
        break
    cursor = st["colas"].get(cola, 0)
    p = os.path.join(BASE, cola)
    if not os.path.isfile(p):
        continue
    mod = None
    tareas, cerrados = [], 0
    lineas = io.open(p, "r", encoding="utf-8").read().splitlines()
    i = 0
    while i < len(lineas) and len(tareas) < (TARGET - publicadas):
        if lineas[i].startswith("## "):
            mod = lineas[i][3:].split("—")[0].strip().split(" ")[0]
        s = lineas[i].strip()
        m = re.match(r"-\s*\(L(\d+)\)\s*(.*)$", s)
        if m and (i + 1) > cursor:
            ln_n = int(m.group(1))
            cuerpo = cargar_item_real(mod, ln_n) if mod else None
            if cuerpo and mod:
                tareas.append((mod, ln_n, cuerpo))
            else:
                cerrados += 1
        i += 1
    if tareas:
        pq = cola
        # reservar NN
        r = subprocess.run(["python", "-X", "utf8", "scripts/reservar_mensaje.py",
                            "Reflection-Beam-1.0", f"tranche-p100-{cola[:14]}-apilador",
                            "--emisor", "GLM-5.3-Flash-Director"], capture_output=True, text=True)
        out = (r.stdout or "") + (r.stderr or "")
        m = re.search(r"archivo: ([^\n]+)", out)
        if not m:
            print("ERROR reserva:", out[:200]); break
        dest = m.group(1).strip()
        lineas_out = ["# APILADOR P-100 — TRANCH de %d tareas (fundador 22oct 06:59: de a 100 mínimo)" % len(tareas),
                      "", "**Modelo:** GLM-5.3 Flash-Director", "**Plataforma:** Kilo Code",
                      "**Responde a:** tus auto-avisos cola-vacia (sin NN individual: alimentación continua)",
                      "",
                      "### Tus %d tareas (en orden; reporte compacto al cerrar: `modulo | ok | skip | fail` por lote de linea)" % len(tareas),
                      ""]
        for mod, ln_n, cuerpo in tareas:
            lineas.append("- **[%s L%d]** %s" % (mod, ln_n, cuerpo))
        lineas += ["", "### Notas",
                   "- Skip automático: %d items del rango ya estaban [x] (cerrados por vos u otro; no repetir)." % cerrados,
                   "- Cubo B/C/D (editor/pipeline/producto): NO ejecutar — reportalos como skip con motivo.",
                   "- Fórmula/spec: al 03 del módulo (sección única, citas), flipa el [?] del 05 con cita a tu tranche.",
                   "- Totales del 05: NUNCA tocar (baselinea el director).",
                   "- Si tu cliente no aguanta el lote completo: ejecuta hasta donde puedas y publica `done=N` con la línea final — el apilador retoma desde donde cortaste (reportame el corte).",
                   "", "Firma: APILADOR P-100 (GLM-5.3 Flash-Director / Kilo Code) — fundador 22oct 22:17+06:59."]
        io.open(dest, "w", encoding="utf-8", newline="\n").write("\n".join(lineas_out) + "\n")
        st["colas"][cola] = i  # cursor al final del escaneo
        publicadas = len(tareas)
        print("PUBLICADO:", dest, "| tareas:", len(tareas), "| cola:", cola)
    else:
        st["colas"][cola] = i
        print("cola agotada/sin accionables:", cola, "| evaluados:", i)

io.open(ESTADO, "w", encoding="utf-8", newline="\n").write(json.dumps(st, ensure_ascii=False, indent=2) + "\n")
print("tareas publicadas esta corrida:", publicadas)
