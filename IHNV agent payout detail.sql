select 
ir.LeadID
, ir.LeadDateCreated
, ir.DialerKey
, CASE 
       WHEN (ir.ListCode = 'IHNV' AND ir.LT = 1) THEN 65
       WHEN (ir.ListCode = 'IHNV' AND ir.LT = 0) THEN 26
       ELSE (ir.UnauditedRevenue * 0.79) END AS AgentPayoutRevenue
, case when ir.listcode = 'IHNV' THEN 'Plattform' ELSE l.name END as dealset
, CASE WHEN lei.value IS NULL THEN i.CampusName ELSE lei.value END AS school_submitted

from ledbi.dbo.inquiry_ref ir

inner join plattform.enterpriseods.dbo.inquiry i (nolock)
	on i.leadid = ir.LeadID

inner join plattform.plattform_db.dbo.location l (nolock) 
	on l.locationid = i.locationid

left join plattform.plattform_db.dbo.leadextendedinfo lei (nolock)
	on lei.leadid = ir.LeadID
	and lei.name = 'portal_school_name'
	AND lei.createddatetime >= '2018-09-16'

where ir.LeadDateCreated >= '2018-09-16'
and ir.LeadDateCreated < '2018-09-30'
and ir.tsr in ('lbrewer2', 'larryb')

and ir.DialerKey is not null