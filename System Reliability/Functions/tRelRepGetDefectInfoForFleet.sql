USE [TEST]
GO

/****** Object:  UserDefinedFunction [dbo].[tRelRepGetDefectInfoForFleet]    Script Date: 06/03/2019 14:33:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jamie Hanna
-- Create date: 
-- Description:	
-- =============================================
ALTER FUNCTION [dbo].[tRelRepGetDefectInfoForFleet] 
(
	-- Add the parameters for the function here
	@RelFleet_ID int, 
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
	-- Fill the table variable with the rows for your result set
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
	WHERE	r.tReliabilityFleet_ID = @RelFleet_ID
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

