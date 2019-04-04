USE [TEST]
GO

/****** Object:  Table [dbo].[tRelRepComponentReliability]    Script Date: 11/03/2019 08:41:28 ******/
DROP TABLE [dbo].[tRelRepComponentReliability]
GO

/****** Object:  Table [dbo].[tRelRepComponentReliability]    Script Date: 11/03/2019 08:41:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tRelRepComponentReliability](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateOfRemoval] [nvarchar](50) NULL,
	[Month] [nvarchar](50) NULL,
	[Year] [int] NULL,
	[Quarter] [nvarchar](50) NULL,
	[PartNo] [nvarchar](50) NULL,
	[PartDescription] [nvarchar](100) NULL,
	[RemovalReason] [nvarchar](50) NULL,
	[TaskDescription] [nvarchar](250) NULL,
	[NonChargeableFilter] [int] NULL,
	[PartClassification] [nvarchar](50) NULL,
	[SerialNo] [nvarchar](50) NULL,
	[ATA] [nvarchar](50) NULL,
	[Registration] [nvarchar](50) NULL,
	[Base] [nvarchar](50) NULL,
	[TaskRef] [nvarchar](50) NULL,
	[JourneyNo] [nvarchar](50) NULL,
	[EngineerStampNo] [nvarchar](50) NULL,
	[AogEvent] [int] NULL,
	[DelayEvent] [nvarchar](50) NULL,
	[DatePartIssuedToAircraft] [nvarchar](50) NULL,
	[PossibleRobbery] [nvarchar](50) NULL,
	[NoOfUnitsOfSamePnSnCombination] [int] NULL,
	[NoOfFleetPurchaseOrdersForPnRaisedToDate] [int] NULL,
	[PnPurchaseOrderCostToDateUSD] [nvarchar](50) NULL,
	[DateOfLastCostOnPn] [nvarchar](50) NULL,
	[CostOfLastPnUSD] [nvarchar](50) NULL,
	[TransactionCode] [nvarchar](50) NULL,
	[Vendor] [nvarchar](50) NULL,
	[ApprovedOrganisation] [nvarchar](100) NULL,
	[ComponentReleaseTagStatusOfWork] [nvarchar](50) NULL,
	[DateOnComponentReleaseCertificate] [nvarchar](50) NULL,
	[FlightTimeComponentWasInstalledFH] [float] NULL,
	[ComponentCostPerFHUSDFH] [nvarchar](50) NULL,
	[NoOfPnRemovedFromRegistration] [nvarchar](50) NULL,
	[NoOfPnRemovedFromFleet] [nvarchar](50) NULL,
	[MTBRAircraft] [nvarchar](50) NULL,
	[MTBRFleet] [nvarchar](50) NULL
) ON [PRIMARY]
GO


