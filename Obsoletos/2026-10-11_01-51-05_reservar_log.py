#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Asignador de numeros de log — protocolo v3 (AGENTS.md 6.1).

**Fuente unica de verdad: `Logs/NUMEROS_DISPONIBLES.txt`.** El numero se consume
al tomarlo de la lista: NO existe archivo de reserva, ni `ULTIMO_NUMERO.txt`, ni
`Logs/reservas/`. El "claim" es la propia linea borrada del pool.

Uso:
    python scripts/reservar_log.py --reservar --agente X --modulo Y
        Consume la PRIMERA linea del pool y la imprime. NO escribe ningun
        archivo: anotala en tu BACKLOG-MASTER.md y nombra el log
        `Logs/<N>-<desc>_<AAAA-MM-DD_HH-MM-SS>.md`.

    python scripts/reservar_log.py --estado
        Informe: tamano del pool, primer numero, y conflictos reales
        (reserva doble, colision, numero reservado y ademas escrito, doble
        asignador). Exit 1 si hay conflictos.

    python scripts/reservar_log.py --check 1042
        Exit 0 si 1042 esta libre; exit 1 si ya tiene log o reserva.

    python scripts/reservar_log.py --liberar 1042
        SOLO para limpiar reservas heredadas de `Logs/reservas/` (mecanismo
        retirado). Con el protocolo v3 no hay nada que liberar.

Historia (por que esta herramienta ya no crea archivos):
  - El mecanismo `ULTIMO_NUMERO.txt` + `Logs/reservas/NNN-*.txt` nacio para
    cerrar la colision de la trampa 67 (reserva 950 doble, Hy3 y Atria, sin
    detector). Funcionaba, pero introducia un SEGUNDO asignador en paralelo al
    pool v3.
  - Medido el 2026-09-18: con los dos asignadores vivos, hy3 recibio el 1001 por
    esta herramienta mientras DeepSeek tomaba el 1001 de la lista -> dos logs con
    el mismo numero. La colision que AGENTS.md 6.1.d daba por imposible ocurrio.
  - El dueño consolido v3 (commit 2ac8b4b): elimino `ULTIMO_NUMERO.txt` y todo
    `Logs/reservas/`. Esta herramienta se alinea: consume el pool y no crea nada.

Riesgo residual HONESTO (no se puede eliminar desde aqui): tomar la primera
linea es un read-modify-write sobre un archivo compartido. Dos procesos pueden
leer la misma primera linea y borrarla los dos. AGENTS.md 6.1.d afirma que "la
linea en blanco resultante se detecta"; medido el 2026-09-18 (1001 y 1002) eso
NO alcanza — la linea en blanco no aparece porque ambos procesos reescriben el
archivo entero. La unica deteccion posible es a posteriori: `--estado` marca
como DOBLE ASIGNADOR cualquier numero que siga en el pool teniendo ya un log.
Mitigacion recomendada: usar `--reservar` (una sola operacion) en vez de editar
el pool a mano, y no dejar el numero "tomado" sin escribir el log.
"""
import argparse
import os
import re
import sys

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
LOGS = os.path.join(RAIZ, 'Logs')
# Mecanismo RETIRADO (2ac8b4b). Se sigue LEYENDO para poder reportar y limpiar
# reservas heredadas, pero --reservar ya no escribe aqui.
RESERVAS = os.path.join(LOGS, 'reservas')
# Protocolo v3 (AGENTS.md 6.1): pool de numeros libres. Asignador CANONICO.
DISPONIBLES = os.path.join(LOGS, 'NUMEROS_DISPONIBLES.txt')

# Cuantos numeros fugados toleramos saltar antes de caer a max+1. Una fuga
# (numero del pool que ya tiene log) se consume igualmente para no volver a
# ofrecerla. El tope evita un bucle sin fin si el pool esta corrupto.
MAX_SALTOS = 25

# OJO: \d{3} dejaba CIEGO al guardian a partir de 1000. Con el protocolo v3
# TODO log nuevo tiene 4 digitos, asi que `logs_por_numero()` no los veia:
# `1000-atria-dawn-M13-QA.txt` existia y --estado informaba "0 numeros".
# Medido el 2026-09-18 (Log 986).
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
    """{numero: [archivos]} de Logs/reservas/*.txt (mecanismo RETIRADO)."""
    d = {}
    if not os.path.isdir(RESERVAS):
        return d
    for n in sorted(os.listdir(RESERVAS)):
        m = RE_RES.match(n)
        if m:
            d.setdefault(int(m.group(1)), []).append(n)
    return d


def _leer_bytes(ruta):
    try:
        with open(ruta, 'rb') as f:
            return f.read()
    except OSError:
        return None


BOM = b'\xef\xbb\xbf'


def _sin_bom(raw):
    """Quita el BOM UTF-8 (seccion 28).

    CRITICO, no cosmetico: con BOM, `b'\\xef\\xbb\\xbf1004'.strip().isdigit()`
    es False, asi que el PRIMER numero del pool queda INVISIBLE al asignador:
    nunca se consume y `--estado` lo omite del recuento. Medido el 2026-09-18:
    el pool informaba "495 libres" teniendo 496 lineas, con el 1004 dentro.
    """
    if raw is None:
        return None
    return raw[len(BOM):] if raw.startswith(BOM) else raw


def _eol_de(raw):
    """EOL dominante, preservado al reescribir (trampa 69: core.autocrlf=true)."""
    crlf = raw.count(b'\r\n')
    lf = raw.count(b'\n') - crlf
    return b'\r\n' if crlf >= lf else b'\n'


def numeros_disponibles():
    """(lista_de_int, eol, existe) del pool v3. Orden de aparicion = orden de reparto."""
    raw = _sin_bom(_leer_bytes(DISPONIBLES))
    if raw is None:
        return [], b'\n', False
    nums = [int(l.strip()) for l in raw.split(b'\n') if l.strip().isdigit()]
    return nums, _eol_de(raw), True


def hay_bom_en_pool():
    raw = _leer_bytes(DISPONIBLES)
    return bool(raw and raw.startswith(BOM))


def consumir_primero_del_pool():
    """Borra la PRIMERA linea numerica del pool v3 y devuelve su numero.

    None si el pool no existe o no tiene numeros. Preserva el EOL del archivo.
    Si el pool traia BOM, al reescribirlo desaparece (se autocura).
    """
    raw = _sin_bom(_leer_bytes(DISPONIBLES))
    if raw is None:
        return None
    eol = _eol_de(raw)
    lineas = raw.split(eol)
    idx = next((i for i, l in enumerate(lineas) if l.strip().isdigit()), None)
    if idx is None:
        return None
    num = int(lineas[idx].strip())
    del lineas[idx]
    with open(DISPONIBLES, 'wb') as f:
        f.write(eol.join(lineas))
    return num


def siguiente_libre(logs, res):
    """Modo legado (pool vacio o inexistente): max(numero usado) + 1."""
    return max(list(logs) + list(res) + [0]) + 1


def cmd_estado():
    logs, res = logs_por_numero(), reservas_por_numero()
    pool, _, hay_pool = numeros_disponibles()
    if hay_pool:
        print('NUMEROS_DISPONIBLES: %d libres (primero=%s)'
              % (len(pool), pool[0] if pool else '-'))
    else:
        print('NUMEROS_DISPONIBLES: AUSENTE (el pool es la fuente de verdad v3)')
    print('Logs/*.md          : %d numeros' % len(logs))
    problemas = 0
    if hay_bom_en_pool():
        print('  !! BOM en NUMEROS_DISPONIBLES.txt: el primer numero (%s) queda '
              'invisible al asignador (seccion 28)' % (pool[0] if pool else '?'))
        problemas += 1
    if res:
        # Aviso, NO conflicto: un archivo suelto del mecanismo retirado no hace
        # dano por si mismo. Solo cuenta si de verdad duplica algo (abajo).
        print('AVISO: %d reserva(s) heredada(s) de Logs/reservas/ (mecanismo '
              'RETIRADO en 2ac8b4b) -> borralas con --liberar NNN:' % len(res))
        for num in sorted(res):
            for nombre in res[num]:
                print('   - %s' % nombre)
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
    if hay_pool:
        # Fuga del pool: un numero que sigue ofreciendose pero ya tiene log (o
        # reserva heredada) se puede entregar DOS veces. Es la huella exacta de
        # la colision del 1001/1002 — y lo UNICO detectable a posteriori.
        for num in sorted((set(logs) | set(res)) & set(pool)):
            quien = ('escrito en Logs/ %s' % logs[num]) if num in logs \
                else ('reservado por %s' % res[num])
            print('  !! DOBLE ASIGNADOR %d: sigue en NUMEROS_DISPONIBLES.txt y ya esta %s'
                  % (num, quien))
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
        print('RESERVADO: %d -> %s (reserva heredada)' % (num, res[num]))
        return 1
    print('LIBRE: %d' % num)
    return 0


def cmd_reservar(agente, modulo):
    """Consume el primer numero libre del pool. NO escribe ningun archivo."""
    logs = logs_por_numero()
    saltados = []
    num = None
    for _ in range(MAX_SALTOS + 1):
        cand = consumir_primero_del_pool()
        if cand is None:
            break
        if cand in logs:
            # Fuga: el pool ofrecia un numero ya escrito. Se consume (no debe
            # volver a ofrecerse) y se reporta.
            saltados.append(cand)
            continue
        num = cand
        break

    if num is None:
        num = siguiente_libre(logs, reservas_por_numero())
        origen = 'max+1 (modo legado: pool v3 vacio o ausente)'
    else:
        origen = 'NUMEROS_DISPONIBLES.txt (protocolo v3, AGENTS.md 6.1.a)'

    if saltados:
        print('AVISO: %d numero(s) del pool ya tenian log y se descartaron: %s'
              % (len(saltados), saltados))
        print('       -> hubo una fuga de pool; revisa --estado.')
    print('Numero de log reservado: %d' % num)
    print('  Origen : %s' % origen)
    print('  Agente : %s' % agente)
    print('  Modulo : %s' % modulo)
    print('  NO hay archivo de reserva: el numero ya salio del pool (protocolo v3).')
    print('  Anotalo en DOCUMENTACION/TAREAS-POR-MODELO/%s/BACKLOG-MASTER.md:' % agente)
    print('      - [x] Log reservado: **%d** — <descripcion de la tarea>' % num)
    print('  Y nombra el log: Logs/%d-<desc>_<AAAA-MM-DD_HH-MM-SS>.md' % num)
    return 0


def cmd_liberar(num):
    """Borra reservas heredadas de Logs/reservas/ (mecanismo retirado)."""
    res = reservas_por_numero()
    if num not in res:
        print('No hay reserva heredada para %d.' % num)
        return 1
    for nombre in res[num]:
        os.remove(os.path.join(RESERVAS, nombre))
        print('Liberada reserva heredada: %s' % nombre)
    return 0


def main():
    p = argparse.ArgumentParser(description='Asignador de numeros de log (protocolo v3)')
    p.add_argument('--estado', action='store_true', help='informe del pool y conflictos')
    p.add_argument('--reservar', action='store_true', help='consumir el primer numero del pool')
    p.add_argument('--liberar', type=int, metavar='NNN', help='borrar la reserva heredada NNN')
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
