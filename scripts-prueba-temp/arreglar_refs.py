# -*- coding: utf-8 -*-
"""Actualiza referencias internas a los numeros viejos dentro de los archivos renombrados."""
import io, os, re

MAP = {
  # nombre_viejo_sin_prefijo -> prefijo_nuevo  (se usa para el nombre completo)
  "2026-10-13_20-10-00-mimo-a-step-5-kilocode-cierre-deuda-4modulos-aceptado-next.md": "284",
  "2026-10-13_20-27-17-step-5-kilocode-a-step-5-kilocode-msg500-3-encargos-cerrados-mojibake-m11-deuda.md": "285",
  "2026-10-13_20-10-00-mimo-a-deepseek-m02-flip-aplicado-m76-gate-m01-next.md": "230",
  "2026-10-13_20-23-06-deepseek-a-mimo-m01-indice-lote-b1-5-candidatos.md": "231",
  "2026-10-13_20-10-00-mimo-a-hy3-diseno-5tareas-recibido-backlog-100-next.md": "197",
  "2026-10-13_20-16-44-hy3-a-mimo-backlog-100-tareas-listo.md": "198",
  "2026-10-13_20-18-09-atria-dawn-s3-a-mimo-backlogs-en-ruta-hy3-m76-congelado-helper-roto.md": "197",
  "2026-10-13_20-22-56-atria-dawn-s3-a-mimo-resumen-backlogs-conteo-urgentes.md": "198",
  "2026-10-13_20-23-00-atria-dawn-s3-a-mimo-resumen-backlogs-conteo-urgentes.md": "199",
  "2026-10-13_20-10-00-mimo-a-s2-ronda6-denegados-r3-m112-aplicado-sello-m35.md": "376",
}

ARCHIVOS = [
  "Mensajes entre modelos/step-5-kilocode/285-2026-10-13_20-27-17-step-5-kilocode-a-step-5-kilocode-msg500-3-encargos-cerrados-mojibake-m11-deuda.md",
  "Mensajes entre modelos/Hy3/198-2026-10-13_20-16-44-hy3-a-mimo-backlog-100-tareas-listo.md",
  "Mensajes entre modelos/DeepSeek-V4.1-Flash/231-2026-10-13_20-23-06-deepseek-a-mimo-m01-indice-lote-b1-5-candidatos.md",
  "Mensajes entre modelos/mimo-v2.6-flash-free/198-2026-10-13_20-22-56-atria-dawn-s3-a-mimo-resumen-backlogs-conteo-urgentes.md",
  "Mensajes entre modelos/mimo-v2.6-flash-free/199-2026-10-13_20-23-00-atria-dawn-s3-a-mimo-resumen-backlogs-conteo-urgentes.md",
  "Mensajes entre modelos/atria-dawn-s2/376-2026-10-13_20-10-00-mimo-a-s2-ronda6-denegados-r3-m112-aplicado-sello-m35.md",
]

for p in ARCHIVOS:
    if not os.path.exists(p):
        print("FALTA:", p)
        continue
    with io.open(p, "r", encoding="utf-8") as f:
        t = f.read()
    orig = t
    # 1) nombres completos viejos -> nuevos
    for resto, nuevo_pref in MAP.items():
        for viejo_pref in ("500", "501", "499", "2027", "2029"):
            viejo_full = viejo_pref + "-" + resto
            nuevo_full = nuevo_pref + "-" + resto
            if viejo_full in t and viejo_pref != nuevo_pref:
                t = t.replace(viejo_full, nuevo_full)
                print("  ref nombre: %s -> %s  (en %s)" % (viejo_full[:28], nuevo_full[:28], os.path.basename(p)[:20]))
    # 2) "msg 500:" / "Msg 500:" en el propio informe
    m = re.match(r"^# (\d+)", t)
    if m:
        propio = m.group(1)
        t = re.sub(r"(?i)\bmsg 500\b(?=:)", "Msg %s" % propio, t)
        t = re.sub(r"(?i)\bmsg 501\b(?=:)", "Msg %s" % propio, t)
    if t != orig:
        with io.open(p, "w", encoding="utf-8", newline="\n") as f:
            f.write(t)
        print("  GUARDADO:", os.path.basename(p)[:45])
    else:
        print("  sin cambios:", os.path.basename(p)[:45])
