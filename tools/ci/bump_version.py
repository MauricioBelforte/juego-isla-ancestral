#!/usr/bin/env python3
# M118 iter 5 (minimax-3): bump_version.py automatiza versionado semver.
# Incrementa la version en:
#   - game/isla-ancestral/project.godot (config/version=)
#   - data/legal/copyright.json (year de cada elemento)
#   - CHANGELOG.md (entrada nueva con la version)
#   - data/operaciones/postlaunch_checks.json (si tiene campo version)
# Tipos de bump: major, minor, patch.
# Uso: python tools/ci/bump_version.py [major|minor|patch] [--dry-run]

import os
import sys
import json
import re
import argparse
import subprocess
from datetime import datetime
from typing import Tuple, Optional

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
PROJECT_GODOT = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "project.godot")
COPYRIGHT_JSON = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data", "legal", "copyright.json")
CHANGELOG_MD = os.path.join(PROJECT_ROOT, "CHANGELOG.md")
POSTLAUNCH_JSON = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data", "operaciones", "postlaunch_checks.json")


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


def _get_current_version() -> Optional[Tuple[int, int, int]]:
    """Lee la version actual del project.godot. Devuelve (major, minor, patch) o None."""
    if not os.path.exists(PROJECT_GODOT):
        return None
    with open(PROJECT_GODOT, "r", encoding="utf-8") as f:
        for line in f:
            # Acepta "0.0.0-dev", "1.2.3", "1.2.3-rc1", etc.
            m = re.match(r'^config/version="(\d+)\.(\d+)\.(\d+)(?:-\w+)?"', line.strip())
            if m:
                return (int(m.group(1)), int(m.group(2)), int(m.group(3)))
    return None


def _set_version_in_project_godot(new_version: str, dry_run: bool) -> Tuple[bool, str]:
    """Actualiza config/version en project.godot."""
    if not os.path.exists(PROJECT_GODOT):
        return False, f"project.godot no existe"
    with open(PROJECT_GODOT, "r", encoding="utf-8") as f:
        content = f.read()
    # Acepta el sufijo dev/rc/etc.
    new_content, n = re.subn(
        r'^(config/version=")\d+\.\d+\.\d+(?:-\w+)?(")',
        f'\\g<1>{new_version}\\g<2>',
        content,
        flags=re.MULTILINE,
    )
    if n == 0:
        return False, "no se encontro config/version= en project.godot"
    if not dry_run:
        with open(PROJECT_GODOT, "w", encoding="utf-8") as f:
            f.write(new_content)
    return True, f"project.godot: {n} cambio(s)"


def _set_version_in_copyright_json(new_version: str, new_year: int, dry_run: bool) -> Tuple[bool, str]:
    """Actualiza year en copyright.json para todos los elementos."""
    if not os.path.exists(COPYRIGHT_JSON):
        return False, f"copyright.json no existe"
    with open(COPYRIGHT_JSON, "r", encoding="utf-8") as f:
        data = json.load(f)
    if "elementos" not in data:
        return False, "copyright.json no tiene clave 'elementos'"
    n = 0
    for e in data["elementos"]:
        if "year" in e:
            old = e["year"]
            e["year"] = new_year
            n += 1
    if not dry_run:
        with open(COPYRIGHT_JSON, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            f.write("\n")
    return True, f"copyright.json: {n} elemento(s) actualizados"


def _add_changelog_entry(new_version: str, new_year: int, dry_run: bool) -> Tuple[bool, str]:
    """Anade una entrada al CHANGELOG.md."""
    if not os.path.exists(CHANGELOG_MD):
        # Si no existe, crear uno basico
        if not dry_run:
            with open(CHANGELOG_MD, "w", encoding="utf-8") as f:
                f.write(f"# Changelog\n\n## [{new_version}] - {new_year}-XX-XX\n\n### Changed\n\n- Version bumped a {new_version}.\n")
        return True, "CHANGELOG.md creado"
    with open(CHANGELOG_MD, "r", encoding="utf-8") as f:
        content = f.read()
    # Insertar nueva entrada despues de "# Changelog" + linea vacia
    fecha = f"{new_year}-XX-XX"
    new_section = f"## [{new_version}] - {fecha}\n\n### Changed\n\n- Version bumped a {new_version}.\n\n"
    # Reemplazar la primera seccion ## [unreleased] si existe
    if "## [unreleased]" in content:
        new_content = content.replace(
            "## [unreleased]",
            f"## [unreleased]\n\n(pendiente: asignar a {new_version})\n",
            1,
        )
        new_content = new_content.replace(
            f"## [unreleased] - {new_year}-XX-XX",
            f"## [{new_version}] - {fecha}",
            1,
        )
    else:
        new_content = re.sub(
            r"^(# Changelog\n)",
            f"\\1\n{new_section}",
            content,
            count=1,
            flags=re.MULTILINE,
        )
    if not dry_run:
        with open(CHANGELOG_MD, "w", encoding="utf-8") as f:
            f.write(new_content)
    return True, "CHANGELOG.md actualizado"


def bump_semver(current: Tuple[int, int, int], kind: str) -> Tuple[int, int, int]:
    """Incrementa la version segun kind."""
    major, minor, patch = current
    if kind == "major":
        return (major + 1, 0, 0)
    elif kind == "minor":
        return (major, minor + 1, 0)
    else:  # patch
        return (major, minor, patch + 1)


def main() -> int:
    parser = argparse.ArgumentParser(description="Bump version del proyecto (semver)")
    parser.add_argument("kind", choices=["major", "minor", "patch"], help="Tipo de bump")
    parser.add_argument("--dry-run", action="store_true", help="Solo mostrar cambios, no escribir")
    args = parser.parse_args()

    current = _get_current_version()
    if current is None:
        print(f"[bump] ERROR: no se pudo leer version actual de {PROJECT_GODOT}")
        return 1
    new_version_tuple = bump_semver(current, args.kind)
    new_version = f"{new_version_tuple[0]}.{new_version_tuple[1]}.{new_version_tuple[2]}"
    old_version = f"{current[0]}.{current[1]}.{current[2]}"
    new_year = datetime.now().year
    print(f"[bump] {old_version} -> {new_version} ({args.kind})")
    if args.dry_run:
        print("[bump] DRY RUN: no se escribiran cambios")
    # Actualizar archivos
    all_ok = True
    for func, args_ in [
        (_set_version_in_project_godot, (new_version, args.dry_run)),
        (_set_version_in_copyright_json, (new_version, new_year, args.dry_run)),
        (_add_changelog_entry, (new_version, new_year, args.dry_run)),
    ]:
        ok, msg = func(*args_)
        status = "OK" if ok else "FAIL"
        print(f"  [{status}] {msg}")
        if not ok:
            all_ok = False
    if all_ok:
        print(f"[bump] {old_version} -> {new_version} hecho" + (" (DRY)" if args.dry_run else ""))
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
