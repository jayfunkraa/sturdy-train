/****** Object:  UserDefinedFunction [dbo].[tRelRepGetDefectInfoForReg]    Script Date: 06/03/2019 14:32:48 ******/
IF OBJECT_ID('dbo.tRelRepGetDefectInfoForReg', 'U') IS NOT NULL
DROP FUNCTION dbo.tRelRepGetDefectInfoForReg
GO
/****** Object:  UserDefinedFunction [dbo].[tRelRepGetDefectInfoForReg]    Script Date: 06/03/2019 14:32:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jamie Hanna
-- =============================================
CREATE FUNCTION [dbo].[tRelRepGetDefectInfoForReg] 
(
	@Reg_ID int, 
	@ATA_ID int
)
RETURNS 
@Defects TABLE 
(
	FirstDefect_ID int, 
	FirstDefect_Date datetime,
	FirstDefect_Cycles decimal(18, 3),
	LatestDefect_ID int,
	LatestDefect_Date datetime,
	LatestDefect_Cycles decimal(18,3)
)
AS
BEGIN
	DECLARE  @OrderedDefects TABLE (ID int, CreatedDate datetime, Cycles decimal(18, 3), Top1 int, Bottom1 int)
	INSERT INTO @OrderedDefects
	SELECT	d.ID,
			d.CreatedDate,
			MAX(lce.LifeTotal),
			ROW_NUMBER() OVER (ORDER BY d.CreatedDate, lce.LifeTotal),
			ROW_NUMBER() OVER (ORDER BY CreatedDate DESC, lce.LifeTotal DESC)
	FROM	tDefect d
	JOIN	tReg r ON d.tReg_ID = r.ID 
	JOIN	tRegJourneyLogBook ON d.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
	JOIN	tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
	JOIN	tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID and tLifeCode.RegJourneyLandings = 1
	WHERE	r.ID = @Reg_ID
	AND		d.tATA_ID = @ATA_ID
	GROUP BY d.ID, d.CreatedDate, lce.LifeTotal

	INSERT INTO @Defects
	SELECT	odTop.ID,
			odTop.CreatedDate,
			odTop.Cycles,
			odBottom.ID,
			odBottom.CreatedDate,
			odBottom.Cycles
	FROM	@OrderedDefects odTop
	JOIN	@OrderedDefects odBottom ON odTop.Top1 = odBottom.Bottom1
	WHERE	odTop.Top1 = 1;

	RETURN 
END
GO

