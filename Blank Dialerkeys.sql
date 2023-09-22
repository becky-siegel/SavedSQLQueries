select 
DATEADD(DAY ,DATEDIFF(DAY ,0 ,ir.leaddatecreated) ,0) as lead_date
, sum(1) AS blank_dialerkeys

from ledbi.dbo.inquiry_ref ir

where ir.leaddatecreated >= '2018-02-01'
and ir.dialerkey is null
and ir.callcenterid = 1
and len(ir.tsr) = 4

group by
DATEADD(DAY ,DATEDIFF(DAY ,0 ,ir.leaddatecreated) ,0)


