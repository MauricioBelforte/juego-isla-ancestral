# -*- coding: utf-8 -*-
"""P-46 ejecutor final. Uso: p46_ejecutar.py [--ejecutar]

Correcciones vs ronda 2:
  - FAMILIA-B-REPLANIFICACION.md y cualquier backlog-folder firmado por
    atria-dawn -> bucket MIO (no es trabajo del modelo).
  - Logs/Auditorias/Mensajes firmados por atria-dawn -> bucket MIO.
  - Una sola key por modelo (merge plan + backlog) -> 1 commit por modelo.
  - Re-lectura live de git status inmediatamente antes de cada commit
    (concurrencia con P-45 de DeepSeek).
  - Verificacion git show --stat HEAD == paths por commit.
"""
import io, os, re, subprocess, sys

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
BASE = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2")
sys.path.insert(0, os.path.join(BASE, "scripts-prueba"))
import clasificar_ronda2 as C

TARGETS = ["glm-5.3-flash", "swe", "nemotron", "ox-alpha",
           "kimi-k3", "step-3.7-flash"]
SCRATCH_PAT = [
    r"scripts-prueba/", r"capturas/", r"__pycache__", r"\.pyc$",
    r"\.out$", r"\.err$", r"\.tmp$", r"\.temp$", r"~$", r"/_",
]


def git(args):
    r = subprocess.run(["git", "-C", ROOT] + args, stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT)
    return r.returncode, r.stdout.decode("utf-8", "replace")


def es_scratch(rel):
    for p in SCRATCH_PAT:
        if re.search(p, rel.replace("\\", "/")):
            return True
    return False


def firma_md(path):
    try:
        with io.open(os.path.join(ROOT, path), encoding="utf-8",
                     errors="replace") as f:
            t = f.read(3000)
    except Exception:
        return None
    m = re.search(r"\*\*Modelo:\*\*\s*(.+?)\s*(?:\*\*|$)", t)
    return m.group(1).strip() if m else None


def untracked_live():
    rc, out = git(["status", "--porcelain", "-uall"])
    res = []
    for l in out.split("\n"):
        if not l.startswith("??"):
            continue
        rel = l[3:].strip()
        if rel.startswith('"') and rel.endswith('"'):
            rel = rel[1:-1]
        res.append(rel)
    return res


def clasificar(agentes, indice):
    un = untracked_live()
    scratch, mios, artefactos, bucket_c = [], [], [], []
    plan = {}          # modelo -> set de rutas
    uids = []
    for rel in un:
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

        mbl = re.search(r"TAREAS-POR-MODELO/([^/]+)/", norm)
        if mbl:
            carp = mbl.group(1)
            if carp in ("GUIA-METODOLOGIA",):
                bucket_c.append((rel, "guia metodologia (coordinador)"))
                continue
            # backlog folder: la firma decide (Modelo u Origen — los
            # artefactos del coordinador usan **Origen:** atria-dawn)
            head = ""
            if rel.endswith(".md"):
                try:
                    with io.open(os.path.join(ROOT, rel), encoding="utf-8",
                                 errors="replace") as ff:
                        head = ff.read(3000)
                except Exception:
                    head = ""
            fm = re.search(r"\*\*(?:Modelo|Origen):\*\*\s*(.+?)\s*(?:\*\*|$)",
                           head, re.MULTILINE)
            f = fm.group(1).strip() if fm else None
            a = C.normaliza(f, C.FIRMA) if f else None
            if a == "atria-dawn":
                mios.append(rel)
                continue
            if a:
                if a in TARGETS:
                    plan.setdefault(a, set()).add(rel)
                else:
                    bucket_c.append((rel, "backlog firmado por ACTIVO %s" % a))
                continue
            # sin firma: la carpeta nombra el modelo
            ag = None
            for t in TARGETS + ["deepseek-v4.1-flash", "mimo-v2.5", "hy3",
                                "agnes-3-flash"]:
                if carp.lower().startswith(t.split("-")[0]):
                    ag = t
                    break
            if ag and ag in TARGETS:
                plan.setdefault(ag, set()).add(rel)
            elif ag:
                bucket_c.append((rel, "backlog de modelo ACTIVO %s" % ag))
            else:
                bucket_c.append((rel, "carpeta modelo no reconocida: %s" % carp))
            continue

        if rel.endswith(".md"):
            f = firma_md(rel)
            a = C.normaliza(f, C.FIRMA) if f else None
            if a == "atria-dawn":
                mios.append(rel)
                continue
            if a and a in TARGETS:
                plan.setdefault(a, set()).add(rel)
                continue
            if a:
                bucket_c.append((rel, "firmado por %s (no objetivo)" % a))
                continue
            # sin firma: modulo por ruta
            mods, clave = C.modulo_de_ruta(rel, indice)
            if mods:
                ags = set()
                for mid in mods:
                    x = C.normaliza(agentes.get(mid, ""), C.AGENTE_GLOBAL)
                    if x:
                        ags.add(x)
                if len(ags) == 1:
                    x = ags.pop()
                    if x in TARGETS:
                        plan.setdefault(x, set()).add(rel)
                    else:
                        bucket_c.append((rel, "modulo %s -> ACTIVO %s" % (
                            sorted(mods), x)))
                    continue
            bucket_c.append((rel, ".md sin firma ni modulo"))
            continue

        mmod = re.search(r"_m(\d+)[_.]", norm) or re.search(r"_m(\d+)$", norm)
        if mmod:
            ag = C.normaliza(agentes.get(mmod.group(1), ""), C.AGENTE_GLOBAL)
            if ag:
                if ag in TARGETS:
                    plan.setdefault(ag, set()).add(rel)
                else:
                    bucket_c.append((rel, "test M%s -> ACTIVO %s" % (
                        mmod.group(1), ag)))
                continue
        mods, clave = C.modulo_de_ruta(rel, indice)
        if mods:
            ags = set()
            for mid in mods:
                x = C.normaliza(agentes.get(mid, ""), C.AGENTE_GLOBAL)
                if x:
                    ags.add(x)
            if len(ags) == 1:
                x = ags.pop()
                if x in TARGETS:
                    plan.setdefault(x, set()).add(rel)
                else:
                    bucket_c.append((rel, "ruta -> modulo %s -> ACTIVO %s" % (
                        sorted(mods), x)))
                continue
        bucket_c.append((rel, "sin senal de autoria"))

    for rel in uids:
        b = rel[:-4]
        situo = False
        for autor, paths in plan.items():
            if b in paths:
                paths.add(rel)
                situo = True
                break
        if not situo:
            scratch.append(rel)

    return plan, scratch, mios, artefactos, bucket_c


def main():
    ejecutar = "--ejecutar" in sys.argv
    rc, out = git(["diff", "--cached", "--name-only"])
    if out.strip():
        print("ABORT: indice no vacio:\n" + out)
        return 1

    agentes = C.cargar_agentes()
    indice = C.construir_indice_rutas()
    plan, scratch, mios, artefactos, bucket_c = clasificar(agentes, indice)

    n = sum(len(v) for v in plan.values())
    print("PLAN: %d modelos, %d archivos | scratch %d | mios %d | "
          "artefactos %d | bucket C %d" % (
              len(plan), n, len(scratch), len(mios), len(artefactos),
              len(bucket_c)))
    for a in sorted(plan):
        print("   %s: %d" % (a, len(plan[a])))

    if not ejecutar:
        print("\n(dry-run)")
        return 0

    hechos = 0
    for autor in sorted(plan):
        # re-lectura live inmediatamente antes de commitear (concurrencia)
        live = set(untracked_live())
        paths = sorted(p for p in plan[autor] if p in live)
        descartados = sorted(p for p in plan[autor] if p not in live)
        if not paths:
            print("SKIP %s: todos sus archivos dejaron de ser untracked" % autor)
            if descartados:
                print("   (alguien los commiteo: %s)" % descartados)
            continue
        msg = "Merge (worktree de %s): archivos sin versionar del modulo (%d archivos)" % (
            autor, len(paths))
        cuerpo = msg + "\n\n" + "\n".join("- " + p for p in paths)
        rc, out = git(["add", "--"] + paths)
        if rc:
            print("FALLO add %s: %s" % (autor, out))
            return 1
        rc, out = git(["commit", "-m", cuerpo])
        if rc:
            print("FALLO commit %s: %s" % (autor, out))
            return 1
        rc, out = git(["show", "--name-only", "--format=", "HEAD"])
        tocados = set(l.strip() for l in out.split("\n") if l.strip())
        if tocados != set(paths):
            print("!! COMMIT CONTAMINADO %s:\n  %s" % (autor, sorted(tocados)))
            return 1
        print("OK commit %s (%d archivos)" % (autor, len(paths)))
        if descartados:
            print("   descartados (commiteados por otro): %s" % descartados)
        hechos += 1

    print("\nCommits hechos: %d" % hechos)
    return 0


if __name__ == "__main__":
    sys.exit(main())
