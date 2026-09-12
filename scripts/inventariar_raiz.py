#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Genera DOCUMENTACION/INVENTARIO-RAIZ.md: inventario de los archivos sueltos
de la raiz del repo (Log 853).

Para cada archivo: tamaño, fecha, si esta versionado, cuantas veces se lo
menciona en la documentacion, y la primera linea como indicio de proposito.

TRAMPA QUE MOTIVO ESTE SCRIPT (no quitar):
la primera version genero el inventario leyendo todo como UTF-8. Habia un
archivo UTF-16 en la raiz (`_gen_aprobado.gd`) y el resultado fue:

  - 310 bytes NUL metidos en el markdown -> git lo clasifico de BINARIO
  - U+FFFD incrustados -> el mismo daño irreversible que documenta el Log 852,
    creado por la herramienta que se suponia que lo evitaba.

Por eso la decodificacion de aqui:
  1. detecta BOM (utf-8-sig / utf-16-le / utf-16-be)
  2. detecta UTF-16 sin BOM por el patron de NUL intercalados
  3. si aun falla, cae a latin-1, que NUNCA falla y NUNCA produce U+FFFD
  4. limpia caracteres de control del preview (los NUL rompen el markdown)

Uso:
    python scripts/inventariar_raiz.py
"""
import io
import os
import re
import subprocess
import sys
from datetime import datetime

RAIZ = None
MAX_PREVIEW = 110

# Directorios de la raiz que no son "sueltos": no se inventarian.
EXCLUIDOS_DIR = {'.git', '.godot', '.workbuddy-ai', 'node_modules', '.venv',
                 '__pycache__', 'game', 'docs', 'build', 'installer',
                 'tools', 'out', 'bin', 'addons'}

EXT_TEXTO = {'.md', '.txt', '.py', '.gd', '.cs', '.json', '.bat', '.ps1',
             '.yml', '.yaml', '.cfg', '.ini', '.csv', '.tscn', '.tres',
             '.sh', '.html', '.css', '.js'}

# Huerfanos (sin versionar y sin menciones) que se CONSERVAN a proposito.
# Sin esta lista, un inventario automatico sugiere mover lo primero que no
# entiende — y se lleva puesta arte de referencia del usuario.
CONSERVAR = {
    'isla-modelo.jpg': 'referencia visual de la isla (insumo del usuario)',
    'isla-modelo-2.jpg': 'referencia visual de la isla (insumo del usuario)',
    'isla-modelo-3.jpg': 'referencia visual de la isla (insumo del usuario)',
    'paleta-propuesta-isla.png': 'paleta de colores propuesta para la isla',
    'renombrar_logs.py': 'utilidad reutilizable: la numeracion de Logs/ se '
                         'rompe seguido (ver BUG-014 en DOCUMENTACION/11-BUGS.md)',
    'postlaunch_checklist.json': 'checklist de post-lanzamiento; decidir si '
                                 'se integra a M121 o se descarta',
}


def raiz_repo():
    d = os.path.dirname(os.path.abspath(__file__))
    for _ in range(10):
        if os.path.isfile(os.path.join(d, 'AGENTS.md')):
            return d
        p = os.path.dirname(d)
        if p == d:
            break
        d = p
    raise SystemExit('No encontre AGENTS.md')


def detectar_encoding(raw):
    """Devuelve el encoding mas probable. Nunca levanta excepcion."""
    if raw.startswith(b'\xff\xfe'):
        return 'utf-16-le'
    if raw.startswith(b'\xfe\xff'):
        return 'utf-16-be'
    if raw.startswith(b'\xef\xbb\xbf'):
        return 'utf-8-sig'
    # UTF-16 sin BOM: NUL intercalados en la cabecera
    muestra = raw[:512]
    if muestra and b'\x00' in muestra:
        # 'e\x00l\x00' -> LE ; '\x00e\x00l' -> BE
        return 'utf-16-be' if muestra[0:1] == b'\x00' else 'utf-16-le'
    return 'utf-8'


def decodificar(raw):
    """Decodifica sin producir jamas U+FFFD. latin-1 es el ultimo recurso:
    no falla y no genera reemplazos, que es exactamente lo que no queremos."""
    enc = detectar_encoding(raw)
    try:
        return raw.decode(enc), enc
    except (UnicodeDecodeError, LookupError):
        try:
            return raw.decode('utf-8'), 'utf-8(?)'
        except UnicodeDecodeError:
            return raw.decode('latin-1'), 'latin-1'


LIMPIAR = re.compile(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]')


def preview(path):
    """Primera linea legible, saneada. Devuelve (texto, encoding)."""
    try:
        with open(path, 'rb') as f:
            raw = f.read(8192)
    except OSError:
        return '(ilegible)', '-'
    if not raw:
        return '(vacio)', '-'
    if os.path.splitext(path)[1].lower() not in EXT_TEXTO:
        return '(no textual)', '-'
    txt, enc = decodificar(raw)
    txt = LIMPIAR.sub('', txt)          # los NUL rompen el markdown
    primera = txt.splitlines()[0] if txt.splitlines() else ''
    primera = primera.replace('|', '\\|').strip()
    if len(primera) > MAX_PREVIEW:
        primera = primera[:MAX_PREVIEW] + '…'
    return primera or '(en blanco)', enc


def versionados():
    r = subprocess.run(['git', 'ls-files'], cwd=RAIZ,
                       stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    return set(l.strip() for l in r.stdout.decode('utf-8', 'replace')
               .splitlines() if l.strip())


def contar_menciones(nombre):
    """Cuantas veces aparece el nombre en la documentacion .md."""
    n = 0
    for dirpath, dirnames, filenames in os.walk(RAIZ):
        dirnames[:] = [d for d in dirnames
                       if d not in ('.git', 'node_modules', '.godot',
                                    '__pycache__', '.workbuddy-ai')]
        for fn in filenames:
            if not fn.endswith('.md'):
                continue
            p = os.path.join(dirpath, fn)
            if os.path.abspath(p) == os.path.abspath(
                    os.path.join(RAIZ, 'DOCUMENTACION', 'INVENTARIO-RAIZ.md')):
                continue
            try:
                t = open(p, 'rb').read()
            except OSError:
                continue
            n += t.count(nombre.encode('utf-8'))
    return n


def clasificar(nombre):
    """Temporal / utilidad / recurso, por el nombre."""
    n = nombre.lower()
    if (n.startswith(('_tmp', 'tmp_', '_gen', '_main', 'patch_', 'recover_',
                      'revert_', 'mark_', 'fix_', '_qa', '_fix'))
            or 'renombrados' in n or n.endswith(('.bak', '.tmp', '.log'))
            or '.bak_' in n):
        return 'temporal'
    if n.endswith(('.py', '.bat', '.ps1', '.sh')):
        return 'utilidad'
    if n.endswith(('.jpg', '.png', '.jpeg')):
        return 'recurso'
    return 'otro'


def main():
    global RAIZ
    RAIZ = raiz_repo()
    os.chdir(RAIZ)
    track = versionados()

    sueltos = []
    for nombre in sorted(os.listdir('.')):
        if not os.path.isfile(nombre):
            continue
        if nombre in EXCLUIDOS_DIR:
            continue
        st = os.stat(nombre)
        sueltos.append((nombre, st.st_size,
                        datetime.fromtimestamp(st.st_mtime)))

    print('sueltos en la raiz: %d' % len(sueltos))

    filas = []
    for nombre, size, mtime in sueltos:
        prev, enc = preview(nombre)
        menc = contar_menciones(nombre)
        filas.append((nombre, size, mtime.strftime('%Y-%m-%d'),
                      'SI' if nombre in track else 'NO',
                      menc, clasificar(nombre), enc, prev))

    out = io.StringIO()
    out.write('# Inventario de archivos sueltos en la raíz\n\n')
    out.write('Generado por `scripts/inventariar_raiz.py` — Log 853, %s.\n\n'
              % datetime.now().strftime('%Y-%m-%d %H:%M'))
    out.write('Criterio de las columnas:\n\n')
    out.write('- **Tracked**: si el archivo está versionado en git.\n')
    out.write('- **Menciones**: cuántas veces aparece el nombre en archivos '
              '`.md` del repo (0 = nadie lo documenta).\n')
    out.write('- **Tipo**: `temporal` (desechable por nombre), `utilidad` '
              '(script posiblemente reutilizable), `recurso`, `otro`.\n')
    out.write('- **Codif**: encoding detectado para leer la primera línea.\n')
    out.write('- **Primera línea**: indicio de propósito.\n\n')
    out.write('| Archivo | Bytes | Fecha | Tracked | Menciones | Tipo '
              '| Codif | Primera línea |\n')
    out.write('|---|---:|---|---|---:|---|---|---|\n')
    for nombre, size, fecha, tracked, menc, tipo, enc, prev in filas:
        out.write('| `%s` | %d | %s | %s | %d | %s | %s | %s |\n'
                  % (nombre, size, fecha, tracked, menc, tipo, enc, prev))

    temporales = [f for f in filas if f[5] == 'temporal']
    huerfanos = [f for f in filas if f[4] == 0 and f[3] == 'NO']
    mover = [f for f in huerfanos if f[0] not in CONSERVAR]
    guardar = [f for f in huerfanos if f[0] in CONSERVAR]
    out.write('\n## Resumen\n\n')
    out.write('- Sueltos totales: **%d**\n' % len(filas))
    out.write('- Sin versionar: **%d**\n'
              % len([f for f in filas if f[3] == 'NO']))
    out.write('- Sin versionar **y** sin menciones en la documentación: '
              '**%d**\n' % len(huerfanos))
    out.write('- Clasificados como temporales por el nombre: **%d**\n'
              % len(temporales))
    out.write('\n## Candidatos a mover a `Obsoletos/`\n\n')
    if mover:
        for f in mover:
            out.write('- `%s` (%d bytes, %s)\n' % (f[0], f[1], f[2]))
    else:
        out.write('(ninguno)\n')

    out.write('\n## Huérfanos que se conservan a propósito\n\n')
    if guardar:
        for f in guardar:
            out.write('- `%s` — %s\n' % (f[0], CONSERVAR[f[0]]))
    else:
        out.write('(ninguno)\n')

    destino = os.path.join('DOCUMENTACION', 'INVENTARIO-RAIZ.md')
    with io.open(destino, 'w', encoding='utf-8', newline='\n') as f:
        f.write(out.getvalue())

    # Control de integridad: el inventario NO puede contener NUL ni U+FFFD.
    crudo = open(destino, 'rb').read()
    assert b'\x00' not in crudo, 'el inventario tiene NUL: git lo ve binario'
    assert b'\xef\xbf\xbd' not in crudo, 'el inventario tiene U+FFFD'
    print('escrito: %s (%d bytes)' % (destino, len(crudo)))
    print('NUL: 0 · U+FFFD: 0  (control de integridad OK)')
    print('sin versionar y sin menciones: %d' % len(huerfanos))
    return 0


if __name__ == '__main__':
    sys.exit(main())
