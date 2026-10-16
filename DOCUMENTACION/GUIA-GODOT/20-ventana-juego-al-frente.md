# GUIA-GODOT 20 — Traer la ventana del juego al frente (PowerShell)

**Modelo:** GLM-5.3 Flash-Director (GLM-5.3-Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16
**Contexto:** al ejecutar el juego con `godot_run_project` (MCP), la ventana del juego aparece **detrás** de VS Code/WorkBuddy. `"AppActivate('isla-ancestral')"` matcheó el EDITOR (también contiene el nombre) — no el juego. El fundador la traía a mano con ALT+TAB. ESTA es la técnica probada que funciona sin tocar nada el humano.

## La técnica (3 bloques, probada 3 veces en una jornada)

### Paso 1 — Identificar las ventanas de los procesos Godot

```powershell
Get-Process -Name Godot* -ErrorAction SilentlyContinue | Select-Object Id, ProcessName, MainWindowTitle, MainWindowHandle | Format-Table -AutoSize | Out-String -Width 200
```

- El **editor** corre con PID propio y título `<escena> - <proyecto> - Godot Engine`.
- El **juego en DEBUG** corre con PID propio y título `<proyecto> (DEBUG)` (p.ej. `isla-ancestral (DEBUG)`).
- Buscar el título con `LIKE '*DEBUG*'` identifica al juego sin confundirlo con el editor.

### Paso 2 — Traer al frente: ALT-trick + RE-RESTORE (doble técnica)

El `SetForegroundWindow` puro a veces se bloquea por el foreground-lock de Windows. La combinación que SI funciona (usadas juntas):

```powershell
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class W32t {
  [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, UIntPtr extra);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
}
' -ErrorAction SilentlyContinue
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue

$h = <HANDLE_DEL_JUEGO>

# 1) Truco ALT: el sistema permite SetForeground si ALT estuvo presionada
[System.Windows.Forms.SendKeys]::SendWait('%')   # pulsa (aparenta) ALT
Start-Sleep -Milliseconds 150

# 2) Restaurar si esta minimizada
[W32t]::ShowWindow($h, 9) | Out-Null   # SW_RESTORE
Start-Sleep -Milliseconds 200

# 3) BringWindowToTop + SetForeground
[W32t]::BringWindowToTop($h) | Out-Null
[W32t]::SetForegroundWindow($h) | Out-Null

# 4) Refuerzo: minimize + restore inmediato del propio juego (garantizado)
[W32t]::ShowWindow($h, 6) | Out-Null   # SW_MINIMIZE
Start-Sleep -Milliseconds 250
[W32t]::ShowWindow($h, 9) | Out-Null   # SW_RESTORE
[W32t]::SetForegroundWindow($h) | Out-Null
```

### Paso 3 — Capturar la ventana (sin depender del foco)

```powershell
# Tool del entorno (Kilo/MCP): screen_capture_window con el titulo exacto
screen_capture_window(title='isla-ancestral (DEBUG)')
```

⚠️ **CUIDADO con el título:** el título de VS Code puede contener el nombre del proyecto (folder) y matchear antes que el juego. Usar el título EXACTO con `(DEBUG)` — o capturar pantalla completa después de traer al frente.

## Alternativa del fundador (la que usa)

`ALT+TAB` y navegar a la ventana manualmente — funciona siempre, pero es trabajo del humano. Con el script del paso 2 el agente lo hace **solo**.

## Errores comunes (los que me pasaron)

1. **AppActivate('isla-ancestral')** trae el **editor** porque su título contiene el nombre también. Usar el PID o el título exacto `(DEBUG)`.
2. **One-liners python con triple-quotes** rompen en PowerShell→python (el `\t` y el `'''` se pelean) — **siempre Write tool + ejecutar archivo .py**.
3. **El foco vuelve al VS Code** después del SetForeground — por eso el paso 4 (minimize/restore del propio juego) es el que garantiza.
4. El `Add-Type` hay que repetirlo **en cada bloque bash** (cada llamada es una sesión nueva — las clases no persisten entre llamadas).

## Script recompuesto completo (el que corrió exitoso)

```powershell
Add-Type '
using System;
using System.Runtime.InteropServices;
public class W32t {
  [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, UIntPtr extra);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
}
' -ErrorAction SilentlyContinue
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue

$p = Get-Process -Name Godot* -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like '*DEBUG*' } | Select-Object -First 1
if ($null -eq $p) { Write-Output "juego no encontrado"; exit 1 }
$h = $p.MainWindowHandle

[System.Windows.Forms.SendKeys]::SendWait('%')
Start-Sleep -Milliseconds 150
[W32t]::ShowWindow($h, 9) | Out-Null
Start-Sleep -Milliseconds 200
[W32t]::BringWindowToTop($h) | Out-Null
[W32t]::SetForegroundWindow($h) | Out-Null
[W32t]::ShowWindow($h, 6) | Out-Null
Start-Sleep -Milliseconds 250
[W32t]::ShowWindow($h, 9) | Out-Null
[W32t]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds 600
Write-Output "ventana del juego al frente (ALT-trick + restore) - $($p.Id)"
```

Guardar como `%-temp-%\kilo\traer_juego.ps1` y ejecutar: `powershell -NoProfile -ExecutionPolicy Bypass -File <ruta>`.

**Firma:** GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-16


## ESTADO REAL DE LA VERIFICACION (honestidad 2026-10-16 21:45 - CONFIRMADO 21:47)

- El script **corre sin errores** y la **captura de VENTANA por titulo EXACTO funciona confiable** (el backbuffer del juego se captura aunque la ventana este detras).
- La **primera** pasada: el foco volvio a VS Code/WorkBuddy despues del SetForeground (el foreground-lock de Windows bloquea a llamadores que no son el foreground).
- La ** segunda pasada (con el paso 4 activate/minimize/restore del propio juego incluido): CONFIRMADO VISUALMENTE por captura full-screen - el juego quedo AL FRENTE sobre WorkBuddy y VS Code, con el theme D102 visible (panel Controles con fondo dark legible, reloj con hora/fecha cream, hotbar con outline).
- **Leccion: el paso 4 (minimize + restore del propio juego) es OBLIGATORIO** - sin el las ventanas compiten y pierden el foreground.
- **Para capturar la UI del juego NO hace falta el al-frente** (la captura de ventana por titulo exacto basta - via usada todo el dia).
