#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.

# M127 iter. 3 - Suite de tools/legal/validate_asset_metadata.py.
#
# Los fixtures se CONSTRUYEN byte a byte (PNG con chunk tEXt, GLB con chunk JSON,
# OGG con comentario Vorbis). No se usan assets reales del repo: un test que
# depende del arbol de trabajo falla cuando otro agente mueve un archivo, y este
# validador se ejecuta en CI.
#
# Guardas contra falso verde (trampa 11 / 63 del skill):
#   - cada bloque se registra con _fin("X") y _resumen() nombra los que faltaron;
#   - CHECKS_MINIMOS: cualquier aborto baja el numero de checks y eso FALLA.
# Se prueba por inyeccion en test_infraestructura(): si se rompe el conteo, el
# piso lo detecta.

import io
import os
import sys
import json
import struct
import shutil
import tempfile
import contextlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import validate_asset_metadata as V  # noqa: E402

MODULO = "M127 validate_asset_metadata"
CHECKS_MINIMOS = 24

_checks = 0
_fallos = 0
_vistos = {}
BLOQUES = ["formato", "atribucion", "escaneo", "inventarios", "scope", "baseline", "inyeccion"]


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
            print("  [FALLO] bloque '%s' NO se ejecuto (posible SCRIPT ERROR / aborto)" % n)
            globals()["_fallos"] += 1
            globals()["_checks"] += 1
    if _checks < CHECKS_MINIMOS:
        print("  [FALLO] solo %d checks ejecutados (minimo %d)" % (_checks, CHECKS_MINIMOS))
        globals()["_fallos"] += 1
        globals()["_checks"] += 1
    print("=== Resumen %s: %d checks, %d fallo(s) ===" % (MODULO, _checks, _fallos))
    return 1 if _fallos else 0


# ---------------------------------------------------------------- fixtures
def chunk_png(tipo, datos):
    return struct.pack(">I", len(datos)) + tipo + datos + b"\x00\x00\x00\x00"


def png(con_texto=None, con_itxt=None, relleno=0):
    """PNG minimo pero SIEMPRE >= TAMANO_MINIMO, para que el test de TRUNCADO
    no contamine los conteos de atribucion."""
    out = b"\x89PNG\r\n\x1a\n"
    out += chunk_png(b"IHDR", struct.pack(">IIBBBBB", 1, 1, 8, 6, 0, 0, 0))
    if con_texto:
        for k, v in con_texto.items():
            out += chunk_png(b"tEXt", k.encode() + b"\x00" + v.encode())
    if con_itxt:
        out += chunk_png(b"iTXt", con_itxt.encode() + b"\x00\x00\x00\x00\x00" + b"valor")
    # Relleno: un chunk tEXt inocuo, para superar el umbral de truncado.
    if relleno:
        out += chunk_png(b"tEXt", b"Comment\x00" + b"x" * relleno)
    out += chunk_png(b"IEND", b"")
    return out


def glb(asset):
    js = json.dumps({"asset": asset, "scenes": []}).encode()
    js += b" " * ((4 - len(js) % 4) % 4)
    cuerpo = struct.pack("<I4s", len(js), b"JSON") + js
    total = 12 + len(cuerpo)
    return b"glTF" + struct.pack("<II", 2, total) + cuerpo


def ogg(campos):
    """Bloque de comentario Vorbis REAL: \\x03vorbis + vendor + n + campos con
    prefijo de longitud uint32 LE. El validador lo parsea, no lo adivina."""
    vendor = b"Isla Ancestral"
    bloque = b"\x03vorbis"
    bloque += struct.pack("<I", len(vendor)) + vendor
    bloque += struct.pack("<I", len(campos))
    for k, v in campos.items():
        campo = k.encode() + b"=" + v.encode()
        bloque += struct.pack("<I", len(campo)) + campo
    return b"OggS" + b"\x00" * 20 + b"\x01\x1e" + bloque + b"\x00" * 32


def escribir(base, rel, datos):
    ruta = os.path.join(base, rel)
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    with open(ruta, "wb") as fh:
        fh.write(datos)
    return ruta


def fixture_scope(base, extensiones, rutas=("assets",), excluir=(), baseline=None):
    """Escribe un scope temporal y devuelve su ruta."""
    ruta = os.path.join(base, "_scope.json")
    scope = {"version": 1, "rutas": list(rutas), "extensiones": list(extensiones),
             "excluir": list(excluir)}
    if baseline is not None:
        scope["baseline"] = baseline
    with open(ruta, "w", encoding="utf-8") as fh:
        json.dump(scope, fh)
    return ruta


# ---------------------------------------------------------------- bloques
def test_formato(base):
    print("\n-- bloque formato --")
    # PNG valido
    ok, desc = V.magic_valido(".png", png())
    _check(ok is True and desc == "PNG", "PNG real -> magic valido")
    # .ttf que es HTML (caso real BUG-042)
    html = b"\n\n<!DOCTYPE html>\n<html><body>404</body></html>\n" * 4
    ok, desc = V.magic_valido(".ttf", html)
    _check(ok is False, "TTF con contenido HTML -> magic invalido")
    _check(V.detectar_contenido(html) == "HTML", "detectar_contenido reconoce HTML")
    # TTF real
    ok, _ = V.magic_valido(".ttf", b"\x00\x01\x00\x00" + b"\x00" * 64)
    _check(ok is True, "TTF real (00010000) -> magic valido")
    ok, _ = V.magic_valido(".otf", b"OTTO" + b"\x00" * 64)
    _check(ok is True, "OTF real (OTTO) -> magic valido")
    # WebP necesita DOS firmas
    ok, _ = V.magic_valido(".webp", b"RIFF" + b"\x00" * 4 + b"WEBP" + b"\x00" * 32)
    _check(ok is True, "WebP con RIFF+WEBP -> valido")
    ok, _ = V.magic_valido(".webp", b"RIFF" + b"\x00" * 4 + b"WAVE" + b"\x00" * 32)
    _check(ok is False, "RIFF/WAVE con extension .webp -> invalido")
    # Extension fuera de la tabla
    ok, desc = V.magic_valido(".xyz", b"loquesea")
    _check(ok is None, "extension desconocida -> None (no verificable)")
    # Deteccion de otros contenidos
    _check(V.detectar_contenido(b"<?xml version='1.0'?>") == "XML", "detectar_contenido reconoce XML")
    _check(V.detectar_contenido(b'{"a": 1}') == "JSON", "detectar_contenido reconoce JSON")
    _fin("formato")


def test_atribucion(base):
    print("\n-- bloque atribucion --")
    # PNG con Copyright
    b = png(con_texto={"Copyright": "Isla Ancestral Team"})
    tiene, claves = V.atribucion_embebida("x.png", ".png", b)
    _check(tiene is True, "PNG con tEXt Copyright -> atribucion presente")
    _check(claves.get("Copyright") == "Isla Ancestral Team", "lee el valor del chunk tEXt")
    # PNG con Author
    tiene, _ = V.atribucion_embebida("x.png", ".png", png(con_texto={"Author": "M. Belforte"}))
    _check(tiene is True, "PNG con tEXt Author -> atribucion presente")
    # PNG sin nada
    tiene, _ = V.atribucion_embebida("x.png", ".png", png())
    _check(tiene is False, "PNG sin chunks de autor -> atribucion ausente")
    # PNG con keyword irrelevante
    tiene, _ = V.atribucion_embebida("x.png", ".png", png(con_texto={"Software": "Aseprite"}))
    _check(tiene is False, "PNG solo con 'Software' -> atribucion ausente (no cualquier tEXt sirve)")

    # GLB con copyright
    tiene, extra = V.atribucion_embebida("x.glb", ".glb", glb({"version": "2.0", "copyright": "Isla Ancestral Team"}))
    _check(tiene is True, "GLB con asset.copyright -> atribucion presente")
    _check(extra["asset"]["copyright"] == "Isla Ancestral Team", "lee asset.copyright del chunk JSON")
    # GLB sin copyright (caso real: los 434 .glb del repo)
    tiene, _ = V.atribucion_embebida("x.glb", ".glb", glb({"version": "2.0", "generator": "Khronos glTF Blender I/O v4.2.83"}))
    _check(tiene is False, "GLB sin asset.copyright -> atribucion ausente")

    # OGG con COPYRIGHT=
    tiene, k = V.atribucion_embebida("x.ogg", ".ogg", ogg({"COPYRIGHT": "Isla Ancestral Team"}))
    _check(tiene is True and k.get("COPYRIGHT") == "Isla Ancestral Team", "OGG con COPYRIGHT= -> atribucion presente")
    # OGG sin nada
    tiene, _ = V.atribucion_embebida("x.ogg", ".ogg", ogg({}))
    _check(tiene is False, "OGG sin comentario de autor -> atribucion ausente")
    # Formato que NO soporta copyright embebido
    tiene, _ = V.atribucion_embebida("x.blend", ".blend", b"BLENDER-v400")
    _check(tiene is None, "extension sin soporte -> None (no se reporta)")

    # GLB corrupto no revienta
    tiene, _ = V.atribucion_embebida("x.glb", ".glb", b"glTF" + b"\x00" * 40)
    _check(tiene is False, "GLB truncado -> False, sin excepcion")
    _fin("atribucion")


def test_escaneo(base):
    print("\n-- bloque escaneo --")
    escribir(base, "assets/ok.png", png(con_texto={"Copyright": "Isla Ancestral Team"}, relleno=64))
    escribir(base, "assets/sin_atrib.png", png(relleno=64))
    escribir(base, "assets/placeholder.ttf", b"\n\n<!DOCTYPE html>\n<html>x</html>\n" * 6)
    escribir(base, "assets/fuente_real.ttf", b"\x00\x01\x00\x00" + b"\x00" * 200)
    escribir(base, "assets/corto.png", b"\x89PNG\r\n\x1a\n" + b"\x00" * 10)
    escribir(base, "assets/ignorado.txt", b"hola" * 40)

    scope = {"rutas": ["assets"], "extensiones": [".png", ".ttf"], "excluir": []}
    res = V.escanear(scope, base)
    por_ruta = {r["ruta"]: r for r in res}
    _check(len(res) == 5, "escanea 5 archivos del alcance (.txt queda fuera): %d" % len(res))
    _check(por_ruta["assets/ok.png"]["atribucion_ok"] is True, "ok.png -> atribucion OK")
    _check(por_ruta["assets/sin_atrib.png"]["atribucion_ok"] is False, "sin_atrib.png -> SIN_ATRIBUCION")
    _check(por_ruta["assets/placeholder.ttf"]["magic_ok"] is False, "placeholder.ttf -> MAGIC_INVALIDO")
    _check(any("MAGIC_INVALIDO" in h for h in por_ruta["assets/placeholder.ttf"]["hallazgos"]),
           "el hallazgo se rotula MAGIC_INVALIDO")
    _check(por_ruta["assets/fuente_real.ttf"]["magic_ok"] is True, "fuente_real.ttf -> magic OK")
    _check(por_ruta["assets/fuente_real.ttf"]["atribucion_ok"] is None, "fuente .ttf -> atribucion no aplicable")
    _check(any("TRUNCADO" in h for h in por_ruta["assets/corto.png"]["hallazgos"]), "archivo <64 B -> TRUNCADO")

    # Exclusion por directorio
    escribir(base, "assets/archive/viejo.png", png())
    scope_ex = {"rutas": ["assets"], "extensiones": [".png"], "excluir": ["archive"]}
    res2 = V.escanear(scope_ex, base)
    _check(all("archive" not in r["ruta"] for r in res2), "el directorio excluido no se escanea")
    _check(V.es_excluido("assets/archive/x.png", ["archive"]), "es_excluido por nombre de directorio")
    _check(not V.es_excluido("assets/otro/x.png", ["archive"]), "es_excluido no sobre-excluye")
    _fin("escaneo")


def test_inventarios(base):
    print("\n-- bloque inventarios --")
    escribir(base, "game/isla-ancestral/data/arte2d/inventario_2d.json", json.dumps(
        {"assets": [{"id": "ico_a", "familia": "herramientas"}, {"id": "ico_b"}]}).encode())
    escribir(base, "game/isla-ancestral/data/legal/modelos_3d.json", json.dumps(
        {"assets": [{"id": "m_a", "origen": "propio", "licencia": "propia"},
                    {"id": "m_b", "origen": "", "licencia": "CC0"}]}).encode())
    escribir(base, "game/isla-ancestral/data/legal/audio_licenses.json", json.dumps(
        {"tracks": [{"id": "t_a", "licencia": "propia"}]}).encode())

    entradas, probs = V.inventarios(base)
    _check(probs == [], "los 3 inventarios se leen sin problemas")
    _check(len(entradas) == 5, "recoge 5 entradas declaradas: %d" % len(entradas))
    faltas = V.auditar_inventarios(entradas)
    _check(any("ico_b" in f and "familia" in f for f in faltas), "detecta 'ico_b' sin familia")
    _check(any("m_b" in f and "origen" in f for f in faltas), "detecta 'm_b' sin origen")
    _check(not any("m_a" in f for f in faltas), "no marca la entrada completa (m_a)")
    _check(len(faltas) == 2, "exactamente 2 faltas de inventario: %d" % len(faltas))

    # Inventario ausente
    base2 = os.path.join(base, "_vacio")
    os.makedirs(base2, exist_ok=True)
    _, probs2 = V.inventarios(base2)
    _check(len(probs2) == 3 and all("FALTA_INVENTARIO" in p for p in probs2),
           "inventarios ausentes -> 3 FALTA_INVENTARIO")
    _fin("inventarios")


def test_scope(base):
    print("\n-- bloque scope --")
    # Sin scope -> fallo controlado
    original = V.SCOPE_JSON
    V.SCOPE_JSON = os.path.join(base, "no_existe.json")
    try:
        inf, probs = V.construir_informe(base)
        _check(inf is None and any("FALTA_SCOPE" in p for p in probs), "sin scope -> FALTA_SCOPE, no excepcion")
    finally:
        V.SCOPE_JSON = original

    # Scope ilegible
    roto = os.path.join(base, "roto.json")
    with open(roto, "w", encoding="utf-8") as fh:
        fh.write("{no json")
    V.SCOPE_JSON = roto
    try:
        inf, probs = V.construir_informe(base)
        _check(inf is None and any("SCOPE_ILEGIBLE" in p for p in probs), "scope ilegible -> SCOPE_ILEGIBLE")
    finally:
        V.SCOPE_JSON = original

    # Informe completo sobre el fixture
    V.SCOPE_JSON = fixture_scope(base, [".png", ".ttf"], excluir=("archive",))
    try:
        inf, probs = V.construir_informe(base)
        _check(probs == [], "construir_informe no reporta problemas de fuentes")
        _check(inf["archivos_en_alcance"] == 5, "5 archivos en alcance (archive/ excluido): %d" % inf["archivos_en_alcance"])
        _check(inf["magic_invalido"] == 1, "cuenta 1 placeholder: %d" % inf["magic_invalido"])
        _check(inf["sin_atribucion"] == 2, "cuenta 2 sin atribucion (sin_atrib + corto): %d" % inf["sin_atribucion"])
        _check(inf["con_atribucion"] == 1, "cuenta 1 con atribucion: %d" % inf["con_atribucion"])
        _check(inf["inventario_incompleto"] == 2, "cuenta 2 faltas de inventario: %d" % inf["inventario_incompleto"])
        # exit code (silenciado: main imprime el informe completo)
        with contextlib.redirect_stdout(io.StringIO()):
            rc = V.main(["--raiz", base, "--check"])
        _check(rc == 1, "main --check con hallazgos -> exit 1")
        # y con un arbol limpio (sin hallazgos) no debe fallar
        limpio = os.path.join(base, "_limpio")
        escribir(limpio, "assets/ok.png", png(con_texto={"Copyright": "Isla Ancestral Team"}, relleno=64))
        for rel, datos in (("game/isla-ancestral/data/arte2d/inventario_2d.json", {"assets": [{"id": "a", "familia": "f"}]}),
                           ("game/isla-ancestral/data/legal/modelos_3d.json", {"assets": [{"id": "b", "origen": "propio", "licencia": "propia"}]}),
                           ("game/isla-ancestral/data/legal/audio_licenses.json", {"tracks": [{"id": "c", "licencia": "propia"}]})):
            escribir(limpio, rel, json.dumps(datos).encode())
        V.SCOPE_JSON = fixture_scope(limpio, [".png"])
        with contextlib.redirect_stdout(io.StringIO()):
            rc0 = V.main(["--raiz", limpio, "--check"])
        _check(rc0 == 0, "main --check sin hallazgos -> exit 0")

        # --json debe emitir JSON PURO en stdout (pipeable). Regresion: el
        # resumen se imprimia en stdout y rompia json.load() con "Extra data".
        V.SCOPE_JSON = fixture_scope(base, [".png", ".ttf"], excluir=("archive",))
        buf_out, buf_err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(buf_out), contextlib.redirect_stderr(buf_err):
            V.main(["--raiz", base, "--json"])
        try:
            json.loads(buf_out.getvalue())
            puro = True
        except Exception:
            puro = False
        _check(puro, "--json emite JSON puro en stdout (sin 'Extra data')")
        _check("=== Resumen" in buf_err.getvalue(), "--json manda el resumen a stderr")
    finally:
        V.SCOPE_JSON = original
    _fin("scope")


def test_baseline(base):
    print("\n-- bloque baseline (techo de deuda) --")
    # Semantica globstar del patron. Regresion medida: con fnmatch,
    # '*/assets/*.ttf' NO matchea 'assets/x.ttf' (exige un prefijo de directorio),
    # y '**/assets/3d/*.glb' NO matchea 'assets/3d/alta/x.glb' (el '*' no cruza '/').
    _check(V.coincide_patron("assets/x.ttf", "**/assets/*.ttf"),
           "globstar: '**/' matchea cero directorios")
    _check(V.coincide_patron("game/isla-ancestral/assets/x.ttf", "**/assets/*.ttf"),
           "globstar: '**/' matchea varios directorios")
    _check(not V.coincide_patron("otro/x.ttf", "**/assets/*.ttf"),
           "globstar: no matchea una ruta fuera del alcance")
    _check(not V.coincide_patron("assets/sub/x.ttf", "**/assets/*.ttf"),
           "globstar: '*' simple NO cruza '/'")
    _check(V.coincide_patron("game/isla-ancestral/assets/3d/alta/x.glb", "**/assets/3d/**/*.glb"),
           "globstar: '**/' intermedio cubre subdirectorios del asset")
    _check(V.coincide_patron("game/isla-ancestral/assets/3d/x.glb", "**/assets/3d/**/*.glb"),
           "globstar: '**/' intermedio tambien matchea sin subdirectorio")

    original = V.SCOPE_JSON
    # Este bloque reusa los assets de test_escaneo, pero necesita inventarios
    # COMPLETOS: --check tambien cuenta inventario_incompleto, y test_inventarios
    # dejo a proposito 2 entradas incompletas. Se reescriben aqui para que el
    # exit code mida SOLO el efecto del techo.
    escribir(base, "game/isla-ancestral/data/arte2d/inventario_2d.json", json.dumps(
        {"assets": [{"id": "ico_a", "familia": "herramientas"}]}).encode())
    escribir(base, "game/isla-ancestral/data/legal/modelos_3d.json", json.dumps(
        {"assets": [{"id": "m_a", "origen": "propio", "licencia": "propia"}]}).encode())
    escribir(base, "game/isla-ancestral/data/legal/audio_licenses.json", json.dumps(
        {"tracks": [{"id": "t_a", "licencia": "propia"}]}).encode())
    # Fixture: 2 SIN_ATRIBUCION (sin_atrib.png, corto.png) + 1 MAGIC_INVALIDO
    # (placeholder.ttf), con archive/ fuera del alcance.
    comun = dict(excluir=("archive",))
    try:
        # 1) Techo que cubre todo -> --check exit 0
        baseline = [
            {"tipo": "MAGIC_INVALIDO", "patron": "**/assets/*.ttf", "max": 1, "motivo": "m1", "dueno": "d1"},
            {"tipo": "SIN_ATRIBUCION", "patron": "**/assets/*.png", "max": 2, "motivo": "m2", "dueno": "d2"},
        ]
        V.SCOPE_JSON = fixture_scope(base, [".png", ".ttf"], baseline=baseline, **comun)
        inf, _ = V.construir_informe(base)
        _check(inf["hallazgos_nuevos"] == [], "con el techo cubriendo todo no hay hallazgos nuevos")
        _check(len(inf["baseline"]) == 2, "el informe detalla los 2 techos")
        _check(inf["baseline"][1]["aceptados"] == 2, "el techo acepta los 2 SIN_ATRIBUCION: %d"
               % inf["baseline"][1]["aceptados"])
        with contextlib.redirect_stdout(io.StringIO()):
            rc = V.main(["--raiz", base, "--check"])
        _check(rc == 0, "con techo suficiente --check -> exit 0")
        with contextlib.redirect_stdout(io.StringIO()):
            rc_e = V.main(["--raiz", base, "--estricto"])
        _check(rc_e == 1, "--estricto sigue contando el techo como deuda")

        # 2) Techo DEMASIADO BAJO -> el exceso es hallazgo nuevo (trinquete)
        baseline_bajo = [{"tipo": "SIN_ATRIBUCION", "patron": "**/assets/*.png", "max": 1,
                          "motivo": "m", "dueno": "d"}]
        V.SCOPE_JSON = fixture_scope(base, [".png", ".ttf"], baseline=baseline_bajo, **comun)
        inf, _ = V.construir_informe(base)
        _check(len(inf["hallazgos_nuevos"]) == 2, "techo bajo -> 2 nuevos (1 png + 1 ttf): %d"
               % len(inf["hallazgos_nuevos"]))
        _check(inf["baseline"][0]["excedido"] is True, "el techo se marca EXCEDIDO")
        with contextlib.redirect_stdout(io.StringIO()):
            rc = V.main(["--raiz", base, "--check"])
        _check(rc == 1, "techo excedido -> --check exit 1 (el trinquete funciona)")

        # 3) Sin patron: acepta exactamente 1 objeto
        baseline_exacto = [{"tipo": "SIN_ATRIBUCION", "patron": "**/assets/corto.png",
                            "max": 1, "motivo": "m", "dueno": "d"}]
        V.SCOPE_JSON = fixture_scope(base, [".png", ".ttf"], baseline=baseline_exacto, **comun)
        inf, _ = V.construir_informe(base)
        _check("assets/corto.png" not in inf["hallazgos_nuevos"],
               "el patron exacto acepta ese archivo")
        _check("assets/sin_atrib.png" in inf["hallazgos_nuevos"],
               "y NO acepta los demas (no es un permiso global)")
    finally:
        V.SCOPE_JSON = original
    _fin("baseline")


def test_inyeccion(base):
    print("\n-- bloque inyeccion (el piso de checks esta vivo?) --")
    # El piso de checks debe detectar un conteo por debajo del minimo.
    # Se aisan los globales: _vistos se vacia para que los 6 bloques cuenten
    # como faltantes, y _checks arranca muy por debajo del piso.
    global _checks, _fallos, _vistos
    guardado = (_checks, _fallos, dict(_vistos))
    _checks, _fallos, _vistos = 3, 0, {}
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        rc = _resumen()
    salida = buf.getvalue()
    _checks, _fallos, _vistos = guardado[0], guardado[1], guardado[2]
    _check(rc == 1, "con 3 checks el piso FALLA y sale 1 (piso vivo)")
    _check("minimo %d" % CHECKS_MINIMOS in salida,
           "el resumen cita el piso (%d)" % CHECKS_MINIMOS)
    _check("bloque 'inyeccion' NO se ejecuto" in salida,
           "el resumen nombra los bloques que faltaron")
    _fin("inyeccion")


def main():
    base = tempfile.mkdtemp(prefix="m127_asset_meta_")
    try:
        test_formato(base)
        test_atribucion(base)
        test_escaneo(base)
        test_inventarios(base)
        test_scope(base)
        test_baseline(base)
        test_inyeccion(base)
    finally:
        shutil.rmtree(base, ignore_errors=True)
    return _resumen()


if __name__ == "__main__":
    sys.exit(main())
