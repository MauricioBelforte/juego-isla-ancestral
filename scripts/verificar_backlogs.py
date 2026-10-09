#!/usr/bin/env python3
"""
Script de Verificacion de Sincronizacion backlog <-> checklist (LOTE 12).

Recorre DOCUMENTACION/TAREAS-POR-MODELO/<MODELO>/BACKLOG-MASTER.md de cada
modelo y verifica que su contenido se corresponda con el estado REAL de los
`05-Checklist.md` de los modulos que cita:

1. **Cierres afirmados**: las tareas `[x]` del backlog que afirman un conteo de
   un modulo (p. ej. "M88 174/185") se contrastan contra el conteo real de
   `plan-actual/05-Checklist.md`. Un [x] afirmado MAYOR que el real indica
   retroceso del modulo (flips posteriores); MENOR indica avance legtimo.
2. **Drift inverso**: las tareas `[ ]` pendientes del backlog que son items
   textuales de un modulo y que YA estan `[x]` en su checklist -> el agente
   podria REPETIR trabajo hecho. Este es el riesgo material del frente.
3. **Marcas colgadas**: `[->]`/`[→]` "EN CURSO" sin cerrar in-situ (patron de
   `[x]` duplicado mas abajo en lugar de actualizar el original).
4. **Modulos inexistentes**: referencias a IDs que no tienen carpeta en
   DOCUMENTACION/ (modulos borrados o renombrados).

El script es READ-ONLY por diseno: nunca modifica un backlog. El flag
`--dry-run` existe por simetria con fix_encoding.py, pero el script no tiene
modo de escritura.

Uso:
    python scripts/verificar_backlogs.py
    python scripts/verificar_backlogs.py --modelo agnes-3-flash
    python scripts/verificar_backlogs.py --json
    python scripts/verificar_backlogs.py --dry-run

Codigos de salida (BUG-075 - no compartir el 1 y el 3):
    0  sin alertas: todos los backlogs sincronizados.
    1  mire y encontre alertas (drift material o marcas colgadas).
    3  DETECTOR CIEGO: no pude leer mi fuente de verdad (no hay backlogs).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import unicodedata
from pathlib import Path

# Forzar salida UTF-8 en Windows (PowerShell/cmd no soportan emojis por defecto)
if sys.stdout and hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

# ---------------------------------------------------------------------------
# Configuracion
# ---------------------------------------------------------------------------

RAIZ = Path(__file__).resolve().parent.parent
DOC = RAIZ / "DOCUMENTACION"
TAREAS = DOC / "TAREAS-POR-MODELO"

# Marcas de checklist en items de lista y en encabezados.
RE_ITEM = re.compile(r"(?m)^[ \t]*[-*][ \t]+\[( |x|\?|->|→)\][ \t]*(.*)$")
RE_HEADING = re.compile(r"(?m)^#{1,4}[ \t]+(.*)$")
RE_MARCA_HEADING = re.compile(r"\[( |x|\?|->|→)\]")

# Referencias a modulos: "62-Memoria", "100-Community-Management", "M88".
# El lookbehind (?<!-) evita匹配 falsos positivos en IDs de TAREA del protocolo
# ("T-M0", "T-M1", ...), que no son modulos.
RE_MODULO_NOMBRE = re.compile(r"(?<![\w-])(\d{1,3})-([A-Za-z][\w\-]*)")
RE_MODULO_M = re.compile(r"(?<![\w-])M(\d{1,3})\b")

# Conteos afirmados en una linea: "174/185", "75/42/14=131", "113/37/0".
RE_CONTEO = re.compile(r"(\d+)\s*/\s*(\d+)(?:\s*/\s*(\d+))?(?:\s*=\s*(\d+))?")

# Sufijo de esfuerzo del checklist ("[S]", "[M]", "[C]") y cola de evidencia
# ("-- **iter. 6 (Log 1196):** ...") que hay que pelar para comparar textos.
RE_SUFIJO_ESFUERZO = re.compile(r"\[(S|M|C)\].*$")

MIN_TEXTO_DRIFT = 25  # chars normalizados minimos para considerar matching


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------

def normalizar(texto: str) -> str:
    """Normaliza un texto de item para comparar backlog vs checklist.

    Quita acentos, signos de puntuacion y el sufijo de esfuerzo [S]/[M]/[C]
    (que solo existe en los checklists), de forma que un item copiado de un
    modulo a un backlog coincida aunque el checklist traiga evidencia anadida.
    """
    t = RE_SUFIJO_ESFUERZO.sub("", texto)
    t = unicodedata.normalize("NFKD", t)
    t = "".join(c for c in t if not unicodedata.combining(c))
    t = t.lower()
    t = re.sub(r"[^a-z0-9 ]+", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def leer(ruta: Path) -> str:
    try:
        return ruta.read_text(encoding="utf-8")
    except Exception:
        return ""


def _norm_marca(marca: str) -> str:
    if marca == "x":
        return "x"
    if marca == "?":
        return "?"
    if marca in ("->", "→"):
        return "->"
    return "a"


SIMBOLOS = {"x": "[x]", "a": "[ ]", "?": "[?]", "->": "[->]"}


# ---------------------------------------------------------------------------
# Fuentes de verdad
# ---------------------------------------------------------------------------

def _canon_id(id_crudo: str) -> str:
    """Caniza un id de modulo quitando ceros a la izquierda.

    Las carpetas usan padding ("04-Game-Engine") y las referencias en texto no
    ("M4"); hay que compararlas en un espacio comun.
    """
    try:
        return str(int(id_crudo))
    except ValueError:
        return id_crudo


def modulos_disponibles() -> dict[str, str]:
    """Mapea id canonico -> nombre de carpeta bajo DOCUMENTACION/."""
    out: dict[str, str] = {}
    if not DOC.is_dir():
        return out
    for d in sorted(DOC.iterdir()):
        if d.is_dir():
            m = re.match(r"^(\d{1,3})-", d.name)
            if m:
                out[_canon_id(m.group(1))] = d.name
    return out


def _ruta_checklist(carpeta: str) -> Path:
    return DOC / carpeta / "plan-actual" / "05-Checklist.md"


def contar_checklist(carpeta: str) -> dict[str, int] | None:
    """Cuenta [x]/[ ]/[?] del plan-actual/05-Checklist.md de un modulo."""
    ruta = _ruta_checklist(carpeta)
    if not ruta.is_file():
        return None
    conteo = {"x": 0, "a": 0, "?": 0}
    for marca, _ in RE_ITEM.findall(leer(ruta)):
        if marca == "x":
            conteo["x"] += 1
        elif marca == "?":
            conteo["?"] += 1
        else:
            conteo["a"] += 1
    return conteo


def items_checklist_x(carpeta: str) -> set[str]:
    """Conjunto de items [x] normalizados de un modulo (para drift inverso)."""
    ruta = _ruta_checklist(carpeta)
    if not ruta.is_file():
        return set()
    out: set[str] = set()
    for marca, resto in RE_ITEM.findall(leer(ruta)):
        if marca == "x":
            n = normalizar(resto)
            if len(n) >= MIN_TEXTO_DRIFT:
                out.add(n)
    return out


# ---------------------------------------------------------------------------
# Backlog de un modelo
# ---------------------------------------------------------------------------

class Tarea:
    __slots__ = ("marca", "texto", "linea", "origen", "seccion_mod")

    def __init__(self, marca: str, texto: str, linea: int, origen: str,
                 seccion_mod: str | None = None):
        self.marca = marca   # 'x' | 'a' | '?' | '->'
        self.texto = texto
        self.linea = linea
        self.origen = origen  # 'item' | 'heading'
        # Modulo citado por el ENCABEZADO de la seccion a la que pertenece
        # esta tarea (los items no siempre repitan la cita del modulo).
        self.seccion_mod = seccion_mod

    @property
    def simbolo(self) -> str:
        return SIMBOLOS[self.marca]


def _modulos_de_linea(texto: str) -> set[str]:
    """IDs canonicos de modulos citados en una linea."""
    ids: set[str] = set()
    for m in RE_MODULO_NOMBRE.finditer(texto):
        ids.add(_canon_id(m.group(1)))
    for m in RE_MODULO_M.finditer(texto):
        ids.add(_canon_id(m.group(1)))
    return ids


def extraer_tareas(texto: str) -> list[Tarea]:
    """Extrae tareas con marca de un backlog, en items de lista y encabezados.

    Recorre el texto linea por linea para mantener el **modulo de seccion**: el
    ultimo encabezado que cite exactamente un modulo presta ese modulo a los
    items que no citan ninguno (asi se detectan, p. ej., items [ ] de M62 bajo
    un encabezado "### 62-Memoria" que no repiten el ID).

    Algunos backlogs (p. ej. atria-dawn-s3) ponen la marca en el TITULO del
    encabezado ("### L-09 - M108 - `[x]` CERRADO") en vez de en items; hay que
    soportar ambos formatos.
    """
    tareas: list[Tarea] = []
    seccion_mod: str | None = None
    for i, linea in enumerate(texto.splitlines(), start=1):
        if linea.lstrip().startswith("#"):
            titulo = linea.lstrip("#").strip()
            mods = _modulos_de_linea(titulo)
            # Solo heredan seccion los encabezados que citan UN solo modulo.
            seccion_mod = next(iter(mods)) if len(mods) == 1 else seccion_mod
            m = RE_MARCA_HEADING.search(titulo)
            if m:
                texto_tarea = RE_MARCA_HEADING.sub("", titulo).strip(" -—")
                tareas.append(Tarea(_norm_marca(m.group(1)), texto_tarea, i,
                                    "heading", seccion_mod))
            continue
        m = RE_ITEM.match(linea)
        if m:
            tareas.append(Tarea(_norm_marca(m.group(1)), m.group(2).strip(), i,
                                "item", seccion_mod))
    return tareas


def modulos_citados(tarea: Tarea) -> set[str]:
    """IDs de modulos citados por una tarea (propios + seccion heredada)."""
    propios = _modulos_de_linea(tarea.texto)
    if propios:
        return propios
    return {tarea.seccion_mod} if tarea.seccion_mod else set()

# ---------------------------------------------------------------------------
# Verificacion de un modelo
# ---------------------------------------------------------------------------

def _citas_modulo(texto: str) -> list[tuple[int, str]]:
    """Todas las citas a modulos de una linea con su posicion."""
    out: list[tuple[int, str]] = []
    for m in RE_MODULO_NOMBRE.finditer(texto):
        out.append((m.start(), _canon_id(m.group(1))))
    for m in RE_MODULO_M.finditer(texto):
        out.append((m.start(), _canon_id(m.group(1))))
    out.sort(key=lambda p: p[0])
    return out


def cierres_linea(texto: str) -> list[tuple[str, int]]:
    """Asocia cada conteo de una linea con el modulo citado mas cercano a su
    izquierda.

    Las lineas de backlog resumen varios modulos ("M44 ... 76/0/37, M114 ...
    76/185"); cruzar el modulo con el conteo por posicion evita asociar a M44
    el conteo de M114. Devuelve [(id_canonico, x_afirmado)].
    """
    citas = _citas_modulo(texto)
    out: list[tuple[str, int]] = []
    for cm in RE_CONTEO.finditer(texto):
        mod = None
        for pos, idm in reversed(citas):
            if pos < cm.start():
                mod = idm
                break
        if mod is not None:
            out.append((mod, int(cm.group(1))))
    return out


def verificar_modelo(nombre: str, disponibles: dict[str, str],
                     umbral: int = 5) -> dict:
    """Analiza un backlog. Devuelve un dict con el reporte completo."""
    ruta = TAREAS / nombre / "BACKLOG-MASTER.md"
    reporte: dict = {
        "modelo": nombre,
        "existe": ruta.is_file(),
        "marcas": {},
        "cierre_afirmado": [],
        "drift_inverso": [],
        "encurso_colgado": [],
        "modulos_inexistentes": [],
    }
    if not ruta.is_file():
        return reporte

    texto = leer(ruta)
    tareas = extraer_tareas(texto)
    for t in tareas:
        reporte["marcas"][t.simbolo] = reporte["marcas"].get(t.simbolo, 0) + 1

    cache_x: dict[str, set[str]] = {}   # id_modulo -> items [x] normalizados
    cache_conteo: dict[str, dict] = {}  # id_modulo -> conteo real

    def _conteo_real(id_mod: str):
        if id_mod not in cache_conteo:
            carpeta = disponibles.get(id_mod)
            cache_conteo[id_mod] = contar_checklist(carpeta) if carpeta else None
        return cache_conteo[id_mod]

    for t in tareas:
        ids = modulos_citados(t)
        for id_mod in sorted(ids):
            carpeta = disponibles.get(id_mod)
            if carpeta is None:
                reporte["modulos_inexistentes"].append({
                    "linea": t.linea, "id": id_mod, "tarea": t.texto[:120],
                })
                continue

            # 2) Drift inverso: items [ ] del backlog que ya estan [x].
            if t.marca == "a" and t.origen == "item":
                if id_mod not in cache_x:
                    cache_x[id_mod] = items_checklist_x(carpeta)
                clave = normalizar(t.texto)
                if len(clave) >= MIN_TEXTO_DRIFT:
                    hechos = cache_x[id_mod]
                    if clave in hechos or any(
                        k.startswith(clave[:40]) for k in hechos
                    ):
                        reporte["drift_inverso"].append({
                            "linea": t.linea, "modulo": "M" + id_mod,
                            "item": t.texto[:120],
                        })

        # 1) Cierres afirmados: items [x] con conteo de modulo, asociando
        #    cada conteo al modulo citado mas cercano a su izquierda. Solo se
        #    reportan los deltas MATERIALES (>= umbral): las variaciones de
        #    pocos items son ruido normal.
        if t.marca == "x" and t.origen == "item":
            for id_mod, afirmados in cierres_linea(t.texto):
                real = _conteo_real(id_mod)
                if real is None:
                    continue
                delta = afirmados - real["x"]
                if abs(delta) >= umbral:
                    reporte["cierre_afirmado"].append({
                        "linea": t.linea, "modulo": "M" + id_mod,
                        "afirmado_x": afirmados, "real": real,
                        "delta": delta,
                        "nota": ("RETROCESO posterior" if delta > 0
                                 else "avance posterior"),
                    })

    # 3) Marcas EN CURSO colgadas: si la misma tarea base aparece despues con
    #    [x], el [->] original no se cerro in-situ (patron de duplicado).
    for t in tareas:
        if t.marca != "->":
            continue
        base = normalizar(t.texto)
        cerrado = any(
            x.marca == "x" and normalizar(x.texto).startswith(base[:40])
            for x in tareas
        )
        reporte["encurso_colgado"].append({
            "linea": t.linea, "tarea": t.texto[:120],
            "tiene_cierre_duplicado": cerrado,
        })

    # Eliminar duplicados de las listas de hallazgos (misma linea+modulo).
    for clave in ("cierre_afirmado", "drift_inverso", "modulos_inexistentes"):
        vistas: set = set()
        unicas = []
        for h in reporte[clave]:
            k = (h["linea"], h.get("modulo", h.get("id")))
            if k not in vistas:
                vistas.add(k)
                unicas.append(h)
        reporte[clave] = unicas

    return reporte


# ---------------------------------------------------------------------------
# Reporte
# ---------------------------------------------------------------------------

def nivel_alertas(reporte: dict) -> int:
    """Numero de hallazgos materiales (drift inverso + modulos inexistentes)."""
    return (len(reporte["drift_inverso"])
            + len(reporte["modulos_inexistentes"]))


def imprimir_reporte(reporte: dict) -> None:
    m = reporte["modelo"]
    if not reporte["existe"]:
        print(f"== {m}: SIN BACKLOG-MASTER.md")
        return
    marcas = reporte["marcas"]
    resumen = " ".join(f"{k}={v}" for k, v in sorted(marcas.items()))
    print(f"== {m}: {resumen}")

    if reporte["cierre_afirmado"]:
        print(f"   cierres afirmados con delta ({len(reporte['cierre_afirmado'])}):")
        for h in reporte["cierre_afirmado"][:12]:
            r = h["real"]
            print(f"     L{h['linea']} {h['modulo']}: afirma {h['afirmado_x']} "
                  f"[x] vs real {r['x']}/{r['a']}/{r['?']} "
                  f"({h['delta']:+d}, {h['nota']})")

    if reporte["drift_inverso"]:
        print(f"   DRIFT INVERSO ({len(reporte['drift_inverso'])}):"
              " items [ ] del backlog ya [x] en el modulo:")
        for h in reporte["drift_inverso"][:15]:
            print(f"     L{h['linea']} {h['modulo']}: {h['item']}")

    colgados = reporte["encurso_colgado"]
    if colgados:
        duplicados = [c for c in colgados if c["tiene_cierre_duplicado"]]
        print(f"   [->] EN CURSO: {len(colgados)}"
              + (f" ({len(duplicados)} con [x] duplicado mas abajo)" if duplicados else ""))

    if reporte["modulos_inexistentes"]:
        print(f"   MODULOS INEXISTENTES ({len(reporte['modulos_inexistentes'])}):")
        for h in reporte["modulos_inexistentes"][:10]:
            print(f"     L{h['linea']} id {h['id']}: {h['tarea']}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Verifica la sincronizacion backlog <-> checklist (LOTE 12)."
    )
    parser.add_argument("--modelo", action="append", default=[],
                        help="limitar a uno o mas modelos (repetible)")
    parser.add_argument("--dry-run", action="store_true",
                        help="no escribe nada (el script es read-only por diseno)")
    parser.add_argument("--json", action="store_true",
                        help="salida parseable en vez de texto")
    parser.add_argument("--solo-alertas", action="store_true",
                        help="solo modelos con hallazgos materiales")
    parser.add_argument("--umbral", type=int, default=5,
                        help="delta minimo en cierres afirmados (default 5)")
    args = parser.parse_args()

    if not TAREAS.is_dir():
        print("DETECTOR CIEGO: no existe DOCUMENTACION/TAREAS-POR-MODELO/",
              file=sys.stderr)
        return 3

    modelos = sorted(d.name for d in TAREAS.iterdir() if d.is_dir())
    if args.modelo:
        filtro = set(args.modelo)
        modelos = [m for m in modelos if m in filtro]

    if not modelos:
        print("DETECTOR CIEGO: no hay backlogs que analizar", file=sys.stderr)
        return 3

    disponibles = modulos_disponibles()
    reportes = [verificar_modelo(m, disponibles, args.umbral)
                for m in modelos]

    con_backlog = [r for r in reportes if r["existe"]]
    if not con_backlog:
        print("DETECTOR CIEGO: ningun modelo tiene BACKLOG-MASTER.md",
              file=sys.stderr)
        return 3

    if args.json:
        print(json.dumps({"modelos": reportes}, ensure_ascii=False, indent=1))
    else:
        print("=" * 72)
        print("Sincronizacion backlog <-> checklist (TAREAS-POR-MODELO)")
        print("=" * 72)
        for r in reportes:
            if args.solo_alertas and r["existe"] and nivel_alertas(r) == 0:
                continue
            imprimir_reporte(r)
        print("=" * 72)
        total_drift = sum(len(r["drift_inverso"]) for r in reportes)
        total_inex = sum(len(r["modulos_inexistentes"]) for r in reportes)
        total_cierres = sum(len(r["cierre_afirmado"]) for r in reportes)
        print(f"Modelos con backlog: {len(con_backlog)}/{len(modelos)}")
        print(f"Cierres afirmados con delta: {total_cierres}")
        print(f"DRIFT INVERSO (trabajo ya hecho): {total_drift}")
        print(f"Modulos inexistentes citados: {total_inex}")
        print("READ-ONLY: no se modifico ningun backlog.")

    if total_drift or total_inex:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
