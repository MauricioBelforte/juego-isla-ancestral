#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Suite del muestreador P-100 (scripts/muestreo_p100.py).

Protege las cuatro cosas que hacen util al muestreador:
  1. CONTEO POR PREFIJO: una linea `- [ ] ... [x]` cuenta como PENDIENTE, no como
     completada (el conteo por substring infla).
  2. POBLACION CORRECTA: los items de diseno/meta ("Definir...", "Documentar...")
     NO entran a la muestra automatica; los de creacion SI.
  3. RESOLUCION HONESTA: un artefacto que existe con otro nombre (03-Diseno.md ->
     3-DOCUMENTO-DISENO-ACTUAL.md) cuenta como existente (VARIANTE); uno que no
     existe en ninguna base NI variante da HUECO.
  4. NO CEGUERA: modulo inexistente -> exit 3, nunca 0.

Correr:
  python scripts/test_muestreo_p100.py

Exit 0 si todo pasa, 1 si algo falla.
"""

from __future__ import annotations

import io
import os
import shutil
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import muestreo_p100 as mod  # noqa: E402

# Piso de checks MEDIDO en verde (no estimado). Se evalua ANTES de contarse a si
# mismo, asi que no puede incluirse en su propio conteo.
CHECKS_MINIMOS = 60

_checks = 0
_fallos = 0
_guard = {"fin": False, "bloques": [], "abiertos": []}


def _ok(cond, msg):
    global _checks, _fallos
    _checks += 1
    if cond:
        print("  [ok] %s" % msg)
    else:
        _fallos += 1
        print("  FALLO: %s" % msg)


def _bloque(desc):
    _guard["abiertos"].append(desc)
    print("-- %s" % desc)


def _cerrar(desc):
    if _guard["abiertos"] and _guard["abiertos"][-1] == desc:
        _guard["bloques"].append(_guard["abiertos"].pop())
    else:
        print("  FALLO: cierre de bloque fuera de orden (%s)" % desc)
        global _fallos
        _fallos += 1


def _escribir(base, rel, contenido):
    ruta = os.path.join(base, rel.replace("/", os.sep))
    d = os.path.dirname(ruta)
    if d:
        os.makedirs(d, exist_ok=True)
    with io.open(ruta, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(contenido)
    return ruta


# ---------------------------------------------------------------- fixtures ---
FIX_DOC = """# 05 Checklist fixture

- [x] Implementar `scripts/foo/bar.gd` con el flujo completo [M]
- [ ] Pendiente que menciona `- [x]` literal en el texto pero NO esta hecha [S]
- [x] Definir el problema: esto es diseno, no creacion [S]
- [x] Crear `AlphaServicioBeta` y cablearlo [M]
- [x] Agregar `fantasma_inexistente.gd` al pipeline [S]
- [x] Generar `03-Diseno.md` con la seccion nueva [S]
- [x] Escribir doc sin cita de ningun artefacto [S]
- [?] Duda sin resolver [M]

**Totales:** 8 ítems · Completados: 6 · Pendientes: 1 · No resueltos: 1.
"""


def _montar_fixture(base):
    """Repo de mentira con la forma minima que el muestreador espera."""
    _escribir(base, "DOCUMENTACION/48-Fixture/plan-actual/05-Checklist.md", FIX_DOC)
    _escribir(base, "DOCUMENTACION/01-Fundamentos/plan-actual/03-Diseno.md", "# diseno\n")
    _escribir(base, "game/isla-ancestral/scripts/foo/bar.gd",
              "extends Node\nclass_name AlphaServicioBeta\n")
    os.makedirs(os.path.join(base, "game", "isla-ancestral", "tests"), exist_ok=True)
    os.makedirs(os.path.join(base, "Logs"), exist_ok=True)
    os.makedirs(os.path.join(base, "docs"), exist_ok=True)
    os.makedirs(os.path.join(base, "scripts"), exist_ok=True)


class _Parche(object):
    """Redirige las constantes del modulo a un repo temporal."""

    def __init__(self, base):
        self.base = base
        self.prev = {}

    def __enter__(self):
        self.prev = dict(
            RAIZ=mod.RAIZ, DOC=mod.DOC, RAIZ_JUEGO=mod.RAIZ_JUEGO,
            RAICES_PATH=mod.RAICES_PATH, RAICES_GREP=mod.RAICES_GREP,
            _IDX=mod._IDX)
        mod.RAIZ = self.base
        mod.DOC = os.path.join(self.base, "DOCUMENTACION")
        mod.RAIZ_JUEGO = os.path.join(self.base, "game", "isla-ancestral")
        mod.RAICES_PATH = (mod.RAIZ_JUEGO, self.base,
                           os.path.join(self.base, "game"), mod.DOC)
        mod.RAICES_GREP = (os.path.join(mod.RAIZ_JUEGO, "scripts"),
                           os.path.join(mod.RAIZ_JUEGO, "tests"))
        mod._IDX = None
        return self

    def __exit__(self, *a):
        mod.RAIZ = self.prev["RAIZ"]
        mod.DOC = self.prev["DOC"]
        mod.RAIZ_JUEGO = self.prev["RAIZ_JUEGO"]
        mod.RAICES_PATH = self.prev["RAICES_PATH"]
        mod.RAICES_GREP = self.prev["RAICES_GREP"]
        mod._IDX = self.prev["_IDX"]
        return False


# ------------------------------------------------------------------ bloques ---
def test_conteo_por_prefijo():
    _bloque("conteo por PREFIJO (no por substring)")
    lineas = FIX_DOC.split("\n")
    c = mod.contar_marcas(lineas)
    _ok(c["x"] == 6, "cuenta 6 [x] (dio %d)" % c["x"])
    _ok(c[" "] == 1, "cuenta 1 [ ] (dio %d)" % c[" "])
    _ok(c["?"] == 1, "cuenta 1 [?] (dio %d)" % c["?"])
    # la trampa: la linea [ ] contiene un literal "[x]" en el texto
    pend = [ln for ln in lineas if ln.startswith("- [ ]")]
    _ok(len(pend) == 1 and "- [x]" in pend[0], "la linea pendiente SI contiene el literal - [x]")
    _ok(c["x"] != FIX_DOC.count("- [x]"),
        "el conteo por prefijo difiere del conteo por substring (%d vs %d)"
        % (c["x"], FIX_DOC.count("[x]")))
    _ok(mod.contar_marcas([]) == {"x": 0, " ": 0, "?": 0}, "lista vacia -> ceros")
    _cerrar("conteo por PREFIJO (no por substring)")


def test_es_creacion():
    _bloque("poblacion: creacion vs diseno/meta")
    _ok(mod.es_creacion("Implementar el servicio X"), "Implementar = creacion")
    _ok(mod.es_creacion("Agregar el flag Y"), "Agregar = creacion")
    _ok(not mod.es_creacion("Definir el problema: sin sistema"), "Definir NO es creacion")
    _ok(not mod.es_creacion("Documentar integracion con M64/M65"), "Documentar NO es creacion")
    _ok(not mod.es_creacion("Mapear la seccion 47 al ID 48"), "Mapear NO es creacion")
    _ok(not mod.es_creacion(""), "texto vacio -> False")
    _cerrar("poblacion: creacion vs diseno/meta")


def test_artefactos():
    _bloque("extraccion de artefactos")
    rutas, idents = mod.extraer_artefactos("Implementar `scripts/foo/bar.gd` y `AlphaServicioBeta`")
    _ok("scripts/foo/bar.gd" in rutas, "extrae la ruta del backtick")
    _ok("AlphaServicioBeta" in idents, "extrae el identificador CamelCase")
    rutas2, _ = mod.extraer_artefactos("ver jugador_lib.tres 3 clips")
    _ok("jugador_lib.tres" in rutas2, "extrae archivo desnudo fuera de backticks")
    rutas3, idents3 = mod.extraer_artefactos("texto sin nada citable")
    _ok(rutas3 == [] and idents3 == [], "texto sin artefactos -> listas vacias")
    _, idents4 = mod.extraer_artefactos("`foo()` y `x`")
    _ok(idents4 == [], "identificadores demasiado cortos se descartan")
    rutas5, _ = mod.extraer_artefactos("`a.gd` y `a.gd`")
    _ok(rutas5 == ["a.gd"], "deduplica artefactos repetidos")
    _cerrar("extraccion de artefactos")


def test_resolver(base):
    _bloque("resolucion de rutas: DIRECTO / BASENAME / VARIANTE / HUECO")
    p, modo = mod.resolver_path("scripts/foo/bar.gd")
    _ok(p is not None and modo == "DIRECTO", "ruta directa -> DIRECTO (%s)" % modo)
    p, modo = mod.resolver_path("bar.gd")
    _ok(p is not None and modo == "BASENAME", "solo basename -> BASENAME (%s)" % modo)
    p, modo = mod.resolver_path("03-Diseno.md")
    _ok(p is not None, "03-Diseno.md existe (resuelto como %s)" % modo)
    _ok(p is not None and "03-Diseno.md" in p, "y apunta al archivo real")
    p, modo = mod.resolver_path("fantasma_inexistente.gd")
    _ok(p is None and modo is None, "archivo inexistente -> (None, None)")
    p, modo = mod.resolver_path("res://scripts/foo/bar.gd")
    _ok(p is not None, "tolera el prefijo res://")
    p, modo = mod.resolver_path("DOCUMENTACION/48-Fixture/plan-actual")
    _ok(p is not None and os.path.isdir(p), "acepta un DIRECTORIO como artefacto")
    _cerrar("resolucion de rutas: DIRECTO / BASENAME / VARIANTE / HUECO")


def test_grep():
    _bloque("grep de identificadores")
    n = mod.grep_identificador("AlphaServicioBeta")
    _ok(n >= 1, "identificador real -> >=1 archivo (%d)" % n)
    n0 = mod.grep_identificador("ZzNoExisteJamasZz")
    _ok(n0 == 0, "identificador inventado -> 0 archivos (%d)" % n0)
    _ok(mod.grep_identificador("AlphaServicio") == 0,
        "un PREFIJO no cuenta como hit (frontera de palabra)")
    _cerrar("grep de identificadores")


def test_muestreo():
    _bloque("muestreo determinista")
    items = [(i, "item%d" % i) for i in range(100)]
    a = mod.muestreo_determinista(items, 5)
    b = mod.muestreo_determinista(items, 5)
    _ok(a == b, "dos corridas dan la MISMA muestra (reproducible)")
    _ok(len(a) == 5, "devuelve exactamente n (%d)" % len(a))
    _ok(a[0][0] == 0, "arranca en el primero")
    _ok(a == sorted(a), "la muestra esta en orden de aparicion")
    _ok(mod.muestreo_determinista([], 5) == [], "poblacion vacia -> muestra vacia")
    _ok(len(mod.muestreo_determinista(items[:3], 5)) == 3, "n > poblacion -> toda la poblacion")
    _cerrar("muestreo determinista")


def test_verificar_item():
    _bloque("veredicto por item")
    v = mod.verificar_item("Implementar `scripts/foo/bar.gd`")
    _ok(v["resultado"] == "RESUELTO", "ruta existente -> RESUELTO (%s)" % v["resultado"])
    v = mod.verificar_item("Agregar `fantasma_inexistente.gd`")
    _ok(v["resultado"] == "HUECO", "ruta inexistente -> HUECO (%s)" % v["resultado"])
    v = mod.verificar_item("Crear `scripts/foo/bar.gd` y `fantasma_x.gd`")
    _ok(v["resultado"] == "PARCIAL", "una ok y una falta -> PARCIAL (%s)" % v["resultado"])
    v = mod.verificar_item("Escribir doc sin cita")
    _ok(v["resultado"] == "INDETERMINADO", "sin artefacto -> INDETERMINADO (%s)" % v["resultado"])
    v = mod.verificar_item("Crear `AlphaServicioBeta`")
    _ok(v["resultado"] == "RESUELTO", "identificador con grep>0 -> RESUELTO")
    _cerrar("veredicto por item")


def test_totales():
    _bloque("lectura de la linea Totales")
    t = mod.leer_totales(FIX_DOC.split("\n"))
    _ok(t is not None and t["total"] == 8, "total leido (8)")
    _ok(t["x"] == 6 and t["vacio"] == 1 and t["q"] == 1, "x/vacio/q leidos")
    doble = ["**Totales:** 10 ítems · Completados: 1 · Pendientes: 9 · No resueltos: 0.",
             "**Totales:** 10 ítems · Completados: 9 · Pendientes: 1 · No resueltos: 0."]
    _ok(mod.leer_totales(doble)["x"] == 9, "con dos lineas Totales gana la ULTIMA")
    _ok(mod.leer_totales(["nada"]) is None, "sin linea Totales -> None")
    _cerrar("lectura de la linea Totales")


def test_modulo(base):
    _bloque("analisis completo de un modulo (fixture)")
    r = mod.analizar_modulo("48", 5)
    _ok("error" not in r, "encuentra el 05 del fixture")
    _ok(r["marcas"]["x"] == 6, "marcas reales 6 [x] (dio %d)" % r["marcas"]["x"])
    _ok(r["drift"] is not None, "calcula drift")
    _ok(r["drift"]["delta_total"] == 0, "fixture sin drift de total")
    _ok(r["drift"]["delta_x"] == 0, "fixture sin drift de x")
    _ok(r["huecos"] == 1, "detecta el unico HUECO de la muestra (dio %d)" % r["huecos"])
    _ok(r["veredicto"] == "CAVEAT", "1 hueco -> CAVEAT (%s)" % r["veredicto"])
    _ok(r["n_req"] == 5, "requisito = 5 para 6 [x] (dio %d)" % r["n_req"])
    # los items de diseno NO entran a la poblacion de creacion
    textos = " ".join(f["texto"] for f in r["muestra"])
    _ok("Definir el problema" not in textos, "un item 'Definir...' NO entra a la muestra")
    _cerrar("analisis completo de un modulo (fixture)")


def test_veredicto_deniega():
    _bloque("2+ huecos DENIEGAN el sello (21.8.2.b punto 3)")
    base = tempfile.mkdtemp(prefix="p100rojo_")
    try:
        doc = ("- [x] Agregar `no_existe_a.gd`\n"
               "- [x] Agregar `no_existe_b.gd`\n"
               "- [x] Agregar `no_existe_c.gd`\n"
               "- [x] Agregar `no_existe_d.gd`\n"
               "- [x] Agregar `no_existe_e.gd`\n")
        _escribir(base, "DOCUMENTACION/48-Rojo/plan-actual/05-Checklist.md", doc)
        os.makedirs(os.path.join(base, "game", "isla-ancestral", "scripts"), exist_ok=True)
        with _Parche(base):
            r = mod.analizar_modulo("48", 5)
        _ok(r["huecos"] == 5, "5 huecos detectados (dio %d)" % r["huecos"])
        _ok(r["veredicto"] == "DISCREPANCIA", "veredicto DISCREPANCIA (%s)" % r["veredicto"])
    finally:
        shutil.rmtree(base, ignore_errors=True)
    _cerrar("2+ huecos DENIEGAN el sello (21.8.2.b punto 3)")


def test_drift_detectado():
    _bloque("drift de Totales detectado (M55 real: 67/49/15 vs 123/6/2)")
    base = tempfile.mkdtemp(prefix="p100drift_")
    try:
        doc = ("- [x] Agregar `x1.gd`\n- [x] Agregar `x2.gd`\n- [x] Agregar `x3.gd`\n"
               "- [ ] pendiente\n- [?] duda\n"
               "**Totales:** 5 ítems · Completados: 1 · Pendientes: 3 · No resueltos: 1.\n")
        _escribir(base, "DOCUMENTACION/55-Drift/plan-actual/05-Checklist.md", doc)
        os.makedirs(os.path.join(base, "game", "isla-ancestral", "scripts"), exist_ok=True)
        with _Parche(base):
            r = mod.analizar_modulo("55", 5)
        _ok(r["drift"]["delta_x"] == 1 - 3, "delta_x = declarado - real = -2 (dio %d)"
            % r["drift"]["delta_x"])
        _ok(r["drift"]["delta_total"] == 0, "el total si coincide (delta 0)")
    finally:
        shutil.rmtree(base, ignore_errors=True)
    _cerrar("drift de Totales detectado (M55 real: 67/49/15 vs 123/6/2)")


def test_ceguera():
    _bloque("detector ciego: modulo inexistente -> exit 3")
    r = mod.analizar_modulo("999", 5)
    _ok(r.get("error") == "SIN 05 EN DISCO", "reporta SIN 05 EN DISCO")
    cod = mod.main(["--modulo", "999"])
    _ok(cod == 3, "main devuelve 3 (dio %d)" % cod)
    cod = mod.main([])
    _ok(cod == 3, "sin argumentos devuelve 3 (dio %d)" % cod)
    _cerrar("detector ciego: modulo inexistente -> exit 3")


def test_no_escribe():
    _bloque("el muestreador es READ-ONLY")
    p = os.path.join(mod.DOC, "48-Animacion", "plan-actual", "05-Checklist.md")
    antes = os.path.getmtime(p) if os.path.isfile(p) else None
    tam = os.path.getsize(p) if os.path.isfile(p) else None
    mod.main(["--modulo", "48", "--quiet"])
    despues = os.path.getmtime(p) if os.path.isfile(p) else None
    tam2 = os.path.getsize(p) if os.path.isfile(p) else None
    _ok(antes == despues and tam == tam2, "no modifica el 05-Checklist real")
    _cerrar("el muestreador es READ-ONLY")


def main():
    print("=== SUITE: muestreo P-100 (21.8.2.b) ===")
    base = tempfile.mkdtemp(prefix="p100_")
    try:
        _montar_fixture(base)
        test_conteo_por_prefijo()
        test_es_creacion()
        test_artefactos()
        with _Parche(base):
            test_resolver(base)
            test_grep()
        test_muestreo()
        with _Parche(base):
            test_verificar_item()
            test_modulo(base)
        test_totales()
        test_veredicto_deniega()
        test_drift_detectado()
        test_ceguera()
        test_no_escribe()
    finally:
        shutil.rmtree(base, ignore_errors=True)

    # Capa 3: si un bloque quedo abierto, la suite NO puede declararse verde.
    if _guard["abiertos"]:
        print("  FALLO: bloques sin cerrar: %s" % _guard["abiertos"])
        global _fallos
        _fallos += 1
    _guard["fin"] = True
    print("")
    print("=== RESUMEN MUESTREO P-100: %d checks, %d fallos, %d bloques cerrados ==="
          % (_checks, _fallos, len(_guard["bloques"])))
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
