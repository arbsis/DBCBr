{
      ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi

                   Copyright (c) 2016, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Vers�o 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos � permitido copiar e distribuir c�pias deste documento de
       licen�a, mas mud�-lo n�o � permitido.

       Esta vers�o da GNU Lesser General Public License incorpora
       os termos e condi��es da vers�o 3 da GNU General Public License
       Licen�a, complementado pelas permiss�es adicionais listadas no
       arquivo LICENSE na pasta principal.
}

{ @abstract(ORMBr Framework.)
  @created(12 Out 2016)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Skype : ispinheiro)

  ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi.
}

unit dbcbr.ddl.generator.firebird;

interface

uses
  SysUtils,
  StrUtils,
  Generics.Collections,
  dbebr.factory.interfaces,
  dbcbr.ddl.register,
  dbcbr.ddl.generator,
  dbcbr.database.mapping;

type
  TDDLSQLGeneratorFirebird = class(TDDLSQLGenerator)
  protected
    function BuilderAlterFieldDefinition(AColumn: TColumnMIK): String; override;
  public
    function GenerateCreateTable(ATable: TTableMIK): String; override;
    function GenerateCreateSequence(ASequence: TSequenceMIK): String; override;
    function GenerateCreateForeignKey(AForeignKey: TForeignKeyMIK): String; override;
    function GenerateDropSequence(ASequence: TSequenceMIK): String; override;
    function GenerateDropIndexe(AIndexe: TIndexeKeyMIK): String; override;
    function GenerateDropColumn(AColumn: TColumnMIK): String; override;
    function GenerateEnableForeignKeys(AEnable: Boolean): String; override;
    function GenerateEnableTriggers(AEnable: Boolean): String; override;
    function GenerateAlterColumn(AColumn: TColumnMIK): String; override;
    function GenerateAlterColumnPosition(AColumn: TColumnMIK): String; override;
    function GenerateAlterDefaultValue(AColumn: TColumnMIK): String; override;
    function GenerateDropDefaultValue(AColumn: TColumnMIK): String; override;
    function GenerateCreateView(AView: TViewMIK): String; override;
  end;

implementation

{ TDDLSQLGeneratorFirebird }

function TDDLSQLGeneratorFirebird.GenerateAlterDefaultValue(AColumn: TColumnMIK): String;
begin
  Result := 'ALTER TABLE %s ALTER COLUMN %s SET DEFAULT %s;';
  Result := Format(Result, [AColumn.Table.Name,
                            AColumn.Name,
                            GetAlterFieldDefaultDefinition(AColumn)]);
end;

function TDDLSQLGeneratorFirebird.GenerateCreateForeignKey(AForeignKey: TForeignKeyMIK): String;
begin
  Result := 'ALTER TABLE %s ADD CONSTRAINT %s FOREIGN KEY (%s) REFERENCES %s(%s) %s %s;';

  Result := Format(Result, [AForeignKey.Table.Name,
                            AForeignKey.Name,
                            GetForeignKeyFromColumnsDefinition(AForeignKey),
                            AForeignKey.FromTable,
                            GetForeignKeyToColumnsDefinition(AForeignKey),
                            GetRuleDeleteActionDefinition(AForeignKey.OnDelete),
                            GetRuleUpdateActionDefinition(AForeignKey.OnUpdate)]);
end;

function TDDLSQLGeneratorFirebird.GenerateCreateSequence(ASequence: TSequenceMIK): String;
begin
  Result := 'CREATE GENERATOR %s;';
  Result := Format(Result, [ASequence.Name]);
end;

function TDDLSQLGeneratorFirebird.GenerateCreateTable(ATable: TTableMIK): String;
var
  LSQL: TStringBuilder;
  LColumn: TPair<String,TColumnMIK>;
begin
  LSQL := TStringBuilder.Create;
  Result := inherited GenerateCreateTable(ATable);
  try
    if ATable.Database.Schema <> '' then
      LSQL.Append(Format(Result, [ATable.Database.Schema + '.' + ATable.Name]))
    else
      LSQL.Append(Format(Result, [ATable.Name]));
    /// <summary>
    ///   Add Colunas
    /// </summary>
    for LColumn in ATable.FieldsSort do
    begin
      LSQL.AppendLine;
      LSQL.Append(BuilderCreateFieldDefinition(LColumn.Value));
      LSQL.Append(',');
    end;
    /// <summary>
    ///   Add PrimariKey
    /// </summary>
    if ATable.PrimaryKey.Fields.Count > 0 then
    begin
      LSQL.AppendLine;
      LSQL.Append(BuilderPrimayKeyDefinition(ATable));
    end;
    /// <summary>
    ///   Add ForeignKey
    /// </summary>
//    if ATable.ForeignKeys.Count > 0 then
//    begin
//      LSQL.Append(',');
//      LSQL.Append(BuilderForeignKeyDefinition(ATable));
//    end;
    /// <summary>
    ///   Add Checks
    /// </summary>
    if ATable.Checks.Count > 0 then
    begin
      LSQL.Append(',');
      LSQL.Append(BuilderCheckDefinition(ATable));
    end;
    LSQL.AppendLine;
    LSQL.Append(');');
    /// <summary>
    /// Add Indexe
    /// </summary>
    if ATable.IndexeKeys.Count > 0 then
      LSQL.Append(BuilderIndexeDefinition(ATable));
    LSQL.AppendLine;
    Result := LSQL.ToString;
  finally
    LSQL.Free;
  end;
end;

function TDDLSQLGeneratorFirebird.GenerateCreateView(AView: TViewMIK): String;
begin
end;

function TDDLSQLGeneratorFirebird.GenerateDropColumn(AColumn: TColumnMIK): String;
begin
  Result := 'ALTER TABLE %s DROP %s;';
  Result := Format(Result, [AColumn.Table.Name, AColumn.Name]);
end;

function TDDLSQLGeneratorFirebird.GenerateDropDefaultValue(AColumn: TColumnMIK): String;
begin
  Result := 'ALTER TABLE %s ALTER COLUMN %s DROP DEFAULT;';
  Result := Format(Result, [aColumn.Table.Name, AColumn.Name]);
end;

function TDDLSQLGeneratorFirebird.GenerateDropIndexe(AIndexe: TIndexeKeyMIK): String;
begin
  Result := 'DROP INDEX %s ;';
  Result := Format(Result, [AIndexe.Name]);
end;

function TDDLSQLGeneratorFirebird.GenerateDropSequence(ASequence: TSequenceMIK): String;
begin
  Result := 'DROP GENERATOR %s;';
  Result := Format(Result, [ASequence.Name]);
end;

function TDDLSQLGeneratorFirebird.BuilderAlterFieldDefinition(AColumn: TColumnMIK): String;
begin
  Result := AColumn.Name + ' TYPE ' +
            GetFieldTypeDefinition(AColumn)    +
            GetFieldNotNullDefinition(AColumn);
end;

function TDDLSQLGeneratorFirebird.GenerateAlterColumn(AColumn: TColumnMIK): String;
begin
  Result := 'ALTER TABLE %s ALTER COLUMN %s;';
  Result := Format(Result, [AColumn.Table.Name,
                            BuilderAlterFieldDefinition(AColumn)]);
end;

function TDDLSQLGeneratorFirebird.GenerateAlterColumnPosition(AColumn: TColumnMIK): String;
begin
  Result := 'ALTER TABLE %s ALTER COLUMN %s POSITION %D;';
  Result := Format(Result, [AColumn.Table.Name,
                            AColumn.Name,
                            AColumn.Position + 1]);
end;

function TDDLSQLGeneratorFirebird.GenerateEnableForeignKeys(AEnable: Boolean): String;
begin
  if AEnable then
    Result := ''
  else
    Result := '';
end;

function TDDLSQLGeneratorFirebird.GenerateEnableTriggers(AEnable: Boolean): String;
begin
  if AEnable then
    Result := 'UPDATE RDB$TRIGGERS SET RDB$TRIGGER_INACTIVE = 0 ' +
              'WHERE RDB$TRIGGER_SOURCE IS NOT NULL AND ((RDB$SYSTEM_FLAG = 0) OR (RDB$SYSTEM_FLAG IS NULL));'
  else
    Result := 'UPDATE RDB$TRIGGERS SET RDB$TRIGGER_INACTIVE = 1 ' +
              'WHERE RDB$TRIGGER_SOURCE IS NOT NULL AND ((RDB$SYSTEM_FLAG = 0) OR (RDB$SYSTEM_FLAG IS NULL));';
end;

initialization
  TSQLDriverRegister.GetInstance.RegisterDriver(dnFirebird, TDDLSQLGeneratorFirebird.Create);

end.
