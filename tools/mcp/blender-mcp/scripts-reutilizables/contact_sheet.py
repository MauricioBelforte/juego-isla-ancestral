#!/usr/bin/env python3
"""
contact_sheet.py — Genera una hoja de contacto (2x3) con las 6 capturas
orbitales de un asset, en JPG de baja resolución, para revisión visual
rápida. Pensado para `read` con visión.

Uso:
    python contact_sheet.py ruta/capturas/*.png salida.jpg
    python contact_sheet.py prefijo_basename salida.jpg
"""
import sys
import os
from PIL import Image, ImageDraw, ImageFont

def hoja(pngs, out):
    """Genera la hoja de contacto. Reutilizable desde `verificar_visual.py`."""
    import glob as _glob
    if isinstance(pngs, str):
        pngs = sorted(_glob.glob(pngs))
    pngs = sorted(pngs)
    imgs = [Image.open(p).convert('RGB') for p in pngs]
    w, h = imgs[0].size
    cols = 3
    rows = (len(imgs) + cols - 1) // cols
    nw, nh = w // 3, h // 3
    pad = 8
    label_h = 22
    sheet = Image.new('RGB', (cols * nw + (cols + 1) * pad,
                              rows * (nh + label_h) + (rows + 1) * pad), 'white')
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 14)
    except Exception:
        font = ImageFont.load_default()
    for i, (path, im) in enumerate(zip(pngs, imgs)):
        r, c = i // cols, i % cols
        x = pad + c * (nw + pad)
        y = pad + r * (nh + label_h + pad)
        sheet.paste(im.resize((nw, nh), Image.LANCZOS), (x, y))
        # Etiqueta: nombre del archivo sin extensión y sin el sufijo _azNNN
        name = os.path.basename(path)
        name = name.rsplit('.', 1)[0]
        # extraer el sufijo _azNNN
        if '_az' in name:
            sufijo = name.split('_az')[-1]
        else:
            sufijo = '?'
        draw.text((x + 4, y + nh + 2), 'az ' + sufijo, fill='black', font=font)
    sheet.save(out, 'JPEG', quality=78)
    print('OK', out, 'con', len(imgs), 'capturas', os.path.getsize(out), 'bytes')
    return out


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    salida = sys.argv[-1]
    # Si los args son rutas
    # E-30: la shell ya expande el glob, así que llegan N rutas sueltas. Había
    # un bug que tomaba solo argv[1] y generaba hojas de UNA captura en vez de
    # 6 -> una hoja así parece "aprobada" pero no cumple E-13 (multi-ángulo).
    if '*' in sys.argv[1]:
        # E-57: el shell NO expande globos entre comillas dobles. Si el literal
        # con '*' llega intacto, habia dos salidas malas: (a) crashear con
        # OSError "Invalid argument" al abrir el literal como archivo, o (b)
        # generar una hoja de UNA sola captura que PARECIA aprobada sin cumplir
        # E-13. Expandir aca cubre las dos.
        import glob as _g
        pngs = sorted(_g.glob(sys.argv[1]))
    elif os.path.isfile(sys.argv[1]):
        pngs = sys.argv[1:-1]
    else:
        # Prefijo: buscar en cwd
        prefijo = sys.argv[1]
        pngs = [os.path.join('.', f) for f in os.listdir('.')
                if f.startswith(prefijo) and f.endswith('.png')]
    if not pngs:
        print('No se encontraron PNGs')
        sys.exit(1)
    if len(pngs) < 2:
        print('AVISO: solo %d captura(s). Para E-13 se esperan 6 ángulos.'
              % len(pngs))
    hoja(pngs, salida)


if __name__ == '__main__':
    main()
