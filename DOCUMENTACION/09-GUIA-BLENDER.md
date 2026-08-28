# 09 — Guía Blender

**Modelo:** GLM
**Plataforma:** Cline
**Fecha:** 2026-08-27

> **Propósito:** Guía de referencia obligatoria para modelar assets con Blender vía scripting (bpy), análoga a `07-GUIA-GODOT.md`. Documenta errores comunes, convenciones, la conexión MCP (V5) y el registro de errores. **Todo agente que modele assets DEBE leerla antes de empezar** y agregar aquí cada descubrimiento nuevo (regla AGENTS.md §26 aplicada a Blender).

---

## 1. Conexión con Blender (V5)

La vía V5 usa Blender en modo servidor + un cliente Python de la venv del proyecto. **No requiere addon de terceros**: Blender corre headless con un socket que ejecuta código `bpy` enviado por el cliente.

| Pieza | Ruta (`tools/mcp/blender-mcp/scripts-reutilizables/`) | Función |
|---|---|---|
| Servidor | `arrancar_servidor_mcp.py` | Arranca Blender 4.2 headless, socket `127.0.0.1:9876` |
| Cliente | `bpy_cliente.py` | `blender_command('execute_code', {'code': ...})` |
| Captura | `cap_blender.py` | Screenshot offscreen del viewport → PNG en `capturas/` |
| Ejemplo | `crear_palmera_lowpoly.py` | Asset reutilizable completo |

### Flujo estándar (PowerShell)

```powershell
# 1) Arrancar servidor (si el puerto 9876 no está escuchando)
& 'D:\Archivos de programa\Blender Foundation\Blender 4.2\blender.exe' -b --python tools/mcp/blender-mcp/scripts-reutilizables/arrancar_servidor_mcp.py &

# 2) Ejecutar un script dentro de Blender
& 'tools/mcp/.venv/Scripts/python.exe' -c "import sys, json; sys.path.insert(0, r'tools/mcp/blender-mcp/scripts-reutilizables'); from bpy_cliente import blender_command; code = open(r'<SCRIPT>.py', encoding='utf-8').read(); print(json.dumps(blender_command('execute_code', {'code': code})))"

# 3) Capturar resultado (SIEMPRE, timestamp nuevo — nunca sobrescribir)
& 'tools/mcp/.venv/Scripts/python.exe' 'tools/mcp/blender-mcp/scripts-reutilizables/cap_blender.py' "tools/mcp/blender-mcp/capturas/{ID-Modulo}-Nombre/cap_{ID}_{AAAA-MM-DD_HH-MM-SS}_nota.png"
```

### Reglas
- Verificar puerto 9876 antes de enviar código.
- Capturas en `capturas/{ID-Modulo}-Nombre/` con timestamp; conservar la anterior como comparativa (AGENTS.md §24).

## 2. Convenciones de código bpy

- **Nombres tipo Godot:** prefijos `SM_` (static mesh), `M_` (mesh data), `MAT_` (materiales). Facilita exportar sin renombrar.
- **Una malla por pieza estructural:** preferir `bmesh` (una malla) antes que apilar primitivas de `bpy.ops` (ver E-01).
- **Materiales lowpoly:** nombres claros y roughness alto.
- **Escena de prueba:** incluir `CAM_<Asset>` encuadrada + sol rasante para validar sombras en cada captura.
- **Idempotencia:** el script debe limpiar la escena para poder re-ejecutarse sin duplicar.
- **Guardado:** terminar con `bpy.ops.wm.save_as_mainfile(filepath=...)` a `trabajos/`.

## 3. Registro de Errores

> Formato: síntoma / causa / solución / fecha. Agregar TODO descubrimiento nuevo (obligatorio, AGENTS.md §26).

### E-01 — Tronco "escalonado" al apilar cilindros
- **Síntoma:** tronco curvado con N cilindros de `primitive_cylinder_add` apilados muestra escalones/huecos en cada unión, aún solapando y reduciendo el giro.
- **Causa:** cada cilindro tiene sus rings de tapa; al decrecer el radio, la silueta muestra cada unión. Inherente a la técnica.
- **Solución:** construir el tronco como **UNA sola malla con `bmesh`**: rings de vértices interpolados sobre la curva (radio y posición en función de `t`), puenteados con caras laterales + tapas. Bonus: 15 objetos vs 24.
- **Fecha:** 2026-08-27

### E-02 — `NameError: name 'cos' is not defined` (código remoto)
- **Causa:** el script usaba `cos()` sin importarla (`from math import radians, sin, pi`). El error solo aparece al ejecutar en el namespace remoto.
- **Solución:** importar todas las funciones de `math` usadas. Validar imports antes de enviar.
- **Fecha:** 2026-08-27

### E-03 — Captura cenital / sin materiales / con grilla
- **Causa:** viewport por defecto sin cámara activa ni modo renderizado.
- **Solución:** el script crea `CAM_<Asset>` con encuadre fijo; `cap_blender.py` captura offscreen desde esa cámara, overlays off, modo Rendered.
- **Fecha:** 2026-08-27

## 4. Checklist antes de dar por terminado un asset

- [ ] Script idempotente (re-ejecutable sin duplicar)
- [ ] Mínima cantidad de mallas posible
- [ ] Materiales `MAT_*` con roughness acorde
- [ ] Escena de prueba con cámara + sol (sombra visible)
- [ ] `.blend` guardado en `trabajos/`
- [ ] Captura con timestamp en `capturas/{ID-Modulo}-Nombre/` (conservar la anterior)
- [ ] Hallazgos nuevos en §3 con fecha
- [ ] Log en `Logs/`

## 5. Caso de estudio: palmera lowpoly (2026-08-27)

- Tronco: tubo curvo único bmesh (radio 0.30→0.18, curvatura `x = 0.70·t²`, altura 3.9).
- 7 frondas: tiras de vértices, ancho `sin(πs)^0.6`, caída parabólica; alternando largo.
- 3 cocos: ico-esferas (subdiv 1) bajo la corona.
- Evidencia: `capturas/154-Vision-Del-Agente/cap_154_2026-08-27_23-09-22_palmera-07.png` (final) + historial 01–06.

- Los `.blend` se guardan en `tools/mcp/blender-mcp/trabajos/`.
