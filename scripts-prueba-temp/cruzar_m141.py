# -*- coding: utf-8 -*-
import io, re, sys
sys.stdout.reconfigure(encoding="utf-8")
spec = io.open("DOCUMENTACION/141-Beta/plan-actual/m141_spec.md", encoding="utf-8").read()
print("=== Secciones de la spec ===")
for m in re.finditer(r"(?m)^## (\d+)\. (.+)$", spec):
    print("  §%s %s" % (m.group(1), m.group(2)))
print()
# cruzar items citados
checks = [
 ("S5 audio 100%", "Definir el 100% de audio implementado (M41-M44)", ["Subt", "Audio", "musica"]),
 ("S6 localizacion", "Definir el 100% de textos localizados (M87)", ["Localizaci", "ES/EN"]),
 ("S7 accesibilidad", "Definir el 100% de accesibilidad implementada (M58)", ["Subt", "Fuentes", "Colorblind"]),
 ("S8 rendimiento", "Definir el 100% del presupuesto M61-M63 cumplido", ["60 FPS", "memory leak", "Carga"]),
 ("S10 plataformas", "Definir build estable y auto-update", ["Build estable", "Auto-update"]),
 ("S11 store", "Definir la store page final", []),
 ("S12 trailer", "Definir el trailer final", []),
 ("S13 certificacion", "Definir la certificacion de plataformas", []),
]
for etiqueta, item, claves in checks:
    if not claves:
        estado = "SIN CLAVE EN SPEC (item de cierre/marketing)"
    else:
        encontradas = [k for k in claves if k.lower() in spec.lower()]
        estado = "RESPALDADA (%s)" % ", ".join(encontradas) if encontradas else "NO RESPALDADA en spec"
    print("  %-22s %s" % (etiqueta, estado))
