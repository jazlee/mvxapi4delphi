{----------------------------------------------------------------
Unit Name:    Compiler Directive
Creation:     06.10.2002
LastModified: 08.03.2002
Author:       Jaimy Azle <jazle@sat.net.id>
Description:
----------------------------------------------------------------}

{.$DEFINE FINAL_BUILD}
{.$DEFINE OBJECTS_ONLY}
{$DEFINE ENABLE_ASM8086}

{$IFNDEF LINUX}
  {$DEFINE MSWINDOWS}
{$ENDIF}

{$IFDEF VER120} { Delphi 4 }
  {$DEFINE D4}
{$ENDIF}

{$IFDEF VER130} { Delphi 5 }
  {$DEFINE D5}
{$ENDIF}

{$IFDEF VER140} { Delphi 6, Kylix 1, Kylix 2 }
  {$DEFINE D6}
{$ENDIF}

{$IFDEF VER150} { Delphi 7 }
  {$DEFINE D7}
{$ENDIF}

{$IFDEF VER170} { Delphi 9 }
  {$DEFINE D9}
{$ENDIF}

{$IFDEF VER180} { Delphi 10 }
  {$DEFINE D10}
{$ENDIF}

{$IFDEF D5}
  {$DEFINE DELPHI3}
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$IFDEF BCB}
    {$DEFINE CBUILDER3}
    {$DEFINE CBUILDER4}
    {$DEFINE CBUILDER5}
    {$OBJEXPORTALL ON}
  {$ENDIF}
{$ENDIF}

{$IFDEF D6}
  {$DEFINE DELPHI3}
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$DEFINE DELPHI6}
  {$IFDEF BCB}
    {$DEFINE CBUILDER3}
    {$DEFINE CBUILDER4}
    {$DEFINE CBUILDER5}
    {$DEFINE CBUILDER6}
    {$OBJEXPORTALL ON}
  {$ENDIF}
{$ENDIF}

{$IFDEF D7}
  {$DEFINE DELPHI3}
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$DEFINE DELPHI6}
  {$DEFINE DELPHI7}
  {$IFDEF BCB}
    {$DEFINE CBUILDER3}
    {$DEFINE CBUILDER4}
    {$DEFINE CBUILDER5}
    {$DEFINE CBUILDER6}
    {$DEFINE CBUILDER7}
    {$OBJEXPORTALL ON}
  {$ENDIF}
{$ENDIF}

{$IFDEF D9}
  {$DEFINE DELPHI3}
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$DEFINE DELPHI6}
  {$DEFINE DELPHI7}
  {$DEFINE DELPHI9}
  {$IFDEF BCB}
    {$DEFINE CBUILDER3}
    {$DEFINE CBUILDER4}
    {$DEFINE CBUILDER5}
    {$DEFINE CBUILDER6}
    {$DEFINE CBUILDER7}
    {$OBJEXPORTALL ON}
  {$ENDIF}
{$ENDIF}

{$IFDEF D10}
  {$DEFINE DELPHI3}
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$DEFINE DELPHI6}
  {$DEFINE DELPHI7}
  {$DEFINE DELPHI9}
  {$DEFINE DELPHI10}
  {$IFDEF BCB}
    {$DEFINE CBUILDER3}
    {$DEFINE CBUILDER4}
    {$DEFINE CBUILDER5}
    {$DEFINE CBUILDER6}
    {$DEFINE CBUILDER7}
    {$OBJEXPORTALL ON}
  {$ENDIF}
{$ENDIF}

{$DEFINE ThreadSafe}

{$IFDEF FINAL_BUILD}
{$O+,R-,C-,D-}

{$F-}    { Force Far Calls }
{$A+}    { Word Align Data }
{$U-}    { Pentium-Save FDIV }
{$K-}    { Smart Callbacks }
{$W-}    { Windows Stack Frame }


{== Runtime Errors ==}

{$S-}    { Stack Checking }
{$I+}    { I/O Checking }
{$Q-}    { Overflow Checking }


{== Syntax Options ==}

{$V-}    { Strict Var-Strings }
{$B-}    { Complete Boolean Evaluation }
{$X+}    { Extended Syntax }
{$T-}    { Typed @ Operator }
{$P+}    { Open Parameters }
{$J+}    { Writeable Typed Constants }

{== Miscellaneous Directives ==}

{$C MOVEABLE DEMANDLOAD DISCARDABLE}    { Code Segment Attribute }
{$G+}    { Delphi 1: 286 Instructions / Delphi 3 & later: Imported Data }
{$N+}    { Numeric Coprocessor }
{$Z-}    { Word Size Enumerated Types }

{$H+}    { Long String Support }


{$ENDIF}
{$M 16384,1048576}
