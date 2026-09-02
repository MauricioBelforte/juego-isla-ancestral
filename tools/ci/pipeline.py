# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M118: CI/CD - Pipeline comun data-driven.
# Reutilizable desde CLI Python (build_dev.py, build_release.py, run_tests.py)
# y desde GitHub Actions (.github/workflows/ci.yml).
# Proposito: factorizar la logica de pipeline en una sola clase que pueda
# ser llamada desde multiples entry points sin duplicar codigo.
#
# Diseno data-driven: el pipeline es una lista de steps (nombre, comando, type).
# El runner los ejecuta uno por uno, mide tiempo, y emite reporte.
# Tolera fallos: si un step falla, el pipeline continua o se aborta segun
# `abort_on_fail`.
#
# Sin dependencias externas (solo stdlib de Python 3.6+).

import os
import sys
import json
import time
import subprocess
import platform
from typing import List, Dict, Optional, Callable
from dataclasses import dataclass, field, asdict


@dataclass
class Step:
    """Un step individual del pipeline."""
    name: str
    cmd: List[str]            # Comando como lista (shell=False)
    type: str = "shell"       # 'shell' | 'godot_test' | 'python' | 'custom'
    cwd: Optional[str] = None # Si None, usa el cwd del pipeline
    timeout: int = 600        # Segundos antes de matar el step
    abort_on_fail: bool = True
    env: Dict[str, str] = field(default_factory=dict)
    description: str = ""     # Para logs y reportes


@dataclass
class StepResult:
    """Resultado de ejecutar un step."""
    name: str
    type: str
    cmd: List[str]
    returncode: int
    duration_s: float
    stdout: str
    stderr: str
    skipped: bool = False
    error: str = ""           # Mensaje de error si fallo


class Pipeline:
    """Pipeline data-driven de CI/CD.

    Uso:
        p = Pipeline(
            name="ci-full",
            steps=[
                Step("lint", ["python", "tools/ci/lint_check.py"]),
                Step("test-fauna", ["godot", "--headless", "--script", "res://tests/test_fauna.gd"]),
                ...
            ],
        )
        results = p.run()
        p.write_report(results, "out/ci-report.json")
    """

    def __init__(self, name: str, steps: List[Step], project_root: Optional[str] = None,
                 verbose: bool = True, fail_fast: bool = True):
        self.name = name
        self.steps = steps
        self.project_root = project_root or os.getcwd()
        self.verbose = verbose
        self.fail_fast = fail_fast
        self.results: List[StepResult] = []
        self.started_at: float = 0.0
        self.finished_at: float = 0.0

    def _log(self, msg: str, level: str = "INFO") -> None:
        if not self.verbose:
            return
        print(f"[{level}] [{self.name}] {msg}", file=sys.stderr)

    def _resolve_godot(self) -> str:
        """Encuentra el binario de Godot (Windows-first)."""
        env_godot = os.environ.get("GODOT_BIN")
        if env_godot and os.path.exists(env_godot):
            return env_godot
        # Búsqueda por defecto (Windows)
        candidates = [
            r"D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe",
            r"C:\Program Files\Godot\godot.exe",
            "/usr/bin/godot",
            "/usr/local/bin/godot",
        ]
        for c in candidates:
            if os.path.exists(c):
                return c
        return "godot"  # fallback al PATH

    def _run_step(self, step: Step) -> StepResult:
        """Ejecuta un step y devuelve su resultado."""
        self._log(f"-> {step.name} ({step.type})")
        cwd = step.cwd or self.project_root
        env = dict(os.environ)
        env.update(step.env)
        env.setdefault("PROJECT_ROOT", self.project_root)
        started = time.time()
        # Si es tipo 'godot_test', resolver el binario
        cmd = list(step.cmd)
        if step.type == "godot_test" and cmd and cmd[0] == "godot":
            resolved = self._resolve_godot()
            # Normalizar: subprocess en Windows trata \ como escape char
            cmd[0] = os.path.normpath(resolved)
        try:
            proc = subprocess.run(
                cmd,
                cwd=cwd,
                env=env,
                capture_output=True,
                text=True,
                timeout=step.timeout,
                shell=False,
            )
            duration = time.time() - started
            result = StepResult(
                name=step.name,
                type=step.type,
                cmd=cmd,
                returncode=proc.returncode,
                duration_s=duration,
                stdout=proc.stdout,
                stderr=proc.stderr,
            )
            if proc.returncode != 0:
                result.error = f"returncode={proc.returncode}"
                self._log(f"!! {step.name} FALLO ({duration:.1f}s) rc={proc.returncode}", "ERROR")
                if self.verbose and proc.stderr:
                    for line in proc.stderr.split("\n")[:30]:
                        print(f"    {line}", file=sys.stderr)
            else:
                self._log(f"OK {step.name} ({duration:.1f}s)")
            return result
        except subprocess.TimeoutExpired as e:
            duration = time.time() - started
            self._log(f"!! {step.name} TIMEOUT after {step.timeout}s", "ERROR")
            return StepResult(
                name=step.name, type=step.type, cmd=cmd, returncode=-1,
                duration_s=duration, stdout="", stderr=str(e),
                error=f"timeout after {step.timeout}s",
            )
        except FileNotFoundError as e:
            duration = time.time() - started
            self._log(f"!! {step.name} cmd not found: {e}", "ERROR")
            return StepResult(
                name=step.name, type=step.type, cmd=cmd, returncode=-1,
                duration_s=duration, stdout="", stderr=str(e),
                error=f"command not found",
            )
        except Exception as e:
            duration = time.time() - started
            self._log(f"!! {step.name} EXCEPTION: {e}", "ERROR")
            return StepResult(
                name=step.name, type=step.type, cmd=cmd, returncode=-1,
                duration_s=duration, stdout="", stderr=str(e),
                error=str(e),
            )

    def run(self) -> List[StepResult]:
        """Ejecuta todos los steps en orden. Devuelve la lista de resultados."""
        self.started_at = time.time()
        self._log(f"=== PIPELINE {self.name} start ({len(self.steps)} steps) ===")
        self.results = []
        for step in self.steps:
            result = self._run_step(step)
            self.results.append(result)
            if result.returncode != 0 and step.abort_on_fail and self.fail_fast:
                self._log(f"!! abort por {step.name}", "ERROR")
                break
        self.finished_at = time.time()
        total = self.finished_at - self.started_at
        ok = sum(1 for r in self.results if r.returncode == 0)
        ko = sum(1 for r in self.results if r.returncode != 0)
        self._log(f"=== PIPELINE {self.name} done in {total:.1f}s: {ok} OK, {ko} FAIL ===")
        return self.results

    def write_report(self, results: List[StepResult], out_path: str) -> None:
        """Escribe reporte JSON machine-readable para GitHub Actions / CI dashboard."""
        os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
        report = {
            "pipeline": self.name,
            "started_at": self.started_at,
            "finished_at": self.finished_at,
            "duration_s": self.finished_at - self.started_at,
            "total_steps": len(self.steps),
            "ok_steps": sum(1 for r in results if r.returncode == 0),
            "fail_steps": sum(1 for r in results if r.returncode != 0),
            "results": [asdict(r) for r in results],
        }
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        self._log(f"reporte escrito en {out_path}")


def load_pipeline_from_json(json_path: str, name: Optional[str] = None) -> Pipeline:
    """Carga un pipeline desde un JSON. Formato: {name, project_root?, steps: [{name, cmd, type?, cwd?, timeout?, abort_on_fail?, env?, description?}]}."""
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    name = name or data.get("name") or os.path.splitext(os.path.basename(json_path))[0]
    steps = [Step(**s) for s in data.get("steps", [])]
    return Pipeline(
        name=name,
        steps=steps,
        project_root=data.get("project_root"),
    )


# CLI: invocar este script con un .json para ejecutar el pipeline
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("uso: python pipeline.py <pipeline.json> [--out report.json] [--no-fail-fast]", file=sys.stderr)
        sys.exit(2)
    p = load_pipeline_from_json(sys.argv[1])
    if "--no-fail-fast" in sys.argv:
        p.fail_fast = False
    results = p.run()
    out_idx = sys.argv.index("--out") + 1 if "--out" in sys.argv else None
    if out_idx:
        p.write_report(results, sys.argv[out_idx])
    # Exit code: 0 si todos los steps pasaron, 1 si alguno fallo
    failed = any(r.returncode != 0 for r in results)
    sys.exit(1 if failed else 0)
