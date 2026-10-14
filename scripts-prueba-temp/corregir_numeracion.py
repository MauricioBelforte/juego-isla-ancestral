# -*- coding: utf-8 -*-
"""Correccion de numeracion de mensajes mal puesta (pedido del usuario, 2026-10-13).
Regla: cada mensaje toma el numero correcto de SU pool; los huecos del medio NO se reutilizan
(solo se toma el siguiente disponible real). Fugas del pool (numeros con archivo ya existente)
se retiran. Headers internos corregidos."""
import io, os, re, subprocess, sys

def leer(p):
    with io.open(p, "r", encoding="utf-8") as f:
        return f.read()

def escribir(p, t):
    with io.open(p, "w", encoding="utf-8", newline="\n") as f:
        f.write(t)

def renombrar(viejo, nuevo_num):
    d = os.path.dirname(viejo)
    base = os.path.basename(viejo)
    # quita el prefijo numerico (o deja igual si no tiene)
    resto = re.sub(r"^\d+-", "", base)
    nuevo = os.path.join(d, "%d-%s" % (nuevo_num, resto))
    if os.path.exists(nuevo):
        return None, "YA EXISTE destino"
    r = subprocess.run(["git", "ls-files", "--", viejo], capture_output=True, text=True)
    trackeado = bool(r.stdout.strip())
    if trackeado:
        r2 = subprocess.run(["git", "mv", viejo, nuevo], capture_output=True, text=True)
        if r2.returncode != 0:
            return None, "git mv fallo: " + r2.stderr[:80]
        return nuevo, "git mv (trackeado)"
    os.rename(viejo, nuevo)
    return nuevo, "rename (untracked)"

def corregir_header(p, viejo_num, nuevo_num):
    t = leer(p)
    t2 = re.sub(r"(?m)^# %d\b" % viejo_num, "# %d" % nuevo_num, t, count=1)
    if t2 != t:
        escribir(p, t2)
        return "header ok"
    return "header no encontrado"

def quitar_del_pool(d, numeros):
    pp = os.path.join(d, "NUMEROS_DISPONIBLES.txt")
    if not os.path.exists(pp):
        return "sin pool"
    lineas = [l.strip() for l in leer(pp).split("\n") if l.strip()]
    original = len(lineas)
    for n in numeros:
        lineas = [l for l in lineas if l != str(n)]
    escribir(pp, "\n".join(lineas) + "\n")
    return "pool %d -> %d" % (original, len(lineas))

PLAN = [
  # (canal, archivo_viejo, num_viejo, num_nuevo, header?)
  ("Mensajes entre modelos/step-5-kilocode",
   "500-2026-10-13_20-10-00-mimo-a-step-5-kilocode-cierre-deuda-4modulos-aceptado-next.md", 500, 284, True),
  ("Mensajes entre modelos/step-5-kilocode",
   "501-2026-10-13_20-27-17-step-5-kilocode-a-step-5-kilocode-msg500-3-encargos-cerrados-mojibake-m11-deuda.md", 501, 285, True),
  ("Mensajes entre modelos/atria-dawn-s2",
   "2027-2026-10-13_17-00-57-s2-a-s2-ronda6-agnes-m141-m15-m16-denegados-m139-ok-m35-sello-m117-sin-drift.md", 2027, 374, True),
  ("Mensajes entre modelos/atria-dawn-s2",
   "2029-2026-10-13_17-29-47-s2-a-s2-m112-r3-6flips-verificados-sello-recomendado.md", 2029, 375, True),
  ("Mensajes entre modelos/atria-dawn-s2",
   "500-2026-10-13_20-10-00-mimo-a-s2-ronda6-denegados-r3-m112-aplicado-sello-m35.md", 500, 376, True),
  ("Mensajes entre modelos/DeepSeek-V4.1-Flash",
   "500-2026-10-13_20-10-00-mimo-a-deepseek-m02-flip-aplicado-m76-gate-m01-next.md", 500, 230, True),
  ("Mensajes entre modelos/DeepSeek-V4.1-Flash",
   "501-2026-10-13_20-23-06-deepseek-a-mimo-m01-indice-lote-b1-5-candidatos.md", 501, 231, True),
  ("Mensajes entre modelos/Hy3",
   "500-2026-10-13_20-10-00-mimo-a-hy3-diseno-5tareas-recibido-backlog-100-next.md", 500, 197, True),
  ("Mensajes entre modelos/Hy3",
   "499-2026-10-13_20-16-44-hy3-a-mimo-backlog-100-tareas-listo.md", 499, 198, True),
  ("Mensajes entre modelos/mimo-v2.6-flash-free",
   "500-2026-10-13_20-18-09-atria-dawn-s3-a-mimo-backlogs-en-ruta-hy3-m76-congelado-helper-roto.md", 500, 197, True),
  ("Mensajes entre modelos/mimo-v2.6-flash-free",
   "499-2026-10-13_20-22-56-atria-dawn-s3-a-mimo-resumen-backlogs-conteo-urgentes.md", 499, 198, True),
  ("Mensajes entre modelos/mimo-v2.6-flash-free",
   "499-2026-10-13_20-23-00-atria-dawn-s3-a-mimo-resumen-backlogs-conteo-urgentes.md", 499, 199, True),
]

FUGAS = {
  "step-5-kilocode": [282, 283],
  "atria-dawn-s2": [372, 373],
  "DeepSeek-V4.1-Flash": [228, 229],
  "Hy3": [],
  "mimo-v2.6-flash-free": [],
}

por_canal = {}
for canal, archivo, vn, nn, hdr in PLAN:
    por_canal.setdefault(canal, []).append((archivo, vn, nn, hdr))

for canal, items in por_canal.items():
    print("==", canal)
    asignados = []
    ok_todo = True
    for archivo, vn, nn, hdr in items:
        viejo = os.path.join(canal, archivo)
        if not os.path.exists(viejo):
            print("   FALLA: no existe", archivo)
            ok_todo = False
            continue
        nuevo, como = renombrar(viejo, nn)
        if nuevo is None:
            print("   FALTA renombrar %d->%d: %s" % (vn, nn, como))
            ok_todo = False
            continue
        msg = "   %d -> %d (%s)" % (vn, nn, como)
        if hdr:
            msg += " | " + corregir_header(nuevo, vn, nn)
        print(msg)
        asignados.append(nn)
    clave = canal.split("/")[-1]
    if ok_todo and asignados:
        fugas = FUGAS.get(clave, [])
        print("   " + quitar_del_pool(canal, fugas + asignados))
