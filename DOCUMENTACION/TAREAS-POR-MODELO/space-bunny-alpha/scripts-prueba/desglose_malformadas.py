# -*- coding: utf-8 -*-
"""SB-02: desglose de las 58 filas mal formadas.

Dos causas distintas, con consecuencias distintas:
  A) FALTAN celdas (10 en vez de 11) -> la columna 'Recom' esta vacia y se
     colapso, o falta alguna. Al parsear por posicion, todo lo que venga
     despues se desplaza una columna.
  B) SOBRAN celdas (>11) -> hay pipes '|' sin escapar DENTRO de la columna
     Notas. Al parsear por posicion, 'Agente actual' y 'Ultima actividad'
     reciben basura.
"""
import io
import os
import re
import sys

RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                     "..", "..", "..", ".."))
GLOBAL = os.path.join(RAIZ, "CHECKLIST-GLOBAL.md")


def main():
    with io.open(GLOBAL, "r", encoding="utf-8", newline="") as f:
        t = f.read()
    NCOL = 11
    faltan, sobran, sin_pipe_final = [], [], []
    for i, l in enumerate(t.split("\n"), 1):
        s = l.strip()
        if not s.startswith("|"):
            continue
        # CONVENCION A (la de partir_filas): quita el primero si vacio y el
        # ULTIMO solo si esta vacio -> respeta las filas que NO terminan en '|'.
        partes = s.split("|")
        if partes and partes[0].strip() == "":
            partes = partes[1:]
        if partes and partes[-1].strip() == "":
            partes = partes[:-1]
        c = [x.strip() for x in partes]
        if not c or not re.match(r"^\d{1,3}$", c[0]):
            continue
        n = len(c)
        if n == NCOL:
            continue
        rec = (i, n, c)
        (faltan if n < NCOL else sobran).append(rec)
        if not s.endswith("|"):
            sin_pipe_final.append(i)

    print("A) FALTAN celdas (%d en vez de %d): %d filas" % (NCOL - 1, NCOL, len(faltan)))
    for i, n, c in faltan:
        # que celdas hay a partir de 'Recom' (indice 6)
        print("   L%-5d %2d celdas  Recom=%r  Agente=%r  Act=%r"
              % (i, n,
                 c[6] if len(c) > 6 else "<NO EXISTE>",
                 c[7] if len(c) > 7 else "<NO EXISTE>",
                 c[8] if len(c) > 8 else "<NO EXISTE>"))
    print()
    print("B) SOBRAN celdas (pipes sin escapar en la columna Notas): %d filas" % len(sobran))
    for i, n, c in sobran[:25]:
        extra = n - NCOL
        # las 'extra' estan a partir del indice 9 (Notas)
        dentro = c[9:] if len(c) > 9 else []
        print("   L%-5d %2d celdas (+%d)  Recom=%r  Agente=%r  Act=%r"
              % (i, n, extra,
                 c[6] if len(c) > 6 else "?",
                 c[7] if len(c) > 7 else "?",
                 c[8] if len(c) > 8 else "?"))
        if dentro:
            print("        celdas extra dentro de Notas: %s" % (" | ".join(dentro)[:110]))
    if len(sobran) > 25:
        print("   ... y %d mas" % (len(sobran) - 25))
    print()
    print("Ademas: %d filas mal formadas que NI SIQUIERA terminan en '|' "
          "(no se pueden parsear igual):" % len(sin_pipe_final))
    print("   lineas: %s" % sin_pipe_final)
    print()
    print("TOTAL: %d filas mal formadas (%d faltan + %d sobran)"
          % (len(faltan) + len(sobran), len(faltan), len(sobran)))


if __name__ == "__main__":
    main()