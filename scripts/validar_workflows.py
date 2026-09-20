#!/usr/bin/env python3
"""Valida que los workflows de GitHub Actions sean YAML parseable y coherente.

BUG-077 (2026-09-20): `quality.yml` quedo con **YAML invalido** — un `name:` con
`: ` sin comillas, introducido en el commit 1582ac2 — y GitHub rechaza el archivo
**completo**. No es que falle un job: dejan de correr los 10. O sea, el CI entero
se apaga sin que ningun gate lo diga. Es la version CI de BUG-075: «no mire» con
cara de «todo verde».

BUG-078 (2026-09-20): el gate `godot-lint` ejecutaba **8 scripts que NO estan en
el repositorio** (`test_player_m11.gd`, 5 de M64, 1 de M116, 1 de M117). En un
checkout limpio Godot sale con **exit 1** («File not found») y el `|| FAIL=1`
pone el job en ROJO — pero en la maquina del autor el archivo existe y todo
parece verde. Es la **trampa 98** (un gate que cita algo que no esta versionado)
y ya habia pasado con BUG-051/BUG-071. Este validador es el gate que faltaba.

Que comprueba:
  1. Que cada `.github/workflows/*.yml` parsee como YAML.
  2. Que el workflow tenga `jobs` no vacio.
  3. Que cada job declare `runs-on`.
  4. Que cada nombre en `needs:` corresponda a un job que EXISTE (misma familia
     que la trampa 98: un gate que cita algo inexistente no es un gate).
  5. Que cada `--script <ruta>.gd` del workflow **este versionado en HEAD**
     (`git cat-file -e`, no `os.path.exists`: el archivo puede estar en tu disco
     y no en el repo). Las citas permitidas y la deuda conocida se declaran
     abajo, y una entrada de la deuda que ya este resuelta se reporta como
     problema para que la lista no envejezca en silencio.

Uso:
    python scripts/validar_workflows.py [--selftest]

Codigos de salida (misma convencion que verificar_checklist.py):
    0  todos los workflows validos.
    1  hay al menos un workflow con un problema real (se imprime el detalle).
    3  DETECTOR CIEGO: no existe `.github/workflows/`, no hay ningun workflow,
       falta el parser YAML, o no se puede consultar el repositorio git (sin
       git no se puede afirmar que las citas esten versionadas).
"""

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
WORKFLOWS = RAIZ / ".github" / "workflows"
PREFIJO_JUEGO = "game/isla-ancestral/"

# Citados por los workflows y NO versionados a proposito, porque se GENERAN en
# CI antes de usarse. Si se dejan de generar, el gate los ve como deuda nueva.
CITAS_PERMITIDAS = {
    "scripts/editor/_colector_sintaxis.gd":
        "generado en CI por tools/quality/gen_colector_sintaxis.py (paso previo)",
}

# Deuda CONOCIDA y registrada (BUG-078): citas que hoy no estan versionadas.
# Se reportan como AVISO, no como problema, para no apagar el CI por deuda de
# otro dueno — pero cualquier cita NUEVA si falla. Al resolver una, hay que
# borrar su linea: si sigue estando, el validador la marca como obsoleta.
DEUDA_CONOCIDA = {
    "scripts/build/test_instalador_m116.gd": "M116",
    "scripts/build/test_build_m117.gd": "M117",
    "scripts/ia_npc/test_ia_npc_m64_iterN.gd": "M64",
    "scripts/ia_npc/test_navegacion_m64.gd": "M64",
    "scripts/ia_npc/test_social_m64.gd": "M64",
    "scripts/ia_npc/test_rendimiento_m64.gd": "M64",
    "scripts/ia_npc/test_persistencia_m64.gd": "M64",
}

RE_SCRIPT = re.compile(r"--script\s+(?:res://)?([A-Za-z0-9_./\-]+\.gd)")

# Fixtures del --selftest. Se prueban EN ROJO: si el validador no ve el defecto
# sintetico, no sirve. (nombre, contenido, problemas ESPERADOS, resolver)
# `resolver` es None (no se comprueban citas) o un dict {ruta: bool versionada}.
FIXTURES = [
    (
        "workflow correcto (control: no debe dar problemas)",
        "name: Q\non: [push]\njobs:\n  a:\n    runs-on: ubuntu-latest\n"
        "  b:\n    runs-on: ubuntu-latest\n    needs: [a]\n",
        0,
        None,
    ),
    (
        "BUG-077: `name:` con ': ' sin comillas",
        "name: Q\non: [push]\njobs:\n  a:\n"
        "    name: Architecture Guard (M62: servicios)\n    runs-on: ubuntu-latest\n",
        1,
        None,
    ),
    (
        "trampa 98: `needs:` cita un job inexistente",
        "name: Q\non: [push]\njobs:\n  a:\n    runs-on: ubuntu-latest\n"
        "  b:\n    runs-on: ubuntu-latest\n    needs: [no_existe]\n",
        1,
        None,
    ),
    (
        "job sin `runs-on` ni `uses`",
        "name: Q\non: [push]\njobs:\n  a:\n    steps: []\n",
        1,
        None,
    ),
    (
        "BUG-078: `--script` cita un archivo NO versionado",
        "name: Q\non: [push]\njobs:\n  a:\n    runs-on: ubuntu-latest\n"
        "    steps:\n      - run: godot --headless --script scripts/x/fantasma.gd\n",
        1,
        {"scripts/x/fantasma.gd": False},
    ),
    (
        "control negativo: `--script` versionado no da problemas",
        "name: Q\non: [push]\njobs:\n  a:\n    runs-on: ubuntu-latest\n"
        "    steps:\n      - run: godot --headless --script scripts/x/real.gd\n",
        0,
        {"scripts/x/real.gd": True},
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


def _scripts_citados(datos):
    """Todas las rutas .gd que los `run:` de los jobs pasan a `--script`.

    Se recorre la estructura real (`jobs.*.steps[*].run`), no el texto crudo:
    asi una ruta mencionada en un comentario no se cuenta como cita ejecutada.
    """
    rutas = []
    for job in datos.get("jobs", {}).values():
        if not isinstance(job, dict):
            continue
        for paso in job.get("steps", []) or []:
            if not isinstance(paso, dict):
                continue
            texto = paso.get("run")
            if not isinstance(texto, str):
                continue
            for m in RE_SCRIPT.finditer(texto):
                ruta = m.group(1)
                if ruta not in rutas:
                    rutas.append(ruta)
    return rutas


def validar_archivo(ruta: Path, yaml_mod, lineas, existe_en_repo=None):
    """Devuelve una lista de problemas (vacia si el workflow esta bien).

    `existe_en_repo` es un Callable(ruta) -> bool|None. None = no se puede
    saber (sin git); en ese caso la cita NO se marca como problema: no medir
    no es medir que falta.
    """
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

    if existe_en_repo is not None:
        for cita in _scripts_citados(datos):
            if cita in CITAS_PERMITIDAS:
                continue
            estado = existe_en_repo(cita)
            if estado is None:
                continue  # sin git no se puede afirmar
            if not estado:
                dueno = DEUDA_CONOCIDA.get(cita)
                if dueno:
                    problemas.append(
                        f"  ~ AVISO deuda conocida (BUG-078): `--script {cita}` "
                        f"no esta versionado — dueno {dueno}"
                    )
                else:
                    problemas.append(
                        f"`--script {cita}` NO esta versionado en el repositorio "
                        f"(trampa 98: en un checkout limpio Godot sale 1 y el job "
                        f"queda ROJO; en tu disco existe y parece verde)"
                    )
    return problemas


def _resolver_git():
    """Devuelve un Callable(ruta) -> bool|None consultando HEAD, o None si no
    hay git utilizable (entonces el validador es CIEGO para esta regla)."""
    try:
        subprocess.run(
            ["git", "rev-parse", "--verify", "HEAD"],
            cwd=RAIZ, capture_output=True, check=True, timeout=30,
        )
    except Exception:
        return None

    cache = {}

    def existe(cita: str):
        if cita in cache:
            return cache[cita]
        for repo in (PREFIJO_JUEGO + cita, cita):
            r = subprocess.run(
                ["git", "cat-file", "-e", "HEAD:" + repo],
                cwd=RAIZ, capture_output=True, timeout=30,
            )
            if r.returncode == 0:
                cache[cita] = True
                return True
        cache[cita] = False
        return False

    return existe


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

    existe_en_repo = _resolver_git()
    if existe_en_repo is None:
        print("=" * 60)
        print("🛑 DETECTOR CIEGO (exit 3): no hay repositorio git en " + str(RAIZ) + ".")
        print("   Sin HEAD no se puede comprobar que las citas `--script` esten")
        print("   versionadas, que es justo lo que causo BUG-078.")
        print("=" * 60)
        return 3

    print("=" * 60)
    print("🔍 VALIDACION DE WORKFLOWS DE GITHUB ACTIONS")
    print("=" * 60)
    print()

    total_problemas = 0
    total_avisos = 0
    for ruta in archivos:
        lineas = ruta.read_text(encoding="utf-8").splitlines()
        problemas = validar_archivo(ruta, yaml, lineas, existe_en_repo)
        reales = [p for p in problemas if not p.startswith("  ->")]
        avisos = [p for p in reales if p.startswith("  ~ ")]
        duros = [p for p in reales if not p.startswith("  ~ ")]
        total_problemas += len(duros)
        total_avisos += len(avisos)
        if duros:
            print(f"  ❌ {ruta.name}")
            for p in problemas:
                print(f"     {p}")
        else:
            print(f"  ✅ {ruta.name}")
            for p in avisos:
                print(f"     {p}")

    # La deuda resuelta que sigue declarada es un problema: una lista de deuda
    # que no se limpia deja de informar.
    for cita, dueno in sorted(DEUDA_CONOCIDA.items()):
        if existe_en_repo(cita):
            total_problemas += 1
            print(
                f"  ❌ DEUDA OBSOLETA en DEUDA_CONOCIDA: `{cita}` (dueno {dueno}) "
                f"YA esta versionada -> borrar su entrada del validador."
            )

    print()
    print("=" * 60)
    if total_problemas:
        print(f"❌ {total_problemas} PROBLEMA(S) en los workflows.")
        print("   GitHub rechaza el archivo COMPLETO: no falla un job, se apaga el CI.")
        return 1
    if total_avisos:
        print(f"⚠️  {len(archivos)} workflow(s) validos, con {total_avisos} aviso(s) de deuda conocida (BUG-078).")
        print("   No es un problema NUEVO, pero sigue pendiente de su dueno.")
    else:
        print(f"✅ {len(archivos)} workflow(s) validos: YAML parseable, jobs con runs-on,")
        print("   needs coherentes y toda cita `--script` versionada.")
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
    for nombre, contenido, esperados, mapa in FIXTURES:
        resolver = (lambda c, m=mapa: m.get(c, True)) if mapa is not None else None
        with tempfile.TemporaryDirectory() as tmp:
            ruta = Path(tmp) / "fixture.yml"
            ruta.write_text(contenido, encoding="utf-8")
            problemas = validar_archivo(ruta, yaml, contenido.splitlines(), resolver)
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
