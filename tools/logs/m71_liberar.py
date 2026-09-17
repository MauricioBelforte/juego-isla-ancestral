# -*- coding: utf-8 -*-
# Temporal: liberar M71 RF12. Se borra tras ejecutar.
import io, re

# 1. Checklist M71: marcar RF12 y secciones C relacionadas
path = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION\71-Progresion\plan-actual\05-Checklist.md'
with io.open(path, 'r', encoding='utf-8') as f:
    c = f.read()

# La checklist fue reconstruida por otro agente (imposibles/caché/predicado puro).
# RF12 puede no existir como item — la buscamos en variantes
patrones_rf12 = [
    '- [ ] RF12: títulos sociales cosméticos otorgados por hitos acumulados, sin poder ni bloqueo [M]',
    '- [?] RF12: títulos sociales cosméticos otorgados por hitos acumulados, sin poder ni bloqueo [M]',
    '- [ ] RF12: t\u00edtulos sociales cosm\u00e9ticos otorgados por hitos acumulados, sin poder ni bloqueo [M]',
]
evidencia = ' \u2014 re-implementado (Log 605, glm-5.3-flash/Kilo Code): se\u00f1al progreso_titulo_obtenido + _otorgar_titulo desde recompensas tipo "titulo" + API p\u00fablica (otorgar_titulo_directo/titulos_obtenidos/tiene_titulo/titulo_count) + persistencia retro-compatible (clave titulos, v1 sin ella \u2192 vac\u00edo) + deep-copy antialiasing. test_progresion con _test_titulos_rf12 (12 checks): 0 fallos'
hechos = 0
for p in patrones_rf12:
    if p in c:
        c = c.replace(p, '- [x]' + p[5:] + evidencia, 1)
        hechos += 1
        break

x = len(re.findall(r'^\s*- \[x\]', c, re.M))
print('Checklist M71: RF12 marcada (%d); [x]=%d' % (hechos, x))

notas = u"""

## Notas del Agente (RF12 re-implementación — Log 605, glm-5.3-flash/Kilo Code)

### Contexto
La iter. 3 original de RF12 (Log 518) fue **revertida por agente concurrente** (documentado
en M72/M74 Notas del Agente y BUG-013). Mientras tanto, OTRO agente implementó la parte
RF10 (imposibles) con diseño superior (caché, predicado puro, detección estática/dinámica)
— esa parte NO se toca. Esta re-implementación cubre SOLO el gap de RF12 (títulos).

### Lo que hice (aditivo, sin pisar)
- Señal `progreso_titulo_obtenido(titulo_id, nombre)` (RF12).
- `_otorgar_titulo(nombre, hito_origen)` idempotente + API pública
  (otorgar_titulo_directo/titulos_obtenidos/tiene_titulo/titulo_count).
- Recompensas tipo `"titulo"` en hitos.json ahora otorgan títulos (hito_amistades_5 → "Amigo del Pueblo").
- Persistencia: clave `titulos` en get_save_data (deep-copy antialiasing Log 553) +
  restore tolerante (saves v1 sin la clave → dict vacío). SIN bump de versión (aditivo retro-compatible).
- Test `_test_titulos_rf12` (12 checks): otorgamiento desde hito, idempotencia, señal única,
  API directa, persistencia round-trip — **0 fallos** (con las iteraciones de agnes/otros corriendo también).

### Coordinación (transparencia)
- RF10/imposibles: ya implementada por otro agente con mejor diseño — respetada y testeada.
- El archivo creció a 817+ líneas con múltiples iteraciones: continuar con ediciones quirúrgicas.
"""
if 'Notas del Agente (RF12 re-implementación' not in c:
    c = c.rstrip() + notas
    with io.open(path, 'w', encoding='utf-8') as f:
        f.write(c)
    print('M71: notas RF12 agregadas')

# 2. CHECKLIST-GLOBAL fila M71
path2 = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\CHECKLIST-GLOBAL.md'
with open(path2, 'rb') as f:
    content = f.read()
out = []
for line in content.split(b'\n'):
    if b'| 71 |' in line and b'71-Progresion' in line:
        t = (u'| 71 | 71-Progresion | 🟡 Liberado (RF12 re-implementado) | 28/213 | glm-5.3-flash | 3 | 22, 38 | GLM-5.3 Flash | — | 2026-09-03 19:35 | '
             '**🟡 Liberado (Log 605) — glm-5.3-flash (Kilo Code):** RF12 títulos sociales RE-IMPLEMENTADO (la original Log 518 fue revertida por agente concurrente): '
             'señal progreso_titulo_obtenido + otorgamiento desde recompensas "titulo" + API pública + persistencia retro-compatible sin bump de versión + deep-copy antialiasing. '
             'RF10/imposibles ya estaba re-hecha por otro agente (caché + predicado puro) — respetada. test_progresion con _test_titulos_rf12 12 checks: 0 fallos. '
             'Pendientes: RF1 registry .tres, RF8 logros base (M72 cubre), RF16 validación editor, secciones C/D/E. |').encode('utf-8')
        out.append(t)
    else:
        out.append(line)
with open(path2, 'wb') as f:
    f.write(b'\n'.join(out))
print('CHECKLIST-GLOBAL: M71 RF12')

# 3. ESTADO-PARALELO
path3 = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Mensajes entre modelos\ESTADO-PARALELO.md'
with open(path3, 'rb') as f:
    content3 = f.read()
out3 = []
added = False
for line in content3.split(b'\n'):
    out3.append(line)
    if not added and b'Agentes activos' in line:
        row = (b'| **M71 Progresi\xc3\xb3n (RF12 re-implementado)** | **glm-5.3-flash** | **Kilo Code** | **\xf0\x9f\x93\xa1 Liberado \xe2\x80\x94 2026-09-03 19:35 (Log 605)** | '
               b'**RF12 t\xc3\xadtulos re-implementada (Log 518 revertido por agente): se\xc3\xb1al + otorgamiento desde recompensas + API + persistencia retro-compatible. '
               b'RF10/imposibles de otro agente respetada. test_progresion 0 fallos con _test_titulos_rf12.** |')
        out3.append(row)
        added = True
with open(path3, 'wb') as f:
    f.write(b'\n'.join(out3))
print('ESTADO-PARALELO: M71 RF12')
