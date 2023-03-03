USE [NBA_Stats]
GO
/****** Object:  StoredProcedure [dbo].[_sp_NBA_Daily_Update_Step1b]    Script Date: 3/2/2023 8:40:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Travis Foster
-- Create date: November 1, 2022
-- Description:	Upload CSV file into landing table.  Make data transformations and upload data into Analytics shema.
-- =============================================
ALTER PROCEDURE [dbo].[_sp_NBA_Daily_Update_Step1b] 


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
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	SET @LANDING_SCHEMA = 'dbo.'
	SET @ANALYTICS_SCHEMA = 'A.'
	SET @TABLE_NAME ='NBAPlayerStats_'
	SET @TEAM_TABLE_NAME = 'NBATeamStats_'
	SET @TIME_STAMP = GETDATE()
	SET @UTCDate = @TIME_STAMP


	SET @DATE = REPLACE(REPLACE(REPLACE(CONVERT(varchar,@TIME_STAMP,20),':','_'),' ','_'),'-','')
	SET @CSV_FILE_DATE = REPLACE(CONVERT(varchar,@TIME_STAMP,106),' ','_')
	SET @FULL_ANALYTICS_TABLE_NAME= CONCAT(@ANALYTICS_SCHEMA,@TABLE_NAME,@DATE)
	SET @FULL_TEAM_ANALYTICS_TABLE_NAME= CONCAT(@ANALYTICS_SCHEMA,@TEAM_TABLE_NAME,@DATE)
	SET @FULL_LANDING_TABLE_NAME = CONCAT(@LANDING_SCHEMA,@TABLE_NAME,@DATE)
	SET @TEAM_FULL_LANDING_TABLE_NAME = CONCAT(@LANDING_SCHEMA,@TEAM_TABLE_NAME,@DATE)
	SET @CREATE_TEAM_STATS_TABLE =


							'CREATE TABLE ' + @TEAM_FULL_LANDING_TABLE_NAME + '(
							[Index] [varchar](50) NULL,
							[Rk] [varchar](50) NULL,
							[Team] [varchar](50) NULL,
							[Conf] [varchar](50) NULL,
							[Div] [varchar](50) NULL,
							[Wins] [varchar](50) NULL,
							[Losses] [varchar](50) NULL,
							[Win-Loss Percentage] [varchar](50) NULL,
							[Margin of Victory] [varchar](50) NULL,
							[Offensive Rating] [varchar](50) NULL,
							[Defensive Rating] [varchar](50) NULL,
							[Net Rating] [varchar](50) NULL,
							[Adjusted Margin of Victory] [varchar](50) NULL,
							[Adjusted Offensive Rating] [varchar](50) NULL,
							[Adjusted Defensive Rating] [varchar](50) NULL,
							[Adjusted Net Rating] [varchar](50) NULL
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
	'BEGIN INSERT INTO ' + CONCAT(@ANALYTICS_SCHEMA,@TEAM_TABLE_NAME,'Final') + '
           ([Rk]
           ,[Team]
           ,[Conf]
           ,[Div]
           ,[Wins]
           ,[Losses]
           ,[Win-Loss Percentage]
           ,[Margin of Victory]
           ,[Offensive Rating]
           ,[Defensive Rating]
           ,[Net Rating]
           ,[Adjusted Margin of Victory]
           ,[Adjusted Offensive Rating]
           ,[Adjusted Defensive Rating]
           ,[Adjusted Net Rating]) 	   
	       
		   SELECT 
		    cast([Rk] as int ) as [Rk]
           ,cast([Team] as varchar(50) ) as [Team]
           ,cast([Conf] as varchar(50) ) as [Conf]
           ,cast([Div] as varchar(50) ) as [Div]
           ,cast([Wins] as int ) as [Wins]
           ,cast([Losses] as int ) as [Losses]
           ,cast([Win-Loss Percentage] as float ) as [Win-Loss Percentage]
           ,cast([Margin of Victory] as float ) as [Margin of Victory]
           ,cast([Offensive Rating] as float ) as [Offensive Rating]
           ,cast([Defensive Rating] as float ) as [Defensive Rating]
           ,cast([Net Rating] as float ) as [Net Rating]
           ,cast([Adjusted Margin of Victory] as float ) as [Adjusted Margin of Victory]
           ,cast([Adjusted Offensive Rating] as float ) as [Adjusted Offensive Rating]
           ,cast([Adjusted Defensive Rating] as float ) as [Adjusted Defensive Rating]
           ,cast([Adjusted Net Rating] as float ) as [Adjusted Net Rating]
		   FROM ' +  @TEAM_FULL_LANDING_TABLE_NAME+ ' END ' 


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--Step1: Create Landing Table SUCCESS
EXEC (@CREATE_TEAM_STATS_TABLE)

--Step2: Upload CSV File to landing table  SUCCESS
EXEC (@TEAM_UPLOAD_CSV)

--Step3: Insert Data into Teams Analytics Table  SUCCESS
EXEC (@INSERT_DATA_INTO_TEAM_ANALYTICS_TABLE)
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--Step6: Add Date to Analytics Table
DECLARE 	@ApplicationsTableUpdateQuery NVARCHAR(MAX) 
SET @ApplicationsTableUpdateQuery= N'
    UPDATE A
    SET Date = @UTCDate 
    FROM [NBA_Stats].[A].[NBATeamStats_Final] A
	WHERE Date IS NULL '

EXEC sp_executesql @ApplicationsTableUpdateQuery
    , N'@UTCDate DATETIME'
    , @UTCDate 
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


END

