# -*- coding: utf-8 -*-
import glob
f = glob.glob("Mensajes entre modelos/atria-dawn-s2/105-*.md")[0]
body = (
 "M85-Modelos-3D-Legal auditado (volumen, opción 1): 99 [x] SUSTENTADOS, 0 degradaciones.\n"
 "Los 99 [x] = definiciones/diseño del modelo de licenciamiento (Resource ModelLicense, enums ModelType/LicenseScope,\n"
 "Resource ModelCredit, Work-for-Hire vs License) — DISEÑADOS en 03-Diseno.md. No degradé nada.\n"
 "SB-02 (L48 'inventario de todas las librerías de stock'): es un KnownIssue NO BLOQUEANTE = DEUDA REAL. Lo dejo [ ]\n"
 "NO lo marco [x] (regla que me diste en canal/59). Reporto como deuda del DoD de M85.\n"
 "GLOBAL/11-BUGS NO tocados. Nota 'Auditoría T' en M85. Siguiente = M131-Creditos (último del volumen).\n")
open(f, "w", encoding="utf-8").write(open(f, "r", encoding="utf-8").read() + body)
print("s2/105 filled:", f.split("/")[-1][:60])
