/****** Object:  Table [dbo].[tRelRepSystemReliabilityFleetAlertLevels]    Script Date: 06/03/2019 14:47:47 ******/
IF EXISTS (
	SELECT 	* 
	FROM 	sys.objects 
	WHERE 	object_id = OBJECT_ID(N'[dbo].[tRelRepSystemReliabilityFleetAlertLevels]') 
	AND 	type = N'U' 
)
BEGIN 
	DROP TABLE [dbo].[tRelRepSystemReliabilityFleetAlertLevels] 
END
/****** Object:  Table [dbo].[tRelRepSystemReliabilityFleetAlertLevels]    Script Date: 06/03/2019 14:47:47 ******/
CREATE TABLE dbo.tRelRepSystemReliabilityFleetAlertLevels
(
    [ID] [INT] IDENTITY(1,1) NOT NULL, 
    [Year] [INT] NOT NULL,
    [Fleet_ID] [INT] NOT NULL,
    [ATASystem] [NVARCHAR](5),
    [AlertLevel] [decimal](18,5) NULL
);
GO