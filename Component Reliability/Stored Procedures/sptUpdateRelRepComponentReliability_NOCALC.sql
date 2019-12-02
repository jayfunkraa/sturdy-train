/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepComponentReliability_NOCALC]    Script Date: 04/03/2019 09:09:49 ******/
IF EXISTS (
	SELECT 	* 
	FROM 	sys.objects 
	WHERE 	object_id = OBJECT_ID(N'[dbo].[sptUpdateRelRepComponentReliability_NOCALC]') 
	AND 	type IN (N'P', N'PC', N'X') 
)
BEGIN 
	DROP PROCEDURE [dbo].[sptUpdateRelRepComponentReliability_NOCALC] 
END
/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepComponentReliability_NOCALC]    Script Date: 04/03/2019 09:09:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jamie Hanna
-- =============================================
CREATE PROCEDURE [dbo].[sptUpdateRelRepComponentReliability_NOCALC]
	
	@FromDate datetime, 
	@ToDate datetime

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FH_ID int = (SELECT TOP 1 ID FROM tLifeCode WHERE RegJourneyHours = 1)

	DECLARE @TempTable TABLE
	(
		[Lock] [bit] NOT NULL,
		[tAsset_ID] [int] NOT NULL,
		[DateOfRemoval] [nvarchar](50) NULL,
		[Month] [nvarchar](50) NULL,
		[Year] [int] NULL,
		[Quarter] [nvarchar](50) NULL,
		[PartNo] [nvarchar](50) NULL,
		[PartDescription] [nvarchar](100) NULL,
		[RemovalReason] [nvarchar](50) NULL,
		[Scheduled] [bit] NULL,
		[sOrderTask_ID] [int] NULL,
		[TaskNo] [nvarchar](100) NULL,
		[TechLogNo] [nvarchar](100) NULL,
		[MaintenanceTaskNo] [nvarchar](100) NULL,
		[DefectItemNo] [nvarchar](50) NULL,
		[TaskDescription] [nvarchar](250) NULL,
		[PartClassification] [nvarchar](50) NULL,
		[tATA_ID] [int] NULL,
		[ATADescription] [nvarchar](100) NULL,
		[Registration] [nvarchar](50) NULL,
		[tReliabilityFleet_ID] [int] NULL,
		[uRALBase_ID] [nvarchar](50) NULL,
		[EmployeeClosedBy] [nvarchar](100) NULL,
		[EmployeeStampClosedBy] [nvarchar](50) NULL,
		[Robbery] [bit] NULL,
		[FlightTimeComponentWasInstalledFH] [decimal](18,3) NULL,
		[FlightTimeComponetWasInstalledFormatted] [nvarchar](50) NULL,
		[FlightTimeComponentWasRemovedFH] [decimal](18,3) NULL,
		[FlightTimeComponentWasRemovedFormatted] [nvarchar](50) NULL,
		[TSI] [decimal](18,3) NULL,
		[TSIFormatted] [nvarchar](50) NULL
	)
	
	INSERT INTO @TempTable
	(
		Lock,
		tAsset_ID,
		DateOfRemoval,
		Month,
		Year,
		Quarter,
		PartNo,
		PartDescription,
		RemovalReason,
		Scheduled,
		sOrderTask_ID,
		TaskNo,
		TechLogNo,
		MaintenanceTaskNo,
		DefectItemNo,
		TaskDescription,
		PartClassification,
		tATA_ID,
		ATADescription,
		Registration,
		tReliabilityFleet_ID,
		uRALBase_ID,
		EmployeeClosedBy,
		EmployeeStampClosedBy,
		Robbery,
		FlightTimeComponentWasInstalledFH,
		FlightTimeComponetWasInstalledFormatted,
		FlightTimeComponentWasRemovedFH,
		FlightTimeComponentWasRemovedFormatted,
		TSI,
		TSIFormatted
	)

	SELECT	1,
			ah.tAsset_ID,
			ah.AttachDetachDate,
			DATENAME(mm, ah.AttachDetachDate),
			DATEPART(yyyy, ah.AttachDetachDate),
			CONCAT('Q',DATEPART(q, ah.AttachDetachDate)),
			sPart.PartNo,
			sPart.Description,
			tAssetRemovalReason.RemovalReason,
			tAssetRemovalReason.Scheduled,
			sOrderTask.ID,
			IIF(sOrderTask.ID IS NOT NULL, CONCAT(sOrder.OrderNo, '/', sOrderTask.TaskNo), NULL),
			IIF(tRegJourney.ID IS NOT NULL, CONCAT(tTechLog.TechLogNo, '/', tRegJourney.JourneyNumber), NULL),
			tMI.MI,
			tDefect.DefectItemNo,
			IIF(tAssetRemovalReason.Scheduled = 1, tMI.Title, tDefect.Description),
			sPartClassification.Code,
			tATA.ID,
			tATA.Description,
			tReg.ID,
			tReg.Reg,
			tReg.tReliabilityFleet_ID,
			uRALBase.ID,
			lEmployee.ShortDisplayName,
			lStamp.Stamp,
			tAssetRemovalReason.Robbery,
			FhInstalled.LifeTotal,
			dbo.FormatedLifeCodeValue(@FH_ID, FhInstalled.LifeTotal, 0),
			FhRemoved.LifeTotal,
			dbo.FormatedLifeCodeValue(@FH_ID, FhRemoved.LifeTotal, 0),
			FhRemoved.LifeTotal - FhInstalled.LifeTotal,
			dbo.FormatedLifeCodeValue(@FH_ID, FhRemoved.LifeTotal - FhInstalled.LifeTotal, 0)

	FROM		tAssetHistory ah
	JOIN		tAsset ON ah.tAsset_ID = tAsset.ID
	JOIN		sPart ON tAsset.sPart_ID = sPart.ID
	JOIN		sPartClassification ON sPart.sPartClassification_ID = sPartClassification.ID
	JOIN		tAssetStatus ON ah.tAssetStatus_ID = tAssetStatus.ID AND tAssetStatus.Removed = 1
	LEFT JOIN	tAssetRemovalReason ON ah.tAssetRemovalReason_ID = tAssetRemovalReason.ID
	LEFT JOIN	sOrderTask ON ah.sOrderTask_ID = sOrderTask.ID
	LEFT JOIN	sOrder ON sOrderTask.sOrder_ID = sOrder.ID
	LEFT JOIN	tMI ON sOrderTask.tMI_IDCreatedFrom = tMI.ID
	LEFT JOIN	tRegJourney ON ah.tRegJourney_ID = tRegJourney.ID
	OUTER APPLY	(
		SELECT TOP 1 	tRegJourney_ID 
		FROM 			tAssetHistory
		WHERE			tAsset_ID = ah.tAsset_ID
		AND				Sequence < ah.Sequence
		AND 			tModelAttachedModelLocation_ID <> 0
		ORDER BY Sequence DESC
	) tRegJourney_ID_Installed
	LEFT JOIN	tDefect ON ah.tDefect_ID = tDefect.ID
	LEFT JOIN	tATA ON tDefect.tATA_ID = tATA.ID OR tMI.tATA_ID = tATA.ID
	LEFT JOIN	tReg ON ah.tReg_ID = tReg.ID
	LEFT JOIN	tTechLog ON tRegJourney.tTechLog_ID = tTechLog.ID
	LEFT JOIN	lEmployeeStamp ON sOrderTask.lEmployeeStamp_IDCarriedOut = lEmployeeStamp.ID
	LEFT JOIN	lStamp ON lEmployeeStamp.lStamp_ID = lStamp.ID
	LEFT JOIN	lEmployee ON sOrderTask.lEmployee_IDCarriedOut = lEmployee.ID
	LEFT JOIN	uRALBase ON sOrderTask.uRALBase_IDReportedFrom = uRALBase.ID
	LEFT JOIN	(
		SELECT	tRegJourney.ID,
				tRegJourneyLogBookLifeCodeEvents.LifeTotal
		FROM	tRegJourney
		JOIN	tRegJourneyLogBook ON tRegJourney.ID = tRegJourneyLogBook.tRegJourney_ID
		JOIN	tRegJourneyLogBookLifeCodeEvents ON tRegJourneyLogBook.ID = tRegJourneyLogBookLifeCodeEvents.tRegJourneyLogBook_ID
		JOIN	tLifeCode ON tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyHours = 1
		JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
		JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
		JOIN	tModel ON tAsset.tModel_ID = tModel.ID
		JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
		WHERE	tModelType.RegAsset = 1
		) FhRemoved ON tRegJourney.ID = FhRemoved.ID
	LEFT JOIN	(
		SELECT	tRegJourney.ID,
				tRegJourneyLogBookLifeCodeEvents.LifeTotal
		FROM	tRegJourney
		JOIN	tRegJourneyLogBook ON tRegJourney.ID = tRegJourneyLogBook.tRegJourney_ID
		JOIN	tRegJourneyLogBookLifeCodeEvents ON tRegJourneyLogBook.ID = tRegJourneyLogBookLifeCodeEvents.tRegJourneyLogBook_ID
		JOIN	tLifeCode ON tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyHours = 1
		JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
		JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
		JOIN	tModel ON tAsset.tModel_ID = tModel.ID
		JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
		WHERE	tModelType.RegAsset = 1
		) FhInstalled ON tRegJourney_ID_Installed.tRegJourney_ID = FhInstalled.ID

	WHERE		tAssetRemovalReason.IncludeInReliability = 1

	ORDER BY ah.tAsset_ID, ah.Sequence

	----------------------------------------------------------

	DECLARE @Start DATETIME = GETUTCDATE()
	DECLARE @IdBeforeUpdate INT = (SELECT IDENT_CURRENT('tRelRepComponentReliability'))
	DECLARE @ErrorMessage NVARCHAR(200) = 'Updated Successfully'

	BEGIN TRANSACTION
	BEGIN TRY

		DELETE FROM	tRelRepComponentReliability
		WHERE		Lock = 0

		INSERT INTO tRelRepComponentReliability
		(
			Lock,
			tAsset_ID,
			DateOfRemoval,
			Month,
			Year,
			Quarter,
			PartNo,
			PartDescription,
			RemovalReason,
			Scheduled,
			sOrderTask_ID,
			TaskNo,
			TechLogNo,
			MaintenanceTaskNo,
			DefectItemNo,
			TaskDescription,
			PartClassification,
			tATA_ID,
			ATADescription,
			Registration,
			tReliabilityFleet_ID,
			uRALBase_ID,
			EmployeeClosedBy,
			EmployeeStampClosedBy,
			Robbery,
			FlightTimeComponentWasInstalledFH,
			FlightTimeComponentWasInstalledFormatted,
			FlightTimeComponentWasRemovedFH,
			FlightTimeComponentWasRemovedFormatted,
			TSI,
			TSIFormatted
		)

		SELECT	Lock,
				tAsset_ID,
				DateOfRemoval,
				Month,
				Year,
				Quarter,
				PartNo,
				PartDescription,
				RemovalReason,
				Scheduled,
				sOrderTask_ID,
				TaskNo,
				TechLogNo,
				MaintenanceTaskNo,
				DefectItemNo,
				TaskDescription,
				PartClassification,
				tATA_ID,
				ATADescription,
				Registration,
				tReliabilityFleet_ID,
				uRALBase_ID,
				EmployeeClosedBy,
				EmployeeStampClosedBy,
				Robbery,
				FlightTimeComponentWasInstalledFH,
				FlightTimeComponetWasInstalledFormatted,
				FlightTimeComponentWasRemovedFH,
				FlightTimeComponentWasRemovedFormatted,
				TSI,
				TSIFormatted

		FROM	@TempTable
		WHERE	CONCAT(SerialNo,'-',PartNo) NOT IN (SELECT CONCAT(SerialNo,'-',PartNo) FROM tRelRepComponentReliability)

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
			'tUpdateRelRepComponentReliability_NOCALC',
			ISNULL((SELECT IDENT_CURRENT('tRelRepComponentReliability')) - @IdBeforeUpdate ,0),
			ISNULL( (SELECT MAX(ID) FROM tAsset), 0),
			@ErrorMessage
			)
END
GO
