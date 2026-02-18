{
      ORM Brasil é um ORM simples e descomplicado para quem utiliza Delphi

                   Copyright (c) 2016, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Versão 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos é permitido copiar e distribuir cópias deste documento de
       licença, mas mudá-lo não é permitido.

       Esta versão da GNU Lesser General Public License incorpora
       os termos e condições da versão 3 da GNU General Public License
       Licença, complementado pelas permissões adicionais listadas no
       arquivo LICENSE na pasta principal.
}

{ @abstract(ORMBr Framework.)
  @created(20 Jul 2016)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Skype : ispinheiro)

  ORM Brasil é um ORM simples e descomplicado para quem utiliza Delphi.
}

unit dbcbr.metadata.register;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  dbcbr.metadata.extract,
  dbebr.factory.interfaces;

type
  TMetadataRegister = class
  private
  class var
    FInstance: TMetadataRegister;
  private
    FDriver: TDictionary<TDriverName, TCatalogMetadataAbstract>;
    constructor CreatePrivate;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    class function GetInstance: TMetadataRegister;
    procedure RegisterMetadata(const ADriverName: TDriverName; const ACatalogMetadata: TCatalogMetadataAbstract);
    function GetMetadata(const ADriverName: TDriverName): TCatalogMetadataAbstract;
  end;

implementation

constructor TMetadataRegister.Create;
begin
  raise Exception.Create('Para usar o MetadataRegister use o método TMetadataRegister.GetInstance()');
end;

constructor TMetadataRegister.CreatePrivate;
begin
  FDriver := TObjectDictionary<TDriverName, TCatalogMetadataAbstract>.Create([doOwnsValues]);
end;

destructor TMetadataRegister.Destroy;
begin
  FDriver.Free;
  inherited;
end;

class function TMetadataRegister.GetInstance: TMetadataRegister;
begin
   if not Assigned(FInstance) then
      FInstance := TMetadataRegister.CreatePrivate;

   Result := FInstance;
end;

function TMetadataRegister.GetMetadata(const ADriverName: TDriverName): TCatalogMetadataAbstract;
begin
  if not FDriver.ContainsKey(ADriverName) then
    raise Exception.Create('O driver ' + TStrDriverName[ADriverName] + ' não está registrado, adicione a unit "ormbr.metadata.???.pas" onde ??? nome do driver, na cláusula USES do seu projeto!');

  Result := FDriver[ADriverName];
end;

procedure TMetadataRegister.RegisterMetadata(const ADriverName: TDriverName; const ACatalogMetadata: TCatalogMetadataAbstract);
begin
  FDriver.AddOrSetValue(ADriverName, ACatalogMetadata);
end;

initialization

finalization
   if Assigned(TMetadataRegister.FInstance) then
     TMetadataRegister.FInstance.Free;

end.

