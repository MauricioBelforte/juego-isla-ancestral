# -*- coding: utf-8 -*-
"""Leer COMPLETO los campos criticos de estado_director.json para vuelta 29."""
import io
import json

e = json.load(io.open("Logs/estado_director.json", encoding="utf-8"))
campos = [
    "decisiones_fundador",
    "consultas_fundador_23oct",
    "go4_pt_runtime_DONE",
    "go4_cerrado_bilateral",
    "go_pendientes_27oct",
    "bug152_go_aplicar",
    "bug152_resuelto",
    "bug152_qa_dirty_item4",
    "ling_rielp_pt_intacto",
    "ling_pt_blindaje_k2k3",
    "ling_rielp",
    "ling_standby_completo",
    "ling_repoblada_m87",
    "ling_m87_ejecutando",
    "m87_cerrado_m87",
    "pendiente_lectura_proximo_director",
    "ultimo_update",
    "record_dia",
    "bug152_resuelto",
    "m55_guardian_test_diario_persist",
]
for c in campos:
    if c in e:
        print("=" * 30, c, "=" * 30)
        print(json.dumps(e[c], ensure_ascii=False, indent=2)[:2500])
    else:
        print("=" * 30, c, "= AUSENTE")
