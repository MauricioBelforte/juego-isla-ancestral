#!/usr/bin/env python3
# M144: Post-Lanzamiento - Generador data-driven de checklist operacional.
# Lee data/operaciones/postlaunch_checks.json y produce
# POSTLAUNCH_CHECKLIST.md (markdown) + postlaunch_checklist.json (machine-readable).
# Uso: python tools/postlaunch/generate_postlaunch_checklist.py [--out-dir <dir>]

import os
import sys
import json
import argparse
from datetime import datetime
from typing import List, Dict

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
DATA_PATH = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data", "operaciones", "postlaunch_checks.json")


def _load(path: str) -> dict:
    if not os.path.exists(path):
        print(f"ERROR: {path} no existe", file=sys.stderr)
        return {}
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def _frecuencia_emoji(frec: str) -> str:
    frec = (frec or "").lower()
    if "diaria" in frec:
        return "[DIARIA]"
    if "semanal" in frec:
        return "[SEMANAL]"
    if "tiempo_real" in frec:
        return "[REAL-TIME]"
    if "por_parche" in frec or "por_bug" in frec:
        return "[POR EVENTO]"
    return f"[{frec.upper()}]"


def generate_markdown(data: dict) -> str:
    """Genera POSTLAUNCH_CHECKLIST.md."""
    lineas: List[str] = [
        "# Isla Ancestral — Post-Lanzamiento Checklist Operacional",
        "",
        f"_Generado automaticamente por `tools/postlaunch/generate_postlaunch_checklist.py` el {datetime.now().isoformat()}_",
        "",
        "## Politicas generales",
        "",
    ]
    for k, v in data.get("politicas", {}).items():
        if isinstance(v, list):
            lineas.append(f"- **{k}**: {', '.join(str(x) for x in v)}")
        else:
            lineas.append(f"- **{k}**: {v}")
    lineas.append("")
    lineas.append("## Checks por categoria")
    lineas.append("")
    for cat_id, cat in data.get("checks", {}).items():
        lineas.append(f"### {cat.get('titulo', cat_id)}")
        lineas.append("")
        lineas.append(f"- **Frecuencia minima**: {cat.get('frecuencia', '?')}")
        lineas.append("")
        lineas.append("| ID | Titulo | Dueno | Frecuencia | SLA / Umbral | Metricas |")
        lineas.append("|----|--------|-------|------------|--------------|----------|")
        for it in cat.get("items", []):
            it_id = it.get("id", "?")
            titulo = it.get("titulo", "?")
            dueno = it.get("dueno", "-")
            frec = it.get("frecuencia", "-")
            sla = it.get("sla") or it.get("umbral") or it.get("metodo") or "-"
            metricas = ", ".join(it.get("metricas", [])) or "-"
            lineas.append(f"| `{it_id}` | {titulo} | {dueno} | {_frecuencia_emoji(frec)} | {sla} | {metricas} |")
        lineas.append("")
    return "\n".join(lineas) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Genera checklist operacional de post-lanzamiento")
    parser.add_argument("--out-dir", default=PROJECT_ROOT, help="Directorio destino (default: project root)")
    args = parser.parse_args()

    data = _load(DATA_PATH)
    if not data:
        return 1

    md = generate_markdown(data)
    out_dir = args.out_dir
    os.makedirs(out_dir, exist_ok=True)
    out_md = os.path.join(out_dir, "POSTLAUNCH_CHECKLIST.md")
    out_json = os.path.join(out_dir, "postlaunch_checklist.json")

    with open(out_md, "w", encoding="utf-8") as f:
        f.write(md)
    with open(out_json, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    checks_total = sum(len(c.get("items", [])) for c in data.get("checks", {}).values())
    cats = len(data.get("checks", {}))
    print(f"[M144] {checks_total} checks en {cats} categorias")
    print(f"[M144] POSTLAUNCH_CHECKLIST.md -> {out_md}")
    print(f"[M144] postlaunch_checklist.json -> {out_json}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
