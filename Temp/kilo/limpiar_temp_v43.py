# -*- coding: utf-8 -*-
"""Limpieza REVERSIBLE Temp/kilo: mueve a _archivo_v25_v41/ los archivos de vueltas v25-v41
(salvos los canonicos v41/v42/v43 + scripts activos). Lista todo lo movido (trazabilidad)."""
import io, os, shutil, glob

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
TK = os.path.join(RAIZ, u"Temp", u"kilo")
DEST = os.path.join(TK, u"_archivo_v25_v41")
if not os.path.isdir(DEST):
    os.makedirs(DEST)

KEEP = {
    u"check_v42.py", u"diff_v43.py", u"ctx_v43.py", u"centinela_v43.py",
    u"v41_detector_delta.txt", u"v42_detector_delta.txt", u"v43_detector.txt",
    u"v43_watchdog.txt", u"estado_director_v42.json", u"v42_validador_i18n.txt",
    u"limpiar_temp_v43.py",
}
movidos = []
for p in glob.glob(os.path.join(TK, u"*")):
    if not os.path.isfile(p):
        continue
    n = os.path.basename(p)
    if n in KEEP:
        continue
    shutil.move(p, os.path.join(DEST, n))
    movidos.append(n)
print(u"movidos a _archivo_v25_v41/: %d" % len(movidos))
print(u"directos restantes: %d" % len([f for f in glob.glob(os.path.join(TK, u"*")) if os.path.isfile(f)]))
for n in sorted(movidos):
    print(u"  " + n)
