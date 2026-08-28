#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardián del contrato de visión — Módulo 153 (Isla Ancestral).

Implementación ejecutable (Python) de validate_vision (espec original en
GDScript para editor/CI — M118). Verifica:
  1. validate_contrato()  -> cada O tiene criterio y dueños
  2. validate_principios()-> ningún criterio viola M152 (palabras prohibidas)
  3. validate_cobertura() -> los 01-Requerimientos de los módulos declaran O#
                             (WARN, no error — permite operaciones)
  4. validate_prueba()    -> prueba_vision.md lista O1-O19

Uso:  python validate_vision.py [--contrato RUTA] [--docs RUTA]
Exit: 0 OK · 1 errores · 2 configuración.
"""
import argparse
import json
import re
import sys
from pathlib import Path

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

PROHIBIDAS = ["combate obligatorio", "fomo", "grind", "cofre aleatorio", "streak", "expiracion"]


def cargar_contrato(ruta: Path) -> dict:
    with ruta.open(encoding="utf-8") as f:
        return json.load(f)


def validate_contrato(contrato: dict) -> list:
    problemas = []
    ids_vistos = []
    for o in contrato.get("objetivos", []):
        oid = o.get("id", "?")
        if not o.get("criterio", "").strip():
            problemas.append(f"{oid}: sin criterio verificable")
        if not o.get("duenos"):
            problemas.append(f"{oid}: sin módulo dueño")
        if not o.get("titulo", "").strip():
            problemas.append(f"{oid}: sin título")
        if oid in ids_vistos:
            problemas.append(f"{oid}: duplicado")
        ids_vistos.append(oid)
    return problemas


def validate_principios(contrato: dict) -> list:
    problemas = []
    for o in contrato.get("objetivos", []):
        c = (o.get("criterio", "") + " " + o.get("titulo", "")).lower()
        for p in PROHIBIDAS:
            if p in c:
                problemas.append(f"{o.get('id','?')}: viola M152/M151 ({p})")
    return problemas


def validate_cobertura(docs_root: Path) -> list:
    """WARN: módulos cuyo 01-Requerimientos no declara ningún O#."""
    avisos = []
    patron = re.compile(r"\bO([1-9]|1[0-9])\b")
    for req in sorted(docs_root.glob("*/plan-actual/01-Requerimientos.md")):
        texto = req.read_text(encoding="utf-8", errors="ignore")
        if not patron.search(texto):
            avisos.append(req.parent.parent.name)
    return avisos


def validate_prueba(ruta_prueba: Path) -> list:
    problemas = []
    if not ruta_prueba.exists():
        return [f"prueba de visión ausente: {ruta_prueba.name}"]
    texto = ruta_prueba.read_text(encoding="utf-8", errors="ignore")
    for n in range(1, 20):
        if f"O{n}" not in texto:
            problemas.append(f"prueba de visión no menciona O{n}")
    return problemas


def main() -> int:
    parser = argparse.ArgumentParser(description="Guardián del contrato de visión M153")
    parser.add_argument("--contrato", default=None)
    parser.add_argument("--docs", default=None)
    args = parser.parse_args()

    aqui = Path(__file__).resolve().parent
    contrato_path = Path(args.contrato) if args.contrato else aqui / "vision_contract.json"
    docs_root = Path(args.docs) if args.docs else aqui.parents[1]

    if not contrato_path.exists():
        print(f"ERROR: contrato no encontrado: {contrato_path}")
        return 2
    contrato = cargar_contrato(contrato_path)

    errores = []
    errores += validate_contrato(contrato)
    errores += validate_principios(contrato)
    errores += validate_prueba(aqui / "prueba_vision.md")

    print("=" * 60)
    print("GUARDIÁN DEL CONTRATO DE VISIÓN — M153")
    print("=" * 60)
    n = len(contrato.get("objetivos", []))
    print(f"Objetivos en contrato: {n} (esperados: 19)")
    if n != 19:
        errores.append(f"el contrato debe tener 19 objetivos (tiene {n})")

    for e in errores:
        print(f"  [X] {e}")
    if not errores:
        print("  [OK] Contrato completo, sin violaciones de principios, prueba presente")

    avisos = validate_cobertura(docs_root)
    print("\nCOBERTURA O# en 01-Requerimientos (WARN, no bloquea):")
    if avisos:
        print(f"  [!] {len(avisos)} módulos sin declaración O# (operaciones/build/legal u aún no alineados)")
        print(f"     Ejemplos: {', '.join(avisos[:10])}{'…' if len(avisos) > 10 else ''}")
    else:
        print("  [OK] Todos los módulos declaran O#")

    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
