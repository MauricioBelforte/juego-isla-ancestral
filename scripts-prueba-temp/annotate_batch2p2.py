#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Patron D batch 2 parte 2: anota cada '[ ]' con sub-linea '  · espera: <nota>'.
No toca [x] ni [?]. Preserva EOL (CRLF/LF) y BOM del archivo original.
Solo se ejecuta sobre los 3 checklists indicados; no commitea.
"""
import re

MODS = {
    "M95":  "DOCUMENTACION/95-Monetizacion/plan-actual/05-Checklist.md",
    "M53":  "DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md",
    "M108": "DOCUMENTACION/108-Pipeline-De-Assets/plan-actual/05-Checklist.md",
}

ITEM_RE = re.compile(r'^(\s*)-\s*\[\s*\]\s*(.*)$')
LISTSTART_RE = re.compile(r'^\s*-\s*\[[ xX\?]\]')
HEADING_RE = re.compile(r'^\s*#{1,6}\s')
MOD_REF_RE = re.compile(r'\bM(\d{1,3})\b')

def derive(content):
    t = content.strip()
    refs = sorted(set(int(m) for m in MOD_REF_RE.findall(t)))
    refstr = ("M" + "/M".join(str(r) for r in refs)) if refs else None
    low = " " + t.lower() + " "
    if refstr:
        base = "depende de %s (coordinar con su dueno)" % refstr
    elif "definir" in low:
        base = "pendiente de definicion de diseno (contrato del item)"
    elif "documentar" in low:
        base = "pendiente de documentacion"
    elif any(k in low for k in (" implementar", " crear ", " agregar", " anadir", " desarrollar", " programar")):
        base = "pendiente de implementacion (codigo)"
    elif any(k in low for k in (" probar", " test", " verificar", " validar", " qa ")):
        base = "pendiente de verificacion/QA (criterio del item)"
    elif "integracion" in low or low.strip().startswith("integrar"):
        base = "pendiente de integracion (ver deps del item)"
    elif "bug" in low:
        base = "BUG conocido: anotado, NO arreglado (espera fix del dueno)"
    else:
        base = "pendiente de definicion/cierre (ver descripcion del item)"
    # tag final tipo [M]/[S]/[C] (no digitos)
    if not refstr:
        m = re.search(r'\[([A-Za-z]{1,4})\]\s*$', t)
        if m and not m.group(1).isdigit():
            base += " (marcado [%s])" % m.group(1)
    return base

def annotate(path):
    b = open(path, 'rb').read()
    had_bom = b[:3] == b'\xef\xbb\xbf'
    if had_bom:
        b = b[3:]
    term = b'\r\n' if b'\r\n' in b else b'\n'
    tstr = term.decode('utf-8')
    s = b.decode('utf-8')
    lines = s.split(tstr)
    out = []
    i = 0
    added = 0
    while i < len(lines):
        line = lines[i]
        m = ITEM_RE.match(line)
        if m:
            indent, content = m.group(1), m.group(2)
            out.append(line)
            # consumir lineas de continuacion del item
            j = i + 1
            while j < len(lines):
                nxt = lines[j]
                if nxt.strip() == "":
                    break
                if LISTSTART_RE.match(nxt):
                    break
                if HEADING_RE.match(nxt):
                    break
                out.append(nxt)
                j += 1
            note = derive(content)
            out.append(indent + "  · espera: " + note)
            added += 1
            i = j
        else:
            out.append(line)
            i += 1
    new = tstr.join(out)
    if not new.endswith(tstr):
        new += tstr
    with open(path, 'wb') as f:
        f.write(new.encode('utf-8'))  # sin BOM, EOL preservado (newline='' implicito en wb)
    return added, term, had_bom

if __name__ == "__main__":
    for mod, p in MODS.items():
        added, term, bom = annotate(p)
        print("%s: +%d '· espera:'  (EOL=%s, BOM=%s)" % (mod, added, "CRLF" if term == b'\r\n' else "LF", bom))
