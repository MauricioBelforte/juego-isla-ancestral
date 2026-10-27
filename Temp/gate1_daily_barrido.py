import os, re, glob
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
doc = os.path.join(root, "DOCUMENTACION")
game = os.path.join(root, "game", "isla-ancestral")

def load(mod):
    for d in os.listdir(doc):
        if d.startswith(mod + "-"):
            p = os.path.join(doc, d, "plan-actual", "05-Checklist.md")
            if os.path.exists(p):
                return open(p, encoding="utf-8-sig", errors="ignore").read()
    return None

CREAT = re.compile(r"(Crear|crear|Implementar|implementar|Agregar|agregar|Escribir|escribir|Configurar|configurar|Integrar|integrar|Conectar|conectar|Generar|generar|Construir|construir|Aadir|añadir|Disenar|diseñar|Adicionar|adicionar|Agregar|Instalar|instalar|Cargar|cargar|Definir|definir|Documentar|Registrar|Mapa)", re.I)
def is_code_item(txt):
    # has .gd / .tscn / CamelCase component, and a creation verb
    hascode = (".gd" in txt) or (".tscn" in txt) or (".tres" in txt) or re.search(r"\b[A-Z][a-z]+[A-Z]", txt)
    hasverb = re.search(r"(Crear|crear|Implementar|implementar|Agregar|agregar|Escribir|escribir|Configurar|configurar|Integrar|integrar|Conectar|conectar|Generar|generar|Construir|construir|añadir|Añadir)", txt, re.I)
    return hascode and hasverb

def grep(term):
    hits = set()
    t = term.lower()
    for pat in ["*.gd", "*.tscn", "*.tres", "*.json", "*.cfg"]:
        for f in glob.glob(os.path.join(game, "**", pat), recursive=True):
            b = os.path.basename(f).lower()
            if t in b:
                hits.add(os.path.relpath(f, root))
    return sorted(hits)[:2]

for mod in ["48", "53"]:
    print("==== M%s ====" % mod)
    body = load(mod)
    picked = 0
    for i, l in enumerate(body.splitlines()):
        m = re.match(r"^\s*-\s*\[x\]\s*(.+)", l)
        if m and is_code_item(m.group(1)):
            txt = m.group(1).strip()
            # extract component names: CamelCase tokens and .gd filenames
            camel = re.findall(r"\b[A-Z][a-z]{2,}[A-Za-z]*\b", txt)
            gdnames = re.findall(r"[\w/]+\.(?:gd|tscn|tres)", txt)
            probes = [g.split("/")[-1] for g in gdnames] + [c for c in camel if c not in ("M45","M48","M53","The","A","An")]
            print("  L%d: %s" % (i + 1, txt[:65]))
            found = False
            for p in probes[:4]:
                h = grep(p)
                if h:
                    print("        -> DISCO OK: " + "; ".join(h)); found = True; break
            if not found and probes:
                print("        -> 0 hits en disco (probes=%s)" % str(probes[:4]))
            elif not found and not probes:
                print("        -> (sin probe de codigo; item doc/diseno)")
            picked += 1
            if picked >= 5:
                break
    print()
