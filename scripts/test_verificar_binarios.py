#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Sonda de scripts/verificar_binarios.py (guard de BUG-042).

Por que existe: el guard decide si un asset versionado es realmente del formato
que su extension promete. Si su tabla de firmas se debilita (alguien agrega
`0a0a0a0a` como firma valida de `.ttf`, o alguien hace que `clasificar_texto()`
devuelva '' para HTML), el guard pasa a dar un FALSO VERDE permanente: el bug
que lo origino (3 fuentes que eran paginas 404) volveria a ser invisible.

La prueba esta hecha POR INYECCION, no por confianza: ademas de comprobar que
detecta lo malo, comprueba que deja pasar lo bueno (si siempre fallara, no
serviria de nada) y MUTA la tabla de firmas para demostrar que la deteccion
sale de ahi. Una guarda nunca probada es una guarda que puede estar muerta.

Uso:
    python scripts/test_verificar_binarios.py
    echo $?   # 0 = el guard discrimina, 1 = el guard esta roto
"""
import importlib.util
import os
import shutil
import sys
import tempfile

CHECKS_MINIMOS = 40


def cargar_guard():
    aqui = os.path.dirname(os.path.abspath(__file__))
    ruta = os.path.join(aqui, 'verificar_binarios.py')
    spec = importlib.util.spec_from_file_location('vbin', ruta)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


# --- fixtures: cabezas reales, no inventadas --------------------------------
PNG_OK = b'\x89PNG\r\n\x1a\n' + b'\x00' * 20
JPG_OK = b'\xff\xd8\xff\xe0' + b'\x00' * 20
WEBP_OK = b'RIFF\x24\x00\x00\x00WEBP' + b'\x00' * 20
WAV_OK = b'RIFF\x24\x00\x00\x00WAVE' + b'\x00' * 20
GLB_OK = b'glTF\x02\x00\x00\x00' + b'\x00' * 20
TTF_OK = b'\x00\x01\x00\x00' + b'\x00' * 20
BLEND_OK = b'BLENDER-v303' + b'\x00' * 20
ELF_OK = b'\x7fELF\x02\x01\x01' + b'\x00' * 20
HTML_404 = (b'\n\n\n\n<!DOCTYPE html><html lang="en">\n<head>\n'
            b'<title>Page not found \xc2\xb7 GitHub</title>\n')
JSON_TEXT = b'{"error":"Not Found"}\n'


def main():
    guard = cargar_guard()
    checks = 0
    fallos = 0

    def check(ok, desc):
        nonlocal checks, fallos
        checks += 1
        if not ok:
            fallos += 1
            print('  [FALLO] %s' % desc)
        return ok

    print('=== A. firma_ok() por extension ===')
    # (extension, cabeza, debe_pasar)
    casos_firma = [
        ('.png', PNG_OK, True),
        ('.png', JPG_OK, False),          # el caso real medido en tools/mcp/
        ('.png', WEBP_OK, False),
        ('.png', HTML_404, False),
        ('.jpg', JPG_OK, True),
        ('.jpg', PNG_OK, False),
        ('.webp', WEBP_OK, True),
        ('.webp', b'RIFF\x24\x00\x00\x00XXXX' + b'\x00' * 20, False),  # RIFF sin WEBP
        # Ambos empiezan con RIFF: solo los bytes 8-11 los distinguen. Este caso
        # es el que destapo el bug de firma_ok() (OR en vez de AND).
        ('.webp', WAV_OK, False),
        ('.wav', WAV_OK, True),
        ('.wav', WEBP_OK, False),
        ('.glb', GLB_OK, True),
        ('.glb', PNG_OK, False),
        ('.ttf', TTF_OK, True),
        ('.ttf', HTML_404, False),        # BUG-042
        ('.ttf', b'OTTO' + b'\x00' * 20, True),   # OTF valido con extension .ttf
        ('.blend', BLEND_OK, True),
        ('.blend1', BLEND_OK, True),
        ('.blend', b'\x00\x01\x00\x00' + b'\x00' * 20, False),
        ('.so', ELF_OK, True),
        ('.so', PNG_OK, False),
    ]
    for ext, cabeza, esperado in casos_firma:
        ok = guard.firma_ok(cabeza, guard.FIRMAS[ext]) == esperado
        check(ok, 'firma_ok(%s) con cabeza %s -> esperado %s'
              % (ext, cabeza[:4].hex(' '), esperado))

    # Extension sin firma declarada (.tga): no se puede afirmar nada -> pasa.
    check(guard.firma_ok(b'cualquier cosa', guard.FIRMAS['.tga']) is True,
          '.tga sin firma declarada no debe marcarse')

    print('=== B. clasificar_texto(): distinguir texto disfrazado ===')
    check(guard.clasificar_texto(HTML_404) == 'HTML', 'HTML 404 se clasifica como HTML')
    check(guard.clasificar_texto(b'<?xml version="1.0"?>') == 'XML', 'XML detectado')
    check(guard.clasificar_texto(JSON_TEXT) == 'JSON', 'JSON detectado')
    check(guard.clasificar_texto(b'404: Not Found') == 'TEXTO 404', 'texto 404 detectado')
    check(guard.clasificar_texto(b'texto plano sin firma\n') == 'TEXTO PLANO',
          'texto plano generico detectado')
    for nombre, cabeza in (('.png', PNG_OK), ('.ttf', TTF_OK), ('.glb', GLB_OK),
                           ('.blend', BLEND_OK), ('.so', ELF_OK)):
        check(guard.clasificar_texto(cabeza) == '',
              'un binario real (%s) NO debe clasificarse como texto' % nombre)

    print('=== C. salta_dir(): directorios fuera de alcance ===')
    for d in ('.git', 'node_modules', 'build', 'Obsoletos', 'godot', '.kilo',
              'papelera', '.workbuddy-ai', '.godot'):
        check(guard.salta_dir(d) is True, 'salta_dir(%r) debe ser True' % d)
    for d in ('assets', 'scripts', 'DOCUMENTACION', '.github', '.gitea'):
        check(guard.salta_dir(d) is False, 'salta_dir(%r) debe ser False' % d)

    print('=== D. escanear() de punta a punta sobre un arbol temporal ===')
    tmp = tempfile.mkdtemp(prefix='vbin_test_')
    try:
        buenos = {'ok.png': PNG_OK, 'ok.jpg': JPG_OK, 'ok.glb': GLB_OK,
                  'ok.ttf': TTF_OK, 'ok.webp': WEBP_OK, 'ok.blend': BLEND_OK}
        malos = {'falso.ttf': HTML_404, 'malo.png': JPG_OK,
                 'json.png': JSON_TEXT, 'vacio.png': b''}
        for nombre, datos in list(buenos.items()) + list(malos.items()):
            with open(os.path.join(tmp, nombre), 'wb') as fh:
                fh.write(datos)
        with open(os.path.join(tmp, 'notas.md'), 'wb') as fh:
            fh.write(b'# no es binario\n')

        rutas = sorted(list(buenos) + list(malos))
        hallazgos = guard.escanear(tmp, rutas)
        encontrados = {h[0] for h in hallazgos}
        check(encontrados == set(malos),
              'debe hallar exactamente los malos; hallo %s' % sorted(encontrados))
        motivos = {h[0]: h[2] for h in hallazgos}
        check(motivos.get('falso.ttf', '').startswith('TEXTO DISFRAZADO'),
              'el .ttf falso se reporta como TEXTO DISFRAZADO')
        check(motivos.get('malo.png') == 'FIRMA INCORRECTA',
              'el .png que es JPEG se reporta como FIRMA INCORRECTA')
        check(motivos.get('vacio.png') == 'VACIO', 'el archivo de 0 bytes se reporta')

        # --solo y prefijos: filtran, no cambian el veredicto
        solo = guard.candidatos(tmp, [], {'.ttf'}, True)[0]
        check(solo == ['falso.ttf', 'ok.ttf'], '--solo .ttf filtra por extension')
        con_pref = guard.candidatos(tmp, ['ok'], set(), True)[0]
        check(con_pref == sorted(buenos), 'el prefijo filtra a los que empiezan con ok')
        check(guard.escanear(tmp, con_pref) == [],
              'solo con los buenos, no hay hallazgos (el guard no siempre falla)')
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    print('=== E. PRUEBA POR INYECCION: la deteccion sale de la tabla de firmas ===')
    # Se muta la tabla para que acepte el HTML como .ttf valido (regresion
    # simulada). Si el guard sigue detectando el falso, su deteccion NO venia de
    # la tabla y esta prueba no probaria nada.
    original = list(guard.FIRMAS['.ttf'])
    try:
        guard.FIRMAS['.ttf'] = original + [((0, b'\n\n\n\n'),)]
        inyectado = guard.firma_ok(HTML_404, guard.FIRMAS['.ttf'])
        check(inyectado is True,
              'con la firma inyectada, el HTML pasa como .ttf (control de la inyeccion)')
    finally:
        guard.FIRMAS['.ttf'] = original
    check(guard.firma_ok(HTML_404, guard.FIRMAS['.ttf']) is False,
          'restaurada la tabla, el HTML vuelve a rechazarse')

    # Regresion inversa: si alguien borra el caso HTML de clasificar_texto, el
    # reporte pierde la clasificacion (aunque el veredicto siga siendo rojo).
    pistas_originales = guard.PISTAS_TEXTO
    try:
        guard.PISTAS_TEXTO = ()
        check(guard.clasificar_texto(HTML_404) == 'TEXTO PLANO',
              'sin las pistas de 404, el HTML cae al heuristico TEXTO PLANO')
    finally:
        guard.PISTAS_TEXTO = pistas_originales
    check(guard.clasificar_texto(HTML_404) == 'HTML',
          'restauradas las pistas, vuelve a clasificar HTML')

    print('')
    if checks < CHECKS_MINIMOS:
        print('  [FALLO] solo %d checks ejecutados (minimo %d)' % (checks, CHECKS_MINIMOS))
        fallos += 1
    print('=== Resumen: %d checks, %d fallos ===' % (checks, fallos))
    if fallos:
        print('FALLOS: %d -- el guard de binarios dejo de discriminar' % fallos)
        return 1
    print('OK: el guard detecta el asset que miente sobre su formato y deja pasar los reales.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
