#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
#
# M102-Bug-Tracking / item 31 de la COLA ACTIVA de DeepSeek-V4.1-Flash
# "unificar metricas con 11-BUGS.md (reporte automatico)".
#
# DeepSeek-V4.1-Flash (WorkBuddy) - 2026-10-21 - Log 2080
#
# Suite de `scripts/metricas_bugs.py`.
#
#   python scripts/test_metricas_bugs.py
#
# QUE CONGELA (y que NO)
# ----------------------
# NO congela los conteos de hoy de `11-BUGS.md`: otro agente registra bugs en
# ese archivo varias veces al dia, y fijar "92 filas" convertiria un dato vivo
# en un invariante falso (familia de la trampa 88: el test que consagra el
# estado). Lo que se congela son INVARIANTES y el poder DISCRIMINANTE del
# detector:
#   - un registro limpio da 0 defectos y exit 0
#   - cada familia de defecto se detecta, con el conteo exacto, sobre fixtures
#   - un registro sin tabla resumen es CIEGO (exit 3), no "0 bugs"
#   - el pipe sin escapar no corre los campos de la izquierda
#   - `--json` imprime SOLO JSON
#   - sobre el registro REAL: los agregados cuadran con las filas y todo
#     defecto declara tipo + linea + detalle (no hay defectos mudos)
#   - INYECCION EN ROJO: corromper una fila del fixture limpio sube los
#     defectos de 0 a 1. Sin esto, "0 defectos" podria ser un detector muerto.
#
# AGENTS.md 28: UTF-8 sin BOM, LF.

import ast
import io
import json
import os
import sys
import tempfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "scripts"))

import metricas_bugs as mod  # noqa: E402

PASS = 0
FAIL = 0

# Piso MEDIDO en verde (no estimado): se re-mide cada vez que crece la suite.
# 2026-10-22 (Log 2120): 30 checks tras agregar los 10 del gate de deuda.
CHECKS_MINIMOS = 30

REGISTRO_REAL = RAIZ / "DOCUMENTACION" / "11-BUGS.md"

FIXTURE_LIMPIO = """# Registro (fixture limpio)

## 5. Tabla Resumen de Bugs

| ID | Titulo | Modulo | Severidad | Estado | Reportado por | Fecha |
|----|--------|--------|-----------|--------|---------------|-------|
| BUG-001 | Uno | M10 | \U0001F534 Critica | [x] Resuelto | alfa | 2026-01-01 |
| BUG-002 | Dos | M20 | \U0001F7E1 Menor | [ ] Abierto | beta | 2026-01-02 |
| BUG-003 | Tres | M20 | \U0001F7E0 Mayor | [?] Delegado | gamma | 2026-01-03 |

## 6. Bugs Abiertos (pendientes)

### BUG-002 — Dos

### BUG-003 — Tres

## 7. Bugs Resueltos (historial)

### BUG-001 — Uno
"""


def _escribir(tmp, nombre, contenido):
    ruta = os.path.join(tmp, nombre)
    with io.open(ruta, "wb") as f:
        f.write(contenido.encode("utf-8"))
    return ruta


def test(nombre, fn):
    global PASS, FAIL
    try:
        fn()
        PASS += 1
        print("  [OK]   %s" % nombre)
    except AssertionError as e:
        FAIL += 1
        print("  [FALLO] %s -> %s" % (nombre, e))
    except Exception as e:  # noqa: BLE001 - un error inesperado es un fallo del test
        FAIL += 1
        print("  [FALLO] %s -> %s: %s" % (nombre, type(e).__name__, e))


def _correr(argv):
    return mod._correr(argv)


# --- fixtures -------------------------------------------------------------

def test_limpio_sin_defectos():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    d = mod.leer_registro(_escribir(tmp, "limpio.md", FIXTURE_LIMPIO), None)
    assert d["ciego"] is None, "el fixture limpio no debe ser ciego"
    assert len(d["tabla"]) == 3, "3 filas, medido %d" % len(d["tabla"])
    assert d["defectos"] == [], "0 defectos, medido %s" % d["metricas"]["defectos_por_tipo"]


def test_agregados_cuadran():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    d = mod.leer_registro(_escribir(tmp, "limpio.md", FIXTURE_LIMPIO), None)
    m = d["metricas"]
    suma = sum(m["por_estado"].values())
    assert suma == len(d["tabla"]), "suma por_estado %d != filas %d" % (suma, len(d["tabla"]))
    suma_sev = sum(m["por_severidad"].values())
    assert suma_sev == len(d["tabla"]), "suma por_severidad %d != filas %d" % (
        suma_sev, len(d["tabla"]))
    assert m["no_resueltos"] == 2, "no resueltos = 2, medido %d" % m["no_resueltos"]


def test_estado_sin_marca_se_declara():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    roto = FIXTURE_LIMPIO.replace("[x] Resuelto", "\u2705 Resuelto")
    d = mod.leer_registro(_escribir(tmp, "sin_marca.md", roto), None)
    tipos = d["metricas"]["defectos_por_tipo"]
    assert tipos.get("estado_sin_marca") == 1, \
        "1 estado_sin_marca, medido %s" % tipos.get("estado_sin_marca")
    # y el estado se sigue contando (la metrica no pierde la fila)
    assert d["metricas"]["por_estado"].get("resuelto") == 1, \
        "el estado se cuenta igual: %s" % d["metricas"]["por_estado"]


def test_fila_malformada_se_declara():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    roto = FIXTURE_LIMPIO.replace(
        "| BUG-002 | Dos | M20 | \U0001F7E1 Menor | [ ] Abierto | beta | 2026-01-02 |",
        "| BUG-002 | Dos | M20 | \U0001F7E1 Menor | [ ] Abierto | be|ta | 2026-01-02 |")
    d = mod.leer_registro(_escribir(tmp, "malformada.md", roto), None)
    tipos = d["metricas"]["defectos_por_tipo"]
    assert tipos.get("fila_malformada") == 1, \
        "1 fila_malformada, medido %s" % tipos.get("fila_malformada")
    fila = [f for f in d["tabla"] if f["id"] == "BUG-002"][0]
    assert fila["estado"] == "abierto", "el pipe en 'Reportado por' no corre el estado"


def test_entrada_sin_fila_y_fila_sin_entrada():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    roto = FIXTURE_LIMPIO.replace("### BUG-003 — Tres", "### BUG-099 — Huerfana")
    d = mod.leer_registro(_escribir(tmp, "drift.md", roto), None)
    tipos = d["metricas"]["defectos_por_tipo"]
    assert tipos.get("fila_sin_entrada") == 1, \
        "1 fila_sin_entrada, medido %s" % tipos.get("fila_sin_entrada")
    assert tipos.get("entrada_sin_fila") == 1, \
        "1 entrada_sin_fila, medido %s" % tipos.get("entrada_sin_fila")


def test_id_duplicado_tabla():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    duplicado = FIXTURE_LIMPIO.replace(
        "| BUG-003 | Tres |", "| BUG-001 | Repetido |")
    d = mod.leer_registro(_escribir(tmp, "dup.md", duplicado), None)
    tipos = d["metricas"]["defectos_por_tipo"]
    assert tipos.get("id_duplicado_tabla") == 1, \
        "1 id_duplicado_tabla, medido %s" % tipos.get("id_duplicado_tabla")


def test_seccion_pegada():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    pegado = FIXTURE_LIMPIO.replace(
        "## 7. Bugs Resueltos (historial)", "## 7. Bugs Resueltos (historial)### BUG-001 — Uno")
    d = mod.leer_registro(_escribir(tmp, "pegado.md", pegado), None)
    tipos = d["metricas"]["defectos_por_tipo"]
    assert tipos.get("seccion_pegada") == 1, \
        "1 seccion_pegada, medido %s" % tipos.get("seccion_pegada")


def test_etiqueta_severidad_inconsistente():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    mixto = FIXTURE_LIMPIO.replace("\U0001F534 Critica", "\U0001F534 Alta").replace(
        "| BUG-003 | Tres | M20 | \U0001F7E0 Mayor |",
        "| BUG-003 | Tres | M20 | \U0001F534 Critica |")
    d = mod.leer_registro(_escribir(tmp, "sev.md", mixto), None)
    tipos = d["metricas"]["defectos_por_tipo"]
    assert tipos.get("etiqueta_severidad_inconsistente") == 1, \
        "1 etiqueta inconsistente (rojo con 2 etiquetas), medido %s" % tipos.get(
            "etiqueta_severidad_inconsistente")


def test_ciego_sin_tabla():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    ruta = _escribir(tmp, "ciego.md", "# Sin tabla\n\n## 1. Proposito\n\nNada.\n")
    d = mod.leer_registro(ruta, None)
    assert d["ciego"], "un registro sin seccion 5 tiene que declararse ciego"
    rc, _ = _correr(["--archivo", ruta])
    assert rc == 3, "exit 3 (ciego), medido %d" % rc


def test_archivo_inexistente_es_ciego():
    rc, _ = _correr(["--archivo", os.path.join(tempfile.gettempdir(), "no_existe_xyz.md")])
    assert rc == 3, "archivo inexistente -> exit 3, medido %d" % rc


def test_dashboard_divergente():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    dash = _escribir(tmp, "dash.md",
                     "| M\u00e9trica | Valor |\n|---|---|\n| Bugs abiertos | 0 |\n")
    d = mod.leer_registro(_escribir(tmp, "limpio.md", FIXTURE_LIMPIO), dash)
    tipos = d["metricas"]["defectos_por_tipo"]
    assert tipos.get("dashboard_divergente") == 1, \
        "dashboard 0 vs 2 no resueltos -> 1 defecto, medido %s" % tipos.get(
            "dashboard_divergente")


def test_dashboard_coincidente_no_marca():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    dash = _escribir(tmp, "dash.md", "| M\u00e9trica | Valor |\n|---|---|\n| Bugs abiertos | 2 |\n")
    d = mod.leer_registro(_escribir(tmp, "limpio.md", FIXTURE_LIMPIO), dash)
    assert "dashboard_divergente" not in d["metricas"]["defectos_por_tipo"], \
        "un dashboard que coincide NO debe marcar defecto (control negativo)"


def test_json_puro():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    ruta = _escribir(tmp, "limpio.md", FIXTURE_LIMPIO)
    rc, salida = _correr(["--archivo", ruta, "--dashboard", "", "--json"])
    assert rc == 0, "exit 0, medido %d" % rc
    obj = json.loads(salida)   # si trae adornos, esto lanza ValueError
    assert obj["metricas"]["filas_tabla"] == 3, "filas en el JSON: %s" % obj["metricas"][
        "filas_tabla"]
    assert salida.strip().startswith("{"), "el JSON empieza con '{', no con texto"


def test_check_exit_codes():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    limpio = _escribir(tmp, "limpio.md", FIXTURE_LIMPIO)
    rc, _ = _correr(["--archivo", limpio, "--dashboard", "", "--check"])
    assert rc == 0, "limpio --check -> 0, medido %d" % rc
    roto = _escribir(tmp, "roto.md", FIXTURE_LIMPIO.replace("[ ] Abierto", "Abierto"))
    rc, _ = _correr(["--archivo", roto, "--dashboard", "", "--check"])
    assert rc == 1, "con defectos --check -> 1, medido %d" % rc
    rc, _ = _correr(["--archivo", limpio, "--flag-que-no-existe"])
    assert rc == 2, "flag invalido -> 2, medido %d" % rc


def test_reporte_markdown_utf8_sin_bom():
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    limpio = _escribir(tmp, "limpio.md", FIXTURE_LIMPIO)
    destino = os.path.join(tmp, "informe.md")
    rc, _ = _correr(["--archivo", limpio, "--dashboard", "", "--report", destino])
    assert rc == 0, "exit 0, medido %d" % rc
    crudo = io.open(destino, "rb").read()
    assert not crudo.startswith(b"\xef\xbb\xbf"), "el informe no debe llevar BOM"
    texto = crudo.decode("utf-8")
    assert "| Filas en la tabla resumen (seccion 5) | 3 |" in texto, \
        "el informe cita el total medido"
    assert "\r" not in texto, "el informe se escribe con LF (sin CR)"


# --- registro REAL: solo invariantes --------------------------------------

def test_registro_real_invariantes():
    assert REGISTRO_REAL.is_file(), "no existe %s" % REGISTRO_REAL
    d = mod.leer_registro(str(REGISTRO_REAL), None)
    assert d["ciego"] is None, "el registro real no debe ser ciego: %s" % d["ciego"]
    m = d["metricas"]
    assert m["filas_tabla"] > 0, "filas > 0 (medido %d)" % m["filas_tabla"]
    assert m["entradas"] > 0, "entradas > 0 (medido %d)" % m["entradas"]
    suma = sum(m["por_estado"].values())
    assert suma <= m["filas_tabla"], \
        "la suma de estados (%d) no puede superar las filas (%d)" % (suma, m["filas_tabla"])
    assert m["ids_unicos_tabla"] <= m["filas_tabla"], "ids unicos <= filas"
    assert m["ids_unicos_registro"] >= m["ids_unicos_tabla"], \
        "la union tabla+entradas no puede tener menos ids que la tabla"
    assert m["id_max"] >= 1, "id maximo >= 1"
    for n in m["huecos"]:
        assert 1 <= n <= m["id_max"], "hueco %d fuera de rango" % n
    # los huecos "ausentes" son un subconjunto de los huecos: si no, la
    # clasificacion se inventa numeros.
    assert set(m["huecos_ausentes"]) <= set(m["huecos"]), \
        "huecos_ausentes debe ser subconjunto de huecos"
    assert set(m["huecos_mencionados"]) <= set(m["huecos"]), \
        "huecos_mencionados debe ser subconjunto de huecos"


def test_registro_real_defectos_no_mudos():
    """Todo defecto declara tipo, linea y detalle: un defecto mudo no se puede accionar."""
    d = mod.leer_registro(str(REGISTRO_REAL), None)
    for defecto in d["defectos"]:
        assert defecto.get("tipo"), "defecto sin tipo: %r" % defecto
        assert defecto.get("detalle"), "defecto sin detalle: %r" % defecto
        assert isinstance(defecto.get("linea"), int), "defecto sin linea: %r" % defecto
    tipos = d["metricas"]["defectos_por_tipo"]
    assert sum(tipos.values()) == len(d["defectos"]), \
        "el resumen por tipo (%d) no cuadra con los defectos (%d)" % (
            sum(tipos.values()), len(d["defectos"]))


def test_registro_real_es_estable():
    """Dos lecturas seguidas dan los mismos conteos (no hay estado oculto)."""
    a = mod.leer_registro(str(REGISTRO_REAL), None)["metricas"]
    b = mod.leer_registro(str(REGISTRO_REAL), None)["metricas"]
    assert a["filas_tabla"] == b["filas_tabla"], "filas inestables"
    assert a["por_estado"] == b["por_estado"], "por_estado inestable"
    assert a["defectos_por_tipo"] == b["defectos_por_tipo"], "defectos inestables"


# --- inyeccion EN ROJO ----------------------------------------------------

def test_inyeccion_roja_detecta():
    """El detector discrimina: una corrupcion sube los defectos de 0 a 1."""
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    limpio = _escribir(tmp, "limpio.md", FIXTURE_LIMPIO)
    d0 = mod.leer_registro(limpio, None)
    assert len(d0["defectos"]) == 0, "linea base: 0 defectos, medido %d" % len(d0["defectos"])
    inyectado = _escribir(tmp, "inyectado.md",
                          FIXTURE_LIMPIO.replace("[?] Delegado", "sin estado"))
    d1 = mod.leer_registro(inyectado, None)
    assert len(d1["defectos"]) == 1, \
        "con la inyeccion: 1 defecto, medido %d (%s)" % (
            len(d1["defectos"]), d1["metricas"]["defectos_por_tipo"])
    assert d1["defectos"][0]["tipo"] == "estado_desconocido", \
        "el tipo detectado es estado_desconocido, medido %s" % d1["defectos"][0]["tipo"]


# --- gate de CI: deuda conocida ------------------------------------------

def test_gate_verde_sin_defectos():
    """Control negativo: registro limpio -> gate verde, exit 0."""
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    d = mod.leer_registro(_escribir(tmp, "limpio.md", FIXTURE_LIMPIO), None)
    codigo, lineas = mod._gate(d, {})
    assert codigo == 0, "limpio -> exit 0, medido %d (%s)" % (codigo, lineas)
    assert any("GATE VERDE" in l for l in lineas), "el veredicto verde se declara: %s" % lineas


def test_gate_rojo_nombra_el_defecto():
    """El gate discrimina y NOMBRA: tipo + firma + linea del defecto nuevo."""
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    roto = _escribir(tmp, "roto.md", FIXTURE_LIMPIO.replace("[?] Delegado", "sin estado"))
    d = mod.leer_registro(roto, None)
    codigo, lineas = mod._gate(d, {})
    texto = "\n".join(lineas)
    assert codigo == 1, "con 1 defecto nuevo -> exit 1, medido %d" % codigo
    assert "GATE ROJO" in texto, "el veredicto rojo se declara"
    assert "estado_desconocido" in texto, "nombra el TIPO del defecto nuevo: %s" % texto
    assert "estado_desconocido:BUG-003" in texto, "nombra la FIRMA del defecto nuevo"
    assert "L" in texto, "nombra la LINEA del defecto nuevo"


def test_gate_verde_con_deuda_conocida():
    """El baseline conocido NO bloquea: es el punto del patron (b)."""
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    roto = _escribir(tmp, "roto.md", FIXTURE_LIMPIO.replace("[?] Delegado", "sin estado"))
    d = mod.leer_registro(roto, None)
    deuda = {x["firma"]: "fixture" for x in d["defectos"]}
    codigo, lineas = mod._gate(d, deuda)
    assert codigo == 0, "defecto ya conocido -> exit 0, medido %d" % codigo


def test_gate_rojo_si_se_repite_una_firma_conocida():
    """Agujero del multiset: 2 defectos con la MISMA firma, 1 en el baseline.

    Si el gate comparase CONJUNTOS en vez de multiset, la repeticion pasaria
    invisible y el baseline se volveria una amnistia.
    """
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    fila = "| BUG-002 | Dos | M20 | \U0001F7E1 Menor | [ ] Abierto | beta | 2026-01-02 |"
    doble = FIXTURE_LIMPIO.replace(
        fila, fila.replace("| beta |", "| be|ta |") + "\n" + fila.replace("| beta |", "| be|ta |"))
    d = mod.leer_registro(_escribir(tmp, "doble.md", doble), None)
    malformadas = [x for x in d["defectos"] if x["firma"] == "fila_malformada:BUG-002"]
    assert len(malformadas) == 2, "2 defectos con la misma firma, medido %d" % len(malformadas)
    codigo, lineas = mod._gate(d, {"fila_malformada:BUG-002": "fixture"})
    assert codigo == 1, "la 2a ocurrencia es NUEVA -> exit 1, medido %d" % codigo


def test_gate_avisa_deuda_obsoleta():
    """Una firma de deuda que ya no aparece se declara, pero NO rompe el gate."""
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    d = mod.leer_registro(_escribir(tmp, "limpio.md", FIXTURE_LIMPIO), None)
    codigo, lineas = mod._gate(d, {"fila_sin_entrada:BUG-999": "ya reparado"})
    texto = "\n".join(lineas)
    assert codigo == 0, "la deuda resuelta NO es un fallo, medido %d" % codigo
    assert "AVISO" in texto and "fila_sin_entrada:BUG-999" in texto, \
        "declara la firma obsoleta: %s" % texto


def test_firma_estable_ante_corrimiento_de_lineas():
    """La firma no depende del numero de linea (si no, cada fix vecino da rojo)."""
    tmp = tempfile.mkdtemp(prefix="t_metricas_")
    roto = FIXTURE_LIMPIO.replace("[?] Delegado", "sin estado")
    a = [x for x in mod.leer_registro(_escribir(tmp, "a.md", roto), None)["defectos"]]
    corrido = "linea nueva al principio\n\n" + roto
    b = [x for x in mod.leer_registro(_escribir(tmp, "b.md", corrido), None)["defectos"]]
    assert len(a) == len(b) == 1, "1 defecto en los dos, medido %d/%d" % (len(a), len(b))
    assert a[0]["firma"] == b[0]["firma"], "firma estable: %s vs %s" % (a[0]["firma"], b[0]["firma"])
    assert a[0]["linea"] != b[0]["linea"], "y las lineas SI cambian (control positivo)"


def test_literal_deuda_es_pegable():
    """`--deuda` imprime un dict Python valido, con una entrada por firma."""
    d = mod.leer_registro(str(REGISTRO_REAL), None)
    literal = mod.literal_deuda(d)
    arbol = ast.parse(literal)   # si el literal no es Python valido, esto lanza
    assert isinstance(arbol.body[0], ast.Assign), "el literal es una ASIGNACION"
    obj = ast.literal_eval(arbol.body[0].value)
    assert isinstance(obj, dict), "el literal evalua a dict, dio %r" % type(obj)
    assert set(obj) == {x["firma"] for x in d["defectos"]}, \
        "una entrada por firma medida (%d vs %d)" % (
            len(obj), len({x["firma"] for x in d["defectos"]}))
    assert all(v.strip() for v in obj.values()), "ninguna firma sin motivo"


def test_deuda_real_tiene_formato():
    """Cada clave del baseline es `tipo:identidad`, y cada valor nombra un dueno."""
    assert mod.DEUDA_CONOCIDA, "el baseline no puede estar vacio (seria un gate ciego)"
    for firma, motivo in mod.DEUDA_CONOCIDA.items():
        assert firma.count(":") == 1, "firma mal formada: %r" % firma
        assert motivo.strip(), "firma sin motivo: %r" % firma


def test_gate_verde_sobre_el_registro_real():
    """Invariante de CI: el baseline de hoy cubre el registro de hoy.

    Se lee CON el dashboard por defecto, igual que el workflow: si esto falla,
    el gate del CI nace ROJO y el CI se apaga solo.

    La obsolescencia de una firma NO se congela aca a proposito: el dashboard de
    GitHub Issues puede cambiar de estado sin que el registro tenga un defecto
    nuevo, y convertir ese aviso en fallo pondria en rojo el trabajo de otro
    agente. El gate lo declara como AVISO; limpiarlo es higiene, no invariante.
    """
    d = mod.leer_registro(str(REGISTRO_REAL))
    codigo, lineas = mod._gate(d)
    texto = "\n".join(lineas)
    assert codigo == 0, "gate real -> exit 0, medido %d: %s" % (codigo, "\n".join(lineas[:6]))
    assert "GATE ROJO" not in texto, "hay defectos NUEVOS sin declarar: %s" % texto


def test_check_json_no_contamina_stdout():
    """--json --check: el stdout sigue siendo SOLO JSON; el veredicto va a stderr."""
    rc, salida = _correr(["--json", "--check"])
    assert rc == 0, "gate real verde -> 0, medido %d" % rc
    obj = json.loads(salida)
    assert obj["metricas"]["defectos_por_tipo"], "el JSON trae los defectos medidos"


def test_piso_de_checks():
    """El piso se verifica a si mismo: si la suite se recorta, esto falla.

    El `+1` es este propio check: cuando corre, todavia no se conto a si mismo.
    """
    assert PASS + FAIL + 1 >= CHECKS_MINIMOS, \
        "solo %d checks ejecutados (minimo %d)" % (PASS + FAIL + 1, CHECKS_MINIMOS)


def main():
    print("=" * 68)
    print("SUITE — scripts/metricas_bugs.py (M102, Log 2080)")
    print("=" * 68)
    print()
    test("fixture limpio: 0 defectos", test_limpio_sin_defectos)
    test("los agregados cuadran con las filas", test_agregados_cuadran)
    test("estado sin marca [x] se declara y se cuenta igual",
         test_estado_sin_marca_se_declara)
    test("fila malformada por pipe sin escapar", test_fila_malformada_se_declara)
    test("drift tabla <-> entradas en las dos direcciones",
         test_entrada_sin_fila_y_fila_sin_entrada)
    test("id duplicado en la tabla", test_id_duplicado_tabla)
    test("encabezado de seccion pegado", test_seccion_pegada)
    test("etiquetas de severidad inconsistentes", test_etiqueta_severidad_inconsistente)
    test("registro sin tabla resumen -> ciego (exit 3)", test_ciego_sin_tabla)
    test("archivo inexistente -> ciego (exit 3)", test_archivo_inexistente_es_ciego)
    test("dashboard divergente se declara", test_dashboard_divergente)
    test("dashboard coincidente NO se marca (control negativo)",
         test_dashboard_coincidente_no_marca)
    test("--json imprime SOLO JSON", test_json_puro)
    test("codigos de salida 0/1/2", test_check_exit_codes)
    test("informe markdown UTF-8 sin BOM y con LF", test_reporte_markdown_utf8_sin_bom)
    test("registro real: invariantes de los agregados", test_registro_real_invariantes)
    test("registro real: ningun defecto mudo", test_registro_real_defectos_no_mudos)
    test("registro real: dos lecturas dan lo mismo", test_registro_real_es_estable)
    test("INYECCION EN ROJO: el detector discrimina", test_inyeccion_roja_detecta)
    test("gate: registro limpio -> verde", test_gate_verde_sin_defectos)
    test("gate: defecto nuevo -> ROJO nombrando tipo+linea", test_gate_rojo_nombra_el_defecto)
    test("gate: la deuda conocida no bloquea", test_gate_verde_con_deuda_conocida)
    test("gate: una 2a ocurrencia de la misma firma SI bloquea",
         test_gate_rojo_si_se_repite_una_firma_conocida)
    test("gate: deuda obsoleta se avisa sin romper", test_gate_avisa_deuda_obsoleta)
    test("firma estable ante corrimiento de lineas", test_firma_estable_ante_corrimiento_de_lineas)
    test("--deuda imprime un literal pegable", test_literal_deuda_es_pegable)
    test("DEUDA_CONOCIDA: formato y motivo", test_deuda_real_tiene_formato)
    test("gate VERDE sobre el registro real (invariante de CI)",
         test_gate_verde_sobre_el_registro_real)
    test("--json --check no contamina stdout", test_check_json_no_contamina_stdout)
    test("piso de checks ejecutados", test_piso_de_checks)
    print()
    print("=" * 68)
    print("RESULTADO: %d PASS, %d FAIL" % (PASS, FAIL))
    print("=" * 68)
    return 1 if FAIL else 0


if __name__ == "__main__":
    sys.exit(main())
