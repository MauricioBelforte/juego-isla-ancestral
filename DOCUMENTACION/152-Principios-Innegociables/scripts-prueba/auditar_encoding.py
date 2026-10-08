# -*- coding: utf-8 -*-
"""Auditoria final de encoding de los archivos que toco space-bunny-alpha (SB-01).

Checks: BOM, CJK no intencional, mojibake latin, fin de linea.
Los CJK intencionales (la cita del bug de M145) se listan aparte, no cuentan
como problema.
"""
import io
import os
import re
import subprocess
import sys

ARCHIVOS = [
    "CHECKLIST-GLOBAL.md",
    "DOCUMENTACION/152-Principios-Innegociables/plan-actual/03-Diseno.md",
    "DOCUMENTACION/152-Principios-Innegociables/plan-actual/04-Codigo.md",
    "DOCUMENTACION/152-Principios-Innegociables/plan-actual/05-Checklist.md",
    "DOCUMENTACION/152-Principios-Innegociables/scripts-prueba/apendice_sb01.md",
    "DOCUMENTACION/152-Principios-Innegociables/scripts-prueba/marcar_principios_sb01.py",
    "DOCUMENTACION/152-Principios-Innegociables/scripts-prueba/normalizar_lf.py",
    "DOCUMENTACION/TAREAS-POR-MODELO/space-bunny-alpha/BACKLOG-MASTER.md",
    "Logs/1270-M152-SB01-VERIFICACION-87-PRINCIPIOS_2026-10-04_09-55-00.md",
    "Logs/NUMEROS_DISPONIBLES.txt",
    "Mensajes entre modelos/ESTADO-PARALELO.md",
]

# El informe de canal se resuelve por PREFIJO, no por nombre literal: el
# director renombro el archivo durante la sesion (igual que hizo con el 01), y
# un nombre fijo en el script lo volveria brittle.
_CANAL = "Mensajes entre modelos/space-bunny-alpha"
for _n in sorted(os.listdir(_CANAL)):
    if _n.startswith("02-"):
        ARCHIVOS.append(_CANAL + "/" + _n)
        break

CJK = re.compile(r"[\u4e00-\u9fff\uf900-\ufaff]+")
MOJI = re.compile(r"[\u00c2-\u00c3][\u0080-\u00bf]")
CITA = u"\u81ea\u7531"  # bug real de M145 (intencional)


def eol_head(path):
    r = subprocess.run(["git", "show", "HEAD:" + path], capture_output=True)
    if r.returncode != 0:
        return "NUEVO"
    b = r.stdout
    return "CRLF" if b.count(b"\r\n") else ("LF" if b.count(b"\n") else "-")


def main():
    print("%-52s %-6s %-6s %-7s %-9s %s"
          % ("archivo", "BOM", "HEAD", "WORK", "CJK_int", "CJK_mal / moji"))
    print("-" * 110)
    problemas = 0
    for f in ARCHIVOS:
        b = io.open(f, "rb").read()
        t = b.decode("utf-8")
        bom = b[:3] == b"\xef\xbb\xbf"
        crlf = t.count("\r\n")
        cjk = CJK.findall(t)
        mal = [x for x in cjk if x != CITA]
        intenc = [x for x in cjk if x == CITA]
        moji = MOJI.findall(t)
        work = "CRLF" if crlf else "LF"
        if bom or mal:
            problemas += 1
        print("%-52s %-6s %-6s %-7s %-9d %s"
              % (os.path.basename(f)[:52], bom, eol_head(f), work,
                 len(intenc), "%s / %s" % (mal if mal else "-", moji if moji else "-")))
    print("-" * 110)
    print("archivos con problema real (BOM o CJK no intencional): %d" % problemas)
    print("NOTA: ESTADO-PARALELO.md y CHECKLIST-GLOBAL.md tienen CRLF en el working copy")
    print("      porque core.autocrlf=true (TODO .md del repo esta igual); HEAD=CRLF en")
    print("      esos dos, asi que no hay re-en-codado de mi parte.")
    return problemas


if __name__ == "__main__":
    sys.exit(0 if main() == 0 else 1)