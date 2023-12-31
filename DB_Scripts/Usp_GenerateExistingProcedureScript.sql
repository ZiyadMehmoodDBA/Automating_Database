CREATE Procedure DBO.[usp_GenerateExistingProcedureScript] --Sp_Generate_Procs 'usp_Procdure'
@ProcToScript varchar(Max)
AS
Begin
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

Declare @QryTab Table (ID Int Primary Key Identity(1,1),QueryIs nvarchar(max));
Declare @EventData nvarchar(max) = '',@flag int = 0,@cnt int = 0,@ID int = 0,@ProcID int = 0,@ProcName varchar(max);

	Insert into @QryTab(QueryIs)
	Select 'IF EXISTS (SELECT 1 FROM SYS.PROCEDURES WHERE NAME = '''+@ProcToScript+''' AND TYPE = ''P'' )'+Char(10)+
	'BEGIN
		DROP PROCEDURE '+@ProcToScript+'
	END'+char(10)+'GO'



			Insert Into @QryTab
			Exec Sp_HelpText @ProcToScript

			Insert Into @QryTab
			Values('Go')


			DECLARE cursor_query CURSOR
			FOR SELECT 
					ID,
					Replace(Replace(Replace(Ltrim(Rtrim(QueryIs)),'\n',''),'\t',''),'CREATE         PROCEDURE ','CREATE PROCEDURE ')
			FROM @QryTab

			OPEN cursor_query

		FETCH NEXT FROM cursor_query INTO 
			@ID,
			@EventData

		WHILE @@FETCH_STATUS =0
			BEGIN
				PRINT @EventData;

				FETCH NEXT FROM cursor_query INTO 
								@ID,
								@EventData
			END

		CLOSE cursor_query
		DEALLOCATE cursor_query
		

End