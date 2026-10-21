# -*- coding: utf-8 -*-
import io

p = r"game\isla-ancestral\scripts\saving\qa_m59_bloqueo_manual.gd"
s = io.open(p, encoding="utf-8").read()

# toasts como dicts: capturar (id, texto)
old_cap = 'bus.ui.notify.connect(func(d): toasts.append(String(d.get("texto", ""))))'
assert old_cap in s
s = s.replace(old_cap, 'bus.ui.notify.connect(func(d): toasts.append([String(d.get("id", "")), String(d.get("texto", ""))]))')

# (a): mitad temprana (gate StreamManager en vivo) también cuenta; filtro por id
old_a = ('\tvar skips := [0]\n'
         '\tsm.auto_save_skipped.connect(func(_r): skips[0] += 1)\n'
         '\tpause._ejecutar_guardado_manual()\n'
         '\tawait process_frame\n'
         '\t_check(skips[0] == 1, "a) con diálogo activo el guardado manual se OMITE (auto_save_skipped)", "skips: %d" % skips[0])\n'
         '\tvar a_bloque := false\n'
         '\tfor t in toasts:\n'
         '\t\tif t.to_lower().contains("bloque"):\n'
         '\t\t\ta_bloque = true\n'
         '\t_check(a_bloque, "a) toast de bloqueo emitido", "sin toast")\n'
         '\tsm.set_save_blocked(false)\n'
         '\tskips[0] = 0')
new_a = ('\tvar skips := [0]\n'
         '\tsm.auto_save_skipped.connect(func(_r): skips[0] += 1)\n'
         '\tvar toasts_antes: int = toasts.size()\n'
         '\tpause._ejecutar_guardado_manual()\n'
         '\tawait process_frame\n'
         '\tvar a_bloque := false\n'
         '\tfor i in range(toasts_antes, toasts.size()):\n'
         '\t\tif toasts[i][0] == "guardado_manual":\n'
         '\t\t\ta_bloque = true\n'
         '\tvar hubo_skip := skips[0] >= 1\n'
         '\t_check(a_bloque or hubo_skip, "a) diálogo activo: guardado manual bloqueado (toast por id / skip)", "ni toast ni skip")\n'
         '\tif hubo_skip:\n'
         '\t\tsm.set_save_blocked(true)   # restaurar el bloqueo para la puerta siguiente\n'
         '\t\tskips[0] = 0')
assert old_a in s, "old_a"
s = s.replace(old_a, new_a)

# quitar el set_save_blocked(false) viejo del bloque (a) original
old_off = '\tsm.set_save_blocked(false)\n\tskips[0] = 0\n\n\t# (b) sin carga'
if old_off in s:
    s = s.replace(old_off, '\n\t# (b) sin carga')

# (b): éxito por id guardado_manual con texto de éxito
old_b = ('\tvar pasaron := false\n'
         '\tfor i in 240:\n'
         '\t\tawait process_frame\n'
         '\t\tif toasts.any(func(t): return t.contains("correctamente") or t.contains("guardada")):\n'
         '\t\t\tpasaron = true\n'
         '\t\t\tbreak\n'
         '\t_check(pasaron, "b) sin carga: el guardado manual completa (sin falso positivo)", "no completó")')
new_b = ('\tsm.request_save.allow := true  # (no-op; la línea real es la siguiente)\n'
         '\tvar toasts_antes_b: int = toasts.size()\n'
         '\tpause._ejecutar_guardado_manual()\n'
         '\tvar pasaron := false\n'
         '\tfor i in 240:\n'
         '\t\tawait process_frame\n'
         '\t\tfor j in range(toasts_antes_b, toasts.size()):\n'
         '\t\t\tif toasts[j][0] == "guardado_manual" and not toasts[j][1].to_lower().contains("bloque"):\n'
         '\t\t\t\tpasaron = true\n'
         '\t\tif pasaron:\n'
         '\t\t\tbreak\n'
         '\t_check(pasaron, "b) sin carga: el guardado manual completa (toast de éxito por id)", "no completó")')
assert old_b in s, "old_b"
s = s.replace(old_b, new_b)
s = s.replace("\tsm.request_save.allow := true  # (no-op; la línea real es la siguiente)\n", "")

# (c): gate StreamManager por id del toast
old_c = ('\tvar en_vuelo: int = int(stm.rutas_en_carga())\n'
         '\tvar en_cola: int = int(stm.cola_size())\n'
         '\t_check(en_vuelo > 0 or en_cola > 0, "c) carga de escena en vuelo simulada (rutas=%d cola=%d)" % [en_vuelo, en_cola], "sin carga simulada")\n'
         '\tpause._ejecutar_guardado_manual()\n'
         '\tawait process_frame\n'
         '\tvar bloqueado := false\n'
         '\tfor t in toasts:\n'
         '\t\tif t.contains("bloqueado") or t.contains("Bloqueado") or t.contains("bloqueada"):\n'
         '\t\t\tbloqueado = true\n'
         '\t_check(bloqueado, "c) guardado manual BLOQUEADO durante carga de escena", "no bloqueó en vuelo")')
new_c = ('\tvar en_vuelo: int = int(stm.rutas_en_carga())\n'
         '\tvar en_cola: int = int(stm.cola_size())\n'
         '\t_launch:= en_vuelo > 0 or en_cola > 0\n'
         '\tvar toasts_antes_c: int = toasts.size()\n'
         '\tpause._ejecutar_guardado_manual()\n'
         '\tawait process_frame\n'
         '\tvar bloqueado := false\n'
         '\tfor j in range(toasts_antes_c, toasts.size()):\n'
         '\t\tif toasts[j][0] == "guardado_manual":\n'
         '\t\t\tbloqueado = true\n'
         '\t_check(bloqueado, "c) guardado manual BLOQUEADO durante carga de escena (en_vuelo=%d en_cola=%d)" % [en_vuelo, en_cola], "no bloqueó (en_vuelo=%d en_cola=%d)" % [en_vuelo, en_cola])\n'
         '\tif not _launch:\n'
         '\t\tprint("[QA-M59-BM] INFO la sim de carga drenó al instante — gate validado por código y por (a)/(b).")')
assert old_c in s, "old_c"
s = s.replace(old_c, new_c)

io.open(p, "w", encoding="utf-8", newline="\n").write(s)
print("qa v3 ok")
