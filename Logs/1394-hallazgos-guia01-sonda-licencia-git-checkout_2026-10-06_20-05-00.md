# Log 1394: Hallazgos M88 documentados en GUIA-GODOT/01 (§32 sonda de licencia, §33 git checkout Windows)

**Fecha:** 2026-10-06
**Hora:** 20:05
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** OpenCode

## Resumen

Se documentaron en `DOCUMENTACION/GUIA-GODOT/01-gdscript-errores-comunes.md` los 2
hallazgos de M88 aprobados por el director (msg 38 §4 / msg 42 §5): la trampa de la sonda
de licencia con reemplazo global (falso verde que silencia la whitelist) y el workaround
Windows de `git checkout` «unable to unlink» vía `git show HEAD:` + escritura binaria.

## Cambios Realizados

- **§32 "Sonda de licencia: el reemplazo global muta la whitelist y da falso verde"**:
  sintoma (gate exit 0 en vez de exit 1), causa (`licencias_permitidas` mutada junto al
  caso), solucion (replace con `count=1`), regla general (la sonda muta el CASO, nunca el
  ESTANDAR que lo juzga) y control de salud (rojo verificado obligatorio).
- **§33 "`git checkout -- archivo` falla con 'unable to unlink' en Windows"**: sintoma,
  causa (handles de Godot/antivirus en Windows), solucion (git show HEAD + escritura `wb`),
  fallback (cerrar Godot) y nota de proceso (respaldar cambios propios antes de restaurar).
- 2 filas nuevas en la tabla "Errores rápidos de referencia" (§32, §33).
- Header del archivo: Fecha e Histórico actualizados (firma del ultimo modificador).
- Verificacion: UTF-8 estricto, 0 secuencias mojibake, sin BOM, 779 lineas (antes 693).

## Archivos Modificados/Creados

- DOCUMENTACION/GUIA-GODOT/01-gdscript-errores-comunes.md (+86 lineas)
- DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md
- Mensajes entre modelos/ESTADO-PARALELO.md
- Mensajes entre modelos/mimo-v2.6-flash-free/43-...-mimo-a-atria-informe-hallazgos-guia01.md
