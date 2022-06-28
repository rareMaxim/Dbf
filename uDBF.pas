unit uDBF;

interface

uses
  System.Classes,
  System.SysUtils;

type
{$SCOPEDENUMS ON}
  TsmDBFVersion = (Unknown = $0, FoxBase = $02, FoxBaseDBase3NoMemo = $03, VisualFoxPro = $30,
    VisualFoxProWithAutoIncrement = $31, dBase4SQLTableNoMemo = $43, dBase4SQLSystemNoMemo = $63,
    FoxBaseDBase3WithMemo = $83, dBase4WithMemo = $8B, dBase4SQLTableWithMemo = $CB, FoxPro2WithMemo = $F5,
    FoxBASE_ = $FB);
  TsmDBFFieldFlags = (None = $00, System = $01, AllowNullValues = $02, Binary = $04, AutoIncrementing = $0C);
  TsmDBFTableFlags = (None = $00, HasStructuralCDX = $01, HasMemoField = $02, IsDBC = $04);
{$SCOPEDENUMS OFF}

  TsmDBFVersionHelper = record helper for TsmDBFVersion
    function ToString: string;
  end;

  TsmDBFTableFlagsHelper = record helper for TsmDBFTableFlags
    function ToString: string;
  end;

  IsmDbfHeaderField = interface
    ['{9CA20DEF-A29E-4DC5-8BA3-6E94EE1E8C84}']
    function FieldName: string;
  end;

  TsmDbfHeaderField = class(TInterfacedObject)
  private
    FStream: TStream;
    FShift: Integer;
  public
    constructor Create(ADbf: TStream; AShift: Integer);
    function FieldName: string;
  end;

  TsmDbfHeader = class
  private
    FStream: TStream;
    function LangDriverName: string;
  public
    function FileType: TsmDBFVersion;
    function LastUpdate: TDate;
    function NumberOfRecords: Integer;
    function HeaderLenght: SmallInt;
    function RecordLenght: SmallInt;
    function Reserved: TBytes;
    function DBFTableFlags: TsmDBFTableFlags;
    function CodePage: Byte;
    function EndOfHeader: SmallInt;
    constructor Create(ADbf: TStream);
  end;

  TsmDBF = class
  private
    FStream: TStream;
    FHeader: TsmDbfHeader;
  protected

  public
    constructor Create(ADbf: TStream);
    destructor Destroy; override;
    property Header: TsmDbfHeader read FHeader write FHeader;

  end;

implementation

uses
  System.Rtti;
{ TsmDBF }

constructor TsmDBF.Create(ADbf: TStream);
begin
  FStream := ADbf;
  FHeader := TsmDbfHeader.Create(FStream);
end;

destructor TsmDBF.Destroy;
begin
  FHeader.Free;
  inherited;
end;

{ TsmDbfHeader }

function TsmDbfHeader.CodePage: Byte;
begin
  FStream.Position := 29;
  FStream.ReadData(Result);
end;

constructor TsmDbfHeader.Create(ADbf: TStream);
begin
  FStream := ADbf;
end;

function TsmDbfHeader.DBFTableFlags: TsmDBFTableFlags;
var
  LByte: Byte;
begin
  FStream.Position := 28;
  FStream.Read(LByte, 1);
  Result := TsmDBFTableFlags(LByte);
end;

function TsmDbfHeader.EndOfHeader: SmallInt;
begin
  FStream.Position := 30;
  FStream.ReadData(Result);
end;

function TsmDbfHeader.FileType: TsmDBFVersion;
var
  LByte: Byte;
begin
  FStream.Position := 0;
  FStream.Read(LByte, 1);
  Result := TsmDBFVersion(LByte);
end;

function TsmDbfHeader.HeaderLenght: SmallInt;
begin
  FStream.Position := 8;
  FStream.ReadData(Result);
end;

function TsmDbfHeader.LangDriverName: string;
begin

end;

function TsmDbfHeader.LastUpdate: TDate;
var
  LDate: TBytes;
begin
  SetLength(LDate, 3);
  FStream.Position := 1;
  FStream.Read(LDate, 3);
  Result := EncodeDate(1900 + LDate[0], LDate[1], LDate[2]);
end;

function TsmDbfHeader.NumberOfRecords: Integer;
begin
  FStream.Position := 4;
  FStream.ReadData(Result);
end;

function TsmDbfHeader.RecordLenght: SmallInt;
begin
  FStream.Position := 10;
  FStream.ReadData(Result);
end;

function TsmDbfHeader.Reserved: TBytes;
begin
  SetLength(Result, 16);
  FStream.Position := 12;
  FStream.ReadData(Result, 16);
end;

{ TsmDBFVersionHelper }

function TsmDBFVersionHelper.ToString: string;
begin
  case Self of
    TsmDBFVersion.FoxBase:
      Result := 'FoxBase';
    TsmDBFVersion.FoxBaseDBase3NoMemo:
      Result := 'FoxBaseDBase3NoMemo';
    TsmDBFVersion.VisualFoxPro:
      Result := 'VisualFoxPro';
    TsmDBFVersion.VisualFoxProWithAutoIncrement:
      Result := 'VisualFoxProWithAutoIncrement';
    TsmDBFVersion.dBase4SQLTableNoMemo:
      Result := 'dBase4SQLTableNoMemo';
    TsmDBFVersion.dBase4SQLSystemNoMemo:
      Result := 'dBase4SQLSystemNoMemo';
    TsmDBFVersion.FoxBaseDBase3WithMemo:
      Result := 'FoxBaseDBase3WithMemo';
    TsmDBFVersion.dBase4WithMemo:
      Result := 'dBase4WithMemo';
    TsmDBFVersion.dBase4SQLTableWithMemo:
      Result := 'dBase4SQLTableWithMemo';
    TsmDBFVersion.FoxPro2WithMemo:
      Result := 'FoxPro2WithMemo';
    TsmDBFVersion.FoxBASE_:
      Result := 'FoxBASE';
  else
    Result := 'Unknown';
  end;

end;

{ TsmDBFTableFlagsHelper }

function TsmDBFTableFlagsHelper.ToString: string;
begin
  case Self of
    TsmDBFTableFlags.None:
      Result := 'None';
    TsmDBFTableFlags.HasStructuralCDX:
      Result := 'HasStructuralCDX';
    TsmDBFTableFlags.HasMemoField:
      Result := 'HasMemoField';
    TsmDBFTableFlags.IsDBC:
      Result := 'IsDBC';
  end;
end;

{ TsmDbfHeaderField }

constructor TsmDbfHeaderField.Create(ADbf: TStream; AShift: Integer);
begin
  FStream := ADbf;
  FShift := AShift;
end;

function TsmDbfHeaderField.FieldName: string;
begin
  FStream.Position := FShift + 0;
  FStream.ReadData(Result);
end;

end.
