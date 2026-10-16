# -*- coding: utf-8 -*-
import io, os, re, subprocess

BASES = {
 "atria-dawn-s2": [
   ("372-16-35-00-mimo-a-s2-ronda6-confirmada-qa-m35-lote3.md", "372-2026-10-13_16-35-00-mimo-a-s2-ronda6-confirmada-qa-m35-lote3.md"),
   ("373-16-45-00-mimo-a-s2-lote354-s3-reenviado.md", "373-2026-10-13_16-45-00-mimo-a-s2-lote354-s3-reenviado.md"),
 ],
 "DeepSeek-V4.1-Flash": [
   ("228-16-35-00-mimo-a-deepseek-m35-aceptada-qa-s2-m76.md", "228-2026-10-13_16-35-00-mimo-a-deepseek-m35-aceptada-qa-s2-m76.md"),
   ("229-16-45-00-mimo-a-deepseek-m02-m01-s3-reenviado.md", "229-2026-10-13_16-45-00-mimo-a-deepseek-m02-m01-s3-reenviado.md"),
 ],
 "step-5-kilocode": [
   ("282-16-35-00-mimo-a-step5-verificar-commits-atria-higiene-m15-m16.md", "282-2026-10-13_16-35-00-mimo-a-step5-verificar-commits-atria-higiene-m15-m16.md"),
   ("283-16-45-00-mimo-a-step5-deuda-s3-reenviado.md", "283-2026-10-13_16-45-00-mimo-a-step5-deuda-s3-reenviado.md"),
 ],
 "Step-5-WorkBuddy": [
   ("17-16-35-00-mimo-a-wb-iter5-aceptada-jolt-iter6-autorizada.md", "17-2026-10-13_16-35-00-mimo-a-wb-iter5-aceptada-jolt-iter6-autorizada.md"),
 ],
}

for c, pares in BASES.items():
    d = os.path.join("Mensajes entre modelos", c)
    for viejo, nuevo in pares:
        v, n = os.path.join(d, viejo), os.path.join(d, nuevo)
        if not os.path.exists(v):
            print("  FALTA:", c, viejo); continue
        if os.path.exists(n):
            print("  YA EXISTE destino:", c, nuevo); continue
        r = subprocess.run(["git", "ls-files", "--", v], capture_output=True, text=True)
        if r.stdout.strip():
            r2 = subprocess.run(["git", "mv", v, n], capture_output=True, text=True)
            print("  %-22s %-24s %s" % (c, viejo[:22], "git mv ok" if r2.returncode == 0 else r2.stderr[:60]))
        else:
            os.rename(v, n)
            print("  %-22s %-24s %s" % (c, viejo[:22], "rename ok"))
