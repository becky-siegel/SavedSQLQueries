select distinct ir.DialerKey, ir.lt, count(ir.leadid) AS leads
into #update
from ledbi.dbo.inquiry_ref ir (nolock)
inner join ledbi.dbo.CallLog c (nolock)
	on c.d_record_id = ir.DialerKey
inner join ledbi.dbo.CallLogStatusMapping cl (nolock)
	on cl.CallLogStatus = c.STATUS
	and cl.IsConnect = 0
where ir.LeadDateCreated >= DATEADD(MONTH, -3, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0))
group by ir.DialerKey, ir.lt

--/*
select 
c.d_record_id, c.STATUS, u.lt, u.leads
, case when u.lt = 1 then 'Live Transfer, Successful Transfer'
	when u.leads = 1 then 'Completed Form, One form'
	when u.leads = 2 then 'Completed Form, Two forms'
	when u.leads = 3 then 'Completed Form, Three forms'
	else 'Completed Form, One form' END
--*/
/*
update c
set STATUS = case when u.lt = 1 then 'Live Transfer, Successful Transfer'
	when u.leads = 1 then 'Completed Form, One form'
	when u.leads = 2 then 'Completed Form, Two forms'
	when u.leads = 3 then 'Completed Form, Three forms'
	else 'Completed Form, One form' END
--*/
from ledbi.dbo.CallLog c
inner join #update u
	on u.DialerKey = c.d_record_id


drop table #update