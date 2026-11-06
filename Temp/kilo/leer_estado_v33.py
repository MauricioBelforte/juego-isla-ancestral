# -*- coding: utf-8 -*-
"""PASO 0 vuelta 33: leer Logs/estado_director.json (io.open UTF-8). Total claves, nuevas vs 391 (v32), campos ling/pt/go/bug152/gemelos/nemotron/hy3."""
import io
import json

P = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Logs\estado_director.json"
with io.open(P, "r", encoding="utf-8") as f:
    data = json.load(f)

print("TOTAL CLAVES:", len(data))
print()
# Claves que mencionan a Ling / pt / go / bug152 / gemelos / nemotron / hy3 / tanda / 343 / 344
patrones = [u"ling", u"pt", u"go", u"bug152", u"gemelos", u"nemotron", u"hy3", u"tanda", u"343", u"344", u"i18n", u"cron", u"vuelta"]
for k in sorted(data.keys(), key=lambda s: s.lower()):
    kl = k.lower()
    if any(p in kl for p in patrones):
        v = data[k]
        sv = json.dumps(v, ensure_ascii=False)
        if len(sv) > 300:
            sv = sv[:300] + u"..."
        print(u"[" + k + u"] = " + sv)
print()
# Campos específicos de interés
for k in [u"ling_344_acusado", u"ling_343_visto", u"ling_343_acusado", u"ling_backlog_reestructurado", u"go4_pt_runtime_DONE", u"go4_cerrado_bilateral", u"hy3_reintegrada_4nov", u"ling_tanda_343", u"ling_tanda_i18n"]:
    if k in data:
        print(u"CAMPO " + k + u": " + json.dumps(data[k], ensure_ascii=False)[:400])
