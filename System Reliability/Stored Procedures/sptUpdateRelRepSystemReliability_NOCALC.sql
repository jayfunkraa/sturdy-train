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
		[RecordID] [int] NOT NULL,
		[ItemNo] [nvarchar](100) NOT NULL,
		[JourneyNo] [nvarchar](100) NOT NULL,
		[DefectDate] [datetime] NULL,
		[DefectDescription] [nvarchar](4000) NULL,
		[DefectType] [nvarchar](100) NULL,
		[DelayOrCancellation] [nvarchar](100) NULL,
		[PartNoOff] [nvarchar](max) NULL,
		[SerialNoOff] [nvarchar](max) NULL,
		[PartNoOn] [nvarchar](max) NULL,
		[SerialNoOn] [nvarchar](max) NULL,
		[CallingTask] [nvarchar](200) NULL,
		[CallingTaskTitle] [nvarchar](400) NULL,
		[WorkOrderTask] [nvarchar](200) NULL,
		[tATA_ID] [int] NULL,
		[ATAChapter] [int] NULL,
		[ATASystem] [int] NULL,
		[ATADescription] [nvarchar](4000) NULL,
		[tReg_ID] [INT] NULL,
		[Reg] [nvarchar](10) NULL,
		[AircraftMSN] [nvarchar] (100) NULL,
		[CarriedOutText] [nvarchar](4000) NULL,
		[MonthKey] [nvarchar](10) NULL,
		[Quarter] [nvarchar](10) NULL,
		[Year] [int] NULL,
		[aOperator_ID] [nvarchar](10) NULL,
		[Operator] [nvarchar](100) NULL,
		[uRALBase_ID] [int] NULL,
		[Base] [nvarchar](100) NULL,
		[EmployeeCreated] [nvarchar](200) NULL,
		[EmployeeClosed] [nvarchar](200) NULL,
		[TotalAircraftHours] [nvarchar](20) NULL,
		[TotalAircraftCycles] [decimal](18, 0) NULL
	)

	INSERT INTO @TempTable 
	(
		Lock,
		tReliabilityFleet_ID,
		ReliabilityFleet,
		Type,
		RecordID,
		ItemNo,
		JourneyNo,
		DefectDate,
		DefectDescription,
		DefectType,
		DelayOrCancellation,
		PartNoOff,
		SerialNoOff,
		PartNoOn,
		SerialNoOn,
		CallingTask,
		CallingTaskTitle,
		WorkOrderTask,
		tATA_ID,
		ATAChapter,
		ATASystem,
		ATADescription,
		tReg_ID,
		Reg,
		AircraftMSN,
		CarriedOutText,
		MonthKey,
		Quarter,
		Year,
		aOperator_ID,
		Operator,
		uRALBase_ID,
		Base,
		EmployeeCreated,
		EmployeeClosed,
		TotalAircraftHours,
		TotalAircraftCycles
	)

	SELECT	1,
			tReg.tReliabilityFleet_ID,
			tReliabilityFleet.Fleet,
			'Defect',
			tDefect.ID,
			tDefect.DefectItemNo,
			IIF(tTechLog.TechLogNo <> '' AND tRegJourney.JourneyNumber <> '', CONCAT(tTechLog.TechLogNo,'/', tRegJourney.JourneyNumber), NULL),
			CAST(tDefect.CreatedDate AS [date]),
			tDefect.Description,
			tDefectType.DefectType,
			DelayCancellation.Category,
			FitRemPnSn.PartNoRemoved,
			FitRemPnSn.SerialNoRemoved,
			FitRemPnSn.PartNoFitted,
			FitRemPnSn.SerialNoFitted,
			NULL,
			NULL,
			IIF(ClosureTask.OrderNo <> '' AND ClosureTask.TaskNo <> '', CONCAT(ClosureTask.OrderNo, '/', ClosureTask.TaskNo), NULL),
			tATA.ID,
			tATA.ATAChapter,
			tATA.ATASystem,
			tATA.Description,
			tReg.ID,
			tReg.Reg,
			tAsset.SerialNo,
			ClosureTask.CarriedOutText,
			UPPER(LEFT(CAST(DATENAME(mm,tDefect.CreatedDate) AS nvarchar),3)) + '-' + RIGHT(CAST(DATEPART(yy,tDefect.CreatedDate) AS nvarchar),2),
			'Q' + CAST(DATEPART(q,tDefect.CreatedDate) AS nvarchar),
			CAST(DATEPART(yyyy, tDefect.CreatedDate) AS int),
			tReg.aOperator_ID,
			aOperator.OperatorName,
			tDefect.uRALBase_IDReportedFrom,
			uRALBase.Name,
			Employee.Created,
			Employee.CarriedOut,
			usageFH.LifeTotal,
			usageFC.LifeTotal

	FROM	tDefect
	JOIN	tATA ON tDefect.tATA_ID = tATA.ID
	JOIN	tReg ON tDefect.tReg_ID = tReg.ID
	JOIN	tAsset ON tReg.tAsset_ID = tAsset.ID
	JOIN	tRegJourney ON tDefect.tRegJourney_ID = tRegJourney.ID
	JOIN	tTechLog ON tRegJourney.tTechLog_ID = tTechLog.ID
	JOIN	tReliabilityFleet ON tReg.tReliabilityFleet_ID = tReliabilityFleet.ID
	JOIN	tDefectStatus ON tDefect.tDefectStatus_ID = tDefectStatus.ID
	JOIN	aOperator ON tReg.aOperator_ID = aOperator.ID
	JOIN	uRALBase ON tDefect.uRALBase_IDReportedFrom = uRALBase.ID
	JOIN	tDefectType ON tDefect.tDefectType_ID = tDefectType.ID
	LEFT JOIN	(
					SELECT  ID,
        					Created,
        					CarriedOut
					FROM    (
            					SELECT  tDefect.ID,
                    					Created.ShortDisplayName AS Created,
                    					CarriedOut.ShortDisplayName AS CarriedOut,
                    					ROW_NUMBER() OVER(PARTITION BY tDefect_ID ORDER BY TaskEmployee.CarriedOutDate DESC, tDefect.ID DESC) AS RowID
            					FROM    tDefect
            					LEFT JOIN    (
                								SELECT  sOrderTask.tDefect_ID,
                        								sOrderTask.CarriedOutDate,
                       									sOrderTask.lEmployee_IDCarriedOut
                								FROM    sOrderTask
                								JOIN    sOrderTaskStatus ON sOrderTask.sOrderTaskStatus_ID = sOrderTaskStatus.ID AND sOrderTaskStatus.TaskClosed = 1
            								) TaskEmployee ON tDefect.ID = TaskEmployee.tDefect_ID
            					LEFT JOIN    lEmployee Created ON tDefect.lEmployee_IDTaskCreated = Created.ID
            					LEFT JOIN    lEmployee CarriedOut ON TaskEmployee.lEmployee_IDCarriedOut = CarriedOut.ID
        					) AS Emp
					WHERE   RowID = 1
				) AS Employee ON tDefect.ID = Employee.ID
	OUTER APPLY (
		SELECT TOP 1	tDefect_ID,
						sOrderTask.ID,
						sOrder.OrderNo,
						sOrderTask.TaskNo,
						CarriedOutText
		FROM			sOrderTask
		JOIN			sOrderTaskStatus ON sOrderTask.sOrderTaskStatus_ID = sOrderTaskStatus.ID
		JOIN			sOrder ON sOrderTask.sOrder_ID = sOrder.ID
		WHERE			sOrderTask.tDefect_ID = tDefect.ID
		AND				sOrderTaskStatus.TaskClosed = 1
		ORDER BY 		sOrderTask.CarriedOutDate DESC
	) AS ClosureTask
	LEFT JOIN	(
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
		) usageFC ON tDefect.ID = usageFC.ID
	LEFT JOIN	(
		SELECT	tDefect.ID,
				REPLACE(RTRIM(dbo.FormatedLifeCodeValue(tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID, tRegJourneyLogBookLifeCodeEvents.LifeTotal, 0)), ' FH', '') AS LifeTotal
		FROM	tDefect
		JOIN	tRegJourneyLogBook ON tDefect.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
		JOIN	tRegJourneyLogBookLifeCodeEvents ON tRegJourneyLogBook.ID = tRegJourneyLogBookLifeCodeEvents.tRegJourneyLogBook_ID
		JOIN	tLifeCode ON tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyHours = 1
		JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
		JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
		JOIN	tModel ON tAsset.tModel_ID = tModel.ID
		JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
		WHERE	tModelType.RegAsset = 1
		) usageFH ON tDefect.ID = usageFH.ID
	LEFT JOIN (
		SELECT  tAOGDetail.tDefect_ID,
        		tDiaryCategory.Category
		FROM    tRegDiary
		JOIN    tDiaryCategory ON tRegDiary.tDiaryCategory_ID = tDiaryCategory.ID
		JOIN    tAOGDetail ON tRegDiary.ID = tAOGDetail.tRegDiary_ID
		WHERE   tRegDiaryRange_ID = 2
	) DelayCancellation ON tDefect.ID = DelayCancellation.tDefect_ID
		JOIN (
			SELECT  ID,
        			TRIM(STUFF(
            			(
                			SELECT  ', ' + tAsset.SerialNo
                			FROM    tAssetHistory ah1
                			JOIN    tAsset ON ah1.tAsset_ID = tAsset.ID
                			JOIN    tAssetStatus ON ah1.tAssetStatus_ID = tAssetStatus.ID
                			WHERE   tAssetStatus.Removed = 1
                			AND     ah1.tDefect_ID = tDefect.ID
							ORDER BY ah1.[Sequence]
                			FOR XML PATH('')
            			), 1, 1, ''
        			)) AS SerialNoRemoved,
        			TRIM(STUFF(
            			(
                			SELECT  ', ' + sPart.PartNo
                			FROM    tAssetHistory ah2
                			JOIN    tAsset ON ah2.tAsset_ID = tAsset.ID
                			JOIN    sPart ON tAsset.sPart_ID = sPart.ID
                			JOIN    tAssetStatus ON ah2.tAssetStatus_ID = tAssetStatus.ID
                			WHERE   tAssetStatus.Removed = 1
                			AND     ah2.tDefect_ID = tDefect.ID
							ORDER BY ah2.[Sequence]
                			FOR XML PATH('')
            			), 1, 1, ''
        			)) AS PartNoRemoved,
        			TRIM(STUFF(
            			(
                			SELECT  ', ' + tAsset.SerialNo
                			FROM    tAssetHistory ah3
                			JOIN    tAsset ON ah3.tAsset_ID = tAsset.ID
                			JOIN    tAssetStatus ON ah3.tAssetStatus_ID = tAssetStatus.ID
                			WHERE   tAssetStatus.Fitted = 1
                			AND     ah3.tDefect_ID = tDefect.ID
							ORDER BY ah3.[Sequence]
                			FOR XML PATH('')
            			), 1, 1, ''
        			)) AS SerialNoFitted,
        			TRIM(STUFF(
            			(
                			SELECT  ', ' + sPart.PartNo
                			FROM    tAssetHistory ah4
                			JOIN    tAsset ON ah4.tAsset_ID = tAsset.ID
                			JOIN    sPart ON tAsset.sPart_ID = sPart.ID
                			JOIN    tAssetStatus ON ah4.tAssetStatus_ID = tAssetStatus.ID
                			WHERE   tAssetStatus.Fitted = 1
                			AND     ah4.tDefect_ID = tDefect.ID
							ORDER BY ah4.[Sequence]
                			FOR XML PATH('')
            			), 1, 1, ''
        			)) AS PartNoFitted
			FROM    tDefect
			GROUP BY ID
	) FitRemPnSn ON tDefect.ID = FitRemPnSn.ID

	WHERE 	tDefectStatus.DefaultClosed = 1
	AND		tDefect.ExcludeReliability = 0
		
	UNION ALL

	SELECT	1,
			tReg.tReliabilityFleet_ID,
			tReliabilityFleet.Fleet,
			'NRC',
			sNRCTask.ID AS sNRCTask_ID,
			sNRCTask.ItemNo,
			IIF(tTechLog.TechLogNo <> '' AND tRegJourney.JourneyNumber <> '', CONCAT(tTechLog.TechLogNo,'/', tRegJourney.JourneyNumber), ''),
			CAST(sNRC.ReportedDate AS [date]),
			sNRCTask.LongDescription,
			'MAREP',
			NULL,
			FitRemPnSn.PartNoRemoved,
			FitRemPnSn.SerialNoRemoved,
			FitRemPnSn.PartNoFitted,
			FitRemPnSn.SerialNoFitted,
			callingTask.MI,
			callingTask.Title,
			IIF(sOrder.OrderNo <> '' AND sOrderTask.TaskNo <> '', CONCAT(sOrder.OrderNo, '/', sOrderTask.TaskNo), NULL),
			tATA.ID,
			tATA.ATAChapter,
			tATA.ATASystem,
			tATA.Description AS ATADescription,
			tReg.ID AS tReg_ID,
			tReg.Reg,
			tAsset.SerialNo,
			sOrderTask.CarriedOutText,
			CONCAT(LEFT(DATENAME(MM, sNRC.ReportedDate), 3), '-', DATEPART(YY, sNRC.ReportedDate)) AS MonthKey,
			CONCAT('Q', DATEPART(Q, sNRC.ReportedDate)) AS Quarter,
			CAST(DATEPART(yyyy, sNRC.ReportedDate) AS int),
			tReg.aOperator_ID,
			aOperator.OperatorName,
			sOrder.uRALBase_ID,
			uRALBase.Name,
			Created.ShortDisplayName,
			CarriedOut.ShortDisplayName,
			usageFH.LifeTotal,
			usageFC.LifeTotal

	FROM	sNRCTask
	JOIN	sNRC ON sNRCTask.sNRC_ID = sNRC.ID
	JOIN	sNRCStatus ON sNRC.sNRCStatus_ID = sNRCStatus.ID
	JOIN	sOrderTask ON sNRCTask.sOrderTask_ID = sOrderTask.ID
	LEFT JOIN	tRegJourney ON sOrderTask.tRegJourney_IDCarriedOut = tRegJourney.ID
	LEFT JOIN	tTechLog on tRegJourney.tTechLog_ID = tTechLog.ID
	LEFT JOIN	tReg ON tRegJourney.tReg_ID = tReg.ID
	LEFT JOIN	tReliabilityFleet ON tReg.tReliabilityFleet_ID = tReliabilityFleet.ID
	LEFT JOIN 	aOperator on tReg.aOperator_ID = aOperator.ID
	LEFT JOIN	tAsset ON tReg.tAsset_ID = tAsset.ID
	LEFT JOIN	tATA ON sOrderTask.tATA_ID = tATA.ID
	JOIN	sOrder ON sOrderTask.sOrder_ID = sOrder.ID
	JOIN	uRALBase ON sOrder.uRALBase_ID = uRALBase.ID
	JOIN	sNRCType ON sNRC.sNRCType_ID = sNRCType.ID
	LEFT JOIN 	lEmployee Created ON sNRC.lEmployee_IDReportedBy = Created.ID
	LEFT JOIN	lEmployee CarriedOut ON sOrderTask.lEmployee_IDCarriedOut = CarriedOut.ID
	LEFT JOIN	(
		SELECT	tRegJourney.ID,
				REPLACE(RTRIM(dbo.FormatedLifeCodeValue(tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID, tRegJourneyLogBookLifeCodeEvents.LifeTotal, 0)), ' FH', '') AS LifeTotal
		FROM	tRegJourney
		JOIN	tRegJourneyLogBook ON tRegJourney.ID = tRegJourneyLogBook.tRegJourney_ID
		JOIN	tRegJourneyLogBookLifeCodeEvents ON tRegJourneyLogBook.ID = tRegJourneyLogBookLifeCodeEvents.tRegJourneyLogBook_ID
		JOIN	tLifeCode ON tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyHours = 1
		JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
		JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
		JOIN	tModel ON tAsset.tModel_ID = tModel.ID
		JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
		WHERE	tModelType.RegAsset = 1
	) usageFH ON tRegJourney.ID = usageFH.ID
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
	) usageFC ON tRegJourney.ID = usageFC.ID
	LEFT JOIN (
		SELECT	sNRCTask.ID,
				tMI.MI,
				tMI.Title
		FROM	sNRCTask
		JOIN	sNRC on sNRCTask.sNRC_ID = sNRC.ID
		JOIN	sOrderTask on sNRC.sOrderTask_IDReportedOn = sOrderTask.ID
		LEFT JOIN	tMI on sOrderTask.tMI_IDCreatedFrom = tMI.ID
	) callingTask ON sNRCTask.ID = callingTask.ID
	JOIN (
		SELECT  ID,
        TRIM(STUFF(
            (
                SELECT  ', ' + tAsset.SerialNo
                FROM    tAssetHistory ah1
                JOIN    tAsset ON ah1.tAsset_ID = tAsset.ID
                JOIN    tAssetStatus ON ah1.tAssetStatus_ID = tAssetStatus.ID
                WHERE   tAssetStatus.Removed = 1
                AND     ah1.sOrderTask_ID = sOrderTask.ID
                ORDER BY ah1.[Sequence]
                FOR XML PATH('')
            ), 1, 1, ''
        )) AS SerialNoRemoved,
        TRIM(STUFF(
            (
                SELECT  ', ' + sPart.PartNo
                FROM    tAssetHistory ah2
                JOIN    tAsset ON ah2.tAsset_ID = tAsset.ID
                JOIN    sPart ON tAsset.sPart_ID = sPart.ID
                JOIN    tAssetStatus ON ah2.tAssetStatus_ID = tAssetStatus.ID
                WHERE   tAssetStatus.Removed = 1
                AND     ah2.sOrderTask_ID = sOrderTask.ID
                ORDER BY ah2.[Sequence]
                FOR XML PATH('')
            ), 1, 1, ''
        )) AS PartNoRemoved,
        TRIM(STUFF(
            (
                SELECT  ', ' + tAsset.SerialNo
                FROM    tAssetHistory ah3
                JOIN    tAsset ON ah3.tAsset_ID = tAsset.ID
                JOIN    tAssetStatus ON ah3.tAssetStatus_ID = tAssetStatus.ID
                WHERE   tAssetStatus.Fitted = 1
                AND     ah3.sOrderTask_ID = sOrderTask.ID
                ORDER BY ah3.[Sequence]
                FOR XML PATH('')
            ), 1, 1, ''
        )) AS SerialNoFitted,
        TRIM(STUFF(
            (
                SELECT  ', ' + sPart.PartNo
                FROM    tAssetHistory ah4
                JOIN    tAsset ON ah4.tAsset_ID = tAsset.ID
                JOIN    sPart ON tAsset.sPart_ID = sPart.ID
                JOIN    tAssetStatus ON ah4.tAssetStatus_ID = tAssetStatus.ID
                WHERE   tAssetStatus.Fitted = 1
                AND     ah4.sOrderTask_ID = sOrderTask.ID
                ORDER BY ah4.[Sequence]
                FOR XML PATH('')
            ), 1, 1, ''
        )) AS PartNoFitted
		FROM    sOrderTask
		GROUP BY ID
	) FitRemPnSn ON sOrderTask.ID = FitRemPnSn.ID

	WHERE 	sNRCStatus.ClosedStatus = 1 OR sNRCStatus.Accepted = 1
	AND		sNRC.ExcludeReliability = 0
	
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
			RecordID,
			ItemNo,
			JourneyNo,
			DefectDate,
			DefectDescription,
			DefectType,
			DelayOrCancellation,
			PartNoOff,
			SerialNoOff,
			PartNoOn,
			SerialNoOn,
			CallingTask,
			CallingTaskTitle,
			WorkOrderTask,
			tATA_ID,
			ATAChapter,
			ATASystem,
			ATADescription,
			tReg_ID,
			Reg,
			AircraftMSN,
			CarriedOutText,
			MonthKey,
			Quarter,
			Year,
			aOperator_ID,
			Operator,
			uRALBase_ID,
			Base,
			EmployeeCreated,
			EmployeeClosed,
			TotalAircraftHours,
			TotalAircraftCycles
		)

		SELECT	Lock,
				tReliabilityFleet_ID,
				ISNULL(ReliabilityFleet, '-'),
				ISNULL(Type, '-'),
				RecordID,
				ISNULL(ItemNo, '-'),
				ISNULL(JourneyNo, '-'),
				DefectDate,
				ISNULL(DefectDescription, '-'),
				ISNULL(DefectType, '-'),
				ISNULL(DelayOrCancellation, '-'),
				ISNULL(PartNoOff,'-'),
				ISNULL(SerialNoOff,'-'),
				ISNULL(PartNoOn,'-'),
				ISNULL(SerialNoOn,'-'),
				ISNULL(CallingTask, '-'),
				ISNULL(CallingTaskTitle, '-'),
				ISNULL(WorkOrderTask, '-'),
				tATA_ID,
				ISNULL(ATAChapter, '-'),
				ISNULL(ATASystem, '-'),
				ISNULL(ATADescription, '-'),
				tReg_ID,
				ISNULL(Reg, '-'),
				ISNULL(AircraftMSN, '-'),
				ISNULL(CarriedOutText, '-'),
				ISNULL(MonthKey, '-'),
				ISNULL(Quarter, '-'),
				ISNULL(Year, '-'),
				aOperator_ID,
				ISNULL(Operator, '-'),
				uRALBase_ID,
				ISNULL(Base, '-'),
				ISNULL(EmployeeCreated, '-'),
				ISNULL(EmployeeClosed, '-'),
				TotalAircraftHours,
				TotalAircraftCycles
		FROM 	@TempTable
		WHERE	RecordID NOT IN (SELECT RecordID FROM tRelRepSystemReliability)

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