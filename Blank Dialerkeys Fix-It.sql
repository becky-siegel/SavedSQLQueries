SET NOCOUNT ON
IF OBJECT_ID('tempdb..#pct') IS NOT NULL DROP TABLE #pct

DECLARE @begin_date AS DATETIME
SET @begin_date = '2018-02-01'


SELECT COUNT(*) FROM 
LEDBI.dbo.inquiry_ref iq (NOLOCK)
WHERE 
	iq.LeadDateCreated >= @begin_date
AND iq.CallCenterID = 1
AND iq.DialerKey IS NULL
AND LEN(iq.tsr) < 5

SELECT 
  pct.CAProspectID
, pct.DialerKey
INTO #pct
FROM 
Plattform.Plattform_Db.dbo.ProspectCallTracker pct (NOLOCK)
WHERE
pct.CreatedDateTime >= @begin_date
AND pct.CAProspectID IN (
		SELECT DISTINCT
		iq.CAProspectID
		FROM 
		LEDBI.dbo.inquiry_ref iq (NOLOCK)
		WHERE
			iq.CallCenterID = 1
		AND iq.LeadDateCreated >= @begin_date
		AND iq.DialerKey IS NULL
)

UPDATE iq
SET
iq.DialerKey = pct.DialerKey
--SELECT
--iq.DialerKey, pct.DialerKey
FROM 
LEDBI.dbo.inquiry_ref iq (NOLOCK)
INNER JOIN #pct pct ON
		iq.CAprospectID = pct.CAProspectID

WHERE 
	iq.LeadDateCreated > @begin_date
AND iq.CallCenterID = 1
AND iq.DialerKey IS NULL



IF OBJECT_ID('tempdb..#cap') IS NOT NULL DROP TABLE #cap
SELECT 
  cap.CAProspectID
, cap.Phone
INTO #cap
FROM 
Plattform.Plattform_DB.dbo.CAProspect cap (NOLOCK)
WHERE
cap.CAProspectID IN (

	SELECT 
	iq.CAProspectID
	FROM 
	LEDBI.dbo.inquiry_ref iq (NOLOCK)

	WHERE
	iq.LeadDateCreated >= @begin_date
	AND iq.DialerKey IS NULL
	AND iq.CallCEnterID = 1
	AND LEN(iq.tsr) = 4
	)

UPDATE iq
SET
iq.DialerKey = cl.d_record_id

FROM 
LEDBI.dbo.call_log cl (NOLOCK)
INNER JOIN #cap cap ON
		cap.phone = cl.ani
INNER JOIN LEDBI.dbo.inquiry_ref iq (NOLOCK) ON
		iq.CAProspectID = cap.CAProspectID
WHERE
	cl.tsr IS NOT NULL
AND cl.call_datetime >= @begin_date
AND cl.tsr <> ''
AND cl.tsr <> 'TCPA'
AND cl.appl <> 'TCPA'

	AND iq.LeadDateCreated >= @begin_date
	AND iq.DialerKey IS NULL
	AND iq.CallCEnterID = 1
	AND LEN(iq.tsr) = 4




SELECT COUNT(*) FROM 
LEDBI.dbo.inquiry_ref iq (NOLOCK)
WHERE 
	iq.LeadDateCreated >= @begin_date
AND iq.CallCenterID = 1
AND iq.DialerKey IS NULL
AND LEN(iq.tsr) < 5

