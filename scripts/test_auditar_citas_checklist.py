#!/usr/bin/env python3
"""Suite del auditor de citas (scripts/auditar_citas_checklist.py).

Protege las tres cosas que hacen util al auditor:
  1. PRECISION: no cuenta como defecto lo que no es una cita de archivo
     (pseudo-codigo, fracciones, listas de extensiones, plantillas de nombre,
     carpetas excluidas, clases citadas con nombre de archivo).
  2. SENSIBILIDAD: si una cita apunta a un archivo que no existe, la nombra.
  3. NO CEGUERA: si no lee nada, sale 3 y no 0.

Correr:
  python scripts/test_auditar_citas_checklist.py

Exit 0 si todo pasa, 1 si algo falla.
"""

from __future__ import annotations

import io
import json
import os
import shutil
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import auditar_citas_checklist as mod  # noqa: E402

# Piso de checks MEDIDO en verde (no estimado).  La primera version puso 34 de
# memoria y el valor real fue 38; al agregar el bloque de byte NUL paso a 42.
# El piso se evalua ANTES de contarse a si mismo, asi que no puede incluirse en
# su propio conteo.
CHECKS_MINIMOS = 42

_checks = 0
_fallos = 0


def _ok(cond: bool, msg: str) -> None:
    global _checks, _fallos
    _checks += 1
    if cond:
        print("  [ok] %s" % msg)
    else:
        _fallos += 1
        print("  FALLO: %s" % msg)


def _bloque(desc: str) -> None:
    print("-- %s" % desc)


def _escribir(base: str, rel: str, contenido: str) -> str:
    ruta = os.path.join(base, rel.replace("/", os.sep))
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    with open(ruta, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(contenido)
    return ruta


def _repo(base: str, checklist: str) -> str:
    """Crea un repo falso minimo y devuelve la ruta de la checklist."""
    _escribir(base, "game/isla-ancestral/scripts/foo.gd", "extends Node\n")
    _escribir(base, "game/isla-ancestral/scripts/data/item_data.gd",
              "class_name ItemData\nextends Resource\n")
    _escribir(base, "game/isla-ancestral/scripts/bar.gd",
              "\n".join("linea %d" % i for i in range(1, 21)) + "\n")
    return _escribir(base, "DOCUMENTACION/01-Fake/plan-actual/05-Checklist.md", checklist)


def _correr(argv: list[str]) -> tuple[int, str]:
    """Corre main() capturando stdout/stderr para poder asertar sobre el efecto."""
    import contextlib
    buf = io.StringIO()
    codigo = 0
    with contextlib.redirect_stdout(buf), contextlib.redirect_stderr(buf):
        try:
            codigo = mod.main(argv)
        except SystemExit as exc:
            codigo = int(exc.code or 0)
    return codigo, buf.getvalue()


def test_camino_feliz() -> None:
    _bloque("1. Camino feliz: todas las citas resuelven -> EXIT 0")
    base = tempfile.mkdtemp()
    try:
        _repo(base, "- [x] usa `scripts/foo.gd` y `bar.gd`\n")
        codigo, salida = _correr(["--raiz", base, "--todas"])
        _ok(codigo == 0, "EXIT 0 con citas validas (dio %d)" % codigo)
        _ok("DEFECTOS: 0 citas de archivo rotas" in salida,
            "el resumen declara 0 citas rotas")
        _ok("checklists leidas: 1" in salida, "leyo exactamente 1 checklist")
    finally:
        shutil.rmtree(base, ignore_errors=True)


def test_cita_rota_se_nombra() -> None:
    _bloque("2. Sensibilidad: una cita a archivo inexistente se nombra")
    base = tempfile.mkdtemp()
    try:
        _repo(base, "- [x] implementado en `scripts/foo.gd` y `no_existe_jamas.gd`\n")
        codigo, salida = _correr(["--raiz", base, "--todas"])
        _ok(codigo == 1, "EXIT 1 con cita rota (dio %d)" % codigo)
        _ok("no_existe_jamas.gd" in salida, "la cita rota aparece NOMBRADA en la salida")
        _ok("EN ITEM [x]" in salida and " 1" in salida,
            "la cuenta como defecto en item [x]")
    finally:
        shutil.rmtree(base, ignore_errors=True)


def test_prosa_no_es_item_x() -> None:
    _bloque("3. Contexto: misma cita en prosa NO cuenta como falso verde")
    base = tempfile.mkdtemp()
    try:
        _repo(base, "Ver `scripts/foo.gd`.\nEl diseno preve `no_existe_jamas.gd` para mas adelante.\n")
        codigo, salida = _correr(["--raiz", base, "--todas"])
        _ok(codigo == 1, "sigue siendo defecto (EXIT 1)")
        _ok("EN ITEM [x] (falso verde declarado): 0" in salida,
            "pero NO se atribuye a un item [x]")
    finally:
        shutil.rmtree(base, ignore_errors=True)


def test_no_es_cita() -> None:
    _bloque("4. Precision: lo que no es cita de archivo no es defecto")
    base = tempfile.mkdtemp()
    try:
        _repo(base,
              "- [x] `scripts/foo.gd` y `fijar(\"vsync\", 0/1/2)` y `163/222` y `.ogg/.wav/.mp3`\n"
              "- [x] plantilla `NN-Nombre.md` y `save_001_v<X.Y.Z>.tres`\n"
              "- [x] `origin/main` y `user://fotos/` y `.godot/cache`\n"
              "- [x] par de API `profundidad_min/max`\n")
        codigo, salida = _correr(["--raiz", base, "--todas"])
        _ok(codigo == 0, "EXIT 0: nada de eso es defecto (dio %d)" % codigo)
        _ok("DEFECTOS: 0 citas de archivo rotas" in salida, "0 citas rotas declaradas")
    finally:
        shutil.rmtree(base, ignore_errors=True)


def test_clase_no_es_fantasma() -> None:
    _bloque("5. Clase citada con nombre de archivo: imprecisa, no fantasma")
    base = tempfile.mkdtemp()
    try:
        _repo(base, "- [x] modelo `ItemData.gd` con campos\n")
        codigo, salida = _correr(["--raiz", base, "--todas"])
        _ok(codigo == 0, "EXIT 0: la clase ItemData existe en item_data.gd")
        _ok("1 citas de CLASE" in salida, "se informa como cita de clase")
        _repo(base, "- [x] `scripts/foo.gd` y modelo `OtraClaseQueNoExiste.gd`\n")
        codigo2, salida2 = _correr(["--raiz", base, "--todas"])
        _ok(codigo2 == 1, "una clase que no existe SI es defecto")
        _ok("OtraClaseQueNoExiste.gd" in salida2, "y se nombra")
    finally:
        shutil.rmtree(base, ignore_errors=True)


def test_linea_fuera_de_rango() -> None:
    _bloque("6. Referencia de linea fuera de rango")
    base = tempfile.mkdtemp()
    try:
        _repo(base, "- [x] en `bar.gd` L5-12 esta el bucle\n")
        codigo, _ = _correr(["--raiz", base, "--todas"])
        _ok(codigo == 0, "L12 dentro de 20 lineas -> sin defecto (dio %d)" % codigo)
        _repo(base, "- [x] en `bar.gd` L190-210 esta el bucle\n")
        codigo2, salida2 = _correr(["--raiz", base, "--todas"])
        _ok(codigo2 == 1, "L210 sobre 20 lineas -> defecto (dio %d)" % codigo2)
        _ok("210" in salida2 and "20 lineas" in salida2,
            "el defecto reporta la referencia y las lineas reales")
    finally:
        shutil.rmtree(base, ignore_errors=True)


def test_directorio_informativo() -> None:
    _bloque("7. Directorio ausente: informativo, no defecto")
    base = tempfile.mkdtemp()
    try:
        _repo(base, "- [x] usa `scripts/foo.gd` y la carpeta `data/inventada/`\n")
        codigo, salida = _correr(["--raiz", base, "--todas"])
        _ok(codigo == 0, "un directorio ausente no rompe el gate (dio %d)" % codigo)
        _ok("1 citas de directorio ausentes" in salida, "se informa aparte")
    finally:
        shutil.rmtree(base, ignore_errors=True)


def test_ceguera() -> None:
    _bloque("8. Guardia de ceguera: nunca 0 por no haber mirado")
    base = tempfile.mkdtemp()
    try:
        os.makedirs(os.path.join(base, "DOCUMENTACION"), exist_ok=True)
        codigo, salida = _correr(["--raiz", base, "--todas"])
        _ok(codigo == 3, "sin checklists -> EXIT 3 (dio %d)" % codigo)
        _ok("CIEGO" in salida, "se declara CIEGO")
        _repo(base, "# sin citas en ninguna linea\n- [x] nada\n")
        codigo2, salida2 = _correr(["--raiz", base, "--todas"])
        _ok(codigo2 == 3, "con checklist pero 0 citas -> EXIT 3 (dio %d)" % codigo2)
    finally:
        shutil.rmtree(base, ignore_errors=True)


def test_gate_y_baseline() -> None:
    _bloque("9. Gate --check con baseline")
    base = tempfile.mkdtemp()
    try:
        _repo(base, "- [x] `scripts/foo.gd` y `rota_conocida.gd`\n")
        ruta_base = os.path.join(base, "scripts", "citas_baseline.json")
        os.makedirs(os.path.dirname(ruta_base), exist_ok=True)
        codigo_deuda, salida_deuda = _correr(["--raiz", base, "--todas", "--deuda"])
        _ok(codigo_deuda == 0, "--deuda sale 0")
        datos = json.loads(salida_deuda)
        _ok(len(datos["firmas"]) == 1, "la deuda emitida tiene 1 firma")
        with open(ruta_base, "w", encoding="utf-8", newline="\n") as fh:
            json.dump(datos, fh)
        codigo_ok, salida_ok = _correr(["--raiz", base, "--todas", "--check"])
        _ok(codigo_ok == 0, "con la deuda en el baseline, --check pasa (dio %d)" % codigo_ok)
        _ok("PASS" in salida_ok, "lo declara PASS")
        _repo(base, "- [x] `scripts/foo.gd` y `rota_conocida.gd`\n- [x] `rota_nueva.gd`\n")
        codigo_new, salida_new = _correr(["--raiz", base, "--todas", "--check"])
        _ok(codigo_new == 1, "una cita rota NUEVA rompe el gate (dio %d)" % codigo_new)
        _ok("NUEVA:" in salida_new and "rota_nueva.gd" in salida_new,
            "el gate nombra la firma nueva")
        _repo(base, "- [x] `scripts/foo.gd` y `otra_cosa.gd`\n")
        codigo_ob, salida_ob = _correr(["--raiz", base, "--todas", "--check"])
        _ok("OBSOLETA" in salida_ob, "avisa de la firma del baseline que ya no ocurre")
    finally:
        shutil.rmtree(base, ignore_errors=True)


def test_json_puro() -> None:
    _bloque("10. --json es JSON puro y parseable")
    base = tempfile.mkdtemp()
    try:
        _repo(base, "- [x] `foo.gd` y `no_existe.gd`\n")
        codigo, salida = _correr(["--raiz", base, "--todas", "--json"])
        _ok(codigo == 0, "--json sale 0 aunque haya defectos (es un volcado)")
        datos = json.loads(salida)
        _ok(datos["checklists"] == 1, "el JSON declara 1 checklist")
        _ok(datos["defectos"] == 1, "el JSON cuenta 1 defecto")
        _ok(datos["informes"][0]["rotas_archivo"][0]["cita"] == "no_existe.gd",
            "el JSON identifica la cita rota")
    finally:
        shutil.rmtree(base, ignore_errors=True)


def test_no_escribe() -> None:
    _bloque("11. El auditor no modifica el repo (solo lee)")
    base = tempfile.mkdtemp()
    try:
        ruta = _repo(base, "- [x] `no_existe.gd`\n")

        def foto() -> dict[str, int]:
            salida = {}
            for actual, _dirs, ficheros in os.walk(base):
                for f in ficheros:
                    p = os.path.join(actual, f)
                    salida[p] = os.path.getsize(p)
            return salida

        antes = foto()
        _correr(["--raiz", base, "--todas"])
        _correr(["--raiz", base, "--todas", "--json"])
        despues = foto()
        _ok(antes == despues, "el arbol quedo identico (%d archivos)" % len(antes))
        with open(ruta, "rb") as fh:
            _ok(b"no_existe.gd" in fh.read(), "la checklist sigue intacta")
    finally:
        shutil.rmtree(base, ignore_errors=True)


def test_uso_incorrecto() -> None:
    _bloque("12. Uso incorrecto: exit 2")
    codigo, _ = _correr([])
    _ok(codigo == 2, "sin --todas ni --modulo -> EXIT 2 (dio %d)" % codigo)


def test_selftest_interno() -> None:
    _bloque("13. El --selftest interno del auditor pasa")
    codigo, salida = _correr(["--selftest"])
    _ok(codigo == 0, "--selftest sale 0 (dio %d)" % codigo)
    _ok("0 fallos" in salida, "el selftest interno declara 0 fallos")


def test_checklist_binaria() -> None:
    _bloque("14. Byte NUL: la checklist se marca binaria (grep la salta)")
    base = tempfile.mkdtemp()
    try:
        ruta = _repo(base, "- [x] `scripts/foo.gd` y ver `06-Diseno.md`\n")
        with open(ruta, "rb") as fh:
            crudo = fh.read()
        _ok(b"\x00" not in crudo, "el fixture arranca sin NUL")
        with open(ruta, "wb") as fh:
            fh.write(crudo.replace(b"06-Diseno", b"\x006-Diseno", 1))
        codigo, salida = _correr(["--raiz", base, "--todas"])
        _ok(codigo == 1, "con NUL el auditor falla (dio %d)" % codigo)
        _ok("BINARIAS" in salida and "1 byte(s) NUL" in salida,
            "lo reporta como checklist binaria y cuenta los NUL")
        _ok("+ 1 checklists binarias" in salida, "entra en el total de defectos")
    finally:
        shutil.rmtree(base, ignore_errors=True)


def main() -> int:
    print("=== SUITE: auditor de citas de checklists ===")
    test_camino_feliz()
    test_cita_rota_se_nombra()
    test_prosa_no_es_item_x()
    test_no_es_cita()
    test_clase_no_es_fantasma()
    test_linea_fuera_de_rango()
    test_directorio_informativo()
    test_ceguera()
    test_gate_y_baseline()
    test_json_puro()
    test_no_escribe()
    test_uso_incorrecto()
    test_selftest_interno()
    test_checklist_binaria()
    print("")
    print("=== RESUMEN AUDITOR DE CITAS: %d checks, %d fallos ===" % (_checks, _fallos))
    if _fallos == 0 and _checks >= CHECKS_MINIMOS:
        print("RESULTADO: PASS (%d checks, minimo %d)" % (_checks, CHECKS_MINIMOS))
        return 0
    if _fallos:
        print("RESULTADO: FAIL (%d fallos)" % _fallos)
    else:
        print("RESULTADO: FAIL (solo %d checks, minimo %d)" % (_checks, CHECKS_MINIMOS))
    return 1


if __name__ == "__main__":
    sys.exit(main())
