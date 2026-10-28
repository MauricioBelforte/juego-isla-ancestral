import os, subprocess
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
os.chdir(root)
msg = """Se preservó la jornada 00:00-01:17 (sin push) tras el cierre del plan de salida de Hy3:

- BUG M20 limite-diarío REGALO corregido (friendship_service.gd + test_m20_limite_regalo.gd
  188 + test_ciclo_amistad_m20_hy3.gd, Log 2219). M17: suite test_m17_reglas_pieza.gd (311,
  reglas declarativas por pieza, Log 2220) + docs M17.
- Cierre del plan de salida Hy3: PLAYBOOK-GATE2-HERENCIA-HY3.md + reportes #429/#430 (incidente
  Beam APROBADO 721 flips/571 citas 0-inventadas) + GUIA-COMPARATIVA (ficha Hy3 con relevo).
- Gate-2 MODEL-AGNOSTIC (GLM #18/#19 + Ling #300-302): playbook + GUIA-GODOT/13 + red_probe;
  Ling repoblada M87 (#302).
- Canales nuevos (Hy3/GLM/Ling/MiniMax #062/Nemotron V1) + estado_director.json.
- M20 04/05 + CHECKLIST-GLOBAL + quality.yml.

Se excluyeron en-vuelo: Nemotron #087/#089, Ling #303, MiniMax CRONOMETRO/BACKLOG.
"""
r = subprocess.run(["git", "commit", "-m", msg], capture_output=True, text=True)
print(r.stdout.strip()[:250])
print("ERR:", r.stderr.strip()[:150])
h = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True, text=True).stdout.strip()
print("HASH:", h)
