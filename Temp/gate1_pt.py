import os, re
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
g = os.path.join(root, "game", "isla-ancestral")
pt = os.path.join(g, "locales", "pt.po")
print("pt.po:", os.path.exists(pt), ("%d bytes" % os.path.getsize(pt)) if os.path.exists(pt) else "")
if os.path.exists(pt):
    c = open(pt, encoding="utf-8-sig", errors="ignore").read()
    print("pt.po entradas msgid:", c.count("msgid"), "| Language: pt:", "Language: pt" in c)
lm = os.path.join(g, "scripts", "localization", "localization_manager.gd")
c = open(lm, encoding="utf-8-sig", errors="ignore").read()
m = re.search(r"LOCALES_SOPORTADOS\s*=\s*\[[^\]]*\]", c)
print("LOCALES_SOPORTADOS:", m.group(0) if m else "not found")
print('has "pt" in manager:', '"pt"' in c)
print("_indice_plural present:", bool(re.search(r"_indice_plural", c)))
lu = os.path.join(g, "scripts", "localization", "locale_utils.gd")
if os.path.exists(lu):
    clu = open(lu, encoding="utf-8-sig", errors="ignore").read()
    print("locale_utils has pt:", '"pt"' in clu or "Portug" in clu)
