#!/usr/bin/env python3
"""
capturar_casa.py — Capturador GENERICO para las casas M18-BIS.

Reemplaza `capturar_casa_mediana.py` (que era especifico de una casa) por
un unico script parametrico: 6 orbitales + N vinietas interiores, con la
iluminacion y el radio de arena adecuados a la ESCALA de cada casa.

Motivo: el M18-BIS tiene 5 casas (choza 5x4, mediana 16x12, casona 10x8,
mansion 14x10, vecino). Copiar el capturador 5 veces duplicaria ~200 lineas
y cualquier mejora habria que aplicarla 5 veces.

Uso:
    blender -b --factory-startup --python capturar_casa.py --
        <ruta.blend> <ruta_base.png> [dist_mult=1.6]

Las VINETAS se eligen por el nombre del .blend (ver `VINETAS`). Si la casa
no esta registrada, se capturan solo los 6 orbitales y se avisa (no falla).

Para props chicos (< 2 m) sigue sirviendo capturar_angulos_headless.py.
"""
import bpy
import math
import os
import sys
from mathutils import Vector

# ============ VINETAS por asset ============
# Clave = parte del nombre del .blend. Valor = (radio_arena, [vinietas])
# Cada vineta es (posicion_camara, punto_mirada, etiqueta).
# Las camaras van a 1.0-1.4 m: vista de un NPC de 1.75 m, ligeramente por
# debajo de los ojos, que es como el jugador vera la casa por dentro.
VINETAS = {
    # --- CASA MEDIANA (16x12, 2 ambientes) -------------------------------
    'casa_mediana': (22.0, [
        # Velador + farol (la alfombra r=1.6 impide que la cama sea hero).
        (Vector((-7.40, 0.05, 0.80)), Vector((-6.60, 0.05, 0.55)),
         'Dormitorio: velador + farol (hero)'),
        (Vector((-2.20, -3.50, 1.20)), Vector((-4.60, -5.10, 0.50)),
         'Dormitorio: sala de estar (sofa + mesa baja)'),
        (Vector((5.00, 2.30, 1.30)), Vector((5.00, -0.80, 0.80)),
         'Sala: mesa de comer + 2 sillas'),
        (Vector((5.00, -2.50, 1.30)), Vector((6.40, -5.20, 1.40)),
         'Sala: estufa de lena + chimenea alta (+ nevera izq)'),
    ]),
    # --- CHOZA AMPLIADA (5x4, 1 ambiente) --------------------------------
    # Muebles: cama CX=-1.55 CY=+0.45 (cabecera Y+, largo 1.90) · cofre
    # (-1.55, -1.30) · mesa+banco (0.85, -0.55 y banco en Y+0.72) · cocina
    # (1.55, 0.60) con chimenea hasta z=4.05. Muro X- izq en X=-2.42,
    # muro X+ der en X=+2.42, muro Y- en Y=-1.92, muro Y+ en Y=+1.92.
    # Camaras ADENTRO del cuarto mirando a cada mueble, en Z=1.50-1.80
    # (vista de NPC 1.75 m con espacio sobre la cabeza, que es como un
    # jugador REAL exploraria una choza donde el techo esta a 2.65 m).
    # El script v2 fallo: las camaras estaban demasiado cerca y solo se
    # veia una esquina del mueble.
    'choza_ampliada': (10.0, [
        # 1) Cama: camara en el SURESTE del cuarto ADENTRO (X=+2.30, Y=-1.70)
        #    a Z=1.90 mirando al OESTE-NOROESTE al centro de la cama. v3
        #    estaba muy cerca, v4 era ocluida por la cocina, v5 se corrigio
        #    pero quedo muy pegado (la mesa cubria la mitad derecha y solo
        #    se veia un rincon de la cama), v6 se SALIO del cuarto (Y=-2.00
        #    estaba fuera del muro Y- en Y=-1.92 -> solo veia la cara
        #    exterior del muro). v7: X=+2.30 (dentro del muro X+ en
        #    X=+2.42), Y=-1.70 (dentro del muro Y- en Y=-1.92, margen
        #    0.22), Z=1.90 (picado suave para ver la cabecera). Linea de
        #    vision pasa por (X=0.85, Y=-1.10) cuando cruza la mesa
        #    (mesa en Y=[-0.85,-0.25]) -> SIN oclusion. Tambien pasa por
        #    encima del cofre (cofre en Y=-1.30 +/-0.30, X=-1.55).
        (Vector((2.30, -1.70, 1.90)), Vector((-1.55, 0.45, 0.55)),
         'Unico ambiente: cama (hero, cabecera)'),
        # 2) Cocina de lena + chimenea: camara en el OESTE interior (-0.80, -0.30)
        #    a Z=1.20 mirando al ESTE a la estanteria (1.55, 0.60, z=0.80,
        #    mitad de la boca del hogar). v3 estaba a 2.4 m -> muy pegado.
        #    v8 estaba a Z=1.80 -> solo veia el techo de la estanteria.
        #    v9 inclino mucho hacia arriba -> solo se veia el sombrerete
        #    desde abajo. v10: frontal con leve picado (9 deg abajo),
        #    distancia 2.55 m -> la estanteria entra completa (0.70x0.62)
        #    ocupando 25% del frame, con la hornalla+llama visibles al
        #    frente. El cano+sombrero quedan arriba del frame pero la
        #    captura exterior ya muestra el sombrerete rojo sobre la paja.
        (Vector((-0.80, -0.30, 1.20)), Vector((1.55, 0.60, 0.80)),
         'Unico ambiente: cocina de lena (estanteria + boca + llama)'),
        # 3) Mesa + banco: camara en el NE del cuarto (1.80, 1.50) a Z=1.60
        #    mirando al SW hacia la zona mesa-banco (0.20, -0.50, z=0.65).
        #    Angulo 3/4: mesa en primer plano, banco en segundo plano al
        #    lado opuesto (banco Y=+0.17 esta del lado opuesto de la
        #    mesa Y=-0.55 respecto al eje camara-target). v8 estaba casi
        #    al ras del tablero y se veia solo la superficie.
        (Vector((1.80, 1.50, 1.60)), Vector((0.20, -0.50, 0.65)),
         'Unico ambiente: mesa + banco'),
        # 4) Vista GENERAL del cuarto desde el NE (1.50, 1.50) a Z=1.60
        #    mirando al SW corner (-1.00, -1.00, z=0.50). v3 estaba casi
        #    cenital y se veia una mesa en escorzo. v8: angulo 3/4 desde
        #    NE -> cama al fondo-izq, cocina al fondo-der (caño+sombrero
        #    asomando sobre cumbrero rojo), mesa al centro, cofre al
        #    fondo-izq atras. Esta es la "vista de inventario".
        (Vector((1.50, 1.50, 1.60)), Vector((-1.00, -1.00, 0.50)),
         'Unico ambiente: vista general desde NE'),
    ]),
    # --- CASONA (10x8, 4 ambientes: sala + cocina + 2 dormitorios) --------
    # Planta: sala Y[0, 3.82] ancho completo · tabique en Y=0 con 3 vanos
    # (dorm1 X[-3.70,-2.70], cocina X[-0.70,0.70], dorm2 X[2.70,3.70]) ·
    # tabiques verticales en X=+-1.60 separando cocina de los dormitorios.
    # Muebles: sofa (-3.55, 1.40) · mesa centro (-2.15, 1.40) · estanteria
    # (3.70, 0.30) · alfombra (-2.60, 1.60) · lampara (-4.30, 2.90) ·
    # cocina lena (0.00, -3.15) con caño hasta z=4.10 · mesa cocina
    # (-0.55, -1.35) · pozo (0.95, -1.35) · cama doble (-3.90, -1.70) ·
    # velador 1 (-2.55, -0.85) · comoda (-2.30, -3.30) · cama basica
    # (3.90, -1.70) · velador 2 (2.55, -0.85) · cuadro (4.55, -3.10).
    # Muros 3.00 alto, PISO_Z 0.105 -> camaras a 1.50-1.65 (vista de NPC).
    'casona': (14.0, [
        # 1) Sala desde el NE mirando al SO: sofa + mesa de centro + alfombra
        (Vector((-0.90, 3.30, 1.55)), Vector((-3.20, 1.20, 0.55)),
         'Sala: sofa + mesa de centro + alfombra'),
        # 2) Sala lado derecho: estanteria con libros + lampara de pie al fondo
        (Vector((1.60, 2.90, 1.55)), Vector((3.80, 0.40, 1.05)),
         'Sala: estanteria + lampara de pie'),
        # 3) Cocina: cocina de lena + chimenea que atraviesa el techo.
        #    Camara en el vano (X=0) mirando al fondo: el pozo (0.95, -1.35)
        #    queda a la derecha y la mesa (-0.55, -1.35) a la izquierda, asi
        #    se ven los 3 a la vez sin que ninguno tape el hogar.
        (Vector((0.00, -0.35, 1.50)), Vector((0.00, -3.05, 0.80)),
         'Cocina: cocina de lena + chimenea + pozo'),
        # 4) Dormitorio 1: cama doble. 3/4 desde la puerta, con el velador
        #    en primer plano abajo (da profundidad, no tapa: esta a 0.46 m
        #    de la camara y su punto mas alto esta en 0.86).
        (Vector((-2.10, -0.75, 1.55)), Vector((-3.60, -1.85, 0.55)),
         'Dormitorio 1: cama doble + velador'),
        # 5) Dormitorio 2: cama basica + cuadro ancestral en el muro X+
        (Vector((2.10, -0.75, 1.55)), Vector((3.90, -2.10, 0.60)),
         'Dormitorio 2: cama basica + cuadro ancestral'),
        # 6) Vista de inventario: desde la puerta principal se ven los 3 vanos
        #    del tabique, que es lo que explica la planta de una mirada.
        (Vector((0.00, 3.45, 1.60)), Vector((0.00, -1.60, 0.70)),
         'General: sala y los 3 vanos del tabique'),
    ]),
}


def setup_iluminacion(radio_arena):
    """Sol fuerte + relleno + fondo claro (sin esto la casa queda silueta)."""
    escena = bpy.context.scene

    mundo = escena.world
    if mundo is None:
        mundo = bpy.data.worlds.new('Mundo_Captura')
        escena.world = mundo
    mundo.use_nodes = True
    nt = mundo.node_tree
    bg = nt.nodes.get('Background')
    if bg is None:
        bg = nt.nodes.new('ShaderNodeBackground')
        nt.nodes.new('ShaderNodeWorldOutput')
        nt.links.new(bg.outputs['Background'],
                     nt.nodes['World Output'].inputs['Surface'])
    bg.inputs['Color'].default_value = (0.78, 0.82, 0.85, 1.0)
    bg.inputs['Strength'].default_value = 0.6

    sol_data = bpy.data.lights.new('Sol_Captura', 'SUN')
    sol_data.energy = 4.5
    sol_data.color = (1.0, 0.96, 0.88)
    sol_data.angle = 0.6
    sol = bpy.data.objects.new('Sol_Captura', sol_data)
    bpy.context.scene.collection.objects.link(sol)
    sol.location = (12.0, -8.0, 18.0)
    sol.rotation_euler = (math.radians(50.0), math.radians(12.0),
                          math.radians(35.0))

    rel_data = bpy.data.lights.new('Relleno_Captura', 'AREA')
    rel_data.energy = 220.0
    rel_data.color = (0.85, 0.90, 1.0)
    rel_data.size = 24.0
    rel = bpy.data.objects.new('Relleno_Captura', rel_data)
    bpy.context.scene.collection.objects.link(rel)
    rel.location = (-14.0, 10.0, 12.0)
    rel.rotation_euler = (math.radians(48.0), 0.0, math.radians(140.0))

    # La Base_Arena del generador nace con r=7: para una casa de 16 m no
    # alcanza y la casa "flota" sobre un disco chico. Se re-escala al radio
    # que corresponde a cada casa (parametro).
    if 'Base_Arena' in bpy.data.objects:
        arena = bpy.data.objects['Base_Arena']
        arena.scale = (radio_arena, radio_arena, 1.0)
        arena.location = (0.0, 0.0, -0.06)


def medir(obs):
    if not obs:
        return Vector((0.0, 0.0, 0.0)), 1.0
    mins, maxs = [], []
    for o in obs:
        bb = [o.matrix_world @ Vector(c) for c in o.bound_box]
        mins.append(Vector((min(v.x for v in bb), min(v.y for v in bb),
                            min(v.z for v in bb))))
        maxs.append(Vector((max(v.x for v in bb), max(v.y for v in bb),
                            max(v.z for v in bb))))
    cmin = Vector((min(m.x for m in mins), min(m.y for m in mins),
                   min(m.z for m in mins)))
    cmax = Vector((max(m.x for m in maxs), max(m.y for m in maxs),
                   max(m.z for m in maxs)))
    return ((cmin + cmax) / 2.0,
            max((cmax - cmin).x, (cmax - cmin).y, (cmax - cmin).z) / 2.0)


def main():
    argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
    if len(argv) < 2:
        print('Uso: blender -b --python capturar_casa.py -- '
              '<blend> <base.png> [dist_mult=1.6]')
        sys.exit(1)
    blend = os.path.abspath(argv[0])
    ruta_base = os.path.abspath(argv[1])
    dist_mult = float(argv[2]) if len(argv) > 2 else 1.6
    n = 6

    if not os.path.exists(blend):
        print('ERROR: blend no existe: ' + blend)
        sys.exit(1)
    os.makedirs(os.path.dirname(ruta_base), exist_ok=True)
    raiz, ext = os.path.splitext(ruta_base)
    if not ext:
        ext = '.png'
    rutas = ['%s_az%03d%s' % (raiz, int(360 * i / n), ext) for i in range(n)]

    # elegir config de vinietas por nombre de asset
    nombre = os.path.basename(blend).lower()
    radio_arena, vinetas = 10.0, []
    for clave, (r_arena, v) in VINETAS.items():
        if clave in nombre:
            radio_arena, vinetas = r_arena, v
            break
    else:
        print('AVISO: sin vinietas registradas para %r — solo 6 orbitales'
              % os.path.basename(blend))

    # E-26: abrir ANTES de medir.
    bpy.ops.wm.open_mainfile(filepath=blend)
    bpy.context.view_layer.update()

    setup_iluminacion(radio_arena)
    bpy.context.view_layer.update()

    obs = [o for o in bpy.data.objects
           if o.type == 'MESH' and o.name.startswith('SM_')]
    print('SM_ capturados: %d' % len(obs))
    centro, radio = medir(obs)
    radio = max(radio, 0.35)
    altura = centro.z
    dist = radio * 3.0 * dist_mult
    print('centro=%s radio=%.2f altura=%.2f dist=%.2f' %
          (tuple(round(c, 2) for c in centro), radio, altura, dist))

    cam_data = bpy.data.cameras.new('CAM_Orbital')
    cam_data.lens = 45
    cam = bpy.data.objects.new('CAM_Orbital', cam_data)
    bpy.context.scene.collection.objects.link(cam)
    bpy.context.scene.camera = cam

    escena = bpy.context.scene
    escena.render.resolution_x = 1200
    escena.render.resolution_y = 800
    escena.render.image_settings.file_format = 'PNG'
    try:
        escena.eevee.use_ssr = True
        escena.eevee.use_ssr_refraction = True
        escena.eevee.use_raytracing = True
    except Exception:
        pass

    for i in range(n):
        az = 2 * math.pi * i / n
        cam.location = (centro.x + dist * math.cos(az),
                        centro.y + dist * math.sin(az),
                        altura + radio * 0.55)
        cam.rotation_euler = (centro - cam.location).to_track_quat(
            '-Z', 'Y').to_euler()
        bpy.context.view_layer.update()
        escena.render.filepath = rutas[i]
        bpy.ops.render.render(write_still=True)
        print(('OK  ' if os.path.exists(rutas[i]) else 'FALLO ') + rutas[i])

    # VINETAS INTERIORES: la casa es ENTRABLE y AMUEBLADA — el exterior
    # solo no valida la directiva del usuario.
    if vinetas:
        rutas_int = ['%s_interior_az%03d%s' % (raiz, int(360 * i / len(vinetas)),
                                               ext)
                     for i in range(len(vinetas))]
        for (loc, tgt, label), ruta in zip(vinetas, rutas_int):
            cam.location = loc
            cam.rotation_euler = (tgt - loc).to_track_quat('-Z', 'Y').to_euler()
            bpy.context.view_layer.update()
            escena.render.filepath = ruta
            bpy.ops.render.render(write_still=True)
            print(('OK  ' if os.path.exists(ruta) else 'FALLO ') + ruta
                  + '  (' + label + ')')

    print('---')
    print('Captura OK. Revisa que NO haya luz/aire entre objeto y base (E-13).')


if __name__ == '__main__':
    main()
