IF EXISTS (
	SELECT 	* 
	FROM 	sys.objects 
	WHERE 	object_id = OBJECT_ID(N'[dbo].[tRelRepComponentReliability]') 
	AND 	type = 'U' 
)
BEGIN 
	DROP TABLE [dbo].[tRelRepComponentReliability] 
END
/****** Object:  Table [dbo].[tRelRepComponentReliability]    Script Date: 11/03/2019 08:41:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tRelRepComponentReliability](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Lock] [bit] NOT NULL,
	[tAsset_ID] [int] NOT NULL,
	[DateOfRemoval] [datetime] NULL,
	[DateOfRemovalFormatted] [varchar] (50) NULL,
	[Month] [nvarchar](50) NULL,
	[Year] [int] NULL,
	[Quarter] [nvarchar](50) NULL,
	[PartNo] [nvarchar](50) NULL,
	[PartDescription] [nvarchar](100) NULL,
	[RemovalReason] [nvarchar](50) NULL,
	[Unscheduled] [bit] NULL,
	[Scheduled] [bit] NULL,
	[FailOnFit] [bit] NULL,
	[ConfirmedFailure] [bit] NULL,
	[TaskDescription] [nvarchar](250) NULL,
	[PartClassification] [nvarchar](50) NULL,
	[tATA_ID] [int] NULL,
	[ATADescription] [nvarchar](100) NULL,
	[tReg_ID] [int] NULL,
	[MSN] [nvarchar](50) NULL,
	[tReliabilityFleet_ID] [int] NULL,
	[uRALBase_ID] [nvarchar](50) NULL,
	[sOrderTask_ID] [int] NULL,
	[TaskNo] [nvarchar](100) NULL,
	[TechLogNo] [nvarchar](100) NULL,
	[MaintenanceTaskNo] [nvarchar](100) NULL,
	[DefectItemNo] [nvarchar](50) NULL,
	[EmployeeClosedBy] [nvarchar](100) NULL,
	[EmployeeStampClosedBy] [nvarchar](50) NULL,
	[AogEvent] [int] NULL,
	[DelayEvent] [nvarchar](50) NULL,
	[Robbery] [bit] NULL,
	[FlightTimeComponentWasInstalledFH] [decimal](18,3) NULL,
	[FlightTimeComponentWasInstalledFormatted] [nvarchar](50) NULL,
	[FlightTimeComponentWasRemovedFH] [decimal](18,3) NULL,
	[FlightTimeComponentWasRemovedFormatted] [nvarchar](50) NULL,
	[TSI] [decimal](18,3) NULL,
	[TSIFormatted] [nvarchar](50) NULL,
	[NoOfPnRemovedFromRegistration] [int] NULL,
	[NoOfPnRemovedFromFleet] [int] NULL,
	[UnscheduledRemovalsRegistration] [int] NULL,
	[UnscheduledRemovalsFleet] [int] NULL,
	[MTBRRegistration] [nvarchar](50) NULL,
	[MTBRFleet] [nvarchar](50) NULL,
	[MTBURRegistration] [nvarchar](50) NULL,
	[MTBURFleet] [nvarchar](50) NULL
) ON [PRIMARY]
GO