# -*- coding: utf-8 -*-
import glob
f = glob.glob("Mensajes entre modelos/atria-dawn-s2/102-*.md")[0]
body = (
 "M120-DLC auditado (volumen, opción 1): SUSTENTADO, 0 degradaciones. 163 [x] / 0 [?] / 59 [ ].\n"
 "Verificación: dlc_manager.gd + data/dlc/ (manifest, bundles) en disco; test_dlc_m120 16/0 (re-corrí yo).\n"
 "Clave: los [x] 'Diseñar dlc_{compatibility_checker,uninstaller,bundle_manager}.gd' son TAREAS DE DISEÑO — los 3\n"
 "componentes están DISEÑADOS en 03-Diseno.md (secciones Compatibilidad + Desinstalación + nombres/class_name).\n"
 "Los .gd AUSENTES = la implementación pendiente (los 59 [ ]). No degradé los 'diseñar': el diseño está documentado.\n"
 "GLOBAL/11-BUGS NO tocados (flip/pase = director). Nota 'Auditoría T' en M120. Siguiente volumen = M100-Community.\n")
open(f, "w", encoding="utf-8").write(open(f, "r", encoding="utf-8").read() + body)
print("s2/102 filled:", f.split("/")[-1][:60])
