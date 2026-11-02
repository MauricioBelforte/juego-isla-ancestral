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
CHECKS_MINIMOS = 119

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

# Modulo CIEGO: todo su contenido son enunciados de diseno/meta, sin verbo de
# creacion y sin citar un solo artefacto -> 0 items muestreables por script.
FIX_CIEGO = """# 05 Checklist ciego

- [x] Definir el pitch del juego en una frase [M]
- [x] Documentar la vision a largo plazo [S]

**Totales:** 2 ítems · Completados: 2 · Pendientes: 0 · No resueltos: 0.
"""


def _montar_fixture(base):
    """Repo de mentira con la forma minima que el muestreador espera."""
    _escribir(base, "DOCUMENTACION/48-Fixture/plan-actual/05-Checklist.md", FIX_DOC)
    _escribir(base, "DOCUMENTACION/77-Ciego/plan-actual/05-Checklist.md", FIX_CIEGO)
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
    # Una EXTENSION suelta es un FORMATO, no un archivo: sin este corte el muestreo
    # reporta HUECO "PATH FALTA .tres" (medido 29-oct: 3 huecos falsos en M74).
    rutas6, idents6 = mod.extraer_artefactos("restricciones: recursos `.tres` y scripts `.gd`")
    _ok(rutas6 == [], "extension suelta NO es artefacto (dio %r)" % rutas6)
    _ok(idents6 == [], "extension suelta tampoco es identificador (dio %r)" % idents6)
    rutas7, _ = mod.extraer_artefactos("el catalogo `festivales.tres` esta en disco")
    _ok(rutas7 == ["festivales.tres"], "archivo con nombre real SI se extrae (control)")
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
    # Cita relativa a la RAIZ del modulo: `prefer` es el propio plan-actual, asi que
    # join() daba "plan-actual/plan-actual" y se reportaba PATH FALTA sobre un
    # directorio que EXISTE (falso hueco medido en M40 L260/L253).
    pref = os.path.join(base, "DOCUMENTACION", "48-Fixture", "plan-actual")
    p, modo = mod.resolver_path("plan-actual/", prefer=pref)
    _ok(p is not None and modo == "MODULO_RAIZ",
        "'plan-actual/' desde el modulo -> MODULO_RAIZ (%s)" % modo)
    p, modo = mod.resolver_path("plan-inicial/", prefer=pref)
    _ok(p is None, "control negativo: 'plan-inicial/' no existe en el fixture -> hueco")
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


def test_totales_variantes():
    _bloque("Totales: variantes de unidad (M40 escribe 'lineas-item')")
    # Regresion medida: el regex exigia la palabra "items/ítems" y M40 declara
    # "211 lineas-item" -> el muestreador imprimia "SIN LINEA **Totales:** EN DISCO"
    # sobre un checklist que SI la tenia, y se perdia el cruce contra el disco.
    m40 = ("**Totales:** 211 lineas-item - Completados: 180 - Pendientes: 27 - "
           "No resueltos: 4. (resync director 00:15 23oct, conteo de disco por prefijo)")
    t = mod.leer_totales([m40])
    _ok(t is not None, "M40 'lineas-item' PARSEA (antes daba None)")
    _ok(t is not None and t["total"] == 211, "total=211")
    _ok(t is not None and (t["x"], t["vacio"], t["q"]) == (180, 27, 4),
        "x/vacio/q = 180/27/4")
    t2 = mod.leer_totales(["**Totales:** 120 líneas-ítem · Completados: 114 · "
                           "Pendientes: 4 · No resueltos: 2"])
    _ok(t2 is not None and t2["total"] == 120 and t2["x"] == 114, "variante 'líneas-ítem'")
    t3 = mod.leer_totales(["**Totales:** 50 elementos - Completados: 40 - "
                           "Pendientes: 8 - No resueltos: 2"])
    _ok(t3 is not None and t3["total"] == 50, "variante 'elementos'")
    # Control negativo: sin "Completados" no hay estructura que cruzar. Si esto
    # parseara, el drift se calcularia sobre numeros inventados.
    _ok(mod.leer_totales(["**Totales:** 211 lineas-item - Pendientes: 27"]) is None,
        "control negativo: sin 'Completados' -> None")
    # Formato de M110/M152: "No resueltos" ANTES de "Pendientes" (orden invertido).
    t4 = mod.leer_totales(["**Totales:** 225 ítems · [x] Completados: 179 · "
                           "[?] No resueltos (con dueño): 0 · Pendientes: 46."])
    _ok(t4 is not None, "M110 orden invertido PARSEA")
    _ok(t4 is not None and (t4["x"], t4["vacio"], t4["q"]) == (179, 46, 0),
        "M110 x/pend/nr = 179/46/0")
    # Formato de M157: parentesis CON DIGITOS dentro de la etiqueta.
    t5 = mod.leer_totales(["**Totales:** 132 items · Completados: 8 (J-01..J-04 + K-15), "
                           "evidencias en 07. · Pendientes: 0 · No resueltos: 124."])
    _ok(t5 is not None and t5["x"] == 8 and t5["total"] == 132,
        "M157 parentesis con digitos PARSEA (x=8, total=132)")
    # Formato de M30/M32: "Totales:" sin negrita.
    t6 = mod.leer_totales(["Totales: 120 items - Completados: 119 - "
                           "Pendientes: 0 - No resueltos: 1."])
    _ok(t6 is not None and t6["total"] == 120, "M30 'Totales:' sin negrita PARSEA")
    # Control negativo: etiquetas sueltas SIN la marca no son una declaracion.
    _ok(mod.leer_totales(["Completados: 5 · Pendientes: 1 · No resueltos: 0"]) is None,
        "control negativo: etiquetas sin 'Totales:' -> None")
    _cerrar("Totales: variantes de unidad (M40 escribe 'lineas-item')")


def test_modulos_en_disco(base):
    _bloque("--todos enumera el DISCO (no una lista hardcodeada)")
    with _Parche(base):
        ids = mod.modulos_en_disco()
    _ok(sorted(ids) == ["48", "77"], "enumera los 2 modulos del fixture (%s)" % ids)
    # Regresion medida: `--todos` estaba fijo en ["48","60","55","151"], asi que
    # imprimia 4 modulos y parecia que "no habia mas".
    _ok("60" not in ids, "NO trae el id hardcodeado 60")
    # CABLEADO: probar la funcion no prueba que `--todos` la USE. La 1.a version de
    # este bloque pasaba con el main() hardcodeado (sonda en rojo que NO se ponia
    # roja). Se ejerce la ruta real: main(["--todos","--json"]).
    import contextlib
    import json as _json
    buf = io.StringIO()
    with _Parche(base):
        with contextlib.redirect_stdout(buf):
            rc = mod.main(["--todos", "--json"])
    try:
        salida = _json.loads(buf.getvalue())
    except ValueError:
        salida = None
    _ok(salida is not None and len(salida) == 2,
        "--todos via main() devuelve los 2 del fixture (no 4 hardcodeados)")
    _ok(salida is not None and sorted(x["modulo"] for x in salida) == ["48", "77"],
        "los ids de --todos salen del disco")
    _ok(rc == 3, "--todos con un modulo CIEGO sale 3 (no 0)")
    _cerrar("--todos enumera el DISCO (no una lista hardcodeada)")


def test_totales_estado():
    _bloque("Totales: AUSENTE vs NO_PARSEA (ceguera != ausencia)")
    e = mod.estado_totales(["nada que ver"])
    _ok(e["estado"] == "AUSENTE", "sin marca -> AUSENTE")
    e2 = mod.estado_totales(["**Totales:** ver nota del director"])
    _ok(e2["estado"] == "NO_PARSEA", "marca presente y cuerpo ilegible -> NO_PARSEA")
    _ok("ver nota del director" in e2["linea"], "NO_PARSEA conserva la linea cruda")
    e3 = mod.estado_totales(["**Totales:** 8 ítems · Completados: 6 · Pendientes: 1 · "
                             "No resueltos: 1."])
    _ok(e3["estado"] == "OK" and e3["totales"]["total"] == 8, "linea sana -> OK")
    # Una PROSA que menciona la palabra no es una declaracion de totales.
    e4 = mod.estado_totales(["> este archivo no tenia linea de Totales. Conteo real: 95."])
    _ok(e4["estado"] == "AUSENTE", "prosa que menciona 'Totales' no cuenta como marca")
    _cerrar("Totales: AUSENTE vs NO_PARSEA (ceguera != ausencia)")


def test_imprime_no_parsea():
    _bloque("imprimir distingue NO_PARSEA de AUSENTE (mensaje distinto)")
    import contextlib

    def _capturar(filas):
        buf = io.StringIO()
        r = {"modulo": "99", "checklist": "x", "marcas": {"x": 1, " ": 0, "?": 0},
             "totales": None, "totales_estado": {"estado": filas[0], "linea": filas[1]},
             "drift": None, "n_muestra": 1, "n_req": 1, "auto_total": 1,
             "manual_sub": 0, "creacion_total": 0, "muestra": [], "manual_total": 0,
             "manual_muestra": [], "fallas": 0, "huecos": 0, "parciales": 0,
             "indeterminados": 0, "negadas": 0, "veredicto": "OK"}
        with contextlib.redirect_stdout(buf):
            mod.imprimir(r, verbose=False)
        return buf.getvalue()

    out_no = _capturar(("NO_PARSEA", "**Totales:** roto"))
    _ok("NO PARSEA" in out_no, "NO_PARSEA -> mensaje 'NO PARSEA'")
    _ok("SIN LINEA" not in out_no, "NO_PARSEA NO se reporta como 'SIN LINEA'")
    out_au = _capturar(("AUSENTE", ""))
    _ok("SIN LINEA" in out_au, "AUSENTE -> mensaje 'SIN LINEA'")
    _cerrar("imprimir distingue NO_PARSEA de AUSENTE (mensaje distinto)")


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


def test_ceguera_muestra_vacia():
    """Muestra vacia != evidencia. Falso verde medido 29-oct en el indice M01:
    122 [x], 0 items muestreables, el resumen decia 'fallas=0 -> VEREDICTO: OK'."""
    _bloque("muestra vacia -> CIEGO / exit 3 (no '0 fallas -> OK')")
    r = mod.analizar_modulo("77", 5)
    _ok(r.get("error") is None, "el 05 existe (no es el caso 'sin archivo')")
    _ok(r["n_muestra"] == 0, "0 items muestreables (dio %d)" % r["n_muestra"])
    _ok(r["marcas"]["x"] == 2, "2 [x] en el fixture ciego (dio %d)" % r["marcas"]["x"])
    _ok(r["veredicto"] == "CIEGO",
        "veredicto CIEGO, no OK (dio %s)" % r["veredicto"])
    _ok(r["fallas"] == 0, "fallas=0 igual: por eso el corte no puede depender de fallas")
    cod = mod.main(["--modulo", "77"])
    _ok(cod == 3, "main devuelve 3 (dio %d)" % cod)
    # Control negativo: un modulo CON muestra no puede caer en CIEGO.
    r2 = mod.analizar_modulo("48", 5)
    _ok(r2["n_muestra"] > 0, "control: el fixture 48 si tiene muestra (dio %d)" % r2["n_muestra"])
    _ok(r2["veredicto"] != "CIEGO", "control: con muestra el veredicto no es CIEGO")
    _cerrar("muestra vacia -> CIEGO / exit 3 (no '0 fallas -> OK')")


def test_citas_negativas():
    """Una cita NEGATIVA no es un hueco: el item menciona el artefacto justamente
    para declararlo inexistente. Medido 30-oct en M14 L163: `slot.tscn` marcaba
    PATH FALTA y tiraba el item a PARCIAL cuando el propio texto dice "que NO
    existe". Caso real, sin parche: el repo de verdad."""
    _bloque("citas negativas: no son huecos")
    real = ("Panel principal con grilla de slots (botones construidos por codigo en "
            "`inventory_layer.gd` _crear_slots, sin .tscn) [C] - **QA atria-dawn "
            "(Log 1047): el claim citaba `slot.tscn`, que NO existe;** la grilla se "
            "construye con Button.new() dinamico.")
    rutas, idents, negadas = mod.extraer_artefactos_ex(real)
    _ok("slot.tscn" in negadas, "slot.tscn se clasifica NEGADA (dio %r)" % (negadas,))
    _ok("slot.tscn" not in rutas, "slot.tscn NO queda en la lista de rutas")
    _ok("inventory_layer.gd" in rutas, "la ruta real sigue siendo verificable")
    v = mod.verificar_item(real)
    _ok(not any("PATH FALTA slot.tscn" in d for d in v["detalle"]),
        "ya no reporta 'PATH FALTA slot.tscn'")
    _ok(any("NEGADO slot.tscn" in d for d in v["detalle"]),
        "reporta 'NEGADO slot.tscn' (visible, no silencioso)")
    _ok(any("GREP 0 _crear_slots" in d for d in v["detalle"]),
        "y sigue cazando el defecto REAL: _crear_slots no existe")
    # Pero si el item dice "`_crear_slots` no existe", el identificador tampoco es
    # hueco: la misma regla que para las rutas (medido 30-oct en la nota de M14).
    _, idents_neg, neg_ident = mod.extraer_artefactos_ex(
        "Cita corregida: `_crear_slots` no existe; el real es `_construir_slots()`")
    _ok("_crear_slots" not in idents_neg, "un ident citado como inexistente no es hueco")
    _ok("_crear_slots" in neg_ident, "y queda registrado como NEGADO (dio %r)" % (neg_ident,))
    _ok("_construir_slots" in idents_neg, "el ident real si se verifica (dio %r)" % (idents_neg,))
    _ok(v["resultado"] == "PARCIAL",
        "el item real sigue PARCIAL, pero por el motivo correcto (dio %s)" % v["resultado"])
    # CONTROL: un archivo ausente SIN marcador de negacion sigue siendo hueco
    rutas2, _, neg2 = mod.extraer_artefactos_ex("Agregar `fantasma_inexistente.gd` al pipeline")
    _ok("fantasma_inexistente.gd" in rutas2 and not neg2,
        "sin marcador de negacion el archivo sigue siendo HUECO")
    # CONTROL: la negacion no se contagia a la cita VECINA
    rutas3, _, neg3 = mod.extraer_artefactos_ex("`a_falta.tscn` no existe y `b_ok.gd` existe")
    _ok("a_falta.tscn" in neg3, "la cita negada se detecta (dio %r)" % (neg3,))
    _ok("b_ok.gd" in rutas3, "la cita VECINA no se contagia (dio %r)" % (rutas3,))
    _ok("b_ok.gd" not in neg3, "y la vecina no aparece como negada")
    # marcador PRE-anclado
    _, _, neg4 = mod.extraer_artefactos_ex("en vez de `viejo.tscn` se usa un Button")
    _ok("viejo.tscn" in neg4, "'en vez de' tambien es marcador negativo")
    # Solo citas negativas -> HUECO: una ausencia declarada no avala nada.
    v5 = mod.verificar_item("El claim citaba `no_existe_x.tscn`, que no existe")
    _ok(v5["resultado"] == "HUECO",
        "solo citas negativas -> HUECO, ni RESUELTO ni INDETERMINADO (dio %s)"
        % v5["resultado"])
    # Caso M85 (medido 30-oct): la nota LISTA los artefactos que no existen. Ahi
    # la negacion NO absuelve el item: sin evidencia positiva sigue siendo HUECO.
    v7 = mod.verificar_item(
        "Crear ModelLegalManager: los artefactos citados NO existen: "
        "`model_legal_manager.gd`, `model_license.gd` = 0 en disco")
    _ok(v7["resultado"] == "HUECO",
        "la nota 'los artefactos NO existen' deja el item en HUECO (dio %s)"
        % v7["resultado"])
    # Regresion del fix de 29-oct: la extension suelta sigue sin ser artefacto.
    r6, _, n6 = mod.extraer_artefactos_ex("restricciones: recursos `.tres` y scripts `.gd`")
    _ok(r6 == [] and n6 == [], "extension suelta sigue sin ser artefacto (dio %r)" % (r6,))
    _cerrar("citas negativas: no son huecos")


def test_ident_pegado():
    """El nombre del metodo no siempre va entre backticks: "`x.gd` _crear_slots".
    Sin esta rama el muestreo AVALA un item que cita una funcion inexistente.
    Precision medida antes de cablearla: 5 ocurrencias en 23.069 items [x], 4
    resuelven y la unica GREP 0 es un defecto real -> ruido nulo."""
    _bloque("identificador suelto pegado a un .gd citado")
    _, idents, _ = mod.extraer_artefactos_ex(
        "grilla de slots (botones construidos por codigo en `inventory_layer.gd` "
        "_crear_slots, sin .tscn)")
    _ok("_crear_slots" in idents, "extrae _crear_slots (dio %r)" % (idents,))
    # CONTROL: prosa castellana tras el .gd NO se confunde con un identificador
    _, idents2, _ = mod.extraer_artefactos_ex("`inventory_layer.gd` extendido con botones")
    _ok(idents2 == [], "prosa tras el .gd no se extrae (dio %r)" % (idents2,))
    _, idents3, _ = mod.extraer_artefactos_ex(
        "`foo.gd` nuevo_modulo y `bar.gd` nuevo_modulo")
    _ok(idents3 == ["nuevo_modulo"], "deduplica el identificador repetido (dio %r)"
        % (idents3,))
    _ok(mod.grep_identificador("_crear_slots") == 0,
        "y el muestreo lo ve GREP 0: el metodo real es _construir_slots")
    _cerrar("identificador suelto pegado a un .gd citado")


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
        test_totales_variantes()
        with _Parche(base):
            test_modulos_en_disco(base)
        test_totales_estado()
        test_imprime_no_parsea()
        test_veredicto_deniega()
        test_drift_detectado()
        test_ceguera()
        with _Parche(base):
            test_ceguera_muestra_vacia()
        test_citas_negativas()
        test_ident_pegado()
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
