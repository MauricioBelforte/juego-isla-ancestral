# -*- coding: utf-8 -*-
"""Campos M157/M87/design-docs completos para decidir tanda doc v29."""
import io
import json

e = json.load(io.open("Logs/estado_director.json", encoding="utf-8"))
for c in ["m157_k_doc_cerrado", "m157_scaffold_OK", "m157_sin_05", "ling_asignada_m157",
          "m87_alcance_islas_items", "ling_design_docs", "m87_cerrado_m87",
          "hallazgo_import_cache_qa", "m22_hallazgo_p100"]:
    print("=" * 25, c, "=" * 25)
    if c in e:
        print(json.dumps(e[c], ensure_ascii=False, indent=2)[:1800])
    else:
        print("AUSENTE")
