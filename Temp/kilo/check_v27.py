# -*- coding: utf-8 -*-
"""Verificacion v27: encoding (UTF-8 sin BOM, LF) + contenidos esperados de los 5 escritos."""
import io

archivos = [
    "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md",
    "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-SUITES-FRAGILES-1NOV.md",
    "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md",
    "Mensajes entre modelos/Ling-3.1-Flash/336-2026-10-31_05-09-24-de-ling-3.1-flash-a-glm-5.3-flash-director-v27-cierre-estabilidad-i18n-bug152-wiring.md",
    "Logs/2275-Ling-v27-estabilidad-detector-sonda-i18n-bug152-wiring_2026-10-31_05-09-24.md",
]
contenidos = {
    "AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md": "## 19. Vuelta 27",
    "AUDITORIA-SUITES-FRAGILES-1NOV.md": "## 9. Re-verificación v27",
    "BACKLOG-MASTER.md": "VUELTA 27 CIERRE",
    "336-2026-10-31_05-09-24": "## Informe de cierre — vuelta 27",
    "2275-Ling-v27": "# Log 2275: Ling v27",
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
