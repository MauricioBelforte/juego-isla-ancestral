# Log 162: Auditoría de seguridad de skills (69 SKILL.md + ~1500 scripts)

**Fecha:** 2026-08-25
**Hora:** 21:25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
Se auditaron las 69 skills instaladas en `.claude/skills/` en busca de código malicioso o prompt injection. Resultado: **TODAS seguras y legítimas**. No hay malware, exfiltración de datos, ni instrucciones de prompt injection.

## Metodología
1. **Lectura manual de los 69 `SKILL.md`** uno por uno (es el contenido que se inyecta al contexto del agente — superficie principal de prompt injection). Todas resultaron ser guías profesionales de Godot 4.7 / Blender con referencias a documentación oficial.
2. **Escaneo automatizado** de los ~1500 archivos de script (.gd, .gdshader, .py, .ps1, .sh, .js, .json) con `audit_skills.py`, buscando 15 patrones de riesgo (OS.execute, subprocess, HTTP, os.remove, eval/exec, base64, credenciales, sockets, descargas).
3. **Verificación manual** de los hallazgos de mayor apariencia de riesgo.

## Hallazgos (87 coincidencias, todas benignas)
- `subprocess` en `godot-agent-vision/capture.py` y `godot-builder/*.py`: invocan Godot headless (patrón legítimo de build).
- `os.remove` en `godot-builder/*.py`: borran el script temporal `.gd` generado y enviado a Godot (limpieza).
- `JavaScriptBridge.eval(...)` en scripts web: **API oficial de Godot** para web, NO Python `eval`.
- `OS.shell_open` / `OS.execute_with_pipe` en platform-desktop/web: APIs oficiales para abrir URLs y tooling.
- `curl` en `vfx_shader_manager.gd`: es "**Curl Noise**" (técnica de shader), no el comando.
- `HTTPRequest` en export/patch/matchmaker: descargas de parches/frames con dominios de *ejemplo* (`api.game.com`, `cdn.game.com`).
- Scripts `.ps1` de export (powershell): automatización legítima de build.

## Conclusión de seguridad
- **Sin exfiltración:** ninguna URL apunta a un servidor real potencialmente malicioso; solo dominios de ejemplo y documentación oficial de Godot.
- **Sin borrado masivo:** `os.remove`/`shutil.rmtree` solo limpian archivos temporales generados por los propios scripts.
- **Sin prompt injection:** ningún SKILL.md contiene órdenes tipo "ignora instrucciones previas", "no digas esto", "override del system prompt", ni monetización oculta.
- **Dominios legítimos:** docs.godotengine.org, godotengine.org, github.com, skills.sh. `*.game.com` son placeholders de ejemplo.

## Archivos Modificados/Creados
- `tools/mcp/godot-mcp/scripts-prueba/audit_skills.py` (nuevo, herramienta de auditoría reutilizable para futuras skills)
- `Logs/162-Auditoria-Skills-Seguridad-2026-08-25.md` (nuevo)