select distinct s.session_id, s.call_center_id, s.agent, c.tsr, c.STATUS, cs.agent_group, s.call_date
into #fix
from ledbi.dbo.ScoreCard_Overall_2019 s (nolock)

left join ledbi.dbo.CallLog c
	on c.d_record_id = s.d_record_id
	and c.call_datetime >= '2022-01-01'

left join (select distinct dialerkey from ledbi.dbo.inquiry_ref where LeadDateCreated >= '2022-01-01') ir
	on ir.DialerKey = s.d_record_id

left join (
	select distinct session_id * 1 as session_id, value as agent_group
	from ledbi.dbo.call_criteria_scorecard cs (nolock)
	where cs.keyname = 'agent_group'
	and cs.CreatedDateTime >= '2021-01-01'
	and len(session_id) < 10 ) cs
	on cs.session_id = s.session_id

where call_date >= '2022-01-01'
and ir.DialerKey is null
and s.call_center_id NOT IN (59, 70)

union
select distinct cs.session_id, c.call_center_id, t.sname as agent, c.tsr, c.STATUS, ca.value as agent_group, cs.CreatedDateTime AS call_date
from ledbi.dbo.call_criteria_scorecard cs (nolock)
inner join ledbi.dbo.call_criteria_scorecard ca (nolock)
	ON ca.session_id = cs.session_id
	and ca.keyname = 'agent_group'
	and ca.value <> 'No group'
inner join ledbi.dbo.call_criteria_scorecard_response cr (nolock)
	on cr.session_id = cs.session_id
	and cr.scorecard = 773
left join ledbi.dbo.CallLog c (nolock)
	ON c.record_id = cs.session_id
left join ledbi.dbo.inquiry_ref ir (nolock)
	ON ir.DialerKey = c.d_record_id
left join ledbi.dbo.TSRMGR t (nolock)
	ON t.tsr = c.tsr
	and t.Day_Date = cast(c.call_datetime as date)
where cs.CreatedDateTime >= '2022-01-01'
and cs.keyname = 'agent'
and t.Dept_Name <> ca.value

select * from #fix

/*
update c
set record_id = concat(record_id, 0) * 1
from ledbi.dbo.CallLog c
inner join #fix f
	on cast(f.session_id as float) = cast(c.record_id as float)
where c.call_datetime >= '2022-01-01'
and c.call_center_id in (1, 17)
--and c.tsr <> ''
--*/

/*
delete s
from ledbi.dbo.ScoreCard_Overall_2019 s
inner join #fix f
	on f.session_id = s.session_id
--*/

drop table #fix