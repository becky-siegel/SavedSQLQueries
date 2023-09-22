select 
ccl.LeadId
, ccl.CallCenterId
, ccl.DialerKey
, DATEADD(HOUR, -1, l.CreatedDate_EST) AS CreatedDate_CST
, lpc.LeadPrice
, i.Name AS Institution
, st.CountAgainstCap
, st.RealTimeDeliveryStatusName

from nexus.dbo.callcenterlead  ccl (nolock)

inner join nexus.dbo.leadtbl l (nolock)
	on l.LeadId = ccl.LeadId

inner join Nexus.dbo.RealTimeDeliveryStatus st (nolock) 
	ON st.RealTimeDeliveryStatusId = l.RealtimeDeliveryStatusId 
	
left join reporting.ACTIVE.LeadPriceScrubRate lpc (nolock)
       ON lpc.leadid = ccl.LeadId

left join nexus.dbo.ClientRelationship cr (nolock)
	ON cr.ClientRelationshipId = l.ClientRelationshipId

left join nexus.dbo.Institution i (nolock)
	ON i.InstitutionId = cr.InstitutionId

where cast(l.CreatedDate_EST as date) >= '2023-08-01'
--and callcenterid in (1, 17, 70, 72, 49)
and ccl.leadid in (
44876988,
44873551,
44854949,
44850508,
44852986,
44848635,
44845026,
44845038,
44844102,
44844319,
44800376,
44795996,
44795091,
44772245,
44760299,
44760454,
44753219,
44735260,
44732501,
44727120,
44727590)


order by l.CreatedDate_EST desc