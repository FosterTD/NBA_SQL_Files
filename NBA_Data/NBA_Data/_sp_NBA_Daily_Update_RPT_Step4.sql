USE [NBA_Stats]
GO
/****** Object:  StoredProcedure [dbo].[_sp_NBA_Daily_Update_RPT_Step4]    Script Date: 3/2/2023 8:41:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Travis D. Foster
-- Create date: November 2, 2022
-- Description:	Create backup tables
-- =============================================
ALTER PROCEDURE [dbo].[_sp_NBA_Daily_Update_RPT_Step4]

	
AS
BEGIN

	SET NOCOUNT ON;


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

IF OBJECT_ID('RPT.NBAInjuryReport') IS NOT NULL 
BEGIN 
    DROP TABLE RPT.NBAInjuryReport 
END

--Purpose of this query is to pull list of games played on current day and provide related data. 

SELECT
       [Index]
      ,[Player]
      ,[Team]
      ,[Update] as 'injury_update_start_date'
	  ,concat([Player], ' - ', [Description]) 'injury_rpt'
into #transform
FROM [NBA_Stats].[A].[NBAInjuryReport]

SELECT 
    a.Team
   ,STUFF((SELECT '; ' + US.injury_rpt 
          FROM #transform US
          WHERE US.Team = a.Team
          FOR XML PATH('')), 1, 1, '') [Injury_Report]
into RPT.NBAInjuryReport 
FROM #transform a
INNER JOIN (
		  SELECT
		  MAX([Index]) [Index]
		  ,[Player] 
		  FROM #transform
		  GROUP BY [Player]) M ON M.[Index]=A.[Index] AND M.[Player]=A.[Player]
GROUP BY a.Team
ORDER BY a.Team


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


END
