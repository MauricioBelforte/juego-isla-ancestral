# -*- coding: utf-8 -*-
"""Agrupa los mensajes de TODAS las carpetas de modelo en subcarpetas de rango.

REGLA (fundador, 2026-10-15):
  Un rango ini..ini+99 se archiva en subcarpeta 'ini-ini+99' cuando YA EXISTEN
  mensajes con numero >= ini+100 (es decir, el rango siguiente ya empezo).
  El rango actual (el ultimo, incompleto) queda SUELTO en la raiz.

  Equivale a: 'en la raiz solo quedan los ultimos 100 mensajes'.
  No depende de la cantidad de archivos: si un numero nunca existio (hueco) o
  hubo colisiones, el rango se archiva igual porque el siguiente ya empezo.

Idempotente: se puede ejecutar varias veces. Deja LEEME-ESTRUCTURA.txt.
"""
import os, re, io, sys

MM = os.path.abspath('Mensajes entre modelos')
MSG_RE = re.compile(r'^(\d+)-.*\.md$')

LEEME = """ESTRUCTURA DE ESTA CARPETA - regla del fundador (2026-10-15)

Los mensajes viven en la RAIZ. Cuando un rango de 100 numeros se COMPLETA
(0-99, 100-199, 200-299, ...), sus archivos se mueven a una subcarpeta con ese
nombre y quedan como archivo historico.

Asi, en la raiz solo quedan los mensajes del rango actual (los ultimos 100),
que se listan rapido y facilitan el scroll para encontrar lo nuevo.

Reglas:
1. NO se crea la subcarpeta de un rango hasta que existan mensajes del rango
   SIGUIENTE. Ejemplo: con mensajes hasta el 372, se archivan 0-99, 100-199 y
   200-299, y quedan sueltos en la raiz los del 300 al 372.
2. Si un numero del rango nunca existio (hueco) o hubo colisiones, el rango se
   archiva igual: lo que cuenta es que el siguiente rango ya empezo.
3. NO se mueven ni renombran archivos que no empiecen con numero + guion.
4. Los archivos de control (NUMEROS_DISPONIBLES.txt, .ultima-revision-*.txt)
   se quedan siempre en la raiz.
5. Los mensajes nuevos siguen creandose en la raiz con el numero que toque.

Nota tecnica: scripts/verificar_pool_numeros.py y
scripts/scripts-reutilizables/ver_mensajes.py listan de forma RECURSIVA, asi
que leen sin problemas la estructura mixta (raiz + subcarpetas de rango).

Carpeta: {carpeta}
"""

def lp(ruta):
    ruta = os.path.abspath(ruta)
    return ruta if ruta.startswith('\\\\?\\') else '\\\\?\\' + ruta

def listar_todos(p):
    """todos los .md con prefijo numerico, en cualquier profundidad."""
    out = []
    for r, d, f in os.walk(p):
        for x in f:
            if MSG_RE.match(x):
                out.append((int(x.split('-')[0]), os.path.join(r, x)))
    return out

def es_carpeta_modelo(p):
    return os.path.exists(os.path.join(p, 'NUMEROS_DISPONIBLES.txt'))

total_movidos = 0
filas = []
problemas = []

for canal in sorted(os.listdir(MM)):
    p = os.path.join(MM, canal)
    if not os.path.isdir(p) or not es_carpeta_modelo(p):
        continue

    antes = len(listar_todos(p))
    todos = listar_todos(p)
    if not todos:
        continue
    maxnum = max(n for n, _ in todos)

    # rangos a archivar: mientras exista mensaje del rango siguiente
    ini = 0
    a_archivar = []
    while ini + 100 <= maxnum:
        a_archivar.append(ini)
        ini += 100

    movidos = 0
    creadas = []
    for ini_r in a_archivar:
        nombre = '%d-%d' % (ini_r, ini_r + 99)
        destino = os.path.join(p, nombre)
        for n, src in sorted(todos):
            if ini_r <= n <= ini_r + 99:
                if os.path.dirname(os.path.abspath(src)) == os.path.abspath(destino):
                    continue
                dst = os.path.join(destino, os.path.basename(src))
                if os.path.exists(lp(dst)):
                    problemas.append('colision %s/%s' % (canal, os.path.basename(src)))
                    continue
                os.makedirs(lp(destino), exist_ok=True)
                os.rename(lp(src), lp(dst))
                movidos += 1
        if nombre not in creadas and os.path.isdir(destino):
            creadas.append(nombre)

    # limpiar subcarpetas de rango que quedaron VACIAS
    for d in sorted(os.listdir(p)):
        sub = os.path.join(p, d)
        if os.path.isdir(sub) and re.match(r'^\d+-\d+$', d):
            if not any(True for _r, _d2, f in os.walk(sub) if f):
                os.rmdir(lp(sub))

    # LEEME
    leeme = os.path.join(p, 'LEEME-ESTRUCTURA.txt')
    prev = io.open(leeme, encoding='utf-8').read() if os.path.exists(leeme) else ''
    nuevo = LEEME.replace('{carpeta}', canal)
    if prev != nuevo:
        with io.open(leeme, 'w', encoding='utf-8', newline='\n') as fh:
            fh.write(nuevo)

    despues = listar_todos(p)
    sueltos = [f for f in os.listdir(p)
               if os.path.isfile(os.path.join(p, f)) and MSG_RE.match(f)]
    subs = {d: len([1 for _r, _d2, f in os.walk(os.path.join(p, d)) if f])
            for d in sorted(os.listdir(p))
            if os.path.isdir(os.path.join(p, d)) and re.match(r'^\d+-\d+$', d)}
    if len(despues) != antes:
        problemas.append('PERDIDA DE ARCHIVOS en %s: %d -> %d' % (canal, antes, len(despues)))
    total_movidos += movidos
    rango = (min(int(f.split('-')[0]) for f in sueltos), max(int(f.split('-')[0]) for f in sueltos)) if sueltos else None
    filas.append((canal, movidos, subs, len(sueltos), rango))

print('%-28s %7s  %-26s %s' % ('CARPETA', 'MOVIDOS', 'SUBCARPETAS (archivos)', 'SUELTOS'))
for c, m, subs, s, r in filas:
    txt = ', '.join('%s:%d' % kv for kv in sorted(subs.items())) or '-'
    print('%-28s %7d  %-26s %d %s' % (c, m, txt, s, r if r else ''))
print()
print('TOTAL movidos:', total_movidos)
if problemas:
    print('PROBLEMAS:')
    for x in problemas:
        print('  ', x)
    sys.exit(1)
print('Sin perdidas de archivos ni colisiones.')
