# -*- coding: utf-8 -*-
# Reconstruye la fila 37 de CHECKLIST-GLOBAL.md a 11 columnas (edicion byte-exacta).
# La fila (como toda la tabla) termina en "|\r\r\n": se preservan los 2 CR.

NEW_ROW = "| 37 | 37-Museos-Y-Colecciones | \U0001F535 En curso (iter. 4: reserva 2026-10-03 19:40) | 36/148 | Media | 3 | 36 | kimi-k3 | kimi-k3 | 2026-10-03 19:40 | **\U0001F535 RESERVA iter. 4 \u2014 kimi-k3 (Verdent), asignaci\u00f3n del coordinador 2026-10-03:** continuar desde iter. 3 (n\u00facleo Registry+DonationService \u2705, baseline 0 fallos). Foco: versionado del bloque de guardado (C.12), exposici\u00f3n arte RF5, escena museum.tscn + ExhibitSlot (D/E), flujos F/G, persistencia K, tests N. Fila reconstruida a 11 columnas (Prioridad ten\u00eda \"glm-5.3-flash\" desplazado; edici\u00f3n byte-exacta). \u00b7 **\U0001F7E1 Liberado (Log 542) \u2014 glm-5.3-flash (Kilo Code):** iter. 3 \u2014 RF2 exposici\u00f3n fauna con 7 especies reales M36 + toast EventBus.ui.notify al completar (RF6) + validar_catalogo RF14 + API panel M53 (get_resumen_para_ui) + estad\u00edstica donaciones_museo M71 + puente diario M55 + test 0 fallos + regresiones M72/M67/M75 0 fallos. HALLAZGO: se\u00f1al notify vive en bus.ui (dominio interno), no en ra\u00edz \u2014 bug latente de M72 corregido. Pendientes: museum.tscn/panel visual M53, RF5 obras M25/M163. \U0001F535 Verificado por Hy3/WorkBuddy (Log 856, \u00a721.8): re-verificado headless test_museo.gd -> 0 fallos (EXIT 0). Cumple \u00a721.8. |"

raw = open("CHECKLIST-GLOBAL.md", "rb").read()
crlf_b = raw.count(b"\r\n")
cr_b = raw.count(b"\r")
lines = raw.split(b"\n")
idx = [i for i, ln in enumerate(lines) if ln.startswith(b"| 37 |")]
assert len(idx) == 1, idx
i = idx[0]
old = lines[i]
assert old.count(b"\r") == 2, "la fila 37 no tiene 2 CR (inesperado): %d" % old.count(b"\r")
new = NEW_ROW.encode("utf-8") + b"\r\r"
cols_new = new.decode("utf-8").count("|") - 1
assert cols_new == 11, "columnas nuevas: %d" % cols_new
lines[i] = new
out = b"\n".join(lines)
assert out.count(b"\r\n") == crlf_b, "CRLF cambiaron: %d -> %d" % (crlf_b, out.count(b"\r\n"))
assert out.count(b"\r") == cr_b, "CR cambiaron: %d -> %d" % (cr_b, out.count(b"\r"))
assert not out.startswith(b"\xef\xbb\xbf"), "BOM agregado"
open("CHECKLIST-GLOBAL.md", "wb").write(out)
print("OK fila 37: 11 columnas. CRLF=%d CR=%d (sin cambios), sin BOM." % (crlf_b, cr_b))
print("longitud fila: %d -> %d bytes" % (len(old), len(new)))
