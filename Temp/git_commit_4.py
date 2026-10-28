import os, subprocess
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
os.chdir(root)
msg = """Se preservó la jornada 01:17-03:17 (sin push):

- M87 05-Checklist CERRADO a 140/0/0 (tanda conciliacion post-PT de Ling, Log 2221):
  JSON<->.po paridad total, 34 orphan JSON cuadrado, 115 .po-solo = 108 vivas (no inflado).
  M87 pasa a cand a 7to sello §21.8 (gate-2 por sucesor).
- Logs 2221 (M87 tanda) + 2222 (verificacion riel PT post-253f942, ronda 6, K1-K4 grep).
- Canales nuevos: Ling #303-307 (M87 cierre), MiniMax #063 (M20 BUG + M17), DeepSeek #434
  (tanda M14), GLM #18-19 (gate-2 model-agnostic), Nemotron #087-100 (V1 + nuevo riel W1
  web-research).
- estado_director.json + backlogs (ling/miniMax/nemotron).

Se excluyeron en-vuelo: Ling #308 + Log 2223 (verificacion h3 claves canonicas) + backlog ling.
"""
r = subprocess.run(["git", "commit", "-m", msg], capture_output=True, text=True)
print(r.stdout.strip()[:250])
print("ERR:", r.stderr.strip()[:150])
h = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True, text=True).stdout.strip()
print("HASH:", h)
