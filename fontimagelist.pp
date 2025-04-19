(*
    FontImageList - TImageList for use with codepoints of fonts.
    Copyright (c) 2025 Humberto Teófilo, All Rights Reserved.
    Licensed under Modified LGPL.

    TERMS

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Library General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at your
    option) any later version with the following modification:

    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent modules,and
    to copy and distribute the resulting executable under terms of your choice,
    provided that you also meet, for each linked independent module, the terms
    and conditions of the license of that module. An independent module is a
    module which is not derived from or based on this library. If you modify
    this library, you may extend this exception to your version of the library,
    but you are not obligated to do so. If you do not wish to do so, delete this
    exception statement from your version.

    This program is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
    for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; if not, write to the Free Software Foundation,
    Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*)
unit FontImageList;

(*
    1.1.1 - First public release.
*)

{$MODE OBJFPC}
{$MACRO ON}
{$H+}
{.$DEFINE FONTIMGLIST_FORCE_RUNTIME_BUILD_ICONS}
{.$DEFINE USE_BGRABITMAP_DRAWER}

interface
uses
  Classes, SysUtils, Types,
{$IFDEF USE_BGRABITMAP_DRAWER}
  BGRABitmap, BGRABitmapTypes,
{$ENDIF}
  Graphics, Controls, Forms;

type
  EFontImageList = Exception;
  EFontNotFound  = EFontImageList;
  ECodepointIcon = EFontImageList;
  TCustomFontImageList = class;

  TFontImageListOptions = class(TPersistent)
  private
    FImageList  : TCustomFontImageList;
    FBgColor    : TColor;
    FXOffset    ,
    FYOffset    : Integer;
    procedure   SetBgColor(const AValue: TColor);
    procedure   SetXOffset(const AValue: Integer);
    procedure   SetYOffset(const AValue: Integer);
  protected
    procedure   DoChangedAnyOption(); virtual;
    procedure   AssignTo(Dest: TPersistent); override;
    function    GetOwner(): TPersistent; override;
  public
    constructor Create(AOwner: TCustomFontImageList);
  published
    property    BackgroundColor: TColor read FBgColor write SetBgColor default clNone;
    property    XOffset: Integer read FXOffset write SetXOffset default 0;
    property    YOffset: Integer read FYOffset write SetYOffset default 0;
  end;

  TCustomFontImageList = class(TImageList)
  protected
    function    CanBuildIcons(): Boolean; virtual;
    function    NewCodepoints(): TStrings; virtual;
    function    NewOptions(): TFontImageListOptions;
    procedure   SetCodepoints(AValue: TStrings); virtual;
    procedure   SetFontSource(AValue: TFont); virtual;
    procedure   SetOptions(const AValue: TFontImageListOptions); virtual;
    procedure   DoUpdateCodepoints(); virtual;
    function    DoGenerateCanvasGlyph(const AIndex: Integer; const AFontColor, ABgColor: TColor; AClearBg: Boolean): TCustomBitmap; virtual;
{$IFDEF USE_BGRABITMAP_DRAWER}
    function    DoGenerateBGRABitmapGlyph(const AIndex: Integer; const AFontColor,
                                          ABgColor: TColor; AClearBg: Boolean): TBGRABitmap; virtual;
{$ENDIF}
  private
    FCodepoints : TStrings;
    FFontSource : TFont;
    FOptions    : TFontImageListOptions;
{$IFDEF USE_BGRABITMAP_DRAWER}
    procedure   DoUpdateCodepointsBGRABitmaps();
{$ENDIF}
    procedure   DoUpdateCodepointsCanvas();
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy(); override;
  published
    property    Options: TFontImageListOptions read FOptions write SetOptions;
    property    FontSource: TFont read FFontSource write SetFontSource;
    property    Codepoints: TStrings read FCodepoints write SetCodepoints;
  end;

  TFontImageList = class(TCustomFontImageList);

  procedure register;

resourcestring
  RS_CANNOT_GEN_ICON_FOR_ITM = 'Cannot generate icons. Wrong codepoint "%" at item: %d.';
  RS_FONT_NOT_FOUND = 'The font "%s" is not installed on this computer.';

implementation
uses
  LCLType, LCLIntf, LazUTF8, LResources,
  GraphUtil, IntfGraphics, FPimage, fpCanvas, LazCanvas;

procedure register;
begin
  RegisterComponents('Misc', [TFontImageList]);
end;

(*
    TFontImageListOptions
*)

(*
    PRIVATE
*)

procedure TFontImageListOptions.SetBgColor(const AValue: TColor);
begin
  if (FBgColor = AValue) then
    Exit;

  FBgColor := AValue;
  DoChangedAnyOption();
end;

procedure TFontImageListOptions.SetXOffset(const AValue: Integer);
begin
  if (FXOffset = AValue) then
    Exit;

  FXOffset := AValue;
  DoChangedAnyOption();
end;

procedure TFontImageListOptions.SetYOffset(const AValue: Integer);
begin
  if (FYOffset = AValue) then
    Exit;

  FYOffset := AValue;
  DoChangedAnyOption();
end;


(*
    PROTECTED
*)
procedure TFontImageListOptions.DoChangedAnyOption();
begin
 // if Assigned(FImageList) and FImageList.CanBuildIcons() then
 //   FImageList.DoUpdateCodepoints();
end;

procedure TFontImageListOptions.AssignTo(Dest: TPersistent);
var
  LDest: TFontImageListOptions absolute Dest;
begin
  if (Dest is TFontImageListOptions) then
    begin
      LDest.BackgroundColor := BackgroundColor;
      LDest.XOffset := XOffset;
      LDest.YOffset := YOffset;
    end
  else
    inherited AssignTo(Dest);
end;

function TFontImageListOptions.GetOwner(): TPersistent;
begin
  Result := FImageList;
end;

(*
    PUBLIC
*)
constructor TFontImageListOptions.Create(AOwner: TCustomFontImageList);
begin
  inherited  Create();
  FImageList := AOwner;
  FBgColor   := clNone;
  FXOffset   := 0;
  FYOffset   := 0;
end;

(*
    TCustomFontImageList
*)

(*
    PROTECTED
*)

function TCustomFontImageList.CanBuildIcons(): Boolean;
begin
{$IFDEF FONTIMGLIST_FORCE_RUNTIME_BUILD_ICONS}
  Result := True;
{$ELSE}
  Result := (csDesigning in Self.ComponentState);
{$ENDIF}
end;

function TCustomFontImageList.NewOptions(): TFontImageListOptions;
begin
  Result := TFontImageListOptions.Create(Self);
end;

function TCustomFontImageList.NewCodepoints(): TStrings;
begin
  Result := TStringList.Create();
end;

procedure TCustomFontImageList.SetCodepoints(AValue: TStrings);
begin
  if (AValue <> FCodepoints) then
    begin
      FCodepoints.Assign(AValue);
      if not (csLoading in ComponentState) then
        DoUpdateCodepoints();
    end;
end;

procedure TCustomFontImageList.SetFontSource(AValue: TFont);
begin
  if Assigned(AValue) then
    begin
      FFontSource.Assign(AValue);
      if not (csLoading in ComponentState) then
        DoUpdateCodepoints();
    end;
end;

procedure TCustomFontImageList.SetOptions(const AValue: TFontImageListOptions);
begin
  FOptions.Assign(AValue);
  if not (csLoading in ComponentState) then
    DoUpdateCodepoints();
end;

procedure TCustomFontImageList.DoUpdateCodepoints();
begin
  if not Self.CanBuildIcons() then
    Exit;

  if (Screen.Fonts.IndexOf(FFontSource.Name) = -1) then
    raise EFontNotFound.Create(Format(RS_FONT_NOT_FOUND, [FFontSource.Name]));

  Self.Clear();
  if (FCodepoints.Count = 0) then
    Exit;
{$IFDEF USE_BGRABITMAP_DRAWER}
  DoUpdateCodepointsBGRABitmaps();
{$ELSE}
  DoUpdateCodepointsCanvas();
{$ENDIF}
end;

function TCustomFontImageList.DoGenerateCanvasGlyph(const AIndex: Integer; const AFontColor,
  ABgColor: TColor; AClearBg: Boolean): TCustomBitmap;
var
{$IFDEF WINDOWS}
  LGlyph: UnicodeChar;
{$ELSE}
  LGlyph: String;
{$ENDIF}
  LBgCol: TColor;
  LItem : String;
  Png   : TPortableNetworkGraphic;
begin
  Result := nil;

  LItem := FCodepoints.Strings[AIndex];
  if (LItem = '') then
    Exit;

  if not LItem.StartsWith('$') then
    LItem := '$' + LItem;

  try
  (*
      NOTES:

      On windows must be written with UnicodeChar to force the compiler choose the unicode
      method for TextOut(using api for TextOutW()).
  *)
  {$IFDEF WINDOWS}
    LGlyph := UnicodeChar(StrToInt(LItem));
  {$ELSE}
    LGlyph := UnicodeToUTF8(StrToInt(LItem));
  {$ENDIF}
  except
    raise EFontImageList.Create(Format(RS_CANNOT_GEN_ICON_FOR_ITM, [LItem, AIndex]));
  end;

  Png := TPortableNetworkGraphic.Create();
  try
    Png.PixelFormat := pf24bit;
    Png.SetSize(Self.Width, Self.Height);
    GraphUtil.GetShadowColor(FFontSource.Color);
    if (AClearBg) then
      begin
        LBgCol := ColorAdjustLuma(FFontSource.Color, 10, False);
        Png.TransparentColor := LBgCol;
        Png.Transparent := True;
        Png.Canvas.Brush.Color := LBgCol;
        Png.Canvas.FillRect(Rect(0, 0, Self.Width, Self.Height));
      end
    else
      begin
        Png.Canvas.Brush.Color := ABgColor;
        Png.Canvas.FillRect(Rect(0, 0, Self.Width, Self.Height));
      end;

    Png.Canvas.Font := FFontSource;
    Png.Canvas.Brush.Style := bsClear;
    Png.Canvas.TextOut(FOptions.XOffset, FOptions.YOffset, LGlyph);
  finally
    Result := Png;
  end;
end;

{$IFDEF USE_BGRABITMAP_DRAWER}
function TCustomFontImageList.DoGenerateBGRABitmapGlyph(const AIndex: Integer; const AFontColor,
  ABgColor: TColor; AClearBg: Boolean): TBGRABitmap;

  procedure BgClear(const ABitmap: TBGRABitmap);
  var
    b: TUniversalBrush;
  begin
    ABitmap.EraseBrush(b, 65535);
    ABitmap.Fill(b);
  end;

  function GetColor(const AColor: TColor): TBGRAPixel;
  begin
    Result.FromColor(AColor);
  end;

  procedure PutFont(const ABitmap: TBGRABitmap; var AFont: TFont);
  begin
    ABitmap.FontStyle  := AFont.Style;
    ABitmap.FontName   := AFont.Name;
    ABitmap.FontHeight := AFont.Height;
    ABitmap.FontQuality:=fqFineAntialiasing;
  end;

var
  LItem ,
  LGlyph: String;
  Bmp   : TBGRABitmap;
begin
  Result := nil;

  LItem := FCodepoints.Strings[AIndex];
  if (LItem = '') then
    Exit;

  if not LItem.StartsWith('$') then
    LItem := '$' + LItem;

  try
    LGlyph := UnicodeToUTF8(StrToInt(LItem));
  except
    raise EFontImageList.Create(Format(RS_CANNOT_GEN_ICON_FOR_ITM, [LItem, AIndex]));
  end;

  Bmp :=  TBGRABitmap.Create(Self.Width, Self.Height);
  try
    if (AClearBg) then
      BgClear(Bmp)
    else
      Bmp.Fill(GetColor(ABgColor));

    PutFont(Bmp, FFontSource);
    Bmp.TextOut(FOptions.XOffset, FOptions.YOffset, LGlyph, AFontColor);
  finally
    Result := Bmp;
  end;
end;
{$ENDIF}


(*
    PRIVATE
*)
{$IFDEF USE_BGRABITMAP_DRAWER}
procedure TCustomFontImageList.DoUpdateCodepointsBGRABitmaps();
var
  I   : Integer;
  LBmp: TBGRABitmap;
begin
  Self.BeginUpdate;
  try
    for I := 0 to FCodepoints.Count -1 do
      begin
        LBmp := Self.DoGenerateBGRABitmapGlyph(I, FFontSource.Color, FOptions.BackgroundColor,
                                               (FOptions.BackgroundColor=clNone));
        if (LBmp <> nil) then
          begin
            Self.Add(LBmp.Bitmap, nil);
            FreeAndNil(LBmp);
          end;
      end;
  finally
    Self.EndUpdate;
  end;
end;
{$ENDIF}

procedure TCustomFontImageList.DoUpdateCodepointsCanvas();
var
  I   : Integer;
  LBmp: TCustomBitmap;
begin
  Self.BeginUpdate;
  try
    for I := 0 to FCodepoints.Count -1 do
      begin
        LBmp := Self.DoGenerateCanvasGlyph(I, FFontSource.Color, FOptions.BackgroundColor,
                                           (FOptions.BackgroundColor=clNone));
        if (LBmp <> nil) then
          begin
            Self.Add(LBmp, nil);
            FreeAndNil(LBmp);
          end;
      end;
  finally
    Self.EndUpdate;
  end;
end;

(*
    PUBLIC
*)

constructor TCustomFontImageList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions    := Self.NewOptions();
  FCodepoints := Self.NewCodepoints();
  FFontSource := TFont.Create();
end;

destructor TCustomFontImageList.Destroy();
begin
  FOptions.Destroy;
  FCodepoints.Destroy;
  FFontSource.Destroy;
  inherited Destroy;
end;

initialization
  {$I fontimagelist.lrs}
end.
