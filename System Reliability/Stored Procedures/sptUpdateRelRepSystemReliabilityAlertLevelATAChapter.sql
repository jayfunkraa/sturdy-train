/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliabilityAlertLevelATAChapter]    Script Date: 06/03/2019 14:35:37 ******/
IF OBJECT_ID('dbo.sptUpdateRelRepSystemReliabilityAlertLevelATAChapter', 'U') IS NOT NULL
DROP PROCEDURE dbo.sptUpdateRelRepSystemReliabilityAlertLevelATAChapter
GO
/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepSystemReliabilityAlertLevelATAChapter]    Script Date: 06/03/2019 14:35:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jamie Hanna
-- =============================================
CREATE PROCEDURE [dbo].[sptUpdateRelRepSystemReliabilityAlertLevelATAChapter] 
	
	@FromDate datetime,
	@ToDate datetime

AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @Start DATETIME = GETUTCDATE();

    DECLARE @MonthValues TABLE (
        [Year] [int],
        [Month] [int],
        [ATAChapter] [nvarchar](5),
        [DefectsPer100FC] [decimal](18,3)
    )

    DECLARE @Calculations TABLE (
        [Year] [int],
        [ATAChapter] [nvarchar](5),
        [StDev] [decimal](18,3),
        [Mean] [decimal](18,3)
    )

    INSERT INTO @MonthValues
        SELECT	DATEPART(YYYY, r.DefectDate),
		        DATEPART(MM, r.DefectDate),
		        tATA.ATAChapter,
		        r.FleetMonthDefectsPer100FC
        FROM	tRelRepSystemReliability r
        JOIN	tATA on r.tATA_ID = tATA.ID

    INSERT INTO @Calculations
        SELECT	    DATEPART(YYYY, r.DefectDate),
		            tATA.ATAChapter,
		            STDEVP(r.FleetMonthDefectsPer100FC),
		            AVG(r.FleetMonthDefectsPer100FC)
        FROM	    tRelRepSystemReliability r
        JOIN	    tATA on r.tATA_ID = tATA.ID
        GROUP BY    DATEPART(YYYY, r.DefectDate), tATA.ATAChapter
    
    
    DECLARE @IdBeforeUpdate int = (SELECT IDENT_CURRENT('tRelRepSystemReliabilityAlertLevelATAChapter'))
	DECLARE @ErrorMessage nvarchar (200) = 'Updated Succesfully'
    
    BEGIN TRANSACTION
    BEGIN TRY
        DELETE FROM     tRelRepSystemReliabilityAlertLevelATAChapter
        WHERE           Lock = 0

        INSERT INTO tRelRepSystemReliabilityAlertLevelATAChapter (
            [Lock],
            [Year],
            [Month],
            [ATAChapter],
            [DefectsPer100FC],
            [StDev],
            [Mean],
            [UCL20],
            [UCL25],
            [UCL30]
        )

        SELECT  1,
                [m].[Year],
                [m].[Month],
                [m].[ATAChapter],
                [m].[DefectsPer100FC],
                [c].[StDev],
                [c].[Mean],
                [c].[Mean] + ([StDev] * 2),
                [c].[Mean] + ([StDev] * 2.5),
                [c].[Mean] + ([StDev] * 3)
        FROM    @MonthValues m
        JOIN    @Calculations c on m.Year = c.Year AND m.ATAChapter = c.ATAChapter
        WHERE   CONCAT(m.Year, '-', m.Month, '-', m.ATAChapter) NOT IN (SELECT CONCAT(Year, '-', Month, '-', ATAChapter) FROM tRelRepSystemReliabilityAlertLevelATAChapter)

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
					'sptUpdateRelRepSystemReliabilityAlerLevelATAChapter',
					ISNULL((SELECT IDENT_CURRENT('tRelRepSystemReliabilityAlertLevelATAhapter')) - @IdBeforeUpdate ,0),
					ISNULL((SELECT MAX(ID) FROM tDefect), 0),
					@ErrorMessage
			)

END
GO