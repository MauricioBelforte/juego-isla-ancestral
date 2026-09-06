#!/usr/bin/env python3
# M144 iter 3 (minimax-3): Format CHANGELOG.md segun Keep a Changelog 1.1.0.
# Mejora mi changelog.py iter 1 con:
#   - Scopes soportados (feat(ui):, fix(mineria):, etc.)
#   - Breaking changes detectados (feat!:, BREAKING CHANGE:)
#   - Links a commits (formato Keep a Changelog: [abc1234])
#   - Filtrado por version (--from, --to)
#   - Format consistente: tipos ordenados (Added, Changed, Deprecated, Removed, Fixed, Security)
# Uso: python tools/postlaunch/format_changelog.py [--from v0.1.0] [--to v0.2.0] [--out CHANGELOG.md]

import os
import sys
import json
import re
import argparse
import subprocess
from datetime import datetime
from typing import List, Dict, Tuple, Optional

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def _git(*args: str) -> str:
    try:
        result = subprocess.run(
            ["git"] + list(args),
            capture_output=True, timeout=15,
            cwd=PROJECT_ROOT,
        )
        if result.returncode == 0:
            try:
                return result.stdout.decode("utf-8")
            except UnicodeDecodeError:
                return result.stdout.decode("latin-1", errors="replace")
    except (OSError, subprocess.TimeoutExpired):
        pass
    return ""


# Keep a Changelog 1.1.0 tipos
KAC_TYPES = {
    "feat": "Added",
    "add": "Added",
    "added": "Added",
    "fix": "Fixed",
    "fixed": "Fixed",
    "docs": "Documentation",
    "doc": "Documentation",
    "style": "Changed",
    "refactor": "Changed",
    "perf": "Changed",
    "test": "Changed",
    "build": "Changed",
    "ci": "Changed",
    "chore": "Changed",
    "revert": "Removed",
    "remove": "Removed",
    "removed": "Removed",
    "security": "Security",
    "deprecate": "Deprecated",
    "deprecated": "Deprecated",
}


def _parsear_commits(raw: str) -> List[Dict]:
    """Parsea git log con formato hash|date|subject."""
    commits: List[Dict] = []
    for line in raw.split("\n"):
        line = line.strip()
        if not line:
            continue
        parts = line.split("|", 2)
        if len(parts) < 3:
            continue
        h, fecha, subject = parts
        commits.append({
            "hash": h.strip(),
            "date": fecha.strip(),
            "subject": subject.strip(),
        })
    return commits


def _parsear_commit_subject(subject: str) -> Dict:
    """Extrae type, scope, breaking, description del subject."""
    info: Dict = {"type": "Changed", "scope": None, "breaking": False, "description": subject}
    # Conventional Commits: type(scope)!: description
    m = re.match(r"^(\w+)(?:\(([^)]+)\))?(!?):\s*(.+)$", subject)
    if m:
        type_str = m.group(1).lower()
        scope = m.group(2)
        bang = m.group(3)
        desc = m.group(4)
        info["type"] = KAC_TYPES.get(type_str, "Changed")
        info["scope"] = scope
        info["breaking"] = bool(bang) or "BREAKING CHANGE" in subject
        info["description"] = desc
    elif "BREAKING CHANGE" in subject:
        info["breaking"] = True
    return info


def _agrupar_por_tipo(commits: List[Dict]) -> Tuple[Dict[str, List[str]], List[str]]:
    """Agrupa commits por tipo Keep a Changelog. Devuelve (grouped, breaking)."""
    grouped: Dict[str, List[str]] = {t: [] for t in ["Added", "Changed", "Deprecated", "Removed", "Fixed", "Security", "Documentation"]}
    breaking: List[str] = []
    for c in commits:
        info = _parsear_commit_subject(c["subject"])
        tipo = info["type"]
        # Formato Keep a Changelog: - scope: description ([hash])
        scope_str = f"**{info['scope']}**: " if info["scope"] else ""
        item = f"- {scope_str}{info['description']} ([{c['hash'][:7]}])"
        if info["breaking"]:
            breaking.append(item)
        elif tipo in grouped:
            grouped[tipo].append(item)
    # Eliminar tipos vacios
    return {k: v for k, v in grouped.items() if v}, breaking


def generate(commits: List[Dict], version: str, fecha: str) -> str:
    """Genera el CHANGELOG.md en formato Keep a Changelog 1.1.0."""
    if not commits:
        return f"# Changelog\n\n## [{version}] - {fecha}\n\nSin cambios registrados.\n"
    grouped, breaking = _agrupar_por_tipo(commits)
    lineas: List[str] = [
        "# Changelog",
        "",
        "Todos los cambios notables de este proyecto se documentan aqui.",
        "",
        "El formato sigue [Keep a Changelog 1.1.0](https://keepachangelog.com/es/1.1.0/),",
        "y este proyecto se adhiere a [Semantic Versioning](https://semver.org/).",
        "",
        f"## [{version}] - {fecha}",
        "",
    ]
    orden = ["Added", "Changed", "Deprecated", "Removed", "Fixed", "Security", "Documentation"]
    for tipo in orden:
        if tipo in grouped and grouped[tipo]:
            lineas.append(f"### {tipo}")
            lineas.append("")
            for item in grouped[tipo]:
                lineas.append(item)
            lineas.append("")
    if breaking:
        lineas.append("### ⚠️ BREAKING CHANGES")
        lineas.append("")
        for b in breaking:
            lineas.append(b)
        lineas.append("")
    return "\n".join(lineas) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Format CHANGELOG.md Keep a Changelog 1.1.0")
    parser.add_argument("--from", dest="from_ref", default=None, help="Ref inicial (ej: v0.1.0)")
    parser.add_argument("--to", dest="to_ref", default="HEAD", help="Ref final (default: HEAD)")
    parser.add_argument("--version", default="unreleased", help="Version semver")
    parser.add_argument("--out", default=os.path.join(PROJECT_ROOT, "CHANGELOG.md"))
    args = parser.parse_args()

    range_arg = f"{args.from_ref}..{args.to_ref}" if args.from_ref else args.to_ref
    raw = _git("log", "--pretty=format:%h|%ai|%s", "--no-merges", range_arg)
    if not raw:
        print(f"[format] no se encontraron commits en {range_arg}")
        commits = []
    else:
        commits = _parsear_commits(raw)
    fecha_raw = _git("log", "-1", "--pretty=format:%ai", args.to_ref)
    fecha = fecha_raw.strip().split(" ")[0] if fecha_raw.strip() else datetime.now().strftime("%Y-%m-%d")
    md = generate(commits, args.version, fecha)
    with open(args.out, "w", encoding="utf-8") as f:
        f.write(md)
    tipos_presentes = sum(1 for c in commits)
    print(f"[format] {tipos_presentes} commits -> {args.out} (version: {args.version})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
