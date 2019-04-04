/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliability_NOCALC]    Script Date: 04/03/2019 09:09:49 ******/
DROP PROCEDURE IF EXISTS dbo.sptUpdateRelRepSystemReliability_NOCALC
GO
/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliability_NOCALC]    Script Date: 04/03/2019 09:09:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jamie Hanna
-- =============================================
CREATE PROCEDURE [dbo].[sptUpdateRelRepSystemReliability_NOCALC] 
	
	@FromDate datetime,
	@ToDate datetime

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Start datetime = GETUTCDATE()
	DECLARE @TempTable TABLE 
	(
		[Lock] [bit] NOT NULL,
		[tReliabilityFleet_ID] [int] NULL,
		[Type] [nvarchar](50) NOT NULL,
		[tDefect_ID] [int] NOT NULL,
		[tRegJourney_ID] [int] NULL,
		[DefectDate] [datetime] NULL,
		[DefectDescription] [nvarchar](4000) NULL,
		[NonChargeable] [bit] NULL,
		[tATA_ID] [int] NULL,
		[ATADescription] [nvarchar](4000) NULL,
		[tReg_ID] [INT] NULL,
		[CarriedOutText] [nvarchar](4000) NULL,
		[MonthKey] [nvarchar](10) NULL,
		[Quarter] [nvarchar](10) NULL,
		[tDefectStatus_ID] [int] NULL,
		[aOperator_ID] [nvarchar](10) NULL,
		[uRALBase_ID] [int] NULL,
		[tModel_ID] [INT] NULL,
		[Cycles] [decimal](18, 0) NULL
	)

	INSERT INTO @TempTable 
	(
		Lock,
		tReliabilityFleet_ID,
		Type,
		tDefect_ID,
		tRegJourney_ID,
		DefectDate,
		DefectDescription,
		NonChargeable,
		tATA_ID,
		ATADescription,
		tReg_ID,
		CarriedOutText,
		MonthKey,
		Quarter,
		tDefectStatus_ID,
		aOperator_ID,
		uRALBase_ID,
		tModel_ID,
		Cycles
	)

	SELECT	1,
			tReg.tReliabilityFleet_ID,
			'Defect',
			tDefect.ID,
			tDefect.tRegJourney_ID,
			CAST(tDefect.CreatedDate as [date]),
			tDefect.Description,
			tDefect.ExcludeReliability,
			tATA.ID,
			tATA.Description,
			tReg.ID,
			ClosureTask.CarriedOutText,
			UPPER(LEFT(CAST(DATENAME(mm,tDefect.CreatedDate) AS nvarchar),3)) + '-' + RIGHT(CAST(DATEPART(yy,tDefect.CreatedDate) AS nvarchar),2),
			'Q' + CAST(DATEPART(q,tDefect.CreatedDate) AS nvarchar),
			tDefect.tDefectStatus_ID,
			tReg.aOperator_ID,
			tDefect.uRALBase_IDReportedFrom,
			tAsset.tModel_ID,
			usage.LifeTotal

	FROM	tDefect
	JOIN	tATA ON tDefect.tATA_ID = tATA.ID
	JOIN	tReg ON tDefect.tReg_ID = tReg.ID
	JOIN	tAsset ON tReg.tAsset_ID = tAsset.ID
	LEFT JOIN	sOrderTask ClosureTask ON ClosureTask.tDefect_ID = tDefect.ID
	JOIN	(
				SELECT	tDefect.ID,
						tRegJourneyLogBookLifeCodeEvents.LifeTotal
				FROM	tDefect
				JOIN	tRegJourneyLogBook ON tDefect.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
				JOIN	tRegJourneyLogBookLifeCodeEvents ON tRegJourneyLogBook.ID = tRegJourneyLogBookLifeCodeEvents.tRegJourneyLogBook_ID
				JOIN	tLifeCode on tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID = tLifeCode.ID and tLifeCode.RegJourneyLandings = 1
				join	tLogBook on tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
				join	tAsset on tLogBook.tAsset_ID = tAsset.ID
				join	tModel on tAsset.tModel_ID = tModel.ID
				join	tModelType on tModel.tModelType_ID = tModelType.ID
				WHERE	tModelType.RegAsset = 1
			) usage ON tDefect.ID = usage.ID


	UNION ALL

	SELECT	1,
			tReg.tReliabilityFleet_ID,
			'NRC',
			sNRCTask.ID as sNRCTask_ID,
			tRegJourney.ID as tRegJourney_ID,
			sNRC.ReportedDate,
			sNRCTask.LongDescription,
			sNRC.ExcludeReliability,
			tATA.ID,
			tATA.Description as ATADescription,
			tReg.ID as tReg_ID,
			sOrderTask.CarriedOutText,
			CONCAT(LEFT(DATENAME(MM, sNRC.ReportedDate), 3), '-', DATEPART(YY, sNRC.ReportedDate)) as MonthKey,
			CONCAT('Q', DATEPART(Q, sNRC.ReportedDate)) as Quarter,
			sNRC.sNRCStatus_ID,
			tReg.aOperator_ID,
			sOrder.uRALBase_ID,
			tAsset.tModel_ID,
			usage.LifeTotal
	FROM	sNRCTask
	JOIN	sNRC on sNRCTask.sNRC_ID = sNRC.ID
	JOIN	sOrderTask on sNRCTask.sOrderTask_ID = sOrderTask.ID
	LEFT JOIN	tRegJourney on sOrderTask.tRegJourney_ID = tRegJourney.ID
	LEFT JOIN	tReg ON tRegJourney.tReg_ID = tReg.ID
	LEFT JOIN	tAsset on tReg.tAsset_ID = tAsset.ID
	LEFT JOIN	tATA on sOrderTask.tATA_ID = tATA.ID
	JOIN	sOrder on sOrderTask.sOrder_ID = sOrder.ID
	LEFT JOIN	(
					SELECT	tRegJourney.ID,
							tRegJourneyLogBookLifeCodeEvents.LifeTotal
					FROM	tRegJourney
					JOIN	tRegJourneyLogBook ON tRegJourney.ID = tRegJourneyLogBook.tRegJourney_ID
					JOIN	tRegJourneyLogBookLifeCodeEvents ON tRegJourneyLogBook.ID = tRegJourneyLogBookLifeCodeEvents.tRegJourneyLogBook_ID
					JOIN	tLifeCode ON tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID = tLifeCode.ID and tLifeCode.RegJourneyLandings = 1
					JOIN	tLogBook on tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
					JOIN	tAsset on tLogBook.tAsset_ID = tAsset.ID
					JOIN	tModel on tAsset.tModel_ID = tModel.ID
					JOIN	tModelType on tModel.tModelType_ID = tModelType.ID
					WHERE	tModelType.RegAsset = 1
				) usage ON tRegJourney.ID = usage.ID

	DECLARE @IdBeforeUpdate int = (SELECT IDENT_CURRENT('tRelRepSystemReliability'))
	DECLARE @ErrorMessage nvarchar (200) = 'Updated Succesfully'
	BEGIN TRANSACTION
	BEGIN TRY
			
		DELETE FROM tRelRepSystemReliability
		WHERE		Lock = 0

		INSERT INTO tRelRepSystemReliability
		(
			Lock,
			tReliabilityFleet_ID,
			Type,
			tDefect_ID,
			tRegJourney_ID,
			DefectDate,
			DefectDescription,
			NonChargeable,
			tATA_ID,
			ATADescription,
			tReg_ID,
			CarriedOutText,
			MonthKey,
			Quarter,
			tDefectStatus_ID,
			aOperator_ID,
			uRALBase_ID,
			tModel_ID,
			Cycles
		)

		SELECT	Lock,
				tReliabilityFleet_ID,
				Type,
				tDefect_ID,
				tRegJourney_ID,
				DefectDate,
				DefectDescription,
				NonChargeable,
				tATA_ID,
				ATADescription,
				tReg_ID,
				CarriedOutText,
				MonthKey,
				Quarter,
				tDefectStatus_ID,
				aOperator_ID,
				uRALBase_ID,
				tModel_ID,
				Cycles
		FROM 	@TempTable
		WHERE	tDefect_ID NOT IN (SELECT tDefect_ID FROM tRelRepSystemReliability)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @ErrorMessage = 'Update Failed'
	END CATCH

	INSERT INTO tRelRepUpdateLog (
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
					@Start,
					GETUTCDATE(),
					GETDATE(),
					GETDATE(),
					'tUpdateRelRepSystemReliability',
					ISNULL((SELECT IDENT_CURRENT('tRelRepSystemReliability')) - @IdBeforeUpdate ,0),
					ISNULL( (SELECT MAX(ID) FROM tDefect), 0),
					@ErrorMessage
			)
END
GO


