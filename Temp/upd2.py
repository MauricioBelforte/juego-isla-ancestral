import json
root = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
e = root + chr(92) + 'Logs' + chr(92) + 'estado_director.json'
st = json.load(open(e, encoding='utf-8'))
st['detector_bug_fixado'] = {'desc': 'Mi detector EXCLUÍA a DS-OpenCode y Nemotron (los marcaba "offline/autónomo"), así que no leía ni acuseaba sus mensajes (DS-OC 225-229 sin acuse, Nemotron B-0/P1 bloqueado). CORRECCION: ambos entran en la detección de los Crons A/B. Regla: ningun canal activo queda afuera del detector.'}
st['dsoc_m67_ruta_b_go'] = {'desc': 'GO M67 Ruta B: re-ver 63 marcas promovidas sin sustento -> 40 [x]. DS-OC aplica. Aprobado en #230.'}
st['dsoc_chase_commits'] = {'desc': 'Tarea (b) DS-OC: investigar a7a3a6b (291 [?] borrados en 50 modulos, pares iden) + 3a3d32c + dd6fb70: deuda legitima perdida o cleanup legitimo? Inventario por modulo + veredicto. NO el grep-repowide (ese es de DeepSeek-WorkBuddy TANDA 7, anti-pisado).'}
st['dsoc_degradaciones_aceptadas'] = {'desc': 'M74(58)+M71(44)+M105(28)+M115(26)=156 marcas false-green Beam -> [?], autor unico Reflection-Beam-1.0. Gate-1 agnes OK (conteos coinciden).'}
st['nemotron_b0_p1_designado'] = {'desc': 'Nemotron B-0 = pre-verif boot-headless M101/M34/M59 (evidencia de boot+suite para que Hy3 gate-2 sin re-medir); P1 = pre-check vision assets M157/M154. Reducir re-aviso redundant en standby.'}
st['nemotron_spam_10min'] = {'desc': 'Nemotron cron 10min re-reportaba "no hay trabajo" cada vez; instruido a reportar 1 vez "standby" y callar hasta designacion nueva.'}
json.dump(st, open(e, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print('estado actualizado: detector fix + M67 GO + chase + nemotron B-0/P1')
