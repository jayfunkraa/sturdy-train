/****** Object:  Table [dbo].[tRelRepSystemReliability]    Script Date: 06/03/2019 14:47:47 ******/
IF EXISTS (
	SELECT 	* 
	FROM 	sys.objects 
	WHERE 	object_id = OBJECT_ID(N'[dbo].[tRelRepSystemReliability]') 
	AND 	type = N'U' 
)
BEGIN 
	DROP TABLE [dbo].[tRelRepSystemReliability] 
END
/****** Object:  Table [dbo].[tRelRepSystemReliability]    Script Date: 06/03/2019 14:47:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tRelRepSystemReliability](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Lock] [bit] NOT NULL,
	[tReliabilityFleet_ID] [int] NULL, --ID
	[ReliabilityFleet] [nvarchar](100) NULL, --NEW
	[Type] [nvarchar](50) NULL,
	[Record_ID] [int] NOT NULL, --ID
	[ItemNo] [nvarchar](100) NULL, --NEW
	[tRegJourney_ID] [int] NULL, --ID
	[JourneyNo] [nvarchar](100) NULL, --NEW
	[DefectDate] [date] NULL,
	[DefectDescription] [nvarchar](4000) NULL,
	[CallingTask] [nvarchar](200) NULL,
	[CallingTaskTitle] [nvarchar](400) NULL,
	[WorkOrderTask] [nvarchar](200) NULL,
	[NonChargeable] [bit] NULL,
	[tATA_ID] [int] NULL, --ID
	[ATAChapter] [nvarchar](5) NULL,
	[ATASystem] [nvarchar](5) NULL,
	[ATADescription] [nvarchar](4000) NULL,
	[tReg_ID] [INT] NULL, --ID
	[Reg] [nvarchar](10) NULL, --NEW
	[CarriedOutText] [nvarchar](4000) NULL,
	[MonthKey] [nvarchar](10) NULL,
	[Quarter] [nvarchar](10) NULL,
	[aOperator_ID] [nvarchar](10) NULL, --ID
	[Operator] [nvarchar](100) NULL, --NEW
	[uRALBase_ID] [int] NULL, --ID
	[Base] [nvarchar](100) NULL, --NEW
	[Cycles] [decimal](18, 0) NULL,
	[FirstDefectOnRegDate] [date] NULL,
	[FirstDefectOnFleetDate] [date] NULL,
	[DefectsPerReg] [int] NULL,
	[DefectsPerFleet] [int] NULL,
	[RegFlightCycles] [decimal](18,3) NULL,
	[FleetFlightCycles] [decimal](18,3) NULL,
	[RegDefectsPer100FC] [decimal](18, 3) NULL,
	[FleetDefectsPer100FC] [decimal](18, 3) NULL,
	[FleetMonthDefects] [int] NULL,
	[FleetMonthCycles] [decimal](18,3) NULL,
	[FleetMonthDefectsPer100FC] [decimal](18,3) NULL,
	[tRelRepAlertLevel_ID] [int] NULL
) ON [PRIMARY]
GO


