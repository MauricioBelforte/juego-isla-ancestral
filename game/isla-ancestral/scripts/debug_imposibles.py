# -*- coding: utf-8 -*-
# Debug: detectar las 3 condiciones imposibles y mostrarlas
import io, sys
sys.stdout.reconfigure(encoding='utf-8')
with io.open(r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\scripts\progresion\progression_manager.gd', 'r', encoding='utf-8') as f:
    c = f.read()
# Buscar la implementación de detectar_condiciones_imposibles_estaticas
idx = c.find('detectar_condiciones_imposibles_estaticas')
print(c[idx:idx+2000])
