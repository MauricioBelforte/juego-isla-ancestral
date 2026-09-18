#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardian del protocolo de reservas de logs (Logs/reservas/).

Cierra el gap que causo las colisiones de numero del 2026-09-17 (trampa 67):
la reserva `950` llego a estar DOBLE (Hy3 y Atria) y nada lo detecto.

Uso:
    python scripts/reservar_log.py --estado
        Lista reservas vivas + conflictos (numero ya en Logs/ o reservado 2 veces).

    python scripts/reservar_log.py --reservar --agente agnes-3-flash --modulo M83
        Asigna el siguiente numero libre (max(ULTIMO_NUMERO, max(Logs/NNN),
        max(reservas/NNN)) + 1), crea Logs/reservas/NNN-<agente>-<modulo>.txt
        y actualiza Logs/ULTIMO_NUMERO.txt.

    python scripts/reservar_log.py --liberar 974
        Borra la reserva 974 (se usa al cerrar el ciclo, tras escribir el log).

    python scripts/reservar_log.py --check 974
        Exit 0 si 974 esta libre; exit 1 si esta ocupado (log o reserva).

Convencion (MEMORY.md): `Logs/` = solo `NNN-*.md` + `ULTIMO_NUMERO.txt` + `reservas/`.
"""
import argparse
import os
import re
import sys

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
LOGS = os.path.join(RAIZ, 'Logs')
RESERVAS = os.path.join(LOGS, 'reservas')
ULTIMO = os.path.join(LOGS, 'ULTIMO_NUMERO.txt')

# OJO: \d{3} dejaba CIEGO al guardián a partir de 1000. Con el protocolo v3
# (Logs/NUMEROS_DISPONIBLES.txt = 1000-1500) TODO log nuevo tiene 4 dígitos, así
# que `reservas_por_numero()` y `logs_por_numero()` no los veían: ni RESERVA
# DOBLE ni COLISION se detectaban para NNNN. Medido el 2026-09-18 (Log 986):
# `1000-atria-dawn-M13-QA.txt` existía y --estado informaba "reservas/*.txt: 0".
RE_LOG = re.compile(r'^(\d+)-.*\.md$')
RE_RES = re.compile(r'^(\d+)-.*\.txt$')


def logs_por_numero():
    """{numero: [archivos]} de Logs/*.md"""
    d = {}
    if not os.path.isdir(LOGS):
        return d
    for n in sorted(os.listdir(LOGS)):
        m = RE_LOG.match(n)
        if m:
            d.setdefault(int(m.group(1)), []).append(n)
    return d


def reservas_por_numero():
    """{numero: [archivos]} de Logs/reservas/*.txt"""
    d = {}
    if not os.path.isdir(RESERVAS):
        return d
    for n in sorted(os.listdir(RESERVAS)):
        m = RE_RES.match(n)
        if m:
            d.setdefault(int(m.group(1)), []).append(n)
    return d


def ultimo_numero():
    try:
        with open(ULTIMO, 'r', encoding='utf-8') as f:
            return int(f.read().strip())
    except (OSError, ValueError):
        return 0


def siguiente_libre(logs, res):
    return max([ultimo_numero()] + list(logs) + list(res)) + 1


def cmd_estado():
    logs, res = logs_por_numero(), reservas_por_numero()
    print('ULTIMO_NUMERO.txt : %d' % ultimo_numero())
    print('Logs/*.md         : %d numeros' % len(logs))
    print('reservas/*.txt    : %d' % len(res))
    problemas = 0
    for num in sorted(set(logs) | set(res)):
        ocupado_por_log = logs.get(num, [])
        reservado_por = res.get(num, [])
        if len(reservado_por) > 1:
            print('  !! RESERVA DOBLE %d: %s' % (num, reservado_por))
            problemas += 1
        if ocupado_por_log and reservado_por:
            print('  !! %d reservado Y ya escrito en Logs/: %s | %s'
                  % (num, reservado_por, ocupado_por_log))
            problemas += 1
        if len(ocupado_por_log) > 1:
            print('  !! COLISION %d: %s' % (num, ocupado_por_log))
            problemas += 1
    if problemas:
        print('\n%d problema(s) de numeracion.' % problemas)
        return 1
    print('\nSin conflictos de numeracion.')
    return 0


def cmd_check(num):
    logs, res = logs_por_numero(), reservas_por_numero()
    if num in logs:
        print('OCUPADO: %d -> %s' % (num, logs[num]))
        return 1
    if num in res:
        print('RESERVADO: %d -> %s' % (num, res[num]))
        return 1
    print('LIBRE: %d' % num)
    return 0


def cmd_reservar(agente, modulo):
    logs, res = logs_por_numero(), reservas_por_numero()
    num = siguiente_libre(logs, res)
    os.makedirs(RESERVAS, exist_ok=True)
    slug = re.sub(r'[^A-Za-z0-9._-]+', '-', '%s-%s' % (agente, modulo)).strip('-')
    destino = os.path.join(RESERVAS, '%d-%s.txt' % (num, slug))
    with open(destino, 'w', encoding='utf-8', newline='') as f:
        f.write('Reserva de Log %d\nAgente: %s\nModulo: %s\nFecha: (completar)\n'
                % (num, agente, modulo))
    with open(ULTIMO, 'w', encoding='utf-8', newline='') as f:
        f.write('%d\n' % num)
    print('Reservado Log %d -> %s' % (num, os.path.relpath(destino, RAIZ)))
    print('ULTIMO_NUMERO.txt -> %d' % num)
    return 0


def cmd_liberar(num):
    res = reservas_por_numero()
    if num not in res:
        print('No hay reserva para %d.' % num)
        return 1
    for nombre in res[num]:
        os.remove(os.path.join(RESERVAS, nombre))
        print('Liberada reserva: %s' % nombre)
    return 0


def main():
    p = argparse.ArgumentParser(description='Guardian de reservas de Logs/')
    p.add_argument('--estado', action='store_true', help='listar reservas y conflictos')
    p.add_argument('--reservar', action='store_true', help='crear una reserva nueva')
    p.add_argument('--liberar', type=int, metavar='NNN', help='borrar la reserva NNN')
    p.add_argument('--check', type=int, metavar='NNN', help='verificar si NNN esta libre')
    p.add_argument('--agente', default='desconocido')
    p.add_argument('--modulo', default='sin-modulo')
    a = p.parse_args()

    if a.check is not None:
        return cmd_check(a.check)
    if a.liberar is not None:
        return cmd_liberar(a.liberar)
    if a.reservar:
        return cmd_reservar(a.agente, a.modulo)
    return cmd_estado()


if __name__ == '__main__':
    sys.exit(main())
