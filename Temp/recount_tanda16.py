import os, re, sys

BASE = "DOCUMENTACION"
MODS = {
    "M78": "78-Legal-Propiedad-Intelectual",
    "M81": "81-Legal-Menores",
    "M83": "83-Licencias-De-Software",
    "M85": "85-Modelos-3D-Legal",
    "M89": "89-Diseno-De-Menus",
    "M95": "95-Monetizacion",
    "M98": "98-Trailer",
    "M111": "111-Codigo-De-Calidad",
}

# Trampa #3: regex de prefijo de linea (no cuenta menciones inline)
LINE_RE = re.compile(r'^\s*(?:\d+\.|[-*])\s+\[([ x?>-])\]')
# Prose Totales: "NNN·NNN·NNN·NNN"
TOTALES_RE = re.compile(r'(\d+)\s*[·.]\s*(\d+)\s*[·.]\s*(\d+)\s*[·.]\s*(\d+)')

def recount(path):
    with open(path, encoding='utf-8') as f:
        text = f.read()
    lines = text.splitlines()
    counts = {'x':0,'?':0,' ':0,'>':0,'-':0}
    for ln in lines:
        m = LINE_RE.match(ln)
        if m:
            counts[m.group(1)] += 1
    # Totales prose: buscar linea que contenga "Total" y 4 numeros
    totales = None
    for ln in lines:
        if re.search(r'total', ln, re.I):
            mt = TOTALES_RE.search(ln)
            if mt:
                totales = tuple(int(x) for x in mt.groups())
                break
    return counts, totales, len(lines)

print(f"{'MOD':<6}{'x':>5}{'?':>5}{'[]':>5}{'>':>4}{'-':>4}  {'Totales(prose)':<24} lines")
for mod, folder in MODS.items():
    p = os.path.join(BASE, folder, "plan-actual", "05-Checklist.md")
    if not os.path.exists(p):
        print(f"{mod:<6}  <MISSING {p}>")
        continue
    c, tot, nl = recount(p)
    print(f"{mod:<6}{c['x']:>5}{c['?']:>5}{c[' ']:>5}{c['>']:>4}{c['-']:>4}  {str(tot):<24} {nl}")
