UPDATE tRelRepSystemReliability set Lock = 0
EXEC sptUpdateRelRepSystemReliability_NOCALC '2019-01-01', '2019-01-01'
EXEC sptUpdateRelRepSystemReliability_CALC '2019-01-01', '2019-01-01'
SELECT  *
FROM    tRelRepSystemReliability