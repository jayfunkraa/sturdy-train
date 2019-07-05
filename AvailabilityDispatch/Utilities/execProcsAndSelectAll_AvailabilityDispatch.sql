DECLARE @From datetime = GETDATE() - 30
DECLARE @To datetime = GETDATE()

UPDATE tRelRepAvailabilityDispatch SET Lock = 0
EXEC sptUpdateRelRepAvailabilityDispatch @From, @To

SELECT * FROM tRelRepAvailabilityDispatch