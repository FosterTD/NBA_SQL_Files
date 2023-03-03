USE [NBA_Stats]
GO
/****** Object:  StoredProcedure [dbo].[_sp_NBA_Daily_Update_RPT_Step2]    Script Date: 3/2/2023 8:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Travis D. Foster
-- Create date: November 2, 2022
-- Description:	Create backup tables
-- =============================================
ALTER PROCEDURE [dbo].[_sp_NBA_Daily_Update_RPT_Step2]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	SET NOCOUNT ON;


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

IF OBJECT_ID('RPT.NBAGameDayPlayerStats') IS NOT NULL 
BEGIN 
    DROP TABLE RPT.NBAGameDayPlayerStats 
END


SELECT [Player_Id]
      ,[Player]
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
      ,[Game_Date]
      ,[Team_Id]
	  ,m.Row_Count as GameDayMatchups_Row_Count
  INTO RPT.NBAGameDayPlayerStats 
  FROM [NBA_Stats].[A].[NBAPlayerStats_Final] player_s
  INNER JOIN (SELECT 
              [Away_Team_Abbreviation] as teams
			  ,[Row_Count]
			  FROM [RPT].[NBAGameDayMatchups]
			  UNION
			  
			  SELECT
			  [Home_Team_Abbreviation] as teams
			  ,[Row_Count]
			  FROM[RPT].[NBAGameDayMatchups]) m on m.[teams] = player_s.[tm]
	where [Games] <> 0
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


END
