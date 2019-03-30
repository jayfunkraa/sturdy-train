USE [TEST]
GO

/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliability_NOCALC]    Script Date: 04/03/2019 09:09:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Jamie Hanna
-- =============================================
ALTER PROCEDURE [dbo].[sptUpdateRelRepSystemReliability_NOCALC] 
	
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
		[tDefect_ID] [int] NOT NULL,
		[tRegJourney_ID] [int] NOT NULL,
		[DefectNo] [nvarchar](50) NULL,
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
		tDefect_ID,
		tRegJourney_ID,
		DefectNo,
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
			tDefect.ID,
			tDefect.tRegJourney_ID,
			tDefect.DefectItemNo,
			tDefect.CreatedDate,
			tDefect.Description,
			tDefect.ExcludeReliability,
			tATA.ID,
			tATA.Description,
			tReg.ID,
			ISNULL(ClosureTask.CarriedOutText,''),
			UPPER(LEFT(CAST(DATENAME(mm,GETDATE()) AS nvarchar),3)) + '-' + RIGHT(CAST(DATEPART(yy,GETDATE()) AS nvarchar),2),
			'Q' + CAST(DATEPART(q,tDefect.CreatedDate) AS nvarchar),
			tDefect.tDefectStatus_ID,
			tReg.aOperator_ID,
			tDefect.uRALBase_IDReportedFrom,
			tAsset.tModel_ID,
			usage.Usage

	FROM	tDefect
	JOIN	tATA ON tDefect.tATA_ID = tATA.ID
	JOIN	tReg ON tDefect.tReg_ID = tReg.ID
	JOIN	tAsset ON tReg.tAsset_ID = tAsset.ID
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
			tDefect_ID,
			tRegJourney_ID,
			DefectNo,
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
				tDefect_ID,
				tRegJourney_ID,
				DefectNo,
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


