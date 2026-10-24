#!/usr/bin/env python3
"""auditar_alertas_verificador.py — clasifica por CAUSA RAIZ las alertas del gate.

Contexto (Log 2166, iter.11 M01): `verificar_checklist.py` publica N alertas
(42 el 2026-10-24) pero NO dice de que familia es cada una. Sin esa
clasificacion el director no puede decidir: 7 de esas 42 son un falso positivo
categorico del propio gate (confunde el eje de RECLAMO con el eje de AVANCE) y
buena parte del resto son sintomas de filas mal formadas, no de progreso real.

Este auditor NO reimplementa el gate: importa `verificar_checklist` y consume
sus alertas. Si el gate cambia su redaccion, este auditor falla en voz alta
(exit 2, "alerta sin clasificar") en vez de devolver una tabla incompleta y
verde. Ese es el guardian anti-falso-verde: toda alerta debe caer en una clase.

Uso:
    python scripts/auditar_alertas_verificador.py
    python scripts/auditar_alertas_verificador.py --md RUTA.md --json RUTA.json
    python scripts/auditar_alertas_verificador.py --horas-limite 24

Exit codes:
    0  todas las alertas clasificadas
    2  hay alertas SIN CLASIFICAR (ceguera del clasificador) -> nombrarlas
    3  el gate no produjo alertas (sospechoso: revisar antes de creer)
"""
from __future__ import annotations

import argparse
import contextlib
import io
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "scripts"))

import verificar_checklist as vc  # noqa: E402

CHECKLIST_GLOBAL = RAIZ / "CHECKLIST-GLOBAL.md"
DOCUMENTACION = RAIZ / "DOCUMENTACION"

# --- clases de causa raiz ---------------------------------------------------
CLASES = {
    "cobertura_fila_sin_checklist": "La fila del GLOBAL no tiene checklist en disco.",
    "drift_estado_sobrescrito": (
        "La celda Estado fue SOBRESCRITA con el progreso: el valor correcto esta "
        "en la fila, en la celda equivocada, y el emoji de estado se perdio."
    ),
    "drift_progreso_obsoleto": (
        "La celda Progreso quedo vieja; el Estado conserva su emoji (drift normal "
        "de quien trabajo el modulo sin actualizar el GLOBAL)."
    ),
    "drift_progreso_con_texto_anexo": (
        "La celda Progreso tiene el NUMERO CORRECTO seguido de prosa: el gate "
        "compara por igualdad de cadena y la marca como drift. No hay drift de "
        "progreso; hay prosa en una celda numerica."
    ),
    "estado_disponible_con_avance": (
        "FALSO POSITIVO CATEGORICO del gate: 🟢 significa 'disponible para "
        "reclamar' (AGENTS.md, leyenda), no 'sin empezar'. Un modulo puede tener "
        "78/104 y seguir disponible para que otro lo reclame."
    ),
    "estado_check_con_trabajo_abierto": (
        "DoD 21.6 real: la fila dice ✅ y el checklist tiene [?] o [ ]. "
        "El que miente es la FILA."
    ),
    "colgado_timestamp_en_celda_equivocada": (
        "La fila esta mal formada: la fecha existe pero cae en otra celda por "
        "desplazamiento posicional. Sintoma estructural, no bloqueo real."
    ),
    "colgado_sin_timestamp": "No hay fecha en ninguna celda de la fila.",
    "colgado_actividad_vencida": "Fecha legible y anterior al limite: bloqueo colgado real.",
}

_PROG_RE = re.compile(r"^\d+/\d+$")
# Progreso con prosa pegada: "63/135 M73 t2 recompensa coleccion (test 9/0)".
_PROG_TEXTO_RE = re.compile(r"^\d+/\d+\s+\S")
_EMOJI_ESTADO = ("✅", "🟡", "🟢", "🔵", "🔴", "⬜")
_FECHA_RE = re.compile(r"^\d{4}-\d{2}-\d{2}(?: \d{2}:\d{2})?$")
_MOJIBAKE_RE = re.compile(r"Ã.|ðŸ|â€|Â.")

# --- patrones de las alertas del gate (una alerta NO clasificada => exit 2) --
_P_COBERTURA = re.compile(r"Cobertura: la fila (\d+) \((.+)\) no tiene")
_P_DRIFT = re.compile(
    r"Inconsistencia en (.+?): CHECKLIST-GLOBAL dice '(.+?)' pero el "
    r"05-Checklist\.md tiene '(.+?)'\."
)
_P_ESTADO_X = re.compile(
    r"Inconsistencia en (.+?): tiene (\d+) items \[x\] pero su estado global es '(.+?)'\."
)
_P_ESTADO_DUDAS = re.compile(
    r"Inconsistencia en (.+?): tiene (\d+) items \[\?\] pero su estado global es '(.+?)'\."
)
_P_ESTADO_PEND = re.compile(
    r"Inconsistencia en (.+?): tiene (\d+) items \[ \] pendientes pero su estado "
    r"global es '(.+?)'"
)
_P_COLGADO = re.compile(
    r"Módulo (\d+) \((.+?)\) está en curso pero (.+?)\. Posible bloqueo colgado"
)


def leer_filas_crudas(archivo: Path):
    """Devuelve (n_columnas_encabezado, {id: dict}) con las celdas SIN normalizar.

    Se lee aparte de `vc.leer_tabla_global` a proposito: para diagnosticar el
    desplazamiento de celdas hace falta el conteo crudo y la posicion exacta,
    cosas que el parser normalizado ya perdio.
    """
    lineas = archivo.read_text(encoding="utf-8").splitlines()
    hdr = next(i for i, l in enumerate(lineas) if l.startswith("| ID |"))
    n_cols = len([c for c in lineas[hdr].strip().strip("|").split("|")])
    filas = {}
    for num, linea in enumerate(lineas[hdr + 2 :], start=hdr + 3):
        if not linea.strip().startswith("|"):
            continue
        celdas = [c.strip() for c in linea.strip().strip("|").split("|")]
        if not celdas or not celdas[0].isdigit():
            continue
        filas[celdas[0]] = {
            "linea": num,
            "celdas": celdas,
            "n": len(celdas),
            "termina_pipe": linea.rstrip().endswith("|"),
            "mojibake": bool(_MOJIBAKE_RE.search(linea)),
            "cruda": linea,
        }
    return n_cols, filas


def _clasificar_celda_estado(celda: str) -> str:
    """'emoji' | 'progreso' | 'vacia' | 'otra'."""
    c = (celda or "").strip()
    if not c:
        return "vacia"
    if c[0] in _EMOJI_ESTADO:
        return "emoji"
    if _PROG_RE.match(c):
        return "progreso"
    return "otra"


def _emoji_sugerido_dod(x: int, pend: int, dudas: int) -> str:
    """Emoji que corresponde por DoD 21.6 al conteo real del checklist.

    Se usa SOLO cuando el estado original se perdio (celda sobrescrita) o para
    contrastar la fila. Es una RECONSTRUCCION por regla, no una restauracion:
    el auditor lo declara asi en el informe.
    """
    if dudas > 0 or pend > 0:
        return "🟡"
    if x > 0:
        return "✅"
    return "⬜"


def _buscar_fecha_en_fila(celdas) -> tuple[int, str] | tuple[None, None]:
    for i, c in enumerate(celdas):
        if _FECHA_RE.match((c or "").strip()):
            return i, c.strip()
    return None, None


def auditar(horas_limite: int = 24):
    """Devuelve (alertas_clasificadas, sin_clasificar, contexto)."""
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        alertas = vc.analizar_proyecto(CHECKLIST_GLOBAL, horas_limite)

    n_cols, filas = leer_filas_crudas(CHECKLIST_GLOBAL)
    filas_norm = vc.leer_tabla_global(CHECKLIST_GLOBAL)

    checklists = {p.parent.parent.name: p for p in DOCUMENTACION.glob("*/plan-actual/05-Checklist.md")}
    conteos = {}
    for nombre, p in checklists.items():
        x, pend, dudas = vc.contar_checklist(p)
        conteos[nombre] = {"x": x, "pend": pend, "dudas": dudas, "total": x + pend + dudas}

    totales_incoh_tuplas = vc.detectar_totales_incoherentes(list(checklists.values()))
    totales_incoh = {n for n, _l, _m, _d in totales_incoh_tuplas}
    _n_esp, problemas, _sin_pipe = vc.analizar_estructura_tabla(CHECKLIST_GLOBAL)
    malformadas = {mid: (num, n, motivo) for num, mid, n, motivo in problemas}

    clasificadas, sin_clasificar = [], []

    def add(clase, **kw):
        d = {"clase": clase, "descripcion": CLASES[clase]}
        d.update(kw)
        clasificadas.append(d)

    for alerta in alertas:
        m = _P_COBERTURA.search(alerta)
        if m:
            add("cobertura_fila_sin_checklist", id=m.group(1), modulo=m.group(2), alerta=alerta)
            continue

        m = _P_DRIFT.search(alerta)
        if m:
            modulo, decl, real = m.group(1), m.group(2), m.group(3)
            mid = modulo.split("-")[0]
            fila = filas.get(mid, {})
            celdas = fila.get("celdas", [])
            clase_estado = _clasificar_celda_estado(celdas[2]) if len(celdas) > 2 else "?"
            progreso_celda = celdas[3] if len(celdas) > 3 else ""
            if _PROG_TEXTO_RE.match(progreso_celda):
                # El numero esta bien; lo que sobra es texto -> el gate compara
                # por igualdad de cadena. No es drift.
                clase = "drift_progreso_con_texto_anexo"
            elif clase_estado == "progreso":
                clase = "drift_estado_sobrescrito"
            else:
                clase = "drift_progreso_obsoleto"
            c = conteos.get(modulo, {})
            add(
                clase,
                id=mid,
                modulo=modulo,
                declarado=decl,
                real_checklist=real,
                estado_celda=celdas[2] if len(celdas) > 2 else "",
                progreso_celda=progreso_celda,
                valor_en_celda_estado_coincide=(
                    len(celdas) > 2 and celdas[2].strip() == real
                ),
                numero_progreso_correcto=progreso_celda.startswith(real + " ")
                or progreso_celda.strip() == real,
                emoji_sugerido_dod=(
                    _emoji_sugerido_dod(c.get("x", 0), c.get("pend", 0), c.get("dudas", 0))
                    if c
                    else "?"
                ),
                totales_incoherente=modulo in totales_incoh,
                fila_linea=fila.get("linea"),
                fila_celdas=fila.get("n"),
                alerta=alerta,
            )
            continue

        # Familia "el estado de la fila no cuadra con el checklist".
        m = None
        for pat in (_P_ESTADO_X, _P_ESTADO_DUDAS, _P_ESTADO_PEND):
            m = pat.search(alerta)
            if m:
                break
        if m:
            modulo, cantidad, estado = m.group(1), m.group(2), m.group(3)
            mid = modulo.split("-")[0]
            emoji = vc.estado_emoji(estado)
            # 🟢/⬜ = eje de RECLAMO; ✅ = eje de AVANCE. Solo el segundo es DoD.
            clase_real = (
                "estado_disponible_con_avance"
                if emoji in ("🟢", "⬜")
                else "estado_check_con_trabajo_abierto"
            )
            add(
                clase_real,
                id=mid,
                modulo=modulo,
                cantidad=int(cantidad),
                estado=estado,
                emoji=emoji,
                alerta=alerta,
            )
            continue

        m = _P_COLGADO.search(alerta)
        if m:
            mid, modulo, motivo = m.group(1), m.group(2), m.group(3)
            fila = filas.get(mid, {})
            idx, fecha = _buscar_fecha_en_fila(fila.get("celdas", []))
            # El motivo MANDA: si el gate dice "sin timestamp", una fecha que
            # aparezca suelta dentro de una nota NO convierte el caso en
            # "actividad vencida" (seria un falso positivo del clasificador).
            if motivo.startswith("timestamp ilegible"):
                clase = (
                    "colgado_timestamp_en_celda_equivocada"
                    if fecha is not None
                    else "colgado_sin_timestamp"
                )
            elif motivo.startswith("sin timestamp"):
                clase = "colgado_sin_timestamp"
            else:
                clase = "colgado_actividad_vencida"
            add(
                clase,
                id=mid,
                modulo=modulo,
                motivo=motivo,
                fecha_en_celda=idx,
                fecha=fecha,
                fila_linea=fila.get("linea"),
                fila_celdas=fila.get("n"),
                alerta=alerta,
            )
            continue

        sin_clasificar.append(alerta)

    ctx = {
        "n_columnas_encabezado": n_cols,
        "filas_tabla": len(filas),
        "checklists": len(checklists),
        "filas_malformadas": len(problemas),
        "filas_malformadas_detalle": sorted(
            ((num, mid, n, motivo) for num, mid, n, motivo in problemas)
        ),
        "checklists_totales_incoherentes": sorted(totales_incoh),
        # OJO: un checklist puede tener MAS DE UN bloque 'Totales:' incoherente.
        # Por eso se publican las dos cifras: modulos (set) y lineas (tuplas).
        "checklists_totales_incoherentes_lineas": len(totales_incoh_tuplas),
        "filas_estado_sobrescrito": sorted(
            mid for mid, f in filas.items()
            if len(f["celdas"]) > 2 and _clasificar_celda_estado(f["celdas"][2]) == "progreso"
        ),
        "filas_mojibake": sorted(mid for mid, f in filas.items() if f["mojibake"]),
        "alertas_gate": len(alertas),
    }
    return clasificadas, sin_clasificar, ctx


def resumen(clasificadas, sin_clasificar, ctx):
    from collections import Counter

    cnt = Counter(c["clase"] for c in clasificadas)
    lineas = []
    lineas.append("=== AUDITORIA DE ALERTAS DEL VERIFICADOR ===")
    lineas.append(
        "gate: %d alertas | clasificadas: %d | sin clasificar: %d"
        % (ctx["alertas_gate"], len(clasificadas), len(sin_clasificar))
    )
    for clase, n in sorted(cnt.items(), key=lambda kv: (-kv[1], kv[0])):
        lineas.append("  %-42s %3d" % (clase, n))
    lineas.append("")
    lineas.append(
        "estructura: %d filas / %d columnas | malformadas: %d | estado sobrescrito: %d | mojibake: %d"
        % (
            ctx["filas_tabla"],
            ctx["n_columnas_encabezado"],
            ctx["filas_malformadas"],
            len(ctx["filas_estado_sobrescrito"]),
            len(ctx["filas_mojibake"]),
        )
    )
    if sin_clasificar:
        lineas.append("")
        lineas.append("SIN CLASIFICAR (ceguera del clasificador):")
        for a in sin_clasificar:
            lineas.append("  ! " + a[:160])
    return "\n".join(lineas)


def a_markdown(clasificadas, sin_clasificar, ctx) -> str:
    from collections import Counter, defaultdict

    cnt = Counter(c["clase"] for c in clasificadas)
    por_clase = defaultdict(list)
    for c in clasificadas:
        por_clase[c["clase"]].append(c)

    out = []
    out.append("# Auditoria de las alertas de `verificar_checklist.py` (clasificacion por causa raiz)")
    out.append("")
    out.append("Generado por `scripts/auditar_alertas_verificador.py`. "
               "El gate NO se modifica: se consume su salida y se clasifica.")
    out.append("")
    out.append("## 1. Totales")
    out.append("")
    out.append("| Metrica | Valor |")
    out.append("|---|---|")
    out.append("| Alertas del gate | %d |" % ctx["alertas_gate"])
    out.append("| Clasificadas | %d |" % len(clasificadas))
    out.append("| Sin clasificar | %d |" % len(sin_clasificar))
    out.append("| Filas de la tabla | %d |" % ctx["filas_tabla"])
    out.append("| Columnas del encabezado | %d |" % ctx["n_columnas_encabezado"])
    out.append("| Filas mal formadas | %d |" % ctx["filas_malformadas"])
    out.append("| Filas con el estado sobrescrito por progreso | %d |" % len(ctx["filas_estado_sobrescrito"]))
    out.append("| Filas con mojibake | %d |" % len(ctx["filas_mojibake"]))
    out.append(
        "| Checklists con `Totales` incoherente | %d modulos / %d lineas |"
        % (len(ctx["checklists_totales_incoherentes"]), ctx["checklists_totales_incoherentes_lineas"])
    )
    out.append("")
    out.append("## 2. Clases")
    out.append("")
    out.append("| Clase | Alertas | Que significa |")
    out.append("|---|---|---|")
    for clase, n in sorted(cnt.items(), key=lambda kv: (-kv[1], kv[0])):
        out.append("| `%s` | %d | %s |" % (clase, n, CLASES[clase]))
    out.append("")
    for clase in sorted(por_clase, key=lambda k: (-len(por_clase[k]), k)):
        out.append("## `%s` — %d" % (clase, len(por_clase[clase])))
        out.append("")
        if clase.startswith("drift"):
            out.append("| id | modulo | GLOBAL dice | checklist real | celda Estado | celda Progreso | valor correcto EN la fila | emoji DoD | Totales del checklist | L fila |")
            out.append("|---|---|---|---|---|---|---|---|---|---|")
            for c in sorted(por_clase[clase], key=lambda c: int(c["id"])):
                out.append(
                    "| %s | %s | %s | %s | `%s` | `%s` | %s | %s | %s | %s |"
                    % (
                        c["id"], c["modulo"], c["declarado"], c["real_checklist"],
                        c.get("estado_celda", ""), c.get("progreso_celda", ""),
                        "si (celda Estado)"
                        if c.get("valor_en_celda_estado_coincide")
                        else ("si (numero, con prosa)" if c.get("numero_progreso_correcto") else "NO"),
                        c.get("emoji_sugerido_dod", "?"),
                        "INCOHERENTE" if c.get("totales_incoherente") else "ok",
                        c.get("fila_linea", "?"),
                    )
                )
        elif clase == "estado_disponible_con_avance":
            out.append("| id | modulo | [x] | estado | emoji |")
            out.append("|---|---|---|---|---|")
            for c in sorted(por_clase[clase], key=lambda c: int(c["id"])):
                out.append("| %s | %s | %s | %s | %s |" % (c["id"], c["modulo"], c["cantidad"], c["estado"], c["emoji"]))
        elif clase == "estado_check_con_trabajo_abierto":
            out.append("| id | modulo | items | estado | emoji |")
            out.append("|---|---|---|---|---|")
            for c in sorted(por_clase[clase], key=lambda c: int(c["id"])):
                out.append("| %s | %s | %s | %s | %s |" % (c["id"], c["modulo"], c["cantidad"], c["estado"], c["emoji"]))
        elif clase.startswith("colgado"):
            out.append("| id | modulo | motivo | fecha hallada | celda | celdas de la fila | L fila |")
            out.append("|---|---|---|---|---|---|---|")
            for c in sorted(por_clase[clase], key=lambda c: int(c["id"])):
                out.append(
                    "| %s | %s | %s | %s | %s | %s | %s |"
                    % (c["id"], c["modulo"], c["motivo"][:90],
                       c.get("fecha") or "-", c.get("fecha_en_celda", "-"),
                       c.get("fila_celdas", "?"), c.get("fila_linea", "?"))
                )
        else:
            out.append("| id | modulo |")
            out.append("|---|---|")
            for c in por_clase[clase]:
                out.append("| %s | %s |" % (c["id"], c["modulo"]))
        out.append("")
    if sin_clasificar:
        out.append("## SIN CLASIFICAR (ceguera del clasificador)")
        out.append("")
        for a in sin_clasificar:
            out.append("- " + a)
        out.append("")
    return "\n".join(out) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description="Clasifica por causa raiz las alertas de verificar_checklist.py")
    ap.add_argument("--horas-limite", type=int, default=24)
    ap.add_argument("--md", type=Path, default=None)
    ap.add_argument("--json", type=Path, default=None)
    ap.add_argument("--quiet", action="store_true")
    args = ap.parse_args()

    clasificadas, sin_clasificar, ctx = auditar(args.horas_limite)

    if not args.quiet:
        print(resumen(clasificadas, sin_clasificar, ctx))

    if args.md:
        args.md.parent.mkdir(parents=True, exist_ok=True)
        args.md.write_text(a_markdown(clasificadas, sin_clasificar, ctx), encoding="utf-8", newline="\n")
        if not args.quiet:
            print("\nmarkdown -> %s" % args.md)

    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(
            json.dumps(
                {"contexto": ctx, "clasificadas": clasificadas, "sin_clasificar": sin_clasificar},
                ensure_ascii=False,
                indent=1,
            ),
            encoding="utf-8",
            newline="\n",
        )
        if not args.quiet:
            print("json -> %s" % args.json)

    if ctx["alertas_gate"] == 0:
        print("\n[ABORTO] el gate no produjo NINGUNA alerta: revisar antes de creer (exit 3)")
        return 3
    if sin_clasificar:
        print("\n[FALLA] %d alertas sin clasificar -> el clasificador es ciego ahi (exit 2)" % len(sin_clasificar))
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
