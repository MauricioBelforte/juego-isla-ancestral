{ ===========================================================================
  M116 - update.iss : deteccion de version instalada y actualizacion (RF9/RF13)
  Incluido desde IslaAncestral.iss dentro de la unica seccion [Code].
  Sin cabecera de seccion a proposito (Inno Setup admite una sola [Code]).

  Se incluye PRIMERO porque declara los globales compartidos y las funciones
  que consumen los otros modulos.
  =========================================================================== }

var
  VersionPrevia: String;   { version instalada ANTES de esta ejecucion }

{ Lee la version instalada del registro (HKCU, coherente con PrivilegesRequired=lowest).
  Devuelve '' si no hay instalacion previa. }
function GetInstalledVersion(): String;
var
  Version: String;
begin
  Version := '';
  if not RegQueryStringValue(HKCU, 'Software\Isla Ancestral', 'Version', Version) then
    Version := '';
  Result := Version;
end;

function IsUpdate(): Boolean;
begin
  Result := (GetInstalledVersion() <> '');
end;

{ La comparacion semantica completa de versiones es responsabilidad de M119
  (Actualizaciones). Aqui basta con distinguir instalacion nueva / reinstalacion
  de la misma version / actualizacion. }
function EsMismaVersion(): Boolean;
begin
  Result := (VersionPrevia = '{#AppVersion}');
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    { Backup ANTES de sobrescribir, para poder hacer rollback (RF14). }
    if IsUpdate() then
      BackupPreviousVersion();
  end
  else if CurStep = ssPostInstall then
  begin
    if VersionPrevia <> '' then
    begin
      if EsMismaVersion() then
        MsgBox('Reinstalacion completada de {#AppNombre} {#AppVersion}.', mbInformation, MB_OK)
      else
        MsgBox('Actualizacion completada: ' + VersionPrevia + ' -> {#AppVersion}.', mbInformation, MB_OK);
    end
    else
      MsgBox('Instalacion completada: {#AppNombre} {#AppVersion}.', mbInformation, MB_OK);
  end;
end;
