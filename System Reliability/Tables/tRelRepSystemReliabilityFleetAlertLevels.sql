/****** Object:  Table [dbo].[tRelRepSystemReliabilityFleetAlertLevels]    Script Date: 06/03/2019 14:47:47 ******/
DROP TABLE IF EXISTS dbo.tRelRepSystemReliabilityFleetAlertLevels
GO
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