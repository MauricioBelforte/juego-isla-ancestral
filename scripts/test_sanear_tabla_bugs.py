#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Suite de `scripts/sanear_tabla_bugs.py` (M102, item 31 residuo).

Mismo patron que `test_metricas_bugs.py`: fixtures en directorio temporal,
checks nombrados, piso de checks MEDIDO en verde (no estimado) y prueba del
guardian EN ROJO por inyeccion.

El piso `CHECKS_MINIMOS` se declara abajo y el ultimo check lo compara contra
los checks realmente ejecutados: si alguien agrega una funcion de test y se
olvida de llamarla desde `main()`, el piso no lo detecta pero el conteo si
baja respecto del numero declarado.
"""

import io
import os
import shutil
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sanear_tabla_bugs as st  # noqa: E402
import metricas_bugs as mb  # noqa: E402

CHECKS_MINIMOS = 23

PASS = 0
FAIL = 0
FALLOS = []


def _escribir(tmp, nombre, contenido):
    ruta = os.path.join(tmp, nombre)
    with io.open(ruta, "wb") as f:
        f.write(contenido.encode("utf-8"))
    return ruta


def test(nombre, fn):
    global PASS, FAIL
    try:
        fn()
    except AssertionError as e:
        FAIL += 1
        FALLOS.append(nombre)
        print("  FAIL  %-58s %s" % (nombre, e))
    except Exception as e:  # noqa: BLE001 - un error de runtime es un fallo
        FAIL += 1
        FALLOS.append(nombre)
        print("  ERROR %-58s %r" % (nombre, e))
    else:
        PASS += 1
        print("  ok    %s" % nombre)


# --- fixtures -------------------------------------------------------------

CABECERA = """# Registro de Bugs

## 5. Tabla Resumen de Bugs

| ID | T\u00edtulo | M\u00f3dulo | Severidad | Estado | Reportado por | Fecha |
|----|--------|--------|-----------|--------|---------------|-------|
| BUG-001 | Un bug con fila | M10 | \U0001F7E1 Menor | [x] Resuelto | alguien | 2026-09-01 |
| BUG-002 | Otro con fila | M11 | \U0001F534 Cr\u00edtica | [ ] Abierto | otro | 2026-09-02 |

## 6. Bugs Abiertos (pendientes)

### BUG-003 \u2014 Tercero sin fila en la tabla

- **Fecha de reporte:** 2026-09-03 10:00
- **M\u00f3dulo(s) afectado(s):** M19 VillagerManager (`villager_manager.gd`)
- **Severidad:** \U0001F534 Cr\u00edtico (rompe el boot)
- **Estado:** [ ] Abierto \u2014 pendiente de fix

### BUG-004 \u2014 Cuarto sin fila, con marcas raras

- **Fecha de reporte:** 2026-09-04
- **M\u00f3dulo(s) afectado(s):** M07
- **Severidad:** \U0001F7E0 Mayor
- **Estado:** \u2705 Resuelto (2026-09-14, DeepSeek)

## 7. Bugs Resueltos (historial)

### BUG-005 \u2014 Quinto sin fila y sin etiqueta de Estado

- **Fecha de reporte:** 2026-09-05
- **M\u00f3dulo(s) afectado(s):** M59
- **Severidad:** \u26AA Trivial
"""


def _fixture(tmp, nombre="bugs.md", contenido=CABECERA):
    return _escribir(tmp, nombre, contenido)


# --- checks ---------------------------------------------------------------

def test_plan_detecta_las_que_faltan():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        datos = mb.leer_registro(ruta, None)
        faltan = {d["firma"].split(":")[1] for d in datos["defectos"]
                  if d["tipo"] == "entrada_sin_fila"}
        assert faltan == {"BUG-003", "BUG-004", "BUG-005"}, faltan
        filas, omitidas = st.plan(st._leer(ruta), datos)
        assert [f[0] for f in filas] == ["BUG-003", "BUG-004"], filas
        assert [o[0] for o in omitidas] == ["BUG-005"], omitidas
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_omite_la_entrada_sin_estado_y_lo_declara():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        filas, omitidas = st.plan(st._leer(ruta), mb.leer_registro(ruta, None))
        motivos = dict(omitidas)
        assert "BUG-005" in motivos, omitidas
        assert "Estado" in motivos["BUG-005"], motivos["BUG-005"]
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_la_fila_tiene_siete_celdas():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        filas, _ = st.plan(st._leer(ruta), mb.leer_registro(ruta, None))
        for bid, celdas in filas:
            assert len(celdas) == 7, "%s tiene %d celdas" % (bid, len(celdas))
            linea = "| " + " | ".join(celdas) + " |"
            assert len(mb._celdas(linea)) == 7, "%s no re-parsea a 7" % bid
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_estado_transcribe_la_marca_real():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        filas, _ = st.plan(st._leer(ruta), mb.leer_registro(ruta, None))
        por_id = dict(filas)
        estado, marca = mb.normalizar_estado(por_id["BUG-003"][4])
        assert (estado, marca) == ("abierto", "[ ]"), (estado, marca)
        estado4, marca4 = mb.normalizar_estado(por_id["BUG-004"][4])
        assert (estado4, marca4) == ("resuelto", "[x]"), (estado4, marca4)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_check_verde_no_acepta_un_estado_vacio():
    # Control negativo del anterior: la celda NO puede quedar vacia, porque
    # `estado_desconocido` es un defecto nuevo.
    assert st._estado("") is None
    assert st._estado("sin marca alguna") is None
    assert st._estado("[ ] Abierto") is not None


def test_severidad_usa_la_etiqueta_canonica():
    # El registro escribe 'Critica' (femenino): 'Critico' crearia
    # etiqueta_severidad_inconsistente.
    assert st._severidad("\U0001F534 Cr\u00edtico (rompe el boot)") == "\U0001F534 Cr\u00edtica"
    assert st._severidad("\U0001F7E0 Mayor") == "\U0001F7E0 Mayor"
    assert st._severidad("\u26AA Trivial") == "\u26AA Trivial"
    assert st._severidad("") == ""


def test_modulos_desde_etiqueta_y_desde_titulo():
    assert st._modulos("M19 VillagerManager, M09 Terreno", "") == "M019/M009"
    assert st._modulos("", "M87: test roto") == "M087"
    assert st._modulos("", "sin modulo") == ""


def test_fecha_extrae_solo_el_dia_y_la_hora():
    assert st._fecha("2026-09-03 10:00") == "2026-09-03 10:00"
    assert st._fecha("2026-09-03") == "2026-09-03"
    assert st._fecha("sin fecha") == ""


def test_pipes_se_escapan():
    celdas = st.fila_para("BUG-009", "titulo con | pipe",
                          {"modulo": "", "severidad": "", "estado": "[ ] Abierto",
                           "reporter": "", "fecha": ""})
    assert "\\|" in celdas[1], celdas[1]
    linea = "| " + " | ".join(celdas) + " |"
    assert len(mb._celdas(linea)) == 7, mb._celdas(linea)


def test_insertar_es_aditivo():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        texto = st._leer(ruta)
        filas, _ = st.plan(texto, mb.leer_registro(ruta, None))
        nuevo = st.insertar(texto, filas)
        viejas = texto.split("\n")
        nuevas = nuevo.split("\n")
        # Toda linea original sigue ahi, en el mismo orden.
        it = iter(nuevas)
        for l in viejas:
            assert any(l == x for x in it), "linea perdida: %r" % l[:60]
        assert len(nuevas) > len(viejas)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_insertar_aborta_sin_ancla():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp, "sin-ancla.md", CABECERA.replace(
            "## 6. Bugs Abiertos (pendientes)", "## 6. Otra cosa"))
        texto = st._leer(ruta)
        try:
            st.insertar(texto, [("BUG-003", ["x"] * 7)])
        except SystemExit as e:
            assert "ancla" in str(e).lower(), str(e)
        else:
            raise AssertionError("insertar() no aborto sin ancla")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_idempotente():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        texto = st._leer(ruta)
        datos = mb.leer_registro(ruta, None)
        filas, _ = st.plan(texto, datos)
        uno = st.insertar(texto, filas)
        ruta2 = _escribir(tmp, "bugs2.md", uno)
        datos2 = mb.leer_registro(ruta2, None)
        filas2, omitidas2 = st.plan(uno, datos2)
        assert filas2 == [], "la 2a pasada agrego %r" % (filas2,)
        assert [o[0] for o in omitidas2] == ["BUG-005"], omitidas2
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_tras_aplicar_no_queda_entrada_sin_fila():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        texto = st._leer(ruta)
        filas, _ = st.plan(texto, mb.leer_registro(ruta, None))
        ruta2 = _escribir(tmp, "bugs2.md", st.insertar(texto, filas))
        datos2 = mb.leer_registro(ruta2, None)
        quedan = [d["firma"].split(":")[1] for d in datos2["defectos"]
                  if d["tipo"] == "entrada_sin_fila"]
        # BUG-005 NO se agrega a proposito: su entrada no declara **Estado:** y
        # deducirlo seria inventar. Queda declarada como omitida.
        assert quedan == ["BUG-005"], quedan
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_tras_aplicar_no_aparecen_defectos_nuevos():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        texto = st._leer(ruta)
        antes = {d["firma"] for d in mb.leer_registro(ruta, None)["defectos"]}
        filas, _ = st.plan(texto, mb.leer_registro(ruta, None))
        nuevo = st.insertar(texto, filas)
        ruta2 = _escribir(tmp, "bugs2.md", nuevo)
        despues = {d["firma"] for d in mb.leer_registro(ruta2, None)["defectos"]}
        nuevas = despues - antes
        assert nuevas == set(), "firmas nuevas: %r" % (nuevas,)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_sin_bom_y_con_lf():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        texto = st._leer(ruta)
        filas, _ = st.plan(texto, mb.leer_registro(ruta, None))
        nuevo = st.insertar(texto, filas)
        assert not nuevo.startswith("\ufeff"), "BOM"
        assert "\r\n" not in nuevo, "CRLF"
        crudo = nuevo.encode("utf-8")
        assert not crudo.startswith(b"\xef\xbb\xbf"), "BOM en bytes"
        assert b"\r\n" not in crudo, "CRLF en bytes"
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_validar_detecta_retroceso_por_inyeccion():
    """GUARDIAN EN ROJO: una fila con estado ilegible DEBE abortar."""
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        texto = st._leer(ruta)
        # Se inyecta a mano una fila sin marca: estado_desconocido.
        roto = texto.replace(
            "## 6. Bugs Abiertos (pendientes)",
            "| BUG-999 | inyectado | M01 | \U0001F7E1 Menor | sin marca | x | 2026-01-01 |\n\n"
            "## 6. Bugs Abiertos (pendientes)")
        destino = os.path.join(tmp, "medir.md")
        ok, msgs = st.validar(texto, roto, destino, ruta)
        assert ok is False, "el guardian no vio el estado ilegible"
        assert any("RETROCESO" in m for m in msgs), msgs
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_validar_acepta_el_cambio_bueno():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        texto = st._leer(ruta)
        filas, _ = st.plan(texto, mb.leer_registro(ruta, None))
        destino = os.path.join(tmp, "medir.md")
        ok, msgs = st.validar(texto, st.insertar(texto, filas), destino, ruta)
        assert ok is True, msgs
        assert any("mejora" in m for m in msgs), msgs
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_cli_dry_run_no_escribe():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        antes = st._leer(ruta)
        codigo = st.main(["--archivo", ruta])
        assert codigo == 0, codigo
        assert st._leer(ruta) == antes, "el dry-run escribio"
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_cli_check_rojo_si_queda_trabajo():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        assert st.main(["--archivo", ruta, "--check"]) == 1
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_cli_aplicar_escribe_y_luego_verde():
    tmp = tempfile.mkdtemp()
    try:
        ruta = _fixture(tmp)
        assert st.main(["--archivo", ruta, "--aplicar"]) == 0
        datos = mb.leer_registro(ruta, None)
        quedan = [d["firma"].split(":")[1] for d in datos["defectos"]
                  if d["tipo"] == "entrada_sin_fila"]
        assert quedan == ["BUG-005"], quedan
        # Segunda pasada: nada aplicable, --check verde aunque quede la omitida.
        assert st.main(["--archivo", ruta, "--check"]) == 0
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_cli_archivo_inexistente_es_ciego():
    assert st.main(["--archivo", os.path.join(tempfile.gettempdir(), "no-existe-xyz.md")]) == 3


def test_registro_real_plan_es_estable():
    """Dos lecturas del registro real dan el mismo plan, y el registro ya esta saneado.

    La asercion de "0 filas aplicables" es el estado FINAL del saneamiento (es un
    trinquete de una sola direccion): si vuelve a aparecer una entrada sin fila,
    el check se pone rojo y NOMBRA cual, que es justo lo que hay que saber.
    """
    texto = st._leer(st.RUTA_POR_DEFECTO)
    a = st.plan(texto, mb.leer_registro(st.RUTA_POR_DEFECTO, None))
    b = st.plan(texto, mb.leer_registro(st.RUTA_POR_DEFECTO, None))
    assert a == b, "el plan no es estable entre lecturas"
    filas, _omitidas = a
    for bid, celdas in filas:
        assert len(celdas) == 7, "%s no tiene 7 celdas" % bid
        assert mb.normalizar_estado(celdas[4])[1] is not None, \
            "%s quedaria con estado sin marca" % bid
    assert filas == [], "quedan filas transcribibles: %r" % ([f[0] for f in filas],)


def test_piso_de_checks():
    ejecutados = PASS + FAIL + 1
    assert ejecutados >= CHECKS_MINIMOS, \
        "solo %d checks ejecutados (minimo %d)" % (ejecutados, CHECKS_MINIMOS)


def main():
    global PASS, FAIL
    PASS = FAIL = 0
    del FALLOS[:]
    print("=" * 74)
    print("SUITE sanear_tabla_bugs.py")
    print("=" * 74)
    test("plan: detecta las entradas sin fila", test_plan_detecta_las_que_faltan)
    test("plan: omite la entrada sin Estado y lo declara",
         test_omite_la_entrada_sin_estado_y_lo_declara)
    test("fila generada tiene 7 celdas y re-parsea", test_la_fila_tiene_siete_celdas)
    test("estado: transcribe la marca real de la entrada",
         test_estado_transcribe_la_marca_real)
    test("estado: celda vacia/ilegible NO se acepta", test_check_verde_no_acepta_un_estado_vacio)
    test("severidad: usa la etiqueta canonica del registro",
         test_severidad_usa_la_etiqueta_canonica)
    test("modulos: desde la etiqueta y desde el titulo",
         test_modulos_desde_etiqueta_y_desde_titulo)
    test("fecha: solo dia y hora", test_fecha_extrae_solo_el_dia_y_la_hora)
    test("pipes escapados (no rompen la tabla)", test_pipes_se_escapan)
    test("insertar: diff aditivo, ninguna linea perdida", test_insertar_es_aditivo)
    test("insertar: aborta si falta el ancla", test_insertar_aborta_sin_ancla)
    test("idempotente: la 2a pasada no agrega nada", test_idempotente)
    test("tras aplicar: 0 entrada_sin_fila", test_tras_aplicar_no_queda_entrada_sin_fila)
    test("tras aplicar: 0 firmas de defecto nuevas",
         test_tras_aplicar_no_aparecen_defectos_nuevos)
    test("salida sin BOM y con LF (bytes)", test_sin_bom_y_con_lf)
    test("INYECCION EN ROJO: el guardian aborta un estado ilegible",
         test_validar_detecta_retroceso_por_inyeccion)
    test("el guardian acepta el cambio bueno", test_validar_acepta_el_cambio_bueno)
    test("CLI: dry-run no escribe", test_cli_dry_run_no_escribe)
    test("CLI: --check rojo si queda trabajo", test_cli_check_rojo_si_queda_trabajo)
    test("CLI: --aplicar escribe y luego queda verde",
         test_cli_aplicar_escribe_y_luego_verde)
    test("CLI: archivo inexistente -> ciego (exit 3)", test_cli_archivo_inexistente_es_ciego)
    test("registro real: el plan es estable entre lecturas",
         test_registro_real_plan_es_estable)
    test("piso de checks ejecutados", test_piso_de_checks)
    print()
    print("=" * 74)
    print("RESULTADO: %d PASS, %d FAIL" % (PASS, FAIL))
    if FALLOS:
        print("fallos: %s" % ", ".join(FALLOS))
    print("=" * 74)
    return 1 if FAIL else 0


if __name__ == "__main__":
    sys.exit(main())
