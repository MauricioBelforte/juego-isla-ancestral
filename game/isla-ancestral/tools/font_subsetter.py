#!/usr/bin/env python3
# -*- coding: ascii -*-
"""Subsetter de fuentes TrueType sin dependencias externas (modulo M88).

Implementa lo que `DOCUMENTACION/88-Fuentes-Tipograficas/plan-actual/03-Diseno.md`
seccion 9 diseno pero nunca implemento: `font_subsetter.gd` / `font_compressor.gd`
debian apoyarse en `pyftsubset` y `woff2_compress`, herramientas EXTERNAS que no
estan instaladas en este repo ni en el CI. Este script hace el subsetting con la
biblioteca estandar (`struct`) y verifica su propia salida.

Que hace:
  1. Lee el directorio de tablas del TTF y el `cmap` (formatos 4 y 12).
  2. Calcula el conjunto de glifos a conservar: glifo 0 (.notdef) + los glifos
     alcanzables desde los codepoints pedidos + los componentes de glifos
     compuestos (cierre transitivo).
  3. Reconstruye `glyf`, `loca`, `hmtx`, `hhea`, `maxp`, `head`, `cmap` y `post`,
     y descarta las tablas que referencian IDs de glifo y quedarian corruptas
     al remapear: GDEF, GPOS, GSUB, kern, hdmx, VDMX, LTSH, DSIG.
  4. Recalcula checksums de tabla y `head.checkSumAdjustment`.
  5. Verifica el resultado: directorio coherente, checksums de tabla, checksum
     global == 0xB1B0AFBA, `cmap` de salida == codepoints pedidos, `loca`
     monotona. Si la verificacion falla, NO escribe la salida.

Limites declarados (no se ocultan):
  - Fuentes variables (con `fvar`/`gvar`) NO soportadas: se rechazan con error.
  - Se pierden kerning y ligaduras (GPOS/GSUB se descartan, no se remapean).
  - Solo BMP en `cmap` de salida (codepoints < 0xFFFF); fuera de eso, error.

Uso:
  python game/isla-ancestral/tools/font_subsetter.py \
      --input  game/isla-ancestral/assets/fonts/Nunito-Regular.ttf \
      --output /tmp/Nunito-Regular.subset.ttf \
      --po     game/isla-ancestral/locales \
      --report /tmp/reporte.json

  # codepoints explicitos (hex, separados por coma)
  python ... --input X.ttf --output Y.ttf --codepoints 0041,00F1,2192

  # solo medir, sin escribir fuente
  python ... --input X.ttf --medir --po game/isla-ancestral/locales

Exit: 0 = ok y verificado / 1 = error o verificacion fallida.
"""

import argparse
import json
import os
import struct
import sys

MARCA_CHECKSUM = 0xB1B0AFBA

# Tablas que NO referencian IDs de glifo: se copian tal cual.
TABLAS_COPIA = ("head", "hhea", "maxp", "OS/2", "name", "prep", "gasp",
                "cvt ", "fpgm", "STAT")
# Tablas que SI referencian IDs de glifo: se descartan (no se remapean).
TABLAS_DESCARTE = ("GDEF", "GPOS", "GSUB", "kern", "hdmx", "VDMX", "LTSH",
                   "DSIG", "morx", "mort", "kerx", "JSTF", "BASE")
# Tablas de fuente variable: no soportadas.
TABLAS_VARIABLE = ("fvar", "gvar", "avar", "HVAR", "VVAR", "MVAR", "CVAR",
                   "cvar", "STAT")


def u16(b, o):
    return struct.unpack(">H", b[o:o + 2])[0]


def i16(b, o):
    return struct.unpack(">h", b[o:o + 2])[0]


def u32(b, o):
    return struct.unpack(">I", b[o:o + 4])[0]


def checksum(datos):
    """Suma de uint32 big-endian sobre datos alineados a 4 bytes."""
    if len(datos) % 4:
        datos = datos + b"\x00" * (4 - len(datos) % 4)
    total = 0
    for i in range(0, len(datos), 4):
        total = (total + u32(datos, i)) & 0xFFFFFFFF
    return total


# --------------------------------------------------------------------------
# Lectura
# --------------------------------------------------------------------------

def leer_directorio(d):
    if d[:4] != b"\x00\x01\x00\x00":
        raise ValueError("no es un TTF (sfnt %r)" % d[:4])
    num = u16(d, 4)
    tabs = {}
    for i in range(num):
        o = 12 + i * 16
        tag = d[o:o + 4].decode("latin-1")
        cs, off, ln = struct.unpack(">III", d[o + 4:o + 16])
        tabs[tag] = {"offset": off, "len": ln, "cs": cs}
    return tabs


def tabla(d, tabs, tag):
    t = tabs[tag]
    return d[t["offset"]:t["offset"] + t["len"]]


def parse_cmap(d, tabs):
    """Devuelve {codepoint: gid} usando la mejor subttabla disponible."""
    base = tabs["cmap"]["offset"]
    n = u16(d, base + 2)
    candidatas = []
    for i in range(n):
        pid = u16(d, base + 4 + i * 8)
        eid = u16(d, base + 6 + i * 8)
        sub = u32(d, base + 8 + i * 8)
        o = base + sub
        fmt = u16(d, o)
        if fmt == 12:
            pref = 3 if (pid, eid) == (3, 10) else 2
        elif fmt == 4:
            pref = 2 if (pid, eid) in ((3, 1), (0, 3)) else 1
        else:
            pref = 0
        if pref:
            candidatas.append((pref, fmt, o))
    if not candidatas:
        raise ValueError("cmap sin subttabla format 4 o 12")
    candidatas.sort(key=lambda x: -x[0])
    _, fmt, o = candidatas[0]
    mapa = {}
    if fmt == 4:
        seg2 = u16(d, o + 6)
        seg = seg2 // 2
        fin = o + 14
        ini = fin + seg2 + 2
        delta = ini + seg2
        rango = delta + seg2
        for i in range(seg):
            e = u16(d, fin + i * 2)
            s = u16(d, ini + i * 2)
            de = i16(d, delta + i * 2)
            ro = u16(d, rango + i * 2)
            for c in range(s, e + 1):
                if c == 0xFFFF:
                    continue
                if ro == 0:
                    g = (c + de) & 0xFFFF
                else:
                    pos = rango + i * 2 + ro + (c - s) * 2
                    if pos + 2 > len(d):
                        continue
                    g = u16(d, pos)
                    if g:
                        g = (g + de) & 0xFFFF
                if g:
                    mapa[c] = g
    else:
        grupos = u32(d, o + 12)
        for i in range(grupos):
            p = o + 16 + i * 12
            s, e, g = u32(d, p), u32(d, p + 4), u32(d, p + 8)
            for c in range(s, e + 1):
                mapa[c] = g + (c - s)
    return mapa


def leer_loca(d, tabs, num_glifos, formato):
    base = tabs["loca"]["offset"]
    if formato == 0:
        return [u16(d, base + i * 2) * 2 for i in range(num_glifos + 1)]
    return [u32(d, base + i * 4) for i in range(num_glifos + 1)]


def _recorrer_compuesto(d, ini, fin, reescribir=None):
    """Recorre un glifo compuesto. Devuelve la lista de gids componentes.

    Si `reescribir` es un dict {viejo: nuevo}, parchea los gids en `d`.
    """
    if fin - ini < 10 or i16(d, ini) != -1:
        return []
    salida = []
    p = ini + 10
    while p + 4 <= fin:
        flags = u16(d, p)
        gid = u16(d, p + 2)
        if reescribir is not None and gid in reescribir:
            d[p + 2:p + 4] = struct.pack(">H", reescribir[gid])
        salida.append(gid)
        p += 4
        p += 4 if flags & 0x0001 else 2          # ARG_1_AND_2_ARE_WORDS
        if flags & 0x0008:                        # WE_HAVE_A_SCALE
            p += 2
        elif flags & 0x0040:                      # X_AND_Y_SCALE
            p += 4
        elif flags & 0x0080:                      # TWO_BY_TWO
            p += 8
        if not flags & 0x0020:                    # MORE_COMPONENTS
            break
    return salida


def leer_hmtx(d, tabs, num_glifos, num_hmetrics):
    base = tabs["hmtx"]["offset"]
    out = []
    for g in range(num_glifos):
        if g < num_hmetrics:
            out.append((u16(d, base + g * 4), i16(d, base + g * 4 + 2)))
        else:
            adv = out[-1][0]
            out.append((adv, i16(d, base + num_hmetrics * 4 + (g - num_hmetrics) * 2)))
    return out


# --------------------------------------------------------------------------
# Escritura
# --------------------------------------------------------------------------

def construir_cmap4(pares):
    """pares: lista de (codepoint, gid) ordenada. Emite format 4, 1 segmento por cp."""
    pares = sorted(pares)
    segs = [c for c, _ in pares]
    seg = len(segs) + 1                       # + centinela 0xFFFF
    entradas = list(pares) + [(0xFFFF, 0)]
    largo = 16 + seg * 8
    out = bytearray()
    out += struct.pack(">HHHHHHH", 4, largo, 0, seg * 2, 0, 0, 0)
    # searchRange / entrySelector / rangeShift (se rellenan abajo)
    es = 0
    while (1 << (es + 1)) <= seg:
        es += 1
    sr = (1 << es) * 2
    out[8:14] = struct.pack(">HHH", sr, es, seg * 2 - sr)
    for c, _ in entradas:
        out += struct.pack(">H", c)           # endCode
    out += struct.pack(">H", 0)               # reservedPad
    for c, _ in entradas:
        out += struct.pack(">H", c)           # startCode
    for c, g in entradas:
        if c == 0xFFFF:
            out += struct.pack(">h", 1)
        else:
            out += struct.pack(">h", (g - c) & 0xFFFF if (g - c) & 0xFFFF < 0x8000
                               else ((g - c) & 0xFFFF) - 0x10000)
    for _ in entradas:
        out += struct.pack(">H", 0)           # idRangeOffset
    cab = struct.pack(">HH", 0, 1) + struct.pack(">HHI", 3, 1, 12)
    return cab + bytes(out)


def construir_post3(original=None):
    """post version 3.0 (sin nombres de glifo) conservando las metricas."""
    angulo, subrayado, grosor, fijo = 0, 0, 0, 0
    if original is not None and len(original) >= 16:
        angulo = struct.unpack(">i", original[4:8])[0]
        subrayado = i16(original, 8)
        grosor = i16(original, 10)
        fijo = u32(original, 12)
    return struct.pack(">IihhIIIII", 0x00030000, angulo, subrayado, grosor,
                       fijo, 0, 0, 0, 0)


def ensamblar(tablas):
    tags = sorted(tablas)
    n = len(tags)
    es = 0
    while (1 << (es + 1)) <= n:
        es += 1
    sr = (1 << es) * 16
    cab = struct.pack(">IHHHH", 0x00010000, n, sr, es, n * 16 - sr)
    off = 12 + n * 16
    directorio = b""
    cuerpo = b""
    pos_head = None
    for tag in tags:
        datos = tablas[tag]
        if tag == "head":
            datos = datos[:8] + b"\x00\x00\x00\x00" + datos[12:]
            pos_head = off
        cs = checksum(datos)
        directorio += struct.pack(">4sIII", tag.encode("latin-1"), cs, off, len(datos))
        relleno = (-len(datos)) % 4
        cuerpo += datos + b"\x00" * relleno
        off += len(datos) + relleno
    fuente = bytearray(cab + directorio + cuerpo)
    ajuste = (MARCA_CHECKSUM - checksum(bytes(fuente))) & 0xFFFFFFFF
    fuente[pos_head + 8:pos_head + 12] = struct.pack(">I", ajuste)
    return bytes(fuente)


# --------------------------------------------------------------------------
# Subsetting
# --------------------------------------------------------------------------

def subset(d, codepoints):
    tabs = leer_directorio(d)
    variables = [t for t in TABLAS_VARIABLE if t in tabs]
    if "fvar" in tabs or "gvar" in tabs:
        raise ValueError("fuente variable no soportada (tablas: %s)"
                         % ",".join(sorted(variables)))
    for req in ("head", "hhea", "maxp", "hmtx", "loca", "glyf", "cmap"):
        if req not in tabs:
            raise ValueError("falta la tabla obligatoria %r" % req)

    head = tabla(d, tabs, "head")
    maxp = tabla(d, tabs, "maxp")
    hhea = tabla(d, tabs, "hhea")
    num_glifos = u16(maxp, 4)
    num_hmetrics = u16(hhea, 34)
    formato_loca = i16(head, 50)

    cmap = parse_cmap(d, tabs)
    faltan = sorted(c for c in codepoints if c not in cmap)
    loca = leer_loca(d, tabs, num_glifos, formato_loca)
    glyf = tabs["glyf"]
    hmtx = leer_hmtx(d, tabs, num_glifos, num_hmetrics)

    conservar = {0}
    for c in codepoints:
        if c in cmap:
            conservar.add(cmap[c])
    # cierre transitivo de componentes
    pendientes = list(conservar)
    while pendientes:
        g = pendientes.pop()
        if g >= num_glifos:
            continue
        ini = glyf["offset"] + loca[g]
        fin = glyf["offset"] + loca[g + 1]
        for comp in _recorrer_compuesto(d, ini, fin):
            if comp not in conservar:
                conservar.add(comp)
                pendientes.append(comp)

    orden = sorted(conservar)
    nuevo = {viejo: i for i, viejo in enumerate(orden)}

    glyf_out = bytearray()
    loca_out = [0]
    for viejo in orden:
        ini = glyf["offset"] + loca[viejo]
        fin = glyf["offset"] + loca[viejo + 1]
        datos = bytearray(d[ini:fin])
        if datos:
            _recorrer_compuesto(datos, 0, len(datos), nuevo)
            if len(datos) % 4:
                datos += b"\x00" * (4 - len(datos) % 4)
        glyf_out += datos
        loca_out.append(len(glyf_out))

    if max(loca_out) // 2 > 0xFFFF:
        formato_salida = 1
        loca_bytes = b"".join(struct.pack(">I", v) for v in loca_out)
    else:
        formato_salida = 0
        loca_bytes = b"".join(struct.pack(">H", v // 2) for v in loca_out)

    hmtx_out = bytearray()
    for viejo in orden:
        adv, lsb = hmtx[viejo]
        hmtx_out += struct.pack(">Hh", adv, lsb)

    head_out = bytearray(head)
    head_out[50:52] = struct.pack(">h", formato_salida)
    # xMin/yMin/xMax/yMax se dejan como estaban: es una caja envolvente valida.

    hhea_out = bytearray(hhea)
    hhea_out[34:36] = struct.pack(">H", len(orden))

    maxp_out = bytearray(maxp)
    maxp_out[4:6] = struct.pack(">H", len(orden))

    pares = []
    for c in sorted(codepoints):
        if c in cmap and cmap[c] in nuevo:
            pares.append((c, nuevo[cmap[c]]))
    cmap_out = construir_cmap4(pares)

    salida = {}
    for tag in TABLAS_COPIA:
        if tag in tabs:
            salida[tag] = bytes(tabla(d, tabs, tag))
    salida["head"] = bytes(head_out)
    salida["hhea"] = bytes(hhea_out)
    salida["maxp"] = bytes(maxp_out)
    salida["hmtx"] = bytes(hmtx_out)
    salida["loca"] = loca_bytes
    salida["glyf"] = bytes(glyf_out)
    salida["cmap"] = cmap_out
    salida["post"] = construir_post3(tabla(d, tabs, "post") if "post" in tabs else None)

    return ensamblar(salida), {
        "glyphs_in": num_glifos,
        "glyphs_out": len(orden),
        "codepoints_pedidos": len(codepoints),
        "codepoints_mapeados": len(pares),
        "codepoints_sin_glifo": faltan,
        "tablas_entrada": sorted(tabs),
        "tablas_salida": sorted(salida),
        "tablas_descartadas": [t for t in sorted(tabs) if t not in salida],
        "indexToLocFormat_out": formato_salida,
    }


# --------------------------------------------------------------------------
# Verificacion de la salida (no confia en el escritor)
# --------------------------------------------------------------------------

def verificar(d, codepoints_esperados):
    checks = []

    def ck(nombre, ok, detalle=""):
        checks.append({"check": nombre, "ok": bool(ok), "detalle": detalle})

    try:
        tabs = leer_directorio(d)
        ck("directorio legible", True, "%d tablas" % len(tabs))
    except Exception as e:                                    # noqa: BLE001
        ck("directorio legible", False, str(e))
        return checks

    malas = []
    for tag, t in tabs.items():
        datos = d[t["offset"]:t["offset"] + t["len"]]
        if len(datos) != t["len"]:
            malas.append(tag + ":truncada")
            continue
        if tag == "head":
            datos = datos[:8] + b"\x00\x00\x00\x00" + datos[12:]
        if checksum(datos) != t["cs"]:
            malas.append(tag)
    ck("checksums de tabla", not malas, "malas: %s" % malas)

    total = checksum(d)
    ck("checksum global == 0xB1B0AFBA", total == MARCA_CHECKSUM, "0x%08X" % total)

    num_glifos = u16(tabla(d, tabs, "maxp"), 4)
    head = tabla(d, tabs, "head")
    loca = leer_loca(d, tabs, num_glifos, i16(head, 50))
    monotona = all(loca[i] <= loca[i + 1] for i in range(len(loca) - 1))
    ck("loca monotona", monotona)
    ck("loca cierra en glyf", loca[-1] == tabs["glyf"]["len"],
       "%d vs %d" % (loca[-1], tabs["glyf"]["len"]))

    cmap = parse_cmap(d, tabs)
    faltan = sorted(c for c in codepoints_esperados if c not in cmap)
    ck("cmap cubre los codepoints pedidos", not faltan,
       "faltan: %s" % ["U+%04X" % c for c in faltan[:8]])
    fuera = sorted(g for g in cmap.values() if g >= num_glifos)
    ck("cmap sin gids fuera de rango", not fuera, "fuera: %s" % fuera[:8])
    return checks


# --------------------------------------------------------------------------
# Catalogos .po
# --------------------------------------------------------------------------

def codepoints_de_po(dirs):
    """Codepoints de TODAS las entradas de los .po (sin comentarios ni cabecera).

    Un .po no garantiza linea en blanco entre entradas: se corta por `msgid`.
    La cabecera (`msgid ""` + `msgstr ""` con metadatos tipo `Content-Type`)
    NO es texto mostrable y se excluye: si se cuenta, aparecen 15 ASCII que
    ningun jugador ve (medido: 94 -> 79 codepoints).
    """
    cps = set()
    for base in dirs:
        for nombre in sorted(os.listdir(base)):
            if not nombre.endswith(".po"):
                continue
            ruta = os.path.join(base, nombre)
            with open(ruta, "rb") as f:
                texto = f.read().decode("utf-8", "replace")
            campo = None
            cabecera = False
            for linea in texto.splitlines():
                s = linea.strip()
                if s.startswith("#"):
                    continue
                if s.startswith("msgid ") or s.startswith("msgid_plural "):
                    campo = "id"
                    valor = s.split(" ", 1)[1]
                    cabecera = valor.strip() == '""'
                elif s.startswith("msgstr"):
                    campo = "str"
                    valor = s.split(" ", 1)[1]
                elif s.startswith('"'):
                    if campo is None:
                        continue
                    valor = s
                else:
                    campo = None
                    continue
                if cabecera or campo != "str":
                    # Solo `msgstr`/`msgstr[n]` es texto que se dibuja. Los
                    # `msgid` de este proyecto son CLAVES (`SETTINGS.CRAFT_OK`,
                    # `CLOCK.ESTACIONES.0`): contarlas metia 11 ASCII que nadie
                    # ve (K, X, _, 0-9) y rompia la comparacion con el auditor.
                    continue
                valor = valor.strip()
                if valor.startswith('"') and valor.endswith('"') and len(valor) >= 2:
                    valor = valor[1:-1]
                for ch in valor:
                    o = ord(ch)
                    # Se incluye ASCII: un subsetter para UI necesita letras,
                    # digitos y puntuacion, no solo los acentos. Se excluyen
                    # los caracteres de control (un glifo de \n no existe).
                    if o >= 0x20 and o != 0x7F:
                        cps.add(o)
    return cps


def main(argv):
    ap = argparse.ArgumentParser(description="Subsetter TTF sin dependencias (M88)")
    ap.add_argument("--input", required=True)
    ap.add_argument("--output")
    ap.add_argument("--codepoints", help="hex separados por coma (ej. 0041,2192)")
    ap.add_argument("--po", action="append", default=[],
                    help="directorio con .po (repetible)")
    ap.add_argument("--report", help="escribir informe JSON aqui")
    ap.add_argument("--medir", action="store_true", help="no escribir la fuente")
    args = ap.parse_args(argv)

    with open(args.input, "rb") as f:
        datos = f.read()

    if args.codepoints:
        cps = set(int(x, 16) for x in args.codepoints.split(",") if x.strip())
    elif args.po:
        cps = codepoints_de_po(args.po)
    else:
        ap.error("hace falta --codepoints o --po")

    if any(c >= 0xFFFF for c in cps):
        print("ERROR: codepoints fuera del BMP no soportados", file=sys.stderr)
        return 1

    try:
        salida, info = subset(datos, cps)
    except Exception as e:                                    # noqa: BLE001
        print("ERROR subsetting: %s" % e, file=sys.stderr)
        return 1

    # Se verifica contra los codepoints que el ORIGEN si mapea: los que el
    # origen no tiene son un dato de cobertura (codepoints_sin_glifo), no un
    # fallo del subsetter. El conjunto esperado no puede quedar vacio.
    esperados = set(c for c in cps if c not in info["codepoints_sin_glifo"])
    checks = verificar(salida, esperados)
    checks.insert(0, {"check": "conjunto esperado no vacio",
                      "ok": len(esperados) > 0,
                      "detalle": "%d de %d pedidos" % (len(esperados), len(cps))})
    fallos = [c for c in checks if not c["ok"]]
    info["checks"] = checks
    info["checks_fallidos"] = len(fallos)
    info["bytes_in"] = len(datos)
    info["bytes_out"] = len(salida)
    info["ratio"] = round(len(salida) / float(len(datos)), 4)
    info["ahorro_pct"] = round(100.0 * (1 - len(salida) / float(len(datos))), 2)
    info["input"] = os.path.basename(args.input)
    info["verificado"] = not fallos

    if fallos:
        print("VERIFICACION FALLIDA:")
        for c in fallos:
            print("  [FAIL] %s %s" % (c["check"], c["detalle"]))
        if args.report:
            with open(args.report, "w", encoding="utf-8", newline="\n") as f:
                json.dump(info, f, indent=2, sort_keys=True)
        return 1

    if not args.medir:
        if not args.output:
            ap.error("hace falta --output (o usar --medir)")
        with open(args.output, "wb") as f:
            f.write(salida)

    print("%s: %d -> %d bytes (%.1f%% menos), glifos %d -> %d, %d codepoints"
          % (info["input"], info["bytes_in"], info["bytes_out"],
             info["ahorro_pct"], info["glyphs_in"], info["glyphs_out"],
             info["codepoints_mapeados"]))
    if info["codepoints_sin_glifo"]:
        print("  sin glifo en el original: %s"
              % ["U+%04X" % c for c in info["codepoints_sin_glifo"]])
    print("  descartadas: %s" % ",".join(info["tablas_descartadas"]))
    print("  checks: %d/%d OK" % (len(checks), len(checks)))

    if args.report:
        with open(args.report, "w", encoding="utf-8", newline="\n") as f:
            json.dump(info, f, indent=2, sort_keys=True)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
