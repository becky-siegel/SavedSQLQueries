declare @session_id VARCHAR(50)  set @session_id = '300000046496033'

IF OBJECT_ID('tempdb..#fix') IS NOT NULL DROP TABLE #fix

select 
distinct cs.session_id
, case when max(cs.f_id) = 0 then max(cr.f_id) else max(cs.f_id) end as f_id
, case when max(cs.review_id) = 0 then max(cr.review_id) else max(cs.review_id) end as review_id
, case when max(cs.pending_id) = 0 then max(cr.pending_id) else max(cs.pending_id) end as pending_id
, case when max(cs.x_id) = 0 then MAX(cr.x_id) else MAX(cs.x_id) end as x_id
into #fix
from ledbi.dbo.call_criteria_scorecard cs
left join ledbi.dbo.call_criteria_scorecard_response cr  on cr.session_id = cs.session_id
where cs.session_id = @session_id   group by cs.session_id
--select * from #fix

select distinct session_id, f_id, review_id, pending_id, x_id from ledbi.dbo.call_criteria_scorecard where session_id = @session_id select distinct session_id, f_id, review_id, pending_id, x_id from ledbi.dbo.call_criteria_scorecard_response where session_id = @session_id /*
update c
set c.f_id = f.f_id, c.review_id = f.review_id, c.pending_id = f.f_id, c.x_id = f.x_id
from ledbi.dbo.call_criteria_scorecard  c
inner join #fix f
	on f.session_id = c.session_id
where c.session_id = @session_id

update c
set c.f_id = f.f_id, c.review_id = f.review_id, c.pending_id = f.f_id, c.x_id = f.x_id
from ledbi.dbo.call_criteria_scorecard_response c
inner join #fix f
	on f.session_id = c.session_id
where c.session_id = @session_id
--*/