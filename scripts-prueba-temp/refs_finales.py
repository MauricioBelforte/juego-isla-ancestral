# -*- coding: utf-8 -*-
import io

# 1) deepseek 231: referencia sin .md + textos
p1 = "Mensajes entre modelos/DeepSeek-V4.1-Flash/231-2026-10-13_20-23-06-deepseek-a-mimo-m01-indice-lote-b1-5-candidatos.md"
with io.open(p1, encoding="utf-8") as f:
    t = f.read()
t = t.replace("500-2026-10-13_20-10-00-mimo-a-deepseek-m02-flip-aplicado-m76-gate-m01-next",
              "230-2026-10-13_20-10-00-mimo-a-deepseek-m02-flip-aplicado-m76-gate-m01-next")
t = t.replace("## 1. Acuse del 500", "## 1. Acuse del 230")
t = t.replace("este 501 + BACKLOG", "este 231 + BACKLOG")
with io.open(p1, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("deepseek 231: referencias actualizadas")

# 2) mi 285: "Msg 285:" -> "Msg 284:" (refiere al mensaje del director)
p2 = "Mensajes entre modelos/step-5-kilocode/285-2026-10-13_20-27-17-step-5-kilocode-a-step-5-kilocode-msg500-3-encargos-cerrados-mojibake-m11-deuda.md"
with io.open(p2, encoding="utf-8") as f:
    t2 = f.read()
antes = t2
t2 = t2.replace("# 285 \u2014 Msg 285: los 3 encargos", "# 285 \u2014 Msg 284: los 3 encargos")
if t2 != antes:
    with io.open(p2, "w", encoding="utf-8", newline="\n") as f:
        f.write(t2)
    print("mi 285: header corregido a 'Msg 284'")
else:
    print("AVISO: no se encontro el patron en 285")
