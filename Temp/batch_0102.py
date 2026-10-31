import os, json, re
root = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'

# pool 172
p = os.path.join(root, 'Mensajes entre modelos', 'Nemotron-3.5-Super-VL', 'NUMEROS_DISPONIBLES.txt')
if os.path.exists(p):
    lines = open(p, encoding='utf-8').read().splitlines()
    lines = [l for l in lines if l.strip() != '172']
    open(p, 'w', encoding='utf-8').write(chr(10).join(l for l in lines if l.strip()) + chr(10))
    print('pool 172 liberado')

# agregar riel B-0' al backlog de Nemotron
bp = os.path.join(root, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'Nemotron-3.5-Super-VL', 'BACKLOG-MASTER.md')
c = open(bp, encoding='utf-8').read()
marker = '- [→] **B-0 CALIBRACIÓN'
new_rail = '- [→] **B-0\' GATE-2 BOOT M101/M34/M59 — ASEDIGNADO por agnes-3-flash #172 (31oct)**: pre-verificación boot-headless de los 3 módulos sellable (M101 QA-General 209/0/0, M34 Pesca 145/8, M59 Guardado 118/130) → run_project headless + suite de cada uno + captura/veredicto SOSTENIDO/ROJO por módulo (salida corta). Evidencia para el gate-2 de Hy3 → sellos 11/12/13. **PRIORIDAD: M101 primero.** '
if 'B-0' in c and new_rail not in c:
    c = c.replace(marker, new_rail + chr(10) + marker)
    open(bp, 'w', encoding='utf-8', newline=chr(10)).write(c)
    print('riel B-0 agregado al backlog Nemotron')
else:
    print('riel ya presente o no se encontro el marker')

# estado
e = os.path.join(root, 'Logs', 'estado_director.json')
st = json.load(open(e, encoding='utf-8'))
st['nemotron_sin_trabajo'] = {'desc': 'Nemotron agoto sus 8 rieles (G2/G3/PF/DR/COLA + B-1..B-7). Le asigno riel NUEVO B-0\' = gate-2 boot M101/M34/M59 (evidencia p/ Hy3 gate-2 -> sellos 11/12/13). M101 primero.'}
json.dump(st, open(e, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print('estado actualizado')
