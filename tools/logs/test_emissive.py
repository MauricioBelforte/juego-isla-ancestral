# -*- coding: utf-8 -*-
# Test diagnóstico: material EMISSIVE en los lofts
import io, sys
sys.stdout.reconfigure(encoding='utf-8')
path = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\scripts\conejo_v10.py'
with io.open(path, 'r', encoding='utf-8') as f:
    c = f.read()

viejo = """MAT_pello = mat('MAT_Conejo_Pello', (0.78, 0.58, 0.38), rough=0.85)"""
nuevo = """MAT_pello = mat('MAT_Conejo_Pello', (0.78, 0.58, 0.38), rough=0.85, emisivo=((1.0, 0.2, 0.8), 5.0))"""
c = c.replace(viejo, nuevo, 1)
with io.open(path, 'w', encoding='utf-8') as f:
    f.write(c)
print('TEST: MAT_pello ahora es EMISSIVE rosa brillante')
