#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
#
# SB-06 — space-bunny-alpha / Kilo Code — 2026-10-05 — Log 1294
#
# Tests de `scripts/verificar_cjk.py`.
#
# Suite autocontenida (el mismo criterio que M151): `scripts/test_scripts.py` es
# de s2 y no se toca.
#
#   python scripts/verificar_cjk.py            -> el gate
#   python scripts/test_verificar_cjk.py       -> esta suite
#
# Lo que congela:
#   - que un archivo con CJK se detecta y se reporta con linea
#   - que un archivo UTF-8 VALIDO puede tener CJK (el caso mio): por eso este
#     check NO es el de mojibake
#   - que el marcador inline exime una linea y solo esa linea
#   - que .gitignore manda sobre que se escanea (sin lista paralela)
#   - que un archivo no-UTF-8 es un DEFECTO reportado, no se saltea en silencio
#   - que la raiz inexistente da exit 3 (detector ciego), no exit 0
#   - que la exclusion de vendor (node_modules) no se escanean
#
# AGENTS.md 28: UTF-8 sin BOM, LF.

import io
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
GATE = RAIZ / "scripts" / "verificar_cjk.py"
sys.path.insert(0, str(RAIZ / "scripts"))

import verificar_cjk as gate  # noqa: E402

PASS = 0
FAIL = 0
CJK = "\u4e00\u529b"                # 2 ideogramas (conteo explicito)
KANA = "\u3042"                     # hiragana
FULLW = "\uff21"                    # latin fullwidth: NO es CJK (trampa)


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


def n_archivos_es_1(cjk, ileg):
    """Helper de lectura: el gate solo debe ver 1 archivo de texto."""
    return len(cjk) + len(ileg) == 1


def escribir(ruta: Path, texto: str):
    ruta.parent.mkdir(parents=True, exist_ok=True)
    ruta.write_text(texto, encoding="utf-8")


# --- deteccion basica ------------------------------------------------------
def test_detecta_cjk():
    with tempfile.TemporaryDirectory() as tmp:
        f = Path(tmp) / "a.md"
        escribir(f, "linea normal\notra con %s pegado\n" % CJK)
        hits, ilegible = gate.escanear_archivo(f)
        assert ilegible is None, ilegible
        assert len(hits) == len(CJK), hits
        assert hits[0][0] == 2, "debe reportar el numero de linea"
        assert hits[0][1] == CJK[0], hits


def test_no_detecta_latino_ni_fullwidth():
    """Trampa: el latin 'fullwidth' (U+FF21) NO es CJK. Un gate con el rango
    mal puesto marcaría plein de texto japones legitimo... o al reves, dejaria
    pasar CJK."""
    with tempfile.TemporaryDirectory() as tmp:
        f = Path(tmp) / "a.md"
        escribir(f, "acentos: ñáéíóú\ncomillas: «»\nfullwidth: %s\n" % FULLW)
        hits, ilegible = gate.escanear_archivo(f)
        assert ilegible is None, ilegible
        assert hits == [], hits


def test_utf8_valido_puede_venir_con_cjk():
    """El caso REAL mio: el archivo estaba en UTF-8 perfectly valid y aun asi
    tenia CJK. Por eso este check es distinto del de mojibake."""
    with tempfile.TemporaryDirectory() as tmp:
        f = Path(tmp) / "a.md"
        escribir(f, "Se aplica el criterio de %s al diseno.\n" % CJK)
        # sigue siendo UTF-8 valido
        f.read_bytes().decode("utf-8")
        hits, ilegible = gate.escanear_archivo(f)
        assert ilegible is None, "un archivo UTF-8 valido NO debe ser ilegible"
        assert len(hits) == len(CJK), hits


def test_detecta_kana_y_full_cjk():
    with tempfile.TemporaryDirectory() as tmp:
        f = Path(tmp) / "a.md"
        escribir(f, "kana %s\nkanji %s\n" % (KANA, CJK))
        hits, _ = gate.escanear_archivo(f)
        assert len(hits) == 1 + len(CJK), hits


# --- marcador inline -------------------------------------------------------
def test_marcador_exime_solo_esa_linea():
    with tempfile.TemporaryDirectory() as tmp:
        f = Path(tmp) / "a.md"
        escribir(f,
                 "linea exenta con %s  [%s]\n" % (CJK, gate.MARCADOR_OK) +
                 "linea NO exenta con %s\n" % CJK)
        hits, ilegible = gate.escanear_archivo(f)
        assert ilegible is None, ilegible
        assert len(hits) == len(CJK), "solo la 2da linea debe reportar: %s" % (hits,)
        assert hits[0][0] == 2, hits


# --- .gitignore manda ------------------------------------------------------
def test_gitignore_manda():
    """El gate NO debe mantener una lista paralela de exclusiones: lee el
    .gitignore del proyecto. Una lista paralela se desactualiza, que es
    exactamente el fallo que este gate caza."""
    with tempfile.TemporaryDirectory() as tmp:
        raiz = Path(tmp)
        # los patrones deben ser de TEXTO: un .log no llega ni al check de
        # .gitignore porque es_texto() lo descarta antes (por eso el 1o test
        # con *.log contaba 1 excluido y no 2 — el codigo estaba bien, el
        # test elegia un patron que no llegaba).
        escribir(raiz / ".gitignore", "vendor/\n*.bak.md\n")
        escribir(raiz / "vendor" / "x.md", "con %s\n" % CJK)
        escribir(raiz / "a.bak.md", "con %s\n" % CJK)
        escribir(raiz / "b.md", "con %s\n" % CJK)

        patrones = gate.leer_gitignore(raiz)
        assert any(p[0] == "vendor" and p[1] and not p[2] for p in patrones), patrones
        assert gate.ruta_ignorada(("vendor",), patrones, es_dir=True), "vendor/ debe ignorarse"
        assert gate.ruta_ignorada(("a.bak.md",), patrones, es_dir=False), "*.bak.md debe ignorarse"
        assert not gate.ruta_ignorada(("b.md",), patrones, es_dir=False), "b.md NO debe ignorarse"

        cjk, ileg, n, n_bom, n_excl = gate.recorrer(raiz, set())
        assert set(cjk.keys()) == {"b.md"}, cjk.keys()
        assert n_archivos_es_1(cjk, ileg), cjk
        assert n_excl >= 2, "esperaba >=2 excluidos (vendor/ podado + a.bak.md), hubo %d" % n_excl


def test_gitignore_ruta_anclada():
    with tempfile.TemporaryDirectory() as tmp:
        raiz = Path(tmp)
        escribir(raiz / ".gitignore", "/build/\n")
        patrones = gate.leer_gitignore(raiz)
        assert gate.ruta_ignorada(("build",), patrones, es_dir=True), "anclado a raiz"
        # con /build/ SOLO la raiz; un build/ anidado no se ignora
        assert not gate.ruta_ignorada(("sub", "build"), patrones, es_dir=True), "no debe ignorar anidados"


def test_gitignore_ausente_no_rompe():
    with tempfile.TemporaryDirectory() as tmp:
        raiz = Path(tmp)
        escribir(raiz / "a.md", "con %s\n" % CJK)
        assert gate.leer_gitignore(raiz) == [], "sin .gitignore debe devolver vacio"
        cjk, ileg, n, n_bom, n_excl = gate.recorrer(raiz, set())
        assert set(cjk.keys()) == {"a.md"}, cjk.keys()


# --- ilegibles: defecto, no silencio ---------------------------------------
def test_ilegible_es_defecto_no_silencio():
    """Un archivo de texto que no es UTF-8 debe REPORTARSE. Si el gate se lo
    tragara, dariamos un OK que no covers el archivo — la trampa 91/100."""
    with tempfile.TemporaryDirectory() as tmp:
        raiz = Path(tmp)
        (raiz / "roto.md").write_bytes(b"texto con byte invalido \xff\xfe aqui")
        escribir(raiz / "bien.md", "sin cjk\n")
        cjk, ileg, n, n_bom, n_excl = gate.recorrer(raiz, set())
        assert "roto.md" in ileg, "el ilegible debe aparecer: %s" % (ileg,)
        assert "UTF-8" in ileg["roto.md"], ileg["roto.md"]
        assert "bien.md" not in ileg, "el sano no debe aparecer"


def test_ilegible_no_impide_escquear_el_resto():
    """Un ilegible NO debe abortar el escaneo entero: si no, un solo archivo
    roto pierde el reporte de los otros miles."""
    with tempfile.TemporaryDirectory() as tmp:
        raiz = Path(tmp)
        (raiz / "roto.md").write_bytes(b"\xff\xfe")
        escribir(raiz / "con_cjk.md", "con %s\n" % CJK)
        cjk, ileg, *_ = gate.recorrer(raiz, set())
        assert "con_cjk.md" in cjk, "el CJK debe reportarse aun con un ilegible"
        assert "roto.md" in ileg


def test_escaneo_ignora_binarios():
    with tempfile.TemporaryDirectory() as tmp:
        raiz = Path(tmp)
        escribir(raiz / "datos.png", "binario con %s\n" % CJK)
        escribir(raiz / "malla.glb", "binario con %s\n" % CJK)
        escribir(raiz / "a.md", "con %s\n" % CJK)
        cjk, *_ = gate.recorrer(raiz, set())
        assert set(cjk.keys()) == {"a.md"}, "los binarios no se escanean: %s" % (cjk.keys(),)


# --- codigos de salida (contrato con el proceso) ---------------------------
def _correr(args):
    return subprocess.run([sys.executable, str(GATE)] + args,
                          capture_output=True, text=True, encoding="utf-8",
                          errors="replace")


def test_raiz_inexistente_da_3_no_0():
    """Detector ciego: si no puedo recorrer, NO es 'sin CJK'. Un exit 0 aqui
    seria un OK falso."""
    with tempfile.TemporaryDirectory() as tmp:
        p = _correr(["--raiz", os.path.join(tmp, "NO_EXISTE"), "--sin-bom"])
        assert p.returncode == 3, "esperaba 3, obtuve %d" % p.returncode
        assert "DETECTOR CIEGO" in p.stdout, p.stdout[-300:]


def test_repo_sin_cjk_da_0():
    with tempfile.TemporaryDirectory() as tmp:
        raiz = Path(tmp)
        escribir(raiz / ".gitignore", "")
        escribir(raiz / "limpio.md", "sin nada raro\n")
        p = _correr(["--raiz", str(raiz), "--sin-bom"])
        assert p.returncode == 0, "esperaba 0, obtuve %d\n%s" % (p.returncode, p.stdout)


def test_repo_con_cjk_da_1():
    with tempfile.TemporaryDirectory() as tmp:
        raiz = Path(tmp)
        escribir(raiz / "malo.md", "con %s\n" % CJK)
        p = _correr(["--raiz", str(raiz), "--sin-bom"])
        assert p.returncode == 1, "esperaba 1, obtuve %d" % p.returncode
        assert "malo.md" in p.stdout, p.stdout[-300:]


def test_json_es_machine_readable():
    with tempfile.TemporaryDirectory() as tmp:
        raiz = Path(tmp)
        escribir(raiz / "malo.md", "con %s\n" % CJK)
        p = _correr(["--raiz", str(raiz), "--json", "--sin-bom"])
        assert p.returncode == 1, p.returncode
        d = json.loads(p.stdout)
        assert d["archivos_con_cjk"] == 1, d
        assert d["caracteres_cjk"] == len(CJK), d
        assert "malo.md" in d["cjk"], d
        assert d["cjk"]["malo.md"][0]["linea"] == 1, d


def test_permitir_exime():
    with tempfile.TemporaryDirectory() as tmp:
        raiz = Path(tmp)
        escribir(raiz / "cita.md", "cita de %s\n" % CJK)
        p = _correr(["--raiz", str(raiz), "--sin-bom", "--permitir", "cita.md"])
        assert p.returncode == 0, "esperaba 0 con --permitir, obtuve %d" % p.returncode


# --- agujero del rango: puntuacion CJK y radicajos (SB-11) ----------------
def test_detecta_puntuacion_cjk():
    """REGRESION (SB-11): la coma ideografica U+3001 NO esta en
    U+4E00..U+9FFF. Un patron que solo cubria ideogramas la dejaba pasar, y
    escapo justo en 11-BUGS.md. Ahora el rango incluye U+3000..U+303F.
    (el caracter se escribe como escape para que el gate no marque su propia
    suite: un gate que se dispara a si mismo es inservible)"""
    CASOS = [("\u3001", "coma ideografica"), ("\u3002", "punto ideografico"),
             ("\u301c", "tilde de onda"), ("\u300c", "corchete CJK")]
    for ch, nombre in CASOS:
        with tempfile.TemporaryDirectory() as tmp:
            f = Path(tmp) / "a.md"
            escribir(f, "frase con %s pegado\n" % ch)
            hits, ilegible = gate.escanear_archivo(f)
            assert ilegible is None, ilegible
            assert len(hits) == 1, "%s (U+%04X) no detectada: %s" % (nombre, ord(ch), hits)


def test_detecta_radicajos_cjk():
    """U+2E80..U+2EFF (radicazos Kangxi y suplementales)."""
    with tempfile.TemporaryDirectory() as tmp:
        f = Path(tmp) / "a.md"
        escribir(f, "con radicajo \u2ea0 aqui\n")
        hits, _ = gate.escanear_archivo(f)
        assert len(hits) == 1, hits


def test_no_marca_fullwidth_latin():
    """Control del rango nuevo: el latin fullwidth (U+FF21) es legitimo en
    japones y NO debe marcarse. El rango se toco, asi que el control se
    mantiene explicito."""
    with tempfile.TemporaryDirectory() as tmp:
        f = Path(tmp) / "a.md"
        escribir(f, "latino fullwidth \uff21 aqui\n")
        hits, _ = gate.escanear_archivo(f)
        assert hits == [], "el fullwidth latin NO es CJK: %s" % (hits,)


def main():
    print("=" * 68)
    print("SUITE DE TESTS — SB-06 verificar_cjk.py")
    print("=" * 68)
    print()
    test("detecta CJK y reporta el numero de linea", test_detecta_cjk)
    test("no marca latin con tilde ni fullwidth (trampa de rango)",
         test_no_detecta_latino_ni_fullwidth)
    test("un UTF-8 valido puede traer CJK (el caso mio, != mojibake)",
         test_utf8_valido_puede_venir_con_cjk)
    test("detecta kana y CJK unificado", test_detecta_kana_y_full_cjk)
    test("el marcador inline exime SOLO esa linea", test_marcador_exime_solo_esa_linea)
    test(".gitignore manda sobre que se escanea (sin lista paralela)",
         test_gitignore_manda)
    test(".gitignore con ruta anclada /build/", test_gitignore_ruta_anclada)
    test("sin .gitignore no se rompe", test_gitignore_ausente_no_rompe)
    test("ilegible es DEFECTO reportado, no silencio",
         test_ilegible_es_defecto_no_silencio)
    test("un ilegible no aborta el escaneo del resto",
         test_ilegible_no_impide_escquear_el_resto)
    test("los binarios no se escanean", test_escaneo_ignora_binarios)
    test("raiz inexistente da exit 3, no exit 0 (BUG-075)",
         test_raiz_inexistente_da_3_no_0)
    test("repo limpio da exit 0", test_repo_sin_cjk_da_0)
    test("repo con CJK da exit 1", test_repo_con_cjk_da_1)
    test("salida --json es legible por maquina", test_json_es_machine_readable)
    test("--permitir exente un archivo", test_permitir_exime)
    test("detecta puntuacion CJK U+3000-303F (el agujero de SB-11)",
         test_detecta_puntuacion_cjk)
    test("detecta radicazos CJK U+2E80-2EFF", test_detecta_radicajos_cjk)
    test("el latin fullwidth NO es CJK (control del rango)",
         test_no_marca_fullwidth_latin)
    print()
    print("=" * 68)
    print(f"RESULTADO: {PASS} PASS, {FAIL} FAIL")
    print("=" * 68)
    return 1 if FAIL else 0


if __name__ == "__main__":
    sys.exit(main())