# -*- coding: utf-8 -*-
"""Clasifica los archivos M del working tree por autor (soporte al merge).

Metodo (indicado por el coordinador):
  - plan-actual/*.md  -> firma **Modelo:** del header (autor del trabajo)
  - resto             -> git log -1 --format=%s -- <path> + mapeo de prefijos

Buckets:
  A = trabajo de un modelo identificable  (lista por modelo)
  B = trabajo del coordinador (Atria main: PEDIDOS, GUIA-COMPARATIVA, P-2x/P-3x)
  C = inclasificable / conflicto (con evidencia)
"""
import io
import os
import re
import subprocess

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
SNAPSHOT = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2", "git_status_snapshot.txt")

# Prefijos de commit -> autor. Orden: de mas especifico a mas generico.
PREFIJOS = [
    (r"^hy3 \(WorkBuddy\)", "hy3"),
    (r"^hy3:", "hy3"),
    (r"^DeepSeek[ _]P-?\d", "deepseek-v4.1-flash"),
    (r"^DeepSeek", "deepseek-v4.1-flash"),
    (r"^P-\d+\+P-\d+", "atria-dawn (coordinador)"),
    (r"^Se asigno P-\d+", "atria-dawn (coordinador)"),
    (r"^Se asignaron P-\d+", "atria-dawn (coordinador)"),
    (r"^Se agrego(?: el)? log", "atria-dawn (coordinador)"),
    (r"^Se actualizo", "atria-dawn (coordinador)"),
    (r"^Se sell", "atria-dawn (coordinador)"),
    (r"^Se dio de alta", "atria-dawn (coordinador)"),
    (r"^Se registro", "atria-dawn (coordinador)"),
    (r"^Cierre de pendientes", "atria-dawn (coordinador)"),
    (r"^docs\(", "atria-dawn (coordinador)"),
    (r"^fix\(", "atria-dawn (coordinador)"),
    (r"^feat\(", "atria-dawn (coordinador)"),
    (r"^M\d+ \(", "atria-dawn (coordinador)"),
    (r"^Se reparo", "atria-dawn (coordinador)"),
]

# Normalizacion de firmas **Modelo:** -> nombre canonico
FIRMA = [
    (r"hy3", "hy3"),
    (r"Hy3", "hy3"),
    (r"Hy4", "hy4"),
    (r"deepseek", "deepseek-v4.1-flash"),
    (r"Deepseek", "deepseek-v4.1-flash"),
    (r"DeepSeek", "deepseek-v4.1-flash"),
    (r"glm", "glm-5.3-flash"),
    (r"GLM", "glm-5.3-flash"),
    (r"agnes", "agnes-3-flash"),
    (r"Agnes", "agnes-3-flash"),
    (r"AGNES", "agnes-3-flash"),
    (r"mimo", "mimo-v2.5"),
    (r"MiMo", "mimo-v2.5"),
    (r"step", "step-3.7-flash"),
    (r"Step", "step-3.7-flash"),
    (r"gemini", "gemini-3.8-flash"),
    (r"ox-alpha", "ox-alpha"),
    (r"claude", "claude"),
    (r"Claude", "claude"),
    (r"Nemotron", "nemotron"),
    (r"SWE", "swe"),
    (r"atria", "atria-dawn"),
    (r"Atria", "atria-dawn"),
]

# Archivos que son trabajo del propio coordinador por naturaleza (bucket B)
PROPIO_COORD = [
    "PEDIDOS-POR-MODELO.md",
    "GUIA-COMPARATIVA",
    "10-GUIA-COMPARATIVA",
    "Mensajes entre modelos",
    "ESTADO-PARALELO",
]


def git(args):
    return subprocess.check_output(
        ["git", "-C", ROOT] + args, stderr=subprocess.STDOUT
    ).decode("utf-8", "replace")


def firma_de_header(ruta):
    """Extrae **Modelo:** del header (primeras 40 lineas)."""
    try:
        with io.open(ruta, encoding="utf-8", errors="replace") as f:
            for i, linea in enumerate(f):
                if i > 40:
                    break
                m = re.search(r"\*\*Modelo:\*\*\s*(.+?)\s*(?:\*\*|$)", linea)
                if m:
                    return m.group(1).strip()
    except Exception:
        pass
    return None


def normaliza_firma(f):
    if not f:
        return None
    for pat, canon in FIRMA:
        if re.search(pat, f):
            return canon
    return None


def autor_por_commit(ruta):
    """Infiere autor por el ultimo commit que toco el archivo."""
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


def clasificar():
    with io.open(SNAPSHOT, encoding="utf-8") as f:
        lineas = [l.rstrip("\n") for l in f if l.strip()]

    bucket_a = {}   # autor -> [paths]
    bucket_b = []
    bucket_c = []   # (path, evidencia)

    for lin in lineas:
        if not lin.startswith(" M"):
            continue
        ruta = lin[3:].strip().strip('"')
        rel = ruta.replace("/", "\\")

        # Bucket B por naturaleza
        if any(p in rel for p in PROPIO_COORD):
            bucket_b.append(rel)
            continue

        abs_path = os.path.join(ROOT, rel)

        # plan-actual: firma del header
        if "plan-actual" in rel and rel.endswith(".md"):
            f = firma_de_header(abs_path)
            autor = normaliza_firma(f)
            if autor:
                bucket_a.setdefault(autor, []).append(rel)
                continue
            # sin firma legible -> git log
            autor, msg = autor_por_commit(ruta)
            if autor:
                bucket_a.setdefault(autor, []).append(rel)
            else:
                bucket_c.append((rel, "plan-actual sin **Modelo:** legible; ultimo commit: %s" % msg))
            continue

        # resto: git log
        autor, msg = autor_por_commit(ruta)
        if autor:
            if autor.startswith("atria-dawn (coordinador)"):
                bucket_b.append(rel)
            else:
                bucket_a.setdefault(autor, []).append(rel)
        else:
            bucket_c.append((rel, "sin prefijo de commit conocido: %s" % msg))

    return bucket_a, bucket_b, bucket_c


if __name__ == "__main__":
    a, b, c = clasificar()
    total = sum(len(v) for v in a.values()) + len(b) + len(c)
    rep = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2",
                       "clasificacion_preliminar.txt")
    with io.open(rep, "w", encoding="utf-8", newline="\n") as f:
        f.write("CLASIFICACION PRELIMINAR DE ARCHIVOS M (ronda 1)\n")
        f.write("TOTAL clasificados: %d\n\n" % total)
        f.write("=== BUCKET A (por modelo) ===\n")
        for autor in sorted(a):
            f.write("%s: %d\n" % (autor, len(a[autor])))
        f.write("\n=== BUCKET B (coordinador): %d ===\n\n" % len(b))
        f.write("=== BUCKET C (inclasificable): %d ===\n" % len(c))
        for path, ev in c:
            f.write("  %s <- %s\n" % (path, ev))
    print("TOTAL clasificados: %d" % total)
    print("bucket C: %d (%.0f%%)" % (len(c), 100.0 * len(c) / total))
    print("reporte:", rep)
