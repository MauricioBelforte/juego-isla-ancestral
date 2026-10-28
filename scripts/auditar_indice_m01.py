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
    python scripts/auditar_indice_m01.py --pendientes    # clasifica los [ ] por bloqueo
    python scripts/auditar_indice_m01.py --dependencias  # clasifica los abiertos por TIPO de dependencia
    python scripts/auditar_indice_m01.py --stale         # clasifica los [x] NO sostenidos hoy + cita

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
    lineas = leer_texto(ruta).splitlines()
    for numero, linea in enumerate(lineas, 1):
        m = RE_ITEM.match(linea)
        if not m:
            continue
        marca, ident, resto = m.group(1), m.group(2), m.group(3)
        # El resto trae "Titulo [M] PRIORIDAD - descripcion"
        titulo = resto.split("[")[0].strip()
        # La cita del flip puede vivir en la linea siguiente (continuacion que
        # empieza con guion largo) y no en la propia: se captura para poder
        # auditar si el flip esta justificado.
        siguiente = ""
        if numero < len(lineas):
            cand = lineas[numero]
            if cand.strip() and not RE_MARCA.match(cand) and not cand.lstrip().startswith("#"):
                siguiente = cand
        items.append(
            {
                "id": "M" + ident,
                "num": int(ident),
                "marca": marca,
                "titulo": titulo,
                "linea": numero,
                "texto": linea,
                "siguiente": siguiente,
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
            "linea": it["linea"],
            "texto": it.get("texto", ""),
            "siguiente": it.get("siguiente", ""),
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


# ---------------------------------------------------------------------------
# Clasificacion por TIPO DE DEPENDENCIA (iter. 10)
#
# El indice solo dice "depende del cierre del modulo". Lo que el director
# necesita saber es QUE cosa falta para desbloquearlo. Estas familias se miden
# sobre el ENUNCIADO del item (no sobre la anotacion de auditoria, que es
# historia y menciona de todo), y cada item conserva la evidencia del match
# para que la clasificacion sea auditable item por item.
# ---------------------------------------------------------------------------

# Corte del enunciado: la anotacion de auditoria empieza tras un separador.
RE_SEPARADOR = re.compile(r"\s(?:\||\u2014|--|::)\s|\s-\s(?=\*\*)")

# El orden ES la precedencia: el primer tipo que matchea gana.
FAMILIAS = (
    (
        "cuenta_externa_fundador",
        "cuenta/servicio externo o gestion que solo puede hacer el fundador",
        (
            r"google\s+cloud",
            r"\boauth\b",
            r"credencial",
            r"steamworks",
            r"\bapi\s*key\b",
            r"drive\s+api",
            r"gdrive",
            r"rclone",
            r"play\s+store",
            r"app\s*store",
            r"marca\s+registrada",
            r"registro\s+de\s+marca",
            r"facturaci[oó]n",
            r"\bfiscal\b",
            r"\bimpuestos?\b",
            r"pasarela\s+de\s+pago",
            r"cuenta\s+de\s+(?:steam|google|desarrollador|pago)",
        ),
    ),
    (
        "hardware",
        "exige medir en un dispositivo real",
        (
            # --- Tokens DUROS: el dispositivo es el sujeto del item. Matchean solos.
            # Plurales incluidos: `\bdispositivo\b` NO matcheaba "dispositivos" y
            # dejaba 5 items fuera (medido 2026-10-24).
            r"steam\s*deck",
            r"\bGPUs?\b",
            r"\bVRAM\b",
            r"\bhardware\b",
            r"\bdispositivos?\b",
            r"\bt[aá]ctiles?\b",
            r"\bhaptics?\b",
            r"\bandroids?\b",
            # --- Tokens BLANDOS: "fps" / "rendimiento" por si solos NO son hardware.
            # Medido: 16 de 56 items (28,6%) cazados asi eran IMPLEMENTACION
            # ("FPS overlay cada 0.5s") o TARGETS de diseno ("Definir objetivo 30
            # fps"). Precision de la familia: 71,4% -> 92,9% con la regla de abajo.
            # Solo cuentan si el item pide MEDIR (dos lookaheads: verbo + token).
            r"(?=.*\b(?:valid|medici|medir|verific|probad|probar|teste|test|benchmark|profiler)\w*)"
            r"(?=.*\b(?:fps|rendimiento|perf|frame\s*budget)\b)",
        ),
    ),
    (
        "asset",
        "exige un asset de arte/audio/3D que no esta en el repo",
        (
            r"\bassets?\b(?!\s*/)",
            r"modelo\s*3d",
            r"\.glb\b",
            r"\.blend\b",
            r"\bblender\b",
            r"\btexturas?\b",
            r"\bsprites?\b",
            r"\biconos?\b",
            r"\bilustraci",
            r"concept\s*art",
            r"\baudio\b",
            r"\bsonidos?\b",
            r"m[uú]sica",
            r"\bSFX\b",
            r"\bclip\b",
            r"\bdoblaje\b",
            r"animaci[oó]n",
            r"\bprefabs?\b",
            r"tipograf",
            # FUERA a proposito (medido 2026-10-24, muestra de 21 items: la
            # precision de `asset` era ~52% por estos tokens). "Pool de meshes
            # reutilizado", "materiales regionales", "particulas de satisfaccion"
            # y "VFX de X" son IMPLEMENTACION en GDScript/escena, no un archivo
            # de arte que falte. Se sacaron `mesh`, `malla`, `material`,
            # `particula` y `vfx`.
        ),
    ),
    (
        "decision_proyecto",
        "espera una decision del director o del fundador",
        (
            # Solo marcadores EXPLICITOS de "esto espera una decision". La version
            # amplia (que incluia "aprob" y "decision" a secas) medía 40 % de
            # precision en la muestra del 2026-10-23: cazaba items que solo
            # MENCIONAN una decision ya tomada.
            r"flag\s+doc-in",
            r"espera\s+decisi",
            r"decisi[oó]n\s+pendiente",
            r"pendiente\s+de\s+(?:una\s+)?decisi",
            r"pendiente\s+de\s+negocio",
            r"por\s+decidir",
            r"\bratific",
            r"no\s+t[eé]cnica",
            r"el\s+director\s+debe",
            r"decisi[oó]n\s+del\s+director",
            r"director\s+debe",
        ),
    ),
    (
        "otro_modulo",
        "depende de otro modulo del proyecto",
        (r"\bM\d{2,3}\b",),
    ),
    (
        "trabajo_propio",
        "sin dependencia externa declarada: falta implementarlo",
        (
            r"no\s+implementado",
            r"no\s+existe",
            r"no\s+hay\b",
            r"0\s+hits",
            r"0\s+c[oó]digo",
            r"sin\s+implementar",
            r"\bfalta\b",
            r"\bparcial\b",
        ),
    ),
)

FAMILIAS_COMPILADAS = tuple(
    (nombre, desc, tuple(re.compile(p, re.I) for p in patrones))
    for nombre, desc, patrones in FAMILIAS
)

# Tipos que exigen algo de FUERA del repositorio y de los demas modulos.
TIPOS_EXTERNOS = ("cuenta_externa_fundador", "hardware", "asset", "decision_proyecto")

# Residual: el enunciado NO declara ninguna dependencia externa. Ojo con el
# nombre: no afirma "no hay dependencia", afirma "no la declara". Para el
# director es la familia ACCIONABLE (trabajo que el proyecto puede hacer solo).
# Se llamaba `sin_senal` y se leia como "el detector no vio nada"; el 56,5 % del
# total hacia pensar en un detector ciego. Medido: solo 5 items del residual
# tenian un token de familia en PLURAL que el patron no cubria.
TIPO_RESIDUAL = "sin_dependencia_declarada"

# Orden de presentacion (incluye el residual al final).
TIPOS_ORDEN = tuple(n for n, _, _ in FAMILIAS) + (TIPO_RESIDUAL,)

# Guarda de ceguera: si no se clasifico NINGUN item, o si se clasificaron menos
# modulos que los que el paso anterior marco `bloqueado_ambos`, el detector esta
# ciego. No se usa un piso fijo de items a proposito: un piso absoluto no
# distingue un repo real de un arbol sintetico, y aqui la relacion
# (modulos clasificados == modulos bloqueados) SI es falsable en los dos casos.
RE_ITEM_ABIERTO = re.compile(r"^\s*-\s+\[([ ?])\]\s*(.*)$")


def enunciado(texto):
    """Recorta el item a su enunciado: corta en el separador de la anotacion.

    Si el item EMPIEZA por un separador (hay items cuyo texto es solo la
    anotacion: `- [?] -- agnes 2026-09-12: ...`), el recorte dejaria la cadena
    vacia y el item caeria a `sin_senal` sin haberlo mirado. En ese caso se
    devuelve el texto completo: ahi la anotacion ES el enunciado.
    """
    m = RE_SEPARADOR.search(texto)
    if m and m.start() >= 8:
        return texto[: m.start()].strip()
    return texto.strip()


def clasificar_item(texto, propio_id):
    """Devuelve (tipo, familias_matched, evidencia). El primer tipo gana.

    `propio_id` (p.ej. "M09") se descarta de las referencias a modulos: un item
    que solo se cita a si mismo no depende de otro modulo.
    """
    enc = enunciado(texto)
    matched = []
    evidencia = ""
    for nombre, _desc, patrones in FAMILIAS_COMPILADAS:
        for pat in patrones:
            m = pat.search(enc)
            if not m:
                continue
            if nombre == "otro_modulo":
                # descartar la auto-referencia: solo cuenta OTRO modulo
                otros = [x for x in re.findall(r"\bM\d{2,3}\b", enc) if x != propio_id]
                if not otros:
                    continue
            matched.append(nombre)
            if not evidencia:
                evidencia = m.group(0)
            break
    return (matched[0] if matched else TIPO_RESIDUAL), matched, evidencia


def items_abiertos_de(ruta):
    """Items [ ] y [?] de una checklist, como lista de textos. None si no existe."""
    if not os.path.isfile(ruta):
        return None
    salida = []
    for linea in leer_texto(ruta).splitlines():
        m = RE_ITEM_ABIERTO.match(linea)
        if m:
            salida.append((m.group(1), m.group(2).strip()))
    return salida


def clasificar_dependencias(datos):
    """Clasifica los items abiertos de cada modulo `bloqueado_ambos`.

    Requiere `clasificar_pendientes()` ya corrido (usa `categoria_pendiente`).
    """
    modulos = []
    ciego = []
    total_items = 0
    global_tipo = dict((t, 0) for t in TIPOS_ORDEN)
    global_familias = dict((t, 0) for t in TIPOS_ORDEN)

    for r in datos["registros"]:
        if r.get("categoria_pendiente") != "bloqueado_ambos":
            continue
        ruta = os.path.join(DOC, r["carpeta"], "plan-actual", "05-Checklist.md")
        abiertos = items_abiertos_de(ruta)
        if abiertos is None:
            ciego.append("%s sin checklist legible" % r["id"])
            continue
        por_tipo = dict((t, 0) for t in TIPOS_ORDEN)
        items = []
        for marca, texto in abiertos:
            tipo, fams, ev = clasificar_item(texto, r["id"])
            por_tipo[tipo] += 1
            for f in fams:
                global_familias[f] += 1
            items.append(
                {
                    "marca": marca,
                    "enunciado": enunciado(texto)[:160],
                    "tipo": tipo,
                    "familias": fams,
                    "evidencia": ev,
                }
            )
        total_items += len(items)
        for t in TIPOS_ORDEN:
            global_tipo[t] += por_tipo[t]
        externos = sum(por_tipo[t] for t in TIPOS_EXTERNOS)
        # tipo dominante: maximo; empate -> el de mayor precedencia (orden de TIPOS_ORDEN)
        dominante = None
        for t in TIPOS_ORDEN:
            if dominante is None or por_tipo[t] > por_tipo[dominante]:
                dominante = t
        modulos.append(
            {
                "id": r["id"],
                "carpeta": r["carpeta"],
                "abiertos": len(items),
                "por_tipo": por_tipo,
                "externos": externos,
                "sin_dependencia_externa": externos == 0,
                "tipo_dominante": dominante if items else None,
                "items": items,
            }
        )

    esperados = list(datos["pendientes"]["ids"]["bloqueado_ambos"])
    if total_items == 0:
        ciego.append("no se leyo ningun item abierto de las checklists")
    if len(modulos) != len(esperados):
        ciego.append(
            "se clasificaron %d modulos de %d marcados bloqueado_ambos"
            % (len(modulos), len(esperados))
        )
    for m in modulos:
        if m["abiertos"] == 0:
            ciego.append("%s figura bloqueado_ambos pero no tiene items abiertos" % m["id"])

    modulos.sort(key=lambda m: (-m["externos"], -m["abiertos"], m["id"]))
    datos["dependencias"] = {
        "modulos": len(modulos),
        "modulos_esperados": len(esperados),
        "items": total_items,
        "por_tipo": global_tipo,
        "familias": global_familias,
        "tipos_externos": list(TIPOS_EXTERNOS),
        "sin_dependencia_externa": [m["id"] for m in modulos if m["sin_dependencia_externa"]],
        "con_dependencia_externa": [m["id"] for m in modulos if not m["sin_dependencia_externa"]],
        "detalle": modulos,
        "ciego": ciego,
    }
    return datos


def informe_dependencias(datos, bloque=0, tam=20):
    d = datos["dependencias"]
    lineas = []
    lineas.append("=== DEPENDENCIAS DE LOS MODULOS BLOQUEADOS (M01) ===")
    lineas.append("modulos bloqueado_ambos : %d" % d["modulos"])
    lineas.append("items abiertos leidos   : %d" % d["items"])
    if d["ciego"]:
        lineas.append("[CIEGO] " + " | ".join(d["ciego"]))
    lineas.append("")
    lineas.append("-- POR TIPO (precedencia: el primero que matchea gana) --")
    for t in TIPOS_ORDEN:
        n = d["por_tipo"][t]
        pct = (100.0 * n / d["items"]) if d["items"] else 0.0
        lineas.append("  %-24s %5d  %5.1f%%" % (t, n, pct))
    lineas.append("")
    lineas.append("-- FAMILIAS QUE MATCHEARON (un item puede tener varias) --")
    for t in TIPOS_ORDEN:
        if t in d["familias"]:
            lineas.append("  %-24s %5d" % (t, d["familias"][t]))
    lineas.append("")
    lineas.append(
        "-- MODULOS SIN NINGUNA DEPENDENCIA EXTERNA: %d --" % len(d["sin_dependencia_externa"])
    )
    lineas.append("   " + (", ".join(d["sin_dependencia_externa"]) or "(ninguno)"))
    lineas.append("")
    lineas.append(
        "-- MODULOS CON DEPENDENCIA EXTERNA: %d --" % len(d["con_dependencia_externa"])
    )
    lineas.append("   " + (", ".join(d["con_dependencia_externa"]) or "(ninguno)"))

    detalle = d["detalle"]
    if bloque:
        ini = (bloque - 1) * tam
        detalle = detalle[ini : ini + tam]
        lineas.append("")
        lineas.append("-- BLOQUE %d (modulos %d-%d de %d) --"
                      % (bloque, ini + 1, ini + len(detalle), d["modulos"]))
    else:
        lineas.append("")
        lineas.append("-- DETALLE POR MODULO --")
    lineas.append(
        "%-6s %-34s %-6s %-6s %-6s %-6s %-6s %-6s %s"
        % ("ID", "CARPETA", "ABIERT", "CTAS", "HDWR", "ASST", "DECI", "MOD", "DOMINANTE")
    )
    for m in detalle:
        pt = m["por_tipo"]
        lineas.append(
            "%-6s %-34s %-6d %-6d %-6d %-6d %-6d %-6d %s"
            % (
                m["id"],
                (m["carpeta"] or "-")[:34],
                m["abiertos"],
                pt["cuenta_externa_fundador"],
                pt["hardware"],
                pt["asset"],
                pt["decision_proyecto"],
                pt["otro_modulo"],
                m["tipo_dominante"] or "-",
            )
        )
    return "\n".join(lineas)


RE_CITA = re.compile(r"\bFLIP\b|\bcita\s*:", re.IGNORECASE)

CLASES_STALE = (
    ("modulo_abierto", "la checklist propia del modulo todavia tiene [ ]: el flip se adelanto"),
    ("solo_interrogantes", "la checklist propia no tiene [ ] pero si [?] abiertos"),
    ("cerrada_sin_fila_ok", "checklist propia cerrada, pero la fila GLOBAL no esta en OK"),
    ("sin_checklist", "no existe la checklist del modulo en disco"),
)


def clase_stale(r):
    """Razon por la que un [x] del indice NO se sostiene hoy."""
    if not r.get("checklist_existe"):
        return "sin_checklist"
    ch = r.get("checklist") or {}
    if ch.get(" ", 0) > 0:
        return "modulo_abierto"
    if ch.get("?", 0) > 0:
        return "solo_interrogantes"
    return "cerrada_sin_fila_ok"


def clasificar_stale(datos):
    """Anota cada [x] no sostenido con su clase y con si el flip trae cita.

    Un [x] es "stale" cuando hoy NO cumple el criterio ratificado
    (checklist propia cerrada Y fila GLOBAL en OK). La cita se busca en la
    propia linea del item y en su continuacion (los FLIP de la iter. 8 se
    anotaron en la linea siguiente).
    """
    detalle = []
    for r in datos["registros"]:
        # La cita se mide en TODOS los items (sirve tambien para auditar los
        # flips que hoy si se sostienen); la clase solo tiene sentido en los
        # que no se sostienen.
        texto_cita = (r.get("texto", "") or "") + " " + (r.get("siguiente", "") or "")
        r["cita"] = bool(RE_CITA.search(texto_cita))
        if r["marca_indice"] != "x" or r["candidato"]:
            continue
        r["clase_stale"] = clase_stale(r)
        detalle.append(r)
    por_clase = {nombre: [] for nombre, _ in CLASES_STALE}
    for r in detalle:
        por_clase[r["clase_stale"]].append(r["id"])
    datos["stale"] = {
        "total": len(detalle),
        "por_clase": por_clase,
        "con_cita": [r["id"] for r in detalle if r["cita"]],
        "sin_cita": [r["id"] for r in detalle if not r["cita"]],
        "detalle": detalle,
    }
    return datos


def informe_stale(datos):
    st = datos["stale"]
    lineas = []
    lineas.append("=== FLIPS NO SOSTENIDOS DEL INDICE MAESTRO M01 ===")
    lineas.append("items del indice     : %d" % datos["items"])
    lineas.append("[x] en el indice     : %d" % sum(
        1 for r in datos["registros"] if r["marca_indice"] == "x"))
    lineas.append("[x] sostenidos hoy   : %d" % len(datos["flipeados_validos"]))
    lineas.append("[x] NO sostenidos    : %d" % st["total"])
    lineas.append("  con cita de flip   : %d" % len(st["con_cita"]))
    lineas.append("  SIN cita de flip   : %d" % len(st["sin_cita"]))
    lineas.append("")
    lineas.append("-- POR CLASE --")
    for nombre, desc in CLASES_STALE:
        ids = st["por_clase"][nombre]
        lineas.append("%-22s %3d  %s" % (nombre, len(ids), desc))
    lineas.append("")
    lineas.append("-- DETALLE --")
    lineas.append("%-5s %-6s %-34s %-11s %-6s %s"
                  % ("ID", "LINEA", "CARPETA", "CHK x/?/[]", "CITA", "CLASE"))
    for r in st["detalle"]:
        ch = r["checklist"] or {"x": 0, "?": 0, " ": 0}
        lineas.append("%-5s %-6d %-34s %-11s %-6s %s" % (
            r["id"], r["linea"], (r["carpeta"] or "SIN CARPETA")[:34],
            "%d/%d/%d" % (ch["x"], ch["?"], ch[" "]),
            "si" if r["cita"] else "NO", r["clase_stale"]))
    lineas.append("")
    lineas.append("-- SIN CITA (el flip no esta justificado en el archivo) --")
    lineas.append("   " + (", ".join(st["sin_cita"]) or "(ninguno)"))
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
    ap.add_argument("--dependencias", action="store_true",
                    help="clasifica los items abiertos de los modulos bloqueado_ambos por TIPO de dependencia")
    ap.add_argument("--bloque", type=int, default=0,
                    help="con --dependencias: numero de bloque de 20 modulos a mostrar (1..N)")
    ap.add_argument("--tam", type=int, default=20,
                    help="con --dependencias: modulos por bloque (default 20)")
    ap.add_argument("--stale", action="store_true",
                    help="clasifica los [x] NO sostenidos hoy (clase + cita del flip)")
    args = ap.parse_args(argv)

    if args.bloque < 0 or args.tam < 1:
        print("uso invalido: --bloque >= 0 y --tam >= 1")
        return 2

    if not os.path.isfile(INDICE):
        print("DETECTOR CIEGO (exit 3): falta el indice maestro %s" % INDICE)
        return 3
    if not os.path.isfile(GLOBAL):
        print("DETECTOR CIEGO (exit 3): falta CHECKLIST-GLOBAL.md")
        return 3

    datos = clasificar_pendientes(clasificar(medir()))
    datos = clasificar_stale(datos)
    if args.dependencias or args.json:
        datos = clasificar_dependencias(datos)

    ciego_dep = bool(args.dependencias and datos["dependencias"]["ciego"])

    if datos["ciego"] or ciego_dep:
        if args.json:
            print(json.dumps(datos, ensure_ascii=False, indent=1))
        elif args.dependencias:
            print(informe_dependencias(datos, args.bloque, args.tam))
        elif args.stale:
            print(informe_stale(datos))
        elif args.pendientes:
            print(informe_pendientes(datos))
        else:
            print(informe(datos))
        return 3

    if args.json:
        print(json.dumps(datos, ensure_ascii=False, indent=1))
    elif args.dependencias:
        print(informe_dependencias(datos, args.bloque, args.tam))
    elif args.stale:
        print(informe_stale(datos))
    elif args.pendientes:
        print(informe_pendientes(datos))
    else:
        print(informe(datos))

    if args.check and args.stale and datos["stale"]["sin_cita"]:
        return 1
    if args.check and datos["candidatos_nuevos"]:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
