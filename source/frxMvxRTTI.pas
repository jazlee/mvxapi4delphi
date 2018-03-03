{******************************************************************************}
{* frxMvxRTTI.pas                                                             *}
{* This module is part of Internal Project but is released under              *}
{* the MIT License: http://www.opensource.org/licenses/mit-license.php        *}
{* Copyright (c) 2006 by Jaimy Azle                                           *}
{* All rights reserved.                                                       *}
{******************************************************************************}
{* Desc:                                                                      *}
{******************************************************************************}
unit frxMvxRTTI;

interface

{$I frx.inc}

implementation
uses
  Windows, Classes, fs_iinterpreter, frxMvxComponents, fs_imvxrtti
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TFunctions = class(TfsRTTIModule)
  private
    function CallMethod(Instance: TObject; ClassType: TClass;
      const MethodName: String; Caller: TfsMethodHelper): Variant;
    function GetProp(Instance: TObject; ClassType: TClass;
      const PropName: String): Variant;
  public
    constructor Create(AScript: TfsScript); override;
  end;


{ TFunctions }

constructor TFunctions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);
  with AScript do
  begin
    with AddClass(TfrxMvxDatabase, 'TfrxCustomDatabase') do
      AddProperty('Database', 'TMvxConnection', GetProp, nil);
    with AddClass(TfrxMvxDataset, 'TfrxCustomDataset') do
    begin
      AddProperty('MVXDATASET', 'TMvxDataset', GetProp, nil);
    end;
  end;
end;

function TFunctions.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; Caller: TfsMethodHelper): Variant;
begin
  Result := 0;
end;

function TFunctions.GetProp(Instance: TObject; ClassType: TClass;
  const PropName: String): Variant;
begin
  Result := 0;

  if ClassType = TfrxMvxDatabase then
  begin
    if PropName = 'DATABASE' then
      Result := Integer(TfrxMvxDatabase(Instance).Database)
  end
  else if ClassType = TfrxMvxDataset then
  begin
    if PropName = 'MVXDATASET' then
      Result := Integer(TfrxMvxDataset(Instance).MvxDataset)
  end
end;


initialization
  fsRTTIModules.Add(TFunctions);

finalization
  if fsRTTIModules <> nil then
    fsRTTIModules.Remove(TFunctions);

end.
