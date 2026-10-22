# -*- coding: utf-8 -*-
"""Saneamiento mecanico de DOCUMENTACION/11-BUGS.md (M102, Log 2120).

Cada edicion es minima y trazable. Si un ancla no aparece EXACTAMENTE una vez,
el script aborta sin escribir: en un worktree compartido, un ancla que
desaparecio significa que otro agente ya toco esa fila.
"""
import io
import re
import sys

RUTA = "DOCUMENTACION/11-BUGS.md"
RE_SPLIT = re.compile(r"(?<!\\)\|")

SEV = {"\U0001F534": "critica", "\U0001F7E0": "mayor", "\U0001F7E1": "menor",
       "\U0001F7E2": "baja", "\u26AA": "trivial"}
CANON = {"critica": "Cr\u00edtica", "mayor": "Mayor", "menor": "Menor",
         "baja": "Baja", "trivial": "Trivial"}

crudo = io.open(RUTA, "rb").read()
assert not crudo.startswith(b"\xef\xbb\xbf"), "el registro no debe llevar BOM"
texto = crudo.decode("utf-8")
antes = texto

log = []


def reemplazo_unico(viejo, nuevo, etiqueta):
    global texto
    n = texto.count(viejo)
    if n != 1:
        sys.exit("ABORTA: ancla '%s' aparece %d veces (se esperaba 1)" % (etiqueta, n))
    texto = texto.replace(viejo, nuevo, 1)
    log.append(etiqueta)


def celdas(linea):
    p = RE_SPLIT.split(linea)
    if p and p[0].strip() == "":
        p = p[1:]
    if p and p[-1].strip() == "":
        p = p[:-1]
    return [x.strip() for x in p]


def fila(cs):
    return "| " + " | ".join(cs) + " |"


# 1) L3061: encabezado de seccion con otro encabezado EMBEBIDO (BUG-119 invisible)
reemplazo_unico("## 7. Bugs Resueltos (historial)## BUG-119:",
                "## 7. Bugs Resueltos (historial)\n## BUG-119:",
                "L3061 seccion_pegada -> BUG-119 visible")

# 2) L141: estado en palabra sin marca
reemplazo_unico("| \u2705 **Resuelto (fix exclusiones",
                "| [x] **Resuelto (fix exclusiones",
                "L141 estado_sin_marca -> [x]")

# 3) L153: dos filas pegadas (BUG-127 || BUG-128)
reemplazo_unico(" | | BUG-128 | ", " |\n| BUG-128 | ", "L153 fila_malformada -> split BUG-127/BUG-128")

# 4) L177: dos filas pegadas (BUG-088 || BUG-090)
reemplazo_unico(" || BUG-090 | ", " |\n| BUG-090 | ", "L177 fila_malformada -> split BUG-088/BUG-090")

# 5) L159 y L205: reconstruir la fila entera (celdas != 7)
lineas = texto.split("\n")
cambios = 0
for i, linea in enumerate(lineas):
    if not linea.startswith("| BUG-"):
        continue
    cs = celdas(linea)
    if len(cs) == 8 and cs[0] == "BUG-139":
        # la 8a celda es una nota del director pegada DESPUES del cierre de fila:
        # se reubica dentro de la celda de Estado (no se pierde contenido)
        nota = cs[7]
        cs = cs[:7]
        cs[4] = cs[4] + " \u2014 " + nota
        lineas[i] = fila(cs)
        cambios += 1
    elif len(cs) == 6 and cs[0] == "BUG-118":
        # falta la celda de fecha: se declara la ausencia, no se inventa una fecha
        cs.append("\u2014")
        lineas[i] = fila(cs)
        cambios += 1
if cambios != 2:
    sys.exit("ABORTA: se esperaban 2 filas reconstruidas (L159/L205), hubo %d" % cambios)
texto = "\n".join(lineas)
log.append("L159/L205 fila_malformada -> 7 celdas (nota reubicada / fecha declarada ausente)")

# 6) Etiquetas de severidad: un nivel = una etiqueta (critica y menor)
lineas = texto.split("\n")
norm = 0
detalle = []
for i, linea in enumerate(lineas):
    if not linea.startswith("| BUG-"):
        continue
    cs = celdas(linea)
    if len(cs) != 7:
        continue
    celda = cs[3]
    for emo, nivel in SEV.items():
        if emo not in celda:
            continue
        resto = celda.replace(emo, "").strip()
        etiqueta = re.split(r"[(\u2014\-]", resto)[0].strip()
        if nivel in ("critica", "menor") and etiqueta != CANON[nivel]:
            sufijo = resto[len(etiqueta):]
            cs[3] = emo + " " + CANON[nivel] + sufijo
            lineas[i] = fila(cs)
            norm += 1
            detalle.append("%s %s->%s" % (cs[0], etiqueta, CANON[nivel]))
        break
texto = "\n".join(lineas)
log.append("etiqueta_severidad: %d celdas normalizadas" % norm)

assert texto != antes, "no se aplico ningun cambio"
io.open(RUTA, "wb").write(texto.encode("utf-8"))

print("CAMBIOS APLICADOS:")
for x in log:
    print("  -", x)
print("  - severidades:", ", ".join(detalle))
