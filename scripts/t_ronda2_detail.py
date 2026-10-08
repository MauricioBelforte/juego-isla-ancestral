# -*- coding: utf-8 -*-
import re, os, glob

def impl_x(name, mid):
    ck = "DOCUMENTACION/" + name + "/plan-actual/05-Checklist.md"
    c = open(ck, "rb").read().decode("utf-8")
    print("\n### %s" % mid)
    for L in c.splitlines():
        m = re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I)
        if m and re.search(r"[Ii]mplement", m.group(1)):
            print("  [x] %s" % m.group(1)[:78])

# M104 documental - los 9 "implementar"
impl_x("104-Analytics", "M104 'Implementar [x]' (mod. documental, AnalyticsDirector.gd AUSENTE):")
# M110 - [x] que citan archivos ausentes
ck = "DOCUMENTACION/110-Debug-Menu/plan-actual/05-Checklist.md"
c = open(ck, "rb").read().decode("utf-8")
absent = ["DebugCommands.gd", "DebugMenu.gd", "DebugVisualizer.gd", "DiagnosticExporter.gd", "debug_config.json"]
print("\n### M110 [x] que citan archivos AUSENTES (21/30 de 04-Codigo):")
for L in c.splitlines():
    m = re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I)
    if m and any(a in m.group(1) for a in absent):
        print("  [x] %s" % m.group(1)[:80])
