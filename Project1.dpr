program Project1;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  uDBF in 'uDBF.pas',
  System.IOUtils,
  System.Classes;

function BytesToString(ABuf: PByte; ALen: Cardinal): string; overload;
const
  HexDigits: array [0 .. $F] of Char = '0123456789ABCDEF';
var
  i: Integer;
begin
  if ALen = 0 then
  begin
    Result := '';
    Exit;
  end;
  SetLength(Result, 3 * ALen - 1);
  Result[1] := HexDigits[ABuf^ shr 4];
  Result[2] := HexDigits[ABuf^ and $0F];
  for i := 1 to ALen - 1 do
  begin
    Inc(ABuf);
    Result[3 * i + 0] := ' ';
    Result[3 * i + 1] := HexDigits[ABuf^ shr 4];
    Result[3 * i + 2] := HexDigits[ABuf^ and $0F];
  end;
end;

procedure test;
const
  CFILE = 'C:\Users\Максим\Desktop\tdbf701\demo\data\disco.DBF';
var
  lDbf: TsmDBF;
  LStream: TFileStream;
begin
  LStream := TFile.Open(CFILE, TFileMode.fmOpen);
  lDbf := TsmDBF.Create(LStream);
  try
    Writeln('Sign: ', lDbf.Header.FileType.ToString);
    Writeln('Modif: ', DateToStr(lDbf.Header.LastUpdate));
    Writeln('NumberOfRecords: ', lDbf.Header.NumberOfRecords);
    Writeln('HeaderLenght: ', lDbf.Header.HeaderLenght);
    Writeln('RecordLenght: ', lDbf.Header.RecordLenght);
    Writeln('Reserved: ', BytesToString(PByte(lDbf.Header.Reserved), Length(lDbf.Header.Reserved)));
    Writeln('DBFTableFlags: ', lDbf.Header.DBFTableFlags.ToString);
    Writeln('CodePage: ', lDbf.Header.CodePage.ToString);
    Writeln('EndOfHeader: ', lDbf.Header.EndOfHeader.ToString);
    // Writeln('LangDriverName: ', lDbf.Header.LangDriverName);
  finally
    lDbf.Free;
  end;
end;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    test;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;

end.
