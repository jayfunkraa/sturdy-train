DECLARE @TableID int = (
    SELECT TOP 1    ID 
    FROM            uMasterData
    WHERE           TableName = 'tRelRepComponentReliability' 
)

----- remove camelCase -----
UPDATE  uMasterDataColumn
SET     Name = TRIM(dbo.fn_extractupper(Name))
WHERE   uMasterData_ID = @TableID

----- set read-only fields -----
UPDATE	uMasterDataColumn
SET		IsEditable = 0
WHERE	ColumnName in (
    'Month',
    'Year',
    'Quarter',
    'PartNo',
    'PartDescription',
    'PartClassification',
    'SerialNo',
    'ATADescription'

		)
AND		uMasterData_ID = @TableID

----- remove columns -----
DELETE FROM uMasterDataColumn
WHERE	ColumnName IN (
            'sOrderTask_ID',
			'DateOfRemoval',
            'FlightTimeComponentWasInstalledFH',
            'FlightTimeComponentWasRemovedFH'
		)
AND		uMasterData_ID = @TableID

----- set filters -----

UPDATE	uMasterDataColumn
SET		UseInFilter = 1
WHERE	ColumnName IN (
    'PartNo',
    'PartDescription',
    'SerialNo',
    'RemovalReason',
    'tReliabilityFleet_ID',
    'tReg_ID',
    'MSN',
    'DateOfRemoval',
    'Quarter',
    'Year',
    'Unscheduled',
    'Scheduled',
    'FailOnFit',
    'Robbery',
    'ConfirmedFailure'
)
AND		uMasterData_ID = @TableID

----- field-specific set up -----
UPDATE	uMasterDataColumn
SET		Name = 'Serial No.',
		LookupColumns = 'SerialNo'
WHERE	ColumnName = 'tAsset_ID'
AND		uMasterData_ID = @TableID

UPDATE	uMasterDataColumn
SET		Name = 'ATA',
		LookupColumns = 'ATA'
WHERE	ColumnName = 'tATA_ID'
AND		uMasterData_ID = @TableID

UPDATE	uMasterDataColumn
SET		Name = 'Registration',
		LookupColumns = 'Reg'
WHERE	ColumnName = 'tReg_ID'
AND		uMasterData_ID = @TableID

UPDATE	uMasterDataColumn
SET		Name = 'Reliability Fleet',
		LookupColumns = 'Fleet'
WHERE	ColumnName = 'tReliabilityFleet_ID'
AND		uMasterData_ID = @TableID

UPDATE	uMasterDataColumn
SET		Name = 'Base',
		LookupColumns = 'Name'
WHERE	ColumnName = 'uRALBase_ID'
AND		uMasterData_ID = @TableID

UPDATE	uMasterDataColumn
SET		Name = 'Date Of Removal'
WHERE	ColumnName = 'DateOfRemovalFormatted'
AND		uMasterData_ID = @TableID

UPDATE	uMasterDataColumn
SET		Name = 'MSN'
WHERE	ColumnName = 'MSN'
AND		uMasterData_ID = @TableID
