{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit FontImageListLCL;

{$warn 5023 off : no warning about unused units}
interface

uses
  FontImageList, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('FontImageList', @FontImageList.Register);
end;

initialization
  RegisterPackage('FontImageListLCL', @Register);
end.
