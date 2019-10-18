DECLARE @From datetime = GETDATE() - 30
DECLARE @To datetime = GETDATE()

TRUNCATE TABLE tRelRepAlertLevel
EXEC sptUpdateRelRepAlertLevel @From, @To
SELECT * FROM tRelRepAlertLevel