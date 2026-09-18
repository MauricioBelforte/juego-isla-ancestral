#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.

# M127 iter. 3 - Suite de tools/legal/registros_db.py.
#
# Cada regla del contrato se prueba en las DOS direcciones: el dato invalido se
# reporta y el valido NO. Un validador que solo prueba el caso bueno no
# distingue de un no-op (trampa 51 del skill).

import io
import os
import sys
import json
import shutil
import contextlib
import tempfile
from datetime import date, timedelta

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import registros_db as R  # noqa: E402

MODULO = "M127 registros_db"
CHECKS_MINIMOS = 22

_checks = 0
_fallos = 0
_vistos = {}
BLOQUES = ["contrato", "duplicados", "elementos", "escritura", "cli", "inyeccion"]

HOY = date.today()
AYER = (HOY - timedelta(days=1)).isoformat()
MANANA = (HOY + timedelta(days=1)).isoformat()


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


CONOCIDOS = {"codigo_fuente", "musica", "nombre_juego"}


def reg(**kw):
    base = {"elemento": "codigo_fuente", "tipo_registro": "codigo_fuente",
            "numero": "TX-1", "fecha_concesion": AYER, "certificado": "cert.pdf"}
    base.update(kw)
    return base


def doc(*registros):
    return {"version": 1, "registros": list(registros)}


def test_contrato(base):
    print("\n-- bloque contrato --")
    _check(R.validar(doc(), CONOCIDOS) == [], "lista vacia -> 0 errores (estado inicial legitimo)")
    _check(R.validar(doc(reg()), CONOCIDOS) == [], "registro completo y valido -> 0 errores")

    for campo in R.OBLIGATORIOS:
        d = doc(reg(**{campo: ""}))
        errs = R.validar(d, CONOCIDOS)
        _check(any("falta '%s'" % campo in e for e in errs), "campo '%s' vacio -> error" % campo)

    errs = R.validar(doc(reg(tipo_registro="inventado")), CONOCIDOS)
    _check(any("no es uno de" in e for e in errs), "tipo_registro invalido -> error")
    _check(R.validar(doc(reg(tipo_registro="artes_visuales", elemento="musica")), CONOCIDOS) == [],
           "tipo valido alternativo -> 0 errores")

    errs = R.validar(doc(reg(fecha_concesion="01/10/2026")), CONOCIDOS)
    _check(any("no es AAAA-MM-DD" in e for e in errs), "fecha con otro formato -> error")
    errs = R.validar(doc(reg(fecha_concesion="2026-02-30")), CONOCIDOS)
    _check(any("no es una fecha real" in e for e in errs), "fecha inexistente (30 feb) -> error")
    errs = R.validar(doc(reg(fecha_concesion=MANANA)), CONOCIDOS)
    _check(any("futuro" in e for e in errs), "fecha futura -> error")
    _check(R.validar(doc(reg(fecha_concesion=AYER)), CONOCIDOS) == [], "fecha de ayer -> valida")

    # Estructura rota
    _check(R.validar([], CONOCIDOS) != [], "un array en la raiz -> error")
    _check(any("falta la lista" in e for e in R.validar({"version": 1}, CONOCIDOS)),
           "sin la clave 'registros' -> error")
    _check(R.validar(doc("no soy un objeto"), CONOCIDOS) != [], "registro que no es objeto -> error")
    _fin("contrato")


def test_duplicados(base):
    print("\n-- bloque duplicados --")
    errs = R.validar(doc(reg(numero="TX-9"), reg(numero="TX-9")), CONOCIDOS)
    _check(any("duplicado" in e for e in errs), "numero repetido -> error")
    _check(any("registros[1]" in e for e in errs), "el error apunta al SEGUNDO registro")
    _check(R.validar(doc(reg(numero="TX-9"), reg(numero="TX-10")), CONOCIDOS) == [],
           "numeros distintos -> 0 errores")
    _fin("duplicados")


def test_elementos(base):
    print("\n-- bloque elementos --")
    errs = R.validar(doc(reg(elemento="no_existe")), CONOCIDOS)
    _check(any("no existe en copyright.json" in e for e in errs), "elemento desconocido -> error")
    _check(any("codigo_fuente" in e for e in errs), "el error lista los elementos validos")
    # Sin catalogo de elementos no se puede juzgar: no debe inventar un error
    _check(R.validar(doc(reg(elemento="lo_que_sea")), None) == [],
           "sin copyright.json no se juzga el elemento (no inventa error)")

    pend = R.sin_registrar(doc(reg(elemento="codigo_fuente")), CONOCIDOS)
    _check(pend == ["musica", "nombre_juego"], "sin_registrar devuelve los que faltan: %s" % pend)
    _check(R.sin_registrar(doc(), CONOCIDOS) == ["codigo_fuente", "musica", "nombre_juego"],
           "sin registros, todos pendientes")
    _check(R.sin_registrar(doc(), None) == [], "sin catalogo, sin_registrar es vacio")
    _fin("elementos")


def test_escritura(base):
    print("\n-- bloque escritura --")
    raiz = os.path.join(base, "repo")
    destino = os.path.join(raiz, "game/isla-ancestral/data/legal")
    os.makedirs(destino, exist_ok=True)
    # copyright.json con elementos conocidos
    with open(os.path.join(destino, "copyright.json"), "w", encoding="utf-8") as fh:
        json.dump({"version": 1, "elementos": [{"id": "codigo_fuente"}, {"id": "musica"}]}, fh)
    # registros.json con EOL LF
    with open(os.path.join(destino, "registros.json"), "w", encoding="utf-8", newline="\n") as fh:
        json.dump({"version": 1, "registros": []}, fh, indent=2)

    datos, err = R.cargar(raiz)
    _check(datos is not None and err is None, "cargar lee el archivo del raiz indicado")
    _check(R.elementos_conocidos(raiz) == {"codigo_fuente", "musica"}, "lee los elementos de copyright.json")

    datos = R.agregar(datos, reg(numero="TX-A"))
    R.guardar(datos, raiz)
    crudo = open(os.path.join(destino, "registros.json"), "rb").read()
    _check(b"TX-A" in crudo, "guardar persiste el registro")
    _check(crudo.count(b"\r\n") == 0, "guardar PRESERVA el EOL LF del archivo original")
    _check(crudo[:3] != b"\xef\xbb\xbf", "guardar no mete BOM")

    # EOL CRLF se preserva tambien
    with open(os.path.join(destino, "registros.json"), "wb") as fh:
        fh.write(b'{\r\n  "version": 1,\r\n  "registros": []\r\n}\r\n')
    datos2, _ = R.cargar(raiz)
    R.guardar(R.agregar(datos2, reg(numero="TX-B")), raiz)
    crudo2 = open(os.path.join(destino, "registros.json"), "rb").read()
    _check(crudo2.count(b"\r\n") > 0 and (crudo2.count(b"\n") - crudo2.count(b"\r\n")) == 0,
           "guardar PRESERVA el EOL CRLF del archivo original")

    # Archivo ausente -> error controlado
    _, err2 = R.cargar(os.path.join(base, "vacio"))
    _check(err2 is not None and "FALTA_REGISTROS_JSON" in err2, "archivo ausente -> FALTA_REGISTROS_JSON")
    _fin("escritura")


def test_cli(base):
    print("\n-- bloque cli --")
    raiz = os.path.join(base, "repo")
    destino = os.path.join(raiz, "game/isla-ancestral/data/legal")

    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        rc = R.main(["--raiz", raiz, "--validar", "--check"])
    _check(rc == 0, "--check con dato valido -> exit 0")
    _check("elementos sin registro formal" in buf.getvalue(), "--validar informa los pendientes")

    # Agregar valido
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        rc = R.main(["--raiz", raiz, "--agregar", "--elemento", "musica", "--tipo", "grabacion_sonora",
                     "--numero", "SR-777", "--fecha", AYER, "--certificado", "c.pdf", "--listar"])
    _check(rc == 0, "--agregar valido -> exit 0")
    _check("SR-777" in buf.getvalue(), "--listar muestra el registro agregado")

    # Agregar invalido NO debe escribir
    antes = open(os.path.join(destino, "registros.json"), "rb").read()
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        rc = R.main(["--raiz", raiz, "--agregar", "--elemento", "musica", "--tipo", "grabacion_sonora",
                     "--numero", "SR-777", "--fecha", AYER, "--certificado", "c.pdf"])
    _check(rc == 1, "--agregar con numero duplicado -> exit 1")
    _check("NO se guardo" in buf.getvalue(), "el mensaje dice que no se guardo")
    _check(open(os.path.join(destino, "registros.json"), "rb").read() == antes,
           "el archivo NO se modifico tras un agregado invalido")

    # Faltan argumentos
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        rc = R.main(["--raiz", raiz, "--agregar", "--elemento", "musica"])
    _check(rc == 1 and "necesita" in buf.getvalue(), "--agregar sin argumentos -> exit 1 con motivo")

    # --json puro
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        R.main(["--raiz", raiz, "--json"])
    try:
        d = json.loads(buf.getvalue())
        _check(isinstance(d.get("registros"), list), "--json emite JSON puro")
    except Exception:
        _check(False, "--json emite JSON puro")
    _fin("cli")


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
    base = tempfile.mkdtemp(prefix="m127_registros_")
    try:
        test_contrato(base)
        test_duplicados(base)
        test_elementos(base)
        test_escritura(base)
        test_cli(base)
        test_inyeccion(base)
    finally:
        shutil.rmtree(base, ignore_errors=True)
    return _resumen()


if __name__ == "__main__":
    sys.exit(main())
