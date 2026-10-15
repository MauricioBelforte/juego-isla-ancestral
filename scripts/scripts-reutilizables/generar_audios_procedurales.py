# -*- coding: utf-8 -*-
"""
Generador de audios procedurales para revisión del fundador.

Lee `game/isla-ancestral/data/audio/sfx_tones.json` (las 21 situaciones que M43 ya
diseñó) y renderiza un WAV por situación en
`DOCUMENTACION/TAREAS-POR-MODELO/step-5-kilocode/audio/`.

Forma de onda y timbre se derivan del campo `tono` de cada situación:
  calido/positivo   -> seno con armónico suave (2do armónico al 12%)
  brillante/logro   -> seno + 3er armónico (más presencia)
  metalico/mecanico -> seno + ruido filtrado de ataque (click metálico)
  agua              -> seno + ruido pasa-altos modulado (salpicadura)
  tierra/follaje    -> ruido filtrado pasa-bajos con envolvente corta
  suave/papel       -> seno con ataque muy suave y decay largo

Cada WAV se verifica numéricamente: pico, offset DC, duración y clipping.
Los parámetros (frecuencias, duraciones, amplitudes) quedan en constantes al
inicio del archivo para que el fundador los ajuste por oreja.

Modelo: step-5-kilocode
Plataforma: Kilo Code
Fecha: 2026-10-15
"""
import io, json, math, os, wave, struct

RUTA_TONES = 'game/isla-ancestral/data/audio/sfx_tones.json'
SALIDA = 'DOCUMENTACION/TAREAS-POR-MODELO/step-5-kilocode/audio'
SAMPLE_RATE = 44100

# Parámetros ajustables (para afinación por oreja del fundador)
AMP_BASE = 0.35          # amplitud de referencia
AMP_ARMONICO = 0.12      # peso del 2do/3er armónico
ATAQUE_S = 0.008         # ataque para evitar clicks
RELEASE_S = 0.05         # release final

# Timbres por campo `tono` del JSON
TIMBRES = {
    'calido':     ['seno', 'arm2'],
    'positivo':   ['seno', 'arm2'],
    'brillante':  ['seno', 'arm3'],
    'logro':      ['seno', 'arm3'],
    'suave':      ['seno', 'suave'],
    'muy_suave':  ['seno', 'suave'],
    'metalico':   ['seno', 'ruido_hp'],
    'mecanico':   ['seno', 'ruido_hp'],
    'seco':       ['ruido_hp'],
    'agua':       ['seno', 'ruido_hp_mod'],
    'tierra':     ['ruido_lp'],
    'follaje':    ['ruido_lp'],
    'papel':      ['seno', 'suave'],
    'medio':      ['seno', 'arm2'],
    'ligero':     ['seno', 'arm2'],
    'productivo': ['seno', 'arm3'],
    'despegue':   ['seno', 'arm2'],
    'clic':       ['ruido_hp'],
    'clic_corto': ['ruido_hp'],
    'click_ui':   ['ruido_hp'],
    'swish':      ['ruido_hp_mod'],
}


def semitonos_a_hz(base_hz, semitonos):
    """Convierte semitonos relativos a frecuencia absoluta."""
    return base_hz * (2.0 ** (semitonos / 12.0))


def envolvente(n, ataque_s, release_s, total_s):
    """Envolvente attack/release para evitar clicks."""
    a = int(ataque_s * SAMPLE_RATE)
    r = int(release_s * SAMPLE_RATE)
    env = [1.0] * n
    for i in range(min(a, n)):
        env[i] = i / max(1, a)
    for i in range(min(r, n)):
        env[n - 1 - i] = min(env[n - 1 - i], i / max(1, r))
    return env


def ruido(n, seed=1234):
    """Ruido blanco determinista (para resultados reproducibles)."""
    estado = seed
    out = []
    for _ in range(n):
        estado = (1103515245 * estado + 12345) & 0x7FFFFFFF
        out.append((estado / 0x3FFFFFFF) - 1.0)
    return out


def ruido_filtrado(n, pasa_bajos=True, seed=7):
    """Ruido con filtro de un polo (pasa-bajos o pasa-altos)."""
    r = ruido(n, seed)
    alpha = 0.35 if pasa_bajos else 0.75
    out = []
    prev = 0.0
    for x in r:
        if pasa_bajos:
            prev = prev + alpha * (x - prev)
            out.append(prev)
        else:
            prev = prev + alpha * (x - prev)
            out.append(x - prev)
    return out


def generar(situacion, spec, verbose=False):
    """Genera las muestras de una situación según su spec del JSON."""
    dur = float(spec.get('duracion_s', 0.3))
    n = int(dur * SAMPLE_RATE)
    notas = spec.get('notas_semitonos', [0])
    orden = spec.get('orden', 'ascendente')
    tono = spec.get('tono', 'calido')
    base_hz = 440.0

    # secuencia de notas: reparte la duración entre las notas
    muestras = [0.0] * n
    por_nota = n // max(1, len(notas))
    for idx, st in enumerate(notas):
        f = semitonos_a_hz(base_hz, st)
        inicio = idx * por_nota
        fin = n if idx == len(notas) - 1 else (idx + 1) * por_nota
        largo = fin - inicio
        env = envolvente(largo, ATAQUE_S, RELEASE_S, dur / len(notas))
        for j in range(largo):
            t = j / SAMPLE_RATE
            seno = math.sin(2 * math.pi * f * t)
            muestras[inicio + j] += AMP_BASE * seno * env[j]

    # timbre adicional según `tono`
    timbres = TIMBRES.get(tono, ['seno'])
    if 'arm2' in timbres:
        for idx, st in enumerate(notas):
            f = semitonos_a_hz(base_hz, st) * 2
            inicio = idx * por_nota
            fin = n if idx == len(notas) - 1 else (idx + 1) * por_nota
            for j in range(fin - inicio):
                t = j / SAMPLE_RATE
                muestras[inicio + j] += AMP_ARMONICO * math.sin(2 * math.pi * f * t)
    if 'arm3' in timbres:
        for idx, st in enumerate(notas):
            f = semitonos_a_hz(base_hz, st) * 3
            inicio = idx * por_nota
            fin = n if idx == len(notas) - 1 else (idx + 1) * por_nota
            for j in range(fin - inicio):
                t = j / SAMPLE_RATE
                muestras[inicio + j] += (AMP_ARMONICO * 0.7) * math.sin(2 * math.pi * f * t)
    if 'ruido_lp' in timbres:
        r = ruido_filtrado(n, pasa_bajos=True, seed=11)
        env = envolvente(n, ATAQUE_S, RELEASE_S, dur)
        for j in range(n):
            muestras[j] += AMP_BASE * 1.2 * r[j] * env[j]
    if 'ruido_hp' in timbres:
        r = ruido_filtrado(n, pasa_bajos=False, seed=5)
        env = envolvente(n, ATAQUE_S, RELEASE_S, dur)
        for j in range(n):
            muestras[j] += AMP_BASE * 0.8 * r[j] * env[j]
    if 'ruido_hp_mod' in timbres:
        r = ruido_filtrado(n, pasa_bajos=False, seed=9)
        env = envolvente(n, ATAQUE_S, RELEASE_S, dur)
        for j in range(n):
            mod = 0.6 + 0.4 * math.sin(2 * math.pi * 6.0 * j / SAMPLE_RATE)
            muestras[j] += AMP_BASE * 0.7 * r[j] * env[j] * mod

    # normalizar a pico objetivo para evitar clipping
    pico = max(abs(s) for s in muestras) if muestras else 0.0
    if pico > 0.85:
        factor = 0.85 / pico
        muestras = [s * factor for s in muestras]
    return muestras


def verificar(muestras, situacion):
    """Verificación numérica: pico, DC, duración, clipping."""
    pico = max(abs(s) for s in muestras)
    dc = sum(muestras) / len(muestras)
    dur = len(muestras) / SAMPLE_RATE
    clip = sum(1 for s in muestras if abs(s) >= 0.999)
    return {
        'situacion': situacion,
        'pico': round(pico, 4),
        'offset_dc': round(dc, 6),
        'duracion_s': round(dur, 3),
        'clipping': clip,
        'ok': clip == 0 and pico <= 0.999 and abs(dc) < 0.01,
    }


def escribir_wav(ruta, muestras):
    with wave.open(ruta, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        frames = b''.join(struct.pack('<h', int(max(-1.0, min(1.0, s)) * 32767)) for s in muestras)
        w.writeframes(frames)


# --- Stings musicales (music_context_matrix.json: 5 momentos, LUFS -18) ---
# Frases cortas de 2-4 s. Misma categoría que `lore_oculto`: se pueden componer
# con acordes y conseguir intención musical. Cada uno tiene carácter distinto y
# una progresión armónica propia.
STINGS = {
    'sting_sello': {
        'acordes': [[0, 4, 7], [5, 9, 12], [7, 11, 14]],
        'dur_acorde': 0.7, 'tono_base': 261.63, 'timbre': 'calido',
    },
    'sting_puzzle': {
        'acordes': [[0, 4, 7], [2, 5, 9], [4, 7, 11], [7, 11, 14]],
        'dur_acorde': 0.35, 'tono_base': 329.63, 'timbre': 'brillante',
    },
    'sting_descubrimiento': {
        'acordes': [[0, 7, 12], [4, 11, 16]],
        'dur_acorde': 1.1, 'tono_base': 293.66, 'timbre': 'etereo',
    },
    'sting_llegada': {
        'acordes': [[0, 4, 7, 11], [5, 9, 12, 16]],
        'dur_acorde': 1.0, 'tono_base': 246.94, 'timbre': 'calido',
    },
    'sting_creditos': {
        'acordes': [[0, 4, 7], [-3, 0, 4], [-5, -1, 2]],
        'dur_acorde': 1.2, 'tono_base': 261.63, 'timbre': 'reflexivo',
    },
}

TIMBRES_STING = {
    'calido':      {'arm2': 0.10, 'arm3': 0.03, 'ataque': 0.05},
    'brillante':   {'arm2': 0.14, 'arm3': 0.08, 'ataque': 0.02},
    'etereo':      {'arm2': 0.06, 'arm3': 0.10, 'ataque': 0.12},
    'reflexivo':   {'arm2': 0.08, 'arm3': 0.02, 'ataque': 0.08},
}


# --- Recetas de feedback (feedback_recetas.json, consumido por feedback_director.gd) ---
# A diferencia de sfx_tones.json (que da notas), estas recetas describen CAPAS que
# hay que mezclar: cada capa es un ruido o tono con su propio carácter. El JSON
# declara las capas; acá está el timbre de cada una y la duración total.
CAPAS_TIMBRE = {
    'crack':          {'tipo': 'ruido_hp', 'dur': 0.08, 'amp': 0.50},
    'roca':           {'tipo': 'ruido_lp', 'dur': 0.22, 'amp': 0.45},
    'eco':            {'tipo': 'tono',     'dur': 0.30, 'amp': 0.12, 'frec': 180.0},
    'thud':           {'tipo': 'tono',     'dur': 0.15, 'amp': 0.40, 'frec': 110.0},
    'arena':          {'tipo': 'ruido_lp', 'dur': 0.18, 'amp': 0.30},
    'tierra_mano':    {'tipo': 'ruido_lp', 'dur': 0.15, 'amp': 0.35},
    'semilla':        {'tipo': 'tono',     'dur': 0.10, 'amp': 0.20, 'frec': 660.0},
    'hoja':           {'tipo': 'ruido_hp', 'dur': 0.12, 'amp': 0.30},
    'arranque':       {'tipo': 'ruido_lp', 'dur': 0.18, 'amp': 0.35},
    'sizzle':         {'tipo': 'ruido_hp_mod', 'dur': 0.45, 'amp': 0.40},
    'vapor':          {'tipo': 'ruido_hp', 'dur': 0.35, 'amp': 0.22},
    'madera_apertura': {'tipo': 'ruido_lp', 'dur': 0.20, 'amp': 0.35},
    'click_cierre':   {'tipo': 'ruido_hp', 'dur': 0.06, 'amp': 0.45},
    'splash':         {'tipo': 'ruido_hp_mod', 'dur': 0.25, 'amp': 0.45},
    'lucha':          {'tipo': 'ruido_hp_mod', 'dur': 0.50, 'amp': 0.35},
    'golpe_roca':     {'tipo': 'ruido_hp', 'dur': 0.07, 'amp': 0.50},
}

# Reverb interior/cueva: cola sintética (unos ms de ruido con decay) que el JSON
# pide en varias recetas. No es IR real, es una aproximación audible.
REVERB = {
    'reverb_interior': {'dur': 0.18, 'amp': 0.14},
    'reverb_cueva':    {'dur': 0.35, 'amp': 0.20},
    '':                {'dur': 0.0,  'amp': 0.0},
}


# --- Momentos narrativos (narrative_sound.json: 35 momentos) ---
# Cada momento trae del JSON: `categoria`, `intensidad` (0.0-1.0) y `duracion_s`.
# De esos tres datos reales sale el arquetipo: la categoría fija la progresión
# armónica y el timbre, y la INTENSIDAD del JSON fija la amplitud (no se inventa
# el volumen: 0.2 es un click de UI, 1.0 es un momento de logro pleno).
ARQUETIPOS = {
    'logro':          {'acordes': [[0, 4, 7], [5, 9, 12], [7, 11, 14]], 'timbre': 'brillante', 'dur_ac': 0.45},
    'descubrimiento': {'acordes': [[0, 7, 12], [4, 11, 16]],            'timbre': 'etereo',    'dur_ac': 0.8},
    'interaccion':    {'acordes': [[0, 5], [2, 7]],                    'timbre': 'mecanico',  'dur_ac': 0.3},
    'personaje':      {'acordes': [[0, 4], [3, 7]],                    'timbre': 'calido',    'dur_ac': 0.7},
    'ui':             {'acordes': [[0, 7]],                            'timbre': 'limpio',    'dur_ac': 0.15},
    'narrativo':      {'acordes': [[0, 5], [-2, 3]],                   'timbre': 'reflexivo', 'dur_ac': 0.9},
    'ambiental':      {'acordes': [[0, 1, 7]],                         'timbre': 'tension',   'dur_ac': 1.4},
}

# Timbres de momentos: armónicos + ataque + presencia de tritono (tensión)
TIMBRES_MOMENTO = {
    'brillante':  {'arm2': 0.14, 'arm3': 0.08, 'ataque': 0.02, 'tritono': False},
    'etereo':     {'arm2': 0.06, 'arm3': 0.10, 'ataque': 0.12, 'tritono': False},
    'mecanico':   {'arm2': 0.10, 'arm3': 0.03, 'ataque': 0.01, 'tritono': False},
    'calido':     {'arm2': 0.10, 'arm3': 0.03, 'ataque': 0.06, 'tritono': False},
    'limpio':     {'arm2': 0.04, 'arm3': 0.0,  'ataque': 0.005, 'tritono': False},
    'reflexivo':  {'arm2': 0.08, 'arm3': 0.02, 'ataque': 0.10, 'tritono': False},
    'tension':    {'arm2': 0.05, 'arm3': 0.06, 'ataque': 0.20, 'tritono': True},
}


def generar_momento(nombre, spec):
    """Compone un momento narrativo desde su categoria, intensidad y duración."""
    cat = spec.get('categoria', 'interaccion')
    intensidad = float(spec.get('intensidad', 0.6))
    dur = float(spec.get('duracion_s', 2.0))
    arq = ARQUETIPOS.get(cat, ARQUETIPOS['interaccion'])
    cfg = TIMBRES_MOMENTO[arq['timbre']]
    acordes = arq['acordes']
    dur_ac = arq['dur_ac']

    # la duración por acorde se ajusta a la que pide el JSON
    dur_ac = dur / max(1, len(acordes))
    n_total = int(dur * SAMPLE_RATE)
    muestras = [0.0] * n_total
    n_ac = n_total // max(1, len(acordes))
    base = 261.63
    # la intensidad del JSON manda la amplitud: 1.0 pleno, 0.2 casi un click
    amp = intensidad * 0.45

    for i_ac, acorde in enumerate(acordes):
        inicio = i_ac * n_ac
        fin = n_total if i_ac == len(acordes) - 1 else inicio + n_ac
        largo = fin - inicio
        env = envolvente(largo, cfg['ataque'], dur_ac * 0.5, dur_ac)
        for j_nota, st in enumerate(acorde):
            f = semitonos_a_hz(base, st)
            delay = int(j_nota * 0.015 * SAMPLE_RATE)
            for j in range(largo):
                if j < delay:
                    continue
                t = (j - delay) / SAMPLE_RATE
                muestras[inicio + j] += amp * math.sin(2 * math.pi * f * t) * env[j]
                if cfg['arm2']:
                    muestras[inicio + j] += amp * cfg['arm2'] * math.sin(2 * math.pi * f * 2 * t) * env[j]
                if cfg['arm3']:
                    muestras[inicio + j] += amp * cfg['arm3'] * math.sin(2 * math.pi * f * 3 * t) * env[j]
        # timbre de tensión: el tritono suena por encima, disonante a propósito
        if cfg['tritono']:
            f_tri = semitonos_a_hz(base, 6)
            for j in range(largo):
                t = j / SAMPLE_RATE
                muestras[inicio + j] += amp * 0.35 * math.sin(2 * math.pi * f_tri * t) * env[j]

    pico = max(abs(s) for s in muestras) if muestras else 0.0
    if pico > 0.85:
        factor = 0.85 / pico
        muestras = [s * factor for s in muestras]
    return muestras


def generar_receta(nombre, spec):
    """Mezcla las capas que declara feedback_recetas.json más la cola de reverb."""
    capas = spec.get('capas', [])
    reverb_id = spec.get('interior_capa', '')
    dur_total = max(CAPAS_TIMBRE[c]['dur'] for c in capas if c in CAPAS_TIMBRE) if capas else 0.3
    dur_total += REVERB.get(reverb_id, {'dur': 0})['dur']
    n = int(dur_total * SAMPLE_RATE)
    muestras = [0.0] * n

    for nombre_capa in capas:
        cfg = CAPAS_TIMBRE.get(nombre_capa)
        if cfg is None:
            continue
        d = cfg['dur']
        largo = int(d * SAMPLE_RATE)
        env = envolvente(largo, 0.004, d * 0.6, d)
        amp = cfg['amp']
        if cfg['tipo'] == 'ruido_lp':
            r = ruido_filtrado(largo, pasa_bajos=True, seed=hash(nombre_capa) % 9999)
            for j in range(largo):
                muestras[j] += amp * r[j] * env[j]
        elif cfg['tipo'] == 'ruido_hp':
            r = ruido_filtrado(largo, pasa_bajos=False, seed=hash(nombre_capa) % 9999)
            for j in range(largo):
                muestras[j] += amp * r[j] * env[j]
        elif cfg['tipo'] == 'ruido_hp_mod':
            r = ruido_filtrado(largo, pasa_bajos=False, seed=hash(nombre_capa) % 9999)
            for j in range(largo):
                mod = 0.65 + 0.35 * math.sin(2 * math.pi * 7.0 * j / SAMPLE_RATE)
                muestras[j] += amp * r[j] * env[j] * mod
        elif cfg['tipo'] == 'tono':
            f = cfg.get('frec', 220.0)
            for j in range(largo):
                t = j / SAMPLE_RATE
                muestras[j] += amp * math.sin(2 * math.pi * f * t) * env[j]

    # cola de reverb: ruido con decay largo, entra cuando terminan las capas
    rv = REVERB.get(reverb_id)
    if rv and rv['dur'] > 0:
        ini = int(max(CAPAS_TIMBRE[c]['dur'] for c in capas if c in CAPAS_TIMBRE) * SAMPLE_RATE) if capas else 0
        largo = int(rv['dur'] * SAMPLE_RATE)
        r = ruido_filtrado(largo, pasa_bajos=True, seed=4242)
        for j in range(largo):
            if ini + j >= n:
                break
            decay = (1.0 - j / largo) ** 2
            muestras[ini + j] += rv['amp'] * r[j] * decay

    pico = max(abs(s) for s in muestras) if muestras else 0.0
    if pico > 0.85:
        factor = 0.85 / pico
        muestras = [s * factor for s in muestras]
    return muestras


def generar_sting(nombre):
    """Compone un sting: progresión de acordes con envolvente por acorde."""
    spec = STINGS[nombre]
    acordes = spec['acordes']
    dur_ac = spec['dur_acorde']
    base = spec['tono_base']
    cfg = TIMBRES_STING[spec['timbre']]

    n_total = int(dur_ac * len(acordes) * SAMPLE_RATE)
    muestras = [0.0] * n_total
    n_ac = int(dur_ac * SAMPLE_RATE)

    for i_ac, acorde in enumerate(acordes):
        inicio = i_ac * n_ac
        fin = n_total if i_ac == len(acordes) - 1 else inicio + n_ac
        largo = fin - inicio
        env = envolvente(largo, cfg['ataque'], dur_ac * 0.55, dur_ac)
        # las notas del acorde entran escalonadas (arpegio sutil)
        for j_nota, semitono in enumerate(acorde):
            f = semitonos_a_hz(base, semitono)
            delay = int(j_nota * 0.018 * SAMPLE_RATE)
            for j in range(largo):
                if j < delay:
                    continue
                t = (j - delay) / SAMPLE_RATE
                muestras[inicio + j] += AMP_BASE * 0.55 * math.sin(2 * math.pi * f * t) * env[j]
                if cfg['arm2']:
                    muestras[inicio + j] += AMP_BASE * cfg['arm2'] * math.sin(2 * math.pi * f * 2 * t) * env[j]
                if cfg['arm3']:
                    muestras[inicio + j] += AMP_BASE * cfg['arm3'] * math.sin(2 * math.pi * f * 3 * t) * env[j]

    pico = max(abs(s) for s in muestras) if muestras else 0.0
    if pico > 0.85:
        factor = 0.85 / pico
        muestras = [s * factor for s in muestras]
    return muestras


def generar_lore_oculto():
    """Sonido de misterio para `lore_oculto` (momentos de narrative_sound.json).

    Spec de origen (narrative_sound.json v1.2.0, agregado en commit 47353d0):
        {"nombre": "Lore Oculto Encontrado",
         "descripcion": "Sonido de misterio al encontrar una pieza de lore oculta",
         "intensidad": 0.9, "leitmotif": "", "duracion_s": 2.0,
         "categoria": "descubrimiento"}

    Diseño propio (no viene de sfx_tones.json): intervalo suspendido (4ª aumentada,
    el tritono, que suena irresuelto = misterio), dos capas — un seno grave
    sostenido y una nota que sube una 5ª — con ataque largo y release muy largo.
    """
    dur = 2.0
    n = int(dur * SAMPLE_RATE)
    base = 220.0          # A3, registro grave
    tritono = base * (2.0 ** (6 / 12.0))   # 4a aumentada sobre A3
    quinta = base * 1.5                    # 5ª justa (resolución que no llega)
    muestras = [0.0] * n
    # capa 1: seno grave sostenido con vibración lenta (tensión)
    for j in range(n):
        t = j / SAMPLE_RATE
        vib = 1.0 + 0.02 * math.sin(2 * math.pi * 5.5 * t)
        muestras[j] += 0.30 * vib * math.sin(2 * math.pi * base * t)
    # capa 2: el tritono, entra al 25% y se mantiene
    inicio = int(0.25 * n)
    for j in range(inicio, n):
        t = j / SAMPLE_RATE
        muestras[j] += 0.22 * math.sin(2 * math.pi * tritono * t)
    # capa 3: la quinta aparece al final y se corta (la resolución que no llega)
    inicio_q = int(0.80 * n)
    for j in range(inicio_q, n):
        t = j / SAMPLE_RATE
        muestras[j] += 0.16 * math.sin(2 * math.pi * quinta * t)
    # envolvente: ataque largo, release muy largo (nada de click metálico)
    env = envolvente(n, 0.25, 0.6, dur)
    muestras = [muestras[j] * env[j] for j in range(n)]
    # normalizar
    pico = max(abs(s) for s in muestras)
    if pico > 0.85:
        f = 0.85 / pico
        muestras = [s * f for s in muestras]
    return muestras


# Variaciones: para que varios disparos seguidos no suenen idénticos.
# Cada variación desplaza el tono base y rota ligeramente el timbre.
VARIACION_SEMITONOS = [-1, 1, -2, 2]      # cicla según índice
VARIACION_AMP = [1.0, 0.92, 1.05, 0.88]   # cicla según índice


def generar_variacion(situacion, spec, indice):
    """Igual que `generar` pero con desplazamiento de tono y amplitud.

    El propósito de las variaciones en el juego es que dos disparos seguidos no
    suenen clonados. Se logra movando el tono unos semitonos y variando la
    amplitud; la receta base (notas, orden, timbre) se conserva.
    """
    dur = float(spec.get('duracion_s', 0.3))
    n = int(dur * SAMPLE_RATE)
    notas = list(spec.get('notas_semitonos', [0]))
    orden = spec.get('orden', 'ascendente')
    tono = spec.get('tono', 'calido')
    base_hz = 440.0
    desplazamiento = VARIACION_SEMITONOS[indice % len(VARIACION_SEMITONOS)]
    amp = VARIACION_AMP[indice % len(VARIACION_AMP)] * AMP_BASE

    muestras = [0.0] * n
    por_nota = n // max(1, len(notas))
    for idx, st in enumerate(notas):
        f = semitonos_a_hz(base_hz, st + desplazamiento)
        inicio = idx * por_nota
        fin = n if idx == len(notas) - 1 else (idx + 1) * por_nota
        largo = fin - inicio
        env = envolvente(largo, ATAQUE_S, RELEASE_S, dur / len(notas))
        for j in range(largo):
            t = j / SAMPLE_RATE
            muestras[inicio + j] += amp * math.sin(2 * math.pi * f * t) * env[j]

    timbres = TIMBRES.get(tono, ['seno'])
    if 'arm2' in timbres or 'arm3' in timbres:
        mult = 3 if 'arm3' in timbres else 2
        for idx, st in enumerate(notas):
            f = semitonos_a_hz(base_hz, st + desplazamiento) * mult
            inicio = idx * por_nota
            fin = n if idx == len(notas) - 1 else (idx + 1) * por_nota
            for j in range(fin - inicio):
                t = j / SAMPLE_RATE
                muestras[inicio + j] += (amp * AMP_ARMONICO / AMP_BASE) * math.sin(2 * math.pi * f * t)
    if 'ruido_lp' in timbres:
        r = ruido_filtrado(n, pasa_bajos=True, seed=11 + indice)
        env = envolvente(n, ATAQUE_S, RELEASE_S, dur)
        for j in range(n):
            muestras[j] += amp * 1.2 * r[j] * env[j]
    if 'ruido_hp' in timbres:
        r = ruido_filtrado(n, pasa_bajos=False, seed=5 + indice)
        env = envolvente(n, ATAQUE_S, RELEASE_S, dur)
        for j in range(n):
            muestras[j] += amp * 0.8 * r[j] * env[j]
    if 'ruido_hp_mod' in timbres:
        r = ruido_filtrado(n, pasa_bajos=False, seed=9 + indice)
        env = envolvente(n, ATAQUE_S, RELEASE_S, dur)
        for j in range(n):
            mod = 0.6 + 0.4 * math.sin(2 * math.pi * 6.0 * j / SAMPLE_RATE)
            muestras[j] += amp * 0.7 * r[j] * env[j] * mod

    pico = max(abs(s) for s in muestras) if muestras else 0.0
    if pico > 0.85:
        factor = 0.85 / pico
        muestras = [s * factor for s in muestras]
    return muestras


# Timbres por MATERIAL, derivados de datos reales del proyecto:
#   - herramienta: los 4 tiers de data/herramientas/tiers_config.json
#     (T1_COBRE, T2_HIERRO, T3_ORO, T4_CRISTAL)
#   - abrir: los materiales que pide sfx_tones.json (madera, cerrojo)
# La caracterización sigue la dureza/brijeza física de cada material: el cobre es
# mate y grave, el hierro duro, el oro brillante, el cristal vidrioso y agudo;
# la madera es seca y corta, el cerrojo metálico y con resorté.
TIMBRES_MATERIAL = {
    'cobre':   {'base_offset': -5, 'arm': 0.08, 'ruido_hp': 0.15, 'dur_mult': 1.1},
    'hierro':  {'base_offset': -2, 'arm': 0.14, 'ruido_hp': 0.45, 'dur_mult': 1.0},
    'oro':     {'base_offset': 1,  'arm': 0.20, 'ruido_hp': 0.25, 'dur_mult': 1.05},
    'cristal': {'base_offset': 7,  'arm': 0.05, 'ruido_hp': 0.60, 'dur_mult': 0.9},
    'madera':  {'base_offset': -3, 'arm': 0.05, 'ruido_lp': 0.55, 'ruido_hp': 0.20, 'dur_mult': 0.9},
    'cerrojo': {'base_offset': 0,  'arm': 0.16, 'ruido_hp': 0.50, 'dur_mult': 1.0},
}

# Superficies reales de data/audio/sfx_surfaces.json (para `saltar`)
SUPERFICIES = ['hierba', 'madera', 'piedra', 'tierra', 'nieve', 'arena', 'agua', 'metal', 'cristal']


def generar_por_material(situacion, spec, material):
    """Sonido con timbre característico del material.

    Usa TIMBRES_MATERIAL para desplazar el tono base y mezclar armónicos y ruido
    según la dureza del material. La receta base (notas, orden, duración) sale
    del JSON; solo el carácter tímbrico depende del material.
    """
    cfg = TIMBRES_MATERIAL.get(material, {})
    dur = float(spec.get('duracion_s', 0.3)) * cfg.get('dur_mult', 1.0)
    n = int(dur * SAMPLE_RATE)
    notas = list(spec.get('notas_semitonos', [0]))
    base_hz = 440.0
    offset = cfg.get('base_offset', 0)
    arm = cfg.get('arm', AMP_ARMONICO / AMP_BASE)
    ruido_hp = cfg.get('ruido_hp', 0.0)
    ruido_lp = cfg.get('ruido_lp', 0.0)

    muestras = [0.0] * n
    por_nota = n // max(1, len(notas))
    for idx, st in enumerate(notas):
        f = semitonos_a_hz(base_hz, st + offset)
        inicio = idx * por_nota
        fin = n if idx == len(notas) - 1 else (idx + 1) * por_nota
        largo = fin - inicio
        env = envolvente(largo, ATAQUE_S, RELEASE_S, dur / len(notas))
        for j in range(largo):
            t = j / SAMPLE_RATE
            muestras[inicio + j] += AMP_BASE * math.sin(2 * math.pi * f * t) * env[j]
            if arm:
                muestras[inicio + j] += AMP_BASE * arm * math.sin(2 * math.pi * f * 2 * t)

    env_total = envolvente(n, ATAQUE_S, RELEASE_S, dur)
    if ruido_hp:
        r = ruido_filtrado(n, pasa_bajos=False, seed=13)
        for j in range(n):
            muestras[j] += AMP_BASE * ruido_hp * r[j] * env_total[j]
    if ruido_lp:
        r = ruido_filtrado(n, pasa_bajos=True, seed=17)
        for j in range(n):
            muestras[j] += AMP_BASE * ruido_lp * r[j] * env_total[j]

    pico = max(abs(s) for s in muestras) if muestras else 0.0
    if pico > 0.85:
        factor = 0.85 / pico
        muestras = [s * factor for s in muestras]
    return muestras


# Materiales por situación: sale de datos, no es invención.
#   herramienta -> los 4 tiers de tiers_config.json (por_tipo: true)
#   abrir       -> los materiales que declara sfx_tones.json
MATERIALES = {
    'herramienta': ['cobre', 'hierro', 'oro', 'cristal'],
    'abrir': ['madera', 'cerrojo'],
}


def nombres_variaciones(situacion, spec):
    """Devuelve los nombres de archivo de cada variación de una situación.

    Orden de especificidad: material/tipo nombrado gana sobre el número genérico,
    porque un sonido de herramienta de COBRE no es intercambiable con uno de
    CRISTAL, mientras que equipar_1/equipar_2 sí son variaciones genéricas.
    """
    if situacion in MATERIALES:
        return ['%s_%s.wav' % (situacion, m) for m in MATERIALES[situacion]]
    n = spec.get('variaciones')
    if n:
        return ['%s_%d.wav' % (situacion, i + 1) for i in range(n)]
    etapas = spec.get('etapas')
    if etapas:
        return ['%s_%s.wav' % (situacion, e) for e in etapas]
    tipos = spec.get('tipos')
    if tipos:
        return ['%s_%s.wav' % (situacion, t) for t in tipos]
    if spec.get('varias_por_superficie'):
        # superficies reales de sfx_surfaces.json
        return ['%s_%s.wav' % (situacion, s) for s in SUPERFICIES]
    rangos = spec.get('rangos_altura')
    if rangos:
        return ['%s_altura%d.wav' % (situacion, i + 1) for i in range(rangos)]
    return []


def renderizar_variacion(situacion, spec, nombre_archivo, indice):
    """Elige el renderizador correcto según el tipo de variación."""
    stem = nombre_archivo[:-4]
    if '_' in stem:
        sufijo = stem.split('_', 1)[1]
        if sufijo in TIMBRES_MATERIAL or sufijo in SUPERFICIES:
            return generar_por_material(situacion, spec, sufijo)
    return generar_variacion(situacion, spec, indice)


def main(solo=None, variaciones=False):
    with io.open(RUTA_TONES, encoding='utf-8') as fh:
        tones = json.load(fh)

    os.makedirs(SALIDA, exist_ok=True)
    claves = list(tones.keys()) if solo is None else [k for k in solo if k in tones]

    reporte = []
    for k in claves:
        spec = tones[k]
        muestras = generar(k, spec)
        ruta = os.path.join(SALIDA, k + '.wav')
        escribir_wav(ruta, muestras)
        v = verificar(muestras, k)
        v['archivo'] = ruta.replace(os.sep, '/')
        reporte.append(v)
        estado = 'OK' if v['ok'] else 'REVISAR'
        print('%-22s pico=%.3f  dc=%+.5f  dur=%.2fs  clip=%d  [%s]'
              % (k, v['pico'], v['offset_dc'], v['duracion_s'], v['clipping'], estado))

    if variaciones:
        print()
        print('--- variaciones ---')
        for k in claves:
            spec = tones[k]
            nombres = nombres_variaciones(k, spec)
            for i, nombre in enumerate(nombres):
                m = renderizar_variacion(k, spec, nombre, i)
                ruta = os.path.join(SALIDA, nombre)
                escribir_wav(ruta, m)
                v = verificar(m, nombre.replace('.wav', ''))
                v['archivo'] = ruta.replace(os.sep, '/')
                reporte.append(v)
                estado = 'OK' if v['ok'] else 'REVISAR'
                print('%-22s pico=%.3f  dc=%+.5f  dur=%.2fs  clip=%d  [%s]'
                      % (nombre, v['pico'], v['offset_dc'], v['duracion_s'], v['clipping'], estado))

    # stings musicales de music_context_matrix.json (5 momentos)
    if solo is None or any(s in solo for s in STINGS):
        print()
        print('--- stings musicales ---')
        for nombre in STINGS:
            if solo is not None and nombre not in solo:
                continue
            m = generar_sting(nombre)
            ruta = os.path.join(SALIDA, nombre + '.wav')
            escribir_wav(ruta, m)
            v = verificar(m, nombre)
            v['archivo'] = ruta.replace(os.sep, '/')
            reporte.append(v)
            estado = 'OK' if v['ok'] else 'REVISAR'
            print('%-22s pico=%.3f  dc=%+.5f  dur=%.2fs  clip=%d  [%s]'
                  % (nombre, v['pico'], v['offset_dc'], v['duracion_s'], v['clipping'], estado))

    # momentos narrativos de narrative_sound.json
    try:
        with io.open('game/isla-ancestral/data/audio/narrative_sound.json', encoding='utf-8') as fh:
            narrativa = json.load(fh).get('momentos', {})
    except OSError:
        narrativa = {}
    pendientes = [k for k in narrativa if k not in [x[:-4] for x in os.listdir(SALIDA)]]
    if pendientes:
        print()
        print('--- momentos narrativos (narrative_sound.json) ---')
        for nombre in pendientes:
            if solo is not None and nombre not in solo:
                continue
            m = generar_momento(nombre, narrativa[nombre])
            ruta = os.path.join(SALIDA, nombre + '.wav')
            escribir_wav(ruta, m)
            v = verificar(m, nombre)
            v['archivo'] = ruta.replace(os.sep, '/')
            reporte.append(v)
            estado = 'OK' if v['ok'] else 'REVISAR'
            print('%-22s pico=%.3f  dc=%+.5f  dur=%.2fs  clip=%d  [%s]'
                  % (nombre, v['pico'], v['offset_dc'], v['duracion_s'], v['clipping'], estado))

    # recetas de feedback_director.gd (feedback_recetas.json)
    try:
        with io.open('game/isla-ancestral/data/audio/feedback_recetas.json', encoding='utf-8') as fh:
            recetas = json.load(fh)
    except OSError:
        recetas = {}
    if recetas:
        print()
        print('--- recetas de feedback (feedback_recetas.json) ---')
        for nombre, spec in recetas.items():
            if solo is not None and nombre not in solo:
                continue
            m = generar_receta(nombre, spec)
            ruta = os.path.join(SALIDA, nombre + '.wav')
            escribir_wav(ruta, m)
            v = verificar(m, nombre)
            v['archivo'] = ruta.replace(os.sep, '/')
            reporte.append(v)
            estado = 'OK' if v['ok'] else 'REVISAR'
            print('%-22s pico=%.3f  dc=%+.5f  dur=%.2fs  clip=%d  [%s]'
                  % (nombre, v['pico'], v['offset_dc'], v['duracion_s'], v['clipping'], estado))

    # lore_oculto: momento narrativo de M150, no está en sfx_tones.json
    if solo is None or 'lore_oculto' in solo:
        m = generar_lore_oculto()
        ruta = os.path.join(SALIDA, 'lore_oculto.wav')
        escribir_wav(ruta, m)
        v = verificar(m, 'lore_oculto')
        v['archivo'] = ruta.replace(os.sep, '/')
        reporte.append(v)
        estado = 'OK' if v['ok'] else 'REVISAR'
        print('%-16s pico=%.3f  dc=%+.5f  dur=%.2fs  clip=%d  [%s]'
              % ('lore_oculto', v['pico'], v['offset_dc'], v['duracion_s'], v['clipping'], estado))

    malos = [r for r in reporte if not r['ok']]
    print()
    print('generados: %d | con problemas: %d' % (len(reporte), len(malos)))
    return reporte


if __name__ == '__main__':
    import sys
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    con_vars = '--variaciones' in sys.argv[1:]
    main(args if args else None, variaciones=con_vars)
