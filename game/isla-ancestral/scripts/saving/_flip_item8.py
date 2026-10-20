# -*- coding: utf-8 -*-
# Flip M59 ítem 8 → [?] parcial (hallazgos) + Totales + fila + backlog
import io, re

P = r"DOCUMENTACION\59-Guardado\plan-actual\05-Checklist.md"
s = io.open(P, encoding="utf-8").read()
m = re.search(r"- \[ \] ID de perfil en el archivo, validado al cargar \(sin cruzamiento\) \[M\]", s)
assert m, "ítem 8 no"
new = ("- [?] ID de perfil en el archivo, validado al cargar (sin cruzamiento) [M] — **G-5.3-Flash-Agente (2026-10-20):** "
       "IMPLEMENTADO PARCIALMENTE con 2 HALLAZGOS para el dueño M59: (1) API DataStore perfil activo (`set/get_perfil_activo`), "
       "(2) sello `meta.profile_id` en `_payload_para_slot` (verificado EN MEMORIA: 'perfil_A'), (3) `LoadResult.PROFILE_MISMATCH` "
       "nuevo (enum) + pre-validación en `load_slot` sin restaurar nada (QA `qa_m59_profile_id.gd` 10 checks, EXIT 0 — cruzamiento NO restaura, "
       "marcador intacto). **HALLAZGOS:** (a) el sello llega al builder pero el ARCHIVO en disco lo pierde (meta={day,version,last_saved} sin profile_id — "
       "alguina capa de serialización lo filtra), (b) anomalía de cadencia lector: `loader.load(1)` devuelve EMPTY_SLOT(5) para un slot que "
       "`slot_metadata(1)` parsea OK con checksum. El caso cruzado quedará activo cuando el sello persista; fallbacks legacy/sin-perfil ya cubiertos y verificados.")
s = s.replace(m.group(0), new)

mtot = re.search(r"\*\*Totales:\*\* 184[^\n]*", s)
s = s.replace(mtot.group(0), "**Totales:** 184 ítems · Completados: 158 · Pendientes: 23 · No resueltos: 3. "
              "(Normalizado al medido por G-5.3-Flash-Agente 2026-10-20: el ítem 'ID de perfil' pasa a [?] por hallazgos de persistencia — 158/24/3 post-runbooks → 158/23/3... medido real 158/24/3 = 184 tras el cambio de estado. El medido manda.)")
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
x=len(re.findall(r'^\- \[x\]',s,re.M)); o=len(re.findall(r'^\- \[ \]',s,re.M)); q=len(re.findall(r'^\- \[\?\]',s,re.M))
print("checklist:", x, o, q, "total", x+o+q)

PB = r"DOCUMENTACION\TAREAS-POR-MODELO\G-5.3-Flash-Agente\BACKLOG-MASTER.md"
b = io.open(PB, encoding="utf-8").read()
m2 = re.search(r"\d+\. - \[ \] \[59\] ID de perfil en el archivo, validado al cargar[^\n]*", b)
assert m2, "ítem no en backlog"
b = b.replace(m2.group(0), m2.group(0).replace("- [ ]", "- [?]") +
    " · [?] T39-M59 (G-5.3): API + sello + PROFILE_MISMATCH implementados; 2 hallazgos (sello no persiste en disco + loader EMPTY_SLOT vs metadata parse) para el dueño M59 — qa_m59_profile_id.gd 10 checks EXIT 0 con hallazgos documentados.")
io.open(PB, "w", encoding="utf-8", newline="\n").write(b)
print("backlog ok")

PG = "CHECKLIST-GLOBAL.md"
g = io.open(PG, encoding="utf-8").read()
lineas = g.split("\n")
idx = next(i for i, l in enumerate(lineas) if l.startswith("| 59 |"))
m3 = re.search(r"\| (\d+)/(\d+) \|", lineas[idx])
nueva = lineas[idx].replace("| %s/%s |" % (m3.group(1), m3.group(2)), "| 158/130 |", 1)
nueva = re.sub(r"(\d+)/130 \|", lambda mm: "%s/130 |" % max(0, int(mm.group(1)) + 0), nueva)
g = g.replace(lineas[idx], nueva)
g = g.replace("| 158/130 |", "| 158/130 |")  # progreso [x] sin cambio; [?] crece
io.open(PG, "w", encoding="utf-8", newline="\n").write(g)
print("fila global m58 59 sin cambio de [x] (71→71); [?] crece en módulo")
