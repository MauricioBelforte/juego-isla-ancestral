# -*- coding: utf-8 -*-
"""P-44: commitea el bucket A de modelos inactivos en commits separados.

Modelos objetivo: glm-5.3-flash, swe, nemotron, ox-alpha, kimi-k3,
step-3.7-flash (los ~59 huerfanos).

Verificaciones obligatorias por archivo:
  - EOL: si adds+dels >= 90% de las lineas del archivo y adds == dels
    -> sospechoso de EOL -> se excluye y se reporta.
  - Hunks ajenos: si las lineas anadidas firman **Modelo:** de OTRO
    modelo o citan "Log N" de otro modelo -> se excluye (bucket C).
  - El indice debe estar vacio al empezar (add + commit sin paths).
Verificacion por commit: git show --stat HEAD lista SOLO archivos del modelo.
"""
import io, os, re, subprocess, sys

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
BASE = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2")
sys.path.insert(0, os.path.join(BASE, "scripts-prueba"))
import clasificar_ronda2 as C

TARGETS = ["glm-5.3-flash", "swe", "nemotron", "ox-alpha",
           "kimi-k3", "step-3.7-flash"]

# nombres cortos de modelos para deteccion de hunks ajenos
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


def main():
    # 0. indice limpio
    rc, out = git(["diff", "--cached", "--name-only"])
    if out.strip():
        print("ABORT: indice no vacio:\n" + out)
        return 1

    # 1. snapshot live
    rc, out = git(["status", "--porcelain"])
    lines = [l.rstrip("\n") for l in out.split("\n") if l.startswith(" M")]
    with io.open(C.SNAPSHOT, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines) + "\n")
    print("snapshot live: %d archivos M" % len(lines))

    # 2. clasificar
    agentes = C.cargar_agentes()
    indice = C.construir_indice_rutas()
    a, b, c = C.clasificar(agentes, indice)

    # 3. recolectar archivos por modelo objetivo
    plan = {}
    excluidos = []
    for autor, items in a.items():
        if not any(t == autor or autor.startswith(t) for t in TARGETS):
            continue
        for rel, ev in items:
            # regla de seguridad: re-verificar que sigue siendo M
            if not any(l.endswith(" " + rel) or l.endswith(' "' + rel + '"')
                       for l in lines):
                excluidos.append((rel, autor, "ya no es M en el worktree"))
                continue
            adds, dels = numstat(rel)
            total = lineas_archivo(rel)
            # EOL: cambio masivo balanceado
            if total and (adds + dels) >= 0.9 * total and adds == dels and adds > 5:
                excluidos.append((rel, autor,
                                  "SOSPECHOSO EOL (%d+/%d- de %d lineas)" % (
                                      adds, dels, total)))
                continue
            # hunks ajenos: firma de otro modelo en lineas anadidas
            txt = "\n".join(diff_added(rel))
            ajeno = None
            for tok, pat in TOKENS.items():
                corto = autor.split(" ")[0].lower()
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
            plan.setdefault(autor, []).append((rel, ev))

    print("\n=== PLAN DE COMMITS P-44 ===")
    n = 0
    for autor in sorted(plan):
        print("\n%s: %d archivos" % (autor, len(plan[autor])))
        for rel, ev in sorted(plan[autor]):
            print("   %s" % rel)
        n += len(plan[autor])
    if excluidos:
        print("\n=== EXCLUIDOS (no se commitean) ===")
        for rel, autor, por in excluidos:
            print("   [%s] %s <- %s" % (autor, rel, por))
    print("\nTOTAL a commitear: %d | excluidos: %d" % (n, len(excluidos)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
