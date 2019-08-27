DECLARE @TableID int = (
    SELECT TOP 1    ID 
    FROM            uMasterData
    WHERE           TableName = 'tRelRepSystemReliabilityAlertLevelATASystem' 
)

----- remove camelCase -----
UPDATE  uMasterDataColumn
SET     Name = TRIM(dbo.fn_extractupper(Name))
WHERE   uMasterData_ID = @TableID

----- set read-only fields -----
UPDATE  uMasterDataColumn
SET     IsEditable = 0
WHERE   ColumnName <> 'Lock'
AND     uMasterData_ID = @TableID

----- adjust camelCase -----
UPDATE  uMasterDataColumn
SET     Name = 'ATA System'
WHERE   ColumnName = 'ATASystem'
AND     uMasterData_ID = @TableID

UPDATE  uMasterDataColumn
SET     Name = 'UCL 2.0'
WHERE   ColumnName = 'UCL20'
AND     uMasterData_ID = @TableID

UPDATE  uMasterDataColumn
SET     Name = 'UCL 2.5'
WHERE   ColumnName = 'UCL25'
AND     uMasterData_ID = @TableID

UPDATE  uMasterDataColumn
SET     Name = 'UCL 3.0'
WHERE   ColumnName = 'UCL30'
AND     uMasterData_ID = @TableID