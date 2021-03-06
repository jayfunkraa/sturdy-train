/****** Object:  Table [dbo].[tRelRepSystemReliabilityAlertLevelATAChapter]    Script Date: 06/03/2019 14:47:47 ******/
IF EXISTS (
	SELECT 	* 
	FROM 	sys.objects 
	WHERE 	object_id = OBJECT_ID(N'[dbo].[tRelRepSystemReliabilityAlertLevelATAChapter]') 
	AND 	type = N'U' 
)
BEGIN 
	DROP TABLE [dbo].[tRelRepSystemReliabilityAlertLevelATAChapter] 
END

/****** Object:  Table [dbo].[tRelRepSystemReliabilityAlertLevelATAChapter]    Script Date: 06/03/2019 14:47:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tRelRepSystemReliabilityAlertLevelATAChapter](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Lock] [bit] NOT NULL,
	[tReliabilityFleet_ID] [int] NULL,
	[Year] [int] NOT NULL,
    [Month] [int] NOT NULL,
    [ATAChapter] [nvarchar](4) NOT NULL,
	[Count] [int] NULL,
	[DefectsPer100FC] [decimal](18, 3) NULL,
	[StDev] [decimal](18,3) NULL,
	[Mean] [decimal](18,3) NULL,
	[UCL20] [decimal](18, 3) NULL,
	[UCL25] [decimal](18, 3) NULL,
	[UCL30] [decimal](18, 3) NULL
) ON [PRIMARY]
GO
