USE [NBA_Stats]
GO
/****** Object:  StoredProcedure [dbo].[_sp_NBA_Daily_Update_Step1a]    Script Date: 3/2/2023 8:40:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Travis Foster
-- Create date: November 1, 2022
-- Description:	Upload CSV file into landing table.  Make data transformations and upload data into Analytics shema.
-- =============================================
ALTER PROCEDURE [dbo].[_sp_NBA_Daily_Update_Step1a] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	DECLARE @TABLE_NAME VARCHAR(MAX)
	
	       ,@TIME_STAMP DATETIME
		   ,@LANDING_SCHEMA VARCHAR(MAX)
		   ,@ANALYTICS_SCHEMA VARCHAR(MAX)
	       ,@DATE VARCHAR(MAX)
		   ,@CSV_FILE_DATE VARCHAR(MAX)
		   ,@FULL_LANDING_TABLE_NAME VARCHAR(MAX)
		   ,@FULL_ANALYTICS_TABLE_NAME VARCHAR(MAX)
		   ,@CREATE_TABLE VARCHAR(MAX)
		   ,@UPLOAD_CSV VARCHAR(MAX)
		   ,@TEAM_UPLOAD_CSV VARCHAR(MAX)
		   ,@T_SQL VARCHAR(MAX)
		   ,@CREATE_ANALYTICS_TABLE VARCHAR(MAX)
		   ,@INSERT_DATA_INTO_ANALYTICS_TABLE VARCHAR(MAX) 
           ,@UTCDate DATETIME
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	SET @LANDING_SCHEMA = 'dbo.'
	SET @ANALYTICS_SCHEMA = 'A.'
	SET @TABLE_NAME ='NBAPlayerStats_'
	SET @TIME_STAMP = GETDATE()
	SET @UTCDate = @TIME_STAMP


	SET @DATE = REPLACE(REPLACE(REPLACE(CONVERT(varchar,@TIME_STAMP,20),':','_'),' ','_'),'-','')
	SET @CSV_FILE_DATE = REPLACE(CONVERT(varchar,@TIME_STAMP,106),' ','_')
	SET @FULL_ANALYTICS_TABLE_NAME= CONCAT(@ANALYTICS_SCHEMA,@TABLE_NAME,@DATE)
	SET @FULL_LANDING_TABLE_NAME = CONCAT(@LANDING_SCHEMA,@TABLE_NAME,@DATE)
	
	SET @CREATE_TABLE  = 
							'CREATE TABLE ' + @FULL_LANDING_TABLE_NAME + ' (
							[Column 0] [varchar](50) NULL,
							[Player] [varchar](50) NULL,
							[Pos] [varchar](50) NULL,
							[Age] [varchar](50) NULL,
							[Tm] [varchar](50) NULL,
							[Games] [varchar](50) NULL,
							[Games Started] [varchar](50) NULL,
							[Minutes Played] [varchar](50) NULL,
							[Field Goals] [varchar](50) NULL,
							[FGA] [varchar](50) NULL,
							[Field Goal Percentage] [varchar](50) NULL,
							[3-Point Field Goals] [varchar](50) NULL,
							[3-Point Field Goal Attempts] [varchar](50) NULL,
							[3-Point Field Goal Percentage] [varchar](50) NULL,
							[2-Point Field Goals] [varchar](50) NULL,
							[2-point Field Goal Attempts] [varchar](50) NULL,
							[2-Point Field Goal Percentage] [varchar](50) NULL,
							[Effective Field Goal Percentage] [varchar](50) NULL,
							[Free Throws] [varchar](50) NULL,
							[Free Throw Attempts] [varchar](50) NULL,
							[Free Throw Percentage] [varchar](50) NULL,
							[Offensive Rebounds] [varchar](50) NULL,
							[Defensive Rebounds] [varchar](50) NULL,
							[Total Rebounds] [varchar](50) NULL,
							[Assists] [varchar](50) NULL,
							[Steals] [varchar](50) NULL,
							[Blocks] [varchar](50) NULL,
							[Turnovers] [varchar](50) NULL,
							[Personal Fouls] [varchar](50) NULL,
							[Points] [varchar](50) NULL
						) ON [PRIMARY]'


	
	SET @UPLOAD_CSV = ' BULK INSERT ' + @FULL_LANDING_TABLE_NAME +' 
						FROM ''C:\Users\hoost\NBA Python Scraper\'+ concat(@TABLE_NAME,@CSV_FILE_DATE) + '.csv''
						WITH
						(
								FORMAT=''CSV'',
								FIRSTROW=2
						)
						'
	SET @T_SQL = 
		' BEGIN UPDATE ' + @FULL_LANDING_TABLE_NAME  + ' 
		  SET [Tm] = right([Tm],3)
		  FROM ' + @FULL_LANDING_TABLE_NAME + ' END '

	--SET @CREATE_ANALYTICS_TABLE = 
	--					'CREATE TABLE ' + @FULL_ANALYTICS_TABLE_NAME + ' (
	--						[Player] [varchar](50) NULL,
	--						[Pos] [varchar](50) NULL,
	--						[Age] [varchar](50) NULL,
	--						[Tm] [varchar](50) NULL,
	--						[Games] [varchar](50) NULL,
	--						[Games Started] [varchar](50) NULL,
	--						[Minutes Played] [varchar](50) NULL,
	--						[Field Goals] [varchar](50) NULL,
	--						[FGA] [varchar](50) NULL,
	--						[Field Goal Percentage] [varchar](50) NULL,
	--						[3-Point Field Goals] [varchar](50) NULL,
	--						[3-Point Field Goal Attempts] [varchar](50) NULL,
	--						[3-Point Field Goal Percentage] [varchar](50) NULL,
	--						[2-Point Field Goals] [varchar](50) NULL,
	--						[2-point Field Goal Attempts] [varchar](50) NULL,
	--						[2-Point Field Goal Percentage] [varchar](50) NULL,
	--						[Effective Field Goal Percentage] [varchar](50) NULL,
	--						[Free Throws] [varchar](50) NULL,
	--						[Free Throw Attempts] [varchar](50) NULL,
	--						[Free Throw Percentage] [varchar](50) NULL,
	--						[Offensive Rebounds] [varchar](50) NULL,
	--						[Defensive Rebounds] [varchar](50) NULL,
	--						[Total Rebounds] [varchar](50) NULL,
	--						[Assists] [varchar](50) NULL,
	--						[Steals] [varchar](50) NULL,
	--						[Blocks] [varchar](50) NULL,
	--						[Turnovers] [varchar](50) NULL,
	--						[Personal Fouls] [varchar](50) NULL,
	--						[Points] [varchar](50) NULL,
	--						[Date] Date 
	--					) ON [PRIMARY]'


	SET @INSERT_DATA_INTO_ANALYTICS_TABLE = 
	'BEGIN INSERT INTO ' + CONCAT(@ANALYTICS_SCHEMA,@TABLE_NAME) + '
           ([Player]
           ,[Pos]
           ,[Age]
           ,[Tm]
           ,[Games]
           ,[Games Started]
           ,[Minutes Played]
           ,[Field Goals]
           ,[FGA]
           ,[Field Goal Percentage]
           ,[3-Point Field Goals]
           ,[3-Point Field Goal Attempts]
           ,[3-Point Field Goal Percentage]
           ,[2-Point Field Goals]
           ,[2-point Field Goal Attempts]
           ,[2-Point Field Goal Percentage]
           ,[Effective Field Goal Percentage]
           ,[Free Throws]
           ,[Free Throw Attempts]
           ,[Free Throw Percentage]
           ,[Offensive Rebounds]
           ,[Defensive Rebounds]
           ,[Total Rebounds]
           ,[Assists]
           ,[Steals]
           ,[Blocks]
           ,[Turnovers]
           ,[Personal Fouls]
           ,[Points]) 	   
	       
		   SELECT 
		   [Player]
           ,[Pos]
           ,[Age]
           ,[Tm]
           ,[Games]
           ,[Games Started]
           ,[Minutes Played]
           ,[Field Goals]
           ,[FGA]
           ,[Field Goal Percentage]
           ,[3-Point Field Goals]
           ,[3-Point Field Goal Attempts]
           ,[3-Point Field Goal Percentage]
           ,[2-Point Field Goals]
           ,[2-point Field Goal Attempts]
           ,[2-Point Field Goal Percentage]
           ,[Effective Field Goal Percentage]
           ,[Free Throws]
           ,[Free Throw Attempts]
           ,[Free Throw Percentage]
           ,[Offensive Rebounds]
           ,[Defensive Rebounds]
           ,[Total Rebounds]
           ,[Assists]
           ,[Steals]
           ,[Blocks]
           ,[Turnovers]
           ,[Personal Fouls]
           ,[Points]
		   FROM ' +  @FULL_LANDING_TABLE_NAME+ ' END ' 
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--Step1: Create Landing Table SUCCESS
EXEC (@CREATE_TABLE)

--Step2: Upload CSV File SUCCESS
EXEC (@UPLOAD_CSV)

--Step3: Add DateTimeStamp Column SUCCESS
EXEC (@T_SQL)

--Step4: Create Analytics Table  SUCCESS
--EXEC (@CREATE_ANALYTICS_TABLE)

--Step5: Insert Data into Analytics Table  SUCCESS
EXEC (@INSERT_DATA_INTO_ANALYTICS_TABLE)
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--Step6: Add Date to Analytics Table
DECLARE 	@ApplicationsTableUpdateQuery NVARCHAR(MAX) 
           ,@TableName_ NVARCHAR(MAX)
		   
SET @TableName_ = (SELECT a.[name] 
				FROM sys.Tables a
				inner join (select max(create_date) as create_date from sys.Tables
							where schema_id =1
							and [name] like '%player%') b on a.[create_date] = b.[create_date]
				WHERE schema_id =1)

SET @ApplicationsTableUpdateQuery= N'
    UPDATE A
    SET Date = @UTCDate 
    FROM [NBA_Stats].[A].[NBAPlayerStats_] A
	WHERE Date IS NULL '

EXEC sp_executesql @ApplicationsTableUpdateQuery
    , N'@UTCDate DATETIME'
    , @UTCDate 
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

END
/*

(SELECT a.[name] 
				FROM sys.Tables a
				inner join (select max(create_date) as create_date from sys.Tables
							where schema_id =1) b on a.[create_date] = b.[create_date]
				WHERE schema_id =1)


*/