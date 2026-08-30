"""saneo_bajas_e34.py — E-34 mass-fix: dedupe material slots en todos los _baja.blend

Bug historico: `generar_variante.py` (antes del fix de log 245) creaba mallas
con slots de material duplicados (3 -> 6, 2 -> 4, etc.) porque `new_from_object`
ya copiaba los slots y despues el codigo volvia a apendarlos. Las caras siguen
apuntando a los slots 0..N-1, asi que visualmente no hay draw calls de mas,
pero el CONTEO de materiales reportado en el checklist se infla por encima
del presupuesto real.

Este script abre cada *_baja.blend, dedupa los slots (queda la primera
ocurrencia de cada material), guarda y reporta.
"""
import bpy, os
BM = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp'
encontrados = []
for raiz, dirs, files in os.walk(BM):
    for f in files:
        if f.endswith('_baja.blend'):
            encontrados.append(os.path.join(raiz, f))

cambios = sin_cambios = fallas = 0
for p in sorted(encontrados):
    try:
        bpy.ops.wm.open_mainfile(filepath=p)
    except Exception as e:
        print('NO SE PUDO ABRIR: %s -> %s' % (p, e))
        fallas += 1
        continue
    modified = False
    for o in bpy.context.scene.objects:
        if not o.type == 'MESH':
            continue
        slots = o.material_slots
        vistos = set()
        indices_a_borrar = []
        for i, s in enumerate(slots):
            mat = s.material
            key = mat.name if mat else None
            if key in vistos:
                indices_a_borrar.append(i)
            else:
                vistos.add(key)
        if indices_a_borrar:
            for i in reversed(indices_a_borrar):
                o.data.materials.pop(index=i)
            modified = True
    if modified:
        if os.path.exists(p + '@'):
            os.remove(p + '@')
        bpy.ops.wm.save_as_mainfile(filepath=p)
        cambios += 1
        bpy.ops.wm.open_mainfile(filepath=p)
        o = [x for x in bpy.context.scene.objects if x.type == 'MESH'][0]
        mats_usados = set()
        for cara in o.data.polygons:
            if cara.material_index < len(o.material_slots):
                m = o.material_slots[cara.material_index].material
                if m:
                    mats_usados.add(m.name)
        print('FIX   %-55s -> %d slots, %d mats usados' % (
            os.path.relpath(p, BM), len(o.material_slots), len(mats_usados)))
    else:
        sin_cambios += 1
print('---')
print('total: %d  |  modificados: %d  |  ya limpios: %d  |  fallas: %d' % (
    len(encontrados), cambios, sin_cambios, fallas))
