USE [TEST]
GO
/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliability_CALC]    Script Date: 06/03/2019 14:35:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jamie Hanna
-- =============================================
ALTER PROCEDURE [dbo].[sptUpdateRelRepSystemReliability_CALC] 
	
	@FromDate datetime,
	@ToDate datetime

AS
BEGIN
	SET NOCOUNT ON;

-- FIRST DEFECT
---- REG
	update tRelRepSystemReliability
		set FirstDefectOnRegDate = (
									select	TOP 1 FirstDefect_Date
									from	tRelRepGetDefectInfoForReg(tRelRepSystemReliability.tReg_ID, tRelRepSystemReliability.tATA_ID)
								   )

---- FLEET
	update tRelRepSystemReliability
		set FirstDefectOnFleetDate = (	
									select	TOP 1 FirstDefect_Date
									from	tRelRepGetDefectInfoForFleet(tRelRepSystemReliability.tReliabilityFleet_ID, tRelRepSystemReliability.tATA_ID)
								  )

-- COUNT OF DEFECTS
	update tRelRepSystemReliability
		set DefectsPerReg = (	
								select	COUNT(*) 
								from	tRelRepSystemReliability r
								where	r.DefectDate between tRelRepSystemReliability.FirstDefectOnRegDate and tRelRepSystemReliability.DefectDate
											and r.tReg_ID = tRelRepSystemReliability.tReg_ID
											and r.tATA_ID = tRelRepSystemReliability.tATA_ID
							)
	update tRelRepSystemReliability
		set DefectsPerFleet = (			
								select	COUNT(*)
								from	tRelRepSystemReliability r
								where	r.DefectDate between tRelRepSystemReliability.FirstDefectOnFleetDate and tRelRepSystemReliability.DefectDate
											and r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
											and r.tATA_ID = tRelRepSystemReliability.tATA_ID
							   )

-- COUNT OF CYCLES

	update tRelRepSystemReliability
		set RegFlightCycles = Cycles - 
							  (
									select	TOP 1 FirstDefect_Cycles
									from	tRelRepGetDefectInfoForReg(tReg_ID, tATA_ID)
							  )
		
	update tRelRepSystemReliability
		set FleetFlightCycles = (	
									SELECT	SUM(lce.LifeUsage)
									FROM	tDefect d
									JOIN	tReg r ON d.tReg_ID = r.ID 
									JOIN	tRegJourneyLogBook ON d.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
									JOIN	tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
									JOIN	tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
									WHERE	r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
									AND		d.tATA_ID = tRelRepSystemReliability.tATA_ID
									AND		CreatedDate BETWEEN tRelRepSystemReliability.FirstDefectOnFleetDate AND tRelRepSystemReliability.DefectDate
								)					   

-- DEFECTS PER 100FC
	update tRelRepSystemReliability
		set RegDefectsPer100FC = IIF(RegFlightCycles > 0, (DefectsPerReg / RegFlightCycles) * 100, 0)

	update tRelRepSystemReliability
		set FleetDefectsPer100FC = IIF(FleetFlightCycles > 0, (DefectsPerFleet / FleetFlightCycles) * 100, 0)

-- FLEET ANNUAL FIGURES
	update tRelRepSystemReliability
		set FleetAnnualDefects = (
									select	COUNT(*)
									from	tRelRepSystemReliability r
									where	DATEPART(YYYY, tRelRepSystemReliability.DefectDate) = DATEPART(YYYY, r.DefectDate)
												and tRelRepSystemReliability.tATA_ID = r.tATA_ID
								  )
	update tRelRepSystemReliability
		set FleetAnnualCycles = (
									SELECT	SUM(lce.LifeUsage)
									FROM	tDefect d
									JOIN	tReg r ON d.tReg_ID = r.ID 
									JOIN	tRegJourneyLogBook ON d.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
									JOIN	tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
									JOIN	tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
									WHERE	r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
									AND		d.tATA_ID = tRelRepSystemReliability.tATA_ID
									AND		DATEPART(YYYY, CreatedDate) = DATEPART(YYYY, tRelRepSystemReliability.DefectDate)
								)
	update tRelRepSystemReliability
		set Mean = IIF(FleetAnnualCycles > 0, (FleetAnnualDefects / FleetAnnualCycles) * 100, 0)
	update tRelRepSystemReliability
		set UCL20 = Mean * 2, UCL25 = Mean * 2.5, UCL30 = Mean * 3

	
END
