DECLARE @TableID int = (
    SELECT TOP 1    ID 
    FROM            uMasterData
    WHERE           TableName = 'tRelRepAlertLevel' 
)

----- remove camelCase -----
UPDATE  uMasterDataColumn
SET     Name = TRIM(dbo.fn_extractupper(Name))
WHERE   uMasterData_ID = @TableID

----- set lookups -----
UPDATE  uMasterDataColumn
SET     LookupColumns = 'Fleet'
WHERE   ColumnName = 'tReliabilityFleet_ID'
AND     uMasterData_ID = @TableID

----- adjust camelCase -----
UPDATE  uMasterDataColumn
SET     Name = 'Reliability Fleet'
WHERE   ColumnName = 'tReliabilityFleet_ID'
AND     uMasterData_ID = @TableID

UPDATE  uMasterDataColumn
SET     Name = 'ATA Chapter'
WHERE   ColumnName = 'ATAChapter'
AND     uMasterData_ID = @TableID

----- add filters -----
UPDATE  uMasterDataColumn
SET     UseInFilter = 1
WHERE   ColumnName IN (
    'ATAChapter',
    'tReliabilityFleet_ID',
    'Year'
)
AND     uMasterData_ID = @TableID