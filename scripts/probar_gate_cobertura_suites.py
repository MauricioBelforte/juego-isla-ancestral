#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.
# -*- coding: utf-8 -*-
"""PRUEBA EN ROJO del gate de cobertura de suites (M112, 2026-11-25).

Un gate que nunca se ve rojo no es un gate: es decoracion. Este script
demuestra que `tools/quality/auditar_cobertura_suites.py --check` se pone
ROJO cuando el workflow del CI referencia una suite que NO existe, y que
sigue VERDE con el workflow real.

Como no se escribe el workflow real (worktree compartido: lo editan varios
agentes), la prueba trabaja sobre una COPIA en un arbol temporal a la que se le
inyecta una entrada rota. Para eso el auditor acepta `--workflow <ruta>`.

Uso:
    python scripts/probar_gate_cobertura_suites.py

Exit: 0 = el gate se comporta como debe | 1 = el gate esta MUERTO o la
prueba no pudo montarse.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
AUDITOR = RAIZ / "tools" / "quality" / "auditar_cobertura_suites.py"
WORKFLOW = RAIZ / ".github" / "workflows" / "quality.yml"

RUTA_ROTA = "scripts/esta_suite_no_existe_jamas_1234.gd"
FALLOS: list[str] = []


def _fallo(msg: str) -> None:
    FALLOS.append(msg)
    print(f"  [FAIL] {msg}")


def _ok(msg: str) -> None:
    print(f"  [ok]   {msg}")


def _auditar(workflow: Path) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, str(AUDITOR), "--check", "--workflow", str(workflow)],
        capture_output=True, text=True, cwd=str(RAIZ),
    )


def main() -> int:
    print("=== Prueba en rojo del gate de cobertura de suites (M112) ===")

    if not AUDITOR.is_file() or not WORKFLOW.is_file():
        _fallo("no encuentro el auditor o el workflow del repo")
        return 1

    # 1) El gate real debe estar VERDE hoy.
    verde = _auditar(WORKFLOW)
    if verde.returncode == 0:
        _ok("el workflow real pasa el gate (exit 0)")
    else:
        _fallo(f"el workflow real ya esta en ROJO (exit {verde.returncode}) — "
               "el gate no puede nacer rojo: se arregla antes de cablearlo")

    # 2) Con una entrada rota, el gate debe PONERSE ROJO.
    with tempfile.TemporaryDirectory(prefix="gate_cobertura_") as tmp:
        copia = Path(tmp) / "quality_inyectado.yml"
        texto = WORKFLOW.read_text(encoding="utf-8")
        if RUTA_ROTA in texto:
            _fallo(f"la ruta de prueba {RUTA_ROTA} ya existe en el workflow real")
            return 1
        # Se inyecta la invocacion rota dentro del propio bloque que se audita.
        marca = "          suite --script scripts/saving/validate_save.gd"
        if marca not in texto:
            _fallo("no encuentro el punto de inyeccion en el workflow (cambio de layout)")
            return 1
        texto_inyectado = texto.replace(
            marca, marca + "\n          suite --script " + RUTA_ROTA, 1)
        copia.write_text(texto_inyectado, encoding="utf-8")

        rojo = _auditar(copia)
        if rojo.returncode == 1:
            _ok("con una suite inexistente el gate se pone ROJO (exit 1)")
        else:
            _fallo(f"el gate NO se ponemos rojo con una suite inexistente "
                   f"(exit {rojo.returncode}) — el gate esta MUERTO")
        salida = (rojo.stdout or "") + (rojo.stderr or "")
        if RUTA_ROTA in salida:
            _ok("el gate NOMBRA la suite rota (no es un fallo mudo)")
        else:
            _fallo("el gate fallo pero no nombro la suite rota: el log no sirve para diagnosticar")

        # 3) La copia no debe haber tocado el workflow real.
        if WORKFLOW.read_text(encoding="utf-8") == texto:
            _ok("el workflow real quedo intacto")
        else:
            _fallo("el workflow real fue modificado por la prueba")

    print(f"--- prueba del gate: {3 - len(FALLOS)} ok, {len(FALLOS)} fallos ---")
    for f in FALLOS:
        print(f"  FALLO: {f}")
    return 1 if FALLOS else 0


if __name__ == "__main__":
    sys.exit(main())
