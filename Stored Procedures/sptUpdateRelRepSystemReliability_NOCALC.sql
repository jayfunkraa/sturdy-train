USE [TEST]
GO

/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliability_NOCALC]    Script Date: 04/03/2019 09:09:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Jamie Hanna
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[sptUpdateRelRepSystemReliability_NOCALC] 
	
	@FromDate datetime,
	@ToDate datetime

AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO tRelRepSystemReliability (
											tReg_ID,
											tReliabilityFleet_ID,
											tATA_ID,
											tDefect_ID,
											DefectNo,
											DefectDate,
											Description,
											NonChargeable,
											ATA,
											ATADescription,
											Registration,
											CarriedOutText,
											Quarter,
											Closed,
											OperatorCode,
											Base,
											Model,
											Cycles
										 )
	SELECT	tDefect.tReg_ID,
			tReg.tReliabilityFleet_ID,
			tDefect.tATA_ID,
			tDefect.ID,
			tDefect.DefectItemNo,
			tDefect.CreatedDate,
			tDefect.Description,
			0 as NonChargeable,
			tATA.ATA,
			tATA.Description,
			tReg.Reg,
			ISNULL(ClosureTask.CarriedOutText,''),
			--CAST(DATEPART(mm,tDefect.CreatedDate) AS nvarchar) + '-' + RIGHT(CAST(DATEPART(yy,tDefect.CreatedDate) AS nvarchar),2) AS MonthKey,
			'Q' + CAST(DATEPART(q,tDefect.CreatedDate) AS nvarchar) AS Quarter,
			tDefect.Closed,
			aOperator.OperatorCode,
			ReportedBase.RALBase,
			tModel.Model,
			usage.Usage

	FROM	tDefect
	JOIN	tATA ON tDefect.tATA_ID = tATA.ID
	JOIN	tReg ON tDefect.tReg_ID = tReg.ID
	JOIN	aOperator ON tReg.aOperator_ID = aOperator.ID
	JOIN	uRALBase ReportedBase ON tDefect.uRALBase_IDReportedFrom = ReportedBase.ID
	JOIN	tAsset ON tReg.tAsset_ID = tAsset.ID
	JOIN	tModel ON tAsset.tModel_ID = tModel.ID
	LEFT JOIN	sOrderTask ClosureTask ON tDefect.sOrderTask_IDClosedAgainst= ClosureTask.ID
	JOIN	(
				SELECT	tDefect.ID,
						max(tRegJourneyLogBookLifeCodeEvents.LifeTotal) AS Usage
				FROM	tDefect
				JOIN	tRegJourneyLogBook ON tDefect.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
				JOIN	tRegJourneyLogBookLifeCodeEvents ON tRegJourneyLogBook.ID = tRegJourneyLogBookLifeCodeEvents.tRegJourneyLogBook_ID
				JOIN	tLifeCode on tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID = tLifeCode.ID and tLifeCode.RegJourneyLandings = 1
				GROUP BY tDefect.ID
			) usage ON tDefect.ID = usage.ID

	EXCEPT

	SELECT	tReg_ID,
			tReliabilityFleet_ID,
			tATA_ID,
			tDefect_ID,
			DefectNo COLLATE Latin1_General_BIN,
			DefectDate,
			Description COLLATE Latin1_General_BIN,
			NonChargeable,
			ATA COLLATE Latin1_General_BIN,
			ATADescription COLLATE Latin1_General_BIN,
			Registration COLLATE Latin1_General_BIN,
			CarriedOutText COLLATE Latin1_General_BIN,
			Quarter COLLATE Latin1_General_BIN,
			Closed,
			OperatorCode COLLATE Latin1_General_BIN,
			Base COLLATE Latin1_General_BIN,
			Model COLLATE Latin1_General_BIN,
			Cycles

	FROM	tRelRepSystemReliability

END
GO


