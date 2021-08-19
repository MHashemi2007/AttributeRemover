unit uAttributeRemover;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls;

type

  { TfrmAttributeRemover }

  TfrmAttributeRemover = class(TForm)
    btnAttributeRemover: TButton;
    cbxDrive: TComboBox;
    lblDrive: TLabel;
    pbrAttributeRemover: TProgressBar;
    procedure btnAttributeRemoverClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    AllFileAndFolders: Integer;
    RemovedAttribute: Integer;
    procedure GetDrives();
    procedure CountAllFileAndFolders(path: string);
    procedure RemoveAttributes(path: string);
  public

  end;

var
  frmAttributeRemover: TfrmAttributeRemover;

implementation

{$R *.lfm}

{ TfrmAttributeRemover }

procedure TfrmAttributeRemover.FormCreate(Sender: TObject);
begin
  with pbrAttributeRemover do
  begin
    Min := 0;
    Max := 100;
    Position := 0;
  end;
  cbxDrive.Items.Clear;
  GetDrives();
  cbxDrive.ItemIndex := 0;
end;

procedure TfrmAttributeRemover.btnAttributeRemoverClick(Sender: TObject);
begin
  btnAttributeRemover.Enabled := false;
  AllFileAndFolders := 0;
  RemovedAttribute := 0;
  CountAllFileAndFolders(cbxDrive.Text);
  with pbrAttributeRemover do
  begin
    Min := 0;
    Max := AllFileAndFolders;
    Position := 0;
  end;
  RemoveAttributes(cbxDrive.Text);
  btnAttributeRemover.Enabled := True;
end;

procedure TfrmAttributeRemover.GetDrives();
var
  i: char;
begin
  for i in ['a'..'z'] do
  begin
    if DirectoryExists(i + ':\') then
    begin
      cbxDrive.Items.Add(i + ':\');
    end;
  end;
end;

procedure TfrmAttributeRemover.CountAllFileAndFolders(path: string);
var
  Rec: TSearchRec;
begin
  path := IncludeTrailingBackslash(path);
  if FindFirst(path + '*', faAnyFile, Rec) = 0 then
  begin
    try
      repeat
        if (Rec.Name <> '.') and (Rec.Name <> '..') then
        begin
          Inc(AllFileAndFolders);
          if (Rec.Attr and faDirectory) = faDirectory then
          begin
            CountAllFileAndFolders(path + Rec.Name);
          end;
        end;
      until FindNext(Rec) <> 0;
    finally
      FindClose(Rec);
    end;
  end;
  inc(AllFileAndFolders);
  pbrAttributeRemover.Max := AllFileAndFolders;
end;

procedure TfrmAttributeRemover.RemoveAttributes(path: string);
var
  Rec: TSearchRec;
begin
  path := IncludeTrailingBackslash(path);
  if FindFirst(path + '*', faAnyFile, Rec) = 0 then
  begin
    try
      repeat
        if (Rec.Name <> '.') and (Rec.Name <> '..') then
        begin
          FileSetAttr(path + Rec.Name, Rec.Attr - faArchive - faReadOnly - faHidden - faSysFile);
          if (Rec.Attr and faDirectory) = faDirectory then
          begin
            RemoveAttributes(path + Rec.Name);
          end;
          Inc(RemovedAttribute);
          pbrAttributeRemover.Position := RemovedAttribute;
        end;
      until FindNext(Rec) <> 0;
    finally
      FindClose(Rec);
    end;
  end;
  FileSetAttr(path, Rec.Attr - faArchive - faReadOnly - faHidden - faSysFile);
  Inc(RemovedAttribute);
  pbrAttributeRemover.Position := RemovedAttribute;
end;

end.

