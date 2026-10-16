import os, re, sys, json
sys.stdout.reconfigure(encoding='utf-8')
base = r'Mensajes entre modelos'
order = ['atria-dawn-s2','step-5-kilocode','Step-5-WorkBuddy','agnes-3-flash','Ling-3.1-Flash','DeepSeek-V4.1-Flash','Hy3','atria-dawn-s3','atria-dawn','kimi-k3','Claude-Haiku-5.5','muse-spark-1.3-contributor','GLM-5.3-Flash','space-bunny-alpha','DS-V4.1-Flash-Opencode']
state_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '.ver_mensajes_vistos.json')

# ============================================================
# REGLA DE NUMERACION — LEER ANTES DE ESCRIBIR CUALQUIER MENSAJE
# ============================================================
# PROHIBIDO usar reservar_mensaje.py (bug: regex matchea años).
# PROHIBIDO borrar el pool solo para "verificar" (consume numeros).
#
# PASO 1: Leer el pool (NUMEROS_DISPONIBLES.txt) — NO modificar.
# PASO 2: Verificar en DISCO que el numero NO exista ya.
#         Buscar archivos que empiecen con "{num}-" en la carpeta.
# PASO 3: Si existe en disco, tomar el SIGUIENTE del pool.
# PASO 4: Recién ahí BORRAR el numero del pool y escribir el archivo.
#
# Ejemplo de uso correcto:
#   num = elegir_numero_seguro('step-5-kilocode')
#   if num:
#       open(f'{canal}/{num}-fecha-titulo.md','w').write(contenido)
# ============================================================

def elegir_numero_seguro(canal):
    """Lee el pool SIN modificarlo, verifica contra disco, devuelve el numero seguro."""
    pool_path = os.path.join(base, canal, 'NUMEROS_DISPONIBLES.txt')
    canal_dir = os.path.join(base, canal)
    if not os.path.exists(pool_path):
        print(f'ERROR: no existe pool de {canal}')
        return None
    lineas = [l.strip() for l in open(pool_path, encoding='utf-8').read().splitlines() if l.strip()]
    # numeros que ya existen en disco (recursivo: los mensajes pueden estar en
    # subcarpetas de rango 0-99/100-199/... — orden del fundador 2026-10-15)
    existentes = set()
    for raiz, _dirs, files in os.walk(canal_dir):
        for f in files:
            if f[0].isdigit() and '-' in f:
                nn = f.split('-')[0]
                if nn.isdigit() and int(nn) < 2026:
                    existentes.add(nn)
    # elegir el primero del pool que NO exista en disco
    for l in lineas:
        if l not in existentes:
            return l
    print(f'ERROR: todos los numeros de {canal} ya existen en disco')
    return None

def borrar_numero_pool(canal, num):
    """Borra el numero del pool — SOLO llamar despues de confirmar la escritura."""
    pool_path = os.path.join(base, canal, 'NUMEROS_DISPONIBLES.txt')
    lineas = [l.strip() for l in open(pool_path, encoding='utf-8').read().splitlines() if l.strip()]
    nuevas = [l for l in lineas if l != num]
    open(pool_path, 'w', encoding='utf-8', newline='\n').write('\n'.join(nuevas) + '\n')

def escribir_mensaje(canal, sufijo_fecha_titulo, contenido):
    """Escribe un mensaje con numeracion segura. Retorna el numero usado o None.
    SIEMPRE usar esta funcion. NUNCA escribir archivos a mano con numero inventado."""
    num = elegir_numero_seguro(canal)
    if num is None:
        return None
    nombre = f'{num}-{sufijo_fecha_titulo}'
    path = os.path.join(base, canal, nombre)
    open(path, 'w', encoding='utf-8', newline='\n').write(contenido)
    borrar_numero_pool(canal, num)
    print(f'OK {canal}/{num}')
    return num
# ============================================================
# Estado por NOMBRES de archivo (robusto a renames y a contadores ciegos como el tren
# de agnes: un archivo es "nuevo" si su nombre no fue listado en una corrida anterior).
vistos = {}
if os.path.exists(state_path):
    try:
        with open(state_path, encoding='utf-8') as f:
            vistos = json.load(f)
    except Exception as e:
        print(f'AVISO: no pude leer estado ({e}); arranco de cero')
        vistos = {}

found = False
total = 0
estado_nuevo = dict(vistos)
for c in order:
    path = os.path.join(base, c)
    if not os.path.isdir(path): continue
    files = []
    for raiz, _dirs, fnames in os.walk(path):
        for f in fnames:
            if f.endswith('.md') and re.match(r'^\d+-', f):
                files.append(os.path.join(raiz, f))
    files.sort(key=lambda p: int(os.path.basename(p).split('-')[0]))
    seen = set(vistos.get(c, []))
    keys = []
    for fp in files:
        key = os.path.relpath(fp, base).replace('\\', '/')
        keys.append(key)
        if key in seen:
            continue
        found = True
        total += 1
        try:
            sz = os.path.getsize(fp)
            content = open(fp, encoding='utf-8').read()
        except OSError as e:
            print(f'NUEVO [{c}]: {os.path.basename(fp)} (INACCESIBLE — {e.__class__.__name__}; probable limite de path Windows)')
            continue
        is_template = 'PLANTILLA RESERVADA' in content and '<cuerpo del mensaje aca>' in content
        tag = ' [PLANTILLA]' if is_template else ''
        print(f'NUEVO [{c}]: {os.path.basename(fp)} ({sz}b){tag}')
    estado_nuevo[c] = keys
with open(state_path, 'w', encoding='utf-8') as f:
    json.dump(estado_nuevo, f, ensure_ascii=False, indent=1)
if not found:
    print('SIN NUEVOS')
else:
    print(f'(total nuevos: {total})')
