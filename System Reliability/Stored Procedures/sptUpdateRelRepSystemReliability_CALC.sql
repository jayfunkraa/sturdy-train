/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliability_CALC]    Script Date: 06/03/2019 14:35:37 ******/
IF EXISTS (
	SELECT 	* 
	FROM 	sys.objects 
	WHERE 	object_id = OBJECT_ID(N'[dbo].[sptUpdateRelRepSystemReliability_CALC]') 
	AND 	type IN (N'P', N'PC', N'X') 
)
BEGIN 
	DROP PROCEDURE [dbo].[sptUpdateRelRepSystemReliability_CALC] 
END
/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliability_CALC]    Script Date: 06/03/2019 14:35:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jamie Hanna
-- =============================================
CREATE PROCEDURE [dbo].[sptUpdateRelRepSystemReliability_CALC] 
	
	@FromDate datetime,
	@ToDate datetime

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Start datetime = GETUTCDATE()
	DECLARE @IdBeforeUpdate int = (SELECT IDENT_CURRENT('tRelRepSystemReliability'))
	DECLARE @ErrorMessage nvarchar (200) = 'Updated Succesfully'
	
	BEGIN TRANSACTION
	BEGIN TRY

		UPDATE tRelRepSystemReliability
			SET	FirstDefectOnRegDate = CASE
				WHEN Type = 'Defect' THEN
					(
						SELECT TOP 1	d.CreatedDate
						FROM			tDefect d
						JOIN			tReg r ON d.tReg_ID = r.ID 
						JOIN			tRegJourneyLogBook ON d.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
						JOIN			tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
						JOIN			tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
						WHERE			r.ID = tRelRepSystemReliability.tReg_ID
						AND				d.tATA_ID = tRelRepSystemReliability.tATA_ID
						GROUP BY		d.ID, d.CreatedDate, lce.LifeTotal
						ORDER BY		d.CreatedDate
					)
				WHEN Type = 'NRC' THEN
					(
						SELECT TOP 1	n.ReportedDate
						FROM			sNRCTask t
						JOIN			sNRC n on t.sNRC_ID = n.ID
						JOIN			sOrderTask ot on t.sOrderTask_ID = ot.ID
						JOIN			sOrder o on ot.sOrder_ID = o.ID
						WHERE			o.tReg_ID = tRelRepSystemReliability.tReg_ID
						AND				ot.tATA_ID = tRelRepSystemReliability.tATA_ID
						GROUP BY		o.tReg_ID, n.ReportedDate
						ORDER BY		n.ReportedDate
					)
				ELSE NULL
				END,
				FirstDefectOnFleetDate = CASE
					WHEN Type = 'Defect' THEN
						(
						SELECT TOP 1	d.CreatedDate
						FROM			tDefect d
						JOIN			tReg r ON d.tReg_ID = r.ID 
						JOIN			tRegJourneyLogBook ON d.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
						JOIN			tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
						JOIN			tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
						WHERE			r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
						AND				d.tATA_ID = tRelRepSystemReliability.tATA_ID
						GROUP BY		d.ID, d.CreatedDate, lce.LifeTotal
						ORDER BY		d.CreatedDate
						)
					WHEN Type = 'NRC' THEN
						(
							SELECT TOP 1	n.ReportedDate
							FROM			sNRCTask t
							JOIN			sNRC n on t.sNRC_ID = n.ID
							JOIN			sOrderTask ot on t.sOrderTask_ID = ot.ID
							JOIN			sOrder o on ot.sOrder_ID = o.ID
							WHERE			o.tReg_ID = tRelRepSystemReliability.tReg_ID
							AND				ot.tATA_ID = tRelRepSystemReliability.tATA_ID
							GROUP BY		o.tReg_ID, n.ReportedDate
							ORDER BY		n.ReportedDate
						)
					ELSE NULL
					END

			UPDATE tRelRepSystemReliability
			SET DefectsPerReg = (
					SELECT	COUNT(*) 
					FROM	tRelRepSystemReliability r
					WHERE	r.DefectDate BETWEEN tRelRepSystemReliability.FirstDefectOnRegDate AND tRelRepSystemReliability.DefectDate
					AND 	r.tReg_ID = tRelRepSystemReliability.tReg_ID
					AND 	r.tATA_ID = tRelRepSystemReliability.tATA_ID
				),
				DefectsPerFleet = (
					SELECT	COUNT(*)
					FROM	tRelRepSystemReliability r
					WHERE	r.DefectDate BETWEEN tRelRepSystemReliability.FirstDefectOnFleetDate AND tRelRepSystemReliability.DefectDate
					AND		r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
					AND		r.tATA_ID = tRelRepSystemReliability.tATA_ID
				),
				RegFlightCycles = (
					SELECT	IIF(tRelRepSystemReliability.FirstDefectOnRegDate = tRelRepSystemReliability.DefectDate, 0, SUM(lce.LifeUsage))
					FROM	tRegJourney rj
					JOIN	tRegJourneyLogBook ON rj.ID = tRegJourneyLogBook.tRegJourney_ID
					JOIN	tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
					JOIN	tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
					JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
					JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
					JOIN	tModel ON tAsset.tModel_ID = tModel.ID
					JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
					WHERE	tModelType.RegAsset = 1
					AND		rj.ID <> (SELECT TOP 1 tRegJourney_ID from tDefect WHERE ID = tRelRepSystemReliability.tDefect_ID)
					AND		rj.tReg_ID = tRelRepSystemReliability.tReg_ID
					AND		rj.JourneyDate BETWEEN tRelRepSystemReliability.FirstDefectOnRegDate AND tRelRepSystemReliability.DefectDate
				),
				FleetFlightCycles = (
					SELECT	IIF(tRelRepSystemReliability.FirstDefectOnFleetDate = tRelRepSystemReliability.DefectDate, 0, SUM(lce.LifeUsage))
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
					AND		rj.ID <> (SELECT TOP 1 tRegJourney_ID from tDefect WHERE ID = tRelRepSystemReliability.tDefect_ID)
					AND		r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
					AND		rj.JourneyDate BETWEEN tRelRepSystemReliability.FirstDefectOnFleetDate AND tRelRepSystemReliability.DefectDate
				)

			UPDATE tRelRepSystemReliability
			SET	RegDefectsPer100FC = IIF(RegFlightCycles > 0, (DefectsPerReg / RegFlightCycles) * 100, NULL),
				FleetDefectsPer100FC = IIF(FleetFlightCycles > 0, (DefectsPerFleet / FleetFlightCycles) * 100, NULL),
				FleetMonthDefects = (
					SELECT	COUNT(*)
					FROM	tRelRepSystemReliability r
					WHERE	DATEPART(MM, tRelRepSystemReliability.DefectDate) = DATEPART(MM, r.DefectDate)
					AND		tRelRepSystemReliability.tATA_ID = r.tATA_ID
				),
				FleetMonthCycles = (
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
					AND 	DATEPART(YYYY, rj.JourneyDate) = DATEPART(YYYY, tRelRepSystemReliability.DefectDate)
					AND		DATEPART(MM, rj.JourneyDate) = DATEPART(MM, tRelRepSystemReliability.DefectDate)
				)
			UPDATE tRelRepSystemReliability
			SET	FleetMonthDefectsPer100FC = 
					IIF(tRelRepSystemReliability.FleetMonthCycles > 0, 
					(tRelRepSystemReliability.FleetMonthDefects / tRelRepSystemReliability.FleetMonthCycles) * 100, NULL),
				tRelRepAlertLevel_ID = (
					SELECT 	TOP 1 ID
					FROM	tRelRepAlertLevel
					WHERE	Year = DATEPART(YYYY, tRelRepSystemReliability.DefectDate)
					AND		tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
					AND		ATAChapter = tRelRepSystemReliability.ATAChapter
				)
	
	COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @ErrorMessage = 'Update Failed'
	END CATCH

	INSERT INTO tRelRepUpdateLog (
		FromDate,
		ToDate,
		UpdateStart,
		UpdateEnd,
		RecordTimeStamp,
		RecordTimeStampCreated,
		ProcessName,
		NumberOFRecords,
		MaxIDBaseTable,
		UpdateLog
		)
		VALUES (
			@FromDate,
			@ToDate,
			@Start,
			GETUTCDATE(),
			GETDATE(),
			GETDATE(),
			'tUpdateRelRepSystemReliability_CALC',
			ISNULL((SELECT IDENT_CURRENT('tRelRepSystemReliability')) - @IdBeforeUpdate ,0),
			ISNULL( (SELECT MAX(ID) FROM tDefect), 0),
			@ErrorMessage
			)
END
GO