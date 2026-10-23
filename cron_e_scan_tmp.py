# -*- coding: utf-8 -*-
import io, re, glob

# CRON E PASO 2: verificar presupuestos numericos en los 03 de los 9 modulos
mods = [('72-Sistema-De-Logros', 5), ('105-Telemetria', 5), ('107-Backups', 2), ('119-Actualizaciones', 3), ('09-Terreno', 5), ('112-Testing', 4), ('114-Playtest', 5), ('116-Instalador', 3), ('118-CI-CD', 3)]
faltan = 0
for pref, esperados in mods:
    g = glob.glob('DOCUMENTACION/' + pref + '*/plan-actual/03-Diseno.md')
    if not g:
        print(pref, 'SIN 03'); continue
    t = io.open(g[0], encoding='utf-8-sig', errors='replace').read()
    tiene = ('Presupuestos numericos' in t) or ('presupuestos numericos' in t.lower())
    print(pref, 'presupuestos en 03:', tiene, '(esperados:', esperados, ')')
    if not tiene:
        faltan += esperados
print('TOTAL presupuestos que faltan definir:', faltan)
