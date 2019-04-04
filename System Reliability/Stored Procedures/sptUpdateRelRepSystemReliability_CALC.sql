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
		set RegFlightCycles = (
			SELECT	SUM(lce.LifeUsage)
			FROM	tDefect
			JOIN	tRegJourney rj on tDefect.tRegJourney_ID = rj.ID
			JOIN	tReg r ON rj.tReg_ID = r.ID
			JOIN	tRegJourneyLogBook ON rj.ID = tRegJourneyLogBook.tRegJourney_ID
			JOIN	tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
			JOIN	tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
			JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
			JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
			JOIN	tModel ON tAsset.tModel_ID = tModel.ID
			JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
			WHERE	tModelType.RegAsset = 1
			AND		tDefect.ID <> tRelRepSystemReliability.tDefect_ID
			AND		r.ID = tRelRepSystemReliability.tReg_ID
			AND		tDefect.CreatedDate BETWEEN tRelRepSystemReliability.FirstDefectOnRegDate AND tRelRepSystemReliability.DefectDate
		)
		
	update tRelRepSystemReliability
		set FleetFlightCycles = (	
									SELECT	SUM(lce.LifeUsage)
									FROM	tRegJourney rj
									JOIN	tReg r ON rj.tReg_ID = r.ID
									JOIN	tRegJourneyLogBook ON rj.ID = tRegJourneyLogBook.tRegJourney_ID
									JOIN	tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
									JOIN	tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
									JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
									JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
									JOIN	tModel ON tAsset.tModel_ID = tModel.ID
									JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
									WHERE	tModelType.RegAsset = 1
									AND		r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
									AND		rj.JourneyDate BETWEEN tRelRepSystemReliability.FirstDefectOnFleetDate AND tRelRepSystemReliability.DefectDate
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
									FROM	tRegJourney rj
									JOIN	tReg r ON rj.tReg_ID = r.ID 
									JOIN	tRegJourneyLogBook ON rj.ID = tRegJourneyLogBook.tRegJourney_ID
									JOIN	tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
									JOIN	tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
									JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
									JOIN	tAsset on tLogBook.tAsset_ID = tAsset.ID
									JOIN	tModel on tAsset.tModel_ID = tModel.ID
									JOIN	tModelType on tModel.tModelType_ID = tModelType.ID
									WHERE	tModelType.RegAsset = 1
									AND		r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
									AND		DATEPART(YYYY, rj.JourneyDate) = DATEPART(YYYY, tRelRepSystemReliability.DefectDate)
								)
	UPDATE tRelRepSystemReliability
		SET FleetMonthDefects = (
									select	COUNT(*)
									from	tRelRepSystemReliability r
									where	DATEPART(MM, tRelRepSystemReliability.DefectDate) = DATEPART(MM, r.DefectDate)
												and tRelRepSystemReliability.tATA_ID = r.tATA_ID
								  )

	UPDATE tRelRepSystemReliability
		SET FleetMonthCycles = (
									SELECT	SUM(lce.LifeUsage)
									FROM	tRegJourney rj
									JOIN	tReg r ON rj.tReg_ID = r.ID 
									JOIN	tRegJourneyLogBook ON rj.ID = tRegJourneyLogBook.tRegJourney_ID
									JOIN	tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
									JOIN	tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
									JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
									JOIN	tAsset on tLogBook.tAsset_ID = tAsset.ID
									JOIN	tModel on tAsset.tModel_ID = tModel.ID
									JOIN	tModelType on tModel.tModelType_ID = tModelType.ID
									WHERE	tModelType.RegAsset = 1
									AND		r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
									AND 	DATEPART(YYYY, rj.JourneyDate) = DATEPART(YYYY, tRelRepSystemReliability.DefectDate)
									AND		DATEPART(MM, rj.JourneyDate) = DATEPART(MM, tRelRepSystemReliability.DefectDate)
								)

	UPDATE tRelRepSystemReliability
		SET FleetMonthDefectsPer100FC = IIF(tRelRepSystemReliability.FleetMonthCycles > 0, (tRelRepSystemReliability.FleetMonthDefects / tRelRepSystemReliability.FleetMonthCycles) * 100, 0)
END
