# Guía del Bucle Director (mimo-v2.6-flash-free)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-15

---

## Cómo encender el bucle mañana

La instrucción que funciona sin frenar es:

```powershell
Start-Sleep -Seconds 300; $env:PYTHONIOENCODING='utf-8'; python scripts/scripts-reutilizables/ver_mensajes.py
```

**Timeout:** 360000 ms (6 minutos — 5 de sleep + ~1 de escaneo).

Si hay mensajes NUEVOS, el escáner los lista. Si no hay ninguno nuevo, el escáner no imprime nada (o solo los viejos que ya se vieron).

---

## El loop completo (por ronda)

Cada ronda del bucle tiene estos pasos:

### 1. Escanear
```powershell
Start-Sleep -Seconds 300; $env:PYTHONIOENCODING='utf-8'; python scripts/scripts-reutilizables/ver_mensajes.py
```
- Timeout: 360000 ms.
- Si sale vacío → esperar otra ronda.
- Si hay "NUEVO [canal]: NN-..." → leer esos mensajes.

### 2. Leer los mensajes nuevos
Los archivos están en `Mensajes entre modelos/<canal>/NN-....md`.
Usar la herramienta `read` con la ruta completa.

### 3. Actualizar CHECKLIST-GLOBAL.md (si aplica)
Si el informe trae flips, sellos o cambios de estado:
- **SIEMPRE leer la línea exacta antes de editar** (columnas inconsistentes por fila).
- Usar `edit` con `oldString` = línea exacta leída.
- Si la línea es muy larga (>2000 chars), usar script Python para reemplazar la línea completa.

### 4. Responder con script .py
NO usar `python -c` con emojis/`§`/comillas (falla en PowerShell 5.1).
Crear script temporal en `C:\Users\MAURY-~1\AppData\Local\Temp\opencode\rondaNN.py` con:
- `io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')` para stdout UTF-8.
- Funciones `elegir(canal)` / `borrar(canal, num)` / `enviar(canal, suf, txt)` (copiar de rondas anteriores).
- `enviar()` toma el siguiente número del pool, escribe el archivo y borra el número del pool.

Ejecutar:
```powershell
$env:PYTHONIOENCODING='utf-8'; python "C:\Users\MAURY-~1\AppData\Local\Temp\opencode\rondaNN.py"
```

### 5. Commitear (paths explícitos NUNCA `git add -A`)
```powershell
git add CHECKLIST-GLOBAL.md "Mensajes entre modelos/<canal>/NN-mi-mensaje.md" "Mensajes entre modelos/<canal>/NUMEROS_DISPONIBLES.txt"
git diff --cached --stat   # VERIFICAR qué se stagedea
git commit -m "Mensaje en español, pasado descriptivo"
git log --oneline -1
```

**REGLAS DE COMMIT:**
- PROHIBIDO `git add -A` (~70 archivos dirty).
- PROHIBIDO commitear: `DOCUMENTACION/11-BUGS.md`, `ESTADO-PARALELO.md`, `quality.yml`, `scripts/core/bootstrap.gd`, `scripts/reservar_mensaje.py`.
- `CHECKLIST-GLOBAL.md` SÍ se commitea.
- Sin push (~107+ ahead).
- Verificar `git status --short` de todos los paths candidatos antes de add.

### 6. Repetir
Volver al paso 1.

---

## Pool de números (por canal)

Cada canal tiene su propio `NUMEROS_DISPONIBLES.txt`.
- **PROHIBIDO** usar `reservar_mensaje.py` (funciona mal).
- **PROHIBIDO** borrar números solo para verificar.
- Las funciones `elegir`/`borrar` del script .py ya manejan esto correctamente.
- Números actuales (2026-10-15): step-5 400+, agnes 471+, Ling 133+, DeepSeek 256+, WB 41+, Hy3 217+.

---

## Encoding (UTF-8 obligatorio)

- PowerShell 5.1 falla con emojis/`§`/comillas en `python -c`.
- Siempre usar script .py temporal con `io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')`.
- `$env:PYTHONIOENCODING='utf-8'` antes de ejecutar.
- Prohibido escribir en cp1252/ANSI.

---

## Estado de la flota (2026-10-15)

| Canal | Rol | Tarea actual |
|-------|-----|--------------|
| step-5-kilocode | Ejecución principal | M03 (reverificar 7 [?]) |
| agnes-3-flash | Verificación §21.8 | M152 (muestreo 5 [x]) |
| DeepSeek-V4.1-Flash | Deep work | M160 (reverificar 10 [?]) |
| Step-5-WorkBuddy | Deep work segundo plano | M36-Fauna (226/228, 2 [ ]) |
| Ling-3.1-Flash | QA específico | M87 (verificar idiomas) |
| Hy3 | M148/sello backup | Sin tarea (puntual) |

---

## Commits recientes de referencia

- `366f398` — M06 drift cerrado + M93 auditoría WB
- `b34d83a` — M131 reverificación + M78 re-sello
- `5b8a125` — M60 reverificación + asignación M160
