# -*- coding: utf-8 -*-
"""P-46: clasifica los archivos untracked (??) por modelo.

Diferencias vs P-44: son archivos NUEVOS (no hay diff contra HEAD), asi que
las verificaciones de EOL y hunks ajenos no aplican. En cambio:
  - scratch files se listan aparte y NO se commitean
  - consistencia de firma: si un .md nuevo firma a un modelo distinto del
    inferido por la ruta -> se excluye
  - los archivos sin senal de autoria (no indexados, sin _m{ID}_, sin
    carpeta de backlog) -> bucket C honesto
"""
import io, os, re, subprocess, sys

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
BASE = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2")
sys.path.insert(0, os.path.join(BASE, "scripts-prueba"))
import clasificar_ronda2 as C

TARGETS = ["glm-5.3-flash", "swe", "nemotron", "ox-alpha",
           "kimi-k3", "step-3.7-flash"]

# scratch: NO se commitean
SCRATCH_PAT = [
    r"scripts-prueba/", r"capturas/", r"__pycache__", r"\.pyc$",
    r"\.out$", r"\.err$", r"\.tmp$", r"\.temp$", r"~$",
    r"/_",            # temporales _*.py / _*.json al final de la ruta
    r"\.uid$",
]


def git(args):
    r = subprocess.run(["git", "-C", ROOT] + args, stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT)
    return r.returncode, r.stdout.decode("utf-8", "replace")


def es_scratch(rel):
    n = rel.replace("\\", "/")
    for p in SCRATCH_PAT:
        if re.search(p, n):
            return True
    return False


def firma_header(path):
    try:
        with io.open(os.path.join(ROOT, path), encoding="utf-8",
                     errors="replace") as f:
            t = f.read(20000)
    except Exception:
        return None
    m = re.search(r"\*\*Modelo:\*\*\s*(.+?)\s*(?:\*\*|$)", t)
    return m.group(1).strip() if m else None


def main():
    # live, todos los untracked individualmente
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

    scratch, plan, bucket_c, mios = [], {}, [], []
    for rel in untracked:
        norm = rel.replace("\\", "/")
        # mios: mi carpeta de esta sesion
        if "atria-dawn-s2" in norm or "atria-dawn/" in norm:
            mios.append(rel)
            continue
        if es_scratch(rel):
            scratch.append(rel)
            continue
        # backlog propio de un modelo
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
            if ag:
                if ag in TARGETS:
                    plan.setdefault(ag + " (backlog)", []).append(
                        (rel, "backlog propio del modelo"))
                else:
                    bucket_c.append((rel, "backlog de modelo ACTIVO %s" % ag))
                continue
            bucket_c.append((rel, "carpeta de modelo no reconocida: %s" % carp))
            continue

        # .md de plan-actual: firma del header
        ev = ""
        autor = None
        if "plan-actual" in norm and rel.endswith(".md"):
            f = firma_header(rel)
            autor = C.normaliza(f, C.FIRMA)
            ev = "firma header **Modelo:** %r" % f
        # nombre _m{ID}_
        if autor is None:
            mmod = re.search(r"_m(\d+)[_.]", norm) or re.search(r"_m(\d+)$", norm)
            if mmod:
                ag = C.normaliza(agentes.get(mmod.group(1), ""), C.AGENTE_GLOBAL)
                if ag:
                    autor = ag
                    ev = "test del modulo M%s (por nombre); agente global" % mmod.group(1)
        # game/ -> modulo -> agente
        if autor is None and (norm.startswith("game/") or "DOCUMENTACION/" not in norm):
            mods, clave = C.modulo_de_ruta(rel, indice)
            if mods:
                ags = set()
                for mid in mods:
                    a = C.normaliza(agentes.get(mid, ""), C.AGENTE_GLOBAL)
                    if a:
                        ags.add(a)
                if len(ags) == 1:
                    autor = ags.pop()
                    ev = "ruta -> modulo %s -> agente global" % sorted(mods)
                elif len(ags) > 1:
                    bucket_c.append((rel, "modulos %s con agentes distintos %s" % (
                        sorted(mods), sorted(ags))))
                    continue

        if autor is None:
            bucket_c.append((rel, "sin senal de autoria %s" % (
                "; " + ev if ev else "")))
            continue
        # consistencia firma vs inferido
        if ev.startswith("firma header") and autor not in TARGETS:
            bucket_c.append((rel, "firma %r -> modelo activo/no objetivo" % (
                firma_header(rel),)))
            continue
        if autor in TARGETS:
            plan.setdefault(autor, []).append((rel, ev))
        else:
            bucket_c.append((rel, "autor %s no objetivo (modelo activo)" % autor))

    print("\n=== SCRATCH (NO se commitean): %d ===" % len(scratch))
    for s in sorted(scratch):
        print("   %s" % s)
    print("\n=== MIOS (atria-dawn, para el coordinador): %d ===" % len(mios))
    for s in sorted(mios):
        print("   %s" % s)
    print("\n=== PLAN DE COMMITS P-46 ===")
    n = 0
    for autor in sorted(plan):
        print("\n%s: %d archivos" % (autor, len(plan[autor])))
        for rel, ev in sorted(plan[autor]):
            print("   %s  [%s]" % (rel, ev))
        n += len(plan[autor])
    print("\n=== BUCKET C (para el coordinador): %d ===" % len(bucket_c))
    for rel, ev in sorted(bucket_c):
        print("   %s <- %s" % (rel, ev))
    print("\nTOTAL: scratch %d | mios %d | a commitear %d | bucket C %d" % (
        len(scratch), len(mios), n, len(bucket_c)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
