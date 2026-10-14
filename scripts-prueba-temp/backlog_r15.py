# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/TAREAS-POR-MODELO/step-5-kilocode/BACKLOG-MASTER.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()
# R11: el director confirmo que los commits de atria ya estan en origin -> cerrar
t = t.replace(
 "- [?] **R11 \u2014 Verificar commits de atria (M04 iter4+5, M35 lote 3)** (PENDIENTE 2026-10-13, msg 281 del director: los logs 1810/1812/1814 existen en disco pero est\u00e1n untracked; origin/main sigue en `edc12ca`; informado al director, a la espera de que atria commitee para re-verificar).",
 "- [x] **R11 \u2014 Verificar commits de atria (M04 iter4+5, M35 lote 3)** (CERRADO 2026-10-14: el director confirm\u00f3 en su msg 285 que los lotes ya estaban commiteados y pusheados a origin \u2014 mi verificaci\u00f3n inicial fue anterior al commit; frente cerrado sin acci\u00f3n pendiente).")
# agregar R15
ancla = "- [x] **R11 \u2014 Verificar commits de atria"
r15 = ("- [x] **R15 \u2014 Correcci\u00f3n de numeraci\u00f3n de mensajes de la flota (pedido directo del fundador)** "
       "(CERRADO 2026-10-14): 8 canales corregidos \u2014 step-5-kilocode (496/497/498/499 \u2192 296/290/288/286, canal "
       "re-numerado completo 280\u2192327 con pool reconstruido), atria-dawn (200/199 \u2192 92/93 + nombres sin fecha "
       "normalizados), DeepSeek (499/500 \u2192 232/233), Hy3 (498 \u2192 199), agnes (16 archivos 500-512 \u2192 395-410 en "
       "orden cronol\u00f3gico, 0 duplicados, referencias verificadas), Step-5-WorkBuddy (19/20 duplicados \u2192 19-22), "
       "mimo (499 duplicado \u2192 197/198/199 + fuga del pool). 14 pools reconstruidos contiguos. Causa ra\u00edz "
       "documentada: bug del regex a\u00f1o-como-n\u00famero en `reservar_mensaje.py` + reserva manual del director. "
       "Informes 201, 295, 300, 302, 322 al director.")
if ancla in t:
    t = t.replace(ancla, r15 + "\n" + ancla, 1)
    print("R15 agregado y R11 cerrado")
else:
    print("AVISO: no se encontro el ancla de R11")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("backlog actualizado")
