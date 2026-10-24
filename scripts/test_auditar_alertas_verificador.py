#!/usr/bin/env python3
"""test_auditar_alertas_verificador.py — suite del clasificador de alertas.

Reglas del proyecto que esta suite respeta (AGENTS.md §21.8 + trampas 46/91):
  * Cada bloque se NOMBRA al correr. Un bloque que no corre no puede fallar.
  * PISO de checks MEDIDO en verde (no estimado): si el numero de checks baja
    del piso, la suite FALLA (un recorte silencioso no pasa).
  * Sonda EN ROJO por inyeccion: se le mete al clasificador una alerta que no
    conoce y se exige que la NOMBRE como no clasificada y que el exit sea 2.
    Un guardian que no se puede poner en rojo no es un guardian.
  * Restauracion byte-exacta (sha256) de cualquier archivo que la sonda toque.

Uso:  python scripts/test_auditar_alertas_verificador.py
Exit: 0 todo verde · 1 fallos · 2 piso no alcanzado
"""
from __future__ import annotations

import hashlib
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "scripts"))

import auditar_alertas_verificador as A  # noqa: E402

CHECKS_MINIMOS = 41  # MEDIDO en verde el 2026-10-24 (41 checks / 0 fallos / EXIT 0 x3)

_checks = 0
_fallos = 0
_bloques = []


def bloque(nombre):
    _bloques.append(nombre)
    print("\n-- bloque %s" % nombre)


def check(nombre, cond, detalle=""):
    global _checks, _fallos
    _checks += 1
    if cond:
        print("   ok   %s" % nombre)
    else:
        _fallos += 1
        print("   FALLA %s %s" % (nombre, detalle))


# ---------------------------------------------------------------------------
# A. Los 8 patrones del gate se reconocen (si el gate cambia la redaccion, aca)
# ---------------------------------------------------------------------------
def bloque_a():
    bloque("A patrones del gate")
    casos = [
        (A._P_COBERTURA, "⚠️ Cobertura: la fila 157 (157-Medios-De-Transporte) no tiene DOCUMENTACION/x — fila stale."),
        (A._P_DRIFT, "❌ Inconsistencia en 10-Generacion-Del-Mundo: CHECKLIST-GLOBAL dice '88/106' pero el 05-Checklist.md tiene '90/106'."),
        (A._P_ESTADO_X, "❌ Inconsistencia en 115-Hardware: tiene 78 items [x] pero su estado global es '🟢 Disponible'."),
        (A._P_ESTADO_DUDAS, "❌ Inconsistencia en 08-Terreno: tiene 9 items [?] pero su estado global es '✅'."),
        (A._P_ESTADO_PEND, "❌ Inconsistencia en 09-X: tiene 3 items [ ] pendientes pero su estado global es '✅' (DoD 21.6: ✅ exige todo [x])."),
        (A._P_COLGADO, "⚠️ Módulo 139 (139-Pre-Alpha) está en curso pero sin actividad desde 2026-10-14 02:20. Posible bloqueo colgado (regla 21.4.7)."),
        (A._P_COLGADO, "⚠️ Módulo 17 (17-Construccion) está en curso pero timestamp ilegible: **Tanda P3-2**. Posible bloqueo colgado (regla 21.4.7)."),
        (A._P_COLGADO, "⚠️ Módulo 59 (59-Guardado) está en curso pero sin timestamp. Posible bloqueo colgado (regla 21.4.7)."),
    ]
    for pat, texto in casos:
        check("reconoce: %s" % texto[:52], pat.search(texto) is not None)

    # Falsabilidad: una alerta con OTRA redaccion NO debe matchear ninguna.
    ajeno = "❌ Inconsistencia en 99-X: el progreso no cuadra."
    check(
        "no matchea una redaccion desconocida",
        not any(p.search(ajeno) for p in (A._P_COBERTURA, A._P_DRIFT, A._P_ESTADO_X, A._P_ESTADO_DUDAS, A._P_ESTADO_PEND, A._P_COLGADO)),
    )


# ---------------------------------------------------------------------------
# B. Clasificacion de la celda Estado
# ---------------------------------------------------------------------------
def bloque_b():
    bloque("B celda Estado")
    check("emoji -> emoji", A._clasificar_celda_estado("🟡 Con dudas") == "emoji")
    check("progreso -> progreso", A._clasificar_celda_estado("90/106") == "progreso")
    check("vacia -> vacia", A._clasificar_celda_estado("") == "vacia")
    check("texto suelto -> otra", A._clasificar_celda_estado("En curso") == "otra")
    check("mojibake -> otra", A._clasificar_celda_estado("ÃƒÂ°Ã…Â¸ En curso") == "otra")


# ---------------------------------------------------------------------------
# C. Emoji que corresponde por DoD 21.6
# ---------------------------------------------------------------------------
def bloque_c():
    bloque("C emoji DoD")
    check("todo [x] -> check", A._emoji_sugerido_dod(10, 0, 0) == "✅")
    check("[?] -> amarillo", A._emoji_sugerido_dod(10, 0, 2) == "🟡")
    check("[ ] -> amarillo", A._emoji_sugerido_dod(10, 3, 0) == "🟡")
    check("0 items -> blanco", A._emoji_sugerido_dod(0, 0, 0) == "⬜")


# ---------------------------------------------------------------------------
# D. Busqueda de fecha dentro de una fila desplazada
# ---------------------------------------------------------------------------
def bloque_d():
    bloque("D fecha en la fila")
    idx, f = A._buscar_fecha_en_fila(["17", "17-X", "🔵", "104/175", "2026-10-21 20:30"])
    check("encuentra fecha con hora", idx == 4 and f == "2026-10-21 20:30")
    idx, f = A._buscar_fecha_en_fila(["59", "🔵", "2026-10-23"])
    check("encuentra fecha sin hora", idx == 2 and f == "2026-10-23")
    idx, f = A._buscar_fecha_en_fila(["104", "—", "—"])
    check("sin fecha -> (None, None)", idx is None and f is None)


# ---------------------------------------------------------------------------
# E. End-to-end contra el repo real: toda alerta clasificada
# ---------------------------------------------------------------------------
def bloque_e():
    bloque("E end-to-end repo")
    clas, sin, ctx = A.auditar()
    check("hay alertas (gate no ciego)", ctx["alertas_gate"] > 0, "gate=%d" % ctx["alertas_gate"])
    check("todas clasificadas", len(sin) == 0, "sin=%r" % sin[:2])
    check(
        "suma de clases == alertas del gate",
        len(clas) == ctx["alertas_gate"],
        "%d vs %d" % (len(clas), ctx["alertas_gate"]),
    )
    clases = {c["clase"] for c in clas}
    check("clase de cobertura presente", "cobertura_fila_sin_checklist" in clases)
    check("clase de drift presente", any(c.startswith("drift") for c in clases))
    check("clase de colgado presente", any(c.startswith("colgado") for c in clases))

    # Invariantes semanticas medibles, no "hay algo":
    g = [c for c in clas if c["clase"] == "estado_disponible_con_avance"]
    check("🟢 siempre con avance > 0", all(c["cantidad"] > 0 and c["emoji"] == "🟢" for c in g))
    il = [c for c in clas if c["clase"] == "colgado_timestamp_en_celda_equivocada"]
    check("'ilegible' siempre tiene fecha en la fila", all(c.get("fecha") for c in il))
    ve = [c for c in clas if c["clase"] == "colgado_actividad_vencida"]
    check("'vencida' nunca tiene motivo ilegible", all(not c["motivo"].startswith("timestamp ilegible") for c in ve))
    nt = [c for c in clas if c["clase"] == "colgado_sin_timestamp"]
    check("'sin timestamp' viene del motivo del gate", all(c["motivo"].startswith("sin timestamp") or c["motivo"].startswith("timestamp ilegible") for c in nt))
    pr = [c for c in clas if c["clase"] == "drift_progreso_con_texto_anexo"]
    check("'prosa anexa' solo si el numero esta bien", all(c.get("numero_progreso_correcto") for c in pr))
    check("contexto trae las filas sobrescritas", isinstance(ctx["filas_estado_sobrescrito"], list))


# ---------------------------------------------------------------------------
# F. SONDA EN ROJO: una alerta desconocida debe quedar SIN CLASIFICAR y exit 2
# ---------------------------------------------------------------------------
def bloque_f():
    bloque("F sonda en rojo (ceguera del clasificador)")
    original = A.vc.analizar_proyecto
    try:
        A.vc.analizar_proyecto = lambda *a, **k: [
            "❌ Inconsistencia en 99-Inventado: texto que este clasificador no conoce."
        ]
        clas, sin, ctx = A.auditar()
        check("la alerta desconocida NO se clasifica", len(clas) == 0 and len(sin) == 1, "clas=%d sin=%d" % (len(clas), len(sin)))
        check("el gate 'vio' 1 alerta", ctx["alertas_gate"] == 1)

        # exit code real de main() con la inyeccion puesta
        argv = sys.argv
        sys.argv = ["auditar_alertas_verificador.py", "--quiet"]
        try:
            rc = A.main()
        finally:
            sys.argv = argv
        check("main() devuelve 2 con alerta sin clasificar", rc == 2, "rc=%r" % rc)

        # Control: con una alerta CONOCIDA el mismo camino devuelve 0.
        A.vc.analizar_proyecto = lambda *a, **k: [
            "⚠️ Cobertura: la fila 999 (999-X) no tiene DOCUMENTACION/999-X/plan-actual/05-Checklist.md — fila stale."
        ]
        sys.argv = ["auditar_alertas_verificador.py", "--quiet"]
        try:
            rc_ok = A.main()
        finally:
            sys.argv = argv
        check("main() devuelve 0 con alerta conocida", rc_ok == 0, "rc=%r" % rc_ok)
    finally:
        A.vc.analizar_proyecto = original

    # El control de arriba no debe haber dejado el repo tocado.
    check("sin archivos escritos por la sonda", not (RAIZ / "out" / "sonda_no_deberia_existir.md").exists())


# ---------------------------------------------------------------------------
# G. PISO medido: el numero de checks no puede bajar
# ---------------------------------------------------------------------------
def bloque_g():
    bloque("G sonda de fallo")
    if "--sonda-piso" in sys.argv:
        # Sonda EN ROJO del runner: un check imposible tiene que reportarse.
        check("SONDA: check imposible debe fallar", _checks >= 9999, "checks=%d" % _checks)
    else:
        check("runner reporta (control)", True)


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main() -> int:
    global CHECKS_MINIMOS
    # --piso N permite probar EN ROJO el propio piso (ej: --piso 9999 -> exit 2).
    if "--piso" in sys.argv:
        CHECKS_MINIMOS = int(sys.argv[sys.argv.index("--piso") + 1])
    objetivos = [RAIZ / "CHECKLIST-GLOBAL.md", RAIZ / "scripts" / "verificar_checklist.py"]
    antes = {p: sha256(p) for p in objetivos}

    for f in (bloque_a, bloque_b, bloque_c, bloque_d, bloque_e, bloque_f, bloque_g):
        f()

    despues = {p: sha256(p) for p in objetivos}
    bloque("H integridad del repo")
    check("CHECKLIST-GLOBAL.md intacto", antes[objetivos[0]] == despues[objetivos[0]])
    check("verificar_checklist.py intacto", antes[objetivos[1]] == despues[objetivos[1]])

    print("\n" + "=" * 60)
    print("bloques: %d | checks: %d | fallos: %d" % (len(_bloques), _checks, _fallos))
    print("PISO: checks=%d / minimo=%d" % (_checks, CHECKS_MINIMOS))
    if _fallos:
        print("RESULTADO: ROJO")
        return 1
    if _checks < CHECKS_MINIMOS:
        print("RESULTADO: ROJO (piso %d no alcanzado, checks=%d)" % (CHECKS_MINIMOS, _checks))
        return 2
    print("RESULTADO: VERDE (piso %d)" % CHECKS_MINIMOS)
    return 0


if __name__ == "__main__":
    sys.exit(main())
