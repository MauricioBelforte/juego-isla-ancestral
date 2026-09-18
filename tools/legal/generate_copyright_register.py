#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.

# M127: Copyright - Generador data-driven de legal/copyright_register.md.
# Lee data/legal/copyright.json y produce el registro de copyright que el propio
# modulo declara como su entregable (03-Diseno.md §2 y 04-Codigo.md §2).
#
# Decision de diseno: la salida es DETERMINISTA (no lleva fecha de generacion) para
# que se pueda verificar en CI con un diff byte a byte.
#
# Uso: python tools/legal/generate_copyright_register.py [--out-dir <dir>]
# Exit 0 si OK, 1 si el catalogo falta o no cumple el contrato.

import os
import sys
import json
import argparse

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
COPYRIGHT_JSON = os.path.join(
    PROJECT_ROOT, "game", "isla-ancestral", "data", "legal", "copyright.json"
)

# Mismo contrato minimo que tools/legal/signoff_check.py
CAMPOS_OBLIGATORIOS = ("id", "elemento", "titular", "year")

SECCIONES = (
    "## 1. Copyright automatico",
    "## 2. Registro formal (opcional)",
    "## 3. Evidencia de autoria",
)


def _load(path):
    if not os.path.exists(path):
        return None, f"no existe: {path}"
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f), None
    except (OSError, json.JSONDecodeError) as e:
        return None, f"error leyendo {path}: {e}"


def validar(data):
    """Devuelve la lista de errores del catalogo (vacia = valido)."""
    errores = []
    if not isinstance(data, dict):
        return ["el catalogo no es un objeto JSON"]
    elementos = data.get("elementos")
    if not isinstance(elementos, list):
        return ["falta la clave 'elementos' o no es un array"]
    if not elementos:
        return ["'elementos' esta vacio"]
    ids = set()
    for e in elementos:
        if not isinstance(e, dict):
            errores.append("hay un elemento que no es objeto")
            continue
        for campo in CAMPOS_OBLIGATORIOS:
            if not e.get(campo):
                errores.append(f"elemento '{e.get('id', '?')}' sin '{campo}'")
        eid = e.get("id")
        if eid in ids:
            errores.append(f"id duplicado: '{eid}'")
        ids.add(eid)
    return errores


def _generar(data):
    """Construye el markdown del registro. Determinista: sin fecha de generacion."""
    elementos = data["elementos"]
    politicas = data.get("politicas", {}) or {}
    lineas = []
    a = lineas.append

    a("# Registro de Copyright - Isla Ancestral")
    a("")
    a("> Archivo **generado** desde `game/isla-ancestral/data/legal/copyright.json`.")
    a("> No editar a mano: regenerar con `python tools/legal/generate_copyright_register.py`.")
    a("")
    a(f"**Titular:** {elementos[0].get('titular', '?')}  ")
    a(f"**Elementos registrados:** {len(elementos)}  ")
    a(f"**Version del catalogo:** {data.get('version', '?')}")
    a("")

    # --- 1. Copyright automatico ---
    a(SECCIONES[0])
    a("")
    a("La proteccion nace con la creacion de la obra (Convenio de Berna), sin")
    a("necesidad de registro. Estado por elemento:")
    a("")
    a("| ID | Elemento | Tipo | Titular | Ano | Licencia |")
    a("|---|---|---|---|---|---|")
    for e in elementos:
        a("| `{id}` | {elemento} | {tipo} | {titular} | {year} | {licencia} |".format(
            id=e.get("id", "?"),
            elemento=e.get("elemento", "?"),
            tipo=e.get("tipo", "-"),
            titular=e.get("titular", "?"),
            year=e.get("year", "?"),
            licencia=e.get("licencia", "-"),
        ))
    a("")
    sin_proteccion = [e.get("id", "?") for e in elementos if not e.get("protegido", True)]
    if sin_proteccion:
        a(f"**Sin proteccion declarada:** {', '.join(sin_proteccion)}")
    else:
        a("Todos los elementos estan marcados como protegidos.")
    a("")

    # --- 2. Registro formal (opcional) ---
    a(SECCIONES[1])
    a("")
    a("El registro formal es opcional y otorga presuncion de validez y derecho a")
    a("reclamar danos. Los tipos USCO aplicables y su costo estan en")
    a("`03-Diseno.md` §2 (USD 35-85 por registro).")
    a("")
    pendientes = [e for e in elementos if str(e.get("registro", "")).lower() == "pendiente"]
    a("| ID | Elemento | Registro | Jurisdiccion |")
    a("|---|---|---|---|")
    for e in elementos:
        a("| `{id}` | {elemento} | {registro} | {juris} |".format(
            id=e.get("id", "?"),
            elemento=e.get("elemento", "?"),
            registro=e.get("registro", "no requerido"),
            juris=e.get("jurisdiccion", "-"),
        ))
    a("")
    if pendientes:
        a("**Pendientes de registro formal:**")
        a("")
        for e in pendientes:
            a(f"- `{e.get('id', '?')}` - {e.get('elemento', '?')}"
              + (f" ({e['nota']})" if e.get("nota") else ""))
    else:
        a("No hay elementos pendientes de registro formal.")
    a("")

    # --- 3. Evidencia de autoria ---
    a(SECCIONES[2])
    a("")
    a("Evidencia automatica disponible en el repositorio:")
    a("")
    a("- **Historial de git** (autores, fechas, diffs): `AUTHORS.md`, generado por")
    a("  `tools/legal/generate_authors.py` a partir de `git log`.")
    a("- **Aviso legal y atribuciones:** `NOTICE.md` y `LICENSE`, generados por")
    a("  `tools/legal/generate_copyright_docs.py`.")
    a("- **Timestamps:** author date y commit date de git, mas el mtime del sistema")
    a("  de archivos.")
    a("- **Validacion pre-release:** `tools/legal/signoff_check.py`.")
    a("")
    a("### Politicas declaradas")
    a("")
    if politicas:
        for k in sorted(politicas):
            a(f"- `{k}`: `{politicas[k]}`")
    else:
        a("- (el catalogo no declara politicas)")
    a("")
    return "\n".join(lineas)


def main():
    parser = argparse.ArgumentParser(
        description="Genera legal/copyright_register.md desde data/legal/copyright.json"
    )
    parser.add_argument("--out-dir", default=PROJECT_ROOT, help="Directorio destino (default: project root)")
    parser.add_argument("--check", action="store_true",
                        help="No escribe: verifica que el archivo en disco este al dia (exit 1 si difiere)")
    args = parser.parse_args()

    data, err = _load(COPYRIGHT_JSON)
    if err:
        print(f"[M127] ERROR: {err}", file=sys.stderr)
        return 1

    errores = validar(data)
    if errores:
        print("[M127] ERROR: el catalogo no cumple el contrato:", file=sys.stderr)
        for e in errores:
            print(f"  - {e}", file=sys.stderr)
        return 1

    contenido = _generar(data)

    dest_dir = os.path.join(args.out_dir, "legal")
    dest = os.path.join(dest_dir, "copyright_register.md")

    if args.check:
        if not os.path.exists(dest):
            print(f"[M127] ERROR: falta {dest}", file=sys.stderr)
            return 1
        with open(dest, "r", encoding="utf-8", newline="") as f:
            actual = f.read()
        if actual != contenido:
            print(f"[M127] ERROR: {dest} esta desactualizado (regenerar)", file=sys.stderr)
            return 1
        print(f"[M127] OK: {dest} al dia ({len(contenido)} chars)")
        return 0

    os.makedirs(dest_dir, exist_ok=True)
    with open(dest, "w", encoding="utf-8", newline="\n") as f:
        f.write(contenido)
    print(f"[M127] copyright_register.md ({len(contenido)} chars) -> {dest}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
