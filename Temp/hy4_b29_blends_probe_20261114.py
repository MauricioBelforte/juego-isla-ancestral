# Sonda de CALIBRACION B29 — 6 .blend de columna_rota (2 variantes x 3 LOD).
#
# NO es una guardia: solo MIDE. Se ejecuta con
#   blender -b --factory-startup --python-exit-code 1 \
#     --python Temp/hy4_b29_blends_probe_20261114.py
#
# Motivo: chk_asset.py mide COSTE (objetos/tris/materiales) y la guardia
# verificar_columna_rota.py (B27) mide el BIN del GLB. NINGUNA de las dos
# mide la FORMA del .blend de origen. El precedente real es 2026-11-06:
# la BAJA de columna_entera paso los 3 presupuestos M166 con el ABACO
# COLAPSADO por decimate. Antes de escribir umbrales hay que medirlos.
#
# Sale: Temp/hy4_b29_blends_probe_20261114.json + .txt (scratch, NO borrar).
import bpy  # noqa: E402
import os  # noqa: E402
import sys  # noqa: E402
import json  # noqa: E402
import hashlib  # noqa: E402

RAIZ = os.path.abspath('.')
MOD_DIR = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '25-Ruinas-Templos')
OUT_JSON = os.path.join(RAIZ, 'Temp', 'hy4_b29_blends_probe_20261114.json')
OUT_TXT = os.path.join(RAIZ, 'Temp', 'hy4_b29_blends_probe_20261114.txt')

VARIANTES = ('columna_rota_alta_lowpoly', 'columna_rota_baja_lowpoly')
SUFS = ('', '_media', '_baja')
LODS = ('alta', 'media', 'baja')
Z_APOYO = 0.045


def verts_mundo(o):
    return [o.matrix_world @ v.co for v in o.data.vertices]


def sha12(ruta):
    h = hashlib.sha256()
    with open(ruta, 'rb') as f:
        for bloque in iter(lambda: f.read(1 << 16), b''):
            h.update(bloque)
    return h.hexdigest()[:12]


def medir(ruta):
    bpy.ops.wm.open_mainfile(filepath=os.path.abspath(ruta))
    bpy.context.view_layer.update()
    obs = [o for o in bpy.context.scene.objects
           if o.type == 'MESH' and o.name.startswith('SM_')]
    vs = [v for o in obs for v in verts_mundo(o)]
    if not vs:
        raise RuntimeError('sin vertices SM_ en %s' % ruta)

    zmin = min(v.z for v in vs)
    zmax = max(v.z for v in vs)
    va = [v for v in vs if abs(v.z - Z_APOYO) < 1e-4]
    fx = (max(v.x for v in va) - min(v.x for v in va)) if va else -1.0
    fy = (max(v.y for v in va) - min(v.y for v in va)) if va else -1.0

    niveles = {}
    for v in vs:
        k = round(v.z, 4)
        niveles[k] = niveles.get(k, 0) + 1

    materiales = set()
    caras = 0
    tris = 0
    por_obj = []
    for o in obs:
        m = o.data
        m.calc_loop_triangles()
        t = len(m.loop_triangles)
        tris += t
        caras += len(m.polygons)
        om = set()
        for f in m.polygons:
            if f.material_index < len(m.materials):
                mat = m.materials[f.material_index]
                if mat:
                    om.add(mat.name)
                    materiales.add(mat.name)
        ov = verts_mundo(o)
        por_obj.append({
            'nombre': o.name,
            'verts': len(ov),
            'caras': len(m.polygons),
            'tris': t,
            'mats': sorted(om),
            'z': [round(min(w.z for w in ov), 4), round(max(w.z for w in ov), 4)],
        })

    # Caras LATERALES que unen EXACTAMENTE dos niveles consecutivos.
    # Un decimate que colapsa una losa deja triangulos con vertices a alturas
    # intermedias: esos NO cuentan como cara completa.
    nivs = sorted(niveles)
    bandas = []
    for a, b in zip(nivs, nivs[1:]):
        if b - a < 1e-6:
            continue
        n = 0
        for o in obs:
            m3 = o.matrix_world.to_3x3()
            for f in o.data.polygons:
                zs = [round((o.matrix_world @ o.data.vertices[i].co).z, 4)
                      for i in f.vertices]
                if abs(min(zs) - a) > 1e-3 or abs(max(zs) - b) > 1e-3:
                    continue
                if any(abs(z - a) > 1e-3 and abs(z - b) > 1e-3 for z in zs):
                    continue
                if abs((m3 @ f.normal).z) < 0.5:
                    n += 1
        bandas.append({'de': a, 'a': b, 'caras_laterales': n})

    return {
        'ruta': os.path.relpath(ruta, RAIZ).replace('\\', '/'),
        'sha12': sha12(ruta),
        'bytes': os.path.getsize(ruta),
        'objetos': len(obs),
        'verts': len(vs),
        'caras': caras,
        'tris': tris,
        'mats': sorted(materiales),
        'zmin': round(zmin, 4),
        'zmax': round(zmax, 4),
        'altura': round(zmax - zmin, 4),
        'apoyo_verts': len(va),
        'huella': [round(fx, 4), round(fy, 4)],
        'niveles': {str(k): v for k, v in sorted(niveles.items())},
        'n_niveles': len(niveles),
        'bandas': bandas,
        'por_obj': por_obj,
    }


def main():
    datos = {}
    lineas = []
    for var in VARIANTES:
        datos[var] = {}
        for suf, lod in zip(SUFS, LODS):
            ruta = os.path.join(MOD_DIR, var + suf + '.blend')
            if not os.path.isfile(ruta):
                print('FALTA BLEND %s' % ruta)
                sys.exit(2)
            d = medir(ruta)
            datos[var][lod] = d
            lineas.append(
                '%-28s %-5s obj=%-3d verts=%-4d caras=%-4d tris=%-4d '
                'mats=%d z=[%.4f..%.4f] alt=%.4f apoyo=%-3d '
                'huella=%.4fx%.4f niveles=%d sha=%s'
                % (var, lod, d['objetos'], d['verts'], d['caras'], d['tris'],
                   len(d['mats']), d['zmin'], d['zmax'], d['altura'],
                   d['apoyo_verts'], d['huella'][0], d['huella'][1],
                   d['n_niveles'], d['sha12']))
            lineas.append('    objetos: ' + ', '.join(
                '%s(%d Tris/%s)' % (o['nombre'], o['tris'],
                                    ','.join(o['mats']) or '-')
                for o in d['por_obj']))
            lineas.append('    niveles: ' + ', '.join(
                '%s:%d' % (k, v) for k, v in list(d['niveles'].items())[:14]))
            lineas.append('    bandas:  ' + ', '.join(
                '%.4f->%.4f:%d' % (b['de'], b['a'], b['caras_laterales'])
                for b in d['bandas'][:14]))

    # Diferencia de altura entre variantes, MEDIDA en cada LOD.
    for lod in LODS:
        a = datos[VARIANTES[0]][lod]['zmax']
        b = datos[VARIANTES[1]][lod]['zmax']
        lineas.append('DIF_ALTURA %-5s alta_var=%.4f baja_var=%.4f diff=%.4f'
                      % (lod, a, b, round(a - b, 4)))

    with open(OUT_JSON, 'w', encoding='utf-8') as f:
        json.dump(datos, f, indent=2, ensure_ascii=False, sort_keys=True)
    txt = '\n'.join(lineas) + '\n'
    with open(OUT_TXT, 'w', encoding='utf-8', newline='\n') as f:
        f.write(txt)
    print(txt)
    print('SONDA_B29 FIN 6 blends -> %s' % os.path.relpath(OUT_JSON, RAIZ))


if __name__ == '__main__':
    main()
