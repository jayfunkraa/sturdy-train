/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliability_NOCALC]    Script Date: 04/03/2019 09:09:49 ******/
IF EXISTS (
	SELECT 	* 
	FROM 	sys.objects 
	WHERE 	object_id = OBJECT_ID(N'[dbo].[sptUpdateRelRepAvailabilityDispatch]') 
	AND 	type IN (N'P', N'PC', N'X') 
)
BEGIN 
	DROP PROCEDURE [dbo].[sptUpdateRelRepAvailabilityDispatch] 
END
/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepAvailabilityDispatch]    Script Date: 04/03/2019 09:09:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jamie Hanna
-- =============================================
CREATE PROCEDURE [dbo].[sptUpdateRelRepAvailabilityDispatch] 
	
	@FromDate datetime,
	@ToDate datetime

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TempTable TABLE
	(
		[Lock] [bit] NOT NULL,
	    [tRegDiary_ID] [int] NOT NULL,
		[tDiaryCategory_ID] [int] NULL,
	    [tReg_ID] [int] NOT NULL,
	    [tReliabilityFleet_ID] [int] NULL,
	    [ReportText] [nvarchar](4000) NULL,
	    [ActionText] [nvarchar](4000) NULL,
	    [tRegDiaryStatus_ID] [int] NOT NULL,
	    [AOGMins] [decimal](18,3) NULL,
	    [AircraftDownTime] [decimal](18,3) NULL,
	    [IncidentDeclaredDateTime] [datetime] NULL,
	    [AOGDeclareDateTime] [datetime] NULL,
	    [AOGClearDateTime] [datetime] NULL,
	    [ARServiceDataTime] [datetime] NULL,
	    [TechLogSector] [nvarchar](50) NULL,
	    [DefectItemNo] [nvarchar](50) NULL,
	    [uRALBase_ID] [int] NULL,
	    [tPlace_ID] [int] NULL,
	    [AFHours] [nvarchar](50) NULL,
	    [AFCycles] [nvarchar](50) NULL,
	    [DefectText] [nvarchar](4000) NULL,
	    [DefectActionText] [nvarchar](4000) NULL
	)

	INSERT INTO @TempTable
	(
		Lock,
		tRegDiary_ID,
	    tDiaryCategory_ID,
	    tReg_ID,
	    tReliabilityFleet_ID,
	    ReportText,
	    ActionText,
	    tRegDiaryStatus_ID,
	    AOGMins,
	    AircraftDownTime,
	    IncidentDeclaredDateTime,
	    AOGDeclareDateTime,
	    AOGClearDateTime,
	    ARServiceDataTime,
	    TechLogSector,
	    DefectItemNo,
	    uRALBase_ID,
	    tPlace_ID,
	    AFHours,
	    AFCycles,
	    DefectText,
	    DefectActionText
	)

	select	1,
			tRegDiary.ID,
			tRegDiary.tDiaryCategory_ID,
			tRegDiary.tReg_ID,
			tReg.tReliabilityFleet_ID,
			tRegDiary.ReportText,
			history.ActionText,
			tRegDiary.tRegDiaryStatus_ID,
			DATEDIFF(MI, tAOGDetail.AOGDeclareDateTime, tAOGDetail.AOGClearDateTime) as AogMins,
			DATEDIFF(MI, tAOGDetail.IncidentDeclaredDateTime, tAOGDetail.ARServiceDataTime) as AcDowntimeMins,
			tAOGDetail.IncidentDeclaredDateTime,
			tAOGDetail.AOGDeclareDateTime,
			tAOGDetail.AOGClearDateTime,
			tAOGDetail.ARServiceDataTime,
			IIF(tTechLog.TechLogNo is not null and tRegJourney.JourneyNumber is not null, CONCAT(tTechLog.TechLogNo, '/', tRegJourney.JourneyNumber), NULL),
			tDefect.DefectItemNo,
			tReg.uRALBase_ID,
			tAOGDetail.tPlace_ID,
			afhours.LifeTotal,
			landings.LifeTotal,
			tDefect.Description,
			tDefect.ActionText
	from	tRegDiary
	join	tReg on tRegDiary.tReg_ID = tReg.ID
	left join	tAOGDetail on tRegDiary.ID = tAOGDetail.tRegDiary_ID
	left join	tDefect on tAOGDetail.tDefect_ID = tDefect.ID
	left join	tRegJourney on tDefect.tRegJourney_ID = tRegJourney.ID
	left join	tTechLog on tRegJourney.tTechLog_ID = tTechLog.ID
	outer apply	(
					SELECT	rj.ID,
							dbo.FormatedLifeCodeValue(tLifeCode.ID, tRegJourneyLogBookLifeCodeEvents.LifeTotal,0) LifeTotal
					FROM	tRegJourney rj
					JOIN	tRegJourneyLogBook ON rj.ID = tRegJourneyLogBook.tRegJourney_ID
					JOIN	tRegJourneyLogBookLifeCodeEvents ON tRegJourneyLogBook.ID = tRegJourneyLogBookLifeCodeEvents.tRegJourneyLogBook_ID
					JOIN	tLifeCode ON tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyLandings = 1
					JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
					JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
					JOIN	tModel ON tAsset.tModel_ID = tModel.ID
					JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
					WHERE	tModelType.RegAsset = 1
					AND		rj.ID = tRegJourney.ID
				) landings
	outer apply	(
					SELECT	rj.ID,
							dbo.FormatedLifeCodeValue(tLifeCode.ID, tRegJourneyLogBookLifeCodeEvents.LifeTotal, 0) LifeTotal
					FROM	tRegJourney rj
					JOIN	tRegJourneyLogBook ON rj.ID = tRegJourneyLogBook.tRegJourney_ID
					JOIN	tRegJourneyLogBookLifeCodeEvents ON tRegJourneyLogBook.ID = tRegJourneyLogBookLifeCodeEvents.tRegJourneyLogBook_ID
					JOIN	tLifeCode ON tRegJourneyLogBookLifeCodeEvents.tLifeCode_ID = tLifeCode.ID AND tLifeCode.RegJourneyHours = 1
					JOIN	tLogBook ON tRegJourneyLogBook.tLogBook_ID = tLogBook.ID
					JOIN	tAsset ON tLogBook.tAsset_ID = tAsset.ID
					JOIN	tModel ON tAsset.tModel_ID = tModel.ID
					JOIN	tModelType ON tModel.tModelType_ID = tModelType.ID
					WHERE	tModelType.RegAsset = 1
					AND		rj.ID = tRegJourney.ID
				) afhours
	cross apply	(
					SELECT	tRegDiary_ID,
							ActionText
					FROM	(
								SELECT	tRegDiary_ID,
										ActionText,
										ROW_NUMBER() OVER(PARTITION BY tRegDiary_ID ORDER BY ID DESC) AS ident
								FROM	tRegDiaryHistory
							) hist
					WHERE	ident = 1
					AND		tRegDiary.ID = tRegDiary_ID
				) history

	order by tRegDiary.DiaryDateTime

	DECLARE @Start datetime = GETUTCDATE()
	DECLARE @IdBeforeUpdate int = (SELECT IDENT_CURRENT('sptUpdateRelRepAvailabilityDispatch'))
	DECLARE @ErrorMessage nvarchar (200) = 'Updated Successfully'
	
	BEGIN TRANSACTION
	BEGIN TRY

		DELETE FROM	tRelRepAvailabilityDispatch
		WHERE		Lock = 0

		INSERT INTO tRelRepAvailabilityDispatch
		(
			Lock,
			tRegDiary_ID,
	    	tDiaryCategory_ID,
		    tReg_ID,
		    tReliabilityFleet_ID,
		    ReportText,
		    ActionText,
		    tRegDiaryStatus_ID,
		    AOGMins,
		    AircraftDownTime,
		    IncidentDeclaredDateTime,
		    AOGDeclareDateTime,
		    AOGClearDateTime,
		    ARServiceDataTime,
		    TechLogSector,
		    DefectItemNo,
		    uRALBase_ID,
		    tPlace_ID,
		    AFHours,
		    AFCycles,
		    DefectText,
		    DefectActionText
		)

		SELECT 	Lock,
				tRegDiary_ID,
	    		tDiaryCategory_ID,
	    		tReg_ID,
	    		tReliabilityFleet_ID,
	    		ReportText,
	    		ActionText,
	    		tRegDiaryStatus_ID,
	    		AOGMins,
	    		AircraftDownTime,
	    		IncidentDeclaredDateTime,
	    		AOGDeclareDateTime,
	    		AOGClearDateTime,
	    		ARServiceDataTime,
	    		TechLogSector,
	    		DefectItemNo,
	    		uRALBase_ID,
	    		tPlace_ID,
	    		AFHours,
	    		AFCycles,
	    		DefectText,
	    		DefectActionText
		FROM	@TempTable
		WHERE	tRegDiary_ID NOT IN (SELECT tRegDiary_ID FROM tRelRepAvailabilityDispatch)

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
		'sptUpdateRelRepAvailabilityDispatch',
		ISNULL((SELECT IDENT_CURRENT('tRelRepAvailabilityDispatch')) - @IdBeforeUpdate, 0),
		ISNULL((SELECT MAX(ID) FROM tRegDiary), 0),
		@ErrorMessage
	)
END
GO