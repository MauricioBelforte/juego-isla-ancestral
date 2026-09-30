# -*- coding: utf-8 -*-
"""Clasifica archivos M por autor — ronda 2.
Senales: 1) plan-actual firma **Modelo:** 2) ruta -> modulo via 04-Codigo.md
-> agente global 3) prefijo commit 4) reglas especiales.
"""
import io, os, re, subprocess

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
BASE = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2")
SNAPSHOT = os.path.join(BASE, "git_status_snapshot.txt")
AGENT_MAP = os.path.join(BASE, "modulo_agente_map.txt")

PREFIJOS = [
    (r"^hy3 \(WorkBuddy\)", "hy3"), (r"^hy3:", "hy3"),
    (r"^DeepSeek", "deepseek-v4.1-flash"),
    (r"^P-\d+\+P-\d+", "atria-dawn (coordinador)"),
    (r"^Se asigno(?:ron)? P-\d+", "atria-dawn (coordinador)"),
    (r"^Se agrego(?: el)? log", "atria-dawn (coordinador)"),
    (r"^Se actualizo", "atria-dawn (coordinador)"),
    (r"^Se sell", "atria-dawn (coordinador)"),
    (r"^Se dio de alta", "atria-dawn (coordinador)"),
    (r"^Se registro", "atria-dawn (coordinador)"),
    (r"^Cierre de pendientes", "atria-dawn (coordinador)"),
    (r"^(docs|fix|feat)\(", "atria-dawn (coordinador)"),
    (r"^M\d+ \(", "atria-dawn (coordinador)"),
    (r"^Se reparo", "atria-dawn (coordinador)"),
    (r"^Se corrigio", "atria-dawn (coordinador)"),
    (r"^Se cerro", "atria-dawn (coordinador)"),
    (r"^Se renombro", "atria-dawn (coordinador)"),
    (r"^Se añadadio", "atria-dawn (coordinador)"),
    (r"^Se implemento", "atria-dawn (coordinador)"),
    (r"^Se sube", "atria-dawn (coordinador)"),
    (r"^chore\(", "atria-dawn (coordinador)"),
    (r"^Avance", "atria-dawn (coordinador)"),
    (r"^Ajustes", "atria-dawn (coordinador)"),
    (r"^Limpieza", "atria-dawn (coordinador)"),
    (r"^Fix CI", "atria-dawn (coordinador)"),
    (r"^Spawn", "atria-dawn (coordinador)"),
]

FIRMA = [
    (r"hy3", "hy3"), (r"Hy3", "hy3"), (r"Hy4", "hy4"),
    (r"[Dd]eep[Ss]eek", "deepseek-v4.1-flash"),
    (r"[Gg][Ll][Mm]", "glm-5.3-flash"),
    (r"[Aa]gnes", "agnes-3-flash"),
    (r"[Mm]i[Mm]o", "mimo-v2.5"),
    (r"[Ss]tep", "step-3.7-flash"),
    (r"[Gg]emini", "gemini-3.8-flash"),
    (r"ox-alpha", "ox-alpha"),
    (r"[Cc]laude", "claude"),
    (r"Nemotron", "nemotron"),
    (r"SWE", "swe"),
    (r"[Aa]tria", "atria-dawn"),
]

AGENTE_GLOBAL = [
    (r"hy3", "hy3"), (r"[Dd]eep[Ss]eek", "deepseek-v4.1-flash"),
    (r"[Aa]gnes", "agnes-3-flash"), (r"[Gg][Ll][Mm]", "glm-5.3-flash"),
    (r"[Mm]i[Mm]o", "mimo-v2.5"), (r"kimi", "kimi-k3"),
    (r"[Gg]emini", "gemini-3.8-flash"), (r"ox-alpha", "ox-alpha"),
    (r"nex", "nex"), (r"[Ss]tep", "step-3.7-flash"), (r"SWE", "swe"),
    (r"MiniMax", "minimax-m3"),
]


def git(args):
    return subprocess.check_output(["git", "-C", ROOT] + args,
                                   stderr=subprocess.STDOUT).decode("utf-8", "replace")


def normaliza(f, tabla):
    if not f:
        return None
    for pat, canon in tabla:
        if re.search(pat, f):
            return canon
    return None


def cargar_agentes():
    m = {}
    with io.open(AGENT_MAP, encoding="utf-8") as f:
        for lin in f:
            p = lin.rstrip("\n").split("\t")
            if len(p) == 2:
                m[p[0]] = p[1]
    return m


def construir_indice_rutas():
    indice = {}
    doc = os.path.join(ROOT, "DOCUMENTACION")
    for entrada in sorted(os.listdir(doc)):
        m = re.match(r"^(\d+)-", entrada)
        if not m:
            continue
        mid = m.group(1)
        for nombre in ("04-Codigo.md", "03-Diseno.md"):
            p4 = os.path.join(doc, entrada, "plan-actual", nombre)
            if not os.path.exists(p4):
                continue
            try:
                t = io.open(p4, encoding="utf-8", errors="replace").read()
            except Exception:
                continue
            for r in re.findall(r"((?:scripts|tests|scenes|data)/[A-Za-z0-9_./\-]+)", t):
                indice.setdefault(r.rstrip("., ").strip(), set()).add(mid)
    return indice


def firma_de_header(ruta):
    try:
        with io.open(ruta, encoding="utf-8", errors="replace") as f:
            t = f.read(20000)
    except Exception:
        return None
    m = re.search(r"\*\*Modelo:\*\*\s*(.+?)\s*(?:\*\*|$)", t)
    return m.group(1).strip() if m else None


def autor_por_commit(ruta):
    try:
        msg = git(["log", "-1", "--format=%s", "--", ruta]).strip()
    except Exception:
        return None, ""
    if not msg:
        return None, ""
    for pat, autor in PREFIJOS:
        if re.search(pat, msg):
            return autor, msg
    return None, msg


def modulo_de_ruta(rel, indice):
    norm = rel.replace("\\", "/")
    for pref in ("game/isla-ancestral/", "game/"):
        if norm.startswith(pref):
            norm = norm[len(pref):]
            break
    if norm in indice:
        return indice[norm], norm
    parcial = "/".join(norm.split("/")[:3])
    hits = set()
    for ruta, mods in indice.items():
        if ruta.startswith(parcial):
            hits |= mods
    return (hits, parcial) if hits else (set(), norm)


def clasificar(agentes, indice):
    with io.open(SNAPSHOT, encoding="utf-8") as f:
        lineas = [l.rstrip("\n") for l in f if l.strip()]
    a, b, c = {}, [], []
    # a: autor -> [(path, evidencia)]  b: [(path, evidencia)]  c: [(path, evidencia)]
    def add(d, k, rel, ev):
        d.setdefault(k, []).append((rel, ev))

    for lin in lineas:
        if not lin.startswith(" M"):
            continue
        rel = lin[3:].strip().strip('"')
        norm = rel.replace("\\", "/")
        ev = ""

        # 4. Reglas especiales primero
        if "atria-dawn-s2" in norm:
            add(a, "atria-dawn-s2 (yo)", rel, "mi carpeta de backlog"); continue
        if re.search(r"Logs/_+(d39|t39|estado39)", norm) or "Logs/_d39" in norm:
            add(a, "deepseek-v4.1-flash", rel, "scratch files de M39 (prefijo _d39/_t39)"); continue
        if norm == "logs/numeros_disponibles.txt" or rel.endswith("NUMEROS_DISPONIBLES.txt"):
            c.append((rel, "pool de logs: infraestructura compartida, multi-autor")); continue
        if norm == ".gitignore":
            add(a, "atria-dawn (coordinador)", rel, "infraestructura del repo"); continue
        # Backlogs propios de cada modelo (el coordinador les agrego notas)
        mbl = re.search(r"TAREAS-POR-MODELO/([^/]+)/", norm)
        if mbl:
            carp = mbl.group(1)
            if carp in ("GUIA-METODOLOGIA",):
                b.append((rel, "guia de metodologia (coordinador)")); continue
            add(a, "%s (backlog propio)" % carp, rel,
                "backlog personal del modelo %s" % carp); continue
        # GUIA-GODOT/06: T-98..100 commiteados por hy3; el diff sin commitear
        # es SOLO mi T-101 (verificado: 56 lineas añadidas, 0 eliminadas)
        if "GUIA-GODOT/06-registro-errores" in norm:
            add(a, "atria-dawn-s2 (yo)", rel,
                "T-98..T-100 ya en HEAD (hy3); diff sin commitear = mi T-101"); continue
        # 11-BUGS.md: multi-autor verificado en el diff sin commitear
        if norm == "documentacion/11-bugs.md" or rel.endswith("11-BUGS.md"):
            c.append((rel, "MULTI-AUTOR: diff sin commitear tiene hunks de atria "
                           "(merge sec.9 + firma BUG-043), deepseek (BUG-071/BUG-072 "
                           "fila) y otros; separar hunks a mano")); continue
        # CHECKLIST-GLOBAL.md: EOL + multi-autor (lo maneja el coordinador
        # con scripts/editar_crlf.py)
        if rel.endswith("CHECKLIST-GLOBAL.md"):
            c.append((rel, "EOL (231 CRLF + 1 NUL) + multi-autor; diff 231/231 — "
                           "coordinador lo maneja con editar_crlf.py")); continue
        # Nombre con _m{ID}_ o _m{ID}. -> modulo -> agente
        mmod = re.search(r"_m(\d+)[_.]", norm) or re.search(r"_m(\d+)$", norm)
        if mmod:
            ag = normaliza(agentes.get(mmod.group(1), ""), AGENTE_GLOBAL)
            if ag:
                add(a, ag, rel, "test del modulo M%s (por nombre); agente global: %s" % (
                    mmod.group(1), agentes.get(mmod.group(1), ""))); continue
            if mmod.group(1) in ("14",):
                b.append((rel, "test de M14; QA propia Log 1013")); continue
            c.append((rel, "test del modulo M%s sin agente asignado" % mmod.group(1))); continue
        # Overrides de subdirectorio
        if "/shops/" in norm:
            add(a, "glm-5.3-flash", rel, "subdir shops/ -> M39 -> agente global"); continue
        if "/ui/" in norm or "/ui\\" in norm:
            add(a, "atria-dawn (coordinador)", rel, "subdir ui/ -> M53 (BUG-048 Log 983, atria)"); continue
        if "tests/" in norm and ("inventario" in norm or "inventory" in norm
                                 or "interfaces" in norm):
            b.append((rel, "infra de tests de M14 (QA Log 1013)")); continue
        if "/audio/" in norm or "narrative_sound" in norm:
            add(a, "mimo-v2.5", rel, "audio -> M84 -> agente global"); continue

        # 1. plan-actual: firma del header
        if "plan-actual" in norm and rel.endswith(".md"):
            f = firma_de_header(os.path.join(ROOT, rel))
            autor = normaliza(f, FIRMA)
            if autor:
                add(a, autor, rel, "firma header **Modelo:** %r" % f); continue
            ev = "sin **Modelo:** legible"

        # 2. ruta -> modulo -> agente global
        if norm.startswith("game/") or "DOCUMENTACION/" not in norm:
            mods, clave = modulo_de_ruta(rel, indice)
            if mods:
                ags = set()
                for mid in mods:
                    ag = normaliza(agentes.get(mid, ""), AGENTE_GLOBAL)
                    if ag:
                        ags.add(ag)
                if len(ags) == 1:
                    add(a, ags.pop(), rel, "ruta -> modulo %s -> agente global" % sorted(mods)); continue
                if len(ags) > 1:
                    c.append((rel, "modulos %s con agentes distintos %s" % (sorted(mods), sorted(ags)))); continue
                ev = "modulos %s sin agente asignado en global" % sorted(mods)
            else:
                ev = "ruta no indexada en 04-Codigo.md (%s)" % clave

        # 3. prefijo de commit
        autor, msg = autor_por_commit(rel)
        if autor:
            if autor.startswith("atria-dawn (coordinador)"):
                b.append((rel, "prefijo commit: %s" % msg)); continue
            add(a, autor, rel, "prefijo commit: %s" % msg); continue

        # plan-actual sin firma + commit generico: QA propia detectable
        if ev.startswith("sin **Modelo:**"):
            if re.search(r"M14 Inventario|M111-Codigo", msg):
                b.append((rel, "QA propia (Log 1013/1032): %s" % msg)); continue
            if "checklists de 130+" in msg:
                b.append((rel, "bulk update de checklists (coordinador): %s" % msg)); continue

        c.append((rel, "%s; ultimo commit: %s" % (ev, msg)))
    return a, b, c


if __name__ == "__main__":
    agentes = cargar_agentes()
    indice = construir_indice_rutas()
    print("rutas indexadas en 04-Codigo/03-Diseno:", len(indice))
    a, b, c = clasificar(agentes, indice)
    total = sum(len(v) for v in a.values()) + len(b) + len(c)
    rep = os.path.join(BASE, "clasificacion_final.txt")
    with io.open(rep, "w", encoding="utf-8", newline="\n") as f:
        f.write("CLASIFICACION FINAL DE ARCHIVOS M — TOTAL %d\n" % total)
        f.write("Metodo: 1) firma **Modelo:** del plan-actual  2) ruta -> modulo\n")
        f.write("(indice 04-Codigo/03-Diseno) -> agente en CHECKLIST-GLOBAL  3) prefijo\n")
        f.write("del ultimo commit  4) reglas especiales (backlogs, scratch M39, UI).\n\n")
        f.write("=== BUCKET A (por modelo) ===\n")
        for autor in sorted(a):
            f.write("\n## %s (%d)\n" % (autor, len(a[autor])))
            for p, e in sorted(a[autor]):
                f.write("  %s  [%s]\n" % (p, e))
        f.write("\n=== BUCKET B (coordinador Atria main): %d ===\n" % len(b))
        for p, e in sorted(b):
            f.write("  %s  [%s]\n" % (p, e))
        f.write("\n=== BUCKET C (inclasificable / conflicto): %d ===\n" % len(c))
        for p, e in sorted(c):
            f.write("  %s <- %s\n" % (p, e))
    print("TOTAL: %d | A=%d B=%d C=%d (%.0f%%)" % (
        total, sum(len(v) for v in a.values()), len(b), len(c),
        100.0 * len(c) / total if total else 0))
