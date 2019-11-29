/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliabilityAlertLevelATASystem]    Script Date: 06/03/2019 14:35:37 ******/
IF EXISTS (
	SELECT 	* 
	FROM 	sys.objects 
	WHERE 	object_id = OBJECT_ID(N'[dbo].[sptUpdateRelRepSystemReliabilityAlertLevelATASystem]') 
	AND 	type IN (N'P', N'PC', N'X') 
)
BEGIN 
	DROP PROCEDURE [dbo].[sptUpdateRelRepSystemReliabilityAlertLevelATASystem] 
END
/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliabilityAlertLevelATASystem]    Script Date: 06/03/2019 14:35:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jamie Hanna
-- =============================================
CREATE PROCEDURE [dbo].[sptUpdateRelRepSystemReliabilityAlertLevelATASystem] 
	
	@FromDate datetime,
	@ToDate datetime

AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @Start DATETIME = GETUTCDATE();

    DECLARE @MonthValues TABLE (
        [Year] [int],
        [Month] [int],
        [tReliabilityFleet_ID] [int],
        [ATASystem] [nvarchar](5),
        [DefectsPer100FC] [decimal](18,3)
    )

    DECLARE @Calculations TABLE (
        [Year] [int],
        [tReliabilityFleet_ID] [int],
        [ATASystem] [nvarchar](5),
        [Count] [int],
        [StDev] [decimal](18,3),
        [Mean] [decimal](18,3)
    )

    INSERT INTO @MonthValues
        SELECT	DATEPART(YYYY, r.DefectDate),
		        DATEPART(MM, r.DefectDate),
                r.tReliabilityFleet_ID,
		        CONCAT(tATA.ATAChapter, '-', tATA.ATASystem),
		        r.FleetMonthDefectsPer100FCSystem
        FROM	tRelRepSystemReliability r
        JOIN	tATA on r.tATA_ID = tATA.ID

    INSERT INTO @Calculations
        SELECT	    DATEPART(YYYY, r.DefectDate),
                    r.tReliabilityFleet_ID,
                    CONCAT(tATA.ATAChapter, '-', tATA.ATASystem),
		            COUNT(*),
                    STDEVP(r.FleetMonthDefectsPer100FCSystem),
		            AVG(r.FleetMonthDefectsPer100FCSystem)
        FROM	    tRelRepSystemReliability r
        JOIN	    tATA on r.tATA_ID = tATA.ID
        GROUP BY    DATEPART(YYYY, r.DefectDate), r.tReliabilityFleet_ID, tATA.ATAChapter, tATA.ATASystem
		    
    DECLARE @IdBeforeUpdate int = (SELECT IDENT_CURRENT('tRelRepSystemReliabilityAlertLevelATASystem'))
	DECLARE @ErrorMessage nvarchar (200) = 'Updated Succesfully'
    
    BEGIN TRANSACTION
    BEGIN TRY
        DELETE FROM     tRelRepSystemReliabilityAlertLevelATASystem
        WHERE           Lock = 0

        INSERT INTO tRelRepSystemReliabilityAlertLevelATASystem (
            [Lock],
            [tReliabilityFleet_ID],
            [Year],
            [Month],
            [ATASystem],
            [Count],
            [DefectsPer100FC],
            [StDev],
            [Mean],
            [UCL20],
            [UCL25],
            [UCL30]
        )

        SELECT  1,
                [m].[tReliabilityFleet_ID],
                [m].[Year],
                [m].[Month],
                [m].[ATASystem],
                [c].[Count],
                [m].[DefectsPer100FC],
                [c].[StDev],
                [c].[Mean],
                [c].[Mean] + ([StDev] * 2),
                [c].[Mean] + ([StDev] * 2.5),
                [c].[Mean] + ([StDev] * 3)
        FROM    @MonthValues m
        JOIN    @Calculations c on m.Year = c.Year AND m.ATASystem = c.ATASystem
        WHERE   CONCAT(m.Year, '-', m.Month, '-', m.ATASystem, '-', m.tReliabilityFleet_ID) NOT IN (SELECT CONCAT(Year, '-', Month, '-', ATASystem, '-', tReliabilityFleet_ID) FROM tRelRepSystemReliabilityAlertLevelATASystem)

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
					'sptUpdateRelRepSystemReliabilityAlerLevelATASystem',
					ISNULL((SELECT IDENT_CURRENT('tRelRepSystemReliabilityAlertLevelATASystem')) - @IdBeforeUpdate ,0),
					ISNULL((SELECT MAX(ID) FROM tDefect), 0),
					@ErrorMessage
			)

END
GO