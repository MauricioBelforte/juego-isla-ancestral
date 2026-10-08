for p in ["DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md",
          "Mensajes entre modelos/ESTADO-PARALELO.md",
          "DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md",
          "DOCUMENTACION/TAREAS-POR-MODELO/kimi-k3/BACKLOG-MASTER.md"]:
    raw = open(p, "rb").read()
    crlf = raw.count(b"\r\n")
    cr = raw.count(b"\r")
    lf = raw.count(b"\n")
    bom = raw[:3] == b"\xef\xbb\xbf"
    print("%s -> CRLF=%d CR=%d LF=%d soloLF=%d BOM=%s" % (p, crlf, cr, lf, lf - crlf, bom))
