#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Suite de `scripts/detectar_duplicados.py` (item 35 de la COLA ACTIVA).

Que protege esta suite:
  1. Que el detector DETECTE (fixtures con duplicado real -> lo nombra).
  2. Que NO invente (controles negativos: misma funcion corta, mismo nombre con
     cuerpo distinto, archivo byte-distinto con el mismo AST...).
  3. Que el gate DISCRIMINE (exit 0/1/3 en los casos que corresponden, no solo
     "distinto de cero").
  4. Que `--json` sea PURO (un aviso extra rompe a cualquier consumidor).
  5. Que el baseline no se pudra (firma nueva -> rojo; firma obsoleta -> rojo).

Regla del repo: el piso CHECKS_MINIMOS se MEDIENE en verde, no se estima. Si se
agregan checks, se re-mide antes de subirlo (trampa 97 del skill).

AGENTS.md 28: UTF-8 sin BOM, LF.

Uso: python scripts/test_detectar_duplicados.py
"""

import io
import json
import os
import sys
import tempfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "scripts"))

import detectar_duplicados as mod  # noqa: E402

PASS = 0
FAIL = 0

# Piso MEDIDO en verde el 2026-10-22 (Log 2141): 28 checks ejecutados ANTES del
# check de piso (total del suite = 29, el ultimo es el piso mismo). Se mide asi a
# proposito: el piso se evalua cuando todavia no se conto a si mismo, y una
# corrida que aborta pierde al menos un check -> 27 < 28 -> rojo. Estimarlo (puse
# 34 "a ojo") hace que el piso falle sobre una suite SANA: es la trampa 97.
CHECKS_MINIMOS = 28

# Fixture: dos archivos byte-identicos + un tercero distinto que comparte AST.
# Tiene que superar MIN_LINEAS_FUNCION (8): con 5 lineas el detector -con razon-
# no lo considera deuda, y el test de "funcion duplicada" quedaba sin sujeto.
CUERPO = (
    "def calcular(items, descuento=0.0):\n"
    "    total = 0\n"
    "    for it in items:\n"
    "        precio = it.get('precio', 0)\n"
    "        cantidad = it.get('cantidad', 1)\n"
    "        total += precio * cantidad\n"
    "    total = total - (total * descuento)\n"
    "    total = round(total, 2)\n"
    "    return total\n"
)


def _escribir(tmp, rel, contenido):
    destino = os.path.join(tmp, rel)
    os.makedirs(os.path.dirname(destino) or tmp, exist_ok=True)
    with io.open(destino, "wb") as fh:
        fh.write(contenido.encode("utf-8"))
    return destino


def test(nombre, fn):
    global PASS, FAIL
    try:
        fn()
        PASS += 1
        print("  [OK]   %s" % nombre)
    except AssertionError as exc:
        FAIL += 1
        print("  [FALLO] %s -> %s" % (nombre, exc))
    except Exception as exc:  # noqa: BLE001 - un error inesperado es un fallo del test
        FAIL += 1
        print("  [FALLO] %s -> %s: %s" % (nombre, type(exc).__name__, exc))


def _correr(argv):
    return mod._correr(argv)


def _fixture(tmp, con_duplicado=True):
    _escribir(tmp, "a.py", CUERPO)
    if con_duplicado:
        _escribir(tmp, "b.py", CUERPO)
    _escribir(tmp, "solo.py", "def distinto(x):\n    return x * 2\n")


# --------------------------------------------------------------------------
# A. deteccion
# --------------------------------------------------------------------------

def test_detecta_exacto():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp)
        inf = mod.analizar(tmp)
        assert inf["archivos_auditados"] == 3, inf["archivos_auditados"]
        grupos = [g for g in inf["exactos"] if "a.py" in g["rutas"]]
        assert len(grupos) == 1, "esperaba 1 grupo exacto, hay %d" % len(grupos)
        assert grupos[0]["rutas"] == ["a.py", "b.py"], grupos[0]["rutas"]


def test_control_negativo_sin_duplicado():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp, con_duplicado=False)
        inf = mod.analizar(tmp)
        assert inf["exactos"] == [], inf["exactos"]
        assert inf["normalizados"] == [], inf["normalizados"]


def test_normalizado_no_exacto():
    """Mismo codigo con otro formato: NO es exacto, SI es normalizado."""
    with tempfile.TemporaryDirectory() as tmp:
        _escribir(tmp, "f1.py", "def resta(a, b):\n    return a - b\n")
        _escribir(tmp, "f2.py", "# otro comentario\n\ndef resta(a,b):\n\n    return a - b\n")
        inf = mod.analizar(tmp)
        assert inf["exactos"] == [], "no deberia haber exactos"
        grupos = [g for g in inf["normalizados"] if "f1.py" in g["rutas"]]
        assert len(grupos) == 1, "esperaba 1 normalizado, hay %d" % len(grupos)
        assert grupos[0]["rutas"] == ["f1.py", "f2.py"], grupos[0]["rutas"]


def test_funcion_duplicada_con_otro_nombre():
    """El mismo cuerpo con otro nombre ES duplicacion: el nombre es lo que cambia."""
    with tempfile.TemporaryDirectory() as tmp:
        _escribir(tmp, "x.py", CUERPO)
        _escribir(tmp, "y.py", CUERPO.replace("calcular", "sumar_todo"))
        inf = mod.analizar(tmp)
        grupos = [g for g in inf["funciones"] if "x.py" in g["archivos"]]
        assert len(grupos) == 1, "esperaba 1 grupo de funciones, hay %d" % len(grupos)
        nombres = {a["nombre"] for a in grupos[0]["apariciones"]}
        assert nombres == {"calcular", "sumar_todo"}, nombres


def test_control_negativo_funcion_corta():
    with tempfile.TemporaryDirectory() as tmp:
        corto = "def f(x):\n    return x + 1\n"
        _escribir(tmp, "c1.py", corto)
        _escribir(tmp, "c2.py", corto)
        inf = mod.analizar(tmp)
        assert inf["funciones"] == [], "una funcion corta no es deuda: %r" % inf["funciones"]


def test_control_negativo_mismo_nombre_distinto_cuerpo():
    with tempfile.TemporaryDirectory() as tmp:
        _escribir(tmp, "n1.py", "def procesar(d):\n    return d.get('a')\n")
        _escribir(tmp, "n2.py", "def procesar(d):\n    return d.get('b')\n")
        inf = mod.analizar(tmp)
        assert inf["funciones"] == [], "mismo nombre con distinto cuerpo no es duplicado"


def test_control_negativo_un_solo_archivo():
    """El mismo cuerpo DOS VECES en un solo archivo no es duplicacion entre archivos."""
    with tempfile.TemporaryDirectory() as tmp:
        _escribir(tmp, "uno.py", CUERPO + "\n" + CUERPO.replace("calcular", "calcular2"))
        inf = mod.analizar(tmp)
        assert inf["funciones"] == [], "un solo archivo no cuenta: %r" % inf["funciones"]


def test_excluye_carpetas():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp)
        _escribir(tmp, "PAPELERA/a.py", CUERPO)
        _escribir(tmp, ".venv/lib/site-packages/a.py", CUERPO)
        inf = mod.analizar(tmp)
        rutas = set(inf["archivos"])
        assert "PAPELERA/a.py" not in rutas, "PAPELERA deberia estar excluida"
        assert not any(".venv" in r for r in rutas), "site-packages deberia estar excluido"


# --------------------------------------------------------------------------
# B. ceguera y codigos de salida
# --------------------------------------------------------------------------

def test_ciego_carpeta_vacia():
    with tempfile.TemporaryDirectory() as tmp:
        codigo, _ = _correr(["--raiz", tmp])
        assert codigo == 3, "carpeta vacia debe dar exit 3 (ciego), dio %d" % codigo


def test_uso_invalido_raiz_inexistente():
    codigo, _ = _correr(["--raiz", os.path.join(tempfile.gettempdir(), "no_existe_xyz_123")])
    assert codigo == 2, "raiz inexistente debe dar exit 2 (uso), dio %d" % codigo


def test_ceguera_detecta_sin_archivos():
    inf = {"archivos_auditados": 0, "archivos": {}}
    assert mod.ceguera(inf) != [], "0 archivos tiene que disparar ceguera"


def test_ceguera_limpia_con_archivos():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp)
        inf = mod.analizar(tmp)
        assert mod.ceguera(inf) == [], mod.ceguera(inf)


# --------------------------------------------------------------------------
# C. --json puro y estabilidad
# --------------------------------------------------------------------------

def test_json_puro():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp)
        codigo, salida = _correr(["--raiz", tmp, "--json"])
        assert codigo == 0, codigo
        datos = json.loads(salida)  # ValueError = no es JSON puro
        assert "firmas" in datos, "el JSON debe traer las firmas"
        assert "archivos" not in datos, "el JSON no debe volcar el mapa interno"
        assert "exactos" in datos, "el JSON debe traer los grupos exactos"


def test_firmas_estables():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp)
        a = mod.firmas(mod.analizar(tmp))
        b = mod.firmas(mod.analizar(tmp))
        assert a == b, "dos corridas deben dar las mismas firmas"


def test_firma_cambia_con_una_copia_mas():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp)
        antes = mod.firmas(mod.analizar(tmp))
        _escribir(tmp, "c.py", CUERPO)
        despues = mod.firmas(mod.analizar(tmp))
        assert antes != despues, "una 3a copia tiene que cambiar la firma"


def test_firma_no_depende_de_la_linea():
    """Un comentario arriba NO cambia la huella estructural (metodo AST).

    Ojo con la distincion: la FIRMA del gate se calcula sobre los BYTES, asi que
    agregar un comentario legitIMAMENTE saca al par de `exactos` (dejan de ser
    byte-identicos). Lo que no puede cambiar es la huella NORMALIZADA: si el AST
    incluyera los numeros de linea, mover el codigo inventaria un duplicado
    distinto. Se aserta sobre `normalizados`, no sobre `firmas`.
    """
    with tempfile.TemporaryDirectory() as tmp:
        _escribir(tmp, "p1.py", CUERPO)
        _escribir(tmp, "p2.py", CUERPO)
        antes = mod.analizar(tmp)
        assert any("p1.py" in g["rutas"] for g in antes["exactos"]), "base: deberia ser exacto"

        _escribir(tmp, "p2.py", "# cabecera agregada\n\n" + CUERPO)
        despues = mod.analizar(tmp)
        assert despues["exactos"] == [], "con el comentario ya no son byte-identicos"
        grupos = [g for g in despues["normalizados"] if "p1.py" in g["rutas"]]
        assert len(grupos) == 1, "el AST tiene que seguir reconociendolos iguales: %r" % (
            despues["normalizados"],)
        assert grupos[0]["rutas"] == ["p1.py", "p2.py"], grupos[0]["rutas"]


# --------------------------------------------------------------------------
# D. gate y baseline
# --------------------------------------------------------------------------

def test_check_sin_baseline_rojo():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp)
        codigo, salida = _correr(["--raiz", tmp, "--check"])
        assert codigo == 1, "con duplicado y sin baseline debe dar exit 1, dio %d" % codigo
        assert "a.py" in salida, "el rojo tiene que NOMBRAR el archivo"


def test_check_limpio_verde():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp, con_duplicado=False)
        codigo, salida = _correr(["--raiz", tmp, "--check"])
        assert codigo == 0, "sin duplicados debe dar exit 0, dio %d (%s)" % (codigo, salida)
        assert "[OK]" in salida, salida


def test_baseline_declara_y_verde():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp)
        base = os.path.join(tmp, "base.json")
        codigo, _ = _correr(["--raiz", tmp, "--escribir-baseline", base])
        assert codigo == 0, codigo
        codigo, salida = _correr(["--raiz", tmp, "--check", "--baseline", base])
        assert codigo == 0, "la deuda declarada no debe bloquear: %s" % salida
        assert "[OK]" in salida, salida


def test_baseline_duplicado_nuevo_rojo():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp)
        base = os.path.join(tmp, "base.json")
        _correr(["--raiz", tmp, "--escribir-baseline", base])
        _escribir(tmp, "nuevo1.py", "def alfa(z):\n    return z + 41\n" * 3)
        _escribir(tmp, "nuevo2.py", "def alfa(z):\n    return z + 41\n" * 3)
        codigo, salida = _correr(["--raiz", tmp, "--check", "--baseline", base])
        assert codigo == 1, "un duplicado NUEVO debe dar exit 1, dio %d" % codigo
        assert "nuevo1.py" in salida, "el rojo debe nombrar el duplicado nuevo: %s" % salida


def test_baseline_obsoleto_rojo():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp)
        base = os.path.join(tmp, "base.json")
        _correr(["--raiz", tmp, "--escribir-baseline", base])
        os.remove(os.path.join(tmp, "b.py"))  # el duplicado desaparece
        codigo, salida = _correr(["--raiz", tmp, "--check", "--baseline", base])
        assert codigo == 1, "una firma obsoleta debe dar exit 1, dio %d" % codigo
        assert "obsolet" in salida.lower(), "el rojo debe decir que el baseline quedo obsoleto: %s" % salida


def test_baseline_conserva_motivos():
    """Regenerar el baseline no puede borrar las justificaciones ya escritas."""
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp)
        base = os.path.join(tmp, "base.json")
        _correr(["--raiz", tmp, "--escribir-baseline", base])
        with io.open(base, "r", encoding="utf-8") as fh:
            datos = json.load(fh)
        firmas = list(datos["firmas"])
        assert firmas, datos
        datos["firmas"][firmas[0]] = "motivo escrito a mano"
        with io.open(base, "w", encoding="utf-8", newline="\n") as fh:
            json.dump(datos, fh, ensure_ascii=False)
        _correr(["--raiz", tmp, "--escribir-baseline", base])
        with io.open(base, "r", encoding="utf-8") as fh:
            datos2 = json.load(fh)
        assert datos2["firmas"][firmas[0]] == "motivo escrito a mano", (
            "el motivo se perdio al regenerar: %r" % datos2["firmas"])


def test_baseline_formato_dict_con_motivo():
    with tempfile.TemporaryDirectory() as tmp:
        _fixture(tmp)
        base = os.path.join(tmp, "base.json")
        _correr(["--raiz", tmp, "--escribir-baseline", base])
        with io.open(base, "r", encoding="utf-8") as fh:
            datos = json.load(fh)
        assert isinstance(datos["firmas"], dict), "el baseline debe ser {firma: motivo}"
        leido = mod.leer_baseline(base)
        assert all(isinstance(k, str) and isinstance(v, str) for k, v in leido.items()), leido


# --------------------------------------------------------------------------
# E. selftest y real
# --------------------------------------------------------------------------

def test_selftest_verde():
    codigo = mod.selftest()
    assert codigo == 0, "el --selftest del detector tiene que dar 0, dio %d" % codigo


def test_selftest_no_es_infalsificable():
    """El selftest tiene que poder FALLAR: se comprueba sobre un fixture mutado.

    Se corre `analizar()` sobre un arbol que NO tiene el duplicado y se verifica
    que la asercion equivalente del selftest fallaria. Si esto no discriminara,
    el 23/23 no probaria nada.
    """
    with tempfile.TemporaryDirectory() as tmp:
        _escribir(tmp, "a.py", CUERPO)
        _escribir(tmp, "b.py", "def otra(x):\n    return x\n")
        inf = mod.analizar(tmp)
        habria_fallado = not any("a.py" in g["rutas"] for g in inf["exactos"])
        assert habria_fallado, "sin duplicado el grupo exacto NO debe aparecer"


def test_repo_real_audita_algo():
    """Sobre el repo real el detector tiene que LEER (no dar 0 en silencio)."""
    inf = mod.analizar(str(RAIZ))
    assert inf["archivos_auditados"] > 100, (
        "leyo %d archivos: el detector esta mirando mal" % inf["archivos_auditados"])


def test_repo_real_sin_ceguera():
    inf = mod.analizar(str(RAIZ))
    assert mod.ceguera(inf) == [], mod.ceguera(inf)


def test_repo_real_gate_verde_con_baseline():
    """Invariante de CI: con el baseline commiteado, `--check` sobre el repo da 0."""
    base = RAIZ / "scripts" / "duplicados_baseline.json"
    if not base.is_file():
        raise AssertionError("falta el baseline %s" % base)
    codigo, salida = _correr(["--raiz", str(RAIZ), "--check", "--baseline", str(base)])
    assert codigo == 0, "el gate sobre el repo real debe estar VERDE: %s" % salida[-800:]


def test_piso_de_checks():
    assert PASS + FAIL >= CHECKS_MINIMOS, (
        "solo %d checks ejecutados (minimo %d)" % (PASS + FAIL, CHECKS_MINIMOS))


# --------------------------------------------------------------------------

def main():
    print("=== SUITE detectar_duplicados ===")
    test("detecta duplicado exacto y lo nombra", test_detecta_exacto)
    test("control negativo: sin duplicado no hay grupo", test_control_negativo_sin_duplicado)
    test("mismo codigo distinto formato -> normalizado, no exacto", test_normalizado_no_exacto)
    test("mismo cuerpo con otro nombre -> funcion duplicada", test_funcion_duplicada_con_otro_nombre)
    test("control negativo: funcion corta no cuenta", test_control_negativo_funcion_corta)
    test("control negativo: mismo nombre, distinto cuerpo", test_control_negativo_mismo_nombre_distinto_cuerpo)
    test("control negativo: mismo cuerpo 2x en UN archivo", test_control_negativo_un_solo_archivo)
    test("excluye PAPELERA y site-packages", test_excluye_carpetas)
    test("carpeta vacia -> exit 3 (DETECTOR CIEGO)", test_ciego_carpeta_vacia)
    test("raiz inexistente -> exit 2 (uso)", test_uso_invalido_raiz_inexistente)
    test("ceguera() dispara con 0 archivos", test_ceguera_detecta_sin_archivos)
    test("ceguera() limpia con archivos leidos", test_ceguera_limpia_con_archivos)
    test("--json imprime SOLO JSON", test_json_puro)
    test("las firmas son estables entre corridas", test_firmas_estables)
    test("una copia mas cambia la firma", test_firma_cambia_con_una_copia_mas)
    test("la firma no depende del numero de linea", test_firma_no_depende_de_la_linea)
    test("--check con duplicado y sin baseline -> ROJO nombrando archivo", test_check_sin_baseline_rojo)
    test("--check limpio -> VERDE", test_check_limpio_verde)
    test("baseline declarado -> VERDE", test_baseline_declara_y_verde)
    test("duplicado NUEVO -> ROJO", test_baseline_duplicado_nuevo_rojo)
    test("firma OBSOLETA -> ROJO", test_baseline_obsoleto_rojo)
    test("regenerar el baseline conserva los motivos", test_baseline_conserva_motivos)
    test("el baseline es {firma: motivo}", test_baseline_formato_dict_con_motivo)
    test("--selftest del detector verde", test_selftest_verde)
    test("el selftest puede fallar (no es infalsificable)", test_selftest_no_es_infalsificable)
    test("repo real: audita mas de 100 archivos", test_repo_real_audita_algo)
    test("repo real: sin motivos de ceguera", test_repo_real_sin_ceguera)
    test("repo real: gate VERDE con el baseline commiteado", test_repo_real_gate_verde_con_baseline)
    test("piso de checks ejecutados", test_piso_de_checks)
    print()
    print("=" * 68)
    print("RESULTADO: %d PASS, %d FAIL" % (PASS, FAIL))
    print("=" * 68)
    if PASS + FAIL < CHECKS_MINIMOS:
        print("[FALLO] solo %d checks ejecutados (minimo %d)" % (PASS + FAIL, CHECKS_MINIMOS))
        return 1
    return 1 if FAIL else 0


if __name__ == "__main__":
    sys.exit(main())
