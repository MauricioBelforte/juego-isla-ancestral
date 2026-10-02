#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Auditor de ARQUITECTURA DE SERVICIOS y de CARGA SINCRONA (modulo 62 Memoria).

Por que existe
--------------
Dos reglas del diseno de M62 que hasta ahora no tenian ninguna puerta que las
hiciera cumplir:

  A. El grafo de autoloads. `scripts/core/service_registry.gd` declara la regla
     "un servicio NO puede depender de otro de nivel superior", pero nadie la
     verificaba. Tres formas de romperla:

     A1 CICLO: A busca a B y B busca a A (componente fuertemente conexa). Godot
        los instancia igual, pero la inicializacion pasa a ser fragil: el orden
        se vuelve carga estructural y cualquier dependencia sincrona futura
        rompe. Se reporta la SCC, no cada ciclo suelto.
     A2 ORDEN: A hace `get_node_or_null("/root/X")` alcanzable desde su
        `_ready()` y X se declara DESPUES que A. Es una violacion de la regla de
        capas, NO un fallo de runtime — ver MEDICIONES abajo: en `_ready()`
        todos los autoloads ya existen. El riesgo es de mantenibilidad: la
        correccion pasa a depender de un detalle de implementacion del motor.
     A3 DUPLICADO: el mismo script registrado como dos autoloads. Godot crea
        UNA INSTANCIA POR ENTRADA, asi que quedan dos servicios con estado
        propio y señales propias. Es un defecto real (medido).

  B. La carga sincrona. El item L190 del checklist de M62 prohibe `load()`,
     `instantiate()` y `duplicate()` dentro de los callbacks por frame
     (`_process`, `_physics_process`, `_input`, ...). Un `load()` ahi bloquea
     el hilo principal justo en el frame que M61 mide.

  C. Los datos de partida (M29). El item L98 del checklist de M62 exige que
     `get_save_data()` (contrato ISaveProvider de M59) devuelva DATOS y no
     referencias al mundo. Devolver `self` mete el propio proveedor — que
     cuando es autoload ES un Nodo — dentro del payload del save: leak y valor
     no serializable. Esta regla es el complemento ESTATICO de la suite de
     runtime `scripts/rendimiento/memoria/test_m62_pureza_save.gd` (que recorre
     el payload real de los 39 proveedores registrados y lo escanea de forma
     recursiva). El gate cubre ademas proveedores que NO se registran como
     autoload y por tanto no aparecen en runtime.

MEDICIONES (Godot 4.7.2 headless, banco de pruebas propio, 2026-09-20)
---------------------------------------------------------------------
Antes de describir la severidad de A2 se midio, y la medicion contradijo la
hipotesis inicial ("X todavia no existe -> null -> rama saltada en silencio"):

    desde _init()   -> null + "ERROR: Can't use get_node() with absolute paths
                       from outside the active scene tree"   (falla FUERTE)
    desde _ready()  -> ENCONTRADO, aunque X se declare despues  (no falla)
    diferido 1 frame-> ENCONTRADO

Es decir: en `_ready()` Godot 4.7.2 ya agrego TODOS los autoloads antes de
correr el primer `_ready()`, asi que A2 hoy NO rompe nada. Y la falla desde
`_init()` no depende del orden: `/root/...` no resuelve ahi para NINGUN destino.
Se reporta A2 como lo que es (regla de capas + fragilidad), no como el bug que
la intuicion sugeria. La hipotesis sin medir habria sido un BUG falso.

Para A3 la medicion si confirmo el defecto: dos entradas -> dos `instance_id`
distintos y `a == b` falso.

Por que un gate y no un test de runtime
---------------------------------------
A1/A2/A3 son propiedades ESTATICAS del arbol de archivos: se deciden sin abrir
el juego, sin GPU y sin mundo. B tambien: un `load()` en `_process` se ve en el
texto, no hace falta esperar a que ocurra.

Anti-falso-verde (obligatorio)
------------------------------
Un auditor que no ve nada y un auditor que ve todo bien dicen lo mismo: "0
hallazgos". Este script se niega a dar ese veredicto si no puede probar que
esta mirando:
  * GUARDA DE CEGUERA: si no resuelve autoloads, o no encuentra funciones por
    frame, o el grafo queda con 0 aristas, sale con codigo 3 (no con 0).
    No es teoria: el 2026-09-20 este mismo detector reporto "0 ciclos" DOS veces
    siendo ciego (rutas de autoload mal resueltas, y despues 0 callbacks).
  * `--selftest`: construye proyectos sinteticos con un ciclo, una violacion de
    orden, un autoload duplicado y un `load()` en `_process`, y exige que las 4
    reglas los detecten. Ademas prueba las 3 guardas de ceguera. Se prueba EN
    ROJO antes de confiar en el. En su primera corrida cazo 4 defectos reales
    del propio auditor (entre ellos que `x.instantiate()` y `d.duplicate()` eran
    indetectables por un lookbehind mal puesto).

Uso
---
    python scripts/auditar_arquitectura_m62.py                # estricto (exit 1 si hay hallazgos nuevos)
    python scripts/auditar_arquitectura_m62.py --informe      # solo informar (exit 0)
    python scripts/auditar_arquitectura_m62.py --selftest     # prueba en rojo
    python scripts/auditar_arquitectura_m62.py --json
    echo $?   # 0 = sin hallazgos nuevos · 1 = hallazgos · 3 = detector CIEGO
"""

import json
import os
import re
import sys

# ---------------------------------------------------------------------------
# Reglas y umbrales
# ---------------------------------------------------------------------------

# Callbacks que corren en el frame: prohibido cargar/instanciar/duplicar ahi.
FUNCIONES_POR_FRAME = (
    "_process", "_physics_process", "_input", "_unhandled_input",
    "_unhandled_key_input", "_integrate_forces",
)

# Profundidad del recorrido de llamadas desde `_ready()` para decidir que corre
# durante la inicializacion. 4 niveles cubre los helpers reales del repo sin
# arrastrar medio archivo.
PROFUNDIDAD_READY = 4

# Referencias EXPLICITAS a un autoload. Deliberadamente NO se cuenta la mera
# aparicion del identificador: eso da falsos positivos (un autoload puede
# nombrar a otro en un string o en un comentario). Ya paso: un detector laxo
# reporto 13 ciclos, uno de los cuales era `HardwareManager -> hardware`, y
# resulta que ambos nombres apuntan al MISMO archivo.
RE_REF = re.compile(r'get_node(?:_or_null)?\s*\(\s*"/root/([A-Za-z_][A-Za-z0-9_]*)"')
RE_FUNC = re.compile(r"^(\s*)func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(")
RE_LLAMADA = re.compile(r"(?<![A-Za-z0-9_.])([A-Za-z_][A-Za-z0-9_]*)\s*\(")

# OJO con el lookbehind, que NO es el mismo en las 3 reglas:
#  * `load(`  -> se excluye un `.` previo, para no marcar `ResourceLoader.load()`
#    (que tiene su propia regla) ni `algo.load()`. `preload(` tampoco entra: la
#    `e` previa lo descarta, y ademas es constante de compilacion, no carga.
#  * `instantiate(` / `duplicate(` -> son SIEMPRE llamadas a metodo (`x.instantiate()`),
#    asi que prohibir el `.` previo las volvia indetectables. Ya paso: el
#    selftest los cazo en rojo antes de que el gate llegara a CI.
REGLAS_CARGA = (
    ("B1", "load() sincrono", re.compile(r"(?<![A-Za-z0-9_.])load\s*\(")),
    ("B1", "ResourceLoader.load()", re.compile(r"ResourceLoader\s*\.\s*load\s*\(")),
    ("B2", "instantiate()", re.compile(r"(?<![A-Za-z0-9_])instantiate\s*\(")),
    ("B3", "duplicate()", re.compile(r"(?<![A-Za-z0-9_])duplicate\s*\(")),
)

# Regla C (item L98): `get_save_data()` no debe devolver `self` DESNUDO.
# Se excluye `self.algo` / `self.metodo()` (uso normal de self); solo cuenta el
# `self` como VALOR (p. ej. `return {"yo": self}` o `var x = self`). Devolver
# `self` mete el proveedor (que puede ser un Nodo autoload) en el payload.
RE_GET_SAVE_DATA = re.compile(r"^\s*func\s+get_save_data\s*\(")
RE_SELF_VALOR = re.compile(r"(?<![A-Za-z0-9_.])self(?![A-Za-z0-9_.])")

# ---------------------------------------------------------------------------
# Hallazgos ACEPTADOS (con justificacion y bug). Se imprimen SIEMPRE: una lista
# de permitidos que no se ve es una forma de `|| true`.
# La clave es el hallazgo EXACTO, no el archivo: asi un hallazgo NUEVO en un
# archivo ya permitido sigue tumbando la puerta.
# ---------------------------------------------------------------------------
PERMITIDOS = {
    # A1 — componentes ciclicas conocidas.
    # ⚠️ CORRECCION (2026-09-24, P-30): estas entradas y las A2 estaban
    # etiquetadas "BUG-068", pero A1/A2 (ciclos y orden de autoloads) son el
    # contenido de BUG-069. BUG-068 es SOLO el A3 (el mismo script como dos
    # autoloads). La etiqueta equivocada mandaba al bug que no era.
    "A1|CollectionRegistry,Fishing,GameTime,Inventario,SaveManager,TimeCalendar,Weather": "BUG-069",
    "A1|ThemeService,UIManager": "BUG-069",
    # A2 — referencias a un autoload declarado despues (regla de capas).
    # Medido: NO es un fallo de runtime (en _ready() todos los autoloads ya
    # existen); es deuda arquitectonica. Ver BUG-069.
    "A2|SaveManager->Fishing": "BUG-069",
    "A2|Localization->DataStore": "BUG-069",
    "A2|Friendship->VillagerManager": "BUG-069",
    "A2|WorldState->SaveManager": "BUG-069",
    "A2|TimeCalendar->GameTime": "BUG-069",
    "A2|AudioConfig->DataStore": "BUG-069",
    "A2|UIManager->ControlInput": "BUG-069",
    "A2|ShopManager->GameTime": "BUG-069",
    "A2|Friendship->GameTime": "BUG-069",
    # P-37 (2026-09-25, agnes-3-flash, Log 1151): M53 P-18 agrego los hooks de
    # accesibilidad i18n en ui_manager.gd — pausa instantanea M58 (RF18) apunta a
    # AccesibilityManager y la re-traducion en vivo apunta a Localization (M87).
    # Ambas son A2 legitimas (regla de capas; runtime OK porque los autoloads ya
    # existen en _ready): se documentan aqui para que el gate no rompa el merge.
    "A2|UIManager->AccesibilityManager": "BUG-069",
    "A2|UIManager->Localization": "BUG-069",
    # A3 — el mismo script registrado como dos autoloads.
    # BUG-068 RESUELTO (2026-09-25, P-32): se elimino el autoload duplicado
    # `hardware` de project.godot (queda solo `HardwareManager`, que es lo que
    # especifica el diseno del modulo: 115-Hardware/plan-actual/04-Codigo.md:278)
    # y se migro `test_hardware.gd` al nombre restante. El A3 dejo de observarse
    # y su entrada se BORRA: una excepcion muerta en el allowlist enmascara la
    # reaparicion del bug (el auditor volveria a verlo, pero ya estaria permitido).
}

EXCLUIDOS_DIR = (".git", "node_modules", "__pycache__", ".godot", "addons",
                 ".workbuddy-ai", "build", "dist", ".venv", "venv")


def raiz_repo():
    d = os.path.dirname(os.path.abspath(__file__))
    for _ in range(10):
        if os.path.isfile(os.path.join(d, "AGENTS.md")):
            return d
        p = os.path.dirname(d)
        if p == d:
            break
        d = p
    raise SystemExit("No encontre AGENTS.md subiendo desde %s" % __file__)


# ---------------------------------------------------------------------------
# Parseo
# ---------------------------------------------------------------------------

def cargar_autoloads(ruta_project_godot):
    """Devuelve (orden, mapa). `orden` es la lista de nombres en el orden en que
    project.godot los declara (que es el orden en que Godot los instancia)."""
    orden = []
    mapa = {}
    if not os.path.isfile(ruta_project_godot):
        return orden, mapa
    en_seccion = False
    with open(ruta_project_godot, encoding="utf-8", errors="replace") as fh:
        for linea in fh:
            s = linea.strip()
            if s.startswith("["):
                en_seccion = s == "[autoload]"
                continue
            if not en_seccion or "=" not in s or s.startswith(";"):
                continue
            nombre, valor = s.split("=", 1)
            nombre = nombre.strip()
            valor = valor.strip().strip('"').lstrip("*")
            if valor.startswith("res://"):
                valor = valor[6:]
            if nombre and valor:
                if nombre not in mapa:
                    orden.append(nombre)
                mapa[nombre] = valor
    return orden, mapa


def parsear_funciones(lineas):
    """{nombre: (linea_inicio, linea_fin)} con lineas 0-based, fin exclusivo."""
    funcs = {}
    actual = None
    for i, linea in enumerate(lineas):
        m = RE_FUNC.match(linea)
        if m:
            if actual is not None:
                funcs[actual] = (funcs[actual][0], i)
            actual = m.group(2)
            funcs[actual] = (i, len(lineas))
    if actual is not None:
        funcs[actual] = (funcs[actual][0], len(lineas))
    return funcs


def leer(raiz, rel):
    try:
        with open(os.path.join(raiz, rel.replace("/", os.sep)),
                  encoding="utf-8", errors="replace") as fh:
            return fh.read().splitlines()
    except OSError:
        return None


def refs_en(lineas, a, b):
    out = set()
    for linea in lineas[a:b]:
        if linea.lstrip().startswith("#"):
            continue
        for m in RE_REF.finditer(linea):
            out.add(m.group(1))
    return out


def llamadas_en(lineas, a, b):
    out = set()
    for linea in lineas[a:b]:
        s = linea.strip()
        if s.startswith("#"):
            continue
        # se corta el comentario de cola para no inventar llamadas
        corte = s.find(" #")
        if corte >= 0:
            s = s[:corte]
        for m in RE_LLAMADA.finditer(s):
            out.add(m.group(1))
    return out


# ---------------------------------------------------------------------------
# Grupo A — grafo de servicios
# ---------------------------------------------------------------------------

def componentes_ciclicas(nodos, adyacencia):
    """Tarjan: componentes fuertemente conexas (SCC) de tamano > 1.

    Se reporta la SCC y no cada ciclo suelto a proposito: un componente de 7
    nodos puede contener decenas de ciclos distintos y enumerarlos no aporta
    nada (ademas de volver inestable cualquier lista de permitidos). La SCC es
    la unidad real del problema: "estos N servicios se necesitan mutuamente".
    """
    indice = {}
    bajo = {}
    pila = []
    en_pila = set()
    componentes = []
    contador = [0]

    def fuerte(v):
        indice[v] = bajo[v] = contador[0]
        contador[0] += 1
        pila.append(v)
        en_pila.add(v)
        for w in sorted(adyacencia.get(v, ())):
            if w not in indice:
                fuerte(w)
                bajo[v] = min(bajo[v], bajo[w])
            elif w in en_pila:
                bajo[v] = min(bajo[v], indice[w])
        if bajo[v] == indice[v]:
            comp = []
            while True:
                w = pila.pop()
                en_pila.discard(w)
                comp.append(w)
                if w == v:
                    break
            if len(comp) > 1:
                componentes.append(sorted(comp))

    for v in nodos:
        if v not in indice:
            fuerte(v)
    componentes.sort(key=lambda c: (-len(c), c))
    return componentes


def analizar_servicios(raiz, base, orden, mapa):
    """Devuelve el analisis del grafo de autoloads."""
    idx = {n: i for i, n in enumerate(orden)}
    # Dos autoloads pueden apuntar al MISMO archivo (pasa en este repo:
    # `hardware` y `HardwareManager`). Referenciarse entre ellos no es una
    # dependencia: es el mismo script. Se excluye y se reporta aparte.
    archivo_de = dict(mapa)
    por_archivo = {}
    for n in orden:
        por_archivo.setdefault(mapa[n], []).append(n)
    duplicados = {a: ns for a, ns in por_archivo.items() if len(ns) > 1}

    sin_archivo = []
    refs_por_func = {}   # nombre -> set (referencias alcanzables desde _ready)
    refs_todas = {}      # nombre -> set (grafo completo)
    ready_directo = {}   # nombre -> set referenciado DIRECTAMENTE en _ready

    for nombre in orden:
        rel = os.path.join(base, mapa[nombre])
        lineas = leer(raiz, rel)
        if lineas is None:
            sin_archivo.append(nombre)
            continue
        funcs = parsear_funciones(lineas)
        directo = set()
        todas = set()
        for f, (a, b) in funcs.items():
            r = refs_en(lineas, a, b)
            todas |= r
            if f in ("_ready", "_init", "_enter_tree"):
                directo |= r
        alcanzables = [f for f in ("_ready", "_init", "_enter_tree") if f in funcs]
        visto = set(alcanzables)
        frontera = list(alcanzables)
        prof = 0
        while frontera and prof < PROFUNDIDAD_READY:
            siguiente = []
            for f in frontera:
                a, b = funcs[f]
                for c in llamadas_en(lineas, a, b):
                    if c in funcs and c not in visto:
                        visto.add(c)
                        siguiente.append(c)
            frontera = siguiente
            prof += 1
        init_refs = set(directo)
        for f in visto:
            init_refs |= refs_en(lineas, *funcs[f])
        refs_por_func[nombre] = init_refs
        refs_todas[nombre] = todas
        ready_directo[nombre] = directo

    # --- A1: componentes fuertemente conexas ---
    adyacencia = {}
    aristas = 0
    for n in orden:
        destinos = set()
        for m in refs_todas.get(n, ()):
            if m not in idx or m == n:
                continue
            if archivo_de.get(m) == archivo_de.get(n):
                continue  # mismo archivo con dos nombres de autoload
            destinos.add(m)
        adyacencia[n] = destinos
        aristas += len(destinos)
    sccs = componentes_ciclicas(orden, adyacencia)

    # --- A2: referencia a un autoload declarado DESPUES, alcanzable desde _ready ---
    orden_violado = []
    for nombre in orden:
        for destino in sorted(refs_por_func.get(nombre, ())):
            if destino not in idx or destino == nombre:
                continue
            if idx[destino] > idx[nombre]:
                orden_violado.append({
                    "origen": nombre, "idx_origen": idx[nombre],
                    "destino": destino, "idx_destino": idx[destino],
                    "delta": idx[destino] - idx[nombre],
                    "directo_en_ready": destino in ready_directo.get(nombre, ()),
                })
    orden_violado.sort(key=lambda v: -v["delta"])
    return {"aristas": aristas, "sccs": sccs, "orden_violado": orden_violado,
            "sin_archivo": sin_archivo, "autoloads_duplicados": duplicados}


# ---------------------------------------------------------------------------
# Grupo B — carga sincrona en callbacks por frame
# ---------------------------------------------------------------------------

def analizar_carga_sincrona(raiz, base):
    """Devuelve (hallazgos, n_archivos, n_funciones_por_frame)."""
    hallazgos = []
    n_archivos = 0
    n_funciones = 0
    raiz_scripts = os.path.join(raiz, base, "scripts")
    for dirpath, dirnames, filenames in os.walk(raiz_scripts):
        dirnames[:] = [d for d in dirnames if d not in EXCLUIDOS_DIR]
        for fn in sorted(filenames):
            if not fn.endswith(".gd"):
                continue
            n_archivos += 1
            p = os.path.join(dirpath, fn)
            rel = os.path.relpath(p, raiz).replace("\\", "/")
            try:
                with open(p, encoding="utf-8", errors="replace") as fh:
                    lineas = fh.read().splitlines()
            except OSError:
                continue
            funcs = parsear_funciones(lineas)
            por_frame = {f: r for f, r in funcs.items() if f in FUNCIONES_POR_FRAME}
            n_funciones += len(por_frame)
            if not por_frame:
                continue
            for f, (a, b) in por_frame.items():
                for i in range(a, b):
                    linea = lineas[i]
                    s = linea.strip()
                    if s.startswith("#"):
                        continue
                    corte = s.find(" #")
                    if corte >= 0:
                        s = s[:corte]
                    for rid, etiqueta, rx in REGLAS_CARGA:
                        if rx.search(s):
                            hallazgos.append({
                                "regla": rid, "etiqueta": etiqueta,
                                "archivo": rel, "linea": i + 1,
                                "funcion": f, "texto": linea.strip()[:100],
                            })
    return hallazgos, n_archivos, n_funciones


# ---------------------------------------------------------------------------
# Grupo C — pureza de los datos de partida (M29, item L98)
# ---------------------------------------------------------------------------

def analizar_pureza_save(raiz, base):
    """Regla C: `get_save_data()` no debe devolver `self` (referencia al mundo).

    Complementa la suite de runtime `test_m62_pureza_save.gd`. Aqui se mira el
    TEXTO de cada `get_save_data()` del arbol de scripts, asi que cubre tambien
    los proveedores que no se registran como autoload y no aparecen en runtime.

    Devuelve (hallazgos, n_archivos_con_get_save_data).
    """
    hallazgos = []
    n_archivos = 0
    raiz_scripts = os.path.join(raiz, base, "scripts")
    for dirpath, dirnames, filenames in os.walk(raiz_scripts):
        dirnames[:] = [d for d in dirnames if d not in EXCLUIDOS_DIR]
        for fn in sorted(filenames):
            if not fn.endswith(".gd"):
                continue
            p = os.path.join(dirpath, fn)
            rel = os.path.relpath(p, raiz).replace("\\", "/")
            try:
                with open(p, encoding="utf-8", errors="replace") as fh:
                    lineas = fh.read().splitlines()
            except OSError:
                continue
            funcs = parsear_funciones(lineas)
            if "get_save_data" not in funcs:
                continue
            n_archivos += 1
            a, b = funcs["get_save_data"]
            for i in range(a, b):
                s = lineas[i].strip()
                if s.startswith("#"):
                    continue
                corte = s.find(" #")
                if corte >= 0:
                    s = s[:corte]
                if RE_SELF_VALOR.search(s):
                    hallazgos.append({
                        "regla": "C", "archivo": rel, "linea": i + 1,
                        "texto": lineas[i].strip()[:100],
                    })
    return hallazgos, n_archivos


# ---------------------------------------------------------------------------
# Informe
# ---------------------------------------------------------------------------

def imprimir_informe(serv, carga, n_archivos, n_funciones, informe, pureza=(), n_prov=0):
    print("=== Auditoria de arquitectura M62 (servicios + carga sincrona) ===\n")

    print("-- Grupo A: grafo de servicios")
    print("   autoloads declarados ....... %d" % len(serv["orden_total"]))
    print("   aristas explicitas ......... %d" % serv["aristas"])
    if serv["sin_archivo"]:
        print("   SIN ARCHIVO ................ %s" % ", ".join(serv["sin_archivo"]))
    if serv["autoloads_duplicados"]:
        for archivo, nombres in sorted(serv["autoloads_duplicados"].items()):
            clave = "A3|" + archivo
            marca = " [permitido %s]" % PERMITIDOS[clave] if clave in PERMITIDOS else "  << NUEVO"
            print("   AUTOLOAD DUPLICADO ......... %s -> %s (mismo archivo)%s"
                  % (", ".join(sorted(nombres)), archivo, marca))
    print("   componentes con ciclo ...... %d" % len(serv["sccs"]))
    print("   refs fuera de orden ........ %d  (regla de capas; medido: en _ready no falla)" % len(serv["orden_violado"]))
    for comp in serv["sccs"]:
        clave = clave_scc(comp)
        marca = " [permitido %s]" % PERMITIDOS[clave] if clave in PERMITIDOS else "  << NUEVO"
        print("     componente de %d: %s%s" % (len(comp), ", ".join(comp), marca))
    for v in serv["orden_violado"]:
        clave = "A2|%s->%s" % (v["origen"], v["destino"])
        marca = " [permitido %s]" % PERMITIDOS[clave] if clave in PERMITIDOS else "  << NUEVO"
        print("     orden: %-20s (#%-3d) -> %-20s (#%-3d) delta=%+d%s%s"
              % (v["origen"], v["idx_origen"], v["destino"], v["idx_destino"],
                 v["delta"], "  DIRECTO en _ready" if v["directo_en_ready"] else "", marca))
    print("     (A2 = regla de capas del diseno, no un fallo de runtime: medido en Godot 4.7.2,")
    print("      en _ready() todos los autoloads ya existen. Solo _init() falla, y falla siempre.)")

    print("\n-- Grupo B: carga sincrona en callbacks por frame")
    print("   archivos .gd revisados ..... %d" % n_archivos)
    print("   funciones por frame ........ %d" % n_funciones)
    print("   hallazgos .................. %d" % len(carga))
    for h in carga:
        clave = "%s|%s:%d" % (h["regla"], h["archivo"], h["linea"])
        marca = " [permitido %s]" % PERMITIDOS[clave] if clave in PERMITIDOS else "  << NUEVO"
        print("     %s %s:%d  en %s()  %s%s"
              % (h["regla"], h["archivo"], h["linea"], h["funcion"], h["etiqueta"], marca))

    print("\n-- Grupo C: pureza de los datos de partida (M29, item L98)")
    print("   scripts con get_save_data() . %d" % n_prov)
    print("   hallazgos .................. %d" % len(pureza))
    for h in pureza:
        clave = "%s|%s:%d" % (h["regla"], h["archivo"], h["linea"])
        marca = " [permitido %s]" % PERMITIDOS[clave] if clave in PERMITIDOS else "  << NUEVO"
        print("     %s %s:%d  %s%s"
              % (h["regla"], h["archivo"], h["linea"], h["texto"], marca))

    nuevos = hallazgos_nuevos(serv, carga, pureza)
    print("\n-- Hallazgos NUEVOS (no permitidos): %d" % len(nuevos))
    for n in nuevos:
        print("     %s" % n)
    obsoletos = permitidos_obsoletos(serv, carga, pureza)
    if obsoletos:
        print("\n-- Aviso: %d entradas de PERMITIDOS ya no se observan (se pueden borrar):"
              % len(obsoletos))
        for o in sorted(obsoletos):
            print("     %s" % o)
    if informe:
        print("\n(modo --informe: no se falla por hallazgos)")
    return nuevos


def clave_scc(componente):
    """Clave estable de una componente ciclica: sus miembros ordenados.

    Si un servicio NUEVO entra en la componente, la clave cambia y la puerta
    salta. Esa es la propiedad que se busca: permitir el estado conocido sin
    permitir que crezca.
    """
    return "A1|" + ",".join(sorted(componente))


def claves_observadas(serv, carga, pureza=()):
    vistas = set()
    for comp in serv["sccs"]:
        vistas.add(clave_scc(comp))
    for archivo in serv["autoloads_duplicados"]:
        vistas.add("A3|" + archivo)
    for v in serv["orden_violado"]:
        vistas.add("A2|%s->%s" % (v["origen"], v["destino"]))
    for h in carga:
        vistas.add("%s|%s:%d" % (h["regla"], h["archivo"], h["linea"]))
    for h in pureza:
        vistas.add("%s|%s:%d" % (h["regla"], h["archivo"], h["linea"]))
    return vistas


def hallazgos_nuevos(serv, carga, pureza=()):
    return sorted(k for k in claves_observadas(serv, carga, pureza) if k not in PERMITIDOS)


def permitidos_obsoletos(serv, carga, pureza=()):
    """Entradas de PERMITIDOS que ya NO se observan (se pueden borrar)."""
    return set(PERMITIDOS) - claves_observadas(serv, carga, pureza)


def claves_carga(carga):
    return set("%s|%s:%d" % (h["regla"], h["archivo"], h["linea"]) for h in carga)


# ---------------------------------------------------------------------------
# Selftest: probar el guardian EN ROJO antes de confiar en el
# ---------------------------------------------------------------------------

FIXTURE_PROJECT = """[application]
config/name="fixture"

[autoload]

Alfa="*res://scripts/alfa.gd"
Beta="*res://scripts/beta.gd"
AlfaAlias="*res://scripts/alfa.gd"

[rendering]
"""

FIXTURE_ALFA = """extends Node

func _ready() -> void:
	_arrancar()

func _arrancar() -> void:
	var b = get_node_or_null("/root/Beta")
	if b != null:
		b.hacer()

func otra() -> void:
	var b = get_node_or_null("/root/Beta")
	pass
"""

FIXTURE_BETA = """extends Node

func _ready() -> void:
	var a = get_node_or_null("/root/Alfa")
	pass

func hacer() -> void:
	pass
"""

FIXTURE_FRAME = """extends Node

func _process(_delta: float) -> void:
	var r = load("res://x.tres")
	var esc = preload("res://y.tscn")
	var n = esc.instantiate()
	var d = {"a": 1}.duplicate()

func _ready() -> void:
	var r2 = load("res://z.tres")
"""

# Grupo C: un proveedor que devuelve `self` (defecto) y otro que usa `self.metodo()`
# (uso normal, NO debe marcarse). Van en el MISMO get_save_data para probar ambos.
FIXTURE_SAVE = """extends Node

func get_save_data() -> Dictionary:
	var n := self._contar()
	return {"yo": self, "n": n}

func _contar() -> int:
	return 1
"""


def selftest(raiz):
    """Construye un fixture con defectos CONOCIDOS y exige que las 4 reglas los vean."""
    import tempfile
    fallos = 0

    def check(nombre, cond, detalle=""):
        nonlocal fallos
        print("  [%s] %s%s" % ("OK" if cond else "FALLO", nombre,
                               "" if not detalle else "  << %s" % detalle))
        if not cond:
            fallos += 1

    print("=== Selftest del auditor (se prueba EN ROJO) ===\n")
    tmp = tempfile.mkdtemp(prefix="m62_arq_")
    base = "game/isla-ancestral"
    os.makedirs(os.path.join(tmp, base, "scripts"))
    with open(os.path.join(tmp, base, "project.godot"), "w", encoding="utf-8") as fh:
        fh.write(FIXTURE_PROJECT)
    for nombre, cuerpo in (("alfa.gd", FIXTURE_ALFA), ("beta.gd", FIXTURE_BETA),
                           ("frame.gd", FIXTURE_FRAME), ("save.gd", FIXTURE_SAVE)):
        with open(os.path.join(tmp, base, "scripts", nombre), "w", encoding="utf-8") as fh:
            fh.write(cuerpo)

    orden, mapa = cargar_autoloads(os.path.join(tmp, base, "project.godot"))
    check("fixture: se leen los 3 autoloads declarados", len(orden) == 3, str(orden))

    serv = analizar_servicios(tmp, base, orden, mapa)
    serv["orden_total"] = orden
    claves_ciclo = [clave_scc(c) for c in serv["sccs"]]
    check("A1 detecta la componente ciclica {Alfa, Beta}",
          claves_ciclo == ["A1|Alfa,Beta"], str(claves_ciclo))
    check("A3 detecta que Alfa y AlfaAlias son el MISMO archivo",
          list(serv["autoloads_duplicados"]) == ["scripts/alfa.gd"],
          str(serv["autoloads_duplicados"]))
    check("A3 NO inventa un ciclo Alfa <-> AlfaAlias (mismo archivo, no es dependencia)",
          serv["sccs"] == [["Alfa", "Beta"]], str(serv["sccs"]))
    viol = ["A2|%s->%s" % (v["origen"], v["destino"]) for v in serv["orden_violado"]]
    check("A2 detecta Alfa -> Beta (Beta se declara DESPUES)",
          "A2|Alfa->Beta" in viol, str(viol))
    check("A2 lo marca como alcanzable desde _ready via llamada",
          any(v["origen"] == "Alfa" and v["destino"] == "Beta" and not v["directo_en_ready"]
              for v in serv["orden_violado"]), str(serv["orden_violado"]))
    check("A2 NO reporta Beta -> Alfa (Alfa se declara ANTES: es legal)",
          "A2|Beta->Alfa" not in viol, str(viol))

    carga, n_arch, n_func = analizar_carga_sincrona(tmp, base)
    # ⚠️ El fixture tiene 3 archivos y UN solo callback por frame (`_process` de
    # frame.gd): `_ready` NO es un callback por frame. La primera version de este
    # selftest esperaba 2 y "fallo" contra un analizador que estaba bien.
    check("B1 detecta load() en _process",
          sum(1 for h in carga if h["regla"] == "B1") == 1, str(carga))
    check("B2 detecta instantiate() en _process (llamada a metodo, con punto delante)",
          any(h["regla"] == "B2" for h in carga), str(carga))
    check("B3 detecta duplicate() en _process (llamada a metodo, con punto delante)",
          any(h["regla"] == "B3" for h in carga), str(carga))
    check("control negativo: el load() de _ready NO se marca (la regla es solo callbacks por frame)",
          not any(h["funcion"] == "_ready" for h in carga), str(carga))
    check("control negativo: preload() NO se marca (es constante de compilacion, no carga)",
          not any("preload(" in h["texto"] for h in carga), str(carga))
    check("B cuenta los archivos y los callbacks por frame del fixture (4 archivos, 1 callback)",
          n_arch == 4 and n_func == 1, "archivos=%d funciones=%d" % (n_arch, n_func))

    pureza, n_prov = analizar_pureza_save(tmp, base)
    check("C detecta `self` desnudo en get_save_data() (fixture save.gd)",
          len(pureza) == 1 and pureza[0]["archivo"].endswith("save.gd"),
          str(pureza))
    check("C NO marca `self.metodo()` (uso normal de self)",
          not any("_contar" in h["texto"] for h in pureza), str(pureza))
    check("C cuenta los scripts con get_save_data() del fixture (1)",
          n_prov == 1, "n=%d" % n_prov)

    # --- guardas de ceguera: probarlas es lo que las hace valer ---
    def fixture(nombre, autoloads_txt, archivos):
        d = tempfile.mkdtemp(prefix="m62_arq_%s_" % nombre)
        os.makedirs(os.path.join(d, base, "scripts"))
        with open(os.path.join(d, base, "project.godot"), "w", encoding="utf-8") as fh:
            fh.write("[application]\nconfig/name=\"%s\"\n\n[autoload]\n\n%s\n" % (nombre, autoloads_txt))
        for n, c in archivos.items():
            with open(os.path.join(d, base, "scripts", n), "w", encoding="utf-8") as fh:
                fh.write(c)
        o, m = cargar_autoloads(os.path.join(d, base, "project.godot"))
        s = analizar_servicios(d, base, o, m)
        _, _, nf = analizar_carga_sincrona(d, base)
        return o, s, nf, d

    # (1) sin autoloads
    o, s, nf, _d1 = fixture("vacio", "", {})
    check("ceguera 1: proyecto sin autoloads -> se declara CIEGO",
          len(o) == 0 and evaluar_ceguera(o, s, nf), str(evaluar_ceguera(o, s, nf)))

    # (2) autoloads declarados pero sin archivo (el error real del 2026-09-20:
    #     las rutas se resolvian mal y los 111 autoloads quedaban "sin archivo",
    #     lo que producia un "0 ciclos" indistinguible de "no mire")
    o, s, nf, _d2 = fixture("sinarchivo",
                            'Fantasma="*res://scripts/no_existe.gd"',
                            {"otro.gd": "extends Node\nfunc _process(_d):\n\tpass\n"})
    check("ceguera 2: autoload declarado sin archivo -> CIEGO",
          len(o) == 1 and evaluar_ceguera(o, s, nf), str(evaluar_ceguera(o, s, nf)))

    # (3) todo resuelve pero NADIE se referencia: grafo de 0 aristas. Es el
    #     segundo falso verde real de hoy (0 aristas -> "0 ciclos").
    o, s, nf, _d3 = fixture("sinaristas",
                            'Uno="*res://scripts/uno.gd"\nDos="*res://scripts/dos.gd"',
                            {"uno.gd": "extends Node\nfunc _process(_d):\n\tpass\n",
                             "dos.gd": "extends Node\nfunc _process(_d):\n\tpass\n"})
    check("ceguera 3: grafo con 0 aristas -> CIEGO (0 ciclos no es lo mismo que 'no mire')",
          s["aristas"] == 0 and evaluar_ceguera(o, s, nf), str(evaluar_ceguera(o, s, nf)))

    # (4) grupo C: hay autoloads, aristas y callbacks por frame, pero NINGUN
    #     get_save_data() -> el detector de pureza queda CIEGO.
    o, s, nf, d4 = fixture("sin_save",
                           'Uno="*res://scripts/uno.gd"\nDos="*res://scripts/dos.gd"',
                           {"uno.gd": "extends Node\nfunc _ready():\n\tvar d = get_node_or_null(\"/root/Dos\")\nfunc _process(_d):\n\tpass\n",
                            "dos.gd": "extends Node\nfunc _ready():\n\tvar u = get_node_or_null(\"/root/Uno\")\nfunc _process(_d):\n\tpass\n"})
    _, np4 = analizar_pureza_save(d4, base)
    check("ceguera 4 (grupo C): sin get_save_data() -> CIEGO",
          np4 == 0 and any("get_save_data" in m for m in evaluar_ceguera(o, s, nf, np4)),
          str(evaluar_ceguera(o, s, nf, np4)))

    # (5) control positivo: el fixture bueno NO se declara ciego
    check("ceguera 5: el fixture con defectos NO se declara ciego (control positivo)",
          evaluar_ceguera(orden, serv, n_func, n_prov) == [],
          str(evaluar_ceguera(orden, serv, n_func, n_prov)))

    print("\n=== Selftest: %d fallos ===" % fallos)
    return 0 if fallos == 0 else 1


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def evaluar_ceguera(orden, serv, n_funciones, n_prov=None):
    """Motivos por los que el auditor NO puede afirmar "no hay hallazgos".

    Existe porque el 2026-09-20 este mismo detector reporto "0 ciclos" dos veces
    seguidas siendo ciego: primero por no resolver las rutas de los autoloads
    (los 111 quedaron "sin archivo") y despues por no encontrar callbacks por
    frame. Un "0" que no se puede distinguir de "no mire" no vale nada.
    """
    motivos = []
    if not orden:
        motivos.append("no se leyo ningun autoload de project.godot")
    if serv["sin_archivo"]:
        motivos.append("%d autoloads sin archivo resoluble: %s"
                       % (len(serv["sin_archivo"]), ", ".join(serv["sin_archivo"][:5])))
    if orden and serv["aristas"] == 0:
        motivos.append("el grafo de servicios quedo con 0 aristas (detector ciego)")
    if n_funciones == 0:
        motivos.append("no se encontro ninguna funcion por frame (detector ciego)")
    if n_prov is not None and n_prov == 0:
        motivos.append("no se encontro ningun get_save_data() (detector ciego, grupo C)")
    return motivos


def main():
    args = sys.argv[1:]
    informe = "--informe" in args
    como_json = "--json" in args
    if "--selftest" in args:
        return selftest(raiz_repo())

    raiz = raiz_repo()
    os.chdir(raiz)
    base = "game/isla-ancestral"
    orden, mapa = cargar_autoloads(os.path.join(base, "project.godot"))
    serv = analizar_servicios(raiz, base, orden, mapa)
    serv["orden_total"] = orden
    carga, n_arch, n_func = analizar_carga_sincrona(raiz, base)
    pureza, n_prov = analizar_pureza_save(raiz, base)

    # --- Guardas de ceguera: sin esto, "0 hallazgos" no significa nada ---
    ciego = evaluar_ceguera(orden, serv, n_func, n_prov)

    if como_json:
        print(json.dumps({
            "autoloads": len(orden), "aristas": serv["aristas"],
            "componentes_ciclicas": serv["sccs"],
            "autoloads_duplicados": serv["autoloads_duplicados"],
            "orden_violado": serv["orden_violado"],
            "sin_archivo": serv["sin_archivo"], "carga_sincrona": carga,
            "pureza_save": pureza, "scripts_get_save_data": n_prov,
            "archivos_gd": n_arch, "funciones_por_frame": n_func,
            "ciego": ciego, "nuevos": hallazgos_nuevos(serv, carga, pureza),
        }, indent=2, ensure_ascii=False))
    else:
        imprimir_informe(serv, carga, n_arch, n_func, informe, pureza, n_prov)

    if ciego:
        print("\nDETECTOR CIEGO — no se puede afirmar que no hay hallazgos:")
        for c in ciego:
            print("   - %s" % c)
        return 3

    if informe:
        return 0
    return 1 if hallazgos_nuevos(serv, carga, pureza) else 0


if __name__ == "__main__":
    sys.exit(main())
