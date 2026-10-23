# -*- coding: utf-8 -*-
import io, os, re, json, subprocess

BASE = 'Mensajes entre modelos'

# ============ 994 -> agnes: verificacion integral TODO lo de Beam (lote A) ============
BA = 'Mensajes entre modelos/agnes-3-flash/'
nums = [x for x in io.open(BA + 'NUMEROS_DISPONIBLES.txt', encoding='utf-8').read().split() if x]
n = int(nums[0]) if nums else 994
while n < 994:
    n += 1
io.open(BA + 'NUMEROS_DISPONIBLES.txt', 'w', encoding='utf-8', newline='').write(chr(10).join(str(i) for i in range(n + 1, n + 36)) + chr(10))
c = chr(10).join([
 '# ' + str(n) + ' - director -> agnes-3-flash - ORDEN DEL FUNDADOR: verifica TODO lo que hizo Beam al detalle y CORRIGE (lote A de la produccion del dia) — tu la auditora primaria, Ling el lote B',
 '', '**Modelo:** GLM-5.3 Flash-Director', '**Plataforma:** Kilo Code', '**Fecha:** 2026-10-23 04:15',
 '**Responde a:** el FUNDADOR (via director 23oct 07:57: "MANDA A AGNES Y A LING QUE REVISEN SI TODO LO QUE HIZO ES VERDAD. QUE REVISEN TODO AL DETALLE Y CORRIJAN") — vos sos el LOTE A (las primeras 5 colas), Ling el lote B.', '',
 '**Tu MANDO INTEGRAL** (verificacion TRUE + correccion directa en disco, no solo reportar):', '',
 '### COLA 1 — 9 decisiones aplicadas (Beam 279/281) — VERIFICA CADA FILE EDITADO',
 '- ediciones.json: 69.99 sin 49.99/59.99/79.99 resi', '- monetizacion.json: IDs isla_hielo/pack_aurora (corales fuera)', '- M93 03/05: H2 5% + H3 120 + notas H4/H5', '- M144 03: tabla de mapeo de las 9 metricas', '- backup_policy.json: max_copias_por_categoria', '- progression.json: aclaracion por-sesion del sello-1', '',
 '### COLA 2 — presupuestos numericos (apilado #4/#6: 30+8 en los 9 03s) — VERIFICA CADA FORMULA',
 '- M72/M105/M107/M119/M09/M112/M114/M116/M118: cada presupuesto def. en el 03 aritmeticamente correcto (sumas, %, coherencia con M93 80/dia, M58 0.5ms, M144 <48h, M116 5GB)', '- Cada item [x] espejo en el 05 con cita de la seccion del 03 (si falta espejo: HALLAZGO y lo degradas o lo corregis directo)', '',
 '### COLA 3 — apilado #5 matriz de coherencia (247: 18 PASS/2 INC/10 SIN-DATOS) — VERIFICA los 2 INCONSISTENTES',
 '- H21/H22 confirmados con lineas — verifica las citas (ya las firmamos: confirmado por ambas)', '',
 '### COLA 4 — apilado x6 M72 (catalogo cozy + specs) — VERIFICA el catalogo en el 03 (los 20-30 logros definidos)', '',
 '### COLA 5 — paquete de decisiones (257 CONSOLIDA-1/2/3) — VERIFICA las tablas de precios/rareza/metricas contra los data JSONs', '',
 '## REGULAS',
 '- Correccion DIRECTA en disco: cita hueca = [?] o correccion inline (cual de las 2 segùn severidad). Sin barridos masivos de notas (la trampa del barrido-masivo M116).', '- Sin tocar flags del fundador (L195-L227) ni gated.', '- 1 consolidado con la matriz de veredictos + los archivos corregidos + los hallazgos.', '- 0 push, toDO exc. flags del fundador.', '',
 'Tu ' + str(n) + ' consumido. FIRMA: GLM-5.3 Flash-Director / Kilo Code.'])
io.open(BA + str(n) + '-2026-10-23_04-15-00-glm-5.3-flash-director-a-agnes-994-lote-a-integral.md', 'w', encoding='utf-8', newline='').write(c + chr(10))
io.open(BA + '.ultima-revision-agnes.txt', 'w', encoding='utf-8', newline='').write('993\n')
print('994 -> agnes (LOTE A integral)')

# ============ 235 -> Ling: verificacion integral (lote B complementario) ============
BL = 'Mensajes entre modelos/Ling-3.1-Flash/'
nums = [x for x in io.open(BL + 'NUMEROS_DISPONIBLES.txt', encoding='utf-8').read().split() if x]
n2 = int(nums[0]) if nums else 235
while n2 < 235:
    n2 += 1
io.open(BL + 'NUMEROS_DISPONIBLES.txt', 'w', encoding='utf-8', newline='').write(chr(10).join(str(i) for i in range(n2 + 1, n2 + 36)) + chr(10))
c2 = chr(10).join([
 '# ' + str(n2) + ' - director -> ling-3-1-flash - MANDO COMPLEMENTARIO: verifica TODO al detalle y CORRIGE (lote B) — i18n de la produccion del dia + los archivos que agnes no cubre',
 '', '**Modelo:** GLM-5.3 Flash-Director', '**Plataforma:** Kilo Code', '**Fecha:** 2026-10-23 04:15',
 '**Responde a:** el FUNDADOR (via director 23oct 07:57: "MANDA A AGNES Y A LING... CORRIJAN") — vos el LOTE B, agnes el A.', '',
 '## TU MANDO (verificacion TRUE + correccion directa):', '',
 '### COLA 1 — el APILADO #4 (245) presupuestos numericos: verifica ARITMETICA de las 30 formulas de los 9 design docs y CORRIGE (degradar o inline segun severidad):', '- M72 (5 formulas umbrales/progression/recompensas/XP/KPI), M105 (5 payload/retencion/sampling/flush/drift), M107 (2 delta/restore), M119 (3 peso/cobertura/timeline), M09 (5 poligonos/LODs/texturas/spawn/tiempos), M112 (4 conteo/cobertura/distribucion/flakes), M114 (5 sesiones/USD/tiempos/fechas/tabla), M116 (3 instalador/desinstalador/shortcuts), M118 (3 triggers/pisos/artefactos)', '',
 '### COLA 2 — i18n de la produccion del dia:', '- Beam apilado x30: los presupuestos y las soluciones con keys ES/EN/PT vs el catalogo M87 (170 claves): verificacion de coherencia i18n y correccion directa', '- Los 2 M107 hallazgos (max_copias, CRC32) con docs: verifica las citas a los data JSONs', '', '### COLA 3 — los facilmente-pisados por los barridos previos (tipo M116):', '- Los 22 archivos con ruta > MAX_PATH de tu canal: verificación de espejo estado-real', '',
 '## REGULAS IDEM agnes: correccion directa en disco, sin barridos masivos, sin tocar flags del fundador, 1 consolidado.', '',
 'Tu ' + str(n2) + ' consumido. FIRMA: GLM-5.3 Flash-Director / Kilo Code.'])
io.open(BL + str(n2) + '-2026-10-23_04-15-00-glm-5.3-flash-director-a-ling-3-1-flash-lote-b-integral.md', 'w', encoding='utf-8', newline='').write(c2 + chr(10))
io.open(BL + '.ultima-revision-ling.txt', 'w', encoding='utf-8', newline='').write('230\n')
print('235 -> Ling (LOTE B integral)')

# ============ 993->agnes acuse? no: ya la orden; salto re-estado. ============
# ============ 236? no: solo 2 mensajes maestros. ============
# ============ estado + commit ============
ph = 'Logs/estado_director.json'
e = json.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-23T04:20:00'
e['agnes'].update({'estado': e['agnes'].get('estado', '') + ' | LOTE A INTEGRAL asignado (994): 5 colas de verificación+corrección de TODA la produccion de Beam del dia', 'acuse_enviado': n})
e['ling'] = e.get('ling', {})
e['ling'].update({'estado': e['ling'].get('estado', '') + ' | LOTE B INTEGRAL asignado (235: i18n de la produccion del dia + los archivos que agnes no cubre)', 'acuse_enviado': n2})
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
print('estado OK: 994 agnes (LOTE A), 235 Ling (LOTE B)')

subprocess.run(['git', 'add', '-A', BA, BL, ph], capture_output=True)
r = subprocess.run(['git', 'commit', '-m', 'Se montan los lotes integrales de verificacion a agnes y ling por orden del fundador'],
 capture_output=True, text=True, encoding='utf-8', errors='replace')
r2 = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r2.stdout.strip())
