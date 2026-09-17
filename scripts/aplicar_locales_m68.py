#!/usr/bin/env python3
# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M68 iter. 2 — Inserta el catálogo de localización de M68 en los .po de M87.
#
# Fuente de verdad: game/isla-ancestral/data/transporte/m68_catalogo.json,
# generado por `TransportLocalizer.generar_catalogo()` (script Godot
# `dump_locales_m68.gd`). Este script NO inventa texto: sólo lo vuelca.
#
# Reglas duras del proyecto:
#   * UTF-8 SIN BOM (§28) y saltos de línea LF.
#   * NO toca ninguna clave que ya exista en el .po (las de M87 se respetan).
#   * Idempotente: correrlo dos veces no duplica entradas.
#
# Uso:  python scripts/aplicar_locales_m68.py [--dry-run]

import json
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
GAME = RAIZ / "game" / "isla-ancestral"
CATALOGO = GAME / "data" / "transporte" / "m68_catalogo.json"
LOCALES = GAME / "locales"
IDIOMAS = ["es", "en"]


def escapar(texto: str) -> str:
    return texto.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")


def msgids_existentes(lineas: list) -> set:
    """msgids simples y plurales ya presentes (para no duplicar)."""
    out = set()
    for linea in lineas:
        s = linea.strip()
        if s.startswith("msgid ") or s.startswith("msgid_plural "):
            valor = s.split(" ", 1)[1].strip()
            if valor.startswith('"') and valor.endswith('"'):
                valor = valor[1:-1]
            if valor:
                out.add(valor)
    return out


def main() -> int:
    dry = "--dry-run" in sys.argv
    if not CATALOGO.exists():
        print("ERROR: falta %s (corré antes dump_locales_m68.gd)" % CATALOGO)
        return 1
    datos = json.loads(CATALOGO.read_text(encoding="utf-8"))
    total_nuevas = 0
    for idioma in IDIOMAS:
        ruta = LOCALES / (idioma + ".po")
        if not ruta.exists():
            print("ERROR: falta %s" % ruta)
            return 1
        crudo = ruta.read_bytes()
        if crudo.startswith(b"\xef\xbb\xbf"):
            print("ERROR: %s tiene BOM (§28 lo prohíbe)" % ruta)
            return 1
        texto = crudo.decode("utf-8")
        if "\r\n" in texto:
            print("ERROR: %s usa CRLF; M68 exige LF" % ruta)
            return 1
        lineas = texto.split("\n")
        existentes = msgids_existentes(lineas)

        simples = datos["locales"][idioma]
        plurales = datos["plurales"][idioma]

        nuevas = []
        for clave in sorted(simples.keys()):
            if clave in existentes:
                continue
            nuevas.append('msgid "%s"' % escapar(clave))
            nuevas.append('msgstr "%s"' % escapar(str(simples[clave])))
            nuevas.append("")
        for clave in sorted(plurales.keys()):
            if clave in existentes:
                continue
            formas = plurales[clave]
            nuevas.append('msgid "%s"' % escapar(clave))
            nuevas.append('msgid_plural "%s"' % escapar(clave))
            for i, forma in enumerate(formas):
                nuevas.append('msgstr[%d] "%s"' % (i, escapar(str(forma))))
            nuevas.append("")

        if not nuevas:
            print("%s: nada nuevo (idempotente)" % ruta.name)
            continue

        cuerpo = texto.rstrip("\n")
        salida = cuerpo + "\n\n# M68: Transporte y Navegación (iter. 2)\n" + "\n".join(nuevas).rstrip("\n") + "\n"
        n_simples = sum(1 for c in simples if c not in existentes)
        n_plurales = sum(1 for c in plurales if c not in existentes)
        total_nuevas += n_simples + n_plurales
        print("%s: +%d simples, +%d plurales (%d lineas)" % (ruta.name, n_simples, n_plurales, len(nuevas)))
        if not dry:
            ruta.write_bytes(salida.encode("utf-8"))

    print("TOTAL claves nuevas: %d%s" % (total_nuevas, " (dry-run)" if dry else ""))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
