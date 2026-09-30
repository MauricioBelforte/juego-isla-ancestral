# -*- coding: utf-8 -*-
"""P-44 ejecutor: commitea el plan en commits separados por modelo.

Uso: python p44_ejecutar.py            (dry-run, no commitea)
     python p44_ejecutar.py --ejecutar (commitea)
"""
import io, os, re, subprocess, sys

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
BASE = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2")
sys.path.insert(0, os.path.join(BASE, "scripts-prueba"))
import clasificar_ronda2 as C

TARGETS = ["glm-5.3-flash", "swe", "nemotron", "ox-alpha",
           "kimi-k3", "step-3.7-flash"]

TOKENS = {
    "hy3": r"hy3|Hy3", "deepseek": r"[Dd]eep[Ss]eek",
    "agnes": r"[Aa]gnes", "mimo": r"[Mm]i[Mm]o",
    "gemini": r"[Gg]emini", "atria": r"[Aa]tria",
    "kimi": r"kimi|Kimi", "ox-alpha": r"ox-alpha|Ox-Alpha",
    "swe": r"\bSWE\b", "nemotron": r"Nemotron",
    "step": r"[Ss]tep", "glm": r"[Gg][Ll][Mm]",
}


def git(args):
    r = subprocess.run(["git", "-C", ROOT] + args, stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT)
    return r.returncode, r.stdout.decode("utf-8", "replace")


def lineas_archivo(path):
    try:
        with io.open(os.path.join(ROOT, path), encoding="utf-8",
                     errors="replace") as f:
            return sum(1 for _ in f)
    except Exception:
        return 0


def numstat(path):
    rc, out = git(["diff", "--numstat", "--", path])
    p = out.strip().split("\t")
    if len(p) >= 2 and p[0].isdigit():
        return int(p[0]), int(p[1])
    return 0, 0


def diff_added(path):
    rc, out = git(["diff", "--unified=0", "--", path])
    return [l[1:] for l in out.split("\n")
            if l.startswith("+") and not l.startswith("+++")]


def calcular_plan(lines):
    agentes = C.cargar_agentes()
    indice = C.construir_indice_rutas()
    a, b, c = C.clasificar(agentes, indice)
    plan, excluidos = {}, []
    for autor, items in a.items():
        if not any(t == autor or autor.startswith(t) for t in TARGETS):
            continue
        for rel, ev in items:
            if not any(l.endswith(" " + rel) or l.endswith(' "' + rel + '"')
                       for l in lines):
                excluidos.append((rel, autor, "ya no es M en el worktree"))
                continue
            adds, dels = numstat(rel)
            total = lineas_archivo(rel)
            if total and (adds + dels) >= 0.9 * total and adds == dels and adds > 5:
                excluidos.append((rel, autor,
                                  "SOSPECHOSO EOL (%d+/%d- de %d lineas)" % (
                                      adds, dels, total)))
                continue
            txt = "\n".join(diff_added(rel))
            ajeno = None
            corto = autor.split(" ")[0].lower()
            for tok, pat in TOKENS.items():
                if tok == corto or tok in corto or corto in tok:
                    continue
                for m in re.finditer(r"\*\*Modelo:\*\*\s*(.+)", txt):
                    if re.search(pat, m.group(1)):
                        ajeno = "firma **Modelo:** de %s en hunks anadidos" % tok
                        break
                if ajeno:
                    break
            if ajeno:
                excluidos.append((rel, autor, "HUNKS AJENOS: " + ajeno))
                continue
            plan.setdefault(autor, []).append(rel)
    return plan, excluidos


def descripcion(autor, paths):
    n = len(paths)
    docs = sum(1 for p in paths if p.endswith(".md"))
    cod = n - docs
    partes = []
    if docs:
        partes.append("documentacion plan-actual de %d modulo%s" % (
            docs, "s" if docs != 1 else ""))
    if cod:
        partes.append("%d archivo%s de codigo/datos" % (
            cod, "s" if cod != 1 else ""))
    return "Merge (worktree de %s): %s (%d archivos)" % (
        autor, " + ".join(partes), n)


def main():
    ejecutar = "--ejecutar" in sys.argv
    rc, out = git(["diff", "--cached", "--name-only"])
    if out.strip():
        print("ABORT: indice no vacio:\n" + out)
        return 1
    rc, out = git(["status", "--porcelain"])
    lines = [l.rstrip("\n") for l in out.split("\n") if l.startswith(" M")]
    plan, excluidos = calcular_plan(lines)
    print("plan: %d modelos, %d archivos | excluidos: %d" % (
        len(plan), sum(len(v) for v in plan.values()), len(excluidos)))

    hechos = 0
    for autor in sorted(plan):
        paths = sorted(plan[autor])
        msg = descripcion(autor, paths)
        cuerpo = msg + "\n\n" + "\n".join("- " + p for p in paths)
        if not ejecutar:
            print("\n[DRY-RUN] %s" % msg)
            continue
        # add solo esos paths
        rc, out = git(["add", "--"] + paths)
        if rc:
            print("FALLO add %s: %s" % (autor, out))
            return 1
        rc, out = git(["commit", "-m", cuerpo])
        if rc:
            print("FALLO commit %s: %s" % (autor, out))
            return 1
        # verificar: el commit toco SOLO esos paths
        rc, out = git(["show", "--stat", "--name-only", "--format=", "HEAD"])
        tocados = [l.strip() for l in out.split("\n") if l.strip()]
        if set(tocados) != set(paths):
            print("!! COMMIT CONTAMINADO %s:\n  tocados: %s\n  esperados: %s"
                  % (autor, tocados, paths))
            return 1
        print("OK commit %s (%d archivos)" % (autor, len(paths)))
        hechos += 1

    if ejecutar:
        print("\nCommits hechos: %d" % hechos)
        if excluidos:
            print("\nEXCLUIDOS (van al bucket C del coordinador):")
            for rel, autor, por in excluidos:
                print("   [%s] %s <- %s" % (autor, rel, por))
    else:
        print("\n(dry-run; correr con --ejecutar)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
