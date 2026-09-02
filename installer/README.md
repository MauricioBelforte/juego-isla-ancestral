# M116 — Instalador (iter 1, deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02)

Scripts de instalación/desinstalación para Windows (user-space, sin admin) y convención de build.

## Archivos

| Archivo | Función |
|---|---|
| `setup_windows.ps1` | Instala el build a `%LocalAppData%\IslaAncestral` (o `-InstallDir`); shortcuts (escritorio + menú inicio, `-NoShortcuts` para omitir); valida archivos críticos (exe+pck) antes de copiar; `-DryRun` simula todo sin cambios |
| `uninstall_windows.ps1` | Desinstala: shortcuts + directorio completo; `-DryRun` simula; pide confirmación (`-Force` para autocompletar) |

## Uso

```powershell
# Simulación (no cambia nada) — smoke del instalador
powershell -executionpolicy bypass -File installer\setup_windows.ps1 -BuildDir .\build -DryRun

# Instalación real (desde la carpeta de build)
powershell -executionpolicy bypass -File installer\setup_windows.ps1 -BuildDir .\build

# Desinstalación
powershell -executionpolicy bypass -File installer\uninstall_windows.ps1
```

## Convención de build (coherente con M117/M118)

- Compilación de exportación: `game/isla-ancestral/.build/` (Windows 64, preset release — dueño M117/M118).
- El instalador valida `isla-ancestral.exe` + `isla-ancestral.pck` como archivos críticos (si faltan → exit 1, RF12 instalación limpia).

## Estado de la iteración 1

- ✅ Scripts creados (RF2-RF5 cubiertos en el alcance): instalador, desinstalador, shortcuts, dry-run.
- ✅ Parse verificado (sin ParserError tras BOM UTF-8).
- [?] Smoke de ejecución en consola real (ventana de PowerShell normal) — el host de herramientas de los agentes no captura el host-stream de scripts .ps1; no bloquea el entregable.
- [?] Distribución empaquetada (MSI/Inno) y validaciones RF8-RF13 (antivirus, actualización, reparación): alcance de la iteración 2 (requiere build release de M117/M118).
