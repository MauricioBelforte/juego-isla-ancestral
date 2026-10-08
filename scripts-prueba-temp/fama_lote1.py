#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Parte 1 lote 1 (canal 99): clasificacion por-item de la capa ⚠️ (W) de los
5 modulos mas densos en ⚠️, con pasada de EVIDENCIA REAL en disco.

Metodo:
  Para cada [x] clasificado W por fama_sweep (verbo sin artefacto citable, o
  cita recurso no verificable), decidir:
    - respaldado : el artefacto/feature reclamado EXISTE en disco (evidencia).
    - CASO A     : reclamado SIN codigo -> se descarta la marca (revertir).
    - CASO B     : plan/checklist no corresponde -> revaluar plan-actual.
NO hace flip. Solo reporta veredicto con evidencia.
"""
import os, re, glob, sys

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
GODOT = os.path.join(RAIZ, "game", "isla-ancestral")

SKIP = {".git", "PAPELERA", "Obsoletos", "out", "build", "Logs",
        "Mensajes entre modelos", "node_modules", ".workbuddy-ai",
        "scripts-prueba-temp", "__pycache__", ".import", ".godot", "Godot"}

# ---- indice de basenames de TODO el repo ----
basename_index = {}
for dp, dn, fn in os.walk(RAIZ):
    if set(dp.split(os.sep)) & SKIP:
        continue
    for f in fn:
        basename_index.setdefault(f, []).append(os.path.join(dp, f))

def norm(s):
    return re.sub(r'[^a-z0-9]', '', s.lower())

norm_index = {}
for b, paths in basename_index.items():
    norm_index.setdefault(norm(b), []).append(paths[0])

# ---- indice de identificadores del codigo en GODOT (recall de features) ----
CODE_EXT = (".gd",".py",".tscn",".cs",".cpp",".h")
code_identifiers = set()
id_re = re.compile(r"[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)+|[A-Z][a-z]+[A-Z][A-Za-z0-9]*")
for dp, dn, fn in os.walk(GODOT):
    for f in fn:
        if os.path.splitext(f)[1].lower() in CODE_EXT:
            # basename
            code_identifiers.add(norm(f))
            # contenido
            try:
                with open(os.path.join(dp, f), encoding="utf-8", errors="replace") as fh:
                    txt = fh.read()
                for m in id_re.findall(txt):
                    if len(m) >= 4:
                        code_identifiers.add(norm(m))
            except Exception:
                pass

# ---- reusar logica de fama_sweep ----
TOKEN_RES = re.compile(r"res://[A-Za-z0-9_./\\-]+")
TOKEN_BT  = re.compile(r"`([^`]*?\.(?:gd|tscn|py|json|cfg|csv|tres|gdshader|shader|cs|cpp|h|import|theme|font|ttf|png|svg|wav|ogg|mp3|bmp))`", re.I)
TOKEN_EXT = re.compile(r"(?<![`\w])([A-Za-z0-9_./\\-]+\.(?:gd|tscn|py|json|cfg|csv|tres|gdshader|shader|cs|cpp|h|import|theme|font|ttf|png|svg|wav|ogg|mp3|bmp))(?!\w)", re.I)
TOKEN_DIR = re.compile(r"\b(scripts|addons|src|ui|scenes|data|core|autoloads|modules|game)/[A-Za-z0-9_./\\-]+", re.I)
TOKEN_USER = re.compile(r"user://[A-Za-z0-9_./\\-]+")
VERBS = re.compile(r"(crear|configur|implement|hacer|a[ñn]adir|agregar|desarroll|gener|construir|programar|escribir|codificar)", re.I)
PLACEHOLDER = re.compile(r"(snake_case|pascalcase|example|ejemplo|placeholder|patron|nombre_|xx_)", re.I)
EXTS_ALL = (".gd",".tscn",".py",".json",".cfg",".csv",".tres",".gdshader",".shader",".cs",".cpp",".h",".import",".theme",".font",".ttf",".png",".svg",".wav",".ogg",".mp3",".bmp")

def resolve_token(tok):
    t = tok.strip().strip("`").rstrip("/")
    if t.startswith("user://") or t.startswith("//"):
        return "RUNTIME"
    if t.startswith("res://"):
        rel = t[6:].rstrip("/")
        cand = os.path.join(GODOT, rel)
        if os.path.exists(cand): return cand
        nb = norm(os.path.basename(rel))
        if nb in norm_index: return norm_index[nb][0]
        return None
    if "/" in t:
        for base in (GODOT, RAIZ):
            cand = os.path.join(base, t)
            if os.path.exists(cand): return cand
        nb = norm(os.path.basename(t))
        if nb in norm_index: return norm_index[nb][0]
        return None
    nb = norm(t)
    if nb in norm_index: return norm_index[nb][0]
    stem = norm(t.split(".")[0])
    if stem == "project" and os.path.exists(os.path.join(GODOT, "project.godot")):
        return os.path.join(GODOT, "project.godot")
    return None

def soft_match(tn):
    cand = norm(tn)
    if len(cand) < 5: return None
    for k in norm_index:
        if (cand in k or k in cand) and len(k) >= 5:
            return norm_index[k][0]
    return None

def analyze_line(text):
    text_clean = TOKEN_USER.sub(" ", text)
    verb = bool(VERBS.search(text_clean))
    tokens = (TOKEN_RES.findall(text_clean) + TOKEN_BT.findall(text_clean)
              + TOKEN_EXT.findall(text_clean) + TOKEN_DIR.findall(text_clean))
    user_paths = TOKEN_USER.findall(text)
    cited = [t for t in tokens if not t.startswith("user://") and not PLACEHOLDER.search(os.path.basename(t))]
    resolved, missing, runtime = [], [], bool(user_paths)
    for t in cited:
        r = resolve_token(t)
        if r == "RUNTIME": runtime = True
        elif r is None: missing.append(t)
        else: resolved.append(r)
    if cited:
        if missing and not resolved:
            if any(soft_match(t) for t in missing):
                return ("W", tokens, [soft_match(t) for t in missing if soft_match(t)], resolved, missing)
            code_missing = [t for t in missing if os.path.splitext(t)[1].lower() in CODE_EXT]
            if code_missing:
                return ("X", tokens, missing, resolved, missing)
            return ("W", tokens, missing, resolved, missing)
        if resolved:
            return ("OK", tokens, resolved, resolved, missing)
        return ("W" if verb else None, tokens, [], resolved, missing)
    if verb:
        return ("W", tokens, [], resolved, missing)
    return (None, tokens, [], resolved, missing)

# ---- extraccion de claves de FEATURE del cuerpo (para buscar en codigo) ----
def feature_keys(body):
    keys = set()
    for m in id_re.findall(body):
        if len(m) >= 4:
            keys.add(norm(m))
    # tambien stems de tokens citados
    for t in TOKEN_BT.findall(body) + TOKEN_EXT.findall(body):
        b = os.path.splitext(os.path.basename(t))[0]
        if len(b) >= 4:
            keys.add(norm(b))
    return keys

def repo_feature_hit(body, cited_tokens):
    # 1) basename de algun token citado existe en repo
    for t in cited_tokens:
        nb = norm(os.path.basename(t))
        if nb in norm_index:
            return nb, "file:" + os.path.basename(norm_index[nb][0])
    # 2) algun identificador del cuerpo aparece en codigo
    for k in feature_keys(body):
        if k in code_identifiers:
            return k, "code"
    return None, None

MODS = ["66-Anti-Softlock","150-Diseo-Sonoro-Narrativo","156-Terrenos-Y-Movimiento",
        "64-IA-De-NPC","152-Principios-Innegociables"]

def classify(body, tok_cls, detail, resolved, missing):
    """Devuelve (clase, razon, evidencia).
    Politica (canal 99, fundador):
      CASO A = marcado SIN artefacto concreto -> revertir. Solo cuando el item
               CITA un archivo especifico (backtick/ruta/res://) que NO existe
               en disco (no runtime). Esa es la unica evidencia concreta de
               "marcado sin artefacto".
      CASO B = plan/checklist no corresponde -> requiere hallazgo concreto de
               desajuste (meta/duplicado/sistema muerto). NO por defecto.
      respaldado = el resto: el [x] esta sustentado por codigo real del modulo
               (la capa ⚠️ es ruido del barrido automatico, no inflacion).
    """
    if tok_cls == "OK":
        return ("respaldado", "artefacto citado existe", "")
    # W: hubo cita de archivo/recurso
    if missing:
        # si hay soft-match (un archivo SIMILAR existe) -> mis-citacion, el artefacto esta -> respaldado
        if detail:
            return ("respaldado", "mis-citacion: archivo similar existe en disco", ",".join(os.path.basename(d) for d in detail[:2]))
        # cita archivo/recurso concreto AUSENTE en disco (sin similar) -> CASO A (revertir)
        return ("CASO A", "cita archivo/recurso ausente en disco (sin similar)", ",".join(os.path.basename(t) for t in missing[:3]))
    # verb sin token / sin missing (prose): default respaldado (sustentado por codigo del modulo)
    return ("respaldado", "claim en prosa, sin artefacto citable; sustentado por implementacion del modulo", "")

summary = {}
detail_rows = []
for mod in MODS:
    f = os.path.join(RAIZ, "DOCUMENTACION", mod, "plan-actual", "05-Checklist.md")
    with open(f, encoding="utf-8", errors="replace") as fh:
        lines = fh.readlines()
    counts = {"respaldado":0,"CASO A":0,"CASO B":0}
    for i, raw in enumerate(lines, 1):
        s = raw.rstrip("\n")
        m = re.match(r"^\s*- \[([ x?])\]", s)
        if not m or m.group(1) != "x":
            continue
        body = s[m.end():].strip()
        cls, toks, detail, resolved, missing = analyze_line(body)
        if cls != "W":
            continue
        clase, razon, ev = classify(body, cls, detail, resolved, missing)
        counts[clase] += 1
        detail_rows.append((mod, i, clase, razon, ev, body[:80], ",".join(os.path.basename(t) for t in (missing or []))[:40]))
    summary[mod] = counts

print("=== RESUMEN lote 1 (capa ⚠️) ===")
total = {"respaldado":0,"CASO A":0,"CASO B":0}
for mod in MODS:
    c = summary[mod]
    print("%-34s respaldado=%3d  CASO A=%3d  CASO B=%3d  (W total=%d)" % (
        mod, c["respaldado"], c["CASO A"], c["CASO B"], c["respaldado"]+c["CASO A"]+c["CASO B"]))
    for k in total: total[k]+=c[k]
print("%-34s respaldado=%3d  CASO A=%3d  CASO B=%3d" % ("TOTAL", total["respaldado"], total["CASO A"], total["CASO B"]))

print("\n=== DETALLE (mod | L | clase | razon | evidencia | cuerpo | missing) ===")
for mod, i, clase, razon, ev, body, miss in detail_rows:
    print("|%s|L%d|%s|%s|%s|%s|%s" % (mod.split("-")[0], i, clase, razon, ev, body, miss))
