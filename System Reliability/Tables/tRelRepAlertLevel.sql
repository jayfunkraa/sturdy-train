-- Create a new table called 'tRelRepSystemReliabilityFleetAlertLevel' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.tRelRepAlertLevel', 'U') IS NOT NULL
DROP TABLE dbo.tRelRepAlertLevel
GO
-- Create the table in the specified schema
CREATE TABLE dbo.tRelRepAlertLevel
(
    [ID] [INT] IDENTITY(1,1) NOT NULL, 
    [Year] [nvarchar](4) NOT NULL,
    [tReliabilityFleet_ID] [INT] NOT NULL,
    [ATAChapter] [nvarchar](5) NULL,
    [AlertLevel] [decimal](18,5) NULL
);
GO