"""Backlog 19: volcar contradicciones cross-doc con citas exactas."""
from pathlib import Path
import re

BP = Path('DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/19-Backlog-CrossDoc-Contradicciones-PRUEBA.md')

H = {
1:'CONTRADICCIÓN: tamaño de isla. M08 02-Analisis.md:13 fija "Isla: 2048×2048 m"; M167 01-Requerimientos.md:21 y 03-Diseno.md:14 fijan radio 2560 → mundo 5120²; M168 01-Requerimientos.md:33 recomienda radio 256. Tres valores incompatibles para la isla principal.',
2:'CONTRADICCIÓN: zoom de cámara. M12 01-Requerimientos.md:21 define 3 niveles (2.5/5/8 m) y 02-Analisis.md:13/16 los da por implementados; M12 03-Diseno.md:127 admite que la implementación real usa zoom continuo 4.0-20.0 m.',
3:'CONTRADICCIÓN: duración del día. M29 01-Requerimientos.md:53 dice 1 mes = 28 días = 560 min (20 min/día) y :55 dice 336 días ≈ 56 h; M29 02-Analisis.md:39 define DURACION_DIA=1440 s + DURACION_NOCHE=480 s (32 min/día → 896 min/mes y 179 h/año).',
4:'CONTRADICCIÓN: mineral de oro. M35 01-Requerimientos.md:22 incluye "oro" entre los minerales del catálogo OreDefinition; M35 03-Diseno.md:98 lista 7 ítems minerales y :100 declara explícitamente "Item de oro: 0 — no existe gold_ore ni mineral_oro".',
5:'CONTRADICCIÓN: dirección de venta. M39 01-Requerimientos.md:28 escribe "Compra (jugador → tienda) y venta (jugador → tienda)" — ambas operaciones con la misma dirección; la venta debería ser tienda → jugador. M38 01-Requerimientos.md:54 define precios distintos por operación.',
6:'CONTRADICCIÓN: número de rutas. M28 04-Codigo.md:166 documenta data/viajes/rutas.json con 4 rutas; M68 03-Diseno.md:72-75 enumera 6+3+2+4 = 15 rutas por terminal y 04-Codigo.md:32 fija transport_network.tres con 10 paradas y 20 rutas como fuente única de verdad.',
7:'SIN HALLAZGOS. Leídos los 5 documentos de M112, M111, M101, M102 y M154; las cifras de suites/checks que aparecen son mediciones de cada módulo con fecha y log, no requisitos incompatibles entre sí. No invento una contradicción.',
8:'CONTRADICCIÓN: número de finales. M03 02-Analisis.md:63 y :69 fijan el roadmap post-lanzamiento en "4 finales"; M22 01-Requerimientos.md:43 define "Los 3 finales (principal, alternativos, secreto)" como alcance de historia principal.',
9:'SIN HALLAZGOS. Leídos los 5 documentos de M106, M100, M121, M120 y M99. Los SLA (M121:41 24-48 h; M100:41 48 h) son compatibles como rango vs cota, y el resto son alcances distintos (seguridad/comunidad/soporte/DLC/marketing), no requisitos que se pisen.',
10:'SIN HALLAZGOS. Leídos los 5 documentos de M90, M91, M88, M47 y M52. M90:25/02-Analisis:15-17 define caps de FPS y calidad de texturas; M47:17 calcula 975 texturas procedurales; M52 y M91 no fijan cifras que contradigan esos presupuestos.',
}

txt = BP.read_text(encoding='utf-8')
if '\n## Evidencia de la tanda' in txt:
    txt = txt.split('\n## Evidencia de la tanda')[0] + '\n'
lineas = txt.splitlines(keepends=True)
n = 0
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    m = re.match(r'^- \[ \] (T19-(\d+)): .+? - buscar contradicciones(?: —.*)?$', l)
    if not m:
        continue
    k = int(m.group(2))
    base = re.sub(r' — .*$', '', l)
    lineas[i] = '- [x] ' + base[6:] + ' — ' + H[k] + '\n'
    n += 1

ev = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:5x UTC)\n\n']
ev.append('Se leyeron los 5 archivos del `plan-actual/` de los 5 módulos de cada tanda (25 documentos por tanda, 250 en total). '
          'Cada hallazgo cita la línea exacta de cada documento enfrentado. No se marcó ningún `[x]` sin haber leído los documentos.\n\n')
ev.append('| Resultado | Tandas |\n|---|---|\n')
ev.append('| Contradicción con líneas citadas | 7 |\n')
ev.append('| Sin hallazgos (declarado, no inventado) | 3 (T19-07, 09, 10) |\n\n')
ev.append('Las contradicciones más duras son de **números incompatibles**: tamaño de isla (2048² vs 5120² vs 512²), '
          'duración de día (20 vs 32 min), rutas de viaje (4 vs 15 vs 20) y finales de historia (3 vs 4). '
          'No se corrigió ningún documento: solo se reporta.\n\n')
ev.append('**Firma:** agnes-3-flash (directora) - 2026-11-17 08:05\n'
          '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:5x\n')

BP.write_text(''.join(lineas) + ''.join(ev), encoding='utf-8', newline='\n')
print('tareas marcadas:', n)
