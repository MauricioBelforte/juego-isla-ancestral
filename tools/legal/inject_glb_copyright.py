#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.

# M127 - Injector de `asset.copyright` en .glb/.gltf (cierre del trinquete
# de validate_asset_metadata.py, item L112).
#
# POR QUE EXISTE: el baseline de tools/legal/asset_metadata_scope.json es un
# TRINQUETE por conteo: 418 .glb exportados desde Blender salen con
# asset.generator pero SIN asset.copyright. Cada .glb nuevo sin copyright
# hace fallar `validate_asset_metadata.py --check` (y con el, el job
# legal-tools de CI). Este script escribe la atribucion que el formato YA
# soporta (glTF 2.0: asset.copyright), en vez de subir el techo.
#
# NO reemplaza el arreglo de fondo: el pipeline de exportacion (M166/M09)
# deberia emitir asset.copyright desde Blender. Mientras tanto, este script
# deja el artefacto distribuible con la evidencia de autoria embebida.
#
# Uso:
#   python tools/legal/inject_glb_copyright.py            # dry-run (lista)
#   python tools/legal/inject_glb_copyright.py --aplicar  # escribe
#   python tools/legal/inject_glb_copyright.py --autotest # prueba sintetica
#
# Exit 0 OK, 1 si algo falla.

import argparse
import json
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
SCOPE_JSON = os.path.join(HERE, "asset_metadata_scope.json")

COPYRIGHT = "Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados."
LICENCIA = "LicenseRef-Propietaria"

CHUNK_JSON = 0x4E4F534A  # 'JSON'
GLB_MAGIC = b"glTF"


def _leer(ruta):
    with open(ruta, "rb") as f:
        return f.read()


def _chunks(b):
    """Devuelve (version, [(tipo, datos), ...]) validando cabecera y longitudes."""
    if len(b) < 12 or b[:4] != GLB_MAGIC:
        raise ValueError("no es un .glb (magic distinto de 'glTF')")
    version, largo = struct.unpack_from("<II", b, 4)
    if largo != len(b):
        raise ValueError("cabecera declara %d bytes y el archivo tiene %d" % (largo, len(b)))
    out = []
    off = 12
    while off < largo:
        if off + 8 > largo:
            raise ValueError("chunk truncado en offset %d" % off)
        clen, ctype = struct.unpack_from("<II", b, off)
        fin = off + 8 + clen
        if fin > largo:
            raise ValueError("chunk en offset %d se pasa del archivo" % off)
        out.append((ctype, b[off + 8:fin]))
        off = fin
    if not out or out[0][0] != CHUNK_JSON:
        raise ValueError("el primer chunk no es JSON")
    return version, out


def _json_de(data):
    txt = data.decode("utf-8").rstrip("\x00 ")
    return json.loads(txt)


def aplicar(ruta, dry_run=True):
    """Escribe asset.copyright en el chunk JSON. Devuelve el dict cambiado o None
    si el archivo ya lo tenia."""
    b = _leer(ruta)
    version, chunks = _chunks(b)
    js = _json_de(chunks[0][1])
    asset = js.setdefault("asset", {})
    if asset.get("copyright"):
        return None
    antes = dict(asset)
    asset["copyright"] = COPYRIGHT
    extras = asset.setdefault("extras", {})
    if isinstance(extras, dict):
        extras.setdefault("licencia", LICENCIA)
    nuevo = json.dumps(js, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    relleno = (4 - len(nuevo) % 4) % 4
    nuevo += b" " * relleno
    if dry_run:
        return {"ruta": ruta, "antes": antes, "copyright": asset["copyright"]}
    out = bytearray(GLB_MAGIC)
    out += struct.pack("<II", version, 0)
    out += struct.pack("<II", len(nuevo), CHUNK_JSON) + nuevo
    for ctype, data in chunks[1:]:
        out += struct.pack("<II", len(data), ctype) + data
    struct.pack_into("<I", out, 8, len(out))
    tmp = ruta + ".tmp"
    with open(tmp, "wb") as f:
        f.write(bytes(out))
    os.replace(tmp, ruta)
    return {"ruta": ruta, "antes": antes, "copyright": asset["copyright"]}


def candidatos(raiz):
    rutas = ["game/isla-ancestral/assets"]
    base = os.path.join(raiz, rutas[0])
    if not os.path.isdir(base):
        return []
    out = []
    for d, _, fs in os.walk(base):
        for f in fs:
            if f.lower().endswith(".glb"):
                out.append(os.path.join(d, f))
    return sorted(out)


def autotest():
    import tempfile
    js = {"asset": {"version": "2.0", "generator": "Blender 4.4"}, "scenes": []}
    raw = json.dumps(js).encode("utf-8")
    raw += b" " * ((4 - len(raw) % 4) % 4)
    bin_data = b"\x00" * 8
    g = bytearray(GLB_MAGIC)
    g += struct.pack("<II", 2, 0)
    g += struct.pack("<II", len(raw), CHUNK_JSON) + raw
    g += struct.pack("<II", len(bin_data), 0x004E4942) + bin_data
    struct.pack_into("<I", g, 8, len(g))
    fallos = 0
    fd, tmp = tempfile.mkstemp(suffix=".glb")
    os.close(fd)
    try:
        with open(tmp, "wb") as f:
            f.write(bytes(g))
        r = aplicar(tmp)
        if not r or r["copyright"] != COPYRIGHT:
            print("[FAIL] dry-run no detecto el .glb sin copyright"); fallos += 1
        else:
            print("[OK] dry-run detecta el archivo sin asset.copyright")
        aplicar(tmp, dry_run=False)
        v, ch = _chunks(_leer(tmp))
        js2 = _json_de(ch[0][1])
        if js2["asset"].get("copyright") != COPYRIGHT:
            print("[FAIL] tras aplicar, asset.copyright no esta"); fallos += 1
        else:
            print("[OK] tras aplicar, asset.copyright esta y el JSON parsea")
        if len(ch) != 2 or ch[1][1] != bin_data:
            print("[FAIL] el chunk BIN no sobrevivio intacto"); fallos += 1
        else:
            print("[OK] el chunk BIN sobrevive byte a byte")
        if aplicar(tmp) is not None:
            print("[FAIL] no es idempotente"); fallos += 1
        else:
            print("[OK] idempotente (no re-inyecta)")
        if js2["asset"].get("generator") != "Blender 4.4":
            print("[FAIL] piso el generator original"); fallos += 1
        else:
            print("[OK] no toca asset.generator")
    finally:
        if os.path.exists(tmp):
            os.remove(tmp)
    print("=== autotest: %d fallos ===" % fallos)
    return 1 if fallos else 0


def main(argv=None):
    ap = argparse.ArgumentParser(description="Inyecta asset.copyright en .glb (M127/L112)")
    ap.add_argument("--raiz", default=PROJECT_ROOT)
    ap.add_argument("--aplicar", action="store_true", help="escribe los cambios (sin esto, dry-run)")
    ap.add_argument("--autotest", action="store_true", help="prueba sintetica del inyector")
    ap.add_argument("--solo-json", default=None,
                    help="informe --json de validate_asset_metadata.py: inyecta SOLO sus hallazgos_nuevos")
    args = ap.parse_args(argv)
    if args.autotest:
        return autotest()
    rutas = candidatos(args.raiz)
    if args.solo_json:
        with open(args.solo_json, "r", encoding="utf-8-sig") as f:
            informe = json.load(f)
        objetivo = set(informe.get("hallazgos_nuevos", []))
        rutas = [r for r in rutas if os.path.relpath(r, args.raiz).replace("\\", "/") in objetivo]
        print("filtrado por hallazgos_nuevos: %d" % len(rutas))
    print("=== inject_glb_copyright (%s) ===" % ("APLICAR" if args.aplicar else "dry-run"))
    print(".glb encontrados: %d" % len(rutas))
    tocados = 0
    fallos = []
    for r in rutas:
        try:
            res = aplicar(r, dry_run=not args.aplicar)
        except Exception as e:
            fallos.append("%s: %s" % (os.path.relpath(r, args.raiz), e))
            continue
        if res:
            tocados += 1
            if tocados <= 5:
                print("   %s" % os.path.relpath(r, args.raiz))
    print("%s: %d" % ("inyectados" if args.aplicar else "a inyectar", tocados))
    if fallos:
        print("-- FALLOS (%d) --" % len(fallos))
        for f in fallos[:20]:
            print("   " + f)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
