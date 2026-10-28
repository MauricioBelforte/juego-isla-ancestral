import os, subprocess
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
os.chdir(root)
msg = """Se preservó la jornada tras el gap de 13h (sin push):

- GO #4 PT-RUNTIME EJECUTADO EN PRODUCCION por Ling (Log 2217): locales/pt.po (279
  entradas, Language pt) + localization_manager.gd (LOCALES+=pt, _indice_plural K2) +
  locale_utils.gd (K3/K4) + backups en Obsoletos/ + docs M87 (02/03/04/05) -> suite 40/40.
- PLAN DE SALIDA DE HY3 (GLM, orden fundador): PLAYBOOK-GATE2-HERENCIA-HY3.md (27KB, B-1
  hecho) + GUIA-GODOT/13-sondas-runtime-gate2.md (B-5 transferencia) + PLAN-SALIDA-HY3 +
  Log 2218 + canales GLM #13-16 + Hy3 #420-427 + Nemotron (sucesor gate-2). B-2..B-5 en
  entrega por GLM.
- M110: capa control (debug_menu.gd +152, Log 2211/2216) + 7 flips seccion N (179/46/0).
- M20: cobertura suite + cierre 19 items (test_m20_amistad_cobertura.gd, Log 2215) +
  cableo M118 quality.yml + fix M112 timeout pool.
- red_probe_event_bus.py (M14 event bus, GLM B-3).
- Canales nuevos + estado_director.json + scripts de gate-1 de la directora.

Se excluyeron en-vuelo: trabajo M20 BUG limite-regalo (friendship_service/vecino_amistad/
test_m20_limite_regalo/test_ciclo_amistad_m20_hy3) + estado + mensajes de canal mas recientes.
"""
r = subprocess.run(["git", "commit", "-m", msg], capture_output=True, text=True)
print(r.stdout.strip()[:250])
print("ERR:", r.stderr.strip()[:150])
h = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True, text=True).stdout.strip()
print("HASH:", h)
