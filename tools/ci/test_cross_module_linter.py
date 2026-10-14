#!/usr/bin/env python3
"""Tests del cross_module_linter (M118).

Verifican el fix del 2026-10-12 (step-5-kilocode, orden del director mimo
msg 232): `detect_broken_refs` ya no debe marcar como "referencia desconocida"
los usos validos de `$` en Godot 4.

    * `@onready var x = $Nodo`          -> nodo hijo de escena
    * `register_hud($UI)`               -> nodo pasado como argumento
    * `s += "$BuildDir = ..."`          -> interpolacion dentro de un string

Y `detect_cycles` debe seguir detectando ciclos reales.

Ejecutar:  python tools/ci/test_cross_module_linter.py
"""

import os
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import cross_module_linter as L  # noqa: E402

_checks = 0
_fallos = 0


def ok(nombre, cond):
    global _checks, _fallos
    _checks += 1
    if cond:
        print("  [OK]   %s" % nombre)
    else:
        _fallos += 1
        print("  [FALLO] %s" % nombre)


def _escribir(directorio, nombre, contenido):
    ruta = os.path.join(directorio, nombre)
    with open(ruta, "w", encoding="utf-8") as fp:
        fp.write(contenido)
    return ruta


def test_strip_strings():
    print("-- 1. _strip_strings elimina contenido de strings --")
    ok("string doble se vacia",
       L._strip_strings('s += "$BuildDir = x"') == 's += ""')
    ok("string simple se vacia",
       L._strip_strings("var a = 'texto $Relleno'") == "var a = ''")
    ok("codigo fuera del string se conserva",
       "$Nodo" in L._strip_strings('var x = "y"; $Nodo'))
    ok("linea sin strings queda igual",
       L._strip_strings("@onready var x = $Nodo") == "@onready var x = $Nodo")


def test_broken_refs_sin_falsos_positivos():
    print("-- 2. detect_broken_refs: 0 falsos positivos --")
    with tempfile.TemporaryDirectory() as d:
        _escribir(d, "a.gd", "@onready var fps_label = $UI/FPSLabel\n")
        _escribir(d, "b.gd", "func _ready():\n\t_tab_bar = $RootPanel/TabBar\n")
        _escribir(d, "c.gd", 'func f():\n\ts += "$BuildDir = \\"x\\""\n')
        _escribir(d, "d.gd", "ui_manager.register_hud($UI)\n")
        archivos = [os.path.join(d, n) for n in ("a.gd", "b.gd", "c.gd", "d.gd")]
        issues = L.detect_broken_refs(archivos, {}, {"UI", "RootPanel"})
        ok("no reporta ninguno de los 4 usos validos", len(issues) == 0)
        if issues:
            for i in issues:
                print("       ->", i)


def test_broken_refs_sigue_vacio():
    print("-- 3. detect_broken_refs documentado como desactivado --")
    with tempfile.TemporaryDirectory() as d:
        _escribir(d, "x.gd", "var y = AlgoRaro.new()\n")
        issues = L.detect_broken_refs([os.path.join(d, "x.gd")], {}, set())
        ok("retorna vacio (por diseno, ver docstring)", issues == [])
        ok("el docstring explica el por que",
           "POR QUE RETORNA VACIO" in L.detect_broken_refs.__doc__)


def test_cycles():
    print("-- 4. detect_cycles detecta ciclos reales --")
    grafo = {
        "a.gd": {"b.gd"},
        "b.gd": {"c.gd"},
        "c.gd": {"a.gd"},
    }
    ciclos = L.detect_cycles(grafo)
    ok("detecta el ciclo a->b->c->a", len(ciclos) >= 1)
    grafo_ok = {"a.gd": {"b.gd"}, "b.gd": {"c.gd"}, "c.gd": set()}
    ok("sin ciclos retorna vacio", L.detect_cycles(grafo_ok) == [])


def main():
    print("== test_cross_module_linter ==")
    test_strip_strings()
    test_broken_refs_sin_falsos_positivos()
    test_broken_refs_sigue_vacio()
    test_cycles()
    print("")
    print("RESULTADO: %s — %d checks, %d fallos" % (
        "OK" if _fallos == 0 else "FALLO", _checks, _fallos))
    return 0 if _fallos == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
