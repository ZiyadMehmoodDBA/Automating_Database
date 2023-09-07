-- =============================================
-- Author:		Ziyad Mehmood
-- Description:	This procedure helps in creating the table
 -- Exec [dbo].[usp_MSOCreateTable] 
	--@InputSQL= 'InvestigationSignedoffID Int ,TreatmentPlanDayID Int,InvestigationID Int,InvestigationSignedDate DateTime',
	--@TableName = 'tblPatientInvestigationsSignedoff',
	--@PrimaryKey = 'InvestigationSignedoffId',
	--@Schemaname='Patient',
	--@ForignKey = 'TreatmentPlanDayID:TreatmentPlanDay'
--Note: please add function dbo.[fnSplit]
-- =============================================

CREATE Procedure [dbo].[usp_CreateTable]
(
@InputSQL AS nvarchar(MAX), 
@TableName AS nvarchar(128) ,
@Schemaname AS nvarchar(128),
@PrimaryKey nvarchar(128),
@ForignKey nvarchar(128) = NULL
)

AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
Begin
SET NOCOUNT ON
DECLARE @SQL AS NVARCHAR(4000) = NULL
DECLARE @NewLine NVARCHAR(2) = CHAR(13) + CHAR(10) -- CRLF
DECLARE @pConstraint nvarchar(500) = NULL
DECLARE @pPrimaryConstraint nvarchar(500) = null
DECLARE @vScript			nVARCHAR(MAX)	= ''


IF (Len(@InputSQL) < 1 or @InputSQL Is NULL)
BEGIN
	RAISERROR('please specify column names in parameter @InputSQL.',16,1)

	PRINT 'Specify column names as following:
	
Exec [dbo].[usp_CreateTable]
	@InputSQL= ''Patient_PhysicalExam_Subsystem_Id BIGINT (pk),Patient_PhysicalExam_System_Id BIGINT,Practice_PhysicalExam_Subsystem_Id BIGINT,Subsystem_Value Varchar(200),Normal BIT'',
	...,
	...,
	...
	'
RETURN -1
END

IF (Len(@TableName) < 1 or @TableName Is NULL)
BEGIN
	RAISERROR('please specify table names in parameter @TableName.',16,1)

	PRINT 'Specify table names as following:
	
Exec [dbo].[usp_CreateTable]
	...,
	@TableName = ''Patient_PhysicalExam_Subsystem'',
	...,
	...
	'
RETURN -1
END

IF (Len(@PrimaryKey) < 1 or @PrimaryKey Is NULL)
BEGIN
	RAISERROR('please specify primary key names in parameter @PrimaryKey.',16,1)

	PRINT 'Specify primary key names as following:
	
Exec [dbo].[usp_CreateTable]
	...,
	...,
	@PrimaryKey = ''Patient_PhysicalExam_Subsystem_Id'',
	...
	'
RETURN -1
END

IF (Len(@Schemaname) < 1 or @Schemaname Is NULL)
BEGIN
	RAISERROR('please specify schema names in parameter @Schemaname.',16,1)

	PRINT 'Specify schema names as following:
	
Exec [dbo].[usp_CreateTable]
	...,
	...,
	...,
	@Schemaname = ''dbo''
	'
RETURN -1
END
/*Declare Table Type*/

Declare @CreateTable Table 
(Id Int Identity(1,1),Column_Name nvarchar(128),Data_Type nvarchar(25),NUll_Type nvarchar(50),Constraints nvarchar(100))

Declare @ForignKeytbl Table
(TableName nVARCHAR(255), TName nVARCHAR(255), ForeignKey nVARCHAR(255), ParentName nVARCHAR(300), PrimaryKey nVARCHAR(255))

SET @InputSQL = Replace(@InputSQL,char(13) + char(10),'')

--Select @InputSQL = Replace(replace(@InputSQL,'(pk)',''),'(fk)','')

Insert Into @CreateTable(Column_Name,Data_type,NUll_Type,Constraints)
Select 
RTRIM(LTRIM(SUBSTRING([item],1,charindex(' ',LTRIM(RTRIM([item])))))) as ColumnName,
lower(Ltrim(Rtrim(Right([item],CHARINDEX(' ',Reverse([item])))))) Data_type,
IIF(LTRIM(RTRIM(SUBSTRING([item],1,charindex(' ',[item])))) Like '%ID','NOT NULL','NULL')NUll_Type,Null
from dbo.[fnSplit](@InputSQL,',') as tab
UNION ALL
SELECT 'Created_By', 'varchar(55)', 'NOT NULL',NULL UNION ALL
SELECT 'Created_Date', 'datetime', 'NOT NULL',' CONSTRAINT DF_'+@TableName+'_CreatedDate DEFAULT GetDate()' UNION ALL
SELECT 'Modified_By', 'varchar(55)', 'NOT NULL',NULL UNION ALL
SELECT 'Modified_Date', 'datetime', 'NOT NULL',' CONSTRAINT DF_'+@TableName+'_ModifiedDate DEFAULT GetDate()' UNION ALL
SELECT 'Deleted', 'bit', 'NOT NULL', ' CONSTRAINT DF_'+@TableName+'_Deleted DEFAULT(0)' 

--Update @CreateTable
--Set Column_Name = replace(Column_Name,char(13) + char(10),'')
----Where id = 1 And Column_Name = @PrimaryKey

Select Column_Name,Len(Column_Name) ColumnLength from @CreateTable
Select * from @CreateTable

SET @pConstraint = 'CONSTRAINT [PK_'+@TableName+'] PRIMARY KEY CLUSTERED (['+@PrimaryKey+'] ASC)'

SET @SQL = 'If NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME ='''+@TableName+''' AND TABLE_SCHEMA = '''+@Schemaname+''')
BEGIN'+@NewLine
SET @SQL += 'CREATE TABLE '+'['+ISNULL(@Schemaname, 'Dbo')+']'+'.'+'[' + ISNULL(@TableName, 'TableName') +'] ('+@NewLine

Set @pPrimaryConstraint = '['+@PrimaryKey+']' +' ' +'bigint'+ ' '+ 'NOT NULL ' + @pConstraint

        SELECT @SQL += 
		IIF(Column_Name = @PrimaryKey,@pPrimaryConstraint,'['+LTRIM(RTRIM(Column_Name))+']')
		+' ' +
		IIF(Column_Name = @PrimaryKey,'',Data_type)
		+' '+ 
		IIF(Column_Name = @PrimaryKey,'',NUll_Type) 
		+''+
		IIF(Constraints is Null,' ',Constraints)
		+
		IIF(Column_Name = 'Deleted',' ',',')+@newline
		From @CreateTable

IF @ForignKey IS NOT NULL
BEGIN 
Select @ForignKey
		  SELECT ISNULL(@Schemaname,'dbo')+'.'+RTRIM(LTRIM(SUBSTRING([item],1,CHARINDEX(':',[item])-1))) AS ParentName
		        ,LTRIM(RTRIM(RIGHT([item],CHARINDEX(':',REVERSE([item]))-1))) AS ForeignKey
			FROM dbo.[fnSplit](@ForignKey,',') f

	INSERT INTO @ForignKeytbl
	(TableName, TName, ForeignKey, ParentName, PrimaryKey)
	SELECT ISNULL(@Schemaname,'dbo')+'.'+ISNULL(@TableName,'') AS TableName
	      ,SUBSTRING(T.ParentName, CHARINDEX('.',T.ParentName)+1, LEN(T.ParentName)) AS TNAME
		  ,T.ForeignKey,T.ParentName
		  ,(
		  SELECT I.COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE I
			 WHERE OBJECTPROPERTY(OBJECT_ID(I.CONSTRAINT_SCHEMA + '.' + QUOTENAME(I.CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
			   AND I.TABLE_SCHEMA+'.'+I.TABLE_NAME = T.ParentName
			   ) AS PrimaryKey
		  
	FROM (
		  SELECT ISNULL(@Schemaname,'dbo')+'.'+RTRIM(LTRIM(SUBSTRING([item],1,CHARINDEX(':',[item])-1))) AS ParentName
		        ,LTRIM(RTRIM(RIGHT([item],CHARINDEX(':',REVERSE([item]))-1))) AS ForeignKey
			FROM dbo.[fnSplit](@ForignKey,',') f
		  ) T  
SELECT @vScript += 'ALTER TABLE '+TableName+' ADD CONSTRAINT FK_'+ISNULL(@TableName,'')+'_'+TName+' FOREIGN KEY ('+ForeignKey+')'
					+@NewLine
					+'REFERENCES '+IsNull(ParentName,@TableName)+'('+IsNull(ForeignKey,@PrimaryKey)+')'+@NewLine+@NewLine
  FROM @ForignKeytbl

END

SET @SQL +=  ')'+@NewLine+@vScript
SET @SQL += 'END'

Print @SQL
/*Select * from @ForignKeytbl*/
/*Select @vScript*/
End
