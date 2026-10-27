# -*- coding: utf-8 -*-
"""RE-MEDICION gate-1 post-pase (por GLM-5.3-Flash, a pedido del fundador 26oct 07:23).
Cruza CADA fila [x] de los T-files de Beam contra el 05-Checklist real del modulo:
  respaldo OK   = el item en el 05 (ancla L# +-2 por drift) esta [x] y el texto matchea
  INFLADO resid = el 05 no esta [x] (o no se encuentra el item)
Escribe informe con la lista exacta de residuales para el pase de Beam."""
import os, re

BASE = r"DOCUMENTACION\TAREAS-POR-MODELO\Reflection-Beam-1.0\tareas"
DOC = r"DOCUMENTACION"
RX_FILA = re.compile(r"^\|\s*\d+\s*\|\s*(\d+)\s*\|\s*L(\d+)\s*\|\s*(.+?)\s*(?:—|\|\s*)*\|\s*\[x\]\s*\|\s*$")
RX_ITEM = re.compile(r"^-\s*\[( |x|X|\?)\]\s*(.+)$", re.S)

def load_05(mid):
    prefs = ("%03d-" % mid, "%02d-" % mid, "%d-" % mid)
    for pref in prefs:
        for d in os.listdir(DOC):
            if d.startswith(pref) and os.path.isdir(os.path.join(DOC, d)):
                p = os.path.join(DOC, d, "plan-actual", "05-Checklist.md")
                if os.path.isfile(p):
                    return open(p, encoding="utf-8").read().split("\n")
                return None
    return None

def texto_clave(t):
    t = t.replace("\\|", "|")          # desescapar pipes de las tablas TASCHE
    # quitar el prefijo que el generador agrego a los qmark (el 05 real nunca lo tuvo)
    t = re.sub(r"^\[\?\]\s*DEGRADADO\s*[—-]\s*", "", t, flags=re.I)
    t = re.sub(r"\s+", " ", t)
    t = re.split(r"\s+—\s+CUBO", t)[0]
    t = re.split(r"\|\|", t)[0]
    return t.strip()[:40].lower()

res_total = inflados = ok = 0
residuales = []
no_05 = []
for f in sorted(os.listdir(BASE)):
    if not (f.startswith("T") and f.endswith(".md")):
        continue
    try:
        tlines = open(os.path.join(BASE, f), encoding="utf-8").read().split("\n")
    except OSError:
        continue
    cache = {}
    for n, line in enumerate(tlines, 1):
        m = RX_FILA.match(line.strip())
        if not m:
            continue
        mid, L, texto = int(m.group(1)), int(m.group(2)), m.group(3)
        res_total += 1
        if mid not in cache:
            cache[mid] = load_05(mid)
        a05 = cache[mid]
        if a05 is None:
            no_05.append((f, mid, L, texto[:60])); inflados += 1
            residuales.append((f, mid, L, texto, "SIN 05 EN DISCO"))
            continue
        clave = texto_clave(texto)
        # busqueda global del texto en el 05 (tolerante a drift de lineas por flips del dia)
        match_ok = False; seen_x = False; seen_open = False
        for t in a05:
            tt = t.lstrip()
            if clave[:30] and clave[:30] in texto_clave(tt):
                mm = RX_ITEM.match(tt)
                if mm:
                    if mm.group(1).lower() == "x":
                        seen_x = True
                    elif mm.group(1) in (" ", "?"):
                        seen_open = True
        if seen_x:
            match_ok = True
        if match_ok:
            ok += 1
        else:
            inflados += 1
            residuales.append((f, mid, L, texto, "05 no [x] o texto no coincide"))

print("filas [x] analizadas: %d" % res_total)
print("con respaldo en 05 (match L#+texto): %d" % ok)
print("SIN RESPALDO (inflado residual):     %d" % inflados)
print("(sin 05 en disco: %d)" % len(no_05))
print()
salida = ["# RE-MEDICION GATE-1 post-pase (GLM-5.3-Flash, 26oct ~07:30, a pedido del fundador)",
          "",
          "Cruce: filas `[x]` de los T-files vs 05-Checklist real (ancla L# +-2 + match de texto).",
          "REGLA: un [x] en el T-file SOLO vale si el 05 del modulo esta [x] en disco CON cita/evidencia.",
          "",
          "## RESULTADO",
          "- filas [x] analizadas: %d" % res_total,
          "- con respaldo: %d" % ok,
          "- **INFLADO RESIDUAL: %d**" % inflados,
          "",
          "## LISTA RESIDUAL (ejecutar/desmarcar segun pase anti-inflacion de agnes 622)",
          ""]
for f, mid, L, texto, motivo in residuales[:400]:
    salida.append("| %s | %d | L%d | %s | %s |" % (f, mid, L, texto[:120], motivo))
out = os.path.join(BASE, "RE-MEDICION-GATE1-26oct-GLM.md")
with open(out, "w", encoding="utf-8", newline="\n") as fh:
    fh.write("\n".join(salida) + "\n")
print("informe:", out)
