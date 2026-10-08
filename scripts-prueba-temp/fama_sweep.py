#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Barrido Familia A de BUG-070 (calibracion + barrido completo).
Metodo (director canal 97, frente A):
  grep [x] con verbo de implementacion -> verificar existencia del artefacto
  citado en disco -> clasificar (✅ existe / ⚠️ verbo sin artefacto / ❌ cita archivo inexistente).
NO hace flip de ningun [x]; solo reporta veredicto.
"""
import os, re, sys

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
GODOT = os.path.join(RAIZ, "game", "isla-ancestral")

# Indice de archivos del proyecto Godot por basename (para resolver nombres sin ruta).
# Indice de archivos de TODO el repo (no solo game/isla-ancestral) para no acusar
# falsamente modulos que citan .py/.json/.tscn fuera del arbol Godot.
SKIP = {".git", "PAPELERA", "Obsoletos", "out", "build", "Logs",
        "Mensajes entre modelos", "node_modules", ".workbuddy-ai",
        "scripts-prueba-temp", "__pycache__", ".import", ".godot", "Godot"}
basename_index = {}
for dp, dn, fn in os.walk(RAIZ):
    parts = set(dp.split(os.sep))
    if parts & SKIP:
        continue
    for f in fn:
        basename_index.setdefault(f, []).append(os.path.join(dp, f))

def norm(s):
    return re.sub(r'[^a-z0-9]', '', s.lower())

# Indice normalizado (case/underscore-insensitive) para resolver nombres mal citados.
norm_index = {}
for b, paths in basename_index.items():
    norm_index.setdefault(norm(b), []).append(paths[0])

VERBS = re.compile(r"(crear|configur|implement|hacer|a[ñn]adir|agregar|desarroll|"
                   r"gener|construir|programar|escribir|codificar)", re.I)

# Tokens de archivo: res://, backticks con extension, rutas con extension, dirs conocidos.
TOKEN_RES = re.compile(r"res://[A-Za-z0-9_./\\-]+")
TOKEN_BT  = re.compile(r"`([^`]*?\.(?:gd|tscn|py|json|cfg|csv|tres|gdshader|shader|cs|cpp|h|import|theme|font|ttf|png|svg|wav|ogg|mp3|bmp))`", re.I)
TOKEN_EXT = re.compile(r"(?<![`\w])([A-Za-z0-9_./\\-]+\.(?:gd|tscn|py|json|cfg|csv|tres|gdshader|shader|cs|cpp|h|import|theme|font|ttf|png|svg|wav|ogg|mp3|bmp))(?!\w)", re.I)
TOKEN_DIR = re.compile(r"\b(scripts|addons|src|ui|scenes|data|core|autoloads|modules|game)/[A-Za-z0-9_./\\-]+", re.I)
TOKEN_USER = re.compile(r"user://[A-Za-z0-9_./\\-]+")

EXTS = (".gd",".tscn",".py",".json",".cfg",".csv",".tres",".gdshader",".shader",
        ".cs",".cpp",".h",".import",".theme",".font",".ttf",".png",".svg",
        ".wav",".ogg",".mp3",".bmp")

# Extensiones de CODIGO (las que importan para BUG-070 Familia A: script ausente).
CODE_EXT = (".gd",".py",".tscn",".cs",".cpp",".h")
# Nombres placeholder usados como EJEMPLO de convencion (no son artefactos reales).
PLACEHOLDER = re.compile(r"(snake_case|pascalcase|example|ejemplo|placeholder|patron|nombre_|xx_)", re.I)

def resolve_token(tok):
    """Devuelve ruta absoluta si existe en disco, o None. Runtime -> 'RUNTIME'."""
    t = tok.strip().strip("`")
    if t.startswith("user://") or t.startswith("//"):
        return "RUNTIME"  # no verificable en repo (runtime)
    if t.startswith("res://"):
        rel = t[6:]
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
    # nombre sin ruta -> indice normalizado
    nb = norm(t)
    if nb in norm_index: return norm_index[nb][0]
    # caso especial: project.gd <-> project.godot
    stem = norm(t.split(".")[0])
    if stem == "project" and os.path.exists(os.path.join(GODOT, "project.godot")):
        return os.path.join(GODOT, "project.godot")
    return None

def soft_match(tn):
    """Devuelve ruta real si el nombre normalizado es sub/sobrequiva de algun archivo existente."""
    cand = norm(tn)
    if len(cand) < 5:
        return None
    for k, paths in norm_index.items():
        if (cand in k or k in cand) and len(k) >= 5:
            return paths[0]
    return None

def analyze_line(text):
    """Devuelve (clase, tokens_encontrados, resueltos)."""
    # quitar spans user:// para que no filtren como tokens de archivo
    text_clean = TOKEN_USER.sub(" ", text)
    verb = bool(VERBS.search(text_clean))
    tokens = []
    tokens += TOKEN_RES.findall(text_clean)
    tokens += TOKEN_BT.findall(text_clean)
    tokens += TOKEN_EXT.findall(text_clean)
    tokens += TOKEN_DIR.findall(text_clean)
    user_paths = TOKEN_USER.findall(text)  # original, para saber si hay runtime
    # quitar placeholders de convencion (snake_case.tres, PascalCase.tscn, ...) -> no son artefactos
    cited = [t for t in tokens
             if not t.startswith("user://")
             and not PLACEHOLDER.search(os.path.basename(t))]
    if not cited and not verb and not user_paths:
        return (None, tokens, [])
    resolved = []
    missing = []
    runtime = bool(user_paths)
    for t in cited:
        r = resolve_token(t)
        if r == "RUNTIME":
            runtime = True
        elif r is None:
            missing.append(t)
        else:
            resolved.append(r)
    if cited:
        if missing and not resolved:
            # ¿match parcial (mis-citacion de prefijo)? -> ⚠️ en vez de ❌
            soft = [soft_match(t) for t in missing]
            if any(soft):
                return ("W", tokens, [p for p in soft if p])
            # clasificar por tipo: codigo (.gd/.py/.tscn) = inflacion real;
            # recurso/config (.tres/.png/.json...) = amenudo asset no commiteado -> ⚠️
            code_missing = [t for t in missing if os.path.splitext(t)[1].lower() in CODE_EXT]
            if code_missing:
                return ("X", tokens, missing)      # ❌ cita CODIGO inexistente (Familia A)
            return ("W", tokens, missing)          # ⚠️ cita recurso no verificable en repo
        if resolved:
            return ("OK", tokens, resolved)     # ✅ citado y existe
        # cited pero todo runtime -> no verificable, tratar como ⚠️ si hay verbo
        return ("W" if verb else None, tokens, [])
    if verb:
        return ("W", tokens, [])               # ⚠️ verbo sin artefacto
    return (None, tokens, [])

def sweep_file(path):
    res = {"x":0, " ":0, "?":0, "OK":0, "W":0, "X":0, "items":[]}
    with open(path, encoding="utf-8", errors="replace") as fh:
        for i, line in enumerate(fh, 1):
            s = line.rstrip("\n")
            m = re.match(r"^\s*- \[([ x?])\]", s)
            if not m:
                continue
            mark = m.group(1)
            if mark == "x": res["x"] += 1
            elif mark == " ": res[" "]+=1
            elif mark == "?": res["?"]+=1
            if mark == "x":
                body = s[m.end():].strip()
                cls, toks, detail = analyze_line(body)
                if cls in ("OK","W","X"):
                    res[cls] += 1
                    res["items"].append((i, cls, body[:90], toks[:3], detail[:2]))
    return res

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--cal":
        f = sys.argv[2]
        r = sweep_file(f)
        print("=== CALIBRACION: %s ===" % f)
        print("marcas: [x]=%d [ ]=%d [?]=%d" % (r["x"], r[" "], r["?"]))
        print("clasif [x]: OK=%d  W=%d  X=%d" % (r["OK"], r["W"], r["X"]))
        for ln, cls, body, toks, det in r["items"][:60]:
            tag = {"OK":"✅","W":"⚠️","X":"❌"}[cls]
            print("  %s L%d | %s | toks=%s det=%s" % (tag, ln, body, toks, [os.path.basename(d) for d in det] if det else det))
        sys.exit(0)
    # barrido completo
    import glob
    files = sorted(glob.glob(os.path.join(RAIZ, "DOCUMENTACION", "*", "plan-actual", "05-Checklist.md")))
    print("Total checklists plan-actual: %d" % len(files))
    rows = []
    for f in files:
        mod = f.split(os.sep)[-3]
        r = sweep_file(f)
        rows.append((mod, r))
    rows.sort(key=lambda x: (-x[1]["X"], -x[1]["x"]))
    print("\n%-34s %5s %5s %5s %5s %5s %5s" % ("MODULO","[x]","OK","W","X","[ ]","[?]"))
    tot = {"x":0," ":0,"?":0,"OK":0,"W":0,"X":0}
    for mod, r in rows:
        print("%-34s %5d %5d %5d %5d %5d %5d" % (mod, r["x"], r["OK"], r["W"], r["X"], r[" "], r["?"]))
        for k in tot: tot[k]+=r[k]
    print("%-34s %5d %5d %5d %5d %5d %5d" % ("TOTAL", tot["x"], tot["OK"], tot["W"], tot["X"], tot[" "], tot["?"]))
    # Detalle de los modulos con X>0
    print("\n=== MODULOS CON ❌ (Familia A confirmada) — detalle ===")
    for mod, r in rows:
        if r["X"] > 0:
            print("\n## %s  (X=%d, [x]=%d)" % (mod, r["X"], r["x"]))
            for ln, cls, body, toks, det in r["items"]:
                if cls == "X":
                    print("  L%d | %s | citado-inexistente=%s" % (ln, body, toks))
