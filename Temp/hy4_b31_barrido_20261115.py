#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Barrido de REGRESION B31 (2026-11-15) sobre TODAS las guardias del repo.

NO modifica nada: solo ejecuta y clasifica. Salidas:
  Temp/hy4_b31_barrido_20261115.json / .txt

Clasificacion (la mas importante es SIN_EVIDENCIA):
  VERDE         RC=0 y publica CHECKS=...FALLOS=0 o VERDE:
  SIN_EVIDENCIA RC=0 pero NO publica ningun check -> posible guardia
                MUERTA Y VERDE (trampa: 0 fallos porque las aserciones
                nunca corrieron). Se publica como HALLAZGO, no como verde.
  ROJO          RC=1
  CIEGO         RC=3
  ERROR         RC distinto, excepcion o timeout.
"""
import glob
import json
import os
import re
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
BLENDER = r'D:\Archivos de programa\Blender Foundation\Blender 4.2\blender.exe'
OUT_JSON = os.path.join(REPO, 'Temp', 'hy4_b31_barrido_20261115.json')
OUT_TXT = os.path.join(REPO, 'Temp', 'hy4_b31_barrido_20261115.txt')

def guardias():
    out = sorted(glob.glob(os.path.join(REPO, 'tools', 'mcp', 'blender-mcp',
                                       '**', 'verificar_*.py'), recursive=True))
    out += [os.path.join(REPO, 'tools', 'mcp', 'blender-mcp',
                         'scripts-reutilizables', 'test_mat_emisivo.py')]
    out += [os.path.join(REPO, 'tools', 'mcp', 'blender-mcp',
                         'scripts-reutilizables', 'auditar_glb_490.py')]
    return out


def interprete(ruta):
    src = open(ruta, encoding='utf-8', errors='replace').read()
    if re.search(r'^\s*(import bpy|from bpy)', src, re.M):
        return [BLENDER, '-b', '--factory-startup', '--python-exit-code', '1',
                '--python', ruta]
    return [sys.executable, ruta]


def clasificar(rc, salida, timeout_flag):
    if timeout_flag:
        return 'ERROR', 'timeout 120 s'
    tiene_checks = re.search(r'CHECKS=\d+\s+PASADOS=\d+\s+FALLOS=\d+', salida)
    tiene_verde = 'VERDE' in salida
    if rc == 0:
        if tiene_checks or tiene_verde:
            m = re.search(r'CHECKS=(\d+)\s+PASADOS=(\d+)\s+FALLOS=(\d+)', salida)
            det = m.group(0) if m else 'VERDE: (sin linea CHECKS=)'
            return 'VERDE', det
        if 'FUERA :' in salida and 'errores:' in salida:
            return 'VERDE', re.search(r'FUERA : \d+', salida).group(0)
        return 'SIN_EVIDENCIA', 'RC=0 sin CHECKS= ni VERDE: (posible guardia muerta)'
    if rc == 1:
        return 'ROJO', re.search(r'ROJO[^\n]*', salida).group(0) if 'ROJO' in salida else 'RC=1'
    if rc == 3:
        return 'CIEGO', 'RC=3'
    ultimas = [l for l in salida.strip().splitlines() if l.strip()][-2:]
    return 'ERROR', 'RC=%d | %s' % (rc, ' / '.join(ultimas)[:160])


def main():
    resultados = []
    for ruta in guardias():
        rel = os.path.relpath(ruta, REPO).replace('\\', '/')
        cmd = interprete(ruta)
        tipo = 'BLENDER' if cmd[0] == BLENDER else 'PYTHON'
        timeout_flag = False
        try:
            p = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True,
                               timeout=120, encoding='utf-8', errors='replace')
            salida = (p.stdout or '') + (p.stderr or '')
            rc = p.returncode
        except subprocess.TimeoutExpired:
            salida, rc, timeout_flag = '', -1, True
        estado, detalle = clasificar(rc, salida, timeout_flag)
        ultima = [l for l in salida.strip().splitlines() if l.strip()]
        resultados.append({
            'ruta': rel, 'tipo': tipo, 'rc': rc, 'estado': estado,
            'detalle': detalle,
            'ultima': ultima[-1][:160] if ultima else '',
        })
        print('%-9s %-7s RC=%-3s %-62s %s'
              % (estado, tipo, rc, rel.split('/')[-1][:60], detalle[:70]))

    conteo = {}
    for r in resultados:
        conteo[r['estado']] = conteo.get(r['estado'], 0) + 1
    print('\nRESUMEN_B31 ' + ' '.join('%s=%d' % (k, conteo[k])
                                      for k in sorted(conteo)))
    print('TOTAL=%d' % len(resultados))
    sin = [r['ruta'] for r in resultados if r['estado'] == 'SIN_EVIDENCIA']
    mal = [r['ruta'] for r in resultados if r['estado'] in ('ROJO', 'ERROR')]
    print('SIN_EVIDENCIA=%d %s' % (len(sin), sin))
    print('ROJO_O_ERROR=%d %s' % (len(mal), mal))

    with open(OUT_JSON, 'w', encoding='utf-8', newline='\n') as f:
        json.dump({'resultados': resultados, 'conteo': conteo},
                  f, indent=2, ensure_ascii=False, sort_keys=True)
        f.write('\n')
    with open(OUT_TXT, 'w', encoding='utf-8', newline='\n') as f:
        for r in resultados:
            f.write('%-9s %-7s RC=%-3s %s | %s | %s\n'
                    % (r['estado'], r['tipo'], r['rc'], r['ruta'],
                       r['detalle'], r['ultima']))
        f.write('RESUMEN_B31 %s TOTAL=%d\n'
                % (' '.join('%s=%d' % (k, conteo[k]) for k in sorted(conteo)),
                   len(resultados)))
    print('SALIDAS %s / %s' % (os.path.relpath(OUT_JSON, REPO),
                               os.path.relpath(OUT_TXT, REPO)))


if __name__ == '__main__':
    main()
