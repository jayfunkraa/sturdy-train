DECLARE @dateFrom DATE = GETDATE()
DECLARE @dateTo DATE = GETDATE() - 30

UPDATE tRelRepComponentReliability SET Lock = 0

EXEC sptUpdateRelRepComponentReliability_NOCALC @dateFrom, @dateTo

SELECT * FROM tRelRepComponentReliability