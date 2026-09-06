#!/usr/bin/env python3
# M118 CI-CD iter 3 (minimax-m3): Generador de CHANGELOG.md data-driven.
# Lee el historial de git, filtra por tag (o rango) y genera un CHANGELOG.md
# con formato Keep a Changelog (added/changed/fixed/removed).
# Tambien puede leer un JSON de convenciones para categorizar commits por prefijo.
# Uso: python tools/ci/changelog.py [--from v0.1.0] [--to v0.2.0] [--out CHANGELOG.md]

import os
import sys
import json
import re
import argparse
import subprocess
from datetime import datetime
from typing import List, Dict, Optional, Tuple

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
CONVENTIONS_PATH = os.path.join(PROJECT_ROOT, "data", "operaciones", "commit_conventions.json")


def _git(*args: str) -> str:
    """Ejecuta git con cwd=PROJECT_ROOT. Devuelve stdout."""
    try:
        result = subprocess.run(
            ["git"] + list(args),
            capture_output=True,
            timeout=30,
            cwd=PROJECT_ROOT,
        )
        if result.returncode == 0:
            return result.stdout.decode("utf-8", errors="replace")
    except (OSError, subprocess.TimeoutExpired):
        pass
    return ""


def _load_conventions() -> Dict:
    """Carga convenciones de categorizacion (default Conventional Commits)."""
    if os.path.exists(CONVENTIONS_PATH):
        try:
            with open(CONVENTIONS_PATH, "r", encoding="utf-8") as f:
                return json.load(f)
        except (OSError, json.JSONDecodeError):
            pass
    # Default: Conventional Commits
    return {
        "version": 1,
        "categorias": {
            "feat": "Added",
            "fix": "Fixed",
            "docs": "Documentation",
            "style": "Changed",
            "refactor": "Changed",
            "perf": "Changed",
            "test": "Changed",
            "chore": "Changed",
            "revert": "Removed",
            "breaking": "Breaking",
        },
    }


def _categoria(prefix: str, conventions: Dict) -> str:
    """Devuelve la categoria del commit segun el prefijo y las convenciones."""
    return conventions.get("categorias", {}).get(prefix, "Changed")


def _parsear_commits(commits_raw: str) -> List[Dict]:
    """Parsea el output de git log en una lista de commits."""
    commits: List[Dict] = []
    # Formato: hash|date|prefixo:subject
    for line in commits_raw.split("\n"):
        line = line.strip()
        if not line:
            continue
        parts = line.split("|", 2)
        if len(parts) < 3:
            continue
        h, fecha, subject = parts
        # Detectar prefijo (feat:, fix:, etc)
        prefix: str = ""
        prefix_match = re.match(r"^([a-z]+)(?:\([^)]+\))?!?:\s*", subject, re.IGNORECASE)
        if prefix_match:
            prefix = prefix_match.group(1).lower()
        commits.append({
            "hash": h.strip(),
            "date": fecha.strip(),
            "subject": subject.strip(),
            "prefix": prefix,
        })
    return commits


def _agrupar_por_categoria(commits: List[Dict], conventions: Dict) -> Dict[str, List[str]]:
    """Agrupa commits por categoria (Added/Changed/Fixed/etc)."""
    grouped: Dict[str, List[str]] = {}
    for c in commits:
        cat = _categoria(c["prefix"], conventions) if c["prefix"] else "Changed"
        if cat not in grouped:
            grouped[cat] = []
        # Formato markdown: - subject (hash)
        grouped[cat].append(f"- {c['subject']} ({c['hash'][:7]})")
    return grouped


def _detectar_breaking_changes(commits: List[Dict]) -> List[str]:
    """Detecta breaking changes (prefijo con '!')."""
    breaking: List[str] = []
    for c in commits:
        # Conventional Commits: feat!:, fix!:, etc.
        if "!" in c["subject"].split(":")[0] or "BREAKING CHANGE" in c["subject"]:
            breaking.append(f"- {c['subject']} ({c['hash'][:7]})")
    return breaking


def _obtener_version(tag: str) -> str:
    """Extrae la version de un tag (v0.1.0 -> 0.1.0)."""
    return tag.lstrip("v") if tag else "unreleased"


def generate_changelog(commits: List[Dict], conventions: Dict, version: str, fecha: str) -> str:
    """Genera el CHANGELOG.md en formato Keep a Changelog."""
    grouped = _agrupar_por_categoria(commits, conventions)
    breaking = _detectar_breaking_changes(commits)
    lineas: List[str] = [
        "# Changelog",
        "",
        "Todos los cambios notables de este proyecto se documentan aqui.",
        "",
        "El formato sigue [Keep a Changelog](https://keepachangelog.com/es/1.1.0/).",
        "",
        f"## [{version}] - {fecha}",
        "",
    ]
    # Orden de categorias (Keep a Changelog)
    orden = ["Added", "Changed", "Deprecated", "Removed", "Fixed", "Security", "Breaking", "Documentation"]
    categorias_presentes: List[str] = []
    for cat in orden:
        if cat in grouped and grouped[cat]:
            lineas.append(f"### {cat}")
            lineas.append("")
            for item in grouped[cat]:
                lineas.append(item)
            lineas.append("")
            categorias_presentes.append(cat)
    # Categorias no en el orden predefinido
    for cat in grouped:
        if cat not in categorias_presentes and grouped[cat]:
            lineas.append(f"### {cat}")
            lineas.append("")
            for item in grouped[cat]:
                lineas.append(item)
            lineas.append("")
    if breaking:
        lineas.append("### Breaking Changes")
        lineas.append("")
        for b in breaking:
            lineas.append(b)
        lineas.append("")
    if not commits:
        lineas.append("Sin cambios registrados en este periodo.")
        lineas.append("")
    return "\n".join(lineas) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Genera CHANGELOG.md data-driven desde git log")
    parser.add_argument("--from", dest="from_tag", default=None, help="Tag de inicio (ej: v0.1.0). Si no se da, se usan todos los commits")
    parser.add_argument("--to", dest="to_tag", default="HEAD", help="Tag/ref de fin (default: HEAD)")
    parser.add_argument("--version", default=None, help="Version a registrar (default: del tag --to o 'unreleased')")
    parser.add_argument("--out", default=os.path.join(PROJECT_ROOT, "CHANGELOG.md"), help="Path de salida (default: project root)")
    args = parser.parse_args()
    # Git log
    range_arg: str = f"{args.from_tag}..{args.to_tag}" if args.from_tag else args.to_tag
    raw = _git(
        "log",
        "--pretty=format:%h|%ai|%s",
        "--no-merges",
        range_arg,
    )
    if not raw:
        print(f"[changelog] no se encontraron commits en {range_arg}")
        commits = []
    else:
        commits = _parsear_commits(raw)
    # Version
    if args.version:
        version = args.version
    elif args.to_tag and args.to_tag != "HEAD":
        version = _obtener_version(args.to_tag)
    else:
        version = "unreleased"
    # Fecha
    fecha_raw = _git("log", "-1", "--pretty=format:%ai", args.to_tag)
    fecha = fecha_raw.strip().split(" ")[0] if fecha_raw.strip() else datetime.now().strftime("%Y-%m-%d")
    # Convenciones
    conventions = _load_conventions()
    # Generar
    md = generate_changelog(commits, conventions, version, fecha)
    out_path = args.out
    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(md)
    print(f"[changelog] {len(commits)} commits -> {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
