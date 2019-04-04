/****** Object:  Table [dbo].[tRelRepSystemReliability]    Script Date: 06/03/2019 14:47:47 ******/
DROP TABLE IF EXISTS dbo.tRelRepSystemReliability
GO
/****** Object:  Table [dbo].[tRelRepSystemReliability]    Script Date: 06/03/2019 14:47:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tRelRepSystemReliability](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Lock] [bit] NOT NULL,
	[tReliabilityFleet_ID] [int] NULL,
	[Type] [nvarchar](50) NOT NULL,
	[tDefect_ID] [int] NOT NULL,
	[tRegJourney_ID] [int] NULL,
	[DefectDate] [datetime] NULL,
	[DefectDescription] [nvarchar](4000) NULL,
	[NonChargeable] [bit] NULL,
	[tATA_ID] [int] NULL,
	[ATADescription] [nvarchar](4000) NULL,
	[tReg_ID] [INT] NULL,
	[CarriedOutText] [nvarchar](4000) NULL,
	[MonthKey] [nvarchar](10) NULL,
	[Quarter] [nvarchar](10) NULL,
	[tDefectStatus_ID] [int] NULL,
	[aOperator_ID] [nvarchar](10) NULL,
	[uRALBase_ID] [int] NULL,
	[tModel_ID] [INT] NULL,
	[Cycles] [decimal](18, 0) NULL,
	[FirstDefectOnRegDate] [datetime] NULL,
	[FirstDefectOnFleetDate] [datetime] NULL,
	[DefectsPerReg] [int] NULL,
	[DefectsPerFleet] [int] NULL,
	[RegFlightCycles] [decimal](18,3) NULL,
	[FleetFlightCycles] [decimal](18,3) NULL,
	[RegDefectsPer100FC] [decimal](18, 3) NULL,
	[FleetDefectsPer100FC] [decimal](18, 3) NULL,
	[FleetAnnualDefects] [int] NULL,
	[FleetAnnualCycles] [decimal](18,3) NULL,
	[FleetMonthDefects] [int] NULL,
	[FleetMonthCycles] [decimal](18,3) NULL,
	[FleetMonthDefectsPer100FC] [decimal](18,3) NULL
) ON [PRIMARY]
GO


