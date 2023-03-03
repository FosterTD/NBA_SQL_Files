USE [NBA_Stats]
GO
/****** Object:  StoredProcedure [dbo].[_sp_NBA_Daily_Update_Step2]    Script Date: 3/2/2023 8:40:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Travis Foster
-- Create date: November 1, 2022
-- Description:	Identify new nba players.
-- =============================================
ALTER PROCEDURE [dbo].[_sp_NBA_Daily_Update_Step2]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

--Step1: Create necessary temporary tables. Create into permanent tables. 

--CREATE TABLE A.NBAPlayer_Id (
--    Player_Id int IDENTITY(1,1) PRIMARY KEY,
--    [Player_Name] varchar(255) NOT NULL,
--    [Date_Added] datetime
--);

--  INSERT A.NBAPlayer_Id
--  SELECT
--  a.[Player]
--  FROM (SELECT DISTINCT [Player] FROM [NBA_Stats].[A].[NBAPlayerStats_]) A
--  ORDER BY a.[Player]

--CREATE TABLE [A].[NBATeam_Id](
--	[Team_Id] [int] IDENTITY(1,1) NOT NULL,
--	[Team_Abbreviation] [varchar](255) NULL,
--	[Team_Name] [varchar](255) NOT NULL,
--  [Conference] varchar(max) not null,
--  [Division] varchar(max) not null
--PRIMARY KEY CLUSTERED 
--(
--	[Team_Id] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
--) ON [PRIMARY];

--Step 1: Find unique players
  SELECT
  A.[Player]
  ,GETDATE() AS 'Date_Added'
  into #temp1
  FROM (SELECT DISTINCT 
  [Player] 
  FROM [NBA_Stats].[A].[NBAPlayerStats_] )A
  LEFT JOIN  [NBA_Stats].A.NBAPlayer_Id B ON A.[Player] = B.Player_Name
  WHERE B.Player_Name IS NULL  

  --Step 2: Only run insert statement if new players are identified. 
  IF (SELECT COUNT(*) FROM #temp1) > 0

   BEGIN
   
		INSERT A.NBAPlayer_Id
		SELECT [Player], Date_Added from #temp1

   END

END
