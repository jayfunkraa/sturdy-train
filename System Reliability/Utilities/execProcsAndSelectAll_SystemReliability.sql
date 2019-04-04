DECLARE @From datetime = GETDATE() - 30
DECLARE @To datetime = GETDATE()

UPDATE tRelRepSystemReliability SET Lock = 0
EXEC sptUpdateRelRepSystemReliability_NOCALC @From, @To
EXEC sptUpdateRelRepSystemReliability_CALC @From, @To
SELECT * FROM tRelRepSystemReliability