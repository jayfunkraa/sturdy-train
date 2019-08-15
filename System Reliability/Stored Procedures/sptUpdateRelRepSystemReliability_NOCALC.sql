/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliability_NOCALC]    Script Date: 04/03/2019 09:09:49 ******/
IF EXISTS (
	SELECT 	* 
	FROM 	sys.objects 
	WHERE 	object_id = OBJECT_ID(N'[dbo].[sptUpdateRelRepSystemReliability_NOCALC]') 
	AND 	type IN (N'P', N'PC', N'X') 
)
BEGIN 
	DROP PROCEDURE [dbo].[sptUpdateRelRepSystemReliability_NOCALC] 
END
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

	DECLARE @TempTable TABLE 
	(
		[Lock] [bit] NOT NULL,
		[tReliabilityFleet_ID] [int] NULL,
		[ReliabilityFleet] [nvarchar](100) NULL,
		[Type] [nvarchar](50) NOT NULL,
		[tDefect_ID] [int] NOT NULL,
		[ItemNo] [nvarchar](100) NOT NULL,
		[tRegJourney_ID] [int] NULL,
		[JourneyNo] [nvarchar](100) NOT NULL,
		[DefectDate] [datetime] NULL,
		[DefectDescription] [nvarchar](4000) NULL,
		[NonChargeable] [bit] NULL,
		[tATA_ID] [int] NULL,
		[ATAChapter] [int] NULL,
		[ATASystem] [int] NULL,
		[ATADescription] [nvarchar](4000) NULL,
		[tReg_ID] [INT] NULL,
		[Reg] [nvarchar](10) NULL,
		[CarriedOutText] [nvarchar](4000) NULL,
		[MonthKey] [nvarchar](10) NULL,
		[Quarter] [nvarchar](10) NULL,
		[tDefectStatus_ID] [int] NULL,
		[DefectStatus] [nvarchar](100) NULL,
		[aOperator_ID] [nvarchar](10) NULL,
		[Operator] [nvarchar](100) NULL,
		[uRALBase_ID] [int] NULL,
		[Base] [nvarchar](100) NULL,
		[tModel_ID] [INT] NULL,
		[Model] [nvarchar](200) NULL,
		[Cycles] [decimal](18, 0) NULL
	)

	INSERT INTO @TempTable 
	(
		Lock,
		tReliabilityFleet_ID,
		ReliabilityFleet,
		Type,
		tDefect_ID,
		ItemNo,
		tRegJourney_ID,
		JourneyNo,
		DefectDate,
		DefectDescription,
		NonChargeable,
		tATA_ID,
		ATAChapter,
		ATASystem,
		ATADescription,
		tReg_ID,
		Reg,
		CarriedOutText,
		MonthKey,
		Quarter,
		tDefectStatus_ID,
		DefectStatus,
		aOperator_ID,
		Operator,
		uRALBase_ID,
		Base,
		tModel_ID,
		Model,
		Cycles
	)

	SELECT	1,
			tReg.tReliabilityFleet_ID,
			tReliabilityFleet.Fleet,
			'Defect',
			tDefect.ID,
			tDefect.DefectItemNo,
			tDefect.tRegJourney_ID,
			IIF(tTechLog.TechLogNo <> '' AND tRegJourney.JourneyNumber <> '', CONCAT(tTechLog.TechLogNo,'/', tRegJourney.JourneyNumber), ''),
			CAST(tDefect.CreatedDate AS [date]),
			tDefect.Description,
			tDefect.ExcludeReliability,
			tATA.ID,
			tATA.ATAChapter,
			tATA.ATASystem,
			tATA.Description,
			tReg.ID,
			tReg.Reg,
			ClosureTask.CarriedOutText,
			UPPER(LEFT(CAST(DATENAME(mm,tDefect.CreatedDate) AS nvarchar),3)) + '-' + RIGHT(CAST(DATEPART(yy,tDefect.CreatedDate) AS nvarchar),2),
			'Q' + CAST(DATEPART(q,tDefect.CreatedDate) AS nvarchar),
			tDefect.tDefectStatus_ID,
			tDefectStatus.[Status],
			tReg.aOperator_ID,
			aOperator.OperatorName,
			tDefect.uRALBase_IDReportedFrom,
			uRALBase.Name,
			tAsset.tModel_ID,
			tModel.Model,
			usage.LifeTotal

	FROM	tDefect
	JOIN	tATA ON tDefect.tATA_ID = tATA.ID
	JOIN	tReg ON tDefect.tReg_ID = tReg.ID
	JOIN	tAsset ON tReg.tAsset_ID = tAsset.ID
	JOIN	tRegJourney ON tDefect.tRegJourney_ID = tRegJourney.ID
	JOIN	tTechLog ON tRegJourney.tTechLog_ID = tTechLog.ID
	JOIN	tReliabilityFleet ON tReg.tReliabilityFleet_ID = tReliabilityFleet.ID
	JOIN	tDefectStatus ON tDefect.tDefectStatus_ID = tDefectStatus.ID
	JOIN	aOperator on tReg.aOperator_ID = aOperator.ID
	JOIN	uRALBase on tDefect.uRALBase_IDReportedFrom = uRALBase.ID
	JOIN	tModel on tAsset.tModel_ID = tModel.ID
	OUTER APPLY (
		SELECT TOP 1	tDefect_ID,
						sOrderTask.ID,
						CarriedOutText
		FROM			sOrderTask
		JOIN			sOrderTaskStatus on sOrderTask.sOrderTaskStatus_ID = sOrderTaskStatus.ID
		WHERE			sOrderTask.tDefect_ID = tDefect.ID
		AND				sOrderTaskStatus.TaskClosed = 1
		ORDER BY 		sOrderTask.CarriedOutDate DESC
	) AS ClosureTask
	JOIN	(
		SELECT	tDefect.ID,
		tRegJourneyLogBookLifeCodeEvents.LifeTotal
		FROM	tDefect
		JOIN	tRegJourneyLogBook ON tDefect.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
		JOIN	tRegJourneyLogBookLifeCodeEvents ON tRegJourneyLogBook.ID = tRegJourneyLogBookLifeCodeEvents.tRegJourneyLogBook_ID
		JOIN	tLifeCode ON tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
		JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
		JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
		JOIN	tModel ON tAsset.tModel_ID = tModel.ID
		JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
		WHERE	tModelType.RegAsset = 1
		) usage ON tDefect.ID = usage.ID
		
	UNION ALL

	SELECT	1,
			tReg.tReliabilityFleet_ID,
			tReliabilityFleet.Fleet,
			'NRC',
			sNRCTask.ID AS sNRCTask_ID,
			sNRCTask.ItemNo,
			tRegJourney.ID AS tRegJourney_ID,
			IIF(tTechLog.TechLogNo <> '' AND tRegJourney.JourneyNumber <> '', CONCAT(tTechLog.TechLogNo,'/', tRegJourney.JourneyNumber), ''),
			sNRC.ReportedDate,
			sNRCTask.LongDescription,
			sNRC.ExcludeReliability,
			tATA.ID,
			tATA.ATAChapter,
			tATA.ATASystem,
			tATA.Description AS ATADescription,
			tReg.ID AS tReg_ID,
			tReg.Reg,
			sOrderTask.CarriedOutText,
			CONCAT(LEFT(DATENAME(MM, sNRC.ReportedDate), 3), '-', DATEPART(YY, sNRC.ReportedDate)) AS MonthKey,
			CONCAT('Q', DATEPART(Q, sNRC.ReportedDate)) AS Quarter,
			sNRC.sNRCStatus_ID,
			sNRCStatus.[Description],
			tReg.aOperator_ID,
			aOperator.OperatorName,
			sOrder.uRALBase_ID,
			uRALBase.Name,
			tAsset.tModel_ID,
			tModel.Model,
			usage.LifeTotal

	FROM	sNRCTask
	JOIN	sNRC ON sNRCTask.sNRC_ID = sNRC.ID
	JOIN	sNRCStatus ON sNRC.sNRCStatus_ID = sNRCStatus.ID
	JOIN	sOrderTask ON sNRCTask.sOrderTask_ID = sOrderTask.ID
	LEFT JOIN	tRegJourney ON sOrderTask.tRegJourney_ID = tRegJourney.ID
	LEFT JOIN	tTechLog on tRegJourney.tTechLog_ID = tTechLog.ID
	LEFT JOIN	tReg ON tRegJourney.tReg_ID = tReg.ID
	LEFT JOIN	tReliabilityFleet ON tReg.tReliabilityFleet_ID = tReliabilityFleet.ID
	LEFT JOIN 	aOperator on tReg.aOperator_ID = aOperator.ID
	LEFT JOIN	tAsset ON tReg.tAsset_ID = tAsset.ID
	LEFT JOIN	tModel ON tAsset.tModel_ID = tModel.ID
	LEFT JOIN	tATA ON sOrderTask.tATA_ID = tATA.ID
	JOIN	sOrder ON sOrderTask.sOrder_ID = sOrder.ID
	JOIN	uRALBase ON sOrder.uRALBase_ID = uRALBase.ID
	LEFT JOIN	(
		SELECT	tRegJourney.ID,
				tRegJourneyLogBookLifeCodeEvents.LifeTotal
		FROM	tRegJourney
		JOIN	tRegJourneyLogBook ON tRegJourney.ID = tRegJourneyLogBook.tRegJourney_ID
		JOIN	tRegJourneyLogBookLifeCodeEvents ON tRegJourneyLogBook.ID = tRegJourneyLogBookLifeCodeEvents.tRegJourneyLogBook_ID
		JOIN	tLifeCode ON tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
		JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
		JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
		JOIN	tModel ON tAsset.tModel_ID = tModel.ID
		JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
		WHERE	tModelType.RegAsset = 1
		) usage ON tRegJourney.ID = usage.ID
	
	DECLARE @Start datetime = GETUTCDATE()
	DECLARE @IdBeforeUpdate int = (SELECT IDENT_CURRENT('tRelRepSystemReliability'))
	DECLARE @ErrorMessage nvarchar (200) = 'Updated Successfully'
	
	BEGIN TRANSACTION
	BEGIN TRY
			
		DELETE FROM tRelRepSystemReliability
		WHERE		Lock = 0

		INSERT INTO tRelRepSystemReliability
		(
			Lock,
			tReliabilityFleet_ID,
			ReliabilityFleet,
			Type,
			tDefect_ID,
			ItemNo,
			tRegJourney_ID,
			JourneyNo,
			DefectDate,
			DefectDescription,
			NonChargeable,
			tATA_ID,
			ATAChapter,
			ATASystem,
			ATADescription,
			tReg_ID,
			Reg,
			CarriedOutText,
			MonthKey,
			Quarter,
			tDefectStatus_ID,
			DefectStatus,
			aOperator_ID,
			Operator,
			uRALBase_ID,
			Base,
			tModel_ID,
			Model,
			Cycles
		)

		SELECT	Lock,
				tReliabilityFleet_ID,
				ISNULL(ReliabilityFleet, '-'),
				ISNULL(Type, '-'),
				tDefect_ID,
				ISNULL(ItemNo, '-'),
				tRegJourney_ID,
				ISNULL(JourneyNo, '-'),
				DefectDate,
				ISNULL(DefectDescription, '-'),
				NonChargeable,
				tATA_ID,
				ISNULL(ATAChapter, '-'),
				ISNULL(ATASystem, '-'),
				ISNULL(ATADescription, '-'),
				tReg_ID,
				ISNULL(Reg, '-'),
				ISNULL(CarriedOutText, '-'),
				ISNULL(MonthKey, '-'),
				ISNULL(Quarter, '-'),
				tDefectStatus_ID,
				ISNULL(DefectStatus, '-'),
				aOperator_ID,
				ISNULL(Operator, '-'),
				uRALBase_ID,
				ISNULL(Base, '-'),
				tModel_ID,
				ISNULL(Model, '-'),
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
			'tUpdateRelRepSystemReliability_NOCALC',
			ISNULL((SELECT IDENT_CURRENT('tRelRepSystemReliability')) - @IdBeforeUpdate ,0),
			ISNULL( (SELECT MAX(ID) FROM tDefect), 0),
			@ErrorMessage
			)
END
GO