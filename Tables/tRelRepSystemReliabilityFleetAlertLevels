-- Create a new table called 'tRelRepSystemReliabilityFleetAlertLevels' in schema 'SchemaName'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.tRelRepSystemReliabilityFleetAlertLevels', 'U') IS NOT NULL
DROP TABLE dbo.tRelRepSystemReliabilityFleetAlertLevels
GO
-- Create the table in the specified schema
CREATE TABLE dbo.tRelRepSystemReliabilityFleetAlertLevels
(
    [ID] [INT] IDENTITY(1,1) NOT NULL, 
    [Year] [INT] NOT NULL,
    [Fleet_ID] [INT] NOT NULL,
    [ATASystem] [NVARCHAR](5),
    [AlertLevel] [decimal](18,5) NULL
);
GO