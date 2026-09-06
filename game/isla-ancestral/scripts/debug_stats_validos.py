# -*- coding: utf-8 -*-
# Debug: imprimir las 3 condiciones imposibles detectadas
import io, sys
sys.stdout.reconfigure(encoding='utf-8')
with io.open(r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\scripts\progresion\progression_manager.gd', 'r', encoding='utf-8') as f:
    c = f.read()
idx = c.find('detectar_condiciones_imposibles_estaticas')
# Buscar la lista de stats válidos
idx2 = c.find('_stats_validos_conocidos')
print(c[idx2:idx2+1500])
