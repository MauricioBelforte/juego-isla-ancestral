#!/usr/bin/env python3
# M127: Copyright - Generador de AUTHORS.md y CONTRIBUTING.md desde git log (iter 2).
# Lee el historial de git (commits, autores, fechas) y produce:
#   - AUTHORS.md: lista de contribuidores ordenada por numero de commits
#   - CONTRIBUTING.md: guia de contribucion con datos reales del proyecto
# Uso: python tools/legal/generate_authors.py [--max-authors 200] [--out-dir <dir>]

import os
import sys
import json
import argparse
import subprocess
from collections import defaultdict
from datetime import datetime
from typing import List, Dict, Tuple

# Calcula HERE robustamente: __file__ puede no estar definido si se importa
# via exec() o Python -c. Usar sys.argv[0] como fallback.
try:
    HERE = os.path.dirname(os.path.abspath(__file__))
except NameError:
    HERE = os.path.dirname(os.path.abspath(sys.argv[0] if sys.argv and sys.argv[0] else "."))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def _git(*args: str) -> str:
    """Ejecuta un comando git y devuelve stdout (o vacio si falla).

    En Windows, git stdout viene en latin-1 (cp1252) por defecto, no en utf-8.
    Probamos utf-8 primero; si falla, usamos latin-1."""
    try:
        result = subprocess.run(
            ["git"] + list(args),
            capture_output=True,
            timeout=30,
            cwd=PROJECT_ROOT,
        )
        if result.returncode == 0:
            raw = result.stdout
            # Intentar utf-8 primero; si falla (caracteres invalidos), usar latin-1
            try:
                return raw.decode("utf-8")
            except UnicodeDecodeError:
                return raw.decode("latin-1", errors="replace")
    except (OSError, subprocess.TimeoutExpired):
        pass
    return ""


def _parse_log_line(line: str) -> Tuple[str, str, str] | None:
    """Parsea una linea del formato: hash|author_date|author_name<email>."""
    # Formato: hash|date|author_name<email>|subject
    # Usamos formato --pretty=format para que sea parseable
    parts = line.split("|", 3)
    if len(parts) < 4:
        return None
    h, fecha, autor, subject = parts
    return h.strip(), fecha.strip(), autor.strip(), subject.strip()


def get_authors(max_authors: int) -> List[Dict]:
    """Devuelve lista de contribuidores ordenados por commits."""
    out = _git("log", "--pretty=format:%h|%ai|%an <%ae>|%s", "--no-merges", "-n", "10000")
    counts: Dict[str, Dict] = defaultdict(lambda: {
        "name": "",
        "email": "",
        "commits": 0,
        "first_commit": None,
        "last_commit": None,
    })
    for line in out.split("\n"):
        line = line.strip()
        if not line:
            continue
        # Parseo: hash|date|nombre<email>|subject
        parts = line.split("|", 3)
        if len(parts) < 4:
            continue
        h, fecha, autor, subject = parts
        # Extraer nombre y email del campo "autor"
        autor = autor.strip()
        if " <" in autor:
            nombre, email = autor.rsplit(" <", 1)
            email = email.rstrip(">")
        else:
            nombre = autor
            email = ""
        # Key por email (lowercase); fallback por nombre
        key = (email or nombre).lower()
        if key not in counts:
            counts[key]["name"] = nombre
            counts[key]["email"] = email
        counts[key]["commits"] += 1
        if counts[key]["first_commit"] is None or fecha < counts[key]["first_commit"]:
            counts[key]["first_commit"] = fecha
        if counts[key]["last_commit"] is None or fecha > counts[key]["last_commit"]:
            counts[key]["last_commit"] = fecha
    # Ordenar por commits desc
    sorted_authors = sorted(counts.values(), key=lambda x: -x["commits"])
    return sorted_authors[:max_authors]


def get_repo_info() -> Dict:
    """Lee informacion basica del repo (nombre, version godot)."""
    out = _git("rev-parse", "--show-toplevel")
    repo_name: str = os.path.basename(out.strip()) if out.strip() else "Isla Ancestral"
    # Lee version de Godot del project.godot
    version_godot: str = "?"
    pg = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "project.godot")
    if os.path.exists(pg):
        with open(pg, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("config/version="):
                    version_godot = line.split("=", 1)[1].strip()
                    break
    return {"repo_name": repo_name, "godot_version": version_godot}


def generate_authors(authors: List[Dict], repo_info: Dict) -> str:
    """Genera AUTHORS.md."""
    lineas: List[str] = [
        f"# {repo_info['repo_name']} — AUTHORS",
        "",
        f"_Generado automaticamente por `tools/legal/generate_authors.py` el {datetime.now().isoformat()}_",
        "",
        "## Contribuidores",
        "",
        "Lista ordenada por numero de commits. Generada con `git log`.",
        "",
        "| # | Nombre | Email | Commits | Primer commit | Ultimo commit |",
        "|---|--------|-------|---------|---------------|----------------|",
    ]
    for i, a in enumerate(authors, 1):
        lineas.append(
            f"| {i} | {a['name']} | {a['email']} | {a['commits']} | {a['first_commit']} | {a['last_commit']} |"
        )
    lineas.append("")
    lineas.append(f"**Total**: {len(authors)} contribuidores unicos.")
    return "\n".join(lineas) + "\n"


def generate_contributing(repo_info: Dict) -> str:
    """Genera CONTRIBUTING.md con info del proyecto."""
    year = datetime.now().year
    lineas: List[str] = [
        f"# Contributing to {repo_info['repo_name']}",
        "",
        f"Version Godot: **{repo_info['godot_version']}**",
        "",
        "## Como contribuir",
        "",
        "1. **Fork** el repositorio",
        "2. Crea una **rama de feature**: `git checkout -b feat/mi-mejora`",
        "3. **Commit** tus cambios: `git commit -m 'feat: description'`",
        "4. **Push**: `git push origin feat/mi-mejora`",
        "5. Abre un **Pull Request**",
        "",
        "## Convenciones de codigo",
        "",
        "- **GDScript**: snake_case para variables/funciones, PascalCase para class_name, tabs NO (usar 4 espacios)",
        "- **Python**: PEP 8, type hints cuando sea posible",
        "- **JSON**: 2 espacios de indentacion",
        "- **Commits**: Conventional Commits (feat:, fix:, docs:, refactor:)",
        "",
        "## Estructura del proyecto",
        "",
        "```",
        "game/isla-ancestral/      # proyecto Godot",
        "  scripts/                # codigo del juego",
        "    <modulo>/             # cada modulo en su carpeta",
        "  data/                   # datos data-driven (JSON)",
        "  tests/                  # tests headless",
        "tools/                   # scripts Python del orquestador",
        "  ci/                     # pipeline CI/CD (M118)",
        "  legal/                  # copyright + creditos (M127, M131)",
        "  postlaunch/             # checklist post-release (M144)",
        "logs/                    # logs de iteraciones",
        "DOCUMENTACION/           # plan-actual por modulo",
        "```",
        "",
        "## Reporte de issues",
        "",
        "Los issues se reportan en GitHub Issues. Plantillas en `.github/ISSUE_TEMPLATE/`.",
        "Para bugs, inclui: version de Godot, OS, pasos para reproducir, log de error.",
        "",
        f"## Licencia",
        "",
        f"Copyright (c) {year} Isla Ancestral Team. Ver LICENSE.",
        "",
        f"_Generado automaticamente el {datetime.now().isoformat()}_",
    ]
    return "\n".join(lineas) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Genera AUTHORS.md y CONTRIBUTING.md")
    parser.add_argument("--max-authors", type=int, default=200, help="Maximo de autores a listar")
    parser.add_argument("--out-dir", default=PROJECT_ROOT, help="Directorio destino")
    args = parser.parse_args()

    authors = get_authors(args.max_authors)
    repo_info = get_repo_info()

    if not authors:
        print("WARN: no se encontraron autores (git no disponible o sin commits)", file=sys.stderr)
        # Crea un placeholder
        authors = [{
            "name": repo_info["repo_name"] + " Team",
            "email": "noreply@isla-ancestral.local",
            "commits": 0,
            "first_commit": "N/A",
            "last_commit": "N/A",
        }]

    out_dir = args.out_dir
    os.makedirs(out_dir, exist_ok=True)

    authors_md = generate_authors(authors, repo_info)
    contrib_md = generate_contributing(repo_info)

    out_authors = os.path.join(out_dir, "AUTHORS.md")
    out_contrib = os.path.join(out_dir, "CONTRIBUTING.md")

    with open(out_authors, "w", encoding="utf-8") as f:
        f.write(authors_md)
    with open(out_contrib, "w", encoding="utf-8") as f:
        f.write(contrib_md)

    print(f"[M127] {len(authors)} contribuidores -> {out_authors}")
    print(f"[M127] Contributing -> {out_contrib}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
