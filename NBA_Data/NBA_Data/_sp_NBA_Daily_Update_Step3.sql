USE [NBA_Stats]
GO
/****** Object:  StoredProcedure [dbo].[_sp_NBA_Daily_Update_Step3]    Script Date: 3/2/2023 8:40:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Travis Foster
-- Create date: November 1, 2022
-- Description:	Calculate daily stats by player
-- =============================================
ALTER PROCEDURE [dbo].[_sp_NBA_Daily_Update_Step3]

	
AS
BEGIN

	SET NOCOUNT ON;


DECLARE @Game_Date AS DATE
SET @Game_Date = cast(DATEADD(D,-1,GETDATE()) as date);

with  Date_time_stamp_partition as (
  SELECT
  ROW_NUMBER() OVER (PARTITION BY 1 ORDER BY  [Date]) AS Date_Id
  ,a.[Date]
  FROM (SELECT DISTINCT [Date] FROM [NBA_Stats].[A].[NBAPlayerStats_]) A )

--Step: Join to Player_Id Source & Date Time Stamp Partition

INSERT [A].[NBAPlayerStats_Final]
SELECT
       b.Player_Id
	  ,a.[Player]
      ,d.[Pos]
      ,cast(d.[Age] as int) AS [Age]
      ,a.[Tm]
      ,cast(a.[Games] as float) - cast(d.[Games] as float) as [Games]
      ,cast(a.[Games Started] as float) - cast(d.[Games Started] as float) as [Games Started]
      ,cast(a.[Minutes Played] as float) - cast(d.[Minutes Played] as float) as [Minutes Played]
      ,cast(a.[Field Goals] as float) - cast(d.[Field Goals] as float) as [Field Goals]
      ,cast(a.[FGA] as float) - cast(d.[FGA] as float) as [FGA]
      ,cast(null as float) as [Field Goal Percentage]
      ,cast(a.[3-Point Field Goals] as float) - cast(d.[3-Point Field Goals]  as float) as [3-Point Field Goals]
      ,cast(a.[3-Point Field Goal Attempts] as float) - cast(d.[3-Point Field Goal Attempts] as float) as [3-Point Field Goal Attempts]
      ,cast(null as float) as [3-Point Field Goal Percentage]
      ,cast(a.[2-Point Field Goals] as float) - cast(d.[2-Point Field Goals] as float) as [2-Point Field Goals]
      ,cast(a.[2-point Field Goal Attempts] as float) - cast(d.[2-point Field Goal Attempts] as float) as [2-point Field Goal Attempts]
      ,cast(null as float) as [2-Point Field Goal Percentage]
      ,cast(null as float) as [Effective Field Goal Percentage]
      ,cast(a.[Free Throws] as float) -cast( d.[Free Throws] as float) as [Free Throws]
      ,cast(a.[Free Throw Attempts] as float) - cast(d.[Free Throw Attempts] as float) as [Free Throw Attempts]
      ,cast(null as float) as [Free Throw Percentage]
      ,cast(a.[Offensive Rebounds] as float) - cast(d.[Offensive Rebounds] as float) as [Offensive Rebounds]
      ,cast(a.[Defensive Rebounds] as float) - cast(d.[Defensive Rebounds] as float) as [Defensive Rebounds]
      ,cast(a.[Total Rebounds] as float) - cast(d.[Total Rebounds] as float) as [Total Rebounds]
      ,cast(a.[Assists] as float) - cast(d.[Assists]  as float) as [Assists]
      ,cast(a.[Steals] as float) - cast(d.[Steals] as float) as [Steals]
      ,cast(a.[Blocks] as float) - cast(d.[Blocks] as float) as [Blocks]
      ,cast(a.[Turnovers] as float) - cast(d.[Turnovers] as float) as [Turnovers]
      ,cast(a.[Personal Fouls] as float) - cast(d.[Personal Fouls] as float) as [Personal Fouls]
      ,cast(a.[Points] as float) - cast(d.[Points] as float) as [Points]
	  ,@Game_Date AS  'Game_Date'
	  ,T.Team_Id
	  --,c.Date_Id
      --,a.[Date]
  FROM [NBA_Stats].[A].[NBAPlayerStats_] A 
  LEFT JOIN [A].[NBATeam_Id] T ON T.Team_Abbreviation=A.Tm
  LEFT JOIN A.NBAPlayer_Id B ON A.[Player] = B.[Player_Name] --WILL BE UPDATED TO NEW TABLE AND NEW PROCESS.
  LEFT JOIN Date_time_stamp_partition C ON a.[Date]=c.[Date]
  LEFT JOIN ( SELECT 
				   b.Player_Id
				  ,a.[Player]
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
				  ,c.Date_Id
				  ,a.[Date]
			  FROM [NBA_Stats].[A].[NBAPlayerStats_] A 
			  LEFT JOIN A.NBAPlayer_Id B ON A.[Player] = B.[Player_Name]
			  LEFT JOIN Date_time_stamp_partition C ON a.[Date]=c.[Date]
			  WHERE C.Date_Id = (SELECT MAX(Date_Id) FROM Date_time_stamp_partition) -1 ) d on d.[Player_Id] = b.[Player_Id]
  WHERE C.Date_Id = (SELECT MAX(Date_Id) FROM Date_time_stamp_partition) 

UPDATE [A].[NBAPlayerStats_Final]
SET [Field Goal Percentage] = ISNULL ( ([Field Goals] / NULLIF([FGA],0) ),0)
,[3-Point Field Goal Percentage] = ISNULL ( ([3-Point Field Goals] / NULLIF([3-Point Field Goal Attempts],0) ),0)
,[2-Point Field Goal Percentage] = ISNULL ( ([2-Point Field Goals] / NULLIF([2-point Field Goal Attempts],0) ),0)
,[Effective Field Goal Percentage] = ISNULL ( (( (0.5 * [3-Point Field Goals]) + [Field Goals] ) / NULLIF([FGA],0) ),0)
,[Free Throw Percentage] = ISNULL ( ([Free Throws] / NULLIF([Free Throw Attempts],0) ),0)
FROM [A].[NBAPlayerStats_Final] 
WHERE Game_Date = @Game_Date


END
