{******************************************************************************}
{* fs_imvxrtti.pas                                                            *}
{* This module is part of Internal Project but is released under              *}
{* the MIT License: http://www.opensource.org/licenses/mit-license.php        *}
{* Copyright (c) 2006 by Jaimy Azle                                           *}
{* All rights reserved.                                                       *}
{******************************************************************************}
{* Desc:                                                                      *}
{******************************************************************************}
unit fs_imvxrtti;

interface

uses
  SysUtils, Classes, fs_iinterpreter, fs_itools, fs_idbrtti,
  DB, MvxCon;

implementation

type
  TFunctions = class(TfsRTTIModule)
  private
    function CallMethod(Instance: TObject; ClassType: TClass;
      const MethodName: String; Caller: TfsMethodHelper): Variant;
    function GetProp(Instance: TObject; ClassType: TClass;
      const PropName: String): Variant;
    procedure SetProp(Instance: TObject; ClassType: TClass;
      const PropName: String; Value: Variant);
  public
    constructor Create(AScript: TfsScript); override;
  end;

{ TFunctions }

function TFunctions.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; Caller: TfsMethodHelper): Variant;
begin
  Result := 0;
  if ClassType = TMvxParams then
  begin
    if MethodName = 'ADD' then
      Result := Integer(TMvxParams(Instance).Add)
    else if MethodName = 'PARAMBYNAME' then
      Result := Integer(TMvxParams(Instance).ParamByName(Caller.Params[0]))
    else if MethodName = 'FINDPARAM' then
      Result := Integer(TMvxParams(Instance).FindParam(Caller.Params[0]))
    else if MethodName = 'ITEMS.GET' then
      Result := Integer(TMvxParams(Instance).Items[Caller.Params[0]]);
  end
end;

constructor TFunctions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);
  with AScript do
  begin
    AddType('TDataType', fvtInt);
    AddClass(TMvxConnection, 'TComponent');
    with AddClass(TMvxParam, 'TCollectionItem') do
    begin
      AddProperty('Name', 'String', GetProp, SetProp);
      AddProperty('Size', 'Integer', GetProp, SetProp);
      AddProperty('DataType', 'TFieldType', GetProp, SetProp);
      AddProperty('Mandatory', 'Boolean', GetProp, SetProp);
      AddProperty('Value','Variant', GetProp, SetProp);
      AddProperty('AsString','String', GetProp, SetProp);
      AddProperty('AsInteger','Integer', GetProp, SetProp);
      AddProperty('AsBCD','Currency', GetProp, SetProp);
    end;
    with AddClass(TMvxParams, 'TCollection') do
    begin
      AddMethod('function Add: TMvxParam', CallMethod);
      AddMethod('function ParamByName(const Value: string): TParam', CallMethod);
      AddMethod('function FindParam(const Value: string): TParam', CallMethod);      
      AddDefaultProperty('Items', 'Integer', 'TMvxParam', CallMethod, True);
    end;
    with AddClass(TMvxCustomDataset, 'TDataSet') do
    begin
      AddProperty('MIProgram', 'String', GetProp, SetProp);
      AddProperty('MICommand', 'String', GetProp, SetProp);
    end;
    AddClass(TMvxDataset, 'TMvxCustomDataset');
  end;

end;

function TFunctions.GetProp(Instance: TObject; ClassType: TClass;
  const PropName: String): Variant;
begin
  Result := 0;
  if ClassType = TMvxParam then
  begin
    if PropName = 'NAME' then
      Result := TMvxParam(Instance).Name
    else
    if PropName = 'SIZE' then
      Result := TMvxParam(Instance).Size
    else
    if PropName = 'DATATYPE' then
      Result := TMvxParam(Instance).DataType
    else
    if PropName = 'MANDATORY' then
      Result := TMvxParam(Instance).Mandatory
    else
    if PropName = 'VALUE' then
      Result := TMvxParam(Instance).Value
    else
    if PropName = 'ASSTRING' then
      Result := TMvxParam(Instance).AsString
    else
    if PropName = 'ASINTEGER' then
      Result := TMvxParam(Instance).AsInteger
    else
    if PropName = 'ASBCD' then
      Result := TMvxParam(Instance).AsBCD
  end else
  if ClassType = TMvxCustomDataset then
  begin
    if PropName = 'MIPROGRAM' then
      Result := TMvxDataset(Instance).MIProgram
    else
    if PropName = 'MICOMMAND' then
      Result := TMvxDataset(Instance).MICommand;
  end
end;

procedure TFunctions.SetProp(Instance: TObject; ClassType: TClass;
  const PropName: String; Value: Variant);
begin
  if ClassType = TMvxParam then
  begin
    if PropName = 'NAME' then
      TMvxParam(Instance).Name := Value
    else
    if PropName = 'SIZE' then
      TMvxParam(Instance).Size := Value
    else
    if PropName = 'DATATYPE' then
      TMvxParam(Instance).DataType := Value
    else
    if PropName = 'MANDATORY' then
      TMvxParam(Instance).Mandatory := Value
    else
    if PropName = 'VALUE' then
      TMvxParam(Instance).Value := Value
    else
    if PropName = 'ASSTRING' then
      TMvxParam(Instance).AsString := Value
    else
    if PropName = 'ASINTEGER' then
      TMvxParam(Instance).AsInteger := Value
    else
    if PropName = 'ASBCD' then
      TMvxParam(Instance).AsBCD := Value;
  end else
  if ClassType = TMvxCustomDataset then
  begin
    if PropName = 'MIPROGRAM' then
      TMvxDataset(Instance).MIProgram := Value
    else
    if PropName = 'MICOMMAND' then
      TMvxDataset(Instance).MICommand := Value; 
  end
end;

initialization
  fsRTTIModules.Add(TFunctions);

finalization
  fsRTTIModules.Remove(TFunctions);

end.
