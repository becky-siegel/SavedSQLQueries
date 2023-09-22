declare @begin_date as date
set @begin_date = DATEADD(DAY, -12, CAST(GETDATE() AS DATE))

select distinct cs.session_id, ca.value as agent_group, cs.CreatedDateTime
, c.call_center_id, t.sname as agent, c.STATUS
, s.new_step2_score_count

from ledbi.dbo.call_criteria_scorecard cs (nolock)

inner join ledbi.dbo.call_criteria_scorecard ca (nolock)
	ON ca.session_id = cs.session_id
	and ca.keyname = 'agent_group'
	and ca.value <> 'No group'
inner join ledbi.dbo.call_criteria_scorecard_response cr (nolock)
	on cr.session_id = cs.session_id
	and cr.scorecard = 773
inner join ledbi.dbo.CallLog c (nolock)
	ON c.record_id = cs.session_id
inner join ledbi.dbo.inquiry_ref ir (nolock)
	ON ir.DialerKey = c.d_record_id
inner join ledbi.dbo.TSRMGR t (nolock)
	ON t.tsr = c.tsr
	and t.Day_Date = cast(c.call_datetime as date)
left join ledbi.dbo.ScoreCard_Overall_2019 s (nolock)
	ON s.d_record_id = c.d_record_id
	and s.call_date >= DATEADD(DAY, -30, @begin_date)
LEFT JOIN dbo.call_criteria_scorecard bad_call (nolock)
	 ON cs.session_id = bad_call.session_id
	AND bad_call.keyname = 'bad_call'
	AND bad_call.CreatedDateTime >= @begin_date

where cs.CreatedDateTime >= @begin_date
and cs.keyname = 'agent'
and bad_call.session_id is null 

and s.session_id is null

--and t.Dept_Name <> ca.value

--exec ledbi.dbo.usp_ScorecardOverall_Merge
--exec ledbi.dbo.usp_ScorecardOverall_Merge_IA