# -*- coding: utf-8 -*-
# Flip M59 "Id de perfil" → [?] + Totales + fila (versión limpia final)
import io, re

# 1) Módulo 59: ítem → [?]
P = r"DOCUMENTACION\59-Guardado\plan-actual\05-Checklist.md"
s = io.open(P, encoding="utf-8").read()
old = "- [ ] Id de perfil en el archivo, validado al cargar (sin cruzamiento) [M]"
assert s.count(old) == 1, s.count(old)
s = s.replace(old, "- [?] Id de perfil en el archivo, validado al cargar (sin cruzamiento) [M] — "
    "**G-5.3-Flash-Agente (2026-10-20): IMPLEMENTADO PARCIALMENTE con 2 HALLAZGOS para el dueño M59.** "
    "Hecho: (1) API en DataStore (`set/get_perfil_activo`; qa_perfil_id.gd ya prueba la API), "
    "(2) sello `meta.profile_id` en `_payload_para_slot` (verificado EN MEMORIA: 'perfil_A'), "
    "(3) `LoadResult.PROFILE_MISMATCH` nuevo (enum save_loader) + pre-validación en `load_slot` SIN restaurar nada "
    "(branch corta; marcador intacto). HALLAZGOS: (a) el sello llega al builder (probe en memoria OK) pero el ARCHIVO en disco lo "
    "pierde (meta={day,version,last_saved} sin profile_id — alguna capa de serialización lo filtra), "
    "(b) anomalía de cadencia lector: `loader.load(1)` devuelve EMPTY_SLOT(5) para un slot que "
    "`slot_metadata(1)` parsea OK con checksum. El rechazo cruzado se activa cuando el sello persista; fallbacks legacy/sin-perfil ya verificados. "
    "QA: `scripts/saving/qa_m59_profile_id.gd` (10 checks, EXIT 0).")
io.open(P, "w", encoding="utf-8", newline="\n").write(s)

x = len(re.findall(r'^\- \[x\]', s, re.M)); o = len(re.findall(r'^\- \[ \]', s, re.M)); q = len(re.findall(r'^\- \[\?\]', s, re.M))
mt = re.search(r"\*\*Totales:\*\*[^\n]*", s)
if mt:
    s = s.replace(mt.group(0), "**Totales:** 184 ítems · Completados: %d · Pendientes: %d · No resueltos: %d. "
        "(Normalizado al medido por G-5.3-Flash-Agente 2026-10-20: 'Id de perfil' pasa a [?] — el medido manda sobre la línea escrita.)" % (x, o, q))
    io.open(P, "w", encoding="utf-8", newline="\n").write(s)
print("checklist M59:", x, o, q, "total", x + o + q)

# 2) Backlog: ítem 8 (prefijo real 8) → [?]
PB = r"DOCUMENTACION\TAREAS-POR-MODELO\G-5.3-Flash-Agente\BACKLOG-MASTER.md"
b = io.open(PB, encoding="utf-8").read()
m2 = re.search(r"(\d+)\. - \[ \] \[59\] ID de perfil en el archivo, validado al cargar[^\n]*", b)
assert m2, "ítem 8 no en backlog"
n8 = m2.group(1)
b = b.replace(m2.group(0), m2.group(0).replace("- [ ]", "- [?]") +
    " · [?] T39-M59 (G-5.3): API + sello + PROFILE_MISMATCH implementados; 2 hallazgos (sello no persiste en disco + loader EMPTY_SLOT vs metadata parse) para el dueño M59 — qa_m59_profile_id.gd 10 checks EXIT 0 con hallazgos documentados.")
io.open(PB, "w", encoding="utf-8", newline="\n").write(b)
print("backlog ok (n=%s)" % n8)

# 3) Fila global (sin cambio de [x])
PG = "CHECKLIST-GLOBAL.md"
g = io.open(PG, encoding="utf-8").read()
lineas = g.split("\n")
idx = next(i for i, l in enumerate(lineas) if l.startswith("| 59 |"))
m3 = re.search(r"\| (\d+)/(\d+) \|", lineas[idx])
nueva = lineas[idx].replace("| %s/%s |" % (m3.group(1), m3.group(2)), "| 71/130 |", 1)
g = g.replace(lineas[idx], nueva)
io.open(PG, "w", encoding="utf-8", newline="\n").write(g)
print("fila global 59 = 71/130 (sin cambio de [x])")
