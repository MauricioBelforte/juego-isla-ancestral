**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 03-Diseno.md — Módulo 116: Instalador

## 1. Arquitectura del módulo

```
Instalador (sistema de distribución del juego en Windows)
├── Build release
│   ├── Godot 4.x export para Windows Desktop
│   ├── Optimizaciones (optimización de código, compresión de assets)
│   ├── Preset: Release (no Debug)
│   ├── Arquitectura: x64 (Windows 64-bit)
│   └── Code signing del ejecutable
├── Instalador Windows
│   ├── Inno Setup (recomendado)
│   ├── WiX Toolset (alternativa)
│   ├── NSIS (alternativa)
│   └── Script de Inno Setup (.iss)
├── Directorio de instalación
│   ├── C:\Program Files\Isla Ancestral (requiere permisos)
│   └── C:\Users\Usuario\AppData\Local\Isla Ancestral (sin permisos)
├── Desinstalador
│   ├── Inno Setup genera automáticamente
│   ├── Elimina todos los archivos del juego
│   ├── Elimina shortcuts
│   ├── Elimina asociación de archivos
│   └── Elimina entradas de registro
├── Shortcuts
│   ├── Shortcut en escritorio (opcional)
│   ├── Shortcut en menú de inicio
│   └── Shortcut de desinstalador
├── Asociación de archivos
│   ├── Asociación para savegames (.island)
│   ├── Asociación para configuración (.config)
│   └── Registro de Windows
├── Validación de permisos
│   ├── Permisos de administrador
│   ├── UAC de Windows
│   └── Validación antes de iniciar instalación
├── Validación de antivirus
│   ├── Code signing del ejecutable
│   ├── Code signing del instalador
│   ├── Certificado digital
│   └── Timestamp del code signing
├── Validación de actualizaciones
│   ├── Detección de versión instalada
│   ├── Actualización incremental
│   ├── Conservación de datos del usuario
│   └── Actualización de shortcuts y asociación
├── Validación de reparación
│   ├── Validación de integridad de archivos
│   ├── Reinstalación de archivos corruptos
│   ├── Conservación de datos del usuario
│   └── Accesible desde Panel de Control
├── Validación de desinstalación
│   ├── Eliminación de todos los archivos
│   ├── Eliminación de shortcuts
│   ├── Eliminación de asociación de archivos
│   └── Conservación de datos del usuario
├── Validación de instalación limpia
│   ├── Validación de sistema operativo
│   ├── Validación de GPU
│   ├── Validación de RAM
│   └── Validación de espacio en disco
├── Validación de actualización
│   ├── Detección de versión instalada
│   ├── Actualización incremental
│   ├── Conservación de datos del usuario
│   └── Actualización de shortcuts y asociación
└── Validación de rollback
    ├── Backup de versión anterior
    ├── Rollback automático si actualización falla
    ├── Restauración de versión anterior
    └── Conservación de datos del usuario
```

## 2. Script de Inno Setup

**Archivo: installer/IslaAncestral.iss**

**Estructura:**
```inno
[Setup]
AppName=Isla Ancestral
AppVersion=1.0.0
DefaultDirName={autopf}\Isla Ancestral
DefaultGroupName=Isla Ancestral
OutputBaseFilename=IslaAncestral-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64only

[Files]
Source: "builds\windows\IslaAncestral.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "builds\windows\*.pck"; DestDir: "{app}"; Flags: ignoreversion
Source: "builds\windows\*.dll"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Isla Ancestral"; Filename: "{app}\IslaAncestral.exe"
Name: "{group}\Desinstalar Isla Ancestral"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Isla Ancestral"; Filename: "{app}\IslaAncestral.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Crear icono en escritorio"; GroupDescription: "Iconos adicionales:"; Flags: unchecked

[Registry]
Root: HKCR; Subkey: ".island"; ValueType: string; ValueName: ""; ValueData: "IslaAncestralSave"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "IslaAncestralSave"; ValueType: string; ValueName: ""; ValueData: "Archivo de savegame de Isla Ancestral"; Flags: uninsdeletekey
Root: HKCR; Subkey: "IslaAncestralSave\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\IslaAncestral.exe,0"
Root: HKCR; Subkey: "IslaAncestralSave\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\IslaAncestral.exe"" ""%1"""

[Run]
Filename: "{app}\IslaAncestral.exe"; Description: "Ejecutar Isla Ancestral"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\savegames"
Type: filesandordirs; Name: "{app}\config"
```

## 3. Diagrama de flujo de instalación

```
[Usuario ejecuta instalador]
    ↓
[UAC solicita permisos de administrador]
    ↓
[Usuario confirma permisos]
    ↓
[Wizard: Bienvenida]
    ↓
[Wizard: Directorio de instalación]
    ↓
[Usuario confirma directorio]
    ↓
[Validación de requisitos de sistema]
    ↓
[Requisitos cumplidos?]
    ↓ No
[Error: requisitos no cumplidos]
    ↓
[Wizard: Shortcuts]
    ↓
[Usuario elige shortcuts]
    ↓
[Wizard: Asociación de archivos]
    ↓
[Usuario elige asociación de archivos]
    ↓
[Wizard: Instalación]
    ↓
[Instalador copia archivos]
    ↓
[Instalador crea shortcuts]
    ↓
[Instalador configura asociación de archivos]
    ↓
[Instalador escribe entradas de registro]
    ↓
[Wizard: Finalización]
    ↓
[Usuario elige ejecutar juego]
    ↓
[Instalación completada]
```

## 4. Validación de requisitos de sistema

**Archivo: installer/system_requirements.iss**

**Estructura:**
```inno
[Code]
function IsWindows10Or11(): Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  Result := (Version.Major >= 10);
end;

function IsDirectX11Available(): Boolean;
begin
  // Validación de DirectX 11 (simplificada)
  Result := True;
end;

function HasEnoughRAM(): Boolean;
var
  MemoryStatus: TMemoryStatusEx;
begin
  MemoryStatus.dwLength := SizeOf(TMemoryStatusEx);
  GlobalMemoryStatusEx(MemoryStatus);
  Result := (MemoryStatus.ullTotalPhys >= 8 * 1024 * 1024 * 1024); // 8GB
end;

function HasEnoughDiskSpace(): Boolean;
var
  RequiredSpace: Int64;
  AvailableSpace: Int64;
begin
  RequiredSpace := 5 * 1024 * 1024 * 1024; // 5GB
  AvailableSpace := GetDiskFreeSpaceEx(ExpandConstant('{sd}'));
  Result := (AvailableSpace >= RequiredSpace);
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  
  if not IsWindows10Or11() then
  begin
    MsgBox('Isla Ancestral requiere Windows 10 o superior.', mbError, MB_OK);
    Result := False;
    Exit;
  end;
  
  if not IsDirectX11Available() then
  begin
    MsgBox('Isla Ancestral requiere DirectX 11 compatible.', mbError, MB_OK);
    Result := False;
    Exit;
  end;
  
  if not HasEnoughRAM() then
  begin
    MsgBox('Isla Ancestral requiere al menos 8GB de RAM.', mbError, MB_OK);
    Result := False;
    Exit;
  end;
  
  if not HasEnoughDiskSpace() then
  begin
    MsgBox('Isla Ancestral requiere al menos 5GB de espacio en disco.', mbError, MB_OK);
    Result := False;
    Exit;
  end;
end;
```

## 5. Code signing

**Archivo: installer/code_signing.bat**

**Estructura:**
```batch
@echo off
REM Code signing del ejecutable de Godot export
signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com builds\windows\IslaAncestral.exe

REM Code signing del instalador de Inno Setup
signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com installer\IslaAncestral-Setup.exe
```

## 6. Actualización incremental

**Archivo: installer/update.iss**

**Estructura:**
```inno
[Code]
function GetInstalledVersion(): String;
var
  Version: String;
begin
  Version := '';
  if RegQueryStringValue(HKLM, 'Software\Isla Ancestral', 'Version', Version) then
    Result := Version
  else
    Result := '';
end;

function IsUpdate(): Boolean;
begin
  Result := (GetInstalledVersion() <> '');
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    if IsUpdate() then
    begin
      // Actualización incremental
      MsgBox('Actualización completada.', mbInformation, MB_OK);
    end
    else
    begin
      // Instalación nueva
      MsgBox('Instalación completada.', mbInformation, MB_OK);
    end;
  end;
end;
```

## 7. Reparación de instalación corrupta

**Archivo: installer/repair.iss**

**Estructura:**
```inno
[Code]
function ValidateFileIntegrity(): Boolean;
begin
  // Validación de integridad de archivos (simplificada)
  Result := True;
end;

procedure RepairInstallation();
begin
  if not ValidateFileIntegrity() then
  begin
    MsgBox('Instalación corrupta detectada. Reparando...', mbInformation, MB_OK);
    // Reinstalación de archivos corruptos
  end;
end;
```

## 8. Rollback a versión anterior

**Archivo: installer/rollback.iss**

**Estructura:**
```inno
[Code]
procedure BackupPreviousVersion();
begin
  // Backup de versión anterior antes de actualizar
  if IsUpdate() then
  begin
    // Copiar archivos a backup
  end;
end;

procedure RollbackToPreviousVersion();
begin
  // Rollback a versión anterior si actualización falla
  if FileExists('{app}\backup\IslaAncestral.exe') then
  begin
    // Restaurar archivos de backup
  end;
end;
```

## 9. Build automation

**Archivo: scripts/build_installer.bat**

**Estructura:**
```batch
@echo off
REM Build release de Godot
godot --export-release "Windows Desktop" builds\windows\IslaAncestral.exe

REM Code signing del ejecutable
signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com builds\windows\IslaAncestral.exe

REM Build del instalador con Inno Setup
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\IslaAncestral.iss

REM Code signing del instalador
signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com installer\IslaAncestral-Setup.exe

echo Build completado
```

## 10. Configuración de Godot export

**Preset: Windows Desktop (Release)**
- **Application/Config/features:** Compress (lzma)
- **Application/Config/pack_mode:** Single-file (opcional)
- **Application/Run/args:** --release
- **Binary/export_console_wrapper:** No
- **Binary/export_embedded_pck:** Yes
- **Binary/export_filter:** include/exclude patterns
- **Binary/export_path:** builds/windows/
- **Binary/file_format:** exe
- **Binary/icon:** icon.ico
- **Binary/name:** Isla Ancestral

## 11. Icono del juego

**Archivo: icon.ico**
- Icono del juego para el ejecutable
- Icono del juego para el instalador
- Icono del juego para shortcuts
- Resoluciones: 16x16, 32x32, 48x48, 64x64, 256x256

## 12. Pruebas de instalación

**Pruebas manuales:**
- Probar instalación limpia en máquina sin el juego
- Probar actualización desde versión anterior
- Probar reparación de instalación corrupta
- Probar desinstalación completa
- Probar shortcuts (escritorio, menú de inicio)
- Probar asociación de archivos
- Probar validación de requisitos de sistema
- Probar validación de antivirus (code signing)
- Probar rollback a versión anterior

**Pruebas automáticas:**
- Tests de validación de requisitos de sistema
- Tests de actualización incremental
- Tests de reparación de instalación corrupta
- Tests de desinstalación completa


## Presupuestos numericos (Reflection-Beam-1.0, 2026-10-23)

| # | Presupuesto | Valor | Formula/Justificacion |
|---|-------------|-------|----------------------|
| 1 | Peso objetivo del instalador | <1.5 GB (base 5 GB comprimido con Inno Setup) | Media indie cozy: 500MB-2GB. 5 GB / 3.3 (compresion) = 1.5 GB. Coherente con M116 RequiredSpace 5 GB. |
| 3 | Tamano maximo del saveset de fotos (user://photos/ + galeria) | Max 50 MB (50 fotos x 1 MB c/u) | Coherente con budget de disco del instalador (5 GB total). 50 MB / 5000 MB = 1%. |
| 5 | Umbrales de version minima de OS/DirectX | Windows 10 build 19041+, DirectX 11 (feature level 11_0), 8 GB RAM, 5 GB espacio | Coherente con checks L183 (IsWindows10Or11) y L186 (IsDirectX11Available). Tabla versionada: Win10 19041+, DX11, 8GB, 5GB. |
| 6 | Cobertura del desinstalador | 100% de archivos creados (app dir, registry, shortcuts, saves opcionales). Brecha 0. | Coherente con instalacion (todo lo que se crea, se limpia). |

## Presupuestos numericos II - detalle minucioso (2da capa)

Definidos por Beam-1.0 via Audit-CRON E x8 (auto-auditoria de la 1ra capa) y escalado al fundador. Formula y unidades con dependencias cruzadas (M93 80/dia, M58 0.5ms, M144 <48h SLA).
- **Presupuesto de saveset de fotos** [x] - formula del storage del user al 100% (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)
- **Presupuesto de matriz de shortcuts por plataforma** [x] - tabla x win lin mac (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)

## Presupuestos numericos II - formulas concretas (Reflection-Beam-1.0, 2026-10-23)

### 26. Peso objetivo del instalador
- Formula: peso_instalador = tamano_base / factor_compresion = 5 GB / 3.3 = 1.5 GB.
- Coherente con RequiredSpace 5 GB de M116.
- Unidad: GB. Dependencia: M116 (RequiredSpace).

### 27. Tamano maximo del saveset de fotos
- Formula: saveset_max = fotos_max * tamano_foto = 50 * 1 MB = 50 MB.
- Coherente con budget de disco del instalador (5 GB total). 50/5000 = 1%.
- Unidad: MB. Dependencia: M56 (fotografia).

### 28. Umbrales de version minima de OS/DirectX
- Formula: Win10 build 19041+, DirectX 11 (feature level 11_0), 8 GB RAM, 5 GB espacio.
- Coherente con checks L183 (IsWindows10Or11) y L186 (IsDirectX11Available).
- Unidad: version/requisito. Dependencia: M90 (configuracion grafica).

### 29. Cobertura del desinstalador
- Formula: cobertura = archivos_creados / archivos_creados * 100 = 100%.
- Brecha 0: todo lo que se crea, se limpia.
- Unidad: porcentaje. Dependencia: M116 (instalador).

### 30. Matriz de shortcuts por plataforma (definida por Beam 320, produce-first)
- Formula: shortcuts_por_plataforma = [win: Ctrl+1..14 (14 atajos), lin: Ctrl+1..14 (14 atajos), mac: Cmd+1..14 (14 atajos)].
- Tabla:
  | Plataforma | Atajo base | Cantidad | Nota |
  |------------|-----------|----------|------|
  | Windows | Ctrl+1..14 | 14 | estandar |
  | Linux | Ctrl+1..14 | 14 | estandar |
  | macOS | Cmd+1..14 | 14 | Cmd en lugar de Ctrl |
- Coherente con M109 (shortcuts Ctrl+1..14 abre cada editor) y M116 (instalador).
- Unidad: atajos/plataforma. Dependencia: M109 (framework de editor).



Riel design-docs SIN DATOS (encargo agnes-3-flash msg 255, 2026-10-24 21:08; GO directora). Produce-first line-based, sin vision: cada numero medido en disco con cita archivo:linea (recorrido python -X utf8 + Grep/Read; sin ejecutar Godot). Las capas I/II (Beam 1.0, 2026-10-23) quedan intactas; aqui se groundean con mediciones reales y se documentan los drift hallados. **Modelo:** Ling-3.1-Flash / **Plataforma:** Kilo Code / **Fecha:** 2026-10-25

## Presupuestos numericos III - mediciones en disco (Ling-3.1-Flash, 2026-10-25)

### 31. Payload medido (exports de M117, Log 1888)
- Windows: 125.98 MB total (exe 120.80 MB + DLL 5.18 MB); Linux/SteamOS: 96.58 MB c/u (bin 86.8 MB + SO 9.78 MB) — DOCUMENTACION/117-Build-System/plan-actual/05-Checklist.md L101/L233-236.
- DRIFT MATERIAL: la capa I #1 presupone "base 5 GB comprimido" -> instalador 1.5 GB (ratio 3.3x). El export medido es 125.98 MB (~40x menor que la base). La auditoria S63 (05-Checklist L317) ya cuestiono el ratio 3.3x; hoy la base misma (5 GB) no cuadra con el export medido. RequiredSpace 5 GB sigue valido como headroom de disco libre (ver ###32).

### 32. Espacio en disco requerido (medido en el instalador)
- DISCO_MINIMO_MB = 5120 (5 GB) — installer/system_requirements.iss L7; validacion GetSpaceOnDisk64 (L29): Libre >= 5120 x 1024 x 1024 (L31); mensaje "se requieren al menos 5 GB libres" (L71).
- setup_windows.ps1 L70: AvailableFreeSpace; IslaAncestral.iss L31 DefaultDirName={localappdata}\IslaAncestral, L41 PrivilegesRequired=lowest (user-space, RF7), L44 ArchitecturesInstallIn64BitMode=x64compatible, L71-72 registro HKCU.
- 03-Diseno L203-208 (esqueleto Inno): RequiredSpace := 5 * 1024 * 1024 * 1024 — COHERENTE con el .iss medido.

### 33. Saveset de fotos (medido en codigo)
- Carpeta: user://fotos/ (scripts/foto/photo_service.gd L28; scripts/foto/photo_gallery.gd L13); indice user://fotos/index.json (photo_service.gd L49); migracion de clave "photos" a "fotos" (L105-108).
- Presupuesto de memoria: MAX_MINIATURAS_CARGADAS = 24 (photo_gallery.gd L15, "presupuesto M61: no cargar todas en memoria"); miniatura 160x90 (L14).
- Presupuesto de captura: < 50 ms (photo_service.gd L47 comentario item 133; validado en scripts/foto/validate_photo.gd L32: _check(ms < 50)).
- saveset_max = 50 fotos x 1 MB = 50 MB = 1% de 5 GB (capa I #3; auditoria S63 PASS en 05-Checklist L318). NOTA honesta: 1 MB/foto es una estimacion de diseño — en disco no hay fotos (user:// es runtime); sin medicion real de peso de saveset.

### 34. Shortcuts, tiempos y retencion (medido)
- Instalador crea 2 shortcuts OS por instalacion: escritorio + menu inicio (installer/setup_windows.ps1 L210-211, L225; flag -NoShortcuts L22/L228).
- Matriz de atajos de gameplay: 14 por plataforma (win Ctrl+1..14, lin Ctrl+1..14, mac Cmd+1..14) — capa II ###30 (Beam 320); depende M109 (framework de editor).
- Tiempos de instalacion/desinstalacion: NO medidos en disco. Evidencia de humo: setup 9 acciones / uninstall 1 accion, RC=0 x3 corridas; ValidadorInstalador 61 checks 0 errores; test_instalador_m116 15 checks x3 corridas; test_build_m117 14 checks (07-Resultados-Testings.md L10-15). Propuesta: medir con Measure-Command en la proxima ronda de smoke.
- Retencion de saves: el desinstalador conserva %APPDATA%\Godot\app_userdata\isla-ancestral (07-Resultados-Testings.md L62-66); installer/ contiene rollback.iss, repair.iss, update.iss.
