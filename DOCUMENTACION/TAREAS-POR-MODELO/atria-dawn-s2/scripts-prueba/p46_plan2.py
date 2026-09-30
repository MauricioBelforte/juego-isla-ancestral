# -*- coding: utf-8 -*-
"""P-46 ronda 2: clasifica untracked con firma de cualquier .md.

Mejoras vs ronda 1:
  - Logs/*.md, Mensajes entre modelos/*.md, Auditorias/*.md, Obsoletos/*.md
    llevan **Modelo:** en el contenido (AGENTS 6.2 / 10.4) -> se leen.
  - companions .uid heredan la clasificacion del archivo base.
  - reports/ (salida HTML/XML de tests) -> categoria aparte, no se commitean.
"""
import io, os, re, subprocess, sys

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
BASE = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2")
sys.path.insert(0, os.path.join(BASE, "scripts-prueba"))
import clasificar_ronda2 as C

TARGETS = ["glm-5.3-flash", "swe", "nemotron", "ox-alpha",
           "kimi-k3", "step-3.7-flash"]
ACTIVOS = ["deepseek", "mimo", "hy3", "agnes"]

SCRATCH_PAT = [
    r"scripts-prueba/", r"capturas/", r"__pycache__", r"\.pyc$",
    r"\.out$", r"\.err$", r"\.tmp$", r"\.temp$", r"~$", r"/_",
]


def git(args):
    r = subprocess.run(["git", "-C", ROOT] + args, stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT)
    return r.returncode, r.stdout.decode("utf-8", "replace")


def firma_cualquier_md(path):
    try:
        with io.open(os.path.join(ROOT, path), encoding="utf-8",
                     errors="replace") as f:
            t = f.read(3000)
    except Exception:
        return None
    m = re.search(r"\*\*Modelo:\*\*\s*(.+?)\s*(?:\*\*|$)", t)
    return m.group(1).strip() if m else None


def es_scratch(rel):
    n = rel.replace("\\", "/")
    for p in SCRATCH_PAT:
        if re.search(p, n):
            return True
    return False


def clasificar_md(rel, agentes, indice):
    """Devuelve (autor, evidencia) para un .md cualquier."""
    f = firma_cualquier_md(rel)
    if f:
        a = C.normaliza(f, C.FIRMA)
        if a:
            return a, "firma **Modelo:** %r" % f
        return None, "firma no reconocida: %r" % f
    # sin firma: probar modulo por ruta
    norm = rel.replace("\\", "/")
    mods, clave = C.modulo_de_ruta(rel, indice)
    if mods:
        ags = set()
        for mid in mods:
            a = C.normaliza(agentes.get(mid, ""), C.AGENTE_GLOBAL)
            if a:
                ags.add(a)
        if len(ags) == 1:
            return ags.pop(), "ruta -> modulo %s -> agente global" % sorted(mods)
    return None, "sin firma y sin modulo"


def main():
    rc, out = git(["status", "--porcelain", "-uall"])
    untracked = []
    for l in out.split("\n"):
        if not l.startswith("??"):
            continue
        rel = l[3:].strip()
        if rel.startswith('"') and rel.endswith('"'):
            rel = rel[1:-1]
        untracked.append(rel)
    print("untracked totales: %d" % len(untracked))

    agentes = C.cargar_agentes()
    indice = C.construir_indice_rutas()

    scratch, plan, bucket_c, mios, artefactos = [], {}, [], [], []
    # companions .uid: diferir al final
    uids = []
    for rel in untracked:
        norm = rel.replace("\\", "/")
        if rel.endswith(".uid"):
            uids.append(rel)
            continue
        if "atria-dawn-s2" in norm or "atria-dawn/" in norm:
            mios.append(rel)
            continue
        if es_scratch(rel):
            scratch.append(rel)
            continue
        if "/reports/" in norm:
            artefactos.append(rel)
            continue
        # backlog propio
        mbl = re.search(r"TAREAS-POR-MODELO/([^/]+)/", norm)
        if mbl:
            carp = mbl.group(1)
            if carp in ("GUIA-METODOLOGIA",):
                bucket_c.append((rel, "guia de metodologia (coordinador)"))
                continue
            ag = None
            for t in TARGETS + ["deepseek-v4.1-flash", "mimo-v2.5", "hy3",
                                "agnes-3-flash"]:
                if carp.lower().startswith(t.split("-")[0]):
                    ag = t
                    break
            if ag and ag in TARGETS:
                plan.setdefault(ag + " (backlog)", []).append(
                    (rel, "backlog propio del modelo"))
                continue
            if ag:
                bucket_c.append((rel, "backlog de modelo ACTIVO %s" % ag))
                continue
            bucket_c.append((rel, "carpeta de modelo no reconocida: %s" % carp))
            continue

        autor, ev = None, ""
        if rel.endswith(".md"):
            autor, ev = clasificar_md(rel, agentes, indice)
            if autor and autor in TARGETS:
                plan.setdefault(autor, []).append((rel, ev))
                continue
            if autor:
                bucket_c.append((rel, "%s -> %s (no objetivo)" % (ev, autor)))
                continue
            bucket_c.append((rel, ev))
            continue

        # codigo/datos: _m{ID}_ o ruta -> modulo
        mmod = re.search(r"_m(\d+)[_.]", norm) or re.search(r"_m(\d+)$", norm)
        if mmod:
            ag = C.normaliza(agentes.get(mmod.group(1), ""), C.AGENTE_GLOBAL)
            if ag:
                if ag in TARGETS:
                    plan.setdefault(ag, []).append(
                        (rel, "test M%s (por nombre)" % mmod.group(1)))
                else:
                    bucket_c.append((rel, "test M%s -> activo %s" % (
                        mmod.group(1), ag)))
                continue
        mods, clave = C.modulo_de_ruta(rel, indice)
        if mods:
            ags = set()
            for mid in mods:
                a = C.normaliza(agentes.get(mid, ""), C.AGENTE_GLOBAL)
                if a:
                    ags.add(a)
            if len(ags) == 1:
                a = ags.pop()
                if a in TARGETS:
                    plan.setdefault(a, []).append(
                        (rel, "ruta -> modulo %s -> agente" % sorted(mods)))
                else:
                    bucket_c.append((rel, "ruta -> modulo %s -> activo %s" % (
                        sorted(mods), a)))
                continue
        bucket_c.append((rel, "sin senal de autoria"))

    # companions .uid: heredan del base si esta en el plan
    for rel in uids:
        base_name = rel[:-4]  # quitar .uid
        situo = False
        for autor, items in plan.items():
            if any(p == base_name for p, _ in items):
                plan[autor].append((rel, "companion .uid de %s" % base_name))
                situo = True
                break
        if not situo:
            scratch.append(rel)

    print("\n=== SCRATCH (NO se commitean): %d ===" % len(scratch))
    for s in sorted(scratch)[:15]:
        print("   %s" % s)
    if len(scratch) > 15:
        print("   ... y %d mas" % (len(scratch) - 15))
    print("\n=== ARTEFACTOS DE TESTS reports/ (no se commitean): %d ==="
          % len(artefactos))
    if artefactos:
        print("   %s ... (%d archivos en report_1..7)" % (
            artefactos[0], len(artefactos)))
    print("\n=== MIOS (atria-dawn): %d ===" % len(mios))
    for s in sorted(mios)[:10]:
        print("   %s" % s)
    if len(mios) > 10:
        print("   ... y %d mas" % (len(mios) - 10))
    print("\n=== PLAN DE COMMITS P-46 ===")
    n = 0
    for autor in sorted(plan):
        print("\n%s: %d archivos" % (autor, len(plan[autor])))
        for rel, ev in sorted(plan[autor]):
            print("   %s  [%s]" % (rel, ev))
        n += len(plan[autor])
    print("\n=== BUCKET C (para el coordinador): %d ===" % len(bucket_c))
    for rel, ev in sorted(bucket_c)[:25]:
        print("   %s <- %s" % (rel, ev))
    if len(bucket_c) > 25:
        print("   ... y %d mas" % (len(bucket_c) - 25))
    print("\nTOTAL: scratch %d | artefactos %d | mios %d | a commitear %d | bucket C %d" % (
        len(scratch), len(artefactos), len(mios), n, len(bucket_c)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
