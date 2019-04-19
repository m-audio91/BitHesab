unit uMain;
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

interface

uses
  Classes, SysUtils, FileUtil, DividerBevel, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Spin, uUrlLabel, LCLType {$ifdef darwin},Menus{$endif};

type

  { TCalcMode }

  TCalcMode = (cmCalcSize = 1, cmCalcvBit = 2);

  { TBH }

  TBH = class(TForm)
    FileSizeBasedL: TLabel;
    AppVer: TLabel;
    MainContainer: TPanel;
    HeaderLinks: TPanel;
    HeaderLinksContainer: TPanel;
    vBitBasedL: TLabel;
    vBitUnit: TComboBox;
    Sep4: TDividerBevel;
    Calc: TButton;
    Sep3: TDividerBevel;
    FileSizeUnit: TComboBox;
    HeaderIcon: TImage;
    Overhead: TFloatSpinEdit;
    FileSize: TFloatSpinEdit;
    HeaderImg: TImage;
    HeaderTitleL: TLabel;
    aBitUnitL: TLabel;
    OverheadUnitL: TLabel;
    Sep1: TLabel;
    Sep2: TLabel;
    Header: TPanel;
    HeaderTexts: TPanel;
    aBitContainer: TPanel;
    DuratonContainer: TPanel;
    OverheadContainer: TPanel;
    TargetsContainer: TPanel;
    TargetValueContainer: TPanel;
    FileSizeValueContainer: TPanel;
    vBitValueContainer: TPanel;
    Footer: TPanel;
    FileSizeBased: TRadioButton;
    vBitBased: TRadioButton;
    aBit: TSpinEdit;
    vBit: TSpinEdit;
    DurH: TSpinEdit;
    DurM: TSpinEdit;
    DurS: TSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FileSizeBasedChange(Sender: TObject);
    procedure vBitBasedChange(Sender: TObject);
    procedure FileSizeUnitChange(Sender: TObject);
    procedure vBitUnitChange(Sender: TObject);
    procedure CalcClick(Sender: TObject);
  private
    {$ifdef darwin}
    MainMenu: TMainMenu;
    AppMenu: TMenuItem;
    {$endif}
    FAuthorUrl,FIssuesUrl,FLicenseUrl: TUrlLabelEx;
    FLangUrl: TCustomUrlLabel;
    FEnglishUI: Boolean;
    FMode: TCalcMode;
    function DoCalc(Dur, AB, OH, FSUnit, FS, VBUnit, VB: Double;
      CalcMode: TCalcMode): Double;
    procedure LangUrlClick(Sender: TObject);
    procedure ChangeLang;
    procedure SetFormWidth;
  published
    property EnglishUI: Boolean read FEnglishUI write FEnglishUI;
  end;

resourcestring
  Issues = 'پشتیبانی و گزارش خطا';
  IssuesUrl = 'https://github.com/m-audio91/BitHesab/issues';
  Author = 'خانه';
  AuthorUrl ='http://mohammadrezab.blogsky.com';
  LicenseVer = 'GPLv3';
  LicenseUrl = 'https://www.gnu.org/licenses/gpl-3.0.en.html';
  LEng = 'English';
  LPer = 'فارسی';
  engCalc = 'Calculate';
  engDuratonContainer = 'Duration';
  engaBitContainer = 'Audio Bitrate(s)';
  engvBitBased = 'Video Bitrate';
  engOverheadContainer = 'Container Overhead';
  engFileSizeBased = 'File Size';
  engHeaderTitle = 'BitHesab - Calculate bitrate and file size before conversion';
  engAuthor = 'Home Page';
  engIssues = 'Support and Issue Reporting';
  perCalc = 'محاسبه کن';
  perDuratonContainer = 'مدت زمان';
  peraBitContainer = 'نرخ بیت صدا(ها)';
  pervBitBased = 'نرخ بیت تصویر';
  perOverheadContainer = 'میزان اضافه حجم حامل';
  perFileSizeBased = 'حجم فایل خروجی';
  perHeaderTitle = 'بیت حساب - محاسبه گر نرخ بیت و حجم فایل خروجی قبل از تبدیل';

var
  BH: TBH;

implementation

{$R *.lfm}

{ TBH }

procedure TBH.FormCreate(Sender: TObject);
begin
  {$ifdef darwin}
    MainMenu := TMainMenu.Create(Self);
    MainMenu.Parent := Self;
    AppMenu := TMenuItem.Create(Self);
    AppMenu.Caption := #$EF#$A3#$BF;
    MainMenu.Items.Insert(0, AppMenu);
  {$endif}
  FAuthorUrl := TUrlLabelEx.Create(Self);
  with FAuthorUrl do
  begin
    Parent := HeaderLinks;
    Caption := Author;
    Hint := Author;
    URL := AuthorUrl;
    Font.Color := $0086C6E4;
    Alignment := taRightJustify;
  end;
  FIssuesUrl := TUrlLabelEx.Create(Self);
  with FIssuesUrl do
  begin
    Parent := HeaderLinks;
    Caption := Issues;
    Hint := Issues;
    URL := IssuesUrl;
    Font.Color := $0086C6E4;
    Alignment := taRightJustify;
  end;
  FLicenseUrl := TUrlLabelEx.Create(Self);
  with FLicenseUrl do
  begin
    Parent := Footer;
    Caption := LicenseVer;
    URL := LicenseUrl;
    HighlightColor := $0086C6E4;
  end;
  FLangUrl := TCustomUrlLabel.Create(Self);
  with FLangUrl do
  begin
    Parent := Footer;
    Caption := LEng;
    HighlightColor := $0086C6E4;
    OnClick := @LangUrlClick;
  end;
  FEnglishUI := False;
  FMode := cmCalcvBit;
end;

procedure TBH.FormShow(Sender: TObject);
begin
  SetFormWidth;
  {$ifdef linux}
  MainContainer.Color := clForm;
  {$endif}
end;

procedure TBH.SetFormWidth;
begin
  Constraints.MinWidth := Round(HeaderTitleL.Width+HeaderIcon.Width*1.5);
end;

procedure TBH.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) then
    CalcClick(Calc);
end;

procedure TBH.FileSizeBasedChange(Sender: TObject);
begin
  with FileSizeValueContainer do
  begin
    Enabled := FileSizeBased.State = cbChecked;
    if Enabled then
      FMode := cmCalcvBit;
  end;
  CalcClick(Calc);
end;

procedure TBH.vBitBasedChange(Sender: TObject);
begin
  with vBitValueContainer do
  begin
    Enabled := vBitBased.State = cbChecked;
    if Enabled then
      FMode := cmCalcSize;
  end;
  CalcClick(Calc);
end;

procedure TBH.FileSizeUnitChange(Sender: TObject);
const
  MAXVAL = 1048576;
begin
  case FileSizeUnit.ItemIndex of
  0: begin
    FileSize.MaxValue := MAXVAL;
    FileSize.Value := FileSize.Value * 1024;
    end;
  1: begin
    FileSize.MaxValue := MAXVAL div 1024;
    if FileSize.Value > 2 then
      FileSize.Value := FileSize.Value / 1024;
    end;
  end;
  CalcClick(Calc);
end;

procedure TBH.vBitUnitChange(Sender: TObject);
const
  MAXVAL = 135606;
begin
  case vBitUnit.ItemIndex of
  0: begin
    vBit.MaxValue := MAXVAL;
    vBit.Value := vBit.Value * 1000;
    end;
  1: begin
    vBit.MaxValue := MAXVAL / 1000;
    vBit.Value := vBit.Value / 1000;
    end;
  end;
  CalcClick(Calc);
end;

function TBH.DoCalc(Dur, AB, OH, FSUnit, FS, VBUnit, VB: Double;
  CalcMode: TCalcMode): Double;
begin
  case CalcMode of
  cmCalcvBit:
    begin
      try
        FS := FS * (1024*8); //in kilobit
        OH := (FS/100) * OH;
        FS := FS - OH;
        if FSUnit = 1 then
          FS := FS*1024;
        VB := ((FS / Dur)*1.024) - AB;
        if VBUnit = 1 then
          VB := VB/1000;
        Result:= VB;
      except
        Result := 1;
      end;
    end;
  cmCalcSize:
    begin
      try
        if VBUnit = 1 then
          VB := VB*1000;
        FS := (((VB + AB)*1000) * Dur) / ((1024*8)*1024);
        OH := (FS/100) * OH;
        FS := FS + OH;
        if FSUnit = 1 then
          FS := FS/1024;
        Result := FS;
      except
        Result := 1;
      end;
    end;
  end;
end;

procedure TBH.CalcClick(Sender: TObject);
var
  Val: Double;
begin
  Val := DoCalc(
    ((DurH.Value*3600) + (DurM.Value*60) + DurS.Value),
    aBit.Value,
    Overhead.Value,
    FileSizeUnit.ItemIndex,
    FileSize.Value,
    vBitUnit.ItemIndex,
    vBit.Value,
    FMode
  );
  case FMode of
  cmCalcSize: FileSize.Value := Val;
  cmCalcvBit: vBit.Value := Round(Val);
  end;
end;

procedure TBH.LangUrlClick(Sender: TObject);
begin
  FEnglishUI := False = FEnglishUI;
  ChangeLang;
end;

procedure TBH.ChangeLang;
begin
  if EnglishUI then
  begin
    Calc.Caption := engCalc;
    DuratonContainer.Caption := engDuratonContainer;
    aBitContainer.Caption := engaBitContainer;
    vBitBasedL.Caption := engvBitBased;
    OverheadContainer.Caption := engOverheadContainer;
    FileSizeBasedL.Caption := engFileSizeBased;
    HeaderTitleL.Caption := engHeaderTitle;
    FAuthorUrl.Caption := engAuthor;
    FIssuesUrl.Caption := engIssues;
    FLangUrl.Caption := LPer;
  end
  else
  begin
    Calc.Caption := perCalc;
    DuratonContainer.Caption := perDuratonContainer;
    aBitContainer.Caption := peraBitContainer;
    vBitBasedL.Caption := pervBitBased;
    OverheadContainer.Caption := perOverheadContainer;
    FileSizeBasedL.Caption := perFileSizeBased;
    HeaderTitleL.Caption := perHeaderTitle;
    FAuthorUrl.Caption := Author;
    FIssuesUrl.Caption := Issues;
    FLangUrl.Caption := LEng;
  end;
  SetFormWidth;
end;

end.

