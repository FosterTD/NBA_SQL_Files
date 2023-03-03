USE [NBA_Stats]
GO
/****** Object:  StoredProcedure [dbo].[_sp_NBA_Daily_Update_Step1d]    Script Date: 3/2/2023 8:57:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Travis Foster
-- Create date: November 1, 2022
-- Description:	Upload CSV file into landing table.  Make data transformations and upload data into Analytics shema.
-- =============================================
ALTER PROCEDURE [dbo].[_sp_NBA_Daily_Update_Step1d] 


AS
BEGIN

	SET NOCOUNT ON;


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	DECLARE @TABLE_NAME VARCHAR(MAX)
	       ,@TEAM_TABLE_NAME VARCHAR(MAX)
	       ,@TIME_STAMP DATETIME
		   ,@LANDING_SCHEMA VARCHAR(MAX)
		   ,@ANALYTICS_SCHEMA VARCHAR(MAX)
	       ,@DATE VARCHAR(MAX)
		   ,@CSV_FILE_DATE VARCHAR(MAX)
		   ,@FULL_LANDING_TABLE_NAME VARCHAR(MAX)
		   ,@TEAM_FULL_LANDING_TABLE_NAME VARCHAR(MAX)
		   ,@FULL_ANALYTICS_TABLE_NAME VARCHAR(MAX)
		   ,@FULL_TEAM_ANALYTICS_TABLE_NAME VARCHAR(MAX)
		   ,@CREATE_TABLE VARCHAR(MAX)
		   ,@CREATE_TEAM_STATS_TABLE VARCHAR(MAX)
		   ,@UPLOAD_CSV VARCHAR(MAX)
		   ,@TEAM_UPLOAD_CSV VARCHAR(MAX)
		   ,@T_SQL VARCHAR(MAX)
		   ,@T_SQL2 VARCHAR(MAX)
		   ,@CREATE_ANALYTICS_TABLE VARCHAR(MAX)
		   ,@CREATE_TEAM_ANALYTICS_TABLE VARCHAR(MAX)
		   ,@INSERT_DATA_INTO_ANALYTICS_TABLE VARCHAR(MAX) 
		   ,@INSERT_DATA_INTO_TEAM_ANALYTICS_TABLE VARCHAR(MAX)
           ,@UTCDate DATETIME
		   ,@ymn varchar(6)
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	SET @LANDING_SCHEMA = 'dbo.'
	SET @ANALYTICS_SCHEMA = 'A.'
	SET @TABLE_NAME ='NBAPlayerStats_'
	SET @TEAM_TABLE_NAME = 'NBAInjuryReport_'
	SET @TIME_STAMP = GETDATE()
	SET @UTCDate = @TIME_STAMP

	SET @ymn = YEAR(DATEADD(D,-1,@TIME_STAMP))*100 + MONTH(DATEADD(D,-1,@TIME_STAMP))


	SET @DATE = REPLACE(REPLACE(REPLACE(CONVERT(varchar,@TIME_STAMP,20),':','_'),' ','_'),'-','')
	SET @CSV_FILE_DATE = REPLACE(CONVERT(varchar,@TIME_STAMP,106),' ','_')
	SET @FULL_ANALYTICS_TABLE_NAME= CONCAT(@ANALYTICS_SCHEMA,@TABLE_NAME,@DATE)
	SET @FULL_TEAM_ANALYTICS_TABLE_NAME= CONCAT(@ANALYTICS_SCHEMA,@TEAM_TABLE_NAME,@DATE)
	SET @FULL_LANDING_TABLE_NAME = CONCAT(@LANDING_SCHEMA,@TABLE_NAME,@DATE)
	SET @TEAM_FULL_LANDING_TABLE_NAME = CONCAT(@LANDING_SCHEMA,@TEAM_TABLE_NAME,@DATE)
	SET @CREATE_TEAM_STATS_TABLE =

							'CREATE TABLE ' + @TEAM_FULL_LANDING_TABLE_NAME + '(
									[Index] [varchar](50) NULL,
									[Player] [varchar](50) NULL,
									[Team] [varchar](50) NULL,
									[Update] date NULL,
									[Description] [varchar](max) NULL
								) ON [PRIMARY]'



	SET @TEAM_UPLOAD_CSV = ' BULK INSERT ' + @TEAM_FULL_LANDING_TABLE_NAME +' 
						FROM ''C:\Users\hoost\NBA Python Scraper\'+ concat(@TEAM_TABLE_NAME,@CSV_FILE_DATE) + '.csv''
						WITH
						(
								FORMAT=''CSV'',
								FIRSTROW=2
						)
						'

	SET @INSERT_DATA_INTO_TEAM_ANALYTICS_TABLE = 
	'BEGIN 
	
	TRUNCATE TABLE  [A].[NBAInjuryReport]
	
	
	INSERT INTO [A].[NBAInjuryReport]
	       
		   SELECT 
		    [Index],
			[Player],
			[Team] ,
			[Update] ,
			[Description]

		   FROM ' +  @TEAM_FULL_LANDING_TABLE_NAME+ ' END ' 


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--Step1: Create Landing Table SUCCESS
EXEC (@CREATE_TEAM_STATS_TABLE)

--Step2: Upload CSV File to landing table  SUCCESS
EXEC (@TEAM_UPLOAD_CSV)

--Step3: Insert Data into Teams Analytics Table  SUCCESS
EXEC (@INSERT_DATA_INTO_TEAM_ANALYTICS_TABLE)
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/*
alter table [A].[NBAGameResults_Final]
add Away_Team_Margin float

alter table [A].[NBAGameResults_Final]
add Home_Team_Margin float
*/
END

