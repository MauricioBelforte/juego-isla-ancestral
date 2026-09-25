#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""GATE: secrets hardcodeados en el código del juego (M106 / job `security-scan`).

Reemplaza los 4 `grep ... || true` de `.github/workflows/quality.yml`, que **nunca podían
fallar** (trampa 81) y además estaban **rotos**: usaban `\\s*=` en BRE (grep sin `-E`), donde
`\\s` es la **letra `s`**, así que el patrón real era `passwords*=` y **no matcheaba** la forma
normal `password = "..."`. Y el `! grep | grep -v test | grep -v mock || true` negaba el exit
code del **último** comando del pipe, no el del `grep` que buscaba.

Los patrones espejan `game/isla-ancestral/scripts/security/security_secret_scanner.gd`
(M106 T-006) para que el gate de CI y el escáner in-game coincidan.

Uso:
    python3 scripts/auditar_secrets.py                  # GATE: exit 1 si hay hallazgos
    python3 scripts/auditar_secrets.py --selftest       # prueba EN ROJO por inyección
    python3 scripts/auditar_secrets.py --incluir-tests  # no excluye test_*/mock*
    python3 scripts/auditar_secrets.py --raiz <dir>     # cambia el árbol escaneado
    python3 scripts/auditar_secrets.py --verbose        # imprime también lo excluido

Salida: una línea por hallazgo (`ruta:línea: <regla> — <prefijo>***REDACTED***`) y un resumen.
**Nunca** imprime el valor del secret.

Exit: 0 = limpio · 1 = hallazgos · 2 = error de uso/entorno.
"""
import argparse
import io
import os
import re
import sys
import tempfile

# --- Patrones (espejo de security_secret_scanner.gd PATRONES_DEFAULT) -------------------
PATRONES = [
    (r"(?i)(api[_-]?key|secret|token|password|passwd|pwd)\s*[:=]+\s*[\"'][^\"']{6,}[\"']",
     "clave-asignada"),
    (r"(?i)(aws|gcp|azure)[_-]?(access|secret)[_-]?key\s*[:=]+\s*[\"'][^\"']+[\"']",
     "cloud-key"),
    (r"AKIA[0-9A-Z]{16}", "aws-access-key-id"),
    (r"-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----", "clave-privada-pem"),
    (r"(?i)bearer\s+[A-Za-z0-9\-._~+/]{10,}", "bearer-token"),
]

# Placeholders legítimos (plantillas/ejemplos) — mismo criterio que el escáner in-game.
PLACEHOLDERS = ("your_", "changeme", "example", "placeholder", "xxx", "todo",
                "<", "env.", "getenv", "os.get_environment", "environment")

EXTENSIONES = (".gd", ".cfg", ".json", ".tscn", ".tres", ".cs", ".py", ".env")

# Rutas EXENTAS por diseño: son el DETECTOR y sus FIXTURES, no "secrets hardcodeados".
# Se eximen por ARCHIVO (no por línea) a propósito: son 2 archivos revisados, y el `--selftest`
# del propio gate prueba que la detección sigue viva — la exención no puede apagarla en silencio.
EXENTAS = (
    "scripts/security/security_secret_scanner.gd",   # escáner in-game: contiene los PATRONES
    "scripts/auditar_secrets.py",                    # este gate: contiene los FIXTURE_* del selftest
)

# Un archivo es de prueba si su nombre o su carpeta lo dicen.
RE_TEST = re.compile(r"(^|/)(tests?|mocks?)/|(^|/)test[_-]|_test\.[a-z]+$|(^|/)mock")


def es_placeholder(linea: str) -> bool:
    low = linea.lower()
    return any(p in low for p in PLACEHOLDERS)


def escanear_texto(contenido: str):
    """Devuelve [(linea, regla, prefijo_redactado)] de un texto fuente."""
    hallazgos = []
    for i, linea in enumerate(contenido.split("\n"), start=1):
        if linea.lstrip().startswith("#"):        # comentario puro
            continue
        if es_placeholder(linea):
            continue
        for patron, regla in PATRONES:
            if re.search(patron, linea):
                hallazgos.append((i, regla, _redactar(linea)))
                break
    return hallazgos


def _redactar(linea: str) -> str:
    """Prefijo de la línea hasta el '=' o ':' — nunca expone el valor."""
    s = linea.strip()
    cortes = [c for c in (s.find("="), s.find(":")) if c > 0]
    corte = min(cortes) if cortes else len(s)
    return s[:min(corte + 1, 48)] + "***REDACTED***"


def archivos(raiz: str, incluir_tests: bool, verbose: bool):
    escaneados, excluidos = 0, 0
    for base, dirs, ficheros in os.walk(raiz):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for f in sorted(ficheros):
            if not f.lower().endswith(EXTENSIONES):
                continue
            ruta = os.path.join(base, f)
            rel = ruta.replace(os.sep, "/")
            if not incluir_tests and RE_TEST.search(rel):
                excluidos += 1
                if verbose:
                    print("  (excluido por test) %s" % rel)
                continue
            if any(rel.endswith(e) for e in EXENTAS):
                excluidos += 1
                if verbose:
                    print("  (exento por diseño) %s" % rel)
                continue
            escaneados += 1
            yield ruta, rel
    print("-- archivos escaneados: %d · excluidos: %d" % (escaneados, excluidos))


def main() -> int:
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("--raiz", default=os.path.join("game", "isla-ancestral", "scripts"))
    ap.add_argument("--incluir-tests", action="store_true")
    ap.add_argument("--verbose", action="store_true")
    ap.add_argument("--selftest", action="store_true")
    args = ap.parse_args()

    if args.selftest:
        return selftest()

    if not os.path.isdir(args.raiz):
        print("ERROR: no existe la raíz '%s'" % args.raiz, file=sys.stderr)
        return 2

    print("=== GATE secrets (M106 / security-scan) — raíz: %s ===" % args.raiz)
    total, con_hallazgos = 0, 0
    for ruta, rel in archivos(args.raiz, args.incluir_tests, args.verbose):
        with io.open(ruta, "r", encoding="utf-8", errors="replace") as f:
            contenido = f.read()
        hallazgos = escanear_texto(contenido)
        if hallazgos:
            con_hallazgos += 1
            for linea, regla, frag in hallazgos:
                total += 1
                print("  %s:%d: [%s] %s" % (rel, linea, regla, frag))

    if total:
        print("\nFALLO: %d hallazgo(s) en %d archivo(s). Un secret no se versiona (§M106 RF2)."
              % (total, con_hallazgos))
        return 1
    print("\nOK: 0 secrets hardcodeados.")
    return 0


# --- Selftest: prueba EN ROJO por inyección (trampa 91) ---------------------------------
FIXTURE_LIMPIO = """extends Node
const VERSION := "1.0.0"
var api_key: String = OS.get_environment("APP_API_KEY")
var token: String = ProjectSettings.get_setting("app/token", "")
func saluda() -> void:
    print("hola")
"""

FIXTURE_SUCIO = """extends Node
var api_key: String = "AKIAIOSFODNN7REALKEY"
var password = "hunter2secreto"
"""


def selftest() -> int:
    print("=== SELFTEST: el gate debe dar VERDE en limpio y ROJO por inyección ===")
    fallos = 0

    # 1) texto limpio -> 0 hallazgos
    h = escanear_texto(FIXTURE_LIMPIO)
    print("  [%s] fixture limpio -> %d hallazgo(s)" % ("OK" if not h else "FALLO", len(h)))
    if h:
        fallos += 1
        print("     inesperado: %r" % (h,))

    # 2) texto sucio -> >= 1 hallazgo, nombrando la línea
    h2 = escanear_texto(FIXTURE_SUCIO)
    ok = len(h2) >= 2 and h2[0][0] == 2
    print("  [%s] fixture sucio -> %d hallazgo(s), 1º en línea %s"
          % ("OK" if ok else "FALLO", len(h2), h2[0][0] if h2 else "-"))
    if not ok:
        fallos += 1

    # 3) el valor del secret NUNCA debe aparecer en el fragmento
    fugas = [f for _, _, f in h2 if "REALKEY" in f or "hunter2secreto" in f]
    print("  [%s] sin fuga del valor en el fragmento -> %d fuga(s)"
          % ("OK" if not fugas else "FALLO", len(fugas)))
    if fugas:
        fallos += 1

    # 4) end-to-end sobre un árbol temporal: rojo si hay secret, verde si se quita
    with tempfile.TemporaryDirectory() as tmp:
        malo = os.path.join(tmp, "modulo_malo.gd")
        with io.open(malo, "w", encoding="utf-8") as f:
            f.write(FIXTURE_SUCIO)
        rc_rojo = _escanear_dir_rc(tmp)
        os.remove(malo)
        rc_verde = _escanear_dir_rc(tmp)
        print("  [%s] árbol con secret -> exit %d (esperaba 1)" % ("OK" if rc_rojo == 1 else "FALLO", rc_rojo))
        print("  [%s] árbol limpio      -> exit %d (esperaba 0)" % ("OK" if rc_verde == 0 else "FALLO", rc_verde))
        if rc_rojo != 1:
            fallos += 1
        if rc_verde != 0:
            fallos += 1

    # 5) un archivo de test NO debe contar (exclusión documentada)
    with tempfile.TemporaryDirectory() as tmp:
        t = os.path.join(tmp, "test_algo.gd")
        with io.open(t, "w", encoding="utf-8") as f:
            f.write(FIXTURE_SUCIO)
        rc = _escanear_dir_rc(tmp)
        print("  [%s] secret en test_*.gd -> exit %d (esperaba 0: excluido)" % ("OK" if rc == 0 else "FALLO", rc))
        if rc != 0:
            fallos += 1

    print("\nSELFTEST: %s (%d fallo(s))" % ("OK" if not fallos else "FALLO", fallos))
    return 0 if not fallos else 1


def _escanear_dir_rc(raiz: str) -> int:
    """Igual que main() pero sobre `raiz`, sin imprimir. Devuelve el exit code."""
    for base, dirs, ficheros in os.walk(raiz):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for f in sorted(ficheros):
            if not f.lower().endswith(EXTENSIONES):
                continue
            rel = os.path.join(base, f).replace(os.sep, "/")
            if RE_TEST.search(rel) or any(rel.endswith(e) for e in EXENTAS):
                continue
            with io.open(os.path.join(base, f), "r", encoding="utf-8", errors="replace") as fh:
                if escanear_texto(fh.read()):
                    return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
