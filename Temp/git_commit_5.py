import os, subprocess
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
os.chdir(root)
msg = """Se preservó la jornada 03:17-05:17 (sin push):

- Degradaciones gate-1 aplicadas en 05: M151 (4, DS-OC 221), M67 (15, DS-OC 223), M110 17 UI
  widgets en deuda (DS-OC 223) + M01 indice maestro: auditoria 86 [x] no sostenidos
  (scripts/auditar_indice_m01.py + 12-Auditoria-Flips, DeepSeek #437).
- M14 event-bus: test_debug_menu_entorno_m110.gd + probe_runtime_bus_m14.gd (Log 2224).
- Riel G2 anti-trunca Nemotron (RIEL-G2-GATE2-SONDAS-MICRO) + B-7 COLA-FALTANTE-A regenerada
  (26 items).
- Canales nuevos: DS-OC 221-224, DeepSeek 435-437, GLM 20-23, Hy3 431-432, Ling 308-311.
- Logs 2223-2229 + estado_director.json.

Se excluyeron en-vuelo: DeepSeek #438 + estado + write_438.py.
"""
r = subprocess.run(["git", "commit", "-m", msg], capture_output=True, text=True)
print(r.stdout.strip()[:250])
print("ERR:", r.stderr.strip()[:150])
h = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True, text=True).stdout.strip()
print("HASH:", h)
