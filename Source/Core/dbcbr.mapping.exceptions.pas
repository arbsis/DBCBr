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
}

unit dbcbr.mapping.exceptions;

interface

uses
  System.SysUtils,
  System.Rtti;

type
  EClassNotRegistered = class(Exception)
  public
    constructor Create(AClass: TClass);
  end;

  EFieldNotNull = class(Exception)
  public
    constructor Create(const ADisplayLabel: String);
  end;

  EFieldValidate = class(Exception)
  public
    constructor Create(const AField: String; const AMensagem: String);
  end;

  EMinimumValueConstraint = class(Exception)
  public
    constructor Create(const ADisplayLabel: String;
      const AValue: Double);
  end;

  EMaximumValueConstraint = class(Exception)
  public
    constructor Create(const ADisplayLabel: String; const AValue: Double);
  end;

  ENotEmptyConstraint = class(Exception)
  public
    constructor Create(const ADisplayLabel: String);
  end;

  EMaxLengthConstraint = class(Exception)
  public
    constructor Create(const ADisplayLabel: String; const MaxLength: Integer);
  end;

  EMinLengthConstraint = class(Exception)
  public
    constructor Create(const ADisplayLabel: String; const MinLength: Integer);
  end;

  EDefaultExpression = class(Exception)
  public
    constructor Create(const ADefault, AColumnName, AClassName: String);
  end;

implementation

uses
  dbcbr.mapping.attributes;

{ EClassNotRegistered }

constructor EClassNotRegistered.Create(AClass: TClass);
begin
   inherited CreateFmt('Classe %s não registrada. Registre no Initialization usando TRegisterClasses.GetInstance.RegisterClass(%s)',
                       [AClass.ClassName]);
end;

{ EFieldNotNull }

constructor EFieldNotNull.Create(const ADisplayLabel: String);
begin
  inherited CreateFmt('Campo [ %s ] não pode ser vazio',
                      [ADisplayLabel]);
end;

{ EHighestConstraint }

constructor EMinimumValueConstraint.Create(const ADisplayLabel: String;
  const AValue: Double);
begin
  inherited CreateFmt('O valor mínimo do campo [ %s ] permitido é [ %s ]!',
                      [ADisplayLabel, FloatToStr(AValue)]);
end;

{ EFieldValidate }

constructor EFieldValidate.Create(const AField: String; const AMensagem: String);
begin
  inherited CreateFmt('[ %s ] %s',
                      [AField, AMensagem]);
end;

{ EDefaultExpression }

constructor EDefaultExpression.Create(const ADefault, AColumnName, AClassName: String);
begin
  inherited CreateFmt('O valor Default [ %s ] do campo [ %s ] na classe [ %s ], é inválido!',
                      [ADefault, AColumnName, AClassName]);
end;

{ EMaximumValueConstraint }

constructor EMaximumValueConstraint.Create(const ADisplayLabel: String; const AValue: Double);
begin
  inherited CreateFmt('O valor máximo do campo [ %s ] permitido é [ %s ]!',
                      [ADisplayLabel, FloatToStr(AValue)]);
end;

{ ENotEmptyConstraint }

constructor ENotEmptyConstraint.Create(const ADisplayLabel: String);
begin
  inherited CreateFmt('O campo [ %s ] não pode ser vazio!', [ADisplayLabel]);
end;

{ EMaxLengthConstraint }

constructor EMaxLengthConstraint.Create(const ADisplayLabel: String; const MaxLength: Integer);
begin
  inherited CreateFmt('O campo [ %s ] não pode ter o tamanho maior que %s!', [ADisplayLabel, IntToStr(MaxLength)]);
end;

{ EMinLengthConstraint }

constructor EMinLengthConstraint.Create(const ADisplayLabel: String; const MinLength: Integer);
begin
  inherited CreateFmt('O campo [ %s ] não pode ter o tamanho menor que %s!', [ADisplayLabel, IntToStr(MinLength)]);
end;

end.
