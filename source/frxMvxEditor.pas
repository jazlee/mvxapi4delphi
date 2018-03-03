{******************************************************************************}
{* frxMvxEditor.pas                                                           *}
{* This module is part of Internal Project but is released under              *}
{* the MIT License: http://www.opensource.org/licenses/mit-license.php        *}
{* Copyright (c) 2006 by Jaimy Azle                                           *}
{* All rights reserved.                                                       *}
{******************************************************************************}
{* Desc:                                                                      *}
{******************************************************************************}
unit frxMvxEditor;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, Controls, frxMvxComponents, frxCustomDB,
  frxDsgnIntf, frxRes, DB, MvxCon, frxEditMvxParams
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxMvxParamsProperty = class(TfrxClassProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    function Edit: Boolean; override;
  end;
  
  TfrxDatabaseProperty = class(TfrxComponentProperty)
  public
    function GetValue: String; override;
  end;

  TfrxMIProgramProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
    procedure SetValue(const Value: String); override;
  end;

  TfrxMICommandProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
    procedure SetValue(const Value: String); override;
  end;  


{ TfrxDatabaseProperty }

function TfrxDatabaseProperty.GetValue: String;
var
  db: TfrxMvxDatabase;
begin
  db := TfrxMvxDatabase(GetOrdValue);
  if db = nil then
  begin
    if (MvxComponents <> nil) and (MvxComponents.DefaultDatabase <> nil) then
      Result := MvxComponents.DefaultDatabase.Name
    else
      Result := frxResources.Get('prNotAssigned');
  end
  else
    Result := inherited GetValue;
end;


{ TfrxMIProgramProperty }

function TfrxMIProgramProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paSortList];
end;

procedure TfrxMIProgramProperty.GetValues;
begin
  inherited;
  with TfrxMvxDataset(Component).MvxDataset do
    if Connection <> nil then
      frxMvxGetMIProgramNames(Connection, Values);
end;

procedure TfrxMIProgramProperty.SetValue(const Value: String);
begin
  inherited;
  Designer.UpdateDataTree;
end;



{ TfrxMICommandProperty }

function TfrxMICommandProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paSortList];
end;

procedure TfrxMICommandProperty.GetValues;
begin
  inherited;
  with TfrxMvxDataset(Component) do
    if MvxDataset <> nil then
      frxMvxGetMICommandNames(MvxDataset, Values);
end;

procedure TfrxMICommandProperty.SetValue(const Value: String);
begin
  inherited;
  Designer.UpdateDataTree;
end;


{ TfrxMvxParamsProperty }

function TfrxMvxParamsProperty.Edit: Boolean;
var
  q: TfrxMvxDataset;
begin
  Result := False;
  q := TfrxMvxDataset(Component);
  if q.Params.Count <> 0 then
    with TfrxMvxParamsEditorForm.Create(Designer) do
    begin
      Params := q.Params;
      Result := ShowModal = mrOk;
      if Result then
      begin
        q.UpdateParams;
        Self.Designer.UpdateDataTree;
      end;
      Free;
    end;
end;

function TfrxMvxParamsProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

initialization
  frxPropertyEditors.Register(TypeInfo(TfrxMvxDatabase), TfrxMvxDataset, 'Database',
    TfrxDatabaseProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxMvxDataset, 'MIProgram',
    TfrxMIProgramProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxMvxDataset, 'MICommand',
    TfrxMICommandProperty);
  frxPropertyEditors.Register(TypeInfo(TfrxParams), TfrxMvxDataset, 'Params',
    TfrxMvxParamsProperty);
end.
