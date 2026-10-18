# CÓMO CORREGIR LA NUMERACIÓN DE LOS MENSAJES — MÉTODO DEFINITIVO (5 pasos)


⚠️ TRANSPARENCIA de la primera corrida: este archivo fue generado DESPUÉS de ejecutar la corrección en DS-V4.1-Flash-Opencode y Step-5-WorkBuddy (inversión del orden natural — el método lo ejecutaron los scripts primero). Su contenido SÍ refleja la corrección. La próxima re-corr VIENE ESTE ARCHIVO COMO GUÍA PREVIA (antes de correr) — no post-hoc.
**Modelo:** GLM-5.3-Flash-Director (GLM-5.3-Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-18 22:49
**Origen:** directiva del fundador (22:49) — la corrección de la numeración de los canales de mensajes, aplicado en DS-V4.1-Flash-Opencode y Step-5-WorkBuddy como prototype.
**Regla permanente del fundador:** "no podés errar en eso — corregí los cálculos".

## LOS 5 PASOS CORRECTOS

### PASO 1 — EVALUAR EL FORMATO CORRECTO

Objetivo: qué está MAL y qué está BIEN (el diagnóstico de la numeración del canal).

- Listar TODO archivo `.md` con prefijo numérico (1-3 dígitos, con o sin padding) con `re.match(r'^(\d{1,3})-(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})-(.+)\.md$', f)`.
- Ordenar por el **timestamp del nombre** (la parte `AAAA-MM-DD_HH-MM-SS`), no por el prefijo numeró.
- Los formatos válidos:
  - `[ext_resource CompressedTexture2D]` (no aplica — mensajería, no Godot).
  - El prefijo de **3 dígitos con zero-padding** (`001-`, `002-` … `NNN-`).
  - La secuencia consecutiva 001, 002, 003 … sin huecos ni saltos.
  - El título interno `# NNN` = el prefijo del nombre (sin desfase).
- Los formatos INVÁLIDOS (corregibles):
  - Los prefijos sin padding (`13-`, `16-`, `60-`, `85-`, `3-`, `5-`).
  - Saltos de números (los huecos → los N mensajes que no existen).
  - Duplicados (dos archivos con el mismo número).
  - El título interno `# NNN` con números ≠ prefijo.
  - El orden NO cronológico (los mensajes fuera de secuencia por fecha).

### PASO 2 — RENUMERAR LOS NÚMEROS CONSECUTIVOS (por fecha)

Objetivo: cada archivo queda con el NÚMERO CONSECUTIVO por orden de fecha (1, 2, 3 … N).

**El método de 2 pasadas (para evitar colisiones de nombre):**

```python
# PASADA 2a: TODOS los .md → __tmp__ (para no colisionar)
for f in sorted(os.listdir(D)):
    if f.endswith('.md') and not f.startswith('__tmp__'):
        os.rename(lp(os.path.join(D, f)), lp(os.path.join(D, '__tmp__' + f)))

# PASADA 2b: los __tmp__ ordenados por ts → nombres finales consecutivos
tmps = []
for f in sorted(os.listdir(D)):
    m = re.match(r'^__tmp__(\d{1,3})-(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})-(.+)\.md$', f)
    if m:
        tmps.append((m.group(2), m.group(3), f))  # sort por ts
tmps.sort()
for idx, (ts, resto, f) in enumerate(tmps, 1):
    os.rename(lp(os.path.join(D, f)), lp(os.path.join(D, '%03d-%s-%s.md' % (idx, ts, resto))))
```

⚠️ **En Windows**: usar `\\?\` + abs_path para archivos con nombres largos (el MAX_PATH 261 — el caso que rompió los renames del canal DS-OC y Step-5).

### PASO 3 — CORREGIR LOS NÚMEROS DENTRO DE LOS ARCHIVOS

Objetivo: cada mensaje lleva el título interno con SU NÚMERO — la numeración del cuerpo queda antigua tras el rename.

```python
# Título interno: `# NNN — temática` → `# NNN-nuevo — temática`
for f in sorted(os.listdir(D)):
    m = re.match(r'^(\d{3})-', f)
    if not m or f.endswith('.md') is False:
        continue
    n = int(m.group(1))
    p = os.path.join(D, f)
    t = io.open(p, encoding='utf-8', errors='strict').read()
    m2 = re.match(r'^# (\d+)', t)
    if m2 and int(m2.group(1)) != n:
        t_n = re.sub(r'^# \d+', '# %d' % n, t, count=1)
        io.open(p, 'w', encoding='utf-8', newline='\n').write(t_n)
        io.open(p, 'rb').read().decode('utf-8', errors='strict')
```

⚠️ El campo `Responde a:` que cita `— NNN` del número viejo: **quedará con la numeración antigua** (es la cita de acuse histórica — no se cambia retroactivamente por el fundador: el riel queda con la traza del original).

### PASO 4 — CORREGIR EL `NUMEROS_DISPONIBLES.TXT`

Objetivo: el pool del canal queda con 100 números consecutivos desde max+1.

```python
# El pool: max + 1 hasta max + 100 (100 números consecutivos)
mx = max(seq)
pool = os.path.join(D, 'NUMEROS_DISPONIBLES.txt')
io.open(pool, 'w', encoding='utf-8', newline='\n').write('\n'.join(str(n) for n in range(mx + 1, mx + 101)) + '\n')
io.open(pool, 'rb').read().decode('utf-8', errors='strict')
```

- El pool queda con 100 números **SIN huecos**, consecutivos desde max+1.

⚠️ **REGLA DEL FUNDADOR (2026-10-18 23:03) — REVISAR SIEMPRE tras cualquier asignación o corrección:**

**El pool debe QUEDAR con 100 números consecutivos SIN huecos y SIN números ya usados.** Cada vez que:
1. Asignás un número (con el helper o a mano) → **REMUEVELO del pool** (era el caso del 76 del informe 078 que quedó disponible aún usado).
2. Corregís la numeración de un canal → **VERIFICÁ que el pool NO contenga ningún número ≤ max de los archivos del canal** (los usados se quitan).
3. Consumís un número de PRUEBA (sin escribir el archivo real) → **DEVOLVELO al pool** (el riel de los 77-78 de prueba del Step-5 se devolvieron).
4. El pool pierde números → **AGREGA al FINAL** para que queden 100 consecutivos (max+1 a max+100).
5. El pool queda **sin BOM** (Python UTF-8, LF, no CRLF, no Set-Content).

Las 5 reglas del pool quedan como el cierre del PASO 4 — **revisar el pool SIEMPRE** después de cada asignación, corrección o consume de prueba.
- **El puntero `.ultima-revision-<agente>.txt` = max** (el máximo del canal, sin BOM).

### PASO 5 — BUSCAR REFERENCIAS ANTIGUAS A LOS NÚMEROS VIEJOS

Objetivo: los LOGS y documentos que citan el número de mensaje viejo quedan con la referencia desalineada — se corrigieren con el mapa.

**El método (2 fuentes de mapas):**
1. Los **renames del `git log --name-status`** del commit de renumeración (R100% con old/new paths).
2. El **mapa ts→num** del inventario (el mismo ts en old y new).

```python
import subprocess as sp
# old_map: los archivos viejos con los números viejos del bosque del 4d1ee65
out = sp.run(['git', 'ls-tree', '-r', '--name-only', '<commit-antes-del-renumerado>'],
             capture_output=True, cwd='.')
old_map = {}
for l in out.stdout.decode('utf-8', errors='strict').splitlines():
    m = re.match(r'^.*?DS-V4\.1-Flash-Opencode/(\d{1,3})-(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})-', l)
    if m:
        old_map[m.group(2)] = int(m.group(1))
# new_map: los archivos actuales con los números nuevos
# vmap: old_num → new_num (por ts común)

# aplicar en los archivos de LOGS y DOCUMENTACION que citan NNN viejo:
for f in glob.glob(os.path.join('Logs', '*.md')):
    t = io.open(f, encoding='utf-8', errors='strict').read()
    t_v = t
    for old_n, new_n in sorted(vmap.items(), reverse=True):
        t_v = re.sub(r'`%d-2026-10-1[89]' % old_n, '`%d-2026-10-1[89]' % new_n, t_v)
        t_v = re.sub(r'Responde a: (\S+ )?%d\b' % old_n, r'Responde a: \g<1>%d' % new_n, t_v)
    if t != t_v:
        io.open(f, 'w', encoding='utf-8', newline='\n').write(t_v)
        io.open(f, 'rb').read().decode('utf-8', errors='strict')
```

⚠️ **El límite**: los logs que citan N viejo **por el contenido del mensaje** (no por el nombre del archivo) **quedan con la cita original** — la traza del original es la evidencia del riel (el fundador queda con la traza del riel: "en el 091 antes de la renumeración era el 110").

## LA ESTRATEGIA DE SIEMPRE (el orden exacto de las pasadas)

```
PASADA 0: mover __tmp__ de vuelta (limpiar el riel de run previos si quedan)
PASADA 1: todos los .md → __tmp__ (la evaluación de las colisiones)
PASADA 2: los __tmp__ ordenados por ts → los nombres consecutivos 001..NNN
PASADA 3: los títulos internos `# NNN` corregidos al número nuevo
PASADA 4: el pool NUMEROS_DISPONIBLES.txt regenerado max+1..max+100 (100 nums)
PASADA 5: el puntero .ultima-revision = max (sin BOM)
PASADA 6: las referencias antiguas (los Logs + docs) con el mapa old→new
```

## LOS ARCHIVOS AUXILIARES (que NO se renumeran)

- `NUMEROS_DISPONIBLES.txt` — regenerado (PASADA 4), nunca renombrado.
- `.ultima-revision-<agente>.txt` — actualizado (PASADA 5), nunca renombrado.
- Los subdirectorios de archivos por rango (`0-99/`, `100-199/`) — los archivos internos se renombran igual, la carpeta no.

## LO QUE NO SE TOCA

- El **contenido** de los mensajes (solo el título interno y el nombre de archivo).
- Las **firmas** cruzadas (la cita del original es la evidencia del riel — el fundador queda con la traza).
- Los **logs** que citan números por el contenido (los referencian el riel con la cita del original — puede quedar desalineado si el fundador lo decide; el riel queda con la traza).


### PASO 7 — EL PUNTERO `.ultima-revision-<agente>.txt` (solo el agente sabe el número correcto)

⚠️ **LÍMITE del director**: el número correcto del puntero **solo lo sabe el agente** (su ciclo de vueltas, su memoria de procesado). El director NO lo ajusta unilateralmente — al final de la corrección de numeración:

**ENVÍA POR MENSAJE al agente el informe completo de lo que corrigió:**

- El estado ANTES (cuántos archivos tenía el canal, los prefijos mezclados, los huecos).
- El estado DESPUÉS (los archivos renumerados consecutivos 001-NNN, los títulos internos corregidos).
- El **mapa old→new** de los archivos que cambian de número (para que el agente ajuste sus referencias internas).
- El **pool regenerado** (el rango del nuevo pool, los números libres).
- La **recomendación del puntero**: "tu puntero queda en NNN (el máximo de los archivos renumerados) — ajústalo si tu riel de procesado difiere".

**La condición**: el agente ajusta su puntero SI su última vuelta procesada lo confirma (el mensaje del agente lo confirma antes de que el director lo ajuste) — sino el agente informa su última vuelta procesada y el director deja el puntero al número que el agente declare.

**Insertar después del PASO 6 en el método definitivo** — el paso 7 queda como la NOTIFICACIÓN al agente de los cambios de numeración (con el informe completo y la recomendación del puntero).

---


---

**Firma:** GLM-5.3-Flash-Director (GLM-5.3-Flash) / Kilo Code — la metodología aplicada en los canales DS-V4.1-Flash-Opencode (108 mensajes, `990b9c4`) y Step-5-WorkBuddy (75 archivos, `07cf51c`) el 2026-10-18.
