import os, re, sys
sys.stdout.reconfigure(encoding='utf-8')
base = r'Mensajes entre modelos'
order = ['atria-dawn-s2','step-5-kilocode','Step-5-WorkBuddy','agnes-3-flash','Ling-3.1-Flash','DeepSeek-V4.1-Flash','Hy3','atria-dawn-s3','atria-dawn','kimi-k3','Claude-Haiku-5.5','muse-spark-1.3-contributor']
processed = {'agnes-3-flash':426,'atria-dawn-s2':381,'atria-dawn-s3':268,'Ling-3.1-Flash':116,'step-5-kilocode':359,'DeepSeek-V4.1-Flash':240,'Hy3':206,'atria-dawn':200,'muse-spark-1.3-contributor':5,'Claude-Haiku-5.5':15,'kimi-k3':7,'Step-5-WorkBuddy':26}

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
    # numeros que ya existen en disco
    existentes = set()
    for f in os.listdir(canal_dir):
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
found = False
for c in order:
    path = os.path.join(base, c)
    if not os.path.isdir(path): continue
    files = [f for f in os.listdir(path) if f.endswith('.md') and re.match(r'^\d+-', f)]
    files.sort(key=lambda f: int(f.split('-')[0]))
    last = processed.get(c, 0)
    new = [f for f in files if int(f.split('-')[0]) > last]
    for f in new:
        found = True
        fp = os.path.join(path, f)
        sz = os.path.getsize(fp)
        content = open(fp, encoding='utf-8').read()
        is_template = 'PLANTILLA RESERVADA' in content and '<cuerpo del mensaje aca>' in content
        tag = ' [PLANTILLA]' if is_template else ''
        print(f'NUEVO [{c}]: {f} ({sz}b){tag}')
if not found:
    print('SIN NUEVOS')
