# -*- coding: utf-8 -*-
# Temporal: agregar _test_hitos_proximos al test_progresion. Se borra.
import io, sys
sys.stdout.reconfigure(encoding='utf-8')
path = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\scripts\progresion\test_progresion.gd'
with io.open(path, 'r', encoding='utf-8') as f:
    c = f.read()

test_nuevo = u"""

func _test_hitos_proximos() -> void:
	# RF8 (Log 678, glm-5.3-flash): sugeridor de metas para M53
	var proximos: Array = _pm.hitos_proximos(3)
	_check(proximos is Array, "hitos_proximos(3) retorna Array")
	_check(proximos.size() <= 3, "max 3 sugerencias: %d" % proximos.size())
	for h in proximos:
		_check(h.has("id") and h.has("nombre"), "cada sugerencia tiene id+nombre")
		_check(not _pm.hito_alcanzado(String(h["id"])),
			"sugerencia '%s' NO alcanzada (solo pendientes)" % String(h["id"]))
	# Con límite 1: solo 1
	var uno: Array = _pm.hitos_proximos(1)
	_check(uno.size() <= 1, "hitos_proximos(1) respeta límite: %d" % uno.size())

"""

# Insertar antes de _test_condition_evaluator
idx = c.find('## ── Iter. 3 (agnes-2.5-flash): evaluador con caché')
if idx > 0:
    c = c[:idx] + test_nuevo.lstrip('\n') + '\n' + c[idx:]
else:
    c = c.rstrip() + test_nuevo

# Agregar al run list
c = c.replace('\t_test_titulos_rf12()\n', '\t_test_titulos_rf12()\n\t_test_hitos_proximos()\n', 1)

with io.open(path, 'w', encoding='utf-8') as f:
    f.write(c)
print('test_progresion: _test_hitos_proximos agregado')
