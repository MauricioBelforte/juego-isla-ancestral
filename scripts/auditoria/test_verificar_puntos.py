#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
#
# M151-Control-Final — space-bunny-alpha / Kilo Code — 2026-10-04 — Log 1289
#
# Tests de `scripts/auditoria/verificar_puntos.py`.
#
# Suite AUTOCONTENIDA a proposito: `scripts/test_scripts.py` es de s2 y no lo
# toco (el director lo prohibio explicitamente en SB-05). Estos tests corren
# aparte:
#
#   python scripts/auditoria/test_verificar_puntos.py
#
# Los 4 casos que el 04-Codigo.md §4 exige explicitamente:
#   - `verificar_puntos` con acta incompleta -> detecta puntos sin evidencia
#   - `importar_telemetria` con datos de prueba -> umbrales correctos  (NO implementado aun: [M] pendiente)
#   - `importar_encuestas` con CSV mal formado -> error claro, sin crash (NO implementado aun: [M] pendiente)
#   - `generar_acta` con ⚠ -> incluye dueno y fecha del plan de accion (NO implementado aun: [M] pendiente)
# Los 3 ultimos quedan como PENDIENTE Honesto, no como falsos verdes.
#
# AGENTS.md 28: UTF-8 sin BOM, LF.

import io
import json
import subprocess
import sys
import tempfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(RAIZ / "scripts" / "auditoria"))

import verificar_puntos as vp  # noqa: E402

PASS = 0
FAIL = 0


def test(nombre, fn):
    global PASS, FAIL
    try:
        fn()
    except Exception as e:  # noqa: BLE001 — el test reporta, no propaga
        FAIL += 1
        print(f"  ❌ FAIL: {nombre} — {type(e).__name__}: {e}")
    else:
        PASS += 1
        print(f"  ✅ PASS: {nombre}")


def acta_valida(**over):
    """Acta minima que NO debe generar alertas (26 puntos, todos ✔ con evidencia)."""
    a = vp.plantilla_acta()
    for p in a["puntos"]:
        p["evidencia"] = "evidencia/prueba.md"
    a["firmas"] = ["produccion", "qa"]
    a.update(over)
    return a


# --- los 4 casos que el 04-Codigo.md exige ---------------------------------
def test_acta_incompleta_detecta_sin_evidencia():
    """Caso 1 del 04-Codigo.md §4: acta incompleta -> detecta puntos sin evidencia."""
    a = vp.plantilla_acta()
    # el punto 7 sin evidencia, y con estado invalido en el 12
    for p in a["puntos"]:
        p["evidencia"] = "evidencia/x.md"
    a["puntos"][6]["evidencia"] = ""
    a["puntos"][11]["estado"] = "inventado"
    alertas = vp.verificar_puntos(a)
    assert any("punto 7" in x and "SIN EVIDENCIA" in x for x in alertas), alertas
    assert any("punto 12" in x and "no es ninguno de" in x for x in alertas), alertas


def test_acta_con_warn_exige_plan_de_accion():
    """Un ⚠ sin planAccion con dueno+fecha es alerta (dueno, fecha y desc)."""
    a = acta_valida()
    a["puntos"][6]["estado"] = "\u26a0"
    alertas = vp.verificar_puntos(a)
    assert any("punto 7" in x and "exige planAccion" in x for x in alertas), alertas

    # con planAccion incompleto (sin dueno) tambien
    a2 = acta_valida()
    a2["puntos"][6]["estado"] = "\u26a0"
    a2["puntos"][6]["planAccion"] = {"fecha": "2026-10-04", "desc": "ajustar"}
    al2 = vp.verificar_puntos(a2)
    assert any("punto 7" in x and "sin 'due\u00f1o'" in x for x in alertas + al2), al2


def test_cierre_exige_cero_bloqueantes_y_firmas():
    """Reglas de cierre del 05-Checklist.md: 0 puntos en ✖ y firmas produccion+QA."""
    a = acta_valida()
    a["puntos"][14]["estado"] = "\u2716"
    a["puntos"][14]["planAccion"] = {"due\u00f1o": "QA", "fecha": "2026-10-04", "desc": "arreglar"}
    a["firmas"] = ["produccion"]
    al = vp.verificar_puntos(a, cierre=True)

    assert any("en \u2716 y el cierre exige" in x for x in al), al
    assert any("falta la firma de 'qa'" in x for x in al), al
    # en modo borrador NO se quejan del ✖ ni de las firmas
    assert vp.verificar_puntos(a, cierre=False) == [], "el borrador no debe exigir firmas"


# --- integridad estructural -------------------------------------------------
def test_faltan_y_sobran_puntos():
    a = acta_valida()
    a["puntos"] = [p for p in a["puntos"] if p["id"] != 3]
    al = vp.verificar_puntos(a)
    assert any("punto 3 FALTA" in x for x in al), al

    a2 = acta_valida()
    a2["puntos"].append({"id": 99, "nombre": "Inventado", "estado": "\u2714",
                         "evidencia": "x", "planAccion": None})
    al2 = vp.verificar_puntos(a2)
    assert any("punto 99 NO ESTA en el diseno" in x for x in al2), al2


def test_ids_duplicados():
    a = acta_valida()
    a["puntos"].append(dict(a["puntos"][0]))
    al = vp.verificar_puntos(a)
    assert any("DUPLICADO" in x for x in al), al


def test_acta_valida_no_da_alertas():
    assert vp.verificar_puntos(acta_valida()) == []
    assert vp.verificar_puntos(acta_valida(), cierre=True) == []


def test_estados_aceptan_asi():
    """El semaforo puede venir como glifo o como OK/WARN/BLOCK."""
    assert vp.normalizar_estado("OK") == "\u2714"
    assert vp.normalizar_estado("warn") == "\u26a0"
    assert vp.normalizar_estado("BLOCK") == "\u2716"
    assert vp.normalizar_estado("\u26a0") == "\u26a0"
    assert vp.normalizar_estado(None) is None
    assert vp.normalizar_estado("cualquier cosa") is None


# --- PENDIENTE (canal 12 del director, 2026-10-05) -------------------------
def test_pendiente_es_estado_valido():
    """Decision del fundador: el dato que aun no existe va como PENDIENTE, no
    como WARN ni como BLOCK. El validador tiene que reconocerlo, o rejecta un
    acta que el fundador considero valida."""
    assert vp.normalizar_estado("PENDIENTE") == "PENDIENTE"
    assert vp.normalizar_estado("pendiente") == "PENDIENTE"
    assert vp.normalizar_estado("SIN-DATO") == "PENDIENTE"
    assert vp.normalizar_estado("sin_dato") == "PENDIENTE"
    assert "PENDIENTE" in vp.ESTADOS

    a = acta_valida()
    a["puntos"][16]["estado"] = "PENDIENTE"
    a["puntos"][16]["evidencia"] = ""      # el dato no existe todavia
    a["puntos"][16]["planAccion"] = {"due\u00f1o": "s2", "fecha": "2026-10-06",
                                     "desc": "falta la telemetria de 72 h (M143)"}
    assert vp.verificar_puntos(a) == [], vp.verificar_puntos(a)


def test_pendiente_exige_plan_de_accion():
    """PENDIENTE no es un verde: exige plan de accion con dueno y fecha. Sin
    eso, cualquier punto sin datos se declara PENDIENTE y el acta cierra en
    verde sin haber medido nada — la trampa 81/100."""
    a = acta_valida()
    a["puntos"][16]["estado"] = "PENDIENTE"
    a["puntos"][16]["evidencia"] = ""
    al = vp.verificar_puntos(a)
    assert any("punto 17" in x and "exige planAccion" in x for x in al), al


def test_pendiente_al_cierre_exige_dueno():
    """Al cierre, un PENDIENTE sin dueno es un limbo: tiene fecha de cierre pero
    nadie responde por traer el dato."""
    a = acta_valida()
    a["puntos"][16]["estado"] = "PENDIENTE"
    a["puntos"][16]["evidencia"] = ""
    a["puntos"][16]["planAccion"] = {"fecha": "2026-10-06", "desc": "sin dueno"}
    al = vp.verificar_puntos(a, cierre=True)
    assert any("PENDIENTE al cierre sin dueno" in x for x in al), al

    a2 = acta_valida()
    a2["puntos"][16]["estado"] = "PENDIENTE"
    a2["puntos"][16]["evidencia"] = ""
    a2["puntos"][16]["planAccion"] = {"due\u00f1o": "s2", "fecha": "2026-10-06",
                                      "desc": "falta telemetria (M143)"}
    assert vp.verificar_puntos(a2, cierre=True) == [], vp.verificar_puntos(a2, cierre=True)


# --- detector ciego (BUG-075): la distincion 1 vs 3 es obligatoria ---------
def test_detector_ciego_no_devuelve_valor():
    """Un acta ausente/vacia/invalida debe LEVANTAR, no devolver {}.

    Si devolvera {}, el llamador leeria «sin alertas» sobre un archivo que no
    pudo leer — indistinguible de «no hay datos» (familia trampa 91/100).
    """
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        casos = []

        inexistente = tmp / "NO_EXISTE.json"
        try:
            vp.cargar_acta(inexistente)
        except vp.DetectorCiegoError as e:
            casos.append(("inexistente", "no existe" in str(e)))
        else:
            raise AssertionError("acta inexistente devolvio un valor")

        vacio = tmp / "VACIA.json"
        vacio.write_bytes(b"")
        try:
            vp.cargar_acta(vacio)
        except vp.DetectorCiegoError as e:
            casos.append(("vacia", "vacia" in str(e)))
        else:
            raise AssertionError("acta de 0 bytes devolvio un valor")

        basura = tmp / "BASURA.json"
        basura.write_text("{no es json", encoding="utf-8")
        try:
            vp.cargar_acta(basura)
        except vp.DetectorCiegoError as e:
            casos.append(("json invalido", "no es JSON valido" in str(e)))
        else:
            raise AssertionError("JSON invalido devolvio un valor")

        lista = tmp / "LISTA.json"
        lista.write_text("[1,2,3]", encoding="utf-8")
        try:
            vp.cargar_acta(lista)
        except vp.DetectorCiegoError as e:
            casos.append(("raiz lista", "deberia ser un objeto" in str(e)))
        else:
            raise AssertionError("raiz lista devolvio un valor")

        for nombre, ok in casos:
            assert ok, "diagnostico poco claro para %s" % nombre


def test_exit_code_3_en_proceso():
    """El contrato con el llamador es el EXIT CODE del proceso, no el retorno."""
    with tempfile.TemporaryDirectory() as tmp:
        vacio = Path(tmp) / "VACIA.json"
        vacio.write_bytes(b"")
        p = subprocess.run(
            [sys.executable, str(RAIZ / "scripts" / "auditoria" / "verificar_puntos.py"),
             "--acta", str(vacio)],
            capture_output=True, text=True, encoding="utf-8", errors="replace",
        )
        assert p.returncode == 3, f"esperaba exit 3 (detector ciego), obtuve {p.returncode}"
        assert "DETECTOR CIEGO" in p.stdout, p.stdout[-400:]


def test_plantilla_es_valida():
    """El esqueleto que emite --plantilla debe pasar la validacion de estructura."""
    a = vp.plantilla_acta()
    assert len(a["puntos"]) == 26, len(a["puntos"])
    assert [p["id"] for p in a["puntos"]] == list(range(1, 27))
    # sin evidencia -> alertas (esperado: es una plantilla vacia)
    al = vp.verificar_puntos(a)
    assert len(al) == 26, "esperaba 26 alertas de 'sin evidencia', obtuve %d" % len(al)
    # y con evidencia pasa
    for p in a["puntos"]:
        p["evidencia"] = "x.md"
    assert vp.verificar_puntos(a) == []


def test_json_escribible():
    """El acta debe poder escribirse en disco y releerse (round-trip UTF-8)."""
    with tempfile.TemporaryDirectory() as tmp:
        ruta = Path(tmp) / "acta.json"
        ruta.write_text(json.dumps(acta_valida(), ensure_ascii=False, indent=2),
                        encoding="utf-8")
        assert vp.verificar_puntos(vp.cargar_acta(ruta)) == []
        assert vp.verificar_puntos(vp.cargar_acta(ruta), cierre=True) == []


def main():
    print("=" * 68)
    print("SUITE DE TESTS — M151 verificar_puntos.py")
    print("=" * 68)
    print()
    test("acta incompleta detecta puntos sin evidencia (04-Codigo.md caso 1)",
         test_acta_incompleta_detecta_sin_evidencia)
    test("un WARN exige planAccion con dueno/fecha/desc", test_acta_con_warn_exige_plan_de_accion)
    test("cierre exige 0 bloqueantes y firmas produccion+QA",
         test_cierre_exige_cero_bloqueantes_y_firmas)
    test("detecta puntos que faltan y puntos que sobran", test_faltan_y_sobran_puntos)
    test("detecta ids duplicados", test_ids_duplicados)
    test("acta valida no da alertas (borrador y cierre)", test_acta_valida_no_da_alertas)
    test("estados aceptan glifo y OK/WARN/BLOCK", test_estados_aceptan_asi)
    test("PENDIENTE es estado valido (decision del fundador)",
         test_pendiente_es_estado_valido)
    test("PENDIENTE exige plan de accion (no es un verde)",
         test_pendiente_exige_plan_de_accion)
    test("PENDIENTE al cierre exige dueno", test_pendiente_al_cierre_exige_dueno)
    test("detector ciego levanta en 4 casos (BUG-075)",
         test_detector_ciego_no_devuelve_valor)
    test("exit code 3 en proceso (detector ciego)", test_exit_code_3_en_proceso)
    test("plantilla tiene los 26 puntos y valida su estructura", test_plantilla_es_valida)
    test("round-trip JSON UTF-8 en disco", test_json_escribible)
    print()
    print("=" * 68)
    print(f"RESULTADO: {PASS} PASS, {FAIL} FAIL")
    print()
    print("PENDIENTE HONESTO (04-Codigo.md §4 los pide, NO estan implementados):")
    print("  [ ] importar_telemetria.py  con datos de prueba -> umbrales correctos")
    print("  [ ] importar_encuestas.py   con CSV mal formado  -> error claro, sin crash")
    print("  [ ] generar_acta.py         con WARN             -> incluye dueno y fecha")
    print("  (son modulos [M] de M151; no se marcan como hechos)")
    print("=" * 68)
    return 1 if FAIL else 0


if __name__ == "__main__":
    sys.exit(main())