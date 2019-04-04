/****** Object:  Table [dbo].[tRelRepSystemReliabilityAlertLevelATASystem]    Script Date: 06/03/2019 14:47:47 ******/
DROP TABLE IF EXISTS dbo.tRelRepSystemReliabilityFleetAlertLevelATASystem
GO
/****** Object:  Table [dbo].[tRelRepSystemReliabilityAlertLevelATASystem]    Script Date: 06/03/2019 14:47:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tRelRepSystemReliabilityAlertLevelATASystem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Lock] [bit] NOT NULL,
	[Year] [int] NOT NULL,
    [Month] [int] NOT NULL,
    [ATASystem] [nvarchar](5) NOT NULL,
	[Count] [int] NULL,
	[DefectsPer100FC] [decimal](18,3) NOT NULL,
	[StDev] [decimal](18,3) NULL,
	[Mean] [decimal](18, 3) NULL,
	[UCL20] [decimal](18, 3) NULL,
	[UCL25] [decimal](18, 3) NULL,
	[UCL30] [decimal](18, 3) NULL
) ON [PRIMARY]
GO