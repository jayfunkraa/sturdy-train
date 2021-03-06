/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepAlertLevel] ******/
IF EXISTS (
	SELECT 	* 
	FROM 	sys.objects 
	WHERE 	object_id = OBJECT_ID(N'[dbo].[sptUpdateRelRepAlertLevel]') 
	AND 	type IN (N'P', N'PC', N'X') 
)
BEGIN 
	DROP PROCEDURE [dbo].[sptUpdateRelRepAlertLevel] 
END
/****** Object:  StoredProcedure [dbo].[sptUpdateRelRepAlertLevel] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jamie Hanna
-- =============================================
CREATE PROCEDURE [dbo].[sptUpdateRelRepAlertLevel] 
	
	@FromDate datetime,
	@ToDate datetime

AS
BEGIN
	SET NOCOUNT ON;

    IF OBJECT_ID('dbo.#TempTable', 'U') IS NOT NULL
    DROP TABLE dbo.#TempTable


    CREATE TABLE #TempTable 
    (
        [Year] [nvarchar](4) COLLATE Latin1_General_CS_AS NOT NULL,
        [tReliabilityFleet_ID] [INT] NOT NULL,
        [ATAChapter] [nvarchar](5) COLLATE Latin1_General_CS_AS NULL,
        [K] [int] DEFAULT 1 NOT NULL,
        [AlertLevel] [decimal](18,5) NULL
    )

    INSERT INTO #TempTable
    (
        Year,
        tReliabilityFleet_ID,
        ATAChapter
    )

    SELECT DISTINCT     tRelRepSystemReliability.Year,
                        RelFleet.ID AS tReliabilityFleet_ID,
                        ATA.ATAChapter
    FROM                tRelRepSystemReliability
    OUTER APPLY (
        SELECT DISTINCT ATAChapter
        FROM tATA
    ) ATA
    OUTER APPLY (
        SELECT ID
        FROM tReliabilityFleet
    ) RelFleet

    EXCEPT

    SELECT  [Year],
            tReliabilityFleet_ID,
            ATAChapter
    FROM    tRelRepAlertLevel

    ORDER BY Year,
        tReliabilityFleet_ID,
        ATAChapter
    

    UPDATE  #TempTable
    SET     AlertLevel = (
                SELECT  TOP 1 DefectsPer100FC * #TempTable.K
                FROM    tRelRepSystemReliabilityAlertLevelATAChapter RelChap
                WHERE    RelChap.ATAChapter = #TempTable.ATAChapter
                            AND RelChap.tReliabilityFleet_ID = #TempTable.tReliabilityFleet_ID
                            AND RelChap.[Year] = #TempTable.[Year]
                
            )

    DECLARE @Start datetime = GETUTCDATE()
	DECLARE @IdBeforeUpdate int = (SELECT IDENT_CURRENT('tRelRepAlertLevel'))
	DECLARE @ErrorMessage nvarchar (200) = 'Updated Successfully'
	
	BEGIN TRANSACTION
	BEGIN TRY

        INSERT INTO tRelRepAlertLevel
        (
            Year,
            tReliabilityFleet_ID,
            ATAChapter,
            K,
            AlertLevel
        )

        SELECT  Year,
                tReliabilityFleet_ID,
                ATAChapter,
                K,
                AlertLevel
        FROM    #TempTable
    
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
			'sptUpdateRelRepAlertLevel',
			ISNULL((SELECT IDENT_CURRENT('tRelRepAlertLevel')) - @IdBeforeUpdate ,0),
			ISNULL( (SELECT MAX(ID) FROM tDefect), 0),
			@ErrorMessage
			)

    DROP TABLE #TempTable
END
GO