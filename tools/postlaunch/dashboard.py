#!/usr/bin/env python3
# M144: Post-Lanzamiento - Dashboard data-driven (iter 2 minimax-m3).
# Agrega los JSONs en out/ y produce:
#   - out/dashboard.html (HTML con bootstrap minimal, sin CDN - 100% offline)
#   - out/dashboard.json (data agregada para integracion con M143)
#   - out/alerts.json (alertas inmediatas segun el plan-actual)
# Uso: python tools/postlaunch/dashboard.py [--in-dir out] [--out-dir out]

import os
import sys
import json
import argparse
import glob
from datetime import datetime, timedelta
from typing import List, Dict

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def _load_json_files(in_dir: str) -> Dict[str, dict]:
    """Carga todos los JSONs en in_dir."""
    if not os.path.isdir(in_dir):
        return {}
    result: Dict[str, dict] = {}
    for path in glob.glob(os.path.join(in_dir, "*.json")):
        name = os.path.splitext(os.path.basename(path))[0]
        try:
            with open(path, "r", encoding="utf-8") as f:
                result[name] = json.load(f)
        except (OSError, json.JSONDecodeError) as e:
            print(f"[dashboard] WARN {path}: {e}", file=sys.stderr)
    return result


def _compute_health_summary(data: Dict[str, dict]) -> Dict:
    """Calcula resumen de salud a partir de los JSONs cargados."""
    summary = {
        "timestamp": datetime.now().isoformat(),
        "data_sources": len(data),
        "indicators": {},
        "alerts": [],
    }
    # Tests: si hay ci-report-*, resumir ok/fail
    for name, content in data.items():
        if name.startswith("ci-report"):
            summary["indicators"]["ci"] = {
                "ok_steps": content.get("ok_steps", 0),
                "fail_steps": content.get("fail_steps", 0),
                "total_steps": content.get("total_steps", 0),
                "duration_s": content.get("duration_s", 0.0),
                "last_pipeline": name,
            }
        elif name == "coverage":
            summary["indicators"]["tests"] = {
                "test_files": content.get("test_files_total", 0),
                "modules_with_tests": len(content.get("test_files_per_module", [])),
            }
        elif name == "postlaunch_checklist":
            checks = content.get("checks", {})
            total = sum(len(c.get("items", [])) for c in checks.values())
            summary["indicators"]["postlaunch"] = {
                "total_checks": total,
                "categories": len(checks),
            }
    return summary


def _detect_alerts(summary: Dict) -> List[Dict]:
    """Detecta alertas segun el plan-actual (politicas del M144)."""
    alerts: List[Dict] = []
    ci = summary.get("indicators", {}).get("ci", {})
    if ci.get("fail_steps", 0) > 0:
        alerts.append({
            "severity": "critical",
            "category": "ci",
            "message": f"CI fallo: {ci.get('fail_steps', 0)} de {ci.get('total_steps', 0)} steps",
        })
    elif ci.get("duration_s", 0) > 900:  # 15 min
        alerts.append({
            "severity": "warning",
            "category": "ci",
            "message": f"CI lento: {ci.get('duration_s', 0):.0f}s (>15 min)",
        })
    tests = summary.get("indicators", {}).get("tests", {})
    if tests.get("test_files", 0) < 50:
        alerts.append({
            "severity": "warning",
            "category": "tests",
            "message": f"Pocos tests: solo {tests.get('test_files', 0)} archivos",
        })
    return alerts


def generate_html(summary: Dict, data: Dict) -> str:
    """Genera dashboard.html con bootstrap inline (sin CDN)."""
    css = """
body { font-family: -apple-system, sans-serif; margin: 20px; background: #f5f5f5; color: #222; }
h1 { color: #2c3e50; }
h2 { color: #34495e; border-bottom: 2px solid #3498db; padding-bottom: 5px; }
.metric { background: white; padding: 15px; margin: 10px 0; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
.metric .value { font-size: 2em; font-weight: bold; color: #3498db; }
.metric .label { color: #7f8c8d; font-size: 0.9em; }
.alert { padding: 12px; margin: 5px 0; border-left: 4px solid; border-radius: 4px; }
.alert.critical { background: #ffe6e6; border-color: #e74c3c; }
.alert.warning { background: #fff3cd; border-color: #f39c12; }
.alert.info { background: #d1ecf1; border-color: #17a2b8; }
table { width: 100%; border-collapse: collapse; background: white; }
th, td { padding: 8px 12px; text-align: left; border-bottom: 1px solid #ecf0f1; }
th { background: #34495e; color: white; }
"""
    html = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<title>Isla Ancestral - Dashboard Post-Lanzamiento</title>
<style>{css}</style>
</head>
<body>
<h1>Isla Ancestral - Dashboard Post-Lanzamiento</h1>
<p><small>Generado: {summary['timestamp']} | Fuentes: {summary['data_sources']}</small></p>
<h2>Indicadores</h2>
"""
    for ind_name, ind_data in summary.get("indicators", {}).items():
        html += f'<div class="metric"><div class="label">{ind_name.upper()}</div><div class="value">'
        if ind_name == "ci":
            html += f'{ind_data.get("ok_steps", 0)}/{ind_data.get("total_steps", 0)} steps OK ({ind_data.get("duration_s", 0):.1f}s)'
        elif ind_name == "tests":
            html += f'{ind_data.get("test_files", 0)} tests en {ind_data.get("modules_with_tests", 0)} modulos'
        elif ind_name == "postlaunch":
            html += f'{ind_data.get("total_checks", 0)} checks en {ind_data.get("categories", 0)} categorias'
        else:
            # No usar {ind_data} en f-string (es dict), usar repr
            html += repr(ind_data)
        html += '</div></div>\n'
    html += '<h2>Alertas</h2>\n'
    if not summary.get("alerts"):
        html += '<p><em>Sin alertas. Todo OK.</em></p>\n'
    else:
        for a in summary["alerts"]:
            html += f'<div class="alert {a["severity"]}"><strong>[{a["severity"].upper()}]</strong> {a["category"]}: {a["message"]}</div>\n'
    html += '<h2>Politicas (M144)</h2>\n<table>\n'
    html += '<tr><th>Politica</th><th>Valor</th></tr>\n'
    pl_data = data.get("postlaunch_checklist", {})
    for k, v in pl_data.get("politicas", {}).items():
        if isinstance(v, list):
            v = ", ".join(str(x) for x in v)
        html += f'<tr><td>{k}</td><td>{v}</td></tr>\n'
    html += '</table>\n<hr>\n<p><small>Generado por tools/postlaunch/dashboard.py. M144 iter 2 minimax-m3.</small></p>\n</body></html>\n'
    return html


def main() -> int:
    parser = argparse.ArgumentParser(description="Genera dashboard post-lanzamiento")
    parser.add_argument("--in-dir", default=os.path.join(PROJECT_ROOT, "out"), help="Directorio con JSONs de entrada")
    parser.add_argument("--out-dir", default=None, help="Directorio de salida (default: --in-dir)")
    args = parser.parse_args()
    out_dir = args.out_dir or args.in_dir
    os.makedirs(out_dir, exist_ok=True)

    data = _load_json_files(args.in_dir)
    if not data:
        print(f"[dashboard] WARN: no se encontraron JSONs en {args.in_dir}")
    summary = _compute_health_summary(data)
    summary["alerts"] = _detect_alerts(summary)

    # Salidas
    json_path = os.path.join(out_dir, "dashboard.json")
    alerts_path = os.path.join(out_dir, "alerts.json")
    html_path = os.path.join(out_dir, "dashboard.html")

    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)
    with open(alerts_path, "w", encoding="utf-8") as f:
        json.dump({"alerts": summary["alerts"], "timestamp": summary["timestamp"]}, f, indent=2, ensure_ascii=False)
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(generate_html(summary, data))

    print(f"[dashboard] {len(data)} JSONs agregados")
    print(f"[dashboard] {len(summary['alerts'])} alertas")
    print(f"[dashboard] HTML -> {html_path}")
    print(f"[dashboard] JSON -> {json_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
