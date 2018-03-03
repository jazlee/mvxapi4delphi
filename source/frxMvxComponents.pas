{******************************************************************************}
{* frxMvxComponents.pas                                                       *}
{* This module is part of Internal Project but is released under              *}
{* the MIT License: http://www.opensource.org/licenses/mit-license.php        *}
{* Copyright (c) 2006 by Jaimy Azle                                           *}
{* All rights reserved.                                                       *}
{******************************************************************************}
{* Desc:                                                                      *}
{******************************************************************************}

unit frxMvxComponents;

interface
{$I frx.inc}

uses
  Windows, Classes, Graphics, SysUtils, frxClass, frxCustomDB, DB, MvxCon
{$IFDEF Delphi6}
, Variants
{$ENDIF}
;

const
  CLASS_TfrxMvxConnection: TGUID = '{1653377E-2FF7-4D1C-BB48-8B94FE8713AF}';
  CLASS_TfrxMvxDataset: TGUID = '{7E494C94-94EB-400E-AB3F-11A124B21DAF}';


type
  TfrxMvxDataset = class;
  
  TfrxMvxComponents = class(TfrxDBComponents)
  private
    FDefaultDatabase: TMvxConnection;
    FOldComponents: TfrxMvxComponents;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDescription: String; override;
  published
    property DefaultDatabase: TMvxConnection read FDefaultDatabase write FDefaultDatabase;
  end;

  TfrxMvxParamItem = class(TCollectionItem)
  private

    FDataType: TFieldType;
    FExpression: String;
    FName: String;
    FValue: Variant;
    
  public
    procedure Assign(Source: TPersistent); override;
    property Value: Variant read FValue write FValue;
  published
    property Name: String read FName write FName;
    property DataType: TFieldType read FDataType write FDataType;
    property Expression: String read FExpression write FExpression;
  end;

  TfrxMvxParams = class(TCollection)
  private
    function GetParam(Index: Integer): TfrxMvxParamItem;
  public
    constructor Create;
    function Add: TfrxMvxParamItem;
    function Find(const Name: String): TfrxMvxParamItem;
    function IndexOf(const Name: String): Integer;
    procedure UpdateParams(ADataset: TMvxDataset);
    property Items[Index: Integer]: TfrxMvxParamItem read GetParam; default;
  end;


  TfrxMvxDatabase = class(TfrxCustomDatabase)
  private
    FDatabase: TMvxConnection;
  protected
    procedure SetConnected(Value: Boolean); override;
    procedure SetDatabaseName(const Value: String); override;
    procedure SetLoginPrompt(Value: Boolean); override;
    function GetConnected: Boolean; override;
    function GetDatabaseName: String; override;
    function GetLoginPrompt: Boolean; override;

  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
    procedure SetLogin(const Login, Password: String); override;
    property Database: TMvxConnection read FDatabase;
  published
    property DatabaseName;
    property LoginPrompt;
    property Connected;
  end;


  TfrxMvxDataset = class(TfrxCustomDataset)
  private
    FDatabase: TfrxMvxDatabase;
    FMvxDataset: TMvxDataset;
    FSaveOnBeforeOpen: TDataSetNotifyEvent;
    FParams: TfrxMvxParams;
    procedure SetDatabase(Value: TfrxMvxDatabase);
    procedure SetParams(const Value: TfrxMvxParams);
    procedure ReadData(Reader: TReader);
    procedure WriteData(Writer: TWriter);    
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function GetMIProgram: String;
    procedure SetMIProgram(const Value: String);
    function GetMICommand: String;
    procedure SetMICommand(const Value: String);
    procedure OnPrepare(Sender: TObject);
    procedure OnBeforeOpen(DataSet: TDataSet); virtual;

    property Filter;
    property Filtered;
    property Master;  

  public
    constructor Create(AOwner: TComponent); override;
    constructor DesignCreate(AOwner: TComponent; Flags: Word); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    procedure BeforeStartReport; override;
    procedure GetFieldList(List: TStrings); override;
    procedure UpdateParams; virtual;
    function ParamByName(const Value: String): TfrxMvxParamItem;

    property MvxDataset: TMvxDataset read FMvxDataset;
  published
    property Database: TfrxMvxDatabase read FDatabase write SetDatabase;
    property MIProgram: String read GetMIProgram write SetMIProgram;
    property MICommand: String read GetMICommand write SetMICommand;
    property Params: TfrxMvxParams read FParams write SetParams;
  end;


procedure frxMvxGetMIProgramNames(conMvx: TMvxConnection; List: TStrings);
procedure frxMvxGetMICommandNames(dsMvx: TMvxDataset; List: TStrings);
procedure frxParamsToTMvxParams(ADataset: TfrxMvxDataset; Params: TMvxParams);

var
  MvxComponents: TfrxMvxComponents;


implementation

uses
  frxMvxRTTI,
{$IFNDEF NO_EDITORS}
  frxMvxEditor,
{$ENDIF}
  frxDsgnIntf, frxRes, frxUtils, frxDBSet;

{$R *.res}  


{ frxParamsToTParameters }

procedure frxMvxGetMIProgramNames(conMvx: TMvxConnection; List: TStrings);
begin
  conMvx.GetProgramList(List);
end;

procedure frxMvxGetMICommandNames(dsMvx: TMvxDataset; List: TStrings);
begin
  dsMvx.GetMICommandList(dsMvx.MIProgram, List);
end;

procedure frxParamsToTMvxParams(ADataset: TfrxMvxDataset; Params: TMvxParams);
var
  i: Integer;
  Item: TfrxMvxParamItem;
begin
  for i := 0 to Params.Count - 1 do
    if ADataset.Params.IndexOf(Params[i].Name) <> -1 then
    begin
      Item := ADataset.Params[ADataset.Params.IndexOf(Params[i].Name)];
      Params[i].Clear;
      { Bound should be True in design mode }
      if not (ADataset.IsLoading or ADataset.IsDesigning) then
        Params[i].Bound := False
      else
        Params[i].Bound := True;
      Params[i].DataType := Item.DataType;
      if Trim(Item.Expression) <> '' then
        if not (ADataset.IsLoading or ADataset.IsDesigning) then
          if ADataset.Report <> nil then
          begin
            ADataset.Report.CurObject := ADataset.Name;
            Item.Value := ADataset.Report.Calc(Item.Expression);
          end;
      if not VarIsEmpty(Item.Value) then
      begin
        Params[i].Bound := True;
        if Params[i].DataType in [ftDate, ftTime, ftDateTime] then
          Params[i].Value := Item.Value
        else
          Params[i].AsString := VarToStr(Item.Value);
      end;
    end;
end;

{ TfrxDBComponents }

constructor TfrxMvxComponents.Create(AOwner: TComponent);
begin
  inherited;
  FOldComponents := MvxComponents;
  MvxComponents := Self;
end;

destructor TfrxMvxComponents.Destroy;
begin
  if MvxComponents = Self then
    MvxComponents := FOldComponents;
  inherited;
end;

function TfrxMvxComponents.GetDescription: String;
begin
  Result := 'Movex';
end;


{ TfrxMvxDatabase }

constructor TfrxMvxDatabase.Create(AOwner: TComponent);
begin
  inherited;
  FDatabase := TMvxConnection.Create(nil);
  Component := FDatabase;
end;

class function TfrxMvxDatabase.GetDescription: String;
begin
  Result := frxResources.Get('obMvxDB');
end;

function TfrxMvxDatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

function TfrxMvxDatabase.GetDatabaseName: String;
begin
  Result := FDatabase.Host;
end;

function TfrxMvxDatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

procedure TfrxMvxDatabase.SetConnected(Value: Boolean);
begin
  BeforeConnect(Value);
  FDatabase.Connected := Value;
end;

procedure TfrxMvxDatabase.SetDatabaseName(const Value: String);
begin
  FDatabase.Host := Value;
end;

procedure TfrxMvxDatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

procedure TfrxMvxDatabase.SetLogin(const Login, Password: String);
begin
  FDatabase.UserName := Login;
  FDatabase.Password := Password;
end;


{ TfrxMvxDataset }

constructor TfrxMvxDataset.Create(AOwner: TComponent);
begin
  FMvxDataset := TMvxDataset.Create(Self);
  DataSet := FMvxDataset;
  FMvxDataset.OnPrepare := OnPrepare;
  SetDatabase(nil);
  FParams := TfrxMvxParams.Create;
  FSaveOnBeforeOpen := DataSet.BeforeOpen;
  DataSet.BeforeOpen := OnBeforeOpen;  
  inherited;
end;

constructor TfrxMvxDataset.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxMvxDatabase then
    begin
      SetDatabase(TfrxMvxDatabase(l[i]));
      break;
    end;
end;

class function TfrxMvxDataset.GetDescription: String;
begin
  Result := frxResources.Get('TMvxDataset');
end;

procedure TfrxMvxDataset.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

procedure TfrxMvxDataset.SetDatabase(Value: TfrxMvxDatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FMvxDataset.Connection := Value.Database
  else if MvxComponents <> nil then
    FMvxDataset.Connection := MvxComponents.DefaultDatabase
  else
    FMvxDataset.Connection := nil;
  DBConnected := FMvxDataset.Connection <> nil;
end;

procedure TfrxMvxDataset.BeforeStartReport;
begin
  SetDatabase(FDatabase);
end;

procedure TfrxMvxDataset.GetFieldList(List: TStrings);
var
  i: Integer;
begin
  List.Clear;
  if FieldAliases.Count = 0 then
  begin
    try
      if (MIProgram <> EmptyStr) and (DataSet <> nil) then
        DataSet.GetFieldNames(List);
    except; end;
  end else
  begin
    for i := 0 to FieldAliases.Count - 1 do
      if Pos('-', FieldAliases.Names[i]) <> 1 then
        List.Add(FieldAliases.Values[FieldAliases.Names[i]]);
  end;
end;

function TfrxMvxDataset.GetMIProgram: String;
begin
  Result := FMvxDataset.MIProgram;
end;

procedure TfrxMvxDataset.SetMIProgram(const Value: String);
begin
  FMvxDataset.MIProgram := Value;
end;

function TfrxMvxDataset.GetMICommand: String;
begin
  Result := FMvxDataset.MICommand;
end;

procedure TfrxMvxDataset.SetMICommand(const Value: String);
begin
  FMvxDataset.MICommand := Value;
end;


destructor TfrxMvxDataset.Destroy;
begin
  FParams.Free;
  inherited Destroy;
end;

procedure TfrxMvxDataset.UpdateParams;
begin
  frxParamsToTMvxParams(Self, FMvxDataset.Params);
end;

procedure TfrxMvxDataset.SetParams(const Value: TfrxMvxParams);
begin
  FParams.Assign(Value);
end;

function TfrxMvxDataset.ParamByName(const Value: String): TfrxMvxParamItem;
begin
  Result := FParams.Find(Value);
  if Result = nil then
    raise Exception.Create('Parameter "' + Value + '" not found');
end;

procedure TfrxMvxDataset.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('Parameters', ReadData, WriteData, True);
end;

procedure TfrxMvxDataset.ReadData(Reader: TReader);
begin
  frxReadCollection(FParams, Reader, Self);
  UpdateParams;
end;

procedure TfrxMvxDataset.WriteData(Writer: TWriter);
begin
  frxWriteCollection(FParams, Writer, Self);
end;

procedure TfrxMvxDataset.OnPrepare(Sender: TObject);
begin
  FParams.UpdateParams(MvxDataset);
end;

procedure TfrxMvxDataset.OnBeforeOpen(DataSet: TDataSet);
begin
  UpdateParams;
  if Assigned(FSaveOnBeforeOpen) then
    FSaveOnBeforeOpen(DataSet);
end;

{ TfrxMvxParamItem }

procedure TfrxMvxParamItem.Assign(Source: TPersistent);
begin
  if Source is TfrxMvxParamItem then
  begin
    FName := TfrxMvxParamItem(Source).Name;
    FDataType := TfrxMvxParamItem(Source).DataType;
    FExpression := TfrxMvxParamItem(Source).Expression;
    FValue := TfrxMvxParamItem(Source).Value;
  end;
end;


{ TfrxMvxParams }

function TfrxMvxParams.Add: TfrxMvxParamItem;
begin
  Result := TfrxMvxParamItem(inherited Add);
end;

constructor TfrxMvxParams.Create;
begin
  inherited Create(TfrxMvxParamItem);
end;

function TfrxMvxParams.Find(const Name: String): TfrxMvxParamItem;
var
  i: Integer;
begin
  i := IndexOf(Name);
  if i <> -1 then
    Result := Items[i] else
    Result := nil;
end;

function TfrxMvxParams.GetParam(Index: Integer): TfrxMvxParamItem;
begin
  Result := TfrxMvxParamItem(inherited Items[Index]);
end;

function TfrxMvxParams.IndexOf(const Name: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if CompareText(Items[i].Name, Name) = 0 then
    begin
      Result := i;
      break;
    end;
end;

procedure TfrxMvxParams.UpdateParams(ADataset: TMvxDataset);
var
  i, j: Integer;
  QParams: TMvxParams;
  NewParams: TfrxMvxParams;
begin
  QParams := TMvxParams.Create;
  QParams.Assign(ADataset.Params);
  NewParams := TfrxMvxParams.Create;
  for i := 0 to QParams.Count - 1 do
    with NewParams.Add do
    begin
      Name := QParams[i].Name;
      j := IndexOf(Name);
      if j <> -1 then
      begin
        DataType := Items[j].DataType;
        Value := Items[j].Value;
        Expression := Items[j].Expression;
      end;
    end;
  Assign(NewParams);
  QParams.Free;
  NewParams.Free;
end;

var
  MvxBmp: TBitmap;

initialization
  MvxBmp := Graphics.TBitmap.Create;
  MvxBmp.LoadFromResourceName(hInstance, 'FRXMVXDATASET');
  frxObjects.RegisterObject1(TfrxMvxDataset, MvxBmp, '', '', 0);

finalization
  MvxBmp.Free;
  frxObjects.UnRegister(TfrxMvxDataset);

end.
