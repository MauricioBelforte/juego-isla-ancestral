# -*- coding: utf-8 -*-
import io, os, subprocess, glob as globmod
base = os.getcwd()
canal = os.path.join(base, "Mensajes entre modelos", "Ling-3.1-Flash")
r432 = os.path.join(canal, "432-2026-11-18_22-40-00-ling-3.1-flash-a-de-director-v169-incidente-313-431-pool-saneado.md")
t = io.open(r432, encoding="utf-8").read()
viejo = "- post431 uso helper --consume con pool del canal Ling ENVENENADO: NUMEROS_DISPONIBLES.txt de 1 byte (solo '\\n'), mtime 2026-11-11T20:45 (7 dias). Resultado: numero 313 (origen bajo investigacion; NO es linea de traceback — helper tiene 66 lineas, hipotesis descartada) -> archivo 313-2026-11-18 colisiono con 313 historico 2026-10-28 (v11 drift 0 sonda M14 a agnes)."
nuevo = "- CAUSA RAIZ CONFIRMADA (correccion honesta): mi script post431 tenia bug de argumentos — lista ['python','-X','utf8','scripts','proximo_numero.py',...] con la ruta PARTIDA en 2 tokens -> Python intento ejecutar el DIRECTORIO scripts ('can't find __main__ module') y mi regex (\\d{3}) capturo '313' del path del propio error ('...\\\\Python\\\\Python313\\\\python.exe'). **El helper JAMAS se ejecuto** para 429/430/431/432: 429 y 430 salieron por fallback hardcodeado ultimo+1 (casualmente correctos), 431/432 por validacion explicita num==max+1. El pool ENVENENADO (1 byte '\\n', mtime 2026-11-11) era problema REAL pero NO la causa del 313; saneado igual (0 nums, linea en blanco eliminada). Numeracion final valida por GUIA 10.2 (pool vacio = discrepancia -> ultimo+1): 431 y 432 correctos en disco."
if viejo in t:
    t = t.replace(viejo, nuevo)
    t += "\n(Correccion 22:45Z: causa raiz del 313 = bug de argumentos propio + regex sobre path Python313; helper nunca ejecutado. Numeracion 431/432 validada correcta.)"
    io.open(r432, "w", encoding="utf-8", newline="\n").write(t)
    print("MSG 432 CORREGIDO")
else:
    print("PATRON NO HALLADO en 432 — revisar manual")
bk = os.path.join(base, "DOCUMENTACION", "TAREAS-POR-MODELO", "ling-3.1-flash", "BACKLOGS", "BACKLOG-MASTER.md")
with io.open(bk, "a", encoding="utf-8", newline="\n") as f:
    f.write("\n## v169b (2026-11-18 22:45Z) — correccion causa raiz incidente 313\n")
    f.write("- [x] Causa real: bug propio argumentos helper (ruta partida 'scripts'+'proximo_numero.py') -> python ejecuto directorio -> regex capturo '313' de 'Python313' en path del error. Helper nunca corrio 429-432; numeros validos por fallback/validacion ultimo+1 (GUIA 10.2). Pool envenenado (1B '\\n') era aparte; saneado.\n")
    f.write("- [x] Msg 432 corregido en disco con causa verdadera. Proximos scripts: ruta helper como UN token 'scripts/proximo_numero.py'.\n")
h = subprocess.run(["python", "-X", "utf8", os.path.join("scripts", "proximo_numero.py"), "Ling-3.1-Flash"], capture_output=True, text=True, cwd=base, encoding="utf-8", errors="replace")
print("HELPER DIRECTO:", h.stdout.strip().replace("\n", " | ")[:300])
print("432 en disco:", len(globmod.glob(os.path.join(canal, "432-*.md"))), "| 431:", len(globmod.glob(os.path.join(canal, "431-*.md"))), "| 313 total:", len(globmod.glob(os.path.join(canal, "313-*.md"))))
