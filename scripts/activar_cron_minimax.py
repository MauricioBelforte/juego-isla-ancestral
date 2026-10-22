#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""MiniMax-M3.1-Flash — imprime el prompt EXACTO del cronometro para reactivarlo.

Uso:  python scripts/activar_cron_minimax.py            -> imprime schedule + prompt
       python scripts/activar_cron_minimax.py --check    -> verifica que el fichero existe y esta completo
Salida lista para pegar en la herramienta `cron_create` (schedule + prompt verbatim).

La copia canonica vive en: DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/CRONOMETRO.md
Este helper NO crea el cron (eso lo hace la herramienta del harness), solo evita reconstruir el texto.
"""
import io, os, re, sys

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(AQUI)
COPIA = os.path.join(RAIZ, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'MiniMax-M3.1-Flash', 'CRONOMETRO.md')
SCHEDULE = '*/30 * * * *'


def main() -> int:
    if not os.path.exists(COPIA):
        print('NO ENCONTRADO: %s' % COPIA)
        return 1
    texto = io.open(COPIA, encoding='utf-8').read()
    m = re.search(r'```text\n(.*?)\n```', texto, re.S)
    if not m:
        print('NO ENCONTRADO el bloque de prompt en %s' % COPIA)
        return 1
    prompt = m.group(1)
    if '--check' in sys.argv:
        print('COPIA OK: %s' % COPIA)
        print('schedule: %s' % SCHEDULE)
        print('prompt: %d caracteres, %d lineas' % (len(prompt), prompt.count(chr(10)) + 1))
        return 0
    print('# --- copiar en cron_create ---')
    print('# schedule: %s' % SCHEDULE)
    print('# prompt:')
    print(prompt)
    return 0


if __name__ == '__main__':
    sys.exit(main())
