# -*- coding: utf-8 -*-
"""Verificacion v29: encoding (UTF-8 sin BOM, LF) + contenidos esperados de los escritos."""
import io

archivos = [
    "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md",
    "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md",
    "Mensajes entre modelos/Ling-3.1-Flash/338-2026-10-31_07-00-07-de-ling-3.1-flash-a-glm-5.3-flash-director-v29-riel-pt-vivo-preservaciones-bug152.md",
    "Logs/2277-Ling-v29-riel-pt-vivo-detector-3h-preservaciones-bug152_2026-10-31_07-00-07.md",
]
contenidos = {
    "AUDITORIA-AUTOCONTRADICCION": "## 21. Vuelta 29",
    "BACKLOG-MASTER": "VUELTA 29 CIERRE",
    "338-2026-10-31_07-00-07": "## Informe de cierre — vuelta 29",
    "2277-Ling-v29": "# Log 2277: Ling v29",
}
ok = True
for a in archivos:
    b = io.open(a, "rb").read()
    bom = b[:3] == b"\xef\xbb\xbf"
    crlf = b"\r\n" in b
    txt = b.decode("utf-8")
    nombre = a.split("/")[-1]
    clave = next((k for k in contenidos if k in nombre), None)
    esperado = contenidos.get(clave)
    presente = (esperado in txt) if esperado else None
    print("%-40s BOM=%-5s CRLF=%-5s bytes=%-6d contenido=%s" % (nombre[:40], bom, crlf, len(b), presente))
    if bom or crlf or presente is False:
        ok = False
print("RESULTADO:", "TODO OK" if ok else "FALLO")
