USE [NBA_Stats]
GO
/****** Object:  StoredProcedure [dbo].[_sp_NBA_Daily_Update_Step0]    Script Date: 3/2/2023 8:40:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Travis D. Foster
-- Create date: November 2, 2022
-- Description:	Create backup tables
-- =============================================
ALTER PROCEDURE [dbo].[_sp_NBA_Daily_Update_Step0]

	
AS
BEGIN

	SET NOCOUNT ON;


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
DECLARE @Detail_BackUpTableName varchar(100)
	   ,@Source varchar(max)
	   ,@Detail_BackUpTableName2 varchar(100)
	   ,@Source2 varchar(max)
       ,@BackUpDateTime varchar(50)
	   ,@Detail_BackUpTableName3 varchar(100)
	   ,@Source3 varchar(max)
	   ,@Detail_BackUpTableName4 varchar(100)
	   ,@Source4 varchar(max)


SET @BackUpDateTime = (SELECT CONVERT(VARCHAR(23), GETDATE(), 126))

SET @Detail_BackUpTableName = (SELECT '[zzz_NBAPlayerStats_'+CAST(@BackUpDateTime AS VARCHAR(50))+']')
SET @Source = '[DESKTOP-QRBACRH].[NBA_Stats].[A].[NBAPlayerStats_]'

SET @Detail_BackUpTableName2 = (SELECT '[zzz_NBAPlayerStats_Final_'+CAST(@BackUpDateTime AS VARCHAR(50))+']')
SET @Source2 =  '[DESKTOP-QRBACRH].[NBA_Stats].[A].[NBAPlayerStats_Final]'

SET @Detail_BackUpTableName3 = (SELECT '[zzz_NBATeamStats_Final_'+CAST(@BackUpDateTime AS VARCHAR(50))+']')
SET @Source3 =  '[DESKTOP-QRBACRH].[NBA_Stats].[A].[NBATeamStats_Final]'

SET @Detail_BackUpTableName4 = (SELECT '[zzz_NBAGameResults_Final_'+CAST(@BackUpDateTime AS VARCHAR(50))+']')
SET @Source4 =  '[DESKTOP-QRBACRH].[NBA_Stats].[A].[NBAGameResults_Final]'

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


DECLARE @sqlCommand_D varchar(1000)
SET @sqlCommand_D = 'SELECT * INTO ' + @Detail_BackUpTableName + ' FROM '+@Source
EXEC (@sqlCommand_D)

DECLARE @sqlCommand_D2 varchar(1000)
SET @sqlCommand_D2 = 'SELECT * INTO ' + @Detail_BackUpTableName2 + ' FROM '+@Source2
EXEC (@sqlCommand_D2)

DECLARE @sqlCommand_D3 varchar(1000)
SET @sqlCommand_D3 = 'SELECT * INTO ' + @Detail_BackUpTableName3 + ' FROM '+@Source3
EXEC (@sqlCommand_D3)

DECLARE @sqlCommand_D4 varchar(1000)
SET @sqlCommand_D4 = 'SELECT * INTO ' + @Detail_BackUpTableName4 + ' FROM '+@Source4
EXEC (@sqlCommand_D4)

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


END
