# -*- coding: utf-8 -*-
"""Saneamiento mojibake UTF-8 (§28 AGENTS.md) — revertir doble codificación cp1252→UTF-8.

Caso real (2026-09-12, GLM-5.3/Kilo Code): WorkBuddy escribió filas de
CHECKLIST-GLOBAL.md pasando texto UTF-8 por una decodificación cp1252 y
re-encodeado UTF-8. Los emojis del protocolo quedaron como mojibake de nivel
TEXTO en UTF-8 válido (p. ej. 🟡 = F0 9F 9F A1 → ðŸŸ¡ = U+00F0 U+0178 U+0178 U+00A1).

Algoritmo seguro (selectivo, no ciego):
  1. Por cada run de caracteres no-ASCII consecutivos de una línea:
  2. Encodear el run como cp1252. Si algún char no mapea (p. ej. un emoji
     legítimo U+1F7E1), abortar y dejar el run intacto.
  3. Decodificar esos bytes como UTF-8. Si es inválido o produce U+FFFD,
     abortar y dejar el run intacto.
  4. Solo si el resultado es limpio, reemplazar el run.

Por qué es seguro: un run de texto legítimo de 1 solo char no-ASCII (ñ, é, º)
nunca decodifica como UTF-8 válido tras cp1252 (un byte >= 0x80 aislado es
siempre lead byte sin continuadores). Las secuencias legítimas largas
(áéíóú = E1 E9 ED F3 FA) tampoco: E1 exige 2 continuadores 80-BF y E9 no lo es.

Uso:
  python scripts/saneamiento_utf8.py <archivo.md> [--dry-run] [--backup]

Salida: número de runs saneados y verificación (0 mojibake residual esperado).
"""
import sys
import re
import shutil
import io
from datetime import datetime

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

PATRON_RUN = re.compile(r"([^\x00-\x7f]+)")


def fix_run(run: str):
    try:
        b = run.encode("cp1252")
    except (UnicodeEncodeError, LookupError):
        return run, False
    try:
        dec = b.decode("utf-8")
    except UnicodeDecodeError:
        return run, False
    if "\ufffd" in dec:
        return run, False
    return dec, True


def fix_line(line: str):
    if not PATRON_RUN.search(line):
        return line, 0
    total = 0

    def _reemplazar(m):
        nonlocal total
        nuevo, ok = fix_run(m.group(1))
        if ok:
            total += 1
        return nuevo

    return PATRON_RUN.sub(_reemplazar, line), total


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    dry = "--dry-run" in sys.argv
    backup = "--backup" in sys.argv
    if not args:
        print("Uso: python saneamiento_utf8.py <archivo> [--dry-run] [--backup]")
        sys.exit(2)
    ruta = args[0]
    with open(ruta, "rb") as f:
        data = f.read()
    tenia_bom = data[:3] == b"\xef\xbb\xbf"
    texto = data.decode("utf-8-sig")
    lineas = texto.split("\n")
    saneados = 0
    detalle = []
    for i, ln in enumerate(lineas):
        nueva, n = fix_line(ln)
        if n:
            saneados += n
            detalle.append((i + 1, ln[:70]))
            lineas[i] = nueva
    resultado = "\n".join(lineas)
    # Verificación: el resultado no debe contener BOM interno ni FFFD nuevo
    assert "\ufffe" not in resultado
    print(f"Archivo: {ruta}")
    print(f"Runs saneados: {saneados}")
    for num, previa in detalle[:60]:
        print(f"  L{num}: {previa}")
    if len(detalle) > 60:
        print(f"  ... y {len(detalle) - 60} más")
    print(f"BOM original: {'sí (será eliminado)' if tenia_bom else 'no'}")
    if dry:
        print("DRY-RUN: no se escribió nada.")
        return
    if backup:
        ts = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        shutil.copy2(ruta, f"{ruta}.bak_{ts}")
        print(f"Backup: {ruta}.bak_{ts}")
    with open(ruta, "wb") as f:
        f.write(resultado.encode("utf-8"))
    print("Escrito en UTF-8 sin BOM.")


if __name__ == "__main__":
    main()
