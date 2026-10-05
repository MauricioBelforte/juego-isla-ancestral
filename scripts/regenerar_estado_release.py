#!/usr/bin/env python3
"""Regenera ``estado_release.json`` con el estado real y medible de cada gate.

Directiva del fundador (2026-10-05, canal 25 del subdirector): los gates sin
dato medible se marcan ``PENDIENTE`` (dueno + fecha) en vez de ``false``, para
que el gate no bloquee por algo que nadie puede medir todavia, pero quede
visible que falta. ``ControlFinalSchema.es_pendiente()`` lo entiende.

Uso desde GitHub Actions::

    python scripts/regenerar_estado_release.py \
        --suite-ok 1 --smoke-ok 1 --ci-gates-ok 1 --backup-ok 1

Los flags binarios reflejan jobs del workflow. Los gates no medibles
(``crash_rate_cero``, ``textos_localizados``) quedan PENDIENTE con dueno/fecha.

Exit codes:
  0 -> JSON regenerado.
  2 -> argumentos invalidos.
  3 -> DETECTOR CIEGO: no se pudo leer 11-BUGS.md y nadie paso --criticos-abiertos.
       Un ``zero_criticos_abiertos`` sin fuente es exactamente la trampa 81/100.
"""

from __future__ import annotations

import argparse
import datetime
import json
import re
import subprocess
import sys
from pathlib import Path

RUTA_BUGS = Path("DOCUMENTACION/11-BUGS.md")
RUTA_SALIDA = Path("game/isla-ancestral/data/control_final/estado_release.json")

_SECCION_TABLA = re.compile(r"^##\s*5\.\s*Tabla Resumen", re.MULTILINE)
_SECCION_SIGUIENTE = re.compile(r"^##\s*6\.\s*Bugs Abiertos", re.MULTILINE)
# El ID rodeado por pipes: la celda ID de la tabla. Sin esto, una mencion de
# "BUG-051" dentro del titulo de otro bug cuenta como registro (falso positivo
# que cazo space-bunny: "critico abierto != mencionado").
_ID_BUG = re.compile(r"\|\s*BUG-(\d+)\s*\|")
_CRITICO = re.compile(r"cr[ií]tic", re.IGNORECASE)
_RESUELTO = re.compile(r"\[\s*x\s*\]", re.IGNORECASE)


def _flag(valor: str | None) -> bool:
    """Convierte un argumento binario a bool. None -> False (no midio)."""
    if valor is None:
        return False
    return valor.strip().lower() in ("1", "true", "yes", "si", "on")


def contar_criticos_abiertos(ruta_bugs: Path) -> tuple[int, list[str], list[str]]:
    """Cuenta bugs criticos NO resueltos en la tabla resumen de 11-BUGS.md.

    Devuelve (cantidad, ids, advertencias). Las advertencias marcan filas
    corruptas (mas de un registro por linea con estados mezclados), donde el
    conteo se inclina a la seguridad: cuenta como abierto.
    """
    texto = ruta_bugs.read_text(encoding="utf-8")
    inicio_tabla = _SECCION_TABLA.search(texto)
    if not inicio_tabla:
        return -1, [], ["no se encontro la seccion 5 (tabla resumen)"]
    fin_tabla = _SECCION_SIGUIENTE.search(texto, inicio_tabla.end())
    tabla = texto[inicio_tabla.end() : (fin_tabla.start() if fin_tabla else len(texto))]
    # Offset de la seccion 5 en lineas (para que las advertencias citen la linea
    # real del archivo, no un offset de caracteres incomprensible).
    linea_offset = texto[: inicio_tabla.end()].count("\n") + 1

    abiertos: list[str] = []
    advertencias: list[str] = []
    for i, linea in enumerate(tabla.splitlines()):
        ids = _ID_BUG.findall(linea)
        if not ids:
            continue
        es_critico = bool(_CRITICO.search(linea))
        resuelto = bool(_RESUELTO.search(linea))
        if es_critico and not resuelto:
            if len(ids) > 1:
                advertencias.append(
                    "L%d: fila corrupta con %d registros (BUG-%s) — cuento como abierto"
                    % (linea_offset + i, len(ids), ", BUG-".join(ids))
                )
            abiertos.extend("BUG-" + i for i in ids)
    return len(abiertos), abiertos, advertencias


def construir_gates(args: argparse.Namespace) -> tuple[dict, list[str]]:
    """Construye el dict de gates + advertencias para el log."""
    advertencias: list[str] = []

    if args.criticos_abiertos is not None:
        n_criticos = args.criticos_abiertos
        fuente = "override --criticos-abiertos"
    else:
        if not args.repo_root:
            raise SystemExit(3)
        ruta_bugs = Path(args.repo_root) / RUTA_BUGS
        if not ruta_bugs.is_file():
            print("::error::DETECTOR CIEGO: no existe %s" % ruta_bugs)
            raise SystemExit(3)
        n_criticos, ids, adv = contar_criticos_abiertos(ruta_bugs)
        advertencias.extend(adv)
        if ids:
            advertencias.append("criticos abiertos: %s" % ", ".join(ids))
        fuente = str(ruta_bugs)
    advertencias.append("zero_criticos_abiertos: fuente=%s n=%d" % (fuente, n_criticos))

    gates: dict = {
        "suite_tests_verde": _flag(args.suite_ok),
        "smoke_aprobado": _flag(args.smoke_ok),
        "zero_criticos_abiertos": n_criticos == 0,
        # Sin dato medible: directiva del fundador (PENDIENTE no bloquea).
        "crash_rate_cero": {
            "estado": "PENDIENTE",
            "duenio": "M143/M104",
            "fecha": args.fecha_pendiente,
            "desc": "Requiere 72 h de telemetria en produccion (M143/M104).",
        },
        "ci_gates_verdes": _flag(args.ci_gates_ok),
        "textos_localizados": {
            "estado": "PENDIENTE",
            "duenio": "M87",
            "fecha": args.fecha_pendiente,
            "desc": "M87 tiene checklist, pero '6 idiomas sin claves rotas' necesita el build.",
        },
        "backup_configurado": _flag(args.backup_ok),
    }
    return gates, advertencias


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Regenera estado_release.json con el estado real de cada gate."
    )
    parser.add_argument("--suite-ok", help="1/0: la suite de tests salio verde")
    parser.add_argument("--smoke-ok", help="1/0: el smoke test aprobo")
    parser.add_argument("--ci-gates-ok", help="1/0: los demas jobs del workflow pasaron")
    parser.add_argument("--backup-ok", help="1/0: el backup esta configurado")
    parser.add_argument(
        "--criticos-abiertos",
        type=int,
        help="Override del conteo de criticos abiertos (no parsea 11-BUGS.md)",
    )
    parser.add_argument("--repo-root", default=".", help="Raiz del repositorio")
    parser.add_argument(
        "--salida",
        default=str(RUTA_SALIDA),
        help="Ruta del JSON a escribir (default: %s)" % RUTA_SALIDA,
    )
    parser.add_argument(
        "--fecha-pendiente",
        default=datetime.date.today().isoformat(),
        help="Fecha que se asigna a los gates PENDIENTE (default: hoy)",
    )
    args = parser.parse_args()

    gates, advertencias = construir_gates(args)

    try:
        commit = subprocess.run(
            ["git", "rev-parse", "--short", "HEAD"],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
    except (subprocess.CalledProcessError, OSError):
        commit = "desconocido"

    documento = {
        "gates": gates,
        "registro": "%s — regenerado por CI (commit %s)"
        % (datetime.datetime.now().isoformat(timespec="minutes"), commit),
    }

    salida = Path(args.salida)
    salida.parent.mkdir(parents=True, exist_ok=True)
    salida.write_text(
        json.dumps(documento, ensure_ascii=False, indent="\t") + "\n",
        encoding="utf-8",
    )

    bloqueantes = [k for k, v in gates.items() if v is False]
    pendientes = [k for k, v in gates.items() if isinstance(v, dict)]
    for a in advertencias:
        print("[estado_release] %s" % a)
    print("[estado_release] escrito: %s" % salida)
    print("[estado_release] bloqueantes: %s" % (", ".join(bloqueantes) or "ninguno"))
    print("[estado_release] pendientes (no bloqueantes): %s" % ", ".join(pendientes))
    return 0


if __name__ == "__main__":
    sys.exit(main())
