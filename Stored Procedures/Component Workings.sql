with FirstDefect as 	(
	SELECT	r.ID as tReg_ID,
			d.CreatedDate,
			d.DefectItemNo,
			lce.LifeTotal
	FROM	tDefect d
	JOIN	tReg r ON d.tReg_ID = r.ID 
	JOIN	tRegJourneyLogBook ON d.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
	JOIN	tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
	JOIN	tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID and tLifeCode.RegJourneyLandings = 1
	order by d.CreatedDate, DefectItemNo
)

select	tDefect.ID as tDefect_ID,
		tDefect.CreatedDate as DefectDate,
		FirstDefect.CreatedDate as FirstDefectDate
from	tDefect
join	FirstDefect FirstDefectByReg on tDefect.tReg_ID = FirstDefect.tReg_ID

) as FirstDefect
cross apply (
		SELECT	d.CreatedDate,
				lce.LifeTotal,
		FROM	tDefect d
		JOIN	tReg r ON d.tReg_ID = r.ID 
		JOIN	tRegJourneyLogBook ON d.tRegJourney_ID = tRegJourneyLogBook.tRegJourney_ID
	JOIN	tRegJourneyLogBookLifeCodeEvents lce ON tRegJourneyLogBook.ID = lce.tRegJourneyLogBook_ID
	JOIN	tLifeCode ON lce.tLifeCode_ID = tLifeCode.ID and tLifeCode.RegJourneyLandings = 1
	WHERE	r.tReliabilityFleet_ID = @RelFleet_ID
	AND		d.tATA_ID = @ATA_ID
	GROUP BY d.ID, d.CreatedDate, lce.LifeTotal
)