#!/usr/bin/env python3
# M118: CI/CD - Coverage analyzer (iter 2 minimax-m3).
# Lee los ultimos reportes de tests y genera un reporte de cobertura
# por modulo (cuantos tests tiene cada modulo, cuantos pasan, cuantos fallan).
# Usage: python tools/ci/coverage.py [--report out/ci-report-dev.json] [--out coverage.json]

import os
import sys
import json
import re
import argparse
from typing import List, Dict

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def find_latest_report(project_root: str) -> str:
    """Encuentra el reporte CI mas reciente."""
    out_dir = os.path.join(project_root, "out")
    if not os.path.isdir(out_dir):
        return ""
    candidates: List[str] = []
    for root, _, files in os.walk(out_dir):
        for f in files:
            if f.startswith("ci-report") and f.endswith(".json"):
                candidates.append(os.path.join(root, f))
    if not candidates:
        return ""
    return max(candidates, key=os.path.getmtime)


def parse_godot_test_output(project_root: str) -> Dict:
    """Busca output de tests godot recientes (gdunit-*.xml) y parsea."""
    out_dir = os.path.join(project_root, "game", "isla-ancestral")
    tests_out: List[Dict] = []
    candidates: List[str] = []
    for d in ["user://", "user:/", os.path.join(out_dir, "user://"), os.path.join(out_dir, "tests/output/")]:
        full = os.path.join(out_dir, d.replace("user:///", "").replace("user://", "").replace("user:/", ""))
        if os.path.isdir(full):
            for f in os.listdir(full):
                if f.startswith("gdunit-") and f.endswith(".xml"):
                    candidates.append(os.path.join(full, f))
    for path in candidates:
        if not os.path.exists(path):
            continue
        try:
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            # parseo simple: busca "failures" y "tests"
            m_fail = re.search(r'failures="(\d+)"', content)
            m_tests = re.search(r'tests="(\d+)"', content)
            m_errors = re.search(r'errors="(\d+)"', content)
            tests_out.append({
                "path": path,
                "tests": int(m_tests.group(1)) if m_tests else 0,
                "failures": int(m_fail.group(1)) if m_fail else 0,
                "errors": int(m_errors.group(1)) if m_errors else 0,
            })
        except (OSError, UnicodeDecodeError):
            pass
    return {"files": tests_out}


def analyze_test_files(project_root: str) -> List[Dict]:
    """Cuenta test_*.gd por modulo (carpeta)."""
    scripts_root = os.path.join(project_root, "game", "isla-ancestral", "scripts")
    tests_root = os.path.join(project_root, "game", "isla-ancestral", "tests")
    modulos: Dict[str, int] = {}
    for root_dir in [scripts_root, tests_root]:
        if not os.path.isdir(root_dir):
            continue
        skip = {".import", "test_temp"}
        for dirpath, dirnames, filenames in os.walk(root_dir):
            dirnames[:] = [d for d in dirnames if d not in skip]
            for f in filenames:
                if f.startswith("test_") and f.endswith(".gd"):
                    mod = os.path.basename(dirpath) or "raiz"
                    modulos[mod] = modulos.get(mod, 0) + 1
    return [{"modulo": m, "test_files": n} for m, n in sorted(modulos.items(), key=lambda x: -x[1])]


def main() -> int:
    parser = argparse.ArgumentParser(description="Coverage analyzer (M118)")
    parser.add_argument("--report", default=None, help="Path al ultimo reporte CI (default: busca en out/)")
    parser.add_argument("--out", default=os.path.join(PROJECT_ROOT, "out", "coverage.json"), help="Path al reporte de salida")
    args = parser.parse_args()

    report_path = args.report or find_latest_report(PROJECT_ROOT)
    test_result = parse_godot_test_output(PROJECT_ROOT) if report_path else {"files": []}
    if report_path:
        test_result["ci_report_source"] = report_path
        try:
            with open(report_path, "r", encoding="utf-8") as f:
                ci = json.load(f)
            test_result["ci_summary"] = {
                "ok_steps": ci.get("ok_steps", 0),
                "fail_steps": ci.get("fail_steps", 0),
                "total_steps": ci.get("total_steps", 0),
                "duration_s": ci.get("duration_s", 0.0),
            }
        except (OSError, json.JSONDecodeError):
            pass

    test_files_per_module = analyze_test_files(PROJECT_ROOT)
    total_test_files = sum(m["test_files"] for m in test_files_per_module)

    summary = {
        "timestamp": __import__("datetime").datetime.now().isoformat(),
        "test_files_total": total_test_files,
        "test_files_per_module": test_files_per_module,
        "gdunit_runs": test_result,
    }
    os.makedirs(os.path.dirname(args.out) or ".", exist_ok=True)
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)
    print(f"[coverage] {total_test_files} test files en {len(test_files_per_module)} modulos -> {args.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
