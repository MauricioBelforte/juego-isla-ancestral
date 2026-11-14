#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Test de REGRESION para `plantilla_asset.py::mat(emisivo=...)` (B30).

Ejecutar con Blender 4.2 headless (necesita `bpy`):
  blender -b --factory-startup --python-exit-code 1 \
      --python test_mat_emisivo.py -- --piso 0
  blender -b --factory-startup --python-exit-code 1 \
      --python test_mat_emisivo.py                 # VERDE
  blender -b --factory-startup --python-exit-code 1 \
      --python test_mat_emisivo.py -- --sin-fix   # ROJO
  blender -b --factory-startup --python-exit-code 1 \
      --python test_mat_emisivo.py -- --solo      # CIEGO exit 3

CONTEXTO / FE DE ERRATAS: en B26 (log 2410, acta 36, mensaje 70) Hy4
publico que `mat(emisivo=...)` tenia un "BUG LATENTE" de la plantilla.
Medicion de B30: la API documentada es `((r,g,b), strength)` y SIETE
generadores la usan correctamente (gema x3, carreta, faro, volcan, ...).
El TypeError de B26 venia de pasar un RGB PLANO `(0.35, 0.30, 0.10)`:
`(*emisivo[0], 1.0)` intentaba desempaquetar un float. Fue un ERROR DE
LLAMADA de Hy4, NO un bug ajeno. El fix de B30 anade TOLERANCIA al rgb
plano (fuerza 1.0) sin cambiar el contrato ni el resultado de los 7
llamadores correctos. Se publica la rectificacion sin reescribir B26.

C5 ejecuta la LINEA LITERAL de la version anterior sobre un material nuevo:
el ROJO no se simula, se REPRODUCE el TypeError real.
"""
import hashlib
import importlib.util
import os
import sys

import bpy  # noqa: E402  (solo disponible bajo Blender headless)

REPO = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
PLANTILLA = os.path.join(REPO, 'tools', 'mcp', 'blender-mcp',
                         'scripts-reutilizables', 'plantilla_asset.py')

# MEDIDO EN VERDE 2026-11-14 con `--piso 0` ANTES de fijar la constante:
#   CHECKS=6 PASADOS=6 FALLOS=0 RC=0. Ver acta 40 / log 2420.
# Este test no tiene bloques por archivo: CIEGO = menos checks que el piso.
CHECKS_MINIMOS = 6

# Valores REALES de los 7 llamadores de la API documentada, medidos con grep.
LLAMADORES = [
    ((1.00, 0.88, 0.62), 0.10),   # 157-Medios-De-Transporte carreta
    ((0.42, 0.20, 0.70), 0.16),   # 16-Crafting gema tallada
    ((0.58, 0.32, 0.88), 0.22),   # 16-Crafting gema tallada
    ((0.76, 0.58, 0.98), 0.30),   # 16-Crafting gema tallada
    ((1.00, 0.92, 0.50), 1.50),   # 27-Islas faro viejo
    ((1.00, 0.40, 0.05), 2.50),   # 27-Islas volcan
]
RGB_PLANO = (0.35, 0.30, 0.10)   # exactamente la llamada erronea de B26


def sha12(ruta):
    return hashlib.sha256(open(ruta, 'rb').read()).hexdigest()[:12]


def cargar_plantilla():
    spec = importlib.util.spec_from_file_location('plantilla_b30', PLANTILLA)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def mat_vieja(nombre, emisivo):
    """LINEA LITERAL de la version anterior a B30 (reproduccion del fallo)."""
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Emission Color'].default_value = (*emisivo[0], 1.0)
    b.inputs['Emission Strength'].default_value = emisivo[1]
    return m


def emision(m):
    b = m.node_tree.nodes.get('Principled BSDF')
    return (tuple(round(float(v), 4)
                  for v in b.inputs['Emission Color'].default_value),
            round(float(b.inputs['Emission Strength'].default_value), 4))


def main(argv):
    piso = CHECKS_MINIMOS
    sin_fix = solo = False
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--piso':
            i += 1
            piso = int(argv[i])
        elif a == '--sin-fix':
            sin_fix = True
        elif a == '--solo':
            solo = True
        i += 1

    publicado = sha12(PLANTILLA)
    plantilla = cargar_plantilla()
    checks = []

    def chk(codigo, ok, detalle):
        checks.append((codigo, bool(ok), detalle))

    def fabricar(emisivo, nombre):
        """En modo ROJO usa la linea VIEJA: el TypeError es real, no simulado."""
        if sin_fix:
            return mat_vieja(nombre, emisivo)
        return plantilla.mat(nombre, (0.5, 0.5, 0.5), emisivo=emisivo)

    # C1: contrato documentado ((r,g,b), strength) INTACTO.
    try:
        m1 = fabricar(((0.42, 0.20, 0.70), 0.16), 'T_B30_C1')
        col, fuerza = emision(m1)
        chk('C1', col[:3] == (0.42, 0.20, 0.70) and abs(fuerza - 0.16) < 1e-4,
            'API documentada: color=%s fuerza=%s' % (col[:3], fuerza))
    except Exception as e:
        chk('C1', False, 'API documentada ROMPIDA: %s: %s'
            % (type(e).__name__, e))

    if solo:
        total = len(checks)
        print('CHECKS=%d PASADOS=%d FALLOS=%d BLOQUES=1 PISO=%d'
              % (total, sum(1 for _, o, _ in checks if o),
                 sum(1 for _, o, _ in checks if not o), piso))
        if total < piso:
            print('CIEGO: menos checks que el verde medido')
            sys.exit(3)
        sys.exit(0)

    # C2: rgb PLANO ya no revienta (la tolerancia nueva). En --sin-fix FALLA.
    try:
        m2 = fabricar(RGB_PLANO, 'T_B30_C2')
        col, fuerza = emision(m2)
        chk('C2', col[:3] == RGB_PLANO and abs(fuerza - 1.0) < 1e-4,
            'rgb plano tolerado: color=%s fuerza=%s' % (col[:3], fuerza))
    except TypeError as e:
        chk('C2', False, 'TypeError REPRODUCIDO con la linea anterior: %s' % e)
    except Exception as e:
        chk('C2', False, 'fallo inesperado: %s: %s' % (type(e).__name__, e))

    # C3: sin emisivo no se toca la emision (regresion sobre el default).
    try:
        m3 = plantilla.mat('T_B30_C3', (0.5, 0.5, 0.5))
        col, fuerza = emision(m3)
        chk('C3', abs(fuerza) < 1e-4,
            'sin emisivo: fuerza=%s color=%s' % (fuerza, col[:3]))
    except Exception as e:
        chk('C3', False, 'fallo inesperado: %s: %s' % (type(e).__name__, e))

    # C4: los 6 pares reales de llamadores siguen dando su fuerza exacta.
    try:
        resultados = []
        for k, (rgb, fuerza) in enumerate(LLAMADORES):
            mk = plantilla.mat('T_B30_C4_%d' % k, (0.5, 0.5, 0.5),
                               emisivo=(rgb, fuerza))
            c, f = emision(mk)
            resultados.append(c[:3] == tuple(round(v, 4) for v in rgb)
                              and abs(f - fuerza) < 1e-4)
        chk('C4', all(resultados), '%d/%d llamadores reales intactos'
            % (sum(resultados), len(resultados)))
    except Exception as e:
        chk('C4', False, 'fallo inesperado: %s: %s' % (type(e).__name__, e))

    # C5: la linea anterior SI produce TypeError con rgb plano. Positivo:
    # prueba que el ROJO no es una simulacion.
    try:
        mat_vieja('T_B30_C5', RGB_PLANO)
        chk('C5', False, 'la linea anterior NO fallo: el ROJO seria falso')
    except TypeError:
        chk('C5', True, 'version anterior reproduce TypeError real')

    # C6: el archivo publicado no fue modificado por el test.
    chk('C6', sha12(PLANTILLA) == publicado
        and hasattr(plantilla, '_normalizar_emisivo'),
        'plantilla publicada sha=%s INTACTA + normalizador presente'
        % publicado)

    ok = sum(1 for _, o, _ in checks if o)
    fallos = len(checks) - ok
    for codigo, bueno, detalle in checks:
        print('%s %-3s %s' % ('OK  ' if bueno else 'FAIL', codigo, detalle))
    print('CHECKS=%d PASADOS=%d FALLOS=%d BLOQUES=6 PISO=%d'
          % (len(checks), ok, fallos, piso))
    if len(checks) < piso:
        print('CIEGO: menos checks que el verde medido')
        sys.exit(3)
    if fallos:
        print('ROJO: %d aserciones fallaron' % fallos)
        sys.exit(1)
    print('VERDE: contrato emisivo intacto + tolerancia B30 activa')
    sys.exit(0)


if __name__ == '__main__':
    main(sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else [])
