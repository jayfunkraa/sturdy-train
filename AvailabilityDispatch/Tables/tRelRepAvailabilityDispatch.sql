IF EXISTS (
	SELECT 	* 
	FROM 	sys.objects 
	WHERE 	object_id = OBJECT_ID(N'[dbo].[tRelRepAvailabilityDispatch]') 
	AND 	type = 'U' 
)
BEGIN 
	DROP TABLE [dbo].[tRelRepAvailabilityDispatch] 
END
/****** Object:  Table [dbo].[tRelRepAvailabilityDispatch]    Script Date: 11/03/2019 08:41:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tRelRepAvailabilityDispatch](
    [ID] [int] IDENTITY(1,1) NOT NULL,
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
) ON [PRIMARY]
GO