# -*- coding: utf-8 -*-
"""MUESTREO P-100 (AGENTS.md 21.8.2.b) - muestreador scriptable y determinista.

Objetivo: dado un modulo, contar marcas reales por prefijo de linea, elegir una
muestra DETERMINISTA de items [x] con verbo de creacion, y verificar cada item
contra DISCO (el artefacto citado existe, o el identificador citado da >=1 hit
en el codigo). No decide sellos: emite evidencia para que el verificador firme.

Uso:
  python scripts/muestreo_p100.py --modulo 48
  python scripts/muestreo_p100.py --modulo 48 --muestra 8
  python scripts/muestreo_p100.py --todos --json

Codigos de salida:
  0 = muestreo completo, 0-1 fallas (sello sostenible)
  1 = 2 o mas fallas (sello DENEGADO por 21.8.2.b punto 3)
  3 = DETECTOR CIEGO (no se pudo leer el 05 / no hay items muestreables: la
      muestra vacia NO es evidencia y el sello queda denegado)
"""
import argparse
import io
import json
import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOC = os.path.join(RAIZ, "DOCUMENTACION")
RAIZ_JUEGO = os.path.join(RAIZ, "game", "isla-ancestral")

# Un item de checklist: guion, corchete, marca, corchete, texto.
RX_ITEM = re.compile(r"^\s*- \[([ x?])\]\s*(.+)$")
# La UNIDAD que sigue al conteo NO es normativa y el ORDEN de las etiquetas
# tampoco: el repo escribe "8 items", "211 lineas-item", "120 líneas-ítem",
# "Completados ... No resueltos ... Pendientes" (M110/M152) y "Totales:" sin
# negrita (M30/M32). Un regex posicional reportaba "SIN LINEA" sobre checklists
# que SI la tienen (medido en M40: "211 lineas-item"). Se parsea por ETIQUETA:
# cada numero se busca por su nombre, en cualquier orden, con o sin `**`.
RX_TOTALES_MARCA = re.compile(r"^\s*(?:\*\*)?\s*Totales\s*:\s*(?:\*\*)?", re.I)
RX_TOT_TOTAL = re.compile(r"^\s*(?:\*\*)?\s*Totales\s*:\s*(?:\*\*)?\s*(\d+)", re.I)
RX_TOT_COMP = re.compile(r"Completados\s*:\s*(\d+)", re.I)
RX_TOT_PEND = re.compile(r"Pendientes\s*:\s*(\d+)", re.I)
# "No resueltos: 0" | "No resueltos (con dueño): 0" | "[?]: 0" (M157 usa el
# simbolo de la marca como etiqueta: mismo concepto, otro vocabulario).
RX_TOT_NR = re.compile(r"(?:No\s+resueltos|\[\?\])\s*[^:\d]{0,40}:\s*(\d+)", re.I)
RX_BACKTICK = re.compile(r"`([^`\n]{2,160})`")
# Mencion de archivo FUERA de backticks (ej: "jugador_lib.tres 3 clips"). Solo
# extensiones de codigo/dato: no se extraen identificadores sueltos para no
# generar falsos positivos con prosa (una palabra cualquiera puede "existir").
RX_ARCHIVO_DESNUDO = re.compile(
    r"(?<![\w`/.])([\w][\w./\-]{1,120}\.(?:gd|tres|tscn|json|py|md|cfg|gdshader|yml))(?![\w`])")
# Extension suelta entre backticks (`.tres`): se cita como FORMATO, no como archivo.
EXTENSION_SUELTA = re.compile(r"^\.[A-Za-z0-9]{1,12}$")

# ── Cita NEGATIVA (el item menciona el artefacto para decir que NO existe) ─────
# Un item puede citar un archivo justamente para aclarar que no existe: "el claim
# citaba `slot.tscn`, que NO existe". Contarlo como PATH FALTA fabrica un hueco
# que el propio texto desmiente: medido 30-oct en M14 L163, un item real quedo
# PARCIAL por un `slot.tscn` que el item declara inexistente.
# El marcador tiene que estar ANCLADO al token (solo puntuacion y "que"/"el" de
# por medio). Aproposito CONSERVADOR: si la negacion es dudosa NO se aplica, para
# que el error residual sea un hueco falso (retrasa un sello) y nunca un OK falso
# (concederia un sello sobre un artefacto ausente).
RX_NEG_PRE = re.compile(
    r"(?:no\s+existe[n]?|no\s+existia|no\s+existía|inexistente[s]?|no\s+hay|"
    r"no\s+aparece|no\s+figura|no\s+se\s+encuentra|no\s+se\s+encontro|"
    r"no\s+se\s+encontró|eliminad[oa]s?|retirad[oa]s?|borrad[oa]s?|"
    r"obsolet[oa]s?|descartad[oa]s?|en\s+vez\s+de|en\s+lugar\s+de|"
    r"nunca\s+existio|nunca\s+existió)"
    r"[\s,;:(\[\]*_`\-]*(?:el\s+|la\s+|los\s+|las\s+|archivo\s+|doc\s+)?$", re.I)
RX_NEG_POST = re.compile(
    r"^[\s,;:.)\]*`\-]*(?:que\s+|el\s+cual\s+)?"
    r"(?:no\s+existe[n]?|no\s+existia|no\s+existía|no\s+aparece|no\s+figura|"
    r"no\s+se\s+encuentra|no\s+se\s+encontro|no\s+se\s+encontró|"
    r"es\s+inexistente|inexistente[s]?)", re.I)
NEG_PRE_CHARS = 60
NEG_POST_CHARS = 40

# Identificador snake_case inmediatamente despues de un `.gd` citado:
# "`inventory_layer.gd` _crear_slots". Exige >=1 underscore para no capturar prosa.
RX_IDENT_PEGADO = re.compile(r"`[^`\n]*\.gd`\s+(_?[a-z][a-z0-9]*(?:_[a-z0-9]+)+)")


def _es_cita_negativa(texto, ini_bt, fin_bt):
    """True si el artefacto entre [ini_bt, fin_bt) se cita como INEXISTENTE.
    `ini_bt` es el backtick de apertura (o el inicio del token desnudo) y `fin_bt`
    el fin del token: las ventanas excluyen el token para no leer su propio texto."""
    pre = (texto or "")[max(0, ini_bt - NEG_PRE_CHARS):ini_bt]
    post = (texto or "")[fin_bt:fin_bt + NEG_POST_CHARS]
    # El marcador no puede pertenecer a OTRA cita: se corta en el backtick vecino.
    if "`" in pre:
        pre = pre.rsplit("`", 1)[1]
    if "`" in post:
        post = post.split("`", 1)[0]
    return bool(RX_NEG_PRE.search(pre) or RX_NEG_POST.search(post))

VERBOS_CREACION = (
    "crear", "crea", "implementar", "implementa", "escribir", "escribe",
    "generar", "genera", "agregar", "agrega", "anadir", "anade", "añadir", "añade",
    "configurar", "configura", "integrar", "integra", "conectar", "conecta",
    "construir", "construye", "instrumentar", "instrumenta", "migrar", "migra",
    "exportar", "exporta", "cablear", "cablea", "medir", "mide",
)
# "Definir", "documentar", "mapear", "separar", "incluir" quedan FUERA a proposito:
# son items de diseno/meta, no afirman que un artefacto EXISTA hoy. 21.8.2.b pide
# elegir por verbos de creacion justamente para no muestrear meta-items.

EXTENSIONES = (
    ".gd", ".json", ".tres", ".tscn", ".md", ".py", ".cfg", ".gdshader",
    ".shader", ".png", ".glb", ".wav", ".ogg", ".svg", ".import", ".uid",
    ".txt", ".yml", ".yaml", ".csv",
)

# Prefijos que indican una ruta (no un identificador suelto).
PREFIJOS_RUTA = ("scripts/", "tests/", "scenes/", "assets/", "data/", "addons/",
                 "docs/", "res://", "user://", "DOCUMENTACION/", "Logs/", "game/")

RAICES_PATH = (
    RAIZ_JUEGO,
    RAIZ,
    os.path.join(RAIZ, "game"),
    os.path.join(DOC),
)

RAICES_GREP = (
    os.path.join(RAIZ_JUEGO, "scripts"),
    os.path.join(RAIZ_JUEGO, "tests"),
    os.path.join(RAIZ_JUEGO, "scenes"),
    os.path.join(RAIZ_JUEGO, "data"),
)


def normalizar(texto):
    """Colapsa espacios y quita la cita de diseno posterior al ' -- ' o ' — '."""
    t = re.sub(r"\s+", " ", texto or "").strip()
    return t


def contar_marcas(lineas):
    """Cuenta por PREFIJO de linea (no por substring). Devuelve dict."""
    c = {"x": 0, " ": 0, "?": 0}
    for ln in lineas:
        m = RX_ITEM.match(ln)
        if m:
            c[m.group(1)] += 1
    return c


def extraer_items(lineas):
    """Lista de (n_linea_1based, marca, texto)."""
    out = []
    for i, ln in enumerate(lineas, 1):
        m = RX_ITEM.match(ln)
        if m:
            out.append((i, m.group(1), normalizar(m.group(2))))
    return out


def _primera_palabra(texto):
    """Primera palabra significativa, sin markdown ni acentos."""
    t = re.sub(r"^[\s*_`\-•]+", "", texto or "")
    m = re.match(r"([A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)", t)
    if not m:
        return ""
    w = m.group(1).lower()
    for a, b in (("á", "a"), ("é", "e"), ("í", "i"), ("ó", "o"), ("ú", "u"), ("ü", "u"), ("ñ", "n")):
        w = w.replace(a, b)
    return w


def es_creacion(texto):
    """True si el item ARRANCA con un verbo de creacion.
    Se compara la primera palabra completa: el matching por substring clasificaba
    "Documentar integracion..." como creacion (por "integra") y "esto es creacion"
    como creacion (por "crea"), metiendo items de diseno en la muestra."""
    return _primera_palabra(texto) in VERBOS_CREACION


def _parece_ruta(tok):
    tl = tok.lower()
    if tl.startswith(PREFIJOS_RUTA):
        return True
    if "/" in tok or "\\" in tok:
        return True
    return tl.endswith(EXTENSIONES)


def _limpiar_ident(tok):
    t = tok.strip()
    t = re.sub(r"\(\)$", "", t)
    t = re.sub(r"^[.\-]+", "", t)
    return t.strip()


def extraer_artefactos_ex(texto):
    """Devuelve (rutas, identificadores, negadas).

    `negadas` son rutas que el item menciona para declararlas INEXISTENTES: no son
    huecos, son aclaraciones del propio item. Se devuelven aparte para poder
    mostrarlas (visibilidad) sin que cuenten como falla.
    """
    rutas, idents, negadas = [], [], []
    for m in RX_BACKTICK.finditer(texto or ""):
        tok = m.group(1).strip()
        if not tok or " " in tok:
            continue
        # Una EXTENSION suelta (`.tres`, `.gd`) NO es un archivo: `_parece_ruta` la
        # acepta porque termina en extension valida y el muestreo reporta HUECO
        # "PATH FALTA .tres" (medido 29-oct en M74 L41/L70/L75: 3 huecos falsos
        # que daban DISCREPANCIA a un modulo con evidencia real).
        if EXTENSION_SUELTA.match(tok):
            continue
        if _parece_ruta(tok):
            if _es_cita_negativa(texto, m.start(), m.end()):
                negadas.append(tok)
            else:
                rutas.append(tok)
        else:
            ident = _limpiar_ident(tok)
            # identificadores utiles: snake_case o CamelCase con >=6 chars
            if len(ident) >= 6 and re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", ident):
                if "_" in ident or re.search(r"[a-z][A-Z]", ident):
                    # Misma regla que para las rutas: "`_crear_slots` no existe" es
                    # una aclaracion, no un hueco (medido 30-oct en M14 L163).
                    if _es_cita_negativa(texto, m.start(), m.end()):
                        negadas.append(ident)
                    else:
                        idents.append(ident)
    for m in RX_ARCHIVO_DESNUDO.finditer(texto or ""):
        tok = m.group(1).strip()
        if _es_cita_negativa(texto, m.start(), m.end()):
            negadas.append(tok)
        else:
            rutas.append(tok)
    # Identificador suelto pegado a una cita de archivo: "`inventory_layer.gd`
    # _crear_slots". El nombre del metodo NO va entre backticks, asi que sin esta
    # rama el muestreo avala un item que cita una funcion inexistente (medido
    # 30-oct: M14 L163 cita `_crear_slots` y el real es `_construir_slots`).
    # Solo snake_case con >=1 underscore: medido en 23.069 items [x] da 5
    # ocurrencias, 4 resuelven y la unica GREP 0 es un defecto REAL -> ruido nulo.
    for m in RX_IDENT_PEGADO.finditer(texto or ""):
        ident = _limpiar_ident(m.group(1))
        if len(ident) >= 6:
            idents.append(ident)
    # dedup preservando orden
    return (list(dict.fromkeys(rutas)), list(dict.fromkeys(idents)),
            list(dict.fromkeys(negadas)))


def extraer_artefactos(texto):
    """Compatibilidad: (rutas, identificadores). Ver `extraer_artefactos_ex`."""
    rutas, idents, _ = extraer_artefactos_ex(texto)
    return rutas, idents


_IDX = None


def _tokens(nombre):
    """Tokens alfanumericos de un nombre de archivo, sin ceros a la izquierda ni
    palabras genericas de la nomenclatura del proyecto."""
    base = os.path.basename(nombre).lower()
    base = re.sub(r"\.(md|gd|json|tres|tscn|py|cfg|txt)$", "", base)
    toks = re.findall(r"[a-z0-9]+", base)
    gen = {"documento", "de", "del", "la", "el", "actual", "md", "res"}
    out = []
    for t in toks:
        if t in gen:
            continue
        t = t.lstrip("0") or "0"
        if t.isdigit():
            continue
        out.append(t)
    return out


def _indexar():
    """Indice basename -> rutas, y token-set -> rutas (solo .md).
    Cubre docs, logs, workflows y el arbol de codigo del juego: si el indice no
    incluyera el arbol de tests/scripts, un item que cita `test_xxx.gd` daria
    PATH FALTA aunque el archivo exista (falso HUECO). Se construye UNA vez."""
    global _IDX
    if _IDX is not None:
        return _IDX
    por_base = {}
    por_tokens = {}
    raices = [DOC, os.path.join(RAIZ, "docs"), os.path.join(RAIZ, "Logs"),
              os.path.join(RAIZ, ".github"), os.path.join(RAIZ, "scripts"),
              RAIZ_JUEGO]
    poda = {".git", "__pycache__", ".godot", "site-packages", ".venv",
            "assets", "Godot", "Obsoletos", "backups"}
    for raiz in raices:
        if not os.path.isdir(raiz):
            continue
        for dirpath, dirnames, filenames in os.walk(raiz):
            dirnames[:] = [d for d in dirnames if d not in poda]
            for fn in filenames:
                p = os.path.join(dirpath, fn)
                por_base.setdefault(fn.lower(), []).append(p)
                if fn.lower().endswith(".md"):
                    tk = frozenset(_tokens(fn))
                    if tk:
                        por_tokens.setdefault(tk, []).append(p)
    # archivos sueltos en la raiz del repo (p.ej. estado_release.json)
    for fn in os.listdir(RAIZ):
        p = os.path.join(RAIZ, fn)
        if os.path.isfile(p):
            por_base.setdefault(fn.lower(), []).append(p)
    _IDX = (por_base, por_tokens)
    return _IDX


def resolver_path(ruta, raices=None, prefer=None):
    """Devuelve (ruta_absoluta, modo) o (None, None).
    OJO: `raices=None` a proposito. Con `raices=RAICES_PATH` el default se liga en
    tiempo de DEFINICION y parchear el modulo (tests) no surte efecto.
    modo: DIRECTO | BASENAME | VARIANTE (alias de nombre, p.ej. 03-Diseno.md ->
    3-DOCUMENTO-DISENO-ACTUAL.md). La variante cuenta como EXISTENTE por la regla
    adoptada (msg 371): solo es hueco si no existe en NINGUNA base ni variante."""
    if raices is None:
        raices = RAICES_PATH
    cand = ruta
    for pref in ("res://", "user://"):
        if cand.startswith(pref):
            cand = cand[len(pref):]
    cand = cand.replace("\\", "/").lstrip("/")
    # AMBIGUEDAD: `03-Diseno.md` existe en decenas de modulos. Si el item vive en un
    # modulo, su propio plan-actual/ es el destino natural de la cita: probarlo
    # PRIMERO evita verificar contra el doc de otro modulo (falso RESUELTO).
    if prefer:
        pp = os.path.join(prefer, cand.replace("/", os.sep))
        if os.path.isfile(pp):
            return pp, "MODULO"
        if os.path.isdir(pp):
            return pp, "MODULO"
        # Citas relativas a la RAIZ del modulo (`plan-actual/`, `plan-inicial/`):
        # `prefer` es el propio plan-actual, asi que join() daba
        # "plan-actual/plan-actual" y se reportaba PATH FALTA sobre un directorio
        # que EXISTE (falso hueco medido en M40 L260/L253). Se prueba un nivel
        # arriba antes de descartar.
        pr = os.path.dirname(os.path.normpath(prefer))
        if pr and pr != prefer:
            pp2 = os.path.join(pr, cand.replace("/", os.sep))
            if os.path.isfile(pp2):
                return pp2, "MODULO_RAIZ"
            if os.path.isdir(pp2):
                return pp2, "MODULO_RAIZ"
    for raiz in raices:
        p = os.path.join(raiz, cand.replace("/", os.sep))
        if os.path.isfile(p):
            return p, "DIRECTO"
        if os.path.isdir(p):
            return p, "DIRECTO"
    por_base, por_tokens = _indexar()
    base = os.path.basename(cand).lower()
    if base in por_base:
        return por_base[base][0], "BASENAME"
    # alias por subconjunto de tokens (solo .md: los docs se citan con nombres viejos)
    if base.endswith(".md"):
        tk = frozenset(_tokens(base))
        if tk:
            for cand_tk, paths in por_tokens.items():
                if tk <= cand_tk:
                    return paths[0], "VARIANTE"
    return None, None


def grep_identificador(ident, raices=None, max_archivos=400):
    """Cuenta archivos de codigo con >=1 hit del identificador. Devuelve int.
    `raices=None` por la misma razon que en resolver_path (binding diferido)."""
    if raices is None:
        raices = RAICES_GREP
    patron = re.compile(r"(?<![A-Za-z0-9_])" + re.escape(ident) + r"(?![A-Za-z0-9_])")
    hits = 0
    revisados = 0
    for raiz in raices:
        if not os.path.isdir(raiz):
            continue
        for dirpath, dirnames, filenames in os.walk(raiz):
            dirnames[:] = [d for d in dirnames if d not in
                           (".git", "Obsoletos", "__pycache__", ".godot", "site-packages", ".venv")]
            for fn in filenames:
                if not fn.endswith((".gd", ".tscn", ".tres", ".py", ".json", ".cfg")):
                    continue
                revisados += 1
                if revisados > 20000:
                    return hits
                p = os.path.join(dirpath, fn)
                try:
                    with io.open(p, "r", encoding="utf-8", errors="ignore") as fh:
                        for ln in fh:
                            if patron.search(ln):
                                hits += 1
                                break
                except OSError:
                    continue
                if hits >= max_archivos:
                    return hits
    return hits


def muestreo_determinista(items, n):
    """Elige n items repartidos uniformemente (paso fijo). Reproducible."""
    if not items:
        return []
    if len(items) <= n:
        return list(items)
    paso = len(items) / float(n)
    return [items[int(i * paso)] for i in range(n)]


def clasificar_item(texto):
    """Devuelve (rutas, idents) y decide si el item es verificable automaticamente."""
    rutas, idents = extraer_artefactos(texto)
    return rutas, idents


def verificar_item(texto, prefer=None):
    """Devuelve dict con resultado: RESUELTO / HUECO / INDETERMINADO + detalle."""
    rutas, idents, negadas = extraer_artefactos_ex(texto)
    detalle = []
    fallas = 0
    aciertos = 0
    for r in rutas:
        p, modo = resolver_path(r, prefer=prefer)
        if p:
            aciertos += 1
            detalle.append("PATH OK [%s] %s -> %s" % (modo, r, os.path.relpath(p, RAIZ)))
        else:
            fallas += 1
            detalle.append("PATH FALTA %s" % r)
    for ident in idents:
        n = grep_identificador(ident)
        if n >= 1:
            aciertos += 1
            detalle.append("GREP OK %s (%d archivos)" % (ident, n))
        else:
            fallas += 1
            detalle.append("GREP 0 %s" % ident)
    # Las citas negativas NO son falla ni acierto: el item declara que no existen.
    # Se muestran para que un humano vea la aclaracion, pero no mueven el veredicto.
    for r in negadas:
        detalle.append("NEGADO %s (el item lo declara inexistente)" % r)
    if aciertos and not fallas:
        res = "RESUELTO"
    elif fallas and not aciertos:
        res = "HUECO"
    elif fallas and aciertos:
        res = "PARCIAL"
    elif negadas:
        # Cita SOLO artefactos que el propio item declara inexistentes: no queda
        # evidencia positiva. Eso es un HUECO, no una aclaracion inofensiva:
        # medido 30-oct en M85 (32 items [x] cuya nota dice "los artefactos
        # citados NO existen ... = 0 en disco"). Decir RESUELTO o INDETERMINADO
        # aqui avalaria un item cuya unica evidencia es una ausencia.
        res = "HUECO"
    else:
        res = "INDETERMINADO"
    return {"resultado": res, "rutas": rutas, "identificadores": idents,
            "negadas": negadas, "detalle": detalle, "fallas": fallas,
            "aciertos": aciertos}


def ruta_checklist(modulo):
    """Busca DOCUMENTACION/{NN}-*/plan-actual/05-Checklist.md tolerando 2 o 3 digitos."""
    mods = str(modulo)
    # El nombre real de carpeta usa 2 o 3 digitos segun el modulo (48-Animacion,
    # 151-Control-Final). Se prueban TODAS las variantes: si solo se probara la
    # variante de 3 digitos, un modulo de 2 digitos daria "SIN 05 EN DISCO" y el
    # muestreo saldria ciego (falso verde por ausencia de dato).
    prefs = ["%s-" % mods, "0%s-" % mods, "00%s-" % mods]
    prefs = list(dict.fromkeys(prefs))
    for d in sorted(os.listdir(DOC)):
        for pref in prefs:
            if d.startswith(pref):
                p = os.path.join(DOC, d, "plan-actual", "05-Checklist.md")
                if os.path.isfile(p):
                    return p
    return None


def _una(linea):
    """Los 4 numeros de UNA linea Totales, o None si falta alguno.

    Parseo por etiqueta (no posicional): tolera cualquier orden, cualquier
    unidad y parentesis con digitos dentro de una etiqueta.
    """
    mt = RX_TOT_TOTAL.match(linea)
    mc = RX_TOT_COMP.search(linea)
    mp = RX_TOT_PEND.search(linea)
    mn = RX_TOT_NR.search(linea)
    if not (mt and mc and mp and mn):
        return None
    return {"total": int(mt.group(1)), "x": int(mc.group(1)),
            "vacio": int(mp.group(1)), "q": int(mn.group(1)), "linea": linea.strip()}


def leer_totales(lineas):
    """Ultima linea **Totales:** parseada -> dict o None."""
    ult = None
    for ln in lineas:
        if not RX_TOTALES_MARCA.match(ln):
            continue
        t = _una(ln)
        if t:
            ult = t
    return ult


def estado_totales(lineas):
    """Estado del cruce con `**Totales:**`, sin confundir ausencia con ceguera.

    - AUSENTE:   el checklist no declara Totales -> no hay nada que cruzar.
    - NO_PARSEA: la linea EXISTE pero el formato no se entiende. Es un fallo de
      MEDICION, no un "no hay linea": reportarlo igual que AUSENTE fue el defecto
      medido en M40 (formato "211 lineas-item"). Se devuelve la linea cruda para
      que quien lea pueda corregir el parser o el checklist.
    - OK:        parsea; `totales` trae los cuatro numeros.
    """
    totales = leer_totales(lineas)
    if totales:
        return {"estado": "OK", "linea": totales["linea"], "totales": totales}
    for ln in lineas:
        if RX_TOTALES_MARCA.match(ln.strip()):
            return {"estado": "NO_PARSEA", "linea": ln.strip(), "totales": None}
    return {"estado": "AUSENTE", "linea": "", "totales": None}



def analizar_modulo(modulo, n_muestra=5):
    p = ruta_checklist(modulo)
    if not p:
        return {"modulo": modulo, "error": "SIN 05 EN DISCO"}
    with io.open(p, "r", encoding="utf-8", errors="replace") as fh:
        lineas = fh.read().split("\n")
    marcas = contar_marcas(lineas)
    items = extraer_items(lineas)
    totales = leer_totales(lineas)
    est_totales = estado_totales(lineas)
    creacion = [(n, t) for (n, mk, t) in items if mk == "x" and es_creacion(t)]
    # Poblacion AUTO-VERIFICABLE: items [x] que citan un artefacto (ruta o identificador).
    # Un item sin artefacto citado no se puede contrastar contra disco por script: va a
    # la COLA MANUAL (se reporta el conteo y una lista corta para revision humana).
    auto, manual = [], []
    for n, t in creacion:
        rutas, idents = extraer_artefactos(t)
        if rutas or idents:
            auto.append((n, t))
        else:
            manual.append((n, t))
    # FALLBACK: hay modulos cuyo checklist esta redactado como enunciados de diseno
    # ("Idle, caminar, correr del jugador") y no arrancan con verbo de creacion ->
    # la poblacion por verbo queda en 0 y el muestreo saldria VACIO (falso verde por
    # muestra vacia). Se completa con los [x] que CITAN artefacto, sea cual sea el verbo.
    if len(auto) < max(5, int(-(-marcas["x"] * 5 // 100))):
        ya = set(n for n, _ in auto)
        extra = []
        for (n, mk, t) in items:
            if mk != "x" or n in ya:
                continue
            rutas, idents = extraer_artefactos(t)
            if rutas or idents:
                extra.append((n, t))
        auto = sorted(auto + extra, key=lambda x: x[0])
        manual = [(n, t) for (n, t) in manual if n not in set(x[0] for x in auto)]
    # Tamano de muestra que EXIGE 21.8.2.b: max(5, 5% de los [x]) del modulo.
    n_req = max(5, int(-(-marcas["x"] * 5 // 100)))  # techo de x*0.05
    n_obj = max(n_req, 5)
    muestra = muestreo_determinista(auto, n_obj)
    faltan = max(0, n_obj - len(muestra))
    manual_sub = muestreo_determinista(manual, faltan) if faltan else []
    filas = []
    for n, t in muestra:
        v = verificar_item(t, prefer=os.path.dirname(p))
        filas.append({"linea": n, "texto": t[:200], "veredicto": v["resultado"],
                      "detalle": v["detalle"], "fallas": v["fallas"],
                      "negadas": len(v.get("negadas") or []), "modo": "SCRIPT"})
    for n, t in manual_sub:
        filas.append({"linea": n, "texto": t[:200], "veredicto": "MANUAL",
                      "detalle": ["sin artefacto citado: exige grep dirigido"],
                      "fallas": 0, "negadas": 0, "modo": "MANUAL"})
    fallas = sum(1 for f in filas if f["veredicto"] in ("HUECO", "PARCIAL"))
    huecos = sum(1 for f in filas if f["veredicto"] == "HUECO")
    parciales = sum(1 for f in filas if f["veredicto"] == "PARCIAL")
    indet = sum(1 for f in filas if f["veredicto"] == "INDETERMINADO")
    negadas = sum(f.get("negadas", 0) for f in filas)
    drift = None
    if totales:
        reales = marcas["x"] + marcas[" "] + marcas["?"]
        drift = {
            "totales_declarados": [totales["x"], totales["vacio"], totales["q"], totales["total"]],
            "reales_medidos": [marcas["x"], marcas[" "], marcas["?"], reales],
            "delta_total": totales["total"] - reales,
            "delta_x": totales["x"] - marcas["x"],
        }
    # MUESTRA VACIA NO ES EVIDENCIA. Un modulo cuyos [x] no citan artefacto y no
    # usan verbo de creacion deja `filas` en 0; sin este corte el resumen sale
    # "fallas=0 -> OK" y el muestreo avala un sello SIN haber mirado nada (medido
    # 29-oct en el indice maestro M01: 122 [x], 0 muestreables, veredicto OK).
    if not filas:
        veredicto = "CIEGO"
    elif huecos >= 2:
        veredicto = "DISCREPANCIA"
    elif fallas >= 1 or indet >= 1:
        veredicto = "CAVEAT"
    else:
        veredicto = "OK"
    return {"modulo": modulo, "checklist": os.path.relpath(p, RAIZ),
            "marcas": marcas, "totales": totales, "totales_estado": est_totales,
            "drift": drift,
            "muestra": filas, "fallas": fallas, "huecos": huecos,
            "parciales": parciales, "indeterminados": indet,
            "creacion_total": len(creacion), "auto_total": len(auto),
            "manual_total": len(manual),
            "manual_muestra": [{"linea": n, "texto": t[:160]} for n, t in manual[:8]],
            "veredicto": veredicto, "n_muestra": len(filas), "n_req": n_req,
            "negadas": negadas, "manual_sub": len(manual_sub)}


def imprimir(r, verbose=True):
    print("=" * 78)
    print("MODULO %s  (%s)" % (r["modulo"], r.get("checklist", r.get("error"))))
    if r.get("error"):
        print("  ERROR: %s" % r["error"])
        return
    m = r["marcas"]
    print("  marcas medidas por prefijo: [x]=%d  [ ]=%d  [?]=%d  total=%d"
          % (m["x"], m[" "], m["?"], m["x"] + m[" "] + m["?"]))
    d = r["drift"]
    est = r.get("totales_estado") or {"estado": "AUSENTE", "linea": ""}
    if d:
        print("  Totales declarados: %s   reales: %s   delta_total=%+d delta_x=%+d"
              % (d["totales_declarados"], d["reales_medidos"], d["delta_total"], d["delta_x"]))
    elif est["estado"] == "NO_PARSEA":
        # Distinto de AUSENTE a proposito: la linea esta y el parser no la entiende.
        print("  Totales: LINEA PRESENTE PERO NO PARSEA (revisar formato) -> %s"
              % est["linea"][:120])
    else:
        print("  Totales: SIN LINEA **Totales:** EN DISCO")
    print("  muestra P-100: %d items (requisito 21.8.2.b = %d; auto-verificables %d, manuales %d)"
          % (r["n_muestra"], r["n_req"], r["auto_total"], r["manual_sub"]))
    print("  poblacion: %d [x] con verbo de creacion + %d [x] sin verbo que SI citan artefacto"
          % (r["creacion_total"], max(0, r["auto_total"] - r["creacion_total"])))
    for f in r["muestra"]:
        print("   - L%-4d [%s] %s" % (f["linea"], f["veredicto"], f["texto"][:110]))
        if verbose:
            for det in f["detalle"]:
                print("        %s" % det)
    if r["manual_total"]:
        print("  COLA MANUAL (%d items de creacion sin artefacto citado, no verificables por script):"
              % r["manual_total"])
        for f in r["manual_muestra"]:
            print("   - L%-4d %s" % (f["linea"], f["texto"][:100]))
    print("  RESUMEN: fallas=%d (huecos=%d parciales=%d) indeterminados=%d negadas=%d  -> VEREDICTO: %s"
          % (r["fallas"], r["huecos"], r["parciales"], r["indeterminados"],
             r.get("negadas", 0), r["veredicto"]))
    if r["veredicto"] == "CIEGO":
        print("  ATENCION: 0 items muestreables (ni por verbo de creacion ni por cita de artefacto).")
        print("            Muestra vacia NO es evidencia: sello DENEGADO hasta muestreo manual.")


def modulos_en_disco():
    """Todos los M## con `plan-actual/05-Checklist.md` en DOCUMENTACION.

    `--todos` estaba hardcodeado a 4 ids (48/60/55/151): un flag que promete
    "todos" y escanea cuatro es la trampa del detector ciego con otro disfraz
    (el resumen sale corto y nadie lo nota). Se enumera el disco, ordenado.
    """
    ids = []
    try:
        nombres = sorted(os.listdir(DOC))
    except OSError:
        return ids
    for d in nombres:
        if not os.path.isdir(os.path.join(DOC, d)):
            continue
        if not os.path.isfile(os.path.join(DOC, d, "plan-actual", "05-Checklist.md")):
            continue
        m = re.match(r"(\d+)", d)
        if m:
            ids.append(m.group(1))
    return ids


def main(argv=None):
    ap = argparse.ArgumentParser(description="Muestreo P-100 (21.8.2.b)")
    ap.add_argument("--modulo", action="append", default=[])
    ap.add_argument("--todos", action="store_true")
    ap.add_argument("--muestra", type=int, default=5)
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--quiet", action="store_true")
    a = ap.parse_args(argv)
    mods = list(a.modulo)
    if a.todos:
        mods = modulos_en_disco()
    if not mods:
        ap.print_help()
        return 3
    res = [analizar_modulo(m, a.muestra) for m in mods]
    if a.json:
        print(json.dumps(res, ensure_ascii=False, indent=2))
    else:
        for r in res:
            imprimir(r, verbose=not a.quiet)
    if any(r.get("error") for r in res):
        return 3
    if any(r.get("veredicto") == "CIEGO" for r in res):
        return 3
    return 1 if any(r["huecos"] >= 2 for r in res) else 0


if __name__ == "__main__":
    sys.exit(main())
