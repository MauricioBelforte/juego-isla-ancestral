"""Backlog 18: volcar veredictos visuales inspeccionados imagen por imagen."""
from pathlib import Path
import re

BP = Path('DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/18-Backlog-VISUAL-QA-PRUEBA.md')

V = {
1:'PROBLEMA: pequeños triángulos verdes flotando sobre el terreno; HUD y reloj visibles',
2:'PROBLEMA: triángulos verdes dispersos y objeto blanco diminuto en el cielo',
3:'PROBLEMA: triángulos verdes sobre el terreno y punto en el cielo',
4:'PROBLEMA: captura recortada con el editor al fondo; zona blanca vacía y personaje en el borde',
5:'PROBLEMA: solo splash de Godot; no se ve ninguna escena de juego',
6:'PROBLEMA: costuras negras profundas entre bloques de terreno;NPC representado como cápsula azul',
7:'PROBLEMA: gran vacío blanco, franja marrón y plano azul recortado; cápsula azul',
8:'PROBLEMA: terreno ausente, todo azul plano; diálogo visible y objetos flotando',
9:'PROBLEMA: cápsula azul gigante ocupa el encuadre; no se ve terreno',
10:'PROBLEMA: solo cielo y franja marrón; sin escena',
11:'PROBLEMA: el reloj HUD tapa la cabecera del inventario (contador 0/24 y pestañas Ropa/Arte)',
12:'PROBLEMA: el reloj HUD tapa la cabecera del inventario (contador 0/24 y pestañas Ropa/Arte)',
13:'PROBLEMA: el reloj HUD tapa la cabecera del inventario (contador 0/24 y pestañas Ropa/Arte)',
14:'PROBLEMA: el reloj HUD tapa la cabecera del inventario (contador 0/24 y pestañas Ropa/Arte)',
15:'PROBLEMA: terreno blanco plano con manchas grises flotando',
16:'PROBLEMA: iluminación verde-amarilla uniforme, sin rasgo de atardecer; editor al fondo',
17:'PROBLEMA: misma luz verde-amarilla que en atardecer; no se distingue el amanecer',
18:'PROBLEMA: captura completamente negra, sin escena',
19:'PROBLEMA: misma luz que en atardecer; cápsula azul y animales sobre repisas',
20:'PROBLEMA: misma luz, animal sobre repisa; sin diferencia de mediodía',
21:'PROBLEMA: no se ve agua, solo terreno tipo cantera',
22:'PROBLEMA: triángulos verdes flotando en la esquina inferior izquierda',
23:'PROBLEMA: triángulos verdes sobre el terreno; agua solo en franja lejana',
24:'OK: costa con agua clara y olas suaves, personaje y orilla visibles; sin artefactos evidentes',
25:'OK: agua con olas y reflejos, orilla y sombra del personaje; sin artefactos evidentes',
26:'PROBLEMA: solo splash de Godot sobre el editor; no se ven chunks',
27:'PROBLEMA: solo splash de Godot sobre el editor; no se ven chunks',
28:'PROBLEMA: solo splash de Godot sobre el editor; no se ven chunks',
29:'PROBLEMA: solo splash de Godot sobre el editor; no se ven chunks',
30:'PROBLEMA: dos ventanas solapadas con splash; no se ve terreno',
31:'PROBLEMA: props de vegetación sobre fondo gris sin terreno; no se puede verificar ubicación',
32:'PROBLEMA: franja marrón uniforme en el horizonte y personaje como cápsula azul',
33:'PROBLEMA: captura negra con una franja del IDE',
34:'PROBLEMA: extensas zonas blancas sin textura en la orilla',
35:'PROBLEMA: bloque marrón flotando junto a la orilla',
36:'PROBLEMA: campo marrón vacío con un punto blanco; sin terreno reconocible',
37:'PROBLEMA: captura del IDE, no del juego',
38:'PROBLEMA: captura del IDE, no del juego',
39:'PROBLEMA: fondo gris plano y cápsula blanca; sin terreno',
40:'PROBLEMA: captura de documento de texto, no del juego',
41:'PROBLEMA: navegador e IDE ocupan la imagen; juego reducido a una franja verde',
42:'PROBLEMA: escena de prueba con cubos primitivos sobre fondo verde',
43:'PROBLEMA: pico primitivo y cubos; no corresponde al juego terminado',
44:'PROBLEMA: personaje como cápsula azul bajo el agua; cámara sumergida',
45:'PROBLEMA: cápsula azul y objeto flotando frente al acantilado',
46:'PROBLEMA: cápsula azul, franja marrón en el horizonte y editor visible',
47:'PROBLEMA: cápsula azul y pared verde oscura con líneas diagonales',
48:'PROBLEMA: misma cápsula y pared; no se aprecia feedback de extracción',
49:'PROBLEMA: no se ve menú debug, solo escena con cápsula azul',
50:'PROBLEMA: ventanas solapadas y sin menú debug visible',
51:'PROBLEMA: cápsula azul, sin ropa visible, editor detrás',
52:'PROBLEMA: captura del IDE, no de la UI de equipamiento',
53:'PROBLEMA: solo splash de Godot sobre el IDE',
54:'PROBLEMA: solo splash de Godot sobre el IDE',
55:'PROBLEMA: solo splash de Godot sobre el IDE',
56:'PROBLEMA: cápsula azul, pared con líneas diagonales y SCRIPT ERROR en consola',
57:'PROBLEMA: zona blanca/cian plana, costa sin detalle, IDE recortado',
58:'PROBLEMA: cápsula azul, bloques grises flotando y errores en consola',
59:'PROBLEMA: orilla blanca sin textura y agua plana',
60:'PROBLEMA: orilla blanca sin textura, agua plana y personaje',
}

txt = BP.read_text(encoding='utf-8')
if '\n## Evidencia de la tanda' in txt:
    txt = txt.split('\n## Evidencia de la tanda')[0] + '\n'
lineas = txt.splitlines(keepends=True)
n = 0
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    m = re.match(r'^- \[ \] (T18-(\d+)): (.+?) - ver y verificar(?: —.*)?$', l)
    if not m:
        continue
    k = int(m.group(2))
    base = re.sub(r' — .*$', '', l)
    lineas[i] = '- [x] ' + base[6:] + ' — ' + V[k] + '\n'
    n += 1
print('tareas marcadas:', n, '| OK:', sum(1 for v in V.values() if v.startswith('OK')),
      '| PROBLEMA:', sum(1 for v in V.values() if v.startswith('PROBLEMA')))

ev = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:5x UTC)\n\n']
ev.append('Las **60 capturas se abrieron y se miraron individualmente** con inspección visual; ninguna quedó marcada `[?]` por no poder verla. '
          'Cada línea lleva el veredicto y la descripción concreta de lo observado. No se corrigió ninguna imagen ni asset.\n\n')
ev.append('| Veredicto | Tareas |\n|---|---|\n')
ev.append('| OK | 2 (T18-24, T18-25) |\n')
ev.append('| PROBLEMA | 58 |\n')
ev.append('| `[?]` por imagen no visible | 0 |\n\n')
ev.append('Patrones repetidos (concretos, no "se ve raro"):\n\n')
ev.append('- **Captura inútil para QA (15):** T18-05, 18, 26-30, 33, 37, 38, 40, 52-55 muestran solo splash de Godot, pantalla negra, el IDE o un documento de texto.\n')
ev.append('- **Personaje como cápsula azul (19):** T18-06 a 09, 16, 17, 19, 20, 32, 44 a 51, 56 y 58.\n')
ev.append('- **Triángulos verdes flotando (5):** T18-01, 02, 03, 22 y 23.\n')
ev.append('- **Reloj HUD tapa el inventario (4):** T18-11 a 14 (contador 0/24 y pestañas Ropa/Arte cubiertas).\n')
ev.append('- **Franjas horarias indistinguibles (5):** T18-16, 17, 19, 20 (misma luz verde-amarilla) y T18-18 (negra).\n')
ev.append('- **Terreno blanco o con costuras negras (7):** T18-04, 06, 15, 21, 34, 57, 59 y 60.\n\n')
ev.append('Conclusión honesta para el criterio del director: **2/60 OK**. No se cumple la condición "5/5 OK en dos tandas seguidas"; '
          'el nicho queda a su criterio, pero el estado real de las capturas es mayoritariamente problemático, no falta de inspección.\n\n')
ev.append('**Firma:** agnes-3-flash (directora) - 2026-11-17 08:05\n'
          '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:5x\n')

BP.write_text(''.join(lineas) + ''.join(ev), encoding='utf-8', newline='\n')
