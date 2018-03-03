{******************************************************************************}
{* MvxCon.pas                                                                 *}
{* This module is part of Internal Project but is released under              *}
{* the MIT License: http://www.opensource.org/licenses/mit-license.php        *}
{* Copyright (c) 2006 by Jaimy Azle                                           *}
{* All rights reserved.                                                       *}
{******************************************************************************}
{* Desc:                                                                      *}
{******************************************************************************}

{$I vcldef.inc}
unit MvxCon;

interface
uses
  SysUtils, Classes, DB, MvxIntf, SqlTimSt, Variants, FmtBcd;

type
  EMvxAPIError = Exception;
  
  TMvxParams = class;
  TMvxCustomDataset = class;
  TMvxParamType = (ptUnknown, ptInput, ptOutput);
  
  TMvxParam = class(TCollectionItem)
  private
    FParamRef: TMvxParam;
    FDataType: TFieldType;
    FIdxFrom: Integer;
    FSize: Integer;
    FIdxTo: Integer;
    FName: string;
    FData: Variant;
    FNull: Boolean;
    FBound: Boolean;
    FParamType: TMvxParamType;
    FMandatory: boolean;

    function GetDataType: TFieldType;
    function GetDataSet: TDataSet;
    function GetParamType: TMvxParamType;
    procedure SetParamType(Value: TMvxParamType);
    procedure SetSize(const Value: Integer);
    procedure SetIdxFrom(const Value: Integer);
    procedure SetAsBlob(const Value: TBlobData);
  protected
    procedure AssignParam(Param: TMvxParam);
    procedure AssignTo(Dest: TPersistent); override;

    function ParamRef: TMvxParam;
    procedure SetDataType(const Value: TFieldType);
    function GetAsBCD: Currency;
    function GetAsInteger: LongInt;
    function GetAsString: string;
    procedure SetAsBCD(const Value: Currency);
    procedure SetAsInteger(const Value: LongInt);
    procedure SetAsString(const Value: string);
    function GetIsNull: Boolean;
    function GetAsVariant: Variant;
    function IsParamStored: Boolean;
    function IsEqual(Value: TMvxParam): Boolean;

    procedure SetAsVariant(const Value: Variant);
    property DataSet: TDataSet read GetDataSet;
  public
    constructor Create(Collection: TCollection); overload; override;
    constructor Create(AParams: TMvxParams; AParamType: TMvxParamType); reintroduce; overload;

    procedure Assign(Source: TPersistent); override;
    procedure Clear;
    procedure GetData(Buffer: Pointer);
    procedure SetBlobData(Buffer: Pointer; Size: Integer);
    procedure SetData(Buffer: Pointer);
    function GetDataSize: Integer;

    procedure LoadFromFile(const FileName: string; BlobType: TBlobType);
    procedure LoadFromStream(Stream: TStream; BlobType: TBlobType);

    property AsString: string read GetAsString write SetAsString;
    property AsInteger: LongInt read GetAsInteger write SetAsInteger;
    property AsBCD: Currency read GetAsBCD write SetAsBCD;
    property IsNull: Boolean read GetIsNull;
    property Bound: Boolean read FBound write FBound;
    property AsBlob: TBlobData read GetAsString write SetAsBlob;
  published
    property Name: string read FName write FName;
    property Size: Integer read FSize write SetSize default 0;
    property DataType: TFieldType read GetDataType write SetDataType;
    property IdxFrom: Integer read FIdxFrom write SetIdxFrom default 0;
    property IdxTo: Integer read FIdxTo write FIdxTo default 0;
    property Mandatory: boolean read FMandatory write FMandatory default False;
    property ParamType: TMvxParamType read GetParamType write SetParamType;
    property Value: Variant read GetAsVariant write SetAsVariant stored IsParamStored;
  end;

  TMvxParams = class(TCollection)
  private
    FOwner: TPersistent;
    function GetItem(Index: Integer): TMvxParam;
    procedure SetItem(Index: Integer; const Value: TMvxParam);
    function GetParamValue(const ParamName: string): Variant;
    procedure SetParamValue(const ParamName: string; const Value: Variant);
    procedure ReadBinaryData(Stream: TStream);
  protected
    function CalcSendSize: integer;
    function CalcRcvSize: integer;
    function GetDataSet: TDataSet;
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
    procedure AssignTo(Dest: TPersistent); override;
    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create; overload;
    constructor Create(Owner: TPersistent); overload;

    function BindParams: string;
    procedure ParseParams(const AStr: string);
    procedure ClearValues;
    procedure AssignValues(Value: TMvxParams);
    procedure AddParam(Value: TMvxParam);
    function FindParam(const Value: string): TMvxParam;
    function ParamByName(const Value: string): TMvxParam;
    procedure GetParamList(List: TList; const ParamNames: string);
    function IsEqual(Value: TMvxParams): Boolean;
    property Items[Index: Integer]: TMvxParam read GetItem write SetItem; default;
    property ParamValues[const ParamName: string]: Variant read GetParamValue write SetParamValue;
  end;
  
  TMvxCustomConnection = class(TCustomConnection)
  private
    FPgmList: TStringList;
    FConnected: boolean;
    PHandle: PMvxServerID;
    FSecured: boolean;
    FPort: integer;
    FPasswd: string;
    FHost: string;
    FAppName: string;
    FUserName: string;
    FCompName: string;
    FSecureKey: string;
    FAPILib: IMvxAPILibrary;
    procedure SetAppName(const Value: string);
    procedure SetHost(const Value: string);
    procedure SetPort(const Value: integer);
    procedure SetSecured(const Value: boolean);
    procedure SetSecureKey(const Value: string);
    procedure GetPgmList;
  protected
    procedure RegisterDataset(ADataset: TMvxCustomDataset);
    procedure UnregisterDataset(ADataset: TMvxCustomDataset);
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    function GetConnected: Boolean; override;

    procedure LoadLibrary;
    procedure Check(const AResult: string); overload;
    procedure Check(AResult: Integer); overload;
    procedure Setup;

    property APILibrary: IMvxAPILibrary read FAPILib;
    property MvxHandle: PMvxServerID read PHandle;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure GetProgramList(AList: TStrings);

    property ComputerName: string read FCompName write FCompName;
    property Host: string read FHost write SetHost;
    property Port: integer read FPort write SetPort;
    property ApplicationName: string read FAppName write SetAppName;
    property Secured: boolean read FSecured write SetSecured;
    property SecureKey: string read FSecureKey write SetSecureKey;
    property UserName: string read FUserName write FUserName;
    property Password: string read FPasswd write FPasswd;
  end;

  TMvxConnection = class(TMvxCustomConnection)
  published
    property ComputerName;
    property Host;
    property Port;
    property ApplicationName;
    property Secured;
    property SecureKey;
    property UserName;
    property Password;
  end;

  TMvxTransactionStatus = (stOK, stNOK, stREP);
  TMvxTransact = class(TComponent)
  private
    FOpened: boolean;
    FOLen: integer;
    FOBuffer: PChar;
    FConnection: TMvxConnection;
    FIParams: TMvxParams;
    FOParams: TMvxParams;
    FMIProgram: string;
    FMICommand: string;
    FPrepared: boolean;
    FOnPrepare: TNotifyEvent;
    FADataset: TMvxCustomDataset;
    FPreparedTrans: Boolean;
    procedure SetMICommand(const Value: string);
    procedure SetMIProgram(const Value: string);
  private
    procedure ConstructParams;
    procedure AllocBuffer(ASize: integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Prepare;
    procedure Open;
    function Transact(IParams, OParams: TMvxParams): TMvxTransactionStatus; overload;
    function Receive(OParams: TMvxParams): TMvxTransactionStatus; overload;
    function Transact: TMvxTransactionStatus; overload;
    function Receive: TMvxTransactionStatus; overload;
    procedure Close;

    property Connection: TMvxConnection read FConnection write FConnection;
    property InputParams: TMvxParams read FIParams;
    property OutputParams: TMvxParams read FOParams;
    property MIProgram: string read FMIProgram write SetMIProgram;
    property MICommand: string read FMICommand write SetMICommand;
    property Prepared: boolean read FPrepared;
    property OnPrepare: TNotifyEvent read FOnPrepare write FOnPrepare;
    property Dataset: TMvxCustomDataset read FADataset write FADataset; 
  end;

  TMvxMemFields = class;
  TMemBlobData = string;

  TBytes = array of Byte;
  TRecordBuffer = PChar;
  TBookMarkStr = string;
  TValueBuffer = Pointer;

  TMvxMemField = class
  private
    FField : TField;
    FDataType : TFieldType;
    FDataSize : Integer;
    FOffSet : Integer;
    FValueOffSet : Integer;
    FMaxIncValue : Integer;
    FOwner : TMvxMemFields;
    FIndex : Integer;
    FIsRecId : Boolean;
    FIsNeedAutoInc : Boolean;

    function DataPointer(AIndex, AOffset: Integer): TRecordBuffer;

    function GetValues(Index : Integer) : TRecordBuffer;
    function GetHasValues(Index : Integer) : Char;
    procedure SetHasValues(Index : Integer; Value : Char);

    procedure SetAutoIncValue(const Buffer : TRecordBuffer; Value : TRecordBuffer);

    function GetDataSet : TMvxCustomDataset;
    function GetMemFields : TMvxMemFields;
  protected
    procedure CreateField(Field : TField); virtual;

    function GetActiveBuffer(AActiveBuffer, ABuffer: TRecordBuffer): Boolean;
    procedure SetActiveBuffer(AActiveBuffer, ABuffer: TRecordBuffer);

    property MemFields : TMvxMemFields read GetMemFields;
  public
    constructor Create(AOwner : TMvxMemFields);

    procedure AddValue(const Buffer : TRecordBuffer);
    procedure InsertValue(AIndex : Integer; const Buffer : TRecordBuffer);
    function GetDataFromBuffer(const ABuffer: TRecordBuffer): TRecordBuffer;
    function GetHasValueFromBuffer(const ABuffer: TRecordBuffer): Char;
    function GetValueFromBuffer(const ABuffer: TRecordBuffer): TRecordBuffer;

    //For the guys from AQA.
    property OffSet: Integer read FValueOffSet;

    property DataSet : TMvxCustomDataset read GetDataSet;
    property Field : TField read FField;
    property Index : Integer read FIndex;
    property Values[Index : Integer] : TRecordBuffer read GetValues;
    property HasValues[Index : Integer] : Char read GetHasValues write SetHasValues;
  end;

  TMvxMemFields = class
  private
    FItems : TList;
    FCalcFields : TList;
    FDataSet : TMvxCustomDataset;
    FValues : TList;
    FIsNeedAutoIncList : TList;
    FValuesSize : Integer;

    function GetRecordCount : Integer;
    function GetItem(Index : Integer)  : TMvxMemField;
  protected
    function Add(AField : TField) : TMvxMemField;
    procedure Clear;
    procedure DeleteRecord(AIndex : Integer);

    procedure InsertRecord(const Buffer: TRecordBuffer; AIndex : Integer; Append: Boolean);

    procedure AddField(Field : TField);
    procedure RemoveField(Field : TField);
  public
    constructor Create(ADataSet : TMvxCustomDataset);
    destructor Destroy; override;

    procedure GetBuffer(Buffer : TRecordBuffer; AIndex : Integer);
    procedure SetBuffer(Buffer : TRecordBuffer; AIndex : Integer);
    function GetActiveBuffer(ActiveBuffer, Buffer : TRecordBuffer; Field : TField) : Boolean;
    procedure SetActiveBuffer(ActiveBuffer, Buffer : TRecordBuffer; Field : TField);
    function GetCount : Integer;
    function IndexOf(Field : TField) : TMvxMemField;

    function GetValue(mField : TMvxMemField; Index : Integer) : TRecordBuffer;
    function GetHasValue(mField : TMvxMemField; Index : Integer) : char;
    procedure SetValue(mField : TMvxMemField; Index : Integer; Buffer : TRecordBuffer);
    procedure SetHasValue(mField : TMvxMemField; Index : Integer; Value : char);


    //For the guys from AQA.
    property Values: TList read FValues;

    property DataSet : TMvxCustomDataset read FDataSet;
    property Count : Integer read GetCount;
    property Items[Index : Integer] : TMvxMemField read GetItem;
    property RecordCount : Integer read GetRecordCount;
  end;

  PdxRecInfo = ^TMvxRecInfo;
  TMvxRecInfo = packed record
    Bookmark: Integer;
    BookmarkFlag: TBookmarkFlag;
  end;

  { TBlobStream }

  TMemBlobStream = class(TStream)
  private
    FField: TBlobField;
    FDataSet: TMvxCustomDataset;
    FBuffer: TRecordBuffer;
    FMode: TBlobStreamMode;
    FOpened: Boolean;
    FModified: Boolean;
    FPosition: Longint;
    FCached: Boolean;
    function GetBlobSize: Longint;
  public
    constructor Create(Field: TBlobField; Mode: TBlobStreamMode);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure Truncate;
  end;

  { TMvxCustomDataset }
  TMvxSortOption = (soDesc, soCaseInsensitive);
  TMvxSortOptions = set of TMvxSortOption;

  TMvxMemIndex = class(TCollectionItem)
  private
    fIsDirty: Boolean;
    fField: TField;
    FSortOptions: TMvxSortOptions;
    fLoadedFieldName: String;
    fFieldName: String;
    fList: TList;
    fIndexList: TList;

    procedure SetIsDirty(Value: Boolean);
    procedure DeleteRecord(pRecord: TRecordBuffer);
    procedure UpdateRecord(pRecord: TRecordBuffer);
    procedure SetFieldName(Value: String);
    procedure SetSortOptions(Value: TMvxSortOptions);
    procedure SetFieldNameAfterMemdataLoaded;
  protected
    function GetMemData: TMvxCustomDataset;
    procedure Prepare;
    function GotoNearest(const Buffer : TRecordBuffer; var Index : Integer) : Boolean;

    property IsDirty: Boolean read fIsDirty write SetIsDirty;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    property MemData: TMvxCustomDataset read GetMemData;
  published
    property FieldName: String read fFieldName write SetFieldName;
    property SortOptions: TMvxSortOptions read FSortOptions write SetSortOptions;
  end;

  TMvxMemIndexes = class(TCollection)
  private
    fMemData: TMvxCustomDataset;
  protected
    function GetOwner: TPersistent; override;
    procedure SetIsDirty;
    procedure DeleteRecord(pRecord: TRecordBuffer);
    procedure UpdateRecord(pRecord: TRecordBuffer);
    procedure RemoveField(AField: TField);
    procedure CheckFields;
    procedure AfterMemdataLoaded;
  public
    function Add: TMvxMemIndex;
    function GetIndexByField(AField: TField): TMvxMemIndex;

    property MemData: TMvxCustomDataset read fMemData;
  end;


  TMvxMemPersistentOption = (poNone, poActive, poLoad);

  TMvxMemPersistent = class(TPersistent)
  private
    FStream: TMemoryStream;
    FOption: TMvxMemPersistentOption;
    FMemData: TMvxCustomDataset;
    FIsLoadFromPersistent: Boolean;

    procedure ReadData(Stream: TStream);
    procedure WriteData(Stream: TStream);
  protected
    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create(AMemData: TMvxCustomDataset);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure SaveData;
    procedure LoadData;

    function HasData: Boolean;

    property MemData: TMvxCustomDataset read FMemData;
  published
    property Option: TMvxMemPersistentOption read FOption write FOption default poActive;
  end;

  TMvxCustomDataset = class(TDataSet)
  private
    FActive : Boolean;
    FData : TMvxMemFields;
    FRecBufSize: Integer;
    FRecInfoOfs: Integer;
    FCurRec: Integer;
    FFilterCurRec : Integer;
    FBookMarks : TList;
    FBlobList : TList;
    FFilterList : TList;
    FLastBookmark: Integer;
    FSaveChanges: Boolean;
    FReadOnly : Boolean;
    FRecIdField : TField;
    FSortOptions : TMvxSortOptions;
    FSortedFieldName : String;
    FSortedField : TField;
    FLoadFlag : Boolean;
    FDelimiterChar : Char;
    FIsFiltered : Boolean;
    FGotoNearestMin : Integer;
    FGotoNearestMax : Integer;
    FProgrammedFilter    : Boolean;
    fIndexes: TMvxMemIndexes;
    fPersistent: TMvxMemPersistent;
    FMvxCmd: TMvxTransact;
    FLastPgm: String;
    FTransactionList: TStringList;
    FOnPrepare: TNotifyEvent;

    procedure SetConnection(const Value: TMvxConnection);
    function GetConnection: TMvxConnection;
    function GetPrepared: boolean;
    function GetMICommand: string;
    function GetMIProgram: string;
    procedure SetMICommand(const Value: string);
    procedure SetMIProgram(const Value: string);
    function GetMvxParams: TMvxParams;


    function AllocBuferForField(AField: TField): Pointer;
    function GetSortOptions : TMvxSortOptions;
    procedure FillValueList(const AList: TList);
    procedure SetSortedField(Value : String);
    procedure SetSortOptions(Value : TMvxSortOptions);
    procedure SetIndexes(Value : TMvxMemIndexes);
    procedure SetPersistent(Value: TMvxMemPersistent);
    function GetActiveRecBuf(var RecBuf: TRecordBuffer): Boolean;
    procedure DoSort(List : TList; AmField: TMvxMemField; ASortOptions: TMvxSortOptions; ExhangeList: TList);
    procedure MakeSort;
    procedure GetLookupFields(List: TList);
    procedure CreateRecIDField;

    function CheckFields(FieldsName: string): Boolean;
    function GetStringLength(AFieldType: TFieldType; const ABuffer: Pointer): Integer;
    function InternalSetRecNo(const Value: Integer): Integer;
    function InternalLocate(const KeyFields: string; const KeyValues: Variant;
                  Options: TLocateOptions): Integer;
    procedure UpdateRecordFilteringAndSorting(AIsMakeSort : Boolean);
    function InternalIsFiltering: Boolean;
    procedure SetOnPrepare(const Value: TNotifyEvent);
  protected
    procedure InitializeBlobData(Buffer: TValueBuffer);
    procedure FinalizeBlobData(Buffer: TValueBuffer);
    function GetBlobData(Buffer: TRecordBuffer; AOffSet: Integer): TMemBlobData; overload;
    function GetBlobData(Buffer: TRecordBuffer; Field: TField): TMemBlobData; overload;
    procedure SetInternalBlobData(Buffer: TRecordBuffer; AOffSet: Integer; const Value: TMemBlobData); virtual;
    procedure SetBlobData(Buffer: TRecordBuffer; AOffSet: Integer; const Value: TMemBlobData); overload;
    procedure SetBlobData(Buffer: TRecordBuffer; Field: TField; const Value: TMemBlobData); overload;
    function GetActiveBlobData(Field: TField): TMemBlobData;
    procedure GetMemBlobData(Buffer : TRecordBuffer);
    procedure SetMemBlobData(Buffer : TRecordBuffer);
    procedure BlobClear;

    procedure Loaded; override;
    function AllocRecordBuffer: TRecordBuffer; override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure GetBookmarkData(Buffer: TRecordBuffer; Data: TBookMark); override;
    function GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag; override;
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordSize: Word; override;
    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); override;
    procedure InternalPrepare(Sender: TObject); virtual;
    procedure InternalInsert; override;
    procedure InternalClose; override;
    procedure InternalDelete; override;
    procedure InternalFirst; override;
    procedure InternalGotoBookmark(Bookmark: TBookmark); override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalInitRecord(Buffer: TRecordBuffer); override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure InternalPost; override;
    procedure InternalRefresh; override;
    procedure InternalSetToRecord(Buffer: TRecordBuffer); override;
    function IsCursorOpen: Boolean; override;
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;
    procedure SetBookmarkData(Buffer: TRecordBuffer; Data: TBookmark); override;
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer); override;
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer; NativeFormat: Boolean); override;

    function GetStateFieldValue(State: TDataSetState; Field: TField): Variant; override;


    procedure DoAfterCancel; override;
    procedure DoAfterClose; override;
    procedure DoAfterInsert; override;
    procedure DoAfterOpen; override;
    procedure DoAfterPost; override;
    procedure DoBeforeClose; override;
    procedure DoBeforeInsert; override;
    procedure DoBeforeOpen; override;
    procedure DoBeforePost; override;
    procedure DoOnNewRecord; override;
  protected
    property MvxCommand: TMvxTransact read FMvxCmd;

    function GetRecordCount: Integer; override;
    function GetRecNo: Integer; override;
    procedure SetRecNo(Value: Integer); override;
    function GetCanModify: Boolean; override;
    procedure ClearCalcFields(Buffer: TRecordBuffer); override;
    procedure SetFiltered(Value: Boolean); override;

    function GetStringValue(const Buffer : TRecordBuffer; ADataSize: Integer) : String;
    function GetIntegerValue(const Buffer : TRecordBuffer; DataType : TFieldType) : Integer;
    function GetLargeIntValue(const Buffer : TRecordBuffer; DataType : TFieldType) : Int64;
    function GetFloatValue(const Buffer : TRecordBuffer) : Double;
    function GetCurrencyValue(const Buffer : TRecordBuffer) : System.Currency;
    function GetDateTimeValue(const Buffer: TRecordBuffer; AField: TField): TDateTime;
    function GetBooleanValue(const Buffer : TRecordBuffer) : Boolean;
    function GetVariantValue(const Buffer : TRecordBuffer; AField : TField) : Variant;
    function InternalCompareValues(const Buffer1, Buffer2: Pointer; AmField: TMvxMemField; IsCaseInSensitive: Boolean) : Integer;
    function CompareValues(const Buffer1, Buffer2 : TRecordBuffer; AmField: TMvxMemField) : Integer; overload;
    function CompareValues(const Buffer1, Buffer2 : TRecordBuffer; AField: TField) : Integer; overload;

    function InternalGotoNearest(List : TList; AField : TField;
          const Buffer : TRecordBuffer; ASortOptions: TMvxSortOptions; var Index : Integer) : Boolean;
    function GotoNearest(const Buffer : TRecordBuffer; ASortOptions: TMvxSortOptions; var Index : Integer) : Boolean;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetOnFilterRecord(const Value: TFilterRecordEvent); override;
    procedure InternalAddFilterRecord;
    procedure MakeRecordSort;
    procedure UpdateFilterRecord; virtual;

    procedure CloseBlob(Field: TField); override;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function GetFieldData(Field: TField; Buffer: TValueBuffer): Boolean; override;
    function GetFieldData(Field: TField; Buffer: TValueBuffer; NativeFormat: Boolean): Boolean; override;
    function BookmarkValid(Bookmark: TBookmark): Boolean; override;
    function GetCurrentRecord(Buffer: TRecordBuffer): Boolean; override;
    function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer; override;
    function Locate(const KeyFields: string; const KeyValues: Variant;
             Options: TLocateOptions): Boolean; override;
    function Lookup(const KeyFields: string; const KeyValues: Variant;
      const ResultFields: string): Variant; override;
    function GetRecNoByFieldValue(Value : Variant; FieldName : String) : Integer; virtual;

    function GetFieldClass(FieldType: TFieldType): TFieldClass; override;

    function SupportedFieldType(AType: TFieldType): Boolean; virtual;

    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;

    procedure FillBookMarks;
    procedure MoveCurRecordTo(Index : Integer);
    procedure LoadFromTextFile(FileName : String); dynamic;
    procedure SaveToTextFile(FileName : String); dynamic;
    procedure LoadFromBinaryFile(FileName : String);
    procedure SaveToBinaryFile(FileName : String);
    procedure LoadFromStream(Stream : TStream);
    procedure SaveToStream(Stream : TStream);
    procedure CreateFieldsFromStream(Stream : TStream);
    procedure CreateFieldsFromDataSet(DataSet : TDataSet);
    procedure LoadFromDataSet(DataSet : TDataSet);
    procedure CopyFromDataSet(DataSet : TDataSet);

    procedure UpdateFilters; virtual;
    {if failed return -1, in other case the record count with the same value}
    function GetValueCount(FieldName : String; Value : Variant) : Integer;

    procedure SetFilteredRecNo(Value: Integer);


    //Again for the guys from AQA. Hi Atanas :-)
    property CurRec: Integer read FCurRec write FCurRec;

    procedure GetMICommandList(const AMIProgram: String; AList: TStrings); 

    procedure Prepare;
    
    property Prepared: boolean read GetPrepared;
    property MIProgram: string read GetMIProgram write SetMIProgram;
    property MICommand: string read GetMICommand write SetMICommand;
    property Connection: TMvxConnection read GetConnection write SetConnection;
    property Params: TMvxParams read GetMvxParams;    

    property BlobFieldCount;
    property BlobList: TList read FBlobList;
    //FilterList made public - so we can set the list of filtered records
    //when ProgrammedFilter is True, the developer is responsible to set the list
    property FilterList: TList read FFilterList;
    //ProgrammedFilter - for faster setting of the filers. This avoids calling OnFilterRecord
    property ProgrammedFilter: Boolean read FProgrammedFilter write FProgrammedFilter;

    property RecIdField : TField read FRecIdField;
    property IsLoading : Boolean read FLoadFlag write FLoadFlag;
    property Data : TMvxMemFields read FData;
    property DelimiterChar : Char read FDelimiterChar write FDelimiterChar;
    property Filter;

    property Indexes: TMvxMemIndexes read fIndexes write SetIndexes;
    property Persistent: TMvxMemPersistent read fPersistent write SetPersistent;
    property ReadOnly : Boolean read FReadOnly write FReadOnly default False;
    property SortOptions : TMvxSortOptions read GetSortOptions write SetSortOptions;
    property SortedField : String read FSortedFieldName write SetSortedField;
    property OnPrepare: TNotifyEvent read FOnPrepare write SetOnPrepare;
  end;

  TMvxDataset = class(TMvxCustomDataset)  
  published
    property MIProgram;
    property MICommand;
    property Connection;
    property Params;
    property Active;
    property Indexes;
    property Persistent;
    property ReadOnly;
    property SortOptions;
    property SortedField;
    
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnNewRecord;
    property OnPostError;
    property OnFilterRecord;   
  end;

procedure FillZeroData(ADestination: Pointer; ACount: Integer);
function ReadBufferFromStream(AStream: TStream; Dest: Pointer; Count: Integer): Boolean;

function ReadByte(ASource: Pointer; AOffset: Integer = 0): Byte;
function ReadInteger(ASource: Pointer; AOffset: Integer = 0): Integer;
function ReadWord(ASource: Pointer; AOffset: Integer = 0): Word;
procedure WriteByte(ADest: Pointer; AValue: Byte; AOffset: Integer = 0);
procedure WriteInteger(ADest: Pointer; AValue: Integer; AOffset: Integer = 0);
procedure WriteWord(ADest: Pointer; AValue: Word; AOffset: Integer = 0);

function WriteCharToStream(AStream: TStream; AValue: Char): Longint; overload;
function WriteDoubleToStream(AStream: TStream; AValue: Double): Longint; overload;
function WriteIntegerToStream(AStream: TStream; AValue: Integer): Longint; overload;
function WriteSmallIntToStream(AStream: TStream; AValue: SmallInt): Longint; overload;
function WriteStringToStream(AStream: TStream; AValue: string): Longint; overload;
function WriteBufferToStream(AStream: TStream; Buffer: Pointer; Count: Longint): Longint; overload;

procedure CopyData(Source, Dest: Pointer; Count: Integer); overload;
procedure CopyData(Source, Dest: Pointer; ASourceOffSet, ADestOffSet, Count: Integer); overload;

procedure DateTimeToMemDataValue(Value : TDateTime; pt : TRecordBuffer; Field : TField);
function VariantToMemDataValue(AValue: Variant; AMemDataValue: Pointer; AField: TField) : Boolean;

implementation

uses
  DBConsts, StrUtils, Contnrs, DBCommon, Windows, Forms;

resourcestring
  SClosedTransaction = 'Attempt to initialize new transaction from a closed connection';
  SNoConnection = 'Connection has not been assigned';
  SUnPreparedTrans = 'Attempt to execute transaction that has not been prepared';

const
  MVX_RES_NAME = 'MRS001MI';
  MVX_FIELD_LIST = 'LstFields';
  MVX_PGM_LIST = 'LstPrograms';
  MVX_CMD_LIST = 'LstTransactions';
  IncorrectedData = 'The data is incorrect';
  ftStrings = [ftWideString, ftString];
  MemDataVer = 1.00;
  CMD_LEN = 15;
  RESERVED_LEN = 2;

procedure StrCopyEx(ASrc: PChar;const AStrToCopy: string; const APos, ALen: integer);
var
  i, AL: integer;
begin
  AL := Length(AStrToCopy);
  if AL > ALen then
    AL := ALen;
  for i := 1 to AL do
    ASrc[APos+i-2] := AstrToCopy[i];
end;

function  StrReplicate(const X:Char;Count:Integer):AnsiString;
begin
  if Count>0 then begin
    SetLength(Result,Count);
    if Length(Result)=Count then FillChar(Result[1],Count,X);
  end;
end;

function GetNoByFieldType(FieldType : TFieldType) : Integer; forward;


procedure FillZeroData(ADestination: Pointer; ACount: Integer);
begin
  ZeroMemory(ADestination, ACount);
end;

function AllocMem(Size: Cardinal): Pointer;
begin
  Result := GetMemory(Size);
  FillZeroData(Result, Size);
end;

procedure FreeMem(P: Pointer);
begin
  FreeMemory(P);
end;

function ReadBufferFromStream(AStream: TStream; Dest: Pointer; Count: Integer): Boolean;
begin
  Result := AStream.Read(Dest^, Count) = Count;
end;

function ReadByte(ASource: Pointer; AOffset: Integer = 0): Byte;
begin
  CopyData(ASource, @Result, AOffset, 0, SizeOf(Byte));
end;

function ReadInteger(ASource: Pointer; AOffset: Integer = 0): Integer;
begin
  CopyData(ASource, @Result, AOffset, 0, SizeOf(Integer));
end;

function ReadPointer(ASource: Pointer): Pointer;
begin
  Result := Pointer(ASource^);
end;

function ReadWord(ASource: Pointer; AOffset: Integer = 0): Word;
begin
  CopyData(ASource, @Result, AOffset, 0, SizeOf(Word));
end;

procedure WriteByte(ADest: Pointer; AValue: Byte; AOffset: Integer = 0);
begin
  CopyData(@AValue, ADest, 0, AOffset, SizeOf(Byte));
end;

procedure WriteInteger(ADest: Pointer; AValue: Integer; AOffset: Integer = 0);
begin
  CopyData(@AValue, ADest, 0, AOffset, SizeOf(Integer));
end;

procedure WritePointer(ADest: Pointer; AValue: Pointer);
begin
  Pointer(ADest^) := AValue;
end;

procedure WriteWord(ADest: Pointer; AValue: Word; AOffset: Integer = 0);
begin
  CopyData(@AValue, ADest, 0, AOffset, SizeOf(Word));
end;

function WriteCharToStream(AStream: TStream; AValue: Char): Longint;
begin
  Result := AStream.Write(AValue, 1);
end;

function WriteDoubleToStream(AStream: TStream; AValue: Double): Longint;
begin
  Result := AStream.Write(AValue, SizeOf(Double));
end;

function WriteIntegerToStream(AStream: TStream; AValue: Integer): Longint;
begin
  Result := AStream.Write(AValue, SizeOf(Integer));
end;

function WriteSmallIntToStream(AStream: TStream; AValue: SmallInt): Longint;
begin
  Result := AStream.Write(AValue, SizeOf(SmallInt));
end;

function WriteStringToStream(AStream: TStream; AValue: string): Longint;
var
  APValue: PChar;
begin
  Result := AStream.Write(PChar(AValue)^, Length(AValue));
end;

function WriteBufferToStream(AStream: TStream; Buffer: Pointer; Count: Longint): Longint;
var
  AData: TBytes;
begin
  SetLength(AData, Count);
  if Buffer <> nil then
    CopyData(Buffer, AData, Count);

  Result := AStream.Write(AData[0], Count);
end;

function GetFieldValue(AField: TField): Variant;
begin
  if AField.DataType = ftWideString then  // Borland bug with WideString
    Result := AField.AsString
  else
    Result := AField.Value;
end;

procedure Shift(var P: Pointer; AOffset: Integer);
begin
  P := Pointer(Integer(P) + AOffset);
end;

function GetCharSize(AFieldType: TFieldType): Integer;
begin
  case AFieldType of
    ftString: Result := 1;
    ftWideString: Result := 2;
  else
    Result := 0;
  end;
end;

function GetDataSize(AField: TField): Integer; overload;
begin
  if AField.DataType in ftStrings then
    Result := (AField.Size + 1) * GetCharSize(AField.DataType)
  else
    Result := AField.DataSize;
end;

function GetDataSize(AParam: TMvxParam): Integer; overload;
begin
  if AParam.DataType in ftStrings then
    Result := (AParam.Size + 1) * GetCharSize(AParam.DataType)
  else
    Result := AParam.GetDataSize;
end;

function StrLen(const S: Pointer; AFieldType: TFieldType): Integer;
begin
  Result := 0;
  case AFieldType of
    ftWideString:
      while (ReadWord(S, Result * GetCharSize(AFieldType)) <> 0) do
        Inc(Result);
    ftString:
      while (ReadByte(S, Result * GetCharSize(AFieldType)) <> 0) do
        Inc(Result);
  end;
end;

function AllocBuferForString(ALength: Integer; AFieldType: TFieldType): Pointer;
begin
  Result := AllocMem((ALength + 1) * GetCharSize(AFieldType));
end;

procedure CopyData(Source, Dest: Pointer; Count: Integer);
begin
  Move(Source^, Dest^, Count);
end;

procedure CopyData(Source, Dest: Pointer; ASourceOffSet, ADestOffSet, Count: Integer); overload;
begin
  if ASourceOffSet > 0 then
    Source := Pointer(Integer(Source) + ASourceOffSet);
  if ADestOffSet > 0 then
    Dest := Pointer(Integer(Dest) + ADestOffSet);
  CopyData(Source, Dest, Count);
end;

procedure CopyChars(ASource, ADest: Pointer; AMaxCharCount: Integer; AFieldType: TFieldType);
var
  ACharCount: Integer;
begin
  ACharCount := StrLen(ASource, AFieldType);
  if ACharCount > AMaxCharCount then
    ACharCount := AMaxCharCount;
  CopyData(ASource, ADest, ACharCount * GetCharSize(AFieldType));
  Shift(ADest, ACharCount * GetCharSize(AFieldType));
  FillZeroData(ADest, GetCharSize(AFieldType));
end;

procedure DateTimeToMemDataValue(Value : TDateTime; pt : TRecordBuffer; Field : TField);
var
  TimeStamp: TTimeStamp;
  Data: TDateTimeRec;
  DataSize : Integer;
begin
  TimeStamp := DateTimeToTimeStamp(Value);
  DataSize := 4;
  case Field.DataType of
    ftDate: Data.Date := TimeStamp.Date;
    ftTime: Data.Time := TimeStamp.Time;
  else
    begin
      Data.DateTime := TimeStampToMSecs(TimeStamp);
      DataSize := 8;
    end;
  end;
  Move(Data, pt^, DataSize);
end;

function VariantToMemDataValue(AValue: Variant; AMemDataValue: Pointer; AField : TField): Boolean;
var
  aString: string;
  wString : WideString;
  dbl : Double; //TFloatField
  bcd : System.Currency; //TBCDField
  bcdvalue: TBCD;
  Int64_ : Int64;
begin
  Result := True;
  case AField.DataType of
    ftString:
      begin
        aString := AValue;
        CopyChars(PChar(aString), AMemDataValue, AField.Size, AField.DataType);
      end;
      ftWideString:
      begin
        wString := AValue;
        CopyChars(PWideChar(wString), AMemDataValue, AField.Size, AField.DataType);
      end;
    ftDate, ftTime, ftDateTime: DateTimeToMemDataValue(AValue, AMemDataValue, AField);
    ftSmallint: WriteWord(AMemDataValue, AValue);
    ftInteger, ftAutoInc: WriteInteger(AMemDataValue, AValue);
    ftWord: WriteWord(AMemDataValue, AValue);
    ftBoolean: WriteWord(AMemDataValue, AValue);
    ftFloat, ftCurrency:
      begin
        dbl := AValue;
        Move(dbl, AMemDataValue^, AField.DataSize);
      end;
    ftBCD:
      begin
        bcd := AValue;
        CurrToBCD(bcd, bcdvalue);
        Move(bcdvalue, AMemDataValue^, SizeOf(TBCD));
      end;
      ftLargeInt:
      begin
        Int64_ := AValue;
        Move(Int64_, AMemDataValue^, AField.DataSize);
      end;
      else Result := False;
    end;
end;


{ TMvxConnection }

procedure TMvxCustomConnection.Check(AResult: Integer);
begin
  if (AResult <> 0) then
    raise EMvxAPIError.Create(PHandle^.Buffer);
end;

procedure TMvxCustomConnection.Check(const AResult: string);
begin
  if (Pos('NOK', AResult) = 1) then
    raise EMvxAPIError.Create(Copy(AResult, 16, Length(AResult) - 16));
end;

constructor TMvxCustomConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  New(PHandle);
  FConnected := False;
  FAPILib := nil;
  LoadLibrary;
  FCompName := 'LOCALA';
  FPgmList := TStringList.Create;
  DoDisconnect;
end;

destructor TMvxCustomConnection.Destroy;
begin
  FPgmList.Free;
  while DatasetCount > 0 do
    UnregisterDataset(TMvxCustomDataset(Datasets[0]));
  Connected := False;
  Dispose(PHandle);
  inherited Destroy;
end;

procedure TMvxCustomConnection.DoConnect;
begin
  if Connected then
    exit;
  Setup;
  GetPgmList;
  FConnected := True;
end;

procedure TMvxCustomConnection.DoDisconnect;
var
  i: integer;
begin
  FConnected := False;
  if DataSetCount > 0 then
    for i := 0 to DataSetCount-1 do
      DataSets[i].Active := False;
end;

function TMvxCustomConnection.GetConnected: Boolean;
begin
  Result := FConnected;
end;

procedure TMvxCustomConnection.GetPgmList;
var
  AMvxCmd: TMvxTransact;
  AStat: TMvxTransactionStatus;
begin
  FPgmList.Clear;
  AMvxCmd := TMvxTransact.Create(Self);
  try
    AMvxCmd.Connection := TMvxConnection(Self);
    AMvxCmd.MIProgram := MVX_RES_NAME;
    AMvxCmd.MICommand := MVX_PGM_LIST;
    AMvxCmd.Open;
    try
      AStat := AMvxCmd.Transact;
      if AStat = stREP then
      begin
        while AStat = stREP do
        begin
          FPgmList.Add(AMvxCmd.OutputParams.Items[0].AsString);
          AStat := AMvxCmd.Receive;
        end;
      end else
      if AStat = stOK then
        FPgmList.Add(AMvxCmd.OutputParams.Items[0].AsString);
    finally
      AMvxCmd.Close;
    end;
  finally
    AMvxCmd.Free;
  end;
end;

procedure TMvxCustomConnection.GetProgramList(AList: TStrings);
begin
  if not Connected then
    Open;
  AList.Assign(FPgmList);
end;

procedure TMvxCustomConnection.LoadLibrary;
begin
  if not Assigned(FAPILib) then
    FAPILib:=MvxIntf.GetClientLibrary(MVX_SOCKET_DLL);
end;

procedure TMvxCustomConnection.RegisterDataset(
  ADataset: TMvxCustomDataset);
begin
  RegisterClient(ADataset);
end;

procedure TMvxCustomConnection.SetAppName(const Value: string);
begin
  if (FAppName <> Value) then
    FAppName := Value;
end;

procedure TMvxCustomConnection.SetHost(const Value: string);
begin
  if FHost <> Value then
    FHost := Value;
end;

procedure TMvxCustomConnection.SetPort(const Value: integer);
begin
  if FPort <> Value then
    FPort := Value;
end;

procedure TMvxCustomConnection.SetSecured(const Value: boolean);
begin
  if FSecured <> Value then
    FSecured := Value;
end;

procedure TMvxCustomConnection.SetSecureKey(const Value: string);
begin
  if FSecureKey <> Value then
    FSecureKey := Value;
end;

{ TMvxTransact }
procedure TMvxTransact.Close;
begin
  if not FOpened then
    exit;
  FOpened := False;
  with Connection do
    Check(APILibrary.MvxSockClose(PHandle));
end;

procedure TMvxTransact.ConstructParams;

type
  TMvxFieldRec = record
    Name: string;
    DataType: TFieldType;
    IdxFrom: integer;
    Size: integer;
    Mandatory: Boolean;
  end;

const
  CMvxIFields: array[1..3] of TMvxFieldRec =
  (
    (Name: 'IMINM'; DataType: ftString; IdxFrom: 16; Size: 10; Mandatory: False),
    (Name: 'ITRNM'; DataType: ftString; IdxFrom: 26; Size: 15; Mandatory: False),
    (Name: 'ITRTP'; DataType: ftString; IdxFrom: 41; Size:  1; Mandatory: False)
  );
  
  CMvxOFields: array[1..16] of TMvxFieldRec =
  (
     (Name: 'OMINM'; DataType: ftString; IdxFrom: 16; Size: 10; Mandatory: False),
     (Name: 'OTRNM'; DataType: ftString; IdxFrom: 26; Size: 15; Mandatory: False),
     (Name: 'OTRTP'; DataType: ftString; IdxFrom: 41; Size:  1; Mandatory: False),
     (Name: 'OFLNM'; DataType: ftString; IdxFrom: 42; Size: 10; Mandatory: False),
     (Name: 'OFLDS'; DataType: ftString; IdxFrom: 52; Size: 60; Mandatory: False),
     (Name: 'OTXT1'; DataType: ftString; IdxFrom:112; Size: 13; Mandatory: False),
     (Name: 'OFRPO'; DataType: ftString; IdxFrom:125; Size:  3; Mandatory: False),
     (Name: 'OTOPO'; DataType: ftString; IdxFrom:128; Size:  3; Mandatory: False),
     (Name: 'OLENG'; DataType: ftString; IdxFrom:131; Size:  3; Mandatory: False),
     (Name: 'OTYPE'; DataType: ftString; IdxFrom:134; Size:  1; Mandatory: False),
     (Name: 'OMAND'; DataType: ftString; IdxFrom:135; Size:  1; Mandatory: False),
     (Name: 'ORGDT'; DataType: ftString; IdxFrom:136; Size:  8; Mandatory: False),
     (Name: 'ORGTM'; DataType: ftString; IdxFrom:144; Size:  6; Mandatory: False),
     (Name: 'OLMDT'; DataType: ftString; IdxFrom:150; Size:  8; Mandatory: False),
     (Name: 'OCHNO'; DataType: ftString; IdxFrom:158; Size:  3; Mandatory: False),
     (Name: 'OCHID'; DataType: ftString; IdxFrom:161; Size: 10; Mandatory: False)
  );
var
  AMvxResCmd: TMvxTransact;

  procedure PrepareParams(AParams: TMvxParams; IO: Boolean);
  var
    i: integer;
  begin
    if IO then
      for i := 1 to 3 do
        with TMvxParam(AParams.Add) do
        begin
          Name := CMvxIFields[i].Name;
          DataType := CMvxIFields[i].DataType;
          IdxFrom := CMvxIFields[i].IdxFrom;
          Size := CMvxIFields[i].Size;
          Mandatory := CMvxIFields[i].Mandatory;
        end
    else
      for i := 1 to 16 do
        with TMvxParam(AParams.Add) do
        begin
          Name := CMvxOFields[i].Name;
          DataType := CMvxOFields[i].DataType;
          IdxFrom := CMvxOFields[i].IdxFrom;
          Size := CMvxOFields[i].Size;
          Mandatory := CMvxOFields[i].Mandatory;
        end;
  end;

  procedure InternalConstructParams(const IO: Boolean; AParams: TMvxParams);
  var
    IParams: TMvxParams;
    OParams: TMvxParams;
    AStat: TMvxTransactionStatus;
  begin
    IParams := TMvxParams.Create(Self);
    OParams := TMvxParams.Create(Self);
    try
      PrepareParams(IParams, True);
      PrepareParams(OParams, False);
      IParams.Items[0].AsString := MIProgram;
      IParams.Items[1].AsString := MICommand;
      IParams.Items[2].AsString := IfThen(IO, 'I','O');
      AStat := AMvxResCmd.Transact(IParams, OParams); 
      if AStat = stREP then
      begin
        while AStat = stREP do
        begin
          with TMvxParam(AParams.Add) do
          begin
            Name := OParams.Items[3].AsString;
            IdxFrom := OParams.Items[6].AsInteger;
            Size := OParams.Items[8].AsInteger;
            Mandatory := OParams.Items[10].AsString <> '0';
            case UpCase(OParams.Items[9].AsString[1]) of
              'N', 'D': DataType := ftInteger;
              'A': DataType := ftString;
            else
              DataType := ftUnknown;
            end;
          end;
          AStat := AMvxResCmd.Receive(OParams);
        end;        
      end else
      if AStat = stOK then
      begin
        with TMvxParam(AParams.Add) do
        begin
          Name := OParams.Items[3].AsString;
          IdxFrom := OParams.Items[6].AsInteger;
          Size := OParams.Items[8].AsInteger;
          Mandatory := OParams.Items[10].AsString <> '0';
          case UpCase(OParams.Items[9].AsString[1]) of
            'N', 'D': DataType := ftInteger;
            'A': DataType := ftString;
          else
            DataType := ftUnknown;
          end;
        end;
      end;
    finally
      IParams.Free;
      OParams.Free;
    end;    
  end;
begin
  AMvxResCmd := TMvxTransact.Create(Self);
  AMvxResCmd.Connection := Self.Connection;
  AMvxResCmd.FMIProgram := MVX_RES_NAME;
  AMvxResCmd.FMICommand := MVX_FIELD_LIST;
  AMvxResCmd.FPrepared  := True;
  AMvxResCmd.FPreparedTrans := True;
  AMvxResCmd.Dataset    := Self.Dataset;
  try
    AMvxResCmd.Open;
    try
      FIParams.Clear;
      FOParams.Clear;
      try      
        InternalConstructParams(True, FIParams);
      except; end;
      try
        InternalConstructParams(False, FOParams);
      except; end;
    finally
      AMvxResCmd.Close;
    end;
  finally
    AMvxResCmd.Free;
  end;
end;

constructor TMvxTransact.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FConnection := nil;
  FIParams := TMvxParams.Create(Self);
  FOParams := TMvxParams.Create(Self);
  FOpened  := False;
  FPreparedTrans := False;
  FPrepared := False;
  FOBuffer := nil;
  FOLen := 0;
end;

destructor TMvxTransact.Destroy;
begin
  FIParams.Free;
  FOParams.Free;
  if Assigned(FOBuffer) then
    AllocBuffer(0);
  inherited Destroy;
end;

procedure TMvxTransact.Open;
begin
  with Connection do
  begin
    Setup;
    Check(APILibrary.MvxSockInit(PHandle, PChar(ComputerName),
      PChar(UserName), PChar(Password), PChar(FMIProgram)));
    FOpened := True;
  end;
end;

procedure TMvxTransact.Prepare;
begin
  if FOpened then
    Close;
  if (FMIProgram <> EmptyStr) and (FMICommand <> EmptyStr) and
     (Connection <> nil) and (not Prepared) then
  begin
    ConstructParams;
    FPrepared := True;
    if Assigned(OnPrepare) then
      FOnPrepare(Self);
  end;
end;

function TMvxTransact.Receive(OParams: TMvxParams): TMvxTransactionStatus;
var
  ALen: integer;
begin
  if not FOpened then
    raise EMvxAPIError.Create(SClosedTransaction);
  Result := stNOK;
  with Connection do
  begin
    ALen := FOLen; 
    Check(APILibrary.MvxSockReceive(PHandle, FOBuffer, @ALen));
    if not FPreparedTrans then
      Check(FOBuffer);
    if (Pos('NOK ', FOBuffer) = 1) then
      Result := stNOK
    else if (Pos('OK ', FOBuffer) = 1) then
      Result := stOK
    else if (Pos('REP', FOBuffer) = 1) then
      Result := stREP;
    if Result <> stNOK then
    begin
      OParams.ClearValues;
      OParams.ParseParams(FOBuffer);
    end;    
  end;
end;

function TMvxTransact.Transact(IParams, OParams: TMvxParams): TMvxTransactionStatus;
var
  AStr: string;
  ALen: integer;
begin
  if not FOpened then
    raise EMvxAPIError.Create(SClosedTransaction);
  if not FPrepared then
    raise EMvxAPIError.Create(SUnPreparedTrans);
  Result := stNOK;
  ALen := OParams.CalcRcvSize;
  Inc(ALen, CMD_LEN + RESERVED_LEN);
  with Connection do
  begin
    AStr := IParams.BindParams;
    if AStr = EmptyStr then
      AStr := StrReplicate(#32, 15);
    if FOLen < ALen then
      AllocBuffer(ALen + 1);
    StrCopyEx(PChar(AStr), FMICommand, 1, 15);
    Check(APILibrary.MvxSockTrans(PHandle, PChar(AStr), FOBuffer, @ALen));
    if not FPreparedTrans then
      Check(FOBuffer);
    if (Pos('NOK ', FOBuffer) = 1) then
      Result := stNOK
    else if (Pos('OK ', FOBuffer) = 1) then
      Result := stOK
    else if (Pos('REP', FOBuffer) = 1) then
      Result := stREP;
    if Result <> stNOK then
    begin
      OParams.ClearValues;
      OParams.ParseParams(FOBuffer);
    end;
  end;  
end;

function TMvxTransact.Receive: TMvxTransactionStatus;
begin
  Result := Receive(FOParams);
end;

function TMvxTransact.Transact: TMvxTransactionStatus;
begin
  Result := Transact(FIParams, FOParams);
end;

procedure TMvxTransact.SetMICommand(const Value: string);
begin
  if FMICommand <> Value then
  begin
    FMICommand := Value;
    FPrepared := False;
    Prepare;
  end;
end;

procedure TMvxTransact.SetMIProgram(const Value: string);
begin
  if FMIProgram <> Value then
  begin
    FMIProgram := Value;
    FPrepared := False;
    Prepare;
  end;
end;

procedure TMvxTransact.AllocBuffer(ASize: integer);
begin
  ReallocMem(FOBuffer, ASize);
  FOLen := ASize;
end;

{ TMvxParam }

procedure TMvxParam.Assign(Source: TPersistent);
  procedure LoadFromStreamPersist(const StreamPersist: IStreamPersist);
  var
    MS: TMemoryStream;
  begin
    MS := TMemoryStream.Create;
    try
      StreamPersist.SaveToStream(MS);
      LoadFromStream(MS, ftGraphic);
    finally
      MS.Free;
    end;
  end;

  procedure LoadFromStrings(Source: TSTrings);
  begin
    AsString := Source.Text;
  end;

var
  StreamPersist: IStreamPersist;
begin
  if Source is TMvxParam then
    AssignParam(TMvxParam(Source))
  else if Source is TStrings then
    LoadFromStrings(TStrings(Source))
  else if Supports(Source, IStreamPersist, StreamPersist) then
    LoadFromStreamPersist(StreamPersist)
  else
    inherited Assign(Source);
end;

procedure TMvxParam.AssignParam(Param: TMvxParam);
begin
  if Param <> nil then
  begin
    FDataType := Param.DataType;
    if Param.IsNull then
      Clear else
      Value := Param.FData;
    FBound := Param.Bound;
    Name := Param.Name;
    Size := Param.Size;
    IdxFrom := Param.IdxFrom;
    IdxTo := Param.IdxTo;
  end;
end;

procedure TMvxParam.AssignTo(Dest: TPersistent);
begin
  if Dest is TField then
    TField(Dest).Value := FData else
    inherited AssignTo(Dest);
end;

procedure TMvxParam.Clear;
begin
  FNull := True;
  FData := Unassigned;
end;

constructor TMvxParam.Create(Collection: TCollection);
var
  AParam: TMvxParam;
begin
  inherited Create(Collection);
  ParamType := ptUnknown;
  DataType := ftUnknown;
  FSize := 0;
  FData := Unassigned;
  FBound := False;
  FNull := True;
  FIdxFrom := 0;
  FIdxTo := 0;
end;

constructor TMvxParam.Create(AParams: TMvxParams;
  AParamType: TMvxParamType);
begin
  Create(AParams);
  ParamType := AParamType;
end;

function TMvxParam.GetAsBCD: Currency;
begin
  if IsNull then
    Result := 0 else
    Result := FData;
end;

function TMvxParam.GetAsInteger: LongInt;
begin
  if IsNull then
    Result := 0 else
    Result := FData;
end;

function TMvxParam.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else if DataType = ftBoolean then
  begin
    if FData then
      Result := STextTrue else
      Result := STextFalse;
  end else
    Result := FData;
end;

function TMvxParam.GetAsVariant: Variant;
begin
  Result := ParamRef.FData;
end;

procedure TMvxParam.GetData(Buffer: Pointer);
var
  P: Pointer;
begin
  case DataType of
    ftUnknown: DatabaseErrorFmt(SUnknownFieldType, [Name], DataSet);
    ftString, ftFixedChar, ftMemo, ftAdt:
      StrMove(Buffer, PChar(GetAsString), Length(GetAsString) + 1);
    ftSmallint: SmallInt(Buffer^) := GetAsInteger;
    ftWord: Word(Buffer^) := GetAsInteger;
    ftAutoInc,
    ftInteger: Integer(Buffer^) := GetAsInteger;
//    ftTime: Integer(Buffer^) := DateTimeToTimeStamp(AsDateTime).Time;
//    ftDate: Integer(Buffer^) := DateTimeToTimeStamp(AsDateTime).Date;
//    ftDateTime:  Double(Buffer^) := TimeStampToMSecs(DateTimeToTimeStamp(AsDateTime));
    ftBCD: CurrToBCD(AsBCD, TBcd(Buffer^));
//    ftFMTBCD: TBcd(Buffer^) := AsFMTBcd;
    ftCurrency,
//    ftFloat: Double(Buffer^) := GetAsFloat;
//    ftTimeStamp:  TSQLTimeStamp(Buffer^) := AsSQLTimeStamp;
//    ftBoolean: Word(Buffer^) := Ord(GetAsBoolean);
    ftBytes, ftVarBytes:
    begin
      if VarIsArray(FData) then
      begin
        P := VarArrayLock(FData);
        try
          Move(P^, Buffer^, VarArrayHighBound(FData, 1) + 1);
        finally
          VarArrayUnlock(FData);
        end;
      end;
    end;
    ftBlob, ftGraphic..ftTypedBinary,ftOraBlob,ftOraClob:
      Move(PChar(GetAsString)^, Buffer^, Length(GetAsString));
    ftArray, ftDataSet,
    ftReference, ftCursor: {Nothing};
  else
    DatabaseErrorFmt(SBadFieldType, [Name], DataSet);
  end;
end;

function TMvxParam.GetDataSet: TDataSet;
begin
  if not Assigned(Collection) then
    Result := nil else
    Result := TMvxParams(Collection).GetDataSet;
end;

function TMvxParam.GetDataSize: Integer;
begin
  Result := 0;
  case DataType of
    ftUnknown: DatabaseErrorFmt(SUnknownFieldType, [Name], DataSet);
    ftString, ftFixedChar, ftMemo, ftADT: Result := Length(VarToStr(FData)) + 1;
    ftBoolean: Result := SizeOf(WordBool);
    ftBCD, ftFMTBcd: Result := SizeOf(TBcd);
    ftTimeStamp: Result := SizeOf( TSqlTimeStamp );
    ftDateTime,
    ftCurrency,
    ftFloat: Result := SizeOf(Double);
    ftTime,
    ftDate,
    ftAutoInc,
    ftInteger: Result := SizeOf(Integer);
    ftSmallint: Result := SizeOf(SmallInt);
    ftWord: Result := SizeOf(Word);
    ftBytes, ftVarBytes:
      if VarIsArray(FData) then
        Result := VarArrayHighBound(FData, 1) + 1 else
        Result := 0;
    ftBlob, ftGraphic..ftTypedBinary,ftOraClob,ftOraBlob: Result := Length(VarToStr(FData));
    ftArray, ftDataSet,
    ftReference, ftCursor: Result := 0;
  else
    DatabaseErrorFmt(SBadFieldType, [Name], DataSet);
  end;
end;

function TMvxParam.GetDataType: TFieldType;
begin
  Result := ParamRef.FDataType;
end;

function TMvxParam.GetIsNull: Boolean;
begin
  Result := FNull or VarIsNull(FData) or VarIsClear(FData);
end;

function TMvxParam.GetParamType: TMvxParamType;
begin
  Result := ParamRef.FParamType;
end;

function TMvxParam.IsEqual(Value: TMvxParam): Boolean;
begin
  Result := (VarType(FData) = VarType(Value.FData)) and
    (VarIsClear(FData) or (FData = Value.FData)) and
    (Name = Value.Name) and (DataType = Value.DataType) and
    (IsNull = Value.IsNull) and(Bound = Value.Bound);
end;

function TMvxParam.IsParamStored: Boolean;
begin
  Result := Bound;
end;

procedure TMvxParam.LoadFromFile(const FileName: string;
  BlobType: TBlobType);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(Stream, BlobType);
  finally
    Stream.Free;
  end;
end;

procedure TMvxParam.LoadFromStream(Stream: TStream; BlobType: TBlobType);
var
  DataStr: string;
  Len: Integer;
begin
  with Stream do
  begin
    FDataType := BlobType;
    Position := 0;
    Len := Size;
    SetLength(DataStr, Len);
    ReadBuffer(Pointer(DataStr)^, Len);
    Self.Value := DataStr;
  end;
end;

function TMvxParam.ParamRef: TMvxParam;
begin
  if not Assigned(FParamRef) then
    if Assigned(Collection) and (Name <> '') then
      FParamRef := TMvxParams(Collection).ParamByName(Name) else
      FParamRef := Self;
  Result := FParamRef;
end;

procedure TMvxParam.SetAsBCD(const Value: Currency);
begin
  FDataType := ftBCD;
  Self.Value := Value;
end;

procedure TMvxParam.SetAsBlob(const Value: TBlobData);
begin
  FDataType := ftBlob;
  Self.Value := Value;
end;

procedure TMvxParam.SetAsInteger(const Value: LongInt);
begin
  FDataType := ftInteger;
  Self.Value := Value;
end;

procedure TMvxParam.SetAsString(const Value: string);
var
  ALen: integer;
begin
  if FDataType <> ftFixedChar then FDataType := ftString;
  ALen := Length(Value);
  if ALen > Size then
    ALen := Size;
  Self.Value := Copy(Value, 1, ALen);
end;

procedure TMvxParam.SetAsVariant(const Value: Variant);
begin
  if ParamRef = Self then
  begin
    FBound := not VarIsClear(Value);
    FNull := VarIsClear(Value) or VarIsNull(Value);
    if FDataType = ftUnknown then
      case VarType(Value) of
        varSmallint, varShortInt, varByte: FDataType := ftSmallInt;
        varWord, varInteger: FDataType := ftInteger;
        varCurrency: FDataType := ftBCD;
        varLongWord, varSingle, varDouble: FDataType := ftFloat;
        varDate: FDataType := ftDateTime;
        varBoolean: FDataType := ftBoolean;
        varString, varOleStr: if FDataType <> ftFixedChar then FDataType := ftString;
        varInt64: FDataType := ftLargeInt;
      else
        if VarType(Value) = varSQLTimeStamp then
          FDataType := ftTimeStamp
        else if VarType(Value) = varFMTBcd then
          FDataType := ftFMTBcd
        else 
          FDataType := ftUnknown;
      end;
    FData := Value;
  end else
    ParamRef.SetAsVariant(Value);
end;

procedure TMvxParam.SetBlobData(Buffer: Pointer; Size: Integer);
var
  DataStr: string;
begin
  SetLength(DataStr, Size);
  Move(Buffer^, PChar(DataStr)^, Size);
  AsBlob := DataStr;
end;

procedure TMvxParam.SetData(Buffer: Pointer);
var
  Value: Currency;
  TimeStamp: TTimeStamp;
begin
  case DataType of
    ftUnknown: DatabaseErrorFmt(SUnknownFieldType, [Name], DataSet);
    ftString, ftFixedChar: Self.Value := StrPas(Buffer);
//    ftWord: AsWord := Word(Buffer^);
//    ftSmallint: AsSmallInt := Smallint(Buffer^);
    ftInteger, ftAutoInc: AsInteger := Integer(Buffer^);
    ftTime:
      begin
        TimeStamp.Time := LongInt(Buffer^);
        TimeStamp.Date := DateDelta;
//        AsTime := TimeStampToDateTime(TimeStamp);
      end;
    ftDate:
      begin
        TimeStamp.Time := 0;
        TimeStamp.Date := Integer(Buffer^);
//        AsDate := TimeStampToDateTime(TimeStamp);
      end;
    ftDateTime:
      begin
        TimeStamp.Time := 0;
        TimeStamp.Date := Integer(Buffer^);
//        AsDateTime := TimeStampToDateTime(MSecsToTimeStamp(Double(Buffer^)));
      end;
//    ftTimeStamp:;
//      AsSqlTimeStamp := TSqlTimeStamp(Buffer^);
    ftBCD:
      if BCDToCurr(TBcd(Buffer^), Value) then
        AsBCD := Value else
        AsBCD := 0;
//    ftFMTBcd:
//      AsFMTBcd := TBcd(Buffer^);
//    ftCurrency: AsCurrency := Double(Buffer^);
//    ftFloat: AsFloat := Double(Buffer^);
//    ftBoolean: AsBoolean := WordBool(Buffer^);
//    ftMemo: AsMemo := StrPas(Buffer);
    ftCursor: FData := 0;
    ftBlob, ftGraphic..ftTypedBinary,ftOraBlob,ftOraClob:
      SetBlobData(Buffer, SysUtils.StrLen(PChar(Buffer)));
  else
    DatabaseErrorFmt(SBadFieldType, [Name], DataSet);
  end;
end;

procedure TMvxParam.SetDataType(const Value: TFieldType);
const
  VarTypeMap: array[TFieldType] of Integer = (varError, varOleStr, varSmallint,
    varInteger, varSmallint, varBoolean, varDouble, varCurrency, varCurrency,
    varDate, varDate, varDate, varOleStr, varOleStr, varInteger, varOleStr,
    varOleStr, varOleStr, varOleStr, varOleStr, varOleStr, varOleStr, varError,
    varOleStr, varOleStr, varError, varError, varError, varError, varError,
    varOleStr, varOleStr, varVariant, varUnknown, varDispatch, varOleStr, varOleStr,varOleStr
    {$IFDEF DELPHI9}, varOleStr, varOleStr, varUnknown, varUnknown{$ENDIF});
var
  vType: Integer;
begin
  ParamRef.FDataType := Value;
  if Assigned(DataSet) and (csDesigning in DataSet.ComponentState) and
     (not ParamRef.IsNull) then
  begin
    vType := VarTypeMap[Value];
    if vType <> varError then
    try
      VarCast(ParamRef.FData, ParamRef.FData, vType);
    except
      ParamRef.Clear;
    end else
      ParamRef.Clear;
  end else
    ParamRef.Clear;
end;

procedure TMvxParam.SetIdxFrom(const Value: Integer);
begin
  if FIdxFrom <> Value then
    FIdxFrom := Value;
  FIdxTo := FIdxFrom + FSize - 1;
end;

procedure TMvxParam.SetParamType(Value: TMvxParamType);
begin
  ParamRef.FParamType := Value;
end;

procedure TMvxParam.SetSize(const Value: Integer);
begin
  if FSize <> Value then
    FSize := Value;
  FIdxTo := FIdxFrom + FSize - 1;
end;

{ TMvxParams }

procedure TMvxParams.AddParam(Value: TMvxParam);
begin
  Value.Collection := nil;
end;

procedure TMvxParams.AssignValues(Value: TMvxParams);
var
  I: Integer;
  P: TMvxParam;
begin
  for I := 0 to Value.Count - 1 do
  begin
    P := FindParam(Value[I].Name);
    if P <> nil then
      P.Assign(Value[I]);
  end;
end;

constructor TMvxParams.Create(Owner: TPersistent);
begin
  FOwner := Owner;
  inherited Create(TMvxParam);
end;

function TMvxParams.BindParams: string;
var
  ASize, i: integer;
  ABuff: PChar;
begin
  ASize := CalcSendSize;
  GetMem(ABuff, ASize + 1);
  try
    FillChar(ABuff^, ASize, #32);
    for i := 0 to Count-1 do
      StrCopyEx(ABuff, Items[i].AsString, Items[i].IdxFrom,  Items[i].Size);
    Result := StrPas(ABuff);
  finally
    FreeMem(ABuff);
  end;
end;

constructor TMvxParams.Create;
begin
  FOwner := nil;
  inherited Create(TMvxParam);
end;

function TMvxParams.FindParam(const Value: string): TMvxParam;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := TMvxParam(inherited Items[I]);
    if AnsiCompareText(Result.Name, Value) = 0 then Exit;
  end;
  Result := nil;
end;

function TMvxParams.GetDataSet: TDataSet;
begin
  if FOwner is TMvxTransact then
    Result := TMvxTransact(FOwner).Dataset else
    Result := nil;
end;

function TMvxParams.GetItem(Index: Integer): TMvxParam;
begin
  Result := TMvxParam(inherited Items[Index]);
  Result := Result.ParamRef;
end;

function TMvxParams.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TMvxParams.GetParamList(List: TList; const ParamNames: string);
var
  Pos: Integer;
begin
  Pos := 1;
  while Pos <= Length(ParamNames) do
    List.Add(ParamByName(ExtractFieldName(ParamNames, Pos)));
end;

function TMvxParams.GetParamValue(const ParamName: string): Variant;
var
  I: Integer;
  Params: TList;
begin
  if Pos(';', ParamName) <> 0 then
  begin
    Params := TList.Create;
    try
      GetParamList(Params, ParamName);
      Result := VarArrayCreate([0, Params.Count - 1], varVariant);
      for I := 0 to Params.Count - 1 do
        Result[I] := TParam(Params[I]).Value;
    finally
      Params.Free;
    end;
  end else
    Result := ParamByName(ParamName).Value
end;

function TMvxParams.IsEqual(Value: TMvxParams): Boolean;
var
  I: Integer;
begin
  Result := Count = Value.Count;
  if Result then
    for I := 0 to Count - 1 do
    begin
      Result := Items[I].IsEqual(Value.Items[I]);
      if not Result then Break;
    end
end;

function TMvxParams.ParamByName(const Value: string): TMvxParam;
begin
  Result := FindParam(Value);
  if Result = nil then
    DatabaseErrorFmt(SParameterNotFound, [Value], nil);
end;

procedure TMvxParams.ParseParams(const AStr: string);
var
  i: integer;
  SValue: string;
begin
  for i := 0 to Count-1 do
  begin
    SValue := Trim(Copy(AStr, Items[i].FIdxFrom, Items[i].Size));
    if Items[i].DataType <> ftString then
    begin
      if SValue = EmptyStr then
        Items[i].Value := null
      else
        Items[i].AsInteger := StrToInt(SValue)
    end else
      Items[i].AsString := SValue;
  end;
end;

procedure TMvxParams.SetItem(Index: Integer; const Value: TMvxParam);
begin
  inherited SetItem(Index, TCollectionItem(Value));
end;

procedure TMvxParams.SetParamValue(const ParamName: string;
  const Value: Variant);
var
  I: Integer;
  Params: TList;
begin
  if Pos(';', ParamName) <> 0 then
  begin
    Params := TList.Create;
    try
      GetParamList(Params, ParamName);
      for I := 0 to Params.Count - 1 do
        TParam(Params[I]).Value := Value[I];
    finally
      Params.Free;
    end;
  end else
    ParamByName(ParamName).Value := Value;
end;

procedure TMvxParams.Update(Item: TCollectionItem);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Items[i].FParamRef := nil;
  inherited Update(Item);
end;

procedure TMvxCustomConnection.Setup;
begin
  Check(APILibrary.MvxSockSetup(MvxHandle, PChar(Host), Port,
    PChar(ApplicationName), Integer(Secured), PChar(SecureKey)));
end;

function TMvxParams.CalcSendSize: integer;
var
  i : integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
    Result := Result + Items[i].Size;
  if Count > 0 then
    Result := Result + (Items[0].IdxFrom -1);
end;

procedure TMvxParams.ClearValues;
var
  i: integer;
begin
  if Count > 0 then
  begin
    BeginUpdate;
    try
      for i := 0 to Count-1 do
        Items[i].Clear;
    finally
      EndUpdate;
    end;
  end; 
end;

function TMvxParams.CalcRcvSize: integer;
var
  i : integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
    Result := Result + Items[i].Size;
end;

procedure TMvxParams.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Data', ReadBinaryData, nil, False);
end;

procedure TMvxParams.ReadBinaryData(Stream: TStream);
var
  I, Temp, NumItems: Integer;
  Buffer: array[0..2047] of Char;
  TempStr: string;
  Version: Word;
  Bool: Boolean;
begin
  Clear;
  with Stream do
  begin
    ReadBuffer(Version, SizeOf(Version));
    if Version > 2 then DatabaseError(SInvalidVersion);
    NumItems := 0;
    if Version = 2 then
      ReadBuffer(NumItems, SizeOf(NumItems)) else
      ReadBuffer(NumItems, 2);
    for I := 0 to NumItems - 1 do
      with TMvxParam(Add) do
      begin
        Temp := 0;
        if Version = 2 then
          ReadBuffer(Temp, SizeOf(Temp)) else
          ReadBuffer(Temp, 1);
        SetLength(TempStr, Temp);
        ReadBuffer(PChar(TempStr)^, Temp);
        Name := TempStr;
        ReadBuffer(FIdxFrom, SizeOf(FIdxFrom));
        ReadBuffer(FSize, SizeOf(FSize));
        ReadBuffer(FParamType, SizeOf(FParamType));
        ReadBuffer(FDataType, SizeOf(FDataType));
        if DataType <> ftUnknown then
        begin
          Temp := 0;
          if Version = 2 then
            ReadBuffer(Temp, SizeOf(Temp)) else
            ReadBuffer(Temp, 2);
          ReadBuffer(Buffer, Temp);
          if DataType in [ftBlob, ftGraphic..ftTypedBinary,ftOraBlob,ftOraClob] then
            SetBlobData(@Buffer, Temp) else
            SetData(@Buffer);
        end;
        ReadBuffer(Bool, SizeOf(Bool));
        if Bool then FData := NULL;
        ReadBuffer(FBound, SizeOf(FBound));
      end;
  end;
end;


procedure TMvxParams.AssignTo(Dest: TPersistent);
begin
  if Dest is TMvxParams then TMvxParams(Dest).Assign(Self)
  else inherited AssignTo(Dest);
end;

{TMvxMemField}

constructor TMvxMemField.Create(AOwner : TMvxMemFields);
begin
  inherited Create;
  FOwner := AOwner;
  FIndex := FOwner.FItems.Count;
end;

procedure TMvxMemField.CreateField(Field : TField);
var
  i : Integer;
  mField : TMvxMemField;
begin
  FField := Field;
  FDataType := Field.DataType;
  FDataSize := GetDataSize(Field);
  FIsRecId := UpperCase(Field.FieldName) = 'RECID';
  FIsNeedAutoInc := FIsRecId or (FDataType = ftAutoInc);
  if FIsNeedAutoInc then
    FOwner.FIsNeedAutoIncList.Add(self);
  if FIndex = 0 then
  begin
    FOffSet := 0;
    fOwner.FValuesSize := 0;
  end else begin
    mField := TMvxMemField(FOwner.FItems[FIndex - 1]);
    FOffSet := mField.FOffSet + mField.FDataSize + 1;
  end;
  FValueOffSet := FOffSet + 1;
  Inc(FOwner.FValuesSize, FDataSize + 1);
  FMaxIncValue := 0;
  for i := 0 to DataSet.RecordCount - 1 do
    AddValue(nil);
end;

function TMvxMemField.GetActiveBuffer(AActiveBuffer, ABuffer: TRecordBuffer): Boolean;
var
  AData: Pointer;
begin
  AData := GetDataFromBuffer(AActiveBuffer);
  Result := ReadByte(AData) <> 0;
  Shift(AData, SizeOf(Byte));
  if (ABuffer <> nil) and Result then
  begin
    if Field.DataType in ftStrings then
      CopyChars(AData, ABuffer, FDataSize, FDataType)
    else
     CopyData(AData, ABuffer, FDataSize);
  end;
end;

procedure TMvxMemField.SetActiveBuffer(AActiveBuffer, ABuffer: TRecordBuffer);

  function GetDataBuffer(ABuffer: Pointer): Pointer;
  begin
  {$IFNDEF DELPHI10}
    if Field.DataType = ftWideString then
      Result := PWideChar(PWideString(ABuffer)^)
    else
  {$ENDIF}
    Result := ABuffer;
  end;

var
  AData: Pointer;
begin
  AData := GetDataFromBuffer(AActiveBuffer);
  if ABuffer <> nil then
  begin
    WriteByte(AData, 1);
    Shift(AData, SizeOf(Byte));
    if FDataType in ftStrings then
      CopyChars(GetDataBuffer(ABuffer), AData, Field.Size, FDataType)
    else
      CopyData(ABuffer, AData, FDataSize);
  end
  else
    WriteByte(AData, 0);
end;

procedure TMvxMemField.SetAutoIncValue(const Buffer : TRecordBuffer; Value : TRecordBuffer);
var
  AMaxValue: Integer;
begin
  if (Buffer <> nil) then
    AMaxValue := ReadInteger(Buffer)
  else
    AMaxValue := -1;
  if (Buffer <> nil) and  (FMaxIncValue < AMaxValue) then
    FMaxIncValue := AMaxValue
  else
  begin
    if (not DataSet.IsLoading) or (Buffer = nil) then
    begin
      Inc(FMaxIncValue);
      WriteByte(Value, 1);
      WriteInteger(Value, FMaxIncValue, 1);
    end;
  end;
end;

procedure TMvxMemField.AddValue(const Buffer : TRecordBuffer);
begin
  if FIndex = 0 then
    InsertValue(FOwner.FValues.Count, Buffer)
  else
    InsertValue(FOwner.FValues.Count - 1, Buffer);
end;


procedure TMvxMemField.InsertValue(AIndex : Integer; const Buffer : TRecordBuffer);
var
  AData: Pointer;
begin
  if AIndex = FOwner.FValues.Count then
  begin
    AData := AllocMem(FOwner.FValuesSize);
    FOwner.Values.Insert(AIndex, AData);
  end
  else
    AData := GetDataFromBuffer(FOwner.Values.Last);
  if Buffer = nil then
    WriteByte(AData, 0)
  else
  begin
    WriteByte(AData, 1);
    CopyData(Buffer, AData, 0, SizeOf(Byte), FDataSize);
  end;
  if FIsNeedAutoInc then
    SetAutoIncValue(Buffer, AData);
end;

function TMvxMemField.GetDataFromBuffer(const ABuffer: TRecordBuffer): TRecordBuffer;
begin
  Result := TRecordBuffer(Integer(ABuffer) + FOffSet);
end;

function TMvxMemField.GetHasValueFromBuffer(const ABuffer: TRecordBuffer): Char;
begin
  Result := Char(ReadByte(ABuffer, FOffSet));
end;

function TMvxMemField.GetValueFromBuffer(const ABuffer: TRecordBuffer): TRecordBuffer;
begin
  Result := TRecordBuffer(Integer(ABuffer) + FValueOffSet);
end;

function TMvxMemField.DataPointer(AIndex, AOffset: Integer): TRecordBuffer;
begin
  Result := TRecordBuffer(Integer(Pointer(FOwner.FValues[AIndex])) + AOffset);
end;

function TMvxMemField.GetValues(Index : Integer) : TRecordBuffer;
begin
  if HasValues[Index] <> #0 then
    Result := DataPointer(Index, FValueOffSet)
  else
    Result := nil;
end;

function TMvxMemField.GetHasValues(Index : Integer) : Char;
begin
  Result := Char(ReadByte(DataPointer(Index, FOffSet)));
end;

procedure TMvxMemField.SetHasValues(Index : Integer; Value : Char);
begin
  WriteByte(DataPointer(Index, FOffSet), Byte(Value));
end;

function TMvxMemField.GetDataSet : TMvxCustomDataset;
begin
  Result := MemFields.DataSet;
end;

function TMvxMemField.GetMemFields : TMvxMemFields;
begin
  Result := FOwner;
end;

{TMvxMemFields}
constructor TMvxMemFields.Create(ADataSet : TMvxCustomDataset);
begin
  inherited Create;
  FDataSet := ADataSet;
  FItems := TList.Create;
  FCalcFields := TList.Create;
  FIsNeedAutoIncList := TList.Create;
end;

destructor TMvxMemFields.Destroy;
begin
  Clear;
  FItems.Free;
  FCalcFields.Free;
  FIsNeedAutoIncList.Free;

  inherited Destroy;
end;

procedure TMvxMemFields.Clear;
var
  i : Integer;
begin
  if FValues <> nil then
  begin
    for i := FValues.Count - 1 downto 0 do
      DeleteRecord(0);
    FreeAndNil(FValues);
  end;
  for i := 0 to FItems.Count - 1 do
    TMvxMemField(FItems[i]).Free;
  FItems.Clear;
  FCalcFields.Clear;
  FIsNeedAutoIncList.Clear;
end;

procedure TMvxMemFields.DeleteRecord(AIndex : Integer);
begin
  FreeMem(Pointer(FValues[AIndex]));
  FValues.Delete(AIndex);
end;

function TMvxMemFields.Add(AField : TField) : TMvxMemField;
begin
  Result := TMvxMemField.Create(self);
  FItems.Add(Result);
  TMvxMemField(Result).CreateField(AField);
end;

function TMvxMemFields.GetItem(Index : Integer)  : TMvxMemField;
begin
  Result := TMvxMemField(FItems[Index]);
end;

function TMvxMemFields.IndexOf(Field : TField) : TMvxMemField;
var
  i : Integer;
begin
  Result := Nil;
  for i := 0 to FItems.Count - 1 do
    if(TMvxMemField(FItems.List[i]).Field = Field) then
    begin
      Result := TMvxMemField(FItems.List[i]);
      break;
    end;
end;

function TMvxMemFields.GetValue(mField : TMvxMemField; Index : Integer) : TRecordBuffer;
begin
  Result := mField.Values[Index];
end;

function TMvxMemFields.GetHasValue(mField : TMvxMemField; Index : Integer) : char;
begin
  Result := mField.GetHasValues(Index);
end;

procedure TMvxMemFields.SetValue(mField : TMvxMemField; Index : Integer; Buffer : TRecordBuffer);
const
  HasValueArr : Array[False..True] of Char = (char(0), char(1));
begin
  SetHasValue(mField, Index, HasValueArr[Buffer <> nil]);
  if (Buffer = nil) then exit;
  CopyData(Buffer, mField.Values[Index], mField.FDataSize);
end;

procedure TMvxMemFields.SetHasValue(mField : TMvxMemField; Index : Integer; Value : char);
begin
  mField.SetHasValues(Index, Value);
end;

function TMvxMemFields.GetCount : Integer;
begin
  Result := FItems.Count;
end;

procedure TMvxMemFields.GetBuffer(Buffer : TRecordBuffer; AIndex : Integer);
begin
  CopyData(Pointer(FValues[AIndex]), Buffer, FValuesSize);
end;

procedure TMvxMemFields.SetBuffer(Buffer : TRecordBuffer; AIndex : Integer);
begin
  if AIndex = -1 then exit;
  CopyData(Buffer, Pointer(FValues[AIndex]), FValuesSize);
end;

function TMvxMemFields.GetActiveBuffer(ActiveBuffer, Buffer : TRecordBuffer; Field : TField) : Boolean;
var
  mField : TMvxMemField;
begin
  mField := IndexOf(Field);
  Result := (mField <> nil) and mField.GetActiveBuffer(ActiveBuffer, Buffer);
end;

procedure TMvxMemFields.SetActiveBuffer(ActiveBuffer, Buffer : TRecordBuffer; Field : TField);
var
  mField : TMvxMemField;
begin
  if Field.Calculated and (DataSet.State = dsCalcFields) then  exit;
  mField := IndexOf(Field);
  if mField <> nil then
    mField.SetActiveBuffer(ActiveBuffer, Buffer);
end;

function TMvxMemFields.GetRecordCount : Integer;
begin
  if(FValues = nil) then
    Result := 0
  else Result := FValues.Count;
end;

procedure TMvxMemFields.InsertRecord(const Buffer: TRecordBuffer; AIndex : Integer; Append: Boolean);
var
  I: Integer;
  AData: Pointer;
  mField : TMvxMemField;
begin
  if AIndex = -1 then
    AIndex := 0;
  AData := AllocMem(FValuesSize);
  CopyData(Buffer, AData, FValuesSize);
  if Append then
    FValues.Add(AData)
  else
    FValues.Insert(AIndex, AData);
  for I := 0 to FIsNeedAutoIncList.Count - 1 do
  begin
    mField := TMvxMemField(FIsNeedAutoIncList[I]);
    mField.SetAutoIncValue(mField.GetValueFromBuffer(Buffer), mField.GetDataFromBuffer(AData));
  end;
end;

procedure TMvxMemFields.AddField(Field : TField);
var
  mField : TMvxMemField;
begin
  mField := IndexOf(Field);
  if(mField = Nil) then
    Add(Field);
end;

procedure TMvxMemFields.RemoveField(Field : TField);
var
  mField : TMvxMemField;
begin
  mField := IndexOf(Field);
  if(mField <> Nil) then
    mField.Free;
end;

{TMvxMemIndex}
constructor TMvxMemIndex.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  fIsDirty := True;
  fList := TList.Create;
  fIndexList := TList.Create;
end;

destructor TMvxMemIndex.Destroy;
begin
  fList.Free;
  fIndexList.Free;

  inherited Destroy;
end;

procedure TMvxMemIndex.Assign(Source: TPersistent);
begin
  if Source is TMvxMemIndex then
  begin
    FieldName := TMvxMemIndex(Source).FieldName;
    SortOptions := TMvxMemIndex(Source).SortOptions;
  end
  else
    inherited Assign(Source);
end;

procedure TMvxMemIndex.Prepare;
var
  I: Integer;
  mField: TMvxMemField;
  tempList: TList;
begin
  if not IsDirty or (fField = nil) then exit;

  fIndexList.Clear;
  mField := GetMemData.fData.IndexOf(fField);
  if (mField <> nil) then
  begin
    GetMemData.FillValueList(FList);
    fIndexList.Capacity := FList.Capacity;
    for i := 0 to FList.Count - 1 do
      fIndexList.Add(TValueBuffer(i));
    tempList := TList.Create;
    tempList.Add(fIndexList);
    try
      GetMemData.DoSort(fList, mField, SortOptions, tempList);
    finally
      tempList.Free;
    end;
    IsDirty := False;
  end;
end;

function TMvxMemIndex.GotoNearest(const Buffer : TRecordBuffer; var Index : Integer) : Boolean;
begin
  Result := False;
  Prepare;
  if IsDirty then exit;
  Result := GetMemData.InternalGotoNearest(fList, fField, Buffer, SortOptions, Index);
  if Result then
    Index := Integer(TValueBuffer(fIndexList.List[Index]));
end;

procedure TMvxMemIndex.SetIsDirty(Value: Boolean);
begin
  if not Value and (fField = nil) then
    Value := True;
  if (fIsDirty <> Value) then
  begin
    fIsDirty := Value;
    if (Value) then
      fList.Clear;
  end;
end;

procedure TMvxMemIndex.DeleteRecord(pRecord: TRecordBuffer);
begin
  if not fIsDirty then
    fList.Remove(pRecord);
end;

procedure TMvxMemIndex.UpdateRecord(pRecord: TRecordBuffer);
var
  i, Index: Integer;
  mField: TMvxMemField;
begin
  if fIsDirty then
    exit;
  i := fList.IndexOf(pRecord);
  if i > -1 then
  begin
    Index := GetMemData.Data.FValues.IndexOf(fList.List[i]);
    if Index > - 1 then
    begin
      mField := GetMemData.Data.IndexOf(fField);
      if ((Index = 0)
        or (GetMemData.InternalCompareValues(mField.Values[Index - 1],
          mField.Values[Index], mField, soCaseinsensitive in SortOptions) <= 0))
      and ((Index = GetMemData.RecordCount - 1)
         or (GetMemData.InternalCompareValues(mField.Values[Index],
            mField.Values[Index + 1], mField, soCaseinsensitive in SortOptions) <= 0)) then
        exit;
    end;
  end;
  fIsDirty := True;
end;

procedure TMvxMemIndex.SetFieldName(Value: String);
var
  AField : TField;
begin
  if (GetMemdata <> nil) and (csLoading in GetMemdata.ComponentState) then
  begin
    fLoadedFieldName := Value;
    exit;
  end;
  if (CompareText(fFieldName, Value) <> 0) then
  begin
    AField := GetMemData.FieldByName(Value);
    if AField <> nil then
    begin
      fFieldName := AField.FieldName;
      fField := AField;
      IsDirty := True;
    end;
  end;
end;

procedure TMvxMemIndex.SetSortOptions(Value: TMvxSortOptions);
begin
  if (SortOptions <>  Value) then
  begin
    FSortOptions :=  Value;
    IsDirty := True;
  end;
end;

procedure TMvxMemIndex.SetFieldNameAfterMemdataLoaded;
begin
  if (fLoadedFieldName <> '') then
    FieldName := fLoadedFieldName;
end;

function TMvxMemIndex.GetMemData: TMvxCustomDataset;
begin
  Result := TMvxMemIndexes(Collection).fMemData;
end;

{TMvxMemIndexes}
function TMvxMemIndexes.GetOwner: TPersistent;
begin
  Result := fMemData;
end;

procedure TMvxMemIndexes.SetIsDirty;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TMvxMemIndex(Items[i]).IsDirty := True;
end;

procedure TMvxMemIndexes.DeleteRecord(pRecord: TRecordBuffer);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TMvxMemIndex(Items[i]).DeleteRecord(pRecord);
end;

procedure TMvxMemIndexes.UpdateRecord(pRecord: TRecordBuffer);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TMvxMemIndex(Items[i]).UpdateRecord(pRecord);
end;

procedure TMvxMemIndexes.RemoveField(AField: TField);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if(TMvxMemIndex(Items[i]).fField = AField) then
    begin
      TMvxMemIndex(Items[i]).fField := nil;
      TMvxMemIndex(Items[i]).IsDirty := True;
    end;
end;

procedure TMvxMemIndexes.CheckFields;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    TMvxMemIndex(Items[i]).fField := fMemData.FindField(TMvxMemIndex(Items[i]).FieldName);
    TMvxMemIndex(Items[i]).IsDirty := True;
  end;
end;

procedure TMvxMemIndexes.AfterMemdataLoaded;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TMvxMemIndex(Items[i]).SetFieldNameAfterMemdataLoaded;
end;

function TMvxMemIndexes.Add: TMvxMemIndex;
begin
  Result := TMvxMemIndex(inherited Add);
end;

function TMvxMemIndexes.GetIndexByField(AField: TField): TMvxMemIndex;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if(TMvxMemIndex(Items[i]).fField = AField) then
    begin
      Result := TMvxMemIndex(Items[i]);
      break;
    end;
end;

{ TMvxCustomDataset }
constructor TMvxCustomDataset.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FData := TMvxMemFields.Create(self);
  FData.FDataSet := self;
  FBookMarks := TList.Create;
  FBlobList := TList.Create;
  FFilterList := TList.Create;
  FDelimiterChar := Char(VK_TAB);

  FGotoNearestMin := -1;
  FGotoNearestMax := -1;
  
  fIndexes := TMvxMemIndexes.Create(TMvxMemIndex);
  fIndexes.fMemData := self;
  fPersistent := TMvxMemPersistent.Create(self);

  CreateRecIDField;  
  FTransactionList := TStringList.Create;
  FMvxCmd := TMvxTransact.Create(Self);
  FMvxCmd.Connection := nil;
  FMvxCmd.OnPrepare := InternalPrepare;
end;

destructor TMvxCustomDataset.Destroy;
begin
  fIndexes.Free;
  BlobClear;
  FBlobList.Free;
  FBlobList := nil;
  FBookMarks.Free;
  FFilterList.Free;
  FData.Free;
  FData := nil;
  FActive := False;
  fPersistent.Free;
  
  FTransactionList.Free;
  Connection := nil;
  FMvxCmd.Free;
  
  inherited Destroy;
end;

procedure TMvxCustomDataset.CreateRecIDField;
begin
  if (FRecIdField <> nil) then exit;
  FRecIdField := TIntegerField.Create(self);
  with FRecIdField do
  begin
    FieldName := 'RecId';
    DataSet := self;
    Name := self.Name + FieldName;
    Calculated := True;
    Visible := False;
  end;
end;

procedure TMvxCustomDataset.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if Active and not (csLoading in ComponentState) and not (csDestroying in ComponentState) then
  begin
    if (AComponent is TField) and (TField(AComponent).DataSet = self) then
    begin
      if(Operation = opInsert) then
        FData.AddField(AComponent as TField)
      else
      begin
        if (FRecIdField = AComponent) then
          FRecIdField := nil;
        FData.RemoveField(AComponent as TField);
        Indexes.RemoveField(AComponent as TField);
      end;
    end;
  end;
  inherited Notification(AComponent, Operation);
end;

function TMvxCustomDataset.BookmarkValid(Bookmark: TBookmark): Boolean;
var
  Index : Integer;
begin
  Result := (Bookmark <> nil);
  if(Result) then
  begin
    Index := FBookMarks.IndexOf(TObject(PInteger(Bookmark)^));
    Result := (Index > -1) and (Index < Data.RecordCount);
    if  FIsFiltered then
      Result := FFilterList.IndexOf(TValueBuffer(Index + 1)) > -1;
  end;
end;

function TMvxCustomDataset.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer;
const
  RetCodes: array[Boolean, Boolean] of ShortInt = ((2, -1), (1, 0));
var
  r1, r2 : Integer;
begin
  Result := RetCodes[Bookmark1 = nil, Bookmark2 = nil];
  if(Result = 2) then
  begin
    r1 := ReadInteger(Bookmark1);
    r2 := ReadInteger(Bookmark2);
    if(r1 = r2) then
       Result := 0
    else begin
      if FSortedField <> nil then
      begin
        r1 := FBookMarks.IndexOf(TObject(r1));
        r2 := FBookMarks.IndexOf(TObject(r2));
      end;
      if(r1 > r2) then
        Result := 1
      else Result := -1;
    end;
  end;
end;

function TMvxCustomDataset.CheckFields(FieldsName: string): Boolean;
var
  FieldList: TList;
  i: Integer;
begin
  FieldList := TList.Create;
  GetFieldList(FieldList, FieldsName);
  Result := FieldList.Count > 0;
  if Result then
  begin
    for i := 0 to FieldList.Count - 1 do
      if(FieldList[i] = nil) then
      begin
        Result := False;
        break;
      end;
  end;
  FieldList.Free;
end;

function TMvxCustomDataset.GetStringLength(AFieldType: TFieldType; const ABuffer: Pointer): Integer;
begin
  Result := 0;
  if ABuffer <> nil then
    case AFieldType of
      ftString, ftWideString:
        Result := StrLen(ABuffer, AFieldType);
    end;
end;


function TMvxCustomDataset.InternalLocate(const KeyFields: string; const KeyValues: Variant;
           Options: TLocateOptions): Integer;
var
  AKeyValues: Variant;

  function CompareLocate_SortCaseSensitive: Boolean;
  begin
    Result := ((loCaseInsensitive in Options) and (soCaseInsensitive in SortOptions))
     or ( not (loCaseInsensitive in Options) and not (soCaseInsensitive in SortOptions))
  end;

  function AllocBufferByVariant(AValue: Variant; AField: TField): Pointer;
  begin
    if VarIsNull(AValue) then
      Result := nil
    else
    begin
      Result := AllocBuferForField(AField);
      VariantToMemDataValue(AValue, Result, AField);
    end;
  end;

  function CompareLocStr(AmField: TMvxMemField; buf1, buf2 : TRecordBuffer; AStSize: Integer) : Integer;
  var
    ATempBuffer: Pointer;
    fStr2Len : Integer;
  begin
    Result := -1;
    fStr2Len := GetStringLength(AmField.FDataType, buf2);
    if fStr2Len = AStSize then
      Result := InternalCompareValues(buf1, buf2, AmField, loCaseInsensitive in Options)
    else
      if (loPartialKey in Options) and (fStr2Len > AStSize) and (AStSize > 0) then
      begin
        ATempBuffer := AllocBuferForString(AStSize, AmField.FDataType);
        CopyChars(buf2, ATempBuffer, AStSize, AmField.FDataType);
        Result := InternalCompareValues(buf1, ATempBuffer, AmField, loCaseInsensitive in Options);
        FreeMem(ATempBuffer);
      end;
  end;

  function LocateByIndexField(AIndex: TMvxMemIndex; AField: TField; AValue: Variant) : Integer;
  var
    FStSize : Integer;
    mField: TMvxMemField;
    fBuf: TRecordBuffer;
  begin
    fBuf := AllocBufferByVariant(AValue, AField);

    if AIndex = nil then
    begin
      if not GotoNearest(fBuf, SortOptions, Result) and
      not (loPartialKey in Options) then
        Result := -1;
    end else
    begin
      if not AIndex.GotoNearest(fBuf, Result) then
         Result := -1;
    end;
    
    if (Result > -1) then
    begin
      mField := FData.IndexOf(AField);
      if AField.DataType in ftStrings then
      begin
        FStSize := GetStringLength(AField.DataType, fBuf);
        if CompareLocStr(mField, fBuf, mField.Values[Result], FStSize) <> 0 then
          Result := -1;
      end
      else
      begin
        if (InternalCompareValues(fBuf, mField.Values[Result], mField, False) <> 0) then
          Result := -1;
      end;
    end;
    FreeMem(fBuf);
 end;

 procedure PrepareLocate;
 begin
   CheckBrowseMode;
   CursorPosChanged;
   UpdateCursorPos;
 end;

 function GetLocateValue(Index: Integer): Variant;
 begin
   if VarIsArray(AKeyValues) then
     Result := AKeyValues[Index]
   else Result := AKeyValues;
 end;

var
  buf : TRecordBuffer;
  AValueList, AmFieldList : TList;
  AFieldList: TList;
  StartId : Integer;
  Field : TField;
  i, j, k, RealRec, RealRecordCount : Integer;
  StSize : Integer;
  IsIndexed  : Boolean;
begin
  Result := -1;
  if not CheckFields(KeyFields) then
    raise Exception.CreateFmt(SFieldNotFound, [KeyFields]);
  if (RecordCount = 0) then exit;

  Field := FindField(KeyFields);

  if (Field = nil) and not VarIsArray(KeyValues)  then
    exit;

  if (Field <> nil) and VarIsArray(KeyValues) then
    AKeyValues := KeyValues[0]
  else AKeyValues := KeyValues;

  PrepareLocate;

  if (Field <> nil) and not FIsFiltered
  and ((Field = FSortedField) or (Indexes.GetIndexByField(Field) <> nil))
  and CompareLocate_SortCaseSensitive then
  begin
    if (Field = FSortedField) then
      Result := LocateByIndexField(nil, Field, AKeyValues)
    else Result := LocateByIndexField(Indexes.GetIndexByField(Field), Field, AKeyValues);
    exit;
  end;

  AFieldList := TList.Create;
  AValueList := TList.Create;
  AmFieldList := TList.Create;
  GetFieldList(AFieldList, KeyFields);
  for i := 0 to AFieldList.Count - 1 do
  begin
    Buf := AllocBufferByVariant(GetLocateValue(i), TField(AFieldList[i]));
    AValueList.Add(buf);
    AmFieldList.Add(FData.IndexOf(TField(AFieldList[i])));
  end;

  StartId := 0;
  IsIndexed := False;
  if not FIsFiltered then
  begin
    RealRecordCount := FData.RecordCount - 1;
    if CompareLocate_SortCaseSensitive and not VarIsArray(KeyValues)
    and ((TField(AFieldList[0]) = FSortedField)
    or (Indexes.GetIndexByField(TField(AFieldList[0])) <> nil)) then
    begin
      Field := TField(AFieldList[0]);
      if (Field = FSortedField) then
        StartId := LocateByIndexField(nil, Field, GetLocateValue(0))
      else StartId := LocateByIndexField(Indexes.GetIndexByField(Field), Field, AKeyValues);
      IsIndexed := True;
    end;
  end else RealRecordCount := FFilterList.Count - 1;

  if StartId > -1 then
  begin
    for i := StartId to RealRecordCount do
    begin
      if not FIsFiltered then
        RealRec := i
      else RealRec := Integer(TValueBuffer(FFilterList[i])) - 1;
      j := 0;
      for k := 0 to AFieldList.Count - 1 do
      if (TField(AFieldList[k]) <> nil) then begin
        if (AValueList[k] = nil) then
        begin
          if (TMvxMemField(AmFieldList[k]).HasValues[RealRec] <> #0) then
            j := -1;
        end
        else
        begin
          if (TField(AFieldList[k]).DataType in ftStrings) and (Options <> []) then
          begin
            StSize := GetStringLength(TField(AFieldList[k]).DataType, TRecordBuffer(AValueList[k]));
            j := CompareLocStr(TMvxMemField(AmFieldList[k]),
                TRecordBuffer(AValueList[k]), TMvxMemField(AmFieldList[k]).Values[RealRec], StSize)
          end else j := InternalCompareValues(TRecordBuffer(AValueList[k]), TMvxMemField(AmFieldList[k]).Values[RealRec], TMvxMemField(AmFieldList[k]), loCaseInsensitive in Options);
        end;
        if IsIndexed and (k = 0) and (j <> 0) then
        begin
         RealRec := -1;
         break;
        end;
        if j <> 0 then break;
      end;
      if RealRec = -1 then
        break;
      if j = 0 then
      begin
        Result := i;
        break;
      end;
    end;
  end;

  for i := 0 to AValueList.Count - 1 do
    FreeMem(Pointer(AValueList[i]));

  AFieldList.Free;
  AValueList.Free;
  AmFieldList.Free;
end;

function TMvxCustomDataset.Locate(const KeyFields: string; const KeyValues: Variant;
           Options: TLocateOptions): Boolean;
var
  AIndex: Integer;
begin
  AIndex := InternalLocate(KeyFields, KeyValues, Options);
  Result := AIndex > -1;
  if Result then
  begin
    Inc(AIndex);
    if(RecNo <> AIndex) then
     RecNo := AIndex
    else Resync([]);
  end;
end;

procedure AddStrings(AStrings: TStrings; S: string);
var
  P: Integer;
begin
  repeat
    P := Pos(';', S);
    if P = 0 then
    begin
      AStrings.Add(S);
      Break;
    end
    else
    begin
      AStrings.Add(Copy(S, 1, P - 1));
      Delete(S, 1, P);
    end;
  until False;
end;

function TMvxCustomDataset.Lookup(const KeyFields: string; const KeyValues: Variant;
    const ResultFields: string): Variant;

   function GetLookupValue(AField: TField; ALookupIndex: Integer): Variant;
   var
     mField : TMvxMemField;
   begin
     if(AField = nil) then
       Result := Null
     else
     begin
      if not (AField is TBlobField) then
      begin
        mField := FData.IndexOf(AField);
        if (mField <> nil) then
        begin
          if (mField.HasValues[ALookupIndex] <> #0) then
            Result := GetVariantValue(mField.Values[ALookupIndex], AField)
          else Result := Null;
        end else Result := Null;
      end else  Result := GetBlobData(TValueBuffer(FBlobList[ALookupIndex]), AField.Offset);
     end;
   end;

var
  FLookupIndex: Integer;
  I: Integer;
  AStrings: TStrings;
begin
  FLookupIndex := InternalLocate(KeyFields, KeyValues, []);
  if (FLookupIndex > -1) then
  begin
    if FIsFiltered then
      FLookupIndex := Integer(TValueBuffer(FFilterList[FLookupIndex])) - 1;
    I := Pos(';', ResultFields);
    if(I < 1) then
      Result := GetLookupValue(FindField(ResultFields), FLookupIndex)
    else
    begin
      AStrings := TStringList.Create;
      AddStrings(AStrings, ResultFields);
      Result := VarArrayCreate([0, AStrings.Count - 1],
        varVariant);
      for I := 0 to AStrings.Count - 1 do
         Result[I] := GetLookupValue(FindField(AStrings[I]), FLookupIndex);
      AStrings.Free;
    end;
  end else Result := Null;
end;

function TMvxCustomDataset.GetRecNoByFieldValue(Value : Variant; FieldName : String) : Integer;
begin
  Result := InternalLocate(FieldName, Value, []);
  if Result > -1 then
    Inc(Result);
end;

function TMvxCustomDataset.SupportedFieldType(AType: TFieldType): Boolean;
begin
  Result := GetNoByFieldType(AType) <> -1;
end;

function TMvxCustomDataset.GetFieldClass(FieldType: TFieldType): TFieldClass;
begin
  Result := inherited GetFieldClass(FieldType);
end;

procedure TMvxCustomDataset.InternalOpen;
var
  i : Integer;
  AStat: TMvxTransactionStatus;

  procedure InternalInsertRecord(AParams: TMvxParams);
  var
    PBuffer: Pointer;
    i, AOffs: Integer;
  begin
    PBuffer := AllocMem(FData.FValuesSize);
    try
      for i := 0 to AParams.Count-1 do
      begin
        if (AParams.Items[i].Value <> null) then
        begin
          WriteByte(PBuffer, 1, FData.Items[i+1].FOffSet);
          AParams.Items[i].GetData(
            PChar(Integer(PBuffer)+FData.Items[i+1].FValueOffSet)
          );
        end;
      end;
      FData.InsertRecord(PBuffer, FCurRec, True);
    finally
      FreeMem(PBuffer);
    end;
  end;

begin
  if Active then
    exit;
  if not Prepared then
    Prepare;
  if Connection = nil then
    raise EMvxAPIError.Create(SNoConnection);
  if not Connection.Connected then
    Connection.Open;
    
  for i := 0 to FieldCount - 1 do
    if not SupportedFieldType(Fields[i].DataType) then
    begin
      DatabaseErrorFmt('Unsupported field type: %s', [Fields[i].FieldName]);
      exit;
    end;

  FillBookMarks;

  FCurRec := -1;
  FFilterCurRec := -1;

  FRecInfoOfs := 0;
  for i := 0 to FieldCount - 1 do
    if not Fields[i].IsBlob then
      Inc(FRecInfoOfs, GetDataSize(Fields[i]) + 1);

  FRecBufSize := FRecInfoOfs + SizeOf(TMvxRecInfo);
  BookmarkSize := SizeOf(Integer);

  InternalInitFieldDefs;

  if DefaultFields then CreateFields;

  for i := 0 to FieldCount - 1 do
   if not Fields[i].IsBlob then
     FData.Add(Fields[i]);

  FData.FValues := TList.Create;
  BindFields(True);
  FActive := True;
  MakeSort;
  Indexes.CheckFields;
  FMvxCmd.Open;
  FLoadFlag := true;
  try
    AStat := FMvxCmd.Transact;
    if AStat = stREP then
    begin
      while AStat = stREP do
      begin
        InternalInsertRecord(FMvxCmd.OutputParams);
        AStat := FMvxCmd.Receive;
      end;
    end else
    if AStat = stOK then
      InternalInsertRecord(FMvxCmd.OutputParams);      
  finally
    FLoadFlag := False;
    FMvxCmd.Close;
    FillBookMarks;    
  end;  
end;

procedure TMvxCustomDataset.InternalClose;
begin
  if (csDestroying in ComponentState) then exit;

  FData.Clear;
  FBookMarks.Clear;
  FFilterList.Clear;
  BlobClear;
  FSortedField := nil;

  if DefaultFields then DestroyFields;

  FLastBookmark := 0;
  FCurRec := -1;
  FFilterCurRec := -1;
  FActive := False;
end;

function TMvxCustomDataset.IsCursorOpen: Boolean;
begin
  Result := FActive;
end;

procedure TMvxCustomDataset.InternalInitFieldDefs;
var
  i : Integer;
begin
  FieldDefs.Clear;
  for i := 0 to  FieldCount - 1 do
    with Fields[i] do
      if not (Calculated  or Lookup) then
        FieldDefs.Add(FieldName, DataType, Size, Required)
      else
        if Calculated then
          FData.FCalcFields.Add(Fields[i]); 
end;

procedure TMvxCustomDataset.InternalHandleException;
begin
  Application.HandleException(Self);
end;

procedure TMvxCustomDataset.InternalGotoBookmark(Bookmark: TBookmark);
var
  Index, IndexF: Integer;
begin
  Index := FBookMarks.IndexOf(TObject(PInteger(Bookmark)^));
  if Index > -1 then
  begin
    if FIsFiltered then
    begin
      IndexF := FFilterList.IndexOf(TValueBuffer(Index + 1));
      if(IndexF > -1) then
      begin
        FFilterCurRec := IndexF;
        FCurRec := Index;
      end;
    end else FCurRec := Index
  end else
    DatabaseError('Bookmark not found');
end;

procedure TMvxCustomDataset.InternalSetToRecord(Buffer: TRecordBuffer);
begin
  InternalGotoBookmark(@PdxRecInfo(Buffer + FRecInfoOfs).Bookmark);
end;

function TMvxCustomDataset.GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag;
begin
  Result := PdxRecInfo(Buffer + FRecInfoOfs).BookmarkFlag;
end;

procedure TMvxCustomDataset.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
begin
  PdxRecInfo(Buffer + FRecInfoOfs).BookmarkFlag := Value;
end;

procedure TMvxCustomDataset.GetBookmarkData(Buffer: TRecordBuffer; Data: TBookMark);
begin
  PInteger(Data)^ := PdxRecInfo(Buffer + FRecInfoOfs).Bookmark;
end;

procedure TMvxCustomDataset.SetBookmarkData(Buffer: TRecordBuffer; Data: TBookmark);
begin
  PdxRecInfo(Buffer + FRecInfoOfs).Bookmark := PInteger(Data)^;
end;

function TMvxCustomDataset.GetCurrentRecord(Buffer: TRecordBuffer): Boolean;
begin
  if ActiveBuffer <> nil then
  begin
    CopyData(ActiveBuffer, Buffer, RecordSize);
    Result := True;
  end else Result := False;
end;

function TMvxCustomDataset.GetRecordSize: Word;
begin
  Result := FRecInfoOfs;
end;

procedure TMvxCustomDataset.Loaded;
begin
  inherited Loaded;
  Indexes.AfterMemdataLoaded;
  if Active and (Persistent.Option = poLoad) then
    Persistent.LoadData;
end;

function TMvxCustomDataset.AllocRecordBuffer: TRecordBuffer;
begin
  Result := AllocMem(FRecBufSize + BlobFieldCount * SizeOf(Pointer));
  InitializeBlobData(TRecordBuffer(Integer(Result) + FRecBufSize));
end;

procedure TMvxCustomDataset.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  FinalizeBlobData(TValueBuffer(Integer(Buffer) + FRecBufSize));
  FreeMem(Buffer);
  Buffer := nil;
end;

function TMvxCustomDataset.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;
begin
  if (FData = nil) then
  begin
    Result := grError;
    exit;
  end;
  if FData.RecordCount < 1 then
    Result := grEOF else
  begin
    Result := grOK;
    if Not FIsFiltered then
      case GetMode of
        gmNext:
          if FCurRec >= RecordCount - 1  then
            Result := grEOF else
            Inc(FCurRec);
        gmPrior:
          if FCurRec <= 0 then
            Result := grBOF else
            Dec(FCurRec);
        gmCurrent:
          if (FCurRec < 0) or (FCurRec >= RecordCount) then
            Result := grError;
        else GetCalcFields(Buffer);
      end
    else
    begin
      case GetMode of
        gmNext:
          if FFilterCurRec >= RecordCount - 1 then
            Result := grEOF else
            Inc(FFilterCurRec);
        gmPrior:
          if FFilterCurRec <= 0 then
            Result := grBOF else
            Dec(FFilterCurRec);
        gmCurrent:
          if (FFilterCurRec < 0) or (FFilterCurRec >= RecordCount) then
            Result := grError;
        else GetCalcFields(Buffer);
      end;
      if (Result = grOK) then
        FCurRec := Integer(TValueBuffer(FFilterList[FFilterCurRec])) - 1
      else FCurRec := -1;
    end;

    if Result = grOK then
    begin
      FData.GetBuffer(Buffer, FCurRec);
      with PdxRecInfo(Buffer + FRecInfoOfs)^ do
      begin
        BookmarkFlag := bfCurrent;
        Bookmark := Integer(FBookMarks[FCurRec])
      end;
      GetMemBlobData(Buffer);
    end else
      if (Result = grError) and DoCheck then DatabaseError('No Records');
  end;
end;

procedure TMvxCustomDataset.InternalInitRecord(Buffer: TRecordBuffer);
begin
  FillZeroData(Buffer, FRecInfoOfs);
  FinalizeBlobData(TRecordBuffer(Integer(Buffer) + FRecBufSize));
  InitializeBlobData(TRecordBuffer(Integer(Buffer) + FRecBufSize));
end;

function TMvxCustomDataset.GetActiveRecBuf(var RecBuf: TRecordBuffer): Boolean;
begin
  case State of
    dsBrowse: if IsEmpty then RecBuf := nil else RecBuf := ActiveBuffer;
    dsEdit, dsInsert: RecBuf := ActiveBuffer;
    dsCalcFields: RecBuf := CalcBuffer;
  else
    RecBuf := nil;
  end;
  Result := RecBuf <> nil;
end;

function TMvxCustomDataset.GetFieldData(Field: TField; Buffer: TValueBuffer): Boolean;
var
  RecBuf: TRecordBuffer;
{$IFNDEF DELPHI10}
  AData: Pointer;
{$ENDIF}
begin
  Result := False;
  if not GetActiveRecBuf(RecBuf) then Exit;

  if Field.IsBlob then
    Result := Length(GetBlobData(RecBuf, Field)) > 0
  else
  {$IFNDEF DELPHI10}
    if Field.DataType = ftWideString then
    begin
      AData := AllocMem(GetDataSize(Field));
      try
        Result := FData.GetActiveBuffer(RecBuf, AData, Field);
        if (Buffer <> nil) and Result then
          PWideString(Buffer)^ := WideString(PWideChar(AData));
      finally
        FreeMem(AData);
      end;
    end
    else
  {$ENDIF}
      Result := FData.GetActiveBuffer(RecBuf, Buffer, Field);
end;

function TMvxCustomDataset.GetFieldData(Field: TField; Buffer: TValueBuffer; NativeFormat: Boolean): Boolean;
begin
  if (Field.DataType = ftWideString) then
    Result := GetFieldData(Field, Buffer)
  else Result :=  inherited GetFieldData(Field, Buffer, NativeFormat)
end;

procedure TMvxCustomDataset.SetFieldData(Field: TField; Buffer: TValueBuffer);
var
  RecBuf : TRecordBuffer;
begin
  if not (State in dsWriteModes) then
    DatabaseError(SNotEditing, Self);
  if not GetActiveRecBuf(RecBuf) then Exit;

  Field.Validate(Buffer);

  FData.SetActiveBuffer(RecBuf, Buffer, Field);

  if not (State in [dsCalcFields, dsFilter, dsNewValue]) then
    DataEvent(deFieldChange, Longint(Field));
end;

procedure TMvxCustomDataset.SetFieldData(Field: TField; Buffer: Pointer; NativeFormat: Boolean);
begin
  if (Field.DataType = ftWideString) then
    SetFieldData(Field, Buffer)
  else
    inherited SetFieldData(Field, Buffer, NativeFormat)
end;

function TMvxCustomDataset.GetStateFieldValue(State: TDataSetState; Field: TField): Variant;
var
  mField: TMvxMemField;
begin
  if (State = dsOldValue) and Modified and (self.State = dsEdit) then
  begin
    mField := FData.IndexOf(Field);
    if mField.HasValues[self.CurRec] <> #0 then
      Result := GetVariantValue(mField.Values[self.CurRec], Field)
    else Result := Null;
  end else Result := inherited GetStateFieldValue(State, Field);
end;

procedure TMvxCustomDataset.InternalFirst;
begin
  FCurRec := -1;
  FFilterCurRec := -1;
end;

procedure TMvxCustomDataset.InternalLast;
begin
  if not FIsFiltered then
    FCurRec := FData.RecordCount
  else begin
    FFilterCurRec := RecordCount;
    FCurRec := FData.RecordCount;
  end;
end;

procedure TMvxCustomDataset.DoAfterCancel;
begin
  if not IsLoading then
    inherited DoAfterCancel;
end;

procedure TMvxCustomDataset.DoAfterClose;
begin
  if not IsLoading then
    inherited DoAfterClose;
end;

procedure TMvxCustomDataset.DoAfterInsert;
begin
  if not IsLoading then
    inherited DoAfterInsert;
end;

procedure TMvxCustomDataset.DoAfterOpen;
begin
  if (Persistent.Option = poActive) then
    Persistent.LoadData;
  if not IsLoading then
    inherited DoAfterOpen;
end;

procedure TMvxCustomDataset.DoAfterPost;
begin
  if not IsLoading then
    inherited DoAfterPost;
end;

procedure TMvxCustomDataset.DoBeforeClose;
begin
  if not IsLoading then
    inherited DoBeforeClose;
end;

procedure TMvxCustomDataset.DoBeforeInsert;
begin
  if not IsLoading then
    inherited ;
end;

procedure TMvxCustomDataset.DoBeforeOpen;
begin
  if not IsLoading then
    inherited ;
end;

procedure TMvxCustomDataset.DoBeforePost;
begin
  if not IsLoading then
    inherited DoBeforePost;
end;

procedure TMvxCustomDataset.DoOnNewRecord;
begin
  if not IsLoading then
    inherited DoOnNewRecord;
end;

procedure TMvxCustomDataset.InternalAddFilterRecord;
var
  i : Integer;
begin
  if InternalIsFiltering then
  begin
    i := FFilterCurRec; 
    if i < 0 then
     i := 0;
    if(i >= FFilterList.Count) then
    begin
      if (FCurRec = -1) then
        FCurRec := 0;
      FFilterList.Add(TValueBuffer(FCurRec + 1));
      FFilterCurRec := FFilterList.Count - 1;
    end else
    begin
      FFilterList.Insert(i, TValueBuffer(FCurRec + 1));
      FFilterCurRec := i;
      Inc(i);
      while i < FFilterList.Count  do
      begin
        FFilterList[i] := TValueBuffer(Integer(TValueBuffer(FFilterList[i])) + 1);
        Inc(i);
      end;
    end;
  end;
end;

procedure TMvxCustomDataset.MakeRecordSort;
var
  mField : TMvxMemField;
  NewCurRec, ATestIndex : Integer;
  Descdx: Integer;

  function GetValue(Index : Integer) : TRecordBuffer;
  begin
    Result := mField.Values[Index];
  end;

  function GetFilterValue(Index: Integer): TRecordBuffer;
  begin
    Result := GetValue(Integer(TValueBuffer(FFilterList[Index])) - 1);
  end;

  procedure ExchangeLists;
  var
    I, Index, AMovedCount: Integer;
  begin
    if FIsFiltered then
    begin
      AMovedCount := 0;
      if FCurRec < NewCurRec then
      begin
        for I := FCurRec + 1 to NewCurRec do
        begin
          Index := FFilterList.IndexOf(TValueBuffer(i + 1));
           if Index > -1 then
           begin
             FFilterList[Index] := TValueBuffer(Integer(TValueBuffer(FFilterList[Index])) - 1);
             Inc(AMovedCount);
           end;
        end;
      end
      else
      begin
        for i := FCurRec - 1 downto NewCurRec  do
        begin
          Index := FFilterList.IndexOf(TValueBuffer(I + 1));
           if Index > -1 then
           begin
             FFilterList[Index] := TValueBuffer(Integer(TValueBuffer(FFilterList[Index])) + 1);
             Dec(AMovedCount);
           end;
        end;
      end;
      FFilterList[FFilterCurRec] := TValueBuffer(NewCurRec + 1);
      if AMovedCount <> 0 then
      begin
        FFilterList.Move(FFilterCurRec, FFilterCurRec + AMovedCount);
        FFilterCurRec := FFilterCurRec + AMovedCount;
      end;
    end;
    FData.FValues.Move(FCurRec, NewCurRec);
    FBookMarks.Move(FCurRec, NewCurRec);
    if FBlobList.Count > 0 then
      FBlobList.Move(FCurRec, NewCurRec);
    FCurRec := NewCurRec;
  end;

begin
  if FLoadFlag or not FActive or (FData.RecordCount < 2) then exit;
  if(FSortedField <> nil) then
  begin
    if not (soDesc in FSortOptions) then
      Descdx := 1
    else Descdx := -1;
    mField := FData.IndexOf(FSortedField);
    NewCurRec := -1;
    if (mField <> nil) then
    begin
      if(FCurRec > 0) and
      (CompareValues(GetValue(FCurRec), GetValue(FCurRec - 1), mField) = -Descdx) then
        FGotoNearestMax := FCurRec - 1
      else
        if (FCurRec < FData.RecordCount - 1) and
          (CompareValues(GetValue(FCurRec), GetValue(FCurRec + 1), mField) = Descdx) then
          FGotoNearestMin := FCurRec + 1;
      GotoNearest(GetValue(FCurRec), FSortOptions, NewCurRec);
      FGotoNearestMax := -1;
      FGotoNearestMin := -1;
      if NewCurRec = -1 then
      begin
        if FCurRec = 0 then
          ATestIndex := 1
        else ATestIndex := 0;
        if(CompareValues(GetValue(FCurRec), GetValue(ATestIndex), mField) = -Descdx) then
          NewCurRec := ATestIndex
        else NewCurRec := FData.RecordCount - 1;
      end;
      if NewCurRec = - 1 then
        NewCurRec := 0;
      if (fCurRec < NewCurRec)
      and (CompareValues(GetValue(NewCurRec), GetValue(FCurRec), mField) = Descdx) then
        NewCurRec := NewCurRec - 1;
      if NewCurRec = -1 then
        NewCurRec := 0;
      if NewCurRec = fData.RecordCount then
        NewCurRec := fData.RecordCount - 1;
      ExchangeLists;
    end;
  end;
end;

procedure TMvxCustomDataset.GetLookupFields(List: TList);
var
  i: Integer;
begin
  for i := 0 to FieldCount - 1 do
    if(Fields[i].Lookup)
    and (Fields[i].LookupDataSet <> nil)
    and (Fields[i].LookupDataSet.Active)then
    begin
      List.Add(Fields[i]);
    end;
end;

procedure TMvxCustomDataset.InternalRefresh;

  function GetLookupKeyFieldValues(const AKeyFields: string) : Variant;
  var
    I: Integer;
    AStrings: TStrings;
    AField: TField;
  begin
    if(AKeyFields = '') then
      Result := Null
    else
    begin
      I := Pos(';', AKeyFields);
      if(I < 1) then
        Result := GetFieldValue(FindField(AKeyFields))
      else
      begin
        AStrings := TStringList.Create;
        AddStrings(AStrings, AKeyFields);
        Result := VarArrayCreate([0, AStrings.Count - 1],
          varVariant);
        for I := 0 to AStrings.Count - 1 do
        begin
          AField := FindField(AStrings[I]);
          if(AField <> nil) then
            Result[I] := GetFieldValue(AField)
          else Result[I] := Null;
        end;  
        AStrings.Free;
      end;
    end;
  end;

var
  FSaveRecNo : Integer;
  i, j : Integer;
  LList: TList;
begin
  LList := TList.Create;
  try
    GetLookupFields(LList);
    if (CalcFieldsSize <> 0) and (RecordCount > 0)
    and (Assigned(OnCalcFields) or (LList.Count > 0)) then
    begin
      FLoadFlag := True;
      FSaveRecNo := RecNo;
      DisableControls;
      for i := 1 to RecordCount do
      begin
        FCurRec := InternalSetRecNo(i);
        Resync([rmCenter]);
        Edit;
        DoOnCalcFields;

        for j := 0 to LList.Count - 1 do
          TField(LList[j]).Value := TField(LList[j]).LookupDataSet.Lookup(TField(LList[j]).LookupKeyFields,
            GetLookupKeyFieldValues(TField(LList[j]).KeyFields), TField(LList[j]).LookupResultField);
            
        Post;
      end;
      FCurRec := InternalSetRecNo(FSaveRecNo);
      Resync([rmCenter]);
      EnableControls;
      FLoadFlag := False;
    end;
  finally
    LList.Free;
  end;
end;

procedure TMvxCustomDataset.UpdateRecordFilteringAndSorting(AIsMakeSort : Boolean);
begin
  if (FSortedField <> nil) and AIsMakeSort then
    MakeRecordSort;
  UpdateFilterRecord;
  if (State = dsEdit) then
    Indexes.UpdateRecord(TValueBuffer(Data.FValues[fCurRec]))
  else Indexes.SetIsDirty;
end;

function TMvxCustomDataset.InternalIsFiltering: Boolean;
begin
  Result := Assigned(OnFilterRecord) and Filtered;
end;

procedure TMvxCustomDataset.InternalPost;
var
  Buf : TValueBuffer;
  IsMakeSort : Boolean;
  mField : TMvxMemField;
begin
  inherited InternalPost;
  FSaveChanges := True;
  IsMakeSort := FSortedField <> nil;
  if State = dsEdit then
  begin
    if IsMakeSort then
    begin
      mField := FData.IndexOf(FSortedField);
      buf := AllocMem(mField.FDataSize);
      if FData.GetActiveBuffer(ActiveBuffer, Buf, FSortedField) then
        IsMakeSort := InternalCompareValues(mField.Values[FCurRec],
                   buf, mField, soCaseInsensitive in SortOptions) <> 0
      else IsMakeSort := False;
      FreeMem(buf);
    end;
    FData.SetBuffer(ActiveBuffer, FCurRec);
  end else
  begin
    Inc(FLastBookmark);
    if (FCurRec < 0) then
      FCurRec := 0;
    FData.InsertRecord(ActiveBuffer, FCurRec, False);
    FBookMarks.Add(TValueBuffer(FLastBookmark));
    if BlobFieldCount > 0 then
    begin
      if (FCurRec < 0) or (FCurRec = RecordCount - 1)  then
        FBlobList.Add(nil)
      else FBlobList.Insert(FCurRec, nil);
    end;
    InternalAddFilterRecord;
  end;

  if BlobFieldCount > 0 then
    SetMemBlobData(ActiveBuffer);

  UpdateRecordFilteringAndSorting(IsMakeSort);
end;

procedure TMvxCustomDataset.InternalInsert;
var
  buf: TRecordBuffer;
  Value: Integer;
  mField: TMvxMemField;
begin
  if (FRecIdField <> nil) then
  begin
    mField := FData.IndexOf(FRecIdField);
    if (mField <> nil) then
    begin
      buf := mField.GetDataFromBuffer(ActiveBuffer);
      Value := mField.FMaxIncValue + 1;
      WriteByte(buf, 1);
      WriteInteger(buf, Value, 1);
    end;
  end;
end;

procedure TMvxCustomDataset.InternalAddRecord(Buffer: Pointer; Append: Boolean);
begin
  FSaveChanges := True;
  Inc(FLastBookmark);
  if Append then InternalLast;
  FData.InsertRecord(ActiveBuffer, FCurRec, True);
  FBookMarks.Add(TValueBuffer(FLastBookmark));

  if BlobFieldCount > 0 then
  begin
    if Append then
      FBlobList.Add(nil)
    else FBlobList.Insert(FCurRec, nil);
    SetMemBlobData(Buffer);
  end;

  InternalAddFilterRecord;
  
  UpdateRecordFilteringAndSorting(True);
end;

procedure TMvxCustomDataset.InternalDelete;
var
  i : Integer;
  p : TValueBuffer;
begin
  FSaveChanges := True;
  Indexes.DeleteRecord(TValueBuffer(FData.FValues.List[FCurRec]));
  FData.DeleteRecord(FCurRec);
  FBookMarks.Delete(FCurRec);

  if BlobFieldCount > 0 then
  begin
    p := TValueBuffer(FBlobList[FCurRec]);
    if (p <> nil) then
    begin
      FinalizeBlobData(p);
      FreeMem(Pointer(FBlobList[FCurRec]));
    end;
    FBlobList.Delete(FCurRec);
  end;

  if not FIsFiltered then
  begin
    if FCurRec >= FData.RecordCount then
      Dec(FCurRec);
  end else
  begin
    FFilterList.Delete(FFilterCurRec);
    if(FFilterCurRec < FFilterList.Count) then
      for i := FFilterCurRec to FFilterList.Count - 1 do
        FFilterList[i] := TValueBuffer(Integer(TValueBuffer(FFilterList[i])) - 1);
    if FFilterCurRec >= RecordCount then
      Dec(FFilterCurRec);
    if(FFilterCurRec > -1) then
      FCurRec := Integer(TValueBuffer(FFilterList[FFilterCurRec]))
    else FCurRec := -1;
  end;
end;

function TMvxCustomDataset.GetRecordCount: Longint;
begin
  if Not FIsFiltered then
    Result := FData.RecordCount
  else Result := FFilterList.Count;
end;

function TMvxCustomDataset.GetRecNo: Longint;
begin
  UpdateCursorPos;
  if (FCurRec = -1) and (RecordCount > 0) then
    Result := 1 else
  begin
    if Not FIsFiltered then
      Result := FCurRec + 1
    else Result := FFilterCurRec + 1;
  end;
end;

function TMvxCustomDataset.InternalSetRecNo(const Value: Integer): Integer;
begin
  if Not FIsFiltered then
    Result := Value - 1
  else begin
    FFilterCurRec := Value - 1;
    Result := Integer(TValueBuffer(FFilterList[FFilterCurRec])) - 1;
  end;
end;

procedure TMvxCustomDataset.SetRecNo(Value: Integer);
var
  NewCurRec : Integer;
begin
  if Active then
    CheckBrowseMode;
  if (Value > 0) and (Value <= FData.RecordCount) then
  begin
    NewCurRec := InternalSetRecNo(Value);
    if (NewCurRec <> FCurRec) then
    begin
      DoBeforeScroll;
      FCurRec := NewCurRec;
      Resync([rmCenter]);
      DoAfterScroll;
    end;
  end;
end;

procedure TMvxCustomDataset.SetFilteredRecNo(Value: Integer);
var
  Index : Integer;
begin
  Index := FFilterList.IndexOf(TValueBuffer(Value));
  if Index >= 0 then
    SetRecNo(Index + 1);
end;

function TMvxCustomDataset.GetCanModify: Boolean;
begin
  Result := False;
end;

procedure TMvxCustomDataset.ClearCalcFields(Buffer: TRecordBuffer);
var
  i : Integer;
  mField: TMvxMemField;
begin
  if (Data.Count < 2) or (State = dsCalcFields) then exit;
  for i := 1 to Data.FCalcFields.Count - 1 do
  begin
    mField := fData.IndexOf(TField(FData.FCalcFields[i]));
    WriteByte(Buffer, 0, mField.FOffSet);
  end;
end;

procedure TMvxCustomDataset.SetFiltered(Value: Boolean);
var
  AOldFiltered: Boolean;
begin
  AOldFiltered := Filtered;
  inherited SetFiltered(Value);
  if AOldFiltered <> Filtered then
    UpdateFilters;
end;

function TMvxCustomDataset.GetStringValue(const Buffer : TRecordBuffer; ADataSize: Integer) : String;
begin
    Result := String(Buffer);
end;

function TMvxCustomDataset.GetVariantValue(const Buffer : TRecordBuffer; AField : TField) : Variant;
var
  bcd: System.Currency;
begin
  case AField.DataType of
    ftString:  Result := GetStringValue(Buffer, AField.DataSize);
    ftWideString: Result := WideString(PWideChar(Buffer));
    ftSmallint, ftInteger, ftWord, ftAutoInc:
        Result := GetIntegerValue(Buffer, AField.DataType);
    ftFloat, ftCurrency:
        Result := GetFloatValue(Buffer);
    ftDate, ftTime, ftDateTime:
      Result := GetDateTimeValue(Buffer, AField);
    ftBCD:
    begin
        BCDToCurr(PBCD(Buffer)^, bcd);
        Result := bcd;
    end;
    ftBoolean: Result := GetBooleanValue(Buffer);
    ftLargeInt: Result := LongInt(GetLargeIntValue(Buffer, AField.DataType));
    else Result := NULL;
  end;
end;

function TMvxCustomDataset.GetIntegerValue(const Buffer : TRecordBuffer; DataType :
  TFieldType) : Integer;
type
  PData = ^Data;
  Data = record
    case Integer of
      0: (I: Smallint);
      1: (W: Word);
      2: (L: Longint);
  end;
var
  ptr : PData;
begin
  assert(buffer <> nil);
  ptr := PData(@buffer[0]);
  case DataType of
     ftSmallint: result := ptr^.I;
     ftWord:     result := ptr^.W;
     else
       Result := ptr^.L;
  end;
end;

function TMvxCustomDataset.GetLargeIntValue(const Buffer : TRecordBuffer; DataType : TFieldType) : Int64;
begin
  Result := 0;
  Copy(Buffer^, Result, SizeOf(Int64));
end;

function TMvxCustomDataset.GetFloatValue(const Buffer : TRecordBuffer) : Double;
begin
  Move(Buffer^, Result, SizeOf(Double));
end;

function TMvxCustomDataset.GetCurrencyValue(const Buffer : TRecordBuffer) : System.Currency;
begin
  Move(Buffer^, Result, SizeOf(System.Currency));
end;

function TMvxCustomDataset.GetDateTimeValue(const Buffer: TRecordBuffer; AField: TField): TDateTime;
begin
  DataConvert(AField, Buffer, @Result, False);
end;

function TMvxCustomDataset.GetBooleanValue(const Buffer : TRecordBuffer) : Boolean;
begin
  Move(Buffer^, Result, SizeOf(Boolean));
end;

function TMvxCustomDataset.CompareValues(const Buffer1, Buffer2 : TRecordBuffer; AmField : TMvxMemField) : Integer;
begin
  Result := InternalCompareValues(Buffer1, Buffer2, AmField, soCaseInsensitive in FSortOptions);
end;

function TMvxCustomDataset.CompareValues(const Buffer1, Buffer2 : TRecordBuffer; AField: TField) : Integer;
begin
  Result := CompareValues(Buffer1, Buffer2, Data.IndexOf(AField));
end;

function TMvxCustomDataset.InternalCompareValues(const Buffer1, Buffer2: Pointer;
  AmField: TMvxMemField;  IsCaseInsensitive: Boolean) : Integer;

  function CompareStrings: Integer;
  const
   AIgnoreCaseFlag: array [Boolean] of Cardinal = (0, NORM_IGNORECASE);
  var
    AFlags: Cardinal;
  begin
    AFlags := AIgnoreCaseFlag[IsCaseInSensitive];
    case AmField.FDataType of
      ftString:
        Result := CompareStringA(LOCALE_USER_DEFAULT, AFlags, Buffer1, -1, Buffer2, -1) - 2;
      ftWideString:
        begin
          Result := CompareStringW(LOCALE_USER_DEFAULT, AFlags, Buffer1, -1, Buffer2, -1) - 2;
          case GetLastError of
            0: ;
            ERROR_CALL_NOT_IMPLEMENTED:
              Result := CompareStringA(LOCALE_USER_DEFAULT, AFlags, Buffer1, -1, Buffer2, -1) - 2;
          else
            RaiseLastOSError;
          end;
        end;
    else
      Result := 0;
    end;
    if(Result <> 0) then
      Result := Result div abs(Result);
  end;

var
  In1, In2 : Integer;
  Db1, Db2 : Double;
  BCD1, BCD2: System.Currency;
  Bool1, Bool2 : Boolean;
  largeint1, largeint2 : Int64;
begin
  if (Buffer1 = nil) or (Buffer2 = nil) then
  begin
    if(Buffer1 = Buffer2) then
      Result := 0
    else
      if Buffer1 = nil then
        Result := -1
      else Result := 1;
    exit;
  end;
  case AmField.FDataType of
    ftString, ftWideString: Result := CompareStrings;
    ftSmallint, ftInteger, ftWord, ftAutoInc:
      begin
        In1 := GetIntegerValue(Buffer1, AmField.FDataType);
        In2 := GetIntegerValue(Buffer2, AmField.FDataType);
        if(In1 > In2) then Result := 1
          else if(In1 < In2) then Result := -1
            else Result := 0;
      end;
    ftLargeInt:
      begin
        largeint1 := GetIntegerValue(Buffer1, AmField.FDataType);
        largeint2 := GetIntegerValue(Buffer2, AmField.FDataType);
        if(largeint1 > largeint2) then Result := 1
          else if(largeint1 < largeint2) then Result := -1
            else Result := 0;
      end;
    ftFloat, ftCurrency:
      begin
        Db1 := GetFloatValue(Buffer1);
        Db2 := GetFloatValue(Buffer2);
        if(Db1 > Db2) then Result := 1
          else if(Db1 < Db2) then Result := -1
            else Result := 0;
      end;
    ftBCD:
      begin
        BCDToCurr(PBcd(Buffer1)^, BCD1);
        BCDToCurr(PBcd(Buffer2)^, BCD2);
        if(BCD1 > BCD2) then Result := 1
          else if(BCD1 < BCD2) then Result := -1
            else Result := 0;
      end;
    ftDate, ftTime, ftDateTime:
      begin
        Db1 := GetDateTimeValue(Buffer1, AmField.FField);
        Db2 := GetDateTimeValue(Buffer2, AmField.FField);
        if(Db1 > Db2) then Result := 1
         else if(Db1 < Db2) then Result := -1
           else Result := 0;
      end;
    ftBoolean:
      begin
        Bool1 := GetBooleanValue(Buffer1);
        Bool2 := GetBooleanValue(Buffer2);
        if(Bool1 > Bool2) then Result := 1
          else if(Bool1 < Bool2) then Result := -1
            else Result := 0;
      end;
    else Result := 0;
  end;
end;

function TMvxCustomDataset.AllocBuferForField(AField: TField): Pointer;
begin
  Result := AllocMem(GetDataSize(AField));
end;

function TMvxCustomDataset.GetSortOptions : TMvxSortOptions;
begin
  Result := FSortOptions;
end;

procedure TMvxCustomDataset.FillValueList(const AList: TList);
var
  I: Integer;
begin
  AList.Clear;
  AList.Capacity := FData.FValues.Count;
  for I := 0 to FData.FValues.Count - 1 do
    AList.Add(FData.FValues[i]);
end;

procedure TMvxCustomDataset.SetSortedField(Value : String);
begin
  if(FSortedFieldName <> Value) then
  begin
    FSortedFieldName := Value;
    MakeSort;
  end else FSortedField := FindField(FSortedFieldName);
end;

procedure TMvxCustomDataset.SetSortOptions(Value : TMvxSortOptions);
begin
  if(FSortOptions <> Value) then
  begin
    FSortOptions := Value;
    MakeSort;
  end;
end;

procedure TMvxCustomDataset.SetIndexes(Value : TMvxMemIndexes);
begin
  fIndexes.Assign(Value);
end;

procedure TMvxCustomDataset.SetPersistent(Value: TMvxMemPersistent);
begin
  fPersistent.Assign(Value);
end;

procedure TMvxCustomDataset.MakeSort;
var
  mField : TMvxMemField;
  List: TList;
begin
  FSortedField := nil;
  if FLoadFlag or not FActive then exit;
  FSortedField := FindField(FSortedFieldName);
  if(FSortedField <> nil) then
  begin
    mField := FData.IndexOf(FSortedField);
    if (mField <> nil) then
    begin
      UpdateCursorPos;
      List := TList.Create;
      List.Add(FBookMarks);
      if FBlobList.Count > 0 then
        List.Add(FBlobList);
      try
        DoSort(FData.FValues, mField, SortOptions, List);
      finally
        List.Free;
      end;
      UpdateFilters;
      if not FIsFiltered then
        SetRecNo(FCurRec + 1);
      if Active then
        Resync([]);
    end;
  end;
end;

procedure TMvxCustomDataset.DoSort(List : TList; AmField: TMvxMemField;
  ASortOptions: TMvxSortOptions; ExhangeList: TList);


  function CompareNodes(const ABuffer1, ABuffer2 : TRecordBuffer) : Integer;
  var
    hasValue1, hasValue2 : char;
  begin
    hasValue1 := AmField.GetHasValueFromBuffer(ABuffer1);
    hasValue2 := AmField.GetHasValueFromBuffer(ABuffer2);
    if((hasValue1 = #0)  or (hasValue2 = #0)) then
    begin
      if(hasValue1 > hasValue2) then
        Result := 1
      else
        if(hasValue1 = hasValue2) then
          Result := 0
        else Result := -1;
      exit;
    end;
    Result := InternalCompareValues(AmField.GetValueFromBuffer(ABuffer1), AmField.GetValueFromBuffer(ABuffer2), AmField, soCaseInsensitive in ASortOptions);

    if (Result = 0) and (FRecIdField <> nil) then
      Result := CompareValues(TRecordBuffer(Integer(ABuffer1) + 1),
          TRecordBuffer(Integer(ABuffer2) + 1), FRecIdField)
    else
     if soDesc in ASortOptions then
       Result := - Result;
  end;

  procedure QuickSort(L : TList; iLo, iHi: Integer);
  var
    Lo, Hi : Integer;
    i: Integer;
    Mid : TRecordBuffer;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := TRecordBuffer(L[(Lo + Hi) div 2]);
    repeat
      while (Lo < iHi) do
      begin
        if CompareNodes(TRecordBuffer(L[Lo]), Mid) < 0 then
          Inc(Lo)
        else break;
      end;
      while (Hi > iLo) do
      begin
        if CompareNodes(TRecordBuffer(L[Hi]), Mid) > 0 then
          Dec(Hi)
        else break;
      end;
      if Lo <= Hi then
      begin
        L.Exchange(Lo, Hi);
        if (ExhangeList <> nil) then
        begin
          for i := 0 to ExhangeList.Count - 1 do
            TList(ExhangeList.List[i]).Exchange(Lo, Hi);
        end;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSort(L, iLo, Hi);
    if Lo < iHi then QuickSort(L, Lo, iHi);
  end;

begin
  if List.Count > 0 then
    QuickSort(List, 0, List.Count-1);
end;

function TMvxCustomDataset.InternalGotoNearest(List : TList; AField : TField;
        const Buffer : TRecordBuffer; ASortOptions: TMvxSortOptions; var Index : Integer) : Boolean;
var
  mField: TMvxMemField;

  function _CompareValues(AIndex: Integer): Integer;
  begin
    Result := InternalCompareValues(Buffer, mField.GetValueFromBuffer(List[AIndex]), mField,
        soCaseInsensitive in ASortOptions);
  end;

var
  Min, Max, cmp : Integer;
begin
  Result := False;
  mField := Data.IndexOf(AField);
  if (List.Count = 0) or (mField = nil) then
  begin
    Index := -1;
    exit;
  end;

  if FGotoNearestMin = -1 then
    Min := 0
  else Min := FGotoNearestMin;
  if FGotoNearestMax = -1 then
    Max := List.Count - 1
  else Max := FGotoNearestMax;
  
  if {((soDesc in ASortOptions) and (_CompareValues(Min) >= 0)) or}
    (not (soDesc in ASortOptions) and (_CompareValues(Min) <= 0)) then
  begin
    cmp := _CompareValues(Min);
    Result := cmp = 0;
    if Result then
      Index := 0
    else Index := -1;
    exit;
  end;

  if ((soDesc in ASortOptions) and (_CompareValues(Max) <= 0)) {or
    (not (soDesc in ASortOptions) and (_CompareValues(Max) >= 0))} then
  begin
    cmp := _CompareValues(Max);
    Result := cmp = 0;
    if Result then
      Index := Max
    else Index := -1;
    Exit;
  end;

  repeat
    if ((Max - Min) = 1) then begin
      if(Min = Index) then Min := Max;
      if(Max = Index) then Max := Min;
    end;
    Index := Min + ((Max - Min) div 2);
    cmp := _CompareValues(Index);
    if cmp = 0 then break;
    if (soDesc in ASortOptions) then
      cmp := cmp * -1;
    if (cmp > 0) then
      Min := Index
    else  Max := Index;
  until (Min = Max);

  cmp := _CompareValues(Index);
  if (soDesc in ASortOptions) then
    cmp := cmp * -1;
  if Not (cmp = 0) then begin
    if (Index < List.Count - 1) And (cmp > 0) then
     Inc(Index);
  end else
  begin
    while (Index > 0)
    and (_CompareValues(Index - 1) = 0) do
      Dec(Index);
    Result := True;
  end;
end;

function TMvxCustomDataset.GotoNearest(const Buffer : TRecordBuffer; ASortOptions: TMvxSortOptions; var Index : Integer) : Boolean;
begin
  Index := -1;
  Result := False;
  if FLoadFlag then exit;

  if(FSortedField <> nil) then
    Result := InternalGotoNearest(FData.FValues, FSortedField, Buffer, ASortOptions, Index);
end;


procedure TMvxCustomDataset.SetOnFilterRecord(const Value: TFilterRecordEvent);
begin
  inherited SetOnFilterRecord(Value);
  UpdateFilters;
end;

procedure TMvxCustomDataset.UpdateFilterRecord;
var
  Accepted : Boolean;
begin
  if not InternalIsFiltering then exit;
  Accepted := True;
  OnFilterRecord(self, Accepted);
  if not Accepted and (FFilterCurRec > -1) and (FFilterCurRec < FFilterList.Count) then
  begin
    FFilterList.Delete(FFilterCurRec);
    FIsFiltered := True;   
  end;
end;

procedure TMvxCustomDataset.UpdateFilters;
var
  Accepted, OldControlsDisabled : Boolean;
  fCount : Integer;
begin
  if not Active then exit;
  OldControlsDisabled := ControlsDisabled;
  if not OldControlsDisabled then
    DisableControls;

  if not FProgrammedFilter then
  begin
    FFilterList.Clear;
    if InternalIsFiltering then
    begin
      FIsFiltered := False;
      First;
      fCount := 1;
      while not EOF do
      begin
        Accepted := True;
        OnFilterRecord(self, Accepted);
        if(Accepted) then
          FFilterList.Add(TValueBuffer(fCount));
        Inc(fCount);
        Next;
      end;
    end;  
  end;

  ClearBuffers;

  FIsFiltered := FProgrammedFilter
                or ((FFilterList.Count <> FData.RecordCount) and (FFilterList.Count > 0))
                or InternalIsFiltering;
  if(FIsFiltered) then
  begin
    if(RecordCount > 0) then
      RecNo := 1;
    if FFilterCurRec >= FFilterList.Count then
      FFilterCurRec := FFilterList.Count -1;
    Resync([]);
  end else First;

  if not OldControlsDisabled then
    EnableControls;
end;

function TMvxCustomDataset.GetValueCount(FieldName : String; Value : Variant) : Integer;
var
  buf : TRecordBuffer;
  i : Integer;
  mField : TMvxMemField;
  Field : TField;
begin
  Result := -1;
  Field := FindField(FieldName);
  if (Field = nil) then exit;

  mField := FData.IndexOf(Field);
  if not VarIsEmpty(Value) and not VarIsNull(Value) then
  begin
    buf := AllocBuferForField(Field);
    try
      if VariantToMemDataValue(Value, buf, Field) and (mField <> nil) then
      begin
        Result := 0;
        for i := 0 to FData.RecordCount - 1 do
          if CompareValues(buf, mField.Values[i], mField) = 0 then
            Inc(Result);
      end;
    finally
      FreeMem(buf);
    end;
  end else
  begin
    for i := 0 to FData.RecordCount - 1 do
      if mField.HasValues[I] = #0 then
        Inc(Result);
  end;
end;

procedure TMvxCustomDataset.FillBookMarks;
var
  i : Integer;
begin
  FBookMarks.Clear;
  for i := 1 to FData.RecordCount do
    FBookMarks.Add(TValueBuffer(i));
  FLastBookmark := FData.RecordCount;
end;

procedure TMvxCustomDataset.MoveCurRecordTo(Index : Integer);
var
  i, FRealRec, FRealIndex : Integer;
begin
  if(Index > 0) and (Index <= RecordCount) and (RecNo <> Index) then
  begin
    if not FIsFiltered then
    begin
      FRealRec := FCurRec;
      FRealIndex := Index - 1;
    end else
    begin
      FRealRec := Integer(TValueBuffer(FFilterList[FFilterCurRec])) - 1;
      FRealIndex := Integer(TValueBuffer(FFilterList[Index - 1])) - 1;
    end;
    FData.FValues.Move(FRealRec, FRealIndex);
    FBookMarks.Move(FRealRec, FRealIndex);
    if FBlobList.Count > 0 then
      FBlobList.Move(FRealRec, FRealIndex);
    if FIsFiltered then
    begin
      if RecNo <  Index then
      begin
        for i := RecNo to Index - 1 do
          FFilterList[i] := TValueBuffer(Integer(TValueBuffer(FFilterList[i])) - 1);
      end else
      begin
        for i := RecNo - 2 downto Index - 1  do
          FFilterList[i] := TValueBuffer(Integer(TValueBuffer(FFilterList[i])) + 1);
      end;
      FFilterList[FFilterCurRec] := TValueBuffer(FRealIndex + 1);
      FFilterList.Move(FFilterCurRec, Index - 1);
    end;
    SetRecNo(Index);
  end;
end;

procedure TMvxCustomDataset.SaveToTextFile(FileName : String);
var
  Sts : TStringList;
  St : String;
  i : Integer;
  bm : TBookMark;
  List : TList;
begin
  if Not Active then exit;

  Sts := TStringList.Create;
  List := TList.Create;
  DisableControls;
  bm := GetBookmark;
  St := '';
  for i := 0 to FieldCount - 1 do
    if not Fields[i].Calculated and not Fields[i].Lookup and not Fields[i].IsBlob then
      List.Add(Fields[i]);
  for i := 0 to List.Count - 1 do
  begin
    if i <> 0 then
      St := St + FDelimiterChar;
    St := St + TField(List[i]).FieldName;
  end;
  Sts.Add(St);
  First;
  while not EOF do
  begin
    St := '';
    for i := 0 to List.Count - 1 do
    begin
      if i <> 0 then
        St := St + FDelimiterChar;
      St := St + TField(List[i]).Text;
    end;
    Sts.Add(St);
    Next;
  end;
  GotoBookmark(bm);
  FreeBookmark(bm);
  EnableControls;
  List.Free;
  try
    Sts.SaveToFile(FileName);
  except
    raise;
  end;
  Sts.Free;
end;

procedure TMvxCustomDataset.LoadFromTextFile(FileName : String);
var
  Sts : TStringList;
  St, St1 : String;
  i, j, p : Integer;
  List : TList;
  Field : TField;
begin
  Sts := TStringList.Create;
  try
    Sts.LoadFromFile(FileName);
  except
    raise;
  end;
  if(Sts.Count = 0) then
  begin
    Sts.Free;
    exit;
  end;
  FLoadFlag := True;
  DisableControls;
  Close;
  Open;
  List := TList.Create;
  St := Sts[0];
  p := 1;
  while (St <> '') and (p > 0) do
  begin
    p := Pos(FDelimiterChar, St);
    if(p = 0) then
      St1 := St
    else begin
      St1 := Copy(St, 1, p - 1);
      St :=  Copy(St, p + 1, Length(St));
    end;
    Field := FindField(St1);
    if(Field <> nil) and (Field.Calculated or Field.Lookup or Field.IsBlob) then
      Field := nil;
    List.Add(Field);
  end;

  for i := 1 to Sts.Count - 1 do
  begin
    Append;
    St := Sts[i];
    p := 1;
    j := 0;
    while (St <> '') and (p > 0) do
    begin
      p := Pos(FDelimiterChar, St);
      if(p = 0) then
        St1 := St
      else begin
        St1 := Copy(St, 1, p - 1);
        St :=  Copy(St, p + 1, Length(St));
      end;
      if(List[j] <> nil) and (St1 <> '') then
        try
          TField(List[j]).Text := St1;
        except
          List[j] := nil;
          raise;
        end;
      Inc(j);
    end;
    Post;
  end;
  FLoadFlag := False;
  First;
  MakeSort;
  EnableControls;
  List.Free;
  Sts.Free;
end;

function GetNoByFieldType(FieldType : TFieldType) : Integer;
const
  dxFieldType : array [TFieldType] of Integer =
    (-1, //ftUnknown
     1, //ftString
     2, //ftSmallint
     3, //ftInteger
     4, //ftWord,
     5, //ftBoolean,
     6, //ftFloat,
     7, //ftCurrency,
     8, //ftBCD,
     9,  //ftDate,
     10, //ftTime,
     11, //ftDateTime,
     -1, //ftBytes,
     -1, //ftVarBytes,
     12, //ftAutoInc,
     13, //ftBlob,
     14, //ftMemo,
     15, //ftGraphic,
     16, //ftFmtMemo,
     17, //ftParadoxOle,
     18, //ftDBaseOle,
     19, //ftTypedBinary
     -1  //ftCursor
       ,-1  //ftFixedChar
       ,20 //ftWideString
       ,21  //ftLargeInt
       ,-1  //ftADT
       ,-1  //ftArray
       ,-1  //ftReference
       ,-1  //ftDataSet
       ,-1, //ftOraBlob
        -1, //ftOraClob
        -1, //ftVariant
        -1, //ftInterface
        -1, //ftIDispatch
        -1  //ftGuid
        , 22 //ftTimeStamp
        , 23 //ftFMTBcd
        {$IFDEF DELPHI10}
          , -1,  // ftFixedWideChar
          -1,    // ftWideMemo
          -1,    // ftOraTimeStamp
          -1     // ftOraInterval
        {$ENDIF}
);
begin
  Result := dxFieldType[FieldType];
end;

const
  SupportFieldCount = 23;

function GetFieldTypeByNo(No : Integer) : TFieldType;
const
  dxFieldType : array [1..SupportFieldCount] of TFieldType =
    (ftString, ftSmallint, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency, ftBCD,
     ftDate, ftTime, ftDateTime, ftAutoInc, ftBlob, ftMemo, ftGraphic, ftFmtMemo,
     ftParadoxOle, ftDBaseOle, ftTypedBinary, ftWideString,
     ftLargeInt, ftTimeStamp, ftFMTBcd);
begin
  if(No < 1) or (No > SupportFieldCount) then
    Result := ftUnknown
  else
    Result := dxFieldType[No];
end;

function GetValidName(AOwner: TComponent; AName: string): string;
var
  I: Integer;
begin
  for I := 1 to Length(AName) do
    if not ((AName[I] in ['A'..'z']) or (AName[I] in ['0'..'9'])) then
      AName[I] := '_';
  if AName[1] in ['0'..'9'] then
    AName := '_' + AName;

  Result := AName;

  I := 0;
  while AOwner.FindComponent(Result) <> nil do
  begin
    Result := AName + IntToStr(I);
    Inc(I);
  end
end;

type
  TMvxBaseFieldType = (bftBlob, bftString, bftOrdinal);

  TMvxFieldStreamer = class
  protected
    FField : TField;
  public
    property Field: TField read FField;
  end;

  TMvxFieldReader = class(TMvxFieldStreamer)
  private
    FFieldName: string;
    FBuffer : TRecordBuffer;
    FDataSize: Integer;
    FFieldSize: Integer;
    FFieldTypeNo : Integer;
    FDataType: TFieldType;
    BlobData : TMemBlobData;

    FRecordFieldSize: Integer;
    FHasValue : Byte;

    function GetHasValue: Boolean;
    procedure SetHasValue(Value: Boolean);

    function ReadFieldSize(AStream: TStream): Boolean;

    property HasValue: Boolean read GetHasValue write SetHasValue;
  protected
    function GetDataSize(AReadingDataSize: Integer): Integer; virtual;
    function GetFieldSize(AReadingDataSize: Integer): Integer; virtual;
  public
    constructor Create(AFieldName: string; AField: TField; ADataSize: Integer; AFieldTypeNo: Integer); virtual;
    destructor Destroy; override;

    procedure CreateField(AMemData: TMvxCustomDataset); virtual;
    function ReadFieldValue(AStream: TStream; AVerNo: Double): Boolean; virtual; abstract;

    property FieldName: string read FFieldName;
    property FieldTypeNo: Integer read FFieldTypeNo;
    property DataType: TFieldType read FDataType;
  end;

  TMvxFieldReaderClass = class of TMvxFieldReader;

  { TMvxReadBlobField }

  TMvxBlobFieldReader = class(TMvxFieldReader)
  private
    function ReadBlobFieldValue(AStream: TStream): Boolean;
  public
    function ReadFieldValue(AStream: TStream; AVerNo: Double): Boolean; override;
  end;

  { TMvxReadStringField }

  TMvxStringFieldReader = class(TMvxFieldReader)
  private
    function ReadString(AStream: TStream): Boolean;
    function ReadStringFieldValue(AStream: TStream): Boolean;
  protected
    function GetDataSize(AReadingDataSize: Integer): Integer; override;
    function GetFieldSize(AReadingDataSize: Integer): Integer; override;
  public
    procedure CreateField(AMemData: TMvxCustomDataset); override;
    function ReadFieldValue(AStream: TStream; AVerNo: Double): Boolean; override;
  end;

  { TMvxReadStringFieldVer190 (1.90) }

  TMvxStringFieldReaderVer190 = class(TMvxStringFieldReader)
  private
    function ReadStringFieldValue(AStream: TStream): Boolean;
  public
    function ReadFieldValue(AStream: TStream; AVerNo: Double): Boolean; override;
  end;

  { TMvxReadStringFieldVer191 (1.91) }

  TMvxStringFieldReaderVer191 = class(TMvxStringFieldReaderVer190)
  protected
    function GetDataSize(AReadingDataSize: Integer): Integer; override;
    function GetFieldSize(AReadingDataSize: Integer): Integer; override;
  end;

  { TMvxReadOrdinalField }

  TMvxOrdinalFieldReader = class(TMvxFieldReader)
  public
    function ReadFieldValue(AStream: TStream; AVerNo: Double): Boolean; override;
  end;

  { TMvxFieldWriter }

  TMvxFieldWriter = class(TMvxFieldStreamer)
  protected
    FMemData: TMvxCustomDataset;
    procedure WriteFieldValue(AStream: TStream; AMemField: TMvxMemField; ARecordIndex: Integer); virtual; abstract;

    property MemData: TMvxCustomDataset read FMemData;
  public
    constructor Create(AMemData: TMvxCustomDataset; AField: TField); virtual;
  end;

  TMvxFieldWriterClass = class of TMvxFieldWriter;

  { TMvxBlobFieldWriter }

  TMvxBlobFieldWriter = class(TMvxFieldWriter)
  protected
    procedure WriteFieldValue(AStream: TStream; AMemField: TMvxMemField; ARecordIndex: Integer); override;
  end;

  { TMvxStringFieldWriter }

  TMvxStringFieldWriter = class(TMvxFieldWriter)
  protected
    procedure WriteFieldValue(AStream: TStream; AMemField: TMvxMemField; ARecordIndex: Integer); override;
  end;

  { TMvxOrdinalFieldWriter }

  TMvxOrdinalFieldWriter = class(TMvxFieldWriter)
    procedure WriteFieldValue(AStream: TStream; AMemField: TMvxMemField; ARecordIndex: Integer); override;
  end;

  { TMvxCustomDatasetStreamer }

  TMvxCustomDatasetStreamer = class
  protected
    FStream: TStream;
    FMemData: TMvxCustomDataset;
    FFields: TList;
    FFieldStreamers: TObjectList;

    function BaseFieldType(AFieldType: TFieldType): TMvxBaseFieldType;
    function FieldCount: Integer;
    function FieldStreamersCount: Integer;
    procedure FillFieldList;
    function GetField(Index: Integer): TField;
    function GetFieldStreamersByField(AField: TField): TMvxFieldStreamer;
    function MemDataField(AField: TField): TMvxMemField;

    property Fields[Index: Integer]: TField read GetField;
  public
    constructor Create(AMemData: TMvxCustomDataset; AStream: TStream); virtual;
    destructor Destroy; override;

    property Stream: TStream read FStream;
    property MemData: TMvxCustomDataset read FMemData;
  end;

  { TMvxCustomDatasetStreamReader }

  TMvxCustomDatasetStreamReader = class(TMvxCustomDatasetStreamer)
  private
    FVerNo: Double;

    function GetFieldReader(Index: Integer): TMvxFieldReader;
    function GetFieldReaderClass(AFieldTypeNo: Integer): TMvxFieldReaderClass;
    function GetFieldReadersByField(AField: TField): TMvxFieldReader;
  protected
    procedure AddRecord;
    function ReadVerNoFromStream: Boolean;
    function ReadFieldsFromStream: Boolean;
    function ReadRecordFromStream: Boolean;

    property FieldReaders[Index: Integer]: TMvxFieldReader read GetFieldReader;
    property FieldReadersByField[Field: TField]: TMvxFieldReader read GetFieldReadersByField;
    property VerNo: Double read FVerNo;
  public
    constructor Create(AMemData: TMvxCustomDataset; AStream: TStream); override;

    procedure CreateFields(AMemData: TMvxCustomDataset);
    procedure LoadData;
  end;

{ TMvxCustomDatasetStreamWriter }

  TMvxCustomDatasetStreamWriter = class(TMvxCustomDatasetStreamer)
  private
    function GetFieldWriterClass(AFieldType: TFieldType): TMvxFieldWriterClass;
    function GetFieldWritersByField(AField: TField): TMvxFieldWriter;

    procedure WriteMemDataVersion;
    procedure WriteFields;
    procedure WriteRecord(ARecordIndex: Integer);

    property FieldWritersByField[Field: TField]: TMvxFieldWriter read GetFieldWritersByField;
  public
    procedure SaveData;
  end;

const
  MemDataVerString = 'Ver';

{TMvxReadField}
constructor TMvxFieldReader.Create(AFieldName: string; AField: TField; ADataSize: Integer; AFieldTypeNo: Integer);
begin
  inherited Create;
  FFieldName := AFieldName;
  FField := AField;
  FFieldTypeNo := AFieldTypeNo;
  FDataType := GetFieldTypeByNo(AFieldTypeNo);
  FDataSize := GetDataSize(ADataSize);
  FFieldSize := GetFieldSize(ADataSize);
  FBuffer := nil;
  if(Field <> nil) then
  begin
    FBuffer := AllocMem(FDataSize);
    HasValue := True;
  end;
end;

destructor TMvxFieldReader.Destroy;
begin
  FreeMem(FBuffer);
  inherited Destroy;
end;

function TMvxFieldReader.GetHasValue: Boolean;
begin
  Result := FHasValue = 1;
end;

procedure TMvxFieldReader.SetHasValue(Value: Boolean);
begin
  if Value then
    FHasValue := 1
  else
    FHasValue := 0;
end;

function TMvxFieldReader.ReadFieldSize(AStream: TStream): Boolean;
begin
  Result := AStream.Read(FRecordFieldSize, SizeOf(Integer)) = SizeOf(Integer);
  if FRecordFieldSize > AStream.Size then
    FRecordFieldSize := AStream.Size;
end;

procedure TMvxFieldReader.CreateField(AMemData: TMvxCustomDataset);
begin
  if (Field <> nil) or (DataType = ftUnknown) then exit;
  FField := AMemData.GetFieldClass(DataType).Create(AMemData);
  FField.FieldName := FieldName;
  FField.DataSet := AMemData;
  FField.Name := GetValidName(AMemData, AMemData.Name + Field.FieldName);
  FField.Calculated := False;
end;

function TMvxFieldReader.GetDataSize(AReadingDataSize: Integer): Integer;
begin
  Result := AReadingDataSize;
end;

function TMvxFieldReader.GetFieldSize(AReadingDataSize: Integer): Integer;
begin
  Result := AReadingDataSize;
end;

{ TMvxReadBlobField }

function TMvxBlobFieldReader.ReadFieldValue(AStream: TStream; AVerNo: Double): Boolean;
begin
  Result := True;
  if(Field <> nil) then
  begin
    if ReadFieldSize(AStream) then
    begin
      HasValue := FRecordFieldSize > 0;
      Result := ReadBlobFieldValue(AStream);
    end;
  end
  else
  begin
    AStream.Read(FRecordFieldSize, 4);
    AStream.Position := AStream.Position + FRecordFieldSize;
  end;
end;

function TMvxBlobFieldReader.ReadBlobFieldValue(AStream: TStream): Boolean;
begin
  BlobData := '';
  if Length(BlobData) < FRecordFieldSize then
    SetLength(BlobData, FRecordFieldSize);
  Result := AStream.Read(TRecordBuffer(BlobData)^, FRecordFieldSize) = FRecordFieldSize;
end;

{ TMvxReadStringField }

procedure TMvxStringFieldReader.CreateField(AMemData: TMvxCustomDataset);
begin
  inherited;
  FField.Size := FFieldSize;
end;

function TMvxStringFieldReader.ReadFieldValue(AStream: TStream; AVerNo: Double): Boolean;
begin
  Result := True;
  if(Field <> nil) then
  begin
    //For compatibility with the previous version
    //For some reason we increased the size of string length by one
    //Here we should increase it by one as well
    if ReadFieldSize(AStream) then
    begin
      HasValue := FRecordFieldSize > 1;
      Result := ReadStringFieldValue(AStream);
    end;
  end
  else
  begin
    AStream.Read(FRecordFieldSize, 4);
    AStream.Position := AStream.Position + FRecordFieldSize;
  end;
end;

function TMvxStringFieldReader.GetDataSize(AReadingDataSize: Integer): Integer;
begin
  Result := AReadingDataSize;
  if FDataType = ftWideString then
    Result := (AReadingDataSize + 1) * GetCharSize(FDataType);
end;

function TMvxStringFieldReader.GetFieldSize(AReadingDataSize: Integer): Integer;
begin
  Result := AReadingDataSize;
  if FDataType = ftString then
    Dec(Result);
end;

function TMvxStringFieldReader.ReadString(AStream: TStream): Boolean;
var
  ATempBuffer: Pointer;
  ACharCount: Integer;
begin
  ATempBuffer := AllocBuferForString(FFieldSize, FDataType);
  try
    if FRecordFieldSize > FFieldSize then
      ACharCount := FFieldSize
    else
      ACharCount := FRecordFieldSize;

    ReadBufferFromStream(AStream, ATempBuffer, ACharCount * GetCharSize(FDataType));
    AStream.Position := AStream.Position + (FRecordFieldSize - ACharCount) * GetCharSize(FDataType);
    Result := AStream.Position <= AStream.Size;
    CopyChars(ATempBuffer, FBuffer, FFieldSize, FDataType);
  finally
    FreeMem(ATempBuffer);
  end;
end;

function TMvxStringFieldReader.ReadStringFieldValue(AStream: TStream): Boolean;
begin
  Result := True;
  case FDataType of
    ftString: Result := ReadString(AStream);
    ftWideString:
      if HasValue then
      begin
       AStream.Position := AStream.Position + 1; //for compatibilities with previous versions
       Result := ReadString(AStream);
      end;
  end;
end;

{ TMvxReadStringFieldVer190 (1.90) }

function TMvxStringFieldReaderVer190.ReadFieldValue(AStream: TStream; AVerNo: Double): Boolean;
begin
  Result := True;
  if(Field <> nil) then
    Result := ReadStringFieldValue(AStream)
  else
  begin
    AStream.Read(FRecordFieldSize, 4);
    AStream.Position := AStream.Position + FRecordFieldSize;
  end;
end;

function TMvxStringFieldReaderVer190.ReadStringFieldValue(AStream: TStream): Boolean;
begin
  Result  := True;
  AStream.Read(FHasValue, 1);
  if HasValue then
  begin
    ReadFieldSize(AStream);
    Result := ReadString(AStream)
  end;
end;

{ TMvxReadStringFieldVer191 (1.91) }

function TMvxStringFieldReaderVer191.GetDataSize(AReadingDataSize: Integer): Integer;
begin
  Result := (AReadingDataSize + 1) * GetCharSize(FDataType);
end;

function TMvxStringFieldReaderVer191.GetFieldSize(AReadingDataSize: Integer): Integer;
begin
  Result := AReadingDataSize;
end;

{ TMvxReadOrdinalField }

function TMvxOrdinalFieldReader.ReadFieldValue(AStream: TStream; AVerNo: Double): Boolean;
begin
  Result := True;
  if(Field <> nil) then
  begin
    if AVerNo > 0 then
      AStream.Read(FHasValue, 1);
    Result := ReadBufferFromStream(AStream, FBuffer, FDataSize);
  end
  else
  begin
    if AVerNo > 0 then
      AStream.Position := AStream.Position + 1;
    AStream.Position := AStream.Position + FDataSize;
  end;
end;

{ TMvxFieldWriter }

constructor TMvxFieldWriter.Create(AMemData: TMvxCustomDataset; AField: TField);
begin
  inherited Create;
  FMemData := AMemData;
  FField := AField;
end;

{ TMvxBlobFieldWriter }

procedure TMvxBlobFieldWriter.WriteFieldValue(AStream: TStream; AMemField: TMvxMemField; ARecordIndex: Integer);
var
  ABlobLength : Integer;
  ABlobData: string;
begin
  ABlobData := MemData.GetBlobData(TValueBuffer(MemData.FBlobList[ARecordIndex]), Field.OffSet);
  ABlobLength := Length(ABlobData);
  WriteIntegerToStream(AStream, ABlobLength);
  if (ABlobLength > 0) then
    WriteStringToStream(AStream, ABlobData);
end;

{ TMvxStringFieldWriter }

procedure TMvxStringFieldWriter.WriteFieldValue(AStream: TStream; AMemField: TMvxMemField; ARecordIndex: Integer);
var
  AStrLength: Integer;
begin
  WriteCharToStream(AStream, AMemField.HasValues[ARecordIndex]);
  if AMemField.HasValues[ARecordIndex] = #1 then
  begin
    AStrLength := MemData.GetStringLength(Field.DataType, AMemField.Values[ARecordIndex]);
    WriteIntegerToStream(AStream, AStrLength);
    WriteBufferToStream(AStream, AMemField.Values[ARecordIndex], AStrLength * GetCharSize(Field.DataType));
  end;
end;

{ TMvxOrdinalFieldWriter }

procedure TMvxOrdinalFieldWriter.WriteFieldValue(AStream: TStream; AMemField: TMvxMemField; ARecordIndex: Integer);
begin
  WriteCharToStream(AStream, AMemField.HasValues[ARecordIndex]);
  WriteBufferToStream(AStream, AMemField.Values[ARecordIndex], AMemField.FDataSize);
end;

{ TMvxCustomDatasetStreamer }

constructor TMvxCustomDatasetStreamer.Create(AMemData: TMvxCustomDataset; AStream: TStream);
begin
  inherited Create;
  FMemData := AMemData;
  FStream := AStream;
  FFields := TList.Create;
  FFieldStreamers := TObjectList.Create;
end;

destructor TMvxCustomDatasetStreamer.Destroy;
begin
  FreeAndNil(FFieldStreamers);
  FreeAndNil(FFields);
  inherited Destroy;
end;

function TMvxCustomDatasetStreamer.BaseFieldType(AFieldType: TFieldType): TMvxBaseFieldType;
begin
  if (MemData.GetFieldClass(AFieldType) <> nil) and MemData.GetFieldClass(AFieldType).IsBlob then
    Result := bftBlob
  else
    if AFieldType in ftStrings then
      Result := bftString
    else
      Result := bftOrdinal;
end;

function TMvxCustomDatasetStreamer.FieldCount: Integer;
begin
  Result := FFields.Count;
end;

function TMvxCustomDatasetStreamer.FieldStreamersCount: Integer;
begin
  Result := FFieldStreamers.Count;
end;

procedure TMvxCustomDatasetStreamer.FillFieldList;
var
  I: Integer;
begin
  for I := 0 to MemData.FieldCount - 1 do
    if not MemData.Fields[i].Lookup and not MemData.Fields[i].Calculated then
      FFields.Add(MemData.Fields[I]);
end;

function TMvxCustomDatasetStreamer.GetField(Index: Integer): TField;
begin
  Result := TField(FFields[Index]);
end;

function TMvxCustomDatasetStreamer.GetFieldStreamersByField(AField: TField): TMvxFieldStreamer;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FieldStreamersCount - 1 do
    if(TMvxFieldStreamer(FFieldStreamers[I]).Field = AField) then
    begin
      Result := TMvxFieldStreamer(FFieldStreamers[I]);
      Break;
    end;
end;

function TMvxCustomDatasetStreamer.MemDataField(AField: TField): TMvxMemField;
begin
  Result := MemData.Data.IndexOf(AField);
end;

{TMvxCustomDatasetStreamReader}

constructor TMvxCustomDatasetStreamReader.Create(AMemData: TMvxCustomDataset; AStream: TStream);
begin
  inherited;
  FVerNo := -1;
end;

function TMvxCustomDatasetStreamReader.GetFieldReader(Index: Integer): TMvxFieldReader;
begin
  Result := TMvxFieldReader(FFieldStreamers[Index]);
end;

function TMvxCustomDatasetStreamReader.GetFieldReaderClass(AFieldTypeNo: Integer): TMvxFieldReaderClass;
var
  AFieldType: TFieldType;
begin
  AFieldType := GetFieldTypeByNo(AFieldTypeNo);
  case BaseFieldType(AFieldType) of
    bftBlob: Result := TMvxBlobFieldReader;
    bftString:
      if VerNo < 1.85 then
        Result := TMvxStringFieldReader
      else
        if VerNo < 1.905 then
          Result := TMvxStringFieldReaderVer190
        else
          Result := TMvxStringFieldReaderVer191;
  else { bftOrdinal }
    Result := TMvxOrdinalFieldReader;
  end;
end;

function TMvxCustomDatasetStreamReader.GetFieldReadersByField(AField : TField) : TMvxFieldReader;
begin
  Result := TMvxFieldReader(GetFieldStreamersByField(AField));
end;

procedure TMvxCustomDatasetStreamReader.AddRecord;
var
  ARecordCount: Integer;
  p: TValueBuffer;
  I: Integer;
  dxrField: TMvxFieldReader;
begin
  ARecordCount := (MemData.RecordCount + 1);
  p := AllocMem(SizeOf(Integer));
  try
    WriteInteger(p, ARecordCount);
    MemData.Data.Items[0].AddValue(p);
  finally
    FreeMem(p);
  end;

  if MemData.BlobFieldCount > 0 then
  begin
    p := AllocMem(MemData.BlobFieldCount * SizeOf(TValueBuffer));
    MemData.InitializeBlobData(p);
    MemData.FBlobList.Add(p);
  end;
  for i := 0 to FieldCount - 1 do
  begin
    dxrField := GetFieldReadersByField(Fields[I]);

    if not Fields[I].IsBlob then
    begin
      if (dxrField <> nil) and dxrField.HasValue then
        MemDataField(Fields[I]).AddValue(dxrField.FBuffer)
      else
        MemDataField(Fields[I]).AddValue(nil);
    end
    else
    begin
      if (MemData.FBlobList.Last <> nil) and (dxrField <> nil) then
        MemData.SetInternalBlobData(TValueBuffer(MemData.FBlobList.Last), dxrField.Field.Offset, dxrField.BlobData);
    end;
  end;
end;

function TMvxCustomDatasetStreamReader.ReadVerNoFromStream: Boolean;
var
  ABuf: Array[0..Length(MemDataVerString)] of Char;
begin
  Result := Stream.Read(ABuf, Length(MemDataVerString)) = Length(MemDataVerString);
  ABuf[Length(MemDataVerString)] := #0;
  if Result then
  begin
    if ABuf = MemDataVerString then
    begin
      Result := Stream.Read(FVerNo, SizeOf(Double)) = SizeOf(Double);
      if FVerNo < 1 then
        FVerNo := 1;
    end else
    begin
      Stream.Position := 0;
      FVerNo := 0;
    end;
  end;
end;

function TMvxCustomDatasetStreamReader.ReadFieldsFromStream: Boolean;
var
  i, AFieldSize, Count: Integer;
  AFieldTypeNo, AFieldNameLength : SmallInt;
  ABuf: Array[0..255] of Char;
begin
  Result := False;
  Stream.Read(Count, 4);
  for i := 0 to Count - 1 do
  begin
    if (Stream.Read(AFieldSize, 4) < 4) then
      Exit;
    if (Stream.Read(AFieldTypeNo, 2) < 2) then
      Exit;
    if (Stream.Read(AFieldNameLength, 2) < 2) then
      Exit;
    if (AFieldNameLength > 255) then
      raise Exception.Create(IncorrectedData);
    if (Stream.Read(ABuf, AFieldNameLength) < AFieldNameLength) then
      Exit;
    FFieldStreamers.Add(GetFieldReaderClass(AFieldTypeNo).Create(string(ABuf), MemData.FindField(String(ABuf)), AFieldSize, AFieldTypeNo));
  end;
  Result := (Stream.Position < Stream.Size) and (FieldStreamersCount > 0);
end;

function TMvxCustomDatasetStreamReader.ReadRecordFromStream: Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to FieldStreamersCount - 1 do
  begin
     Result := FieldReaders[I].ReadFieldValue(Stream, VerNo);
     if not Result then
       break;
  end;
end;

procedure TMvxCustomDatasetStreamReader.CreateFields(AMemData: TMvxCustomDataset);
var
  I : Integer;
begin
  if ReadVerNoFromStream and ReadFieldsFromStream then
  begin
    for I := 0 to FieldStreamersCount - 1 do
      FieldReaders[I].CreateField(AMemData);
  end;
end;

procedure TMvxCustomDatasetStreamReader.LoadData;
begin
  if not ReadVerNoFromStream or not ReadFieldsFromStream then exit;
  FillFieldList;
  while True do
  begin
    if ReadRecordFromStream then
      AddRecord
    else break;
    if (Stream.Position >= Stream.Size) then  break;
  end;
end;

{TMvxCustomDatasetStreamWriter}

procedure TMvxCustomDatasetStreamWriter.WriteMemDataVersion;
begin
  WriteStringToStream(Stream, MemDataVerString);
  WriteDoubleToStream(Stream, MemDataVer);
end;

function TMvxCustomDatasetStreamWriter.GetFieldWriterClass(AFieldType: TFieldType): TMvxFieldWriterClass;
begin
  case BaseFieldType(AFieldType) of
    bftBlob: Result := TMvxBlobFieldWriter;
    bftString: Result := TMvxStringFieldWriter;
  else { bftOrdinal }
    Result := TMvxOrdinalFieldWriter;
  end;
end;

function TMvxCustomDatasetStreamWriter.GetFieldWritersByField(AField: TField): TMvxFieldWriter;
begin
  Result := TMvxFieldWriter(GetFieldStreamersByField(AField));
end;

procedure TMvxCustomDatasetStreamWriter.WriteFields;
var
  I: Integer;
begin
  WriteIntegerToStream(Stream, FieldCount);
  for I := 0 to FieldCount - 1 do
  begin
    if Fields[I].DataType in ftStrings then
      WriteIntegerToStream(Stream, Fields[I].Size)
    else
      WriteIntegerToStream(Stream, Fields[I].DataSize);

    WriteSmallIntToStream(Stream, GetNoByFieldType(Fields[I].DataType));
    WriteSmallIntToStream(Stream, Length(Fields[I].FieldName) + 1);
    WriteStringToStream(Stream, Fields[I].FieldName);

    //lines below for compability with Win32 version.
    //there was a bug on saving unneeded byte
    WriteCharToStream(Stream, #0);

    FFieldStreamers.Add(GetFieldWriterClass(Fields[I].DataType).Create(MemData, Fields[I]));
  end;
end;

procedure TMvxCustomDatasetStreamWriter.WriteRecord(ARecordIndex: Integer);
var
  I: Integer;
begin
  for I := 0 to FieldCount - 1 do
    FieldWritersByField[Fields[I]].WriteFieldValue(Stream, MemDataField(Fields[I]), ARecordIndex);
end;

procedure TMvxCustomDatasetStreamWriter.SaveData;
var
  I : Integer;
begin
  WriteMemDataVersion;
  FillFieldList;
  WriteFields;

  for I := 0 to MemData.FData.RecordCount - 1 do
    WriteRecord(I);
end;

procedure TMvxCustomDataset.CreateFieldsFromStream(Stream : TStream);
var
  AMemStreamReader: TMvxCustomDatasetStreamReader;
begin
  Close;
  AMemStreamReader := TMvxCustomDatasetStreamReader.Create(self, Stream);
  try
    AMemStreamReader.CreateFields(self);
  finally
    AMemStreamReader.Free;
  end;
end;

procedure TMvxCustomDataset.LoadFromStream(Stream : TStream);
var
  AMemReader: TMvxCustomDatasetStreamReader;
begin
  DisableControls;
  Close;
  Open;
  FLoadFlag := True;
  AMemReader := TMvxCustomDatasetStreamReader.Create(self, Stream);
  try
    AMemReader.LoadData;
  finally
    AMemReader.Free;
    FLoadFlag := False;
    FillBookmarks;
    MakeSort;
    UpdateFilters;
    if not FIsFiltered then
      First;
    Resync([]);
    Refresh;
    EnableControls;
  end;
end;

procedure TMvxCustomDataset.LoadFromBinaryFile(FileName : String);
var
  AStream : TMemoryStream;
begin
  AStream := TMemoryStream.Create;
  try
    AStream.LoadFromFile(FileName);
    LoadFromStream(AStream);
  finally
    AStream.Free;
  end;
end;

procedure TMvxCustomDataset.SaveToStream(Stream : TStream);
var
  AMemDataStreamWriter: TMvxCustomDatasetStreamWriter;
begin
  if not Active then exit;
  AMemDataStreamWriter := TMvxCustomDatasetStreamWriter.Create(self, Stream);
  try
    AMemDataStreamWriter.SaveData;
  finally
    AMemDataStreamWriter.Free;
  end;
end;

procedure TMvxCustomDataset.SaveToBinaryFile(FileName : String);
var
  fMem : TMemoryStream;
begin
  if Not Active then exit;

  fMem := TMemoryStream.Create;
  SaveToStream(fMem);
  try
    fMem.SaveToFile(FileName);
  except
    raise;
  end;
  fMem.Free;
end;

function TMvxCustomDataset.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
begin
  Result := TMemBlobStream.Create(TBlobField(Field), Mode);
end;

procedure TMvxCustomDataset.CloseBlob(Field: TField);
begin
  if (FBlobList <> nil) and (FCurRec >= 0) and (FCurRec < RecordCount) and (State = dsEdit) then
    SetBlobData(ActiveBuffer, Field, GetBlobData(TValueBuffer(FBlobList[FCurRec]), Field.Offset))
  else SetBlobData(ActiveBuffer, Field, '');
end;

procedure TMvxCustomDataset.BlobClear;
var
  i : Integer;
  p : TValueBuffer;
begin
  if BlobFieldCount > 0 then
    for i := 0 to FBlobList.Count - 1 do
    begin
      p := TValueBuffer(FBlobList[i]);
      if(p <> nil) then
      begin
        FinalizeBlobData(p);
        FreeMem(Pointer(FBlobList[i]));
      end;
    end;
  FBlobList.Clear;
end;

procedure TMvxCustomDataset.InitializeBlobData(Buffer: TValueBuffer);
begin
  if BlobFieldCount = 0 then exit;
  FillZeroData(Buffer, BlobFieldCount * SizeOf(Integer));
end;

procedure TMvxCustomDataset.SetOnPrepare(const Value: TNotifyEvent);
begin
  FOnPrepare := Value;
end;

procedure TMvxCustomDataset.FinalizeBlobData(Buffer: TValueBuffer);
var
  I: Integer;
  ptr: TValueBuffer;
begin
  if BlobFieldCount = 0 then exit;
  for I := 0 to BlobFieldCount - 1 do
  begin
    ptr := TValueBuffer(Integer(Buffer) + I * SizeOf(Integer));
    ptr := ReadPointer(ptr);
    FreeMem(ptr);
  end;
end;

function TMvxCustomDataset.GetBlobData(Buffer: TRecordBuffer; AOffSet: Integer): TMemBlobData;
var
  ptr: TValueBuffer;
  Len: Integer;
  data: PChar;
begin
  Result := '';
  if Buffer = nil then
    Exit;
  ptr := TValueBuffer(Integer(Buffer) + AOffSet * SizeOf(TValueBuffer));
  ptr := ReadPointer(ptr);
  if ptr <> nil then
  begin
    Move(ptr^, Len, SizeOf(Integer));
    if Len > 0 then
    begin
      SetLength(Result, Len);
      data := StrAlloc(Len + 1);
      try
        Move(TRecordBuffer(Integer(ptr) + SizeOf(Integer))^, data^, Len);
        data[Len] := #0;
        Move(data^, PChar(@Result[1])^, Len);
      finally
        StrDispose(data);
      end;
    end;
  end;
end;

function TMvxCustomDataset.GetBlobData(Buffer: TRecordBuffer; Field: TField): TMemBlobData;
begin
  Result := GetBlobData(TRecordBuffer(Integer(Buffer) + FRecBufSize), Field.Offset);
end;

procedure TMvxCustomDataset.SetInternalBlobData(Buffer: TRecordBuffer; AOffSet: Integer; const Value: TMemBlobData);
var
  ptr, bufPtr: TValueBuffer;
  Len: Integer;
  data: Pointer;
begin
  bufPtr := TValueBuffer(Integer(Buffer) + AOffSet * SizeOf(TValueBuffer));
  ptr := ReadPointer(bufPtr);
  if ptr <> nil then
  begin
    FreeMem(ptr);
    ptr := nil;
  end;
  Len := Length(Value);
  if Len > 0 then
  begin
    ptr := AllocMem(Len + SizeOf(TValueBuffer));
    WriteInteger(ptr, Len);
    data := PChar(Value);
    CopyData(data, ptr, 0, SizeOf(Integer), Len);
  end;
  WritePointer(bufPtr, ptr);
end;

procedure TMvxCustomDataset.SetBlobData(Buffer: TRecordBuffer; AOffSet: Integer; const Value: TMemBlobData);
begin
  if (TRecordBuffer(Integer(ActiveBuffer) + FRecBufSize) <> Buffer) or (State = dsFilter) then exit;
  SetInternalBlobData(Buffer, AOffSet, Value);
end;

procedure TMvxCustomDataset.SetBlobData(Buffer: TRecordBuffer; Field: TField; const Value: TMemBlobData);
begin
  SetBlobData(TRecordBuffer(Integer(Buffer) + FRecBufSize), Field.Offset, Value);
end;

function TMvxCustomDataset.GetActiveBlobData(Field: TField): TMemBlobData;
var
  i : Integer;
begin
  Result := '';
  i := FCurRec;
  if (i < 0) and (RecordCount > 0) then i := 0
  else if i >= RecordCount then i := RecordCount - 1;
  if (i >= 0) and (i < RecordCount) then
  begin
    if FIsFiltered then
      i := Integer(TValueBuffer(FFilterList[FFilterCurRec])) - 1;
    Result := GetBlobData(TValueBuffer(FBlobList[i]), Field.Offset);
  end;
end;

procedure TMvxCustomDataset.GetMemBlobData(Buffer : TRecordBuffer);
var
  i : Integer;
begin
  if BlobFieldCount > 0 then
  begin
    if (FCurRec >= 0) and (FCurRec < FData.RecordCount) then
    begin
      for i := 0 to BlobFieldCount - 1 do
        SetInternalBlobData(TRecordBuffer(Integer(Buffer) + FRecBufSize), i, GetBlobData(TValueBuffer(FBlobList[FCurRec]), i))
    end;
  end;
end;

procedure TMvxCustomDataset.SetMemBlobData(Buffer : TRecordBuffer);
var
  p : TValueBuffer;
  i, Pos : Integer;
begin
  if BlobFieldCount > 0 then
  begin
    Pos := FCurRec;
    if (Pos < 0) and (FData.RecordCount > 0) then Pos := 0
    else if Pos >= FData.RecordCount then Pos := FData.RecordCount - 1;
    if (Pos >= 0) and (Pos < FData.RecordCount) then
    begin
      if FBlobList[Pos] = nil then
        p := nil
      else p := TValueBuffer(FBlobList[Pos]);
      if p = nil then
      begin
        p := AllocMem(BlobFieldCount * SizeOf(Pointer));
        InitializeBlobData(p);
      end;
      for i := 0 to BlobFieldCount - 1 do
        SetInternalBlobData(p, i, GetBlobData(TRecordBuffer(Integer(Buffer) + FRecBufSize), i));
      FBlobList[Pos] := p;
    end;
  end;
end;

procedure TMvxCustomDataset.CreateFieldsFromDataSet(DataSet : TDataSet);
var
  AField : TField;
  i : Integer;
begin
  if (DataSet = nil) or (DataSet.FieldCount = 0) then exit;
  Close;
  while FieldCount > 1 do
    Fields[FieldCount - 1].Free;
  if DataSet.FieldCount > 0 then
  begin
    for i := 0 to DataSet.FieldCount - 1 do
      if SupportedFieldType(DataSet.Fields[i].DataType)
      and (CompareText(DataSet.Fields[i].FieldName, 'RECID') <> 0) then
      begin
        AField := DefaultFieldClasses[DataSet.Fields[i].DataType].Create(self);
        AField.Name := GetValidName(Self, Name + DataSet.Fields[i].FieldName);
        AField.DisplayLabel := DataSet.Fields[i].DisplayLabel;
        AField.DisplayWidth := DataSet.Fields[i].DisplayWidth;
        AField.EditMask := DataSet.Fields[i].EditMask;
        AField.FieldName := DataSet.Fields[i].FieldName;
        AField.Visible := DataSet.Fields[i].Visible;
        if (AField is TStringField) or (AField is TBlobField) then
          AField.Size := DataSet.Fields[i].Size;
        if AField is TFloatField then
        begin
          TFloatField(AField).Currency := TFloatField(DataSet.Fields[i]).Currency;
          TFloatField(AField).Precision := TFloatField(DataSet.Fields[i]).Precision;
        end;
        AField.DataSet := self;
        AField.Calculated := DataSet.Fields[i].Calculated;
        AField.Lookup := DataSet.Fields[i].Lookup;
        if DataSet.Fields[i].Lookup then
        begin
          AField.KeyFields := DataSet.Fields[i].KeyFields;
          AField.LookupDataSet := DataSet.Fields[i].LookupDataSet;
          AField.LookupKeyFields := DataSet.Fields[i].LookupKeyFields;
          AField.LookupResultField := DataSet.Fields[i].LookupResultField;
        end;
      end;
  end else
  begin
    DataSet.FieldDefs.Update;
    for i := 0 to DataSet.FieldDefs.Count - 1 do
      if SupportedFieldType(DataSet.FieldDefs[i].DataType) then
      begin
        AField := DefaultFieldClasses[DataSet.Fields[i].DataType].Create(self);
        AField.Name := Name + DataSet.FieldDefs[i].Name;
        AField.FieldName := DataSet.FieldDefs[i].Name;
        if (AField is TStringField) or (AField is TBlobField) then
          AField.Size := DataSet.FieldDefs[i].Size;
        AField.DataSet := self;
      end;
  end;
end;

procedure TMvxCustomDataset.CopyFromDataSet(DataSet : TDataSet);
begin
  Close;
  CreateFieldsFromDataSet(DataSet);
  LoadFromDataSet(DataSet);
end;

procedure TMvxCustomDataset.LoadFromDataSet(DataSet : TDataSet);

  function CanAssignTo(ASource, ADestination: TFieldType): Boolean;
  begin
    Result := ASource = ADestination;
    if not Result then
      Result := (ASource = ftAutoInc) and (ADestination = ftInteger);
  end;

  procedure ClearAutoIncList;
  var
    I: Integer;
  begin
    for I := 1 to Data.FItems.Count - 1 do
    begin
      if Data.Items[I].FDataType = ftAutoInc then
        Data.FIsNeedAutoIncList.Remove(Data.Items[I]);
    end;
  end;

  procedure SetAutoIncList;
  var
    I: Integer;
  begin
    for I := 1 to Data.FItems.Count - 1 do
    begin
      if Data.Items[I].FDataType = ftAutoInc then
        Data.FIsNeedAutoIncList.Add(Data.Items[I]);
    end;
  end;

var
  i : Integer;
  AField : TField;
  mField: TMvxMemField;
begin
  if (DataSet = nil) or (DataSet.FieldCount = 0) or not DataSet.Active then exit;
  if FieldCount < 2 then
    CreateFieldsFromDataSet(DataSet);
  DataSet.DisableControls;
  DataSet.First;
  DisableControls;
  Open;
  ClearAutoIncList;
  while not DataSet.EOF do
  begin
    Append;
    for i := 0 to DataSet.FieldCount - 1 do
    begin
      AField := FindField(DataSet.Fields[i].FieldName);
      if(AField <> nil) and CanAssignTo(DataSet.Fields[i].DataType, AField.DataType) then
      begin
          if (AField.DataType = ftLargeInt) and (DataSet.Fields[i].DataType = ftLargeInt) then
            TLargeintField(AField).AsLargeInt := TLargeintField(DataSet.Fields[i]).AsLargeInt
          else
         AField.Value := GetFieldValue(DataSet.Fields[i]);
         if AField.DataType = ftAutoInc then
         begin
           mField := Data.IndexOf(AField);
           if mField.FMaxIncValue < AField.AsInteger then
             mField.FMaxIncValue := AField.AsInteger;
         end;
      end;
    end;
    Post;
    DataSet.Next;
  end;
  SetAutoIncList;
  DataSet.EnableControls;
  EnableControls;
end;

{TMemBlobStream}
constructor TMemBlobStream.Create(Field: TBlobField; Mode: TBlobStreamMode);
begin
  inherited Create;
  FMode := Mode;
  FField := Field;
  FDataSet := TMvxCustomDataset(FField.DataSet);
  if not FDataSet.GetActiveRecBuf(FBuffer) then Exit;
  if not FField.Modified and (Mode <> bmRead) then
  begin
    FCached := True;
    if FField.ReadOnly then DatabaseErrorFmt(SFieldReadOnly, [FField.DisplayName]);
    if not (FDataSet.State in [dsEdit, dsInsert]) then DatabaseError(SNotEditing);
  end else FCached := (FBuffer = FDataSet.ActiveBuffer);
  FOpened := True;
  if Mode = bmWrite then Truncate;
end;

destructor TMemBlobStream.Destroy;
begin
  if FOpened then
    if FModified then FField.Modified := True;
  if FModified then
  try
    FDataSet.DataEvent(deFieldChange, Longint(FField));
  except
    Application.HandleException(Self);
  end;
end;

function TMemBlobStream.GetBlobSize: Longint;
begin
  Result := 0;
  if FOpened then
    if FCached then
      Result := Length(FDataSet.GetBlobData(FBuffer, FField))
    else Result :=  Length(FDataSet.GetActiveBlobData(FField));
end;

function TMemBlobStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := 0;
  if FOpened then
  begin
    if FCached then
    begin
      if Count > Size - FPosition then
        Result := Size - FPosition else
        Result := Count;
      if Result > 0 then
      begin
        Move(TRecordBuffer(FDataSet.GetBlobData(FBuffer, FField))[FPosition], Buffer, Result);
        Inc(FPosition, Result);
      end;
    end else
    begin
      Move(TRecordBuffer(FDataSet.GetActiveBlobData(FField))[FPosition], Buffer, Result);
      Inc(FPosition, Result);
    end;
  end;
end;

function TMemBlobStream.Write(const Buffer; Count: Longint): Longint;
var
  Temp: TMemBlobData;
begin
  Result := 0;
  if FOpened and FCached  then
  begin
    Temp := FDataSet.GetBlobData(FBuffer, FField);
    if Length(Temp) < FPosition + Count then
      SetLength(Temp, FPosition + Count);
    Move(Buffer, TRecordBuffer(Temp)[FPosition], Count);
    FDataSet.SetBlobData(FBuffer, FField, Temp);
    Inc(FPosition, Count);
    Result := Count;
    FModified := True;
  end;
end;

function TMemBlobStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    0: FPosition := Offset;
    1: Inc(FPosition, Offset);
    2: FPosition := GetBlobSize + Offset;
  end;
  Result := FPosition;
end;

procedure TMemBlobStream.Truncate;
begin
  if FOpened then begin
    FDataSet.SetBlobData(FBuffer, FField, '');
    FModified := True;
  end;
end;

{ TMvxMemPersistent }
procedure TMvxMemPersistent.Assign(Source: TPersistent);
begin
  if (Source is TMvxMemPersistent) then
  begin
    Option := TMvxMemPersistent(Source).Option;
    FStream.LoadFromStream(TMvxMemPersistent(Source).FStream);
  end else inherited;
end;

constructor TMvxMemPersistent.Create(AMemData: TMvxCustomDataset);
begin
  inherited Create;
  FStream := TMemoryStream.Create;
  FOption := poActive;
  FMemData := AMemData;
  FIsLoadFromPersistent := False;
end;

destructor TMvxMemPersistent.Destroy;
begin
  FStream.Free;

  inherited Destroy;
end;

procedure TMvxMemPersistent.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Data', ReadData, WriteData, HasData);
end;

procedure TMvxMemPersistent.ReadData(Stream: TStream);
begin
  FStream.Clear;
  FStream.LoadFromStream(Stream);
end;

procedure TMvxMemPersistent.WriteData(Stream: TStream);
begin
  FStream.SaveToStream(Stream);
end;

function TMvxMemPersistent.HasData: Boolean;
begin
  Result := FStream.Size > 0;
end;

procedure TMvxMemPersistent.LoadData;
begin
  if HasData and not FIsLoadFromPersistent then
  begin
    FIsLoadFromPersistent := True;
    try
      FStream.Position := 0;
      FMemData.LoadFromStream(FStream);
    finally
      FIsLoadFromPersistent := False;
    end;
  end;
end;

procedure TMvxMemPersistent.SaveData;
begin
  FStream.Clear;
  FMemData.SaveToStream(FStream);
end;

procedure TMvxCustomDataset.GetMICommandList(const AMIProgram: String;
  AList: TStrings);
var
  AMvxCmd: TMvxTransact;
  AStat: TMvxTransactionStatus;
begin
  AList.Clear;
  if Trim(AMIProgram) = EmptyStr then
    exit;
  if not Assigned(Connection) then
    raise EMvxAPIError.Create(SNoConnection);
  if not Connection.Connected then
    Connection.Open;
  if FLastPgm = AMIProgram then
  begin
    AList.Assign(FTransactionList);
  end else
  begin
    AMvxCmd := TMvxTransact.Create(Self);
    FTransactionList.Clear;
    try
      AMvxCmd.Connection := Self.Connection;
      AMvxCmd.MIProgram := MVX_RES_NAME;
      AMvxCmd.MICommand := MVX_CMD_LIST;
      AMvxCmd.Open;
      try
        AMvxCmd.InputParams[0].AsString := AMIProgram;
        AStat := AMvxCmd.Transact;
        if AStat = stREP then
        begin
          while AStat = stREP do
          begin
            FTransactionList.Add(AMvxCmd.OutputParams.Items[1].AsString);
            AStat := AMvxCmd.Receive;
          end;
        end else
        if AStat = stOK then
          FTransactionList.Add(AMvxCmd.OutputParams.Items[1].AsString);
      finally
        AMvxCmd.Close;
      end;
    finally
      AMvxCmd.Free;
      AList.Assign(FTransactionList);
    end;
  end;
end;

function TMvxCustomDataset.GetConnection: TMvxConnection;
begin
  Result := FMvxCmd.Connection;
end;

function TMvxCustomDataset.GetMICommand: string;
begin
  Result := FMvxCmd.MICommand;
end;

function TMvxCustomDataset.GetMIProgram: string;
begin
  Result := FMvxCmd.MIProgram;
end;

function TMvxCustomDataset.GetMvxParams: TMvxParams;
begin
  Result := FMvxCmd.InputParams;
end;

function TMvxCustomDataset.GetPrepared: boolean;
begin
  Result := FMvxCmd.Prepared;
end;

procedure TMvxCustomDataset.InternalPrepare(Sender: TObject);
var
  i: integer;
  Item: TMvxParam;
  AField : TField;
begin
  if Prepared then
  begin
    Active := False;
    while FieldCount > 1 do
      Fields[FieldCount - 1].Free;
    for i := 0 to FMvxCmd.OutputParams.Count-1 do
    begin
      Item := FMvxCmd.OutputParams[i];
      if (SupportedFieldType(Item.DataType))
        and (CompareText(Item.Name, 'RECID') <> 0) then
      begin
        AField := DefaultFieldClasses[Item.DataType].Create(self);
        if (AField is TStringField) or (AField is TBlobField) then
          AField.Size := Item.Size;
        AField.Name := GetValidName(Self, Name + Item.Name);
        AField.Required := Item.Mandatory;
        AField.FieldName := Item.Name;
        AField.DataSet := self;      
      end;
    end;
    if Assigned(FOnPrepare) then
      FOnPrepare(Self);
  end;
end;

procedure TMvxCustomDataset.Prepare;
begin
  if not Prepared then
    FMvxCmd.Prepare;
end;

procedure TMvxCustomDataset.SetConnection(const Value: TMvxConnection);
begin
  if Connection <> Value then
  begin
    if Connection <> nil then
      Connection.UnRegisterClient(Self);
    FMvxCmd.Connection := Value;
    if Connection <> nil then
      Connection.RegisterClient(Self);
  end
end;

procedure TMvxCustomDataset.SetMICommand(const Value: string);
begin
  FMvxCmd.MICommand := Value;
end;

procedure TMvxCustomDataset.SetMIProgram(const Value: string);
begin
  FMvxCmd.MIProgram := Value; 
end;

procedure TMvxCustomConnection.UnregisterDataset(
  ADataset: TMvxCustomDataset);
begin
  ADataset.Connection := nil;
end;

end.
