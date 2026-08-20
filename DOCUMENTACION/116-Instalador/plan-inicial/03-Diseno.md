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
