#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.

# M127 iter. 3 (item L139) - Base centralizada de numeros de registro,
# certificados y fechas de concesion de derechos de autor.
#
# Distincion que importa (y que el registro existente no hacia):
#   - copyright.json / legal/copyright_register.md  -> QUE elementos existen y
#     su estado de proteccion (automatica desde Berna).
#   - registros.json (este)                        -> QUE registros FORMALES se
#     obtuvieron, con numero, certificado y fecha de concesion.
# Son cosas distintas: la proteccion nace sola; el registro formal es un acto
# administrativo con un numero y una fecha. Hasta ahora no habia donde anotarlos.
#
# El estado inicial es legitimo y NO es un fallo: la lista esta vacia porque
# todavia no se registro nada. El validador comprueba el CONTRATO del dato, no
# que haya datos.
#
# Uso:
#   python tools/legal/registros_db.py --validar          # exit 1 si el dato no cumple
#   python tools/legal/registros_db.py --listar
#   python tools/legal/registros_db.py --agregar --elemento codigo_fuente \
#       --tipo codigo_fuente --numero TX-1234567 --fecha 2026-10-01 --certificado legal/certificados/tx.pdf
#   python tools/legal/registros_db.py --json
#
# Exit 0 si OK, 1 si el dato no cumple el contrato.

import os
import re
import sys
import json
import argparse
from datetime import date

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
REGISTROS_JSON = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data", "legal", "registros.json")
COPYRIGHT_JSON = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data", "legal", "copyright.json")

# Tipos de obra registrables (los mismos que documenta 03-Diseno.md §2).
TIPOS = ("codigo_fuente", "artes_visuales", "grabacion_sonora", "obra_literaria", "marca")

# Campos obligatorios de cada registro.
OBLIGATORIOS = ("elemento", "tipo_registro", "numero", "fecha_concesion", "certificado")

RE_FECHA = re.compile(r"^\d{4}-\d{2}-\d{2}$")


def _leer_json(ruta):
    with open(ruta, "rb") as fh:
        return json.loads(fh.read().decode("utf-8-sig"))


def cargar(raiz=PROJECT_ROOT):
    """(datos, error)."""
    ruta = os.path.join(raiz, os.path.relpath(REGISTROS_JSON, PROJECT_ROOT))
    if not os.path.isfile(ruta):
        return None, "FALTA_REGISTROS_JSON: %s" % os.path.relpath(ruta, raiz)
    try:
        return _leer_json(ruta), None
    except Exception as e:
        return None, "REGISTROS_ILEGIBLE: %s" % e


def elementos_conocidos(raiz=PROJECT_ROOT):
    """Ids declarados en copyright.json (a que elemento puede apuntar un registro)."""
    ruta = os.path.join(raiz, os.path.relpath(COPYRIGHT_JSON, PROJECT_ROOT))
    if not os.path.isfile(ruta):
        return None
    try:
        return {e.get("id") for e in _leer_json(ruta).get("elementos", [])}
    except Exception:
        return None


def validar(datos, conocidos):
    """Lista de errores. Lista vacia = el dato cumple el contrato."""
    errores = []
    if not isinstance(datos, dict):
        return ["el archivo no es un objeto JSON"]
    registros = datos.get("registros")
    if not isinstance(registros, list):
        return ["falta la lista 'registros'"]

    numeros = {}
    for i, r in enumerate(registros):
        prefijo = "registros[%d]" % i
        if not isinstance(r, dict):
            errores.append("%s: no es un objeto" % prefijo)
            continue
        for campo in OBLIGATORIOS:
            if not str(r.get(campo, "")).strip():
                errores.append("%s: falta '%s'" % (prefijo, campo))
        tipo = str(r.get("tipo_registro", ""))
        if tipo and tipo not in TIPOS:
            errores.append("%s: tipo_registro '%s' no es uno de %s" % (prefijo, tipo, ", ".join(TIPOS)))
        fecha = str(r.get("fecha_concesion", ""))
        if fecha:
            if not RE_FECHA.match(fecha):
                errores.append("%s: fecha_concesion '%s' no es AAAA-MM-DD" % (prefijo, fecha))
            else:
                try:
                    d = date.fromisoformat(fecha)
                    if d > date.today():
                        errores.append("%s: fecha_concesion %s esta en el futuro" % (prefijo, fecha))
                except ValueError:
                    errores.append("%s: fecha_concesion '%s' no es una fecha real" % (prefijo, fecha))
        numero = str(r.get("numero", "")).strip()
        if numero:
            if numero in numeros:
                errores.append("%s: numero '%s' duplicado (ya en registros[%d])" % (prefijo, numero, numeros[numero]))
            else:
                numeros[numero] = i
        elemento = str(r.get("elemento", "")).strip()
        if elemento and conocidos is not None and elemento not in conocidos:
            errores.append("%s: elemento '%s' no existe en copyright.json (%s)" % (
                prefijo, elemento, ", ".join(sorted(conocidos)) or "vacio"))
    return errores


def sin_registrar(datos, conocidos):
    """Elementos de copyright.json que todavia no tienen registro formal (informativo)."""
    if conocidos is None:
        return []
    con = {str(r.get("elemento", "")) for r in datos.get("registros", []) if isinstance(r, dict)}
    return sorted(conocidos - con)


def agregar(datos, registro):
    datos.setdefault("registros", []).append(registro)
    return datos


def guardar(datos, raiz=PROJECT_ROOT):
    """Escribe con el mismo encoding/EOL que el archivo existente."""
    ruta = os.path.join(raiz, os.path.relpath(REGISTROS_JSON, PROJECT_ROOT))
    salto = "\n"
    if os.path.isfile(ruta):
        with open(ruta, "rb") as fh:
            crudo = fh.read()
        salto = "\r\n" if crudo.count(b"\r\n") > (crudo.count(b"\n") - crudo.count(b"\r\n")) else "\n"
    texto = json.dumps(datos, ensure_ascii=False, indent=2) + "\n"
    if salto == "\r\n":
        texto = texto.replace("\n", "\r\n")
    with open(ruta, "wb") as fh:
        fh.write(texto.encode("utf-8"))


def main(argv=None):
    ap = argparse.ArgumentParser(description="Base de registros de copyright (M127 L139)")
    ap.add_argument("--raiz", default=PROJECT_ROOT)
    ap.add_argument("--validar", action="store_true")
    ap.add_argument("--listar", action="store_true")
    ap.add_argument("--agregar", action="store_true")
    ap.add_argument("--elemento")
    ap.add_argument("--tipo", choices=TIPOS)
    ap.add_argument("--numero")
    ap.add_argument("--fecha")
    ap.add_argument("--certificado")
    ap.add_argument("--notas", default="")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args(argv)

    datos, error = cargar(args.raiz)
    if datos is None:
        print("[FALLO] " + error)
        return 1
    conocidos = elementos_conocidos(args.raiz)

    if args.agregar:
        faltan = [n for n, v in (("--elemento", args.elemento), ("--tipo", args.tipo),
                                 ("--numero", args.numero), ("--fecha", args.fecha),
                                 ("--certificado", args.certificado)) if not v]
        if faltan:
            print("[FALLO] --agregar necesita: %s" % ", ".join(faltan))
            return 1
        registro = {"elemento": args.elemento, "tipo_registro": args.tipo, "numero": args.numero,
                    "fecha_concesion": args.fecha, "certificado": args.certificado}
        if args.notas:
            registro["notas"] = args.notas
        candidato = json.loads(json.dumps(datos))
        agregar(candidato, registro)
        errores = validar(candidato, conocidos)
        if errores:
            print("[FALLO] el registro no cumple el contrato; NO se guardo:")
            for e in errores:
                print("   " + e)
            return 1
        guardar(candidato, args.raiz)
        print("[OK] registro agregado: %s (%s, %s)" % (registro["numero"], registro["tipo_registro"], registro["fecha_concesion"]))
        datos = candidato

    errores = validar(datos, conocidos)
    pendientes = sin_registrar(datos, conocidos)

    if args.json:
        print(json.dumps({"registros": datos.get("registros", []), "errores": errores,
                          "sin_registrar": pendientes, "tipos": list(TIPOS)}, ensure_ascii=False, indent=2))
    else:
        print("=== registros_db (M127 / L139) ===")
        print("registros formales : %d" % len(datos.get("registros", [])))
        print("tipos admitidos    : %s" % ", ".join(TIPOS))
        if args.listar or args.validar or args.check or not datos.get("registros"):
            for r in datos.get("registros", []):
                print("   %-16s %-18s %s  (%s)" % (r.get("numero", "?"), r.get("tipo_registro", "?"),
                                                   r.get("fecha_concesion", "?"), r.get("elemento", "?")))
        if pendientes:
            print("\n-- elementos sin registro formal (%d, informativo) --" % len(pendientes))
            print("   " + ", ".join(pendientes))
        if errores:
            print("\n-- errores de contrato (%d) --" % len(errores))
            for e in errores:
                print("   " + e)
        print("\n=== Resumen: %d error(es) ===" % len(errores))

    if args.check and errores:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
