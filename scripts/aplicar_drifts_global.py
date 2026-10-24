#!/usr/bin/env python3
"""Aplica el bloque de 26 drifts de la iter.11 sobre CHECKLIST-GLOBAL.md.

Orden del director (msg 384, punto 1): «Los 26 drifts: te AUTORIZO para aplicar
tu bloque (con tu `--json`). Regla del emoji de las 10 sobrescritas: usa tu
reconstruccion por DoD (regla propia), citas al pie por fila, y marca cada fila
como "emoji reconstruido"».

QUE HACE
  1. Progreso: escribe el valor MEDIDO en disco (contar_checklist sobre el
     05-Checklist.md del modulo). No se copia de la auditoria: se re-mide.
  2. Estado: si la celda no empieza con un emoji valido (fue sobrescrita por un
     numero, o quedo mojibake), se reconstruye:
        - texto legible dice "En curso"  -> 🔵 En curso  (mojibake decodificado)
        - hay [ ] o [?]                  -> 🟡 Con dudas (regla DoD del director)
        - todo [x]                       -> ✅ Completado
  3. Notas: se anexa la cita de la fila (que cambio, de que a que, por que).

Uso:
    python scripts/aplicar_drifts_global.py --dry-run
    python scripts/aplicar_drifts_global.py --aplicar
"""
import argparse
import hashlib
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "scripts"))
import verificar_checklist as ver  # noqa: E402

GLOBAL = RAIZ / "CHECKLIST-GLOBAL.md"
DOC = RAIZ / "DOCUMENTACION"

# ids con drift de Progreso (15 de la clase drift_progreso_obsoleto + 10 de
# drift_estado_sobrescrito + M73 prosa, que el realineador ya resolvio).
# Se listan los 25 que el gate sigue reportando.
IDS_DRIFT = [10, 16, 40, 48, 68, 72, 77, 108, 138, 156,
             11, 15, 17, 20, 23, 24, 27, 45, 50, 62, 93, 104, 139, 161, 162]

# filas con el emoji destruido por mojibake (fuera de los 26: defecto aparte,
# medido en la auditoria §8.2). 45 y 161 ademas tienen drift de Progreso.
IDS_MOJIBAKE = [45, 83, 159, 161]

EMOJIS_VALIDOS = ("⬜", "🟢", "🔵", "🔴", "🟡", "✅")
RE_EMOJI_INICIAL = re.compile(r"^(\S+)")


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def medir(nombre_modulo: str):
    cl = DOC / nombre_modulo / "plan-actual" / "05-Checklist.md"
    if not cl.exists():
        return None
    x, p, d = ver.contar_checklist(cl)
    return x, p, d, "%d/%d" % (x, x + p + d)


def emoji_ok(celda: str) -> bool:
    m = RE_EMOJI_INICIAL.match(celda.strip())
    return bool(m) and m.group(1) in EMOJIS_VALIDOS


def reconstruir_estado(celda: str, x: int, p: int, d: int):
    """Devuelve (emoji, motivo)."""
    if "En curso" in celda or "Implementado" in celda:
        return "🔵", "texto legible dice En curso/Implementado"
    if d > 0 or p > 0:
        return "🟡", "hay %d [ ] y %d [?] -> DoD 21.6 no permite ✅" % (p, d)
    return "✅", "todo [x]"


def main():
    ap = argparse.ArgumentParser()
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--aplicar", action="store_true")
    g.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    texto = GLOBAL.read_text(encoding="utf-8")
    lineas = texto.split("\n")
    idx_enc = next(i for i, l in enumerate(lineas)
                   if l.strip().startswith("|") and l.strip().split("|")[1].strip() == "ID")
    print("sha256 ANTES: %s" % sha256(GLOBAL))

    cambios = []
    for i in range(idx_enc + 2, len(lineas)):
        linea = lineas[i]
        if not linea.strip().startswith("|"):
            continue
        c = [x.strip() for x in linea.strip().split("|")]
        while c and c[0] == "":
            c = c[1:]
        while c and c[-1] == "":
            c = c[:-1]
        if not c or not c[0].isdigit():
            continue
        mid = int(c[0])
        if len(c) != 11:
            continue
        nombre = c[1]
        hecho = medir(nombre)
        if hecho is None:
            print("  !! sin checklist: M%d %s" % (mid, nombre))
            continue
        x, p, d, esperado = hecho

        notas_extra = []
        prog_viejo = c[3]
        est_viejo = c[2]
        nuevo = list(c)

        if mid in IDS_DRIFT and prog_viejo != esperado:
            nuevo[3] = esperado
            notas_extra.append("Progreso %s→%s (medido en 05-Checklist, iter.12)"
                               % (prog_viejo, esperado))

        if (mid in IDS_DRIFT or mid in IDS_MOJIBAKE) and not emoji_ok(est_viejo):
            emoji, motivo = reconstruir_estado(est_viejo, x, p, d)
            if re.match(r"^\d+/\d+$", est_viejo.strip()):
                # la celda *Estado* fue SOBRESCRITA con el progreso: no queda
                # texto que preservar, solo el numero (que ya vive en la
                # columna Progreso). Se repone la etiqueta completa.
                etiqueta = "Con dudas" if emoji == "🟡" else "Completado"
                nuevo[2] = "%s %s" % (emoji, etiqueta)
            else:
                resto = est_viejo
                if mid in IDS_MOJIBAKE:
                    m = re.search(r"(En curso|Implementado|Con dudas|Completado)",
                                  est_viejo)
                    resto = est_viejo[m.start():] if m else est_viejo
                nuevo[2] = "%s %s" % (emoji, resto.strip())
            notas_extra.append(
                "emoji Estado reconstruido por DoD (era %r; %s; iter.12)"
                % (est_viejo[:24], motivo))

        if nuevo != c:
            nuevo[10] = c[10] + " · **iter.12 DS (msg 384):** " + "; ".join(notas_extra) + "."
            lineas[i] = "| " + " | ".join(nuevo) + " |"
            cambios.append((i + 1, mid, nombre, prog_viejo, nuevo[3],
                            est_viejo[:30], nuevo[2][:30]))

    print()
    print("FILAS CAMBIADAS: %d" % len(cambios))
    for ln, mid, nombre, pv, pn, ev, en in cambios:
        print("  L%-4d M%-4d %s" % (ln, mid, nombre))
        print("        Progreso: %-12s -> %-12s" % (pv, pn))
        print("        Estado  : %-30r -> %r" % (ev, en))

    salida = "\n".join(lineas)
    if args.aplicar:
        GLOBAL.write_text(salida, encoding="utf-8", newline="\n")
        print()
        print("sha256 DESPUES: %s" % sha256(GLOBAL))
        print("bytes: %d -> %d" % (len(texto.encode("utf-8")),
                                   len(salida.encode("utf-8"))))
    else:
        print("\n[dry-run] no se escribio nada")
    return 0


if __name__ == "__main__":
    sys.exit(main())
