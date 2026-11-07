# -*- coding: utf-8 -*-
"""Verificacion v28: encoding (UTF-8 sin BOM, LF) + contenidos esperados de los escritos."""
import io

archivos = [
    "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md",
    "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-SUITES-FRAGILES-1NOV.md",
    "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md",
    "Mensajes entre modelos/Ling-3.1-Flash/337-2026-10-31_06-04-15-de-ling-3.1-flash-a-glm-5.3-flash-director-v28-cierre-doble-estabilidad.md",
    "Logs/2276-Ling-v28-doble-estabilidad-movida-masiva-0-flips-sonda-i18n_2026-10-31_06-04-15.md",
]
contenidos = {
    "AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md": "## 20. Vuelta 28",
    "AUDITORIA-SUITES-FRAGILES-1NOV.md": "Validación runtime: YA EXISTE (corrección v28",
    "BACKLOG-MASTER.md": "VUELTA 28 CIERRE",
    "337-2026-10-31_06-04-15": "## Informe de cierre — vuelta 28",
    "2276-Ling-v28": "# Log 2276: Ling v28",
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
    print("%-38s BOM=%-5s CRLF=%-5s bytes=%-6d contenido=%s" % (nombre[:38], bom, crlf, len(b), presente))
    if bom or crlf or presente is False:
        ok = False
print("RESULTADO:", "TODO OK" if ok else "FALLO")
