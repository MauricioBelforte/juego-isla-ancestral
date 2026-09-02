#!/usr/bin/env python3
# M127: Copyright - Generador data-driven de NOTICE.md y LICENSE.
# Lee data/legal/copyright.json y data/legal/licencias.json, produce
# NOTICE.md (atribuciones de terceros) y LICENSE (terminos del juego).
# Uso: python tools/legal/generate_copyright_docs.py [--out-dir <dir>]

import os
import sys
import json
import argparse
from datetime import datetime
from typing import List, Dict, Optional

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
LEGAL_DIR = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data", "legal")

COPYRIGHT_JSON = os.path.join(LEGAL_DIR, "copyright.json")
LICENCIAS_JSON = os.path.join(LEGAL_DIR, "licencias.json")
COPYRIGHT_YEAR = 2026
COPYRIGHT_TITULAR = "Isla Ancestral Team"

LICENSE_TEMPLATES = {
    "MIT": "Permission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files (the \"Software\"), to deal\nin the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\ncopies of the Software, and to permit persons to whom the Software is\nfurnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all\ncopies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND.",
    "CC0": "Creative Commons CC0 1.0 Universal - Public Domain Dedication\n\nThe person who associated a work with this deed has dedicated the work to the\npublic domain by waiving all rights worldwide under copyright law.",
    "CC_BY_4": "Creative Commons Attribution 4.0 International\n\nThis work is licensed under CC BY 4.0. You are free to share and adapt the\nmaterial for any purpose, including commercially, with attribution to the\noriginal creator.",
    "Propietaria": "TODOS LOS DERECHOS RESERVADOS.\n\nEste software y su contenido asociado (graficos, audio, narrativa) son\npropiedad de %s. No se permite la redistribucion, modificacion,\no uso comercial sin autorizacion escrita del titular." % COPYRIGHT_TITULAR,
}


def _load(path: str) -> dict:
    if not os.path.exists(path):
        print(f"  WARN: {path} no existe", file=sys.stderr)
        return {}
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        print(f"  WARN: error leyendo {path}: {e}", file=sys.stderr)
        return {}


def _year() -> int:
    return datetime.now().year


def _licencia_texto(licencia: str) -> str:
    """Devuelve el texto canonico de una licencia."""
    if not licencia:
        return "(sin licencia especificada)"
    if licencia in LICENSE_TEMPLATES:
        return LICENSE_TEMPLATES[licencia]
    return f"Licencia: {licencia}\n(ver archivo original en la fuente)"


def generate_notice(copyright_data: dict, licencias_data: dict) -> str:
    """Genera NOTICE.md con atribuciones y resumen de copyright."""
    year = _year()
    lineas: List[str] = [
        f"# Isla Ancestral — Notice & Third-Party Attributions",
        "",
        f"Copyright (c) {year} {COPYRIGHT_TITULAR}. Todos los derechos reservados.",
        "",
        "## Elementos protegidos por copyright del estudio",
        "",
    ]
    for e in copyright_data.get("elementos", []):
        protegido = "SI" if e.get("protegido", True) else "NO"
        lineas.append(f"- **{e.get('elemento', '?')}** (id: {e.get('id', '?')})")
        lineas.append(f"  - Titular: {e.get('titular', '?')}")
        lineas.append(f"  - Protegido: {protegido}")
        if "year" in e:
            lineas.append(f"  - Año: {e.get('year')}")
        if "jurisdiccion" in e:
            lineas.append(f"  - Jurisdiccion: {e.get('jurisdiccion')}")
        if "licencia" in e:
            lineas.append(f"  - Licencia: {e.get('licencia')}")
        if "nota" in e:
            lineas.append(f"  - Nota: {e.get('nota')}")
        lineas.append("")
    # Software y assets de terceros
    if licencias_data.get("licencias"):
        lineas.append("## Software y assets de terceros con licencias")
        lineas.append("")
        for l in licencias_data["licencias"]:
            lineas.append(f"- **{l.get('software', '?')}** (id: {l.get('id', '?')})")
            lineas.append(f"  - Licencia: {l.get('licencia', '?')}")
            lineas.append(f"  - Uso: {l.get('uso', '?')}")
            if not l.get("comercial_ok", True):
                lineas.append(f"  - ⚠️ NO uso comercial")
            lineas.append("")
    # Politicas
    if copyright_data.get("politicas"):
        lineas.append("## Politicas")
        lineas.append("")
        for k, v in copyright_data["politicas"].items():
            lineas.append(f"- {k}: {v}")
        lineas.append("")
    lineas.append(f"_Generado automaticamente por `tools/legal/generate_copyright_docs.py` el {datetime.now().isoformat()}_")
    return "\n".join(lineas) + "\n"


def generate_license(copyright_data: dict) -> str:
    """Genera LICENSE con copyright principal + terminos."""
    year = _year()
    elementos = copyright_data.get("elementos", [])
    # Busca la licencia del codigo fuente
    licencia_codigo = "Propietaria"
    for e in elementos:
        if e.get("id") == "codigo_fuente" and e.get("licencia"):
            licencia_codigo = e["licencia"]
    lineas: List[str] = [
        f"LICENSE — Isla Ancestral",
        "",
        f"Copyright (c) {year} {COPYRIGHT_TITULAR}",
        "",
        f"Licencia aplicable: {licencia_codigo}",
        "",
        "---",
        "",
    ]
    lineas.append(_licencia_texto(licencia_codigo))
    lineas.append("")
    lineas.append("---")
    lineas.append("")
    lineas.append("## Componentes")
    lineas.append("")
    for e in elementos:
        if e.get("protegido", True):
            tipo = e.get("tipo", "componente")
            titular = e.get("titular", "?")
            elem = e.get("elemento", "?")
            e_year = e.get("year", year)
            lineas.append(f"- {elem} ({tipo}) © {e_year} {titular}")
    lineas.append("")
    lineas.append("## Software y assets de terceros (atribuciones)")
    lineas.append("")
    lineas.append("Ver NOTICE.md para la lista completa de licencias de terceros.")
    lineas.append("")
    lineas.append("---")
    lineas.append("")
    lineas.append(f"Este archivo fue generado automaticamente por `tools/legal/generate_copyright_docs.py` el {datetime.now().isoformat()}.")
    lineas.append("Si modifica manualmente el copyright, regenere con el script.")
    return "\n".join(lineas) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Genera NOTICE.md y LICENSE desde data/legal/")
    parser.add_argument("--out-dir", default=PROJECT_ROOT, help="Directorio destino (default: project root)")
    parser.add_argument("--year", type=int, default=None, help="Año forzado (default: año actual)")
    args = parser.parse_args()

    copyright_data = _load(COPYRIGHT_JSON)
    licencias_data = _load(LICENCIAS_JSON)

    if not copyright_data:
        print("ERROR: copyright.json no cargado. Abortando.", file=sys.stderr)
        return 1

    notice = generate_notice(copyright_data, licencias_data)
    license_text = generate_license(copyright_data)

    out_dir = args.out_dir
    os.makedirs(out_dir, exist_ok=True)

    notice_path = os.path.join(out_dir, "NOTICE.md")
    license_path = os.path.join(out_dir, "LICENSE")

    with open(notice_path, "w", encoding="utf-8") as f:
        f.write(notice)
    with open(license_path, "w", encoding="utf-8") as f:
        f.write(license_text)

    print(f"[M127] NOTICE.md ({len(notice)} chars) -> {notice_path}")
    print(f"[M127] LICENSE ({len(license_text)} chars) -> {license_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
