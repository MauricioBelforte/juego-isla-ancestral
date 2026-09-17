{ ===========================================================================
  M116 - repair.iss : reparacion de instalacion corrupta (RF10)
  Incluido desde IslaAncestral.iss dentro de la unica seccion [Code].

  Validacion de integridad por manifiesto (ruta|tamano), generado por
  scripts/build_installer.bat. Se usa tamano en vez de SHA-256 a proposito:
  GetSHA256OfFile solo existe en Inno Setup >= 6.3 y esto mantiene el script
  compilable en toda la rama 6.x. (Mejora futura documentada en 04-Codigo.md.)
  =========================================================================== }

const
  MANIFIESTO = 'install_manifest.txt';

function ValidateFileIntegrity(): Boolean;
var
  Lineas: TArrayOfString;
  i, sep: Integer;
  Linea, Ruta, TamEsperado, RutaAbs: String;
  TamReal: Int64;
begin
  Result := True;
  RutaAbs := ExpandConstant('{app}\') + MANIFIESTO;

  if not FileExists(RutaAbs) then
  begin
    { Sin manifiesto no se puede validar: se considera instalacion incompleta. }
    Result := False;
    Exit;
  end;

  if not LoadStringsFromFile(RutaAbs, Lineas) then
  begin
    Result := False;
    Exit;
  end;

  for i := 0 to GetArrayLength(Lineas) - 1 do
  begin
    Linea := Trim(Lineas[i]);
    if Linea <> '' then
    begin
      sep := Pos('|', Linea);
      if sep > 0 then
      begin
        Ruta := Copy(Linea, 1, sep - 1);
        TamEsperado := Copy(Linea, sep + 1, Length(Linea));
        RutaAbs := ExpandConstant('{app}\') + Ruta;
        if not FileExists(RutaAbs) then
        begin
          Result := False;
          Exit;
        end;
        TamReal := FileSize64(RutaAbs);
        if IntToStr(TamReal) <> TamEsperado then
        begin
          Result := False;
          Exit;
        end;
      end;
    end;
  end;
end;

{ Diagnostico para el usuario. La reinstalacion efectiva la hace Inno Setup
  volviendo a ejecutar el instalador sobre la misma carpeta. }
procedure RepairInstallation();
begin
  if ValidateFileIntegrity() then
    MsgBox('La instalacion esta integra: no hace falta reparar.', mbInformation, MB_OK)
  else
    MsgBox('Se detectaron archivos faltantes o modificados.' + #13#10 +
           'Ejecuta de nuevo el instalador para reparar la instalacion.' + #13#10 +
           'Tus partidas guardadas y tu configuracion no se tocan.',
           mbInformation, MB_OK);
end;
