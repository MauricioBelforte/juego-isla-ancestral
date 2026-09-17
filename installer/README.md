# M116 — Instalador (Windows)

Pipeline de distribución de **Isla Ancestral**: export release de Godot, instalador,
desinstalador, manifiesto de integridad, firma digital y validación headless.

> **Iteración 2 — 2026-09-13 (DeepSeek-V4.1-Flash / WorkBuddy, Log 877).**
> La iteración 1 dejó `setup_windows.ps1` y `uninstall_windows.ps1` **vacíos**
> (3 bytes: solo un BOM UTF-8) mientras este README y el `05-Checklist.md` los
> daban por implementados. Esta iteración los implementa de verdad, añade el
> preset de export de Windows, los scripts de Inno Setup, la firma y un
> validador headless que impide que vuelva a pasar.

## Archivos

| Archivo | Función |
|---|---|
| `setup_windows.ps1` | Instalador user-space (sin admin). `-BuildDir`, `-InstallDir`, `-NoShortcuts`, `-DryRun`, `-Force`. Valida el build, los requisitos y el espacio; copia, crea shortcuts (escritorio + menú inicio), registra la entrada de desinstalación en HKCU y escribe `install.json` |
| `uninstall_windows.ps1` | Desinstalador. `-InstallDir`, `-DryRun`, `-Force`, `-PurgeUserData`. Elimina shortcuts, carpeta y clave de registro. **Conserva las partidas por defecto** |
| `verificar_requisitos.ps1` | Pre-flight de RAM/GPU/DirectX/SO/disco. Existe porque **Inno Setup no puede consultar RAM ni DirectX** desde Pascal Script. `-Json` para CI |
| `IslaAncestral.iss` | Script principal de Inno Setup: `[Setup]`, `[Files]`, `[Icons]`, `[Tasks]`, `[Registry]`, `[Run]`, `[UninstallDelete]` y la única sección `[Code]` |
| `system_requirements.iss` | Validación de SO/x64/disco y `InitializeSetup()` |
| `update.iss` | `GetInstalledVersion()`, `IsUpdate()`, `CurStepChanged()` (backup antes de sobrescribir) |
| `repair.iss` | `ValidateFileIntegrity()` por manifiesto, `RepairInstallation()` |
| `rollback.iss` | `BackupPreviousVersion()`, `RollbackToPreviousVersion()` |
| `code_signing.bat` | Firma con `signtool` + timestamp (RF8) |
| `license.txt` | EULA que muestra el instalador |
| `../scripts/build_installer.bat` | Encadena export → manifiesto → firma → ISCC → firma |

## Convención de build

- **Carpeta de build:** `game/build/windows/` — es la MISMA que declara el preset
  `Windows` de `game/isla-ancestral/export_presets.cfg` (`export_path =
  ../build/windows/isla-ancestral.exe`) y la que usa `setup_windows.ps1`.
  El validador comprueba esta coherencia (check V7).
- **Archivos:** `isla-ancestral.exe` (obligatorio). `isla-ancestral.pck` es
  **opcional**: con `binary_format/embed_pck=true` el paquete va embebido en el
  ejecutable. La iteración 1 exigía ambos; eso ya no aplica.
- La carpeta `game/build/` está en `.gitignore` (línea 21).

## Uso

```powershell
# Pre-flight de requisitos
powershell -ExecutionPolicy Bypass -File installer\verificar_requisitos.ps1

# Simulación (no cambia nada) — smoke del instalador
powershell -ExecutionPolicy Bypass -File installer\setup_windows.ps1 -DryRun

# Instalación real
powershell -ExecutionPolicy Bypass -File installer\setup_windows.ps1

# Desinstalación (conserva partidas)
powershell -ExecutionPolicy Bypass -File installer\uninstall_windows.ps1 -Force

# Desinstalación total, incluidos savegames
powershell -ExecutionPolicy Bypass -File installer\uninstall_windows.ps1 -Force -PurgeUserData
```

```bat
REM Pipeline completo (requiere Godot 4.x e Inno Setup 6 en PATH)
scripts\build_installer.bat
```

## Validación

El validador headless no necesita Inno Setup ni Windows SDK:

```bash
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral --script res://scripts/build/test_instalador_m116.gd
```

Resultado de la iteración 2: **15 checks, 0 fallos, 3/3 corridas, 0 SCRIPT ERROR.**
Comprueba 61 condiciones sobre el repo real (secciones del `.iss`, claves de
`[Setup]`, coherencia de versión con `project.godot`, includes, parámetros de los
`.ps1`, preset de Windows, rutas de build, licencia, firma y encoding) y además
**verifica que el propio validador detecta** un `.iss` incompleto, un `.ps1`
vacío, un `[UninstallDelete]` que borraría las partidas, una versión desalineada
y un preset ausente.

## Estado de la iteración 2

- ✅ `setup_windows.ps1` y `uninstall_windows.ps1` implementados y **ejecutados**
  en `-DryRun` (RC=0, 0 errores, sin efectos colaterales verificados).
- ✅ Preset de export `Windows` (x64, pck embebido) añadido a `export_presets.cfg`.
  Godot lo lee correctamente y el target P0 de M117 deja de estar huérfano.
- ✅ Scripts de Inno Setup, firma y build creados.
- ✅ Validador + test headless deterministas.
- ⚠️ **NO verificado:** compilación real con `ISCC.exe` (Inno Setup no está
  instalado) y firma real (requiere certificado de una CA). El validador
  comprueba la ESTRUCTURA, no que Inno Setup compile.
- ⚠️ La instalación real sobre `%LocalAppData%` (sin `-DryRun`) no se ejecutó:
  el host de agentes bloquea la creación de procesos hijos y no debe modificar
  el sistema del usuario.
- ⚠️ **Inno Setup no puede consultar RAM ni DirectX** desde Pascal Script; esos
  dos chequeos viven en `verificar_requisitos.ps1` (ver `04-Codigo.md`).
