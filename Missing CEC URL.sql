
select 
l.LeadID
, lei.value as CAProspect
, ll.LeadID AS ProspectLeadID
, llei.value As SiteSourceURL
, lllei.value AS CallCenterURL

from Plattform_DB.dbo.lead l (nolock)

left join Plattform_DB.dbo.LeadExtendedInfo lei (nolock)
       on lei.LeadID = l.LeadID
       and lei.Name = 'CAProspectId'

left join plattform_db.dbo.CAProspect cap (nolock)
       on cap.CAProspectID = lei.Value

left join plattform_db.dbo.lead ll (nolock)
       on ll.LeadID = cap.ProspectLeadID

left join Plattform_DB.dbo.LeadExtendedInfo llei (nolock)
       on llei.LeadID = ll.LeadID
       and llei.name = 'SiteSourceUrl'

left join Plattform_DB.dbo.LeadExtendedInfo lllei (nolock)
       on lllei.LeadID = ll.LeadID
       and lllei.name = 'callcenterurl'


where l.leadid in 
