#!/usr/bin/env python3
"""Genera el colector de sintaxis GDScript (fix BUG-051).

El job ``godot-lint`` de ``.github/workflows/quality.yml`` era un no-op:
ejecutaba ``godot --headless --script`` SIN script y con ``|| true``, de modo
que el paso "Check for Godot parser errors" nunca validaba nada.

Este generador produce ``scripts/editor/_colector_sintaxis.gd``: un script con
un ``preload`` por cada ``.gd`` del proyecto. Como ``preload`` fuerza el parseo
en tiempo de compilacion, ``godot --headless --check-only --script`` sobre el
colector valida TODOS los scripts de una sola pasada y aborta (exit 1) si
alguno no parsea.

Exclusiones:
  - ``.godot/``  cache del editor (regenerable).
  - ``addons/``  codigo de terceros (gdUnit4, zylann.voxel).
  - ``Godot/``   datos del editor.
  - Scripts que extienden gdUnit4: ``tests/unit/*`` heredan de
    ``res://addons/gdUnit4/src/GdUnitTestSuite.gd``. gdUnit4 es codigo de
    terceros NO versionado (decision del fundador: solo voxel se versiono),
    asi que Godot no puede resolver el ``extends`` y el preload del colector
    falla con "Could not resolve script" + "Cannot infer the type of _gNNN"
    (2 errores por script). Se detectan por contenido, no por carpeta: si
    alguien agrega un test propio a tests/unit/ SI se valida (Log 1320).

Uso:
  python3 tools/quality/gen_colector_sintaxis.py [--proyecto game/isla-ancestral]

Salida: 0 siempre que se pueda escribir el colector.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

EXCLUIR_DIR = {".godot", "addons", "Godot"}
EXCLUIR_ARCHIVO = {"_colector_sintaxis.gd"}  # autoreferencia (preload de si mismo)
# NOTA (Log 1368): la exclusion de scripts que extienden gdUnit4 se elimino.
# gdUnit4 ahora esta versionado en addons/gdUnit4 (decision del fundador), asi
# que Godot resuelve el extends GdUnitTestSuite y el preload no falla en
# cascada. Antes (Log 1320) el addon no estaba en git y 4 tests de tests/unit/
# tenian que excluirse por contenido.
SALIDA = Path("scripts/editor/_colector_sintaxis.gd")


def _encontrar_raiz(inicio: Path) -> Path:
    """Sube hasta encontrar el directorio con project.godot."""
    for cand in [inicio, *inicio.parents]:
        if (cand / "project.godot").is_file():
            return cand
    raise SystemExit(f"No se encontro project.godot desde {inicio}")


def _recolectar(raiz: Path) -> tuple[list[str], list[str]]:
    """Devuelve (a_incluir, a_excluir). Los excluidos se reportan en el header."""
    archivos: list[str] = []
    excluidos: list[str] = []
    for path in sorted(raiz.rglob("*.gd")):
        rel = path.relative_to(raiz)
        if rel.parts[0] in EXCLUIR_DIR:
            continue
        if rel.name in EXCLUIR_ARCHIVO:
            continue
        archivos.append(rel.as_posix())
    return archivos, excluidos


def _generar(raiz: Path, archivos: list[str]) -> str:
    lineas = [
        "extends SceneTree",
        "",
        "# COLECTOR GENERADO por tools/quality/gen_colector_sintaxis.py",
        "# (fix BUG-051, atria-dawn 2026-09-18). NO EDITAR A MANO: se",
        "# regenera en cada ejecucion de CI. Cada preload fuerza el parseo",
        "# de un .gd en tiempo de compilacion; correr con:",
        "#   godot --headless --check-only \\",
        "#        --script res://scripts/editor/_colector_sintaxis.gd",
        "",
    ]
    for i, rel in enumerate(archivos):
        lineas.append(f"const _g{i} := preload(\"res://{rel}\")")
    lineas.append("")
    return "\n".join(lineas)


def _generar_con_excluidos(raiz: Path, archivos: list[str], excluidos: list[str]) -> str:
    """Genera el colector listando los excluidos en el header (trazabilidad)."""
    base = _generar(raiz, archivos)
    if not excluidos:
        return base
    nota = [
        "",
        "# Excluidos: heredan de gdUnit4 (addon de terceros NO versionado; solo",
        "# voxel se versiono, Log 1320). No se puede validar la sintaxis de un",
        "# script cuyo extends apunta a una clase ausente. Verificarlos con",
        "# gdUnit4 instalado (local), no desde CI:",
    ]
    nota += [f"#   - {rel}" for rel in excluidos]
    nota.append("")
    # Se inserta justo antes del primer preload (linea 'const _g0 ...').
    lineas = base.split("\n")
    for idx, linea in enumerate(lineas):
        if linea.startswith("const _g"):
            return "\n".join(lineas[:idx] + nota + lineas[idx:])
    return base


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--proyecto",
        type=Path,
        help="Directorio del proyecto Godot (auto-detectado si se omite)",
    )
    args = parser.parse_args()

    raiz = _encontrar_raiz(args.proyecto or Path.cwd())
    archivos, excluidos = _recolectar(raiz)
    if not archivos:
        raise SystemExit(f"No se encontraron .gd en {raiz} — el gate no validaria nada")
    if excluidos:
        print("gdUnit4 excluidos (%d): %s" % (len(excluidos), ", ".join(excluidos)))

    destino = raiz / SALIDA
    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_text(
        _generar_con_excluidos(raiz, archivos, excluidos), encoding="utf-8", newline="\n"
    )
    print(f"Colector generado: {destino} ({len(archivos)} preloads, {len(excluidos)} excluidos)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
