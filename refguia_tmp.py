# -*- coding: utf-8 -*-
import io

# 1) AGENTS.md: referencia en la seccion de numeracion
p = 'AGENTS.md'
t = io.open(p, encoding='utf-8-sig', errors='replace').read()
anchor = '## 5. Respaldos ante Cambios Grandes'
ref_lines = [
 '## 4.1-b GUÍA DE NUMERACIÓN DE CANALES (fundador 23oct 04:30 — obligatoria para todos los crons y apiladores)',
 '',
 'Cuando un canal de `Mensajes entre modelos/<agente>/` acumule gemelos/huecos/desorden: usar la GUIA y el script oficial (NUNCA sufijos -B, NUNCA renumerar a mano):',
 '- Guía SOP: `Mensajes entre modelos/GUIA-NUMERACION-CANALES.md` (trampas, reglas, mantenimiento preventivo)',
 '- Herramienta: `python -X utf8 scripts/renumerar_canal.py "Mensajes entre modelos/<canal>"` (renumeración secuencial 001-N por fecha cronológica real + INDICE-CANAL.md con mapping viejo→nuevo + pool reseembra + punteros)',
 '- Reglas críticas: (1) consumir head del pool EN el mismo acto de escribir (nunca predecir el número), (2) sembrar pools ≥30-40 en días de producción, (3) archivos-fantasma NTFS (>260 MAX_PATH) se saltan con try/except, (4) nunca editar logs históricos para arreglar números — resuelven con el INDICE-CANAL mapping.',
 '',
]
ref = chr(10).join(ref_lines)
if 'GUIA-NUMERACION-CANALES' not in t:
    t = t.replace(anchor, ref + chr(10) + anchor, 1)
    io.open(p, 'w', encoding='utf-8', newline='').write(t)
    print('AGENTS.md: referencia anadida en 4.1-b')
else:
    print('AGENTS.md ya la tenia')

# 2) CRONOMETROS canon: referencia tambien
p2 = 'DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash-Director/CRONOMETROS-VIGENTES-COMO-CREARLOS.md'
t2 = io.open(p2, encoding='utf-8-sig', errors='replace').read()
if 'GUIA-NUMERACION-CANALES' not in t2:
    t2 = t2.rstrip() + chr(10) + chr(10) + '- REFERENCIA CRUZADA: la SOP de numeración de canales vive en `Mensajes entre modelos/GUIA-NUMERACION-CANALES.md` (fundador 23oct 04:30) con herramienta `scripts/renumerar_canal.py` — obligatoria cuando un canal acumule gemelos/huecos.' + chr(10)
    io.open(p2, 'w', encoding='utf-8', newline='').write(t2)
    print('cronometros canon: referencia cruzada anadida')

# 3) estado
ph = 'Logs/estado_director.json'
e = json = None
import json as J
e = J.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-23T04:34:00'
e['infraestructura_crons']['guia_numeracion'] = 'publicada en Mensajes entre modelos/GUIA-NUMERACION-CANALES.md + referenciada en AGENTS.md 4.1-b y CRONOMETROS canon (23oct 04:34, orden del fundador: "que sepan todos de su existencia")'
J.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
print('estado OK')

subprocess.run(['git', 'add', p, p2, ph], capture_output=True)
r = subprocess.run(['git', 'commit', '-m', 'Se referencia la guia de numeracion en agents y en el canon de cronometros'], capture_output=True, text=True, encoding='utf-8', errors='replace')
r2 = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r2.stdout.strip())
