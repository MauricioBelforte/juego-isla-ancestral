#!/usr/bin/env python3
"""Realinea las filas mal formadas de CHECKLIST-GLOBAL.md a 11 celdas.

Orden del director (msg 384, punto 3): «Las 40 filas mal formadas: te AUTORIZO
a realinear directamente (una pasada, reporte before/after por fila, sha256 de
control como hiciste)».

REGLAS (declaradas, aplicadas en orden; si una fila no encaja en ninguna se
deja INTACTA y se reporta):

  R1  celda [4] duplicada de [3] (dos x/y seguidos) -> se borra [4].
      Es un progreso viejo que quedo pegado cuando el Estado se sobrescribio.
  R2  mas de 11 celdas -> las celdas [10:] son fragmentos de Notas partidos por
      un `|` sin escapar -> se unen con ` · ` (NO con `\\|`: el parser del gate
      hace split('|') crudo, asi que escaparlo no arregla el conteo; hallazgo
      reportado al director).
  R3  exactamente 10 celdas -> falta la celda *Recom* (7): se inserta `—`.
  R4  9 celdas y la celda [8] contiene el artefacto de re.sub `\\g<1>` /
      `\\g<3>` -> se parte ahi (Agente | Fecha | Notas). El artefacto es un
      reemplazo de regex que se comio los separadores.
  R5  [9] == [7] (Recom copiado en Ultima actividad) -> [9] = `—`.
      Solo se aplica si [9] NO es una fecha.

Uso:
    python scripts/realinear_filas_global.py --dry-run   # no escribe
    python scripts/realinear_filas_global.py --aplicar
"""
import argparse
import hashlib
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
GLOBAL = RAIZ / "CHECKLIST-GLOBAL.md"

N_ESPERADAS = 11
RE_PROGRESO = re.compile(r"^\d+/\d+$")
RE_PROSA = re.compile(r"^(\d+/\d+)\s+(.+)$")
RE_FECHA = re.compile(r"^\d{4}-\d{2}-\d{2}")
RE_AGENTE = re.compile(r"^[\w.\-]*(?:flash|deepseek|agnes|minimax|glm|hy\d|ling|mimo|beam)[\w.\- ]*$",
                       re.IGNORECASE)
# Dependencias validas: ids de modulo y separadores ("53,98,91", "07, 14", "—",
# "M23,M55"). Todo lo que no encaje aca y parezca un agente es una celda
# corrida de lugar (ver R7b).
RE_DEPS = re.compile(r"^[M\d,\s—]+$")
PRIORIDADES = {"Alta", "Media", "Baja", "—"}

# M104 tiene DOS filas (L40 vacia + L41 con datos). Se conserva la rica (L41),
# se borra la vacia (L40) y su Nota se anexa para no perder el dato.
DUPLICADO_A_BORRAR = "104"


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def split_celdas(linea: str):
    """Split de una fila de tabla.

    A diferencia del parser del gate (que descarta UN solo vacio a cada punta),
    aca se descartan TODOS los vacios de los extremos: hay filas del archivo que
    empiezan con `| | |` (dos pipes seguidos) y con un solo descarte el id cae
    en la posicion 1 y la fila queda invisible para el gate. Medido el
    2026-10-24: la fila 104 tiene esa forma, y por eso `verificar_checklist`
    la reportaba como «modulo sin fila» (faltan=1) en vez de leerla.
    """
    partes = linea.strip().split("|")
    while partes and partes[0].strip() == "":
        partes = partes[1:]
    while partes and partes[-1].strip() == "":
        partes = partes[:-1]
    return [p.strip() for p in partes]


def reparar(celdas):
    """Devuelve (celdas_nuevas, lista_de_reglas) o (None, motivo)."""
    c = list(celdas)
    reglas = []
    nota_extra = ""

    # R1: progreso duplicado (dos x/y seguidos)
    if len(c) > N_ESPERADAS and RE_PROGRESO.match(c[3]) and RE_PROGRESO.match(c[4]):
        c.pop(4)
        reglas.append("R1")

    # R1b: celda huerfana con un nombre de agente justo despues del Progreso.
    # El nombre ya vive en Notas («Liberado ... glm-5.3-flash»), asi que la
    # celda se reemplaza por «—»: en las 3 filas medidas (56/75/95) esa celda
    # ocupa el lugar de la *Prioridad* que falta, y el agente real esta en la
    # columna *Agente actual*. No se pierde informacion.
    if (len(c) > N_ESPERADAS and c[4] not in PRIORIDADES
            and RE_AGENTE.match(c[4]) and c[5].isdigit()):
        c[4] = "—"
        reglas.append("R1b")

    # R6: prosa pegada al numero del Progreso -> el numero se queda en la
    # celda y la prosa se mueve a Notas (no se pierde).
    if not RE_PROGRESO.match(c[3]):
        m = RE_PROSA.match(c[3])
        if m:
            c[3] = m.group(1)
            nota_extra = m.group(2).strip()
            reglas.append("R6")

    # R4: artefacto de re.sub
    if len(c) == 9 and ("\\g<" in c[8]):
        trozos = re.split(r"\\g<\d+>", c[8])
        trozos = [t.strip() for t in trozos if t.strip()]
        if len(trozos) == 3:
            c = c[:8] + trozos
            reglas.append("R4")

    # R3: falta Recom
    if len(c) == 10:
        c.insert(7, "—")
        reglas.append("R3")

    # R2: fragmentos de Notas partidos
    if len(c) > N_ESPERADAS:
        c = c[:10] + [" · ".join(c[10:])]
        reglas.append("R2")

    if nota_extra:
        c[10] = nota_extra + " · " + c[10]

    # R5: Recom copiado en Ultima actividad
    if len(c) == N_ESPERADAS and c[9] == c[7] and not RE_FECHA.match(c[9]):
        c[9] = "—"
        reglas.append("R5")

    # R7: la FECHA esta en la columna *Agente actual* (8) y *Ultima actividad*
    # (9) tiene una nota o esta vacia -> falta la celda Agente actual. Se
    # inserta vacia: la fecha corre a su columna y no se inventa ningun agente.
    # Medido el 2026-10-24: 9 filas (115, 127, 138, 30, 32, 41, 48, 49, 59).
    # De esas, el gate solo veia 3 (41, 49, 59) porque el resto no es 🔵.
    if (len(c) == N_ESPERADAS and RE_FECHA.match(c[8])
            and not RE_FECHA.match(c[9])):
        agente_huerfano = ""
        # R7b: si *Dependencias* (6) no es una lista de ids sino un nombre de
        # agente, ese nombre ES el Agente actual que se corrio de lugar. Se
        # MUEVE (no se copia) y Dependencias queda en '—'.
        if not RE_DEPS.match(c[6]) and RE_AGENTE.match(c[6]):
            agente_huerfano = c[6]
            c[6] = "—"
            reglas.append("R7b")
        c.insert(8, agente_huerfano)
        reglas.append("R7")
        if len(c) > N_ESPERADAS:
            c = c[:10] + [" · ".join(x for x in c[10:] if x)]

    if len(c) != N_ESPERADAS:
        return None, "quedaron %d celdas" % len(c)
    # validacion de forma: Progreso numerico y Prioridad valida
    if not RE_PROGRESO.match(c[3]):
        return None, "Progreso no numerico: %r" % c[3]
    if c[4] not in PRIORIDADES:
        return None, "Prioridad inesperada: %r" % c[4]
    return c, reglas


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--aplicar", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    if not (args.aplicar or args.dry_run):
        ap.error("elegi --dry-run o --aplicar")

    texto = GLOBAL.read_text(encoding="utf-8")
    lineas = texto.split("\n")
    idx_enc = next(i for i, l in enumerate(lineas)
                   if l.strip().startswith("|") and l.strip().split("|")[1].strip() == "ID")

    antes = sha256(GLOBAL)
    print("sha256 ANTES: %s" % antes)
    print("lineas: %d | EOL: %s" % (len(lineas), "CRLF" if "\r\n" in texto else "LF"))
    print()

    nuevas = list(lineas)
    reparadas, intactas, borradas = [], [], []

    for i in range(idx_enc + 2, len(lineas)):
        linea = lineas[i]
        if not linea.strip().startswith("|"):
            continue
        celdas = split_celdas(linea)
        if not celdas or not celdas[0].isdigit():
            continue
        mid = celdas[0]
        # fila duplicada vacia de M104
        if mid == DUPLICADO_A_BORRAR and len(celdas) == N_ESPERADAS and all(
                x in ("—", "") for x in celdas[4:10]):
            borradas.append((i + 1, mid, linea.strip()[:120]))
            nuevas[i] = None
            continue
        # Una fila puede tener las 11 celdas y aun asi estar MAL UBICADA: la
        # fecha en *Agente actual* (8) y prosa en *Ultima actividad* (9). Esas
        # se procesan igual (R7/R7b); el resto de las de 11 celdas se saltea.
        mal_ubicada = (len(celdas) == N_ESPERADAS
                       and RE_FECHA.match(celdas[8])
                       and not RE_FECHA.match(celdas[9]))
        if len(celdas) == N_ESPERADAS and not mal_ubicada:
            continue
        res, reglas = reparar(celdas)
        if res is None:
            intactas.append((i + 1, mid, len(celdas), reglas))
            continue
        nuevas[i] = "| " + " | ".join(res) + " |"
        reparadas.append((i + 1, mid, len(celdas), len(res), reglas,
                          " / ".join(x[:38] for x in celdas[:5]),
                          " / ".join(x[:38] for x in res[:5])))

    # anexar la Nota de la fila borrada a la fila que queda
    if borradas:
        nota_vieja = borradas[0][2]
        # el ultimo campo de la fila borrada es su Notas
        celda_nota = split_celdas(lineas[borradas[0][0] - 1])[-1]
        for i in range(idx_enc + 2, len(lineas)):
            if nuevas[i] and nuevas[i].startswith("| %s |" % DUPLICADO_A_BORRAR):
                c = split_celdas(nuevas[i])
                c[10] = c[10] + " · " + celda_nota
                nuevas[i] = "| " + " | ".join(c) + " |"
                break

    print("FILAS REPARADAS: %d" % len(reparadas))
    for ln, mid, n0, n1, reglas, a, b in reparadas:
        print("  L%-4d M%-4s %2d->%2d [%s]" % (ln, mid, n0, n1, "+".join(reglas)))
        print("        antes: %s" % a)
        print("        ahora: %s" % b)
    print()
    print("FILAS BORRADAS (duplicado vacio): %d" % len(borradas))
    for ln, mid, txt in borradas:
        print("  L%-4d M%-4s %s" % (ln, mid, txt))
    print()
    print("FILAS INTACTAS (no encajan en ninguna regla): %d" % len(intactas))
    for ln, mid, n, motivo in intactas:
        print("  L%-4d M%-4s n=%d -> %s" % (ln, mid, n, motivo))

    salida = "\n".join(l for l in nuevas if l is not None)
    if args.aplicar:
        GLOBAL.write_text(salida, encoding="utf-8", newline="\n")
        print()
        print("sha256 DESPUES: %s" % sha256(GLOBAL))
        print("bytes: %d -> %d" % (len(texto.encode("utf-8")),
                                   len(salida.encode("utf-8"))))
    else:
        print()
        print("[dry-run] no se escribio nada")
    return 0


if __name__ == "__main__":
    sys.exit(main())
