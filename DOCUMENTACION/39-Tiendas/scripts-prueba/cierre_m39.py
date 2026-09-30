# -*- coding: utf-8 -*-
"""
Cierre de M39 (glm-5.3-flash): registros de coordinacion de la iteracion GLM
(atomicidad del catalogo D8 + falso-verde del loop economico, Log 1017).

Idempotente: puede ejecutarse varias veces sin duplicar lineas.
Genera reporte en Logs/_cierre_m39.txt (UTF-8).
No usa shell ni subprocess: solo lectura/escritura de texto preservando CRLF.
"""
import io
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
LOG = []


def say(s):
    LOG.append(s)


def ruta(rel):
    return os.path.join(ROOT, rel)


def leer(rel):
    with io.open(ruta(rel), encoding="utf-8", newline="") as f:
        return f.read()


def escribir(rel, txt):
    with io.open(ruta(rel), "w", encoding="utf-8", newline="") as f:
        f.write(txt)


def nl_de(t):
    return "\r\n" if "\r\n" in t else "\n"


say("=== CIERRE M39 - reporte de registros ===")

# ---------------------------------------------------------------------------
# 1) Guia 08: registro de reservas del modulo 39
# ---------------------------------------------------------------------------
G08 = "DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md"
if os.path.exists(ruta(G08)):
    t = leer(G08)
    lineas = t.splitlines()
    hit = [i for i, l in enumerate(lineas) if re.search(r"\|\s*39\s*\|", l) or "M39" in l]
    say("[1] Guia 08: %d linea(s) con 39/M39" % len(hit))
    for i in hit[:12]:
        say("    L%d: %s" % (i + 1, lineas[i].strip()[:170]))
    fila = ("| 39 | 39-Tiendas | 🟢 Disponible | Alta | 4 | 38 | — | 2026-09-19 22:10 | "
            "Iter GLM cerrada por glm-5.3-flash (Log 1017); reserva liberada |")
    ya = any(re.search(r"\|\s*39\s*\|", lineas[i]) for i in hit)
    if ya:
        # actualizar la fila existente del 39 a estado liberado
        def _rep(m):
            return fila
        nuevo, n = re.subn(r"(?m)^\|\s*39\s*\|[^\n]*$", fila, t)
        if n:
            escribir(G08, nuevo)
            say("    -> fila del 39 actualizada a liberada (%d linea)" % n)
        else:
            say("    -> fila del 39 detectada pero no reemplazable (revisar a mano)")
    else:
        idx = None
        for i, l in enumerate(lineas):
            if l.lstrip().startswith("|") and "Módulo" in l and "Estado" in l:
                idx = i
        if idx is not None:
            # fin de la tabla de reservas
            j = idx + 2
            while j < len(lineas) and lineas[j].lstrip().startswith("|"):
                j += 1
            ins = fila
            partes = t.splitlines(True)
            # insertar antes de la linea j
            partes.insert(j, ins + nl_de(t))
            escribir(G08, "".join(partes))
            say("    -> fila de M39 agregada a la tabla de reservas (tras L%d)" % j)
        elif "Reservas liberadas" in t:
            say("    -> ya existe seccion historica; agregar fila a mano si hace falta")
        else:
            escribir(G08, t.rstrip() + nl_de(t) + nl_de(t) + "## Reservas liberadas (historico)" + nl_de(t) + nl_de(t) + fila + nl_de(t))
            say("    -> creada seccion 'Reservas liberadas (historico)' con la fila de M39")
else:
    say("[1] Guia 08 NO ENCONTRADA")

# ---------------------------------------------------------------------------
# 2) Backlog master: marcar 39-Tiendas y registrar el Log 1017
# ---------------------------------------------------------------------------
BM = "DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3-flash/BACKLOG-MASTER.md"
if os.path.exists(ruta(BM)):
    t = leer(BM)
    nuevo, n = re.subn(r"(?m)^(\s*[-*]\s*)\[(?: |→)\](?=[^\n]*39-Tiendas)",
                       r"\1[x]", t)
    say("[2] Backlog master: %d marcador(es) [x] en lineas de 39-Tiendas" % n)
    cambio = n > 0
    if "1017" not in nuevo:
        linea_log = ("- [x] Log creado: **1017** — M39 cierre iter GLM "
                     "(atomicidad catalogo D8 + falso-verde loop economico)")
        if "## Logs" in nuevo:
            nuevo = nuevo.rstrip() + nl_de(t) + linea_log + nl_de(t)
        else:
            nuevo = nuevo.rstrip() + nl_de(t) + nl_de(t) + "## Logs" + nl_de(t) + nl_de(t) + linea_log + nl_de(t)
        cambio = True
        say("    -> linea del Log 1017 agregada")
    else:
        say("    -> Log 1017 ya presente (sin duplicar)")
    if cambio:
        escribir(BM, nuevo)
else:
    say("[2] Backlog master NO ENCONTRADO")

# ---------------------------------------------------------------------------
# 3) Checklist personal M39: marcar tareas de la iteracion GLM
# ---------------------------------------------------------------------------
CK = "DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3-flash/39-Tiendas/checklist.md"
CLAVES = r"(iter|glm|atomic|d8|falso-verde|verde|catalogo|catálogo|shop_manager|test_loop|loop_economico|back\()"
if os.path.exists(ruta(CK)):
    t = leer(CK)
    nuevo, n = re.subn(r"(?mi)^(\s*[-*]\s*)\[(?: |→)\](?=[^\n]*" + CLAVES + r")",
                       r"\1[x]", t)
    if n:
        escribir(CK, nuevo)
    say("[3] Checklist personal M39: %d tarea(s) marcadas [x]" % n)
    fin = nuevo if n else t
    pend = len(re.findall(r"(?m)^\s*[-*]\s*\[(?: |→)\]", fin))
    hech = len(re.findall(r"(?m)^\s*[-*]\s*\[x\]", fin))
    say("    pendientes=%d | hechas=%d" % (pend, hech))
else:
    say("[3] Checklist personal M39 NO ENCONTRADO")

# ---------------------------------------------------------------------------
# Reporte
# ---------------------------------------------------------------------------
rep = "\n".join(LOG) + "\n"
with io.open(ruta("Logs/_cierre_m39.txt"), "w", encoding="utf-8", newline="") as f:
    f.write(rep)
print(rep.encode("utf-8", "replace").decode("utf-8", "replace"))
