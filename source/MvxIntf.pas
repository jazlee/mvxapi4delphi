{******************************************************************************}
{* MvxIntf.pas                                                                *}
{* This module is part of Internal Project but is released under              *}
{* the MIT License: http://www.opensource.org/licenses/mit-license.php        *}
{* Copyright (c) 2006 by Jaimy Azle                                           *}
{* All rights reserved.                                                       *}
{******************************************************************************}
{* Desc:                                                                      *}
{******************************************************************************}
unit MvxIntf;

interface

uses
  SysUtils, Windows, Messages, Classes;

const
  MVX_SOCKET_DLL = 'MvxSock.dll';

type
  UChar     = Byte;    // 8 bit unsigned
  UShort    = Word;
  Uint      = DWORD;
  Long      = LongInt; // 32 bit signed
  ULong     = DWord;   // 32 bit unsigned
  MvxSocket = DWORD;
  wchar_u   = WORD;
  PUChar    = ^UChar;
  PULong    = ^Ulong;
  PWChar_u  = ^wchar_u;

  PMvxField = ^TMvxField;
  TMvxField = packed record
    Name:       array[0..7] of char;
    Data:       array[0..327] of char;
    Next:       PMvxField;
  end;

  PMvxFieldMap = ^TMvxFieldMap;
  TMvxFieldMap = packed record
    Name:       array[0..15] of char;
    Reserved:   array[0..7] of char;
    PMap:       PChar;
    Next:       PMvxFieldMap;
  end;

  PMvxServerID = ^TMvxServerID;
  TMvxServerID = packed record
    ServerName: array[0..31] of char;
    ServerPortNr: UShort;
    Flags: UShort;
    AppName: array[0..16] of char;
    MsgID: array[0..7] of char;
    BadField: array[0..6] of char;
    Buffer: array[0..255] of char;
    TheSocket: MvxSocket;
    CryptOn: Integer;
    CryptKey: array[0..56] of Char;
    Trim: Integer;
    NextGen: Integer;
    Token: Integer;
    PField: PChar;
    PCurTrans: PChar;
    PTrans: PChar;
    PMvxIn: PMvxFieldMap;
    PMvxOut: PMvxFieldMap;
    PMvxField: PMvxField;
    Reserved: array[0..14] of char;
  end;

  EAPICallException = Exception;

  IMvxAPILibrary = interface
  ['{480FBB21-4C1C-4CEE-80D9-CB8C545F825F}']
    function  GetLibName:string;
    procedure FreeMvxLibrary;

    function MvxSockSetup(PStruct: PMvxServerID;
                          WrapperName: PChar;
                          WrapperPort: Integer;
                          ApplicationName: PChar;
                          CryptOn: Integer;
                          CryptKey: PChar): ULong; stdcall;
    function MvxSockConfig(PStruct: PMvxServerID; ConfigFileName: PChar): ULong; stdcall;
    function MvxSockInit(PStruct: PMvxServerID;
                          ComputerName: PChar;
                          UserID: PChar;
                          UserPwd: PChar;
                          AS400Program: PChar): ULong; stdcall;
    function MvxSockConnect(PStruct: PMvxServerID;
                          Host: PChar;
                          Port: Integer;
                          UserID: PChar;
                          Pwd: PChar;
                          MI: PChar;
                          Key: PChar): ULong; stdcall;
    function MvxSockTrans(PStruct: PMvxServerID;
                          PSendBuffer: PChar;
                          PRetBuffer: PChar;
                          PRetLength: PULong): ULong; stdcall;
    function MvxSockTransW(PStruct: PMvxServerID;
                          PSendBuffer: PWChar_u;
                          PRetBuffer: PWChar_u;
                          PRetLength: PULong): ULong; stdcall;
    function MvxSockReceive(PStruct: PMvxServerID;
                          PRecvBuffer: PChar;
                          PRetLength: PULong): ULong; stdcall;
    function MvxSockReceiveW(PStruct: PMvxServerID;
                          PRecvBuffer: PWChar_u;
                          PRetLength: PULong): ULong; stdcall;
    function MvxSockSend(PStruct: PMvxServerID; PSendBuffer: PChar): ULong; stdcall;
    function MvxSockSendW(PStruct: PMvxServerID; PSendBuffer: PWChar_u): ULong; stdcall;
    function MvxSockSetMode(PStruct: PMvxServerID;
                          mode: Integer;
                          PTransName: PChar;
                          PResult: PChar;
                          PRetLength: PULong): ULong; stdcall;
    function MvxSockVersion: UShort; stdcall;
    procedure MvxSockShowLastError(PStruct: PMvxServerID; ErrText: PChar); stdcall;
    function MvxSockGetLastError(PStruct: PMvxServerID;
                          Buffer: PChar;
                          BuffSize: Integer): PChar; stdcall;
    function MvxSockGetLastMessageID(PStruct: PMvxServerID;
                          Buffer: PChar;
                          BuffSize: Integer): PChar; stdcall;
    function MvxSockGetLastBadField(PStruct: PMvxServerID;
                          Buffer: PChar;
                          BuffSize: Integer): PChar; stdcall;
    function MvxSockClose(PStruct: PMvxServerID): ULong; stdcall;
    function MvxSockChgPwd(PStruct: PMvxServerID;
                          User: PChar;
                          OldPwd: PChar;
                          NewPwd: PChar): ULong; stdcall;
    function MvxSockAccess(PStruct: PMvxServerID; Trans: PChar): ULong; stdcall;
    procedure MvxSockClearFields(PStruct: PMvxServerID); stdcall;
    function MvxSockGetField(PStruct: PMvxServerID; pszFldName: PChar): PChar; stdcall;
    function MvxSockGetFieldW(PStruct: PMvxServerID; pszFldName: PChar): PWChar_u; stdcall;
    procedure MvxSockSetField(PStruct: PMvxServerID; pszFldName, pszData: PChar); stdcall;
    procedure MvxSockSetFieldW(PStruct: PMvxServerID; pszFldName: PChar; pszData: PWChar_u); stdcall;
    function MvxSockMore(PStruct: PMvxServerID): ULong; stdcall;
//    procedure AS400ToMovexJava(PStruct: PMvxServerID); stdcall;
    function MvxSockSetMaxWait(PStruct: PMvxServerID; milli: integer): ULong; stdcall;
    function MvxSockSetBlob(PStruct: PMvxServerID; PByte: PUChar; Size: ULong): ULong; stdcall;
    function MvxSockGetBlob(PStruct: PMvxServerID; PByte: PUChar; Size: PULong): ULong; stdcall;

    property LibraryName:string read GetLibName;
  end;

{**
 * Description: Alternative way of configuring the Sockets communication
 *              where no cfg file is used. Instead the IP-adress and socket port
 *              are given as arguments.
 *
 * Argument: pointer to struct
 *           IP-adress of FPW server
 *           Socket port of FPW
 *           Application name
 *           Encryption on/off
 *           Encryption key
 *
 * Returns: 0 = OK  0 >Error.
 *
 * Remark: Application name are for logging purposes only.
 *         Call MvxSockSetup OR MvxSockConfig before opening connection
 *
 * Example call:
 *       result=MvxSockSetup(TheServerStruct, "10.20.20.238", 6000, "MyTestApp", 0, NULL);
 *
 *}

  TMvxSockSetup = function(PStruct: PMvxServerID; WrapperName: PChar;
    WrapperPort: Integer; ApplicationName: PChar; CryptOn: Integer; CryptKey: PChar): ULong; stdcall;

  {**
   * Description: Load the configuration file. In the cfg-file IP-address
   *              of the FPW server and Socket port are located.
   *
   * Argument: Pointer to PSERVER_ID struct
   *           Namepath of configuration file
   *
   * Returns: 0 = OK  0 > Error.
   *
   * Remark: Call MvxSockConfig OR MvxSockSetup before opening connection
   *
   *}
  TMvxSockConfig = function(PStruct: PMvxServerID; ConfigFileName: PChar): ULong; stdcall;


  {**
   * Initialization function for starting up the communication.
   *
   * Argument: pstruct = Pointer to PSERVER_ID structure
   *           ComputerName = LOCALA when used with standard FPW
   *           UserId = User Id
   *           UserPwd = Password
   *           AS400program = name of communication program on the AS/400 given
   *                          as "LIBRARY/PGMNAME"
   *
   * Return:   0 = OK, 0 > Error
   *
   * Remark: The function can NOT verify the user and password or the existence of the
   *         given program.
   *}
  TMvxSockInit = function(PStruct: PMvxServerID; ComputerName: PChar; UserID: PChar;
    UserPwd: PChar; AS400Program: PChar): ULong; stdcall;

  {**
   * Description: Simplified, combined setup and initiation function
   *
   * Argument: pstruct = Pointer to PSERVER_ID structure
   *           UserId = User Id on Movex application server
   *           Pwd = Password
   *           MI = name of MI program on application server given as "LIBRARY/PGMNAME" or "PGMNAME"
   *           Host = IP-adress of application server
   *           Port = Socket port of application server
   *           Key = Encryption key, if not used set it NULL
   *
   * Return:   0 = OK, 0 > Error
   *
   * Remark:
   *
   *}
  TMvxSockConnect = function(PStruct: PMvxServerID; Host: PChar; Port: Integer;
    UserID: PChar; Pwd: PChar; MI: PChar; Key: PChar): ULong; stdcall;

  {**
   * Description: The transfer function. Transfers a null terminated string
   *              to the program initiated. Layout/protocol of string should
   *              be coordinated with that program.
   *
   * Argument:   Pointer to struct
   *             Pointer to data to be sent.
   *             Pointer to return buffer
   *             Pointer to unsigned long variable to receive returned length
   *               OBS! On entry to the function it should contain the size of return buffer.
   *
   * Return:    0 = OK, 0 > Error
   *
   * Remark:    The wide chars supported are UCS-2, ie two bytes.
   *}
  TMvxSockTrans = function(PStruct: PMvxServerID; PSendBuffer: PChar;
    PRetBuffer: PChar; PRetLength: PULong): ULong; stdcall;

  TMvxSockTransW = function(PStruct: PMvxServerID; PSendBuffer: PWChar_u;
    PRetBuffer: PWChar_u; PRetLength: PULong): ULong; stdcall;

  {**
   * Description: The receive functions. Used when more than one record is to be retrieved.
   *              Repeatedly called in a loop. Break loop when OK is received.
   *
   * Argument:    Pointer to struct
   *              Pointer to return buffer
   *              Pointer to unsigned long variable to receive returned length in bytes.
   *               OBS! On entry to the function it should contain the size of return buffer.
   *
   * Return:      0 = OK, 0 > Error
   *
   * Remark:     The wide chars supported are UCS-2, ie two bytes.
   *}
  TMvxSockReceive = function(PStruct: PMvxServerID; PRecvBuffer: PChar; PRetLength: PULong): ULong; stdcall; 
  TMvxSockReceiveW = function(PStruct: PMvxServerID; PRecvBuffer: PWChar_u; PRetLength: PULong): ULong; stdcall;

  {**
   * Description: The send function. Used only with transactions beginning with the
   *              letters "Snd". The purpose is to offer a fast way to upload data.
   *              The function does not expect the MI - program to reply on the sent
   *              information. No error information can therefore be returned as well.
   *
   * Argument:    Pointer to struct
   *              Pointer to send buffer (NULL terminated)
   *              Pointer to unsigned long variable with sending length
   *
   * Return:    0 = OK, 0 > Error
   *
   * Remark:     Only certain special transactions support use of this function. You
   *             need to verify in the transaction documentation if this is the case.
   *             The wide chars supported are UCS-2, ie two bytes.
   *}
  TMvxSockSend = function(PStruct: PMvxServerID; PSendBuffer: PChar): ULong; stdcall;
  TMvxSockSendW = function(PStruct: PMvxServerID; PSendBuffer: PWChar_u): ULong; stdcall;

  {**
   *       ***************************************************************
   *       *   OBSOLETE function!!! No longer used in the Send context.  *
   *       ***************************************************************
   *
   * Description: Change mode. Currently only two modes are allowed: normal mode and
   *              multiple sending mode. The multiple sending mode should only be used
   *              when you need to upload lots of data and you get performance problems
   *              if you upload the data with MvxSockTrans().
   *              Allowed modes are: SOCKMODESEND, SOCKMODENORMAL
   *
   *}
  TMvxSockSetMode = function(PStruct: PMvxServerID; mode: Integer; PTransName: PChar; PResult: PChar;
    PRetLength: PULong): ULong; stdcall;


  {**
   * Description: Get current MvxSock version
   *
   * Argument: none
   *
   * Returns:  SHORT
   *
   * Remark: Major version in HIBYTE(v), minor in LOBYTE(v)
   *         E.g. version 1.0 gives highbyte==1, lowbyte==0
   *}
  TMvxSockVersion = function: UShort; stdcall;

  {**
   * Description: Show the last error in a message box.
   *
   * Argument: struct pointer
   *           Pointer to additional error text.
   * Returns:
   *
   * Remark:
   *
   *}
  TMvxSockShowLastError = procedure(PStruct: PMvxServerID; ErrText: PChar); stdcall;

  {**
   * Description: Returns the last error in given buffer.
   *
   * Argument: struct pointer
   *           Pointer to buffer or NULL.
   *           Size of the buffer in where to store error text.
   *
   * Returns:  Pointer to buffer if not NULL.
   *           If buffer is NULL, a pointer to internal storage is returned.
   *
   * Remark: Always returns text in ANSI/ASCII format.
   *
   *}
  TMvxSockGetLastError = function(PStruct: PMvxServerID; Buffer: PChar; BuffSize: Integer): PChar; stdcall;

  {**
   * Description: Retrieve message ID from the last NOK error.
   *
   * Argument: struct pointer
   *           Pointer to buffer or NULL.
   *           Size of the buffer in where to store text.
   *
   * Returns:  Pointer to buffer if not NULL.
   *           If buffer is NULL, a pointer to internal storage is returned.
   *
   * Remark: Always returns text in ANSI/ASCII format.
   *
   *}
  TMvxSockGetLastMessageID = function(PStruct: PMvxServerID; Buffer: PChar; BuffSize: Integer): PChar; stdcall;

  {**
   * Description: Retrieve name of the input field containing erroneous data
   *              as returned from the last NOK error.
   *
   * Argument: struct pointer
   *           Pointer to buffer or NULL.
   *           Size of the buffer in where to store text.
   *
   * Returns:  Pointer to buffer if not NULL.
   *           If buffer is NULL, a pointer to internal storage is returned.
   *
   * Remark: Always returns text in ANSI/ASCII format.
   *
   *}
  TMvxSockGetLastBadField = function(PStruct: PMvxServerID; Buffer: PChar; BuffSize: Integer): PChar; stdcall;

  {**
   * Close the conversation
   *}
  TMvxSockClose = function(PStruct: PMvxServerID): ULong; stdcall;

  {* This one is not really supported. *}
  TMvxSockChgPwd = function(PStruct: PMvxServerID; User: PChar; OldPwd: PChar; NewPwd: PChar): ULong; stdcall;

  {**
   * Description: Function to build and execute a transaction built up from field
   *              name/data pairs.
   *
   * Argument: Pointer to struct
   *           Name of transaction to execute
   *
   * Returns:    0 = OK, 0 > Error. 8 is often recoverable, the others are not.
   *
   * Remark: When called with only the struct pointer and NULL for trans name as arguments
   *         the function retrieves the next record in a Lst (multiple) transaction.
   *         The function allocates and maintain it's own memory buffers. To avoid memory
   *         leakage MvxSockClose() shall always be called to close the communication.
   *}
  TMvxSockAccess = function(PStruct: PMvxServerID; Trans: PChar): ULong; stdcall;


  {**
   * Description: Clear fields set with MvxSockSetField
   *
   * Argument: Pointer to struct
   *
   * Returns:
   *
   * Remark: Used eg. in pooling functionality. If set fields are not to be used.
   *
   *}
  TMvxSockClearFields = procedure(PStruct: PMvxServerID); stdcall;

  {**
   * Description: Get the data for a specific field.
   *
   * Argument: Pointer to struct
   *           Name of the field to return data from.
   *
   * Returns:  Pointer to an internal buffer containing data from the field.
   *           Data is null terminated and trailing blanks removed.
   *
   * Remark: This function does only work in conjunction with MvxSockAccess().
   *
   *}
  TMvxSockGetField = function(PStruct: PMvxServerID; pszFldName: PChar): PChar; stdcall;

  {**
   * Description: Get the data for a specific field.
   *
   * Argument: Pointer to struct
   *           Name of the field to return data from.
   *
   * Returns:  Pointer to an internal buffer containing Unicode data from the field.
   *           Data is null terminated and trailing blanks removed.
   *
   * Remark: This function does only work in conjunction with MvxSockAccess().
   *
   *}
  TMvxSockGetFieldW = function(PStruct: PMvxServerID; pszFldName: PChar): PWChar_u; stdcall;

  {**
   * Description: Set the data for a specific field, preparing to call MvxSockAccess.
   *
   * Argument: Pointer to struct
   *           Name of the field to return data from.
   *           Data for the named field.
   *
   * Returns:  Nothing
   *
   * Remark: This function does only work in conjunction with MvxSockAccess().
   *
   *}
  TMvxSockSetField = procedure(PStruct: PMvxServerID; pszFldName, pszData: PChar); stdcall;

  {**
   * Description: Set the data for a specific field, preparing to call MvxSockAccess.
   *
   * Argument: Pointer to struct
   *           Name of the field to return data from.
   *           Data for the named field in Unicode UCS2 encoding.
   *
   * Returns:  Nothing
   *
   * Remark: This function does only work in conjunction with MvxSockAccess().
   *
   *}
  TMvxSockSetFieldW = procedure(PStruct: PMvxServerID; pszFldName: PChar; pszData: PWChar_u); stdcall;

  {**
   * Description: Returns TRUE if there is more data to retrieve using MvxSockGetField()
   *
   * Argument: Pointer to struct
   *
   * Returns:  TRUE = more data to retreive, FALSE = no more data
   *
   * Remark: To be used in loops for "Lst" transactions
   *
   *}
  TMvxSockMore = function(PStruct: PMvxServerID): ULong; stdcall;

  {**
   * Description: Function to, from an AS400 client, enable communication towards Movex Java
   *
   * Argument: Pointer to struct
   *
   * Returns:  nothing
   *
   * Remark: This one is only available, and only needed, in an AS400 client running against
   *         Movex Java that communicates with UCS2.
   *}
//  TAS400ToMovexJava = procedure(PStruct: PMvxServerID); stdcall;

  {**
   * Description: Set Receive timeout. Max time to wait before receiving answer from Movex.
   *
   * Argument: Pointer to struct.
   *           Time to wait in milli seconds.
   *
   * Returns:  0 if OK, 7 otherwise.
   *
   * Remark: In Windows requires Winsock 2.0.
   *         Read plain text message for details.
   *         Primarily for use with Movex Java where no server side timeout exist.
   *
   *}
  TMvxSockSetMaxWait = function(PStruct: PMvxServerID; milli: integer): ULong; stdcall;

  {**
   * Description: Sends a binary large object to the server.
   *
   * Argument: Pointer to a buffer containing the blob, size of the blob.
   *
   * Returns: 0 if ok, 7 or 8 otherwise. Read plain text in Buff struct member.
   *
   * Remark: This function must be called and the blob thus sent prior to sending the application
   *         unique transaction that completes the process of setting a blob.
   *
   *}
  TMvxSockSetBlob = function(PStruct: PMvxServerID; PByte: PUChar; Size: ULong): ULong; stdcall;

  {**
   * Description: Retrieve a binary large object from the application server.
   *
   * Argument: Pointer to a byte buffer, pointer to a long receiving the size of blob.
   *
   * Returns: 0 if ok, 7 or 8 otherwise. Read plain text in Buff struct member.
   *
   * Remark: This function is to be called in two steps. The first time with a null pointer to
   *         buffer but with pointer to size storage. The client use this size indicator to allocate
   *         a memory buffer with enough size to contain the compete blob and then calls the function again.
   *         This function is to be called after an application unique transaction
   *         that, on the server side, picks up the blob and makes it available for retrieval with
   *         this function.
   *
   *}
  TMvxSockGetBlob = function(PStruct: PMvxServerID; PByte: PUChar; Size: PULong): ULong; stdcall;


  TMvxClientLibrary = class(TInterfacedObject, IMvxAPILibrary)
  private
    FLibraryHandle: THandle;
    FLibraryName:string;
  private
    FMvxSockSetup: TMvxSockSetup;
    FMvxSockConfig: TMvxSockConfig;
    FMvxSockInit: TMvxSockInit;
    FMvxSockConnect: TMvxSockConnect;
    FMvxSockTrans: TMvxSockTrans;
    FMvxSockTransW: TMvxSockTransW;
    FMvxSockReceive: TMvxSockReceive;
    FMvxSockReceiveW: TMvxSockReceiveW;
    FMvxSockSend: TMvxSockSend;
    FMvxSockSendW: TMvxSockSendW;
    FMvxSockSetMode: TMvxSockSetMode;
    FMvxSockVersion: TMvxSockVersion;
    FMvxSockShowLastError: TMvxSockShowLastError;
    FMvxSockGetLastError: TMvxSockGetLastError;
    FMvxSockGetLastMessageID: TMvxSockGetLastMessageID;
    FMvxSockGetLastBadField: TMvxSockGetLastBadField;
    FMvxSockClose: TMvxSockClose;
    FMvxSockChgPwd: TMvxSockChgPwd;
    FMvxSockAccess: TMvxSockAccess;
    FMvxSockClearFields: TMvxSockClearFields;
    FMvxSockGetField: TMvxSockGetField;
    FMvxSockGetFieldW: TMvxSockGetFieldW;
    FMvxSockSetField: TMvxSockSetField;
    FMvxSockSetFieldW: TMvxSockSetFieldW;
    FMvxSockMore: TMvxSockMore;
//    FAS400ToMovexJava: TAS400ToMovexJava;
    FMvxSockSetMaxWait: TMvxSockSetMaxWait;
    FMvxSockSetBlob: TMvxSockSetBlob;
    FMvxSockGetBlob: TMvxSockGetBlob;
  private
    function GetLibName:string;

    function MvxSockSetup(PStruct: PMvxServerID;
                          WrapperName: PChar;
                          WrapperPort: Integer;
                          ApplicationName: PChar;
                          CryptOn: Integer;
                          CryptKey: PChar): ULong; stdcall;
    function MvxSockConfig(PStruct: PMvxServerID; ConfigFileName: PChar): ULong; stdcall;
    function MvxSockInit(PStruct: PMvxServerID;
                          ComputerName: PChar;
                          UserID: PChar;
                          UserPwd: PChar;
                          AS400Program: PChar): ULong; stdcall;
    function MvxSockConnect(PStruct: PMvxServerID;
                          Host: PChar;
                          Port: Integer;
                          UserID: PChar;
                          Pwd: PChar;
                          MI: PChar;
                          Key: PChar): ULong; stdcall;
    function MvxSockTrans(PStruct: PMvxServerID;
                          PSendBuffer: PChar;
                          PRetBuffer: PChar;
                          PRetLength: PULong): ULong; stdcall;
    function MvxSockTransW(PStruct: PMvxServerID;
                          PSendBuffer: PWChar_u;
                          PRetBuffer: PWChar_u;
                          PRetLength: PULong): ULong; stdcall;
    function MvxSockReceive(PStruct: PMvxServerID;
                          PRecvBuffer: PChar;
                          PRetLength: PULong): ULong; stdcall;
    function MvxSockReceiveW(PStruct: PMvxServerID;
                          PRecvBuffer: PWChar_u;
                          PRetLength: PULong): ULong; stdcall;
    function MvxSockSend(PStruct: PMvxServerID; PSendBuffer: PChar): ULong; stdcall;
    function MvxSockSendW(PStruct: PMvxServerID; PSendBuffer: PWChar_u): ULong; stdcall;
    function MvxSockSetMode(PStruct: PMvxServerID;
                          mode: Integer;
                          PTransName: PChar;
                          PResult: PChar;
                          PRetLength: PULong): ULong; stdcall;
    function MvxSockVersion: UShort; stdcall;
    procedure MvxSockShowLastError(PStruct: PMvxServerID; ErrText: PChar); stdcall;
    function MvxSockGetLastError(PStruct: PMvxServerID;
                          Buffer: PChar;
                          BuffSize: Integer): PChar; stdcall;
    function MvxSockGetLastMessageID(PStruct: PMvxServerID;
                          Buffer: PChar;
                          BuffSize: Integer): PChar; stdcall;
    function MvxSockGetLastBadField(PStruct: PMvxServerID;
                          Buffer: PChar;
                          BuffSize: Integer): PChar; stdcall;
    function MvxSockClose(PStruct: PMvxServerID): ULong; stdcall;
    function MvxSockChgPwd(PStruct: PMvxServerID;
                          User: PChar;
                          OldPwd: PChar;
                          NewPwd: PChar): ULong; stdcall;
    function MvxSockAccess(PStruct: PMvxServerID; Trans: PChar): ULong; stdcall;
    procedure MvxSockClearFields(PStruct: PMvxServerID); stdcall;
    function MvxSockGetField(PStruct: PMvxServerID; pszFldName: PChar): PChar; stdcall;
    function MvxSockGetFieldW(PStruct: PMvxServerID; pszFldName: PChar): PWChar_u; stdcall;
    procedure MvxSockSetField(PStruct: PMvxServerID; pszFldName, pszData: PChar); stdcall;
    procedure MvxSockSetFieldW(PStruct: PMvxServerID; pszFldName: PChar; pszData: PWChar_u); stdcall;
    function MvxSockMore(PStruct: PMvxServerID): ULong; stdcall;
//    procedure AS400ToMovexJava(PStruct: PMvxServerID); stdcall;
    function MvxSockSetMaxWait(PStruct: PMvxServerID; milli: integer): ULong; stdcall;
    function MvxSockSetBlob(PStruct: PMvxServerID; PByte: PUChar; Size: ULong): ULong; stdcall;
    function MvxSockGetBlob(PStruct: PMvxServerID; PByte: PUChar; Size: PULong): ULong; stdcall;
  public
    constructor Create(const aLibName:string);
    destructor Destroy; override;
    procedure   LoadMvxLibrary;
    procedure   FreeMvxLibrary;
  end;

{ Library Initialization }



function GetClientLibrary(const aLibName:string):IMvxAPILibrary;

implementation

var
  vClientLibs:TInterfaceList;

resourcestring
  SCantFindApiProc     ='Can''t find procedure %s in %s';
  SCantLoadLibrary     ='Can''t load library %s ';
  SUnknownClientLibrary='Can''t perform operation %s. Unknown client library';

procedure InitFPU;
var
  Default8087CW: Word;
begin
  asm
    FSTCW Default8087CW
    OR Default8087CW, 0300h
    FLDCW Default8087CW
  end;
end;

function GetClientLibrary(const aLibName:string):IMvxAPILibrary;
var
  I: Integer;
begin
  for I := 0 to vClientLibs.Count - 1 do
    if IMvxAPILibrary(vClientLibs[i]).LibraryName=aLibName then
    begin
     Result:=IMvxAPILibrary(vClientLibs[i]);
     Exit;
    end;
  Result:=TMvxClientLibrary.Create(aLibName);
  vClientLibs.Add(Result)
end;  

{ TMvxClientLibrary }

constructor TMvxClientLibrary.Create(const aLibName: string);
begin
 inherited Create;
 FLibraryName:=aLibName;
 LoadMvxLibrary;
end;

destructor TMvxClientLibrary.Destroy;
begin
  FreeMvxLibrary;
end;

procedure TMvxClientLibrary.FreeMvxLibrary;
begin
  if (FLibraryHandle > HINSTANCE_ERROR) then
  begin
    FreeLibrary(FLibraryHandle);
    FLibraryHandle:=HINSTANCE_ERROR
  end;
end;

function TMvxClientLibrary.GetLibName: string;
begin
  Result:=FLibraryName
end;

procedure TMvxClientLibrary.LoadMvxLibrary;
  function TryGetProcAddr(ProcName: PChar): Pointer;
  begin
    Result := GetProcAddress(FLibraryHandle, ProcName);
  end;

  function GetProcAddr(ProcName: PChar): Pointer;
  begin
    Result := GetProcAddress(FLibraryHandle, ProcName);
    if not Assigned(Result) then
      RaiseLastOSError
  end;
begin
  FLibraryHandle := LoadLibrary(PChar(FLibraryName));
  if (FLibraryHandle > HINSTANCE_ERROR) then
  begin
    FMvxSockSetup:= GetProcAddr('MvxSockSetup');
    FMvxSockConfig:= GetProcAddr('MvxSockConfig');
    FMvxSockInit:= GetProcAddr('MvxSockInit');
    FMvxSockConnect:= GetProcAddr('MvxSockConnect');
    FMvxSockTrans:= GetProcAddr('MvxSockTrans');
    FMvxSockTransW:= GetProcAddr('MvxSockTransW');
    FMvxSockReceive:= GetProcAddr('MvxSockReceive');
    FMvxSockReceiveW:= GetProcAddr('MvxSockReceiveW');
    FMvxSockSend:= GetProcAddr('MvxSockSend');
    FMvxSockSendW:= GetProcAddr('MvxSockSendW');
    FMvxSockSetMode:= GetProcAddr('MvxSockSetMode');
    FMvxSockVersion:= GetProcAddr('MvxSockVersion');
    FMvxSockShowLastError:= GetProcAddr('MvxSockShowLastError');
    FMvxSockGetLastError:= GetProcAddr('MvxSockGetLastError');
    FMvxSockGetLastMessageID:= GetProcAddr('MvxSockGetLastMessageID');
    FMvxSockGetLastBadField:= GetProcAddr('MvxSockGetLastBadField');
    FMvxSockClose:= GetProcAddr('MvxSockClose');
    FMvxSockChgPwd:= GetProcAddr('MvxSockChgPwd');
    FMvxSockAccess:= GetProcAddr('MvxSockAccess');
    FMvxSockClearFields:= GetProcAddr('MvxSockClearFields');
    FMvxSockGetField:= GetProcAddr('MvxSockGetField');
    FMvxSockGetFieldW:= GetProcAddr('MvxSockGetFieldW');
    FMvxSockSetField:= GetProcAddr('MvxSockSetField');
    FMvxSockSetFieldW:= GetProcAddr('MvxSockSetFieldW');
    FMvxSockMore:= GetProcAddr('MvxSockMore');
//    FAS400ToMovexJava:= GetProcAddr('AS400ToMovexJava');
    FMvxSockSetMaxWait:= GetProcAddr('MvxSockSetMaxWait');
    FMvxSockSetBlob:= GetProcAddr('MvxSockSetBlob');
    FMvxSockGetBlob:= GetProcAddr('MvxSockGetBlob');
  end
  else
  begin
    // Can't load Library
    raise EAPICallException.Create(Format(SCantLoadLibrary,[FLibraryName]));
  end;
  InitFPU;
end;

function TMvxClientLibrary.MvxSockAccess(PStruct: PMvxServerID;
  Trans: PChar): ULong;
begin
  if Assigned(FMvxSockAccess) then
    Result  := FMvxSockAccess(PStruct, Trans)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockAccess', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockChgPwd(PStruct: PMvxServerID; User,
  OldPwd, NewPwd: PChar): ULong;
begin
  if Assigned(FMvxSockChgPwd) then
    Result  := FMvxSockChgPwd(PStruct, User, OldPwd, NewPwd)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockChgPwd', FLibraryName])
    );
end;

procedure TMvxClientLibrary.MvxSockClearFields(PStruct: PMvxServerID);
begin
  if Assigned(FMvxSockClearFields) then
    FMvxSockClearFields(PStruct)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockClearFields', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockClose(PStruct: PMvxServerID): ULong;
begin
  if Assigned(FMvxSockClose) then
    Result  := FMvxSockClose(PStruct)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockClose', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockConfig(PStruct: PMvxServerID;
  ConfigFileName: PChar): ULong;
begin
  if Assigned(FMvxSockConfig) then
    Result  := FMvxSockConfig(PStruct, ConfigFileName)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockConfig', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockConnect(PStruct: PMvxServerID;
  Host: PChar; Port: Integer; UserID, Pwd, MI, Key: PChar): ULong;
begin
  if Assigned(FMvxSockConnect) then
    Result  := FMvxSockConnect(PStruct, Host, Port, UserID, Pwd, MI, Key)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockConnect', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockGetBlob(PStruct: PMvxServerID;
  PByte: PUChar; Size: PULong): ULong;
begin
  if Assigned(FMvxSockGetBlob) then
    Result  := FMvxSockGetBlob(PStruct, PByte, Size)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockGetBlob', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockGetField(PStruct: PMvxServerID;
  pszFldName: PChar): PChar;
begin
  if Assigned(FMvxSockGetField) then
    Result  := FMvxSockGetField(PStruct, pszFldName)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockGetField', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockGetFieldW(PStruct: PMvxServerID;
  pszFldName: PChar): PWChar_u;
begin
  if Assigned(FMvxSockGetFieldW) then
    Result  := FMvxSockGetFieldW(PStruct, pszFldName)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockGetFieldW', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockGetLastBadField(PStruct: PMvxServerID;
  Buffer: PChar; BuffSize: Integer): PChar;
begin
  if Assigned(FMvxSockGetLastBadField) then
    Result  := FMvxSockGetLastBadField(PStruct, Buffer, BuffSize)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockGetLastBadField', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockGetLastError(PStruct: PMvxServerID;
  Buffer: PChar; BuffSize: Integer): PChar;
begin
  if Assigned(FMvxSockGetLastError) then
    Result  := FMvxSockGetLastError(PStruct, Buffer, BuffSize)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockGetLastError', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockGetLastMessageID(PStruct: PMvxServerID;
  Buffer: PChar; BuffSize: Integer): PChar;
begin
  if Assigned(FMvxSockGetLastMessageID) then
    Result  := FMvxSockGetLastMessageID(PStruct, Buffer, BuffSize)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockGetLastMessageID', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockInit(PStruct: PMvxServerID; ComputerName,
  UserID, UserPwd, AS400Program: PChar): ULong;
begin
  if Assigned(FMvxSockInit) then
    Result  := FMvxSockInit(PStruct, ComputerName, UserID, UserPwd, AS400Program)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockInit', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockMore(PStruct: PMvxServerID): ULong;
begin
  if Assigned(FMvxSockMore) then
    Result  := FMvxSockMore(PStruct)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockMore', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockReceive(PStruct: PMvxServerID;
  PRecvBuffer: PChar; PRetLength: PULong): ULong;
begin
  if Assigned(FMvxSockReceive) then
    Result  := FMvxSockReceive(PStruct, PRecvBuffer, PRetLength)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockReceive', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockReceiveW(PStruct: PMvxServerID;
  PRecvBuffer: PWChar_u; PRetLength: PULong): ULong;
begin
  if Assigned(FMvxSockReceiveW) then
    Result  := FMvxSockReceiveW(PStruct, PRecvBuffer, PRetLength)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockReceiveW', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockSend(PStruct: PMvxServerID;
  PSendBuffer: PChar): ULong;
begin
  if Assigned(FMvxSockSend) then
    Result  := FMvxSockSend(PStruct, PSendBuffer)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockSend', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockSendW(PStruct: PMvxServerID;
  PSendBuffer: PWChar_u): ULong;
begin
  if Assigned(FMvxSockSendW) then
    Result  := FMvxSockSendW(PStruct, PSendBuffer)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockSendW', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockSetBlob(PStruct: PMvxServerID;
  PByte: PUChar; Size: ULong): ULong;
begin
  if Assigned(FMvxSockSetBlob) then
    Result  := FMvxSockSetBlob(PStruct, PByte, Size)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockSetBlob', FLibraryName])
    );
end;

procedure TMvxClientLibrary.MvxSockSetField(PStruct: PMvxServerID;
  pszFldName, pszData: PChar);
begin
  if Assigned(FMvxSockSetField) then
    FMvxSockSetField(PStruct, pszFldName, pszData)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockSetField', FLibraryName])
    );
end;

procedure TMvxClientLibrary.MvxSockSetFieldW(PStruct: PMvxServerID;
  pszFldName: PChar; pszData: PWChar_u);
begin
  if Assigned(FMvxSockSetFieldW) then
    FMvxSockSetFieldW(PStruct, pszFldName, pszData)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockSetFieldW', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockSetMaxWait(PStruct: PMvxServerID;
  milli: integer): ULong;
begin
  if Assigned(FMvxSockSetMaxWait) then
    Result  := FMvxSockSetMaxWait(PStruct, milli)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockSetMaxWait', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockSetMode(PStruct: PMvxServerID;
  mode: Integer; PTransName, PResult: PChar; PRetLength: PULong): ULong;
begin
  if Assigned(FMvxSockSetMode) then
    Result  := FMvxSockSetMode(PStruct, mode, PTransName, PResult, PRetLength)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockSetMode', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockSetup(PStruct: PMvxServerID;
  WrapperName: PChar; WrapperPort: Integer; ApplicationName: PChar;
  CryptOn: Integer; CryptKey: PChar): ULong;
begin
  if Assigned(FMvxSockSetup) then
    Result  := FMvxSockSetup(PStruct, WrapperName, WrapperPort, ApplicationName, CryptOn, CryptKey)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockSetup', FLibraryName])
    );
end;

procedure TMvxClientLibrary.MvxSockShowLastError(PStruct: PMvxServerID;
  ErrText: PChar);
begin
  if Assigned(FMvxSockShowLastError) then
    FMvxSockShowLastError(PStruct, ErrText)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockShowLastError', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockTrans(PStruct: PMvxServerID; PSendBuffer,
  PRetBuffer: PChar; PRetLength: PULong): ULong;
begin
  if Assigned(FMvxSockTrans) then
    Result  := FMvxSockTrans(PStruct, PSendBuffer, PRetBuffer, PRetLength)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockTrans', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockTransW(PStruct: PMvxServerID;
  PSendBuffer, PRetBuffer: PWChar_u; PRetLength: PULong): ULong;
begin
  if Assigned(FMvxSockTransW) then
    Result  := FMvxSockTransW(PStruct, PSendBuffer, PRetBuffer, PRetLength)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockTransW', FLibraryName])
    );
end;

function TMvxClientLibrary.MvxSockVersion: UShort;
begin
  if Assigned(FMvxSockVersion) then
    Result  := FMvxSockVersion
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['MvxSockVersion', FLibraryName])
    );
end;

{
procedure TMvxClientLibrary.AS400ToMovexJava(PStruct: PMvxServerID);
begin
  if Assigned(FAS400ToMovexJava) then
    FAS400ToMovexJava(PStruct)
  else
    raise EAPICallException.Create(
      Format(SCantFindApiProc,['AS400ToMovexJava', FLibraryName])
    );
end;
}

initialization
 vClientLibs:=TInterfaceList.Create;
finalization
 vClientLibs.Free;
end.
