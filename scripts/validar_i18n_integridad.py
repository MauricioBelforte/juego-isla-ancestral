#!/usr/bin/env python3
# Validador de integridad i18n (Bloque C, tarea 27 del backlog Ling-3.1-Flash).
#
# Uso:
#   python scripts/validar_i18n_integridad.py [--json-dir DIR] [--po-dir DIR]
#
# Que hace (report-only, NO modifica nada; exit 0 = limpio, 1 = errores):
#   1. Conteo recursivo de claves de los catálogos JSON (ES/EN/PT).
#   2. UTF-8 estricto, 0 BOM, 0 U+FFFD, 0 CRLF, 0 claves duplicadas.
#   3. Paridad de claves ES<->EN<->PT (faltantes/extra por dirección).
#   4. Paridad de placeholders ({...}) por clave común, por par de idiomas.
#   5. Copias ES->PT no cognadas (valores idénticos sospechosos de no estar
#      traducidos; los cognatos conocidos y los valores neutros se listan aparte).
#   6. Estado cruzado JSON<->.po (comunes / solo-JSON / solo-.po) — insumo de
#      la conciliación bloqueada (msg 153); la divergencia se reporta como
#      ADVERTENCIA, no como error.
#
# Metodología: adaptación python del "control integridad" del estándar 142
# (Tandas 1-6 del canal Ling-3.1-Flash, 2026-10-17). El canon de claves
# usadas en producción sigue siendo AuditorClaves.auditar() (suite M87).
# Nota de conteo (Tanda 7): los controles de Tandas 1-6 reportaron 147
# claves porque su walk incluía la clave de metadatos "idioma" (código de
# locale, no traducible). Este validador cuenta solo las claves traducibles
# bajo "cadenas": 146 por catálogo (121 comunes + 25 solo-JSON).

import argparse
import json
import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JSON_DIR = os.path.join(RAIZ, "game", "isla-ancestral", "data", "localizacion")
PO_DIR = os.path.join(RAIZ, "game", "isla-ancestral", "locales")
IDIOMAS = ("es", "en", "pt")

PLACEHOLDER_RE = re.compile(r"\{[^}]*\}")

COGNADOS_PT_ES = {
    "Visto", "Favorito", "Favoritos", "Filtro", "Todos", "Vistos",
    "Mapa", "Pausa", "Saldo", "Ambiente", "Aplicar", "Buscar",
    "Cancelar", "Confirmar", "Continuar", "Créditos", "Descartar",
    "Música", "Ordenar", "Suave", "Silenciar", "Catálogo", "Comprar",
    "Comprar máx.", "Vender", "Vender máx.", "Cinemáticas",
    "Enter para continuar", "Slots",
}
VALORES_NEUTRALES = {"???", "{tipo}: {item}"}


def cargar_json(ruta):
    with open(ruta, "rb") as f:
        crudo = f.read()
    errores = []
    if crudo.startswith(b"\xef\xbb\xbf"):
        errores.append("BOM UTF-8 presente")
    if b"\r\n" in crudo:
        errores.append("CRLF presente")
    try:
        texto = crudo.decode("utf-8")
    except UnicodeDecodeError as e:
        return None, ["decodificación UTF-8 fallida: %s" % e]
    if "�" in texto:
        errores.append("U+FFFD presente")

    dupes = []

    def hook(pares):
        vistos = {}
        for k, v in pares:
            if k in vistos:
                dupes.append(k)
            vistos[k] = v
        return vistos

    try:
        datos = json.loads(texto, object_pairs_hook=hook)
    except ValueError as e:
        return None, ["JSON inválido: %s" % e]
    if dupes:
        errores.append("claves duplicadas: %s" % ", ".join(sorted(set(dupes))))
    return datos, errores


def claves_recursivo(d, prefijo=""):
    out = []
    for k, v in d.items():
        clave = prefijo + k
        if isinstance(v, dict):
            out += claves_recursivo(v, clave + ".")
        else:
            out.append((clave, v))
    return sorted(out, key=lambda kv: kv[0])


def parse_po(ruta):
    with open(ruta, "rb") as f:
        texto = f.read().decode("utf-8")
    msgids = []
    msgid_actual = None
    en_msgid = False
    for linea in texto.split("\n"):
        if linea.startswith("#~"):
            continue
        m = re.match(r'msgid "(.*)"$', linea)
        if m:
            if en_msgid and msgid_actual is not None:
                msgids.append(msgid_actual)
            msgid_actual = m.group(1)
            en_msgid = True
            continue
        m = re.match(r'"(.*)"$', linea)
        if m and en_msgid and msgid_actual is not None:
            msgid_actual += m.group(1)
            continue
        m = re.match(r'msgstr "(.*)"$', linea)
        if m and en_msgid:
            if msgid_actual:
                msgids.append(msgid_actual)
            msgid_actual = None
            en_msgid = False
    return msgids


def main():
    ap = argparse.ArgumentParser(description="Validador de integridad i18n")
    ap.add_argument("--json-dir", default=JSON_DIR)
    ap.add_argument("--po-dir", default=PO_DIR)
    ap.add_argument("--verbose", action="store_true",
                    help="lista las claves solo-.po (115, insumo conciliación)")
    args = ap.parse_args()

    errores = []
    avisos = []
    catalogos = {}

    print("=== Validador de integridad i18n (M87, Bloque C) ===")
    print("JSON: %s" % args.json_dir)
    print(".po : %s" % args.po_dir)
    print()

    for idioma in IDIOMAS:
        ruta = os.path.join(args.json_dir, "strings_%s.json" % idioma)
        datos, errs = cargar_json(ruta)
        if datos is None:
            print("[%s] ERROR: %s" % (idioma.upper(), "; ".join(errs)))
            errores += errs
            continue
        catalogos[idioma] = claves_recursivo(datos.get("cadenas", datos))
        print("[%s] %d claves" % (idioma.upper(), len(catalogos[idioma])))
        for e in errs:
            print("    ERROR: %s" % e)
            errores.append(e)
    print()

    if len(catalogos) < 2:
        print("ERROR: no hay suficientes catálogos cargados")
        return 1

    print("--- Paridad de claves ---")
    for a, b in (("es", "en"), ("es", "pt"), ("en", "pt")):
        if a not in catalogos or b not in catalogos:
            continue
        ka = {k for k, _ in catalogos[a]}
        kb = {k for k, _ in catalogos[b]}
        solo_a = sorted(ka - kb)
        solo_b = sorted(kb - ka)
        print("%s->%s: %d solo-%s, %d solo-%s"
              % (a, b, len(solo_a), a, len(solo_b), b))
        for k in solo_a:
            print("    solo en %s: %s" % (a, k))
        for k in solo_b:
            print("    solo en %s: %s" % (b, k))
        errores += solo_a + solo_b
    print()

    print("--- Paridad de placeholders por clave común ---")
    disc = 0
    for a, b in (("es", "en"), ("es", "pt")):
        if a not in catalogos or b not in catalogos:
            continue
        va = dict(catalogos[a])
        vb = dict(catalogos[b])
        for k in sorted(set(va) & set(vb)):
            pa = set(PLACEHOLDER_RE.findall(str(va[k])))
            pb = set(PLACEHOLDER_RE.findall(str(vb[k])))
            if pa != pb:
                disc += 1
                print("    %s: %s tiene %s, %s tiene %s"
                      % (k, a, sorted(pa), b, sorted(pb)))
    print("discrepancias: %d" % disc)
    errores += ["placeholder"] * disc
    print()

    if "es" in catalogos and "pt" in catalogos:
        print("--- Copias ES->PT (valores idénticos) ---")
        ve = dict(catalogos["es"])
        vp = dict(catalogos["pt"])
        cogn = []
        sospechosos = []
        for k in sorted(set(ve) & set(vp)):
            if ve[k] == vp[k]:
                if ve[k] in COGNADOS_PT_ES or ve[k] in VALORES_NEUTRALES:
                    cogn.append((k, ve[k]))
                else:
                    sospechosos.append((k, ve[k]))
        print("cognatos/neutrales (ok): %d" % len(cogn))
        print("sospechosos de copia no traducida: %d" % len(sospechosos))
        for k, v in sospechosos:
            print("    REVISAR %s = %r" % (k, v))
        avisos += ["copia-ES:%s" % k for k, _ in sospechosos]
        print()

    print("--- Estado cruzado JSON<->.po (insumo conciliación msg 153) ---")
    claves_json = set()
    for idioma in catalogos:
        claves_json |= {k for k, _ in catalogos[idioma]}
    msgids_po = set()
    po_path = os.path.join(args.po_dir, "es.po")
    if os.path.exists(po_path):
        msgids_po = {m for m in parse_po(po_path) if m}
    comunes = sorted(claves_json & msgids_po)
    solo_json = sorted(claves_json - msgids_po)
    solo_po = sorted(msgids_po - claves_json)
    print("comunes: %d | solo-JSON: %d | solo-.po: %d"
          % (len(comunes), len(solo_json), len(solo_po)))
    for k in solo_json:
        print("    solo-JSON: %s" % k)
    if args.verbose:
        for k in solo_po:
            print("    solo-.po: %s" % k)
    else:
        print("    (las %d solo-.po se listan con --verbose)" % len(solo_po))
    avisos.append("divergencia po/json: %d/%d/%d" % (len(comunes), len(solo_json), len(solo_po)))
    print()

    print("=== VEREDICTO ===")
    if errores:
        print("ERROR: %d problema(s) estructural(es) — revisar arriba" % len(errores))
        return 1
    print("LIMPIO: estructura íntegra. %d advertencia(s) informativa(s)."
          % len(avisos))
    for a in avisos:
        print("  aviso: %s" % a)
    return 0


if __name__ == "__main__":
    sys.exit(main())
