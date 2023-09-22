SELECT 
  l.createddatetime
, l.email
, l.LeadID
, l.DayPhoneNumber
, lei.value AS school
, si.Value AS session_id

FROM plattform_db.dbo.lead l (nolock)

LEFT JOIN plattform_db.dbo.leadextendedinfo lei (NOLOCK) 
	ON lei.leadid = l.leadid
	AND lei.SourceName = 'portal_school_name'

LEFT JOIN plattform_db.dbo.leadextendedinfo si (NOLOCK) 
	ON si.leadid = l.leadid
	AND si.SourceName = 'SessionID'

WHERE l.locationid = 99999
AND l.campaignID IN (7604, 7607)
AND l.CreatedDateTime >= '2018-10-01'
AND l.CreatedDateTime < '2018-10-30'