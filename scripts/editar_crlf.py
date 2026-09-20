#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""editar_crlf.py — edita texto SIN poder romperle el EOL (P-19).

Por que existe
--------------
Defecto M-03 del coordinador: `CHECKLIST-GLOBAL.md` tenia **211 CRLF + 10 LF**
mezclados y los destruyo **dos veces en una sola sesion**, aunque conocia el
patron correcto (`newline=''` al leer + `'wb'` al escribir). La disciplina no
puede depender de que el agente se acuerde de la regla: el error tiene que ser
**imposible**. Mismo espiritu que el test `fe2d80a` (BUG-075).

Imposible por construccion
--------------------------
Lee **bytes** y escribe **bytes**. Nunca usa universal newlines
(`splitlines()`, `read_text()`, `open(..., 'r')` sin `newline=''`), que es lo
que convierte CRLF -> LF en silencio. El texto, cuando hace falta, se obtiene
con `b.decode('utf-8')`, que **no traduce terminadores**.

Verificado por medicion (no por confianza)
------------------------------------------
Antes de escribir se **vuelve a medir** la firma de EOL del resultado y se
comparan los **tipos de terminador presentes**:

    tipos(EOL) = { CRLF si hay alguno, LF-sueltos si hay alguno, CR-sueltos si hay alguno }

Si el conjunto cambia (p. ej. `{CRLF, LF}` -> `{LF}`), **NO se escribe nada** y
sale exit 1. Asi:
  - un archivo CRLF puro no puede volverse LF puro (el caso M-03);
  - un archivo LF puro no puede ganar un CRLF;
  - un archivo **mixto** (211 CRLF + 10 LF) sigue mixto, con sus 2 tipos.

La normalizacion se aplica **solo al fragmento que agregas**, nunca al documento
entero. Ese era el bug de la primera version: `--reemplazar "a" "A"` en un
archivo mixto se bloqueaba a si mismo porque normalizaba todo el texto y
aplanaba el LF suelto (falso positivo, medido).

Limite declarado (honestidad): la regla de tipos detecta **conversion**, no
"aritmetica" (p. ej. que 200 de 211 CRLF se vuelvan LF y queden 11 CRLF: el
conjunto seguiria siendo `{CRLF, LF}`). Para eso esta `--ver`, que imprime los
conteos; y el helper nunca puede causarlo el mismo, porque no decodifica con
universal newlines.

Codigos de salida
-----------------
  0 -> escrito
  1 -> el guardian bloqueo (NO se escribio NADA; el archivo queda intacto)
  2 -> uso incorrecto
  3 -> DETECTOR CIEGO: no existe, esta en 0 bytes o es un directorio

Uso como biblioteca
-------------------
    from editar_crlf import editar, editar_anexando, editar_reemplazando, \
                             editar_insertando_despues, editar_bytes, normalizar_eol

    editar("ruta.md", lambda t: t.replace("viejo", "nuevo"))   # estricto, sin normalizar
    editar_anexando("ruta.md", "\\n\\nseccion nueva\\n")         # normaliza el fragmento
    editar_reemplazando("ruta.md", "viejo", "nuevo")
    editar_insertando_despues("ruta.md", "ANCLA", "\\ntexto nuevo")
    editar_bytes("ruta.md", lambda b: b.replace(b"viejo", b"nuevo"))

Las tres funciones `editar_*` normalizan los `\\n` del **fragmento** al EOL del
archivo (`eol="auto"` por defecto = el dominante). `editar()` no normaliza nada:
si le devolves un texto con otro EOL, el guardian lo bloquea — que es lo que
queres cuando controlas la edicion.

Uso por CLI
-----------
    python scripts/editar_crlf.py RUTA --ver
    python scripts/editar_crlf.py RUTA --reemplazar VIEJO NUEVO
    python scripts/editar_crlf.py RUTA --insertar-despues ANCLA TEXTO
    python scripts/editar_crlf.py RUTA --anexar TEXTO
    python scripts/editar_crlf.py RUTA --anexar-archivo OTRO.md
    python scripts/editar_crlf.py --selftest
"""

import argparse
import sys
from pathlib import Path

EXIT_OK = 0
EXIT_BLOQUEADO = 1
EXIT_USO = 2
EXIT_CIEGO = 3

BOM = b"\xef\xbb\xbf"
NOMBRES = ("CRLF", "LF-suelto", "CR-suelto")


class EdicionBloqueada(Exception):
    """El guardian no dejo escribir. El archivo queda INTACTO."""


class DetectorCiego(Exception):
    """No se puede razonar sobre el archivo: ausente, 0 bytes o directorio."""


# --------------------------------------------------------------------------
# medicion
# --------------------------------------------------------------------------
def firma_eol(b: bytes):
    """(n CRLF, n LF sueltos, n CR sueltos). Exacto, no aproximado."""
    crlf = b.count(b"\r\n")
    resto = b.replace(b"\r\n", b"")
    return (crlf, resto.count(b"\n"), resto.count(b"\r"))


def tipos_eol(b: bytes):
    """Conjunto de tipos de terminador presentes. Es lo que NO puede cambiar."""
    return frozenset(n for n, v in zip(NOMBRES, firma_eol(b)) if v > 0)


def eol_dominante(b: bytes) -> str:
    """El terminador del archivo: CRLF si es mayoritariamente CRLF, si no LF/CR."""
    crlf, lf, cr = firma_eol(b)
    if crlf and crlf >= lf:
        return "\r\n"
    if lf:
        return "\n"
    if cr:
        return "\r"
    return "\n"


def describir(b: bytes) -> str:
    crlf, lf, cr = firma_eol(b)
    extra = ""
    if b.count(b"\x00"):
        extra += ", NUL=%d" % b.count(b"\x00")
    if b[:3] == BOM:
        extra += ", BOM"
    return "CRLF=%d LF=%d CR=%d%s" % (crlf, lf, cr, extra)


def normalizar_eol(texto: str, eol: str) -> str:
    """Lleva TODOS los terminadores del texto a `eol`, sin duplicar CR."""
    sin_crlf = texto.replace("\r\n", "\n").replace("\r", "\n")
    return sin_crlf if eol == "\n" else sin_crlf.replace("\n", eol)


# --------------------------------------------------------------------------
# lectura (con el guardian de ceguera)
# --------------------------------------------------------------------------
def _leer(ruta):
    p = Path(ruta)
    if p.is_dir():
        raise DetectorCiego("es un directorio, no un archivo: %s" % ruta)
    if not p.is_file():
        raise DetectorCiego("no existe: %s" % ruta)
    b = p.read_bytes()
    if len(b) == 0:
        raise DetectorCiego(
            "esta en 0 bytes: %s (restaurar byte-exacto de HEAD antes de editarlo)" % ruta
        )
    return p, b


def _unico(texto, aguja):
    n = texto.count(aguja)
    if n == 0:
        raise EdicionBloqueada("el ancla no aparece en el archivo: %r" % aguja[:60])
    if n > 1:
        raise EdicionBloqueada(
            "el ancla aparece %d veces (debe ser 1): %r -> usa mas contexto" % (n, aguja[:60])
        )


def _destino_eol(b: bytes, eol):
    return eol_dominante(b) if eol == "auto" else eol


# --------------------------------------------------------------------------
# el guardian
# --------------------------------------------------------------------------
def _guardar(p: Path, original: bytes, nuevo) -> int:
    """Verifica los 6 invariantes y escribe. Devuelve el delta de bytes."""
    if not isinstance(nuevo, (bytes, bytearray)):
        raise EdicionBloqueada("la edicion no devolvio bytes, devolvio %s" % type(nuevo).__name__)
    nuevo = bytes(nuevo)

    if len(nuevo) == 0:
        raise EdicionBloqueada("el resultado queda en 0 bytes: se descarta")
    if nuevo == original:
        raise EdicionBloqueada("la edicion no cambio nada (no-op): no se escribe")

    t0, t1 = tipos_eol(original), tipos_eol(nuevo)
    if t0 != t1:
        raise EdicionBloqueada(
            "CAMBIO EL EOL: tipos %s -> %s  |  %s -> %s. NO se escribio nada. "
            "Si normalizaste el documento entero en vez del fragmento, eso es el bug: "
            "usa normalizar_eol() SOLO sobre el texto que agregas."
            % (sorted(t0) or ["(ninguno)"], sorted(t1) or ["(ninguno)"],
               describir(original), describir(nuevo))
        )

    if (nuevo[:3] == BOM) != (original[:3] == BOM):
        raise EdicionBloqueada("el BOM aparecio o desaparecio")

    n0, n1 = original.count(b"\x00"), nuevo.count(b"\x00")
    if n0 != n1:
        raise EdicionBloqueada("cambio la cantidad de bytes NUL: %d -> %d" % (n0, n1))

    try:
        nuevo.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise EdicionBloqueada("el resultado no es UTF-8 valido: %s" % exc)

    p.write_bytes(nuevo)
    return len(nuevo) - len(original)


# --------------------------------------------------------------------------
# API
# --------------------------------------------------------------------------
def editar(ruta, fn, *, encoding="utf-8"):
    """Edita `ruta` con `fn(texto) -> texto`. ESTRICTO: no normaliza nada.

    Si `fn` devuelve un texto con otro EOL que el archivo, el guardian bloquea.
    """
    p, b = _leer(ruta)
    nuevo_texto = fn(b.decode(encoding))
    if not isinstance(nuevo_texto, str):
        raise EdicionBloqueada("fn debe devolver str, devolvio %s" % type(nuevo_texto).__name__)
    return _guardar(p, b, nuevo_texto.encode(encoding))


def editar_bytes(ruta, fn):
    """Edita `ruta` con `fn(bytes) -> bytes`. Sin decodificar: EOL intacto por construccion."""
    p, b = _leer(ruta)
    return _guardar(p, b, fn(b))


def editar_anexando(ruta, fragmento, *, eol="auto", encoding="utf-8"):
    """Anexa `fragmento` al final, normalizando SUS terminadores al EOL del archivo."""
    p, b = _leer(ruta)
    frag = normalizar_eol(fragmento, _destino_eol(b, eol))
    return _guardar(p, b, b + frag.encode(encoding))


def editar_insertando_despues(ruta, ancla, fragmento, *, eol="auto", encoding="utf-8"):
    """Inserta `fragmento` justo despues de `ancla` (que debe ser unica)."""
    p, b = _leer(ruta)
    texto = b.decode(encoding)
    _unico(texto, ancla)
    frag = normalizar_eol(fragmento, _destino_eol(b, eol))
    return _guardar(p, b, texto.replace(ancla, ancla + frag, 1).encode(encoding))


def editar_reemplazando(ruta, viejo, nuevo, *, eol="auto", encoding="utf-8"):
    """Reemplaza `viejo` (unica) por `nuevo`, normalizando el EOL de `nuevo`."""
    p, b = _leer(ruta)
    texto = b.decode(encoding)
    _unico(texto, viejo)
    frag = normalizar_eol(nuevo, _destino_eol(b, eol))
    return _guardar(p, b, texto.replace(viejo, frag, 1).encode(encoding))


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------
def cmd_ver(ruta):
    p, b = _leer(ruta)
    print("%s" % p)
    print("  %s" % describir(b))
    print("  tipos de EOL: %s" % (sorted(tipos_eol(b)) or ["(ninguno)"]))
    print("  EOL dominante: %r" % eol_dominante(b))
    print("  bytes: %d" % len(b))
    return EXIT_OK


def _informar(ruta, delta):
    b = Path(ruta).read_bytes()
    print("OK %s  (%+d bytes)  ->  %s" % (ruta, delta, describir(b)))
    return EXIT_OK


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Edita texto preservando el EOL (guard anti-M-03).",
        epilog="Nunca usa universal newlines: lee bytes y escribe bytes.",
    )
    ap.add_argument("ruta", nargs="?", help="archivo a editar")
    ap.add_argument("--ver", action="store_true", help="solo mide e imprime la firma de EOL")
    ap.add_argument("--reemplazar", nargs=2, metavar=("VIEJO", "NUEVO"),
                    help="reemplaza VIEJO por NUEVO (VIEJO debe aparecer 1 sola vez)")
    ap.add_argument("--insertar-despues", nargs=2, metavar=("ANCLA", "TEXTO"),
                    help="inserta TEXTO justo despues de ANCLA (ANCLA debe ser unica)")
    ap.add_argument("--anexar", metavar="TEXTO", help="anexa TEXTO al final")
    ap.add_argument("--anexar-archivo", metavar="RUTA", help="anexa el contenido de RUTA")
    ap.add_argument("--eol", choices=("auto", "crlf", "lf"), default="auto",
                    help="EOL para el texto insertado (por defecto: el dominante del archivo)")
    ap.add_argument("--selftest", action="store_true", help="corre los fixtures y sale")
    args = ap.parse_args(argv)

    if args.selftest:
        return selftest()
    if not args.ruta:
        ap.error("falta RUTA (o usa --selftest)")

    eol = {"auto": "auto", "crlf": "\r\n", "lf": "\n"}[args.eol]
    ops = [bool(args.ver), bool(args.reemplazar), bool(args.insertar_despues),
           bool(args.anexar), bool(args.anexar_archivo)]
    if sum(ops) != 1:
        ap.error("elegi exactamente UNA operacion (--ver / --reemplazar / --insertar-despues / "
                 "--anexar / --anexar-archivo)")

    try:
        if args.ver:
            return cmd_ver(args.ruta)
        if args.reemplazar:
            return _informar(args.ruta, editar_reemplazando(
                args.ruta, args.reemplazar[0], args.reemplazar[1], eol=eol))
        if args.insertar_despues:
            return _informar(args.ruta, editar_insertando_despues(
                args.ruta, args.insertar_despues[0], args.insertar_despues[1], eol=eol))
        if args.anexar:
            return _informar(args.ruta, editar_anexando(args.ruta, args.anexar, eol=eol))
        fragmento = Path(args.anexar_archivo).read_text(encoding="utf-8")
        return _informar(args.ruta, editar_anexando(args.ruta, fragmento, eol=eol))
    except DetectorCiego as exc:
        print("=" * 62)
        print("DETECTOR CIEGO (exit 3): %s" % exc)
        print("   Sin archivo legible no se puede afirmar nada sobre su EOL.")
        print("=" * 62)
        return EXIT_CIEGO
    except EdicionBloqueada as exc:
        print("=" * 62)
        print("BLOQUEADO (exit 1) — el archivo NO se toco.")
        print("   %s" % exc)
        print("=" * 62)
        return EXIT_BLOQUEADO
    except UnicodeDecodeError as exc:
        print("BLOQUEADO (exit 1): el archivo no es UTF-8 valido: %s" % exc)
        return EXIT_BLOQUEADO


# --------------------------------------------------------------------------
# selftest — probar el guardian EN ROJO antes de confiar en el
# --------------------------------------------------------------------------
def _caso(nombre, contenido, accion, espera):
    """espera: 'ok' | 'bloqueado' | 'ciego'. Devuelve 0 si acierta, 1 si no.

    `accion(ruta)` es la llamada real (las funciones de API o el CLI).
    Si bloquea, ADEMAS se verifica que el archivo quedo byte-identico.
    """
    import tempfile

    with tempfile.TemporaryDirectory() as tmp:
        ruta = Path(tmp) / "caso.md"
        if contenido is not None:
            ruta.write_bytes(contenido)
        try:
            accion(ruta)
            obtenido = "ok"
        except DetectorCiego:
            obtenido = "ciego"
        except EdicionBloqueada:
            obtenido = "bloqueado"

        detalle = ""
        if contenido is not None and obtenido != "ok":
            if ruta.read_bytes() != contenido:
                print("  FALLO %-52s -> !!! el archivo SE MODIFICO pese al bloqueo" % nombre)
                return 1
            detalle = " (archivo intacto)"

        if obtenido == espera:
            print("  OK   %-52s -> %s%s" % (nombre, obtenido, detalle))
            return 0
        print("  FALLO %-52s -> esperaba %s, obtuvo %s" % (nombre, espera, obtenido))
        return 1


def selftest():
    print("=" * 62)
    print("SELFTEST — editar_crlf.py (el guardian se prueba EN ROJO)")
    print("=" * 62)
    print()

    CRLF = b"a\r\nb\r\nc\r\n"
    MIXTO = b"a\r\nb\nc\r\n"
    LF = b"a\nb\nc\n"
    CERO = b""
    fallos = 0

    print("1) conversion de EOL -> DEBE bloquear (es el defecto M-03)")
    fallos += _caso("CRLF puro + anexar con \\n sin normalizar",
                    CRLF, lambda r: editar(r, lambda t: t + "d\n"), "bloqueado")
    fallos += _caso("CRLF puro + splitlines/join (el patron que rompe)",
                    CRLF, lambda r: editar(r, lambda t: "\n".join(t.splitlines()) + "\n"),
                    "bloqueado")
    fallos += _caso("LF puro + anexar con \\r\\n (ganaria un CRLF)",
                    LF, lambda r: editar(r, lambda t: t + "d\r\n"), "bloqueado")
    fallos += _caso("CRLF puro + --eol lf forzado por CLI",
                    CRLF, lambda r: editar_anexando(r, "d\n", eol="\n"), "bloqueado")

    print()
    print("2) edicion legitima -> DEBE pasar y PRESERVAR el EOL")
    fallos += _caso("CRLF puro + anexar normalizado (auto)", CRLF,
                    lambda r: editar_anexando(r, "d\n"), "ok")
    fallos += _caso("LF puro + anexar normalizado (auto)", LF,
                    lambda r: editar_anexando(r, "d\n"), "ok")
    fallos += _caso("MIXTO + reemplazo sin newlines (NO debe bloquear)",
                    MIXTO, lambda r: editar_reemplazando(r, "b", "B"), "ok")
    fallos += _caso("MIXTO + insertar normalizado al dominante", MIXTO,
                    lambda r: editar_insertando_despues(r, "a\r\n", "x\n"), "ok")
    fallos += _caso("LF puro + editar_bytes (sin decodificar)", LF,
                    lambda r: editar_bytes(r, lambda b: b + b"d\n"), "ok")

    print()
    print("3) el guardian no debe dejar pasar estas otras formas de romper")
    fallos += _caso("no-op (no cambia nada)", LF, lambda r: editar(r, lambda t: t), "bloqueado")
    fallos += _caso("resultado vacio (borraria el archivo)", LF,
                    lambda r: editar(r, lambda t: ""), "bloqueado")
    fallos += _caso("devolver bytes en vez de str", LF,
                    lambda r: editar(r, lambda t: b"x"), "bloqueado")
    fallos += _caso("ancla que aparece 2 veces", b"a\r\nb\r\na\r\n",
                    lambda r: editar_reemplazando(r, "a", "A"), "bloqueado")
    fallos += _caso("ancla inexistente", LF,
                    lambda r: editar_reemplazando(r, "zzz", "A"), "bloqueado")

    print()
    print("4) detector ciego -> DEBE salir 3, no 1")
    fallos += _caso("archivo en 0 bytes", CERO, lambda r: editar_anexando(r, "x"), "ciego")
    fallos += _caso("archivo inexistente", None, lambda r: editar_anexando(r, "x"), "ciego")

    print()
    print("=" * 62)
    if fallos:
        print("SELFTEST FALLIDO: %d caso(s) mal." % fallos)
        return 1
    print("SELFTEST OK: 16/16 casos.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
