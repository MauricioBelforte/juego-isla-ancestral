# Guía del Bucle Director (De-Director V4.1)

**Modelo:** De-Director V4.1 (DeepSeek V4.1 Flash)
**Plataforma:** OpenCode
**Fecha:** 2026-10-15 (migrado al asumir como director; original de mimo)

> **Actualización 2026-10-15:** migrado de la carpeta de `mimo-v2.6-flash-free` al asumir
> `De-Director V4.1` (tercera directiva del fundador). La metodología del bucle no cambia;
> se actualizan identidad y números de pools.

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
- Sin push (~180+ ahead).
- Verificar `git status --short` de todos los paths candidatos antes de add.

### 6. Repetir
Volver al paso 1.

---

## Pool de números (por canal)

Cada canal tiene su propio `NUMEROS_DISPONIBLES.txt`.
- **PROHIBIDO** usar `reservar_mensaje.py` (funciona mal).
- **PROHIBIDO** borrar números solo para verificar.
- Las funciones `elegir`/`borrar` del script .py ya manejan esto correctamente.
- Próximos números (2026-10-15): step-5-kilocode 423+, agnes 489+, Ling 137+, DeepSeek 262+, Step-5-WorkBuddy 47+, Hy3 221+.

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
| step-5-kilocode | Ejecución principal | M91 resto (212/239 tras 6 flips) |
| agnes-3-flash | Verificación §21.8 | QA cruzada M114 + muestreo M39 (foco i18n) |
| DeepSeek-V4.1-Flash | Deep work | M64/M160 según encargos |
| Step-5-WorkBuddy | Deep work segundo plano | M94 (asignado, msg 46) / M36-Fauna |
| Ling-3.1-Flash | QA/localización (dueño M87) | M87 (5 [?]) + curación i18n (112 claves) |
| Hy3 | Sello backup | muestreos M141 + M52 |

---

## Commits recientes de referencia

- `11c4b7f` — flips M91/M114 + degradaciones DoD (ronda 42)
- `cb2b708` — fixes estructurales GLOBAL + asignaciones (ronda 41)
- `366f398` — M06 drift cerrado + M93 auditoría WB
