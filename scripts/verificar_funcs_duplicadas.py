#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Verificador de FUNCIONES DE NIVEL SUPERIOR DUPLICADAS en scripts GDScript.

Por que existe (Log 1208, M59): Godot rechaza el archivo ENTERO si un script
declara dos veces la misma funcion en el MISMO alcance:

    SCRIPT ERROR: Parse Error: Function "X" has the same name as a previously
    declared function.

Un script asi NO CARGA (el nodo/clase queda roto al 100 %), y ademas contamina
el conteo de "SCRIPT ERROR" de cualquier suite que cargue el proyecto. Es un
defecto silencioso: nada lo detecta hasta que algo intenta cargar el script.

ALCANCE (clave para no dar falsos positivos):
  - Solo cuentan las `func` a NIVEL DE CLASE (indentacion 0). En GDScript una
    funcion anidada solo puede ser una lambda SIN nombre, asi que toda `func`
    con nombre a columna 0 es miembro de la clase del archivo.
  - Las funciones de las INNER CLASSES (`class Foo:` -> indentadas) viven en
    OTRO alcance y pueden repetir nombre legitimamente. Por eso NO se cuentan.
    (addons/gdUnit4 y varios test_*.gd repiten nombres a proposito.)
  - Se ignoran las lineas de comentario (`#`) y las cadenas no se interpretan.

Uso:
    python scripts/verificar_funcs_duplicadas.py            # informar
    python scripts/verificar_funcs_duplicadas.py --selftest # probar el detector
    python scripts/verificar_funcs_duplicadas.py game/isla-ancestral/scripts
    echo $?   # 0 = sin duplicados, 1 = hay duplicados (o fallo el selftest)
"""
import os
import re
import sys

# `func NAME(` a COLUMNA 0 (sin indentacion) => miembro de la clase del archivo.
# Se admite `static func`. NO se admite indentacion (eso es inner class).
RE_FUNC_TOP = re.compile(r'^(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(')
# Una `func` indentada (inner class) — para documentar el descarte, no para contar.
RE_FUNC_INDENT = re.compile(r'^\s+func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(')

EXCLUIDOS_DIR = ('.git', 'node_modules', '__pycache__', '.godot', 'bin', 'out',
                 'obsoletos', '.workbuddy-ai', 'build', 'dist', '.venv', 'venv',
                 'godot')
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


def duplicados_en_texto(texto):
    """Devuelve {nombre: [lineas]} de funcs de nivel superior repetidas."""
    vistas = {}
    for i, linea in enumerate(texto.split('\n'), start=1):
        if linea.lstrip().startswith('#'):
            continue
        m = RE_FUNC_TOP.match(linea)
        if not m:
            continue
        vistas.setdefault(m.group(1), []).append(i)
    return {n: ls for n, ls in vistas.items() if len(ls) > 1}


def escanear(raiz, prefijos):
    hallados = []
    for dirpath, dirnames, filenames in os.walk(raiz):
        dirnames[:] = [d for d in dirnames if not salta_dir(d)]
        for fn in filenames:
            if not fn.endswith('.gd'):
                continue
            p = os.path.join(dirpath, fn)
            rel = os.path.relpath(p, raiz).replace('\\', '/')
            if prefijos and not any(rel.startswith(x) for x in prefijos):
                continue
            try:
                with open(p, 'rb') as fh:
                    raw = fh.read()
            except OSError:
                continue
            texto = raw.decode('utf-8', 'replace')
            dups = duplicados_en_texto(texto)
            if dups:
                hallados.append((rel, dups))
    return sorted(hallados)


def selftest():
    """Prueba el detector: (1) debe CAZAR el duplicado de nivel superior;
    (2) NO debe marcar inner classes; (3) NO debe marcar nombres unicos."""
    casos = [
        # (texto, espera_duplicados)
        ('extends Node\n\nfunc a():\n\tpass\n\nfunc a():\n\tpass\n', True),
        ('extends Node\n\nfunc _ready():\n\tpass\n', False),
        ('extends Node\n\nclass Inner:\n\tfunc a():\n\t\tpass\n\tfunc a():\n\t\tpass\n\nfunc a():\n\tpass\n', False),
        ('extends Node\n\nstatic func x():\n\tpass\n\nfunc x():\n\tpass\n', True),
        ('extends Node\n\n# func a():\nfunc a():\n\tpass\n', False),
    ]
    fallos = 0
    for k, (txt, espera) in enumerate(casos, start=1):
        d = duplicados_en_texto(txt)
        obtuvo = bool(d)
        estado = 'OK' if obtuvo == espera else 'FALLO'
        if obtuvo != espera:
            fallos += 1
        print('  [%s] caso %d: esperaba_dup=%s obtuve=%s %s'
              % (estado, k, espera, obtuvo, sorted(d.keys())))
    # Control negativo global: un archivo real sin duplicados de nivel superior.
    print('  selftest: %d/%d casos OK' % (len(casos) - fallos, len(casos)))
    return 1 if fallos else 0


def main():
    args = [a for a in sys.argv[1:]]
    if '--selftest' in args:
        return selftest()
    prefijos = [a.strip('/').replace('\\', '/') for a in args if not a.startswith('-')]

    os.chdir(raiz_repo())
    hallados = escanear('.', prefijos)

    if not hallados:
        print('Sin funciones de nivel superior duplicadas en .gd.')
        return 0

    total = sum(len(d) for _, d in hallados)
    print('Archivos con funcs de nivel superior duplicadas: %d (total %d nombres)'
          % (len(hallados), total))
    for rel, dups in hallados:
        for nombre, lineas in sorted(dups.items()):
            print('  %s: func %s x%d en lineas %s' % (rel, nombre, len(lineas), lineas))
    print('\nACCION: renombrar/eliminar la definicion duplicada (el script NO compila).')
    return 1


if __name__ == '__main__':
    sys.exit(main())
