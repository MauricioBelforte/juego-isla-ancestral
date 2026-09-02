#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Genera el backlog personal de un modelo según la metodología
DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md.

Extrae los ítems pendientes ([ ] y [?]) del 05-Checklist.md (plan-actual,
fallback plan-inicial) de cada módulo cuya columna Recom de
CHECKLIST-GLOBAL.md nombre al modelo, y genera:

  DOCUMENTACION/TAREAS-POR-MODELO/<MODELO>/
  ├── BACKLOG-MASTER.md
  └── <ID-Modulo>-<Nombre>/checklist.md   (IDs T-### secuenciales por módulo)

Uso:
  python scripts/generar_tareas_modelo.py --modelo glm-5.3 --recom glm-5.3 [--dry-run]

Notas:
  - Excluye módulos en estado "Completado" y "En curso" (bloqueados por §21.4.2).
  - Escritura siempre en UTF-8 sin BOM (AGENTS.md §28).
  - --dry-run muestra el plan sin escribir archivos.
"""

import argparse
import io
import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CHECKLIST_GLOBAL = os.path.join(RAIZ, "CHECKLIST-GLOBAL.md")
DOC_DIR = os.path.join(RAIZ, "DOCUMENTACION")
OUT_BASE = os.path.join(DOC_DIR, "TAREAS-POR-MODELO")


def leer_utf8(path):
    """Lee un archivo tolerando mojibake (errors=replace)."""
    with io.open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()


def parse_checklist_global(path=CHECKLIST_GLOBAL):
    """Parsea la tabla de CHECKLIST-GLOBAL.md → lista de dicts de módulos."""
    modulos = []
    for line in leer_utf8(path).splitlines():
        if not re.match(r"^\|\s*\d{1,3}\s*\|", line):
            continue
        cells = [c.strip() for c in line.split("|")[1:-1]]
        if len(cells) < 9:
            continue
        modulos.append({
            "id": cells[0],
            "nombre": cells[1],
            "estado": cells[2],
            "progreso": cells[3],
            "prioridad": cells[4],
            "complejidad": cells[5],
            "recom": cells[7],
            "agente": cells[8] if len(cells) > 8 else "",
        })
    return modulos


def estado_bloqueado(estado):
    """True si el módulo está Completado o En curso (no asignable)."""
    e = estado.lower()
    return ("completado" in e) or ("en curso" in e)


def find_module_folder(mod_id):
    """Busca DOCUMENTACION/<ID>-<Nombre>/ (prefijo exacto del ID)."""
    patron = re.compile(r"^%s-" % re.escape(mod_id))
    for name in sorted(os.listdir(DOC_DIR)):
        if patron.match(name) and os.path.isdir(os.path.join(DOC_DIR, name)):
            return os.path.join(DOC_DIR, name)
    return None


def extraer_pendientes(mod_folder):
    """Devuelve (ruta_05, pendientes, total) del 05-Checklist.md del módulo.

    pendientes = lista de (marca, texto) con marca en {' ', '?'}.
    Prefiere plan-actual/05-Checklist.md; fallback plan-inicial/.
    """
    for sub in ("plan-actual", "plan-inicial"):
        ruta = os.path.join(mod_folder, sub, "05-Checklist.md")
        if not os.path.exists(ruta):
            continue
        pendientes, total = [], 0
        for line in leer_utf8(ruta).splitlines():
            m = re.match(r"^\s*[-*]\s*\[([ xX?→>])\]\s*(.+?)\s*$", line)
            if not m:
                continue
            total += 1
            marca = m.group(1).lower()
            if marca in (" ", "?"):
                pendientes.append((marca, m.group(2)))
        return ruta, pendientes, total
    return None, [], 0

def clave_orden(mod):
    """Priorización de la guía: (a) núcleo existente, (b) prioridad, (c) ID."""
    estado = mod["estado"].lower()
    nucleo = 0 if "dudas" in estado else 1  # Con dudas → núcleo existe, primero
    prio = {"alta": 0, "media": 1, "baja": 2}.get(mod["prioridad"].lower(), 3)
    return (nucleo, prio, int(mod["id"]))


def generar(modelo, recom_patron, plataforma, dry_run=False):
    recom_re = re.compile(recom_patron, re.IGNORECASE)
    asignados = [
        m for m in parse_checklist_global()
        if recom_re.search(m["recom"]) and not estado_bloqueado(m["estado"])
    ]
    asignados.sort(key=clave_orden)
    if not asignados:
        print("No se encontraron módulos con Recom ~ /%s/ asignables." % recom_patron)
        return 1

    plan = []
    for m in asignados:
        carpeta_mod = find_module_folder(m["id"])
        if not carpeta_mod:
            plan.append((m, None, None, [], 0))
            continue
        ruta05, pendientes, total = extraer_pendientes(carpeta_mod)
        plan.append((m, os.path.basename(carpeta_mod), ruta05, pendientes, total))

    total_tareas = sum(len(p[3]) for p in plan)
    print("Modelo: %s | Módulos asignables: %d | Tareas pendientes: %d"
          % (modelo, len(plan), total_tareas))
    for m, carpeta, _r05, pendientes, total in plan:
        print("  M%-4s %-45s %-22s pend=%d/%d" % (
            m["id"], (carpeta or "SIN CARPETA")[:45], m["estado"][:22],
            len(pendientes), total))
    if dry_run:
        print("[dry-run] no se escribió nada.")
        return 0

    out_dir = os.path.join(OUT_BASE, modelo)
    os.makedirs(out_dir, exist_ok=True)
    firma = "**Modelo:** %s\n**Plataforma:** %s\n" % (modelo, plataforma)

    # --- checklist.md por módulo ---
    for m, carpeta, _r05, pendientes, total in plan:
        if carpeta is None:
            continue
        mod_dir = os.path.join(out_dir, carpeta)
        os.makedirs(mod_dir, exist_ok=True)
        lineas = [
            firma,
            "**Módulo:** %s (%s)" % (carpeta, m["id"]),
            "",
            "# Checklist personal tareas — %s" % carpeta,
            "",
            "> Extraídas del `05-Checklist.md` del módulo (%d pendientes de %d ítems)."
            " Fuente de verdad del ítem: el `05-Checklist.md`." % (len(pendientes), total),
            "",
            "## Tareas",
            "",
        ]
        for i, (marca, texto) in enumerate(pendientes, 1):
            suf = " *[?]*" if marca == "?" else ""
            lineas.append("- [ ] T-%03d %s%s" % (i, texto, suf))
        with io.open(os.path.join(mod_dir, "checklist.md"), "w",
                     encoding="utf-8", newline="\n") as f:
            f.write("\n".join(lineas) + "\n")

    # --- BACKLOG-MASTER.md ---
    lineas = [
        firma,
        "# BACKLOG MASTER — %s" % modelo,
        "",
        "> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`."
        " Fuente: columna **Recom** de `CHECKLIST-GLOBAL.md` (patrón `%s`),"
        " ítems pendientes `[ ]`/`[?]` de los `05-Checklist.md`." % recom_patron,
        "",
        "**Módulos asignados:** %d  |  **Tareas pendientes totales:** %d"
        % (len([p for p in plan if p[1]]), total_tareas),
        "",
        "## Orden de trabajo",
        "",
        "| # | ID | Módulo | Estado global | Progreso | Prioridad | Pendientes | Subcarpeta |",
        "|---|----|--------|---------------|----------|-----------|------------|------------|",
    ]
    for n, (m, carpeta, _r05, pendientes, _total) in enumerate(plan, 1):
        lineas.append(
            "| %d | %s | %s | %s | %s | %s | %d | `%s/checklist.md` |"
            % (n, m["id"], carpeta or "—", m["estado"][:30], m["progreso"],
               m["prioridad"], len(pendientes) if carpeta else 0, carpeta or "—"))
    lineas += [
        "",
        "## Reglas de sincronización (al completar una T-###)",
        "",
        "1. Marcar `[x]` en esta checklist personal (con evidencia: log + test).",
        "2. Marcar el ítem correspondiente en el `05-Checklist.md` del módulo.",
        "3. Actualizar la fila del módulo en `CHECKLIST-GLOBAL.md` (progreso).",
        "",
    ]
    with io.open(os.path.join(out_dir, "BACKLOG-MASTER.md"), "w",
                 encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lineas) + "\n")

    print("OK → %s (BACKLOG-MASTER.md + %d subcarpetas)"
          % (out_dir, len([p for p in plan if p[1]])))
    return 0


def main():
    ap = argparse.ArgumentParser(description="Genera backlog TAREAS-POR-MODELO de un modelo")
    ap.add_argument("--modelo", required=True, help="Identidad del modelo (nombre de carpeta)")
    ap.add_argument("--recom", required=True,
                    help="Patrón regex a buscar en la columna Recom (ej: 'glm-5.3')")
    ap.add_argument("--plataforma", default="Cline")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    sys.exit(generar(args.modelo, args.recom, args.plataforma, args.dry_run))


if __name__ == "__main__":
    main()
