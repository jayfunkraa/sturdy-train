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
			SET	FirstDefectOnRegDateChapter = CASE
				WHEN Type = 'Defect' THEN
					(
						SELECT TOP 1	d.CreatedDate
						FROM			tDefect d
						JOIN			tATA ON d.tATA_ID = tATA.ID
						JOIN			tReg r ON d.tReg_ID = r.ID 
						JOIN			tRegJourneyLogBook ON d.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
						JOIN			tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
						JOIN			tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
						WHERE			r.ID = tRelRepSystemReliability.tReg_ID
						AND				tATA.ATAChapter = tRelRepSystemReliability.ATAChapter
						GROUP BY		d.ID, d.CreatedDate, lce.LifeTotal
						ORDER BY		d.CreatedDate
					)
				WHEN Type = 'NRC' THEN
					(
						SELECT TOP 1	n.ReportedDate
						FROM			sNRCTask t
						JOIN			sNRC n ON t.sNRC_ID = n.ID
						JOIN			sOrderTask ot ON t.sOrderTask_ID = ot.ID
						JOIN			tATA ON ot.tATA_ID = tATA.ID
						JOIN			sOrder o ON ot.sOrder_ID = o.ID
						WHERE			o.tReg_ID = tRelRepSystemReliability.tReg_ID
						AND				tATA.ATAChapter = tRelRepSystemReliability.ATAChapter
						GROUP BY		o.tReg_ID, n.ReportedDate
						ORDER BY		n.ReportedDate
					)
				ELSE NULL
				END,
				FirstDefectOnRegDateSystem = CASE
				WHEN Type = 'Defect' THEN
					(
						SELECT TOP 1	d.CreatedDate
						FROM			tDefect d
						JOIN			tATA ON d.tATA_ID = tATA.ID
						JOIN			tReg r ON d.tReg_ID = r.ID 
						JOIN			tRegJourneyLogBook ON d.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
						JOIN			tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
						JOIN			tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
						WHERE			r.ID = tRelRepSystemReliability.tReg_ID
						AND				tATA.ATAChapter = tRelRepSystemReliability.ATAChapter
						AND				tATA.ATASystem = tRelRepSystemReliability.ATASystem
						GROUP BY		d.ID, d.CreatedDate, lce.LifeTotal
						ORDER BY		d.CreatedDate
					)
				WHEN Type = 'NRC' THEN
					(
						SELECT TOP 1	n.ReportedDate
						FROM			sNRCTask t
						JOIN			sNRC n ON t.sNRC_ID = n.ID
						JOIN			sOrderTask ot ON t.sOrderTask_ID = ot.ID
						JOIN			tATA ON ot.tATA_ID = tATA.ID
						JOIN			sOrder o ON ot.sOrder_ID = o.ID
						WHERE			o.tReg_ID = tRelRepSystemReliability.tReg_ID
						AND				tATA.ATAChapter = tRelRepSystemReliability.ATAChapter
						AND				tATA.ATASystem = tRelRepSystemReliability.ATASystem
						GROUP BY		o.tReg_ID, n.ReportedDate
						ORDER BY		n.ReportedDate
					)
				ELSE NULL
				END,
				FirstDefectOnFleetDateChapter = CASE
					WHEN Type = 'Defect' THEN
						(
						SELECT TOP 1	d.CreatedDate
						FROM			tDefect d
						JOIN			tATA ON d.tATA_ID = tATA.ID
						JOIN			tReg r ON d.tReg_ID = r.ID 
						JOIN			tRegJourneyLogBook ON d.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
						JOIN			tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
						JOIN			tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
						WHERE			r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
						AND				tATA.ATAChapter = tRelRepSystemReliability.ATAChapter
						GROUP BY		d.ID, d.CreatedDate, lce.LifeTotal
						ORDER BY		d.CreatedDate
						)
					WHEN Type = 'NRC' THEN
						(
							SELECT TOP 1	n.ReportedDate
							FROM			sNRCTask t
							JOIN			sNRC n ON t.sNRC_ID = n.ID
							JOIN			sOrderTask ot ON t.sOrderTask_ID = ot.ID
							JOIN			tATA ON ot.tATA_ID = tATA.ID
							JOIN			sOrder o ON ot.sOrder_ID = o.ID
							WHERE			o.tReg_ID = tRelRepSystemReliability.tReg_ID
							AND				tATA.ATAChapter = tRelRepSystemReliability.ATAChapter
							GROUP BY		o.tReg_ID, n.ReportedDate
							ORDER BY		n.ReportedDate
						)
					ELSE NULL
					END,
					FirstDefectOnFleetDateSystem = CASE
					WHEN Type = 'Defect' THEN
						(
						SELECT TOP 1	d.CreatedDate
						FROM			tDefect d
						JOIN			tATA ON d.tATA_ID = tATA.ID
						JOIN			tReg r ON d.tReg_ID = r.ID 
						JOIN			tRegJourneyLogBook ON d.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
						JOIN			tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
						JOIN			tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
						WHERE			r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
						AND				tATA.ATAChapter = tRelRepSystemReliability.ATAChapter
						AND				tATA.ATASystem = tRelRepSystemReliability.ATASystem
						GROUP BY		d.ID, d.CreatedDate, lce.LifeTotal
						ORDER BY		d.CreatedDate
						)
					WHEN Type = 'NRC' THEN
						(
							SELECT TOP 1	n.ReportedDate
							FROM			sNRCTask t
							JOIN			sNRC n ON t.sNRC_ID = n.ID
							JOIN			sOrderTask ot ON t.sOrderTask_ID = ot.ID
							JOIN			tATA ON ot.tATA_ID = tATA.ID
							JOIN			sOrder o ON ot.sOrder_ID = o.ID
							WHERE			o.tReg_ID = tRelRepSystemReliability.tReg_ID
							AND				tATA.ATAChapter = tRelRepSystemReliability.ATAChapter
							AND				tATA.ATASystem = tRelRepSystemReliability.ATASystem
							GROUP BY		o.tReg_ID, n.ReportedDate
							ORDER BY		n.ReportedDate
						)
					ELSE NULL
					END

			UPDATE tRelRepSystemReliability
			SET DefectsPerRegChapter = (
					SELECT	COUNT(*) 
					FROM	tRelRepSystemReliability r
					WHERE	r.DefectDate BETWEEN tRelRepSystemReliability.FirstDefectOnRegDateChapter AND tRelRepSystemReliability.DefectDate
					AND 	r.tReg_ID = tRelRepSystemReliability.tReg_ID
					AND 	r.ATAChapter = tRelRepSystemReliability.ATAChapter
				),
				DefectsPerRegSystem = (
					SELECT	COUNT(*) 
					FROM	tRelRepSystemReliability r
					WHERE	r.DefectDate BETWEEN tRelRepSystemReliability.FirstDefectOnRegDateSystem AND tRelRepSystemReliability.DefectDate
					AND 	r.tReg_ID = tRelRepSystemReliability.tReg_ID
					AND 	r.ATAChapter = tRelRepSystemReliability.ATAChapter
					AND		r.ATASystem = tRelRepSystemReliability.ATASystem
				),
				DefectsPerFleetChapter = (
					SELECT	COUNT(*)
					FROM	tRelRepSystemReliability r
					WHERE	r.DefectDate BETWEEN tRelRepSystemReliability.FirstDefectOnFleetDateChapter AND tRelRepSystemReliability.DefectDate
					AND		r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
					AND		r.ATAChapter = tRelRepSystemReliability.ATAChapter
				),
				DefectsPerFleetSystem = (
					SELECT	COUNT(*)
					FROM	tRelRepSystemReliability r
					WHERE	r.DefectDate BETWEEN tRelRepSystemReliability.FirstDefectOnFleetDateSystem AND tRelRepSystemReliability.DefectDate
					AND		r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
					AND		r.ATAChapter = tRelRepSystemReliability.ATAChapter
					AND		r.ATASystem = tRelRepSystemReliability.ATASystem
				),
				RegFlightCyclesChapter = (
					SELECT	IIF(tRelRepSystemReliability.FirstDefectOnRegDateChapter = tRelRepSystemReliability.DefectDate, 0, SUM(lce.LifeUsage))
					FROM	tRegJourney rj
					JOIN	tRegJourneyLogBook ON rj.ID = tRegJourneyLogBook.tRegJourney_ID
					JOIN	tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
					JOIN	tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
					JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
					JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
					JOIN	tModel ON tAsset.tModel_ID = tModel.ID
					JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
					WHERE	tModelType.RegAsset = 1
					AND		rj.ID <> (SELECT TOP 1 tRegJourney_ID FROM tDefect WHERE ID = tRelRepSystemReliability.RecordID)
					AND		rj.tReg_ID = tRelRepSystemReliability.tReg_ID
					AND		rj.JourneyDate BETWEEN tRelRepSystemReliability.FirstDefectOnRegDateChapter AND tRelRepSystemReliability.DefectDate
				),
				RegFlightCyclesSystem = (
					SELECT	IIF(tRelRepSystemReliability.FirstDefectOnRegDateSystem = tRelRepSystemReliability.DefectDate, 0, SUM(lce.LifeUsage))
					FROM	tRegJourney rj
					JOIN	tRegJourneyLogBook ON rj.ID = tRegJourneyLogBook.tRegJourney_ID
					JOIN	tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
					JOIN	tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
					JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
					JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
					JOIN	tModel ON tAsset.tModel_ID = tModel.ID
					JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
					WHERE	tModelType.RegAsset = 1
					AND		rj.ID <> (SELECT TOP 1 tRegJourney_ID FROM tDefect WHERE ID = tRelRepSystemReliability.RecordID)
					AND		rj.tReg_ID = tRelRepSystemReliability.tReg_ID
					AND		rj.JourneyDate BETWEEN tRelRepSystemReliability.FirstDefectOnRegDateSystem AND tRelRepSystemReliability.DefectDate
				),
				FleetFlightCyclesChapter = (
					SELECT	IIF(tRelRepSystemReliability.FirstDefectOnFleetDateChapter = tRelRepSystemReliability.DefectDate, 0, SUM(lce.LifeUsage))
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
					AND		rj.ID <> (SELECT TOP 1 tRegJourney_ID FROM tDefect WHERE ID = tRelRepSystemReliability.RecordID)
					AND		r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
					AND		rj.JourneyDate BETWEEN tRelRepSystemReliability.FirstDefectOnFleetDateChapter AND tRelRepSystemReliability.DefectDate
				),
				FleetFlightCyclesSystem = (
					SELECT	IIF(tRelRepSystemReliability.FirstDefectOnFleetDateSystem = tRelRepSystemReliability.DefectDate, 0, SUM(lce.LifeUsage))
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
					AND		rj.ID <> (SELECT TOP 1 tRegJourney_ID FROM tDefect WHERE ID = tRelRepSystemReliability.RecordID)
					AND		r.tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
					AND		rj.JourneyDate BETWEEN tRelRepSystemReliability.FirstDefectOnFleetDateSystem AND tRelRepSystemReliability.DefectDate
				)

			UPDATE tRelRepSystemReliability
			SET	RegDefectsPer100FCChapter = IIF(RegFlightCyclesChapter > 0, (DefectsPerRegChapter / RegFlightCyclesChapter) * 100, NULL),
				RegDefectsPer100FCSystem = IIF(RegFlightCyclesSystem > 0, (DefectsPerRegSystem / RegFlightCyclesSystem) * 100, NULL),
				FleetDefectsPer100FCChapter = IIF(FleetFlightCyclesChapter > 0, (DefectsPerFleetChapter / FleetFlightCyclesChapter) * 100, NULL),
				FleetDefectsPer100FCSystem = IIF(FleetFlightCyclesSystem > 0, (DefectsPerFleetSystem / FleetFlightCyclesSystem) * 100, NULL),
				FleetMonthDefectsChapter = (
					SELECT	COUNT(*)
					FROM	tRelRepSystemReliability r
					WHERE	DATEPART(MM, tRelRepSystemReliability.DefectDate) = DATEPART(MM, r.DefectDate)
					AND		tRelRepSystemReliability.ATAChapter = r.ATAChapter
				),
				FleetMonthDefectsSystem = (
					SELECT	COUNT(*)
					FROM	tRelRepSystemReliability r
					WHERE	DATEPART(MM, tRelRepSystemReliability.DefectDate) = DATEPART(MM, r.DefectDate)
					AND		tRelRepSystemReliability.ATAChapter = r.ATAChapter
					AND		tRelRepSystemReliability.ATASystem = r.ATASystem
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
			SET	FleetMonthDefectsPer100FCChapter = 
					IIF(tRelRepSystemReliability.FleetMonthCycles > 0, 
					(tRelRepSystemReliability.FleetMonthDefectsChapter / tRelRepSystemReliability.FleetMonthCycles) * 100, NULL),
				FleetMonthDefectsPer100FCSystem = 
					IIF(tRelRepSystemReliability.FleetMonthCycles > 0, 
					(tRelRepSystemReliability.FleetMonthDefectsSystem / tRelRepSystemReliability.FleetMonthCycles) * 100, NULL),
				tRelRepAlertLevel_ID = (
					SELECT 	TOP 1 ID
					FROM	tRelRepAlertLevel
					WHERE	Year = DATEPART(YYYY, tRelRepSystemReliability.DefectDate)
					AND		tReliabilityFleet_ID = tRelRepSystemReliability.tReliabilityFleet_ID
					AND		ATAChapter = tRelRepSystemReliability.ATAChapter
				)

			UPDATE tRelRepSystemReliability
			SET FirstDefectOnRegDateFormattedChapter = CONVERT(nvarchar, FirstDefectOnRegDateChapter, 103),
				FirstDefectOnRegDateFormattedSystem = CONVERT(nvarchar, FirstDefectOnRegDateSystem, 103),

				FirstDefectOnFleetDateFormattedChapter = CONVERT(nvarchar, FirstDefectOnFleetDateChapter, 103),
				FirstDefectOnFleetDateFormattedSystem = CONVERT(nvarchar, FirstDefectOnFleetDateSystem, 103)
	
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