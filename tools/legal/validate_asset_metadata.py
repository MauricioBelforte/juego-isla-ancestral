#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.

# M127 iter. 3 (item L112) - Validador de metadata de copyright embebida en
# assets EXPORTADOS (texturas, modelos, musica, fuentes).
#
# Dos cosas distintas que este validador comprueba y que conviene no confundir:
#
#   1. SANIDAD DE FORMATO. Un asset "exportado" cuyo contenido no corresponde a
#      su extension no es un asset: es un PLACEHOLDER de terceros (caso real
#      BUG-042: 3 archivos .ttf de assets/fonts/ son paginas HTML 404 de
#      github.githubassets.com guardadas con extension .ttf, 304 KB cada una).
#      Un placeholder sin licencia es exactamente lo que el item L164 prohibe.
#
#   2. ATRIBUCION EMBEBIDA. Los formatos que este validador soporta tienen un
#      lugar estandar para el copyright y la autoria:
#         .glb/.gltf -> asset.copyright (glTF 2.0 spec)
#         .png       -> chunks tEXt/iTXt con keyword Copyright/Author
#         .ogg/.flac -> comentario Vorbis "COPYRIGHT="
#         .wav       -> chunk LIST/INFO con ICOP
#         .jpg       -> EXIF tag 0x8298 (Copyright)
#      Si el formato puede llevarlo y no lo lleva, la evidencia de autoria
#      depende solo del repositorio git, no del artefacto distribuido.
#
# Uso:
#   python tools/legal/validate_asset_metadata.py --check      # CI: exit 1 si hay hallazgos
#   python tools/legal/validate_asset_metadata.py --detalle
#   python tools/legal/validate_asset_metadata.py --json
#
# Exit 0 si OK, 1 si hay hallazgos (o si falta el scope).

import os
import re
import sys
import json
import struct
import argparse

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
SCOPE_JSON = os.path.join(HERE, "asset_metadata_scope.json")

# --------------------------------------------------------------------------
# Tabla de magic numbers.
# Estructura: ext -> lista de ALTERNATIVAS; cada alternativa es una lista de
# requisitos (offset, bytes, descripcion) que deben cumplirse TODOS.
#   .ttf -> 4 alternativas, cada una de 1 requisito  (00010000 *o* OTTO *o* ...)
#   .webp -> 1 alternativa de 2 requisitos           (RIFF *y* WEBP)
# Confundir "o" con "y" deja pasar un RIFF/WAVE con extension .webp.
# --------------------------------------------------------------------------
MAGIC = {
    ".glb": [[(0, b"glTF", "glTF binary")]],
    ".gltf": [[(0, b"{", "glTF JSON")]],
    ".png": [[(0, b"\x89PNG\r\n\x1a\n", "PNG")]],
    ".jpg": [[(0, b"\xff\xd8\xff", "JPEG")]],
    ".jpeg": [[(0, b"\xff\xd8\xff", "JPEG")]],
    ".webp": [[(0, b"RIFF", "RIFF"), (8, b"WEBP", "WebP")]],
    ".wav": [[(0, b"RIFF", "RIFF"), (8, b"WAVE", "WAVE")]],
    ".ogg": [[(0, b"OggS", "Ogg")]],
    ".flac": [[(0, b"fLaC", "FLAC")]],
    ".mp3": [[(0, b"ID3", "MP3/ID3")], [(0, b"\xff\xfb", "MPEG frame")]],
    ".ttf": [[(0, b"\x00\x01\x00\x00", "TrueType")],
             [(0, b"OTTO", "CFF/OpenType")],
             [(0, b"true", "TrueType (Apple)")],
             [(0, b"ttcf", "TrueType collection")]],
    ".otf": [[(0, b"OTTO", "OpenType CFF")],
             [(0, b"\x00\x01\x00\x00", "TrueType outlines")]],
    ".woff": [[(0, b"wOFF", "WOFF")]],
    ".woff2": [[(0, b"wOF2", "WOFF2")]],
}

# Extensiones que ADEMAS deben llevar copyright embebido (si el formato lo permite).
SOPORTAN_COPYRIGHT = {".glb", ".gltf", ".png", ".ogg", ".flac", ".wav", ".jpg", ".jpeg", ".webp"}

# Si el archivo es mas chico que esto no puede ser un asset real exportado.
TAMANO_MINIMO = 64


def _leer(ruta, n=None):
    with open(ruta, "rb") as fh:
        return fh.read() if n is None else fh.read(n)


# --------------------------------------------------------------------------
# 1. Sanidad de formato
# --------------------------------------------------------------------------
def magic_valido(ext, head):
    """(bool, descripcion). Si la extension no esta en la tabla -> (None, 'no verificable').

    Cada alternativa exige que TODOS sus requisitos se cumplan; las alternativas
    entre si son un 'o'. Devuelve la descripcion de la alternativa que matcheo.
    """
    alternativas = MAGIC.get(ext)
    if not alternativas:
        return None, "extension no verificable"
    for requisitos in alternativas:
        if all(head[off:off + len(firma)] == firma for off, firma, _ in requisitos):
            return True, "+".join(desc for _, _, desc in requisitos)
    return False, "no coincide con ningun magic conocido de " + ext


def detectar_contenido(head):
    """Etiqueta humana del contenido real, para explicar un magic invalido.

    Se ignora el espacio en blanco inicial: los 3 .ttf placeholder del repo
    empiezan con 8 saltos de linea antes del '<!DOCTYPE html>', y sin el lstrip()
    se reportaban como 'texto plano' en vez de 'HTML'.
    """
    h = head.lstrip()
    if h[:5].upper() == b"<!DOC" or h[:5].lower() == b"<html":
        return "HTML"
    if h[:5] == b"<?xml":
        return "XML"
    if h[:4] == b"<svg":
        return "SVG"
    if h[:1] in (b"{", b"["):
        return "JSON"
    if h[:2] == b"\x1f\x8b":
        return "gzip"
    imprimibles = sum(1 for b in head[:256] if 32 <= b < 127 or b in (9, 10, 13))
    if len(head) and imprimibles / len(head[:256]) > 0.9:
        return "texto plano"
    return "binario desconocido"


# --------------------------------------------------------------------------
# 2. Atribucion embebida
# --------------------------------------------------------------------------
def metadata_glb(b):
    """Lee el chunk JSON de un .glb/.gltf y devuelve su bloque asset."""
    if b[:4] != b"glTF":
        return None
    try:
        clen, ctype = struct.unpack("<I4s", b[12:20])
        if ctype != b"JSON":
            return None
        return json.loads(b[20:20 + clen].decode("utf-8"))
    except Exception:
        return None


def claves_png(b):
    """Recorre los chunks PNG y devuelve los textos tEXt/iTXt (keyword -> texto)."""
    salida = {}
    pos = 8
    while pos + 8 <= len(b):
        try:
            largo, tipo = struct.unpack(">I4s", b[pos:pos + 8])
        except Exception:
            break
        datos = b[pos + 8:pos + 8 + largo]
        if tipo == b"tEXt" and b"\x00" in datos:
            k, v = datos.split(b"\x00", 1)
            salida[k.decode("latin-1", "replace")] = v.decode("latin-1", "replace")
        elif tipo == b"iTXt" and b"\x00" in datos:
            k = datos.split(b"\x00", 1)[0]
            salida[k.decode("latin-1", "replace")] = datos[-min(len(datos), 200):].decode("utf-8", "replace")
        elif tipo == b"IEND":
            break
        pos += 12 + largo
    return salida


def claves_vorbis(b):
    """Comentario Vorbis (ogg y flac comparten el bloque \\x03vorbis).

    Parser real, no heuristica: el bloque es
        \\x03vorbis + len(vendor) + vendor + n + [len(campo) + "KEY=valor"]*
    con las longitudes en uint32 little-endian. Antes se partia por \\x01 y se
    quedaba el NUL terminador dentro del valor.
    """
    salida = {}
    i = b.find(b"\x03vorbis")
    if i < 0:
        return salida
    p = i + 7
    try:
        vlen = struct.unpack("<I", b[p:p + 4])[0]
        p += 4 + vlen
        n = struct.unpack("<I", b[p:p + 4])[0]
        p += 4
        for _ in range(min(n, 128)):
            largo = struct.unpack("<I", b[p:p + 4])[0]
            p += 4
            campo = b[p:p + largo]
            p += largo
            if b"=" in campo:
                k, v = campo.split(b"=", 1)
                ks = k.decode("ascii", "ignore").strip()
                if ks:
                    salida[ks] = v.decode("utf-8", "replace").strip()
    except (struct.error, IndexError):
        pass
    return salida


def claves_wav(b):
    """Chunk LIST/INFO con sub-chunks ICOP (copyright)."""
    salida = {}
    pos = 12
    while pos + 8 <= len(b):
        try:
            tipo = b[pos:pos + 4]
            largo = struct.unpack("<I", b[pos + 4:pos + 8])[0]
        except Exception:
            break
        if tipo == b"LIST":
            sub = b[pos + 8:pos + 8 + largo]
            q = 4
            while q + 8 <= len(sub):
                st = sub[q:q + 4]
                sl = struct.unpack("<I", sub[q + 4:q + 8])[0]
                salida[st.decode("ascii", "ignore")] = sub[q + 8:q + 8 + sl].decode("latin-1", "replace")
                q += 8 + sl + (sl % 2)
        pos += 8 + largo + (largo % 2)
    return salida


def claves_exif_jpeg(b):
    """EXIF tag 0x8298 = Copyright (IFD0)."""
    salida = {}
    if b[:2] != b"\xff\xd8":
        return salida
    pos = 2
    while pos + 4 <= len(b):
        if b[pos] != 0xFF:
            break
        marca = b[pos + 1]
        if marca == 0xE1 and b[pos + 4:pos + 10] == b"Exif\x00\x00":
            seg = b[pos + 10:pos + 2 + struct.unpack(">H", b[pos + 2:pos + 4])[0]]
            if seg[:2] == b"II":
                le = "<"
            elif seg[:2] == b"MM":
                le = ">"
            else:
                break
            off = struct.unpack(le + "I", seg[4:8])[0]
            if off + 2 <= len(seg):
                n = struct.unpack(le + "H", seg[off:off + 2])[0]
                for i in range(n):
                    e = off + 2 + i * 12
                    if e + 12 > len(seg):
                        break
                    tag = struct.unpack(le + "H", seg[e:e + 2])[0]
                    if tag == 0x8298:
                        cnt = struct.unpack(le + "I", seg[e + 4:e + 8])[0]
                        salida["Copyright"] = seg[e + 8:e + 8 + min(cnt, 200)].decode("latin-1", "replace")
            break
        largo = struct.unpack(">H", b[pos + 2:pos + 4])[0]
        pos += 2 + largo
    return salida


def claves_exif_webp(b):
    """WEBP: chunk EXIF -> reusa el parser JPEG saltando el header RIFF."""
    if b[:4] != b"RIFF" or b[8:12] != b"WEBP":
        return {}
    pos = 12
    while pos + 8 <= len(b):
        tipo = b[pos:pos + 4]
        largo = struct.unpack("<I", b[pos + 4:pos + 8])[0]
        if tipo == b"EXIF":
            return claves_exif_jpeg(b"\xff\xd8" + b"\xff\xe1" + b[pos + 8:pos + 8 + largo])
        pos += 8 + largo + (largo % 2)
    return {}


def atribucion_embebida(ruta, ext, b):
    """(bool|None, dict). None = el formato no permite copyright embebido."""
    if ext in (".glb", ".gltf"):
        js = metadata_glb(b)
        if js is None:
            return False, {}
        asset = js.get("asset", {}) if isinstance(js, dict) else {}
        return bool(asset.get("copyright")), {"asset": asset}
    if ext == ".png":
        k = claves_png(b)
        return any(x.lower() in ("copyright", "author", "artist") for x in k), k
    if ext in (".ogg", ".flac"):
        k = claves_vorbis(b)
        return bool(k.get("COPYRIGHT") or k.get("ARTIST")), k
    if ext == ".wav":
        k = claves_wav(b)
        return bool(k.get("ICOP") or k.get("IART")), k
    if ext in (".jpg", ".jpeg"):
        k = claves_exif_jpeg(b)
        return bool(k.get("Copyright")), k
    if ext == ".webp":
        k = claves_exif_webp(b)
        return bool(k.get("Copyright")), k
    return None, {}


# --------------------------------------------------------------------------
# 3. Escaneo
# --------------------------------------------------------------------------
def es_excluido(ruta_rel, excluidos):
    partes = ruta_rel.replace("\\", "/").split("/")
    for ex in excluidos:
        ex = ex.strip("/")
        if "/" in ex:
            if ex in ruta_rel.replace("\\", "/"):
                return True
        elif ex in partes:
            return True
    return False


def escanear(scope, raiz):
    """Devuelve la lista de resultados por archivo dentro del alcance."""
    ext_scope = {e.lower() for e in scope.get("extensiones", [])}
    excluidos = scope.get("excluir", [])
    resultados = []

    for dir_rel in scope.get("rutas", []):
        base = os.path.join(raiz, dir_rel)
        if not os.path.isdir(base):
            continue
        for actual, dirs, archivos in os.walk(base):
            dirs[:] = [d for d in dirs if not es_excluido(os.path.relpath(os.path.join(actual, d), raiz), excluidos)]
            for nombre in sorted(archivos):
                ext = os.path.splitext(nombre)[1].lower()
                if ext not in ext_scope:
                    continue
                ruta = os.path.join(actual, nombre)
                rel = os.path.relpath(ruta, raiz).replace("\\", "/")
                if es_excluido(rel, excluidos):
                    continue
                if rel.endswith(".import"):
                    continue
                resultados.append(analizar(ruta, rel, ext))
    return resultados


def analizar(ruta, rel, ext):
    res = {
        "ruta": rel,
        "ext": ext,
        "bytes": 0,
        "magic_ok": None,
        "magic_desc": "",
        "contenido_real": "",
        "atribucion_ok": None,
        "atribucion": {},
        "hallazgos": [],
    }
    try:
        tam = os.path.getsize(ruta)
        res["bytes"] = tam
        b = _leer(ruta)
    except OSError as e:
        res["hallazgos"].append("ILEGIBLE: %s" % e)
        return res

    head = b[:512]
    ok, desc = magic_valido(ext, head)
    res["magic_ok"] = ok
    res["magic_desc"] = desc
    if ok is False:
        real = detectar_contenido(head)
        res["contenido_real"] = real
        res["hallazgos"].append("MAGIC_INVALIDO: dice %s pero el contenido es %s (%s)" % (ext, real, desc))
        # Un placeholder no puede tener metadata de copyright valida: no seguir.
        return res

    if tam < TAMANO_MINIMO:
        res["hallazgos"].append("TRUNCADO: %d bytes (< %d)" % (tam, TAMANO_MINIMO))

    if ext in SOPORTAN_COPYRIGHT:
        tiene, claves = atribucion_embebida(ruta, ext, b)
        res["atribucion_ok"] = tiene
        res["atribucion"] = {k: v for k, v in list(claves.items())[:4]}
        if tiene is False:
            res["hallazgos"].append("SIN_ATRIBUCION: %s puede llevar copyright embebido y no lo lleva" % ext)
    return res


# --------------------------------------------------------------------------
# 4. Inventarios declarados (evidencia data-driven)
# --------------------------------------------------------------------------
def inventarios(raiz):
    """Lee los inventarios data-driven y devuelve (entradas, problemas)."""
    entradas, problemas = [], []
    fuentes = [
        ("game/isla-ancestral/data/arte2d/inventario_2d.json", "assets", ("id", "familia")),
        ("game/isla-ancestral/data/legal/modelos_3d.json", "assets", ("id", "origen", "licencia")),
        ("game/isla-ancestral/data/legal/audio_licenses.json", "tracks", ("id", "licencia")),
    ]
    for rel, clave, campos in fuentes:
        ruta = os.path.join(raiz, rel)
        if not os.path.isfile(ruta):
            problemas.append("FALTA_INVENTARIO: %s" % rel)
            continue
        try:
            datos = json.loads(_leer(ruta).decode("utf-8-sig"))
        except Exception as e:
            problemas.append("INVENTARIO_ILEGIBLE: %s (%s)" % (rel, e))
            continue
        for it in datos.get(clave, []):
            entradas.append({"fuente": rel, "item": it, "campos": campos})
    return entradas, problemas


def auditar_inventarios(entradas):
    """Cada entrada debe declarar los campos de atribucion que le corresponden."""
    faltas = []
    for e in entradas:
        it = e["item"]
        faltan = [c for c in e["campos"] if not str(it.get(c, "")).strip()]
        if faltan:
            faltas.append("%s: '%s' sin %s" % (e["fuente"], it.get("id", "?"), ", ".join(faltan)))
    return faltas


# --------------------------------------------------------------------------
# 5. Informe
# --------------------------------------------------------------------------
def clave_hallazgo(r):
    """Clase de hallazgo de un archivo (para el baseline por conteo)."""
    if r["magic_ok"] is False:
        return "MAGIC_INVALIDO"
    if r["atribucion_ok"] is False:
        return "SIN_ATRIBUCION"
    return None


def coincide_patron(ruta, patron):
    """Glob con semantica globstar: '**/' matchea cero o mas directorios.

    fnmatch NO sirve aqui: traduce '*' a '.*' (que cruza '/'), asi que
    '*/assets/*.ttf' exige un prefijo de directorio y no matchea 'assets/x.ttf'.
    Con '**/' el mismo patron sirve tanto para rutas relativas al repo
    ('game/isla-ancestral/assets/fonts/x.ttf') como al raiz que se escanee.
    """
    trozos, i = [], 0
    while i < len(patron):
        if patron.startswith("**/", i):
            trozos.append("(?:.*/)?")
            i += 3
        elif patron[i] == "*":
            trozos.append("[^/]*")
            i += 1
        elif patron[i] == "?":
            trozos.append("[^/]")
            i += 1
        else:
            trozos.append(re.escape(patron[i]))
            i += 1
    return re.match("^" + "".join(trozos) + "$", ruta.replace("\\", "/")) is not None


def aplicar_baseline(resultados, baseline):
    """Techo de deuda por clase de hallazgo.

    Un baseline de N objetos exactos no sirve cuando la deuda es de 418 archivos.
    Aqui cada entrada acepta hasta `max` hallazgos de una clase (opcionalmente
    filtrados por glob). Si la cuenta real SUPERA el techo, el exceso son
    hallazgos nuevos y --check falla: el techo es un TRINQUETE, no un permiso.
    """
    hallazgos = [r for r in resultados if clave_hallazgo(r)]
    aceptados, nuevos, consumo = set(), [], []

    for b in baseline:
        tipo = b.get("tipo")
        patron = b.get("patron")
        tope = b.get("max")
        candidatos = [r for r in hallazgos if clave_hallazgo(r) == tipo and r["ruta"] not in aceptados]
        if patron:
            candidatos = [r for r in candidatos if coincide_patron(r["ruta"], patron)]
        if tope is None:
            tope = 1
        tomar = candidatos[:tope]
        for r in tomar:
            aceptados.add(r["ruta"])
        consumo.append({"tipo": tipo, "patron": patron, "max": tope, "aceptados": len(tomar),
                        "motivo": b.get("motivo", ""), "dueno": b.get("dueno", ""),
                        "excedido": len(candidatos) > tope})

    for r in hallazgos:
        if r["ruta"] not in aceptados:
            r["aceptado"] = False
            nuevos.append(r)
    return nuevos, consumo


def construir_informe(raiz):
    if not os.path.isfile(SCOPE_JSON):
        return None, ["FALTA_SCOPE: %s" % SCOPE_JSON]
    try:
        scope = json.loads(_leer(SCOPE_JSON).decode("utf-8-sig"))
    except Exception as e:
        return None, ["SCOPE_ILEGIBLE: %s" % e]

    res = escanear(scope, raiz)
    entradas, probs = inventarios(raiz)
    faltas_inv = auditar_inventarios(entradas)

    nuevos, consumo = aplicar_baseline(res, scope.get("baseline", []))
    con_hallazgos = [r for r in res if r["hallazgos"]]
    invalidos = [r for r in res if r["magic_ok"] is False]
    sin_atrib = [r for r in res if r["atribucion_ok"] is False]
    con_atrib = [r for r in res if r["atribucion_ok"] is True]

    informe = {
        "archivos_en_alcance": len(res),
        "con_hallazgos": len(con_hallazgos),
        "magic_invalido": len(invalidos),
        "sin_atribucion": len(sin_atrib),
        "con_atribucion": len(con_atrib),
        "entradas_inventario": len(entradas),
        "inventario_incompleto": len(faltas_inv),
        "problemas": probs,
        "hallazgos": con_hallazgos,
        "hallazgos_nuevos": [r["ruta"] for r in nuevos],
        "baseline": consumo,
        "faltas_inventario": faltas_inv,
        "entradas": entradas,
    }
    return informe, []


def imprimir(informe, detalle):
    print("=== validate_asset_metadata (M127 / L112) ===")
    print("archivos en alcance      : %d" % informe["archivos_en_alcance"])
    print("magic invalido (placeholder): %d" % informe["magic_invalido"])
    print("sin atribucion embebida  : %d" % informe["sin_atribucion"])
    print("con atribucion embebida  : %d" % informe["con_atribucion"])
    print("entradas de inventario   : %d (incompletas: %d)" % (
        informe["entradas_inventario"], informe["inventario_incompleto"]))

    if informe["problemas"]:
        print("\n-- problemas de fuentes --")
        for p in informe["problemas"]:
            print("   " + p)

    if informe["baseline"]:
        print("\n-- techo de deuda (baseline) --")
        for b in informe["baseline"]:
            print("   %s%s: aceptados %d de max %d%s" % (
                b["tipo"], " (%s)" % b["patron"] if b["patron"] else "",
                b["aceptados"], b["max"], "  <-- EXCEDIDO" if b["excedido"] else ""))
            print("      motivo: %s" % b["motivo"])
            print("      dueño : %s" % b["dueno"])

    nuevos = informe["hallazgos_nuevos"]
    if nuevos:
        print("\n-- HALLAZGOS NUEVOS (%d) --" % len(nuevos))
        for r in nuevos[:40]:
            print("   %s" % r)
        if len(nuevos) > 40:
            print("   ... y %d mas" % (len(nuevos) - 40))

    if informe["faltas_inventario"]:
        print("\n-- inventario incompleto (%d) --" % len(informe["faltas_inventario"]))
        for f in informe["faltas_inventario"][:20]:
            print("   " + f)

    if detalle:
        print("\n-- detalle por archivo --")
        for e in informe["entradas"]:
            print("   %s" % json.dumps(e["item"], ensure_ascii=False)[:160])


def _fallos_de(informe):
    return (len(informe["hallazgos_nuevos"]) + informe["inventario_incompleto"]
            + len(informe["problemas"]))


def main(argv=None):
    ap = argparse.ArgumentParser(description="Validador de metadata de copyright en assets exportados (M127 L112)")
    ap.add_argument("--raiz", default=PROJECT_ROOT)
    ap.add_argument("--check", action="store_true", help="exit 1 si hay hallazgos NUEVOS (CI)")
    ap.add_argument("--estricto", action="store_true", help="exit 1 si hay cualquier hallazgo (techo incluido)")
    ap.add_argument("--detalle", action="store_true")
    ap.add_argument("--json", action="store_true", help="imprime el informe en JSON")
    args = ap.parse_args(argv)

    informe, problemas = construir_informe(args.raiz)
    if informe is None:
        for p in problemas:
            print("[FALLO] " + p)
        return 1

    fallos = _fallos_de(informe)
    total = (informe["magic_invalido"] + informe["sin_atribucion"]
             + informe["inventario_incompleto"] + len(informe["problemas"]))

    if args.json:
        # stdout debe ser JSON PURO para poder pipearlo a json.load().
        # El resumen y el ruido humano van a stderr.
        print(json.dumps(informe, ensure_ascii=False, indent=2))
        print("=== Resumen: %d nuevo(s), %d total(es) ===" % (fallos, total), file=sys.stderr)
    else:
        imprimir(informe, args.detalle)
        print("\n=== Resumen: %d hallazgo(s) nuevo(s), %d total(es) ===" % (fallos, total))

    if args.estricto and total:
        return 1
    if args.check and fallos:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
