/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepComponentReliability_CALC]    Script Date: 04/03/2019 09:09:49 ******/
IF EXISTS (
    SELECT 	* 
	FROM 	sys.objects 
	WHERE 	object_id = OBJECT_ID(N'[dbo].[sptUpdateRelRepComponentReliability_CALC]') 
	AND 	type IN (N'P', N'PC', N'X') 
)
BEGIN
    DROP PROCEDURE [dbo].[sptUpdateRelRepComponentReliability_CALC]
END
/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepComponentReliability_CALC]    Script Date: 04/03/2019 09:09:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jamie Hanna
-- =============================================
CREATE PROCEDURE [dbo].[sptUpdateRelRepComponentReliability_CALC]

    @FromDate datetime, 
	@ToDate datetime

AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Start datetime = GETUTCDATE()
	DECLARE @IdBeforeUpdate int = (SELECT IDENT_CURRENT('tRelRepComponentReliability'))
	DECLARE @ErrorMessage nvarchar (200) = 'Updated Succesfully'
	
	BEGIN TRANSACTION
	BEGIN TRY

        DECLARE @FH_ID int = (SELECT TOP 1 ID FROM tLifeCode WHERE RegJourneyHours = 1)

        UPDATE  tRelRepComponentReliability
            SET NoOfPnRemovedFromRegistration = (
                    SELECT  COUNT(*)
                    FROM    tRelRepComponentReliability r
                    WHERE   r.PartNo = tRelRepComponentReliability.PartNo
                    AND     r.tReg_ID = tRelRepComponentReliability.tReg_ID
                    AND     r.DateOfRemoval <= tRelRepComponentReliability.DateOfRemoval
                ),
                
                NoOfPnRemovedFromFleet = (
                    SELECT  COUNT(*)
                    FROM    tRelRepComponentReliability r
                    WHERE   r.PartNo = tRelRepComponentReliability.PartNo
                    AND     r.tReliabilityFleet_ID = tRelRepComponentReliability.tReliabilityFleet_ID
                    AND     r.DateOfRemoval <= tRelRepComponentReliability.DateOfRemoval
                ),

                UnscheduledRemovalsRegistration = (
                    SELECT  COUNT(*)
                    FROM    tRelRepComponentReliability r
                    WHERE   r.PartNo = tRelRepComponentReliability.PartNo
                    AND     r.tReg_ID = tRelRepComponentReliability.tReg_ID
                    AND     r.DateOfRemoval <= tRelRepComponentReliability.DateOfRemoval
                    AND     tRelRepComponentReliability.Scheduled = 0
                ),

                UnscheduledRemovalsFleet = (
                    SELECT  COUNT(*)
                    FROM    tRelRepComponentReliability r
                    WHERE   r.PartNo = tRelRepComponentReliability.PartNo
                    AND     r.tReliabilityFleet_ID = tRelRepComponentReliability.tReliabilityFleet_ID
                    AND     r.DateOfRemoval <= tRelRepComponentReliability.DateOfRemoval
                    AND     tRelRepComponentReliability.Scheduled = 0
                )
            
        UPDATE  tRelRepComponentReliability
            SET MTBRRegistration =	IIF(NoOfPnRemovedFromRegistration > 0, dbo.FormatedLifeCodeValue(@FH_ID, TSI / NoOfPnRemovedFromRegistration, 0), NULL),

                MTBRFleet =			IIF(NoOfPnRemovedFromFleet > 0, dbo.FormatedLifeCodeValue(@FH_ID, TSI / NoOfPnRemovedFromFleet, 0), NULL),
        
                MTBURRegistration = IIF(UnscheduledRemovalsRegistration > 0, dbo.FormatedLifeCodeValue(@FH_ID, TSI / UnscheduledRemovalsRegistration, 0), NULL),

                MTBURFleet =		IIF(UnscheduledRemovalsFleet > 0, dbo.FormatedLifeCodeValue(@FH_ID, TSI / UnscheduledRemovalsFleet, 0), NULL)

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
			'tUpdateRelRepComponentReliability_CALC',
			ISNULL((SELECT IDENT_CURRENT('tRelRepComponentReliability')) - @IdBeforeUpdate ,0),
			ISNULL( (SELECT MAX(ID) FROM tAsset), 0),
			@ErrorMessage
			)
END
GO