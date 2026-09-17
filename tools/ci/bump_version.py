#!/usr/bin/env python3
# M118 iter 5 (minimax-3): bump_version.py automatiza versionado semver.
# Incrementa la version en:
#   - game/isla-ancestral/project.godot (config/version=)
#   - data/legal/copyright.json (year de cada elemento)
#   - CHANGELOG.md (entrada nueva con la version)
#   - data/operaciones/postlaunch_checks.json (si tiene campo version)
#   - installer/*.iss (#define AppVersion "..." — M117 iter. 3, Log 946; V3 de M116)
# Tipos de bump: major, minor, patch.
# Uso: python tools/ci/bump_version.py [major|minor|patch] [--dry-run]
#
# FIX M117 iter. 2 (muse-spark-1.3-contributor / Cline, Log 902):
# el PROJECT_ROOT se calculaba solo desde la UBICACION del script
# (HERE/../..), ignorando el cwd. Un runner que copiara el repo (CI) o un test
# con tempdir veia bump_version leer/escribir SIEMPRE el project.godot del repo
# real. Ahora: si el cwd contiene un project.godot con config/version=, se usa
# ese arbol (cwd-first); si no, se cae al layout clasico HERE/../...
# Test afectado: tools/ci/test_bump_version.py (7/11 -> expect 11/11).

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
INSTALLER_DIR = os.path.join(PROJECT_ROOT, "installer")


def _root_desde_cwd() -> Optional[str]:
    """Si el cwd es un arbol de proyecto con config/version=, devolverlo (cwd-first)."""
    cwd = os.path.abspath(os.getcwd())
    for root in (cwd, os.path.dirname(cwd)):
        pg = os.path.join(root, "game", "isla-ancestral", "project.godot")
        if os.path.exists(pg):
            try:
                with open(pg, "r", encoding="utf-8") as f:
                    for line in f:
                        if re.match(r'^config/version="\d+\.\d+\.\d+', line.strip()):
                            return root
            except OSError:
                pass
    return None


_CWD_ROOT = _root_desde_cwd()
if _CWD_ROOT:
    PROJECT_ROOT = _CWD_ROOT
    PROJECT_GODOT = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "project.godot")
    COPYRIGHT_JSON = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data", "legal", "copyright.json")
    CHANGELOG_MD = os.path.join(PROJECT_ROOT, "CHANGELOG.md")
    POSTLAUNCH_JSON = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data", "operaciones", "postlaunch_checks.json")
    INSTALLER_DIR = os.path.join(PROJECT_ROOT, "installer")



def _get_current_version_str() -> Optional[str]:
    """Devuelve la version cruda tal como esta escrita (con sufijo, ej '0.0.0-dev')."""
    if not os.path.exists(PROJECT_GODOT):
        return None
    with open(PROJECT_GODOT, "r", encoding="utf-8") as f:
        for line in f:
            m = re.match(r'^config/version="([^"]+)"', line.strip())
            if m:
                return m.group(1)
    return None


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
    """Actualiza year en copyright.json para todos los elementos.
    Ausente = skip tolerante (no es error: un repo sin copyright.json no debe
    romper el bump de version; FIX Log 902)."""
    if not os.path.exists(COPYRIGHT_JSON):
        return True, "copyright.json ausente — skip"
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


def _set_version_in_installer_iss(new_version: str, dry_run: bool) -> Tuple[bool, str]:
    """Actualiza #define AppVersion "..." en installer/*.iss para que coincida con
    config/version de project.godot (V3 del validador M116). Solo reescribe el valor
    numerico (conserva comentario/whitespace). Ausente = skip tolerante: un repo sin
    installer/ no rompe el bump de version.

    FIX M117 iter. 3 (agnes-3-flash, Log 946): el bump no sincronizaba AppVersion del
    instalador, asi que cada bump desalineaba .iss vs project.godot y el check V3 de
    M116 quedaba rojo (falso-verde del modulo)."""
    if not os.path.isdir(INSTALLER_DIR):
        return True, "installer/ ausente — skip"
    total = 0
    archivos = 0
    for name in sorted(os.listdir(INSTALLER_DIR)):
        if not name.endswith(".iss"):
            continue
        path = os.path.join(INSTALLER_DIR, name)
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
        new_content, k = re.subn(
            r'(#define\s+AppVersion\s+")[\w.-]+(")',
            lambda m: m.group(1) + new_version + m.group(2),
            content,
        )
        if k > 0:
            archivos += 1
            total += k
            if not dry_run:
                with open(path, "w", encoding="utf-8") as f:
                    f.write(new_content)
    if total == 0:
        return True, "installer/*.iss: sin #define AppVersion para actualizar"
    return True, f"installer: {total} AppVersion en {archivos} archivo(s)"


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
    _old_raw = _get_current_version_str()
    old_version = _old_raw if _old_raw else f"{current[0]}.{current[1]}.{current[2]}"
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
        (_set_version_in_installer_iss, (new_version, args.dry_run)),
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
