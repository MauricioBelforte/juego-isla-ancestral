import json, os
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
p = os.path.join(root, "Logs", "estado_director.json")
d = json.load(open(p, encoding="utf-8-sig"))
d["nemotron_riels_b7_g2"] = {
    "fecha": "2026-10-28 03:40", "canal": "GLM #20/#21/#22 -> acuse #23",
    "contenido": "GLM (orden fundador) integro en Nemotron: riel B-7 = COLA-FALTANTE-A (26 items A vivos) en su BACKLOG-MASTER + cronometro (batch 5 + skip con motivo) - resuelve el falso 'backlog vacio' de Nemotron. + micro-riel G2 = 6 micro-tareas anti-trunca del veredicto dual gate-2 (G2-1 red_probe_event_bus.py, G2-5 reporte max 40 lineas) + nota ANTI-VACIO. Gate-2 ahora corre por B-7+G2 model-agnostic.",
    "agendas_agnes": ["ratificar relevo gate-2 Nemotron (B-7+G2)", "gate-1 de las tandas B-7/G2", "sello formal B-7 al cierre (tras re-medicion GLM)"]
}
g2 = d.get("gate2_model_agnostic") or {}
g2["ejecucion_nemotron"] = "via riel B-7 (cola 26) + micro-riel G2 (anti-trunca), cron 20min lo toma solo. No hace falta el tandem dual."
d["gate2_model_agnostic"] = g2
with open(p, "w", encoding="utf-8", newline="") as f:
    json.dump(d, f, ensure_ascii=False, indent=1)
print("estado: nemotron_riels_b7_g2 + gate2_model_agnostic.ejecucion")
