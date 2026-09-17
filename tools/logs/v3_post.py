# -*- coding: utf-8 -*-
# Temporal: (1) escalas.json post-v3 (2) plan cercanias con árboles. Se borra.
import io, json, sys
sys.stdout.reconfigure(encoding='utf-8')

# 1. escalas.json: palmera_joven y flor_isla horneadas a sus nuevos tamaños
path_e = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\data\escalas\escalas.json'
with io.open(path_e, 'r', encoding='utf-8') as f:
    d = json.load(f)
d['vegetacion']['palmera_joven'] = 1.0  # horneado a 4.5m
d['vegetacion']['flor_isla'] = 1.0      # horneado a 0.8m
with io.open(path_e, 'w', encoding='utf-8') as f:
    json.dump(d, f, ensure_ascii=False, indent='\t')
print('escalas.json: palmera_joven y flor_isla = 1.0 (horneadas)')

# 2. vegetation_plan.gd: cercanias_spawn incluye árboles
path_p = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\scripts\vegetacion\vegetation_plan.gd'
with io.open(path_p, 'r', encoding='utf-8') as f:
    c = f.read()
viejo = '''		var tipos_c := VM.tipos_para_bioma("cercanias")'''
nuevo = '''		# Mix de tipos: hierba/flor (mayoría) + arbusto + árboles (pocos, escala)
		var tipos_c := [
			"50-Vegetacion_hierba_alta", "50-Vegetacion_hierba_alta",
			"50-Vegetacion_flor_isla", "50-Vegetacion_flor_isla",
			"50-Vegetacion_arbusto_redondo",
			"50-Vegetacion_helecho_chico",
			"50-Vegetacion_arbol_frutal",   # árbol cerca del spawn
			"50-Vegetacion_palmera_joven",  # palmera joven cerca
		]'''
if viejo in c:
    c = c.replace(viejo, nuevo, 1)
    with io.open(path_p, 'w', encoding='utf-8') as f:
        f.write(c)
    print('plan: cercanias_spawn ahora incluye árboles')
else:
    print('WARN: patrón no encontrado — revisar manualmente')
