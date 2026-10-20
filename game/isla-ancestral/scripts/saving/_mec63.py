# -*- coding: utf-8 -*-
import io, re

rutas = {
    'M90 graphics_config': r'game\isla-ancestral\scripts\grafica\graphics_config.gd',
    'M58 accesibilidad': r'game\isla-ancestral\scripts\accesibilidad\accesibilidad_manager.gd',
    'M87 GameSettings': r'game\isla-ancestral\scripts\core\game_settings.gd',
}
for k, r in rutas.items():
    try:
        s = io.open(r, encoding='utf-8').read()
    except FileNotFoundError:
        print(k, '-> ARCHIVO NO ENCONTRADO:', r)
        continue
    pat = sorted(set(re.findall(r'(FileAccess\.[A-Za-z_]+\("[^"]+"|save\(|load\(|config\.cfg|user://[^"\']+)', s)))
    print(k, '->', pat[:8])
