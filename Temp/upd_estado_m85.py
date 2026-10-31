import json
root = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
e = root + chr(92) + 'Logs' + chr(92) + 'estado_director.json'
st = json.load(open(e, encoding='utf-8'))
st['m85_rebaseline'] = {'antes': '99/1/0 inflado', 'despues': '73/25/2 (26 [x] revertidos, P-100 delta_x+0)', 'autoría': '24/26 = restauracion silenciosa cron-bulk (325b814+84ea2ed, conservando nota INFLADO/NO-existen, sin firma) + 2/26 Beam T246-85 spec-only. NO fue solo Beam.', 'global': 'fila 85 = 73/100 (amarillo), sello QA Log 1111 (73/2/25) coincide con rebaseline, modulo NO sellable (25 [ ] deuda real)'}
st['cron_c_bug_proceso'] = {'desc': 'BUG DE PROCESO: mis commits de preservacion (Cron C) commitean el worktree tal cual. Si alguien re-infla marcas [ ]->[x] en el worktree (manteniendo nota contraria "INFLADO/NO-existen"), el cron las versiona SIN firma ni flip. REGLA ANTI-RESTAURACION (30oct): antes de commitear detectar regresion de marcas [ ]->[x] sin nota de flip; si hay, anotar y no commitear (o commitear senalado como inflacion pendiente re-audit).'}
st['grep_repowide_autocontradictorio'] = {'desc': 'PATRON A CAZAR repo-wide: items [x] cuya nota dice INFLADO / NO-existen / sin-codigo-en-disco = autocontradiccion, no debe existir en ningun modulo. El M85 fue el caso visible; puede haber mas. Grep: 05-Checklist.md de cada modulo -> marca [x] + nota con esas palabras. TANDA 7 de DeepSeek.'}
st['m22_sello_invalido_confirmado'] = {'desc': 'M22 fila 22 -> 78/91 amarillo (sello 2026-10-15 invalidado por P-100). M14 139/140 caveat. M34 145/8 stale rebaseline.'}
json.dump(st, open(e, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print('estado_director actualizado (m85 + cron-c-bug + grep-repowide + m22)')
