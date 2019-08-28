DECLARE @TableID int = (
    SELECT TOP 1    ID 
    FROM            uMasterData
    WHERE           TableName = 'tRelRepSystemReliability' 
)

----- remove camelCase -----
UPDATE  uMasterDataColumn
SET     Name = TRIM(dbo.fn_extractupper(Name))
WHERE   uMasterData_ID = @TableID

----- remove lookups -----
DELETE FROM uMasterDataColumn
WHERE	ColumnName LIKE '%[_]ID'
AND		ColumnName NOT IN (
			'tRelRepAlertLevel_ID',
			'tATA_ID',
			'tReg_ID'
		)
AND		uMasterData_ID = @TableID

----- set read-only fields -----
UPDATE	uMasterDataColumn
SET		IsEditable = 0
WHERE	ColumnName in (
			'ReliabilityFleet',
			'Type',
			'ItemNo',
			'JourneyNo',
			'ATADescription',
			'tReg_ID',
			'AircraftMSN',
			'MonthKey',
			'Quarter',
			'DefectStatus',
			'Model',
			'Cycles',
			'FirstDefectOnRegDate',
			'FirstDefectOnFleetDate',
			'DefectsPerReg',
			'DefectsPerFleet',
			'RegFlightCycles',
			'FleetFlightCycles',
			'RegDefectsPer100FC',
			'FleetDefectsPer100FC',
			'FleetMonthDefects',
			'FleetMonthCycles',
			'FleetMonthDefectsPer100FC'
		)
AND		uMasterData_ID = @TableID

----- field-specific set up -----
UPDATE	uMasterDataColumn
SET		Name = 'Alert Level',
		LookupColumns = 'AlertLevel'
WHERE	ColumnName = 'tRelRepAlertLevel_ID'
AND		uMasterData_ID = @TableID

UPDATE	uMasterDataColumn
SET		IsVisible = 1,
		UseInFilter = 1,
		LookupColumns = 'ATA',
		Name = 'ATA'
WHERE	ColumnName = 'tATA_ID'
AND		uMasterData_ID = @TableID

UPDATE	uMasterDataColumn
SET		IsVisible = 1,
		UseInFilter = 1,
		LookupColumns = 'Reg',
		Name = 'Registration'
WHERE	ColumnName = 'tReg_ID'
AND		uMasterData_ID = @TableID

----- adjust camelCase conversion -----
UPDATE  uMasterDataColumn
SET     Name = 'ATA Chapter'
WHERE   ColumnName = 'ATAChapter'
AND		uMasterData_ID = @TableID

UPDATE  uMasterDataColumn
SET     Name = 'ATA System'
WHERE   ColumnName = 'ATASystem'
AND		uMasterData_ID = @TableID

UPDATE  uMasterDataColumn
SET     Name = 'ATA Description'
WHERE   ColumnName = 'ATADescription'
AND		uMasterData_ID = @TableID

UPDATE  uMasterDataColumn
SET     Name = 'First Defect On Reg Date'
WHERE   ColumnName = 'FirstDefectOnRegDate'
AND		uMasterData_ID = @TableID

UPDATE  uMasterDataColumn
SET     Name = 'First Defect On Fleet Date'
WHERE   ColumnName = 'FirstDefectOnFleetDate'
AND		uMasterData_ID = @TableID

-- TODO: remove Reg column from load script and table
DELETE 
FROM	uMasterDataColumn
WHERE	ColumnName = 'Reg'
AND		uMasterData_ID = @TableID

----- remove unwanted month columns
DELETE
FROM 	uMasterDataColumn
WHERE   ColumnName = 'FleetMonthDefects'
AND		uMasterData_ID = @TableID

DELETE
FROM 	uMasterDataColumn
WHERE   ColumnName = 'FleetMonthCycles'
AND		uMasterData_ID = @TableID

DELETE
FROM 	uMasterDataColumn
WHERE   ColumnName = 'FleetMonthDefectsPer100FC'
AND		uMasterData_ID = @TableID