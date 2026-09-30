# -*- coding: utf-8 -*-
"""Verificacion post-P-44: ningun commit toco archivos protegidos."""
import subprocess

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
BASE = "7587838"  # commit anterior a mis commits

PROHIBIDOS_PATRONES = [
    "11-BUGS.md", "ESTADO-PARALELO.md", "CHECKLIST-GLOBAL.md",
    "NUMEROS_DISPONIBLES", "CHECKLIST-QA-SEALS",
    "GUIA-GODOT/06-registro-errores",
    "07-Arquitectura-General/plan-actual/04-Codigo",  # mi P-40
    "atria-dawn-s2",  # mis propios archivos
]

MODELOS_ACTIVOS = ["deepseek", "mimo", "hy3", "agnes"]


def git(args):
    r = subprocess.run(["git", "-C", ROOT] + args, stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT)
    return r.returncode, r.stdout.decode("utf-8", "replace")


rc, out = git(["log", "--oneline", "%s..HEAD" % BASE])
mios = [l.split(" ", 1)[0] for l in out.strip().split("\n") if l.strip()]
print("commites propios despues de %s: %d" % (BASE, len(mios)))

todos = set()
for sha in mios:
    rc, o = git(["show", "--name-only", "--format=", sha])
    for f in o.split("\n"):
        f = f.strip()
        if f:
            todos.add(f)

print("archivos tocados en total: %d" % len(todos))

mal = []
for f in sorted(todos):
    for p in PROHIBIDOS_PATRONES:
        if p in f:
            mal.append((f, "patron protegido: " + p))
            break
    for m in MODELOS_ACTIVOS:
        if ("TAREAS-POR-MODELO/%s" % m) in f:
            mal.append((f, "carpeta de modelo activo: " + m))
            break

if mal:
    print("\n!! PROHIBIDOS COMMITEADOS:")
    for f, por in mal:
        print("   %s <- %s" % (f, por))
else:
    print("OK: ningun archivo protegido fue commiteado")

# archivos que debian quedar sin commitear: siguen modified?
rc, out = git(["status", "--porcelain"])
quedan = [l[3:].strip().strip('"') for l in out.split("\n") if l.startswith(" M")]
print("\narchivos M restantes: %d" % len(quedan))
deben_quedar = [
    "DOCUMENTACION/11-BUGS.md",
    "Mensajes entre modelos/ESTADO-PARALELO.md",
    "CHECKLIST-GLOBAL.md",
    "DOCUMENTACION/GUIA-GODOT/06-registro-errores.md",
    "DOCUMENTACION/38-Economia/plan-actual/05-Checklist.md",
    "DOCUMENTACION/07-Arquitectura-General/plan-actual/04-Codigo.md",
    "Logs/NUMEROS_DISPONIBLES.txt",
]
for d in deben_quedar:
    ok = any(q.replace("/", "\\").lower().endswith(d.split("/")[-1].lower())
             for q in quedan)
    print("   %-60s %s" % (d.split("/")[-1], "sigue M (OK)" if ok else "FALTA"))
