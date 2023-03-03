USE [NBA_Stats]
GO
/****** Object:  StoredProcedure [dbo].[_sp_NBA_Daily_Update_RPT_Step3]    Script Date: 3/2/2023 8:53:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Travis D. Foster
-- Create date: November 2, 2022
-- Description:	Create backup tables
-- =============================================
ALTER PROCEDURE [dbo].[_sp_NBA_Daily_Update_RPT_Step3]

	
AS
BEGIN

	SET NOCOUNT ON;


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

IF OBJECT_ID('RPT.NBAGameDayMatchups_History') IS NOT NULL 
BEGIN 
    DROP TABLE RPT.NBAGameDayMatchups_History 
END

--Purpose of this query is to pull list of games played on current day and provide related data. 
SELECT 
      row_number() over (partition by g.[date] order by right(g.Start_Time_ET,1) ,len(g.Start_Time_ET), g.Start_Time_ET ) as 'Row_Count'
	  ,2023 as 'Season'
	  ,g.[Date]
      ,g.[Start_Time_ET]
	  ,concat(away_t.Team_Name ,' @ ',home_t.Team_Name) as 'Game_Matchup'
	  ,home_t.Division
	  ,home_t.Conference
	  ,case when home_t.Division = away_t.Division then 1 else 0 end 'Division_Game_Flag'
	  ,case when home_t.Conference = away_t.Conference then 1 else 0 end 'Conference_Game_Flag'
	  ,g.Visitor_Points
	  ,g.Home_Points
	  ,away_s.[Adjusted Offensive Rating] as Away_Adjusted_Offensive_Rating
	  ,home_s.[Adjusted Offensive Rating] as Home_Adjusted_Offensive_Rating
	  ,away_s.[Adjusted Defensive Rating] as Away_Adjusted_Defensive_Rating
	  ,home_s.[Adjusted Defensive Rating] as Home_Adjusted_Defensive_Rating
	  ,away_s.[Adjusted Net Rating] as Away_Adjusted_Net_Rating
	  ,home_s.[Adjusted Net Rating] as Home_Adjusted_Net_Rating
	  ,g.Away_Team_Margin
	  ,g.Home_Team_Margin
  INTO RPT.NBAGameDayMatchups_History
  FROM [NBA_Stats].[A].[NBAGameResults_Final] g with (nolock)
  left join [A].[NBATeam_Id] home_t with (nolock) on home_t.Team_Abbreviation = g.Home
  left join (SELECT * 
             FROM [A].[NBATeamStats_Final] 
			 WHERE [Date] = (select max([date]) from [A].[NBATeamStats_Final] ) ) home_s on home_s.Team = g.Home 
  left join [A].[NBATeam_Id] away_t with (nolock) on away_t.Team_Abbreviation = g.Visitor
  left join (SELECT * 
             FROM [A].[NBATeamStats_Final] 
			 WHERE [Date] = (select max([date]) from [A].[NBATeamStats_Final] ) ) away_s on away_s.Team = g.Visitor  
  where g.[Date]< cast(getdate() as date) 

UNION ALL
SELECT 
      row_number() over (partition by g.[date] order by right(g.Start_Time_ET,1) ,len(g.Start_Time_ET), g.Start_Time_ET ) as 'Row_Count'
	  ,2022 as 'Season'
	  ,g.[Date]
      ,g.[Start_Time_ET]
	  ,concat(away_t.Team_Name ,' @ ',home_t.Team_Name) as 'Game_Matchup'
	  ,home_t.Division
	  ,home_t.Conference
	  ,case when home_t.Division = away_t.Division then 1 else 0 end 'Division_Game_Flag'
	  ,case when home_t.Conference = away_t.Conference then 1 else 0 end 'Conference_Game_Flag'
	  ,g.Visitor_Points
	  ,g.Home_Points
	  ,NULL as Away_Adjusted_Offensive_Rating
	  ,NULL as Home_Adjusted_Offensive_Rating
	  ,NULL as Away_Adjusted_Defensive_Rating
	  ,NULL as Home_Adjusted_Defensive_Rating
	  ,NULL as Away_Adjusted_Net_Rating
	  ,NULL as Home_Adjusted_Net_Rating
	  ,g.Away_Team_Margin
	  ,g.Home_Team_Margin
  FROM [NBA_Stats].[dbo].[NBAGameResultsSeason_2022] g with (nolock)
  --FROM [NBA_Stats].[A].[NBAGameResults_Final] g with (nolock)
  left join [A].[NBATeam_Id] home_t with (nolock) on home_t.Team_Abbreviation = g.Home
  --left join (SELECT * 
  --           FROM [A].[NBATeamStats_Final] 
		--	 WHERE [Date] = (select max([date]) from [A].[NBATeamStats_Final] ) ) home_s on home_s.Team = g.Home 
  left join [A].[NBATeam_Id] away_t with (nolock) on away_t.Team_Abbreviation = g.Visitor
  --left join (SELECT * 
  --           FROM [A].[NBATeamStats_Final] 
		--	 WHERE [Date] = (select max([date]) from [A].[NBATeamStats_Final] ) ) away_s on away_s.Team = g.Visitor  

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


END
