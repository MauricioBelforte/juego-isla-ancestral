{ ===========================================================================
  M116 - system_requirements.iss : validacion de requisitos (RF12)
  Incluido desde IslaAncestral.iss dentro de la unica seccion [Code].
  =========================================================================== }

const
  DISCO_MINIMO_MB = 5120;   { 5 GB }

function IsWindows10Or11(): Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  Result := (Version.Major >= 10);
end;

function EsSistemaX64(): Boolean;
begin
  Result := IsWin64;
end;

function HasEnoughDiskSpace(): Boolean;
var
  Libre, Total: Int64;
begin
  { GetSpaceOnDisk64 es la API correcta de Inno Setup 6.
    El esqueleto de 04-Codigo.md usaba GetDiskFreeSpaceEx, que NO existe en
    Pascal Script y no compilaria. }
  Result := GetSpaceOnDisk64(ExpandConstant('{sd}'), Libre, Total);
  if Result then
    Result := (Libre >= Int64(DISCO_MINIMO_MB) * 1024 * 1024);
end;

{ LIMITACION DOCUMENTADA (honestidad obligatoria):
  - HasEnoughRAM(): Inno Setup NO expone la memoria RAM total en Pascal Script
    (no admite structs para llamadas externas). El chequeo real de RAM vive en
    installer\verificar_requisitos.ps1, que usa CIM/.NET. No se implementa aqui
    un stub que devuelva True siempre.
  - IsDirectX11Available(): tampoco hay API de DirectX en Pascal Script. La
    deteccion real (dxdiag / registro) esta en verificar_requisitos.ps1. }

function InitializeSetup(): Boolean;
var
  Version: TWindowsVersion;
begin
  { Inno Setup llama a ESTA funcion al arrancar. Capturamos aqui la version
    previa, ANTES de que [Registry] escriba la nueva. }
  VersionPrevia := GetInstalledVersion();

  Result := True;

  if not IsWindows10Or11() then
  begin
    GetWindowsVersionEx(Version);
    MsgBox('{#AppNombre} requiere Windows 10 o superior.' + #13#10 +
           'Detectado: ' + IntToStr(Version.Major) + '.' + IntToStr(Version.Minor),
           mbCriticalError, MB_OK);
    Result := False;
    Exit;
  end;

  if not EsSistemaX64() then
  begin
    MsgBox('{#AppNombre} requiere un sistema operativo de 64 bits.', mbCriticalError, MB_OK);
    Result := False;
    Exit;
  end;

  if not HasEnoughDiskSpace() then
  begin
    MsgBox('Espacio en disco insuficiente: se requieren al menos 5 GB libres.', mbCriticalError, MB_OK);
    Result := False;
    Exit;
  end;
end;
