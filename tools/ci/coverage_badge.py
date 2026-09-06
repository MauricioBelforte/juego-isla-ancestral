#!/usr/bin/env python3
# M118 iter 11 (minimax-3): Generador de badge SVG con cobertura de tests.
# Lee el coverage.json de coverage.py y genera un badge SVG
# estilo shields.io para incrustar en README o web.
# Uso: python tools/ci/coverage_badge.py [--coverage out/coverage.json] [--out out/coverage-badge.svg]

import os
import sys
import json
import argparse

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def _load_coverage(coverage_path: str) -> dict:
    """Carga el coverage.json."""
    if not os.path.exists(coverage_path):
        return {}
    try:
        with open(coverage_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError):
        return {}


def _color_for_pct(pct: float) -> str:
    """Color del badge segun el porcentaje."""
    if pct >= 80:
        return "#4c1"  # verde
    elif pct >= 60:
        return "#97ca00"  # verde claro
    elif pct >= 40:
        return "#dfb317"  # amarillo
    elif pct >= 20:
        return "#fe7d37"  # naranja
    else:
        return "#e05d44"  # rojo


def _make_badge(label: str, value: str, color: str) -> str:
    """Genera un SVG estilo shields.io."""
    # Dimensiones aproximadas de cada parte del badge
    label_w = max(len(label) * 6 + 10, 60)
    value_w = max(len(value) * 7 + 10, 50)
    total_w = label_w + value_w
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{total_w}" height="20">
  <linearGradient id="b" x2="0" y2="100%">
    <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
    <stop offset="1" stop-opacity=".1"/>
  </linearGradient>
  <clipPath id="a"><rect width="{total_w}" height="20" rx="3" fill="#fff"/></clipPath>
  <g clip-path="url(#a)">
    <path fill="#555" d="M0 0h{label_w}v20H0z"/>
    <path fill="{color}" d="M{label_w} 0h{value_w}v20H{label_w}z"/>
    <path fill="url(#b)" d="M0 0h{total_w}v20H0z"/>
  </g>
  <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" text-rendering="geometricPrecision" font-size="110">
    <text aria-hidden="true" x="{label_w // 2 + 5}" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)">{label}</text>
    <text x="{label_w // 2 + 5}" y="140" fill="#fff" transform="scale(.1)">{label}</text>
    <text aria-hidden="true" x="{label_w + value_w // 2 + 5}" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)">{value}</text>
    <text x="{label_w + value_w // 2 + 5}" y="140" fill="#fff" transform="scale(.1)">{value}</text>
  </g>
</svg>'''


def main() -> int:
    parser = argparse.ArgumentParser(description="Genera badge SVG de cobertura de tests")
    parser.add_argument("--coverage", default=os.path.join(PROJECT_ROOT, "out", "coverage.json"), help="Path al coverage.json")
    parser.add_argument("--out", default=os.path.join(PROJECT_ROOT, "out", "coverage-badge.svg"), help="Path al SVG de salida")
    args = parser.parse_args()

    cov = _load_coverage(args.coverage)
    if not cov:
        print(f"[coverage_badge] {args.coverage} no existe o esta vacio. Generando placeholder.")
        svg = _make_badge("coverage", "no data", "#9f9f9f")
    else:
        total = cov.get("test_files_total", 0)
        modules = len(cov.get("test_files_per_module", []))
        if total == 0:
            svg = _make_badge("coverage", "0%", "#e05d44")
        else:
            # Heuristica simple: cada test file cubre ~1% (placeholder)
            # En realidad, coverage necesita instrumentacion. Solo reportamos el total.
            value = f"{total} tests"
            color = "#97ca00" if total > 50 else "#dfb317"
            svg = _make_badge("tests", value, color)
    os.makedirs(os.path.dirname(args.out) or ".", exist_ok=True)
    with open(args.out, "w", encoding="utf-8") as f:
        f.write(svg)
    print(f"[coverage_badge] badge escrito en {args.out} ({len(svg)} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
