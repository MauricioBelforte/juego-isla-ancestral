#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Auditor del indice maestro de M01 (01-Fundamentos-Del-Proyecto).

Mide los 152 items del indice maestro del plan inicial contra el criterio
documentado del proyecto para poder flipearlos:

    checklist propia 100 % cerrada  Y  fila de CHECKLIST-GLOBAL en estado OK

No escribe nada: solo mide e informa. El flip lo aplica el director.

Uso:
    python scripts/auditar_indice_m01.py             # informe legible
    python scripts/auditar_indice_m01.py --json      # JSON puro (sin texto extra)
    python scripts/auditar_indice_m01.py --check     # exit 1 si hay candidatos nuevos

Codigos de salida:
    0 = medicion completa, sin candidatos nuevos
    1 = medicion completa, CON candidatos nuevos (--check)
    2 = uso invalido
    3 = DETECTOR CIEGO (no se pudo leer una fuente, o leyo 0 items)
"""

import argparse
import json
import os
import re
import sys
import unicodedata

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOC = os.path.join(RAIZ, "DOCUMENTACION")
INDICE = os.path.join(DOC, "01-Fundamentos-Del-Proyecto", "plan-actual", "05-Checklist.md")
GLOBAL = os.path.join(RAIZ, "CHECKLIST-GLOBAL.md")

# Marcas por prefijo de linea (regla del proyecto: contar por prefijo, no por substring).
RE_ITEM = re.compile(r"^\s*-\s+\[([ x?])\]\s+\*\*M(\d{2,3})\*\*\s+(.*)$")
RE_MARCA = re.compile(r"^\s*-\s+\[([ x?\u2192])\]")
RE_CELDA = re.compile(r"(?<!\\)\|")

# Estados del GLOBAL que cuentan como "OK" para el criterio de flip.
ESTADOS_OK = ("\u2705",)  # check mark


def leer_texto(ruta):
    with open(ruta, "rb") as f:
        crudo = f.read()
    if crudo.startswith(b"\xef\xbb\xbf"):
        crudo = crudo[3:]
    return crudo.decode("utf-8", errors="replace")


def normalizar(texto):
    """NFKD sin tildes, minusculas, no-alfanumericos a espacio."""
    t = unicodedata.normalize("NFKD", texto)
    t = "".join(c for c in t if not unicodedata.combining(c))
    t = t.lower()
    t = re.sub(r"[^a-z0-9]+", " ", t)
    return t.strip()


def carpeta_de(numero):
    """Numero de carpeta -> ruta. Formato %02d para <100, %03d para >=100."""
    patron = "%02d-" % numero if numero < 100 else "%03d-" % numero
    if not os.path.isdir(DOC):
        return None
    for nombre in sorted(os.listdir(DOC)):
        if nombre.startswith(patron):
            ruta = os.path.join(DOC, nombre)
            if os.path.isdir(ruta):
                return nombre
    return None


def contar_marcas(ruta):
    """Cuenta marcas por PREFIJO de linea en una checklist. None si no existe."""
    if not os.path.isfile(ruta):
        return None
    conteo = {"x": 0, " ": 0, "?": 0, "\u2192": 0}
    total = 0
    for linea in leer_texto(ruta).splitlines():
        m = RE_MARCA.match(linea)
        if not m:
            continue
        total += 1
        clave = m.group(1)
        if clave in conteo:
            conteo[clave] += 1
    conteo["total"] = total
    return conteo


def leer_global(ruta):
    """id de carpeta -> {modulo, estado, progreso, celdas}."""
    filas = {}
    malformadas = []
    for numero, linea in enumerate(leer_texto(ruta).splitlines(), 1):
        if not linea.lstrip().startswith("|"):
            continue
        celdas = [c.strip() for c in RE_CELDA.split(linea)]
        if len(celdas) < 4:
            continue
        # celdas[0] es la cadena vacia previa al primer pipe
        if not re.fullmatch(r"\d{1,3}", celdas[1]):
            continue
        try:
            cid = int(celdas[1])
        except ValueError:
            continue
        if len(celdas) < 11:
            malformadas.append((numero, len(celdas)))
            continue
        filas[cid] = {
            "modulo": celdas[2],
            "estado": celdas[3],
            "progreso": celdas[4],
            "linea": numero,
            "celdas": len(celdas),
        }
    return filas, malformadas


def leer_indice(ruta):
    items = []
    for numero, linea in enumerate(leer_texto(ruta).splitlines(), 1):
        m = RE_ITEM.match(linea)
        if not m:
            continue
        marca, ident, resto = m.group(1), m.group(2), m.group(3)
        # El resto trae "Titulo [M] PRIORIDAD - descripcion"
        titulo = resto.split("[")[0].strip()
        items.append(
            {
                "id": "M" + ident,
                "num": int(ident),
                "marca": marca,
                "titulo": titulo,
                "linea": numero,
            }
        )
    return items


def evaluar_ceguera(items, filas, carpetas_vistas):
    motivos = []
    if not items:
        motivos.append("no se leyo ningun item del indice maestro")
    if len(items) != 152:
        motivos.append("el indice maestro tiene %d items, se esperaban 152" % len(items))
    if not filas:
        motivos.append("no se leyo ninguna fila de CHECKLIST-GLOBAL")
    if carpetas_vistas == 0:
        motivos.append("no se resolvio ninguna carpeta de modulo")
    return motivos


def medir():
    items = leer_indice(INDICE)
    filas, malformadas = leer_global(GLOBAL)

    registros = []
    carpetas_vistas = 0
    for it in items:
        objetivo = it["num"] + 1
        carpeta = carpeta_de(objetivo)
        reg = {
            "id": it["id"],
            "num": it["num"],
            "marca_indice": it["marca"],
            "titulo": it["titulo"],
            "carpeta_esperada": objetivo,
            "carpeta": carpeta,
            "checklist": None,
            "global": filas.get(objetivo),
        }
        if carpeta:
            carpetas_vistas += 1
            ruta_check = os.path.join(DOC, carpeta, "plan-actual", "05-Checklist.md")
            reg["checklist"] = contar_marcas(ruta_check)
            reg["checklist_existe"] = os.path.isfile(ruta_check)
            # verificacion del mapeo por titulo (evidencia, no premisa)
            reg["titulo_carpeta"] = normalizar(carpeta.split("-", 1)[1].replace("-", " "))
            reg["titulo_item"] = normalizar(it["titulo"])
        else:
            reg["checklist_existe"] = False
            reg["titulo_carpeta"] = ""
            reg["titulo_item"] = normalizar(it["titulo"])
        registros.append(reg)

    ciegos = evaluar_ceguera(items, filas, carpetas_vistas)
    return {
        "items": len(items),
        "carpetas_resueltas": carpetas_vistas,
        "filas_global": len(filas),
        "global_malformadas": malformadas,
        "ciego": ciegos,
        "registros": registros,
    }


def clasificar(datos):
    """Agrega el veredicto por item: cerrada, ok_global, candidato."""
    candidatos = []
    ya_flipeados_validos = []
    ya_flipeados_stale = []
    for r in datos["registros"]:
        ch = r["checklist"]
        glob = r["global"]
        r["cerrada"] = bool(ch) and ch[" "] == 0 and ch["?"] == 0 and ch["total"] > 0
        r["ok_global"] = bool(glob) and glob["estado"].startswith(ESTADOS_OK)
        r["candidato"] = r["cerrada"] and r["ok_global"]
        if r["marca_indice"] == "x":
            if r["candidato"]:
                ya_flipeados_validos.append(r["id"])
            else:
                ya_flipeados_stale.append(r["id"])
        elif r["candidato"]:
            candidatos.append(r["id"])
    datos["candidatos_nuevos"] = candidatos
    datos["flipeados_validos"] = ya_flipeados_validos
    datos["flipeados_stale"] = ya_flipeados_stale
    return datos


UMBRAL_CASI = 5

CATEGORIAS = (
    ("resoluble_headless", "checklist propia cerrada + fila GLOBAL en OK: se puede flipear hoy"),
    ("bloqueado_global", "checklist propia cerrada, fila GLOBAL no OK: la palanca es la FILA"),
    ("bloqueado_checklist", "fila GLOBAL en OK pero checklist propia abierta: el GLOBAL sobre-afirma"),
    ("bloqueado_ambos", "checklist abierta y fila GLOBAL no OK: depende del cierre del modulo"),
    ("sin_checklist", "no existe la checklist del modulo en disco"),
)


def categoria_de(r):
    """Devuelve la condicion que bloquea un item [ ] del indice."""
    if not r.get("checklist_existe"):
        return "sin_checklist"
    if r["candidato"]:
        return "resoluble_headless"
    if r["cerrada"] and not r["ok_global"]:
        return "bloqueado_global"
    if r["ok_global"] and not r["cerrada"]:
        return "bloqueado_checklist"
    return "bloqueado_ambos"


def abiertos_de(r):
    """Items no cerrados de la checklist propia ([ ] + [?]), o None si no hay."""
    ch = r.get("checklist")
    if not ch:
        return None
    return ch[" "] + ch["?"]


def clasificar_pendientes(datos):
    """Clasifica SOLO los items [ ] del indice por la condicion que los bloquea.

    Requiere que `clasificar()` ya haya corrido (usa cerrada/ok_global/candidato).
    """
    grupos = dict((k, []) for k, _ in CATEGORIAS)
    casi = []
    for r in datos["registros"]:
        if r["marca_indice"] != " ":
            r["categoria_pendiente"] = None
            r["abiertos"] = abiertos_de(r)
            continue
        cat = categoria_de(r)
        r["categoria_pendiente"] = cat
        grupos[cat].append(r["id"])
        ab = abiertos_de(r)
        r["abiertos"] = ab
        if cat in ("bloqueado_ambos", "bloqueado_checklist") and ab is not None and 0 < ab <= UMBRAL_CASI:
            casi.append((r["id"], ab))
    casi.sort(key=lambda t: (t[1], t[0]))
    datos["pendientes"] = {
        "total": sum(len(v) for v in grupos.values()),
        "por_categoria": dict((k, len(v)) for k, v in grupos.items()),
        "ids": grupos,
        "casi_cerradas": casi,
        "umbral_casi": UMBRAL_CASI,
    }
    return datos


def informe_pendientes(datos):
    p = datos["pendientes"]
    lineas = []
    lineas.append("=== PENDIENTES DEL INDICE M01, POR BLOQUEO ===")
    lineas.append("items [ ] en el indice : %d" % p["total"])
    lineas.append("")
    for k, desc in CATEGORIAS:
        ids = p["ids"][k]
        lineas.append("[%d] %-20s %s" % (len(ids), k, desc))
        lineas.append("     " + (", ".join(ids) or "(ninguno)"))
    lineas.append("")
    lineas.append("-- CASI CERRADAS (abiertos <= %d): %d --" % (p["umbral_casi"], len(p["casi_cerradas"])))
    for mid, ab in p["casi_cerradas"]:
        lineas.append("   %-5s abiertos=%d" % (mid, ab))
    return "\n".join(lineas)


def informe(datos):
    lineas = []
    lineas.append("=== AUDITOR INDICE MAESTRO M01 ===")
    lineas.append("items del indice        : %d" % datos["items"])
    lineas.append("carpetas resueltas      : %d" % datos["carpetas_resueltas"])
    lineas.append("filas GLOBAL leidas     : %d" % datos["filas_global"])
    lineas.append("filas GLOBAL malformadas: %d" % len(datos["global_malformadas"]))
    if datos["ciego"]:
        lineas.append("[CIEGO] " + " | ".join(datos["ciego"]))
    lineas.append("")
    lineas.append("-- CANDIDATOS NUEVOS (%d) --" % len(datos["candidatos_nuevos"]))
    lineas.append("   " + (", ".join(datos["candidatos_nuevos"]) or "(ninguno)"))
    lineas.append("-- YA FLIPEADOS VALIDOS (%d) --" % len(datos["flipeados_validos"]))
    lineas.append("   " + (", ".join(datos["flipeados_validos"]) or "(ninguno)"))
    lineas.append("-- YA FLIPEADOS STALE (%d) --" % len(datos["flipeados_stale"]))
    lineas.append("   " + (", ".join(datos["flipeados_stale"]) or "(ninguno)"))
    lineas.append("")
    lineas.append("-- DETALLE --")
    lineas.append("%-6s %-3s %-30s %-9s %-9s %s" % ("ID", "FLP", "CARPETA", "CHK", "GLOBAL", "VEREDICTO"))
    for r in datos["registros"]:
        ch = r["checklist"]
        chk = "-" if not ch else "%d/%d/%d" % (ch["x"], ch["?"], ch[" "])
        est = "-" if not r["global"] else r["global"]["estado"][:9]
        ver = []
        if r["cerrada"]:
            ver.append("cerrada")
        if r["ok_global"]:
            ver.append("global-ok")
        if r["candidato"]:
            ver.append("CANDIDATO")
        lineas.append(
            "%-6s %-3s %-30s %-9s %-9s %s"
            % (
                r["id"],
                r["marca_indice"],
                (r["carpeta"] or "SIN CARPETA")[:30],
                chk,
                est,
                ",".join(ver) or "-",
            )
        )
    return "\n".join(lineas)


def main(argv=None):
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--pendientes", action="store_true",
                    help="clasifica los items [ ] del indice por la condicion que los bloquea")
    args = ap.parse_args(argv)

    if not os.path.isfile(INDICE):
        print("DETECTOR CIEGO (exit 3): falta el indice maestro %s" % INDICE)
        return 3
    if not os.path.isfile(GLOBAL):
        print("DETECTOR CIEGO (exit 3): falta CHECKLIST-GLOBAL.md")
        return 3

    datos = clasificar_pendientes(clasificar(medir()))

    if datos["ciego"]:
        if args.json:
            print(json.dumps(datos, ensure_ascii=False, indent=1))
        elif args.pendientes:
            print(informe_pendientes(datos))
        else:
            print(informe(datos))
        return 3

    if args.json:
        print(json.dumps(datos, ensure_ascii=False, indent=1))
    elif args.pendientes:
        print(informe_pendientes(datos))
    else:
        print(informe(datos))

    if args.check and datos["candidatos_nuevos"]:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
