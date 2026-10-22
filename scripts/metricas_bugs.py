#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
#
# M102-Bug-Tracking / item 31 de la COLA ACTIVA de DeepSeek-V4.1-Flash
# "unificar metricas con 11-BUGS.md (reporte automatico)".
#
# DeepSeek-V4.1-Flash (WorkBuddy) - 2026-10-21 - Log 2080
#
# POR QUE EXISTE
# -------------
# `docs/bug_metrics.md` y `.github/workflows/bug_metrics.yml` miden SOLO GitHub
# Issues. El registro real del proyecto es `DOCUMENTACION/11-BUGS.md`, que hoy
# no lo lee ninguna herramienta de metricas: `scripts/verificar_bugs_gate.py`
# lo abre, pero solo para bloquear P0/P1 abiertos (no cuenta nada). Resultado:
# hay dos universos de bugs y ninguno manda.
#
# Este script unifica las metricas sobre el registro LOCAL y mide el DRIFT
# entre sus dos representaciones (la tabla resumen de la seccion 5 y las
# entradas de las secciones 6/7/8), que es donde el registro se desincroniza.
#
# USO
# ---
#   python scripts/metricas_bugs.py                  # informe humano
#   python scripts/metricas_bugs.py --json           # SOLO JSON (maquina)
#   python scripts/metricas_bugs.py --check          # exit 1 si hay defectos
#   python scripts/metricas_bugs.py --report RUTA    # escribe informe markdown
#   python scripts/metricas_bugs.py --archivo RUTA   # otro registro (fixtures)
#   python scripts/metricas_bugs.py --selftest       # fixtures limpio/sucio/ciego
#
# CODIGOS DE SALIDA (convencion del proyecto, no colapsar "no pude mirar" con
# "mire y encontre"):
#   0 = sin defectos      1 = defectos      2 = uso invalido      3 = CIEGO
#
# DISENO (trampas del skill que se respetan aca)
# ----------------------------------------------
# - Las celdas se parten con `(?<!\\)\|`: un `|` sin escapar dentro de una
#   celda desalinea la tabla y `split("|")` atribuye mal TODOS los campos
#   (trampa 86/103).
# - El detector de ceguera NO es opcional: un registro sin la tabla de la
#   seccion 5 devuelve exit 3, no "0 bugs" (trampa 91). Un registro que no se
#   pudo leer es indistinguible de un registro limpio si el codigo no distingue.
# - `--json` imprime SOLO JSON (trampa 97): nada de lineas de adorno alrededor.
# - El informe NO fija numeros transitorios como invariante: los cuenta en la
#   corrida. Los tests de la suite afirman INVARIANTES sobre el registro real,
#   nunca el conteo de hoy (eso consagraria el estado y se pondria rojo cuando
#   otro agente registre un bug).

import argparse
import collections
import io
import json
import os
import re
import sys

RUTA_POR_DEFECTO = "DOCUMENTACION/11-BUGS.md"
RUTA_DASHBOARD = "docs/bug_metrics.md"

# --- Parseo ---------------------------------------------------------------

RE_SPLIT_CELDA = re.compile(r"(?<!\\)\|")
RE_ENTRADA = re.compile(r"^#{2,3} (BUG-\d+)")
RE_ENCABEZADO_SECCION = re.compile(r"^## ")
RE_ESTADO = re.compile(r"\[(x|X|\u2192|\?| )\]")
RE_MODULO = re.compile(r"\bM(\d{1,3})\b")

# Fallback: hay filas que expresan el estado con PALABRA y sin marca, p. ej.
# '✅ **Resuelto (fix exclusiones, Log 1092)**'. Se cuenta el estado (si no, la
# metrica pierde la fila) y ADEMAS se declara el defecto de formato.
ESTADOS_POR_TEXTO = (
    ("resuelto", "resuelto"),
    ("abierto", "abierto"),
    ("delegado", "delegado"),
    ("progreso", "en_progreso"),
)

SECCION_TABLA = re.compile(r"^## 5\.")

# Emoji de severidad -> nivel canonico. El registro usa DOS escalas a la vez
# (Critica/Alta, Media/Menor) y eso se reporta como defecto de etiqueta, no se
# "arregla" aca: la nomenclatura es del dueno del registro.
SEVERIDADES = {
    "\U0001F534": "critica",   # circulo rojo
    "\U0001F7E0": "mayor",     # circulo naranja
    "\U0001F7E1": "menor",     # circulo amarillo
    "\U0001F7E2": "baja",      # circulo verde
    "\u26AA": "trivial",       # circulo blanco
}

ESTADOS_CANONICOS = {
    "x": "resuelto",
    "\u2192": "en_progreso",
    "?": "delegado",
    " ": "abierto",
}

# --- Deuda conocida (baseline del gate de CI) -----------------------------
#
# El gate `--check` NO puede nacer rojo sobre un registro que ya arrastra
# decenas de defectos heredados: un gate rojo el primer dia se desactiva el
# segundo. `DEUDA_CONOCIDA` es el baseline — lo listado aca NO bloquea, lo que
# NO esta, bloquea. Es el mismo patron de `scripts/validar_workflows.py`
# (BUG-078: deuda con dueno declarado en vez de gate apagado).
#
# La clave es la FIRMA del defecto, no su numero de linea: al reparar una fila
# las lineas de abajo se corren, y una clave por linea convertiria cada
# saneamiento en un falso rojo. `firma_de()` usa el id del bug, que es la
# identidad estable del defecto.
#
# Higiene: al reparar un defecto su firma queda OBSOLETA. El gate lo declara
# con las lineas exactas a borrar (una lista de deuda que no se limpia deja de
# informar) pero NO se pone rojo por eso: castigar una mejora es la forma mas
# rapida de que nadie limpie la lista.
DEUDA_CONOCIDA = {
    "dashboard_divergente:dashboard": "M102: dashboard de GitHub Issues vs registro local",
    "entrada_duplicada:BUG-052": "M102: dos entradas para el mismo id (fusionarlas decide contenido)",
    "entrada_duplicada:BUG-058": "M102: dos entradas para el mismo id (fusionarlas decide contenido)",
    "entrada_sin_fila:BUG-047": "M102: la entrada existe y la fila resumen falta (reconstruirla es contenido, no mecanica)",
    "entrada_sin_fila:BUG-070": "M102: la entrada existe y la fila resumen falta (reconstruirla es contenido, no mecanica)",
    "etiqueta_severidad_inconsistente:baja": "M102: dos escalas de severidad conviviendo (nomenclatura del registro)",
    "etiqueta_severidad_inconsistente:trivial": "M102: dos escalas de severidad conviviendo (nomenclatura del registro)",
    "fila_sin_entrada:BUG-095": "M102: la fila resumen existe y la entrada falta (escribirla es contenido, no mecanica)",
    "fila_sin_entrada:BUG-106": "M102: la fila resumen existe y la entrada falta (escribirla es contenido, no mecanica)",
    "fila_sin_entrada:BUG-107": "M102: la fila resumen existe y la entrada falta (escribirla es contenido, no mecanica)",
    "fila_sin_entrada:BUG-118": "M102: la fila resumen existe y la entrada falta (escribirla es contenido, no mecanica)",
    "fila_sin_entrada:BUG-131": "M102: la fila resumen existe y la entrada falta (escribirla es contenido, no mecanica)",
    "fila_sin_entrada:BUG-132": "M102: la fila resumen existe y la entrada falta (escribirla es contenido, no mecanica)",
    "fila_sin_entrada:BUG-137": "M102: la fila resumen existe y la entrada falta (escribirla es contenido, no mecanica)",
    "fila_sin_entrada:BUG-138": "M102: la fila resumen existe y la entrada falta (escribirla es contenido, no mecanica)",
    "id_duplicado_tabla:BUG-129": "director: colision de id entre bugs DISTINTOS (renumerar cambia identidad)",
    "id_duplicado_tabla:BUG-130": "director: colision de id entre bugs DISTINTOS (renumerar cambia identidad)",
    "id_duplicado_tabla:BUG-139": "director: colision de id entre bugs DISTINTOS (renumerar cambia identidad)",
}


def _limpiar_markdown(texto):
    """Quita el enfasis de markdown para poder leer la celda."""
    return texto.replace("*", "").replace("`", "").replace("\u2705", "").strip()


def normalizar_estado(celda):
    """Devuelve (estado_canonico, marca). marca=None si no habia marca.

    Si el estado viene en TEXTO (sin `[x]`), se devuelve igual el estado y la
    marca como None: el llamador declara el defecto de formato. Devolver None
    perderia la fila de la metrica, que es peor que el defecto de formato.
    """
    limpio = _limpiar_markdown(celda)
    m = RE_ESTADO.search(limpio)
    if m:
        marca = m.group(1)
        return ESTADOS_CANONICOS.get(marca), "[%s]" % marca
    bajo = limpio.lower()
    for palabra, canonico in ESTADOS_POR_TEXTO:
        if palabra in bajo:
            return canonico, None
    return None, None


def normalizar_severidad(celda):
    """Devuelve (nivel, etiqueta) o (None, None)."""
    for emoji, nivel in SEVERIDADES.items():
        if emoji in celda:
            etiqueta = celda.replace(emoji, "").strip()
            etiqueta = re.split(r"[(\u2014\-]", etiqueta)[0].strip()
            return nivel, etiqueta
    return None, None


def normalizar_modulos(celda):
    """'M53/M14' -> ['M53','M14']; 'Transversal' -> ['Transversal']."""
    mods = ["M%03d" % int(m) for m in RE_MODULO.findall(celda)]
    if mods:
        return mods
    limpio = _limpiar_markdown(celda)
    return [limpio] if limpio else []


def _celdas(fila):
    partes = RE_SPLIT_CELDA.split(fila)
    if partes and partes[0].strip() == "":
        partes = partes[1:]
    if partes and partes[-1].strip() == "":
        partes = partes[:-1]
    return [p.strip() for p in partes]


def _seccion_de(lineas, indice):
    actual = "?"
    for i, l in enumerate(lineas):
        if i > indice:
            break
        if RE_ENCABEZADO_SECCION.match(l):
            actual = l.strip()
    return actual


def _mencionado(texto, numero):
    """True si el registro menciona ese numero de bug con cualquier formato."""
    patron = r"\b(?:BUG|Bug|bug)[-_ ]?0*%d\b" % numero
    return re.search(patron, texto) is not None


RE_BUG_EN_DETALLE = re.compile(r"\bBUG-(\d{3})\b")
RE_SEV_EN_DETALLE = re.compile(r"severidad '([^']+)'")


def firma_de(defecto):
    """Identidad ESTABLE de un defecto: tipo + id, sin linea ni detalle.

    Las lineas se corren al reparar filas vecinas y el detalle cambia al
    reescribir una fila; el id del bug no. Ejemplos:
        fila_sin_entrada:BUG-095
        etiqueta_severidad_inconsistente:critica   (el defecto es por NIVEL)
        dashboard_divergente:dashboard
    """
    tipo = defecto.get("tipo", "?")
    detalle = defecto.get("detalle", "")
    if tipo == "etiqueta_severidad_inconsistente":
        m = RE_SEV_EN_DETALLE.search(detalle)
        return "%s:%s" % (tipo, m.group(1) if m else "?")
    if tipo == "dashboard_divergente":
        return "%s:dashboard" % tipo
    m = RE_BUG_EN_DETALLE.search(detalle)
    return "%s:%s" % (tipo, ("BUG-%s" % m.group(1)) if m else "?")


def leer_dashboard(ruta=RUTA_DASHBOARD):
    """Lee el dashboard de GitHub Issues (`docs/bug_metrics.md`).

    Devuelve None si no existe o no se puede leer: el dashboard es un universo
    PARALELO, no la fuente de verdad, asi que su ausencia no vuelve ciego al
    medidor del registro local.
    """
    if not os.path.isfile(ruta):
        return None
    try:
        texto = io.open(ruta, encoding="utf-8").read()
    except (IOError, OSError, UnicodeDecodeError):
        return None
    datos = {"archivo": ruta, "abiertos": None, "cerrados": None,
             "generado": None}
    for linea in texto.split("\n"):
        if not linea.startswith("|"):
            continue
        celdas = _celdas(linea)
        if len(celdas) < 2:
            continue
        clave = celdas[0].lower()
        valor = celdas[1]
        num = re.match(r"\s*(\d+)", valor)
        if "bugs abiertos" in clave and num:
            datos["abiertos"] = int(num.group(1))
        elif "bugs cerrados" in clave and num:
            datos["cerrados"] = int(num.group(1))
        elif clave.startswith("**generado"):
            datos["generado"] = valor
    if datos["abiertos"] is None and datos["cerrados"] is None:
        return None
    return datos


def leer_registro(ruta=RUTA_POR_DEFECTO, ruta_dashboard=RUTA_DASHBOARD):
    """Parsea el registro y devuelve un dict con tabla, entradas, defectos, metricas.

    `ruta_dashboard=None` desactiva la comparacion con el dashboard (los
    fixtures lo usan: un fixture no debe depender del estado del repo).
    Lanza IOError si el archivo no existe (el llamador decide: exit 3).
    """
    crudo = io.open(ruta, "rb").read()
    texto = crudo.decode("utf-8")
    lineas = texto.split("\n")

    defectos = []

    # --- localizar la tabla resumen (seccion 5) ---
    ini = None
    fin = None
    for i, l in enumerate(lineas):
        if SECCION_TABLA.match(l):
            ini = i
            continue
        if ini is not None and i > ini and RE_ENCABEZADO_SECCION.match(l):
            fin = i
            break
    if ini is None:
        return {
            "archivo": ruta,
            "ciego": "no se encontro la seccion '## 5. Tabla Resumen de Bugs'",
            "tabla": [], "entradas": [], "defectos": [], "metricas": {},
        }
    if fin is None:
        fin = len(lineas)

    tabla = []
    for i in range(ini, fin):
        linea = lineas[i]
        if not linea.startswith("| BUG-"):
            continue
        celdas = _celdas(linea)
        fila = {
            "linea": i + 1,
            "id": celdas[0] if celdas else "",
            "celdas": len(celdas),
        }
        if len(celdas) != 7:
            defectos.append({
                "tipo": "fila_malformada",
                "linea": i + 1,
                "detalle": "%s tiene %d celdas (esperadas 7)" % (fila["id"], len(celdas)),
            })
        if len(celdas) >= 6:
            fila["titulo"] = celdas[1]
            fila["modulo_raw"] = celdas[2]
            fila["severidad_raw"] = celdas[3]
            fila["estado_raw"] = celdas[4]
            fila["reportado_por"] = celdas[5]
            fila["fecha"] = celdas[6] if len(celdas) > 6 else ""
        else:
            # Fila corta: recuperar lo que se pueda sin inventar posiciones.
            fila["titulo"] = celdas[1] if len(celdas) > 1 else ""
            fila["modulo_raw"] = ""
            fila["severidad_raw"] = ""
            fila["estado_raw"] = " ".join(celdas[2:])
            fila["reportado_por"] = ""
            fila["fecha"] = ""

        fila["estado"], fila["marca"] = normalizar_estado(fila["estado_raw"])
        fila["severidad"], fila["etiqueta_severidad"] = normalizar_severidad(
            fila["severidad_raw"])
        fila["modulos"] = normalizar_modulos(fila["modulo_raw"])

        if fila["estado"] is None:
            defectos.append({
                "tipo": "estado_desconocido",
                "linea": i + 1,
                "detalle": "%s sin marca de estado legible: %r"
                           % (fila["id"], fila["estado_raw"][:60]),
            })
        elif fila["marca"] is None:
            defectos.append({
                "tipo": "estado_sin_marca",
                "linea": i + 1,
                "detalle": "%s declara '%s' sin marca [x]/[ ]/[?]/[->]: %r"
                           % (fila["id"], fila["estado"], fila["estado_raw"][:50]),
            })
        if fila["severidad"] is None and fila["severidad_raw"]:
            defectos.append({
                "tipo": "severidad_desconocida",
                "linea": i + 1,
                "detalle": "%s sin emoji de severidad: %r"
                           % (fila["id"], fila["severidad_raw"][:60]),
            })
        tabla.append(fila)

    # --- entradas (secciones 6/7/8 y anexos) ---
    entradas = []
    for i, l in enumerate(lineas):
        m = RE_ENTRADA.match(l)
        if m:
            entradas.append({
                "linea": i + 1,
                "id": m.group(1),
                "seccion": _seccion_de(lineas, i),
            })

    # Encabezado de seccion con OTRO encabezado pegado adentro: parte el
    # documento en dos y hace que el resto de las entradas pierda su seccion.
    for i, l in enumerate(lineas):
        if RE_ENCABEZADO_SECCION.match(l) and l.count("## ") > 1:
            defectos.append({
                "tipo": "seccion_pegada",
                "linea": i + 1,
                "detalle": "encabezado con otro encabezado embebido: %r" % l[:80],
            })

    # --- drift entre las dos representaciones ---
    ids_tabla = [f["id"] for f in tabla]
    cuenta_ids = collections.Counter(ids_tabla)
    for bug_id, n in sorted(cuenta_ids.items()):
        if n > 1:
            lineas_dup = [f["linea"] for f in tabla if f["id"] == bug_id]
            defectos.append({
                "tipo": "id_duplicado_tabla",
                "linea": lineas_dup[0],
                "detalle": "%s aparece %d veces en la tabla (lineas %s)"
                           % (bug_id, n, ", ".join(str(x) for x in lineas_dup)),
            })

    ids_entrada = [e["id"] for e in entradas]
    cuenta_ent = collections.Counter(ids_entrada)
    for bug_id, n in sorted(cuenta_ent.items()):
        if n > 1:
            lineas_dup = [e["linea"] for e in entradas if e["id"] == bug_id]
            defectos.append({
                "tipo": "entrada_duplicada",
                "linea": lineas_dup[0],
                "detalle": "%s tiene %d entradas (lineas %s)"
                           % (bug_id, n, ", ".join(str(x) for x in lineas_dup)),
            })

    set_tabla = set(ids_tabla)
    set_ent = set(ids_entrada)
    for bug_id in sorted(set_tabla - set_ent):
        fila = next(f for f in tabla if f["id"] == bug_id)
        defectos.append({
            "tipo": "fila_sin_entrada",
            "linea": fila["linea"],
            "detalle": "%s esta en la tabla y no tiene entrada" % bug_id,
        })
    for bug_id in sorted(set_ent - set_tabla):
        ent = next(e for e in entradas if e["id"] == bug_id)
        defectos.append({
            "tipo": "entrada_sin_fila",
            "linea": ent["linea"],
            "detalle": "%s tiene entrada (%s) y no esta en la tabla"
                       % (bug_id, ent["seccion"][:48]),
        })

    # Etiquetas de severidad inconsistentes: mismo emoji, distinta palabra.
    etiquetas = collections.defaultdict(collections.Counter)
    for f in tabla:
        if f["severidad"]:
            etiquetas[f["severidad"]][f["etiqueta_severidad"]] += 1
    for nivel, cuenta in sorted(etiquetas.items()):
        if len(cuenta) > 1:
            defectos.append({
                "tipo": "etiqueta_severidad_inconsistente",
                "linea": 0,
                "detalle": "severidad '%s' con %d etiquetas distintas: %s"
                           % (nivel, len(cuenta),
                              ", ".join("%s x%d" % (e, n) for e, n in cuenta.most_common())),
            })

    # --- universos paralelos: el dashboard de GitHub Issues ---
    dashboard = leer_dashboard(ruta_dashboard) if ruta_dashboard else None
    no_resueltos = sum(n for e, n in
                       collections.Counter(f["estado"] for f in tabla if f["estado"]).items()
                       if e != "resuelto")
    if dashboard and dashboard.get("abiertos") is not None:
        if dashboard["abiertos"] != no_resueltos:
            defectos.append({
                "tipo": "dashboard_divergente",
                "linea": 0,
                "detalle": "%s declara %d bugs abiertos y el registro local tiene %d "
                           "no resueltos (%s)"
                           % (dashboard["archivo"], dashboard["abiertos"], no_resueltos,
                              ", ".join("%s=%d" % (k, v)
                                        for k, v in sorted(
                                            collections.Counter(
                                                f["estado"] for f in tabla
                                                if f["estado"] and f["estado"] != "resuelto"
                                            ).items()))),
            })

    # --- metricas ---
    por_estado = collections.Counter(f["estado"] for f in tabla if f["estado"])
    por_severidad = collections.Counter(f["severidad"] for f in tabla if f["severidad"])
    por_modulo = collections.Counter()
    for f in tabla:
        for m in f["modulos"]:
            por_modulo[m] += 1
    por_reporter = collections.Counter(
        _limpiar_markdown(f["reportado_por"]) for f in tabla if f["reportado_por"])

    # Los huecos se miden sobre la UNION (tabla + entradas): un bug que solo
    # tiene entrada SI existe; contarlo como hueco seria inventar deuda.
    numeros = sorted(int(m.group(1)) for m in
                     (re.match(r"BUG-(\d+)$", i) for i in (set_tabla | set_ent)) if m)
    huecos = []
    if numeros:
        presentes = set(numeros)
        huecos = [n for n in range(1, numeros[-1] + 1) if n not in presentes]

    # Un hueco puede estar "tapado" por una mencion en un encabezado NO canonico
    # ('## [fecha] — Bug 023: ...' o un encabezado pegado). Eso NO es una entrada
    # valida (no se inventa una), pero distingue "numero que nunca existio" de
    # "numero que existe con formato que el parser no reconoce".
    huecos_mencionados = [n for n in huecos if _mencionado(texto, n)]
    huecos_ausentes = [n for n in huecos if n not in set(huecos_mencionados)]

    metricas = {
        "filas_tabla": len(tabla),
        "ids_unicos_tabla": len(set_tabla),
        "ids_unicos_registro": len(set_tabla | set_ent),
        "entradas": len(entradas),
        "entradas_unicas": len(set_ent),
        "no_resueltos": no_resueltos,
        "por_estado": dict(sorted(por_estado.items())),
        "por_severidad": dict(sorted(por_severidad.items())),
        "por_modulo": dict(por_modulo.most_common()),
        "por_reportero": dict(por_reporter.most_common()),
        "id_max": numeros[-1] if numeros else 0,
        "huecos_de_numeracion": len(huecos),
        "huecos": huecos[:40],
        "huecos_mencionados": huecos_mencionados,
        "huecos_ausentes": huecos_ausentes,
        "dashboard": dashboard,
        "defectos_por_tipo": dict(sorted(collections.Counter(
            d["tipo"] for d in defectos).items())),
    }

    # La firma se calcula al final, en un solo sitio: los sitios que crean
    # defectos no tienen que acordarse de rellenarla (un defecto sin firma
    # seria invisible para el gate, que es la peor clase de defecto).
    for d in defectos:
        d["firma"] = firma_de(d)

    return {
        "archivo": ruta,
        "ciego": None,
        "bytes": len(crudo),
        "tabla": tabla,
        "entradas": entradas,
        "defectos": defectos,
        "metricas": metricas,
    }


# --- Salidas --------------------------------------------------------------

def informe_humano(datos):
    m = datos["metricas"]
    print("=" * 70)
    print("METRICAS DE BUGS — %s" % datos["archivo"])
    print("=" * 70)
    print("Filas de la tabla resumen (seccion 5) : %d" % m["filas_tabla"])
    print("IDs unicos en la tabla                : %d" % m["ids_unicos_tabla"])
    print("Entradas con encabezado (6/7/8/anexos): %d (%d unicas)"
          % (m["entradas"], m["entradas_unicas"]))
    print("IDs unicos en el registro             : %d" % m["ids_unicos_registro"])
    print("No resueltos (abierto+delegado+progr.): %d" % m["no_resueltos"])
    print("ID maximo                             : BUG-%03d" % m["id_max"])
    print("Huecos de numeracion                  : %d" % m["huecos_de_numeracion"])
    if m["huecos_de_numeracion"]:
        print("  mencionados sin entrada canonica    : %s"
              % (m["huecos_mencionados"] or "ninguno"))
        print("  ausentes del registro entero        : %s"
              % (m["huecos_ausentes"] or "ninguno"))
    if m.get("dashboard"):
        d = m["dashboard"]
        print("Dashboard GitHub Issues               : abiertos=%s cerrados=%s (%s)"
              % (d.get("abiertos"), d.get("cerrados"), d.get("archivo")))
    print()
    print("Por estado:")
    for k, v in m["por_estado"].items():
        print("  %-14s %3d" % (k, v))
    print("Por severidad:")
    for k, v in m["por_severidad"].items():
        print("  %-14s %3d" % (k, v))
    print("Top modulos:")
    for k, v in list(m["por_modulo"].items())[:10]:
        print("  %-14s %3d" % (k, v))
    print()
    if datos["defectos"]:
        print("DEFECTOS ESTRUCTURALES: %d" % len(datos["defectos"]))
        for tipo, n in m["defectos_por_tipo"].items():
            print("  %-34s %3d" % (tipo, n))
        print()
        print("Detalle (primeros 20):")
        for d in datos["defectos"][:20]:
            print("  L%-6d %-32s %s" % (d["linea"], d["tipo"], d["detalle"]))
        print()
        print("VEREDICTO: %d defectos de sincronizacion entre la tabla y las entradas."
              % len(datos["defectos"]))
    else:
        print("VEREDICTO: tabla y entradas sincronizadas, sin defectos.")
    print("=" * 70)


def informe_markdown(datos):
    m = datos["metricas"]
    out = []
    out.append("# Metricas de bugs — informe automatico")
    out.append("")
    out.append("Generado por `scripts/metricas_bugs.py` sobre `%s`." % datos["archivo"])
    out.append("Fuente de verdad: `DOCUMENTACION/11-BUGS.md` (registro local).")
    out.append("")
    out.append("## Totales medidos")
    out.append("")
    out.append("| Metrica | Valor |")
    out.append("|---|---|")
    out.append("| Filas en la tabla resumen (seccion 5) | %d |" % m["filas_tabla"])
    out.append("| IDs unicos en la tabla | %d |" % m["ids_unicos_tabla"])
    out.append("| Entradas con encabezado | %d (%d unicas) |" % (m["entradas"], m["entradas_unicas"]))
    out.append("| IDs unicos en el registro (union tabla+entradas) | %d |" % m["ids_unicos_registro"])
    out.append("| No resueltos (abierto + delegado + en progreso) | %d |" % m["no_resueltos"])
    out.append("| ID maximo | BUG-%03d |" % m["id_max"])
    out.append("| Huecos de numeracion | %d |" % m["huecos_de_numeracion"])
    if m["huecos_de_numeracion"]:
        out.append("| — mencionados sin entrada canonica | %s |"
                   % (", ".join("BUG-%03d" % n for n in m["huecos_mencionados"]) or "ninguno"))
        out.append("| — ausentes del registro entero | %s |"
                   % (", ".join("BUG-%03d" % n for n in m["huecos_ausentes"]) or "ninguno"))
    out.append("")
    if m.get("dashboard"):
        d = m["dashboard"]
        out.append("## Universo paralelo: dashboard de GitHub Issues")
        out.append("")
        out.append("`%s` declara **%s abiertos / %s cerrados**." % (
            d.get("archivo"), d.get("abiertos"), d.get("cerrados")))
        out.append("Ese dashboard cuenta SOLO issues de GitHub; el registro local "
                   "(`11-BUGS.md`) es la fuente de verdad de este informe. Si los dos "
                   "numeros no coinciden, el defecto `dashboard_divergente` lo declara.")
        out.append("")
    out.append("## Por estado")
    out.append("")
    out.append("| Estado | Cantidad |")
    out.append("|---|---|")
    for k, v in m["por_estado"].items():
        out.append("| %s | %d |" % (k, v))
    out.append("")
    out.append("## Por severidad")
    out.append("")
    out.append("| Severidad | Cantidad |")
    out.append("|---|---|")
    for k, v in m["por_severidad"].items():
        out.append("| %s | %d |" % (k, v))
    out.append("")
    out.append("## Defectos de sincronizacion")
    out.append("")
    if not datos["defectos"]:
        out.append("Ninguno.")
    else:
        out.append("| Tipo | Cantidad |")
        out.append("|---|---|")
        for tipo, n in m["defectos_por_tipo"].items():
            out.append("| %s | %d |" % (tipo, n))
        out.append("")
        out.append("### Detalle")
        out.append("")
        for d in datos["defectos"]:
            out.append("- L%d `%s` — %s" % (d["linea"], d["tipo"], d["detalle"]))
    out.append("")
    return "\n".join(out)


# --- Autotest -------------------------------------------------------------

FIXTURE_LIMPIO = """# Registro de bugs (fixture limpio)

## 5. Tabla Resumen de Bugs

| ID | Titulo | Modulo | Severidad | Estado | Reportado por | Fecha |
|----|--------|--------|-----------|--------|---------------|-------|
| BUG-001 | Uno | M10 | \U0001F534 Critica | [x] Resuelto | alfa | 2026-01-01 |
| BUG-002 | Dos | M20 | \U0001F7E1 Menor | [ ] Abierto | beta | 2026-01-02 |

## 6. Bugs Abiertos (pendientes)

### BUG-002 — Dos

## 7. Bugs Resueltos (historial)

### BUG-001 — Uno
"""

FIXTURE_SUCIO = """# Registro de bugs (fixture sucio)

## 5. Tabla Resumen de Bugs

| ID | Titulo | Modulo | Severidad | Estado | Reportado por | Fecha |
|----|--------|--------|-----------|--------|---------------|-------|
| BUG-001 | Uno | M10 | \U0001F534 Critica | [x] Resuelto | alfa | 2026-01-01 |
| BUG-001 | Uno repetido | M10 | \U0001F534 Alta | [ ] Abierto | alfa | 2026-01-01 |
| BUG-002 | Dos | M20 | \U0001F7E1 Menor | sin marca | beta | 2026-01-02 |
| BUG-003 | Tres | M30 | \U0001F7E0 Mayor | [ ] Abierto | gam|ma | 2026-01-03 |
| BUG-004 | Cuatro | M40 | \U0001F7E0 Mayor | [ ] Abierto | delta | 2026-01-04 |

## 6. Bugs Abiertos (pendientes)### BUG-004 — encabezado pegado

### BUG-002 — Dos

## 7. Bugs Resueltos (historial)

### BUG-001 — Uno

### BUG-099 — Huerfana sin fila
"""

FIXTURE_CIEGO = """# Registro sin tabla resumen

## 1. Proposito

Nada que medir aca.
"""


def _fixture(tmpdir, nombre, contenido):
    ruta = os.path.join(tmpdir, nombre)
    with io.open(ruta, "wb") as f:
        f.write(contenido.encode("utf-8"))
    return ruta


def selftest():
    """Fixtures limpio / sucio / ciego. Devuelve exit code."""
    import tempfile

    ok = 0
    fail = 0

    def check(cond, desc):
        nonlocal ok, fail
        if cond:
            ok += 1
            print("  [OK]   %s" % desc)
        else:
            fail += 1
            print("  [FALLO] %s" % desc)

    tmp = tempfile.mkdtemp(prefix="metricas_bugs_")
    print("=" * 70)
    print("SELFTEST — scripts/metricas_bugs.py")
    print("=" * 70)

    # 1. limpio
    d = leer_registro(_fixture(tmp, "limpio.md", FIXTURE_LIMPIO), None)
    check(d["ciego"] is None, "fixture limpio: no es ciego")
    check(len(d["tabla"]) == 2, "fixture limpio: 2 filas (medido %d)" % len(d["tabla"]))
    check(len(d["defectos"]) == 0,
          "fixture limpio: 0 defectos (medido %d: %s)"
          % (len(d["defectos"]), d["metricas"]["defectos_por_tipo"]))
    check(d["metricas"]["por_estado"].get("resuelto") == 1, "fixture limpio: 1 resuelto")
    check(d["metricas"]["por_estado"].get("abierto") == 1, "fixture limpio: 1 abierto")

    # 2. sucio: cada defecto tiene que aparecer y con el conteo exacto
    s = leer_registro(_fixture(tmp, "sucio.md", FIXTURE_SUCIO), None)
    tipos = s["metricas"]["defectos_por_tipo"]
    check(len(s["tabla"]) == 5, "fixture sucio: 5 filas (medido %d)" % len(s["tabla"]))
    check(tipos.get("id_duplicado_tabla") == 1,
          "fixture sucio: 1 id duplicado (medido %s)" % tipos.get("id_duplicado_tabla"))
    check(tipos.get("fila_malformada") == 1,
          "fixture sucio: 1 fila malformada (medido %s)" % tipos.get("fila_malformada"))
    check(tipos.get("estado_desconocido") == 1,
          "fixture sucio: 1 estado desconocido (medido %s)" % tipos.get("estado_desconocido"))
    check(tipos.get("seccion_pegada") == 1,
          "fixture sucio: 1 encabezado pegado (medido %s)" % tipos.get("seccion_pegada"))
    # BUG-004 solo figura en el encabezado PEGADO ('## 6. ...### BUG-004'), que
    # no matchea el patron de entrada: el defecto `seccion_pegada` ES la causa de
    # que BUG-004 quede sin entrada. Por eso son 2 y no 1 (medido, no supuesto).
    check(tipos.get("fila_sin_entrada") == 2,
          "fixture sucio: 2 filas sin entrada (medido %s)" % tipos.get("fila_sin_entrada"))
    check(tipos.get("entrada_sin_fila") == 1,
          "fixture sucio: 1 entrada sin fila (medido %s)" % tipos.get("entrada_sin_fila"))
    check(tipos.get("etiqueta_severidad_inconsistente") == 1,
          "fixture sucio: 1 etiqueta de severidad inconsistente (medido %s)"
          % tipos.get("etiqueta_severidad_inconsistente"))
    check(len(s["defectos"]) == 8,
          "fixture sucio: 8 defectos en total (medido %d: %s)"
          % (len(s["defectos"]), tipos))
    # El pipe sin escapar desplaza el campo de la DERECHA (aqui 'Reportado por'),
    # no los de la izquierda: el defecto se declara, no se propaga en silencio.
    fila3 = [f for f in s["tabla"] if f["id"] == "BUG-003"][0]
    check(fila3["estado"] == "abierto",
          "fixture sucio: el pipe sin escapar no corre el estado (estado=%s)"
          % fila3["estado"])

    # 3. ciego: sin seccion 5 -> exit 3, NO "0 defectos"
    c = leer_registro(_fixture(tmp, "ciego.md", FIXTURE_CIEGO), None)
    check(c["ciego"] is not None, "fixture ciego: se declara ciego")
    check(c["tabla"] == [], "fixture ciego: 0 filas leidas")

    # 3-bis. dashboard divergente: el universo de GitHub dice 0 y el registro
    # tiene 1 no resuelto -> el defecto tiene que aparecer (es el hallazgo que
    # motiva este script).
    dash = _fixture(tmp, "dashboard.md",
                    "# Dashboard\n\n| M\u00e9trica | Valor |\n|---|---|\n"
                    "| Bugs abiertos | 0 |\n| Bugs cerrados (total) | 0 |\n")
    dv = leer_registro(_fixture(tmp, "limpio.md", FIXTURE_LIMPIO), dash)
    check(dv["metricas"]["defectos_por_tipo"].get("dashboard_divergente") == 1,
          "dashboard que declara 0 con 1 no resuelto -> dashboard_divergente (medido %s)"
          % dv["metricas"]["defectos_por_tipo"].get("dashboard_divergente"))
    check(dv["metricas"]["no_resueltos"] == 1,
          "no_resueltos del fixture limpio = 1 (medido %d)" % dv["metricas"]["no_resueltos"])
    # control NEGATIVO: un dashboard que coincide NO debe marcar defecto
    dash_ok = _fixture(tmp, "dashboard_ok.md",
                       "| M\u00e9trica | Valor |\n|---|---|\n| Bugs abiertos | 1 |\n")
    dok = leer_registro(_fixture(tmp, "limpio.md", FIXTURE_LIMPIO), dash_ok)
    check("dashboard_divergente" not in dok["metricas"]["defectos_por_tipo"],
          "dashboard que coincide NO marca dashboard_divergente (control negativo)")

    # 4. --json puro
    ruta_limpio = _fixture(tmp, "limpio.md", FIXTURE_LIMPIO)
    salida = _capturar_stdout(["--archivo", ruta_limpio, "--json"])
    parseable = True
    try:
        obj = json.loads(salida)
    except ValueError:
        parseable = False
        obj = {}
    check(parseable, "--json imprime SOLO JSON (parseable)")
    check(obj.get("metricas", {}).get("filas_tabla") == 2,
          "--json trae las metricas (filas=%s)"
          % obj.get("metricas", {}).get("filas_tabla"))

    # 5. exit codes con archivo inexistente (ciego, no 0)
    rc, _ = _correr(["--archivo", os.path.join(tmp, "no_existe.md")])
    check(rc == 3, "archivo inexistente -> exit 3 (detector ciego), medido %d" % rc)
    rc, _ = _correr(["--archivo", _fixture(tmp, "ciego.md", FIXTURE_CIEGO)])
    check(rc == 3, "registro sin tabla -> exit 3 (ciego), medido %d" % rc)
    rc, _ = _correr(["--archivo", ruta_limpio, "--dashboard", "", "--check"])
    check(rc == 0, "fixture limpio --check -> exit 0, medido %d" % rc)
    rc, _ = _correr(["--archivo", _fixture(tmp, "sucio.md", FIXTURE_SUCIO),
                     "--dashboard", "", "--check"])
    check(rc == 1, "fixture sucio --check -> exit 1, medido %d" % rc)
    rc, _ = _correr(["--archivo", ruta_limpio, "--basura"])
    check(rc == 2, "--flag desconocido -> exit 2 (uso), medido %d" % rc)

    # 6. el informe markdown se escribe y cita los totales medidos
    ruta_md = os.path.join(tmp, "informe.md")
    rc, _ = _correr(["--archivo", ruta_limpio, "--report", ruta_md])
    escrito = io.open(ruta_md, encoding="utf-8").read() if os.path.isfile(ruta_md) else ""
    check("| Filas en la tabla resumen (seccion 5) | 2 |" in escrito,
          "el informe markdown cita el total medido")
    check("\n\n\n" not in escrito, "el informe markdown no deja lineas vacias triples")

    print()
    print("=" * 70)
    print("RESULTADO SELFTEST: %d OK, %d FALLO" % (ok, fail))
    print("=" * 70)
    return 1 if fail else 0


def _capturar_stdout(argv):
    """Corre main() capturando stdout (para verificar que --json es puro)."""
    rc, salida = _correr(argv)
    return salida


def _correr(argv):
    """Devuelve (exit_code, stdout_capturado). Nunca deja escapar SystemExit.

    El stderr se descarta: lo usan las sondas y el selftest, y los mensajes de
    'DETECTOR CIEGO' / 'usage' son esperados ahi. La CLI real no pasa por aca.
    """
    import contextlib

    buf = io.StringIO()
    rc = 0
    with contextlib.redirect_stdout(buf), contextlib.redirect_stderr(io.StringIO()):
        try:
            rc = main(argv)
        except SystemExit as e:
            rc = int(e.code) if e.code is not None else 0
    return rc, buf.getvalue()


# --- Gate de CI (deuda conocida) ------------------------------------------

# Motivo por familia, para que la entrada del baseline diga POR QUE sigue ahi
# y quien la debe. Una firma sin motivo es deuda sin dueno.
MOTIVO_POR_TIPO = {
    "entrada_sin_fila": "M102: la entrada existe y la fila resumen falta (reconstruirla es contenido, no mecanica)",
    "fila_sin_entrada": "M102: la fila resumen existe y la entrada falta (escribirla es contenido, no mecanica)",
    "entrada_duplicada": "M102: dos entradas para el mismo id (fusionarlas decide contenido)",
    "id_duplicado_tabla": "director: colision de id entre bugs DISTINTOS (renumerar cambia identidad)",
    "etiqueta_severidad_inconsistente": "M102: dos escalas de severidad conviviendo (nomenclatura del registro)",
    "seccion_pegada": "M102: encabezado embebido en otro encabezado",
    "estado_sin_marca": "M102: estado escrito con palabra en vez de [x]/[ ]/[?]/[->]",
    "fila_malformada": "M102: fila con numero de celdas distinto de 7",
    "dashboard_divergente": "M102: dashboard de GitHub Issues vs registro local",
    "estado_desconocido": "M102: estado no reconocido",
}


def literal_deuda(datos):
    """Devuelve el literal `DEUDA_CONOCIDA` medido, listo para pegar.

    Imprime, NO escribe: bendecir el estado actual tiene que ser un acto
    deliberado con diff visible, no un efecto colateral de correr un flag.
    """
    firmas = sorted({d["firma"] for d in datos["defectos"]})
    out = ["DEUDA_CONOCIDA = {"]
    for firma in firmas:
        tipo = firma.split(":", 1)[0]
        motivo = MOTIVO_POR_TIPO.get(tipo, "M102: sin motivo declarado")
        out.append('    "%s": "%s",' % (firma, motivo))
    out.append("}")
    return "\n".join(out)


def _gate(datos, deuda=None):
    """Gate de CI. Devuelve (codigo, [lineas]) — exit 1 solo con defectos NUEVOS.

    Compara la MULTISET de firmas contra el baseline: un segundo defecto con la
    misma firma que el baseline tambien es NUEVO (si no, el gate tendria un
    agujero del tamano de una repeticion).
    """
    deuda = DEUDA_CONOCIDA if deuda is None else deuda
    por_firma = collections.defaultdict(list)
    for d in datos["defectos"]:
        por_firma[d["firma"]].append(d)

    nuevos = []
    for firma in sorted(por_firma):
        tope = 1 if firma in deuda else 0
        if len(por_firma[firma]) > tope:
            nuevos.extend(por_firma[firma][tope:])

    obsoletas = sorted(f for f in deuda if f not in por_firma)
    total = len(datos["defectos"])
    out = []

    if nuevos:
        out.append("GATE ROJO: %d defecto(s) NUEVO(S) fuera de DEUDA_CONOCIDA "
                   "(%d defectos, %d ya conocidos)."
                   % (len(nuevos), total, total - len(nuevos)))
        for d in nuevos:
            out.append("  NUEVO  %-32s L%-6d %s" % (d["tipo"], d["linea"], d["detalle"]))
            out.append("         firma: %s" % d["firma"])
        out.append("  Reparar el registro. Si el defecto es heredado y tiene dueno, "
                   "agregarlo a DEUDA_CONOCIDA con su motivo (diff visible).")
        return 1, out

    out.append("GATE VERDE: 0 defectos nuevos; %d deuda conocida vigente." % total)
    if obsoletas:
        out.append("AVISO: %d firma(s) de DEUDA_CONOCIDA ya no aparecen (deuda "
                   "RESUELTA). Borrar estas lineas del dict:" % len(obsoletas))
        for firma in obsoletas:
            out.append('    "%s": ...' % firma)
    return 0, out


# --- main -----------------------------------------------------------------

def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Metricas unificadas de DOCUMENTACION/11-BUGS.md")
    ap.add_argument("--archivo", default=RUTA_POR_DEFECTO)
    ap.add_argument("--dashboard", default=RUTA_DASHBOARD,
                    help="dashboard de GitHub Issues a comparar ('' lo desactiva)")
    ap.add_argument("--json", action="store_true", help="imprime SOLO JSON")
    ap.add_argument("--check", action="store_true",
                    help="gate: exit 1 solo con defectos NUEVOS fuera de DEUDA_CONOCIDA")
    ap.add_argument("--deuda", action="store_true",
                    help="imprime el literal DEUDA_CONOCIDA medido (no escribe nada)")
    ap.add_argument("--report", metavar="RUTA", help="escribe el informe markdown")
    ap.add_argument("--selftest", action="store_true")
    try:
        args = ap.parse_args(argv)
    except SystemExit as e:
        # argparse sale 2 por uso invalido, que es justo nuestra convencion;
        # --help sale 0.
        return 0 if not e.code else 2

    if args.selftest:
        return selftest()

    if not os.path.isfile(args.archivo):
        sys.stderr.write("DETECTOR CIEGO (exit 3): no existe %s\n" % args.archivo)
        return 3

    try:
        datos = leer_registro(args.archivo, args.dashboard or None)
    except (IOError, OSError, UnicodeDecodeError) as e:
        sys.stderr.write("DETECTOR CIEGO (exit 3): no se pudo leer %s: %s\n"
                         % (args.archivo, e))
        return 3

    if datos["ciego"]:
        sys.stderr.write("DETECTOR CIEGO (exit 3): %s\n" % datos["ciego"])
        if args.json:
            print(json.dumps({"archivo": args.archivo, "ciego": datos["ciego"]},
                             ensure_ascii=False, indent=2))
        return 3

    if args.deuda:
        print(literal_deuda(datos))
        return 0

    if args.report:
        with io.open(args.report, "w", encoding="utf-8", newline="\n") as f:
            f.write(informe_markdown(datos) + "\n")

    if args.json:
        print(json.dumps(datos, ensure_ascii=False, indent=2))
    else:
        informe_humano(datos)
        if args.report:
            print("Informe markdown escrito en: %s" % args.report)

    if args.check:
        codigo, lineas = _gate(datos)
        # Con --json el stdout es SOLO JSON: el veredicto se va a stderr.
        destino = sys.stderr if args.json else sys.stdout
        for l in lineas:
            destino.write(l + "\n")
        return codigo
    return 0


if __name__ == "__main__":
    sys.exit(main())
