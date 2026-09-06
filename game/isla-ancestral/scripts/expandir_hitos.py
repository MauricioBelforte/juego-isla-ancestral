# -*- coding: utf-8 -*-
# M71: Expandir hitos.json de 15 a 25 con stats de puentes existentes
import io, json, sys

path = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\data\progresion\hitos.json'
with io.open(path, 'r', encoding='utf-8') as f:
    d = json.load(f)

nuevos = [
    # ── Pesca (M34: pescar_<pez_id>) ──
    {"id": "hito_peces_10", "nombre": "Pescador Paciente", "dominio": "generales",
     "condicion": {"tipo": "stat_min", "stat_id": "peces_capturados", "umbral": 10},
     "recompensas": [{"tipo": "info", "valor": "El anzuelo y vos ya son amigos."}]},
    {"id": "hito_peces_30", "nombre": "Maestro del Anzuelo", "dominio": "generales",
     "condicion": {"tipo": "stat_min", "stat_id": "peces_capturados", "umbral": 30},
     "recompensas": [{"tipo": "info", "valor": "Los peces saltan cuando te acercás."}]},
    # ── Trueques (M38: trueque_exitoso) ──
    {"id": "hito_trueques_5", "nombre": "Negociador Nato", "dominio": "economia",
     "condicion": {"tipo": "stat_min", "stat_id": "trueques_realizados", "umbral": 5},
     "recompensas": [{"tipo": "info", "valor": "Nadie cierra un truco mejor que vos."}]},
    # ── Amistades (M20: friendship_level_up) ──
    {"id": "hito_amistades_nivel2", "nombre": "Amigo de Todos", "dominio": "amistad",
     "condicion": {"tipo": "stat_min", "stat_id": "amistades_subidas", "umbral": 2},
     "recompensas": [{"tipo": "info", "valor": "Tu presencia ilumina la isla."}]},
    # ── Sellos adicionales (M22: sellos_obtenidos stats) ──
    {"id": "hito_sellos_4", "nombre": "Cuatro Sellos Ancestrales", "dominio": "historia",
     "condicion": {"tipo": "stat_min", "stat_id": "sellos_obtenidos", "umbral": 4},
     "recompensas": [{"tipo": "info", "valor": "La isla susurra tu nombre en el viento."}]},
    # ── Misiones adicionales ──
    {"id": "hito_misiones_10", "nombre": "Vecino Ejemplar", "dominio": "amistad",
     "condicion": {"tipo": "stat_min", "stat_id": "misiones_completadas", "umbral": 10},
     "recompensas": [{"tipo": "info", "valor": "Diez misiones: la isla confía en vos."}]},
    # ── Viajes adicionales (M28: travel_started) ──
    {"id": "hito_viajes_5", "nombre": "Marinero Experto", "dominio": "generales",
     "condicion": {"tipo": "stat_min", "stat_id": "viajes_realizados", "umbral": 5},
     "recompensas": [{"tipo": "info", "valor": "El Gran Vapor ya es tu casa flotante."}]},
    # ── Contribución económica (reputación) ──
    {"id": "hito_contribucion_500", "nombre": "Contribuyente Honorario", "dominio": "economia",
     "condicion": {"tipo": "stat_min", "stat_id": "monedas_ganadas", "umbral": 500},
     "recompensas": [{"tipo": "info", "valor": "500 monedas ganadas: la economía florece."}]},
    {"id": "hito_contribucion_2000", "nombre": "Pilar Económico", "dominio": "economia",
     "condicion": {"tipo": "stat_min", "stat_id": "monedas_ganadas", "umbral": 2000},
     "recompensas": [{"tipo": "info", "valor": "2000 monedas: un pilar de la economía de Aurora."}]},
    # ── Hitos previos (encadenamiento) ──
    {"id": "hito_explorador_completo", "nombre": "Explorador Completo", "dominio": "generales",
     "condicion": {"tipo": "compuesta", "operador": "AND", "hijos": [
         {"tipo": "stat_min", "stat_id": "viajes_realizados", "umbral": 3},
         {"tipo": "stat_min", "stat_id": "items_recolectados", "umbral": 50},
         {"tipo": "stat_min", "stat_id": "misiones_completadas", "umbral": 5}
     ]},
     "recompensas": [{"tipo": "info", "valor": "Explorador, recolector y vecino: todo en uno."}]},
]

ids_existentes = {h["id"] for h in d["hitos"]}
agregados = 0
for h in nuevos:
    if h["id"] not in ids_existentes:
        d["hitos"].append(h)
        agregados += 1

with io.open(path, 'w', encoding='utf-8') as f:
    json.dump(d, f, ensure_ascii=False, indent='\t')
print('hitos.json: %d nuevos agregados, total %d' % (agregados, len(d["hitos"])))
