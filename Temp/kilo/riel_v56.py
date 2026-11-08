# -*- coding: utf-8 -*-
import io, os, re, subprocess, sys
R = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# 1) localization_manager CANONICO (autoload): de donde carga .po
p1 = os.path.join(R, 'game', 'isla-ancestral', 'scripts', 'localization', 'localization_manager.gd')
t1 = io.open(p1, encoding='utf-8', errors='replace').read()
print('== localization/ manager (CANONICO por autoload) bytes:', len(t1))
for i, ln in enumerate(t1.splitlines(), 1):
    if '.po' in ln or 'locales' in ln or 'translations' in ln:
        print('  L%d: %s' % (i, ln.strip()[:130]))

# 2) gemelo localizacion/
p2 = os.path.join(R, 'game', 'isla-ancestral', 'scripts', 'localizacion', 'localization_manager.gd')
t2 = io.open(p2, encoding='utf-8', errors='replace').read()
print('== gemelo localizacion/ bytes:', len(t2), '| IDENTICO al canonico:', t1 == t2)
print('   cabecera gemelo:', t2.splitlines()[0][:100] if t2.splitlines() else '(vacio)')

# 3) msgids por locale (nueva ruta locales/)
for loc in ['es', 'en', 'pt']:
    b = io.open(os.path.join(R, 'game', 'isla-ancestral', 'locales', loc + '.po'), encoding='utf-8', errors='replace').read()
    ids = re.findall(r'^msgid "(.*)"', b, re.M)
    strs = re.findall(r'^msgstr "(.*)"', b, re.M)
    vivos = [(i, s) for i, s in zip(ids, strs) if i]
    vac = [i for i, s in vivos if not s.strip()]
    print(loc, '| msgids:', len(ids), '| vivos:', len(vivos), '| msgstr vacios:', len(vac), vac[:5])

# 4) watchdog propio (mi script de nicho)
print('== watchdog scripts/validar_i18n_integridad.py ==')
r = subprocess.run([sys.executable, '-X', 'utf8', os.path.join(R, 'scripts', 'validar_i18n_integridad.py')], capture_output=True, text=True, cwd=R)
print('rc:', r.returncode)
out = (r.stdout or '') + (r.stderr or '')
print(out[-1100:])

# 5) git: cuando cambiaron los .po
print('== git log -3 --format -- locales/ ==')
g = subprocess.run(['git', '-C', R, 'log', '--date=iso', '-3', '--format=%h %ad %s', '--', 'game/isla-ancestral/locales/'], capture_output=True, text=True)
print(g.stdout)
print('== diff stat HEAD~1..HEAD -- locales/ ==')
g2 = subprocess.run(['git', '-C', R, 'diff', '--stat', 'HEAD~1', 'HEAD', '--', 'game/isla-ancestral/locales/'], capture_output=True, text=True)
print(g2.stdout or '(sin cambios entre HEAD~1 y HEAD)')
