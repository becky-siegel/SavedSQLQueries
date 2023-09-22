select 
distinct cast(leaddatecreated as date) as leaddate
, sum(UnauditedRevenue) AS rev
, sum(DollarCostPerUnit) AS net_rev
from ledbi.dbo.inquiry_ref (nolock)
where leaddatecreated >= '2021-01-01'
group by cast(leaddatecreated as date) 
--order by cast(leaddatecreated as date) 

order by sum(UnauditedRevenue) desc