#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Verificador de BYTES MAGICOS de los binarios versionados (BUG-042).

Por que existe: `load()` de un recurso corrupto NO devuelve null. Medido en M87
iter. 6: `load("res://assets/fonts/X.ttf")` sobre una pagina HTML 404 guardada
con extension `.ttf` devuelve un `FontFile` NO nulo con las metricas en cero y
FreeType solo emite `Error loading font: ''`. El juego sigue andando con la
fuente de fallback y NO hay excepcion, ni crash, ni test rojo. Tres de las
cuatro `.ttf` del repo eran la pagina `Page not found . GitHub` (~304 KB de
HTML cada una): el TAMANO no lo delataba.

La unica deteccion fiable es leer los PRIMEROS BYTES y compararlos con la firma
que promete la extension. Eso es lo que hace este script.

Alcance: por defecto audita los archivos **versionados** (`git ls-files`), que es
lo que existe en un checkout de CI. Un PNG mal etiquetado en un directorio
gitignoreado (p. ej. `tools/mcp/*/capturas/`) no es un asset del repo y no debe
tumbar la puerta; para revisar tambien esos, usar `--todos`.

Uso:
    python scripts/verificar_binarios.py                 # informar (exit 1 si hay hallazgos)
    python scripts/verificar_binarios.py assets/fonts    # solo bajo esos prefijos
    python scripts/verificar_binarios.py --solo .ttf .png
    python scripts/verificar_binarios.py --todos         # incluye no versionados
    echo $?   # 0 = todos los binarios tienen la firma que su extension promete
"""

import os
import subprocess
import sys

# ---------------------------------------------------------------------------
# Firmas: extension -> lista de FIRMAS ALTERNATIVAS.
# Cada firma es una tupla de pares (offset, bytes) que deben cumplirse TODOS.
# Un archivo pasa si coincide por completo con ALGUNA de las alternativas.
#
# ⚠️ La distincion importa: `.webp` y `.wav` empiezan los dos con `RIFF` en 0 y
# solo se diferencian por los bytes 8-11. Con un OR ingenuo, un WAV con
# extension `.webp` pasaria. Por eso cada alternativa es un conjunto de pares
# que deben cumplirse juntos.
# ---------------------------------------------------------------------------
FIRMAS = {
    # --- Tipografia -------------------------------------------------------
    '.ttf':  [((0, b'\x00\x01\x00\x00'),), ((0, b'true'),),
              ((0, b'ttcf'),), ((0, b'OTTO'),)],
    '.otf':  [((0, b'OTTO'),), ((0, b'\x00\x01\x00\x00'),), ((0, b'ttcf'),)],
    '.ttc':  [((0, b'ttcf'),)],
    '.woff': [((0, b'wOFF'),)],
    '.woff2': [((0, b'wOF2'),)],
    # --- Imagen -----------------------------------------------------------
    '.png':  [((0, b'\x89PNG\r\n\x1a\n'),)],
    '.jpg':  [((0, b'\xff\xd8\xff'),)],
    '.jpeg': [((0, b'\xff\xd8\xff'),)],
    '.gif':  [((0, b'GIF87a'),), ((0, b'GIF89a'),)],
    '.bmp':  [((0, b'BM'),)],
    '.webp': [((0, b'RIFF'), (8, b'WEBP'))],
    '.ico':  [((0, b'\x00\x00\x01\x00'),)],
    '.psd':  [((0, b'8BPS'),)],
    '.tga':  [],  # TGA no lleva firma al principio: se valida por el footer.
    # --- 3D / audio / video ----------------------------------------------
    '.glb':  [((0, b'glTF'),)],
    '.ogg':  [((0, b'OggS'),)],
    '.wav':  [((0, b'RIFF'), (8, b'WAVE'))],
    '.mp3':  [((0, b'ID3'),), ((0, b'\xff\xfb'),), ((0, b'\xff\xf3'),),
              ((0, b'\xff\xf2'),)],
    '.flac': [((0, b'fLaC'),)],
    '.mp4':  [((4, b'ftyp'),)],
    # --- Empaquetado / ejecutables ---------------------------------------
    '.zip':  [((0, b'PK\x03\x04'),), ((0, b'PK\x05\x06'),), ((0, b'PK\x07\x08'),)],
    '.pck':  [((0, b'GDPC'),)],
    '.exe':  [((0, b'MZ'),)],
    '.dll':  [((0, b'MZ'),)],
    '.so':   [((0, b'\x7fELF'),)],
    '.dylib': [((0, b'\xcf\xfa\xed\xfe'),), ((0, b'\xce\xfa\xed\xfe'),),
               ((0, b'\xfe\xed\xfa\xcf'),), ((0, b'\xfe\xed\xfa\xce'),)],
    '.wasm': [((0, b'\x00asm'),)],
    # --- Blender ----------------------------------------------------------
    '.blend':  [((0, b'BLENDER'),)],
    '.blend1': [((0, b'BLENDER'),)],
    '.blend2': [((0, b'BLENDER'),)],
}

# Directorios que no son "binarios versionados vivos" (mismo criterio que
# scripts/verificar_bom.py, mas los artefactos de build y el user:// de Godot).
EXCLUIDOS_DIR = ('.git', 'node_modules', '__pycache__', '.godot', 'bin',
                 'out', 'obsoletos', 'addons', '.workbuddy-ai', 'build',
                 'dist', '.venv', 'venv', '.kilo', '.cache', 'papelera',
                 # `game/isla-ancestral/Godot/` es el user:// real: contiene
                 # saves, diagnostics y fixtures de test. No es asset del repo.
                 'godot')
OCULTOS_PERMITIDOS = ('.github', '.gitea')

# Extensiones de texto que, si aparecen DENTRO de un archivo declarado binario,
# delatan una descarga fallida (una pagina HTML/JSON guardada con extension de
# asset). Es la firma exacta de BUG-042.
PISTAS_TEXTO = (
    (b'<!DOCTYPE html', 'HTML'),
    (b'<!doctype html', 'HTML'),
    (b'<html', 'HTML'),
    (b'<?xml', 'XML'),
    (b'{"', 'JSON'),
    (b'404: Not Found', 'TEXTO 404'),
    (b'Not Found', 'TEXTO 404'),
    (b'Page not found', 'TEXTO 404'),
)


def salta_dir(nombre):
    n = nombre.lower()
    if n in EXCLUIDOS_DIR:
        return True
    if nombre.startswith('.') and n not in OCULTOS_PERMITIDOS:
        return True
    return False


def raiz_repo():
    d = os.path.dirname(os.path.abspath(__file__))
    for _ in range(10):
        if os.path.isfile(os.path.join(d, 'AGENTS.md')):
            return d
        p = os.path.dirname(d)
        if p == d:
            break
        d = p
    raise SystemExit('No encontre AGENTS.md subiendo desde %s' % __file__)


def firma_ok(cabeza, variantes):
    """True si la cabeza coincide POR COMPLETO con alguna firma alternativa.

    Cada firma es una tupla de pares (offset, bytes) que deben cumplirse
    TODOS juntos (AND dentro de la firma, OR entre alternativas).
    """
    if not variantes:
        return True  # sin firma conocida (p. ej. .tga): no se puede afirmar nada
    for firma in variantes:
        if all(cabeza[offset:offset + len(magia)] == magia
               for offset, magia in firma):
            return True
    return False


def clasificar_texto(cabeza):
    """Devuelve la etiqueta del texto disfrazado, o '' si no parece texto."""
    bajo = cabeza.lower()
    for pista, etiqueta in PISTAS_TEXTO:
        if pista.lower() in bajo:
            return etiqueta
    # Heuristica general: primeros 64 bytes casi todos imprimibles.
    muestra = cabeza[:64]
    if not muestra:
        return ''
    imprimibles = sum(1 for b in muestra if 32 <= b < 127 or b in (9, 10, 13))
    if imprimibles >= len(muestra) * 0.95:
        return 'TEXTO PLANO'
    return ''


def fragmento(cabeza):
    """Primera linea legible, recortada, para mostrar en el informe."""
    for linea in cabeza.split(b'\n'):
        t = linea.strip()
        if t:
            return t[:60].decode('utf-8', 'replace')
    return ''


def versionados(raiz):
    """Rutas (relativas, con /) de los archivos versionados. None si no hay git."""
    try:
        r = subprocess.run(['git', 'ls-files', '-z'], cwd=raiz,
                           stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    except (OSError, subprocess.SubprocessError):
        return None
    if r.returncode != 0:
        return None
    return [x.decode('utf-8', 'replace') for x in r.stdout.split(b'\x00') if x]


def recorrer(raiz):
    """Rutas (relativas, con /) de todos los archivos no excluidos por directorio."""
    salida = []
    for dirpath, dirnames, filenames in os.walk(raiz):
        dirnames[:] = [d for d in dirnames if not salta_dir(d)]
        for fn in filenames:
            p = os.path.join(dirpath, fn)
            salida.append(os.path.relpath(p, raiz).replace('\\', '/'))
    return salida


def candidatos(raiz, prefijos, solo_ext, todos):
    """Filtra la lista de archivos a auditar y devuelve (rutas, origen)."""
    base = recorrer(raiz) if todos else versionados(raiz)
    if base is None:
        base, origen = recorrer(raiz), 'arbol (git no disponible)'
    else:
        origen = 'arbol completo (--todos)' if todos else 'versionados (git ls-files)'
    if not todos:
        # un archivo versionado puede no estar en el disco (borrado sin stagear)
        base = [r for r in base if os.path.isfile(os.path.join(raiz, r))]
    out = []
    for rel in base:
        ext = os.path.splitext(rel)[1].lower()
        if ext not in FIRMAS:
            continue
        if solo_ext and ext not in solo_ext:
            continue
        if prefijos and not any(rel.startswith(x) for x in prefijos):
            continue
        out.append(rel)
    return sorted(out), origen


def escanear(raiz, rutas):
    """Devuelve la lista de hallazgos sobre las rutas dadas (relativas a raiz)."""
    hallazgos = []
    for rel in rutas:
        ext = os.path.splitext(rel)[1].lower()
        p = os.path.join(raiz, rel)
        try:
            with open(p, 'rb') as fh:
                cabeza = fh.read(64)
        except OSError as e:
            hallazgos.append((rel, ext, 'ILEGIBLE', str(e), 0))
            continue
        if not cabeza:
            hallazgos.append((rel, ext, 'VACIO', '0 bytes', 0))
            continue
        if firma_ok(cabeza, FIRMAS[ext]):
            continue
        texto = clasificar_texto(cabeza)
        if texto:
            motivo = 'TEXTO DISFRAZADO (%s)' % texto
        else:
            motivo = 'FIRMA INCORRECTA'
        hallazgos.append((rel, ext, motivo,
                          cabeza[:4].hex(' '), os.path.getsize(p)))
    return sorted(hallazgos)


def main():
    args = list(sys.argv[1:])
    todos = '--todos' in args
    args = [a for a in args if a != '--todos']
    solo_ext = set()
    if '--solo' in args:
        i = args.index('--solo')
        for a in args[i + 1:]:
            if a.startswith('-'):
                break
            solo_ext.add(a if a.startswith('.') else '.' + a)
        # se quitan del listado de prefijos
        args = args[:i] + [a for a in args[i + 1:] if a.startswith('-')]
    prefijos = [a.strip('/').replace('\\', '/') for a in args if not a.startswith('-')]

    raiz = raiz_repo()
    os.chdir(raiz)
    rutas, origen = candidatos(raiz, prefijos, solo_ext, todos)
    hallazgos = escanear(raiz, rutas)

    if not hallazgos:
        print('Binarios OK: los %d archivos con extension conocida (%s) tienen la '
              'firma que su extension promete.' % (len(rutas), origen))
        return 0

    print('Binarios con firma INVALIDA: %d de %d revisados (%s)\n'
          % (len(hallazgos), len(rutas), origen))
    por_motivo = {}
    for rel, ext, motivo, detalle, tam in hallazgos:
        por_motivo.setdefault(motivo, []).append(rel)
    for motivo, rutas_m in sorted(por_motivo.items(), key=lambda x: -len(x[1])):
        print('  %-32s %d' % (motivo, len(rutas_m)))
    print('')

    for rel, ext, motivo, detalle, tam in hallazgos:
        print('  %s' % rel)
        print('     extension=%s  bytes=%s  firma real=%s' % (ext, tam, detalle))
        print('     %s' % motivo)
        if motivo.startswith('TEXTO DISFRAZADO') and tam:
            try:
                with open(rel, 'rb') as fh:
                    f = fragmento(fh.read(400))
            except OSError:
                f = ''
            if f:
                print('     fragmento: %s' % f)
        print('')

    print('Un binario con extension X y contenido que no es X rompe en SILENCIO:')
    print('load() devuelve un recurso NO nulo con datos vacios. Ver BUG-042.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
