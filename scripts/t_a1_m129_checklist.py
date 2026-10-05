# -*- coding: utf-8 -*-
"""T-A1 M129: remarca los 40 items [ ] del 05-Checklist segun evidencia.
   35 -> [x] (especificado en merchandising.json v2 + merch_catalog.md + test 24/0)
   5  -> [?] (dueño externo: M45/M46 arte, M41 musica, M53 web)
   Aserta el conteo esperado de cada reemplazo (anti-clobber).
"""
import io

P = r'DOCUMENTACION/129-Merchandising/plan-actual/05-Checklist.md'
text = open(P, 'rb').read().decode('utf-8')

# (texto del item tras "- [ ] ", nuevo marcador, conteo esperado)
X = 'x'; Q = '?'
REPS = [
 ("Peluches", X, 1),
 ("Figuras", X, 1),
 ("Definir materiales (algod\u00f3n 100%)", X, 1),
 ("Definir tallas (XS, S, M, L, XL, XXL)", X, 1),
 ("Definir colores (blanco, negro, gris, azul)", X, 1),
 ("Definir materiales (cer\u00e1mica)", X, 1),
 ("Definir tama\u00f1o (11oz, 15oz)", X, 1),
 ("Definir colores (blanco, negro, azul)", X, 1),
 ("Definir materiales (papel, CMYK)", X, 1),
 ("Definir tama\u00f1os (11x17, 18x24, 24x36)", X, 1),
 ("Definir dise\u00f1o (concept art, sketches, renders)", Q, 1),
 ("Definir materiales (pasta dura, CMYK)", X, 1),
 ("Definir tama\u00f1o (8x10, 9x12)", X, 1),
 ("Definir p\u00e1ginas (100-200)", X, 1),
 ("Definir dise\u00f1o (tracks originales, remasters)", Q, 1),
 ("Definir formatos (digital, CD, vinyl)", X, 1),
 ("Definir dise\u00f1o (personajes, cute/cozy)", Q, 1),
 ("Definir materiales (peluche suave, algod\u00f3n)", X, 1),
 ("Definir tama\u00f1os (8, 12, 18 pulgadas)", X, 1),
 ("Definir dise\u00f1o (personajes, chibi/detallado)", Q, 1),
 ("Definir materiales (PVC, ABS)", X, 1),
 ("Definir tama\u00f1os (4, 6, 8 pulgadas)", X, 1),
 ("Dise\u00f1ar prueba de calidad de camisetas (material, impresi\u00f3n)", X, 1),
 ("Dise\u00f1ar prueba de calidad de tazas (material, impresi\u00f3n)", X, 1),
 ("Dise\u00f1ar prueba de calidad de posters (papel, impresi\u00f3n)", X, 1),
 ("Dise\u00f1ar prueba de calidad de peluches (material, costura)", X, 1),
 ("Dise\u00f1ar prueba de calidad de figuras (material, pintura)", X, 1),
 ("Crear protocolo de pruebas de seguridad para peluches (costuras reforzadas, ojos de seguridad, telas hipoalerg\u00e9nicas)", X, 1),
 ("Optimizar archivos gr\u00e1ficos vectoriales y rasterizados para minimizar tiempos de procesamiento en imprenta", X, 1),
 ("Estandarizar formatos y dimensiones de cajas para optimizar tarifas de env\u00edo por volumen en couriers", X, 1),
 ("Redactar gu\u00eda de est\u00e1ndares de calidad y acabados para fabricantes y talleres textiles", X, 1),
 ("Elaborar gu\u00eda de cuidado, lavado y mantenimiento de prendas y cer\u00e1micas para el comprador final", X, 1),
 ("Dise\u00f1ar una interfaz de tienda web limpia, inmersiva y totalmente integrada con la est\u00e9tica del juego", Q, 1),
 ("Dise\u00f1ar margen (40-50%)", X, 7),
]

ok = True
for item_text, mark, expected in REPS:
    old = "- [ ] %s" % item_text
    cnt = text.count(old)
    if cnt != expected:
        print("!! no coincide: %r esperado=%d real=%d" % (item_text, expected, cnt))
        ok = False
        continue
    new = "- [%s] %s" % (mark, item_text)
    text = text.replace(old, new)

if not ok:
    print("FALLO — no se escribio.")
    raise SystemExit(1)

# actualizar los 3 bloques de conteo si existen (Totales ya corregido por T-A3 en otra ruta;
# aqui hay 'Total de ítems'/'Ítems resueltos'/'Ítems pendientes' propios)
open(P, 'wb').write(text.encode('utf-8'))

# recuento final
import re
marks = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", text)
x = sum(1 for m in marks if m in ("x","X"))
q = sum(1 for m in marks if m == "?")
e = sum(1 for m in marks if m == " ")
print("ESCRITO. recuento: [x]=%d [?]=%d [ ]=%d total=%d" % (x, q, e, x+q+e))
