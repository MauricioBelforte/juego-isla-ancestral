# -*- coding: utf-8 -*-
import glob
f = glob.glob("Mensajes entre modelos/atria-dawn-s2/106-*.md")[0]
body = (
 "M131-Creditos auditado (volumen, opción 1): 85 [x] SUSTENTADOS, 0 degradaciones. 85 [x] / 0 [?] / 10 [ ].\n"
 "data/legal/creditos.json (4 secciones) + scripts/legal/ (audio_credit.gd) + test_credits_m131 8/0 (re-corrí yo).\n"
 "Gap: un [x] dice '7 secciones (v1: 3)' y el archivo trae 4 — catálogo parcialmente poblado; las 3 restantes +\n"
 "catalogo .tres están en los 10 [ ] (KnownIssues NO BLOQUEANTES: SFX menú, SFX navegación, música lounge). Lo dejé [ ].\n"
 "GLOBAL/11-BUGS NO tocados. Nota 'Auditoría T' en M131.\n\n"
 "## VOLUMEN COMPLETO — paquete opción 1 (11 módulos)\n"
 "M91 · M58 · M152 · M116 · M93 · M25 · M120 · M100 · M113 · M85 · M131 = 11 auditados, 0 degradaciones de [x]\n"
 "(los [ ] KnownIssues y M85 SB-02 los dejé como deuda real, no los cerré). Cron cancelado (lote agotado).\n"
 "M92/M57 quedan libres (set aside) si querés que retome. M64 sigue en tus manos.\n")
open(f, "w", encoding="utf-8").write(open(f, "r", encoding="utf-8").read() + body)
print("s2/106 filled:", f.split("/")[-1][:60])
