#!/usr/bin/env python3
"""M100 — report_analyzer.py: analiza reportes de comunidad y genera métricas."""
import json, pathlib, re

def analyze_reports(reports_file: str = "res://data/community/reports.json") -> dict:
    """Lee reportes y devuelve métricas de severidad + categorías."""
    path = pathlib.Path(reports_file)
    if not path.exists():
        return {"total": 0, "por_categoria": {}, "severidad_media": 0.0}
    data = json.loads(path.read_text())
    reports = data.get("reportes", [])
    total = len(reports)
    cats = {}
    sev_sum = 0
    for r in reports:
        c = r.get("categoria", "otro")
        cats[c] = cats.get(c, 0) + 1
        sev_sum += r.get("severidad", 1)
    return {
        "total": total,
        "por_categoria": cats,
        "severidad_media": round(sev_sum / total, 2) if total > 0 else 0.0
    }

if __name__ == "__main__":
    m = analyze_reports()
    print(json.dumps(m, indent=2))
