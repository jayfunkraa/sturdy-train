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
	[RecordID] [int] NOT NULL, --ID
	[tReliabilityFleet_ID] [int] NULL, --ID
	[ReliabilityFleet] [nvarchar](100) NULL, --NEW
	[Type] [nvarchar](50) NULL,
	[DefectType] [nvarchar](100) NULL,
	[tReg_ID] [INT] NULL, --ID
	[Reg] [nvarchar](10) NULL, --NEW
	[tAsset_IDReg] [int] NULL,
	[AircraftMSN] [nvarchar] (100) NULL,
	[DefectDate] [date] NULL,
	[DefectDateFormatted] [nvarchar](10) NULL,
	[tATA_ID] [int] NULL, --ID
	[ATAChapter] [nvarchar](5) NULL,
	[ATASystem] [nvarchar](5) NULL,
	[DefectDescription] [nvarchar](4000) NULL,
	[CarriedOutText] [nvarchar](4000) NULL,
	[DelayOrCancellation] [nvarchar](100) NULL,
	[TotalAircraftHours] [nvarchar](100) NULL,
	[TotalAircraftCycles] [decimal](18, 0) NULL,
	[PartNoOff] [nvarchar](max) NULL,
	[SerialNoOff] [nvarchar](max) NULL,
	[PartNoOn] [nvarchar](max) NULL,
	[SerialNoOn] [nvarchar](max) NULL,
	[uRALBase_ID] [int] NULL, --ID
	[Base] [nvarchar](100) NULL, --NEW
	[aOperator_ID] [nvarchar](10) NULL, --ID
	[Operator] [nvarchar](100) NULL, --NEW
	[JourneyNo] [nvarchar](100) NULL, --NEW
	[EmployeeCreated] [nvarchar](200) NULL,
	[EmployeeClosed] [nvarchar](200) NULL,
	[ItemNo] [nvarchar](100) NULL, --NEW
	[ATADescription] [nvarchar](4000) NULL,
	[MonthKey] [nvarchar](10) NULL,
	[Quarter] [nvarchar](10) NULL,
	[Year] [int] NULL,
	[CallingTask] [nvarchar](200) NULL,
	[CallingTaskTitle] [nvarchar](400) NULL,
	[WorkOrderTask] [nvarchar](200) NULL,
	
	[FirstDefectOnRegDateChapter] [date] NULL,
	[FirstDefectOnRegDateSystem] [date] NULL,
	[FirstDefectOnRegDateFormattedChapter] [nvarchar](10) NULL,
	[FirstDefectOnRegDateFormattedSystem] [nvarchar](10) NULL,
	[FirstDefectOnFleetDateChapter] [date] NULL,
	[FirstDefectOnFleetDateSystem] [date] NULL,
	[FirstDefectOnFleetDateFormattedChapter] [nvarchar](10) NULL,
	[FirstDefectOnFleetDateFormattedSystem] [nvarchar](10) NULL,
	[DefectsPerRegChapter] [int] NULL,
	[DefectsPerRegSystem] [int] NULL,
	[DefectsPerFleetChapter] [int] NULL,
	[DefectsPerFleetSystem] [int] NULL,
	[RegFlightCyclesChapter] [decimal](18,0) NULL,
	[RegFlightCyclesSystem] [decimal](18,0) NULL,
	[FleetFlightCyclesChapter] [decimal](18,0) NULL,
	[FleetFlightCyclesSystem] [decimal](18,0) NULL,
	[RegDefectsPer100FCChapter] [decimal](18, 3) NULL,
	[RegDefectsPer100FCSystem] [decimal](18, 3) NULL,
	[FleetDefectsPer100FCChapter] [decimal](18, 3) NULL,
	[FleetDefectsPer100FCSystem] [decimal](18, 3) NULL,
	[FleetMonthDefectsChapter] [int] NULL,
	[FleetMonthDefectsSystem] [int] NULL,
	[FleetMonthCycles] [decimal](18,3) NULL,
	[FleetMonthDefectsPer100FCChapter] [decimal](18,3) NULL,
	[FleetMonthDefectsPer100FCSystem] [decimal](18,3) NULL,
	[tRelRepAlertLevel_ID] [int] NULL
) ON [PRIMARY]
GO