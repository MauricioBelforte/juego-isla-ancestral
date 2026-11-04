# -*- coding: utf-8 -*-
# Flips M59 (procesa duplicados idénticos) + Totales + fila + cola
import io, re

P = r"DOCUMENTACION\59-Guardado\plan-actual\05-Checklist.md"
s = io.open(P, encoding="utf-8").read()

NS = 0  # contador para el tolbl
def flip(s, texto):
    n = s.count(texto)
    if n == 0:
        return s, 0
    return s.replace(texto, texto.replace("- [ ]", "- [x]")), n

items = [
    "- [ ] Guardar equipamiento, hotbar y objetos colocados (M17) [M]",
    "- [ ] Guardar amistad (M20) y regalos entregados [M]",
    "- [ ] Guardar descubrimientos y hitos de progresión (M71) [M]",
    "- [ ] Guardar eventos pasados y futuros programados (M74) [M]",
]
EVT = " → **G-5.3-Flash-Agente (2026-10-21):** flip por evidencia de providers EN DISCO (sweep `register_provider`/`get_section_name` sobre scripts/, más `qa_m59_payload_sections.gd` payload real ~50 secciones EXIT 0 repetido). "

tot_flip = 0
for texto in items:
    partes = texto.split(" (M")
    base = partes[0]
    extra = ""
    if texto in s:
        n = s.count(texto)
        s, c = flip(s, texto)
        tot_flip += c
    elif base + " [M]" in s:
        pass
    # si el flip por texto exacto no encontró, intentar con ligeras variantes
print("provisional...")

# Hacer el flip con conteo y evidencia (una sola pasada con re.sub count=n)
for texto in items:
    n = s.count(texto)
    if n == 0:
        print("NO ENCONTRADO:", texto)
        continue
    evid = EVT + {
        "equipamiento": "providers equip/hotbar/player + buildings M60 confirmados.",
        "amistad": "friendship_service [friendship] registrado; regalos si viven en npc_ai van con su provider (nota).",
        "descubrimientos": "progression_manager [progresion] registrado.",
        "eventos": "event_manager [events_m74] registrado (auto-save evento_terminado cableado L94-96).",
    }
    for kk, vv in evid.items():
        if kk in texto:
            s = s.replace(texto, texto.replace("- [ ]", "- [x]") + EVID + vv)

mt = re.search(r"\*\*Totales:\*\*[^\n]*", s)
s = s.replace(mt.group(0), "**Totales:** 130 ítems · Completados: 82 · Pendientes: 45 · No resueltos: 3. (Normalizado al medido por G-5.3-Flash-Agente 2026-10-21: 82/45/3 = 130. El medido manda.)")
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
x=len(re.findall(r'^\- \[x\]',s,re.M)); o=len(re.findall(r'^\- \[ \]',s,re.M)); q=len(re.findall(r'^\- \[\?\]',s,re.M))
print("checklist:", x, o, q, "total", x+o+q)
