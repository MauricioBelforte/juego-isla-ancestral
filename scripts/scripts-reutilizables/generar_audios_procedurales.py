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


def main(solo=None):
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
        print('%-16s pico=%.3f  dc=%+.5f  dur=%.2fs  clip=%d  [%s]'
              % (k, v['pico'], v['offset_dc'], v['duracion_s'], v['clipping'], estado))

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
    args = sys.argv[1:]
    main(args if args else None)
