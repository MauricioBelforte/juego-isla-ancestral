#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.
# -*- coding: utf-8 -*-
"""M127 iter. 4 -- Empaquetado del deposito para el registro formal (USCO).

Implementa **37 CFR 202.20(c)(2)(vii)** (deposito de programas de computadora en
soportes legibles por maquina). El item de la checklist pedia "automatizar el
empaquetado de codigo y muestras visuales segun formatos y limites USCO" y
citaba `03-Diseno.md 4.2`: **esa seccion no existia**. La especificacion real
ahora vive en `03-Diseno.md 4.1-4.4` y este script la ejecuta.

Reglas de CODIGO (4.1):
  * <= 50 paginas  -> se deposita TODO el codigo fuente.
  * >  50 paginas  -> PRIMERAS 25 + ULTIMAS 25 paginas (o unidades equivalentes)
                      + la pagina que contiene el aviso de copyright.

Reglas de CODIGO CON SECRETOS (4.2), invariant de admisibilidad:
  `tachado < visible`  Y  `visible > 0`.
  No es una recomendacion: un deposito donde lo tachado no deja ver una cantidad
  apreciable de codigo original es inadmisible.

Reglas de MUESTRAS VISUALES (4.3):
  reproducciones no menores a 3x3 pulgadas ni mayores a 9x12 pulgadas.
  Es un limite de tamano FISICO: px -> pulgadas necesita el DPI declarado, y el
  validador lo EXIGE en vez de adivinarlo.

Unidad equivalente: el reglamento no fija el alto de pagina. Este proyecto adopta
50 lineas por pagina (`PAGINAS_POR_UNIDAD`), configurable, y el informe SIEMPRE
declara cual se uso: de ese numero depende que regla aplica.

Uso:
    python tools/legal/empaquetar_deposito_usco.py --plan
    python tools/legal/empaquetar_deposito_usco.py --emitir <dir>
    python tools/legal/empaquetar_deposito_usco.py --check
    python tools/legal/empaquetar_deposito_usco.py --json
    python tools/legal/empaquetar_deposito_usco.py --selftest

Exit: 0 = conforme / 1 = viola un limite / 3 = CIEGO (no encontro fuentes que
medir: "0 hallazgos" sin haber medido no es un aprobado).
"""

import argparse
import hashlib
import io
import json
import math
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(HERE, "..", ".."))
ALCANCE = os.path.join(HERE, "deposito_usco_scope.json")

# --- 4.1 / 4.2 ---
PAGINAS_POR_UNIDAD = 50      # lineas de codigo por "pagina o unidad equivalente"
PAGINAS_PRIMERAS = 25
PAGINAS_ULTIMAS = 25
UMBRAL_COMPLETO = 50         # <= 50 paginas -> todo el fuente
MODO_COMPLETO = "completo"
MODO_RECORTE = "primeras+ultimas"

# --- 4.3 ---
VISUAL_MIN_PULG = (3.0, 3.0)
VISUAL_MAX_PULG = (9.0, 12.0)

# --- 4.4 ---
LIMITE_METADATA = 0.10       # el metadata no debe pasar del 10% del paquete

MAGIC = {
    ".png": (0, b"\x89PNG\r\n\x1a\n"),
    ".jpg": (0, b"\xff\xd8\xff"),
    ".jpeg": (0, b"\xff\xd8\xff"),
}


def leer_bytes(p):
    with open(p, "rb") as f:
        return f.read()


def leer_texto(p):
    with io.open(p, "r", encoding="utf-8", errors="replace", newline="") as f:
        return f.read()


# --------------------------------------------------------------------------
# 4.1 Plan de deposito de codigo
# --------------------------------------------------------------------------

def paginas_de(n_lineas, ppu=PAGINAS_POR_UNIDAD):
    """Paginas (o unidades equivalentes) que ocupa un texto de n_lineas.

    0 lineas -> 0 paginas (no se deposita "nada"); si hay contenido, minimo 1.
    """
    if n_lineas <= 0:
        return 0
    return max(1, int(math.ceil(float(n_lineas) / float(ppu))))


def modo_de(n_paginas):
    if n_paginas <= UMBRAL_COMPLETO:
        return MODO_COMPLETO
    return MODO_RECORTE


def plan_codigo(n_paginas, ppu=PAGINAS_POR_UNIDAD, pagina_aviso=None):
    """Que paginas hay que depositar. Devuelve rangos 1-based inclusive."""
    modo = modo_de(n_paginas)
    if modo == MODO_COMPLETO:
        rangos = [(1, n_paginas)] if n_paginas > 0 else []
    else:
        rangos = [(1, PAGINAS_PRIMERAS),
                  (n_paginas - PAGINAS_ULTIMAS + 1, n_paginas)]
    # La pagina del aviso se agrega SIEMPRE (4.1) y se evita duplicarla.
    if pagina_aviso is not None and 1 <= pagina_aviso <= n_paginas:
        if not any(a <= pagina_aviso <= b for a, b in rangos):
            rangos.append((pagina_aviso, pagina_aviso))
    rangos.sort()
    return {"modo": modo, "paginas_totales": n_paginas, "ppu": ppu,
            "rangos": rangos, "unidades": sum(b - a + 1 for a, b in rangos)}


def pagina_del_aviso(texto, ppu=PAGINAS_POR_UNIDAD):
    """1-based; None si el texto no lleva aviso de copyright."""
    for i, linea in enumerate(texto.split("\n")):
        if "SPDX-License-Identifier:" in linea or "Copyright (c)" in linea:
            return i // ppu + 1
    return None


# --------------------------------------------------------------------------
# 4.2 Invariante de tachado
# --------------------------------------------------------------------------

def verificar_tachado(tachado, visible):
    """(ok, motivo). Invariant: tachado < visible  Y  visible > 0."""
    if visible <= 0:
        return False, "no queda codigo original visible (visible=%d)" % visible
    if tachado >= visible:
        return False, ("lo tachado (%d) no es proporcionalmente menor que lo "
                       "restante (%d)" % (tachado, visible))
    return True, "tachado=%d < visible=%d (cantidad apreciable conservada)" % (tachado, visible)


# --------------------------------------------------------------------------
# 4.3 Muestras visuales: dimensiones desde la CABECERA del archivo
# --------------------------------------------------------------------------

def dimensiones_png(b):
    """IHDR: ancho/alto big-endian uint32 en los bytes 16..24."""
    if len(b) < 24 or b[12:16] != b"IHDR":
        return None
    ancho, alto = struct.unpack(">II", b[16:24])
    return int(ancho), int(alto)


def dimensiones_jpeg(b):
    """Recorre segmentos hasta un SOF (0xC0-0xCF salvo C4/C8/CC)."""
    if len(b) < 4:
        return None
    pos = 2
    while pos + 9 < len(b):
        if b[pos] != 0xFF:
            pos += 1
            continue
        marca = b[pos + 1]
        if marca in (0xD8, 0xD9) or 0xD0 <= marca <= 0xD7:
            pos += 2
            continue
        largo = struct.unpack(">H", b[pos + 2:pos + 4])[0]
        if marca in (0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7,
                     0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF):
            alto, ancho = struct.unpack(">HH", b[pos + 5:pos + 9])
            return int(ancho), int(alto)
        if largo <= 0:
            return None
        pos += 2 + largo
    return None


def dimensiones(ruta):
    """(ancho, alto) leidos de la cabecera real, o None. NO usa metadatos
    declarados: un archivo con extension valida puede ser otra cosa (BUG-042)."""
    try:
        b = leer_bytes(ruta)
    except OSError:
        return None
    ext = os.path.splitext(ruta)[1].lower()
    firma = MAGIC.get(ext)
    if firma and not b[firma[0]:firma[0] + len(firma[1])] == firma[1]:
        return None
    if ext == ".png":
        return dimensiones_png(b)
    if ext in (".jpg", ".jpeg"):
        return dimensiones_jpeg(b)
    return None


def verificar_visual(ancho_px, alto_px, dpi):
    """(ok, motivo, (w_pulg, h_pulg)). Limite FISICO: 3x3 .. 9x12 pulgadas."""
    if not dpi or dpi <= 0:
        return False, "falta el DPI declarado (el limite es fisico, no de pixeles)", (0.0, 0.0)
    w = ancho_px / float(dpi)
    h = alto_px / float(dpi)
    if w < VISUAL_MIN_PULG[0] or h < VISUAL_MIN_PULG[1]:
        return False, ("%.2f x %.2f pulgadas: menor al minimo %.0fx%.0f"
                       % (w, h, VISUAL_MIN_PULG[0], VISUAL_MIN_PULG[1])), (w, h)
    if w > VISUAL_MAX_PULG[0] or h > VISUAL_MAX_PULG[1]:
        return False, ("%.2f x %.2f pulgadas: excede el maximo %.0fx%.0f"
                       % (w, h, VISUAL_MAX_PULG[0], VISUAL_MAX_PULG[1])), (w, h)
    return True, "%.2f x %.2f pulgadas (dentro de 3x3..9x12)" % (w, h), (w, h)


# --------------------------------------------------------------------------
# Alcance y recoleccion
# --------------------------------------------------------------------------

def alcance_por_defecto():
    return {"version": 1, "paginas_por_unidad": PAGINAS_POR_UNIDAD,
            "codigo": {"extensiones": [".gd", ".py"], "incluir": [], "excluir": []},
            "secretos": {"activo": False, "opcion": "a", "tachado_lineas": 0,
                         "visible_lineas": 0},
            "visuales": [], "limite_metadata": LIMITE_METADATA, "deuda": []}


def cargar_alcance():
    try:
        with io.open(ALCANCE, "r", encoding="utf-8") as f:
            data = json.load(f)
        base = alcance_por_defecto()
        base.update(data)
        return base
    except (OSError, ValueError):
        return alcance_por_defecto()


def _norm(p):
    return p.replace("\\", "/")


def es_excluido(rel, excluir):
    rel = _norm(rel)
    partes = rel.split("/")
    for pat in excluir:
        pat = _norm(pat).rstrip("/")
        if not pat:
            continue
        if rel == pat or rel.startswith(pat + "/"):
            return True
        if "/" not in pat and pat in partes:
            return True
    return False


def fuentes_en_alcance(codigo):
    ext = [e.lower() for e in codigo.get("extensiones", [".gd", ".py"])]
    excluir = list(codigo.get("excluir", []))
    out = []
    for item in codigo.get("incluir", []):
        abs_item = os.path.join(RAIZ, _norm(item).replace("/", os.sep))
        if os.path.isfile(abs_item):
            if os.path.splitext(item)[1].lower() in ext:
                out.append(_norm(item))
            continue
        if not os.path.isdir(abs_item):
            continue
        for base, dirs, files in os.walk(abs_item):
            dirs[:] = sorted(d for d in dirs if d != "__pycache__")
            for nombre in sorted(files):
                if os.path.splitext(nombre)[1].lower() not in ext:
                    continue
                rel = _norm(os.path.relpath(os.path.join(base, nombre), RAIZ))
                if not es_excluido(rel, excluir):
                    out.append(rel)
    vistos, salida = set(), []
    for r in out:
        if r not in vistos:
            vistos.add(r)
            salida.append(r)
    return sorted(salida)


def flujo_fuente(fuentes):
    """Concatena las fuentes en un unico flujo logico ("el programa")."""
    partes = []
    for rel in fuentes:
        try:
            texto = leer_texto(os.path.join(RAIZ, rel.replace("/", os.sep)))
        except OSError:
            continue
        partes.append("// ==== %s ====\n" % rel + texto)
    return "\n".join(partes)


def evaluar_ceguera(fuentes, n_lineas, visuales, limites_visuales):
    """Motivos por los que el informe no vale. Vacio = se midio de verdad."""
    motivos = []
    if not fuentes:
        motivos.append("no se resolvio ninguna fuente de codigo en el alcance")
    if fuentes and n_lineas == 0:
        motivos.append("se listaron %d fuentes pero el flujo tiene 0 lineas" % len(fuentes))
    if visuales and not limites_visuales:
        motivos.append("%d muestras visuales declaradas pero 0 con dimensiones legibles"
                       % len(visuales))
    return motivos


# --------------------------------------------------------------------------
# Informe
# --------------------------------------------------------------------------

def analizar(alcance):
    codigo = alcance.get("codigo", {})
    ppu = int(alcance.get("paginas_por_unidad", PAGINAS_POR_UNIDAD) or PAGINAS_POR_UNIDAD)
    fuentes = fuentes_en_alcance(codigo)
    flujo = flujo_fuente(fuentes)
    n_lineas = len(flujo.split("\n")) if flujo else 0
    n_paginas = paginas_de(n_lineas, ppu)
    aviso = pagina_del_aviso(flujo, ppu)
    plan = plan_codigo(n_paginas, ppu, aviso)

    sec = alcance.get("secretos", {})
    ok_tachado, motivo_tachado = verificar_tachado(
        int(sec.get("tachado_lineas", 0) or 0), int(sec.get("visible_lineas", 0) or 0))

    visuales = list(alcance.get("visuales", []))
    limites_visuales = []
    for v in visuales:
        ruta = v.get("ruta", "")
        dpi = v.get("dpi")
        dim = dimensiones(os.path.join(RAIZ, _norm(ruta).replace("/", os.sep)))
        if dim is None:
            limites_visuales.append({"ruta": ruta, "ok": False,
                                     "motivo": "no se pudieron leer dimensiones reales "
                                               "de la cabecera (puede no ser una imagen)"})
            continue
        ok, motivo, (w, h) = verificar_visual(dim[0], dim[1], dpi)
        limites_visuales.append({"ruta": ruta, "px": [dim[0], dim[1]], "dpi": dpi,
                                 "pulgadas": [round(w, 3), round(h, 3)],
                                 "ok": ok, "motivo": motivo})

    ciegos = evaluar_ceguera(fuentes, n_lineas, visuales, [x for x in limites_visuales if x.get("px")])

    violaciones = []
    if sec.get("activo") and not ok_tachado:
        violaciones.append({"clave": "4.2|secretos", "detalle": motivo_tachado})
    for lv in limites_visuales:
        if not lv["ok"]:
            violaciones.append({"clave": "4.3|visual|%s" % lv["ruta"], "detalle": lv["motivo"]})

    return {"paginas_por_unidad": ppu, "fuentes": fuentes, "lineas": n_lineas,
            "paginas": n_paginas, "pagina_del_aviso": aviso, "plan": plan,
            "secretos": {"activo": bool(sec.get("activo")), "opcion": sec.get("opcion", "a"),
                         "ok": ok_tachado, "motivo": motivo_tachado},
            "visuales": limites_visuales, "violaciones": violaciones,
            "deuda": list(alcance.get("deuda", [])),
            "limite_metadata": float(alcance.get("limite_metadata", LIMITE_METADATA)
                                     or LIMITE_METADATA),
            "ciego": ciegos}


def verificar_metadata(bytes_meta, bytes_total, limite=LIMITE_METADATA):
    """(ok, motivo, ratio). El metadata no debe engordar el paquete (4.4)."""
    if bytes_total <= 0:
        return False, "paquete vacio: no hay nada que medir", 0.0
    ratio = float(bytes_meta) / float(bytes_total)
    return (ratio <= limite,
            "metadata %.1f%% del paquete (limite %.0f%%)" % (ratio * 100.0, limite * 100.0),
            ratio)


def emitir(res, destino):
    """Escribe el deposito: el recorte de codigo + un manifiesto."""
    os.makedirs(destino, exist_ok=True)
    flujo = flujo_fuente(res["fuentes"])
    lineas = flujo.split("\n")
    ppu = res["paginas_por_unidad"]
    trozos = []
    for a, b in res["plan"]["rangos"]:
        trozos.append("// ---- paginas %d..%d ----" % (a, b))
        trozos.extend(lineas[(a - 1) * ppu: b * ppu])
    ruta_dep = os.path.join(destino, "deposito_codigo.txt")
    with io.open(ruta_dep, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(trozos) + "\n")
    # La LISTA de fuentes es parte del material depositado, no metadata: va en su
    # propio archivo. El manifiesto guarda solo el conteo y un hash. Meter 891
    # rutas en el manifiesto lo inflaba al 37,6% del paquete (medido) y violaba
    # la regla 4.4 que este mismo script comprueba.
    ruta_fue = os.path.join(destino, "fuentes.txt")
    crudo_fue = ("\n".join(res["fuentes"]) + "\n").encode("utf-8")
    with open(ruta_fue, "wb") as f:
        f.write(crudo_fue)

    manifiesto = {
        "norma": "37 CFR 202.20(c)(2)(vii)",
        "paginas_por_unidad": ppu, "paginas_totales": res["paginas"],
        "modo": res["plan"]["modo"], "rangos": res["plan"]["rangos"],
        "unidades_depositadas": res["plan"]["unidades"],
        "pagina_del_aviso": res["pagina_del_aviso"],
        "fuentes_total": len(res["fuentes"]),
        "fuentes_sha256": hashlib.sha256(crudo_fue).hexdigest(),
        "lineas_totales": res["lineas"],
        "secretos": res["secretos"], "visuales": res["visuales"],
    }
    # 4.4: el metadata no debe engordar el paquete. Se mide EN LA EMISION, porque
    # antes de emitir el paquete no existe; `--check` no puede comprobarlo.
    crudo_man = json.dumps(manifiesto, indent=2, ensure_ascii=False).encode("utf-8")
    bytes_dep = os.path.getsize(ruta_dep) + len(crudo_fue)
    ok_meta, motivo_meta, ratio = verificar_metadata(
        len(crudo_man), len(crudo_man) + bytes_dep,
        float(res.get("limite_metadata", LIMITE_METADATA) or LIMITE_METADATA))
    manifiesto["paquete"] = {"bytes_deposito": bytes_dep, "bytes_metadata": len(crudo_man),
                             "ratio_metadata": round(ratio, 6), "metadata_ok": ok_meta,
                             "motivo": motivo_meta}

    ruta_man = os.path.join(destino, "manifiesto.json")
    with io.open(ruta_man, "w", encoding="utf-8", newline="\n") as f:
        json.dump(manifiesto, f, indent=2, ensure_ascii=False)
    return ruta_dep, ruta_man


def clasificar_violaciones(violaciones, deuda):
    """Separa hallazgos NUEVOS de deuda DECLARADA, y detecta deuda obsoleta.

    Patron del proyecto: una excepcion invisible es un agujero negro, asi que
    cada deuda lleva `clave`/`motivo`/`dueno` y solo `--check` falla ante una
    clave NO declarada. La deuda que ya no ocurre se reporta (no se deja podrir).
    """
    declaradas = {}
    for d in deuda or []:
        declaradas[d.get("clave", "")] = d
    activas = [v["clave"] for v in violaciones]
    nuevas = [v for v in violaciones if v["clave"] not in declaradas]
    vigentes = [v for v in violaciones if v["clave"] in declaradas]
    obsoletas = [c for c in declaradas if c not in activas]
    return nuevas, vigentes, obsoletas


def imprimir_plan(res):
    p = res["plan"]
    print("[deposito USCO] 37 CFR 202.20(c)(2)(vii)")
    print("  unidad: %d lineas/pagina (declarado, no supuesto)" % res["paginas_por_unidad"])
    print("  fuentes en alcance: %d | lineas: %d | paginas: %d"
          % (len(res["fuentes"]), res["lineas"], res["paginas"]))
    if res["pagina_del_aviso"]:
        print("  pagina del aviso de copyright: %d" % res["pagina_del_aviso"])
    else:
        print("  pagina del aviso de copyright: NINGUNA (4.1 la exige si existe)")
    print("  modo 4.1: %s" % p["modo"])
    for a, b in p["rangos"]:
        print("     paginas %d..%d" % (a, b))
    print("  unidades depositadas: %d" % p["unidades"])
    s = res["secretos"]
    if s["activo"]:
        print("  secreto comercial 4.2: opcion (%s) %s -> %s"
              % (s["opcion"], "OK" if s["ok"] else "VIOLA", s["motivo"]))
    for lv in res["visuales"]:
        print("  visual 4.3 %s: %s" % (lv["ruta"], lv["motivo"]))
    if not res["visuales"]:
        print("  visual 4.3: 0 muestras declaradas (el limite se ejercita en --selftest)")


def main():
    p = argparse.ArgumentParser(description="Empaquetado del deposito USCO (M127)")
    p.add_argument("--plan", action="store_true", help="que se depositaria")
    p.add_argument("--emitir", metavar="DIR", help="construye el deposito en DIR")
    p.add_argument("--check", action="store_true", help="exit 1 si viola un limite")
    p.add_argument("--json", action="store_true")
    p.add_argument("--selftest", action="store_true")
    a = p.parse_args()

    if a.selftest:
        return selftest()

    alcance = cargar_alcance()
    res = analizar(alcance)
    nuevas, vigentes, obsoletas = clasificar_violaciones(res["violaciones"], alcance.get("deuda"))

    # --json debe imprimir SOLO JSON: si despues se agregan lineas de texto, el
    # consumidor recibe "Extra data" y el JSON no parsea (medido en la suite).
    if a.json:
        salida = dict(res)
        salida["violaciones_nuevas"] = nuevas
        salida["deuda_vigente"] = vigentes
        salida["deuda_obsoleta"] = obsoletas
        print(json.dumps(salida, indent=2, ensure_ascii=False))
        if res["ciego"]:
            return 3
        return 1 if (nuevas and a.check) else 0

    imprimir_plan(res)

    if res["ciego"]:
        print("[deposito USCO] DETECTOR CIEGO (exit 3):")
        for m in res["ciego"]:
            print("   - %s" % m)
        return 3

    if a.emitir:
        d, m = emitir(res, a.emitir)
        print("  emitido: %s" % d)
        print("  emitido: %s" % m)

    for v in vigentes:
        d = [x for x in alcance.get("deuda", []) if x.get("clave") == v["clave"]][0]
        print("  DEUDA DECLARADA %s -> %s" % (v["clave"], v["detalle"]))
        print("      motivo: %s | dueno: %s" % (d.get("motivo", "N/A"), d.get("dueno", "N/A")))
    for v in nuevas:
        print("  VIOLA: %s -> %s" % (v["clave"], v["detalle"]))
    for c in obsoletas:
        print("  [aviso] deuda declarada que YA NO ocurre (revisar el techo): %s" % c)

    if nuevas:
        return 1 if a.check else 0
    print("  conforme: 0 violaciones nuevas (%d deuda declarada)" % len(vigentes))
    return 0


# --------------------------------------------------------------------------
# Selftest: se prueba EN ROJO antes de confiar en el gate
# --------------------------------------------------------------------------

CHECKS_MINIMOS = 42   # MEDIDO en verde (42/42), no estimado


def primer_png_real():
    """Primer PNG real del repo: el parser debe probarse contra bytes DE VERDAD,
    no solo contra fixtures sinteticos (un asset con extension valida puede ser
    otra cosa: BUG-042)."""
    raices = [os.path.join(RAIZ, "tools", "mcp", "blender-mcp", "NPC_EXPORT"),
              os.path.join(RAIZ, "game", "isla-ancestral", "assets")]
    for raiz in raices:
        if not os.path.isdir(raiz):
            continue
        for base, dirs, files in os.walk(raiz):
            dirs[:] = sorted(d for d in dirs if d != "__pycache__")
            for nombre in sorted(files):
                if nombre.lower().endswith(".png"):
                    return os.path.join(base, nombre)
    return None


def _png(ancho, alto):
    """PNG minimo con IHDR real (ancho/alto big-endian)."""
    ihdr = struct.pack(">II", ancho, alto) + b"\x08\x06\x00\x00\x00"
    def chunk(tipo, datos):
        return struct.pack(">I", len(datos)) + tipo + datos + b"\x00\x00\x00\x00"
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IEND", b"")


def _jpeg(ancho, alto):
    """JPEG minimo con un SOF0 real."""
    return (b"\xff\xd8"
            + b"\xff\xe0" + struct.pack(">H", 16) + b"JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00"
            + b"\xff\xc0" + struct.pack(">H", 17) + b"\x08"
            + struct.pack(">HH", alto, ancho) + b"\x03\x01\x11\x00\x02\x11\x01\x03\x11\x01"
            + b"\xff\xd9")


def selftest():
    t = []

    def chk(ok, msg):
        t.append((bool(ok), msg))

    # --- 4.1 paginas y modo (frontera 50/51) ---
    chk(paginas_de(0) == 0, "paginas_de(0)=0 (nada que depositar)")
    chk(paginas_de(1) == 1, "paginas_de(1)=1 (minimo 1 pagina con contenido)")
    chk(paginas_de(2500) == 50, "paginas_de(2500 lineas)=50 con 50 lineas/pagina")
    chk(paginas_de(2501) == 51, "paginas_de(2501)=51 (cruza la frontera)")
    chk(modo_de(50) == MODO_COMPLETO, "50 paginas -> regla 'todo el fuente' (frontera)")
    chk(modo_de(51) == MODO_RECORTE, "51 paginas -> regla 'primeras+ultimas' (frontera)")
    chk(plan_codigo(50)["unidades"] == 50, "50 paginas -> deposita las 50")
    chk(plan_codigo(51)["rangos"] == [(1, 25), (27, 51)], "51 paginas -> 1..25 y 27..51")
    chk(plan_codigo(51)["unidades"] == 50, "51 paginas -> 50 unidades (25+25)")
    chk(plan_codigo(200)["rangos"] == [(1, 25), (176, 200)], "200 paginas -> 1..25 y 176..200")
    # La pagina del aviso se agrega y NO se duplica.
    chk(plan_codigo(200, pagina_aviso=1)["rangos"] == [(1, 25), (176, 200)],
        "aviso en pagina ya incluida -> no se duplica")
    chk(plan_codigo(200, pagina_aviso=100)["rangos"] == [(1, 25), (100, 100), (176, 200)],
        "aviso en pagina intermedia -> se agrega")
    chk(pagina_del_aviso("x\ny\n# SPDX-License-Identifier: X\n") == 1,
        "pagina_del_aviso localiza el SPDX en la 1a pagina")
    chk(pagina_del_aviso("a" * 6000) is None, "sin aviso -> None (no se inventa)")

    # --- 4.2 invariante de tachado ---
    ok, _ = verificar_tachado(10, 100)
    chk(ok, "tachado 10 < visible 100 -> admisible")
    ok, m = verificar_tachado(100, 10)
    chk(not ok and "proporcionalmente menor" in m, "tachado 100 > visible 10 -> INADMISIBLE")
    ok, _ = verificar_tachado(50, 50)
    chk(not ok, "tachado == visible -> INADMISIBLE (no es 'menor')")
    ok, m = verificar_tachado(0, 0)
    chk(not ok and "visible" in m, "visible 0 -> INADMISIBLE (sin cantidad apreciable)")
    ok, _ = verificar_tachado(0, 1)
    chk(ok, "visible 1 > 0 y tachado 0 -> admisible (caso minimo)")

    # --- 4.3 dimensiones REALES desde cabecera (no metadatos) ---
    chk(dimensiones_png(_png(1200, 900)) == (1200, 900), "PNG: lee ancho/alto de IHDR")
    chk(dimensiones_jpeg(_jpeg(800, 600)) == (800, 600), "JPEG: lee ancho/alto de SOF0")
    chk(dimensiones_png(b"<html>no soy un png</html>") is None,
        "bytes que no son PNG -> None (no se fia de la extension)")
    chk(dimensiones_jpeg(b"\xff\xd8\xff\xd9") is None, "JPEG sin SOF -> None")

    ok, _, (w, h) = verificar_visual(1200, 900, 300)
    chk(ok and abs(w - 4.0) < 0.01, "1200x900 px @300dpi = 4.0x3.0 in -> dentro del rango")
    ok, m, _ = verificar_visual(3000, 900, 300)
    chk(not ok and "excede" in m, "10.0 in de ancho @300dpi -> EXCEDE el maximo de 9")
    ok, m, _ = verificar_visual(600, 600, 300)
    chk(not ok and "menor al minimo" in m, "2.0x2.0 in @300dpi -> menor al minimo de 3")
    ok, m, _ = verificar_visual(1200, 900, 0)
    chk(not ok and "DPI" in m, "sin DPI -> falla (el limite es fisico, no de pixeles)")

    # --- Control negativo: extension valida con contenido ajeno ---
    chk(dimensiones_png(_png(100, 100)) == (100, 100), "control positivo de PNG antes del negativo")
    chk(dimensiones(os.path.join(RAIZ, "tools", "legal", "headers_scope.json")) is None,
        "un .json del propio repo -> None (no cuenta como imagen)")

    # --- El parser contra bytes REALES del repo (no solo fixtures) ---
    png_real = primer_png_real()
    chk(png_real is not None, "se encontro un PNG real del repo para el control positivo")
    if png_real:
        dim = dimensiones(png_real)
        chk(dim is not None and dim[0] >= 16 and dim[1] >= 16,
            "lee un PNG REAL: %s -> %s px" % (os.path.basename(png_real), dim))
    else:
        chk(False, "sin PNG real: el control positivo contra bytes reales NO se ejecuto")

    # --- Techo de deuda: solo una clave NO declarada rompe el gate ---
    v = [{"clave": "4.3|visual|x.png", "detalle": "2.56 in < 3 in"}]
    n, vig, obs = clasificar_violaciones(v, [])
    chk(n == v and vig == [] and obs == [], "sin deuda declarada -> el hallazgo es NUEVO")
    n, vig, obs = clasificar_violaciones(v, [{"clave": "4.3|visual|x.png", "motivo": "m", "dueno": "d"}])
    chk(n == [] and len(vig) == 1 and obs == [], "deuda declarada -> no es nuevo y queda vigente")
    n, vig, obs = clasificar_violaciones([], [{"clave": "4.3|visual|x.png"}])
    chk(n == [] and vig == [] and obs == ["4.3|visual|x.png"],
        "deuda declarada que ya no ocurre -> se reporta como obsoleta")
    n, vig, obs = clasificar_violaciones(v + [{"clave": "4.2|secretos", "detalle": "x"}],
                                        [{"clave": "4.3|visual|x.png"}])
    chk(len(n) == 1 and n[0]["clave"] == "4.2|secretos",
        "con 1 deuda declarada, la clave ajena sigue siendo NUEVA (rompe el gate)")

    # --- 4.4 el metadata no debe engordar el paquete ---
    ok, m, ratio = verificar_metadata(1, 100)
    chk(ok and abs(ratio - 0.01) < 1e-9, "metadata 1% del paquete -> dentro del limite")
    ok, m, _ = verificar_metadata(20, 100)
    chk(not ok and "limite" in m, "metadata 20% del paquete -> EXCEDE el limite de 10%")
    ok, m, _ = verificar_metadata(0, 0)
    chk(not ok and "vacio" in m, "paquete vacio -> NO se declara conforme")

    # --- Guarda de ceguera (probada EN ROJO) ---
    chk(len(evaluar_ceguera([], 0, [], [])) >= 1, "0 fuentes -> la ceguera se declara")
    chk(len(evaluar_ceguera(["a.gd"], 0, [], [])) >= 1,
        "fuentes listadas pero 0 lineas -> la ceguera se declara")
    chk(evaluar_ceguera(["a.gd"], 10, [], []) == [],
        "control negativo: fuentes con lineas -> NO ciego")
    chk(len(evaluar_ceguera([], 0, [{"ruta": "x.png"}], [])) >= 1,
        "visual declarada pero ilegible -> la ceguera se declara")

    # --- Plan real del repo: debe medir algo (no ciego) ---
    res = analizar(cargar_alcance())
    chk(len(res["fuentes"]) > 0, "el alcance real resuelve fuentes (%d)" % len(res["fuentes"]))
    chk(res["paginas"] > 0, "el repo real ocupa %d paginas" % res["paginas"])
    chk(res["ciego"] == [], "el analisis real NO es ciego")

    fallos = 0
    for ok, msg in t:
        print("  [%s] %s" % ("OK" if ok else "FAIL", msg))
        if not ok:
            fallos += 1
    print("=== Resumen M127 empaquetar_deposito_usco --selftest: %d/%d OK ===" % (len(t) - fallos, len(t)))
    if len(t) < CHECKS_MINIMOS:
        print("  [FAIL] guardian: solo %d checks (minimo %d)" % (len(t), CHECKS_MINIMOS))
        return 1
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
