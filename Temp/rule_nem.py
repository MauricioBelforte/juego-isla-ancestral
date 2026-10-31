import json
root = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
e = root + chr(92) + 'Logs' + chr(92) + 'estado_director.json'
st = json.load(open(e, encoding='utf-8'))
st['regla_permanente_nemotron_fuel'] = {
 'directiva': 'Fundador 31oct 02:51: "Recorda SIEMPRE revisar si Nemotron tiene tareas para hacer y llenale su backlog cuando falten."',
 'accion': 'En CADA Cron D (asignador) y en cada verificacion de flota: chequear el BACKLOG-MASTER de Nemotron. Si sus rieles [ ]/[->] ejecutables por EL (nicho vision/boot/MCP) quedan < ~5 items, AGREGAR un riel nuevo (B-11, B-12...) con tasks de su capacidad (gate-2 boot de modulos a sellar, vision post-flip, vision assets M154). Nemotron dispara cron 10min y se queda en standby si el backlog esta vacio. NO lo dejar sin fuel.',
 'estado_actual': 'B-8 (boot M55/M60/M48/M151) + B-9 (vision post-flip) + B-10 (vision assets M33/M65/M54/M50) = ~13 modulos. B-8 en curso (M48 SOSTENIDO 3/4).',
}
json.dump(st, open(e, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print('regla permanente nemotron-fuel anotada en estado')
