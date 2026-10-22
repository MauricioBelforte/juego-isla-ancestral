# Iter. 9 M23: agrega las 3 cadenas del cluster Familias (03-Diseno L35)
# al dataset principal. Edicion por bytes; el archivo es LF sin BOM.
import json

p = 'game/isla-ancestral/data/historias/secundarias.json'
data = open(p, 'rb').read()
ancla = b"\t\t}\t]\n}\n"
assert data.count(ancla) == 1, "ancla final no unica: %d" % data.count(ancla)

nuevas = """		{
			"id": "cadena-molinera",
			"titulo": "La Familia de la Molinera",
			"contexto": "La familia que muele el grano desde antes del faro guarda su reloj de arena en el molino; sin el no se turna la molienda y el pueblo espera la harina",
			"pasos": [
				{ "id": "p1", "tipo": "hablar", "npc": "mateo_mapache" },
				{ "id": "p2", "tipo": "explorar", "lugar": "molino" },
				{ "id": "p3", "tipo": "entregar", "objeto": "OBJ-REL-003" },
				{ "id": "p4", "tipo": "puzzle", "ref": "piedras-de-molienda" }
			],
			"recompensa": { "diario": "capitulo-molinera", "cosmetico": "delantal de la molinera" },
			"consecuencia": { "molienda_familiar_restaurada": true },
			"oculta": false,
			"postgame": false
		},
		{
			"id": "cadena-pescadores",
			"titulo": "La Familia de los Pescadores",
			"contexto": "El abuelo de Finneas reparo la red de la familia con un nudo que ya nadie sabe hacer; la red se solto en el muelle viejo y la familia no puede salir a pescar",
			"pasos": [
				{ "id": "p1", "tipo": "hablar", "npc": "finneas_zorro" },
				{ "id": "p2", "tipo": "explorar", "lugar": "muelle_viejo" },
				{ "id": "p3", "tipo": "entregar", "objeto": "OBJ-HER-014" },
				{ "id": "p4", "tipo": "puzzle", "ref": "nudo-del-abuelo" }
			],
			"recompensa": { "diario": "capitulo-pescadores", "cosmetico": "flotador de corcho" },
			"consecuencia": { "red_del_abuelo_reparada": true },
			"oculta": false,
			"postgame": false
		},
		{
			"id": "cadena-guardas",
			"titulo": "La Familia de los Guardas",
			"contexto": "Los guardas del bosque se turnan la noche con un candil que pasa de padres a hijos; el candil se apago en la ronda y la familia quiere devolverle la luz",
			"pasos": [
				{ "id": "p1", "tipo": "hablar", "npc": "nico_gato" },
				{ "id": "p2", "tipo": "explorar", "lugar": "bosque_nocturno" },
				{ "id": "p3", "tipo": "entregar", "objeto": "OBJ-LUZ-011" },
				{ "id": "p4", "tipo": "puzzle", "ref": "ronda-de-los-guardas" }
			],
			"recompensa": { "diario": "capitulo-guardas", "cosmetico": "capa de guarda" },
			"consecuencia": { "vigilia_de_los_guardas": true },
			"oculta": false,
			"postgame": false
		}"""

nuevo = data.replace(ancla, b"\t\t},\n" + nuevas.encode("utf-8") + b"\n\t]\n}\n", 1)
open(p, 'wb').write(nuevo)

# --- verificaciones ---
d = json.load(open(p, encoding='utf-8'))
assert len(d['cadenas']) == 26, len(d['cadenas'])
flags = {}
diarios = {}
for c in d['cadenas']:
    for f in c.get('consecuencia', {}):
        flags.setdefault(f, []).append(c['id'])
    dv = c['recompensa']['diario']
    diarios.setdefault(dv, []).append(c['id'])
dups_f = {f: v for f, v in flags.items() if len(v) > 1}
dups_d = {f: v for f, v in diarios.items() if len(v) > 1}
assert not dups_f, dups_f
assert not dups_d, dups_d
b = open(p, 'rb').read()
print('cadenas:', len(d['cadenas']))
print('flags unicos:', len(flags), '| diarios unicos:', len(diarios))
print('bytes:', len(b), 'bom:', b[:3] == b'\xef\xbb\xbf',
      'crlf:', b.count(b'\r\n'), 'lf_suelto:', b.count(b'\n') - b.count(b'\r\n'),
      'fffd:', b.count(b'\xef\xbf\xbd'))
