#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.

# M127 iter. 3 - Suite de tools/legal/dump_authorship_evidence.py.
#
# Lo que de verdad hay que probar aqui no es que el volcado se genere (eso se ve
# a simple vista) sino que la HUELLA DETECTE LA MANIPULACION: un volcado sin
# huella verificable no sirve como prueba pericial. Se prueba por inyeccion:
# se edita un byte del .txt y --verificar debe fallar.

import io
import os
import sys
import json
import shutil
import contextlib
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dump_authorship_evidence as D  # noqa: E402

MODULO = "M127 dump_authorship_evidence"
CHECKS_MINIMOS = 18

_checks = 0
_fallos = 0
_vistos = {}
BLOQUES = ["cuerpo", "huella", "generar", "listar", "inyeccion"]


def _check(cond, msg):
    global _checks, _fallos
    _checks += 1
    if cond:
        print("  [OK] %s" % msg)
    else:
        _fallos += 1
        print("  [FALLO] %s" % msg)


def _fin(nombre):
    _vistos[nombre] = True


def _resumen():
    for n in BLOQUES:
        if n not in _vistos:
            print("  [FALLO] bloque '%s' NO se ejecuto (posible aborto)" % n)
            globals()["_fallos"] += 1
            globals()["_checks"] += 1
    if _checks < CHECKS_MINIMOS:
        print("  [FALLO] solo %d checks ejecutados (minimo %d)" % (_checks, CHECKS_MINIMOS))
        globals()["_fallos"] += 1
        globals()["_checks"] += 1
    print("=== Resumen %s: %d checks, %d fallo(s) ===" % (MODULO, _checks, _fallos))
    return 1 if _fallos else 0


COMMITS = [
    ("aaaa1111222233334444", "Ana Dev", "ana@ejemplo.com", "2026-09-10T10:00:00-03:00", "2026-09-10T10:00:00-03:00", "feat: primera"),
    ("bbbb1111222233334444", "Beto Dev", "beto@ejemplo.com", "2026-09-11T11:00:00-03:00", "2026-09-11T11:00:00-03:00", "fix: segunda"),
    ("cccc1111222233334444", "Ana Dev", "ana@ejemplo.com", "2026-09-12T12:00:00-03:00", "2026-09-12T12:00:00-03:00", "docs: tercera"),
]


def test_cuerpo(base):
    print("\n-- bloque cuerpo --")
    cuerpo = D.construir_cuerpo(COMMITS, ["ruta/x"], None, None)
    _check("EVIDENCIA DE AUTORIA" in cuerpo, "el cuerpo lleva titulo")
    _check("Commits   : 3" in cuerpo, "cuenta los commits")
    _check("Autores   : 2" in cuerpo, "cuenta autores UNICOS (Ana aparece 2 veces): %s"
           % [l for l in cuerpo.splitlines() if "Autores" in l])
    _check("Ana Dev" in cuerpo and "<ana@ejemplo.com>" in cuerpo, "lista autor y email")
    _check("Ana Dev" in cuerpo and cuerpo.count("ana@ejemplo.com") >= 2, "cuenta los commits por autor")
    _check("inicio .. HEAD" in cuerpo, "rango por defecto = inicio..HEAD")
    _check("ruta/x" in cuerpo, "declara el alcance")

    # DETERMINISMO: dos construcciones del mismo rango deben ser identicas
    _check(D.construir_cuerpo(COMMITS, ["ruta/x"], None, None) == cuerpo,
           "el cuerpo es determinista para el mismo rango")

    # Sin commits no revienta
    vacio = D.construir_cuerpo([], None, "2026-01-01", "2026-01-02")
    _check("Commits   : 0" in vacio and "TODO el repositorio" in vacio,
           "rango vacio -> 0 commits y alcance 'TODO el repositorio'")

    _check(D.slug("game/isla-ancestral/scripts/legal") == "game-isla-ancestral-scripts-legal",
           "slug normaliza la ruta")
    _check(D.slug("///") == "repo", "slug de algo vacio -> 'repo'")
    _fin("cuerpo")


def test_huella(base):
    print("\n-- bloque huella --")
    txt = os.path.join(base, "ev.txt")
    with open(txt, "wb") as fh:
        fh.write(b"contenido original\n")
    import hashlib
    digest = hashlib.sha256(open(txt, "rb").read()).hexdigest()
    with open(os.path.join(base, "ev.sha256"), "w", encoding="ascii", newline="\n") as fh:
        fh.write("%s  ev.txt\n" % digest)

    ok, msg = D.verificar(txt)
    _check(ok is True, "huella correcta -> verifica OK")
    _check(digest[:16] in msg, "el mensaje cita la huella")

    # MANIPULACION: un byte distinto debe romper la verificacion
    with open(txt, "ab") as fh:
        fh.write(b"linea anadida a escondidas\n")
    ok, msg = D.verificar(txt)
    _check(ok is False, "archivo manipulado -> verifica FALLA")
    _check("NO COINCIDE" in msg, "el mensaje dice que no coincide")

    # Falta el .sha256
    os.remove(os.path.join(base, "ev.sha256"))
    ok, msg = D.verificar(txt)
    _check(ok is False and "falta el .sha256" in msg, "sin .sha256 -> falla con motivo")

    # Archivo inexistente
    ok, msg = D.verificar(os.path.join(base, "no_existe.txt"))
    _check(ok is False and "no existe" in msg, "archivo inexistente -> falla con motivo")
    _fin("huella")


def test_generar(base):
    print("\n-- bloque generar --")
    out = os.path.join(base, "evidencia")
    r = D.generar(None, "2026-09-01", "2026-09-18", out)
    _check(r is not None, "genera el volcado sobre el repo real")
    if r is None:
        _fin("generar")
        return
    _check(os.path.isfile(r["txt"]), "crea el .txt")
    _check(os.path.isfile(r["sha256"]), "crea el .sha256")
    _check(r["commits"] > 0, "volca al menos 1 commit del rango: %d" % r["commits"])
    _check(r["bytes"] > 100, "el volcado tiene contenido: %d bytes" % r["bytes"])
    ok, _ = D.verificar(r["txt"])
    _check(ok is True, "el volcado recien generado verifica OK")

    # El digest del retorno debe ser el del archivo
    import hashlib
    real = hashlib.sha256(open(r["txt"], "rb").read()).hexdigest()
    _check(real == r["digest"], "el digest devuelto coincide con el archivo")

    # El cuerpo es determinista SOLO para un rango CERRADO en el pasado.
    # Con un rango abierto (hasta hoy/HEAD) el volcado cambia mientras corre: en
    # este worktree compartido otros agentes commitean, y generar() tarda segundos
    # (un `git show --numstat` por commit). Medido: 187 commits -> 2 corridas
    # seguidas dieron cuerpos distintos porque entro un commit ajeno en el medio.
    r2 = D.generar(None, "2026-09-01", "2026-09-10", out)
    r3 = D.generar(None, "2026-09-01", "2026-09-10", out)
    a = open(r2["txt"], "rb").read().split(b"\n\n", 1)[1]
    b = open(r3["txt"], "rb").read().split(b"\n\n", 1)[1]
    _check(a == b, "el CUERPO es identico entre dos generaciones de un rango CERRADO")
    _check(r2["digest"] != r3["digest"] or r2["txt"] == r3["txt"],
           "dos volcados del mismo rango cerrado: huellas iguales solo si el archivo es el mismo")

    # Ruta inexistente -> 0 commits, sin excepcion
    r4 = D.generar(["ruta/que/no/existe"], None, None, out)
    _check(r4 is not None and r4["commits"] == 0, "ruta inexistente -> 0 commits, sin excepcion")
    _fin("generar")


def test_listar(base):
    print("\n-- bloque listar --")
    out = os.path.join(base, "evidencia")
    archivos = D.listar(out)
    _check(len(archivos) >= 1, "listar encuentra los volcados: %d" % len(archivos))
    _check(all(f.endswith(".txt") for f in archivos), "listar solo devuelve .txt (no los .sha256)")
    _check(D.listar(os.path.join(base, "no_existe")) == [], "directorio inexistente -> lista vacia")

    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        rc = D.main(["--listar", "--out-dir", out])
    _check(rc == 0 and "volcados de evidencia" in buf.getvalue(), "--listar sale 0 e informa")

    # --json de listar debe ser JSON puro
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        D.main(["--listar", "--out-dir", out, "--json"])
    try:
        json.loads(buf.getvalue())
        _check(True, "--listar --json emite JSON puro")
    except Exception:
        _check(False, "--listar --json emite JSON puro")
    _fin("listar")


def test_inyeccion(base):
    print("\n-- bloque inyeccion (el piso de checks esta vivo?) --")
    global _checks, _fallos, _vistos
    guardado = (_checks, _fallos, dict(_vistos))
    _checks, _fallos, _vistos = 2, 0, {}
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        rc = _resumen()
    salida = buf.getvalue()
    _checks, _fallos, _vistos = guardado
    _check(rc == 1, "con 2 checks el piso FALLA y sale 1 (piso vivo)")
    _check("minimo %d" % CHECKS_MINIMOS in salida, "el resumen cita el piso (%d)" % CHECKS_MINIMOS)
    _check("bloque 'inyeccion' NO se ejecuto" in salida, "nombra los bloques faltantes")
    _fin("inyeccion")


def main():
    base = tempfile.mkdtemp(prefix="m127_dump_ev_")
    try:
        test_cuerpo(base)
        test_huella(base)
        test_generar(base)
        test_listar(base)
        test_inyeccion(base)
    finally:
        shutil.rmtree(base, ignore_errors=True)
    return _resumen()


if __name__ == "__main__":
    sys.exit(main())
