program BitHesab;
{ BitHesab: Free video bitrate/file size calculator. available in both CLI and
  GUI versions.

  Copyright (C) 2019 Mohammadreza Bahrami m.audio91@gmail.com

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, uTimeCode, CommonNumeralUtils;

type

  TCalcMode = (cmCalcSize, cmCalcvBit);
  { TBitHesab }

  TBitHesab = class(TCustomApplication)
  protected
    procedure DoRun; override;
  private
    FDuration,
    FaBitrate,
    FvBitrate,
    FFileSize,
    FOverhead: Double;
    FInGigabyte: Boolean;
    FCalcMode: TCalcMode;
    procedure ParseParams; inline;
    procedure DoCalc;
    procedure Fatal(const ExceptionMsg: String);
    procedure Warn(const WarningMsg: String);
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

const
  Ver='1.0.4';
  MinFileSize=0.1;
  MaxFileSize=104857600;
  DefFileSize=700;
  MinVBit=0.1;
  MaxVBit=13560600;
  DefVBit=832;
  MinABit=0;
  MaxABit=20000;
  DefABit=96;
  MinDur=1;
  MaxDur=12747599;
  DefDur=6330;
  MinDurStr='00:00:01';
  MaxDurStr='1000:59:59';
  DefDurStr='01:45:30';

resourcestring
  rsHelp='BitHesab v%s'
  + LineEnding
  + 'A simple commandline bitrate calculator'
  + LineEnding
  + '{ video bitrate:=(file size / time) - audio bitrate }'
  + LineEnding
  + '{ file size:=(video bitrate + audio bitrate) * time }'
  + LineEnding
  + LineEnding
  + 'Compiled on %s using Free Pascal Compiler, version %s'
  + LineEnding
  + 'Copyright (c) 2015-%s Mohammadreza Bahrami, http://mohammadrezab.blogsky.com'
  + LineEnding
  + 'Source code available at https://github.com/m-audio91/BitHesab under the terms of the GNU General Public License version 3.0'
  + LineEnding
  + LineEnding
  + 'Usage with -short options: BitHesab -O1 -O2 VALUE2 -O3 VALUE3...'
  + LineEnding
  + 'Usage with --long options: BitHesab --OPTION1 --OPTION2=VALUE2 --OPTION3=VALUE3...'
  + LineEnding
  + LineEnding
  + 'OPTIONS: '
  + LineEnding
  + '-h, --help:          shows this help'
  + LineEnding
  + '-d, --duration:      <string> duration in form HH:MM:SS or H:M:S and so on. from %s to %s, default %s'
  + LineEnding
  + '-a, --abitrate:      <double> audio bitrate in kilobit/s. from %s to %s, default %s'
  + LineEnding
  + '-v, --vbitrate:      <double> video bitrate in kilobit/s. from %s to %s, default %s'
  + LineEnding
  + '-s, --filesize:      <double> file size in megabytes. or in case of -g used, in gigabytes. from %s to %s, default %s'
  + LineEnding
  + '-o, --overhead:      <double> container overhead in percent. from 0.00 to 100.00, default 0'
  + LineEnding
  + '-g, --gigabyte:      indicates that the entered file size is in gigabyte instead of default megabyte. not used by default'
  + LineEnding
  + LineEnding
  + 'example 1 (-short):'
  + LineEnding
  + '.\BitHesab.exe -d 43:30 -a 96 -s 230'
  + LineEnding
  + LineEnding
  + 'example 2 (--long):'
  + LineEnding
  + '.\BitHesab.exe --duration=43:30 --abitrate=96 --filesize=230'
  + LineEnding;
  rsWrongDur='ERROR: Wrong value entered for duration!';
  rsWrongVBit='ERROR: Wrong value entered for video bitrate!';
  rsWrongABit='ERROR: Wrong value entered for audio bitrate!';
  rsWrongOverhead='ERROR: Wrong value entered for overhead!';
  rsWrongSize='ERROR: Wrong value entered for file size!';
  rsWhatDoYouWant='ERROR: It is not clear what you want. --vbitrate and --filesize cannot be used at the same time or ommited at the same time';
  rsClipping='WARNING: Clipping occured. your result may be wrong. Option: ';

{ TBitHesab }

procedure TBitHesab.DoRun;
var
  ErrorMsg: String;
begin
  if HasOption('h','help') or (ParamCount<1) then
  begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  try
    ErrorMsg:=CheckOptions('d:a:v:s:o:ge', 'duration: abitrate: vbitrate: '
      +'filesize: overhead: gigabyte erroroutput');
    if ErrorMsg<>EmptyStr then
      Fatal(ErrorMsg);
    ParseParams;
  except
    on E: Exception do
    begin
      ErrorMsg:=E.Message;
      WriteLn(Stderr, ErrorMsg);
    end;
  end;

  if ErrorMsg<>EmptyStr then
  begin
    WriteLn(StdOut, -1);
    Terminate;
    Exit;
  end;

  DoCalc;

  Terminate;
end;

procedure TBitHesab.ParseParams;
var
  s: String;
  d: Double;
  b1,b2: Boolean;
  TC: TTimeCode;
begin
  b1:=HasOption('v', 'vbitrate');
  b2:=HasOption('s', 'filesize');
  if b1 and not b2 then
    FCalcMode:=cmCalcSize
  else if not b1 and b2 then
    FCalcMode:=cmCalcvBit
  else if b1 and b2
  or not b1 and not b2 then
    Fatal(rsWhatDoYouWant);

  if HasOption('g', 'gigabyte') then
    FInGigabyte:=True;

  if HasOption('s', 'filesize') then
  begin
    s:=GetOptionValue('s', 'filesize');
    if TryStrToFloat(s, d) then
    begin
      FFileSize:=d;
      b1:=ForceInRange(FFileSize, MinFileSize, MaxFileSize);
      if b1 then
        Warn(rsClipping+'filesize');
      FFileSize:=FFileSize*(1024*8); //in kilobit
    end
    else
      Fatal(rsWrongSize);
  end;

  if HasOption('v', 'vbitrate') then
  begin
    s:=GetOptionValue('v', 'vbitrate');
    if TryStrToFloat(s, d) then
    begin
      FvBitrate:=d;
      b1:=ForceInRange(FvBitrate, MinVBit, MaxVBit);
      if b1 then
        Warn(rsClipping+'vbitrate');
    end
    else
      Fatal(rsWrongVBit);
  end;

  if HasOption('a', 'abitrate') then
  begin
    s:=GetOptionValue('a', 'abitrate');
    if TryStrToFloat(s, d) then
    begin
      FaBitrate:=d;
      b1:=ForceInRange(FaBitrate, MinABit, MaxABit);
      if b1 then
        Warn(rsClipping+'abitrate');
    end
    else
      Fatal(rsWrongABit);
  end;

  if HasOption('o', 'overhead') then
  begin
    s:=GetOptionValue('o', 'overhead');
    if TryStrToFloat(s, d) then
    begin
      FOverhead:=d;
      b1:=ForceInRange(FOverhead, 0, 100);
      if b1 then
        Warn(rsClipping+'overhead');
    end
    else
      Fatal(rsWrongOverhead);
  end;

  if HasOption('d', 'duration') then
  begin
    s:=GetOptionValue('d', 'duration');
    TC.ValueAsString:=s;
    FDuration:=TC.ValueAsDouble;
    if FDuration=0 then
      Fatal(rsWrongDur)
    else
    begin
    b1:=ForceInRange(FDuration, MinDur, MaxDur);
      if b1 then
        Warn(rsClipping+'duration');
    end;
  end;
end;

procedure TBitHesab.DoCalc;
begin
  case FCalcMode of
  cmCalcvBit:
    begin
      FOverhead:=(FFileSize/100)*FOverhead;
      FFileSize:=FFileSize-FOverhead;
      if FInGigabyte then
        FFileSize:=FFileSize*1024;
      FvBitrate:=((FFileSize/FDuration)*1.024)-FaBitrate;
      if FvBitrate<1 then
        FvBitrate:=-1;
      WriteLn(StdOut, Round(FvBitrate));
    end;
  cmCalcSize:
    begin
      FFileSize:=(((FvBitrate+FaBitrate)*1000)*FDuration)/((1024*8)*1024);
      FOverhead:=(FFileSize/100)*FOverhead;
      FFileSize:=FFileSize + FOverhead;
      if FInGigabyte then
        FFileSize:=FFileSize/1024;
      if FFileSize<1 then
        FFileSize:=-1;
      WriteLn(StdOut, FloatRound(FFileSize,3).ToString.Replace(',','.'));
    end;
  end;
end;

procedure TBitHesab.Fatal(const ExceptionMsg: String);
begin
  raise Exception.Create(ExceptionMsg);
end;

procedure TBitHesab.Warn(const WarningMsg: String);
begin
  WriteLn(StdErr, WarningMsg);
end;

constructor TBitHesab.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
  CaseSensitiveOptions:=False;
  FDuration:=DefDur;
  FaBitrate:=DefABit;
  FvBitrate:=DefVBit;
  FFileSize:=DefFileSize;
  FOverhead:=0;
  FInGigabyte:=False;
  FCalcMode:=cmCalcvBit;
end;

destructor TBitHesab.Destroy;
begin
  inherited Destroy;
end;

procedure TBitHesab.WriteHelp;
var
  h: String;
begin
  h:=Format(rsHelp, [
  Ver,
  FormatDateTime('d mmmm yyyy', Now),
  {$i %FPCVERSION%},
  FormatDateTime('yyyy', Now),
  MinDurStr,
  MaxDurStr,
  DefDurStr,
  MinABit.ToString,
  MaxABit.ToString,
  DefABit.ToString,
  MinVBit.ToString,
  MaxVBit.ToString,
  DefVBit.ToString,
  MinFileSize.ToString,
  MaxFileSize.ToString,
  DefFileSize.ToString
  ]);
  WriteLn(Stderr, h);
end;

var
  Application: TBitHesab;

{$R *.res}

begin
  Application:=TBitHesab.Create(nil);
  Application.Title:='BitHesab';
  DefaultFormatSettings.DecimalSeparator:='.';
  Application.Run;
  Application.Free;
end.

