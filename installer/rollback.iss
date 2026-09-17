{ ===========================================================================
  M116 - rollback.iss : rollback a la version anterior (RF14)
  Incluido desde IslaAncestral.iss dentro de la unica seccion [Code].

  BackupPreviousVersion() lo invoca CurStepChanged(ssInstall) de update.iss
  cuando se detecta una instalacion previa.
  =========================================================================== }

const
  CARPETA_BACKUP = 'backup';

function RutaBackup(): String;
begin
  Result := ExpandConstant('{app}\') + CARPETA_BACKUP;
end;

procedure BackupPreviousVersion();
var
  Origen, Destino: String;
begin
  Origen := ExpandConstant('{app}\{#AppExe}');
  Destino := RutaBackup();

  if not FileExists(Origen) then
    Exit;   { no hay nada que respaldar }

  if not DirExists(Destino) then
    ForceDirectories(Destino);

  if FileCopy(Origen, Destino + '\{#AppExe}', False) then
  begin
    { Copiar tambien el paquete si existe suelto (con embed_pck puede no estar). }
    if FileExists(ExpandConstant('{app}\{#AppPck}')) then
      FileCopy(ExpandConstant('{app}\{#AppPck}'), Destino + '\{#AppPck}', False);
  end;
end;

function HayBackup(): Boolean;
begin
  Result := FileExists(RutaBackup() + '\{#AppExe}');
end;

procedure RollbackToPreviousVersion();
begin
  if not HayBackup() then
  begin
    MsgBox('No hay copia de seguridad de una version anterior que restaurar.',
           mbError, MB_OK);
    Exit;
  end;

  if FileCopy(RutaBackup() + '\{#AppExe}', ExpandConstant('{app}\{#AppExe}'), False) then
  begin
    if FileExists(RutaBackup() + '\{#AppPck}') then
      FileCopy(RutaBackup() + '\{#AppPck}', ExpandConstant('{app}\{#AppPck}'), False);
    MsgBox('Version anterior restaurada desde la copia de seguridad.' + #13#10 +
           'Tus partidas guardadas y tu configuracion no se han tocado.',
           mbInformation, MB_OK);
  end
  else
    MsgBox('No se pudo restaurar la version anterior.' + #13#10 +
           'Copia manual disponible en: ' + RutaBackup(),
           mbError, MB_OK);
end;

{ El rollback AUTOMATICO ante fallo de actualizacion depende del modulo de
  actualizaciones (M119), que decide cuando una actualizacion ha fallado. Aqui
  se deja el respaldo listo y el rollback manual/scriptable. }
