import os, subprocess
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
os.chdir(root)
msg = """Se preservó la jornada de preservacion local (sin push) tras el reintegro de MiniMax:

- M48-Animacion: implementacion de la Fase 2 de validacion (4 archivos en
  scripts/animacion/validacion/: animation_validator.gd + import_animation_defaults.gd
  + validate_animation_cli.gd + test_validacion_m48.gd, Log 2211). Resuelve el FALLO
  21.8.2.b del barrido 03:25. Fila 48 GLOBAL syncada 43/123->113/123 (backup en Obsoletos).
- M60-Datos: revert T224 = 7 flips (4 T224->[?] + 3 M08->[ ]) -> 189/3/4 HONEST (DeepSeek
  #428, corrige mi aritmetica de 4 flips).
- M55-Diario: iconografia iter6 (iconos_diario.gd + test_diario_iconos_m55.gd +
  validate_diary.gd + diary_layer.gd + diary_service.gd, Log 2210) + 5 flips honestos
  + sync Totales 122/7/2 (pendiente GO del fundador para el commit M55).
- T-file de Reflection-Beam-1.0: 8 desmarcados residuales del pase 448 (#626) -> riel
  limpio de inflados.
- Canales nuevos: DeepSeek #425/#426/#427/#428/#429, Hy3 #417/#418/#419, MiniMax #57
  (bienvenida/re-orientacion M20+M17), Beam #626.
- Logs 2207/2209/2210/2211 + estado_director.json.

Se excluyeron los archivos en vuelo (<15m): estado_director.json (pendiente),
MiniMax #57 (recien escrito), DS-V4.1-Flash-Opencode #219 + Log 2213 (trabajo en vuelo).
"""
r = subprocess.run(["git", "commit", "-m", msg], capture_output=True, text=True)
print(r.stdout.strip()[:300])
print("ERR:", r.stderr.strip()[:200])
h = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True, text=True).stdout.strip()
print("HASH:", h)
