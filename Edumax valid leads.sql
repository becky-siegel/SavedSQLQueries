select 
i.LeadID
, i.LeadDateCreated
, i.Email
, i.CampaignId
, i.CampusName AS [Partner]
, i.CampaignDescription  
, lei.Value AS school
, cpi.Value AS CPI
, i.CurriculumID
, i.LocationId
, si.Value AS session_id


from EnterpriseODS.dbo.inquiry i (nolock)

inner join plattform_db.dbo.leadextendedinfo lei (nolock)
	on lei.leadid = i.LeadID
	and lei.name = 'portal_school_name'

inner JOIN plattform_db.dbo.leadextendedinfo si (NOLOCK) 
	ON si.leadid = i.leadid
	AND si.SourceName = 'SessionID'


inner join plattform_db.dbo.leadextendedinfo cpi (nolock)
	on cpi.leadid = i.LeadID
	and cpi.name = 'CPI'

where 
 i.leaddatecreated >= '2018-10-01'
and i.LeadDateCreated < '2018-10-30'
and i.AffiliateLocationId = 38406
AND i.AffiliateTypeID = 2 
AND i.IsTest = 0 
AND i.LeadStateCode IN ('Billed', 'Delivered') 
AND i.LeadStatusCode IN ('OK', 'Credited', 'Error') 
AND i.UnauditedRevenue > 0
AND i.IsRepostedFlag = 0
