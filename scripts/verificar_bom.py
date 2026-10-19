#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Verificador/reparador de BOM UTF-8 (AGENTS.md §28: UTF-8 SIN BOM).

Por que existe separado de scripts/fix_encoding.py: este ultimo DETECTA el BOM
(lineas 195-196: hace s = s[1:]) pero despues devuelve ("ok", None) y su
llamador solo reescribe los archivos clasificados cp1252/mojibake (linea 260).
Resultado: el BOM se descarta en memoria y el archivo nunca se toca. Por eso
sobrevivian cientos de BOMs. Mientras ese bug no se corrija, esta es la
herramienta que si reescribe.

Igual que con el mojibake, diagnosticar y reparar estan separados: por defecto
solo informa y sale con codigo 1 si hay BOM. La reparacion exige --fix.

Uso:
    python scripts/verificar_bom.py                  # informar
    python scripts/verificar_bom.py --fix            # quitar BOM
    python scripts/verificar_bom.py --fix Logs       # solo bajo Logs/
    python scripts/verificar_bom.py --estricto       # U+FEFF embebido tambien falla
    echo $?   # 0 = sin BOM, 1 = habia BOM (antes de --fix)

COBERTURA (ampliada 2026-10-18, reincidencia 3 del BOM segun msg 312 del director):
hasta esta version el escaner leia SOLO los primeros 3 bytes, asi que se le
escapaban los dos modos de falla reales de la flota:

  1. **UTF-16** (`FF FE` / `FE FF`): es lo que escribe `Set-Content` de
     PowerShell 5.1 y el redirect `>` de PS5.1. NO empieza con `EF BB BF`, por
     lo que el gate lo daba por LIMPIO mientras el archivo estaba en UTF-16.
     Ahora es FALLO DURO (mismo exit 1 que el BOM UTF-8). No se repara con
     `--fix`: transcodificar UTF-16 -> UTF-8 es una decision de contenido
     (puede haber caracteres fuera de rango), se informa y se arregla a mano.
  2. **U+FEFF EMBEBIDO** (no al inicio): invisible para grep, rompe parsers
     por bytes. Se informa como AVISO, NO cambia el exit code, porque hay
     casos legitimos medidos en el repo: el propio BACKLOG-MASTER de
     DeepSeek-V4.1-Flash cita un `\ufeff1536` DENTRO de backticks para
     documentar un defecto del pool de logs. Convertirlo en fallo duro
     obligaria a borrar la evidencia. `--estricto` lo vuelve fallo cuando la
     deuda este limpia.
"""
import os
import sys

BOM = b'\xef\xbb\xbf'
UTF16_BOM = (b'\xff\xfe', b'\xfe\xff')
EXT = ('.md', '.gd', '.txt', '.json', '.cfg', '.py', '.tres', '.tscn',
       '.yml', '.yaml', '.po', '.iss', '.godot', '.shader', '.import')
# Respaldos y dependencias: no son texto versionado "vivo", no se tocan.
# (Se comparan en minusculas: en el repo conviven `Obsoletos/` y `OBSOLETOS/`.)
EXCLUIDOS_DIR = ('.git', 'node_modules', '__pycache__', '.godot', 'bin',
                 'out', 'obsoletos', 'addons', '.workbuddy-ai', 'build',
                 'dist', '.venv', 'venv',
                 # `game/isla-ancestral/Godot/` = user:// (runtime). Ademas
                 # m87_val_bom.po es el BOM LEGITIMO: es el fixture con el que
                 # se prueba el validador de .po. No se debe "arreglar".
                 'godot')
# Todo directorio oculto se salta salvo `.github` (workflows) y `.gitea`.
# Motivo real: `.kilo/worktrees/<nombre>/` es un worktree de otro agente y
# metia 463 "BOM" que no son del repo versionado.
OCULTOS_PERMITIDOS = ('.github', '.gitea')


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


def clasificar(p):
    """Devuelve 'bom' | 'utf16' | 'feff' | 'ok' | None (no se pudo leer).

    Lee el archivo COMPLETO a proposito: con los primeros 3 bytes no se puede
    ver un U+FEFF embebido ni distinguir UTF-16 sin BOM declarado.
    """
    try:
        with open(p, 'rb') as fh:
            raw = fh.read()
    except OSError:
        return None
    if raw.startswith(BOM):
        return 'bom'
    if raw[:2] in UTF16_BOM:
        return 'utf16'
    if BOM in raw:
        return 'feff'
    return 'ok'


def escanear_detalle(raiz, prefijos):
    """Barre `raiz` y clasifica cada archivo de texto. Devuelve dict de listas."""
    detalle = {'bom': [], 'utf16': [], 'feff': []}
    for dirpath, dirnames, filenames in os.walk(raiz):
        dirnames[:] = [d for d in dirnames if not salta_dir(d)]
        for fn in filenames:
            if not fn.endswith(EXT):
                continue
            p = os.path.join(dirpath, fn)
            rel = os.path.relpath(p, raiz).replace('\\', '/')
            if prefijos and not any(rel.startswith(x) for x in prefijos):
                continue
            clase = clasificar(p)
            if clase in detalle:
                detalle[clase].append(rel)
    for k in detalle:
        detalle[k].sort()
    return detalle


def escanear(raiz, prefijos):
    """Compatibilidad: lista de archivos que BLOQUEAN (BOM UTF-8 + UTF-16)."""
    d = escanear_detalle(raiz, prefijos)
    return sorted(d['bom'] + d['utf16'])


def main():
    args = [a for a in sys.argv[1:]]
    fix = '--fix' in args
    estricto = '--estricto' in args
    args = [a for a in args if a not in ('--fix', '--estricto')]
    prefijos = [a.strip('/').replace('\\', '/') for a in args if not a.startswith('-')]

    os.chdir(raiz_repo())
    detalle = escanear_detalle('.', prefijos)
    hallados = sorted(detalle['bom'] + detalle['utf16'])
    feff = detalle['feff']

    if not hallados and not feff:
        print('Sin BOM: ningun archivo empieza con EF BB BF ni con FF FE / FE FF,')
        print('y ninguno tiene U+FEFF embebido.')
        return 0

    if hallados:
        # Recuento por carpeta de primer nivel para dimensionar el problema.
        por_carpeta = {}
        for r in hallados:
            cabeza = r.split('/')[0] if '/' in r else '(raiz)'
            por_carpeta[cabeza] = por_carpeta.get(cabeza, 0) + 1

        print('Archivos con BOM: %d' % len(hallados))
        for k, v in sorted(por_carpeta.items(), key=lambda x: -x[1]):
            print('  %-24s %4d' % (k, v))
        print('')

    if feff:
        print('AVISO: %d archivo(s) con U+FEFF EMBEBIDO (no al inicio). No bloquea'
              % len(feff))
        print('       el gate (puede ser una cita/fixture legitima); revisar a mano:')
        for r in feff[:20]:
            print('  %s' % r)
        if len(feff) > 20:
            print('  ... y %d mas' % (len(feff) - 20))
        print('')

    if not hallados:
        return 1 if (estricto and feff) else 0

    if detalle['utf16']:
        print('UTF-16 detectado (Set-Content de PowerShell 5.1 / redirect de PS5.1).')
        print('NO se repara con --fix: transcodificar a UTF-8 puede perder datos.')
        for r in detalle['utf16'][:40]:
            print('  %s' % r)
        print('')

    if not fix:
        for r in hallados[:40]:
            print('  %s' % r)
        if len(hallados) > 40:
            print('  ... y %d mas' % (len(hallados) - 40))
        print('\nACCION: python scripts/verificar_bom.py --fix [carpeta]')
        return 1

    ok = 0
    for r in hallados:
        try:
            with open(r, 'rb') as fh:
                raw = fh.read()
        except OSError as e:
            print('  [ERR lectura] %s -> %s' % (r, e))
            continue
        if not raw.startswith(BOM):
            # UTF-16: no se toca (ver arriba).
            continue
        # Se preserva el resto del archivo byte a byte: solo se quitan 3 bytes.
        with open(r, 'wb') as fh:
            fh.write(raw[3:])
        ok += 1
    print('BOM quitado en %d archivo(s).' % ok)
    # Si quedaron UTF-16 sin reparar, el gate NO puede declararse verde.
    return 1 if detalle['utf16'] else 0


if __name__ == '__main__':
    sys.exit(main())
