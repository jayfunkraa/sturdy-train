DECLARE @TableID int = (
    SELECT TOP 1    ID 
    FROM            uMasterData
    WHERE           TableName = 'tRelRepSystemReliability' 
)

----- add spaces on camel -----
UPDATE uMasterDataColumn
SET Name = dbo.fn_extractupper(Name)
WHERE uMasterData_ID = @TableID

----- rename, set lookups and set filters -----

UPDATE  uMasterDataColumn
SET     Name = 'Reliability Fleet', 
        LookupColumns = 'Fleet', 
        UseInFilter = 1
WHERE   uMasterData_ID = @TableID
            AND Name = 't Reliability Fleet _ ID'

UPDATE  uMasterDataColumn
SET     Name = 'Defect',
        LookupColumns = 'DefectItemNo' 
WHERE   uMasterData_ID = @TableID
            AND Name = 't Defect _ I D'

UPDATE  uMasterDataColumn
SET     Name =  'Sector',
        LookupColumns = 'JourneyNumber' 
WHERE   uMasterData_ID = @TableID
            AND Name = 't Reg Journey _ ID'

UPDATE  uMasterDataColumn
SET     Name = 'ATA', 
        LookupColumns = 'ATA',
        UseInFilter = 1
WHERE   uMasterData_ID = @TableID
            AND Name = 't  A T  A _ ID'

UPDATE  uMasterDataColumn
SET     Name = 'Registration',
        LookupColumns = 'Reg',
        UseInFilter = 1
WHERE   uMasterData_ID = @TableID
                AND Name = 't Reg _ ID'

UPDATE  uMasterDataColumn
SET     Name = 'Defect Status' 
WHERE   uMasterData_ID = @TableID
            AND Name = 't Defect Status _ I D'

UPDATE  uMasterDataColumn
SET     Name = 'Operator',
        LookupColumns = 'OperatorCode',
        UseInFilter = 1
WHERE   uMasterData_ID = @TableID
            AND Name = 'a Operator _ ID'

UPDATE  uMasterDataColumn
SET     Name = 'Base',
        LookupColumns = 'Name',
        UseInFilter = 1
WHERE   uMasterData_ID = @TableID
            AND Name = 'u R A L Base _ ID'

UPDATE uMasterDataColumn
SET Name = 'Model',
    LookupColumns = 'Model',
    UseInFilter = 1
WHERE uMasterData_ID = @TableID
            AND Name = 't Model _ ID'

----- tidy up camel -----

UPDATE  uMasterDataColumn
SET     Name = 'ATA Description'
WHERE   uMasterData_ID = @TableID
            AND Name = ' A T A Description'

UPDATE  uMasterDataColumn
SET     Name = 'First Defect On Reg Date'
WHERE   uMasterData_ID = @TableID
            AND Name = 'First  Defect On Reg  Date'

UPDATE  uMasterDataColumn
SET     Name = 'First Defect On Fleet Date'
WHERE   uMasterData_ID = @TableID
            AND Name = ' First  Defect On Fleet  Date'

UPDATE  uMasterDataColumn
SET     Name = 'Fleet Flight Cycles'
WHERE   uMasterData_ID = @TableID
            AND Name = ' Fleet Flight Cycles'

UPDATE  uMasterDataColumn
SET     Name = 'Reg Defects Per 100 FC' 
WHERE uMasterData_ID = @TableID
            AND Name = 'Reg Defects Per 1  0  0 FC'

UPDATE  uMasterDataColumn
SET     Name = 'Fleet Defects Per 100 FC' 
WHERE   uMasterData_ID = @TableID
            AND Name = ' Fleet Defects Per 1  0  0 FC'

UPDATE  uMasterDataColumn
SET     Name = 'B1900D Alert Level' 
WHERE   uMasterData_ID = @TableID
            AND Name = 'B 1 9  0  0 D Alert Level'

UPDATE  uMasterDataColumn
SET     Name = 'Defect Date'
WHERE   uMasterData_ID = @TableID
            AND Name = ' Defect Date'

UPDATE  uMasterDataColumn
SET     Name = 'Defect Description'
WHERE   uMasterData_ID = @TableID
            AND Name = ' Defect Description'