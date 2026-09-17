; ============================================================================
;  M116 - Instalador de Isla Ancestral (Windows) - Inno Setup
;  Requiere Inno Setup 6.x (ISCC.exe).
;
;  Alcance: RF2 (instalador), RF3 (directorio), RF4 (desinstalador), RF5
;  (shortcuts), RF6 (asociacion .island), RF7 (permisos), RF9/RF13
;  (actualizacion), RF10 (reparacion), RF11 (desinstalacion), RF14 (rollback).
;
;  Diseno: instalacion USER-SPACE por defecto (sin admin) en
;  {localappdata}\IslaAncestral, coherente con installer\setup_windows.ps1.
;  El usuario puede pedir instalacion para todos los usuarios (requiere UAC).
;
;  NOTA: Inno Setup admite UNA sola seccion [Code]; por eso los modulos de
;  requisitos/actualizacion/reparacion/rollback se incluyen con #include y
;  contienen unicamente declaraciones Pascal (sin cabeceras de seccion).
; ============================================================================

#define AppNombre    "Isla Ancestral"
#define AppVersion   "0.0.6"          ; DEBE coincidir con config/version de project.godot
#define AppExe       "isla-ancestral.exe"
#define AppPck       "isla-ancestral.pck"
#define AppEditor    "Isla Ancestral"
#define BuildDir     "..\game\build\windows"

[Setup]
AppId={{7E2B9C41-5A6D-4F3B-9C08-1D2E3F4A5B60}
AppName={#AppNombre}
AppVersion={#AppVersion}
AppVerName={#AppNombre} {#AppVersion}
AppPublisher={#AppEditor}
DefaultDirName={localappdata}\IslaAncestral
DefaultGroupName={#AppNombre}
DisableProgramGroupPage=yes
OutputDir=..\game\build\installer
OutputBaseFilename=IslaAncestral-Setup-{#AppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; RF7: por defecto NO requiere administrador (user-space). El usuario puede
; elevarlo desde el dialogo si elige instalar para todos los usuarios.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
LicenseFile=license.txt
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName={#AppNombre}

[Languages]
Name: "espanol"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; El .exe es obligatorio. El .pck y las .dll pueden no existir: con
; binary_format/embed_pck=true el paquete va embebido en el .exe.
Source: "{#BuildDir}\{#AppExe}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDir}\{#AppPck}"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#BuildDir}\*.dll";    DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; Desinstalador en PowerShell (user-space), disponible tambien dentro de {app}.
Source: "uninstall_windows.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#AppNombre}";              Filename: "{app}\{#AppExe}"
Name: "{group}\Desinstalar {#AppNombre}";  Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppNombre}";        Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Registry]
; Todo en HKCU: no requiere administrador (coherente con PrivilegesRequired=lowest).
Root: HKCU; Subkey: "Software\{#AppNombre}"; ValueType: string; ValueName: "Version";    ValueData: "{#AppVersion}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\{#AppNombre}"; ValueType: string; ValueName: "InstallDir"; ValueData: "{app}";          Flags: uninsdeletevalue
; RF6: asociacion del savegame .island (HKCU\Software\Classes = sin admin).
Root: HKCU; Subkey: "Software\Classes\.island";                    ValueType: string; ValueName: ""; ValueData: "IslaAncestralSave"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\IslaAncestralSave";          ValueType: string; ValueName: ""; ValueData: "Partida guardada de {#AppNombre}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\IslaAncestralSave\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#AppExe},0"
Root: HKCU; Subkey: "Software\Classes\IslaAncestralSave\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExe}"" ""%1"""

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppNombre}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; OJO: NO borrar aqui los savegames del usuario. En este proyecto viven en
; %APPDATA%\Godot\app_userdata\isla-ancestral, fuera de {app}. El diseno previo
; (04-Codigo.md, seccion 4) los borraba, contradiciendo el requisito "el
; desinstalador conserva savegames y configuracion por defecto".
Type: filesandordirs; Name: "{app}\logs"

[Code]
; ORDEN IMPORTANTE: update.iss declara VersionPrevia y GetInstalledVersion(),
; que consumen system_requirements.iss y rollback.iss. Pascal Script no admite
; referencias hacia adelante, asi que se incluye primero.
#include "update.iss"
#include "system_requirements.iss"
#include "repair.iss"
#include "rollback.iss"
