{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit libsql_design;

interface

uses
  sqlcomponents, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('sqlcomponents', @sqlcomponents.Register);
end;

initialization
  RegisterPackage('libsql_design', @Register);
end.
