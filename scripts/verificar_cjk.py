#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
#
# SB-06 — space-bunny-alpha / Kilo Code — 2026-10-05 — Log 1294
#
# `verificar_cjk.py` — Gate de CI que falla si encuentra caracteres CJK en un
# archivo de texto del repo.
#
# POR QUE EXISTE (el problema que lo motiva):
#   Un agente genero caracteres CJK colados dentro de frases en espanol, en 4
#   documentos distintos y 3 sesiones diferentes (space-bunny-alpha, Log 1282
#   addendum). Es un fallo SISTEMATICO de generacion, no un accidente, asi que
#   no sirve con "tener cuidado": hace falta un gate. El AGENTS.md 28 lo pide
#   implicitamente al prohibir el mojibake; aqui se cubre el caso CJK, que el
#   `scripts/diagnosticar_mojibake.py` existente NO cubre (busca latin-1
#   mal decodificado, no CJK).
#
# POSTURA (la fijo el director): el CJK intencional **no deberia existir en
# ningun archivo del repo**. Por eso la lista de excepciones es VACIA por
# defecto. Se puede ampliar con `--permitir`, y una linea puede declararse
# exenta con el marcador inline `cjk-gate: allow`.
#
# DISTINCION IMPORTANTE: esto NO es "detectar mojibake". Un archivo puede estar
# perfectamente en UTF-8 y aun asi tener un CJK colado (es lo que me pasaba: el
# archivo estaba en UTF-8 valido, el contenido estaba mal). Y al reves: un
# archivo puede estar mal decodificado SIN CJK. Son dos checks distintos.
#
# Uso:
#   python scripts/verificar_cjk.py                 # escanea el repo
#   python scripts/verificar_cjk.py --raiz <dir>    # otra raiz
#   python scripts/verificar_cjk.py --permitir a.txt,b.md
#   python scripts/verificar_cjk.py --json          # salida para consumo de otra herramienta
#
# Codigos de salida (misma convencion que verificar_checklist.py, BUG-075):
#   0  sin CJK: todo bien.
#   1  mire y hay CJK.
#   3  DETECTOR CIEGO: no pude recorrer el arbol, o un archivo de texto no es
#      UTF-8 valido. NO es «sin CJK»: es «no mire».
#      Un archivo ilegible se CUENTA como problema, nunca se saltea en
#      silencio: un gate que se traga los errores es peor que no tener gate.
#
# AGENTS.md 28: UTF-8 sin BOM, LF.

import argparse
import io
import json
import os
import re
import sys
from pathlib import Path

if sys.stdout and hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

RAIZ_DEFECTO = Path(__file__).resolve().parent.parent

# --- Que es "texto" --------------------------------------------------------
# Solo estas extensiones se escanean. Los binarios (.glb, .png, .import, .exe…)
# pueden contener CJK en los metadatos SIN que sea un defecto, asi que
# escanearlos produciria falsos positivos y ruido.
EXTENSIONES_TEXTO = {
    ".md", ".markdown", ".txt", ".csv", ".tsv",
    ".py", ".gd", ".cs", ".ps1", ".bat", ".sh",
    ".json", ".tres", ".tscn", ".godot", ".cfg", ".ini", ".toml", ".yml", ".yaml",
    ".uid", ".import", ".xml", ".html", ".css", ".js", ".gitignore", ".gitattributes",
}

# --- Directorios que NO se escanean ---------------------------------------
# Solo los que NO estan en .gitignore y aun asi no son prosa del proyecto.
# Todo lo demas (node_modules, .venv, .workbuddy-ai, Obsoletos, out/...) sale de
# leer el .gitignore del proyecto, para no mantener una lista paralela que se
# desactualiza — que es exactamente el modo de fallo que este gate caza.
DIRS_EXCLUIDOS = {".git", ".godot", "__pycache__"}
SUBDIRS_EXCLUIDOS = {(".claude", "skills")}


def leer_gitignore(raiz: Path):
    """Lee el .gitignore del proyecto y devuelve [(patron, dir_only, anclado)].

    Subconjunto soportado (documentado a proposito, no es un gitignore completo):
      - lineas vacias y comentarios (#) se ignoran
      - `!patron` (negacion) se IGNORA: no se soporta re-inclusion
      - `dir/`  -> excluir el directorio en cualquier nivel
      - `/dir/` -> excluir SOLO en la raiz (anclado)
      - `ruta/dir/` -> excluir esa ruta
      - `*.ext` -> excluir por extension
    Lo que no se soporta: escapes con backslash, clases de caracter tipo
    `[abc]`, y `**` en medio. Si el proyecto usara eso, el gate podria escanear
    algo que .gitignore excluye: eso produce un falso POSITIVO (mas severo que
    perder un hallazgo), nunca un falso verde.
    """
    patrones = []
    gi = raiz / ".gitignore"
    if not gi.is_file():
        return patrones
    try:
        texto = gi.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return patrones
    for linea in texto.split("\n"):
        s = linea.strip()
        if not s or s.startswith("#") or s.startswith("!"):
            continue
        dir_only = s.endswith("/")
        if dir_only:
            s = s[:-1]
        anclado = s.startswith("/")
        if anclado:
            s = s[1:]
        s = s.rstrip("/")
        if not s:
            continue
        patrones.append((s, dir_only, anclado))
    return patrones


def ruta_ignorada(rel_parts, patrones, es_dir):
    """True si la ruta (partes relativas a la raiz) matchea algún patron.

    `es_dir` es lo que hace que la logica funcione: un patron `build/` excluye
    el DIRECTORIO build, no un archivo llamado build. Sin este parametro la
    comparacion es ambigua y el gate escanea directorios que .gitignore excluye
    (bug propio, cazado por test_gitignore_manda en la 1a corrida).
    """
    import fnmatch
    rel = "/".join(rel_parts)
    n = len(rel_parts)
    for pat, dir_only, anclado in patrones:
        if anclado:
            # solo matchea si la ruta empieza exactamente con el patron
            if rel == pat or rel.startswith(pat + "/"):
                return True
            if fnmatch.fnmatch(rel, pat):
                return True
            continue
        if "/" in pat:
            # patron con ruta (no anclado): matchea como prefijo o exacto
            if rel == pat or rel.startswith(pat + "/"):
                return True
            if fnmatch.fnmatch(rel, pat):
                return True
            continue
        # patron simple: matchea cualquier nivel
        for i, parte in enumerate(rel_parts):
            if not fnmatch.fnmatch(parte, pat):
                continue
            if dir_only:
                # `foo/` solo excluye: (a) el directorio foo, o (b) cualquier
                # directorio foo que sea padre de la ruta examinada.
                if es_dir:
                    return True
                if i < n - 1:
                    return True
            else:
                # `*.ext` excluye archivos; tambien directoros con esa extension
                return True
    return False

# --- El patron -------------------------------------------------------------
# U+2E80..U+2EFF  : radicajos CJK y supplementation (Kangxi)
# U+3000..U+303F  : simbolos y PUNTUACION CJK
#                  (ejemplos: U+3001 coma ideografica, U+3002 punto, U+301c tilde,
#                   U+300C/D corchetes, U+300A/B angulares, U+2026 puntos suspensivos)
#                  OJO: los ejemplos van en NOTACION, no literales. El gate
#                  detecta su propia documentacion si se los pone (medido: asi
#                  se detecto a si mismo la primera vez).
# U+3040..U+30FF  : hiragana + katakana (japones)
# U+31F0..U+31FF  : katakana phonetic extensions
# U+3400..U+4DBF  : extension A
# U+4E00..U+9FFF  : ideogramas CJK unificados
# U+F900..U+FAFF  : ideogramas de compatibilidad
# U+20000..       : supplementary ideographic plane (ext B+), Utf-8 de 4 bytes
#
# U+3000..U+303F se AGREGO después de que el gate se escapara un token meu:
# la coma ideografica U+3001 NO esta en U+4E00..U+9FFF, asi que un patron
# que solo cubria ideogramas la deja pasar. Encontrado en 11-BUGS.md (SB-11).
#
# NO se incluye U+FF00..U+FFEF (fullwidth forms): el latin fullwidth (U+FF21) es
# legitimo en texto japones y hay un test que exige NO marcarlo.
PATRON_CJK = re.compile(
    "["
    "\u2e80-\u2eff"
    "\u3000-\u303f"
    "\u3040-\u30ff"
    "\u31f0-\u31ff"
    "\u3400-\u4dbf"
    "\u4e00-\u9fff"
    "\uf900-\ufaff"
    "\U00020000-\U0002ffff"
    "]"
)

# Marcador inline para exentar una linea. Se busca como texto plano para no
# depender de que sea un comentario valido del lenguaje del archivo.
MARCADOR_OK = "cjk-gate: allow"


class DetectorCiegoError(RuntimeError):
    """No pude recorrer el arbol o leer un archivo de texto. NO es «sin CJK»."""


def es_texto(ruta: Path):
    """El archivo tiene extension de texto segun EXTENSIONES_TEXTO."""
    return ruta.suffix.lower() in EXTENSIONES_TEXTO


def archivo_permitido(ruta: Path, raiz: Path, permitidos):
    try:
        rel = ruta.relative_to(raiz).as_posix()
    except ValueError:
        rel = ruta.as_posix()
    return rel in permitidos or ruta.as_posix() in permitidos


def escanear_archivo(ruta: Path):
    """Devuelve (hallazgos, ilegible).

    hallazgos : lista de (num_linea, caracter, contexto) con CJK
    ilegible  : str con el motivo, o None

    Un archivo que NO es UTF-8 valido no se salta en silencio: se devuelve como
    `ilegible` para que el gate lo reporte como DEFECTO (el AGENTS.md 28 exige
    UTF-8 en todo archivo de texto). Antes esta funcion levantaba y abortaba el
    escaneo entero, lo que hacia inútil el gate: con un solo `_lint.txt` roto
    perdia el reporte de los otros ~800 archivos. La version levantadora queda
    como `escanear_archivo_estricto` para quien prefiera fail-fast.
    """
    try:
        datos = ruta.read_bytes()
    except OSError as e:
        return [], "no se pudo leer: %s" % e

    if datos[:3] == b"\xef\xbb\xbf":
        datos = datos[3:]

    try:
        texto = datos.decode("utf-8")
    except UnicodeDecodeError as e:
        return [], ("no es UTF-8 valido (byte %d, razon: %s)"
                    % (e.start, e.reason))

    hallazgos = []
    for i, linea in enumerate(texto.split("\n"), 1):
        if MARCADOR_OK in linea:
            continue
        for m in PATRON_CJK.finditer(linea):
            hallazgos.append((i, m.group(0), linea.strip()[:100]))
    return hallazgos, None


def escanear_archivo_estricto(ruta: Path):
    """Variante fail-fast: levanta DetectorCiegoError si el archivo es ilegible."""
    hits, ilegible = escanear_archivo(ruta)
    if ilegible:
        raise DetectorCiegoError("%s %s" % (ruta, ilegible))
    return hits


def recorrer(raiz: Path, permitidos):
    """Recorre el arbol.

    Devuelve (cjk_por_archivo, ilegibles, n_archivos, n_bom).
    """
    if not raiz.is_dir():
        raise DetectorCiegoError(f"la raiz no existe o no es un directorio: {raiz}")

    patrones_gi = leer_gitignore(raiz)
    cjk = {}
    ilegibles = {}
    n_archivos = 0
    n_bom = 0
    n_excluidos = 0

    for dirp, dirnames, filenames in os.walk(raiz):
        partes_raiz = Path(dirp).relative_to(raiz).parts if dirp != str(raiz) else ()
        # podar: directorios excluidos + los que matchean .gitignore
        kept = []
        for d in dirnames:
            if d in DIRS_EXCLUIDOS:
                continue
            if any(partes_raiz[: len(p)] == p for p in SUBDIRS_EXCLUIDOS):
                continue
            if ruta_ignorada(partes_raiz + (d,), patrones_gi, es_dir=True):
                n_excluidos += 1
                continue
            kept.append(d)
        dirnames[:] = kept
        if any(partes_raiz[: len(p)] == p for p in SUBDIRS_EXCLUIDOS):
            continue

        for fn in filenames:
            ruta = Path(dirp) / fn
            partes = partes_raiz + (fn,)
            if not es_texto(ruta):
                continue
            if ruta_ignorada(partes, patrones_gi, es_dir=False):
                n_excluidos += 1
                continue
            if archivo_permitido(ruta, raiz, permitidos):
                continue
            n_archivos += 1
            try:
                rel = ruta.relative_to(raiz).as_posix()
            except ValueError:
                rel = ruta.as_posix()
            if ruta.read_bytes()[:3] == b"\xef\xbb\xbf":
                n_bom += 1
            hits, ilegible = escanear_archivo(ruta)
            if ilegible:
                ilegibles[rel] = ilegible
            elif hits:
                cjk[rel] = hits

    return cjk, ilegibles, n_archivos, n_bom, n_excluidos


def main():
    ap = argparse.ArgumentParser(
        description="SB-06: falla si encuentra caracteres CJK en archivos de texto del repo."
    )
    ap.add_argument("--raiz", type=Path, default=RAIZ_DEFECTO,
                    help="Raiz a escanear (default: la raiz del repo).")
    ap.add_argument("--permitir", default="",
                    help="Lista de rutas relativas separadas por coma que se exentan.")
    ap.add_argument("--json", action="store_true",
                    help="Salida en JSON (para consumption por otro script).")
    ap.add_argument("--sin-bom", action="store_true",
                    help="No reportar los archivos con BOM (solo interested en CJK).")
    args = ap.parse_args()

    permitidos = {p.strip() for p in args.permitir.split(",") if p.strip()}

    try:
        cjk, ilegibles, n_archivos, n_bom, n_excluidos = recorrer(args.raiz, permitidos)
    except DetectorCiegoError as e:
        if args.json:
            print(json.dumps({"error": str(e), "codigo": 3}, ensure_ascii=False))
        else:
            print("=" * 68)
            print("DETECTOR CIEGO (exit 3): no pude recorrer el arbol.")
            print(f"   {e}")
            print()
            print("Esto NO es «sin CJK»: es «no mire».")
        return 3

    total = sum(len(v) for v in cjk.values())
    n_ileg = len(ilegibles)

    if args.json:
        print(json.dumps({
            "archivos_escaneados": n_archivos,
            "archivos_con_cjk": len(cjk),
            "caracteres_cjk": total,
            "archivos_ilegibles": n_ileg,
            "archivos_con_bom": n_bom,
            "cjk": {k: [{"linea": ln, "caracter": c, "contexto": ctx}
                        for ln, c, ctx in v]
                   for k, v in cjk.items()},
            "ilegibles": ilegibles,
        }, ensure_ascii=False, indent=2))
        return 1 if (total or n_ileg or (n_bom and not args.sin_bom)) else 0

    print("=" * 68)
    print("SB-06 — GATE ANTI-CJK")
    print("=" * 68)
    print("raiz            : %s" % args.raiz)
    print("archivos texto  : %d  (excluidos por .gitignore / vendor: %d)"
          % (n_archivos, n_excluidos))
    print("archivos con CJK: %d  (%d caracteres)" % (len(cjk), total))
    print("ilegibles       : %d  (texto no UTF-8: es un defecto, no se los saltea)" % n_ileg)
    if not args.sin_bom:
        print("archivos con BOM: %d  (AGENTS.md 28 exige UTF-8 SIN BOM)" % n_bom)
    if permitidos:
        print("exentos         : %s" % ", ".join(sorted(permitidos)))
    print()

    if cjk:
        print("ARCHIVOS CON CJK:")
        for rel in sorted(cjk):
            print("  %s" % rel)
            for ln, c, ctx in cjk[rel]:
                print("     L%-5d U+%04X  %s" % (ln, ord(c), ctx))
        print()
        print("Cada uno de estos es un caracter colado dentro de una frase en espanol.")
        print("El AGENTS.md 28 los prohibi. Un archivo puede estar en UTF-8 VALIDO y aun")
        print("asi tener CJK: por eso este check es distinto del de mojibake.")
        print()

    if ilegibles:
        print("ARCHIVOS ILEGIBLES (texto que no es UTF-8 valido):")
        for rel in sorted(ilegibles):
            print("  %-56s %s" % (rel, ilegibles[rel]))
        print()

    if n_bom and not args.sin_bom:
        print("NOTA: %d archivos con BOM. Para el detalle, 'python scripts/verificar_bom.py'." % n_bom)
        print()

    if args.sin_bom:
        if total or n_ileg:
            print("VEREDICTO: FALLA — %d CJK%s."
                  % (total, (" + %d ilegibles" % n_ileg) if n_ileg else ""))
            return 1
        print("VEREDICTO: sin CJK.")
        return 0

    if total or n_ileg or n_bom:
        print("VEREDICTO: FALLA — %d CJK%s%s."
              % (total,
                 (" + %d ilegibles" % n_ileg) if n_ileg else "",
                 (" + %d BOM" % n_bom) if n_bom else ""))
        return 1

    print("VEREDICTO: sin CJK, sin ilegibles y sin BOM.")
    return 0


if __name__ == "__main__":
    sys.exit(main())