#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
#
# M151-Control-Final — space-bunny-alpha / Kilo Code — 2026-10-04 — Log 1289
#
# `verificar_puntos.py` — Valida que el acta de Control Final tenga los 26
# puntos con evidencia y estado coherente.
#
# Ref: DOCUMENTACION/151-Control-Final/plan-actual/03-Diseno.md
#   §2 mapa de los 26 puntos -> evidencia requerida
#   §4 plantilla del acta (JSON) y semaforizador
#   §6 que NO se hace en Control Final
# Ref: 04-Codigo.md §1 "scripts/auditoria/verificar_puntos.py | Valida que los
#   26 puntos tengan evidencia y estado"
#
# REGLAS que implementa (todas del 05-Checklist.md de M151):
#   - "Definir evidencia obligatoria para cada estado (sin evidencia = no aprobado)"
#   - "Definir plan de accion con dueno y fecha para cada ⚠/✖"
#   - "Definir 0 puntos en ✖ al cierre (requisito)"
#   - "Definir acta firmada por produccion y QA"
#   - "Definir verificacion automatica: puntos sin evidencia = alerta"
#
# CONVENCIONES (heredadas de verificar_checklist.py, BUG-075):
#   exit 0 = acta valida
#   exit 1 = mire y hay alertas
#   exit 3 = DETECTOR CIEGO (no pude leer el acta). NO es "0 problemas".
#   La distincion 1 vs 3 es obligatoria: un parser que no itera devuelve
#   "sin alertas", que es indistinguible de "no hay datos" (familia trampa 91/100).
#
# Uso:
#   python scripts/auditoria/verificar_puntos.py --acta <ruta.json>
#   python scripts/auditoria/verificar_puntos.py --acta <ruta.json> --cierre
#   python scripts/auditoria/verificar_puntos.py --plantilla     # emite el esqueleto
#
# AGENTS.md 28: UTF-8 sin BOM. Este archivo se escribe con LF.

import argparse
import io
import json
import sys
from pathlib import Path

if sys.stdout and hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

RAIZ = Path(__file__).resolve().parent.parent.parent
RUTA_ACTA_DEFECTO = RAIZ / "DOCUMENTACION" / "151-Control-Final" / "plan-actual" / "acta-control-final.json"

# ---------------------------------------------------------------------------
# Los 26 puntos de control (03-Diseno.md §2). Cada uno con la evidencia que
# el diseno declara obligatoria. El validator compara el acta contra esta
# lista: si el diseno agrega un punto, el validator avisa (no lo ignora).
# ---------------------------------------------------------------------------
PUNTOS = [
    (1, "Identidad propia", "Propuesta de juego (M147) + benchmark vs 3 pares"),
    (2, "Bucle principal divertido", "Encuestas diversi\u00f3n >= 4/5 + 3 sesiones observadas"),
    (3, "Construir divertido", "Encuesta + sesi\u00f3n de construcci\u00f3n 30 min"),
    (4, "Explorar divertido", "Encuesta + mapa de descubrimientos (M28/M50)"),
    (5, "Puzzles divertidos", "Encuesta + tasa de rendici\u00f3n < 15% (M93)"),
    (6, "NPC interesante", "Encuesta + gui\u00f3n revisado (M21/M23)"),
    (7, "Econom\u00eda funciona", "Simulaci\u00f3n M93: sin quiebres en 40 h"),
    (8, "Progresi\u00f3n funciona", "Matriz de sellos/habilidades verificada (M71)"),
    (9, "Mundo vivo", "Rutinas/eventos sin huecos en 7 d\u00edas (M25/M74)"),
    (10, "Estaciones con prop\u00f3sito", "Efectos estacionales en cultivos/eventos (M33)"),
    (11, "Clima con prop\u00f3sito", "Clima altera gameplay (lluvia/helada) (M32)"),
    (12, "M\u00fasica refuerza zonas", "Playlist por zona auditable (M41) + test auditivo"),
    (13, "Audio refuerza acciones", "Matriz de SFX por interacci\u00f3n (M42/M44)"),
    (14, "Gr\u00e1ficos coherentes", "Gu\u00eda de estilo (M06/M49) + screenshots por zona"),
    (15, "Voxels eficientes", "Presupuesto t\u00e9cnico (M08/M11/M61)"),
    (16, "Guardado confiable", "30 ciclos + 0 reportes de save (M59/M60/M66)"),
    (17, "Rendimiento aceptable", "Telemetr\u00eda 72 h: fps p99, crash < 0.5%"),
    (18, "Accesibilidad contemplada", "Checklist M58 100% verificado"),
    (19, "Localizaci\u00f3n contemplada", "Checklist M87 100% verificado"),
    (20, "Contratos documentados", "\u00cdndice de contratos (ubicaci\u00f3n + estado)"),
    (21, "Licencias documentadas", "\u00cdndice de licencias de assets/herramientas"),
    (22, "PI documentada", "Registros de marca/nombre/logo archivados"),
    (23, "P\u00e1gina de tienda preparada", "Store publicada y verificada (M149)"),
    (24, "Soporte preparado", "Canales activos + SLA operativo"),
    (25, "Actualizaci\u00f3n preparada", "Pipeline hotfix/patcheo probado (M142/M143)"),
    (26, "Plan post-lanzamiento", "Hoja de ruta M144 aprobada"),
]

# Los estados del semaforo.
#
# PENDIENTE (agregado 2026-10-05 por decision del fundador, canal 12): el dato
# que exige el punto NO EXISTE todavia (telemetria 72 h de M143/M104, CSV de
# encuestas, criterios de S1). No es un fallo del producto: es un hueco de
# evidencia. Se distingue de WARN a proposito, porque un WARN dice «el producto
# tiene un problema» y un PENDIENTE dice «todavia no puedo medirlo».
#
# Se_iso es lo que evita que PENDIENTE sea unvertedero: no exime de la
# evidencia (la que hay, parcial), y EXIGE plan de accion con dueno y fecha
# igual que WARN. Si no, cualquier punto sin datos se declara PENDIENTE y el
# acta cierra en verde sin haber medido nada — que es la trampa 81/100.
ESTADOS = {
    "\u2714": "aprobado",
    "\u26a0": "con accion",
    "\u2716": "bloqueante",
    "PENDIENTE": "sin dato todavia",
}

# Estados que exigen planAccion con dueo/fecha/desc.
ESTADOS_CON_PLAN = {"\u26a0", "\u2716", "PENDIENTE"}

# Estados que NO pueden aparecer en un acta de cierre.
ESTADOS_BLOQUEANTES_CIERRE = {"\u2716"}

# Firmas exigidas al cierre (05-Checklist.md: "Definir acta firmada por produccion y QA").
FIRMAS_EXIGIDAS = {"produccion", "qa"}


class DetectorCiegoError(RuntimeError):
    """No pude leer el acta. NO es «0 problemas»: es «no mire»."""


def normalizar_estado(bruto):
    """Normaliza el estado del semaforo. Acepta el glifo o su sinonimo ASCII.

    Un acta puede venir de un editor que no escribe los simbolos, asi que se
    aceptan las 3 formas ASCII (OK/WARN/BLOCK) ademas de los 3 glifos.
    `PENDIENTE` (y su alias `SIN-DATO`) se aceptan tal cual, en cualquier caja.
    """
    if bruto is None:
        return None
    s = str(bruto).strip()
    if s in ESTADOS:
        return s
    alt = {"OK": "\u2714", "WARN": "\u26a0", "BLOCK": "\u2716"}
    if s.upper() in alt:
        return alt[s.upper()]
    if s.upper().replace("-", "").replace("_", "") in ("PENDIENTE", "SINDATO"):
        return "PENDIENTE"
    return None


def verificar_puntos(acta, cierre: bool = False):
    """Devuelve una lista de alertas del acta.

    Parametros
    ----------
    acta : dict
        Acta ya parseada (JSON object).
    cierre : bool
        Si True, aplica los requisitos de CIERRE del checklist, que no aplican
        a un acta en borrador: 0 puntos en ✖ y firmas de produccion + QA.
    """
    alertas = []

    puntos = acta.get("puntos")
    if not isinstance(puntos, list) or not puntos:
        return ["El acta no tiene la clave 'puntos' como lista no vacia"]

    por_id = {}
    for i, p in enumerate(puntos):
        if not isinstance(p, dict):
            alertas.append(f"puntos[{i}] no es un objeto")
            continue
        pid = p.get("id")
        if pid is None:
            alertas.append(f"puntos[{i}] sin 'id'")
            continue
        if not isinstance(pid, int):
            alertas.append(f"punto id={pid!r}: 'id' no es entero")
            continue
        if pid in por_id:
            alertas.append(f"punto id={pid}: DUPLICADO en el acta")
        por_id[pid] = p

    # 1) Los 26 puntos deben estar, y solo ellos.
    esperados = {pid for pid, _n, _e in PUNTOS}
    for pid in sorted(esperados - set(por_id)):
        alertas.append(f"punto {pid} FALTA en el acta")
    for pid in sorted(set(por_id) - esperados):
        alertas.append(
            f"punto {pid} NO ESTA en el diseno (03-Diseno.md §2 define 1..26): "
            "el diseno cambio y el validador esta desactualizado"
        )

    # 2) Por cada punto presente: estado valido, evidencia, plan de accion.
    for pid in sorted(set(por_id) & esperados):
        p = por_id[pid]
        nombre = next((n for i, n, _e in PUNTOS if i == pid), "?")
        estado = normalizar_estado(p.get("estado"))
        evidencia = p.get("evidencia")
        plan = p.get("planAccion")

        if estado is None:
            alertas.append(
                f"punto {pid} ({nombre}): estado {p.get('estado')!r} no es "
                f"ninguno de {sorted(ESTADOS)} (ni OK/WARN/BLOCK)"
            )
            continue

        # "sin evidencia = no aprobado", con una excepcion para PENDIENTE: si
        # el dato no existe, no hay evidencia que adjuntar, pero el punto debe
        # decir POR QUE y QUIEN lo va a traer (exigido mas abajo).
        vacio = evidencia is None or (isinstance(evidencia, str) and not evidencia.strip())
        if vacio and estado != "PENDIENTE":
            alertas.append(f"punto {pid} ({nombre}): SIN EVIDENCIA (estado {estado})")

        # "plan de accion con dueno y fecha para cada WARN/BLOCK/PENDIENTE"
        if estado in ESTADOS_CON_PLAN:
            if not isinstance(plan, dict):
                alertas.append(
                    f"punto {pid} ({nombre}): estado {estado} exige planAccion "
                    "con dueno/fecha/desc; falta o no es objeto"
                )
            else:
                for campo in ("due\u00f1o", "fecha", "desc"):
                    v = plan.get(campo)
                    if v is None or (isinstance(v, str) and not v.strip()):
                        alertas.append(
                            f"punto {pid} ({nombre}): planAccion sin '{campo}'"
                        )

    # 3) Requisitos de CIERRE (no aplican a un borrador).
    if cierre:
        for pid in sorted(set(por_id) & esperados):
            if normalizar_estado(por_id[pid].get("estado")) in ESTADOS_BLOQUEANTES_CIERRE:
                alertas.append(
                    f"punto {pid}: en \u2716 y el cierre exige 0 puntos bloqueantes"
                )
        # Un PENDIENTE sin dueno NO puede quedar abierto al cierre: seria un
        # limbo con fecha deierre pero sin responsable.
        for pid in sorted(set(por_id) & esperados):
            if normalizar_estado(por_id[pid].get("estado")) == "PENDIENTE":
                plan = por_id[pid].get("planAccion")
                dueno = plan.get("due\u00f1o") if isinstance(plan, dict) else None
                if not dueno or not str(dueno).strip():
                    alertas.append(
                        f"punto {pid}: PENDIENTE al cierre sin dueno — "
                        "quien lo mide y cuando"
                    )
        firmas = acta.get("firmas")
        if not isinstance(firmas, list):
            alertas.append("el acta no tiene 'firmas' como lista")
        else:
            normalizadas = {str(f).strip().lower() for f in firmas}
            for req in sorted(FIRMAS_EXIGIDAS - normalizadas):
                alertas.append(f"falta la firma de '{req}' en el acta de cierre")

    return alertas


def cargar_acta(ruta: Path):
    """Carga el acta con fail-fast. Un `return {}` seria indistinguible de
    «no hay datos», asi que todo fallo de lectura levanta DetectorCiegoError."""
    if not ruta.exists():
        raise DetectorCiegoError(f"el acta no existe: {ruta}")
    if ruta.stat().st_size == 0:
        raise DetectorCiegoError(f"el acta esta vacia (0 bytes): {ruta}")
    texto = ruta.read_text(encoding="utf-8")
    if not texto.strip():
        raise DetectorCiegoError(f"el acta solo tiene espacios: {ruta}")
    try:
        data = json.loads(texto)
    except json.JSONDecodeError as e:
        raise DetectorCiegoError(f"el acta no es JSON valido ({ruta}): {e}") from e
    if not isinstance(data, dict):
        raise DetectorCiegoError(
            f"la raiz del acta deberia ser un objeto JSON, es {type(data).__name__} ({ruta})"
        )
    return data


def plantilla_acta():
    """Emite el esqueleto del acta con los 26 puntos (03-Diseno.md §4)."""
    return {
        "acta": "CONTROL-FINAL-1.0",
        "fecha": "AAAA-MM-DD",
        "juego": "Isla Ancestral",
        "puntos": [
            {
                "id": pid,
                "nombre": nombre,
                "estado": "\u2714",
                "evidencia": "",
                "planAccion": None,
            }
            for pid, nombre, _ev in PUNTOS
        ],
        "firmas": [],
    }


def main():
    ap = argparse.ArgumentParser(
        description="M151: valida el acta de Control Final (26 puntos, evidencia, semaforo, firmas)."
    )
    ap.add_argument("--acta", type=Path, default=RUTA_ACTA_DEFECTO,
                    help="Ruta al acta .json (default: plan-actual/acta-control-final.json).")
    ap.add_argument("--cierre", action="store_true",
                    help="Aplica los requisitos de cierre: 0 puntos en ✖ y firmas produccion+QA.")
    ap.add_argument("--plantilla", action="store_true",
                    help="Emite el esqueleto del acta con los 26 puntos y sale.")
    args = ap.parse_args()

    if args.plantilla:
        print(json.dumps(plantilla_acta(), ensure_ascii=False, indent=2))
        return 0

    try:
        acta = cargar_acta(args.acta)
    except DetectorCiegoError as e:
        print("=" * 68)
        print("DETECTOR CIEGO (exit 3): no pude leer el acta.")
        print(f"   {e}")
        print()
        print("Esto NO es «acta valida»: es «no mire». Genera una con --plantilla")
        print("y completala, o revise la ruta con --acta.")
        return 3

    alertas = verificar_puntos(acta, cierre=args.cierre)

    print("=" * 68)
    print("M151 CONTROL FINAL — verificacion del acta")
    print("=" * 68)
    print(f"acta: {args.acta}")
    modo = "CIERRE" if args.cierre else "BORRADOR"
    n_puntos = len(acta.get("puntos") or [])
    print(f"modo: {modo} · puntos en el acta: {n_puntos}/{len(PUNTOS)}")
    print()

    if alertas:
        print(f"SE ENCONTRARON {len(alertas)} ALERTAS:")
        for a in alertas:
            print(f"   - {a}")
        print()
        if not args.cierre:
            print("(recorda: --cierre exige ademas 0 puntos en ✖ y las firmas)")
        return 1

    extra = " (incluye requisitos de cierre)" if args.cierre else ""
    print(f"ACTA VALIDA: los {len(PUNTOS)} puntos tienen estado y evidencia{extra}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())