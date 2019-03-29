-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jamie Hanna
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sptUpdateRelRepComponentReliability 
	-- Add the parameters for the stored procedure here
	@fromDate datetime = 0, 
	@toDate datetime = 0
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO tRelRepComponentReliability (
												DateOfRemoval,
												Month,
												Year,
												Quarter,
												PartNo,
												PartDescription,
												RemovalReason,
												TaskDescription,
												NonChargeableFilter,
												PartClassification,
												SerialNo,
												ATA,
												Registration,
												Base,
												TaskRef,
												JourneyNo,
												EngineerStampNo,
												AogEvent,
												DelayEvent,
												DatePartIssuedToAircraft,
												PossibleRobbery,
												ComponentReleaseTagStatusOfWork,
												DateOnComponentReleaseCertificate,
												FlightTimeComponentWasInstalledFH
											)
	select	IIF(h.AttachDetachDate > 0 and Action = 'Removed', h.AttachDetachDate, null),
		IIF(h.AttachDetachDate > 0 and Action = 'Removed',DATENAME(mm, h.AttachDetachDate),null),
		IIF(h.AttachDetachDate > 0 and Action = 'Removed', DATEPART(YYYY, h.AttachDetachDate), null),
		IIF(h.AttachDetachDate > 0 and Action = 'Removed', 'Q' + CAST(DATEPART(q,h.AttachDetachDate) as nvarchar(2)), null),
		sPart.PartNo,
		sPart.Description,
		vtAssetHistory.Reason,
		sOrderTask.Description,
		0 as NonChargeableFilter,
		sPartClassification.Description,
		tAsset.SerialNo,
		tATA.ATA,
		tReg.Reg,
		uRALBase.RALBase,
		IIF(h.WorkOrder <> '', h.WorkOrder + '/' + h.TaskNo, ''),
		h.JourneyNumber,
		lStamp.Stamp,
		'',
		'',
		'',
		IIF(vtAssetHistory.Reason = 'Robbery', 1, 0),
		'',
		'',
		''



from	vtAssetHistoryView h
left join	vtAssetHistory on h.tAsset_ID = vtAssetHistory.Asset_ID and h.AttachDetachDate = vtAssetHistory.CarriedOutDate
join		tAsset on h.tAsset_ID = tAsset.ID
join		sPart on tAsset.sPart_ID = sPart.ID
left join	sOrder on h.sOrder_ID = sOrder.ID
left join	sOrderTask on h.sOrderTask_ID = sOrderTask.ID and sOrderTask.sOrder_ID = sOrder.ID
join		sPartClassification on sPart.sPartClassification_ID = sPartClassification.ID
left join	tATA on sOrderTask.tATA_ID = tATA.ID
left join	uRALBase on sOrder.uRALBase_ID = uRALBase.ID
left join	lEmployeeStamp on sOrderTask.lEmployeeStamp_IDCarriedOut = lEmployeeStamp.ID
left join	lStamp on lEmployeeStamp.lStamp_ID = lStamp.ID
join		tReg on h.tReg_ID = tReg.ID

---------TESTING ONLY ---------
where h.AttachDetachDate > 0 and Action = 'Removed'
-------------------------------
--order by h.tAsset_ID

EXCEPT

SELECT DateOfRemoval,
		Month,
		Year,
		Quarter,
		PartNo COLLATE Latin1_General_BIN,
		PartDescription COLLATE Latin1_General_BIN,
		RemovalReason COLLATE Latin1_General_BIN,
		TaskDescription COLLATE Latin1_General_BIN,
		NonChargeableFilter,
		PartClassification COLLATE Latin1_General_BIN,
		SerialNo COLLATE Latin1_General_BIN,
		ATA COLLATE Latin1_General_BIN,
		Registration COLLATE Latin1_General_BIN,
		Base COLLATE Latin1_General_BIN,
		TaskRef COLLATE Latin1_General_BIN,
		JourneyNo COLLATE Latin1_General_BIN,
		EngineerStampNo COLLATE Latin1_General_BIN,
		AogEvent,
		DelayEvent,
		DatePartIssuedToAircraft COLLATE Latin1_General_BIN,
		PossibleRobbery COLLATE Latin1_General_BIN,
		ComponentReleaseTagStatusOfWork COLLATE Latin1_General_BIN,
		DateOnComponentReleaseCertificate COLLATE Latin1_General_BIN,
		FlightTimeComponentWasInstalledFH

		from tRelRepComponentReliability

END
GO
