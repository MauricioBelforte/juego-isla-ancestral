#!/usr/bin/env python3
"""Valida que los workflows de GitHub Actions sean YAML parseable y coherente.

BUG-077 (2026-09-20): `quality.yml` quedo con **YAML invalido** — un `name:` con
`: ` sin comillas, introducido en el commit 1582ac2 — y GitHub rechaza el archivo
**completo**. No es que falle un job: dejan de correr los 10. O sea, el CI entero
se apaga sin que ningun gate lo diga. Es la version CI de BUG-075: «no mire» con
cara de «todo verde».

Nada en el repo validaba los workflows, asi que el defecto vivio ~3 h. Este
validador es el gate que faltaba.

Que comprueba:
  1. Que cada `.github/workflows/*.yml` parsee como YAML.
  2. Que el workflow tenga `jobs` no vacio.
  3. Que cada job declare `runs-on`.
  4. Que cada nombre en `needs:` corresponda a un job que EXISTE (misma familia
     que la trampa 98: un gate que cita algo inexistente no es un gate).

Uso:
    python scripts/validar_workflows.py [--selftest]

Codigos de salida (misma convencion que verificar_checklist.py):
    0  todos los workflows validos.
    1  hay al menos un workflow con un problema real (se imprime el detalle).
    3  DETECTOR CIEGO: no existe `.github/workflows/`, no hay ningun workflow, o
       falta el parser YAML. No se puede afirmar que sean validos.
"""

import argparse
import sys
import tempfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
WORKFLOWS = RAIZ / ".github" / "workflows"

# Fixtures del --selftest. Se prueban EN ROJO: si el validador no ve el defecto
# sintetico, no sirve. (nombre, contenido, problemas ESPERADOS)
FIXTURES = [
    (
        "workflow correcto (control: no debe dar problemas)",
        "name: Q\non: [push]\njobs:\n  a:\n    runs-on: ubuntu-latest\n"
        "  b:\n    runs-on: ubuntu-latest\n    needs: [a]\n",
        0,
    ),
    (
        "BUG-077: `name:` con ': ' sin comillas",
        "name: Q\non: [push]\njobs:\n  a:\n"
        "    name: Architecture Guard (M62: servicios)\n    runs-on: ubuntu-latest\n",
        1,
    ),
    (
        "trampa 98: `needs:` cita un job inexistente",
        "name: Q\non: [push]\njobs:\n  a:\n    runs-on: ubuntu-latest\n"
        "  b:\n    runs-on: ubuntu-latest\n    needs: [no_existe]\n",
        1,
    ),
    (
        "job sin `runs-on` ni `uses`",
        "name: Q\non: [push]\njobs:\n  a:\n    steps: []\n",
        1,
    ),
]

# Forzar salida UTF-8 en Windows (PowerShell/cmd no soportan emojis por defecto)
if sys.stdout and hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass


def _detectar_causa(lineas, n_linea):
    """Devuelve una pista accionable para el error de la linea indicada.

    El error tipico de esta familia es un `: ` sin comillas dentro de un escalar
    (`name: Foo (Bar: baz)`), que YAML lee como un mapeo anidado. El parser solo
    dice «mapping values are not allowed here», que no ayuda a arreglarlo.
    """
    if not (1 <= n_linea <= len(lineas)):
        return None
    linea = lineas[n_linea - 1]
    cuerpo = linea.split(":", 1)[1] if ":" in linea else ""
    if ": " in cuerpo and not cuerpo.strip().startswith(('"', "'", "|", ">")):
        return (
            f"la linea {n_linea} tiene un ': ' sin comillas dentro del valor "
            f"-> comillarla. YAML lo lee como un mapeo anidado."
        )
    return None


def validar_archivo(ruta: Path, yaml_mod, lineas):
    """Devuelve una lista de problemas (vacia si el workflow esta bien)."""
    problemas = []
    try:
        datos = yaml_mod.safe_load(ruta.read_text(encoding="utf-8"))
    except yaml_mod.YAMLError as e:
        marca = getattr(e, "problem_mark", None)
        donde = f"linea {marca.line + 1}, col {marca.column + 1}" if marca else "ubicacion desconocida"
        problemas.append(f"YAML INVALIDO en {donde}: {e.problem or e}")
        if marca:
            pista = _detectar_causa(lineas, marca.line + 1)
            if pista:
                problemas.append(f"  -> {pista}")
        return problemas

    if not isinstance(datos, dict):
        problemas.append("el YAML no es un mapeo (raiz invalida)")
        return problemas

    jobs = datos.get("jobs")
    if not isinstance(jobs, dict) or not jobs:
        problemas.append("no declara `jobs` (o esta vacio)")
        return problemas

    for nombre, job in jobs.items():
        if not isinstance(job, dict):
            problemas.append(f"job `{nombre}`: no es un mapeo")
            continue
        if "uses" not in job and "runs-on" not in job:
            problemas.append(f"job `{nombre}`: sin `runs-on` ni `uses`")
        needs = job.get("needs")
        if needs is None:
            continue
        if isinstance(needs, str):
            needs = [needs]
        if not isinstance(needs, list):
            problemas.append(f"job `{nombre}`: `needs` no es lista ni string")
            continue
        for dep in needs:
            if dep not in jobs:
                problemas.append(
                    f"job `{nombre}`: `needs: {dep}` cita un job que NO EXISTE "
                    f"(trampa 98 — un gate que cita algo inexistente no es un gate)"
                )
    return problemas


def validar_repo():
    try:
        import yaml
    except ImportError:
        print("=" * 60)
        print("🛑 DETECTOR CIEGO (exit 3): falta el parser YAML (PyYAML).")
        print("   Sin parser no se puede afirmar que los workflows sean validos.")
        print("   Instalar con: pip install pyyaml")
        print("=" * 60)
        return 3

    if not WORKFLOWS.is_dir():
        print("=" * 60)
        print(f"🛑 DETECTOR CIEGO (exit 3): no existe {WORKFLOWS}.")
        print("   Un repo sin workflows no esta «sin problemas»: esta sin CI.")
        print("=" * 60)
        return 3

    archivos = sorted(list(WORKFLOWS.glob("*.yml")) + list(WORKFLOWS.glob("*.yaml")))
    if not archivos:
        print("=" * 60)
        print(f"🛑 DETECTOR CIEGO (exit 3): {WORKFLOWS} no tiene ningun .yml/.yaml.")
        print("=" * 60)
        return 3

    print("=" * 60)
    print("🔍 VALIDACION DE WORKFLOWS DE GITHUB ACTIONS")
    print("=" * 60)
    print()

    total_problemas = 0
    for ruta in archivos:
        lineas = ruta.read_text(encoding="utf-8").splitlines()
        problemas = validar_archivo(ruta, yaml, lineas)
        if problemas:
            total_problemas += len([p for p in problemas if not p.startswith("  ->")])
            print(f"  ❌ {ruta.name}")
            for p in problemas:
                print(f"     {p}")
        else:
            print(f"  ✅ {ruta.name}")

    print()
    print("=" * 60)
    if total_problemas:
        print(f"❌ {total_problemas} PROBLEMA(S) en los workflows.")
        print("   GitHub rechaza el archivo COMPLETO: no falla un job, se apaga el CI.")
        return 1
    print(f"✅ {len(archivos)} workflow(s) validos: YAML parseable, jobs con runs-on y needs coherentes.")
    return 0


def selftest():
    """Corre los fixtures del validador. Un guardian que no ve el defecto
    sintetico no sirve, asi que esto se corre ANTES de confiar en el gate."""
    import yaml

    print("=" * 60)
    print("🧪 SELFTEST — validar_workflows.py")
    print("=" * 60)
    print()

    fallos = 0
    for nombre, contenido, esperados in FIXTURES:
        with tempfile.TemporaryDirectory() as tmp:
            ruta = Path(tmp) / "fixture.yml"
            ruta.write_text(contenido, encoding="utf-8")
            problemas = validar_archivo(ruta, yaml, contenido.splitlines())
        reales = [p for p in problemas if not p.startswith("  ->")]
        if len(reales) == esperados:
            print(f"  ✅ {nombre} -> {len(reales)} problema(s)")
        else:
            fallos += 1
            print(f"  ❌ {nombre} -> esperaba {esperados}, obtuvo {len(reales)}")
            for p in problemas:
                print(f"       {p}")

    print()
    print("=" * 60)
    if fallos:
        print(f"❌ SELFTEST FALLIDO: {fallos} de {len(FIXTURES)} fixtures mal.")
        return 1
    print(f"✅ SELFTEST OK: {len(FIXTURES)}/{len(FIXTURES)} fixtures.")
    return 0


def main():
    parser = argparse.ArgumentParser(description="Valida los workflows de GitHub Actions.")
    parser.add_argument(
        "--selftest",
        action="store_true",
        help="Corre los fixtures del propio validador (probarlo en rojo) y sale.",
    )
    args = parser.parse_args()
    if args.selftest:
        return selftest()
    return validar_repo()


if __name__ == "__main__":
    sys.exit(main())
